# asamalar_parti3.py
#
# Uretim asamalari -- III. Parti: orijinal 75 "Klasik" tariflik
# kutuphanenin II. Grup (corba/pilav/zeytinyagli/makarna/borek, 24 tarif)
# ve III. Grup (salata/tatli/komposto/yogurt/cacik/tursu, 20 tarif) --
# toplam 44 tarif. asamalar_parti1.py'deki sema ve kurallarla birebir
# ayni:
#   - Ardisik ayni-kap isil islemler TEK asamada birlestirildi (Delta T=0
#     hatasini onlemek icin, asamalar_parti2/I.Grup'ta uygulanan kural).
#   - Gercekten PARALEL yapilabilen bagimsiz asamalar ayni "sira" numarasini
#     alir ve sadece ortak on-kosula (genelde "Hazirlik") bagimlidir,
#     birbirlerine degil.
#   - Isil islem icermeyen (ham/salata/hazir urun) tarifler icin tek bir
#     "Hazirlik" asamasi var (isil_islem_mi=False, malzemeler=[]) --
#     iscilik suresi hala hesaba katilsin diye, enerji maliyeti sifir kalir.
#   - Enerji kaynagi: ocak ustu (kavurma/kaynatma/kizartma) = "dogalgaz",
#     firin = "elektrik" (asamalar_parti1/parti2 ile ayni yaklasim).
#   - "aktif_dakika" sadece toplam sureden (sure_dakika) FARKLI oldugunda
#     eklendi (ör. firinlama, demlenme gibi buyuk kismi pasif olan
#     asamalarda); esit oldugunda alan atlandi (asama_yukle.py zaten
#     bu durumda sure_dakika'yi kullaniyor).
#
# asama_yukle.py'nin import satirina bu dosya da eklenmelidir (bkz. asagida
# verilen guncellenmis asama_yukle.py).

