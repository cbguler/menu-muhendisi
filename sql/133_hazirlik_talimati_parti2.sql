-- 133_hazirlik_talimati_parti2.sql
-- (1) Parti 1 duzeltmeleri: Ayran'da SÜT (TAM YAĞ) cikarilip yerine SU eklendi
--     (ayran su ile yapilir); Bahar Cacığı'na SU eklendi; ikisinin talimati guncellendi.
-- (2) Parti 2: alfabetik 16-30 talimatlari + 12 tarife SU (Bahri onayli miktarlar,
--     10 porsiyon). Cevizli Kırmızı Lahana Salatası, Cevizli Pekmez, Çilekli Yoğurt: su YOK (onayli).
-- Tek transaction; herhangi bir kontrol tutmazsa HICBIR degisiklik yapilmaz. Idempotent.

do $$
declare
    v_n int;
    v_recete_id uuid;
    v_rm_id uuid;
    v_asama_id uuid;
    v_su_id uuid := '9f265c5f-7d22-43c8-8356-9f748af1c9ee';
begin
    perform 1 from malzemeler where id = v_su_id and ad = 'SU';
    if not found then raise exception 'SU malzemesi bulunamadi'; end if;

    ---------------- A) AYRAN: SÜT -> SU ----------------
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayran (Ev Usulü)';
    if v_recete_id is null then raise exception 'Ayran bulunamadi'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in (
        select rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
        where rm.recete_id = v_recete_id and m.ad = 'SÜT (TAM YAĞ)');
    delete from recete_malzemeleri rm using malzemeler m
    where m.id = rm.malzeme_id and rm.recete_id = v_recete_id and m.ad = 'SÜT (TAM YAĞ)';
    -- (tekrar calistirmada 0 satir silinir -- bu normal, kontrol edilmiyor)

    ---------------- B) HAZIRLIK TALIMATLARI ----------------
    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Yoğurdu geniş bir kapta pürüzsüz olana kadar çırpın.
