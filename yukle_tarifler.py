# yukle_tarifler.py
#
# ETL scripti: tarif_verisi.py (ilk 74) + tarif_verisi_ek1.py (ek 176)
# tariflerini birlestirip Supabase'deki `receteler` ve
# `recete_malzemeleri` tablolarina GLOBAL (isletme_id = NULL) tarif olarak
# yukler. Yillik menu uretim motorunun tarif havuzunu olusturur.
#
# IDEMPOTENT: Ismi zaten `receteler`de (global) var olan tarifler atlanir --
# bu script birden fazla kez, kutuphane buyudukce tekrar tekrar calistirilabilir.
#
# ON KOSUL: 12_tarif_kutuphanesi_global_receteler.sql onceden calistirilmis
# olmali (receteler.isletme_id NULL destegi + eksik SALATALIK kalemi bu
# migration'da eklenir).
#
# GUVENLIK: Bu script SERVICE_ROLE anahtarini kullanir (RLS'i bypass eder;
# global tarif eklemek normal kullanici politikasiyla mumkun degildir).
# Bu anahtari ASLA app.py/secrets.toml icine koyma, ASLA GitHub'a commitleme.
#
# Kullanim (cmd):
#   set SUPABASE_URL=https://xxxx.supabase.co
#   set SUPABASE_SERVICE_ROLE_KEY=xxxx
#   python yukle_tarifler.py

import os

from supabase import create_client

from tarif_verisi import TARIFLER
from tarif_verisi_ek1 import TARIFLER_EK1

TUM_TARIFLER = TARIFLER + TARIFLER_EK1

SUPABASE_URL = os.environ.get("SUPABASE_URL") or input("SUPABASE_URL: ").strip()
SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or input(
    "SUPABASE_SERVICE_ROLE_KEY (Settings > API > Legacy anon, service_role API keys): "
).strip()

supabase = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)

# Kural etiketleri disinda, siniflandirma amacli birincil etikete gore
# receteler.kategori (serbest metin) alanini dolduran yardimci esleme.
KATEGORI_ONCELIK = [
    "izgara", "kirmizi_et", "beyaz_et", "balik", "etli_sebze", "kuru_baklagil",
    "yumurta", "corba", "pilav", "zeytinyagli", "dolma", "pilav_makarna_borek",
    "salata", "cacik", "yogurt", "tursu", "komposto", "tatli",
]


def kategori_belirle(etiketler):
    for k in KATEGORI_ONCELIK:
        if k in etiketler:
            return k
    return None


def main():
    print(f"{len(TUM_TARIFLER)} tarif taniniyor (mevcut kutuphane dahil).")

    print("Mutfak kategorileri (Turk mutfagi I/II/III grup) okunuyor...")
    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", "turk").single().execute()
    ).data
    if not mutfak:
        raise RuntimeError(
            "'turk' kodlu mutfak bulunamadi -- once 11_coklu_mutfak_capraz_kesim.sql calistirilmali."
        )
    mutfak_id = mutfak["id"]

    kategoriler = (
        supabase.table("mutfak_kategorileri")
        .select("id, sira")
        .eq("mutfak_id", mutfak_id)
        .execute()
    ).data
    kategori_id_by_sira = {k["sira"]: k["id"] for k in kategoriler}
    for grup in (1, 2, 3):
        if grup not in kategori_id_by_sira:
            raise RuntimeError(f"mutfak_kategorileri icinde sira={grup} bulunamadi.")

    print("Malzeme katalogu (global, isletme_id NULL) okunuyor...")
    malzemeler = (
        supabase.table("malzemeler")
        .select("id, ad, diger_adlar")
        .is_("isletme_id", "null")
        .execute()
    ).data
    malzeme_id_by_ad = {}
    for m in malzemeler:
        malzeme_id_by_ad[m["ad"]] = m["id"]
        for esanlamli in (m.get("diger_adlar") or []):
            malzeme_id_by_ad[esanlamli] = m["id"]

    print("Mevcut global tarifler (zaten yuklenmis olanlar) okunuyor...")
    mevcut_receteler = (
        supabase.table("receteler").select("ad").is_("isletme_id", "null").execute()
    ).data
    mevcut_adlar = {r["ad"] for r in mevcut_receteler}

    yuklenecekler = [t for t in TUM_TARIFLER if t["ad"] not in mevcut_adlar]
    atlanan = len(TUM_TARIFLER) - len(yuklenecekler)
    if atlanan:
        print(f"{atlanan} tarif zaten yuklu, atlanacak. {len(yuklenecekler)} yeni tarif yuklenecek.")
    if not yuklenecekler:
        print("Yuklenecek yeni tarif yok, cikiliyor.")
        return

    # Once tum malzeme adlarini dogrula -- eksik varsa hicbir sey yazmadan dur.
    eksikler = set()
    for t in yuklenecekler:
        for m in t["malzemeler"]:
            if m["ad"] not in malzeme_id_by_ad:
                eksikler.add(m["ad"])
    if eksikler:
        raise RuntimeError(
            "Su malzemeler katalogda bulunamadi, once eklenmeli: " + ", ".join(sorted(eksikler))
        )

    eklenen = 0
    for t in yuklenecekler:
        kategori = kategori_belirle(t["etiketler"])
        recete_satiri = {
            "isletme_id": None,
            "ad": t["ad"],
            "kategori": kategori,
            "porsiyon_sayisi": 1,
            "hazirlik_dakika": t["hazirlik_dakika"],
            "mutfak_kategori_id": kategori_id_by_sira[t["grup"]],
            "ozel_etiketler": t["etiketler"],
            "mevsim_etiketi": t["mevsim_etiketi"],
            "bolge": "Genel",
        }
        sonuc = supabase.table("receteler").insert(recete_satiri).execute()
        recete_id = sonuc.data[0]["id"]

        malzeme_satirlari = []
        for m in t["malzemeler"]:
            malzeme_satirlari.append(
                {
                    "recete_id": recete_id,
                    "malzeme_id": malzeme_id_by_ad[m["ad"]],
                    "miktar_gram": m["miktar_gram"],
                }
            )
        supabase.table("recete_malzemeleri").insert(malzeme_satirlari).execute()

        eklenen += 1
        print(f"  {eklenen}/{len(yuklenecekler)}  {t['ad']}")

    print(f"Tamamlandi: {eklenen} yeni tarif + malzeme iliskileri yuklendi.")


if __name__ == "__main__":
    main()
