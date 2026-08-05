# asama_yukle.py
#
# TEKRAR TEKRAR KULLANILABILIR script: bir ASAMALAR sozlugunu
# ({tarif_adi: [asama_dict, ...]}) recete_asamalari/asama_malzemeleri/
# asama_bagimliliklari tablolarina isler. Ayni recete icin tekrar
# calistirilirsa, o recetenin mevcut asamalarini SILIP yeniden ekler
# (idempotent -- eski/yanlis veri birikmez).
#
# Kullanim: asagidaki import satirini yeni partiye gore degistir.

import os

from supabase import create_client

from asamalar_parti1 import ASAMALAR

SUPABASE_URL = os.environ.get("SUPABASE_URL") or input("SUPABASE_URL: ").strip()
SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or input(
    "SUPABASE_SERVICE_ROLE_KEY: "
).strip()

supabase = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)


def main():
    print(f"{len(ASAMALAR)} tarif icin asama verisi islenecek...")

    for tarif_adi, asamalar in ASAMALAR.items():
        recete = (
            supabase.table("receteler")
            .select("id")
            .eq("ad", tarif_adi)
            .is_("isletme_id", "null")
            .single()
            .execute()
        ).data
        if not recete:
            print(f"  BULUNAMADI (recete): {tarif_adi}")
            continue
        recete_id = recete["id"]

        # Mevcut asamalari sil (idempotent yeniden yukleme -- eski/yanlis
        # veri birikmesin). asama_malzemeleri/asama_bagimliliklari
        # cascade ile otomatik silinir (10_uretim_maliyet_semasi.sql'de
        # "on delete cascade" tanimli).
        supabase.table("recete_asamalari").delete().eq("recete_id", recete_id).execute()

        recete_malzemeleri = (
            supabase.table("recete_malzemeleri")
            .select("id, malzemeler(ad)")
            .eq("recete_id", recete_id)
            .execute()
        ).data
        recete_malzeme_id_by_ad = {
            rm["malzemeler"]["ad"]: rm["id"] for rm in recete_malzemeleri if rm.get("malzemeler")
        }

        asama_id_by_ad = {}
        for a in asamalar:
            satir = {
                "recete_id": recete_id,
                "ad": a["ad"],
                "sira": a["sira"],
                "sure_dakika": a["sure_dakika"],
                "isil_islem_mi": a["isil_islem_mi"],
            }
            if a["isil_islem_mi"]:
                satir.update({
                    "enerji_kaynagi": a["enerji_kaynagi"],
                    "baslangic_sicaklik": a["baslangic_sicaklik"],
                    "hedef_sicaklik": a["hedef_sicaklik"],
                    "verimlilik_orani": a["verimlilik_orani"],
                })
            yeni_asama = supabase.table("recete_asamalari").insert(satir).execute()
            asama_id = yeni_asama.data[0]["id"]
            asama_id_by_ad[a["ad"]] = asama_id

            eksik_malzeme = [m for m in a["malzemeler"] if m not in recete_malzeme_id_by_ad]
            if eksik_malzeme:
                print(f"  UYARI ({tarif_adi} / {a['ad']}): malzeme bulunamadi: {eksik_malzeme}")

            malzeme_satirlari = [
                {"asama_id": asama_id, "recete_malzeme_id": recete_malzeme_id_by_ad[m]}
                for m in a["malzemeler"] if m in recete_malzeme_id_by_ad
            ]
            if malzeme_satirlari:
                supabase.table("asama_malzemeleri").insert(malzeme_satirlari).execute()

        # Bagimliliklar (once tum asamalar eklenip ID'leri bilinmesi gerekiyor)
        for a in asamalar:
            if a["bagimli"]:
                bagimlilik_satirlari = [
                    {"asama_id": asama_id_by_ad[a["ad"]], "onceki_asama_id": asama_id_by_ad[b]}
                    for b in a["bagimli"]
                ]
                supabase.table("asama_bagimliliklari").insert(bagimlilik_satirlari).execute()

        print(f"  OK: {tarif_adi} ({len(asamalar)} asama)")

    print("\nTamamlandi.")


if __name__ == "__main__":
    main()
