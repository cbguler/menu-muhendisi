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
    # sekilde ayarlandi. Ozellikle Sodyum/Fosfor/Potasyum/Kalsiyum/Iyot
    # onceki tahmini araliklarin COK UZERINDE, Vitamin D/B7 ise COK
    # ALTINDA cikiyordu -- kullanicinin gelecekte hastane/huzurevi/okul
    # gibi COK SAYIDA besin ogesini AYNI ANDA hedefleyecegi kurumsal
    # kullanim senaryolari icin altyapinin saglam kalmasi amaciyla,
    # TUM 27 alan (sadece sorun cikaranlar degil) gercek veriyle
    # yeniden dogrulanip guncellendi.
    ("kalori", "Kalori (kcal)", 0.0, 3000.0, 900.0, 1200.0),
    ("protein", "Protein (g)", 0.0, 150.0, 20.0, 60.0),
    ("yag", "Yağ (g)", 0.0, 120.0, 10.0, 55.0),
    ("karbonhidrat", "Karbonhidrat (g)", 0.0, 300.0, 40.0, 120.0),
    ("gi", "Glisemik İndeks", 0.0, 100.0, 0.0, 70.0),
    ("sodyum_mg", "Sodyum (mg)", 0.0, 8000.0, 800.0, 5000.0),
    ("lif_g", "Lif (g)", 0.0, 30.0, 3.0, 10.0),
    ("seker_g", "Şeker (g)", 0.0, 80.0, 0.0, 25.0),
    ("doymus_yag_g", "Doymuş Yağ (g)", 0.0, 50.0, 0.0, 20.0),
    ("vitamin_a_mcg", "Vitamin A (mcg)", 0.0, 2000.0, 50.0, 400.0),
    ("vitamin_b1_mg", "Vitamin B1 — Tiamin (mg)", 0.0, 3.0, 0.1, 0.6),
    ("vitamin_b2_mg", "Vitamin B2 — Riboflavin (mg)", 0.0, 3.0, 0.1, 1.0),
    ("vitamin_b3_mg", "Vitamin B3 — Niasin (mg)", 0.0, 30.0, 1.0, 12.0),
    ("vitamin_b5_mg", "Vitamin B5 — Pantotenik Asit (mg)", 0.0, 12.0, 0.3, 3.0),
    ("vitamin_b6_mg", "Vitamin B6 (mg)", 0.0, 4.0, 0.1, 1.2),
    ("vitamin_b7_mcg", "Vitamin B7 — Biyotin (mcg)", 0.0, 60.0, 0.0, 8.0),
    ("vitamin_b9_mcg", "Vitamin B9 — Folat (mcg)", 0.0, 800.0, 20.0, 200.0),
    ("vitamin_b12_mcg", "Vitamin B12 (mcg)", 0.0, 40.0, 0.0, 3.0),
    ("vitamin_c_mg", "Vitamin C (mg)", 0.0, 250.0, 5.0, 80.0),
    ("vitamin_d_mcg", "Vitamin D (mcg)", 0.0, 15.0, 0.0, 3.0),
    ("vitamin_e_mg", "Vitamin E (mg)", 0.0, 35.0, 1.0, 6.0),
    ("vitamin_k_mcg", "Vitamin K (mcg)", 0.0, 1800.0, 2.0, 150.0),
    ("kalsiyum_mg", "Kalsiyum (mg)", 0.0, 1500.0, 50.0, 600.0),
    ("demir_mg", "Demir (mg)", 0.0, 35.0, 1.0, 8.0),
    ("magnezyum_mg", "Magnezyum (mg)", 0.0, 700.0, 30.0, 180.0),
    ("potasyum_mg", "Potasyum (mg)", 0.0, 5000.0, 300.0, 2500.0),
    ("cinko_mg", "Çinko (mg)", 0.0, 25.0, 1.0, 8.0),
    ("fosfor_mg", "Fosfor (mg)", 0.0, 3000.0, 100.0, 900.0),
    ("bakir_mg", "Bakır (mg)", 0.0, 5.0, 0.05, 0.8),
    ("manganez_mg", "Manganez (mg)", 0.0, 12.0, 0.1, 2.0),
    ("selenyum_mcg", "Selenyum (mcg)", 0.0, 180.0, 5.0, 40.0),
    ("iyot_mcg", "İyot (mcg)", 0.0, 800.0, 10.0, 500.0),
]
BESIN_ETIKET = {anahtar: etiket for anahtar, etiket, *_ in TUM_BESIN_ALANLARI}
BESIN_ARALIK = {anahtar: (minv, maxv, def_alt, def_ust) for anahtar, _, minv, maxv, def_alt, def_ust in TUM_BESIN_ALANLARI}
