# asamalar_karadeniz.py
#
# Uretim asamalari -- Karadeniz Bolgesi (20 tarif). asamalar_parti1.py'deki
# sema ve kurallarla birebir ayni.

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

    "Karadeniz Usulü Hamsi Buğulama": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 13, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Buğulama", "sira": 2, "sure_dakika": 20, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["HAMSİ", "KURU SOĞAN", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Akçaabat Köfte": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Izgara", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.35, "malzemeler": ["SIĞIR KIYMA"], "bagimli": ["Hazırlık"]},
    ],
    "Karalahana Sarması (Etli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "İç Harç Kavurma", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.42, "malzemeler": ["SIĞIR KIYMA", "PİRİNÇ (HAM)", "MISIR UNU", "KURU SOĞAN"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Sarma", "sira": 3, "sure_dakika": 35, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["İç Harç Kavurma"]},
        {"ad": "Pişirme", "sira": 4, "sure_dakika": 40, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "verimlilik_orani": 0.42,
         "malzemeler": ["KARALAHANA"], "bagimli": ["Sarma"]},
    ],
    "Hamsili Pilav": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pilav Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "ÇAM FISTIĞI", "KUŞ ÜZÜMÜ", "PİRİNÇ (HAM)", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Hamsi Kızartma", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 175,
         "verimlilik_orani": 0.4, "malzemeler": ["HAMSİ"],
         "bagimli": ["Hazırlık"]},  # Pilav Kavurma ve Kaynatma İLE PARALEL
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Pilav Kavurma ve Kaynatma"]},
    ],
    "Kuymak (Muhlama)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 2, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 18, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 95,
         "verimlilik_orani": 0.42,
         "malzemeler": ["MISIR UNU", "TEREYAĞI", "SU", "KAŞAR PEYNİRİ"],
         "bagimli": ["Hazırlık"]},
    ],
    "Karadeniz Usulü Palamut Izgara": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Izgara", "sira": 2, "sure_dakika": 12, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.35, "malzemeler": ["PALAMUT"], "bagimli": ["Hazırlık"]},
    ],
    "Fındıklı Tavuk Sote": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 6, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Sote", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 150, "verimlilik_orani": 0.42,
         "malzemeler": ["TAVUK GÖĞÜS", "FINDIK", "KURU SOĞAN", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Karadeniz Usulü Fasulye Pilaki": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 45, "aktif_dakika": 12,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU FASULYE", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],

    "Karalahana Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 35, "aktif_dakika": 13,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KARALAHANA", "KURU FASULYE", "MISIR UNU", "TEREYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Mısır Çorbası (Karadeniz Usulü)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kaynatma", "sira": 2, "sure_dakika": 20, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["MISIR", "SÜT (TAM YAĞ)", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Karadeniz Pidesi (Kıymalı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kıyma Sotesi", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.42, "malzemeler": ["SIĞIR KIYMA", "KURU SOĞAN"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Fırınlama", "sira": 3, "sure_dakika": 15, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 200, "verimlilik_orani": 0.58,
         "malzemeler": ["BUĞDAY UNU", "KAŞAR PEYNİRİ"], "bagimli": ["Kıyma Sotesi"]},
    ],
    "Mısır Ekmeği": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 25, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 200, "verimlilik_orani": 0.58,
         "malzemeler": ["MISIR UNU", "BUĞDAY UNU", "SU"], "bagimli": ["Hazırlık"]},
    ],
    "Fındıklı Pirinç Pilavı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 15, "aktif_dakika": 7,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["PİRİNÇ (HAM)", "FINDIK", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Kolot Böreği (Peynirli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 20, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 25, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.58,
         "malzemeler": ["YUFKA", "LOR PEYNİRİ", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
    ],

    "Laz Böreği": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Krema Pişirme", "sira": 2, "sure_dakika": 12, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 90,
         "verimlilik_orani": 0.42, "malzemeler": ["SÜT (TAM YAĞ)", "MISIR NİŞASTASI", "ŞEKER"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Fırınlama", "sira": 3, "sure_dakika": 20, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.58,
         "malzemeler": ["YUFKA", "TEREYAĞI"], "bagimli": ["Krema Pişirme"]},
    ],
    "Kete (Karadeniz Tatlısı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 25, "aktif_dakika": 5,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.58,
         "malzemeler": ["BUĞDAY UNU", "ŞEKER", "TEREYAĞI", "TAVUK YUMURTASI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Fındıklı Kurabiye": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 20, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 170, "verimlilik_orani": 0.58,
         "malzemeler": ["BUĞDAY UNU", "FINDIK", "TEREYAĞI", "ŞEKER", "TAVUK YUMURTASI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Karadeniz Yeşil Salata": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Karalahana Turşusu": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Fındıklı Sütlaç": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pirinç Haşlama", "sira": 2, "sure_dakika": 11, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.42, "malzemeler": ["PİRİNÇ (HAM)"], "bagimli": ["Hazırlık"]},
        {"ad": "Sütle Pişirme", "sira": 3, "sure_dakika": 22, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 95,
         "verimlilik_orani": 0.42,
         "malzemeler": ["SÜT (TAM YAĞ)", "ŞEKER", "FINDIK", "MISIR NİŞASTASI"],
         "bagimli": ["Pirinç Haşlama"]},
    ],

}
