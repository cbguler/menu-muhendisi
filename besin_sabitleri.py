"""besin_sabitleri.py -- SEKSEN IKINCI DUZELTME (4 Eylul 2026) ile
0_Yillik_Menu.py'den buraya tasindi. Sebep: Abonelik sayfasinin da
(porsiyon profillerine besin hedefi eklemek icin) AYNI besin listesine
ihtiyaci var -- iki ayri kopya tutmak, bu projede daha once yasanan
"ayni formulun/verinin birden fazla kopyasi" sorununu (Optima Skor,
fire orani) tekrarlar. Tek kaynak burasi, her iki sayfa da buradan
import ediyor.
"""

TUM_BESIN_ALANLARI = [
    # NOT: Streamlit'in number_input'u min/maks/varsayilan degerlerin
    # HEPSININ AYNI TIPTE (ya hep int ya hep float) olmasini zorunlu
    # kilar -- aksi halde StreamlitMixedNumericTypesError firlatir.
    # Bu yuzden HER satirda tum 4 deger (min, maks, def_alt, def_ust)
    # BILINCLI OLARAK float yaziliyor, tam sayi gibi gorunse bile.
    #
    # OTUZ IKINCI DUZELTME (13 Agustos 2026, Oturum 11): kullanicinin
    # "neredeyse hicbir ogun hedefte cikmiyor" bildirimi uzerine, TUM
    # varsayilan def_alt/def_ust degerleri GERCEK veriye gore yeniden
    # kalibre edildi (o zamanki "3 x medyan" formulu).
    #
    # YUZ YIRMI DOKUZUNCU DUZELTME (9 Eylul 2026): OTUZ IKINCI
    # DUZELTME'nin "3 x medyan" formulu, GERCEK 3'lu OGUN
    # kombinasyonlarinin dagilimini yansitmiyordu (bkz. PROJE_NOTLARI,
    # 9 Eylul XXI. Oturum). `besin_kalibrasyon.py` ile TUM MEVSIMLER
    # birlestirilerek 400.000 GERCEK (rastgele, uyumlu, porsiyona
    # DOGRU bolunmus) uclu ornegi uzerinden olculen p10/p90 yuzdelik
    # dilimleri once denendi.
    #
    # YUZ OTUZUNCU DUZELTME (9 Eylul 2026): p10/p90 bazi ogelerde
    # (sodyum, potasyum, fosfor, iyot, GI) eski araliktan DAHA DAR
    # cikti -- p5/p95'e (yuzde 90 kapsama) gecildi.
    #
    # YUZ OTUZ BIRINCI DUZELTME (9 Eylul 2026): p5/p95'te bile 9 oge
    # (gi, sodyum, b2, b5, b6, b7, potasyum, fosfor, iyot) ESKI (kaba
    # tahmini) araliktan hala DAHA DAR kaldi. Bu 9 oge icin ESKI ve
    # YENI araligin BIRLESIMI (ikisini de kapsayan en genis bant)
    # kullanildi -- geri kalan 23 oge zaten p5/p95 ile eskisinden
    # genis/esitti. SONUC: hicbir oge artik eskisinden dar degil,
    # tamami en az eski kadar genis (cogu daha da genis, gercek
    # veriyle desteklenmis).
    ("kalori", "Kalori (kcal)", 0.0, 3000.0, 457.9, 1234.9),
    ("protein", "Protein (g)", 0.0, 150.0, 23.9, 67.5),
    ("yag", "Yağ (g)", 0.0, 120.0, 17.7, 68.3),
    ("karbonhidrat", "Karbonhidrat (g)", 0.0, 300.0, 21.4, 135.0),
    ("gi", "Glisemik İndeks", 0.0, 100.0, 0.0, 70.0),
    ("sodyum_mg", "Sodyum (mg)", 0.0, 8000.0, 737.7, 5000.0),
    ("lif_g", "Lif (g)", 0.0, 30.0, 2.8, 25.7),
    ("seker_g", "Şeker (g)", 0.0, 80.0, 2.1, 55.2),
    ("doymus_yag_g", "Doymuş Yağ (g)", 0.0, 50.0, 5.2, 26.7),
    ("vitamin_a_mcg", "Vitamin A (mcg)", 0.0, 2000.0, 79.9, 751.8),
    ("vitamin_b1_mg", "Vitamin B1 — Tiamin (mg)", 0.0, 3.0, 0.2, 1.0),
    ("vitamin_b2_mg", "Vitamin B2 — Riboflavin (mg)", 0.0, 3.0, 0.1, 1.1),
    ("vitamin_b3_mg", "Vitamin B3 — Niasin (mg)", 0.0, 30.0, 4.4, 23.3),
    ("vitamin_b5_mg", "Vitamin B5 — Pantotenik Asit (mg)", 0.0, 12.0, 0.3, 3.2),
    ("vitamin_b6_mg", "Vitamin B6 (mg)", 0.0, 4.0, 0.1, 1.4),
    ("vitamin_b7_mcg", "Vitamin B7 — Biyotin (mcg)", 0.0, 60.0, 0.0, 8.0),
    ("vitamin_b9_mcg", "Vitamin B9 — Folat (mcg)", 0.0, 800.0, 40.9, 420.4),
    ("vitamin_b12_mcg", "Vitamin B12 (mcg)", 0.0, 40.0, 0.6, 13.0),
    ("vitamin_c_mg", "Vitamin C (mg)", 0.0, 250.0, 3.5, 147.2),
    ("vitamin_d_mcg", "Vitamin D (mcg)", 0.0, 15.0, 0.0, 3.2),
    ("vitamin_e_mg", "Vitamin E (mg)", 0.0, 35.0, 1.2, 9.1),
    ("vitamin_k_mcg", "Vitamin K (mcg)", 0.0, 1800.0, 5.9, 442.4),
    ("kalsiyum_mg", "Kalsiyum (mg)", 0.0, 1500.0, 64.4, 863.8),
    ("demir_mg", "Demir (mg)", 0.0, 35.0, 1.9, 9.0),
    ("magnezyum_mg", "Magnezyum (mg)", 0.0, 700.0, 65.2, 274.3),
    ("potasyum_mg", "Potasyum (mg)", 0.0, 5000.0, 300.0, 2500.0),
    ("cinko_mg", "Çinko (mg)", 0.0, 25.0, 2.4, 10.4),
    ("fosfor_mg", "Fosfor (mg)", 0.0, 3000.0, 100.0, 952.6),
    ("bakir_mg", "Bakır (mg)", 0.0, 5.0, 0.2, 1.2),
    ("manganez_mg", "Manganez (mg)", 0.0, 12.0, 0.3, 3.4),
    ("selenyum_mcg", "Selenyum (mcg)", 0.0, 180.0, 12.8, 86.5),
    ("iyot_mcg", "İyot (mcg)", 0.0, 800.0, 10.0, 500.0),
]
BESIN_ETIKET = {anahtar: etiket for anahtar, etiket, *_ in TUM_BESIN_ALANLARI}
BESIN_ARALIK = {anahtar: (minv, maxv, def_alt, def_ust) for anahtar, _, minv, maxv, def_alt, def_ust in TUM_BESIN_ALANLARI}

