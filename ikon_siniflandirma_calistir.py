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

SISTEM_PROMPTU = f"""Sen bir Turk yemek tarifi metnini analiz eden bir asistansin.
Sana numaralandirilmis satirlar halinde bir tarifin "hazirlik talimati"
metni verilecek. Her satir icin, o satirda GERCEKTEN yapilmasi
talimat edilen mutfak islemlerini asagidaki SABIT listeden secmen
gerekiyor:

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

SADECE gecerli JSON ile cevap ver, baska hicbir metin ekleme:
{{"satirlar": [{{"index": 0, "eylemler": []}}, {{"index": 1, "eylemler": ["dograma"]}}, ...]}}
"index" degerleri sana verilen satir numaralarina BIREBIR uymali."""


def _hazirlik_metni_hashle(metin):
    return hashlib.sha256(metin.encode("utf-8")).hexdigest()


def _tarif_siniflandir(client, hazirlik_talimati):
    satirlar = hazirlik_talimati.splitlines()
    numarali_satirlar = "\n".join(f"{i}: {s}" for i, s in enumerate(satirlar))

    yanit = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": SISTEM_PROMPTU},
            {"role": "user", "content": numarali_satirlar},
        ],
        response_format={"type": "json_object"},
        temperature=0,
    )
    veri = json.loads(yanit.choices[0].message.content)

    ikonlar_by_satir = [[] for _ in satirlar]
    for satir_sonucu in veri.get("satirlar", []):
        idx = satir_sonucu.get("index")
        eylemler = satir_sonucu.get("eylemler", [])
        if idx is None or not (0 <= idx < len(satirlar)):
            continue
        ikon_yollari = []
        for eylem in eylemler:
            if eylem not in ASAMA_IKON_KOKLERI:
                continue  # AI SABIT listenin disinda bir sey uydurduysa yok say
            yol = ikon_yolu_for_eylem(eylem, satirlar[idx])
            if yol and yol not in ikon_yollari:
                ikon_yollari.append(yol)
        ikonlar_by_satir[idx] = ikon_yollari

    return ikonlar_by_satir


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
            islenecekler.append((t, mevcut_hash))

    print(f"Toplam {len(tarifler)} tarif, {len(islenecekler)} tanesi islenecek "
          f"(yeni veya degismis).")

    basarili, hatali = 0, 0
    for t, mevcut_hash in islenecekler:
        try:
            ikonlar_by_satir = _tarif_siniflandir(client, t["hazirlik_talimati"])
            supabase.table("receteler").update({
                "hazirlik_ikonlari": {
                    "hash": mevcut_hash,
                    "ikonlar_by_satir": ikonlar_by_satir,
                }
            }).eq("id", t["id"]).execute()
            basarili += 1
            print(f"  OK: {t['ad']}")
        except Exception as e:
            hatali += 1
            print(f"  HATA ({t['ad']}): {e}")
        time.sleep(0.3)  # Groq RPM limitine karsi hafif bir yavaslatma

    print(f"\nTamamlandi. Basarili: {basarili}, Hatali: {hatali}")


if __name__ == "__main__":
    calistir()
