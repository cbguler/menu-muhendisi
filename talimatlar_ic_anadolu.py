# talimatlar_ic_anadolu.py
#
# Pisirme talimatlari -- Ic Anadolu Bolgesi (24 tarif, ic_anadolu_tarifleri.py).
# Ayni v2 formati. talimat_yukle.py ile Supabase'e islenir.

TALIMATLAR = {

    "Keşkek": """**Hazırlık / Mise en Place**
1. Buğdayı bir gece önceden suda bekletin, süzün.

**Isıl İşlem**
1. Haşlama ve Dövme (~100°C, kısık ateş, 100 dk): buğday ve tavuk butunu bol suyla birlikte, ara ara tahta kaşıkla dövülüp lifleri dağıtılarak, pütürsüz bir kıvama gelene kadar çok uzun süre kaynatın — bölgenin en emek yoğun ve en uzun süren tarifi.

**Tereyağı Ekleme:** servis öncesi üzerine eritilmiş tereyağı gezdirin (ısıl işlem gerekmez).

**PARALEL YAPILABİLİRLİK:** Uzun pişirme süresi boyunca (100 dk) başka tariflerin hazırlığına geçilebilir, ama dövme işlemi ara ara aktif müdahale gerektirdiği için tamamen bırakılamaz.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk (ara sıra dövme dahil) · Pasif bekleme (bir gece ıslatma + uzun pişirme) çok yüksek · Mutfaktaki pişirme süresi ~100 dk""",

    "Etli Ekmek (Konya)": """**Hazırlık / Mise en Place**
1. Hamuru yoğurup açın.
2. Soğanı doğrayın, domatesi rendeleyin.

**Isıl İşlem**
1. Kıyma Sotesi (~150°C, tavada, 10 dk): soğanı kavurup kıymayı ekleyin, domatesi katıp suyunu çekene kadar pişirin.
2. Fırınlama (~200°C, 15 dk): hamuru kıyma harcıyla doldurup kenarlarını kapatarak fırında kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kıyma sotesi tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (hamur açma dahil) · Pasif bekleme (fırınlama) ~13 dk · Toplam ~45 dk""",

    "Testi Kebabı": """**Hazırlık / Mise en Place**
1. Kuzu tandırı domates, yeşil biber ve soğanla birlikte toprak testiye doldurun, ağzını hamurla kapatın.

**Isıl İşlem**
1. Ağır Ateş Pişirme (~155°C, fırında kapalı, 70 dk): testiyi çok kısık ateşte et yumuşayana kadar uzun süre pişirin.

**Servis:** testinin ağzı kırılarak/hamur açılarak servis edilir.

**PARALEL YAPILABİLİRLİK:** Uzun pasif pişirme süresi boyunca başka tariflerin hazırlığına geçilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (uzun ağır ateş) ~65+ dk · Toplam ~90 dk""",

    "Kayseri Mantısı": """**Hazırlık / Mise en Place**
1. Hamuru yoğurup ince açın, minik karelere kesin.
2. Her kareye küçük bir tutam kıyma harcı koyup dört köşesini birleştirerek kapatın — bölgenin en küçük ve en emek yoğun mantı şeklidir.
3. Sarımsaklı yoğurt ve pul biberli tereyağlı sosu hazırlayın.

**Isıl İşlem**
1. Haşlama (100°C, 15 dk): mantıları kaynar suda yüzeye çıkana ve iç harç pişene kadar haşlayın.

**PARALEL YAPILABİLİRLİK:** Sos hazırlığı, mantılar haşlanırken paralel yapılabilir (~5 dk kazanç). Doldurma işlemi (en uzun adım) elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~50 dk (minik doldurma dahil, kütüphanedeki en yüksek aktif emek gerektiren tariflerden) · Pasif bekleme (haşlama) ~15 dk · Toplam ~70 dk""",

    "Pastırmalı Yumurta": """**Hazırlık / Mise en Place**
1. Pastırmayı ince dilimleyin.

**Isıl İşlem**
1. Pişirme (~100°C, tavada, 7 dk): tereyağında pastırmayı kavurup yumurtaları kırıp üzerinde pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı, hızlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Bamya Yemeği (Etli)": """**Hazırlık / Mise en Place**
1. Bamyaların saplarını temizleyin, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (100°C, 35 dk): soğanı kavurup kıymayı ekleyin, bamya ve domatesi katıp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~20 dk · Toplam ~45 dk""",

    "Kavurmalı Nohut": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, kavurmayı küçük parçalara ayırın.

**Isıl İşlem**
1. Isıtma ve Pişirme (~110°C, tavada, 25 dk): soğanı kavurup kavurmayı ekleyin (kavurma zaten pişmiş olduğu için sadece ısıtılıp soğanla harmanlanır), nohudu katıp birkaç dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme) ~15 dk · Toplam ~35 dk""",

    "Sucuklu Kuru Fasulye": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, sucuğu dilimleyin.

**Isıl İşlem**
1. Kavurma ve Pişirme (100°C, 55 dk): soğan ve sucuğu kavurup salçayı ekleyin, fasulye ve az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~45 dk · Toplam ~70 dk""",

    "Kayısılı Kuzu Tandır": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, kuru kayısıları hazırlayın.

**Isıl İşlem**
1. Ağır Ateş Pişirme (~155°C, fırında kapalı, 85 dk): kuzu tandırı soğan ve kayısıyla birlikte çok kısık ateşte lifler ayrılana kadar uzun süre pişirin.

**PARALEL YAPILABİLİRLİK:** Uzun pasif pişirme süresi boyunca başka tariflerin hazırlığına geçilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (uzun ağır ateş) ~85 dk · Toplam ~100 dk""",

    "Tarhana Çorbası": """**Hazırlık / Mise en Place**
1. Tarhanayı az suyla ezip pürüzsüzleştirin.

**Isıl İşlem**
1. Kaynatma (100°C, 18 dk): tereyağında salçayı kısaca kavurup su ve tarhanayı ekleyin, sürekli karıştırarak topaklanmadan kaynatın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (kaynama) ~15 dk · Toplam ~25 dk""",

    "Arpa Şehriyeli Çorba": """**Hazırlık / Mise en Place**
1. Havucu küp doğrayın.

**Isıl İşlem**
1. Kaynatma (100°C, 20 dk): tavuk suyunu havuçla kaynatıp şehriyeyi ekleyin, tam pişene kadar kaynatmaya devam edin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (kaynama) ~22 dk · Toplam ~30 dk""",

    "Bamya Yemeği (Zeytinyağlı)": """**Hazırlık / Mise en Place**
1. Bamyaların saplarını temizleyin, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 25 dk): zeytinyağında soğanı kavurup bamya ve domatesi ekleyin, az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~35 dk""",

    "Şehriyeli Bulgur Pilavı": """**Hazırlık / Mise en Place**
1. Bulguru durulayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): tereyağında şehriyeyi kızarana kadar kavurup bulguru ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Mantı Çorbası (Yoğurtlu)": """**Hazırlık / Mise en Place**
1. İnce hamur açıp minik parçalar halinde kesin.

**Isıl İşlem**
1. Haşlama (100°C, 10 dk): hamur parçalarını kaynar suda yüzeye çıkana kadar haşlayın.
2. Terbiye (~85°C, kaynatmadan, 8 dk): ateşi kısıp yoğurdu yavaşça karıştırarak ekleyin, kaynatmadan ısıtın, üzerine kuru naneli tereyağı gezdirin.

**PARALEL YAPILABİLİRLİK:** Yoğurdun hazırlanması, hamur parçaları haşlanırken paralel yapılabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (hamur açma+kesme dahil) · Pasif bekleme (haşlama) ~15 dk · Toplam ~40 dk""",

    "Erişte (Ev Yapımı Makarna)": """**Hazırlık / Mise en Place**
1. Un, yumurta ve suyla hamur hazırlayıp ince açıp şeritler halinde kesin, kurumaya bırakın.

**Isıl İşlem**
1. Haşlama (100°C, 10 dk): erişteyi tereyağıyla birlikte kaynar suda haşlayın.

**PARALEL YAPILABİLİRLİK:** Hamur açma/kesme işlemi elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk (hamur açma dahil) · Pasif bekleme (haşlama) ~13 dk · Toplam ~35 dk""",

    "Sac Böreği (Peynirli)": """**Hazırlık / Mise en Place**
1. Yufka katmanları arasına kaşarı serpiştirin.

**Isıl İşlem**
1. Pişirme (~180°C, sac üstünde, 15 dk): tereyağıyla her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac ısınırken dizme tamamlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (aktif izleme gerektirir) · Pasif bekleme yok · Toplam ~20 dk""",

    "Höşmerim": """**Hazırlık / Mise en Place**
1. Lor peynirini süzün.

**Isıl İşlem**
1. Pişirme (~150°C, tavada, 20 dk): tereyağında irmiği kavurup lor peynirini ve şekeri ekleyin, sürekli karıştırarak kıvam alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sürekli karıştırma gerektiren tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk (çoğu sürekli karıştırma) · Pasif bekleme yok · Toplam ~25 dk""",

    "Malatya Usulü Kayısı Tatlısı": """**Hazırlık / Mise en Place**
1. Kuru kayısıları ortadan yarıp içine ceviz doldurun, üzerine krema gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk (doldurma dahil) · Pasif bekleme yok · Toplam ~20 dk""",

    "Kuru Kayısı Kompostosu": """**Hazırlık / Mise en Place**
1. Kuru kayısıları yıkayın.

**Isıl İşlem**
1. Kaynatma (100°C, 15 dk): kayısı, şeker ve suyu kaynattıktan sonra kısık ateşte pişirin.

**Soğutma (pasif, en az 60 dk):** komposto soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme (pişme + soğutma) ~75+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

    "Kuru Fasulye Piyazı": """**Hazırlık / Mise en Place**
1. Önceden haşlanmış kuru fasulyeyi taze soğan, maydonoz, zeytinyağı ve limon suyuyla karıştırın.

**Isıl İşlem**
Isıl işlem yok — fasulye önceden haşlanmış olarak kullanılır.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme yok · Toplam ~15 dk""",

    "Konya Usulü Kavun Dilimi": """**Hazırlık / Mise en Place**
1. Kavunu dilimleyin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — kütüphanedeki en hızlı tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Kuru Üzümlü İrmik Helvası": """**Hazırlık / Mise en Place**
1. İrmiği hazırlayın.

**Isıl İşlem**
1. Kavurma (~110°C, tavada, 10 dk): tereyağında irmiği kızarana kadar kavurun.
2. Şerbet (~100°C, ayrı tencerede, 15 dk): şeker, su ve kuru üzümü kaynatın.

**Şerbetleme:** kavrulmuş irmiğin üzerine sıcak şerbeti dökün, ocağı kapatıp dinlendirin.

**PARALEL YAPILABİLİRLİK:** Şerbet, irmik kavrulurken AYRI ocakta paralel hazırlanabilir — ardışık ~25 dk'yı ~15 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme (dinlendirme) ~10 dk · Paralel yapılırsa toplam ~20 dk, sıralı yapılırsa ~30 dk""",

    "Ev Yapımı Karışık Turşu": """**Hazırlık / Mise en Place**
1. Hazır (konserve) turşuyu süzün, sirkeyle karıştırıp servis tabağına düzenleyin.

**Isıl İşlem**
Isıl işlem yok. Not: bu tarif, önceden fermente edilmiş/hazır turşunun servise hazırlanmasını kapsar.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Kuru Üzümlü Yoğurt": """**Hazırlık / Mise en Place**
1. Yoğurdu kaseye alın, üzerine kuru üzüm ve ceviz serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

}
