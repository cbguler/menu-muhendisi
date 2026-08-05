# talimatlar_marmara.py
#
# Pisirme talimatlari -- Marmara Bolgesi (24 tarif, marmara_tarifleri.py).
# Ayni v2 formati: Hazirlik/Mise en Place -> Isil Islem asama(lar)i ->
# PARALEL YAPILABILIRLIK -> SURE OZETI. talimat_yukle.py ile Supabase'e
# islenir.

TALIMATLAR = {

    # ----------------------------- GRUP 1 (9) -----------------------------

    "İskender Kebap": """**Hazırlık / Mise en Place**
1. Dana bifteği ince şeritler halinde dilimleyin.
2. Pideyi kareler halinde doğrayıp servis tabağının tabanına dizin.

**Isıl İşlem**
1. Et Izgara (~200°C, tava/ızgara, 8-10 dk): eti her yüzü mühürlenene kadar pişirin.
2. Salça Sosu (~110°C, ayrı tavada, 3 dk): tereyağında domates salçasını kısa süre kavurun.
3. Tereyağı Eritme (~90°C, 1 dk): ayrı bir tavada tereyağını eritin.

**PARALEL YAPILABİLİRLİK:** Salça sosu ve tereyağı eritme, et ızgarada pişerken AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~12 dk'yı ~8-10 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Paralel yapılırsa toplam ~12 dk, sıralı yapılırsa ~15 dk""",

    "Hünkar Beğendi": """**Hazırlık / Mise en Place**
1. Patlıcanları çatalla delin (fırında/ocakta patlamaması için).
2. Soğanı ince doğrayın.

**Isıl İşlem**
1. Patlıcan Közleme (~220°C, doğrudan alev/fırın, 15 dk): patlıcanların kabuğu tamamen kararıp içi yumuşayana kadar közleyin, soyup ezin.
2. Beğendi Yapma (~90°C, tavada, 8 dk): tereyağında unu kavurup sütü azar azar ekleyin, ezilmiş patlıcanı ve kaşarı karıştırarak pürüzsüz bir kıvama getirin.
3. Kıyma Yahnisi (~150°C, ayrı tavada, 15 dk): soğanı kavurup kıymayı ekleyin, suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma yahnisi (adım 3), beğendi hazırlanırken (adım 2) AYRI ocak gözünde eş zamanlı yapılabilir — ardışık ~23 dk'yı ~15 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme (közleme) ~10 dk · Paralel yapılırsa toplam ~35 dk, sıralı yapılırsa ~48 dk""",

    "Midye Tava": """**Hazırlık / Mise en Place**
1. Midyeleri yıkayıp süzün, una bulayın.

**Isıl İşlem**
1. Kızartma (~180°C, yağda, 6-8 dk): midyeleri her yüzü altın rengi alana kadar kızartın.

**PARALEL YAPILABİLİRLİK:** Tek adımlı, hızlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~15 dk""",

    "Kestaneli Tavuk": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, kestaneleri (önceden haşlanmışsa) hazırlayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~110-150°C, tencerede, 35 dk): tereyağında soğanı kavurup tavuk butlarını ekleyin, kestaneyi de katıp kapağı kapatarak tavuk yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme) ~30 dk · Toplam ~40 dk""",

    "Kağıtta Somon (Marmara Usulü)": """**Hazırlık / Mise en Place**
1. Somonu limon dilimleri, zeytinyağı ve dereotuyla birlikte pişirme kağıdına sarın.

**Isıl İşlem**
1. Fırınlama (~200°C, 18-20 dk): kağıt paketi fırında somon tam pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (fırınlama) ~18 dk · Toplam ~25 dk""",

    "Bursa Usulü İnegöl Köfte": """**Hazırlık / Mise en Place**
1. Kıymayı soğan, sarımsak ve tuzla iyice yoğurun.
2. Harçtan köfte şekli verin.

**Isıl İşlem**
1. Izgara (~200°C, 10 dk): köfteleri her yüzü pişene kadar ızgarada çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken (ön ısıtma) köfte şekillendirmeye devam edilebilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (yoğurma ve şekillendirme dahil) · Pasif bekleme yok · Toplam ~25 dk""",

    "Kaymaklı Mantı (Marmara Usulü)": """**Hazırlık / Mise en Place**
