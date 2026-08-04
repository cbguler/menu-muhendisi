# yukle_yeni_tarifler.py
#
# TEKRAR TEKRAR KULLANILABİLİR ETL scripti: herhangi bir yeni tarif
# partisini (bolgesel/kategori genisletmesi) Supabase'e ekler.
# yukle_tarifler.py'den farki: mevcut tarifleri ATLAR (isme gore kontrol
# eder), bu yuzden guvenle tekrar tekrar, farkli partilerle calistirilabilir.
#
# Kullanim: asagidaki iki satiri yeni partiye gore degistir, sonra calistir.
#   from karadeniz_tarifleri import KARADENIZ_TARIFLERI as YENI_PARTI, BOLGE_ADI
#
# Kurulum yukle_tarifler.py ile ayni (SUPABASE_URL + SERVICE_ROLE_KEY).

import os

from supabase import create_client

from guneydogu_tarifleri import GUNEYDOGU_TARIFLERI as YENI_PARTI, BOLGE_ADI

SUPABASE_URL = os.environ.get("SUPABASE_URL") or input("SUPABASE_URL: ").strip()
SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or input(
    "SUPABASE_SERVICE_ROLE_KEY: "
).strip()

supabase = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)

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
    print(f"{len(YENI_PARTI)} yeni tarif kontrol edilecek...")

    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", "turk").single().execute()
    ).data
    mutfak_id = mutfak["id"]

    kategoriler = (
        supabase.table("mutfak_kategorileri")
        .select("id, sira")
        .eq("mutfak_id", mutfak_id)
        .execute()
    ).data
    kategori_id_by_sira = {k["sira"]: k["id"] for k in kategoriler}

    print("Mevcut global tarifler okunuyor (tekrar eklememek icin)...")
    mevcut_receteler = (
        supabase.table("receteler").select("ad").is_("isletme_id", "null").execute()
    ).data
    mevcut_adlar = {r["ad"] for r in mevcut_receteler}

    print("Malzeme kataloğu (esanlamlilar dahil) okunuyor...")
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

    yeni_tarifler = [t for t in YENI_PARTI if t["ad"] not in mevcut_adlar]
    atlanan = len(YENI_PARTI) - len(yeni_tarifler)
    if atlanan:
        print(f"{atlanan} tarif zaten var, atlanacak.")

    eksikler = set()
    for t in yeni_tarifler:
        for m in t["malzemeler"]:
            if m["ad"] not in malzeme_id_by_ad:
                eksikler.add(m["ad"])
    if eksikler:
        raise RuntimeError(
            "Şu malzemeler katalogda bulunamadı, önce eklenmeli: " + ", ".join(sorted(eksikler))
        )

    eklenen = 0
    for t in yeni_tarifler:
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
            "bolge": BOLGE_ADI,
        }
        sonuc = supabase.table("receteler").insert(recete_satiri).execute()
        recete_id = sonuc.data[0]["id"]

        malzeme_satirlari = [
            {
                "recete_id": recete_id,
                "malzeme_id": malzeme_id_by_ad[m["ad"]],
                "miktar_gram": m["miktar_gram"],
            }
            for m in t["malzemeler"]
        ]
        supabase.table("recete_malzemeleri").insert(malzeme_satirlari).execute()

        eklenen += 1
        print(f"  {eklenen}/{len(yeni_tarifler)}  {t['ad']}")

    print(f"Tamamlandı: {eklenen} yeni tarif eklendi ({atlanan} zaten vardı, atlandı).")


if __name__ == "__main__":
    main()
