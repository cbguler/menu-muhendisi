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
# GRUPLU ISLEME (30 Agustos 2026, gercek kullanimda TPD/gunluk token
# limitine takilinca eklendi): her tarif icin AYRI bir API cagrisi
# yapmak, ayni (uzun) sistem promptunu 240 KEZ tekrar tekrar
# gonderiyordu -- gunluk token butcesinin cogunu bu tekrar israf
# ediyordu. Groq'un "prompt caching" ozelligi bu modelde (gpt-oss-120b)
# DESTEKLENMIYOR (sadece Kimi K2'de var), o yuzden bu israfi onlemenin
# tek yolu: BIRDEN FAZLA tarifi TEK istekte gruplamak. Sistem promptu
# artik 240 kez degil, 240/GRUP_BOYUTU kez gonderiliyor.
#
# CALISTIRMA: python ikon_siniflandirma_calistir.py
# GEREKEN SIR: GROQ_API_KEY_IKON (Streamlit secrets'ta veya ortam
# degiskeninde) -- TrendSurf'teki GROQ_API_KEY'den KASITLI OLARAK
# FARKLI bir Groq HESABINA ait (rate limit havuzlarinin karismamasi
# icin, bkz. PROJE_NOTLARI.md).

import hashlib
import json
import os
import sys
import time

from groq import Groq

from asama_ikonlari import ASAMA_IKON_KOKLERI, ikon_yolu_for_eylem
from db import get_supabase

GECERLI_EYLEMLER = sorted(ASAMA_IKON_KOKLERI.keys())

MODEL = "openai/gpt-oss-120b"  # llama-3.3-70b-versatile 16 Agustos 2026'da tamamen kaldirildi, Groq'un resmi onerisi bu
GRUP_BOYUTU = 6  # tek istekte kac tarif birlikte gonderilsin

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

    yanit = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": SISTEM_PROMPTU},
            {"role": "user", "content": kullanici_mesaji},
        ],
        response_format={"type": "json_object"},
        temperature=0,
    )
    veri = json.loads(yanit.choices[0].message.content)

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
    api_key = os.environ.get("GROQ_API_KEY_IKON")
    if not api_key:
        print("HATA: GROQ_API_KEY_IKON ortam degiskeni/sir bulunamadi.")
        sys.exit(1)

    client = Groq(api_key=api_key)
    supabase = get_supabase()

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
                    supabase.table("receteler").update({
                        "hazirlik_ikonlari": {
                            "hash": tarif["hash"],
                            "ikonlar_by_satir": ikonlar_by_satir,
                        }
                    }).eq("id", tarif["id"]).execute()
                    basarili += 1
                    print(f"  OK: {tarif['ad']}")
                break
            except Exception as e:
                rate_limit_mi = "rate_limit" in str(e) or "429" in str(e)
                if rate_limit_mi and deneme < 2:
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
        print("Eger hata GUNLUK token limitiyle ilgiliyse (TPD), o gunku "
              "kotanin dolmasi anlamina gelir -- ertesi gun tekrar "
              "calistirinca kaldigi yerden devam eder.")


if __name__ == "__main__":
    calistir()