2. 400 ml (400 g) soğuk içme suyunu azar azar ekleyerek çırpmaya devam edin; suyu bir anda eklemek topaklanmaya yol açar.
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
1. Salatalıkları yıkayın, uçlarını kesip küçük küp doğrayın veya iri rendeleyin; rendelenmişse suyunu hafifçe sıkın.
2. Sarımsakları soyup tuzla birlikte havanda veya bıçak sırtıyla ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
4. 300 ml (300 g) soğuk içme suyunu azar azar ekleyerek çırpın ve akışkan cacık kıvamı elde edin.
5. Salatalığı ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Bahar Cacığı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bahar Cacığı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Dana butu sinir ve zarlarından ayıklayıp 2–2,5 cm kuşbaşı doğrayın, kağıt havluyla kurulayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Taze bezelyeyi ayıklayıp yıkayın; dondurulmuş bezelye kullanılıyorsa çözdürmeden kullanın.
5. 1,2 litre (1200 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Yahni Pişirme (~95°C, tencerede kısık ateşte, 45 dk): Zeytinyağında etleri yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk, domatesi ekleyip 2–3 dk daha kavurun. 1,2 litre sıcak suyu ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak etler yumuşamaya başlayana kadar pişirin. Pişirmenin son 15 dakikasında bezelye, tuz ve karabiberi ekleyin; et ve bezelye tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; yahni kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~35 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Bezelyeli Dana Yahnisi';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bezelyeli Dana Yahnisi', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu kol etini kemik ve fazla yağından ayırıp 2–2,5 cm kuşbaşı doğrayın, kağıt havluyla kurulayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Taze bezelyeyi ayıklayıp yıkayın; dondurulmuş bezelye kullanılıyorsa çözdürmeden kullanın.
5. 1 litre (1000 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 40 dk): Zeytinyağında etleri yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk, domatesi ekleyip 2–3 dk daha kavurun. 1 litre sıcak suyu ekleyin; kaynayınca ateşi kısın, kapağı kapalı pişirin. Pişirmenin son 15 dakikasında bezelye, tuz ve karabiberi ekleyin; et ve bezelye tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; yemek kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~30 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Bezelyeli Kuzu Yemeği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bezelyeli Kuzu Yemeği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Taze bezelyeyi ayıklayıp yıkayın; dondurulmuş bezelye kullanılıyorsa çözdürmeden kullanın.
3. Tavuk suyunu ve 100 ml (100 g) suyu birlikte ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tavuk suyu ve su karışımını ayrı bir kapta ısıtın. Tereyağını tencerede eritip bezelyeyi 2 dk çevirin. Pirinci ekleyip taneler şeffaflaşana kadar 2–3 dk kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin ve servis edin.

**PARALEL YAPILABİLİRLİK:** Sıvı, bezelye ve pirinç kavrulurken ayrı gözde ısıtılabilir; pilav kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Bezelyeli Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bezelyeli Pilav', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Taze bezelyeyi ayıklayıp yıkayın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 7 dk): 1 litre (1000 g) suyu kaynatın, bezelyeyi ekleyip diri kalacak şekilde 3–5 dk haşlayın. Süzüp hemen soğuk suya alarak pişmeyi durdurun (rengi de canlı kalır) ve iyice süzdürün.
2. Son işlemler: Soğumuş bezelyeyi sarımsaklı yoğurtla karıştırıp soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Sarımsaklı yoğurt, haşlama suyu kaynarken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Bezelyeli Yoğurt Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Bezelyeli Yoğurt Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Biberleri yıkayın; sap kısımlarını kapak olarak kullanmak üzere yuvarlak kesin, çekirdeklerini ve iç zarlarını temizleyin.
2. Pirinci yıkayıp süzün.
3. Kuru soğanı ve domatesi rendenin ince tarafıyla rendeleyin.
4. Kıyma, pirinç, rendelenmiş soğan ve domates, tuz ve karabiberi bir kapta harmanlayın (domatesin suyu yeterli olduğu için harca ayrıca su eklemeyin).
5. Harcı biberlere, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun ve kapaklarını kapatın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 40 dk): Dolmaları tencereye dik ve sıkı dizin. 500 ml (500 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısın ve pirinç tamamen pişip biberler yumuşayana kadar pişirin.
2. Son işlemler: Dolmaları tencerede 5–10 dk dinlendirip servis edin.

**PARALEL YAPILABİLİRLİK:** Su, dolmalar doldurulurken ısıtılabilir; pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~32 dk · Toplam ~65 dk$t$
    where isletme_id is null and ad = 'Biber Dolması (Etli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Biber Dolması (Etli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Brokoliyi yıkayıp çiçeklerine ayırın; sapını soyup küçük doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyunu ve 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 20 dk): Tavuk suyu ve su karışımını ayrı bir kapta ısıtın. Tereyağında soğanı 3–4 dk kavurun, brokoliyi ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp brokoli tamamen yumuşayana kadar (~10–12 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin. Kıvam koyu kalırsa az miktarda sıcak suyla açın.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Brokoli Çorbası (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Brokoli Çorbası (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2 cm kuşbaşı doğrayın.
2. Brokoliyi yıkayıp küçük çiçeklerine ayırın.
3. Sarımsakları ince kıyın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp tavukları tavayı doldurmadan her yüzü renk alana kadar soteleyin (~6–7 dk). Sarımsağı ekleyip 1 dk çevirin. Brokoliyi ekleyin, 100 ml (100 g) suyu dökün ve kapağı kapatarak brokoli diri-yumuşak olana kadar 3–4 dk buharda pişirin. Kapağı açıp kalan suyu uçurun, tuz ve karabiberi ekleyip 1–2 dk çevirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Sote sürekli takip gerektirdiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Brokolili Tavuk Sote (Sporcu)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Brokolili Tavuk Sote (Sporcu)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Brüksel lahanalarının sarı ve sert dış yapraklarını ayıklayın, sap uçlarını kesin ve yıkayın; büyük olanları ikiye bölün.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Havuçları kazıyıp küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı 3–4 dk, ardından havucu 2 dk kavurun. Brüksel lahanalarını ekleyip 2 dk çevirin. 300 ml (300 g) sıcak su, şeker ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak lahanalar yumuşayana kadar pişirin.
2. Son işlemler: Tencerede ılımaya bırakın; zeytinyağlı olarak ılık veya soğuk servis edin (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Brüksel Lahanalı Zeytinyağlı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Brüksel Lahanalı Zeytinyağlı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kırmızı lahananın dış yapraklarını ve sert göbeğini çıkarın, ince şeritler halinde doğrayın.
2. Doğranmış lahanayı tuzla ovarak birkaç dakika bekletin; hafif yumuşar ve acılığı azalır.
3. Zeytinyağı ve limon suyunu çırparak sosu hazırlayın.
4. Cevizleri iri kırın.
5. Lahanayı sosla karıştırın, cevizleri servis sırasında üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Lahana tuzla beklerken sos ve ceviz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Cevizli Kırmızı Lahana Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Cevizli Kırmızı Lahana Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Cevizleri iri parçalar halinde kırın.
2. Üzüm pekmezini servis kasesine alın.
3. Cevizleri pekmeze ekleyip karıştırın veya pekmezin üzerine serperek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk$t$
    where isletme_id is null and ad = 'Cevizli Pekmez';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Cevizli Pekmez', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Çilekleri yapraklarını koparmadan yıkayın (sonradan yıkanırsa su çeker), ardından yapraklarını ayırıp dörde bölün.
2. Çileklerin yarısını şekerle ezin veya el blenderiyle püre haline getirin.
3. Süzme yoğurdu çırpıp çilek püresiyle karıştırın.
4. Kalan doğranmış çilekleri üzerine koyup soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Çilekli Yoğurt';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Çilekli Yoğurt', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Sert ve iri domatesleri yıkayın; sap tarafından ince bir kapak kesin.
2. Domateslerin içini kaşıkla, kabuğa 0,5–1 cm et payı bırakarak oyun; çıkan iç kısmı ince doğrayıp ayırın.
3. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
4. Kıyma, pirinç, soğan, ayırdığınız domates içinin yarısı, zeytinyağının yarısı, tuz ve karabiberi harmanlayın.
5. Harcı domateslere, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun ve kapaklarını kapatın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 35 dk): Dolmaları tencereye dik dizin. Kalan domates içini ve zeytinyağını 300 ml (300 g) sıcak suyla karıştırıp kenarlardan ekleyin; domatesler de suyunu salacağı için fazla su eklemeyin. Kapağı kapatın; kaynayınca ateşi kısıp pirinç tamamen pişene kadar pişirin. Domateslerin dağılmaması için karıştırmayın.
2. Son işlemler: Tencerede birkaç dakika dinlendirip dikkatle servis tabağına alın.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~27 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Domates Dolması (Etli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Domates Dolması (Etli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Turşu için sert, olgunlaşmamış (yeşil) domates tercih edin. Domatesleri yıkayıp saplarını çıkarın ve kürdanla birkaç yerinden delin (salamura içine işlesin).
2. Sarımsakları soyun.
3. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın ve tuz tamamen eriyene kadar kaynamayı sürdürün. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin (sirke kaynatılmaz, aroması uçar).
2. Son işlemler: Domatesleri sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı domateslerin üzerini tamamen örtecek şekilde dökün. Kavanozu kapatın ve serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Domates ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Domates Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Domates Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Salatalıkları yıkayın, uçlarını kesip küçük küp doğrayın.
2. Domatesleri yıkayıp çekirdekli sulu kısmını ayırın ve küçük küp doğrayın (cacığı sulandırmasın).
3. Sarımsakları soyup tuzla birlikte ezin.
4. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
5. 300 ml (300 g) soğuk içme suyunu azar azar ekleyerek çırpın ve akışkan cacık kıvamı elde edin.
6. Salatalık ve domatesi ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Domatesli Cacık';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Domatesli Cacık', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patatesleri soyup 2 cm küp doğrayın; kararmaması için pişirmeye kadar soğuk suda bekletin.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı 3–4 dk kavurun, domatesi ekleyip 3 dk pişirin. Süzdüğünüz patatesleri ekleyip 2 dk çevirin. 400 ml (400 g) sıcak su ve tuzu ekleyin; su patateslerin hemen altına gelmelidir. Kaynayınca ateşi kısıp kapağı kapalı olarak patatesler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Domatesli Patates Yemeği (Etsiz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Domatesli Patates Yemeği (Etsiz)', v_n; end if;

    ---------------- C) SU MALZEMESI ----------------
    -- Ayran (Ev Usulü): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayran (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Ayran (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Bahar Cacığı: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bahar Cacığı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Bahar Cacığı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Bezelyeli Dana Yahnisi: 1200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Dana Yahnisi';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Bezelyeli Dana Yahnisi'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Bezelyeli Dana Yahnisi', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Bezelyeli Kuzu Yemeği: 1000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Kuzu Yemeği';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Bezelyeli Kuzu Yemeği'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Bezelyeli Kuzu Yemeği', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Bezelyeli Pilav: 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Pilav';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Bezelyeli Pilav'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Bezelyeli Pilav', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Bezelyeli Yoğurt Salatası: 1000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Yoğurt Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Bezelyeli Yoğurt Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Bezelyeli Yoğurt Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Biber Dolması (Etli): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Biber Dolması (Etli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Biber Dolması (Etli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Biber Dolması (Etli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Brokoli Çorbası (Ev Usulü): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Brokoli Çorbası (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Brokoli Çorbası (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Brokoli Çorbası (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Brokolili Tavuk Sote (Sporcu): 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Brokolili Tavuk Sote (Sporcu)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Brokolili Tavuk Sote (Sporcu)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Brokolili Tavuk Sote (Sporcu)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Brüksel Lahanalı Zeytinyağlı: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Brüksel Lahanalı Zeytinyağlı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Brüksel Lahanalı Zeytinyağlı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Brüksel Lahanalı Zeytinyağlı', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Domates Dolması (Etli): 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domates Dolması (Etli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Domates Dolması (Etli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Domates Dolması (Etli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Domates Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domates Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Domates Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Domates Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Domatesli Cacık: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Cacık';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Domatesli Cacık'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Domatesli Patates Yemeği (Etsiz): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Patates Yemeği (Etsiz)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Domatesli Patates Yemeği (Etsiz)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Domatesli Patates Yemeği (Etsiz)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama: 17 satir. su_gram: 3 tarifte (Kırmızı Lahana, Pekmez, Çilekli Yoğurt) null olmali.
-- Ayran'da sut_var = false olmali. isil_asama: 3 soguk tarif + susuz 3 tarif disinda dolu olmali.
select r.ad, length(r.hazirlik_talimati) as uzunluk, su.miktar_gram as su_gram, a.ad as isil_asama,
       exists (select 1 from recete_malzemeleri x join malzemeler m on m.id = x.malzeme_id
               where x.recete_id = r.id and m.ad = 'SÜT (TAM YAĞ)') as sut_var
from receteler r
left join recete_malzemeleri su on su.recete_id = r.id and su.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee'
left join asama_malzemeleri am on am.recete_malzeme_id = su.id
left join recete_asamalari a on a.id = am.asama_id
where r.isletme_id is null and r.ad in ('Ayran (Ev Usulü)', 'Bahar Cacığı', 'Bezelyeli Dana Yahnisi', 'Bezelyeli Kuzu Yemeği', 'Bezelyeli Pilav', 'Bezelyeli Yoğurt Salatası', 'Biber Dolması (Etli)', 'Brokoli Çorbası (Ev Usulü)', 'Brokolili Tavuk Sote (Sporcu)', 'Brüksel Lahanalı Zeytinyağlı', 'Cevizli Kırmızı Lahana Salatası', 'Cevizli Pekmez', 'Çilekli Yoğurt', 'Domates Dolması (Etli)', 'Domates Turşusu', 'Domatesli Cacık', 'Domatesli Patates Yemeği (Etsiz)')
order by r.ad;
