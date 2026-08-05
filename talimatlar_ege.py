# talimatlar_ege.py
#
# Pisirme talimatlari -- Ege Bolgesi (26 tarif, ege_tarifleri.py).
# Ayni v2 formati. talimat_yukle.py ile Supabase'e islenir.

TALIMATLAR = {

    # ----------------------------- GRUP 1 (10) -----------------------------

    "Zeytinyağlı Bakla": """**Hazırlık / Mise en Place**
1. Baklaları ayıklayın, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 30 dk): zeytinyağında soğanı kavurup baklayı ekleyin, az suyla yumuşayana kadar pişirin, dereotunu karıştırın.

**Soğutma (pasif):** zeytinyağlılar oda sıcaklığında/soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~40 dk""",

    "Ahtapot Izgara": """**Hazırlık / Mise en Place**
1. Ahtapotu temizleyin.

**Isıl İşlem**
1. Haşlama (100°C, 20 dk): ahtapotu yumuşayana kadar haşlayın.
2. Izgara (~220°C, 5 dk): haşlanmış ahtapotu zeytinyağı ve limonla ızgarada kısa süre kızartın.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken haşlama tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (haşlama) ~20 dk · Toplam ~35 dk""",

    "Pazı Kavurma (Etli)": """**Hazırlık / Mise en Place**
1. Pazıyı yıkayıp doğrayın, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma (~150°C, tavada, 25 dk): soğanı kavurup kıymayı ekleyin, kıyma pişince pazıyı ekleyip yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme) ~20 dk · Toplam ~30 dk""",

    "Fırında Çipura (Sebzeli)": """**Hazırlık / Mise en Place**
1. Çipurayı temizleyin, domatesi dilimleyin.

**Isıl İşlem**
1. Fırınlama (~200°C, 20 dk): balığı domates, zeytinyağı ve limonla fırın kabına yerleştirip pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (fırınlama) ~20 dk · Toplam ~35 dk""",

    "İzmir Köfte": """**Hazırlık / Mise en Place**
1. Kıymayı soğanla yoğurup köfte şekli verin.
2. Patatesi doğrayın.

**Isıl İşlem**
1. Köfte Kızartma (~175°C, tavada, 10 dk): köfteleri her yüzü pişene kadar kızartın.
2. Patates Kızartma (~175°C, ayrı tavada, 10 dk): patatesleri kızartın.
3. Sos ve Pişirme (~95°C, 15 dk): köfte ve patatesi fırın kabına alıp üzerine domates sosunu dökerek pişirin.

**PARALEL YAPILABİLİRLİK:** Köfte kızartma ve patates kızartma AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~20 dk'yı ~10 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme (fırın pişirme) ~15 dk · Paralel yapılırsa toplam ~25 dk, sıralı yapılırsa ~35 dk""",

    "Etli Enginar Dolması": """**Hazırlık / Mise en Place**
1. Enginar kalplerini hazırlayın, soğanı doğrayın.

**Isıl İşlem**
1. İç Harç Kavurma (~110°C, tavada, 8 dk): soğanı kavurup kıyma ve pirinci ekleyin, kısaca kavurun.
2. Doldurma ve Pişirme (~95°C, kısık ateş, kapalı, 30 dk): enginar kalplerini harçla doldurup az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Enginar kalplerinin hazırlanması, iç harç kavrulurken paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk (doldurma dahil) · Pasif bekleme (pişme) ~22 dk · Toplam ~55 dk""",

    "Midyeli Pilav": """**Hazırlık / Mise en Place**
1. Midyeleri temizleyin, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 20 dk): tereyağında soğanı kavurup midye ve pirinci ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + demlenme) ~22 dk · Toplam ~40 dk""",

    "Domates Dolması (Zeytinyağlı)": """**Hazırlık / Mise en Place**
1. Domateslerin üstünü kesip içini oyun.
2. Soğanı doğrayın.

**Isıl İşlem**
1. İç Harç Kavurma (~110°C, tavada, 6 dk): zeytinyağında soğanı ve pirinci kısaca kavurun.
2. Doldurma ve Pişirme (~95°C, kısık ateş, kapalı, 28 dk): domatesleri harçla doldurup az suyla pişirin.

**Soğutma (pasif):** zeytinyağlılar soğuk/oda sıcaklığında servis edilir.

**PARALEL YAPILABİLİRLİK:** Domates oyma, iç harç kavrulurken paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~21 dk (oyma dahil) · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~50 dk""",

    "Ege Usulü Fırın Tavuk (Zeytinli)": """**Hazırlık / Mise en Place**
1. Tavuk butlarını marine edin, domatesi dilimleyin.

**Isıl İşlem**
1. Fırınlama (~200°C, 35 dk): tavuk butlarını zeytin, domates ve zeytinyağıyla fırın kabında pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (fırınlama) ~30 dk · Toplam ~50 dk""",

    "Bademli Tavuk Sote": """**Hazırlık / Mise en Place**
1. Tavuk göğsünü küp küp doğrayın, badem ve soğanı hazırlayın.

**Isıl İşlem**
1. Sote (~150°C, tavada, 20 dk): tereyağında soğanı kavurup tavuğu ekleyin, pişince bademi katıp birkaç dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme) ~10 dk · Toplam ~30 dk""",

    # ----------------------------- GRUP 2 (8) -----------------------------

    "Pazı Çorbası": """**Hazırlık / Mise en Place**
1. Pazıyı ince doğrayın.

**Isıl İşlem**
1. Kaynatma (100°C, 25 dk): tereyağında pirinci kısaca kavurup su ve pazıyı ekleyin, pazı yumuşayana kadar kaynatın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (kaynama) ~15 dk · Toplam ~35 dk""",

    "Ege Otlu Bulgur Pilavı": """**Hazırlık / Mise en Place**
1. Bulguru durulayın, soğan ve fesleğeni doğrayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): zeytinyağında soğanı kavurup bulguru ekleyin, sıcak su ve tuzla su çekilene kadar pişirin, ocaktan alıp fesleğeni karıştırın.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Zeytinyağlı Enginar Kalbi": """**Hazırlık / Mise en Place**
1. Enginar kalplerini ve havucu hazırlayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 20 dk): zeytinyağında havucu kavurup enginar kalplerini ekleyin, limon suyu ve az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~30 dk""",

    "Zeytinyağlı Radika": """**Hazırlık / Mise en Place**
