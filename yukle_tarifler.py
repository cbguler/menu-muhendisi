# yukle_tarifler.py
#
# BİR KEREYE MAHSUS ETL scripti: tarif_verisi.py içindeki 74 tariflik
# Türk mutfağı başlangıç kütüphanesini Supabase'deki `receteler` ve
# `recete_malzemeleri` tablolarına GLOBAL (isletme_id = NULL) tarif olarak
# yükler. Yıllık menü üretim motorunun tarif havuzunu oluşturur.
#
# ÖN KOŞUL: 12_tarif_kutuphanesi_global_receteler.sql önceden çalıştırılmış
# olmalı (receteler.isletme_id NULL desteği + eksik SALATALIK kalemi bu
# migration'da eklenir).
#
# GÜVENLİK: Bu script SERVICE_ROLE anahtarını kullanır (RLS'i bypass eder;
# global tarif eklemek normal kullanıcı politikasıyla mümkün değildir).
# Bu anahtarı ASLA app.py/secrets.toml içine koyma, ASLA GitHub'a commitleme.
#
# Kullanım (cmd):
#   set SUPABASE_URL=https://xxxx.supabase.co
#   set SUPABASE_SERVICE_ROLE_KEY=xxxx
#   python yukle_tarifler.py

import os

from supabase import create_client

from tarif_verisi import TARIFLER

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
    print(f"{len(TARIFLER)} tarif yüklenecek...")

    print("Mutfak kategorileri (Türk mutfağı I/II/III grup) okunuyor...")
    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", "turk").single().execute()
    ).data
    if not mutfak:
        raise RuntimeError(
            "'turk' kodlu mutfak bulunamadı -- önce 11_coklu_mutfak_capraz_kesim.sql çalıştırılmalı."
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
            raise RuntimeError(f"mutfak_kategorileri içinde sira={grup} bulunamadı.")

    print("Malzeme kataloğu (global, isletme_id NULL) okunuyor...")
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

    # Önce tüm malzeme adlarını doğrula -- eksik varsa hiçbir şey yazmadan dur.
    eksikler = set()
    for t in TARIFLER:
        for m in t["malzemeler"]:
            if m["ad"] not in malzeme_id_by_ad:
                eksikler.add(m["ad"])
    if eksikler:
        raise RuntimeError(
            "Şu malzemeler katalogda bulunamadı, önce eklenmeli: " + ", ".join(sorted(eksikler))
        )

    eklenen = 0
    for t in TARIFLER:
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
        print(f"  {eklenen}/{len(TARIFLER)}  {t['ad']}")

    print(f"Tamamlandı: {eklenen} tarif + malzeme ilişkileri yüklendi.")


if __name__ == "__main__":
    main()
