# talimatlar_guneydogu.py
#
# Pisirme talimatlari -- Guneydogu Anadolu Bolgesi (24 tarif,
# guneydogu_tarifleri.py). Ayni v2 formati. talimat_yukle.py ile
# Supabase'e islenir.

TALIMATLAR = {

    "Çiğ Köfte (Vejetaryen)": """**Hazırlık / Mise en Place**
1. İnce bulguru salça, pul biber, isot ve sarımsakla karıştırıp yoğurun.
2. Sıcak suyla azar azar ıslatarak (kaynatmadan) yoğurmaya devam edin, nar ekşisini ekleyip şekil verin.

**Isıl İşlem**
Isıl işlem yok — bulgur kaynatılmaz, sadece yoğrulup ıslatılır.

**PARALEL YAPILABİLİRLİK:** Isıl işlem içermediği için paralel fırsatı yok — ama yoğurma işlemi uzun ve emek yoğun tek bir adımdır.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk (yoğurma en uzun adım) · Pasif bekleme (bulgurun suyu çekmesi) ~5 dk · Toplam ~40 dk""",

    "Kuzu Şiş (Isotlu)": """**Hazırlık / Mise en Place**
1. Kuzu şişi isot, zeytinyağı ve tuzla marine edip şişlere dizin.

**Isıl İşlem**
1. Izgara (~200°C, 12 dk): şişleri her yüzü pişene kadar çevirerek ızgarada pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken marine etme tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (marinasyon, isteğe bağlı uzatılabilir) yok · Toplam ~30 dk""",

    "Alinazik Kebap": """**Hazırlık / Mise en Place**
1. Patlıcanı çatalla delin.
2. Soğanı doğrayın, sarımsaklı yoğurdu hazırlayın.

**Isıl İşlem**
1. Patlıcan Közleme (~220°C, doğrudan alev, 15 dk): patlıcanların kabuğu kararıp içi yumuşayana kadar közleyin, soyup ezin.
2. Kıyma Sotesi (~150°C, ayrı tavada, 10 dk): kıymayı kendi yağında kavurun.

**Beğendi ve Birleştirme (aktif, 5 dk):** ezilmiş közlenmiş patlıcanı sarımsaklı yoğurtla karıştırıp tabağa yayın, üzerine sıcak kıymayı dökün.

**PARALEL YAPILABİLİRLİK:** Patlıcan közleme ve kıyma sotesi AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~25 dk'yı ~15 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Paralel yapılırsa toplam ~30 dk, sıralı yapılırsa ~40 dk""",

    "İçli Köfte": """**Hazırlık / Mise en Place**
1. İnce bulguru yoğurup dış kabuk hamurunu hazırlayın.

**Isıl İşlem**
1. İç Harç Kavurma (~150°C, tavada, 10 dk): soğanı kavurup kıyma ve cevizi ekleyin, kısaca pişirin, ılımaya bırakın.

**Doldurma ve Şekillendirme (aktif, elle, 20 dk):** dış kabuğu avuç içinde inceltip iç harçla doldurup kapatın — en emek yoğun adım.

**Isıl İşlem (devam)**
2. Haşlama (100°C, 10 dk): köfteleri kaynar suda yüzeye çıkana kadar haşlayın.

**PARALEL YAPILABİLİRLİK:** İç harç kavrulurken dış kabuk hamuru hazırlığı paralel yapılabilir (~5 dk kazanç). Doldurma (en uzun adım) elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk (doldurma dahil, en yüksek aktif emek gerektiren tariflerden) · Pasif bekleme (haşlama) ~10 dk · Toplam ~60 dk""",

    "Küşleme (Kuzu Kavurma)": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın.

**Isıl İşlem**
1. Kavurma (~150°C, tavada, 35 dk): tereyağında soğanı kavurup kuzu tandırı ekleyin, yumuşayana kadar kavurarak pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~20 dk · Toplam ~40 dk""",

    "Antep Fıstıklı Tavuk Sote": """**Hazırlık / Mise en Place**
1. Tavuk göğsünü küp doğrayın, soğanı doğrayın, fıstıkları kabaca kırın.

**Isıl İşlem**
1. Sote (~150°C, tavada, 20 dk): tereyağında soğanı kavurup tavuğu ekleyin, pişince fıstığı katıp birkaç dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme) ~10 dk · Toplam ~30 dk""",

    "Isotlu Tavuk Şiş": """**Hazırlık / Mise en Place**
