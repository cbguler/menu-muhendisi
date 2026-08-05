# asamalar_ege.py
#
# Uretim asamalari -- Ege Bolgesi (26 tarif). asamalar_parti1.py'deki sema
# ve kurallarla birebir ayni.

# ---------------------------------------------------------------------
# 5 Agustos 2026 duzeltmesi: Bu uygulama ev kullanicilari icin degil,
# TICARI (restoran) kullanim icin tasarlaniyor -- bu yuzden verimlilik_orani
# degerleri ev tipi degil TICARI MUTFAK EKIPMANI verilerine dayanir (web
# arastirmasiyla dogrulandi, kaynaklar PROJE_NOTLARI.md'de):
#   - dogalgaz + ocak/kavurma/kaynatma/hasla/sote/pisirme: 0.42
#     (ticari acik alevli ocak brulanleri, sanayi kaynaklarina gore
#     dusukten-orta %40'lar araliginda genel isil verimlilik)
#   - dogalgaz + kizartma: 0.4 (ENERGY STAR sertifikasiz standart ticari
#     gazli fritoz, sertifikali minimum %50'nin ~%30 altinda)
#   - elektrik + firinlama: 0.58 (ENERGY STAR sertifikasiz standart ticari
#     elektrikli konveksiyonlu firin, sertifikali minimum %71-76'nin ~%27
#     altinda)
#   - izgara (dogrudan alev/izgara): 0.35 -- BU DEGER KAYNAKLANMADI, projenin
#     ilk oturumunda belirlenen tahmini bir deger, tutarlilik icin korundu.
# Sure/sicaklik degerleri hala tarif-ozel TAHMINDIR, dogrulanmamistir.
# ---------------------------------------------------------------------
ASAMALAR = {

    "Zeytinyağlı Bakla": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 30, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "BAKLA", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Ahtapot Izgara": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Haşlama", "sira": 2, "sure_dakika": 20, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.42, "malzemeler": ["AHTAPOT"], "bagimli": ["Hazırlık"]},
        {"ad": "Izgara", "sira": 3, "sure_dakika": 5, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 100, "hedef_sicaklik": 220,
         "verimlilik_orani": 0.35, "malzemeler": ["AHTAPOT", "ZEYTİNYAĞI"],
         "bagimli": ["Haşlama"]},
    ],
    "Pazı Kavurma (Etli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma", "sira": 2, "sure_dakika": 25, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 150, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "SIĞIR KIYMA", "PAZI"], "bagimli": ["Hazırlık"]},
    ],
    "Fırında Çipura (Sebzeli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 20, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 200, "verimlilik_orani": 0.58,
         "malzemeler": ["ÇİPURA", "DOMATES", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "İzmir Köfte": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Köfte Kızartma", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 175,
         "verimlilik_orani": 0.4, "malzemeler": ["SIĞIR KIYMA"], "bagimli": ["Hazırlık"]},
        {"ad": "Patates Kızartma", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 175,
         "verimlilik_orani": 0.4, "malzemeler": ["PATATES"],
         "bagimli": ["Hazırlık"]},  # Köfte Kızartma İLE PARALEL
        {"ad": "Sos ve Pişirme", "sira": 3, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 95,
         "verimlilik_orani": 0.42, "malzemeler": ["KONSERVE DOMATES", "KURU SOĞAN"],
         "bagimli": ["Köfte Kızartma", "Patates Kızartma"]},
    ],
    "Etli Enginar Dolması": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "İç Harç Kavurma", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.42, "malzemeler": ["SIĞIR KIYMA", "KURU SOĞAN", "PİRİNÇ (HAM)"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Doldurma ve Pişirme", "sira": 3, "sure_dakika": 30, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["ENGİNAR KALBİ"], "bagimli": ["İç Harç Kavurma"]},
    ],
    "Midyeli Pilav": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "MİDYE", "PİRİNÇ (HAM)"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Domates Dolması (Zeytinyağlı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "İç Harç Kavurma", "sira": 2, "sure_dakika": 6, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.42, "malzemeler": ["KURU SOĞAN", "PİRİNÇ (HAM)", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Doldurma ve Pişirme", "sira": 3, "sure_dakika": 28, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["DOMATES"], "bagimli": ["İç Harç Kavurma"]},
    ],
    "Ege Usulü Fırın Tavuk (Zeytinli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 35, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 200, "verimlilik_orani": 0.58,
         "malzemeler": ["TAVUK BUT", "SİYAH ZEYTİN", "DOMATES", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Bademli Tavuk Sote": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 6, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Sote", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 150, "verimlilik_orani": 0.42,
         "malzemeler": ["TAVUK GÖĞÜS", "BADEM", "KURU SOĞAN", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],

    "Pazı Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 25, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["PAZI", "PİRİNÇ (HAM)", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Ege Otlu Bulgur Pilavı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 15, "aktif_dakika": 7,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "BULGUR", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Zeytinyağlı Enginar Kalbi": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["ENGİNAR KALBİ", "HAVUÇ", "ZEYTİNYAĞI", "LİMON SUYU"],
         "bagimli": ["Hazırlık"]},
    ],
    "Zeytinyağlı Radika": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["RADİKA", "ZEYTİNYAĞI", "LİMON SUYU"], "bagimli": ["Hazırlık"]},
    ],
    "Bademli Pilav": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 15, "aktif_dakika": 6,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["PİRİNÇ (HAM)", "BADEM", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Ispanaklı Makarna (Ege Usulü)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Makarna Haşlama", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.42, "malzemeler": ["MAKARNA"], "bagimli": ["Hazırlık"]},
        {"ad": "Ispanak Sotesi", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.42, "malzemeler": ["SARIMSAK", "ISPANAK", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},  # Makarna Haşlama İLE PARALEL
        {"ad": "Birleştirme", "sira": 3, "sure_dakika": 2, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Makarna Haşlama", "Ispanak Sotesi"]},
    ],
    "Zeytinyağlı Yer Elması": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 25, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["YER ELMASI", "HAVUÇ", "ZEYTİNYAĞI", "LİMON SUYU"],
         "bagimli": ["Hazırlık"]},
    ],
    "Ege Peynirli Gözleme": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 15, "aktif_dakika": 15,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.42,
         "malzemeler": ["YUFKA", "LOR PEYNİRİ", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
    ],

    "Radika Salatası (Haşlanmış)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Haşlama", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.42, "malzemeler": ["RADİKA"], "bagimli": ["Hazırlık"]},
    ],
    "Midye Dolma": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 20, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 35, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["MİDYE", "PİRİNÇ (HAM)", "KURU SOĞAN"], "bagimli": ["Hazırlık"]},
    ],
    "Bademli Kurabiye": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 20, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 170, "verimlilik_orani": 0.58,
         "malzemeler": ["BUĞDAY UNU", "BADEM", "TEREYAĞI", "ŞEKER", "TAVUK YUMURTASI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Şeftalili Komposto": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 7, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.42, "malzemeler": ["ŞEFTALİ", "ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},
    ],
    "Üzüm Salatası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "İncir Tatlısı (Kremalı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Zeytin Ezmesi": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Limonlu Kek": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 30, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.58,
         "malzemeler": ["BUĞDAY UNU", "ŞEKER", "TEREYAĞI", "TAVUK YUMURTASI"],
         "bagimli": ["Hazırlık"]},
    ],

}
