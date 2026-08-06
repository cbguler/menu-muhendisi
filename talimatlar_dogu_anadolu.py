# talimatlar_dogu_anadolu.py
#
# Pisirme talimatlari -- Dogu Anadolu Bolgesi (24 tarif, 7. ve son bolge,
# dogu_anadolu_tarifleri.py). Ayni v2 formati. talimat_yukle.py ile
# Supabase'e islenir.

TALIMATLAR = {

    "Cağ Kebabı": """**Hazırlık / Mise en Place**
1. Soğanı rendeleyin — marinasyonda etin daha iyi yumuşaması için soğan suyu doğrudan etle temas etmeli.
2. Kuzu tandırı ince dilimler halinde rendelenmiş soğan ve karabiberle marine edip yatay şişe dizin.

**Isıl İşlem**
1. Izgara (~200°C, yatay şişte, 15 dk): şişi döndürerek dış yüzeyi kızaran kısmı ince ince kesip servis edin, dönüşümlü olarak pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı, sürekli izleme gerektiren bir teknik — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk (sürekli kesme+döndürme) · Pasif bekleme yok · Toplam ~35 dk""",

    "Van Usulü Kahvaltı Tabağı (Otlu Peynirli)": """**Hazırlık / Mise en Place**
1. Otlu peyniri dilimleyin, balı kaseye koyun.

**Isıl İşlem**
1. Yumurta Pişirme (~100°C, tavada, 8 dk): tereyağında yumurtaları sahanda pişirin.

**Servis:** otlu peynir ve balı yanında ısıl işlemsiz servis edin.

**PARALEL YAPILABİLİRLİK:** Otlu peynir dilimleme, yumurta pişerken paralel yapılabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme yok · Toplam ~15 dk""",

    "Kadayıf Dolması (Etli, Erzurum)": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, kadayıfı didikleyin.

**Isıl İşlem**
1. Kıyma Sotesi (~150°C, tavada, 10 dk): soğanı kavurup kıymayı ekleyin, suyunu çekene kadar pişirin, ılımaya bırakın.
2. Sarma (aktif, elle, 15 dk): ılımış kıyma harcını kadayıf tutamlarıyla sarın.
3. Fırınlama (~180°C, 20 dk): sarılan kadayıf dolmalarını tereyağıyla üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Kıyma sotesi pişerken kadayıf didikleme tamamlanabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk (sarma dahil) · Pasif bekleme (fırınlama) ~17 dk · Toplam ~55 dk""",

    "Erzincan Usulü Kavurmalı Yumurta": """**Hazırlık / Mise en Place**
1. Pastırmayı ince dilimleyin.

**Isıl İşlem**
1. Pişirme (~100°C, tavada, 7 dk): tereyağında pastırmayı kavurup yumurtaları kırıp üzerinde pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı, hızlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Tulumlu Kuzu Tandır": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın.

**Isıl İşlem**
1. Ağır Ateş Pişirme (~155°C, tencerede/fırında kapalı, 75 dk): kuzu tandırı soğanla birlikte çok kısık ateşte lifler ayrılana kadar uzun süre pişirin.

**Peynir Ekleme:** servis öncesi üzerine tulum peyniri serpin (ısıl işlem gerekmez, sıcaklığıyla hafif erir).

**PARALEL YAPILABİLİRLİK:** Uzun pasif pişirme süresi boyunca başka tariflerin hazırlığına geçilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (uzun ağır ateş) ~67 dk · Toplam ~100 dk""",

    "Erzurum Usulü Etli Ekmek": """**Hazırlık / Mise en Place**
1. Hamuru yoğurup açın.
2. Soğanı doğrayın.

**Isıl İşlem**
1. Kıyma Sotesi (~150°C, tavada, 10 dk): soğanı kavurup kıymayı ekleyin, suyunu çekene kadar pişirin.
2. Fırınlama (~200°C, 15 dk): hamuru kıyma harcıyla doldurup kenarlarını kapatarak fırında kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kıyma sotesi tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (hamur açma dahil) · Pasif bekleme (fırınlama) ~13 dk · Toplam ~45 dk""",

    "Otlu Peynirli Gözleme": """**Hazırlık / Mise en Place**
1. Yufkaya otlu peyniri serpip katlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): gözlemeyi tereyağıyla her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac ısınırken doldurma tamamlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (aktif izleme gerektirir) · Pasif bekleme yok · Toplam ~20 dk""",

    "Kavurma (Erzurum Usulü)": """**Hazırlık / Mise en Place**
1. Kıymayı hazırlayın.

