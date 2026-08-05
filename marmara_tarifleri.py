# marmara_tarifleri.py
#
# Bolgesel genisleme -- VI. Parti: MARMARA BÖLGESİ (24 tarif).
# yukle_yeni_tarifler.py ile (mevcutlari atlayarak) Supabase'e eklenir.
#
# Yeni malzemeler (23_marmara_malzemeleri_ekle.sql ile eklendi):
# KESTANE, EKMEK KADAYIFI.

BOLGE_ADI = "Marmara"

MARMARA_TARIFLERI = [
    # ---- I. Grup (ana yemek) -- 9 ----
    {"ad": "İskender Kebap", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "DANA BİFTEK", "miktar_gram": 130},
        {"ad": "PİDE", "miktar_gram": 100},
        {"ad": "YOĞURT (TAM)", "miktar_gram": 60},
        {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 15},
        {"ad": "KORNİŞON TURŞU", "miktar_gram": 20},
     ]},
    {"ad": "Hünkar Beğendi", "grup": 1, "mevsim_etiketi": "yaz",
     "etiketler": ["etli_sebze"], "hazirlik_dakika": 55,
     "malzemeler": [
        {"ad": "PATLICAN", "miktar_gram": 180},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 80},
        {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 60},
        {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 20},
        {"ad": "BUĞDAY UNU", "miktar_gram": 10},
     ]},
    {"ad": "Midye Tava", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["balik"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "MİDYE", "miktar_gram": 150},
        {"ad": "BUĞDAY UNU", "miktar_gram": 25},
        {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15},
        {"ad": "TUZ", "miktar_gram": 2},
     ]},
    {"ad": "Kestaneli Tavuk", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["beyaz_et"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "TAVUK BUT", "miktar_gram": 180},
        {"ad": "KESTANE", "miktar_gram": 60},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Kağıtta Somon (Marmara Usulü)", "grup": 1, "mevsim_etiketi": "ilkbahar",
     "etiketler": ["balik"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "SOMON", "miktar_gram": 150},
        {"ad": "LİMON", "miktar_gram": 20},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 8},
        {"ad": "TAZE DEREOTU", "miktar_gram": 5},
     ]},
    {"ad": "Bursa Usulü İnegöl Köfte", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et", "izgara"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "SIĞIR KIYMA", "miktar_gram": 140},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "SARIMSAK", "miktar_gram": 3},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Kaymaklı Mantı (Marmara Usulü)", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 65,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 60},
        {"ad": "KAYMAK", "miktar_gram": 30},
        {"ad": "SARIMSAK", "miktar_gram": 3},
     ]},
    {"ad": "Bursa Usulü Kestaneli Kuzu", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["kirmizi_et"], "hazirlik_dakika": 90,
     "malzemeler": [
        {"ad": "KUZU TANDIR", "miktar_gram": 140},
        {"ad": "KESTANE", "miktar_gram": 50},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
     ]},
    {"ad": "İstanbul Usulü Karides Güveç (Kaşarlı)", "grup": 1, "mevsim_etiketi": "yaz",
     "etiketler": ["balik"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "KARİDES", "miktar_gram": 140},
        {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 30},
        {"ad": "KONSERVE DOMATES", "miktar_gram": 40},
        {"ad": "TEREYAĞI", "miktar_gram": 8},
     ]},

    # ---- II. Grup (yardımcı yemek) -- 7 ----
    {"ad": "Kestaneli Pilav", "grup": 2, "mevsim_etiketi": "sonbahar",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 45},
        {"ad": "KESTANE", "miktar_gram": 40},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Zeytinyağlı Midye Pilaki", "grup": 2, "mevsim_etiketi": "sonbahar",
     "etiketler": ["pilav_makarna_borek"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "MİDYE", "miktar_gram": 120},
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 40},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Bursa Usulü Kıymalı Katmer", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "YUFKA", "miktar_gram": 70},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 50},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Kestaneli Bulgur Pilavı", "grup": 2, "mevsim_etiketi": "sonbahar",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "BULGUR", "miktar_gram": 45},
        {"ad": "KESTANE", "miktar_gram": 35},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},
    {"ad": "Marmara Usulü Zeytinyağlı Pırasa", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["zeytinyagli", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "PIRASA", "miktar_gram": 200},
        {"ad": "HAVUÇ", "miktar_gram": 30},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 15},
     ]},
    {"ad": "Bursa Usulü Zeytinyağlı Nohut", "grup": 2, "mevsim_etiketi": "yaz",
     "etiketler": ["zeytinyagli", "vejetaryen"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "NOHUT", "miktar_gram": 70},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 15},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
     ]},
    {"ad": "Kestaneli Çorba", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "KESTANE", "miktar_gram": 60},
        {"ad": "TAVUK SUYU", "miktar_gram": 250},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
     ]},

    # ---- III. Grup (tamamlayıcılar) -- 8 ----
    {"ad": "Kestane Şekeri", "grup": 3, "mevsim_etiketi": "kis",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "KESTANE", "miktar_gram": 100},
        {"ad": "ŞEKER", "miktar_gram": 60},
        {"ad": "SU", "miktar_gram": 80},
     ]},
    {"ad": "Kaymaklı Ekmek Kadayıfı", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "EKMEK KADAYIFI", "miktar_gram": 70},
        {"ad": "KAYMAK", "miktar_gram": 40},
        {"ad": "ŞEKER", "miktar_gram": 30},
        {"ad": "SU", "miktar_gram": 40},
     ]},
    {"ad": "Vişne Reçelli Yoğurt", "grup": 3, "mevsim_etiketi": "yaz",
     "etiketler": ["yogurt", "vejetaryen"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "YOĞURT (TAM)", "miktar_gram": 160},
        {"ad": "VİŞNE", "miktar_gram": 40},
        {"ad": "ŞEKER", "miktar_gram": 10},
     ]},
    {"ad": "Marmara Usulü Yeşil Salata", "grup": 3, "mevsim_etiketi": "ilkbahar",
     "etiketler": ["salata", "vejetaryen"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "MARUL", "miktar_gram": 100},
        {"ad": "TAZE SOĞAN", "miktar_gram": 20},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 8},
        {"ad": "LİMON SUYU", "miktar_gram": 5},
     ]},
    {"ad": "Nar Ekşili Pancar Salatası", "grup": 3, "mevsim_etiketi": "kis",
     "etiketler": ["salata", "vejetaryen"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "PANCAR", "miktar_gram": 150},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 8},
        {"ad": "NAR EKŞİSİ", "miktar_gram": 8},
     ]},
    {"ad": "Kestaneli Muhallebi", "grup": 3, "mevsim_etiketi": "kis",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "KESTANE", "miktar_gram": 50},
        {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 180},
        {"ad": "MISIR NİŞASTASI", "miktar_gram": 15},
        {"ad": "ŞEKER", "miktar_gram": 20},
     ]},
    {"ad": "Marmara Usulü Karışık Turşu", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tursu", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "KONSERVE TURŞU", "miktar_gram": 100},
        {"ad": "SİRKE", "miktar_gram": 10},
     ]},
    {"ad": "Marmara Usulü Vişne Kompostosu", "grup": 3, "mevsim_etiketi": "yaz",
     "etiketler": ["komposto", "vejetaryen"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "VİŞNE", "miktar_gram": 150},
        {"ad": "ŞEKER", "miktar_gram": 25},
        {"ad": "SU", "miktar_gram": 150},
     ]},
]
