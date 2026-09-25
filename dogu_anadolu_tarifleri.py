# dogu_anadolu_tarifleri.py
#
# Doğu Anadolu bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
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

BOLGE_ADI = "Doğu Anadolu"

DOGU_ANADOLU_TARIFLERI = [
    {
        "ad": "Erzurum Cağ Kebabı",
        "etiketler": ["izgara", "kirmizi_et"],
        "hazirlik_dakika": 40,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "KOYUN ETİ (BUT)", "miktar_gram": 150},
            {"ad": "KURU SOĞAN", "miktar_gram": 10},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Erzincan Tulumlu Kavurma",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 35,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 90},
            {"ad": "TULUM PEYNİRİ", "miktar_gram": 15},
            {"ad": "KURU SOĞAN", "miktar_gram": 10},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Van Otlu Peynirli Kahvaltı Böreği",
        "etiketler": ["pilav_makarna_borek", "vejetaryen"],
        "hazirlik_dakika": 30,
        "grup": 2,
        "mevsim_etiketi": "ilkbahar",
        "malzemeler": [
            {"ad": "YUFKA", "miktar_gram": 50},
            {"ad": "OTLU PEYNİR", "miktar_gram": 40},
            {"ad": "TEREYAĞI", "miktar_gram": 6},
            {"ad": "TAVUK YUMURTASI", "miktar_gram": 15},
            {"ad": "TUZ", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Malatya Kayısılı Kuzu Yahnisi",
        "etiketler": ["kirmizi_et", "etli_sebze"],
        "hazirlik_dakika": 55,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 100},
            {"ad": "KURU KAYISI", "miktar_gram": 30},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Elazığ Usulü Kuru Fasulye Kavurması",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 40,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KURU FASULYE", "miktar_gram": 50},
            {"ad": "DANA KIYMA", "miktar_gram": 40},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "DOMATES", "miktar_gram": 25},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Kars Usulü Kaz Eti Kavurması",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 45,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)", "miktar_gram": 120},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "TUZ", "miktar_gram": 0.6},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Doğu Anadolu Pekmezli Ceviz Ezmesi",
        "etiketler": ["tatli", "vejetaryen"],
        "hazirlik_dakika": 15,
        "grup": 3,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 50},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 30},
            {"ad": "MISIR NİŞASTASI", "miktar_gram": 10},
        ],
    },
    {
        "ad": "Doğu Anadolu Kayısı ve Ceviz Salatası",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 15,
        "grup": 3,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "KAYISI", "miktar_gram": 40},
            {"ad": "CEVİZ (İÇ)", "miktar_gram": 10},
            {"ad": "YOĞURT (TAM)", "miktar_gram": 30},
            {"ad": "ŞEKER", "miktar_gram": 3},
        ],
    },
]
