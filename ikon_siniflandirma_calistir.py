# ikon_siniflandirma_calistir.py
#
# Hazirlik-asamasi ikonlarini KELIME-KOKU eslestirmesi yerine (yoğur/
# yoğurt es-sesliligi, "SÜRE ÖZETİ" satirindaki yanlis eslesme, "Kavurma
# ve Kaynatma" gibi bilesik baslik satirlari vb. -- 30 Agustos 2026
# oturumunda tekrar tekrar bulunan hatalar) bir YAPAY ZEKA GECISIYLE,
# BIR KEZ siniflandirip SONUCU veritabaninda saklar.
#
# ARTIMLI CALISIR: sadece hazirlik_ikonlari BOS olan VEYA
# hazirlik_talimati DEGISMIS (hash uyusmuyor) tarifleri isler. Zaten
# islenmis, degismemis tarifler ATLANIR -- kutuphane 241'den 1000'e
# cikinca script'i tekrar calistirmak sadece YENI/DEGISEN tarifleri
# isler, hepsini bastan degil.
#
# GRUPLU ISLEME: her tarif icin AYRI bir API cagrisi yapmak, ayni
# (uzun) sistem promptunu tekrar tekrar gonderip token israf ediyordu
# -- birden fazla tarif TEK istekte gruplaniyor.
#
# ALTMIS DOKUZUNCU DUZELTME (30 Agustos 2026): Groq'un GUNLUK (TPD)
# token limiti (200.000/gun, gpt-oss-120b icin) 240 tariflik bu isi
# GUNLERCE surecek hale getiriyordu. Kullanici ucretli bir cozum
# istemedi -- arastirma sonucu Google Gemini API'nin ucretsiz
# katmaninin (Gemini 2.0 Flash-Lite: dakikada 1.000.000 token, gunde
# 1.500 istek, KREDI KARTI GEREKTIRMIYOR) bu is icin COK daha uygun
# oldugu bulundu. Script Groq'tan Gemini'ye tasindi.
#
# CALISTIRMA: python ikon_siniflandirma_calistir.py
# GEREKEN SIRLAR: GEMINI_API_KEY (aistudio.google.com'dan, ucretsiz),
# SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.

import hashlib
import json
import os
import sys
import time

from google import genai
from google.genai import types

from asama_ikonlari import ASAMA_IKON_KOKLERI, ikon_yolu_for_eylem
from supabase import create_client

GECERLI_EYLEMLER = sorted(ASAMA_IKON_KOKLERI.keys())

MODEL = "gemini-3.5-flash-lite"  # gemini-2.0-flash-lite kaldirildi (30 Agustos 2026), Google'in onerisi bu
GRUP_BOYUTU = 12  # tek istekte kac tarif birlikte gonderilsin

