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
# islenmis, degismemis tarifler ATLANIR.
#
# GRUPLU ISLEME: her tarif icin AYRI bir API cagrisi yapmak, ayni
# (uzun) sistem promptunu tekrar tekrar gonderip token israf ediyordu
# -- birden fazla tarif TEK istekte gruplaniyor.
#
# YETMISINCI DUZELTME (30 Agustos 2026): Gemini denendi ama Google'in
# 23 Mart 2026'dan itibaren YENI hesaplar icin zorunlu kildigi en az
# 10$'lik "prepay" sarti (kullanicinin "ucretli cozum istemiyorum"
# karariyla celisiyor) yuzunden vazgecildi. Groq'a geri donuldu, kucuk
# model (llama-3.1-8b-instant) kullanildi.
#
# YETMIS BIRINCI DUZELTME (3 Eylul 2026): llama-3.1-8b-instant
# calisirken 210/210 "model_not_found" (404) hatasi alindi. Arastirma
# gosterdi: Groq bu modeli (ve llama-3.3-70b-versatile'i) 17 Haziran
# 2026'da kullanimdan kaldirmayi duyurmus, 16 Agustos 2026'da TAMAMEN
# kapatmis -- artik hicbir sekilde erisilemiyor. Groq'un resmi rate-
# limits sayfasi DOGRUDAN kontrol edildi: onerilen yerine gecen model
# openai/gpt-oss-20b'ye gecildi, ANCAK durum llama-3.1-8b-instant'taki
# kadar iyi degil -- bu model, zaten reddettigimiz gpt-oss-120b ile
# BIREBIR AYNI limitlere sahip (30 RPM, 1K RPD, 8K TPM, 200K TPD).
# Groq'un ucretsiz katmaninda bunun disinda daha yuksek limitli genel
# amacli bir model YOK (qwen3.6-27b / qwen3.8-27b de ayni 200K TPD).
# Yani islem YAVAS olacak (gunluk kota bitince ertesi gun kaldigi
# yerden devam edecek) ama script zaten artimli oldugu icin bu
# sorunsuz calisir -- sadece .bat'i her gun tekrar calistirmak yeterli.
#
# YETMIS IKINCI DUZELTME (3 Eylul 2026): gpt-oss-20b, 12 tarifi tek
# istekte gruplarken "json_object" modunda iç içe JSON yapisini sik sik
# bozuyordu (bazen bir tarif objesi hic {} ile sarilmadan diziye
# ekleniyordu, bazen "tarifler" listesi icinde dict yerine duz string
# donuyordu). Groq'un "Structured Outputs" (strict: true, kisitlanmis
# decoding) ozelligine gecildi -- gpt-oss-20b bunu destekliyor, model
# artik token seviyesinde semaya ZORLANIYOR, semaya uymayan/bozuk JSON
# uretmesi TEKNIK OLARAK IMKANSIZ hale geldi.
#
# YETMIS UCUNCU DUZELTME (3 Eylul 2026): strict-mode duzeltmesinden
# sonra farkli bir hata cikti: "Request too large ... TPM: Limit 8000,
# Requested 10272". Matematik acik: 10272 = 2272 (gercek prompt) + 8000
# (bizim kodda sabit yazili max_tokens degeri). Yani max_tokens=8000
# TEK BASINA 8000 TPM kotasinin TAMAMINI harciyordu -- ufak bir prompt
# bile eklense siniri asiyordu. 12 tarifin siniflandirma ciktisi
# (sadece index + kisa eylem etiketleri) gercekte 8000 tokene hicbir
# zaman ihtiyac duymuyor. Cozum: max_tokens 3000'e dusuruldu (cikti
# icin fazlasiyla yeterli, TPM'de prompt icin ~5000 token pay birakiyor)
# VE GRUP_BOYUTU 12'den 8'e dusuruldu (uzun tarifler icin ekstra
# guvenlik payi).
#
# CALISTIRMA: python ikon_siniflandirma_calistir.py
# GEREKEN SIRLAR: GROQ_API_KEY_IKON, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.

import hashlib
import json
import os
import sys
import time

from groq import Groq

from asama_ikonlari import ASAMA_IKON_KOKLERI, ikon_yolu_for_eylem
from supabase import create_client

GECERLI_EYLEMLER = sorted(ASAMA_IKON_KOKLERI.keys())

MODEL = "openai/gpt-oss-20b"  # llama-3.1-8b-instant 16 Agustos 2026'da kapatildi (bkz. YETMIS BIRINCI DUZELTME). Bu modelin gunluk 200K TOKEN (TPD) duvari var -- yavas ilerleyecek, gunluk kota dolunca ertesi gun devam eder.
GRUP_BOYUTU = 8  # tek istekte kac tarif birlikte gonderilsin (12'den 8'e dusuruldu, bkz. YETMIS UCUNCU DUZELTME)

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


# YETMIS IKINCI DUZELTME (3 Eylul 2026): "json_object" modu, kucuk model
# (gpt-oss-20b) 12 tarifi tek istekte gruplarken iç içe yapıyı sık sık
# bozuyordu (kapanmamis {} , bazen "tarifler" listesi icinde dict yerine
# duz string donduruyordu -- 'str' object has no attribute 'get' hatasi
# BUNDAN kaynaklaniyordu). Groq'un resmi "Structured Outputs" belgesi
# dogrudan kontrol edildi: gpt-oss-20b, "strict: true" (kisitlanmis
# decoding) modunu DESTEKLIYOR -- bu modda model token seviyesinde
# semaya ZORLANIYOR, asla semaya uymayan/bozuk JSON uretemiyor. Asagidaki
# sema, yukaridaki JSON formatini BIREBIR tanimliyor (tum alanlar
# 'required', tum objelerde 'additionalProperties: false' -- strict
# modun zorunlu kildigi kurallar).
_EYLEM_SATIR_SEMASI = {
    "type": "object",
    "properties": {
        "index": {"type": "integer"},
        "eylemler": {
            "type": "array",
            "items": {"type": "string", "enum": GECERLI_EYLEMLER},
        },
    },
    "required": ["index", "eylemler"],
    "additionalProperties": False,
}

_TARIF_SEMASI = {
    "type": "object",
    "properties": {
        "tarif_index": {"type": "integer"},
        "satirlar": {
            "type": "array",
            "items": _EYLEM_SATIR_SEMASI,
        },
    },
    "required": ["tarif_index", "satirlar"],
    "additionalProperties": False,
}

YANIT_SEMASI = {
    "type": "object",
    "properties": {
        "tarifler": {
            "type": "array",
            "items": _TARIF_SEMASI,
        },
    },
    "required": ["tarifler"],
    "additionalProperties": False,
}


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
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "tarif_siniflandirma",
                "strict": True,
                "schema": YANIT_SEMASI,
            },
        },
        temperature=0,
        max_tokens=3000,
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

    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if not supabase_url or not supabase_service_key:
        print("HATA: SUPABASE_URL ve/veya SUPABASE_SERVICE_ROLE_KEY bulunamadi.")
        print("Supabase projenin Settings -> API sayfasindan 'Project URL' ve")
        print("'service_role' anahtarini al (ANON anahtari DEGIL -- service_role,")
        print("RLS'i atlar, cok gizli tut, hicbir zaman istemci tarafinda kullanma).")
        sys.exit(1)

    client = Groq(api_key=api_key)
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
                    if not guncelleme.data:
                        raise RuntimeError(
                            f"Guncelleme 0 satir etkiledi (RLS engelliyor olabilir): {tarif['ad']}"
                        )
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