**Isıl İşlem**
1. Kavurma (~150°C, tavada, 30 dk): kıymayı kendi yağında, karabiber ve tuzla suyunu çekip kavrulana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme) ~25 dk · Toplam ~40 dk""",

    "Erzurum Usulü Etli Nohut": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, nohut önceden haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma ve Pişirme (100°C, 40 dk): soğanı kavurup kıyma ve nohudu ekleyin, az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme) ~35 dk · Toplam ~55 dk""",

    "Ayran Aşı (Etli)": """**Hazırlık / Mise en Place**
1. Yoğurdu çırpıp pürüzsüzleştirin.

**Isıl İşlem**
1. Kıyma Sotesi (~150°C, tavada, 10 dk): kıymayı kendi yağında kavurun.
2. Terbiye ve Kaynatma (~90°C, kısık ateş, sürekli karıştırarak, 15 dk): yoğurt, un ve suyu ekleyip sürekli karıştırarak kaynatmadan kıvam alana kadar pişirin, kıymayı katıp nane serpin.

**PARALEL YAPILABİLİRLİK:** Kıyma sotesi ile yoğurt karışımının hazırlanması AYRI ocak gözlerinde eş zamanlı yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk (terbiye adımı sürekli karıştırma gerektirir) · Pasif bekleme yok · Paralel yapılırsa toplam ~20 dk, sıralı yapılırsa ~25 dk""",

    "Doğu Anadolu Usulü Mercimek Çorbası": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 25 dk): tereyağında soğanı kavurup mercimek ve suyu ekleyin, mercimek yumuşayana kadar kaynatın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (kaynama) ~20 dk · Toplam ~35 dk""",

    "Tulumlu Bulgur Pilavı": """**Hazırlık / Mise en Place**
1. Bulguru durulayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): tereyağında bulguru kavurup sıcak su ve tuzla su çekilene kadar pişirin, ocaktan alıp tulum peynirini karıştırın.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Erzurum Usulü Kavurmalı Kuru Fasulye": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, kuru fasulyeyi (önceden ıslatılmış/haşlanmış) süzün.

**Isıl İşlem**
1. Kavurma ve Pişirme (100°C, 55 dk): soğanı kavurup kıymayı ekleyin, fasulyeyi katıp az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~45 dk · Toplam ~70 dk""",

    "Otlu Peynirli Börek": """**Hazırlık / Mise en Place**
1. Yufka katmanları arasına otlu peyniri serpiştirin.

**Isıl İşlem**
1. Fırınlama (~180°C, 20 dk): tereyağıyla üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken dizme tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~17 dk · Toplam ~35 dk""",

    "Nohutlu Erişte": """**Hazırlık / Mise en Place**
1. Un, yumurta ve suyla eriştelik hamur hazırlayıp ince açıp kesin.

**Isıl İşlem**
1. Haşlama (100°C, 15 dk): erişteyi ve önceden haşlanmış nohudu tereyağıyla birlikte kaynar suda haşlayın.

**PARALEL YAPILABİLİRLİK:** Hamur açma/kesme işlemi elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk (hamur açma dahil) · Pasif bekleme (haşlama) ~13 dk · Toplam ~35 dk""",

    "Kaymaklı Bulgur Çorbası": """**Hazırlık / Mise en Place**
1. Bulguru durulayın.

**Isıl İşlem**
1. Kaynatma (100°C, 20 dk): tereyağında bulguru kısaca kavurup suyu ekleyin, yumuşayana kadar kaynatın.

**Kaymak Ekleme:** servis anında üzerine kaymak ekleyin (ısıl işlem gerekmez).

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (kaynama) ~15 dk · Toplam ~30 dk""",

    "Bal Kaymak": """**Hazırlık / Mise en Place**
1. Kaymağı tabağa yayın, üzerine balı gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — kütüphanedeki en hızlı tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Erzurum Usulü Kayısı Tatlısı (Ballı)": """**Hazırlık / Mise en Place**
1. Kuru kayısıları ortadan yarıp içine ceviz ve bal doldurun.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (doldurma dahil) · Pasif bekleme yok · Toplam ~15 dk""",

    "Otlu Peynir Tabağı (Meze)": """**Hazırlık / Mise en Place**
1. Otlu peyniri dilimleyin, cevizle birlikte tabağa düzenleyin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Yoğurtlu Semizotu Salatası": """**Hazırlık / Mise en Place**
1. Semizotunu yıkayıp doğrayın.
2. Yoğurt ve sarımsağı karıştırıp üzerine dökün.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Ballı Ceviz Tabağı": """**Hazırlık / Mise en Place**
1. Cevizi tabağa düzenleyip üzerine bal gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — kütüphanedeki en hızlı tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Erzurum Usulü Kete": """**Hazırlık / Mise en Place**
1. Un, şeker, tereyağı ve yumurtayı yoğurup hamur yapın, şekil verin.

**Isıl İşlem**
1. Fırınlama (~180°C, 25 dk): hamur parçalarını kürdan temiz çıkana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~25 dk · Toplam ~45 dk""",

    "Doğu Anadolu Usulü Karışık Turşu": """**Hazırlık / Mise en Place**
1. Hazır (konserve) turşuyu süzün, sirkeyle karıştırıp servis tabağına düzenleyin.

**Isıl İşlem**
Isıl işlem yok. Not: bu tarif, önceden fermente edilmiş/hazır turşunun servise hazırlanmasını kapsar.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Doğu Anadolu Usulü Kayısı Kompostosu": """**Hazırlık / Mise en Place**
1. Kayısıları yıkayıp çekirdeklerini çıkarın.

**Isıl İşlem**
1. Kaynatma (100°C, 18 dk): kayısı, şeker ve suyu kaynattıktan sonra kısık ateşte pişirin.

**Soğutma (pasif, en az 60 dk):** komposto soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) ~75+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

}