SISTEM_PROMPTU = f"""Sen bir Turk yemek tarifi metnini analiz eden bir asistansin.
Sana BIRDEN FAZLA tarifin "hazirlik talimati" metni, her biri kendi
TARIF NUMARASI ve numaralandirilmis SATIRLARIYLA verilecek. Her tarifin
her satiri icin, o satirda GERCEKTEN yapilmasi talimat edilen mutfak
islemlerini asagidaki SABIT listeden secmen gerekiyor:

{', '.join(GECERLI_EYLEMLER)}

KURALLAR (cok onemli, dikkatli ol):
1. Bir satir baslik/ozet/etiket ise (ör. "**Hazırlık**", "**Isıl İşlem**",
   "**PARALEL YAPILABİLİRLİK:**", "**SÜRE ÖZETİ:**" gibi) -- bu satira
   HICBIR eylem atama, bos liste dondur. Boyle satirlar bir TALIMAT
   DEGIL, yapisal bir baslik/ozettir, icinde teknik kelimeler gecse
   bile (ör. "SÜRE ÖZETİ" icinde "demlenme ~18 dk" gecebilir ama bu
   GERCEK bir demlendirme/dinlendirme talimati DEGILDIR).
2. "yoğurt" kelimesi bir MALZEME olarak geciyorsa (ör. "yoğurdu
   çırpın", "yoğurt ekleyin") bunu "yogurma" (hamur yogurma) ile
   KARISTIRMA -- sadece GERCEKTEN hamur/karisim yogurmak/yumusatmak
   anlaminda kullanildiginda "yogurma" ata.
3. Bir satirda birden fazla gercek islem varsa (ör. "kavurup
   bulguru ekleyin, su cekilene kadar pisirin" -- hem kavurma hem
   haslama/kaynatma) HEPSINI listele.
4. Sadece yukaridaki SABIT listeden eylem adi kullan, baska hicbir
   kelime uydurma.
5. Bir satirda hicbir gercek mutfak islemi talimati yoksa (baslikler,
   malzeme listeleri, notlar, ozetler) bos liste dondur.
6. Her tarifi BAGIMSIZ degerlendir -- bir tarifteki bir kelime baska
   bir tarifin siniflandirmasini ETKILEMEMELI.

SADECE gecerli JSON ile cevap ver, baska hicbir metin ekleme:
{{"tarifler": [
  {{"tarif_index": 0, "satirlar": [{{"index": 0, "eylemler": []}}, {{"index": 1, "eylemler": ["dograma"]}}]}},
  {{"tarif_index": 1, "satirlar": [...]}}
]}}
"tarif_index" ve "index" degerleri sana verilenlerle BIREBIR uymali,
her tarifin HER satiri icin bir giris olmali."""


def _hazirlik_metni_hashle(metin):
    return hashlib.sha256(metin.encode("utf-8")).hexdigest()


def _tarif_grubu_siniflandir(client, tarif_grubu):
    """tarif_grubu: [{"satirlar": [...]}, ...] -- birden fazla tarifin
    satirlari. Donus: HER tarif icin ikonlar_by_satir listesi (ayni
    sirada)."""
    parcalar = []
    for i, tarif in enumerate(tarif_grubu):
        numarali_satirlar = "\n".join(f"  {j}: {s}" for j, s in enumerate(tarif["satirlar"]))
        parcalar.append(f"TARIF {i}:\n{numarali_satirlar}")
    kullanici_mesaji = "\n\n".join(parcalar)

    yanit = client.models.generate_content(
        model=MODEL,
        contents=kullanici_mesaji,
        config=types.GenerateContentConfig(
            system_instruction=SISTEM_PROMPTU,
            temperature=0,
            max_output_tokens=8000,
            response_mime_type="application/json",
        ),
    )
    veri = json.loads(yanit.text)

    sonuclar = [[[] for _ in tarif["satirlar"]] for tarif in tarif_grubu]
    for tarif_sonucu in veri.get("tarifler", []):
        t_idx = tarif_sonucu.get("tarif_index")
        if t_idx is None or not (0 <= t_idx < len(tarif_grubu)):
            continue
        satirlar = tarif_grubu[t_idx]["satirlar"]
        for satir_sonucu in tarif_sonucu.get("satirlar", []):
            idx = satir_sonucu.get("index")
            eylemler = satir_sonucu.get("eylemler", [])
            if idx is None or not (0 <= idx < len(satirlar)):
                continue
            ikon_yollari = []
            for eylem in eylemler:
                if eylem not in ASAMA_IKON_KOKLERI:
                    continue
                yol = ikon_yolu_for_eylem(eylem, satirlar[idx])
                if yol and yol not in ikon_yollari:
                    ikon_yollari.append(yol)
            sonuclar[t_idx][idx] = ikon_yollari

    return sonuclar


