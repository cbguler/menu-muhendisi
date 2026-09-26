# yukle_yeni_tarifler_toplu.py
#
# yukle_yeni_tarifler.py'nin TOPLU surumu: tek seferde BIRDEN FAZLA
# bolge dosyasini sirayla isler, boylece kimlik bilgilerini (SUPABASE_URL
# + SERVICE_ROLE_KEY) sadece BIR KEZ girmen yeterli olur.
#
# Kullanim: BOLGE_MODULLERI listesine yeni bir bolge partisi eklemek
# icin sadece (modul_adi, degisken_adi) ciftini listeye ekle -- import
# satirini elle degistirmen gerekmez.
#
# Ayni klasorde bulunmasi gereken dosyalar:
#   marmara_tarifleri.py, ege_tarifleri.py, akdeniz_tarifleri.py,
#   ic_anadolu_tarifleri.py, karadeniz_tarifleri.py,
#   dogu_anadolu_tarifleri.py, guneydogu_anadolu_tarifleri.py
#
# Kurulum yukle_tarifler.py ile ayni (SUPABASE_URL + SERVICE_ROLE_KEY).

import importlib
import os

from supabase import create_client

SUPABASE_URL = os.environ.get("SUPABASE_URL") or input("SUPABASE_URL: ").strip()
SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or input(
    "SUPABASE_SERVICE_ROLE_KEY: "
).strip()

supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

KATEGORI_ONCELIK = [
    "izgara", "kirmizi_et", "beyaz_et", "balik", "etli_sebze", "kuru_baklagil",
    "yumurta", "corba", "pilav", "zeytinyagli", "dolma", "pilav_makarna_borek",
    "salata", "cacik", "yogurt", "tursu", "komposto", "tatli",
]

# (modul_adi, o moduldeki tarif listesinin degisken_adi)
BOLGE_MODULLERI = [
    ("marmara_tarifleri", "MARMARA_TARIFLERI"),
    ("ege_tarifleri", "EGE_TARIFLERI"),
    ("akdeniz_tarifleri", "AKDENIZ_TARIFLERI"),
    ("ic_anadolu_tarifleri", "IC_ANADOLU_TARIFLERI"),
    ("karadeniz_tarifleri", "KARADENIZ_TARIFLERI"),
    ("dogu_anadolu_tarifleri", "DOGU_ANADOLU_TARIFLERI"),
    ("guneydogu_anadolu_tarifleri", "GUNEYDOGU_ANADOLU_TARIFLERI"),
]


def kategori_belirle(etiketler):
    for k in KATEGORI_ONCELIK:
        if k in etiketler:
            return k
    return None


def bir_bolgeyi_yukle(yeni_parti, bolge_adi, kategori_id_by_sira, mevcut_adlar, malzeme_id_by_ad):
    yeni_tarifler = [t for t in yeni_parti if t["ad"] not in mevcut_adlar]
    atlanan = len(yeni_parti) - len(yeni_tarifler)
    if atlanan:
        print(f"  {atlanan} tarif zaten var, atlanacak.")

    eksikler = set()
    for t in yeni_tarifler:
        for m in t["malzemeler"]:
            if m["ad"] not in malzeme_id_by_ad:
                eksikler.add(m["ad"])
    if eksikler:
        raise RuntimeError(
            f"[{bolge_adi}] Şu malzemeler katalogda bulunamadı: " + ", ".join(sorted(eksikler))
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
            "bolge": bolge_adi,
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
        mevcut_adlar.add(t["ad"])  # ayni isim baska bir bolge dosyasinda da varsa mukerrer eklenmesin
        print(f"    {eklenen}/{len(yeni_tarifler)}  {t['ad']}")

    print(f"  Tamamlandı: {eklenen} yeni tarif eklendi ({atlanan} zaten vardı, atlandı).")
    return eklenen, atlanan


def main():
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
    baslangic_sayisi = len(mevcut_adlar)

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

    toplam_eklenen = 0
    toplam_atlanan = 0
    for modul_adi, degisken_adi in BOLGE_MODULLERI:
        modul = importlib.import_module(modul_adi)
        yeni_parti = getattr(modul, degisken_adi)
        bolge_adi = modul.BOLGE_ADI
        print(f"\n=== {bolge_adi} ({len(yeni_parti)} tarif) ===")
        eklenen, atlanan = bir_bolgeyi_yukle(
            yeni_parti, bolge_adi, kategori_id_by_sira, mevcut_adlar, malzeme_id_by_ad
        )
        toplam_eklenen += eklenen
        toplam_atlanan += atlanan

    print(f"\nTUMU TAMAMLANDI: {toplam_eklenen} yeni tarif eklendi ({toplam_atlanan} zaten vardı, atlandı).")
    print(f"Kütüphane: {baslangic_sayisi} -> {baslangic_sayisi + toplam_eklenen} tarif.")


if __name__ == "__main__":
    main()