1. Tavuk göğsünü küp doğrayın, isot, zeytinyağı ve limonla marine edip şişlere dizin.

**Isıl İşlem**
1. Izgara (~200°C, 12 dk): şişleri her yüzü pişene kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken şiş dizme tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme yok · Toplam ~25 dk""",

    "Nohutlu Kuzu Yahnisi": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, nohut önceden haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma ve Pişirme (100°C, 45 dk): soğanı kavurup kuzu tandırı ekleyin, nohut ve az suyla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~30 dk · Toplam ~60 dk""",

    "Antep Usulü Mercimekli Köfte": """**Hazırlık / Mise en Place**
1. Sarımsağı ezin.

**Isıl İşlem**
1. Mercimek Haşlama (100°C, 15 dk): kırmızı mercimeği yumuşayana kadar haşlayın.

**Yoğurma ve Şekillendirme (aktif, 15 dk):** haşlanmış mercimeği ince bulgur, isot, sarımsak ve zeytinyağıyla yoğurup köfte şekli verin (ısıl işlem gerekmez).

**PARALEL YAPILABİLİRLİK:** Sarımsak hazırlığı, mercimek haşlanırken paralel yapılabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk (yoğurma dahil) · Pasif bekleme (haşlama) ~13 dk · Toplam ~40 dk""",

    "Yoğurtlu Mercimek Çorbası": """**Hazırlık / Mise en Place**
1. Yoğurdu çırpıp pürüzsüzleştirin.

**Isıl İşlem**
1. Kaynatma (100°C, 20 dk): tereyağında mercimeği ve suyu kaynattıktan sonra yumuşayana kadar pişirin.
2. Terbiye (~85°C, kaynatmadan, 8 dk): ateşi kısıp yoğurdu yavaşça karıştırarak ekleyin, kaynatmadan ısıtın, üzerine kuru nane serpin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (kaynama) ~15 dk · Toplam ~35 dk""",

    "Antep Usulü Bulgur Pilavı (İsotlu)": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, bulguru durulayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): tereyağında soğanı ve isotu kavurup bulguru ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Antep Usulü Nohutlu Bulgur": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, nohut önceden haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 17 dk): tereyağında soğanı kavurup nohut ve bulguru ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~20 dk · Toplam ~30 dk""",

    "Güneydoğu Usulü Ispanaklı Börek": """**Hazırlık / Mise en Place**
1. Yufkayı hazırlayın.

**Isıl İşlem**
1. Ispanak Kavurma (~110°C, tavada, 7 dk): ıspanağı suyunu salıp çekene kadar kavurun, ılımaya bırakın.

**Harç Birleştirme (aktif, 3 dk):** ılımış ıspanağı lor peyniriyle karıştırın.

**Isıl İşlem (devam)**
2. Fırınlama (~180°C, 25 dk): yufka katmanları arasına harcı serpiştirip tereyağıyla üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Ispanak kavrulurken yufka hazırlığı paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme) ~25 dk · Toplam ~45 dk""",

    "Zeytinyağlı Nane Soslu Kabak": """**Hazırlık / Mise en Place**
1. Kabağı dilimleyin.

**Isıl İşlem**
1. Kabak Haşlama (100°C, 15 dk): kabak dilimlerini yumuşayana kadar haşlayın.

**Terbiye (aktif, 5 dk):** yoğurt ve kuru naneyi karıştırıp haşlanmış kabağın üzerine dökün (ısıl işlem gerekmez).

**PARALEL YAPILABİLİRLİK:** Yoğurtlu sos, kabak haşlanırken hazırlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (haşlama) ~13 dk · Toplam ~25 dk""",

    "Antep Usulü Katmer (Kahvaltılık)": """**Hazırlık / Mise en Place**
1. Yufkaya kaşarı serpip katlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): katmeri tereyağıyla her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac ısınırken doldurma tamamlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (aktif izleme gerektirir) · Pasif bekleme yok · Toplam ~20 dk""",

    "Antep Usulü Zeytinyağlı Nohut": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, nohut önceden haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 25 dk): zeytinyağında soğanı kavurup nohudu ekleyin, limon suyu ve az suyla kaynatın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~30 dk""",

    "Sumaklı Soğan Salatası": """**Hazırlık / Mise en Place**
