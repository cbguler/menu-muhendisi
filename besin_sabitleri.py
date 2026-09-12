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
    # kalibre edildi. Yontem: kalibrasyon_besin_dagilimi.sql ile TUM
    # tariflerin (564 malzeme, tam veri) GERCEK TEK TARIF medyan/p90
    # degerleri olculdu; bir ogun ~3 tarifin (ana+yardimci+tamamlayici)
    # toplami oldugu icin "3 x medyan" o besin ogesi icin TIPIK bir
    # ogun degeri olarak kullanildi, def_alt/def_ust bu tipik degerin
    # etrafinda MAKUL bir bant (cogu gercek ogunun sigabilecegi) olacak
    # sekilde ayarlandi.
    #
    # YUZ YIRMI DOKUZUNCU DUZELTME (9 Eylul 2026): OTUZ IKINCI
    # DUZELTME'nin "3 x medyan" formulu, GERCEK 3'lu OGUN
    # kombinasyonlarinin dagilimini yansitmiyordu (bkz. PROJE_NOTLARI,
    # 9 Eylul XXI. Oturum) -- ozellikle kalori icin gercekte olustugu
    # gibi degil, cok yuksek/dar bir aralik veriyordu. `besin_kalibrasyon.py`
    # ile TUM MEVSIMLER birlestirilerek 400.000 GERCEK (rastgele, uyumlu,
    # porsiyona DOGRU bolunmus) uclu ornegi uzerinden olculen p10/p90
    # yuzdelik dilimleri, def_alt/def_ust olarak DOGRUDAN uygulandi --
    # tahmini formul yerine artik doğrudan olculmus gercek dagilim
    # kullaniliyor. min/maks sinirlar (3. ve 4. sutun) DEGISMEDI.
    ("kalori", "Kalori (kcal)", 0.0, 3000.0, 524.6, 1123.1),
    ("protein", "Protein (g)", 0.0, 150.0, 26.9, 61.5),
    ("yag", "Yağ (g)", 0.0, 120.0, 21.0, 60.8),
    ("karbonhidrat", "Karbonhidrat (g)", 0.0, 300.0, 32.8, 119.9),
    ("gi", "Glisemik İndeks", 0.0, 100.0, 34.8, 64.2),
    ("sodyum_mg", "Sodyum (mg)", 0.0, 8000.0, 912.5, 2834.6),
    ("lif_g", "Lif (g)", 0.0, 30.0, 3.5, 18.8),
    ("seker_g", "Şeker (g)", 0.0, 80.0, 3.1, 44.1),
    ("doymus_yag_g", "Doymuş Yağ (g)", 0.0, 50.0, 6.4, 22.7),
    ("vitamin_a_mcg", "Vitamin A (mcg)", 0.0, 2000.0, 108.5, 607.9),
    ("vitamin_b1_mg", "Vitamin B1 — Tiamin (mg)", 0.0, 3.0, 0.2, 0.8),
    ("vitamin_b2_mg", "Vitamin B2 — Riboflavin (mg)", 0.0, 3.0, 0.4, 0.9),
    ("vitamin_b3_mg", "Vitamin B3 — Niasin (mg)", 0.0, 30.0, 5.8, 19.8),
    ("vitamin_b5_mg", "Vitamin B5 — Pantotenik Asit (mg)", 0.0, 12.0, 1.2, 2.8),
    ("vitamin_b6_mg", "Vitamin B6 (mg)", 0.0, 4.0, 0.5, 1.3),
    ("vitamin_b7_mcg", "Vitamin B7 — Biyotin (mcg)", 0.0, 60.0, 0.2, 5.9),
    ("vitamin_b9_mcg", "Vitamin B9 — Folat (mcg)", 0.0, 800.0, 52.7, 295.4),
    ("vitamin_b12_mcg", "Vitamin B12 (mcg)", 0.0, 40.0, 1.0, 5.9),
    ("vitamin_c_mg", "Vitamin C (mg)", 0.0, 250.0, 5.5, 93.7),
    ("vitamin_d_mcg", "Vitamin D (mcg)", 0.0, 15.0, 0.1, 2.5),
    ("vitamin_e_mg", "Vitamin E (mg)", 0.0, 35.0, 1.5, 7.2),
    ("vitamin_k_mcg", "Vitamin K (mcg)", 0.0, 1800.0, 8.1, 293.1),
    ("kalsiyum_mg", "Kalsiyum (mg)", 0.0, 1500.0, 80.2, 578.9),
    ("demir_mg", "Demir (mg)", 0.0, 35.0, 2.3, 7.8),
    ("magnezyum_mg", "Magnezyum (mg)", 0.0, 700.0, 73.2, 226.3),
    ("potasyum_mg", "Potasyum (mg)", 0.0, 5000.0, 806.6, 2117.8),
    ("cinko_mg", "Çinko (mg)", 0.0, 25.0, 3.0, 9.4),
    ("fosfor_mg", "Fosfor (mg)", 0.0, 3000.0, 382.1, 861.1),
    ("bakir_mg", "Bakır (mg)", 0.0, 5.0, 0.2, 1.0),
    ("manganez_mg", "Manganez (mg)", 0.0, 12.0, 0.5, 2.9),
    ("selenyum_mcg", "Selenyum (mcg)", 0.0, 180.0, 16.4, 73.7),
    ("iyot_mcg", "İyot (mcg)", 0.0, 800.0, 91.4, 335.3),
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
