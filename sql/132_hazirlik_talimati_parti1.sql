-- 132_hazirlik_talimati_parti1.sql  (REVIZYON 2)
-- 244/245 eksik talimat gorevi, Parti 1: alfabetik 1-15.
-- Revizyon 2: (a) su miktarlari talimata yazildi, (b) SU malzemesi 5 tarifin
-- recete_malzemeleri'ne ve isil islem asamasinin asama_malzemeleri'ne eklendi
-- (enerji hesabi suyu da kapsasin diye), (c) firin adimlari '...C'ye onceden
-- isitilmis firinda X dakika' kalibina cevrildi.
-- Su miktarlari Claude TAHMINI, Bahri onayiyla. Gramajlar 10 porsiyon icin.
-- Tek transaction: herhangi bir kontrol tutmazsa HICBIR degisiklik yapilmaz.
-- Idempotent: tekrar calistirilabilir (eski SU satirlari once silinir).

do $$
declare
    v_n int;
    v_recete_id uuid;
    v_rm_id uuid;
    v_asama_id uuid;
    v_su_id uuid := '9f265c5f-7d22-43c8-8356-9f748af1c9ee';
begin
    -- SU malzemesinin varligini dogrula
    perform 1 from malzemeler where id = v_su_id and ad = 'SU';
    if not found then raise exception 'SU malzemesi bulunamadi'; end if;

    ---------------- A) HAZIRLIK TALIMATLARI ----------------
    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ahtapotu akan soğuk su altında yıkayın; gözleri ve ağızdaki sert gagayı bıçakla çıkarıp başın içini boşaltın.
2. Maydanozu yıkayıp süzün, saplarını ayırarak yapraklarını ince kıyın.
3. Zeytinyağı, limon suyu ve tuzu bir kapta emülsiyon oluşana kadar çırparak sosu hazırlayın.

**Isıl İşlem**
1. Haşlama (~85°C, tencerede kısık ateşte, 30 dk): Tencereye 2 litre (2000 g) su koyup kaynamaya yakın ısıtın. Ahtapotu bu suya dokunaçlarından tutarak 3 kez daldırıp çıkarın (dokunaçlar kıvrılır, kabuk sıyrılmaz), sonra tamamen batırın. Suyu fokurdatmadan, gövdenin en kalın yerine çatal rahatça batana kadar pişirin.
2. Son işlemler: Ahtapotu süzün, dokunaçları ve gövdeyi 1–1,5 cm parçalara doğrayın. Ilıkken sosla ve maydanozla karıştırın (ılık et sosu daha iyi çeker). Servisten önce buzdolabında soğutun (soğutma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Maydanoz kıyımı ve sos hazırlığı haşlama sırasındaki pasif bekleme içinde yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~22 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Ahtapot Salatası (Soğuk)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ahtapot Salatası (Soğuk)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bulguru süzgeçte hızlıca durulayıp iyice süzdürün.
2. Antep fıstıklarını bıçakla iri kırın.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tavuk suyunu ayrı bir kapta ısıtın. Tereyağını tencerede eritip fıstıkları 1 dk çevirin ve bir kaba alın. Aynı yağda bulguru 2 dk kavurun, sıcak tavuk suyunu ve tuzu ekleyin. Kaynayınca ateşi en kısığa alıp kapağı kapalı olarak bulgur suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez veya kağıt havlu koyarak kısa süre demlendirin. Fıstıkları üzerine serpip servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, fıstık ve bulgur kavrulurken ayrı gözde ısıtılabilir; pilav kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Antep Fıstıklı Bulgur Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Antep Fıstıklı Bulgur Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru soğanı soyup ince yarım ay veya küçük küp doğrayın.
2. Antep fıstıklarını bıçakla iri kırın.

**Isıl İşlem**
1. Kavurma (orta-yüksek ateş, geniş tavada, 20 dk): Kıymayı yağ eklemeden tavaya alın; iri topakları kaşıkla dağıtarak önce suyunu salıp sonra çekene ve tane tane olana kadar kavurun (~10 dk). Soğanı ekleyip pembeleşene kadar kavurmaya devam edin (~7 dk). Tuz, karabiber ve fıstığı ekleyip 2–3 dk daha çevirin.

**PARALEL YAPILABİLİRLİK:** Kavurma boyunca sürekli karıştırma gerektiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Antep Fıstıklı Kavurma';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Antep Fıstıklı Kavurma', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Süzme yoğurdu pürüzsüz olana kadar çırpın.
2. Armutları yıkayın, dörde bölüp çekirdek evlerini çıkarın ve 1 cm küp doğrayın.
3. Doğranan armutları kararmaması için bekletmeden yoğurda katıp karıştırın.
4. Cevizleri iri kırıp servis sırasında üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Armutlu Cevizli Salata';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Armutlu Cevizli Salata', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Arpayı suyu berraklaşana kadar yıkayıp süzün. Tam tane arpa kullanılıyorsa önceden birkaç saat ıslatılması pişme süresini kısaltır (ıslatma süresi özete dahil değildir).
2. Kuru soğanı soyup küçük küp doğrayın.
3. Havuçları kazıyıp küçük küp doğrayın.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 30 dk): Tereyağında soğanı 3–4 dk, ardından havucu 2 dk kavurun. Arpayı ekleyip 1 dk çevirin, 2,5 litre (2500 g) sıcak su ekleyin. Kaynayınca ateşi kısıp arpa yumuşayana kadar ara ara karıştırarak pişirin. Tuzu son 5 dakikada ekleyin; kıvam fazla koyulaşırsa az miktarda sıcak suyla açın.

