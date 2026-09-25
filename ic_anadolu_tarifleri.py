# ic_anadolu_tarifleri.py
#
# İç Anadolu bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
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

BOLGE_ADI = "İç Anadolu"

IC_ANADOLU_TARIFLERI = [
    {
        "ad": "Kayseri Mantısı",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 60,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "EKMEKLİK UN", "miktar_gram": 70},
            {"ad": "KUZU KIYMA", "miktar_gram": 50},
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
        "ad": "Ankara Tava (Kuzu Etli)",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 45,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 120},
            {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "TEREYAĞI", "miktar_gram": 6},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Konya Etli Ekmek",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 40,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "EKMEKLİK UN", "miktar_gram": 80},
            {"ad": "KUZU KIYMA", "miktar_gram": 70},
            {"ad": "DOMATES", "miktar_gram": 25},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "MAYDANOZ", "miktar_gram": 2},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "PUL BİBER", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Nevşehir Testi Kebabı",
        "etiketler": ["kirmizi_et", "etli_sebze"],
        "hazirlik_dakika": 90,
        "grup": 1,
        "mevsim_etiketi": "sonbahar",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 100},
            {"ad": "DOMATES", "miktar_gram": 30},
            {"ad": "YEŞİL BİBER", "miktar_gram": 20},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "MANTAR", "miktar_gram": 20},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Kayseri Yağlaması",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 35,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "LAVAŞ", "miktar_gram": 60},
            {"ad": "KUZU KIYMA", "miktar_gram": 50},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "TEREYAĞI", "miktar_gram": 6},
            {"ad": "PUL BİBER", "miktar_gram": 0.5},
            {"ad": "TUZ", "miktar_gram": 0.8},
        ],
    },
    {
        "ad": "Kapadokya Kestaneli Komposto",
        "etiketler": ["komposto", "vejetaryen"],
        "hazirlik_dakika": 30,
        "grup": 3,
        "mevsim_etiketi": "sonbahar",
        "malzemeler": [
            {"ad": "KESTANE", "miktar_gram": 50},
            {"ad": "ŞEKER", "miktar_gram": 15},
            {"ad": "SU", "miktar_gram": 70},
        ],
    },
    {
        "ad": "Kayseri Usulü Nohutlu Bulgur Pilavı",
        "etiketler": ["pilav", "vejetaryen"],
        "hazirlik_dakika": 30,
        "grup": 2,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "BULGUR", "miktar_gram": 60},
            {"ad": "NOHUT", "miktar_gram": 30},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "TEREYAĞI", "miktar_gram": 6},
            {"ad": "TAVUK SUYU", "miktar_gram": 90},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Niğde Bademli Un Helvası",
        "etiketler": ["tatli", "vejetaryen"],
        "hazirlik_dakika": 30,
        "grup": 3,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "EKMEKLİK UN", "miktar_gram": 50},
            {"ad": "TEREYAĞI", "miktar_gram": 30},
            {"ad": "ŞEKER", "miktar_gram": 40},
            {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 60},
            {"ad": "BADEM (İÇ)", "miktar_gram": 6},
        ],
    },
]
