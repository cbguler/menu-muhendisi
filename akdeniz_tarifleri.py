# akdeniz_tarifleri.py
#
# Akdeniz bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
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

BOLGE_ADI = "Akdeniz"

AKDENIZ_TARIFLERI = [
    {
        "ad": "Antalya Usulü Nohut Piyazı",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 20,
        "grup": 3,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "NOHUT", "miktar_gram": 60},
            {"ad": "KURU SOĞAN", "miktar_gram": 10},
            {"ad": "MAYDANOZ", "miktar_gram": 3},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "LİMON SUYU", "miktar_gram": 2.5},
            {"ad": "SUMAK", "miktar_gram": 0.5},
            {"ad": "TUZ", "miktar_gram": 0.8},
        ],
    },
    {
        "ad": "Mersin Tantunisi",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 25,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "DANA BONFİLE", "miktar_gram": 100},
            {"ad": "MISIR YAĞI", "miktar_gram": 6},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "YEŞİL BİBER", "miktar_gram": 15},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "SUMAK", "miktar_gram": 0.5},
            {"ad": "LAVAŞ", "miktar_gram": 50},
        ],
    },
    {
        "ad": "Adana Kebap",
        "etiketler": ["izgara", "kirmizi_et"],
        "hazirlik_dakika": 30,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "KUZU KIYMA", "miktar_gram": 90},
            {"ad": "KIRMIZI BİBER", "miktar_gram": 15},
            {"ad": "PUL BİBER", "miktar_gram": 0.8},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Hatay Usulü İçli Köfte (Etli)",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 60,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "BULGUR", "miktar_gram": 50},
            {"ad": "DANA KIYMA", "miktar_gram": 80},
            {"ad": "KURU SOĞAN", "miktar_gram": 20},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 10},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "PUL BİBER", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Antalya Şakşuka",
        "etiketler": ["zeytinyagli", "vejetaryen"],
        "hazirlik_dakika": 35,
        "grup": 2,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "PATLICAN", "miktar_gram": 50},
            {"ad": "KABAK", "miktar_gram": 30},
            {"ad": "YEŞİL BİBER", "miktar_gram": 15},
            {"ad": "DOMATES", "miktar_gram": 40},
            {"ad": "SARIMSAK", "miktar_gram": 1.5},
            {"ad": "YOĞURT (TAM)", "miktar_gram": 30},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 6},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Akdeniz Usulü Limonlu Zeytin Ezmesi",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 10,
        "grup": 3,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "ZEYTİN EZMESİ", "miktar_gram": 40},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "LİMON SUYU", "miktar_gram": 2},
            {"ad": "PUL BİBER", "miktar_gram": 0.5},
            {"ad": "KURU SOĞAN", "miktar_gram": 5},
        ],
    },
    {
        "ad": "Adana Usulü Nar Ekşili Salata",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 15,
        "grup": 3,
        "mevsim_etiketi": "sonbahar",
        "malzemeler": [
            {"ad": "MARUL", "miktar_gram": 30},
            {"ad": "NAR", "miktar_gram": 30},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 8},
            {"ad": "NAR EKŞİSİ", "miktar_gram": 3},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 3},
            {"ad": "TUZ", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Antalya Usulü Şeftali Kompostosu",
        "etiketler": ["komposto", "vejetaryen"],
        "hazirlik_dakika": 25,
        "grup": 3,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "ŞEFTALİ", "miktar_gram": 80},
            {"ad": "ŞEKER", "miktar_gram": 15},
            {"ad": "SU", "miktar_gram": 70},
        ],
    },
]
