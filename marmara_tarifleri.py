# marmara_tarifleri.py
#
# Marmara bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
# ile yuklenmek uzere hazirlandi. Malzeme miktarlari 1 PORSIYON
# (kisi basi) bazinda -- kutuphanenin geneliyle tutarli (23 Eylul
# 2026 karari: tum tarifler ayni porsiyon biriminde olmali).
# Zihinde gercekci 10 kisilik bir tencere/tepsi tasarlanip 10'a
# bolunerek yazildi (kucuk baharat miktarlarini dogru olceklemek
# icin). Tum malzeme adlari kaynak_duzeltilmis_v37.xlsx katalogundaki
# adlarla BIREBIR dogrulandi.
#
# hazirlik_talimati ve recete_asamalari BU DOSYADA YOK -- 245 tarif
# gorevindeki gibi, bu ayri bir SONRAKI asama olacak.

BOLGE_ADI = "Marmara"

MARMARA_TARIFLERI = [
    {
        "ad": "Bursa İskender Kebabı",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 25,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "DÖNER (ET, PİŞMİŞ, BURSA)", "miktar_gram": 120},
            {"ad": "PİDE", "miktar_gram": 70},
            {"ad": "TEREYAĞI", "miktar_gram": 12},
            {"ad": "YOĞURT (TAM)", "miktar_gram": 50},
            {"ad": "DOMATES", "miktar_gram": 40},
            {"ad": "TUZ", "miktar_gram": 0.8},
        ],
    },
    {
        "ad": "İnegöl Köfte",
        "etiketler": ["izgara", "kirmizi_et"],
        "hazirlik_dakika": 30,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "DANA KIYMA", "miktar_gram": 90},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "EKMEKLİK UN", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "KİMYON", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Bursa Kestaneli Kaz Dolması",
        "etiketler": ["kirmizi_et", "dolma"],
        "hazirlik_dakika": 45,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KAZ ETİ (BÜTÜN, DERİLİ)", "miktar_gram": 180},
            {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30},
            {"ad": "KESTANE", "miktar_gram": 40},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 6},
            {"ad": "TUZ", "miktar_gram": 1.5},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "YENİBAHAR", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "İstanbul Usulü Karnıyarık",
        "etiketler": ["kirmizi_et", "etli_sebze"],
        "hazirlik_dakika": 35,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "PATLICAN", "miktar_gram": 120},
            {"ad": "DANA KIYMA", "miktar_gram": 70},
            {"ad": "KURU SOĞAN", "miktar_gram": 20},
            {"ad": "DOMATES", "miktar_gram": 40},
            {"ad": "YEŞİL BİBER", "miktar_gram": 15},
            {"ad": "SARIMSAK", "miktar_gram": 1.5},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 6},
        ],
    },
    {
        "ad": "Bandırma Mantısı",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 50,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "EKMEKLİK UN", "miktar_gram": 70},
            {"ad": "DANA KIYMA", "miktar_gram": 50},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "YOĞURT (TAM)", "miktar_gram": 60},
            {"ad": "SARIMSAK", "miktar_gram": 2},
            {"ad": "TEREYAĞI", "miktar_gram": 8},
            {"ad": "PUL BİBER", "miktar_gram": 0.8},
            {"ad": "KURU NANE", "miktar_gram": 0.5},
            {"ad": "TUZ", "miktar_gram": 1.2},
        ],
    },
    {
        "ad": "Marmara Usulü Midye Tava",
        "etiketler": ["balik"],
        "hazirlik_dakika": 30,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "MİDYE", "miktar_gram": 120},
            {"ad": "EKMEKLİK UN", "miktar_gram": 25},
            {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.5},
            {"ad": "MISIR YAĞI", "miktar_gram": 30},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 10},
            {"ad": "SARIMSAK", "miktar_gram": 2},
            {"ad": "EKMEK (BEYAZ)", "miktar_gram": 8},
            {"ad": "LİMON SUYU", "miktar_gram": 3},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Kırklareli Rokalı Beyaz Peynir Salatası",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 15,
        "grup": 3,
        "mevsim_etiketi": "ilkbahar",
        "malzemeler": [
            {"ad": "ROKA", "miktar_gram": 40},
            {"ad": "EDİRNE BEYAZ PEYNİRİ", "miktar_gram": 30},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 10},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "LİMON SUYU", "miktar_gram": 2.5},
            {"ad": "TUZ", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Marmara Kestaneli Muhallebi",
        "etiketler": ["tatli", "vejetaryen"],
        "hazirlik_dakika": 30,
        "grup": 3,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 150},
            {"ad": "KESTANE", "miktar_gram": 40},
            {"ad": "ŞEKER", "miktar_gram": 25},
            {"ad": "MISIR NİŞASTASI", "miktar_gram": 8},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 6},
        ],
    },
]