def calistir():
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("HATA: GEMINI_API_KEY ortam degiskeni/sir bulunamadi.")
        print("aistudio.google.com'dan ucretsiz bir anahtar alip")
        print('"setx GEMINI_API_KEY <anahtarin>" ile kaydet, terminali')
        print("kapatip yeniden ac.")
        sys.exit(1)

    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if not supabase_url or not supabase_service_key:
        print("HATA: SUPABASE_URL ve/veya SUPABASE_SERVICE_ROLE_KEY bulunamadi.")
        print("Supabase projenin Settings -> API sayfasindan 'Project URL' ve")
        print("'service_role' anahtarini al (ANON anahtari DEGIL -- service_role,")
        print("RLS'i atlar, cok gizli tut, hicbir zaman istemci tarafinda kullanma).")
        sys.exit(1)

    client = genai.Client(api_key=api_key)
    supabase = create_client(supabase_url, supabase_service_key)

    tarifler = (
        supabase.table("receteler")
        .select("id, ad, hazirlik_talimati, hazirlik_ikonlari")
        .is_("isletme_id", "null")
        .not_.is_("hazirlik_talimati", "null")
        .execute()
    ).data or []

    islenecekler = []
    for t in tarifler:
        mevcut_hash = _hazirlik_metni_hashle(t["hazirlik_talimati"])
        onceki = t.get("hazirlik_ikonlari") or {}
        if onceki.get("hash") != mevcut_hash:
            islenecekler.append({
                "id": t["id"],
                "ad": t["ad"],
                "hash": mevcut_hash,
                "satirlar": t["hazirlik_talimati"].splitlines(),
            })

    print(f"Toplam {len(tarifler)} tarif, {len(islenecekler)} tanesi islenecek "
          f"(yeni veya degismis). {GRUP_BOYUTU}'serli gruplar halinde gonderilecek.")

    basarili, hatali = 0, 0
    for basi in range(0, len(islenecekler), GRUP_BOYUTU):
        grup = islenecekler[basi:basi + GRUP_BOYUTU]
        isimler = ", ".join(t["ad"] for t in grup)

        for deneme in range(3):
            try:
                sonuclar = _tarif_grubu_siniflandir(client, grup)
                for tarif, ikonlar_by_satir in zip(grup, sonuclar):
                    guncelleme = supabase.table("receteler").update({
                        "hazirlik_ikonlari": {
                            "hash": tarif["hash"],
                            "ikonlar_by_satir": ikonlar_by_satir,
                        }
                    }).eq("id", tarif["id"]).execute()
                    # gecen sefer "OK" yazdi ama HICBIR SEY yazilmamisti
                    # (RLS sessizce 0 satirla sonuclaniyordu, hata
                    # FIRLATMIYORDU). Donen veri GERCEKTEN bos mu kontrol
                    # ediliyor -- boyleyse bunu SESSIZ BASARI degil, ACIK
                    # HATA olarak isliyoruz.
                    if not guncelleme.data:
                        raise RuntimeError(
                            f"Guncelleme 0 satir etkiledi (RLS engelliyor olabilir): {tarif['ad']}"
                        )
                    basarili += 1
                    print(f"  OK: {tarif['ad']}")
                break
            except Exception as e:
                hata_metni = str(e)
                # Gemini'nin kota/rate-limit hatalari genelde
                # "RESOURCE_EXHAUSTED" veya "429" iceriyor -- kisa bir
                # yeniden deneme (Gemini'de gunluk limit Groq'taki kadar
                # sert degil, dakikalik/istek bazli olma ihtimali daha
                # yuksek, bu yuzden TPD icin ozel bir "hemen dur" mantigina
                # burada gerek yok, kisa retry yeterli).
                gecici_hata_mi = (
                    "RESOURCE_EXHAUSTED" in hata_metni or "429" in hata_metni
                    or "rate limit" in hata_metni.lower()
                )
                if gecici_hata_mi and deneme < 2:
                    bekleme = 15 * (deneme + 1)
                    print(f"  BEKLENIYOR (grup: {isimler[:60]}...): rate limit, {bekleme}sn sonra tekrar denenecek...")
                    time.sleep(bekleme)
                    continue
                hatali += len(grup)
                print(f"  HATA (grup: {isimler[:60]}...): {e}")
                break
        time.sleep(0.5)

    print(f"\nTamamlandi. Basarili: {basarili}, Hatali: {hatali}")
    if hatali:
        print("Hatali olanlar icin scripti TEKRAR calistirman yeterli -- "
              "sadece onlar (hash uyusmadigi icin) yeniden denenecek.")


if __name__ == "__main__":
    calistir()
