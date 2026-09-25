# guneydogu_anadolu_tarifleri.py
#
# Güneydoğu Anadolu bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
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

BOLGE_ADI = "Güneydoğu Anadolu"

GUNEYDOGU_ANADOLU_TARIFLERI = [
    {
        "ad": "Gaziantep Alinazik Kebabı",
        "etiketler": ["kirmizi_et", "etli_sebze"],
        "hazirlik_dakika": 45,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "PATLICAN", "miktar_gram": 80},
            {"ad": "KUZU KIYMA", "miktar_gram": 60},
            {"ad": "YOĞURT (TAM)", "miktar_gram": 40},
            {"ad": "SARIMSAK", "miktar_gram": 2},
            {"ad": "TEREYAĞI", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Şanlıurfa Usulü Çiğ Köfte (Etsiz)",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 40,
        "grup": 3,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "BULGUR", "miktar_gram": 50},
            {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 15},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 10},
            {"ad": "SARIMSAK", "miktar_gram": 1.5},
            {"ad": "NAR EKŞİSİ", "miktar_gram": 4},
            {"ad": "PUL BİBER", "miktar_gram": 1},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Urfa Usulü Kuzu Kavurma",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 35,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 100},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "PUL BİBER", "miktar_gram": 1},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Mardin Usulü Kaburga Dolması",
        "etiketler": ["kirmizi_et", "dolma"],
        "hazirlik_dakika": 90,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "SIĞIR KABURGA", "miktar_gram": 150},
            {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30},
            {"ad": "KURU SOĞAN", "miktar_gram": 10},
            {"ad": "KİMYON", "miktar_gram": 0.5},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Diyarbakır Usulü Meftune",
        "etiketler": ["kirmizi_et", "etli_sebze"],
        "hazirlik_dakika": 50,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 80},
            {"ad": "PATLICAN", "miktar_gram": 40},
            {"ad": "KABAK", "miktar_gram": 30},
            {"ad": "DOMATES", "miktar_gram": 30},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "SARIMSAK", "miktar_gram": 1.5},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Antep Usulü Yuvalama Çorbası",
        "etiketler": ["corba"],
        "hazirlik_dakika": 45,
        "grup": 2,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "YOĞURT (TAM)", "miktar_gram": 60},
            {"ad": "PİRİNÇ (HAM)", "miktar_gram": 15},
            {"ad": "DANA KIYMA", "miktar_gram": 30},
            {"ad": "TAVUK SUYU", "miktar_gram": 80},
            {"ad": "TEREYAĞI", "miktar_gram": 4},
            {"ad": "KURU NANE", "miktar_gram": 0.5},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Siirt Usulü Büryan",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 30,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "KUZU ETİ (BUT)", "miktar_gram": 180},
            {"ad": "TUZ", "miktar_gram": 1.5},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Antep Fıstıklı Muhallebi",
        "etiketler": ["tatli", "vejetaryen"],
        "hazirlik_dakika": 25,
        "grup": 3,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 150},
            {"ad": "ANTEP FISTIĞI", "miktar_gram": 15},
            {"ad": "ŞEKER", "miktar_gram": 25},
            {"ad": "PİRİNÇ UNU", "miktar_gram": 8},
        ],
    },
]
