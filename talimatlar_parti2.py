# talimatlar_parti2.py
#
# Pisirme talimatlari -- II. Parti: orijinal 75 "Klasik" tariflik
# kutuphanenin II. Grup (corba/pilav/zeytinyagli/makarna/borek, 24 tarif)
# ve III. Grup (salata/tatli/komposto/yogurt/cacik/tursu, 20 tarif) --
# toplam 44 tarif. I. Grup'ta (talimatlar_parti1.py) uygulanan v2 formatinin
# aynisi: Hazirlik/Mise en Place -> Isil Islem asama(lar)i (sicaklik+sure+
# teknik) -> PARALEL YAPILABILIRLIK notu -> SURE OZETI (aktif/pasif dk).
# talimat_yukle.py ile (recete_id'yi isme gore bulup UPDATE ederek)
# Supabase'e islenir.

TALIMATLAR = {

    # ---------------------------------------------------------------
    # GRUP 2 -- Corba (6)
    # ---------------------------------------------------------------

    "Mercimek Çorbası": """**Hazırlık / Mise en Place**
1. Kırmızı mercimeği süzgeçte yıkayın.
2. Soğanı ve havucu ince doğrayın ya da rendeleyin.

**Isıl İşlem**
1. Kavurma (~110°C, tavada, 5 dk): tereyağında soğan ve havucu pembeleşene kadar kavurun.
2. Kaynatma (100°C, 25-30 dk): kavrulan sebzelerin üzerine mercimek ve su ekleyip kaynattıktan sonra kısık ateşte mercimek dağılana kadar pişirin.
3. Püre (aktif, 2 dk): blenderdan geçirip pürüzsüzleştirin, gerekirse kıvamına su ekleyin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — ayrı bir ocak gözü gerektirmiyor, paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif kaynama beklemesi ~25 dk · Toplam ~40 dk""",

    "Ezogelin Çorbası": """**Hazırlık / Mise en Place**
1. Mercimeği ve ince bulguru yıkayın.
2. Soğanı ince doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tavada, 5 dk): tereyağında soğanı kavurup salça ve pul biberi ekleyip 1-2 dk daha kavurun.
2. Kaynatma (100°C, 30-35 dk): mercimek, bulgur ve su ekleyip kısık ateşte mercimek ve bulgur tam yumuşayana kadar pişirin, ara sıra karıştırın (dibe yapışmaya meyilli).

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (ara sıra karıştırma dahil) · Pasif kaynama beklemesi ~25 dk · Toplam ~45 dk""",

    "Yayla Çorbası": """**Hazırlık / Mise en Place**
1. Pirinci yıkayın.
2. Yoğurdu çırpıp pürüzsüzleştirin (buzdolabından erken çıkarıp oda sıcaklığına yaklaştırmak kesilmeyi azaltır).

**Isıl İşlem**
1. Haşlama (100°C, 15 dk): pirinci suda yumuşayana kadar haşlayın.
2. Terbiye ve ısıtma (~85°C, kaynatmadan, 8-10 dk): ateşi kısın, haşlanmış pirincin suyuna yoğurdu yavaş yavaş, sürekli karıştırarak ekleyin; KAYNATMAYIN (yoğurt kesilir) — sadece iyice ısınana kadar tutun.
3. Son dokunuş: tereyağında kızdırılan nane ile üzerini süsleyip servis edin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — ama nane-tereyağı sosu son dakikada ayrı bir küçük tavada hazırlanabilir (1-2 dk kazanç, ihmal edilebilir düzeyde).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk (sürekli karıştırma gerektiren terbiye adımı dahil) · Pasif bekleme ~15 dk · Toplam ~30 dk""",

    "Domates Çorbası": """**Hazırlık / Mise en Place**
1. Soğanı ince doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tavada, 5 dk): tereyağında soğanı pembeleşene kadar kavurun.
2. Kaynatma (100°C, 15-20 dk): konserve domatesi ekleyip kısık ateşte pişirin, isterseniz blenderdan geçirin.
3. Kremayı ekleme (~85°C, kaynatmadan, 2 dk): ocaktan almadan hemen önce kremayı ekleyip karıştırın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif kaynama beklemesi ~20 dk · Toplam ~30 dk""",

    "Tavuk Suyu Çorbası (Şehriyeli)": """**Hazırlık / Mise en Place**
1. Havucu küp küp doğrayın.

**Isıl İşlem**
1. Kaynatma (100°C, 20-25 dk): hazır tavuk suyunu kaynatıp havucu ekleyin, yumuşayana kadar pişirin.
2. Şehriye haşlama (100°C, 8-10 dk): şehriyeyi ekleyip tam pişene kadar kaynatmaya devam edin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif kaynama beklemesi ~25 dk · Toplam ~30 dk""",

    "Sebze Çorbası": """**Hazırlık / Mise en Place**
1. Havuç, patates, kereviz ve pırasayı küp küp doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tavada, 5 dk): tereyağında pırasayı hafifçe kavurun.
2. Kaynatma (100°C, 25-30 dk): diğer sebzeleri ve suyu ekleyip hepsi yumuşayana kadar kısık ateşte pişirin.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk (doğrama dahil) · Pasif kaynama beklemesi ~25 dk · Toplam ~35 dk""",

    # ---------------------------------------------------------------
    # GRUP 2 -- Pilav (5)
    # ---------------------------------------------------------------

    "Sade Pirinç Pilavı": """**Hazırlık / Mise en Place**
1. Pirinci nişastası gidene kadar bol suda yıkayın, süzün.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 3 dk): tereyağını eritip pirinci 2-3 dk kavurun.
2. Kaynatma + demlendirme (100°C kaynatma ~2 dk, sonra kısık ateşte kapalı 15-18 dk): sıcak su ekleyip tuzu koyun, kaynayınca kısıp kapağı kapatın; su çekilene kadar pişirin.
3. Dinlendirme (pasif, 10 dk): ocaktan alıp kapağın üzerine bir kağıt havlu koyarak 10 dk demlenmeye bırakın — bu adım pilavın tane tane olması için kritiktir, atlanmamalı.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok. Ama demlenme (pasif 10 dk) sırasında başka bir tarifin hazırlığına geçilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~6 dk · Pasif bekleme (pişme + demlenme) ~19 dk · Toplam ~25 dk""",

    "Bulgur Pilavı": """**Hazırlık / Mise en Place**
1. Bulguru süzgeçte durulayın.
2. Soğanı ince doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 5 dk): tereyağında soğanı kavurup salçayı ekleyip 1-2 dk daha kavurun, bulguru ekleyip 2 dk karıştırın.
2. Kaynatma + demlendirme (100°C kaynatma ~2 dk, sonra kısık ateşte kapalı 12-15 dk): sıcak su ve tuzu ekleyip kaynayınca kısıp su çekilene kadar pişirin.
3. Dinlendirme (pasif, 10 dk): ocaktan alıp kapağı kapalı 10 dk demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~9 dk · Pasif bekleme (pişme + demlenme) ~16 dk · Toplam ~25 dk""",

    "Şehriyeli Pirinç Pilavı": """**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 4 dk): tereyağında şehriyeyi kızarana kadar kavurun, pirinci ekleyip 2 dk daha kavurun.
2. Kaynatma + demlendirme (100°C kaynatma ~2 dk, sonra kısık ateşte kapalı 15-18 dk): sıcak su ve tuzu ekleyip su çekilene kadar pişirin.
3. Dinlendirme (pasif, 10 dk): kapağı kapalı 10 dk demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme (pişme + demlenme) ~18 dk · Toplam ~25 dk""",

    "Nohutlu Pilav": """**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün. Nohut önceden haşlanmış/konserve ise süzüp durulayın.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 4 dk): tereyağında pirinci 2-3 dk kavurun, nohudu ekleyip karıştırın.
2. Kaynatma + demlendirme (100°C kaynatma ~2 dk, sonra kısık ateşte kapalı 15-18 dk): sıcak su ve tuzu ekleyip su çekilene kadar pişirin.
3. Dinlendirme (pasif, 10 dk): kapağı kapalı 10 dk demlenmeye bırakın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~6 dk · Pasif bekleme (pişme + demlenme) ~19 dk · Toplam ~30 dk""",

    "Kuşkonmaz Risotto": """**Hazırlık / Mise en Place**
1. Kuşkonmazı yıkayıp odunsu uçlarını kırın, 2-3 cm parçalar halinde doğrayın.
2. Parmesanı rendeleyin.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 2 dk): tereyağında pirinci yarı saydamlaşana kadar kavurun.
2. Kademeli pişirme (~95°C, sürekli karıştırarak, 18-20 dk): sıcak suyu kepçe kepçe ekleyip her seferinde emilmesini bekleyerek, SÜREKLİ karıştırarak pişirin (klasik risotto tekniği — tek seferde su eklemek kremamsı kıvamı bozar).
3. Kuşkonmazı ekleme (~95°C, son 5 dk): kuşkonmazı ekleyip pirinçle birlikte al dente kıvamına gelene kadar pişirin.
4. Son dokunuş: ocaktan alıp parmesanı karıştırın.

**PARALEL YAPILABİLİRLİK:** Kuşkonmaz doğrama ve parmesan rendeleme, pirinç kavrulurken paralel yapılabilir (~3 dk kazanç). Ancak ana pişirme aşaması (kademeli su ekleme) sürekli dikkat gerektirdiği için başka bir işlemle paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (sürekli karıştırma gerektirir) · Pasif bekleme yok · Toplam ~35 dk""",

    # ---------------------------------------------------------------
    # GRUP 2 -- Zeytinyağlı (6)
    # ---------------------------------------------------------------

    "Zeytinyağlı Taze Fasulye": """**Hazırlık / Mise en Place**
1. Fasulyeyi ayıklayıp yıkayın, ikiye bölün.
2. Soğanı yemeklik doğrayın, domatesi rendeleyin.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 5 dk): zeytinyağında soğanı hafifçe kavurun.
2. Pişirme (~95°C, kısık ateş, kapalı, 30-35 dk): fasulye ve domatesi ekleyip az su ile kapağı kapatarak fasulye yumuşayana kadar pişirin.
3. Soğutma (pasif, en az 60 dk): zeytinyağlılar geleneksel olarak SOĞUK ya da oda sıcaklığında servis edilir — pişirdikten sonra oda sıcaklığına, ardından buzdolabında soğumaya bırakın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — ama soğutma beklemesi (pasif, uzun) sırasında başka işlere geçilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme + soğutma) ~90+ dk (soğutma süresi servis zamanına göre esnektir) · Mutfaktaki aktif+pişirme süresi ~40 dk""",

    "Zeytinyağlı Pırasa": """**Hazırlık / Mise en Place**
1. Pırasayı halka halka doğrayıp yıkayın (toprak kalıntısı için).
2. Havucu küp doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 5 dk): zeytinyağında pırasayı hafifçe kavurun.
2. Pişirme (~95°C, kısık ateş, kapalı, 25-30 dk): havuç, pirinç ve az suyu ekleyip pırasa ve pirinç yumuşayana kadar pişirin.
3. Soğutma (pasif): oda sıcaklığına, ardından buzdolabına alın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~35 dk""",

    "Zeytinyağlı Enginar": """**Hazırlık / Mise en Place**
1. Enginarları temizleyip limonlu suda bekletin (kararmasın diye).
2. Havuç ve taze fasulyeyi doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 3 dk): zeytinyağında havucu hafifçe kavurun.
2. Pişirme (~95°C, kısık ateş, kapalı, 25-30 dk): enginar, fasulye, limon suyu ve az suyu ekleyip enginar yumuşayana kadar pişirin.
3. Soğutma (pasif): oda sıcaklığına, ardından buzdolabına alın.

**PARALEL YAPILABİLİRLİK:** Enginar temizliği ile havuç/fasulye doğrama aynı anda (iki kişi varsa) yapılabilir; tek kişi için sıralı.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (enginar temizliği dahil, en zahmetli adım) · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~40 dk""",

    "Zeytinyağlı Kereviz": """**Hazırlık / Mise en Place**
1. Kerevizi soyup küp küp doğrayın, kararmaması için limonlu suda bekletin.
2. Havuç ve patatesi doğrayın.

**Isıl İşlem**
1. Kavurma (~110°C, tencerede, 3 dk): zeytinyağında havucu hafifçe kavurun.
2. Pişirme (~95°C, kısık ateş, kapalı, 30-35 dk): kereviz, patates, limon suyu ve az suyu ekleyip hepsi yumuşayana kadar pişirin.
3. Soğutma (pasif): oda sıcaklığına, ardından buzdolabına alın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~40 dk""",

    "İmam Bayıldı": """**Hazırlık / Mise en Place**
1. Patlıcanları soyup (çizgili soyma) tuzlu suda 10 dk bekletin, sonra kurulayın.
2. Soğan, domates ve sarımsağı doğrayın.

**Isıl İşlem**
1. Kızartma/kavurma (~170°C yağda, 8-10 dk): patlıcanları her yüzü hafif kızarana kadar kızartın (ya da fırında közleyin), kenara alın.
2. İç harç kavurma (~110°C, ayrı tavada, 8-10 dk): zeytinyağında soğan, sarımsak ve domatesi kavurun.
3. Doldurma ve pişirme (~95°C, kısık ateş, kapalı, 25-30 dk): patlıcanların ortasını açıp harcı doldurun, az su ile kısık ateşte pişirin.
4. Soğutma (pasif): oda sıcaklığına, ardından buzdolabına alın.

**PARALEL YAPILABİLİRLİK:** Patlıcan kızartma (adım 1) ile iç harcın kavrulması (adım 2) AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~18-20 dk'yı ~10 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme (tuzlu su + pişme + soğutma) değişken · Paralel yapılmadan mutfak süresi ~50 dk, paralel yapılırsa ~40 dk""",

    "Zeytinyağlı Yaprak Sarma": """**Hazırlık / Mise en Place**
1. Salamura yaprakları sıcak suda 2-3 dk bekletip tuzunu giderin, süzün.
2. İç harç için pirinci yıkayın, soğanı ince doğrayın.

**Isıl İşlem**
1. İç harç kavurma (~110°C, tavada, 5 dk): zeytinyağında soğanı kavurup pirinci ekleyip 2 dk daha kavurun, ocaktan alıp ılımaya bırakın.
2. Sarma (aktif, elle, 25-30 dk): her yaprağın parlak yüzü altta kalacak şekilde bir tutam harç koyup sıkıca sarın — bu tarifin en emek yoğun adımıdır.
3. Pişirme (~90°C, kısık ateş, kapalı, 35-40 dk): tencereye sık dizip üzerine ters bir tabak ve az su koyup kısık ateşte pişirin.
4. Soğutma (pasif): oda sıcaklığına, ardından buzdolabına alın.

**PARALEL YAPILABİLİRLİK:** Yaprakların tuzdan arındırılması (adım 1) ile iç harcın kavrulması (adım 2/Isıl İşlem-1) aynı anda yapılabilir (~3 dk kazanç) — ama sarma işlemi (en uzun adım) başka bir işlemle paralel yürütülemez, tamamen elle yapılan sıralı bir iştir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk (sarma dahil, en yüksek aktif emek gerektiren tarif) · Pasif bekleme (pişme + soğutma) değişken · Mutfaktaki aktif+pişirme süresi ~75 dk""",

    # ---------------------------------------------------------------
    # GRUP 2 -- Makarna (3)
    # ---------------------------------------------------------------

    "Domates Soslu Makarna": """**Hazırlık / Mise en Place**
1. Sarımsağı ince doğrayın.

**Isıl İşlem**
1. Makarna haşlama (100°C, kaynar tuzlu su, 9-11 dk paket üzerindeki süreye göre): makarnayı al dente haşlayın.
2. Sos (~110°C, ayrı tavada, 8-10 dk): zeytinyağında sarımsağı kısa süre kavurup konserve domatesi ekleyip kısık ateşte pişirin.
3. Birleştirme (aktif, 1-2 dk): süzülen makarnayı sosla karıştırın.

**PARALEL YAPILABİLİRLİK:** Makarna haşlama (adım 1) ile sos hazırlama (adım 2) AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~18-20 dk'yı ~10-11 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (haşlama/pişirme süresi, paralel yürütülürse çakışıyor) ~10 dk · Paralel yapılırsa toplam ~15 dk, sıralı yapılırsa ~22 dk""",

    "Fırın Makarna (Kıymalı)": """**Hazırlık / Mise en Place**
1. Kaşarı rendeleyin.

**Isıl İşlem**
1. Makarna haşlama (100°C, kaynar tuzlu su, 9-11 dk): makarnayı al dente haşlayın, süzün.
2. Kıyma sotesi (~110°C, ayrı tavada, 10-12 dk): kıymayı kendi yağında kavurup rengi dönene kadar pişirin, kremayı ekleyip 2 dk daha karıştırın.
3. Birleştirme ve fırınlama (200°C fırın, 15-18 dk): makarna ve kıyma harcını fırın kabında karıştırıp üzerine kaşarı serpin, kaşar eriyip hafif kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Makarna haşlama (adım 1) ile kıyma sotesi (adım 2) AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~21-23 dk'yı ~12 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (fırınlama) ~17 dk · Paralel yapılırsa toplam ~30 dk, sıralı yapılırsa ~40 dk""",

    "Fesleğenli Pesto Makarna": """**Hazırlık / Mise en Place**
1. Parmesanı rendeleyin.

**Isıl İşlem**
1. Makarna haşlama (100°C, kaynar tuzlu su, 9-11 dk): makarnayı al dente haşlayın.
2. Birleştirme (aktif, ısı kapalı ya da çok kısık, 1-2 dk): süzülen sıcak makarnayı ocaktan alıp pesto sosla karıştırın (pesto pişirilmez, sıcak makarnanın ısısıyla ısınır — fazla ısıtmak fesleğenin rengini/tadını bozar).
3. Servis: üzerine parmesan serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Tek ısıl işlem adımı var (makarna haşlama) — pesto hazır sos olduğu için paralel fırsatı yok, zaten en hızlı tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme (haşlama) ~10 dk · Toplam ~15 dk""",

    # ---------------------------------------------------------------
    # GRUP 2 -- Börek (4)
    # ---------------------------------------------------------------

    "Su Böreği (Peynirli)": """**Hazırlık / Mise en Place**
1. İç harç için lor peynirini maydonozla karıştırın.
2. Yumurta ve unu karıştırıp hamur/yufka karışımını hazırlayın.

**Isıl İşlem**
1. Haşlama (100°C, kaynar tuzlu su, 3-4 dk): yufka katmanlarını teker teker haşlayıp soğuk suya alın, süzün — su böreğini "su böreği" yapan bu adımdır.
2. Dizme ve pişirme (~180°C fırın ya da tepside ocak üstü, 20-25 dk): haşlanmış yufkaları tereyağıyla katman katman dizip aralarına iç harcı serpiştirin, üzeri kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** İç harcın hazırlanması (adım Hazırlık-1), yufkalar haşlanırken paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk (yufka dizme dahil, emek yoğun) · Pasif bekleme (pişme) ~20 dk · Toplam ~45-50 dk""",

    "Sigara Böreği (Peynirli)": """**Hazırlık / Mise en Place**
1. Lor peynirini maydonozla karıştırın.
2. Yufkaları üçgen/dikdörtgen şeritler halinde kesin.

**Isıl İşlem**
1. Sarma (aktif, elle, 15-20 dk): her yufka şeridine bir tutam harç koyup sıkıca sigara şeklinde sarın.
2. Kızartma (~170-180°C yağda, 2-3 dk/parti): her yüzü altın rengi alana kadar kızartın.

**PARALEL YAPILABİLİRLİK:** Tek kişilik iş akışında sarma ve kızartma sıralı ilerler; ama yağ ısınırken (ön ısıtma ~3-4 dk) sarma işlemine devam edilebilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (sarma dahil) · Pasif bekleme yok (kızartma aktif izleme gerektirir) · Toplam ~30 dk""",

    "Ispanaklı Börek": """**Hazırlık / Mise en Place**
1. Ispanağı yıkayıp iri doğrayın.
2. Lor peynirini hazırlayın.

**Isıl İşlem**
1. Ispanak kavurma (~110°C, tavada, 6-8 dk): ıspanağı kendi suyunu salıp çekene kadar kavurun, ılımaya bırakın.
2. Harç birleştirme (aktif, 3 dk): ılımış ıspanağı lor peyniriyle karıştırın.
3. Dizme ve pişirme (~180°C fırın, 25-30 dk): yufka katmanları arasına harcı serpiştirip tereyağıyla üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Ispanak kavrulurken yufka hazırlığı/serme paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme (pişme) ~25 dk · Toplam ~45 dk""",

    "Kıymalı Börek": """**Hazırlık / Mise en Place**
1. Soğanı ince doğrayın.

**Isıl İşlem**
1. Kıyma sotesi (~110°C, tavada, 10-12 dk): yağda soğanı kavurup kıymayı ekleyin, suyunu çekene kadar kavurun, ılımaya bırakın.
2. Dizme ve pişirme (~180°C fırın, 25-30 dk): yufka katmanları arasına harcı serpiştirip üzeri kızarana kadar fırınlayın.

**PARALEL YAPILABİLİRLİK:** Kıyma sotesi pişerken yufka serme/dizme hazırlığı paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme (pişme) ~25 dk · Toplam ~50 dk""",

    # ---------------------------------------------------------------
    # GRUP 3 -- Salata (5)
    # ---------------------------------------------------------------

    "Çoban Salata": """**Hazırlık / Mise en Place**
1. Domates, yeşil biber ve taze soğanı küp/ince doğrayın.
2. Zeytinyağı, limon suyu ve tuzu karıştırıp sos hazırlayın.

**Isıl İşlem**
Isıl işlem yok — tüm malzemeler çiğ tüketilir.

**PARALEL YAPILABİLİRLİK:** Isıl işlem içermediği için paralel fırsatı zaten yok; tarifin kendisi zaten en hızlı hazırlanan tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Mevsim Yeşil Salata": """**Hazırlık / Mise en Place**
1. Marulu yıkayıp elle koparın (bıçakla kesmek kenarları kararttığı için tercih edilmez).
2. Turpu ince dilimleyin.
3. Zeytinyağı, limon suyu ve tuzu karıştırıp sos hazırlayın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk""",

    "Roka Salatası (Parmesanlı)": """**Hazırlık / Mise en Place**
1. Rokayı yıkayıp süzün.
2. Parmesanı ince dilimler (talaş) halinde kesin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~8 dk""",

    "Kırmızı Lahana Salatası": """**Hazırlık / Mise en Place**
1. Kırmızı lahanayı ince ince doğrayın (julyen).
2. Zeytinyağı, limon suyu ve tuzu ekleyip karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok. Not: limon suyuyla en az 10 dk dinlendirilirse lahana yumuşar, tat daha iyi oturur (isteğe bağlı pasif bekleme).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (isteğe bağlı dinlendirme) ~10 dk · Toplam ~10-20 dk""",

    "Sezar Usulü Tavuklu Salata": """**Hazırlık / Mise en Place**
1. Marulu yıkayıp koparın.
2. Parmesanı rendeleyin/talaş halinde kesin.

**Isıl İşlem**
1. Tavuk ızgara (~200°C ızgara/tava, 10-12 dk): tuz ve karabiberle tatlandırılan tavuk göğsünü her yüzü tam pişene kadar ızgara yapın, dilimleyin.

**PARALEL YAPILABİLİRLİK:** Marul ve parmesan hazırlığı, tavuk ızgarada pişerken paralel yapılabilir (~5 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (tavuk dinlendirme, isteğe bağlı) ~3 dk · Toplam ~15-20 dk""",

    # ---------------------------------------------------------------
    # GRUP 3 -- Cacık / Yoğurt (2)
    # ---------------------------------------------------------------

    "Cacık": """**Hazırlık / Mise en Place**
1. Salatalığı rendeleyin ya da minik küp doğrayın.
2. Sarımsağı ezin.
3. Yoğurdu çırpıp pürüzsüzleştirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok — zaten çok hızlı bir tarif.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme yok · Toplam ~8 dk""",

    "Havuçlu Yoğurtlu Salata": """**Hazırlık / Mise en Place**
1. Havucu rendeleyin.
2. Sarımsağı ezin, yoğurtla karıştırın.

**Isıl İşlem**
1. Havuç haşlama/kavurma (~100°C, 8-10 dk, isteğe bağlı): rendelenmiş havucu kısa süre haşlayıp ya da az yağda kavurup yumuşatın (çiğ de servis edilebilir, bu adım isteğe bağlıdır — daha yumuşak doku için tercih edilir).
2. Birleştirme (aktif, 2 dk): ılımış havucu sarımsaklı yoğurtla karıştırın.

**PARALEL YAPILABİLİRLİK:** Sarımsak-yoğurt karışımı, havuç haşlanırken paralel hazırlanabilir (~3 dk kazanç).

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme (havuç haşlanıyorsa) ~8 dk · Toplam ~10-18 dk (haşlama tercihine göre)""",

    # ---------------------------------------------------------------
    # GRUP 3 -- Turşu (2)
    # ---------------------------------------------------------------

    "Karışık Turşu": """**Hazırlık / Mise en Place**
1. Hazır (konserve) turşuyu süzün, dilimleyip servis tabağına düzenleyin.

**Isıl İşlem**
Isıl işlem yok. Not: bu tarif, önceden fermente edilmiş/hazır turşunun servise hazırlanmasını kapsar — turşu yapım süreci (haftalarca fermantasyon) bu tarifin kapsamı dışındadır.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

    "Lahana Turşusu": """**Hazırlık / Mise en Place**
1. Lahanayı ince doğrayın, tuz ve sirkeyle karıştırın.

**Isıl İşlem**
Isıl işlem yok. Not: bu tarif, önceden fermente edilmiş lahana turşusunun servise/karışıma hazırlanmasını kapsar — ev yapımı fermente turşu üretimi (tuzlu suda haftalarca bekletme) bu tarifin kapsamı dışındadır; burada verilen süre yalnızca servis hazırlığı içindir.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok (gerçek fermantasyon süreci hariç) · Toplam ~5 dk""",

    # ---------------------------------------------------------------
    # GRUP 3 -- Komposto (3)
    # ---------------------------------------------------------------

    "Kayısı Kompostosu": """**Hazırlık / Mise en Place**
1. Kayısıları yıkayıp çekirdeklerini çıkarın, iri parçalar halinde bırakın.

**Isıl İşlem**
1. Kaynatma (100°C, 15-20 dk): kayısı, şeker ve suyu tencereye alıp kaynattıktan sonra kısık ateşte kayısılar yumuşayana kadar pişirin.

**Soğutma (pasif, en az 60 dk):** komposto genellikle soğuk servis edilir — oda sıcaklığına, ardından buzdolabına alın.

**PARALEL YAPILABİLİRLİK:** Tek kap, sıralı süreç — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) ~75+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

    "Vişne Kompostosu": """**Hazırlık / Mise en Place**
1. Vişneleri yıkayıp çekirdeklerini çıkarın (çekirdekli de kullanılabilir, servis öncesi uyarı gerekir).

**Isıl İşlem**
1. Kaynatma (100°C, 15-18 dk): vişne, şeker ve suyu kaynattıktan sonra kısık ateşte pişirin.

**Soğutma (pasif, en az 60 dk).**

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) ~70+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

    "Elma Kompostosu": """**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Kaynatma (100°C, 15-20 dk): elma, tarçın, şeker ve suyu kaynattıktan sonra kısık ateşte elmalar yumuşayana kadar pişirin.

**Soğutma (pasif, en az 60 dk).**

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme (pişme + soğutma) ~75+ dk · Mutfaktaki aktif+pişirme süresi ~20 dk""",

    # ---------------------------------------------------------------
    # GRUP 3 -- Tatlı (8)
    # ---------------------------------------------------------------

    "Sütlaç": """**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün.
2. Mısır nişastasını az suyla ezip pürüzsüzleştirin.

**Isıl İşlem**
1. Pirinç haşlama (100°C, 10-12 dk): pirinci az suda yumuşayana kadar haşlayın.
2. Sütle pişirme (~90°C, kısık ateş, sürekli karıştırarak, 20-25 dk): sütü ekleyip şeker ve nişastayı karıştırarak kıvam alana kadar pişirin (dibi tutmaması için sürekli karıştırma gerekir).
3. Soğutma (pasif, en az 2 saat, tercihen buzdolabında): kaselere paylaştırıp soğumaya bırakın.

**PARALEL YAPILABİLİRLİK:** Sürekli karıştırma gerektiren bir adım olduğu için (adım 2) başka bir işlemle paralel yürütülemez.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk (çoğu sürekli karıştırma) · Pasif bekleme (soğutma) ~120+ dk · Mutfaktaki aktif+pişirme süresi ~40 dk""",

    "Kazandibi": """**Hazırlık / Mise en Place**
1. Tavuk göğsünü (tatlı için ayrılmış, lifleri ayrılmış) hazırlayın.
2. Mısır nişastasını az suyla ezin.

**Isıl İşlem**
1. Karışım pişirme (~90°C, kısık ateş, sürekli karıştırarak, 15 dk): süt, şeker, tavuk göğsü ve nişastayı sürekli karıştırarak kıvam alana kadar pişirin.
2. Kazandibi yakma (~180-200°C, tavanın altını doğrudan güçlü ateşe tutarak, KARIŞTIRMADAN, 5-8 dk): karışımı yayvan bir tavaya dökün, tavanın altını doğrudan ocak alevine tutarak alt yüzeyin kontrollü şekilde kahverengi/karamelize olmasını (yanık desenini) sağlayın — bu adımın karakteristik tekniği budur, karıştırmadan yapılır.
3. Ters çevirme ve soğutma (pasif, en az 1 saat): tavayı ters çevirip karamelize yüzü üste alın, rulo yapıp soğumaya bırakın.

**PARALEL YAPILABİLİRLİK:** Yakma adımı (adım 2) tam dikkat gerektirir, paralel yürütülemez — ama malzeme hazırlığı (Hazırlık adımları) önceden bitirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk (yakma adımı dahil, dikkat yoğun) · Pasif bekleme (soğutma) ~60+ dk · Mutfaktaki aktif+pişirme süresi ~30 dk""",

    "Revani": """**Hazırlık / Mise en Place**
1. Yumurta ve şekeri çırpın.
2. İrmik ve unu eleyip hazırlayın.

**Isıl İşlem**
1. Kek pişirme (180°C fırın, 25-30 dk): irmik, un, şeker, yumurta ve suyu karıştırıp kalıba dökün, kürdan temiz çıkana kadar pişirin.
2. Şerbet (100°C, ayrı tencerede, 8-10 dk): şeker ve suyu kaynatıp hafif koyulaşana kadar pişirin.
3. Şerbetleme (pasif, en az 30 dk): sıcak keke ILIK şerbeti (ya da tersi — soğuk keke sıcak şerbet) yavaşça gezdirip emmesi için bekletin.

**PARALEL YAPILABİLİRLİK:** Şerbet (adım Isıl İşlem-2), kek fırında pişerken AYRI ocakta paralel hazırlanabilir — ardışık ~35-40 dk'yı ~30 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (pişme + şerbetleme) ~55-60 dk · Paralel yapılırsa toplam ~55 dk, sıralı yapılırsa ~65 dk""",

    "Aşure": """**Hazırlık / Mise en Place**
1. Nohut ve kuru fasulyeyi bir gece önceden ayrı ayrı suda bekletin, süzün.
2. Kuru kayısı ve kuru üzümü yıkayın.
3. Cevizi kabaca kırın.

**Isıl İşlem**
1. Baklagil haşlama (100°C, 45-60 dk): nohut ve kuru fasulyeyi ayrı ayrı ya da birlikte yumuşayana kadar haşlayın.
2. Buğday haşlama (100°C, 45-60 dk, PARALEL): buğdayı ayrı bir tencerede aynı anda yumuşayana kadar haşlayın.
3. Birleştirme ve pişirme (100°C, kısık ateş, 20-25 dk): haşlanmış baklagiller, buğday, kuru kayısı, kuru üzüm, şeker ve suyu tek tencerede birleştirip kısık ateşte kaynatın.
4. Soğutma (pasif, en az 2 saat): kaselere paylaştırıp soğumaya bırakın, üzerine ceviz serpin.

**PARALEL YAPILABİLİRLİK:** Nohut/kuru fasulye haşlaması (adım 1) ile buğday haşlaması (adım 2) AYRI ocak gözlerinde eş zamanlı yapılabilir — ardışık ~90-120 dk'yı ~45-60 dk'ya indirir. Bu, kütüphanedeki en uzun süren tarif olduğu için paralelleştirmenin kazancı da en yüksek olanıdır.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme (bir gece ıslatma + haşlama + soğutma) çok yüksek · Paralel yapılırsa mutfaktaki pişirme süresi ~70-85 dk, sıralı yapılırsa ~115-145 dk""",

    "Muhallebi": """**Hazırlık / Mise en Place**
1. Mısır nişastasını az soğuk sütle ezip pürüzsüzleştirin (topaklanmayı önler).

**Isıl İşlem**
1. Pişirme (~90°C, kısık ateş, sürekli karıştırarak, 12-15 dk): sütün geri kalanı, şeker ve nişasta karışımını tencereye alıp sürekli karıştırarak kıvam alana kadar pişirin.
2. Soğutma (pasif, en az 2 saat, buzdolabında): kaselere paylaştırıp üzerine streç film kapatarak (kabuk bağlamasın diye) soğumaya bırakın.

**PARALEL YAPILABİLİRLİK:** Sürekli karıştırma gerektiren tek adımlı bir tarif — paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme (soğutma) ~120+ dk · Mutfaktaki aktif+pişirme süresi ~15 dk""",

    "Cevizli Kadayıf Tatlısı": """**Hazırlık / Mise en Place**
1. Kadayıfı elle didikleyip açın, eritilmiş tereyağıyla harmanlayın.
2. Cevizi kabaca kırın.

**Isıl İşlem**
1. Fırınlama (180°C, 25-30 dk): yağlanmış kadayıfın yarısını kalıba serip cevizi üzerine, kalan kadayıfı da üstüne kapatıp altı ve üstü kızarana kadar fırınlayın.
2. Şerbet (100°C, ayrı tencerede, PARALEL, 10 dk): şeker ve suyu kaynatıp hafif koyulaşana kadar pişirin.
3. Şerbetleme (pasif, en az 30 dk): fırından çıkan sıcak kadayıfın üzerine SOĞUK şerbeti (sıcak tatlıya soğuk şerbet — ya da tersi, ikisi asla aynı sıcaklıkta olmamalı) yavaşça gezdirip emmesini bekleyin.

**PARALEL YAPILABİLİRLİK:** Şerbet (adım 2), kadayıf fırında pişerken AYRI ocakta paralel hazırlanabilir — ardışık ~35-40 dk'yı ~25-30 dk'ya indirir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk (kadayıf didikleme dahil) · Pasif bekleme (pişme + şerbetleme) ~55-60 dk · Paralel yapılırsa toplam ~45-50 dk, sıralı yapılırsa ~65 dk""",

    "Meyveli Panna Cotta": """**Hazırlık / Mise en Place**
1. Jelatini soğuk suda 5-10 dk bekletip yumuşatın (pasif).
2. Çileği doğrayın.

**Isıl İşlem**
1. Pişirme (~85°C, kaynatmadan, karıştırarak, 8-10 dk): krema, süt ve şekeri tencerede karıştırarak ısıtın, kaynatmadan (kaynarsa krema ayrışabilir) yumuşamış jelatini ekleyip eriyene kadar karıştırın.
2. Kalıba dökme ve soğutma (pasif, en az 4 saat, buzdolabında): karışımı kalıplara paylaştırıp jelatin tam sertleşene kadar bekletin.
3. Servis: kalıptan çıkarıp üzerine doğranmış çilek ekleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Jelatin ıslatma (pasif, adım Hazırlık-1) ile krema-süt karışımının ısıtılmaya başlanması aynı anda yapılabilir (~5 dk kazanç). Ana bekleme (buzdolabı, 4+ saat) zaten pasif olduğu için mutfak süresini etkilemez.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme (jelatin + soğutma) ~4+ saat · Mutfaktaki aktif+pişirme süresi ~15 dk""",

    "Mevsim Meyve Tabağı": """**Hazırlık / Mise en Place**
1. Karpuz ve kavunu dilimleyip kabuklarından ayırın, küp küp doğrayın.
2. Üzümü yıkayıp salkımından ayırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Isıl işlem içermediği için paralel fırsatı yok — kütüphanedeki en hızlı hazırlanan tariflerden biri.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk""",

}
