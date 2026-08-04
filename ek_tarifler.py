# ek_tarifler.py
#
# Kullanicinin istegiyle sonradan eklenen tekil tarif(ler). "Genel"
# bolgesine ait (74'luk baslangic kutuphanesiyle ayni kategori).
# yukle_yeni_tarifler.py ile (mevcutlari atlayarak) Supabase'e eklenir.

BOLGE_ADI = "Genel"

EK_TARIFLER = [
    {"ad": "İç Pilav", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 60},
        {"ad": "ÇAM FISTIĞI", "miktar_gram": 15},
        {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 15},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "TEREYAĞI", "miktar_gram": 15},
        {"ad": "YENİBAHAR", "miktar_gram": 1},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
]
