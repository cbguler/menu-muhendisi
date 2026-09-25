# ege_tarifleri.py
#
# Ege bolgesine ait 8 yeni tarif -- yukle_yeni_tarifler.py
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

BOLGE_ADI = "Ege"

EGE_TARIFLERI = [
    {
        "ad": "İzmir Köfte (Fırında)",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 35,
        "grup": 1,
        "mevsim_etiketi": "yil_boyunca",
        "malzemeler": [
            {"ad": "DANA KIYMA", "miktar_gram": 90},
            {"ad": "PATATES", "miktar_gram": 50},
            {"ad": "DOMATES", "miktar_gram": 40},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "EKMEKLİK UN", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1.2},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
        ],
    },
    {
        "ad": "Çeşme Usulü Ahtapot Güveç",
        "etiketler": ["balik", "etli_sebze"],
        "hazirlik_dakika": 40,
        "grup": 1,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "AHTAPOT", "miktar_gram": 100},
            {"ad": "DOMATES", "miktar_gram": 40},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "YEŞİL BİBER", "miktar_gram": 15},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 5},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Ege Otlu Peynirli Gözleme",
        "etiketler": ["pilav_makarna_borek", "vejetaryen"],
        "hazirlik_dakika": 25,
        "grup": 2,
        "mevsim_etiketi": "ilkbahar",
        "malzemeler": [
            {"ad": "YUFKA", "miktar_gram": 60},
            {"ad": "OTLU PEYNİR", "miktar_gram": 40},
            {"ad": "ISPANAK", "miktar_gram": 30},
            {"ad": "TEREYAĞI", "miktar_gram": 6},
            {"ad": "TUZ", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Ege Usulü Isırgan Kavurması (Etli)",
        "etiketler": ["kirmizi_et", "etli_sebze"],
        "hazirlik_dakika": 30,
        "grup": 1,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "KUZU ETİ (KOL)", "miktar_gram": 70},
            {"ad": "ISIRGAN", "miktar_gram": 50},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Ege Yaylası Kuzu Tandır",
        "etiketler": ["kirmizi_et"],
        "hazirlik_dakika": 100,
        "grup": 1,
        "mevsim_etiketi": "ilkbahar",
        "malzemeler": [
            {"ad": "KUZU TANDIR", "miktar_gram": 150},
            {"ad": "KURU SOĞAN", "miktar_gram": 15},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "TUZ", "miktar_gram": 1.5},
            {"ad": "KEKİK", "miktar_gram": 0.5},
            {"ad": "KARABİBER", "miktar_gram": 0.3},
        ],
    },
    {
        "ad": "Ege Portakallı Zeytinyağlı Kek",
        "etiketler": ["tatli", "vejetaryen"],
        "hazirlik_dakika": 50,
        "grup": 3,
        "mevsim_etiketi": "kis",
        "malzemeler": [
            {"ad": "EKMEKLİK UN", "miktar_gram": 50},
            {"ad": "ŞEKER", "miktar_gram": 35},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 20},
            {"ad": "PORTAKAL", "miktar_gram": 30},
            {"ad": "TAVUK YUMURTASI", "miktar_gram": 30},
            {"ad": "KABARTMA TOZU", "miktar_gram": 1.5},
        ],
    },
    {
        "ad": "Datça Bademli Yeşil Salata",
        "etiketler": ["salata", "vejetaryen"],
        "hazirlik_dakika": 15,
        "grup": 3,
        "mevsim_etiketi": "ilkbahar",
        "malzemeler": [
            {"ad": "ROKA", "miktar_gram": 30},
            {"ad": "MARUL", "miktar_gram": 20},
            {"ad": "BADEM", "miktar_gram": 8},
            {"ad": "ZEYTİNYAĞI", "miktar_gram": 4},
            {"ad": "LİMON SUYU", "miktar_gram": 2.5},
            {"ad": "TUZ", "miktar_gram": 0.5},
        ],
    },
    {
        "ad": "Ege İnciri ile Komposto",
        "etiketler": ["komposto", "vejetaryen"],
        "hazirlik_dakika": 25,
        "grup": 3,
        "mevsim_etiketi": "yaz",
        "malzemeler": [
            {"ad": "KURU İNCİR", "miktar_gram": 50},
            {"ad": "ŞEKER", "miktar_gram": 10},
            {"ad": "SU", "miktar_gram": 80},
        ],
    },
]