1. Hamuru yoğurup dinlendirin, ince açın.
2. Kıyma ve sarımsakla iç harcı hazırlayın.
3. Hamuru küçük karelere kesip iç harçla doldurup kapatın — en emek yoğun adım.

**Isıl İşlem**
1. Haşlama (100°C, 15-18 dk): mantıları kaynar suda yumuşayana ve iç harcı pişene kadar haşlayın.

**PARALEL YAPILABİLİRLİK:** Kaymaklı sarımsaklı sos, mantılar haşlanırken ayrı bir kapta hazırlanabilir (~5 dk kazanç). Doldurma işlemi (en uzun adım) elle yapılan sıralı bir iştir, paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk (hamur açma ve doldurma dahil, en yüksek aktif emek gerektiren tariflerden) · Pasif bekleme (hamur dinlendirme + haşlama) ~30 dk · Toplam ~65 dk""",

    "Bursa Usulü Kestaneli Kuzu": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, kestaneleri hazırlayın.

**Isıl İşlem**
1. Ağır Ateş Pişirme (~155°C, tencerede/fırında kapalı, 75 dk): kuzu tandırı soğan ve kestaneyle birlikte çok kısık ateşte ette lifler ayrılana kadar uzun süre pişirin.

**PARALEL YAPILABİLİRLİK:** Uzun pasif pişirme süresi boyunca (75 dk) başka tariflerin hazırlığına geçilebilir — ama bu tek başlı, sıralı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (başlangıç hazırlığı) · Pasif bekleme (uzun ağır ateş) ~67 dk · Toplam ~90 dk""",

    "İstanbul Usulü Karides Güveç (Kaşarlı)": """**Hazırlık / Mise en Place**
1. Karidesleri temizleyin.

**Isıl İşlem**
1. Sote (~110°C, tavada, 12 dk): tereyağında karidesleri ve konserve domatesi kısa süre pişirin.
2. Fırınlama (~200°C, güveç kabında, 8 dk): karışımı güveç kabına alıp üzerine kaşarı serpip fırında kaşar eriyip hafif kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken (ön ısıtma) sote adımı tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~8 dk · Toplam ~30 dk""",

    # ----------------------------- GRUP 2 (7) -----------------------------

    "Kestaneli Pilav": """**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, kestaneleri hazırlayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 20 dk): tereyağında pirinci kavurup kestaneyi ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): ocaktan alıp kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~23 dk · Toplam ~30 dk""",

    "Zeytinyağlı Midye Pilaki": """**Hazırlık / Mise en Place**
1. Midyeleri temizleyin, soğanı doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 30 dk): zeytinyağında soğanı kavurup midye ve pirinci ekleyip az suyla pirinç yumuşayana kadar pişirin.
2. Soğutma (pasif): zeytinyağlılar geleneksel olarak oda sıcaklığında/soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~35 dk""",

    "Bursa Usulü Kıymalı Katmer": """**Hazırlık / Mise en Place**
1. Yufkayı hazırlayın.

**Isıl İşlem**
1. Kıyma Sotesi (~150°C, tavada, 10 dk): soğanı kavurup kıymayı ekleyin, suyunu çekene kadar pişirin.
2. Katmer Pişirme (~180°C, sac/tavada, 12 dk): yufkanın arasına kıyma harcını serpiştirip her iki yüzü kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sac/tava ısınırken kıyma sotesi tamamlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme yok (aktif izleme gerektirir) · Toplam ~22 dk""",

    "Kestaneli Bulgur Pilavı": """**Hazırlık / Mise en Place**
1. Bulguru durulayın, kestaneleri hazırlayın.

**Isıl İşlem**
1. Kavurma ve Kaynatma (100°C, 19 dk): tereyağında bulguru kavurup kestaneyi ekleyin, sıcak su ve tuzla su çekilene kadar pişirin.
2. Demlendirme (pasif, 10 dk): kapağı kapalı demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + demlenme) ~21 dk · Toplam ~30 dk""",

    "Marmara Usulü Zeytinyağlı Pırasa": """**Hazırlık / Mise en Place**
1. Pırasayı halka halka doğrayıp yıkayın, havucu doğrayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 30 dk): zeytinyağında pırasayı kavurup havuç ve az suyla pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~35 dk""",

    "Bursa Usulü Zeytinyağlı Nohut": """**Hazırlık / Mise en Place**
1. Soğanı doğrayın, nohut önceden haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma ve Pişirme (~95°C, kısık ateş, kapalı, 25 dk): zeytinyağında soğanı kavurup nohudu ekleyip az suyla kaynatın.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~30 dk""",

    "Kestaneli Çorba": """**Hazırlık / Mise en Place**
1. Kestaneleri hazırlayın (önceden haşlanmış/kavrulmuş).

**Isıl İşlem**
1. Kaynatma (100°C, 20 dk): tavuk suyunu kestaneyle birlikte kaynatıp blenderdan geçirin, tereyağını karıştırın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (kaynama) ~15 dk · Toplam ~25 dk""",

    # ----------------------------- GRUP 3 (8) -----------------------------

    "Kestane Şekeri": """**Hazırlık / Mise en Place**
1. Kestaneleri kabuklarından ayıklayın.

**Isıl İşlem**
1. Haşlama (100°C, 20 dk): kestaneleri yumuşayana kadar haşlayın.
2. Şerbetleme (~105°C, 15 dk): şeker ve suyla hazırlanan şerbette kestaneleri kaynatıp şerbeti emmesini sağlayın.

**PARALEL YAPILABİLİRLİK:** Şerbet, kestaneler haşlanırken ayrı bir tencerede paralel hazırlanabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (haşlama + şerbetleme + soğutma) ~30+ dk · Mutfaktaki pişirme süresi ~30-35 dk""",

    "Kaymaklı Ekmek Kadayıfı": """**Hazırlık / Mise en Place**
1. Ekmek kadayıfını hazırlayın.

**Isıl İşlem**
1. Şerbetleme (~100°C, 10 dk): şeker ve suyla hazırlanan şerbeti kaynatıp ekmek kadayıfının üzerine dökün.
2. Emdirme (pasif, 15 dk): kadayıfın şerbeti tamamen emmesini bekleyin.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (emdirme + soğutma) ~15+ dk · Mutfaktaki pişirme süresi ~18 dk. Servis öncesi üzerine kaymak eklenir (ısıl işlem gerektirmez).""",

    "Vişne Reçelli Yoğurt": """**Hazırlık / Mise en Place**
1. Yoğurdu kaseye alın, üzerine vişne reçelini ve şekeri gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Marmara Usulü Yeşil Salata": """**Hazırlık / Mise en Place**
1. Marulu yıkayıp koparın, taze soğanı doğrayın.
2. Zeytinyağı ve limon suyuyla sos hazırlayın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Nar Ekşili Pancar Salatası": """**Hazırlık / Mise en Place**
1. Pancarı yıkayın (kabuğuyla haşlanacaksa soymadan).