ASAMALAR = {

    # ---------------------------------------------------------------
    # GRUP 2 -- Corba (6)
    # ---------------------------------------------------------------

    "Mercimek Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 30, "aktif_dakika": 12,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["KURU SOĞAN", "HAVUÇ", "KIRMIZI MERCİMEK", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Püre", "sira": 3, "sure_dakika": 2, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Ezogelin Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 35, "aktif_dakika": 15,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "KIRMIZI MERCİMEK",
                        "İNCE BULGUR", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Yayla Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pirinç Haşlama", "sira": 2, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["PİRİNÇ (HAM)"], "bagimli": ["Hazırlık"]},
        {"ad": "Terbiye ve Isıtma", "sira": 3, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 85,
         "verimlilik_orani": 0.45, "malzemeler": ["YOĞURT (TAM)"],
         "bagimli": ["Pirinç Haşlama"]},
    ],
    "Domates Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["KURU SOĞAN", "KONSERVE DOMATES", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Krema Ekleme", "sira": 3, "sure_dakika": 2, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 85,
         "verimlilik_orani": 0.4, "malzemeler": ["KREMA (SIVI)"],
         "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Tavuk Suyu Çorbası (Şehriyeli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 25, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["TAVUK SUYU", "HAVUÇ", "ŞEHRİYE"], "bagimli": ["Hazırlık"]},
    ],
    "Sebze Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 7, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 30, "aktif_dakika": 12,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["PIRASA", "HAVUÇ", "PATATES", "KEREVİZ", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 2 -- Pilav (5)
    # ---------------------------------------------------------------

    "Sade Pirinç Pilavı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.55,
         "malzemeler": ["PİRİNÇ (HAM)", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Bulgur Pilavı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 19, "aktif_dakika": 9,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.55,
         "malzemeler": ["KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "BULGUR", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Şehriyeli Pirinç Pilavı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 7,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.55,
         "malzemeler": ["ŞEHRİYE", "PİRİNÇ (HAM)", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Nohutlu Pilav": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 6,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.55,
         "malzemeler": ["PİRİNÇ (HAM)", "NOHUT", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Kuşkonmaz Risotto": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kademeli Pişirme", "sira": 2, "sure_dakika": 25, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 95,
         "verimlilik_orani": 0.5, "malzemeler": ["PİRİNÇ (HAM)", "KUŞKONMAZ", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 2 -- Zeytinyağlı (6)
    # ---------------------------------------------------------------

    "Zeytinyağlı Taze Fasulye": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 35, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.5,
         "malzemeler": ["KURU SOĞAN", "TAZE FASULYE", "DOMATES", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Zeytinyağlı Pırasa": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 30, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.5,
         "malzemeler": ["PIRASA", "HAVUÇ", "PİRİNÇ (HAM)", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Zeytinyağlı Enginar": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 12, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 30, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.5,
         "malzemeler": ["HAVUÇ", "ENGİNAR", "TAZE FASULYE", "ZEYTİNYAĞI", "LİMON SUYU"],
         "bagimli": ["Hazırlık"]},
    ],
    "Zeytinyağlı Kereviz": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 35, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.5,
         "malzemeler": ["HAVUÇ", "KEREVİZ", "PATATES", "ZEYTİNYAĞI", "LİMON SUYU"],
         "bagimli": ["Hazırlık"]},
    ],
    "İmam Bayıldı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Patlıcan Kızartma", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 175,
         "verimlilik_orani": 0.45, "malzemeler": ["PATLICAN", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "İç Harç Kavurma", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.5, "malzemeler": ["KURU SOĞAN", "SARIMSAK", "DOMATES"],
         "bagimli": ["Hazırlık"]},  # Patlıcan Kızartma İLE PARALEL
        {"ad": "Doldurma ve Pişirme", "sira": 3, "sure_dakika": 28, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.5,
         "malzemeler": ["PATLICAN", "KURU SOĞAN", "DOMATES"],
         "bagimli": ["Patlıcan Kızartma", "İç Harç Kavurma"]},
    ],
    "Zeytinyağlı Yaprak Sarma": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "İç Harç Kavurma", "sira": 2, "sure_dakika": 5, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.5, "malzemeler": ["KURU SOĞAN", "PİRİNÇ (HAM)", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Sarma", "sira": 3, "sure_dakika": 30, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["İç Harç Kavurma"]},
        {"ad": "Pişirme", "sira": 4, "sure_dakika": 38, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "verimlilik_orani": 0.5,
         "malzemeler": ["SALAMURA YAPRAK", "PİRİNÇ (HAM)", "LİMON SUYU"],
         "bagimli": ["Sarma"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 2 -- Makarna (3)
    # ---------------------------------------------------------------

    "Domates Soslu Makarna": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Makarna Haşlama", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["MAKARNA"], "bagimli": ["Hazırlık"]},
        {"ad": "Sos", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.5, "malzemeler": ["SARIMSAK", "KONSERVE DOMATES", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},  # Makarna Haşlama İLE PARALEL
        {"ad": "Birleştirme", "sira": 3, "sure_dakika": 2, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Makarna Haşlama", "Sos"]},
    ],
    "Fırın Makarna (Kıymalı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Makarna Haşlama", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["MAKARNA"], "bagimli": ["Hazırlık"]},
        {"ad": "Kıyma Sotesi", "sira": 2, "sure_dakika": 11, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.5, "malzemeler": ["SIĞIR KIYMA", "KREMA (SIVI)"],
         "bagimli": ["Hazırlık"]},  # Makarna Haşlama İLE PARALEL
        {"ad": "Fırınlama", "sira": 3, "sure_dakika": 17, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 200, "verimlilik_orani": 0.6,
         "malzemeler": ["MAKARNA", "SIĞIR KIYMA", "KAŞAR PEYNİRİ"],
         "bagimli": ["Makarna Haşlama", "Kıyma Sotesi"]},
    ],
    "Fesleğenli Pesto Makarna": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Makarna Haşlama", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["MAKARNA"], "bagimli": ["Hazırlık"]},
        {"ad": "Birleştirme", "sira": 3, "sure_dakika": 2, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Makarna Haşlama"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 2 -- Börek (4)
    # ---------------------------------------------------------------

    "Su Böreği (Peynirli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Yufka Haşlama", "sira": 2, "sure_dakika": 4, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["BUĞDAY UNU"], "bagimli": ["Hazırlık"]},
        {"ad": "İç Harç Hazırlama", "sira": 2, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Hazırlık"]},  # Yufka Haşlama İLE PARALEL
        {"ad": "Dizme ve Pişirme", "sira": 3, "sure_dakika": 22, "aktif_dakika": 15,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.55,
         "malzemeler": ["BUĞDAY UNU", "LOR PEYNİRİ", "TEREYAĞI"],
         "bagimli": ["Yufka Haşlama", "İç Harç Hazırlama"]},
    ],
    "Sigara Böreği (Peynirli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Sarma", "sira": 2, "sure_dakika": 18, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Hazırlık"]},
        {"ad": "Kızartma", "sira": 3, "sure_dakika": 3, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 175, "verimlilik_orani": 0.45,
         "malzemeler": ["BUĞDAY UNU", "AYÇİÇEK YAĞI"], "bagimli": ["Sarma"]},
    ],
    "Ispanaklı Börek": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Ispanak Kavurma", "sira": 2, "sure_dakika": 7, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.5, "malzemeler": ["ISPANAK"], "bagimli": ["Hazırlık"]},
        {"ad": "Harç Birleştirme", "sira": 3, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Ispanak Kavurma"]},
        {"ad": "Dizme ve Pişirme", "sira": 4, "sure_dakika": 27, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.55,
         "malzemeler": ["BUĞDAY UNU", "LOR PEYNİRİ", "TEREYAĞI"],
         "bagimli": ["Harç Birleştirme"]},
    ],
    "Kıymalı Börek": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kıyma Sotesi", "sira": 2, "sure_dakika": 11, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.5, "malzemeler": ["KURU SOĞAN", "SIĞIR KIYMA", "AYÇİÇEK YAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Dizme ve Pişirme", "sira": 3, "sure_dakika": 27, "aktif_dakika": 9,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.55,
         "malzemeler": ["BUĞDAY UNU"], "bagimli": ["Kıyma Sotesi"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 3 -- Salata (5)
    # ---------------------------------------------------------------

    "Çoban Salata": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Mevsim Yeşil Salata": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Roka Salatası (Parmesanlı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Kırmızı Lahana Salatası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Sezar Usulü Tavuklu Salata": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 7, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Tavuk Izgara", "sira": 2, "sure_dakika": 12, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.5, "malzemeler": ["TAVUK GÖĞÜS"], "bagimli": ["Hazırlık"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 3 -- Cacık / Yoğurt (2)
    # ---------------------------------------------------------------

    "Cacık": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Havuçlu Yoğurtlu Salata": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Havuç Haşlama", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["HAVUÇ"], "bagimli": ["Hazırlık"]},
        {"ad": "Birleştirme", "sira": 3, "sure_dakika": 2, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Havuç Haşlama"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 3 -- Turşu (2)
    # ---------------------------------------------------------------

    "Karışık Turşu": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Lahana Turşusu": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],

    # ---------------------------------------------------------------
    # GRUP 3 -- Komposto (3)
    # ---------------------------------------------------------------

    "Kayısı Kompostosu": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 18, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["KAYISI", "ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},
    ],
    "Vişne Kompostosu": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 16, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["VİŞNE", "ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},
    ],
    "Elma Kompostosu": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 7, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 18, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["ELMA", "ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},
    ],

    # ---------------------------------------------------------------
    # GRUP 3 -- Tatlı (8)
    # ---------------------------------------------------------------

    "Sütlaç": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pirinç Haşlama", "sira": 2, "sure_dakika": 11, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["PİRİNÇ (HAM)"], "bagimli": ["Hazırlık"]},
        {"ad": "Sütle Pişirme", "sira": 3, "sure_dakika": 22, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 95,
         "verimlilik_orani": 0.5, "malzemeler": ["SÜT (TAM YAĞ)", "ŞEKER", "MISIR NİŞASTASI"],
         "bagimli": ["Pirinç Haşlama"]},
    ],
    "Kazandibi": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Karışım Pişirme", "sira": 2, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 90,
         "verimlilik_orani": 0.5,
         "malzemeler": ["SÜT (TAM YAĞ)", "TAVUK GÖĞSÜ (TATLI)", "ŞEKER", "MISIR NİŞASTASI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Kazandibi Yakma", "sira": 3, "sure_dakika": 7, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 90, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.4, "malzemeler": ["SÜT (TAM YAĞ)", "TAVUK GÖĞSÜ (TATLI)"],
         "bagimli": ["Karışım Pişirme"]},
    ],
    "Revani": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kek Pişirme", "sira": 2, "sure_dakika": 28, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.55,
         "malzemeler": ["İRMİK", "BUĞDAY UNU", "TAVUK YUMURTASI"], "bagimli": ["Hazırlık"]},
        {"ad": "Şerbet", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 105,
         "verimlilik_orani": 0.5, "malzemeler": ["ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},  # Kek Pişirme İLE PARALEL
        {"ad": "Şerbetleme", "sira": 3, "sure_dakika": 30, "aktif_dakika": 3,
         "isil_islem_mi": False, "malzemeler": [],
         "bagimli": ["Kek Pişirme", "Şerbet"]},
    ],
    "Aşure": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Baklagil Haşlama", "sira": 2, "sure_dakika": 50, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["NOHUT", "KURU FASULYE", "SU"], "bagimli": ["Hazırlık"]},
        {"ad": "Buğday Haşlama", "sira": 2, "sure_dakika": 50, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["BUĞDAY UNU"], "bagimli": ["Hazırlık"]},  # Baklagil Haşlama İLE PARALEL
        {"ad": "Birleştirme ve Pişirme", "sira": 3, "sure_dakika": 22, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.5,
         "malzemeler": ["KURU KAYISI", "KURU ÜZÜM", "ŞEKER"],
         "bagimli": ["Baklagil Haşlama", "Buğday Haşlama"]},
    ],
    "Muhallebi": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 13, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 90,
         "verimlilik_orani": 0.5, "malzemeler": ["SÜT (TAM YAĞ)", "MISIR NİŞASTASI", "ŞEKER"],
         "bagimli": ["Hazırlık"]},
    ],
    "Cevizli Kadayıf Tatlısı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 27, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.55,
         "malzemeler": ["KADAYIF", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Şerbet", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 105,
         "verimlilik_orani": 0.5, "malzemeler": ["ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},  # Fırınlama İLE PARALEL
        {"ad": "Şerbetleme", "sira": 3, "sure_dakika": 30, "aktif_dakika": 2,
         "isil_islem_mi": False, "malzemeler": [],
         "bagimli": ["Fırınlama", "Şerbet"]},
    ],
    "Meyveli Panna Cotta": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 85,
         "verimlilik_orani": 0.45,
         "malzemeler": ["KREMA (AĞIR)", "SÜT (TAM YAĞ)", "JELATİN", "ŞEKER"],
         "bagimli": ["Hazırlık"]},
    ],
    "Mevsim Meyve Tabağı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],

}
