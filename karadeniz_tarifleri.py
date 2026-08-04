# karadeniz_tarifleri.py
#
# Bolgesel genisleme -- I. Parti: KARADENİZ BÖLGESİ (20 tarif).
# Ayni format: tarif_verisi.py'deki TARIFLER listesiyle birlestirilip
# yukle_yeni_tarifler.py ile (mevcutlari atlayarak) Supabase'e eklenir.
#
# Yeni malzemeler (bu partiyle birlikte 17_karadeniz_malzemeleri_ekle.sql
# ile kataloga eklendi): KARALAHANA, FINDIK.

BOLGE_ADI = "Karadeniz"

KARADENIZ_TARIFLERI = [
    # ---- I. Grup (ana yemek) -- 8 ----
    {"ad": "Karadeniz Usulü Hamsi Buğulama", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["balik"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "HAMSİ", "miktar_gram": 180},
        {"ad": "KURU SOĞAN", "miktar_gram": 30},
        {"ad": "MAYDONOZ", "miktar_gram": 5},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Akçaabat Köfte", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["kirmizi_et", "izgara"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "SIĞIR KIYMA", "miktar_gram": 130},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "PUL BİBER", "miktar_gram": 2},
        {"ad": "TUZ", "miktar_gram": 3},
        {"ad": "KARABİBER", "miktar_gram": 1},
     ]},
    {"ad": "Karalahana Sarması (Etli)", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["etli_sebze", "dolma", "etli_zeytinyagli_dolma"], "hazirlik_dakika": 80,
     "malzemeler": [
        {"ad": "KARALAHANA", "miktar_gram": 200},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 70},
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30},
        {"ad": "MISIR UNU", "miktar_gram": 15},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Hamsili Pilav", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["balik"], "hazirlik_dakika": 40,
     "malzemeler": [
        {"ad": "HAMSİ", "miktar_gram": 150},
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50},
        {"ad": "ÇAM FISTIĞI", "miktar_gram": 10},
        {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 10},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
        {"ad": "KARABİBER", "miktar_gram": 1},
     ]},
    {"ad": "Kuymak (Muhlama)", "grup": 1, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["vejetaryen"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "MISIR UNU", "miktar_gram": 60},
        {"ad": "TEREYAĞI", "miktar_gram": 30},
        {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 60},
        {"ad": "SU", "miktar_gram": 120},
        {"ad": "TUZ", "miktar_gram": 2},
     ]},
    {"ad": "Karadeniz Usulü Palamut Izgara", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["balik", "izgara"], "hazirlik_dakika": 20,
     "malzemeler": [
        {"ad": "PALAMUT", "miktar_gram": 200},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 8},
        {"ad": "LİMON", "miktar_gram": 20},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Fındıklı Tavuk Sote", "grup": 1, "mevsim_etiketi": "sonbahar",
     "etiketler": ["beyaz_et"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "TAVUK GÖĞÜS", "miktar_gram": 150},
        {"ad": "FINDIK", "miktar_gram": 20},
        {"ad": "KURU SOĞAN", "miktar_gram": 25},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Karadeniz Usulü Fasulye Pilaki", "grup": 1, "mevsim_etiketi": "kis",
     "etiketler": ["kuru_baklagil", "zeytinyagli", "vejetaryen"], "hazirlik_dakika": 60,
     "malzemeler": [
        {"ad": "KURU FASULYE", "miktar_gram": 70},
        {"ad": "HAVUÇ", "miktar_gram": 30},
        {"ad": "KURU SOĞAN", "miktar_gram": 30},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 15},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},

    # ---- II. Grup (yardımcı yemek) -- 6 ----
    {"ad": "Karalahana Çorbası", "grup": 2, "mevsim_etiketi": "kis",
     "etiketler": ["corba"], "hazirlik_dakika": 50,
     "malzemeler": [
        {"ad": "KARALAHANA", "miktar_gram": 150},
        {"ad": "KURU FASULYE", "miktar_gram": 40},
        {"ad": "MISIR UNU", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Mısır Çorbası (Karadeniz Usulü)", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["corba", "vejetaryen"], "hazirlik_dakika": 30,
     "malzemeler": [
        {"ad": "MISIR", "miktar_gram": 120},
        {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 100},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Karadeniz Pidesi (Kıymalı)", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek"], "hazirlik_dakika": 50,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "SIĞIR KIYMA", "miktar_gram": 60},
        {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 20},
        {"ad": "KURU SOĞAN", "miktar_gram": 20},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Mısır Ekmeği", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "MISIR UNU", "miktar_gram": 80},
        {"ad": "BUĞDAY UNU", "miktar_gram": 20},
        {"ad": "SU", "miktar_gram": 60},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Fındıklı Pirinç Pilavı", "grup": 2, "mevsim_etiketi": "sonbahar",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 25,
     "malzemeler": [
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50},
        {"ad": "FINDIK", "miktar_gram": 15},
        {"ad": "TEREYAĞI", "miktar_gram": 10},
        {"ad": "TUZ", "miktar_gram": 3},
     ]},
    {"ad": "Kolot Böreği (Peynirli)", "grup": 2, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["pilav_makarna_borek", "vejetaryen"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "YUFKA", "miktar_gram": 80},
        {"ad": "LOR PEYNİRİ", "miktar_gram": 60},
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 40},
        {"ad": "TEREYAĞI", "miktar_gram": 15},
        {"ad": "TUZ", "miktar_gram": 2},
     ]},

    # ---- III. Grup (tamamlayıcılar) -- 6 ----
    {"ad": "Laz Böreği", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 55,
     "malzemeler": [
        {"ad": "YUFKA", "miktar_gram": 70},
        {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 150},
        {"ad": "MISIR NİŞASTASI", "miktar_gram": 15},
        {"ad": "ŞEKER", "miktar_gram": 25},
        {"ad": "TEREYAĞI", "miktar_gram": 15},
     ]},
    {"ad": "Kete (Karadeniz Tatlısı)", "grup": 3, "mevsim_etiketi": "yil_boyunca",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 60},
        {"ad": "ŞEKER", "miktar_gram": 20},
        {"ad": "TEREYAĞI", "miktar_gram": 20},
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 20},
     ]},
    {"ad": "Fındıklı Kurabiye", "grup": 3, "mevsim_etiketi": "sonbahar",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 35,
     "malzemeler": [
        {"ad": "BUĞDAY UNU", "miktar_gram": 50},
        {"ad": "FINDIK", "miktar_gram": 25},
        {"ad": "TEREYAĞI", "miktar_gram": 25},
        {"ad": "ŞEKER", "miktar_gram": 20},
        {"ad": "TAVUK YUMURTASI", "miktar_gram": 15},
     ]},
    {"ad": "Karadeniz Yeşil Salata", "grup": 3, "mevsim_etiketi": "ilkbahar",
     "etiketler": ["salata", "vejetaryen"], "hazirlik_dakika": 10,
     "malzemeler": [
        {"ad": "ROKA", "miktar_gram": 60},
        {"ad": "KUZU KULAĞI", "miktar_gram": 40},
        {"ad": "ZEYTİNYAĞI", "miktar_gram": 8},
        {"ad": "LİMON SUYU", "miktar_gram": 5},
     ]},
    {"ad": "Karalahana Turşusu", "grup": 3, "mevsim_etiketi": "kis",
     "etiketler": ["tursu", "vejetaryen"], "hazirlik_dakika": 5,
     "malzemeler": [
        {"ad": "KARALAHANA", "miktar_gram": 100},
        {"ad": "TUZ", "miktar_gram": 5},
        {"ad": "SİRKE", "miktar_gram": 10},
     ]},
    {"ad": "Fındıklı Sütlaç", "grup": 3, "mevsim_etiketi": "sonbahar",
     "etiketler": ["tatli", "vejetaryen"], "hazirlik_dakika": 45,
     "malzemeler": [
        {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 200},
        {"ad": "PİRİNÇ (HAM)", "miktar_gram": 15},
        {"ad": "ŞEKER", "miktar_gram": 20},
        {"ad": "FINDIK", "miktar_gram": 10},
        {"ad": "MISIR NİŞASTASI", "miktar_gram": 5},
     ]},
]
