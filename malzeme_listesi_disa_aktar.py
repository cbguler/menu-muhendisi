# malzeme_listesi_disa_aktar.py
#
# AMAC: Yeni tarif eklerken (1000 tarif hedefi) hangi malzeme adlarinin
# GERCEKTEN veritabaninda oldugunu KESIN olarak bilmek -- yanlis/eksik
# yazilan bir malzeme adi, INSERT sirasinda hata VERMEZ, sadece o
# malzemeyi SESSIZCE atlar (join eslesmez). Sadece daha once tariflerde
# KULLANILMIS ~141 malzeme biliniyordu; veritabaninda muhtemelen daha
# fazlasi (toplam ~564) var ama hicbir tarifte kullanilmadigi icin
# gorunmuyordu.
#
# CALISTIRMA:
#   python malzeme_listesi_disa_aktar.py
#
# Cikti: malzeme_listesi.txt (proje kok dizininde, satir satir malzeme
# adlari) -- bu dosyayi yeni sohbette Claude'a geri yukle.

import os

from supabase import create_client

supabase_url = os.environ.get("SUPABASE_URL")
supabase_service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
if not supabase_url or not supabase_service_key:
    print("HATA: SUPABASE_URL ve/veya SUPABASE_SERVICE_ROLE_KEY bulunamadi.")
    raise SystemExit(1)

supabase = create_client(supabase_url, supabase_service_key)

malzemeler = (
    supabase.table("malzemeler")
    .select("ad")
    .is_("isletme_id", "null")
    .order("ad")
    .execute()
).data or []

print(f"Toplam {len(malzemeler)} global malzeme bulundu.")

with open("malzeme_listesi.txt", "w", encoding="utf-8") as f:
    for m in malzemeler:
        f.write(f"{m['ad']}\n")

print("malzeme_listesi.txt yazildi.")
