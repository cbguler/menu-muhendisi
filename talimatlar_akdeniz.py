# talimatlar_akdeniz.py
#
# Pisirme talimatlari -- Akdeniz Bolgesi (24 tarif, akdeniz_tarifleri.py).
# Ayni v2 formati. talimat_yukle.py ile Supabase'e islenir.

TALIMATLAR = {

    "Adana Kebap": """**Hazırlık / Mise en Place**
1. Soğanı rendeleyin (ya da robotta çekip ezin) — köfte/kebap harcında soğan doğranmış değil, rendelenmiş kullanılır; çok su bırakıyorsa suyunu hafifçe süzün.
2. Kıymayı rendelenmiş soğan ve pul biberle iyice yoğurun, şişlere sarın.

**Isıl İşlem**
1. Izgara (~200°C, 10 dk): şişleri her yüzü pişene kadar çevirerek ızgarada pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken şiş sarma tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~25 dk""",

    "Akdeniz Usulü Karides Sote": """**Hazırlık / Mise en Place**
1. Karidesleri temizleyin, sarımsağı doğrayın.

**Isıl İşlem**
1. Sote (~110°C, tavada, 12 dk): zeytinyağında sarımsağı kısaca kavurup karidesi ve domatesi ekleyin, karides pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok, zaten hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk (çoğu aktif izleme gerektirir) · Pasif bekleme yok · Toplam ~20 dk""",

    "Muhammara Soslu Tavuk": """**Hazırlık / Mise en Place**
1. Ceviz, pul biber, salça ve zeytinyağını karıştırıp muhammara sosunu hazırlayın (ısıl işlem gerekmez).

**Isıl İşlem**
1. Tavuk Sote (~150°C, tavada, 15 dk): tavuk göğsünü her yüzü pişene kadar pişirin.

**Servis:** üzerine muhammara sosunu dökerek servis edin.

**PARALEL YAPILABİLİRLİK:** Sos hazırlığı, tavuk pişerken paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~30 dk""",

    "Akdeniz Usulü Fırın Levrek (Sumaklı)": """**Hazırlık / Mise en Place**
1. Levreği temizleyin, sumak ve limonla marine edin.

**Isıl İşlem**
1. Fırınlama (~200°C, 20 dk): balığı zeytinyağıyla fırın kabında pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (fırınlama) ~20 dk · Toplam ~35 dk""",

    "Nar Ekşili Köfte": """**Hazırlık / Mise en Place**
1. Soğanı rendeleyin — çok su bırakıyorsa suyunu hafifçe süzün.
2. Kıymayı rendelenmiş soğan ve nar ekşisiyle yoğurup köfte şekli verin.

**Isıl İşlem**
1. Izgara (~200°C, 10 dk): köfteleri her yüzü pişene kadar ızgarada çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte şekillendirmeye devam edilebilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~25 dk""",

    "Sumaklı Tavuk Şiş": """**Hazırlık / Mise en Place**
1. Tavuk göğsünü küp doğrayın, sumak, zeytinyağı ve limonla marine edip şişlere dizin.

**Isıl İşlem**
1. Izgara (~200°C, 12 dk): şişleri her yüzü pişene kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken şiş dizme tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme yok · Toplam ~25 dk""",

    "Etli Yeşil Mercimek Yemeği": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, mercimeği yıkayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (100°C, 35 dk): soğanı kavurup kıymayı ekleyin, mercimek ve suyu katıp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~20 dk · Toplam ~45 dk""",

    "Karidesli Bulgur Pilavı": """**Hazırlık / Mise en Place**
1. Karidesleri temizleyin, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 19 dk): zeytinyağında soğanı kavurup karides ve bulguru ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme + demlenme) ~17 dk · Toplam ~30 dk""",

    "Patlıcan Kebabı (Yoğurtlu)": """**Hazırlık / Mise en Place**
1. Patlıcanı doğrayın, sarımsaklı yoğurdu hazırlayın.

**Isıl İşlem**
1. Patlıcan Kızartma (~175°C, tavada, 8 dk): patlıcanı her yüzü hafif kızarana kadar kızartın.
2. Kıyma Sotesi (~150°C, ayrı tavada, 10 dk): kıymayı sarımsakla kavurup pişirin.
3. Birleştirme ve Servis (aktif, 3 dk): patlıcan ve kıymayı tabakta birleştirip üzerine sarımsaklı yoğurdu dökün.

**PARALEL YAPILABİLİRLİK:** Patlıcan kızartma ve kıyma sotesi AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~18 dk'yı ~10 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme yok · Paralel yapılırsa toplam ~23 dk, sıralı yapılırsa ~31 dk""",

    "Yeşil Mercimek Çorbası": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, mercimeği yıkayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 30 dk): tereyağında soğanı kavurup mercimek ve suyu ekleyin, mercimek yumuşayana kadar kaynatın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (kaynama) ~25 dk · Toplam ~40 dk""",

    "Akdeniz Usulü Bulgur Pilavı (Domatesli)": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, bulguru durulayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): zeytinyağında soğanı ve salçayı kavurup bulguru ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Nar Ekşili Zeytinyağlı Patlıcan": """**Hazırlık / Mise en Place**
