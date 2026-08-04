# dogu_anadolu_tarifleri.py
#
# Bolgesel genisleme -- VII. (ve SON) Parti: DOĞU ANADOLU BÖLGESİ (24 tarif).
# Bu parti ile 7 cografi bolgenin tamami tamamlanmis olur.
# yukle_yeni_tarifler.py ile (mevcutlari atlayarak) Supabase'e eklenir.
#
# Yeni malzeme (24_dogu_anadolu_malzemeleri_ekle.sql ile eklendi):
# OTLU PEYNİR. TULUM PEYNİRİ ve BAL zaten katalogda mevcuttu.

BOLGE_ADI = "Doğu Anadolu"

DOGU_ANADOLU_TARIFLERI = [
    # ---- I. Grup (ana yemek) -- 9 ----
    {"ad": "Cağ Kebabı", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et", "izgara"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "KUZU TANDIR", "miktar_gram": 150},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "KARABİBER", "miktar_gram": 2},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Van Usulü Kahvaltı Tabağı (Otlu Peynirli)", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["yumurta"], "hazirlik_dakika": 15,
     "malzemeler": [
        {"ad": "OTLU PEYNİR", "miktar_gram": 60},
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 100},
        {"ad": "BAL", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Kadayıf Dolması (Etli, Erzurum)", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 55,
     "malzemeler": [
        {"ad": "KADAYIF", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 90},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Erzincan Usulü Kavurmalı Yumurta", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["yumurta"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 100},
        {"ad": "PASTIRMA", "miktar_gram": 40},
        {"ad": "TEREYAĞI", "miktar_gram": 8},
     ]},
    {"ad": "Tulumlu Kuzu Tandır", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 100,
     "malzemeler": [
        {"ad": "KUZU TANDIR", "miktar_gram": 150},
        {"ad": "TULUM PEYNİRİ", "miktar_gram": 30},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
     ]},
    {"ad": "Erzurum Usulü Etli Ekmek", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 90},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Otlu Peynirli Gözleme", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["vejetaryen"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "YUFKA", "miktar_gram": 80},
        {"ad": "OTLU PEYNİR", "miktar_gram": 60},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Kavurma (Erzurum Usulü)", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "SIĞIR KIYMA", "miktar_gram": 140},
        {"ad": "KARABİBER", "miktar_gram": 2},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Erzurum Usulü Etli Nohut", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["kuru_baklagil"], "hazirlik_dakika": 55,
     "malzemeler": [
        {"ad": "NOHUT", "miktar_gram": 70},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 60},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
     ]},

    # ---- II. Grup (yardımcı yemek) -- 7 ----
    {"ad": "Ayran Aşı (Etli)", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "YOĞURT (TAM)", "miktar_gram": 150},
        {"ad": "BUĞDAY UNU", "miktar_gram": 15},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 40},
        {"ad": "KURU NANE", "miktar_gram": 1},
     ]},
    {"ad": "Doğu Anadolu Usulü Mercimek Çorbası", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "KIRMIZI MERCİMEK", "miktar_gram": 50},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
     ]},
    {"ad": "Tulumlu Bulgur Pilavı", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "BULGUR", "miktar_gram": 50},
        {"ad": "TULUM PEYNİRİ", "miktar_gram": 25},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Erzurum Usulü Kavurmalı Kuru Fasulye", "grup": 2, "mevsim_etiketi": "sonbahar",
     "etiketler": ["kuru_baklagil"], "hazirlik_dakika": 70,
     "malzemeler": [
        {"ad": "KURU FASULYE", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 50},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
     ]},
    {"ad": "Otlu Peynirli Börek", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "YUFKA", "miktar_gram": 70},
        {"ad": "OTLU PEYNİR", "miktar_gram": 50},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Nohutlu Erişte", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 50},
        {"ad": "NOHUT", "miktar_gram": 30},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Kaymaklı Bulgur Çorbası", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "BULGUR", "miktar_gram": 30},
        {"ad": "KAYMAK", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 8},
     ]},

    # ---- III. Grup (tamamlayıcılar) -- 8 ----
    {"ad": "Bal Kaymak", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "BAL", "miktar_gram": 40},
        {"ad": "KAYMAK", "miktar_gram": 80},
     ]},
    {"ad": "Erzurum Usulü Kayısı Tatlısı (Ballı)", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 15,
     "malzemeler": [
        {"ad": "KURU KAYISI", "miktar_gram": 100},
        {"ad": "BAL", "miktar_gram": 20},
        {"ad": "CEVİZ (İÇ)", "miktar_gram": 15},
     ]},
    {"ad": "Otlu Peynir Tabağı (Meze)", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "OTLU PEYNİR", "miktar_gram": 80},
        {"ad": "CEVİZ (İÇ)", "miktar_gram": 15},
     ]},
    {"ad": "Yoğurtlu Semizotu Salatası", "grup": 3, "mevsim_etiketi": "yaz",
     "etiketler": ["salata", "vejetaryen"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "SEMİZOTU", "miktar_gram": 100},
        {"ad": "YOĞURT (TAM)", "miktar_gram": 80},
        {"ad": "SARIMSAK", "miktar_gram": 3},
     ]},
    {"ad": "Ballı Ceviz Tabağı", "grup": 3, "mevsim_etiketi": "sonbahar",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "CEVİZ (İÇ)", "miktar_gram": 40},
        {"ad": "BAL", "miktar_gram": 30},
     ]},
    {"ad": "Erzurum Usulü Kete", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "ŞEKER", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 20},
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 20},
     ]},
    {"ad": "Doğu Anadolu Usulü Karışık Turşu", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tursu", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "KONSERVE TURŞU", "miktar_gram": 100},
        {"ad": "SİRKE", "miktar_gram": 10},
     ]},
    {"ad": "Doğu Anadolu Usulü Kayısı Kompostosu", "grup": 3, "mevsim_etiketi": "yaz",
     "etiketler": ["komposto", "vejetaryen"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "KAYISI", "miktar_gram": 150},
        {"ad": "ŞEKER", "miktar_gram": 20},
        {"ad": "SU", "miktar_gram": 150},
     ]},
]
