# talimat_yukle.py
#
# TEKRAR TEKRAR KULLANILABILIR script: TALIMATLAR sozluklerini
# ({tarif_adi: talimat_metni}) isme gore recete_id bularak
# receteler.hazirlik_talimati alanina UPDATE eder. Idempotent -- ayni
# tarif icin tekrar calistirilirsa sadece metni gunceller, hata vermez.
#
# Artik parti1 (I. Grup, 30 tarif) + parti2 (II./III. Grup, 44 tarif)
# birlikte yukleniyor. Gelecekteki partiler icin: yeni bir
# talimatlar_partiN.py yaz, asagidaki import ve TALIMATLAR birlestirme
# satirina ekle.

import os

from supabase import create_client

from talimatlar_parti1 import TALIMATLAR as TALIMATLAR_PARTI1
from talimatlar_parti2 import TALIMATLAR as TALIMATLAR_PARTI2
from talimatlar_marmara import TALIMATLAR as TALIMATLAR_MARMARA

TALIMATLAR = {**TALIMATLAR_PARTI1, **TALIMATLAR_PARTI2, **TALIMATLAR_MARMARA}

SUPABASE_URL = os.environ.get("SUPABASE_URL") or input("SUPABASE_URL: ").strip()
SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or input(
    "SUPABASE_SERVICE_ROLE_KEY: "
).strip()

supabase = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)


def main():
    print(f"{len(TALIMATLAR)} tarif icin talimat yuklenecek...")
    bulunamayan = []
    guncellenen = 0
    for ad, talimat in TALIMATLAR.items():
        sonuc = (
            supabase.table("receteler")
            .update({"hazirlik_talimati": talimat})
            .eq("ad", ad)
            .is_("isletme_id", "null")
            .execute()
        )
        if sonuc.data:
            guncellenen += 1
            print(f"  OK: {ad}")
        else:
            bulunamayan.append(ad)
            print(f"  BULUNAMADI: {ad}")

    print(f"\nTamamlandi: {guncellenen} tarif guncellendi.")
    if bulunamayan:
        print(f"Bulunamayan {len(bulunamayan)} tarif: {bulunamayan}")


if __name__ == "__main__":
    main()