1. Radikayı ayıklayıp yıkayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 20 dk): zeytinyağında radikayı limon suyu ve az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~25 dk""",

    "Bademli Pilav": """**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, bademleri kabaca kırın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): tereyağında badem ve pirinci kavurup sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~6 dk · Pasif bekleme (pişme + demlenme) ~19 dk · Toplam ~25 dk""",

    "Ispanaklı Makarna (Ege Usulü)": """**Hazırlık / Mise en Place**
1. Sarımsağı doğrayın.

**Isıl İşlem**
1. Makarna Haşlama (100°C, 10 dk): makarnayı al dente haşlayın.
2. Ispanak Sotesi (~110°C, ayrı tavada, 8 dk): zeytinyağında sarımsağı kısaca kavurup ıspanağı ekleyin, suyunu salıp çekene kadar pişirin.
3. Birleştirme (aktif, 2 dk): süzülen makarnayı ıspanaklı sosla karıştırın.

**PARALEL YAPILABİLİRLİK:** Makarna haşlama ve ıspanak sotesi AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~18 dk'yı ~10 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (haşlama, paralel yürütülürse çakışıyor) ~8 dk · Paralel yapılırsa toplam ~13 dk, sıralı yapılırsa ~21 dk""",

    "Zeytinyağlı Yer Elması": """**Hazırlık / Mise en Place**
1. Yer elmasını soyup doğrayın, havucu doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 25 dk): zeytinyağında havucu kavurup yer elmasını ekleyin, limon suyu ve az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~35 dk""",

    "Ege Peynirli Gözleme": """**Hazırlık / Mise en Place**
1. Lor peynirini maydonozla karıştırıp iç harcı hazırlayın.
2. Yufkaya harcı sürüp katlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): gözlemeyi tereyağıyla her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac ısınırken iç harç hazırlığı tamamlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok (aktif izleme gerektirir) · Toplam ~20 dk""",

    # ----------------------------- GRUP 3 (8) -----------------------------

    "Radika Salatası (Haşlanmış)": """**Hazırlık / Mise en Place**
1. Radikayı ayıklayıp yıkayın.

**Isıl İşlem**
1. Haşlama (100°C, 10 dk): radikayı yumuşayana kadar haşlayın, süzüp soğutun.

**PARALEL YAPILABİLİRLİK:** Radika haşlanırken sos (zeytinyağı+limon) hazırlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme (haşlama + soğutma) ~15 dk · Toplam ~15 dk""",

    "Midye Dolma": """**Hazırlık / Mise en Place**
1. Midyeleri temizleyin, soğanı doğrayın.
2. Pirinç harcını hazırlayıp midyelerin içine doldurun — en emek yoğun adım.

**Isıl İşlem**
1. Pişirme (~95°C, kısık ateş, kapalı, 35 dk): doldurulmuş midyeleri az suyla pirinç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Doldurma işlemi elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (doldurma dahil) · Pasif bekleme (pişme + soğutma) ~35+ dk · Mutfaktaki aktif+pişirme süresi ~60 dk""",

    "Bademli Kurabiye": """**Hazırlık / Mise en Place**
1. Un, badem, tereyağı, şeker ve yumurtayı yoğurup hamur yapın, şekil verin.

**Isıl İşlem**
1. Fırınlama (~170°C, 20 dk): kurabiyeleri hafif kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~20 dk · Toplam ~35 dk""",

    "Şeftalili Komposto": """**Hazırlık / Mise en Place**
1. Şeftalileri yıkayıp çekirdeklerini çıkarın, dilimleyin.

**Isıl İşlem**
1. Kaynatma (100°C, 15 dk): şeftali, şeker ve suyu kaynattıktan sonra kısık ateşte pişirin.

**Soğutma (pasif, en az 60 dk):** komposto soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + soğutma) ~65+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

    "Üzüm Salatası": """**Hazırlık / Mise en Place**
1. Rokayı yıkayın, üzümleri ikiye bölün.
2. Zeytinyağı ve limon suyuyla sos hazırlayın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "İncir Tatlısı (Kremalı)": """**Hazırlık / Mise en Place**
1. İncirleri yıkayıp ortadan kesin.
2. Kremayı şekerle çırpın, ceviz kırın.

**Isıl İşlem**
Isıl işlem yok — krema pişirilmeden çırpılarak kullanılır.

**PARALEL YAPILABİLİRLİK:** Isıl işlem içermediği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~20 dk""",

    "Zeytin Ezmesi": """**Hazırlık / Mise en Place**
1. Zeytinlerin çekirdeğini çıkarın, zeytinyağı ve limon suyuyla ezerek/blenderdan geçirerek karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Limonlu Kek": """**Hazırlık / Mise en Place**
1. Yumurta ve şekeri çırpın, limon kabuğu rendeleyip suyunu sıkın.
2. Unu eleyip karışıma katın.

**Isıl İşlem**
1. Fırınlama (~180°C, 30 dk): karışımı kalıba dökün, kürdan temiz çıkana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~30 dk · Toplam ~45 dk""",

}
