-- 135_hazirlik_talimati_parti3.sql
-- 244/245 eksik talimat gorevi, Parti 3: alfabetik 31-45.
-- Su miktarlari yerlesik/yaygin tariflerle karsilastirmali arastirilip
-- Bahri onayiyla eklendi (bkz. PROJE_NOTLARI.md). Gramajlar 10 porsiyon icin.
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

    ---------------- A) HAZIRLIK TALIMATLARI ----------------
    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Domatesleri yıkayıp kabuklarını soyun; rendenin iri tarafıyla rendeleyin veya küçük küp doğrayın.
2. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 17 dk): Tereyağını tencerede eritip domatesi 3–4 dk kavurun. Tavuk suyu ve su karışımını ekleyin; kaynayınca şehriyeyi ve tuzu ekleyip şehriye yumuşayana kadar (~12–13 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, domates kavrulurken ayrı bir kapta ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Domatesli Şehriye Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Domatesli Şehriye Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Hazır ekmek kadayıfını fırın/servis tepsisine, parçaları üst üste binmeyecek şekilde tek kat yayın.
2. Şeker ve 450 ml (450 g) suyu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Şerbet Pişirme (~100°C, tencerede, 30 dk): Şeker ve suyu bir tencerede kaynatın; şeker tamamen eriyene kadar (~10 dk) karıştırarak kaynatmaya devam edin. Sıcak şerbeti kepçeyle azar azar, tüm yüzeye eşit dağılacak şekilde kadayıfın üzerine dökün. Şerbetin tamamen çekmesi için kadayıfı 15–20 dk kendi halinde bekletin.
2. Son işlemler: Kadayıf oda sıcaklığına gelince üzerine kaymağı eşit şekilde yayın, dilimleyip servis edin.

**PARALEL YAPILABİLİRLİK:** Kadayıf tepsiye yayılırken şerbet ayrı ocakta kaynatılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Ekmek Kadayıfı (Kaymaklı)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ekmek Kadayıfı (Kaymaklı)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Elmaları yıkayıp soyun, çekirdek evlerini çıkarın ve iri dilimler veya küp halinde doğrayın; kararmaması için pişirmeye kadar soğuk suda bekletin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 17 dk): 800 ml (800 g) suyu ve şekeri bir tencerede kaynatın. Elmaları ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak elmalar yumuşayıp diri kalacak şekilde pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), elmaları kendi şerbetiyle birlikte soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Elma Kompostosu (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Elma Kompostosu (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Elmaları yıkayın, çekirdek evlerini çıkarıp küçük küp doğrayın.
2. Süzme yoğurdu şekerle çırpın.
3. Cevizleri iri kırın.
4. Doğranmış elmaları yoğurt karışımına ekleyip nazikçe karıştırın; cevizleri servis sırasında üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Ceviz kırılırken elma doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Elmalı Cevizli Bahar Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Elmalı Cevizli Bahar Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Enginarları temizleyin: sert dış yapraklarını ve içindeki tüylü kısmı (ayşekadın) çıkarıp kalan etli kısımlarını dilimleyin; kararmaması için limonlu suda bekletin.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Pirinci yıkayıp süzün.
4. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 28 dk): Tereyağında soğanı 3–4 dk kavurun. Enginar ve pirinci ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp enginar ve pirinç tamamen yumuşayana kadar (~20 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin, limon suyunu ekleyip karıştırın.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler hazırlanırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Enginar Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginar Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Enginarları temizleyin: sert dış yapraklarını çıkarıp içindeki tüylü kısmı (ayşekadın) bir kaşıkla oyarak çıkarın, doldurma için boşluk bırakın. Kararmaması için limonlu suda bekletin.
2. Pirinci yıkayıp süzün, kuru soğanı rendeleyin.
3. Kıyma, pirinç, soğan, tuz ve limon suyunun yarısını harmanlayın.
4. Harcı enginarların oyulan kısmına doldurun.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 35 dk): Doldurulmuş enginarları tencereye dik dizin. 600 ml (600 g) sıcak suyu ve kalan limon suyunu kenarlardan ekleyin; su enginarların yaklaşık yarısına gelmelidir. Kapağı kapatın; kaynayınca ateşi kısıp pirinç tamamen pişip enginarlar yumuşayana kadar pişirin.
2. Son işlemler: Tencerede birkaç dakika dinlendirip servis tabağına alın.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~27 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Enginar Dolması (Etli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginar Dolması (Etli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Enginar kalplerini süzüp dilimleyin (dondurulmuş veya konserve kullanılıyorsa iyice süzdürün).
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip enginar kalplerini 2–3 dk çevirin. Pirinci ekleyip taneler şeffaflaşana kadar 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin ve servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, pirinç yıkanırken ısıtılabilir; pilav kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Enginar Kalpli Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginar Kalpli Pilav', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2–3 cm kuşbaşı doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Enginar kalplerini süzüp dilimleyin.

**Isıl İşlem**
1. Güveç Pişirme (~90°C, güveç kabında veya tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı 3–4 dk kavurun, tavukları ekleyip her yüzü renk alana kadar 5–6 dk çevirin. Enginar kalplerini, tuzu ve karabiberi ekleyin. 200 ml (200 g) sıcak suyu ekleyin; kapağı kapatıp tavuk ve enginar tamamen yumuşayana kadar kısık ateşte pişirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Enginar Kalpli Tavuk Güveç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginar Kalpli Tavuk Güveç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Enginarları temizleyin: sert dış yapraklarını ve tüylü iç kısmını (ayşekadın) çıkarıp kalan etli kısımlarını dilimleyin; kararmaması için limonlu suda bekletin.
2. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 20 dk): Tencereye 1,5 litre (1500 g) su koyup kaynatın. Enginarları ekleyip çatal rahatça batana kadar (~15 dk) haşlayın.
2. Son işlemler: Süzüp soğuk suya alarak pişmeyi durdurun, iyice süzdürün. Sosla karıştırıp soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Sos, su kaynarken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Enginar Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginar Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu kol etini kemik ve fazla yağından ayırıp 2–2,5 cm kuşbaşı doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Enginarları temizleyin, dilimleyip limonlu suda bekletin.
5. 1,5 litre (1500 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Yahni Pişirme (~95°C, tencerede kısık ateşte, 45 dk): Zeytinyağında etleri yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk, domatesi ekleyip 2–3 dk daha kavurun. 1,5 litre sıcak suyu ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar pişirin. Pişirmenin son 15 dakikasında enginar, tuz, karabiber ve limon suyunu ekleyin; et ve enginar tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; yahni kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~35 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Enginarlı Kuzu Yahnisi';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginarlı Kuzu Yahnisi', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Enginarları temizleyin: sert dış yapraklarını ve tüylü iç kısmını çıkarıp dilimleyin; kararmaması için limonlu suda bekletin.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 20 dk): 1,2 litre (1200 g) suyu kaynatın, enginarları ekleyip çatal rahatça batana kadar (~15 dk) haşlayın. Süzüp soğuk suya alarak pişmeyi durdurun, iyice süzdürün.
2. Son işlemler: Soğumuş enginarı sarımsaklı yoğurtla karıştırıp soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Sarımsaklı yoğurt, haşlama suyu kaynarken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Enginarlı Yoğurt';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Enginarlı Yoğurt', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün.
2. Et suyu ile 700 ml (700 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 15 dk): Et suyu ve su karışımını kaynatın. Pirinci ve tuzu ekleyip pirinç yumuşayana kadar (~10 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Sıvı kaynarken pirinç yıkanabilir; sade bir çorba olduğu için başka paralel fırsat sınırlı.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~10 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Et Suyu Çorbası (Sade)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Et Suyu Çorbası (Sade)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat (tercihen bir gece) önce bol soğuk suda ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Kuzu kol etini 2–2,5 cm kuşbaşı doğrayın.

**Isıl İşlem**
1. Kaynatma/Pişirme (~100°C, tencerede, 55 dk): Zeytinyağında soğanı 3–4 dk kavurun, eti ekleyip renk alana kadar 5–6 dk çevirin. Domatesi ekleyip 3 dk pişirin. Süzülmüş fasulyeyi ekleyip 1–2 dk çevirin. 2,2 litre (2200 g) sıcak su ile tuzu ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye ve et tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su, sebzeler ve et doğranırken ısıtılabilir; pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~45 dk · Toplam ~70 dk$t$
    where isletme_id is null and ad = 'Etli Kuru Fasulye (Kış)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Etli Kuru Fasulye (Kış)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2 cm kuşbaşı doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Fındıkları kabaca kırın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp soğanı 2–3 dk kavurun. Tavukları ekleyip her yüzü renk alana kadar 6–7 dk soteleyin. Tuz ve karabiberi ekleyin, fındıkları serpip 2 dk daha çevirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Sote sürekli takip gerektirdiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Fındıklı Tavuk Sote (Karadeniz Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fındıklı Tavuk Sote (Karadeniz Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Tavuğu kağıt havluyla için için kurulayın (kuru yüzey daha iyi renk alır).
3. Limonu ikiye kesin; yarısının suyunu sıkıp zeytinyağı, tuz, kekik ve karabiberle karıştırın, tavuğun her yerine ve deri altına ovun. Kalan limon yarısını tavuğun içine yerleştirin.
4. Tavuğun bacaklarını (varsa pişirme ipiyle) bağlayın — eşit pişmesine yardımcı olur.

**Isıl İşlem**
1. Fırınlama (200°C, 70 dk): Tavuğu göğüs kısmı üste gelecek şekilde fırın tepsisine yerleştirin. 200°C'ye önceden ısıtılmış fırında, arada bir kendi yağıyla üzerini gezdirerek 70 dakika pişirin. Butun en kalın yerinde, kemiğe değmeden, iç sıcaklık en az 75°C olmalı ve suyu berrak akmalı.
2. Son işlemler: Fırından çıkarıp 10 dk dinlendirdikten sonra parçalayıp servis edin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir; fırınlama sırasında garnitür veya yan yemek hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~62 dk · Toplam ~90 dk$t$
    where isletme_id is null and ad = 'Fırında Bütün Tavuk (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Bütün Tavuk (Ev Usulü)', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Domatesli Şehriye Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Şehriye Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Domatesli Şehriye Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Domatesli Şehriye Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Ekmek Kadayıfı (Kaymaklı): 450 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ekmek Kadayıfı (Kaymaklı)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Ekmek Kadayıfı (Kaymaklı)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 450) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Ekmek Kadayıfı (Kaymaklı)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Elma Kompostosu (Ev Usulü): 800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Elma Kompostosu (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Elma Kompostosu (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Elma Kompostosu (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Enginar Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Enginar Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Enginar Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Enginar Dolması (Etli): 600 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Dolması (Etli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Enginar Dolması (Etli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 600) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Enginar Dolması (Etli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Enginar Kalpli Tavuk Güveç: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Kalpli Tavuk Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Enginar Kalpli Tavuk Güveç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Enginar Kalpli Tavuk Güveç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Enginar Salatası: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Enginar Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Enginar Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Enginarlı Kuzu Yahnisi: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginarlı Kuzu Yahnisi';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Enginarlı Kuzu Yahnisi'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Enginarlı Kuzu Yahnisi', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Enginarlı Yoğurt: 1200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginarlı Yoğurt';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Enginarlı Yoğurt'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Enginarlı Yoğurt', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Et Suyu Çorbası (Sade): 700 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Et Suyu Çorbası (Sade)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Et Suyu Çorbası (Sade)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 700) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Et Suyu Çorbası (Sade)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Etli Kuru Fasulye (Kış): 2200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Etli Kuru Fasulye (Kış)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Etli Kuru Fasulye (Kış)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 2200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Etli Kuru Fasulye (Kış)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 15 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Domatesli Şehriye Çorbası', 'Ekmek Kadayıfı (Kaymaklı)', 'Elma Kompostosu (Ev Usulü)', 'Elmalı Cevizli Bahar Salatası', 'Enginar Çorbası', 'Enginar Dolması (Etli)', 'Enginar Kalpli Pilav', 'Enginar Kalpli Tavuk Güveç', 'Enginar Salatası', 'Enginarlı Kuzu Yahnisi', 'Enginarlı Yoğurt', 'Et Suyu Çorbası (Sade)', 'Etli Kuru Fasulye (Kış)', 'Fındıklı Tavuk Sote (Karadeniz Usulü)', 'Fırında Bütün Tavuk (Ev Usulü)') order by ad;

-- Dogrulama 2: 11 satir; hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Domatesli Şehriye Çorbası', 'Ekmek Kadayıfı (Kaymaklı)', 'Elma Kompostosu (Ev Usulü)', 'Enginar Çorbası', 'Enginar Dolması (Etli)', 'Enginar Kalpli Tavuk Güveç', 'Enginar Salatası', 'Enginarlı Kuzu Yahnisi', 'Enginarlı Yoğurt', 'Et Suyu Çorbası (Sade)', 'Etli Kuru Fasulye (Kış)')
order by r.ad;