**PARALEL YAPILABİLİRLİK:** 2,5 litre su, sebzeler doğranırken ayrı bir kapta ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~22 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Arpa Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Arpa Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Yoğurdu geniş bir kapta pürüzsüz olana kadar çırpın.
2. Soğuk sütü azar azar ekleyerek çırpmaya devam edin.
3. Tuzu ekleyip el blenderiyle üzeri köpüklenene kadar çırpın.
4. Soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Ayran (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ayran (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ayvaları yıkayıp üzerindeki tüyleri bir bezle silin.
2. Ayvaları soyun, ikiye kesip çekirdek evlerini kaşıkla oyun. Kabukları ve çekirdekleri atmayın, ayrı bir kaba alın.
3. Oyduğunuz ayvaları kararmaması için pişirmeye kadar soğuk suda bekletin.

**Isıl İşlem**
1. Şerbette Pişirme (~95°C, geniş tencerede kapaklı, 30 dk): Kabukları ve çekirdekleri tencerenin tabanına yayın (renk ve kıvam verir). Ayvaları oyuk tarafları yukarı gelecek şekilde dizin, şekeri oyuklara ve üzerine serpin. 500 ml (500 g) su ekleyin; su ayvaların yaklaşık yarısına gelmelidir. Kaynayınca ateşi kısıp kapağı kapalı olarak ayvalar yumuşayıp şerbet koyulaşana kadar pişirin; arada şerbeti ayvaların üzerine gezdirin.
2. Son işlemler: Ayvaları tencerede ılımaya bırakın, şerbetiyle birlikte servis tabağına alın. Soğuk servis edin (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu süre içinde başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~22 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Ayva Tatlısı (Kış)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ayva Tatlısı (Kış)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Beyaz ezme için kabuğu soyulmuş (beyazlatılmış) badem kullanın.
2. Şekeri mutfak robotunda pudra kıvamına gelene kadar öğütün.
3. Bademleri ekleyip kısa aralıklarla çalıştırarak ince un kıvamına getirin; uzun çalıştırmayın, badem yağını salar.
4. Karışımı bir kaba alıp 2 yemek kaşığı (30 g) suyu azar azar ekleyerek avuç içinde bastıra bastıra toparlanan bir hamur elde edin.
5. Ceviz büyüklüğünde parçalar koparıp yuvarlayın veya şekil verin, servis tabağına dizin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Badem Ezmesi Tabağı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Badem Ezmesi Tabağı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Tavuk butlarını kağıt havluyla kurulayın (kuru yüzey daha iyi renk alır).
3. Zeytinyağı, tuz ve karabiberi karıştırıp butları her yüzünden ovun.
4. Bademleri iri doğrayın.

**Isıl İşlem**
1. Fırınlama (200°C, 40 dk): Butları tepsiye derili yüzleri üstte ve aralıklı dizin. 200°C'ye önceden ısıtılmış fırında 40 dakika pişirin; son 10 dakikada doğranmış bademleri üzerlerine serpin (erken konursa yanar). Butun en kalın yerinde iç sıcaklık en az 75°C olmalı, kemiğe yakın kısımda pembelik kalmamalıdır.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir; fırınlama sırasında garnitür veya yan yemek hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~32 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Bademli Fırın Tavuk But';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bademli Fırın Tavuk But', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Bademleri ince şerit veya iri parçalar halinde doğrayın.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tavuk suyunu ayrı bir kapta ısıtın. Tereyağını tencerede eritip bademleri hafif renk alana kadar çevirin ve bir kaba alın. Aynı yağda pirinci taneler şeffaflaşana kadar 2–3 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin. Bademleri üzerine serpip servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, badem ve pirinç kavrulurken ayrı gözde ısıtılabilir; pilav kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Bademli Pirinç Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bademli Pirinç Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Salatalıkları yıkayın, uçlarını kesip küçük küp doğrayın veya iri rendeleyin; rendelenmişse suyunu hafifçe sıkın.
2. Sarımsakları soyup tuzla birlikte havanda veya bıçak sırtıyla ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
4. Salatalığı ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Bahar Cacığı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bahar Cacığı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 190°C'ye ısıtmaya başlayın.
2. Ispanakları ayıklayın, toprağı tamamen gidene kadar bol suda birkaç kez yıkayıp süzün.
3. Ispanakları ince doğrayın, tuzla ovun ve suyunu avuçla iyice sıkın (fırında sulanmasın).
4. Feta peynirini ufalayıp ıspanakla karıştırın.
5. Tereyağını eritin; yumurtaları çırpıp erimiş tereyağının yarısıyla karıştırın (üstüne sürmek için 2–3 kaşık ayırın).
6. Tepsiyi yağlayın. Yufkaları kat kat serin, her katın arasına yağlı yumurta karışımı sürün. Harcı ortadaki kata eşit yayın, kalan yufkalarla kapatın.
7. Üst yüzeye ayırdığınız karışımı sürün ve böreği pişirmeden önce servis dilimlerine kesin.

**Isıl İşlem**
1. Fırınlama (190°C, 25 dk): Böreği 190°C'ye önceden ısıtılmış fırının orta rafında, üstü ve altı altın rengi olana kadar 25 dakika pişirin.
2. Son işlemler: Birkaç dakika dinlendirip kesik yerlerinden ayırarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken ıspanak ve harç hazırlığı yapılabilir; fırınlama sırasında başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~20 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Bahar Ispanaklı Böreği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bahar Ispanaklı Böreği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2 cm kuşbaşı doğrayın.
2. Taze soğanları yıkayın; beyaz kısımlarını ve yeşil kısımlarını ayrı ayrı doğrayın.
3. Sarımsakları ince kıyın.
4. Domatesleri yıkayıp küçük küp doğrayın.
5. Taze bezelyeyi ayıklayın; dondurulmuş bezelye kullanılıyorsa çözdürmeden kullanın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp tavukları tavayı doldurmadan her yüzü renk alana kadar soteleyin (~6–7 dk). Taze soğanın beyaz kısmını ve sarımsağı ekleyip 1–2 dk çevirin. Bezelyeyi ekleyip 3–4 dk soteleyin. Domates, tuz ve karabiberi ekleyin; domates suyunu salıp çekene ve bezelye yumuşayana kadar pişirin (~6–7 dk). Taze soğanın yeşil kısmını ocaktan almadan hemen önce ekleyin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Sote sürekli karıştırma gerektirdiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Bahar Sebzeli Tavuk Sote';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bahar Sebzeli Tavuk Sote', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Piliç göğüslerini kurulayın; kalın kısımlarını bıçakla açarak veya et döveceğiyle döverek her parçayı eşit kalınlığa (~1,5–2 cm) getirin.
2. Zeytinyağı, pul biber, kekik ve tuzu karıştırın.
3. Göğüsleri bu karışımla her yüzünden ovun.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 20 dk): Izgarayı ısıtıp ızgara tellerini yağlayın. Göğüsleri partiler halinde her yüzü ~5–6 dk pişirin; pişerken sık çevirmeyin. En kalın yerde iç sıcaklık en az 75°C olmalı.
2. Son işlemler: Pişen parçaları birkaç dakika dinlendirip dilimleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken baharatlama yapılabilir; ızgara boyunca parti parti takip gerektiği için başka paralel fırsat yok.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Baharatlı Izgara Piliç Göğüs';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Baharatlı Izgara Piliç Göğüs', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Taze barbunyaları ayıklayıp yıkayın.
2. Sarımsakları soyup ikiye bölün.
3. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): Tencereye 1,5 litre (1500 g) su ve tuzu koyup kaynatın. Barbunyaları bu suda tam kaynama noktasında, taneler diri kalacak şekilde haşlayın. Çiğ veya az pişmiş barbunya güvenli değildir; en az 10 dk tam kaynama şarttır.
2. Son işlemler: Barbunyaları haşlama suyundan ayırıp sarımsakla birlikte kavanoza yerleştirin. Haşlama suyu ılıyınca sirkeyle karıştırıp barbunyaların üzerini tamamen örtecek kadar ekleyin. Kavanozun ağzını kapatın ve serin, karanlık bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Kavanoz ve sarımsak hazırlığı haşlama sırasında yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Barbunya Turşusu (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Barbunya Turşusu (Bahar)', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Ahtapot Salatası (Soğuk): 2000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ahtapot Salatası (Soğuk)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Ahtapot Salatası (Soğuk)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 2000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Ahtapot Salatası (Soğuk)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Arpa Çorbası: 2500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Arpa Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Arpa Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 2500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Arpa Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Ayva Tatlısı (Kış): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayva Tatlısı (Kış)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Ayva Tatlısı (Kış)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Ayva Tatlısı (Kış)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Badem Ezmesi Tabağı: 30 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Badem Ezmesi Tabağı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Badem Ezmesi Tabağı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 30) returning id into v_rm_id;
    -- Isil islem asamasi yok (hamur baglama suyu) -- asama_malzemeleri eklenmez.

    -- Barbunya Turşusu (Bahar): 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Barbunya Turşusu (Bahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Barbunya Turşusu (Bahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Barbunya Turşusu (Bahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 15 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Ahtapot Salatası (Soğuk)', 'Antep Fıstıklı Bulgur Pilavı', 'Antep Fıstıklı Kavurma', 'Armutlu Cevizli Salata', 'Arpa Çorbası', 'Ayran (Ev Usulü)', 'Ayva Tatlısı (Kış)', 'Badem Ezmesi Tabağı', 'Bademli Fırın Tavuk But', 'Bademli Pirinç Pilavı', 'Bahar Cacığı', 'Bahar Ispanaklı Böreği', 'Bahar Sebzeli Tavuk Sote', 'Baharatlı Izgara Piliç Göğüs', 'Barbunya Turşusu (Bahar)') order by ad;

-- Dogrulama 2: 5 satir; Badem Ezmesi disinda hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
order by r.ad;
