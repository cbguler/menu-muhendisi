# talimatlar_parti1.py
#
# Pisirme talimatlari -- I. Parti (v2, detayli surum): orijinal 75
# "Klasik" tariflik kutuphanenin I. Grup (ana yemek) tarifleri (30 adet).
# Format: Hazirlik (mise en place) -> Isil Islem asama(lari) (sicaklik/
# sure/teknik) -> Paralel yapilabilirlik notlari -> Toplam sure ozeti
# (aktif isçilik vs pasif bekleme suresi ayrimi). Uretim Asamalari
# sayfasindaki maliyet hesabiyla dogrudan uyumlu olacak sekilde
# tasarlandi.
#
# talimat_yukle.py ile (recete_id'yi isme gore bulup UPDATE ederek)
# Supabase'e islenir.

TALIMATLAR = {

"Dana Kuşbaşı Sote": """HAZIRLIK (~8 dk):
- Dana kuşbaşı etini (150g) oda sıcaklığına getirin, kağıt havluyla kurulayın (nem, mühürlemeyi engeller).
- Kuru soğanı (25g) yarım ay şeklinde dilimleyin.
Not: Et kurulama ve soğan doğrama aynı kişi tarafından ardışık yapılır, paralelleştirme fırsatı yoktur (tek istasyon).

ISIL İŞLEM 1 — Mühürleme (~6 dk, tava üstü 200-220°C):
- Yağı (10g) dumanı tütecek kadar (yüksek ateş) kızdırın.
- Eti TEK KAT halinde, tavayı doldurmadan 2-3 partide ekleyin (kalabalık et su bırakıp haşlanır, mühürlenmez).
- Her partiyi 1,5-2 dk çevirmeden bekletip kahverengi kabuk oluşturun.

ISIL İŞLEM 2 — Kavurma ve Pişirme (~25-30 dk, orta-kısık ateş ~140-160°C):
- Soğanı ekleyip 3-4 dk pembeleşene kadar kavurun.
- Ateşi kısıp kapağı kapatarak et kendi suyunda yumuşayana kadar (yakl. 25 dk) pişirin, gerekirse 2-3 çorba kaşığı su ekleyin.
- Son 5 dk'da tuz/karabiber ekleyin (tuz erken eklenirse et sertleşir).

PARALEL YAPILABİLİRLİK: Isıl İşlem 2'nin kısık ateşte pişme süresi (yakl. 20 dk) PASİF bir bekleme aşamasıdır — personel bu sürede başka bir hazırlığa (ör. yanında sunulacak pilav/salata) geçebilir.

SÜRE ÖZETİ: Aktif işçilik ~15 dk (hazırlık+mühürleme+kavurma), pasif bekleme ~20 dk. Tek kişi seri çalışırsa toplam ~35-40 dk.""",

"Izgara Dana Biftek": """HAZIRLIK (~20 dk, çoğunluğu pasif bekleme):
- Bifteği (180g) buzdolabından çıkarıp oda sıcaklığına gelmesini bekleyin (pasif, ~18-20 dk — et soğukken ızgaraya girerse dışı yanar, içi soğuk kalır).
- Her iki yüzünü kağıt havluyla kurulayın, zeytinyağı (8g) sürüp tuz/karabiberle (3g) baharatlayın.

PARALEL YAPILABİLİRLİK: Etin oda sıcaklığına gelme süresi (pasif) tam olarak ızgaranın ısınma süresiyle örtüşecek şekilde planlanmalı — ızgara/dökme tava bu 18-20 dk içinde yüksek ateşte ısıtılmaya başlanır, ayrı bir bekleme oluşmaz.

ISIL İŞLEM — Izgara (~8-10 dk, çok yüksek ateş, tava/plaka yüzeyi ~230-250°C):
- Izgarayı dumanı tütene kadar kızdırın (bu, yüzeyde Maillard reaksiyonunun/kabuk oluşumunun oluşması için şarttır).
- Bifteği pişirme derecesine göre her yüzde 2-4 dk (az pişmiş: 2 dk/yüz, orta: 3 dk/yüz, iyi pişmiş: 4-5 dk/yüz) çevirmeden pişirin.
- Kalın kesimlerde kenar yağ şeridini de birkaç saniye ızgaraya değdirin.

DİNLENDİRME (pasif, ~5 dk):
- Ocaktan alıp folyoyla gevşek örterek dinlendirin — bu adım atlanırsa et suyu kesilirken dışarı akar, kurur.

SÜRE ÖZETİ: Aktif işçilik ~5 dk (baharatlama+ızgara çevirme), pasif bekleme ~23-25 dk (oda sıcaklığına gelme+dinlendirme). Toplam ~30 dk, ama personel pasif sürelerde başka masaya hizmet edebilir.""",

"Kuzu Tandır": """HAZIRLIK (~10 dk):
- Kuzu et parçasını (150g) tuz/karabiberle (3g) her yüzeyden ovun.
- İnce doğranmış soğanı (20g) etin üzerine serpin.
- Fırın kabına yerleştirip 2-3 yemek kaşığı su ekleyin, kapağı kapatın (ya da folyoyla sıkıca örtün — buharın kaçmaması, etin kendi suyunda yumuşaması için kritik).

ISIL İŞLEM — Ağır Ateş Fırınlama (PASİF, ~2,5-3 SAAT, 150-160°C fırın):
- Önceden 150-160°C'ye ısıtılmış fırına verin.
- Bu süre boyunca kolajen dokusu jelatine dönüşür, et "kemikten ayrılan" kıvama gelir — süre kısaltılırsa et sertleşir, uzatılırsa kurur.
- Ara sıra (30 dk'da bir) kontrol edip gerekirse az su ekleyin.

ISIL İŞLEM 2 — Kızartma (~15 dk, 200-220°C, kapak açık):
- Son aşamada kapağı/folyoyu açıp fırın sıcaklığını yükseltin, üstünün kızarmasını sağlayın.

PARALEL YAPILABİLİRLİK: 2,5-3 saatlik fırınlama TAMAMEN PASİF bir süreçtir — bu süre boyunca personel/fırın kapasitesi diğer siparişler için tamamen serbesttir, sadece 30 dk'da bir kontrol gerekir (~1 dk/kontrol aktif işçilik).

SÜRE ÖZETİ: Aktif işçilik ~12-15 dk (hazırlık+ara kontroller+servis), pasif fırın süresi ~2,75-3,25 saat. Bu, üretim planlamasında "uzun pasif süreçler" kategorisine girer — sabah hazırlanıp akşam servise yetiştirilebilir.""",

"Sığır Kaburga Haşlama": """HAZIRLIK (~5 dk):
- Kaburga etini (180g) soğuk suyla durulayın, geniş bir tencereye alın.
- Üzerini 3-4 cm geçecek kadar soğuk su ekleyin (soğuk suyla başlamak, etin yavaş ısınıp lifli kalmasını sağlar).

ISIL İŞLEM 1 — Kaynatma ve Köpük Alma (~10 dk, yüksek ateş → kaynama noktası 100°C):
- Yüksek ateşte kaynatın, yüzeyde biriken gri köpüğü kevgirle alın (bu adım atlanırsa suyun berraklığı ve tadı bozulur).

ISIL İŞLEM 2 — Ağır Kaynama (~1,5-2 SAAT, kısık ateş, hafif fokurdama ~90-95°C):
- İri doğranmış soğan (30g), havuç (30g) ve birkaç tane karabiber ekleyin.
- Kapağı aralık bırakarak et kemikten kolayca ayrılana kadar (yakl. 2 saat) ağır ateşte haşlayın.
- Son 10 dk'da tuz (3g) ekleyin.

PARALEL YAPILABİLİRLİK: 2 saatlik ağır kaynama süresi PASİFTİR — personel bu sürede diğer hazırlıklara (garnitür, salata, başka masaların siparişi) geçebilir; ocak sadece düşük ateşte gözetim gerektirir (10-15 dk'da bir kontrol, ~1 dk/kontrol).

SÜRE ÖZETİ: Aktif işçilik ~15 dk (hazırlık+köpük alma+ara kontroller), pasif kaynama ~2 saat. Toplam süre ~2 saat 15 dk, aktif işçilik payı çok düşüktür.""",

"Kuzu Pirzola Izgara": """HAZIRLIK (~20 dk, çoğu pasif):
- Pirzolaları (160g) buzdolabından çıkarıp oda sıcaklığına gelmesini bekleyin (pasif ~15-18 dk).
- Zeytinyağı (8g), tuz ve karabiberle (3g) ovup dinlendirin.

ISIL İŞLEM — Izgara (~6-8 dk toplam, çok yüksek ateş ~230-250°C):
- Izgarayı iyice kızdırın.
- Pirzolaları her yüzde 3-4 dk (orta pişmiş için) çevirin.
- Kalın kesimlerde yağ şeridi kenarını da birkaç saniye ateşe değdirin (yağın erimesi, çıtırlaşması için).

PARALEL YAPILABİLİRLİK: Etin oda sıcaklığına gelme süresi ile ızgaranın ısınma süresi ÖRTÜŞTÜRÜLEBİLİR — ayrı bir bekleme oluşturmaz.

DİNLENDİRME (pasif, ~3-4 dk): Ocaktan alıp dinlendirin, et suyu içeri çekilsin.

SÜRE ÖZETİ: Aktif işçilik ~8-10 dk, pasif bekleme ~20 dk. Toplam ~28-30 dk.""",

"Fırında Tavuk But": """HAZIRLIK (~8 dk):
- Tavuk butlarını (180g) yıkayıp kurulayın.
- Zeytinyağı (10g), tuz/karabiber (3g) ile ovun, isteğe göre limon dilimi ve sarımsak ekleyip fırın tepsisine dizin.

ISIL İŞLEM — Fırınlama (~35-40 dk, 200°C, önceden ısıtılmış fırın):
- Fırını MUTLAKA önceden 200°C'ye ısıtın (soğuk fırına konursa pişme süresi uzar, dış kısım kurur iç kısım geç pişer).
- 20 dk sonra tepsiyi çevirip kendi yağıyla yağlayın (eşit pişme için).
- İç sıcaklığın yeterli olduğundan emin olun: bıçakla en kalın yerden kestiğinizde suyu berrak akmalı, pembe olmamalı.

PARALEL YAPILABİLİRLİK: 35-40 dk'lık fırınlama süresi PASİFTİR — personel bu sürede diğer siparişlere geçebilir, sadece 20. dakikada 1 dakikalık bir çevirme müdahalesi gerekir.

DİNLENDİRME (pasif, ~5 dk): Fırından alıp dinlendirin, et suyu dağılsın.

SÜRE ÖZETİ: Aktif işçilik ~10 dk (hazırlık+çevirme+servis), pasif fırın süresi ~35-40 dk. Toplam ~45-50 dk.""",

"Tavuk Şiş": """HAZIRLIK (~35 dk, çoğu pasif marinasyon):
- Tavuk göğsünü (170g) 3x3 cm küpler halinde doğrayın (eşit boyut, eşit pişme için önemli).
- Zeytinyağı (10g), tuz/karabiber (3g) ve limonla (15g) marine edip en az 30 dk buzdolabında bekletin (pasif — marinasyon süresi kısaltılırsa et kuru/sert kalır).
- Etleri şişlere aynı sıklıkta dizin.

PARALEL YAPILABİLİRLİK: 30 dk'lık marinasyon PASİF bir süreçtir — bu sürede diğer siparişlerin hazırlığı, garnitür/pilav pişirme gibi işler paralel yürütülebilir.

ISIL İŞLEM — Izgara (~10-12 dk, yüksek ateş ~200-220°C):
- Izgara/tavayı iyice kızdırın.
- Şişleri çevirerek her yüzü altın rengi alana kadar, toplam 10-12 dk pişirin.
- İçinin tam piştiğinden emin olun (en kalın parçayı kesip kontrol edin).

SÜRE ÖZETİ: Aktif işçilik ~10 dk (doğrama+dizme+ızgara), pasif marinasyon ~30 dk. Marinasyon önceden (sabah/vardiya başında) toplu yapılırsa servis anındaki gerçek süre ~10-12 dk'ya iner.""",

"Tavuk Sote": """HAZIRLIK (~6 dk):
- Tavuk göğsünü (150g) ince şeritler halinde (yaklaşık 1 cm) doğrayın.
- Kuru soğanı (25g) julienne (ince uzun) doğrayın.

ISIL İŞLEM 1 — Soğan Kavurma (~4 dk, orta-yüksek ateş):
- Tavada yağı (10g) kızdırıp soğanı pembeleşene kadar kavurun.

ISIL İŞLEM 2 — Tavuk Pişirme (~10-12 dk, yüksek ateş → orta ateş):
- Tavuğu ekleyip yüksek ateşte 2-3 dk rengi dönene kadar karıştırarak pişirin.
- Ateşi orta seviyeye alıp su salıp çekene, et beyazlaşıp yumuşayana kadar (~8-10 dk) pişirmeye devam edin.
- Tuz/karabiber (3g) ekleyin.

PARALEL YAPILABİLİRLİK: Bu tarif sürekli müdahale gerektiren (karıştırma) bir sote olduğu için gerçek paralelleştirme fırsatı sınırlıdır — tek istasyon, tek personel gerektirir.

SÜRE ÖZETİ: Aktif işçilik ~16-18 dk (neredeyse tamamı aktif, pasif süre yok denecek kadar az). Toplam ~18-20 dk.""",

"Tavuk Suyu Haşlama": """HAZIRLIK (~5 dk):
- Tavuk parçalarını geniş bir tencereye alıp üzerini 3-4 cm geçecek kadar soğuk su ekleyin.

ISIL İŞLEM 1 — Kaynatma ve Köpük Alma (~8 dk, yüksek ateş):
- Kaynamaya başlayınca yüzeydeki köpüğü kaşıkla alın.

ISIL İŞLEM 2 — Ağır Haşlama (~45-60 dk, kısık ateş, hafif fokurdama ~90-95°C):
- İri doğranmış soğan (25g), havuç (20g) ve birkaç tane karabiber ekleyin.
- Kapağı aralık bırakarak et kemikten ayrılana kadar (yakl. 45-60 dk) haşlayın.
- Son 10 dk'da tuz (3g) ekleyin.

PARALEL YAPILABİLİRLİK: 45-60 dk'lık haşlama süresi PASİFTİR — bu süre boyunca personel diğer hazırlıklara geçebilir; elde edilen tavuk suyu ayrıca başka tariflerde (çorba tabanı vb.) kullanılabileceği için bu süreç genelde toplu/önceden yapılır.

SÜRE ÖZETİ: Aktif işçilik ~13 dk (hazırlık+köpük alma+ara kontroller), pasif haşlama ~45-60 dk.""",

"Kremalı Mantarlı Tavuk": """HAZIRLIK (~6 dk):
- Tavuk göğsünü (150g) dilimleyip tuz/karabiberle (3g) tatlandırın.
- Mantarları (60g) dilimleyin.
Not: Tavuk dilimleme ve mantar doğrama, iki farklı kişi tarafından PARALEL yapılabilir (ayrı kesme tahtaları gerektirir, çapraz bulaşmaya dikkat).

ISIL İŞLEM 1 — Tavuk Mühürleme (~6-8 dk, yüksek ateş):
- Tavada yağda tavuğun her iki yüzünü kızarana kadar mühürleyip tavadan alın (ayrı bir tabakta bekletin).

ISIL İŞLEM 2 — Mantar ve Sos (~8 dk, orta ateş):
- Aynı tavada mantarları suyunu salıp çekene kadar (~5 dk) kavurun.
- Kremayı (60g) ekleyip karıştırarak kaynatın (~2-3 dk, sos koyulaşmaya başlamalı).

ISIL İŞLEM 3 — Birleştirme (~5 dk, kısık ateş):
- Tavuğu tekrar tavaya alıp sosla kaplayın, kısık ateşte 5 dk daha pişirin (tavuğun iç sıcaklığının sosla dengelenmiş şekilde tamamlanması için).

PARALEL YAPILABİLİRLİK: Hazırlık aşamasındaki doğrama işleri paralel yapılabilir; ısıl işlem aşamaları ise sıralıdır (aynı tava kullanıldığı için).

SÜRE ÖZETİ: Aktif işçilik ~22-25 dk (neredeyse tamamı aktif müdahale gerektirir). Toplam ~25 dk.""",

"Izgara Tavuk Göğsü": """HAZIRLIK (~15 dk, çoğu pasif):
- Tavuk göğsünü (160g) eşit kalınlıkta olacak şekilde hafifçe tokmaklayın (eşit pişme için kritik — kalınlık farkı varsa ince kısım kurur, kalın kısım çiğ kalır).
- Zeytinyağı (8g), tuz/karabiber (3g) ve isteğe göre kekikle marine edip 10-15 dk bekletin (pasif).

ISIL İŞLEM — Izgara (~10-12 dk, orta-yüksek ateş ~180-200°C):
- Izgara/dökme tavayı iyice kızdırın.
- Her yüzünü 5-6 dk, içi tam pişene (dokununca sertleşmiş, ortası beyaz) kadar çevirerek ızgara yapın.

PARALEL YAPILABİLİRLİK: Marinasyon süresi (pasif) sırasında ızgaranın ısıtılması ve garnitür hazırlığı paralel yürütülebilir.

DİNLENDİRME (pasif, ~2-3 dk): Servis öncesi kısa dinlendirme, et suyunun dağılması için.

SÜRE ÖZETİ: Aktif işçilik ~12 dk, pasif bekleme ~13-15 dk. Toplam ~25 dk.""",

"Fırında Levrek": """HAZIRLIK (~8 dk):
- Levreği (180g) temizletip yıkayın, iç ve dış yüzeyini tuzlayın (3g).
- Karnına limon dilimi (15g) ve taze dereotu (5g) yerleştirin.
- Üzerine zeytinyağı (10g) gezdirip fırın tepsisine alın.

ISIL İŞLEM — Fırınlama (~20-25 dk, 200°C önceden ısıtılmış fırın):
- Fırını mutlaka önceden ısıtın.
- Balığın eti kolayca kemikten ayrılana (çatalla dokunulduğunda pul pul dağılana) kadar pişirin — fazla pişirme balığı kurutur, bu yüzden 20 dk'dan sonra sık kontrol edin.

PARALEL YAPILABİLİRLİK: 20-25 dk'lık fırınlama PASİFTİR — bu sürede garnitür/salata hazırlığı yapılabilir.

SÜRE ÖZETİ: Aktif işçilik ~10 dk (hazırlık+servis), pasif fırın süresi ~20-25 dk. Toplam ~30-35 dk.""",

"Izgara Çipura": """HAZIRLIK (~6 dk):
- Çipurayı (180g) temizletip yıkayın, her iki yüzüne çapraz kesikler atın (ısının içeri işlemesi ve eşit pişme için).
- Zeytinyağı (8g) ve tuzla (3g) ovun.

ISIL İŞLEM — Izgara (~12-16 dk, orta-yüksek ateş ~180-200°C):
- Izgarayı iyice kızdırın (balık derisinin yapışmaması için önemli).
- Balığı her yüzde 6-8 dk, derisi çıtır çıtır olana kadar pişirin — çevirmeden önce derinin ızgaradan kolayca ayrılmasını bekleyin (erken çevirme deriyi yırtar).

PARALEL YAPILABİLİRLİK: Sınırlıdır — balık ızgarası sürekli gözetim gerektiren tek istasyonlu bir işlemdir.

SÜRE ÖZETİ: Aktif işçilik ~15-18 dk (neredeyse tamamı aktif). Toplam ~18-22 dk.""",

"Hamsi Tava": """HAZIRLIK (~10 dk):
- Hamsileri (180g) temizleyip yıkayın, kağıt havluyla iyice kurulayın (nem, unun yapışmasını ve yağın sıçramasını etkiler).
- Mısır unu (30g), tuz/karabiber (3g) karışımını hazırlayın.
- Hamsileri una bulayıp fazlasını silkeleyin.
Not: Temizleme ve unlama iki ayrı istasyonda PARALEL yürütülebilir (bir kişi temizlerken diğeri unlar).

ISIL İŞLEM — Derin Yağda Kızartma (~4-5 dk, 175-180°C):
- Yağı (kızartma yağı ayrı, tarifte belirtilen ayçiçek yağı miktarı üzeri) 175-180°C'ye ısıtın (fazla sıcak yağ dışını yakar içini çiğ bırakır, az sıcak yağ ise fazla yağ emdirir).
- Hamsileri bol sıcak yağda her yüzü altın rengi alana kadar (yakl. 2 dk/yüz) kızartın.
- Kağıt havlu üzerinde fazla yağını aldırın.

PARALEL YAPILABİLİRLİK: Kızartma süresi kısa olduğu için (4-5 dk) anlamlı bir paralelleştirme fırsatı yoktur — sürekli gözetim gerektirir (yanma riski).

SÜRE ÖZETİ: Aktif işçilik ~14-15 dk (neredeyse tamamı aktif). Toplam ~15 dk.""",

"Somon Izgara": """HAZIRLIK (~15 dk, çoğu pasif):
- Somon fileto (170g) pişirmeden 15 dk önce buzdolabından çıkarın (pasif, oda sıcaklığına gelmesi eşit pişme için önemli).
- Zeytinyağı (8g), tuz/karabiber (3g) ve limonla (15g) ovun.

ISIL İŞLEM — Izgara (~7-9 dk, orta-yüksek ateş):
- Izgara/tavayı kızdırın, önce DERİ TARAFINDAN başlayarak pişirin (deri altındaki yağ tabakası eriyip balığı korur, ters başlanırsa et parçalanabilir).
- Deri çıtır olduğunda (~5-6 dk) çevirip diğer yüzü 2-3 dk daha pişirin.
- İç kısmı hafif pembe (medium) kalacak şekilde ocaktan alın — fazla pişirme somonun kurumasına yol açar.

PARALEL YAPILABİLİRLİK: Oda sıcaklığına gelme süresi (pasif) sırasında garnitür hazırlığı yapılabilir.

SÜRE ÖZETİ: Aktif işçilik ~10 dk, pasif bekleme ~15 dk. Toplam ~25 dk.""",

"Karides Güveç": """HAZIRLIK (~8 dk):
- Karidesleri (150g) kabuklarından ve sırt ipliğinden temizleyin.
- Kuru soğan (20g) ve sarımsağı (5g) ince kıyın.

ISIL İŞLEM 1 — Sos Tabanı (~6-8 dk, orta ateş):
- Güveç kabında (ya da tavada) zeytinyağında (10g) soğan ve sarımsağı kavurun.
- Domates/domates sosunu (40g) ekleyip 4-5 dk pişirin, sos koyulaşmalı.

ISIL İŞLEM 2 — Karides Pişirme (~3-4 dk, orta-yüksek ateş — KISA TUTULMALI):
- Karidesleri ekleyip sadece 3-4 dk, pembeleşene kadar pişirin — karides FAZLA PİŞİRİLİRSE lastik gibi sertleşir, bu adım tarifin en kritik zamanlama noktasıdır.

ISIL İŞLEM 3 — Fırınlama/Gratine (~5-6 dk, üstten ızgara/salamander veya 220°C fırın):
- Üzerine kaşar peyniri (30g) serpip fırında/salamanderde peynir eriyip hafif kızarana kadar tutun.

PARALEL YAPILABİLİRLİK: Sos tabanı hazırlanırken (Isıl İşlem 1) karidesler paralel olarak temizlenebilir/hazırlanabilir.

SÜRE ÖZETİ: Aktif işçilik ~20-22 dk, pasif süre azdır (sadece fırınlama gözetimli geçer). Toplam ~22-25 dk.""",

"Kalamar Tava": """HAZIRLIK (~8 dk):
- Kalamarları (160g) halka halka (0,8-1 cm) doğrayın, kağıt havluyla iyice kurulayın.
- Un (30g), tuz/karabiber (3g) karışımını hazırlayın.
- Halkaları una bulayıp fazlasını silkeleyin.

ISIL İŞLEM — Hızlı Derin Yağda Kızartma (~1,5-2 DK, çok yüksek ateş 180-190°C):
- Bol sıcak yağda kalamar halkalarını 1-2 dk (fazla pişirirseniz lastikleşir — kalamarın pişme penceresi çok dardır, "az pişmiş" ile "aşırı pişmiş" arasındaki fark saniyelerle ölçülür) hızlıca kızartın.
- Kağıt havlu üzerinde süzdürüp hemen servis edin (bekletilirse yumuşar/lastikleşir).

PARALEL YAPILABİLİRLİK: Kızartma süresi çok kısa olduğu için paralelleştirme anlamsızdır — ama hazırlık (doğrama/unlama) önceden toplu yapılıp servis anına kadar soğukta bekletilebilir.

SÜRE ÖZETİ: Aktif işçilik ~10 dk (neredeyse tamamı aktif, pasif süre yok). Toplam ~10 dk — bu tarifte hız kritik, geciken servis kaliteyi doğrudan düşürür.""",

"Karnıyarık": """HAZIRLIK / MİSE EN PLACE (~15 dk):
- Patlıcanları (200g) yıkayın, sapını kesin, uzunlamasına 2-3 yerinden ~1 cm derinliğinde çizik atın ("karnıyarık" adı bu yarma tekniğinden gelir).
- Kuru soğanı (30g) ince kıyın (3-4mm küpler), domatesi (40g) küçük küp doğrayın/rendeleyin.
Not: Patlıcan hazırlama ve soğan/domates doğrama, İKİ KİŞİYLE PARALEL yürütülebilir — bu durumda hazırlık süresi ~8 dk'ya iner.

ISIL İŞLEM 1 — Patlıcan Kızartma (~8-10 dk, derin yağda 170-180°C):
- Yağı 170-180°C'ye ısıtın (bir parça ekmek 15 saniyede kızarmalı — pratik ısı testi).
- Patlıcanları her yüzü altın kahverengi olana kadar (~4-5 dk/yüz) kızartın.
- Kağıt havlu üzerinde fazla yağını süzdürün.

ISIL İŞLEM 2 — Kıyma Harcı (~8 dk, orta-yüksek ateş — Isıl İşlem 1 İLE PARALEL YAPILABİLİR, ayrı ocak gözü/tava kullanılarak):
- Ayrı bir tavada kıymayı (80g) doğranmış soğanla 5 dk kavurun (kıyma suyunu salıp çekmeli, gri rengini almalı).
- Domatesi ekleyip 3 dk daha pişirin, tuzla (3g) tatlandırın.

MONTAJ VE FIRINLAMA (~20-25 dk, 180°C önceden ısıtılmış fırın):
- Kızarmış patlıcanları fırın kabına dizip yarıklarını nazikçe açın.
- Kıyma harcını yarıklara doldurun, üzerine ince domates dilimi koyun.
- 180°C fırında üzeri hafif kızarana kadar 20-25 dk pişirin.

PARALEL YAPILABİLİRLİK (ÖZET): Isıl İşlem 1 (patlıcan kızartma, ayrı ocak gözü) ile Isıl İşlem 2 (kıyma harcı, ayrı tava) EŞ ZAMANLI yürütülebilir — ardışık yapılsaydı 10+8=18 dk sürecek işlem, paralel yapılınca fiili süre ~10 dk'ya iner. Fırınlama tamamen PASİFTİR, bu sırada personel serbesttir.

SÜRE ÖZETİ: Aktif işçilik ~25-28 dk (2 kişiyle paralelleştirilirse ~18-20 dk), pasif fırın süresi ~20-25 dk. Tek kişi sıralı çalışırsa toplam ~55-60 dk; 2 istasyon paralel + fırın pasif kullanılırsa gerçek "mutfak bloke süresi" ~45 dk'ya iner.""",

"Etli Biber Dolması": """HAZIRLIK (~12 dk):
- Biberlerin (220g) kapaklarını kesip içini boşaltın (çekirdek/zar temizliği).
- Kıymayı (70g) pirinç (30g), doğranmış soğan (25g) ve baharatlarla bir kapta harmanlayın.
Not: Biber oyma ve harç hazırlama İKİ KİŞİYLE PARALEL yürütülebilir.

DOLDURMA (~8 dk, aktif elle işçilik):
- Harcı biberlere, üstte ~1 cm boşluk bırakarak (pirinç pişerken şişer, boşluksuz doldurulursa taşar/biber çatlar) doldurun.

ISIL İŞLEM — Haşlama/Buğulama (~40-45 dk, kısık ateş, hafif fokurdama):
- Tencereye dik dizip üzerine domates (20g) ve su ekleyin.
- Kapağı kapatıp kısık ateşte pirinç tam yumuşayana kadar (40-45 dk) pişirin — ateş fazla açık olursa dipteki dolmalar yapışıp yanar.

PARALEL YAPILABİLİRLİK: 40-45 dk'lık pişirme PASİFTİR — bu sürede yeni siparişlerin hazırlığına geçilebilir, sadece 15 dk'da bir kontrol (yanma riski) gerekir.

SÜRE ÖZETİ: Aktif işçilik ~20 dk (2 kişiyle ~14-15 dk), pasif pişirme ~40-45 dk. Toplam ~60-65 dk.""",

"Etli Kabak Dolması": """HAZIRLIK (~12 dk):
- Kabakları (200g) oyacak boyuta göre kesin, içini oyup boşaltın (kabuğu delmemeye dikkat — delinirse pişirme sırasında harç dışarı akar).
- Kıymayı (70g) pirinç (30g), doğranmış soğan (20g) ve baharatlarla harmanlayın.

DOLDURMA (~8 dk): Harcı kabaklara sıkıştırmadan doldurun (pirinç şişer).

ISIL İŞLEM — Buğulama (~35-40 dk, kısık ateş):
- Tencereye dizip 2-3 parmak su ekleyip kapağını kapatın.
- Kısık ateşte kabak ve pirinç yumuşayana kadar (35-40 dk) pişirin.

PARALEL YAPILABİLİRLİK: Pişirme süresi PASİFTİR, personel bu sürede başka işlere geçebilir.

SÜRE ÖZETİ: Aktif işçilik ~20 dk, pasif pişirme ~35-40 dk. Toplam ~55-60 dk.""",

"Etli Yaprak Sarma": """HAZIRLIK (~15 dk):
- Salamura yaprakları (150g) tuzunu gidermek için sıcak suda 3-4 dk bekletip süzün.
- Kıymayı (60g) pirinç (30g), doğranmış soğan (25g) ve baharatlarla harmanlayın.

SARMA (~20-25 dk, aktif elle işçilik — EN İŞÇİLİK-YOĞUN AŞAMA):
- Her yaprağın parlak/damarlı yüzü altta kalacak şekilde bir tutam harç koyup sıkıca (ama pirincin şişeceğini hesaba katarak gevşek değil, orta sıkılıkta) sarın.
- Bu aşama tecrübeye bağlı hız farkı gösterir — deneyimli personelde ~15 dk, yeni personelde 25-30 dk sürebilir.

ISIL İŞLEM — Buğulama (~40-45 dk, kısık ateş):
- Tencereye sık dizip üzerine ters bir tabak (sarmaların açılmasını engellemek için ağırlık), ardından az su koyun.
- Kısık ateşte 40-45 dk pişirin.

PARALEL YAPILABİLİRLİK: Sarma aşaması (elle işçilik) birden fazla personelle paralelleştirilebilir (2 kişi ~10-12 dk'da bitirir). Pişirme aşaması tamamen pasiftir.

SÜRE ÖZETİ: Aktif işçilik ~35-40 dk (sarma dahil, en büyük payı sarma alır), pasif pişirme ~40-45 dk. Toplam ~75-85 dk — bu tarifte işçilik maliyeti diğer ana yemeklere göre belirgin şekilde yüksektir (sarma adımı nedeniyle).""",

"Patlıcan Musakka": """HAZIRLIK (~20 dk, kısmen pasif):
- Patlıcanları (200g) dilimleyip hafif tuzlayın, 15 dk suyunu bırakmasını bekleyin (PASİF — bu adım acılığı azaltır ve kızartırken yağ emilimini düşürür), sonra kurulayın.

ISIL İŞLEM 1 — Patlıcan Kızartma (~10 dk, derin yağda 170-180°C):
- Dilimleri her iki yüzü kızarana kadar kızartıp kağıt havluda süzdürün.

ISIL İŞLEM 2 — Kıyma Harcı (~10 dk, orta ateş — Isıl İşlem 1 İLE PARALEL yapılabilir, ayrı ocak gözü):
- Kıymayı (70g) soğan (25g) ve domatesle (30g) kavurup harcı hazırlayın.

MONTAJ VE FIRINLAMA (~20-25 dk, 180°C fırın):
- Fırın kabına patlıcan ve kıyma harcını katman katman dizin, üzerine domates dilimi koyun.
- 180°C fırında üzeri hafif kızarana kadar 20-25 dk pişirin.

PARALEL YAPILABİLİRLİK: Patlıcanın dinlenme süresi (pasif, 15 dk) sırasında kıyma harcının malzemeleri hazırlanabilir. Kızartma ve harç pişirme aşamaları paralel yürütülebilir (ayrı ocak gözleri). Fırınlama tamamen pasiftir.

SÜRE ÖZETİ: Aktif işçilik ~25-28 dk (paralelleştirilirse ~18-20 dk), pasif süre (dinlendirme+fırın) ~35-40 dk. Toplam ~60-65 dk.""",

"Etli Kuru Fasulye": """HAZIRLIK (PASİF, bir gece önceden, ~8 saat):
- Kuru fasulyeyi (60g) bir gece önceden bol suda bekletin (bu adım atlanamaz — bekletilmeyen fasulye pişmesi çok uzar ve sindirimi zorlaşır), suyunu süzün.

ISIL İŞLEM 1 — Kavurma (~5 dk, orta-yüksek ateş):
- Tencerede kıymayı (50g) doğranmış soğanla (25g) kavurun.

ISIL İŞLEM 2 — Ana Pişirme (~60-90 dk, kısık ateş, hafif fokurdama):
- Fasulyeyi ekleyip üzerini 3-4 cm geçecek kadar su koyun.
- Domates salçası (15g) ve baharatları ekleyip kapağı kapatarak fasulye tam yumuşayana kadar (yakl. 60-90 dk, fasulyenin bekletilme süresine göre değişir) pişirin.

PARALEL YAPILABİLİRLİK: Bir gece önceden bekletme adımı tamamen pasif ve önceden planlanabilir (vardiya başlamadan önce). Ana pişirme süresi (60-90 dk) de pasiftir — bu süre boyunca personel tamamen serbesttir, 15-20 dk'da bir kontrol yeterlidir.

SÜRE ÖZETİ: Aktif işçilik ~12-15 dk, pasif pişirme ~60-90 dk (+bir gece bekletme, servis gününden önce yapılır). Günlük üretim planlamasında bu tarif sabah erken başlatılmalıdır.""",

"Etli Nohut Yemeği": """HAZIRLIK (PASİF, bir gece önceden ya da hazır haşlanmış nohut kullanılabilir):
- Nohutları (70g) bir gece önceden suda bekletip haşlayın (ya da önceden haşlanmış nohut hazırlayın).

ISIL İŞLEM 1 — Kavurma (~5 dk, orta-yüksek ateş):
- Eti (60g) doğranmış soğanla (25g) kavurun.

ISIL İŞLEM 2 — Ana Pişirme (~30-35 dk, kısık ateş):
- Nohutu ekleyip üzerini geçecek kadar su koyun, domates salçası (15g) ekleyin.
- Kapağı kapatarak et ve nohut yumuşayana, sos koyulaşana kadar pişirin.

PARALEL YAPILABİLİRLİK: Nohut haşlama önceden toplu yapılabilir (haftalık/günlük stok). Ana pişirme süresi (30-35 dk) pasiftir, personel serbesttir.

SÜRE ÖZETİ: Aktif işçilik ~10-12 dk, pasif pişirme ~30-35 dk (haşlanmış nohut kullanılırsa). Toplam ~40-45 dk.""",

"Mercimek Köftesi": """HAZIRLIK VE PİŞİRME (~20 dk, aktif+pasif karışık):
- Kırmızı mercimeği (50g) yıkayıp 2,5 kat suyla haşlayın (~12-15 dk, orta ateş, suyunu çekene kadar).
- Suyunu çekince ince bulguru (40g) ekleyip ocaktan alın, kapağı kapatıp 10 dk demlenmeye bırakın (PASİF — bulgurun mercimek buharıyla yumuşaması için gereklidir, acele edilirse bulgur sert kalır).

SOĞUTMA (PASİF, ~10-15 dk): Karışımın elle yoğrulabilecek sıcaklığa (ılık) gelmesini bekleyin — sıcakken yoğrulursa yanık riski oluşur ve baharatlar tam karışmaz.

ŞEKİLLENDİRME (~10-12 dk, aktif elle işçilik):
- Ilıyan karışıma doğranmış soğan (20g), salça, baharat ve limon suyunu (10g) ekleyip iyice yoğurun (pürüzsüz, parlak bir kıvam oluşana kadar — bu, köftenin dağılmadan şekil almasını sağlar).
- Avuç içinde küçük parçalar alıp parmak izi bırakarak şekil verin (geleneksel görünüm + yüzey alanı artışı sos/limonu daha iyi tutar).

Not: PİŞİRME GEREKMEZ — bu bir "çiğ köfte" tekniğidir, mercimek/bulgur haşlanmış olsa da son ürün pişirilmeden servis edilir.

PARALEL YAPILABİLİRLİK: Mercimek haşlanıp soğurken (pasif ~25 dk) diğer garnitürler (marul, limon dilimleme) hazırlanabilir. Şekillendirme birden fazla kişiyle paralelleştirilebilir.

SÜRE ÖZETİ: Aktif işçilik ~15-18 dk, pasif bekleme (demlenme+soğuma) ~20-25 dk. Toplam ~35-40 dk.""",

"Zeytinyağlı Barbunya Pilaki": """HAZIRLIK (~8 dk):
- Taze barbunyayı (180g) ayıklayıp yıkayın, iri parçaları bölün.
- Soğan (25g) ve havucu (20g) küp doğrayın.

ISIL İŞLEM (~28-32 dk, kısık-orta ateş):
- Tencerede zeytinyağında (15g) soğan ve havucu 4-5 dk kavurun.
- Barbunyayı ekleyip birkaç dakika çevirin.
- Domates (20g) ve az su ekleyip kapağını kapatarak barbunya yumuşayana kadar (25-30 dk) pişirin.

SOĞUTMA (PASİF, ~1-2 saat oda sıcaklığında, ardından buzdolabında): Zeytinyağlılar geleneksel olarak SICAK değil ILIK/SOĞUK servis edilir — bu bekleme, tadın oturması için de önemlidir, acele edilmemelidir.

PARALEL YAPILABİLİRLİK: Pişirme süresi (25-30 dk) pasiftir. Soğuma süresi de tamamen pasif ve önceden (bir gün önceden bile) planlanabilir — zeytinyağlılar bekleyerek lezzetlenir.

SÜRE ÖZETİ: Aktif işçilik ~12-15 dk, pasif pişirme+soğuma ~30 dk (+servis öncesi soğuma süresi, ayrı planlanır). Bu tarif toplu/önceden üretime çok uygundur.""",

"Zeytinyağlı Nohut Yemeği": """HAZIRLIK: Haşlanmış nohut (70g) hazır bulundurun (ya da bir gece önceden bekletip haşlayın — PASİF, bir gece).

ISIL İŞLEM (~20-25 dk, kısık ateş):
- Tencerede zeytinyağında (15g) doğranmış soğanı (25g) kavurun.
- Nohutu ve domatesi/salçayı ekleyip az su koyun.
- Kapağı kapatıp kısık ateşte 15-20 dk, sos koyulaşana kadar pişirin.

SOĞUTMA (PASİF): Ilık ya da soğuk servis edilir, önceden hazırlanıp bekletilmesi lezzeti artırır.

PARALEL YAPILABİLİRLİK: Nohut haşlama önceden toplu yapılabilir. Pişirme süresi pasiftir.

SÜRE ÖZETİ: Aktif işçilik ~10 dk, pasif pişirme ~15-20 dk. Toplam ~25-30 dk (haşlanmış nohutla).""",

"Menemen": """HAZIRLIK (~5 dk):
- Domatesleri (küçük küp/rendelenmiş) ve yeşil biberi ince doğrayın.

ISIL İŞLEM 1 — Biber Kavurma (~3-4 dk, orta ateş):
- Tavada yağda biberi kavurun.

ISIL İŞLEM 2 — Domates Pişirme (~5-6 dk, orta ateş):
- Domatesi ekleyip suyunu salıp çekene kadar pişirin (bu adım atlanırsa/yeterince pişirilmezse menemen sulu kalır).

ISIL İŞLEM 3 — Yumurta (~3-5 dk, orta-kısık ateş — KİŞİSEL TERCİHE GÖRE SÜRE DEĞİŞİR):
- Yumurtaları kırıp karıştırmadan (Ege usulü) ya da hafif karıştırarak (İstanbul usulü) pişirin.
- İstenen kıvama (akışkan/orta/katı) göre 3-5 dk arasında değişen sürede ocaktan alın.

PARALEL YAPILABİLİRLİK: Bu tarif tek tavada sıralı ilerleyen bir işlemdir, anlamlı paralelleştirme fırsatı yoktur — hız, sürekli aktif müdahaleye bağlıdır.

SÜRE ÖZETİ: Aktif işçilik ~15-18 dk (neredeyse tamamı aktif). Toplam ~15-18 dk — hızlı servis gerektiren bir tarif, kahvaltı/brunch yoğun saatlerinde tek kişi seri üretebilir.""",

"Sahanda Yumurta (Sucuklu)": """HAZIRLIK (~3 dk):
- Sucuğu (40g) ince dilimleyin.

ISIL İŞLEM 1 — Sucuk Kavurma (~4-5 dk, orta ateş):
- Tavada yağda sucuğu her iki yüzü kızarıp kendi yağını bırakana kadar pişirin (bu yağ, yumurtaya lezzet verir — sucuk yağının erimesi kritik bir adımdır).

ISIL İŞLEM 2 — Yumurta (~4-6 dk, kısık ateş, kapaklı):
- Yumurtaları doğrudan sucuğun üzerine kırın.
- Kapağı kapatıp ak kısım pişene, sarısı istenen kıvama (genelde akışkan bırakılır) gelene kadar kısık ateşte pişirin.

PARALEL YAPILABİLİRLİK: Kısa süreli, tek tavalı bir tariftir — paralelleştirme fırsatı sınırlıdır.

SÜRE ÖZETİ: Aktif işçilik ~10 dk (çoğunlukla aktif, kapak kapalıyken kısa bir pasif bekleme vardır). Toplam ~10-11 dk.""",

"Dana Rosto": """HAZIRLIK (~5 dk):
- Rosto etini oda sıcaklığına getirin, tuz/karabiberle ovun.

ISIL İŞLEM 1 — Mühürleme (~6-8 dk, yüksek ateş):
- Tencerede yağı kızdırıp etin her yüzünü (bütün parça ya da büyük parçalar halinde) kahverengi kabuk oluşana kadar mühürleyin.

ISIL İŞLEM 2 — Kavurma (~4 dk, orta ateş):
- Doğranmış soğanı ekleyip pembeleşene kadar kavurun.

ISIL İŞLEM 3 — Ağır Pişirme (~60-90 dk, kısık ateş, kapaklı):
- Az su ekleyip kapağı kapatarak kısık ateşte et yumuşayana kadar (yakl. 1-1,5 saat) pişirin, arada kontrol edip gerekirse su ilave edin.

PARALEL YAPILABİLİRLİK: Isıl İşlem 3'ün 60-90 dk'lık süresi tamamen PASİFTİR — personel bu sürede diğer hazırlıklara geçebilir, 15-20 dk'da bir kontrol yeterlidir.

DİLİMLEME VE SERVİS (~5 dk): Et dinlendirildikten sonra (pasif ~5 dk) dilimlenip kendi sosuyla servis edilir.

SÜRE ÖZETİ: Aktif işçilik ~15-18 dk, pasif pişirme ~60-90 dk. Toplam ~80-110 dk, ama aktif işçilik payı düşüktür.""",

}
