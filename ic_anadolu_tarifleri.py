# ic_anadolu_tarifleri.py
#
# Bolgesel genisleme -- V. Parti: İÇ ANADOLU BÖLGESİ (24 tarif).
# yukle_yeni_tarifler.py ile (mevcutlari atlayarak) Supabase'e eklenir.
#
# Yeni malzemeler (21_ic_anadolu_malzemeleri_ekle.sql ile eklendi):
# BUĞDAY (TAM TANE), TARHANA, BAMYA.

BOLGE_ADI = "İç Anadolu"

IC_ANADOLU_TARIFLERI = [
    # ---- I. Grup (ana yemek) -- 9 ----
    {"ad": "Keşkek", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["beyaz_et"], "hazirlik_dakika": 120,
     "malzemeler": [
        {"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 60},
        {"ad": "TAVUK BUT", "miktar_gram": 130},
        {"ad": "TEREYAĞI", "miktar_gram": 15},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Etli Ekmek (Konya)", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 90},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "DOMATES", "miktar_gram": 30},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Testi Kebabı", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 90,
     "malzemeler": [
        {"ad": "KUZU TANDIR", "miktar_gram": 140},
        {"ad": "DOMATES", "miktar_gram": 50},
        {"ad": "YEŞİL BİBER", "miktar_gram": 30},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Kayseri Mantısı", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 70,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 60},
        {"ad": "YOĞURT (TAM)", "miktar_gram": 80},
        {"ad": "SARIMSAK", "miktar_gram": 3},
        {"ad": "KURU NANE", "miktar_gram": 1},
        {"ad": "PUL BİBER", "miktar_gram": 2},
     ]},
    {"ad": "Pastırmalı Yumurta", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["yumurta"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 100},
        {"ad": "PASTIRMA", "miktar_gram": 40},
        {"ad": "TEREYAĞI", "miktar_gram": 8},
     ]},
    {"ad": "Bamya Yemeği (Etli)", "grup": 1, "mevsim_etiketi": "yaz",
     "etiketler": ["etli_sebze"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "BAMYA", "miktar_gram": 180},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 70},
        {"ad": "KONSERVE DOMATES", "miktar_gram": 40},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Kavurmalı Nohut", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["kuru_baklagil"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "NOHUT", "miktar_gram": 70},
        {"ad": "PASTIRMA", "miktar_gram": 40},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TUZ", "miktar_gram": 2},
     ]},
    {"ad": "Sucuklu Kuru Fasulye", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["kuru_baklagil"], "hazirlik_dakika": 70,
     "malzemeler": [
        {"ad": "KURU FASULYE", "miktar_gram": 60},
        {"ad": "SUCUK", "miktar_gram": 40},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 15},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Kayısılı Kuzu Tandır", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 100,
     "malzemeler": [
        {"ad": "KUZU TANDIR", "miktar_gram": 140},
        {"ad": "KAYISI", "miktar_gram": 40},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},

    # ---- II. Grup (yardımcı yemek) -- 7 ----
    {"ad": "Tarhana Çorbası", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba", "vejetaryen"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "TARHANA", "miktar_gram": 40},
        {"ad": "SU", "miktar_gram": 250},
        {"ad": "TEREYAĞI", "miktar_gram": 8},
        {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 10},
     ]},
    {"ad": "Arpa Şehriyeli Çorba", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "ŞEHRİYE", "miktar_gram": 20},
        {"ad": "TAVUK SUYU", "miktar_gram": 250},
        {"ad": "HAVUÇ", "miktar_gram": 20},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Bamya Yemeği (Zeytinyağlı)", "grup": 2, "mevsim_etiketi": "yaz",
     "etiketler": ["zeytinyagli", "vejetaryen"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "BAMYA", "miktar_gram": 180},
        {"ad": "KONSERVE DOMATES", "miktar_gram": 40},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 15},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
     ]},
    {"ad": "Şehriyeli Bulgur Pilavı", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "BULGUR", "miktar_gram": 45},
        {"ad": "ŞEHRİYE", "miktar_gram": 10},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Mantı Çorbası (Yoğurtlu)", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba", "vejetaryen"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 30},
        {"ad": "YOĞURT (TAM)", "miktar_gram": 100},
        {"ad": "KURU NANE", "miktar_gram": 1},
        {"ad": "TEREYAĞI", "miktar_gram": 8},
     ]},
    {"ad": "Erişte (Ev Yapımı Makarna)", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 55},
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Sac Böreği (Peynirli)", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "YUFKA", "miktar_gram": 70},
        {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 50},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},

    # ---- III. Grup (tamamlayıcılar) -- 8 ----
    {"ad": "Höşmerim", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "İRMİK", "miktar_gram": 40},
        {"ad": "LOR PEYNİRİ", "miktar_gram": 100},
        {"ad": "ŞEKER", "miktar_gram": 30},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Malatya Usulü Kayısı Tatlısı", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "KURU KAYISI", "miktar_gram": 100},
        {"ad": "CEVİZ (İÇ)", "miktar_gram": 20},
        {"ad": "KREMA (AĞIR)", "miktar_gram": 30},
     ]},
    {"ad": "Kuru Kayısı Kompostosu", "grup": 3, "mevsim_etiketi": "kis",
     "etiketler": ["komposto", "vejetaryen"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "KURU KAYISI", "miktar_gram": 80},
        {"ad": "ŞEKER", "miktar_gram": 15},
        {"ad": "SU", "miktar_gram": 200},
     ]},
    {"ad": "Kuru Fasulye Piyazı", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["salata", "vejetaryen"], "hazirlik_dakika": 15,
     "malzemeler": [
        {"ad": "KURU FASULYE", "miktar_gram": 100},
        {"ad": "TAZE SOĞAN", "miktar_gram": 20},
        {"ad": "MAYDONOZ", "miktar_gram": 5},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 10},
        {"ad": "LİMON SUYU", "miktar_gram": 5},
     ]},
    {"ad": "Konya Usulü Kavun Dilimi", "grup": 3, "mevsim_etiketi": "yaz",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "KAVUN", "miktar_gram": 200},
     ]},
    {"ad": "Kuru Üzümlü İrmik Helvası", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "İRMİK", "miktar_gram": 60},
        {"ad": "KURU ÜZÜM", "miktar_gram": 20},
        {"ad": "ŞEKER", "miktar_gram": 40},
        {"ad": "TEREYAĞI", "miktar_gram": 25},
        {"ad": "SU", "miktar_gram": 80},
     ]},
    {"ad": "Ev Yapımı Karışık Turşu", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tursu", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "KONSERVE TURŞU", "miktar_gram": 100},
        {"ad": "SİRKE", "miktar_gram": 10},
     ]},
    {"ad": "Kuru Üzümlü Yoğurt", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["yogurt", "vejetaryen"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "YOĞURT (TAM)", "miktar_gram": 150},
        {"ad": "KURU ÜZÜM", "miktar_gram": 20},
        {"ad": "CEVİZ (İÇ)", "miktar_gram": 10},
     ]},
]