1. Taze soğanı ince doğrayın, sumak ve nar ekşisiyle karıştırın, maydonoz serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Antep Usulü Baklava": """**Hazırlık / Mise en Place**
1. Yufka katmanlarını yağlayıp fıstığı serpiştirerek dizin.

**Isıl İşlem**
1. Fırınlama (~180°C, 25 dk): dilimleyip tereyağıyla üzeri kızarana kadar fırınlayın.
2. Şerbet (~105°C, ayrı tencerede, 10 dk): şeker ve suyu kaynatıp hafif koyulaşana kadar pişirin.

**Şerbetleme (aktif, 5 dk):** fırından çıkan sıcak baklavanın üzerine SOĞUK şerbeti gezdirip emmesini bekleyin.

**PARALEL YAPILABİLİRLİK:** Şerbet, baklava fırında pişerken AYRI ocakta paralel hazırlanabilir — ardışık ~35 dk'yı ~25 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (yufka dizme dahil) · Pasif bekleme (pişme + şerbetleme) ~30 dk · Paralel yapılırsa toplam ~50 dk, sıralı yapılırsa ~60 dk""",

    "Fıstıklı Katmer (Tatlı, Kaymaklı)": """**Hazırlık / Mise en Place**
1. Yufkaya fıstık ve şekeri serpip katlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): katmeri tereyağıyla her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac ısınırken doldurma tamamlanabilir (~2 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (aktif izleme gerektirir) · Pasif bekleme yok · Toplam ~30 dk""",

    "Antep Fıstıklı Künefe": """**Hazırlık / Mise en Place**
1. Kadayıfı didikleyip eritilmiş tereyağıyla harmanlayın.

**Isıl İşlem**
1. Pişirme (~180°C, sac/tavada, 15 dk): kadayıfın arasına kaşarı koyup her iki yüzü kızarana kadar pişirin.
2. Şerbet (~105°C, ayrı tencerede, 10 dk): şeker ve suyu kaynatıp hafif koyulaşana kadar pişirin.

**Şerbetleme ve Servis:** sıcak künefenin üzerine şerbeti dökün, üzerine fıstık serpin.

**PARALEL YAPILABİLİRLİK:** Şerbet, künefe pişerken AYRI ocakta paralel hazırlanabilir — ardışık ~25 dk'yı ~15 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok (aktif izleme gerektirir) · Paralel yapılırsa toplam ~20 dk, sıralı yapılırsa ~30 dk""",

    "Kayısı Tatlısı (Cevizli)": """**Hazırlık / Mise en Place**
1. Kuru kayısıları ortadan yarıp içine ceviz doldurun, üzerine krema gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk (doldurma dahil) · Pasif bekleme yok · Toplam ~20 dk""",

    "Sumaklı Cacık": """**Hazırlık / Mise en Place**
1. Salatalığı rendeleyin, sarımsağı ezin, yoğurtla karıştırıp üzerine sumak serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Sumaklı Kırmızı Lahana Salatası": """**Hazırlık / Mise en Place**
1. Kırmızı lahanayı ince doğrayın, sumak, zeytinyağı ve limon suyuyla karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Yoğurtlu Bulgur Salatası": """**Hazırlık / Mise en Place**
1. Bulguru sıcak suyla (kaynatmadan, sadece ıslatarak) yumuşatın.
2. Yoğurt, sarımsak ve kuru naneyi karıştırıp bulgurla birleştirin.

**Isıl İşlem**
Isıl işlem yok — bulgur kaynatılmaz, sadece sıcak suda ıslatılır.

**PARALEL YAPILABİLİRLİK:** Bulgur ıslanırken yoğurtlu sos hazırlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (bulgur ıslanma) ~10 dk · Toplam ~20 dk""",

}