_TUM_ANAHTAR_SIRASI = [anahtar for anahtar, *_ in TUM_BESIN_ALANLARI]


def kanonik_sirala(anahtar_koleksiyonu):
    """Bir besin-ogesi anahtar kumesini/listesini, TUM_BESIN_ALANLARI'ndaki
    TANIM SIRASINA (Kalori, Protein, Yağ, Karbonhidrat, Glisemik İndeks,
    Sodyum, ...) gore siralar. SEKSEN DORDUNCU DUZELTME (4 Eylul 2026):
    profil hedeflerini bir set'ten olusturup sorted() ile siralamak,
    besin ogelerini ALFABETIK (gi, kalori, karbonhidrat, protein, yag)
    diziyordu -- kullanici bunun yerine dogal/beklenen sirayi
    (Kalori, Protein, Yağ, Karbonhidrat, GI) istiyor."""
    anahtar_kumesi = set(anahtar_koleksiyonu)
    return [a for a in _TUM_ANAHTAR_SIRASI if a in anahtar_kumesi]


# YUZ OTUZ DORDUNCU DUZELTME (9 Eylul 2026): STANDART_PROFILLER --
# dunyada/klinikte taninmis beslenme kaliplari icin ARASTIRILMIS
# baslangic sablonlari. Abonelik sayfasinda bir porsiyon profilinin
# besin hedeflerini "sifirdan" girmek yerine, buradan birini secip
# "Şablonu uygula" ile BASLANGIC noktasi olarak kullanabilir --
# sonra istedigi gibi elle degistirebilir (profil sistemi zaten
# TAMAMEN ozgur/sinirsiz, bu SADECE bir kolaylik, bir KISIT degil).
#
# TUMU gunluk resmi/klinik rakamlarin %35'i olarak (Ogle VE Aksam icin
# AYNI deger -- kahvaltiya/ara ogune kalan pay ~%30 varsayilarak)
# hesaplandi; bu yontem ve tum kaynaklar PROJE_NOTLARI'nda (9 Eylul,
# XXI. Oturum) satir satir belgelendi. Her deger, ozellikle o grubu
# AYIRT EDEN ogeler icin -- kalan ogeler icin genel varsayilan (yukarida)
# gecerli kalir, "genel gibi" sayilan alanlar buraya YAZILMADI (uydurma
# sayi yerine bos birakildi).
#
# BILINCLI OLARAK DISLANANLAR: MIND ve Nordik diyetleri (DASH'in
# aksine, literaturde SAYISAL bir hedef tablosu yok -- besin
# grubu/porsiyon sikligi olarak tanimlaniyorlar, min-max araligina
# zorlanirsa uydurma olur). Vejetaryen/Vegan zaten ayri bir FILTRE
# (bkz. YUZ OTUZ UCUNCU DUZELTME) -- bunlar burada TEKRAR EDILMEDI.
# Keto EKLENMEDI -- fizibilite testi yapilmadan (Turk mutfagi
# tarif havuzunun cok dusuk karbonhidratli kombinasyon barindirmasi
# suphesi var) eklemek, Aralik'ta yasanan "hicbir ogun hedefte
# cikmiyor" sorununu tekrarlama riski tasiyordu.
STANDART_PROFILLER = {
    "Hastane (Genel/Standart Diyet)": {
        # NHS Scotland "Food in Hospitals" standardi + Kanada hastane
        # menu degerlendirmesi (gunluk 1800-2400 kcal, protein
        # >=56-75g, yag %20-35, sodyum <=2300-3000mg, lif 19-30g).
        # Elderly hastane popülasyonunda RNI-alti cikan ogeler icin
        # (D vitamini, cinko, C vitamini, selenyum, magnezyum,
        # potasyum, iyot) genel RDA taban alindi.
        "kalori": (630.0, 840.0),
        "protein": (20.0, 40.0),
        "karbonhidrat": (92.0, 119.0),
        "yag": (16.0, 29.0),
        "doymus_yag_g": (0.0, 9.0),
        "lif_g": (7.0, 11.0),
        "sodyum_mg": (0.0, 900.0),
        "vitamin_d_mcg": (7.0, 15.0),
        "vitamin_c_mg": (27.0, 250.0),
        "cinko_mg": (3.0, 25.0),
        "selenyum_mcg": (19.0, 180.0),
        "magnezyum_mg": (110.0, 700.0),
        "potasyum_mg": (910.0, 5000.0),
        "iyot_mcg": (52.0, 800.0),
    },
    "Sporcu (Orta-Yüksek Antrenman)": {
        # ISSN protein pozisyon bildirgesi (1.6-2.0 g/kg/gun) + ACSM
        # karbonhidrat rehberi (6-8 g/kg/gun, orta-yuksek antrenman),
        # 70kg referans. Demir/kalsiyum/cinko: Female Athlete
        # Triad/REDs literaturu (kadin sporcularda daha yuksek ihtiyac,
        # koruyucu taraf secildi). Sodyum bilincli olarak EKLENMEDI --
        # ter kaybi bireysel farkliligi cok yuksek, guvenilir tek bir
        # sayi bulunamadi.
        "kalori": (980.0, 1120.0),
        "protein": (35.0, 55.0),
        "karbonhidrat": (147.0, 196.0),
        "yag": (23.0, 35.0),
        "lif_g": (9.0, 13.0),
        "demir_mg": (6.0, 35.0),
        "kalsiyum_mg": (350.0, 1500.0),
        "cinko_mg": (3.0, 25.0),
    },
    "Diyet / Kilo Verme": {
        # NHLBI "Low-Calorie Step I Diet" + USDA 2025-2030 kilavuzu
        # (protein 1.6-2.0 g/kg diyet sirasinda, lif 25-38g/gun,
        # sodyum <=2.4g/gun). Mikrobesin icin ozel bir hedef oneren
        # kilavuz bulunamadi -- genel varsayilan gecerli.
        "kalori": (420.0, 630.0),
        "protein": (25.0, 40.0),
        "karbonhidrat": (57.0, 70.0),
        "yag": (11.0, 17.0),
        "lif_g": (9.0, 13.0),
        "seker_g": (0.0, 15.0),
        "sodyum_mg": (0.0, 800.0),
    },
    "Şeker Hastası": {
        # ADA 2026 Standartlari (lif >=14g/1000kcal, dusuk-GI vurgusu,
        # seker/sodyum minimizasyonu). ADA acikca "tek bir ideal
        # karbonhidrat orani yok, bireysellestirilmeli" diyor, karbonhidrat
        # araligi bu yuzden genis tutuldu. Magnezyum/cinko takviyesi
        # ARASTIRILDI ama kanit CELISKILI (bir meta-analiz "rutin
        # onerilemez" diyor) -- bu yuzden EKLENMEDI.
        "kalori": (630.0, 770.0),
        "karbonhidrat": (50.0, 90.0),
        "lif_g": (10.0, 20.0),
        "seker_g": (0.0, 10.0),
        "sodyum_mg": (0.0, 750.0),
        "gi": (0.0, 55.0),
        "doymus_yag_g": (0.0, 8.0),
    },
    "Çocuklar (9-13 Yaş / Okul Çağı)": {
        # Mayo Clinic (USDA tabanli) cocuk kalori rehberi + IOM AMDR
        # (yag/protein/karbonhidrat, 9-13 yas) + CDC cocuk sodyum
        # verisi. Kalsiyum/D vitamini/demir/cinko/iyot: standart
        # 9-13 yas RDA degerleri (buyume donemi kemik/bagisiklik
        # ihtiyaci).
        "kalori": (490.0, 910.0),
        "protein": (15.0, 45.0),
        "karbonhidrat": (79.0, 114.0),
        "yag": (19.0, 27.0),
        "lif_g": (8.0, 15.0),
        "sodyum_mg": (0.0, 650.0),
        "seker_g": (0.0, 9.0),
        "kalsiyum_mg": (455.0, 1500.0),
        "vitamin_d_mcg": (5.0, 15.0),
        "demir_mg": (2.8, 35.0),
        "cinko_mg": (2.8, 25.0),
        "iyot_mcg": (42.0, 800.0),
    },
    "Hamile / Emziren": {
        # ACOG (demir, kalsiyum, folat) + USDA 2020-2025 kilavuzu
        # (kalori/protein artisi) + WHO/ATA (iyot 250mcg/gun -- hamilelikte
        # en kritik eksiklik risklerinden biri, fetal beyin gelisimi).
        "kalori": (805.0, 945.0),
        "protein": (25.0, 45.0),
        "lif_g": (9.0, 13.0),
        "demir_mg": (9.0, 35.0),
        "kalsiyum_mg": (350.0, 1500.0),
        "vitamin_b9_mcg": (210.0, 800.0),
        "vitamin_d_mcg": (5.0, 15.0),
        "vitamin_c_mg": (30.0, 250.0),
        "vitamin_a_mcg": (270.0, 2000.0),
        "iyot_mcg": (87.0, 800.0),
        "cinko_mg": (4.0, 25.0),
    },
    "Kalp-Damar / Hipertansiyon (DASH)": {
        # NHLBI/Mayo Clinic DASH protokolu -- resmi klinik hedefler:
        # sodyum 1500mg (siki hedef), potasyum >=4700mg/gun, magnezyum
        # 450mg/gun, doymus yag ~%6 enerji, kalsiyum ~1131mg/gun,
        # lif 28g/gun.
        "kalori": (630.0, 770.0),
        "sodyum_mg": (0.0, 500.0),
        "potasyum_mg": (1600.0, 5000.0),
        "doymus_yag_g": (0.0, 5.0),
        "lif_g": (9.0, 13.0),
        "kalsiyum_mg": (440.0, 1500.0),
        "magnezyum_mg": (155.0, 700.0),
        "seker_g": (0.0, 10.0),
    },
    "Akdeniz (Yaklaşık)": {
        # PREDIMED calismasi + genel Akdeniz diyeti literaturu --
        # DASH'in aksine RESMI bir sayisal hedef tablosu YOK, bu
        # deger bir referans 700kcal uzerinden ORANSAL (%35-50 yag
        # -cogu MUFA/zeytinyagi-, %35-55 karbonhidrat, %12-20 protein,
        # yuksek lif, dusuk doymus yag) YAKLASIMDIR -- diger kaliplar
        # kadar kesin degildir, bu yuzden adinda "(Yaklaşık)" var.
        # Kalori bilincli olarak EKLENMEDI -- Akdeniz diyeti kaloriyi
        # kisitlamaz, besin KALITESINE odaklanir.
        "protein": (21.0, 35.0),
        "yag": (27.0, 39.0),
        "karbonhidrat": (61.0, 96.0),
        "lif_g": (9.0, 15.0),
        "doymus_yag_g": (0.0, 10.0),
    },
}