1. Patlıcanı doğrayın, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 30 dk): zeytinyağında soğanı kavurup patlıcanı ekleyin, nar ekşisi ve az suyla yumuşayana kadar pişirin.

**Soğutma (pasif):** zeytinyağlılar oda sıcaklığında/soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~40 dk""",

    "Zeytinyağlı Kabak (Akdeniz Usulü)": """**Hazırlık / Mise en Place**
1. Kabağı doğrayın, soğanı doğrayın, domatesi rendeleyin.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 25 dk): zeytinyağında soğanı kavurup kabak ve domatesi ekleyin, az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~33 dk""",

    "Sumaklı Mercimek Köftesi": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın.

**Isıl İşlem**
1. Mercimek Haşlama (100°C, 15 dk): kırmızı mercimeği yumuşayana kadar haşlayın.

**Yoğurma ve Şekillendirme (aktif, 15 dk):** haşlanmış mercimeği ince bulgur, sumak, soğan ve zeytinyağıyla yoğurup köfte şekli verin (ısıl işlem gerekmez).

**PARALEL YAPILABİLİRLİK:** Soğan doğrama, mercimek haşlanırken paralel yapılabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk (yoğurma dahil) · Pasif bekleme (haşlama) ~13 dk · Toplam ~30 dk""",

    "Hatay Usulü Katmer (Peynirli)": """**Hazırlık / Mise en Place**
1. Yufkayı lor peyniriyle doldurup katlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): katmeri tereyağıyla her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac ısınırken doldurma tamamlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (aktif izleme gerektirir) · Pasif bekleme yok · Toplam ~20 dk""",

    "Akdeniz Usulü Bakla": """**Hazırlık / Mise en Place**
1. Baklaları ayıklayın, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 30 dk): zeytinyağında soğanı kavurup baklayı ekleyin, az suyla yumuşayana kadar pişirin, dereotunu karıştırın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~38 dk""",

    "Humus": """**Hazırlık / Mise en Place**
1. Haşlanmış nohudu tahin, limon suyu, sarımsak ve zeytinyağıyla blenderdan geçirip pürüzsüzleştirin.

**Isıl İşlem**
Isıl işlem yok — mekanik karıştırma/püre işlemidir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~15 dk""",

    "Muhammara": """**Hazırlık / Mise en Place**
1. Cevizi, pul biberi, salçayı, zeytinyağı ve limon suyunu blenderdan geçirip karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~15 dk""",

    "Nar Ekşili Roka Salatası": """**Hazırlık / Mise en Place**
1. Rokayı yıkayın, nar tanelerini ayıklayın.
2. Zeytinyağı ve nar ekşisiyle sos hazırlayın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Kısır": """**Hazırlık / Mise en Place**
1. İnce bulguru sıcak suyla (kaynatmadan, sadece ıslatarak) yumuşatın.
2. Domates ve maydonozu ince doğrayın.
3. Nar ekşisi ve zeytinyağıyla karıştırıp yoğurun.

**Isıl İşlem**
Isıl işlem yok — bulgur kaynatılmaz, sadece sıcak suda ıslatılır.

**PARALEL YAPILABİLİRLİK:** Bulgur ıslanırken domates/maydonoz doğranabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (bulgur ıslanma) ~10 dk · Toplam ~25 dk""",

    "Nar Ekşili Yoğurt": """**Hazırlık / Mise en Place**
1. Yoğurdu kaseye alın, üzerine nar taneleri ve zeytinyağı gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Künefe": """**Hazırlık / Mise en Place**
1. Kadayıfı didikleyip eritilmiş tereyağıyla harmanlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): kadayıfın arasına kaşarı koyup her iki yüzü kızarana kadar pişirin.
2. Şerbet (~105°C, ayrı tencerede, 10 dk): şeker ve suyu kaynatıp hafif koyulaşana kadar pişirin.

**Şerbetleme:** sıcak künefenin üzerine şerbeti dökün.

**PARALEL YAPILABİLİRLİK:** Şerbet, künefe pişerken AYRI ocakta paralel hazırlanabilir — ardışık ~25 dk'yı ~15 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok (aktif izleme gerektirir) · Paralel yapılırsa toplam ~20 dk, sıralı yapılırsa ~30 dk""",

    "Nar Taneli Meyve Tabağı": """**Hazırlık / Mise en Place**
1. Nar tanelerini ayıklayın, üzüm ve elmayı doğrayın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten en hızlı tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Şam Tatlısı": """**Hazırlık / Mise en Place**
1. İrmiği hazırlayın.

**Isıl İşlem**
1. Kavurma (~110°C, tavada, 10 dk): tereyağında irmiği kızarana kadar kavurun.
2. Şerbet (~105°C, ayrı tencerede, 15 dk): şeker ve suyu kaynatıp hafif koyulaşana kadar pişirin.
3. Şerbetleme (aktif, 5 dk): kavrulmuş irmiğin üzerine şerbeti dökün, emmesini bekleyin.

**PARALEL YAPILABİLİRLİK:** Şerbet, irmik kavrulurken AYRI ocakta paralel hazırlanabilir — ardışık ~25 dk'yı ~15 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Paralel yapılırsa toplam ~20 dk, sıralı yapılırsa ~30 dk""",

}
