# talimatlar_karadeniz.py
#
# Pisirme talimatlari -- Karadeniz Bolgesi (20 tarif, karadeniz_tarifleri.py).
# Ayni v2 formati. talimat_yukle.py ile Supabase'e islenir.

TALIMATLAR = {

    # ----------------------------- GRUP 1 (8) -----------------------------

    "Karadeniz Usulü Hamsi Buğulama": """**Hazırlık / Mise en Place**
1. Hamsileri temizleyip yıkayın.
2. Soğanı ince doğrayın.

**Isıl İşlem**
1. Buğulama (~95°C, kısık ateş, kapalı, 20 dk): tencerenin tabanına soğan ve hamsiyi katman katman dizip zeytinyağı ve maydonozla üzerini kapatarak kısık ateşte pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk (temizleme dahil) · Pasif bekleme (pişme) ~15 dk · Toplam ~25 dk""",

    "Akçaabat Köfte": """**Hazırlık / Mise en Place**
1. Soğanı rendeleyin — çok su bırakıyorsa suyunu hafifçe süzün.
2. Kıymayı rendelenmiş soğan, pul biber, tuz ve karabiberle iyice yoğurun.
3. Harçtan ince uzun köfteler şekillendirin.

**Isıl İşlem**
1. Izgara (~200°C, 10 dk): köfteleri her yüzü pişene kadar ızgarada çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte şekillendirmeye devam edilebilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~25 dk""",

    "Karalahana Sarması (Etli)": """**Hazırlık / Mise en Place**
1. Karalahana yapraklarını ayıklayıp yıkayın, kalın sap kısımlarını inceltin.
2. Soğanı ince doğrayın.

**Isıl İşlem**
1. İç Harç Kavurma (~110°C, tavada, 8 dk): kıyma, soğan, pirinç ve mısır ununu birlikte kavurun, ılımaya bırakın.
2. Sarma (aktif, elle, 35 dk): her yaprağa bir tutam harç koyup sıkıca sarın — en emek yoğun adım.
3. Pişirme (~90°C, kısık ateş, kapalı, 40 dk): sarmaları tencereye sık dizip az suyla karalahana yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** İç harcın kavrulması (adım 1), yapraklar ayıklanıp yıkanırken paralel yapılabilir (~5 dk kazanç). Sarma (en uzun adım) elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk (sarma dahil, en yüksek aktif emek gerektiren tariflerden) · Pasif bekleme (pişme) ~35 dk · Toplam ~80 dk""",

    "Hamsili Pilav": """**Hazırlık / Mise en Place**
1. Hamsileri temizleyip fileto çıkarın.
2. Soğanı ince doğrayın.

**Isıl İşlem**
1. Pilav Kavurma ve Kaynatma (100°C, 20 dk): tereyağında soğan, çam fıstığı ve kuş üzümünü kavurup pirinci ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Hamsi Kızartma (~175°C, ayrı tavada, 8 dk): hamsileri her yüzü altın rengi alana kadar kızartın.
3. Demlendirme (pasif, 10 dk): pilavı ocaktan alıp kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Hamsi kızartma (adım 2), pilav pişerken AYRI ocak gözünde eş zamanlı yapılabilir — ardışık ~28 dk'yı ~20 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme (pişme + demlenme) ~20 dk · Paralel yapılırsa toplam ~30 dk, sıralı yapılırsa ~38 dk""",

    "Kuymak (Muhlama)": """**Hazırlık / Mise en Place**
1. Kaşarı rendeleyin.

**Isıl İşlem**
1. Pişirme (~95°C, kısık ateş, sürekli karıştırarak, 18 dk): tereyağını eritip mısır ununu kavurun, sıcak suyu azar azar ekleyip pürüzsüz bir kıvama gelene kadar karıştırın, ocaktan almadan önce kaşarı ekleyip eritin.

**PARALEL YAPILABİLİRLİK:** Sürekli karıştırma gerektiren tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk (tamamı sürekli karıştırma) · Pasif bekleme yok · Toplam ~20 dk""",

    "Karadeniz Usulü Palamut Izgara": """**Hazırlık / Mise en Place**
1. Palamutu temizleyip dilimleyin, zeytinyağı ve limonla marine edin.

**Isıl İşlem**
1. Izgara (~200°C, 12 dk): her yüzü pişene kadar ızgarada çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı, hızlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~20 dk""",

    "Fındıklı Tavuk Sote": """**Hazırlık / Mise en Place**
1. Tavuk göğsünü küp küp doğrayın, soğanı doğrayın, fındıkları kabaca kırın.

**Isıl İşlem**
1. Sote (~150°C, tavada, 20 dk): tereyağında soğanı kavurup tavuğu ekleyin, tavuk pişince fındığı katıp birkaç dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme) ~12 dk · Toplam ~30 dk""",

    "Karadeniz Usulü Fasulye Pilaki": """**Hazırlık / Mise en Place**
1. Kuru fasulyeyi (önceden ıslatılmış/haşlanmış) süzün, havuç ve soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 45 dk): zeytinyağında soğan ve havucu kavurup fasulyeyi ekleyin, az suyla fasulye yumuşayana kadar pişirin.

**Soğutma (pasif, en az 60 dk):** zeytinyağlılar oda sıcaklığında/soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~60 dk""",

    # ----------------------------- GRUP 2 (6) -----------------------------

    "Karalahana Çorbası": """**Hazırlık / Mise en Place**
1. Karalahanayı ince doğrayın, kuru fasulyeyi (önceden haşlanmış) hazırlayın.

**Isıl İşlem**
1. Kaynatma (~100°C, 35 dk): tereyağında mısır ununu kısaca kavurup su, karalahana ve fasulyeyi ekleyin, karalahana yumuşayana kadar kaynatın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme (kaynama) ~25 dk · Toplam ~50 dk""",

    "Mısır Çorbası (Karadeniz Usulü)": """**Hazırlık / Mise en Place**
1. Mısırı hazırlayın (konserve ise süzün).

**Isıl İşlem**
1. Kaynatma (~95°C, 20 dk): tereyağında mısırı kısaca kavurup sütü ekleyin, kısık ateşte kaynatın, isterseniz blenderdan geçirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (kaynama) ~15 dk · Toplam ~30 dk""",

    "Karadeniz Pidesi (Kıymalı)": """**Hazırlık / Mise en Place**
1. Hamuru yoğurup açın.
2. Soğanı doğrayın.

**Isıl İşlem**
1. Kıyma Sotesi (~150°C, tavada, 10 dk): soğanı kavurup kıymayı ekleyin, suyunu çekene kadar pişirin.
2. Fırınlama (~200°C, 15 dk): pide hamurunu kıyma harcı ve kaşarla doldurup kenarlarını kapatarak fırında kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kıyma sotesi tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (hamur açma dahil) · Pasif bekleme (fırınlama) ~13 dk · Toplam ~50 dk""",

    "Mısır Ekmeği": """**Hazırlık / Mise en Place**
1. Mısır unu, buğday unu, su ve tuzu karıştırıp hamur yapın.

**Isıl İşlem**
1. Fırınlama (~200°C, 25 dk): hamuru kalıba dökün, kürdan temiz çıkana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (fırınlama) ~25 dk · Toplam ~35 dk""",

    "Fındıklı Pirinç Pilavı": """**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, fındıkları kabaca kırın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 15 dk): tereyağında fındık ve pirinci kavurup sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Kolot Böreği (Peynirli)": """**Hazırlık / Mise en Place**
1. Lor peynirini yumurtayla karıştırıp iç harcı hazırlayın.
2. Yufkaları hazırlayın.

**Isıl İşlem**
1. Fırınlama (~180°C, 25 dk): yufka katmanları arasına harcı serpiştirip tereyağıyla üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken yufka dizme tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme (pişme) ~22 dk · Toplam ~45 dk""",

    # ----------------------------- GRUP 3 (6) -----------------------------

    "Laz Böreği": """**Hazırlık / Mise en Place**
1. Yufkaları hazırlayın.

**Isıl İşlem**
1. Krema Pişirme (~90°C, kısık ateş, sürekli karıştırarak, 12 dk): süt, mısır nişastası ve şekeri sürekli karıştırarak kıvam alana kadar pişirin, ılımaya bırakın.
2. Fırınlama (~180°C, 20 dk): yufka katmanları arasına ılımış kremayı serpiştirip tereyağıyla üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Yufka hazırlığı, krema pişerken paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme (pişme) ~25 dk · Toplam ~55 dk""",

    "Kete (Karadeniz Tatlısı)": """**Hazırlık / Mise en Place**
1. Un, şeker, tereyağı ve yumurtayı yoğurup hamur yapın, şekil verin.

**Isıl İşlem**
1. Fırınlama (~180°C, 25 dk): hamur parçalarını kürdan temiz çıkana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~25 dk · Toplam ~45 dk""",

    "Fındıklı Kurabiye": """**Hazırlık / Mise en Place**
1. Un, fındık, tereyağı, şeker ve yumurtayı yoğurup hamur yapın, şekil verin.

**Isıl İşlem**
1. Fırınlama (~170°C, 20 dk): kurabiyeleri hafif kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~20 dk · Toplam ~35 dk""",

    "Karadeniz Yeşil Salata": """**Hazırlık / Mise en Place**
1. Rokayı ve kuzu kulağını yıkayıp koparın.
2. Zeytinyağı ve limon suyuyla sos hazırlayın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Karalahana Turşusu": """**Hazırlık / Mise en Place**
1. Karalahanayı ince doğrayın, tuz ve sirkeyle karıştırın.

**Isıl İşlem**
Isıl işlem yok. Not: bu tarif önceden fermente edilmiş karalahana turşusunun servise hazırlanmasını kapsar — ev yapımı fermantasyon süreci bu tarifin kapsamı dışındadır.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok (gerçek fermantasyon süreci hariç) · Toplam ~5 dk""",

    "Fındıklı Sütlaç": """**Hazırlık / Mise en Place**
1. Fındıkları kabaca kırın, mısır nişastasını az soğuk sütle ezin.

**Isıl İşlem**
1. Pirinç Haşlama (100°C, 11 dk): pirinci az suda yumuşayana kadar haşlayın.
2. Sütle Pişirme (~95°C, kısık ateş, sürekli karıştırarak, 22 dk): sütü, şekeri, fındığı ve nişastayı ekleyip kıvam alana kadar karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Sürekli karıştırma gerektiren adım (2) başka bir işlemle paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk (çoğu sürekli karıştırma) · Pasif bekleme (soğutma) ~120+ dk · Mutfaktaki aktif+pişirme süresi ~35 dk""",

}
