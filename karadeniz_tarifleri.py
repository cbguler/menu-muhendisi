# karadeniz_tarifleri.py
#
# Karadeniz bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
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

BOLGE_ADI = "Karadeniz"

KARADENIZ_TARIFLERI = [
    {
        "ad": "Karadeniz Mıhlaması",
        "etiketler": ["pilav_makarna_borek", "vejetaryen"],
        "hazirlik_dakika": 20,
        "grup": 2,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "MISIR UNU", "miktar_gram": 40},
            {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 50},
            {"ad": "TEREYAĞI", "miktar_gram": 15},
            {"ad": "SU", "miktar_gram": 60},
            {"ad": "TUZ", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Karadeniz Kaymaklı Pide",
        "etiketler": ["pilav_makarna_borek", "vejetaryen"],
        "hazirlik_dakika": 45,
        "grup": 2,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "EKMEKLİK UN", "miktar_gram": 70},
            {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 40},
            {"ad": "TAVUK YUMURTASI", "miktar_gram": 30},
            {"ad": "TEREYAĞI", "miktar_gram": 8},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Trabzon Usulü Hamsili Pilav",
        "etiketler": ["pilav"],
        "hazirlik_dakika": 35,
        "grup": 2,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "HAMSİ", "miktar_gram": 60},
            {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "TEREYAĞI", "miktar_gram": 8},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Rize Usulü Karalahana Çorbası",
        "etiketler": ["corba", "vejetaryen"],
        "hazirlik_dakika": 40,
        "grup": 2,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KARALAHANA", "miktar_gram": 50},
            {"ad": "MISIR UNU", "miktar_gram": 10},
            {"ad": "KURU FASULYE", "miktar_gram": 15},
            {"ad": "TEREYAĞI", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Giresun Fındıklı Kuru Fasulye",
        "etiketler": ["kuru_baklagil", "vejetaryen"],
        "hazirlik_dakika": 45,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KURU FASULYE", "miktar_gram": 50},
            {"ad": "FINDIK (İÇ)", "miktar_gram": 10},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "DOMATES", "miktar_gram": 25},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1},
        ],
    },
    {
        "ad": "Karadeniz Mısır Ekmeği",
        "etiketler": ["pilav_makarna_borek", "vejetaryen"],
        "hazirlik_dakika": 40,
        "grup": 2,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "MISIR UNU", "miktar_gram": 60},
            {"ad": "EKMEKLİK UN", "miktar_gram": 20},
            {"ad": "YOĞURT (TAM)", "miktar_gram": 30},
            {"ad": "TAVUK YUMURTASI", "miktar_gram": 20},
            {"ad": "KABARTMA TOZU", "miktar_gram": 1.5},
            {"ad": "TUZ", "miktar_gram": 0.8},
        ],
    },
    {
        "ad": "Trabzon Usulü Akçaabat Köfte",
        "etiketler": ["izgara", "kirmizi_et"],
        "hazirlik_dakika": 30,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "DANA KIYMA", "miktar_gram": 90},
            {"ad": "KURU SOĞAN", "miktar_gram": 10},
            {"ad": "GALETA UNU (PANKO)", "miktar_gram": 6},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "KİMYON", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Karadeniz Dutlu Komposto",
        "etiketler": ["komposto", "vejetaryen"],
        "hazirlik_dakika": 25,
        "grup": 3,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "DUT", "miktar_gram": 50},
            {"ad": "ŞEKER", "miktar_gram": 12},
            {"ad": "SU", "miktar_gram": 60},
        ],
    },
]
