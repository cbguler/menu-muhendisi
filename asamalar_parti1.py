# asamalar_parti1.py
#
# Uretim asamalari -- I. Parti (kanit-kavram/pilot): pisirme talimatlarini
# YAPISAL veriye donusturup mevcut "Uretim Asamalari" maliyet motoruna
# (recete_asamalari / asama_malzemeleri / asama_bagimliliklari, zaten var
# olan sema -- 10_uretim_maliyet_semasi.sql) baglar. Bu sema isletmeye
# ozel DEGIL -- herhangi bir recete_id icin calisir (global kutuphane
# tarifleri dahil), sadece enerji/iscilik ORANLARI (isletme_maliyet_ayarlari)
# oturum acan isletmeye ozeldir.
#
# 3 tarifle basliyoruz (farkli karmasiklik oruntuleri icin secildi):
#   - Menemen: basit, sirali, paralellik firsati yok
#   - Karniyarik: iki asamanin (patlican kizartma / kiyma harci) PARALEL
#     yapilabildigi klasik ornek
#   - Kuzu Tandir: uzun PASIF firin suresi agirlikli
#
# asama_yukle.py ile (recete_id/recete_malzeme_id'yi isme gore cozerek)
# Supabase'e islenir.

ASAMALAR = {
    "Menemen": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 5, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Biber Kavurma", "sira": 2, "sure_dakika": 4, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.5, "malzemeler": ["YEŞİL BİBER"], "bagimli": ["Hazırlık"]},
        {"ad": "Domates Pişirme", "sira": 3, "sure_dakika": 5, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.5, "malzemeler": ["DOMATES"], "bagimli": ["Biber Kavurma"]},
        {"ad": "Yumurta Pişirme", "sira": 4, "sure_dakika": 4, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 100,
         "verimlilik_orani": 0.5, "malzemeler": ["TAVUK YUMURTASI"], "bagimli": ["Domates Pişirme"]},
    ],
    "Karnıyarık": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 15, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Patlıcan Kızartma", "sira": 2, "sure_dakika": 9, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 175,
         "verimlilik_orani": 0.45, "malzemeler": ["PATLICAN", "AYÇİÇEK YAĞI"], "bagimli": ["Hazırlık"]},
        {"ad": "Kıyma Harcı", "sira": 2, "sure_dakika": 8, "isil_islem_mi": True,
         "enerji_kaynagi": "dogalgaz", "baslangic_sicaklik": 20, "hedef_sicaklik": 150,
         "verimlilik_orani": 0.5, "malzemeler": ["SIĞIR KIYMA", "KURU SOĞAN", "DOMATES"],
         "bagimli": ["Hazırlık"]},  # Patlıcan Kızartma İLE PARALEL -- ona bağımlı DEĞİL
        {"ad": "Montaj ve Fırınlama", "sira": 3, "sure_dakika": 22, "aktif_dakika": 4, "isil_islem_mi": True,
         "enerji_kaynagi": "elektrik", "baslangic_sicaklik": 20, "hedef_sicaklik": 180,
         "verimlilik_orani": 0.6, "malzemeler": ["PATLICAN", "SIĞIR KIYMA"],
         "bagimli": ["Patlıcan Kızartma", "Kıyma Harcı"]},
    ],
    "Kuzu Tandır": [
        {"ad": "Hazırlık", "sira": 1, "sure_dakika": 10, "isil_islem_mi": False,
         "malzemeler": [], "bagimli": []},
        {"ad": "Ağır Ateş Fırınlama", "sira": 2, "sure_dakika": 165, "aktif_dakika": 6, "isil_islem_mi": True,
         "enerji_kaynagi": "elektrik", "baslangic_sicaklik": 20, "hedef_sicaklik": 155,
         "verimlilik_orani": 0.55, "malzemeler": ["KUZU TANDIR"], "bagimli": ["Hazırlık"]},
        {"ad": "Kızartma", "sira": 3, "sure_dakika": 15, "isil_islem_mi": True,
         "enerji_kaynagi": "elektrik", "baslangic_sicaklik": 155, "hedef_sicaklik": 210,
         "verimlilik_orani": 0.55, "malzemeler": ["KUZU TANDIR"], "bagimli": ["Ağır Ateş Fırınlama"]},
    ],
}
