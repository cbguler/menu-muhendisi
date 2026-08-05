# asamalar_akdeniz.py
#
# Uretim asamalari -- Akdeniz Bolgesi (24 tarif). asamalar_parti1.py'deki
# sema ve kurallarla birebir ayni. Verimlilik oranlari 5 Agustos 2026
# duzeltmesinden itibaren KAYNAKLI ticari ekipman sabitleriyle yazildi:
#   dogalgaz ocak/kavurma/kaynatma/hasla/sote/pisirme: 0.42
#   dogalgaz kizartma: 0.4
#   elektrik firinlama: 0.58
#   izgara (dogrudan alev): 0.35 -- KAYNAKLANMADI, projenin ilk oturumundan
#   korunan tahmini deger.

ASAMALAR = {

    "Adana Kebap": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Izgara", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.35, "malzemeler": ["SIĞIR KIYMA"], "bagimli": ["Hazırlık"]},
    ],
    "Akdeniz Usulü Karides Sote": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Sote", "sira": 2, "sure_dakika": 12, "aktif_dakika": 12,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "verimlilik_orani": 0.42,
         "malzemeler": ["KARİDES", "SARIMSAK", "DOMATES", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Muhammara Soslu Tavuk": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Tavuk Sote", "sira": 2, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.42, "malzemeler": ["TAVUK GÖĞÜS"], "bagimli": ["Hazırlık"]},
    ],
    "Akdeniz Usulü Fırın Levrek (Sumaklı)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Fırınlama", "sira": 2, "sure_dakika": 20, "aktif_dakika": 3,
         "isil_islem_mi": True, "enerji_kaynagi": "elektrik",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 200, "verimlilik_orani": 0.58,
         "malzemeler": ["LEVREK", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Nar Ekşili Köfte": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Izgara", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.35, "malzemeler": ["SIĞIR KIYMA"], "bagimli": ["Hazırlık"]},
    ],
    "Sumaklı Tavuk Şiş": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Izgara", "sira": 2, "sure_dakika": 12, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 200,
         "verimlilik_orani": 0.35, "malzemeler": ["TAVUK GÖĞÜS"], "bagimli": ["Hazırlık"]},
    ],
    "Etli Yeşil Mercimek Yemeği": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 35, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "SIĞIR KIYMA", "YEŞİL MERCİMEK"], "bagimli": ["Hazırlık"]},
    ],
    "Karidesli Bulgur Pilavı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 19, "aktif_dakika": 8,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "KARİDES", "BULGUR", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Patlıcan Kebabı (Yoğurtlu)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Patlıcan Kızartma", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 175,
         "verimlilik_orani": 0.4, "malzemeler": ["PATLICAN"], "bagimli": ["Hazırlık"]},
        {"ad": "Kıyma Sotesi", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.42, "malzemeler": ["SIĞIR KIYMA"],
         "bagimli": ["Hazırlık"]},  # Patlıcan Kızartma İLE PARALEL
        {"ad": "Birleştirme ve Servis", "sira": 3, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Patlıcan Kızartma", "Kıyma Sotesi"]},
    ],

    "Yeşil Mercimek Çorbası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 30, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "YEŞİL MERCİMEK", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Akdeniz Usulü Bulgur Pilavı (Domatesli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 3, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Kaynatma", "sira": 2, "sure_dakika": 15, "aktif_dakika": 7,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "BULGUR", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
        {"ad": "Demlendirme", "sira": 3, "sure_dakika": 10, "aktif_dakika": 0,
         "isil_islem_mi": False, "malzemeler": [], "bagimli": ["Kavurma ve Kaynatma"]},
    ],
    "Nar Ekşili Zeytinyağlı Patlıcan": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 30, "aktif_dakika": 12,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "PATLICAN", "NAR EKŞİSİ", "ZEYTİNYAĞI"],
         "bagimli": ["Hazırlık"]},
    ],
    "Zeytinyağlı Kabak (Akdeniz Usulü)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 25, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "KABAK", "DOMATES", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Sumaklı Mercimek Köftesi": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Mercimek Haşlama", "sira": 2, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.42, "malzemeler": ["KIRMIZI MERCİMEK"], "bagimli": ["Hazırlık"]},
        {"ad": "Yoğurma ve Şekillendirme", "sira": 3, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Mercimek Haşlama"]},
    ],
    "Hatay Usulü Katmer (Peynirli)": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 15, "aktif_dakika": 15,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.42,
         "malzemeler": ["YUFKA", "LOR PEYNİRİ", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
    ],
    "Akdeniz Usulü Bakla": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma ve Pişirme", "sira": 2, "sure_dakika": 30, "aktif_dakika": 10,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "verimlilik_orani": 0.42,
         "malzemeler": ["KURU SOĞAN", "BAKLA", "ZEYTİNYAĞI"], "bagimli": ["Hazırlık"]},
    ],

    "Humus": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Muhammara": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Nar Ekşili Roka Salatası": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Kısır": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Nar Ekşili Yoğurt": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 8, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Künefe": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Pişirme", "sira": 2, "sure_dakika": 15, "aktif_dakika": 15,
         "isil_islem_mi": True, "enerji_kaynagi": "dogalgaz",
         "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "verimlilik_orani": 0.42,
         "malzemeler": ["KADAYIF", "KAŞAR PEYNİRİ", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Şerbet", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 105,
         "verimlilik_orani": 0.42, "malzemeler": ["ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},  # Pişirme İLE PARALEL
    ],
    "Nar Taneli Meyve Tabağı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
    ],
    "Şam Tatlısı": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Kavurma", "sira": 2, "sure_dakika": 10, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 110,
         "verimlilik_orani": 0.42, "malzemeler": ["İRMİK", "TEREYAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Şerbet", "sira": 2, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 105,
         "verimlilik_orani": 0.42, "malzemeler": ["ŞEKER", "SU"],
         "bagimli": ["Hazırlık"]},  # Kavurma İLE PARALEL
        {"ad": "Şerbetleme", "sira": 3, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": ["Kavurma", "Şerbet"]},
    ],

}