**Isıl İşlem**
1. Haşlama (100°C, 15 dk): pancarları yumuşayana kadar haşlayın, soyup dilimleyin.

**PARALEL YAPILABİLİRLİK:** Pancar haşlanırken diğer malzemelerin (zeytinyağı, nar ekşisi karışımı) hazırlığı paralel yapılabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (haşlama + soğutma) ~20+ dk · Mutfaktaki pişirme süresi ~20 dk""",

    "Kestaneli Muhallebi": """**Hazırlık / Mise en Place**
1. Mısır nişastasını az soğuk sütle ezip pürüzsüzleştirin.
2. Kestaneleri parçalayın.

**Isıl İşlem**
1. Pişirme (~90°C, kısık ateş, sürekli karıştırarak, 15 dk): süt, şeker, kestane ve nişastayı sürekli karıştırarak kıvam alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sürekli karıştırma gerektiren tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme (soğutma) ~120+ dk · Mutfaktaki aktif+pişirme süresi ~18 dk""",

    "Marmara Usulü Karışık Turşu": """**Hazırlık / Mise en Place**
1. Hazır (konserve) turşuyu süzün, sirkeyle karıştırıp servis tabağına düzenleyin.

**Isıl İşlem**
Isıl işlem yok. Not: bu tarif, önceden fermente edilmiş/hazır turşunun servise hazırlanmasını kapsar.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Marmara Usulü Vişne Kompostosu": """**Hazırlık / Mise en Place**
1. Vişneleri yıkayıp çekirdeklerini çıkarın.

**Isıl İşlem**
1. Kaynatma (100°C, 18 dk): vişne, şeker ve suyu kaynattıktan sonra kısık ateşte pişirin.

**Soğutma (pasif, en az 60 dk):** komposto soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) ~75+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

}
