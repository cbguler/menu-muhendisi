-- 136_hazirlik_talimati_parti4.sql
-- 244/245 eksik talimat gorevi, Parti 4: alfabetik 46-60.
-- Su miktarlari yerlesik tariflerle karsilastirmali arastirildi (ozellikle
-- uzun firin pisirmelerinde folyo/kapakla az miktar su teknigi -- kuzu but
-- ve sigir kaburga icin gercek tarif kaynaklariyla dogrudan karsilastirildi).
-- Bahri onayi: 'bilimsel veriye dayali oldugu surece su eklemeyi onayliyorum'.
-- Gramajlar 10 porsiyon icin. Tek transaction; herhangi bir kontrol tutmazsa
-- HICBIR degisiklik yapilmaz. Idempotent.

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
1. Beyni akan soğuk su altında yıkayıp üzerindeki ince zarı (varsa) dikkatle sıyırın.
2. Beyni 15 dakika kadar hafif tuzlu soğuk suda bekletip kanını çıkarın, sonra süzün (bu bekleme aşağıdaki süreye dahil değildir).
3. Fırın kabına yerleştirip zeytinyağı, limon suyu ve tuzla ovun.

**Isıl İşlem**
1. Fırınlama (190°C, 20 dk): 190°C'ye önceden ısıtılmış fırında, üzeri hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken beyin temizlenip baharatlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Fırında Dana Beyin';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Dana Beyin', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 180°C'ye ısıtmaya başlayın.
2. Dana butu kağıt havluyla kurulayın.
3. Sarımsakları ezin, zeytinyağı, tuz, kekik ve karabiberle karıştırın; butun her yüzüne ve varsa bıçakla açtığınız derin kesiklere ovun.

**Isıl İşlem**
1. Fırınlama (180°C, 80 dk): Butu fırın tepsisine yerleştirin, tepsinin dibine 200 ml (200 g) su ekleyin. Tepsiyi alüminyum folyoyla sıkıca kapatıp 180°C'ye önceden ısıtılmış fırında 65 dakika pişirin. Folyoyu açıp üzeri hafif kızarana kadar son 15 dakika folyosuz pişirmeye devam edin. Etin en kalın yerinde iç sıcaklık en az 63°C (orta pişmişlik) olmalı; daha yumuşak bir sonuç için 70°C'ye kadar çıkarabilirsiniz.
2. Son işlemler: Fırından çıkarıp 10 dk dinlendirdikten sonra dilimleyin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir; fırınlama sırasında garnitür hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~70 dk · Toplam ~100 dk$t$
    where isletme_id is null and ad = 'Fırında Dana But';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Dana But', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 190°C'ye ısıtmaya başlayın.
2. Hindi butlarını kağıt havluyla kurulayın.
3. Zeytinyağı, tuz, kekik ve karabiberi karıştırıp butların her yüzüne ovun.

**Isıl İşlem**
1. Fırınlama (190°C, 45 dk): Butları fırın tepsisine yerleştirin, tepsinin dibine 150 ml (150 g) su ekleyin. Tepsiyi folyoyla kapatıp 190°C'ye önceden ısıtılmış fırında 35 dakika pişirin. Folyoyu açıp üzeri renk alana kadar son 10 dakika folyosuz pişirin. Butun en kalın yerinde iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~37 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Fırında Hindi But';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Hindi But', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Kalkanı (pullarından ve iç organlarından temizletilmiş) akan soğuk suda yıkayıp kağıt havluyla kurulayın.
3. Balığın her iki yüzüne çapraz kesikler atın (eşit pişmesi için).
4. Zeytinyağı, limon suyu ve tuzu karıştırıp balığın her yüzüne ve kesiklerin içine sürün; maydanozu ince kıyıp üzerine serpin.

**Isıl İşlem**
1. Fırınlama (200°C, 23 dk): Balığı yağlanmış fırın tepsisine yerleştirin. 200°C'ye önceden ısıtılmış fırında, etin en kalın yerinde çatalla kolayca dağılana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken balık temizlenip baharatlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~18 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Fırında Kalkan';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Kalkan', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 170°C'ye ısıtmaya başlayın.
2. Eti kağıt havluyla kurulayın.
3. Sarımsakları ezin, zeytinyağı, tuz, kekik ve karabiberle karıştırıp etin her yüzüne ovun.

**Isıl İşlem**
1. Fırınlama (170°C, 90 dk): Eti fırın tepsisine yerleştirin, tepsinin dibine 200 ml (200 g) su ekleyin. Tepsiyi folyoyla sıkıca kapatıp 170°C'ye önceden ısıtılmış fırında 75 dakika pişirin. Folyoyu açıp üzeri hafif kızarana kadar son 15 dakika folyosuz pişirin. Et lif lif ayrılacak kıvamda yumuşamalı.
2. Son işlemler: Fırından çıkarıp birkaç dakika dinlendirip parçalayarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir; fırınlama sırasında garnitür/pilav hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~80 dk · Toplam ~110 dk$t$
    where isletme_id is null and ad = 'Fırında Koyun Tandır';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Koyun Tandır', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 180°C'ye ısıtmaya başlayın.
2. Kuzu butu kağıt havluyla kurulayıp bıçakla birkaç yerinden derin kesikler açın.
3. Sarımsakları ezip zeytinyağı, tuz, kekik ve karabiberle karıştırın; harcı kesiklerin içine ve butun her yüzüne ovun.

**Isıl İşlem**
1. Fırınlama (180°C, 90 dk): Butu fırın tepsisine yerleştirin, tepsinin dibine 200 ml (200 g) su ekleyin. Tepsiyi folyoyla sıkıca kapatıp 180°C'ye önceden ısıtılmış fırında 75 dakika pişirin. Folyoyu açıp üzeri kızarana kadar son 15 dakika folyosuz pişirin. Etin en kalın yerinde iç sıcaklık en az 63°C (orta pişmişlik) olmalı.
2. Son işlemler: Fırından çıkarıp 10–15 dk dinlendirdikten sonra dilimleyin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir; fırınlama sırasında garnitür hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~80 dk · Toplam ~110 dk$t$
    where isletme_id is null and ad = 'Fırında Kuzu But (Bütün)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Kuzu But (Bütün)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Patatesleri ve havuçları soyup iri parçalar halinde doğrayın.
3. Pirzolaları kağıt havluyla kurulayın.
4. Zeytinyağı, tuz ve karabiberi karıştırıp hem sebzelere hem pirzolalara sürün.

**Isıl İşlem**
1. Fırınlama (200°C, 65 dk): Sebzeleri fırın kabının tabanına yayın, pirzolaları üzerine yerleştirin. 400 ml (400 g) sıcak suyu kenarlardan ekleyin. Kabı folyoyla kapatıp 200°C'ye önceden ısıtılmış fırında 50 dakika pişirin. Folyoyu açıp pirzolalar ve sebzeler hafif kızarana kadar son 15 dakika folyosuz pişirin. Pirzolanın en kalın yerinde iç sıcaklık en az 63°C olmalı.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken sebzeler doğranıp pirzolalar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~57 dk · Toplam ~85 dk$t$
    where isletme_id is null and ad = 'Fırında Kuzu Pirzola (Sebzeli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Kuzu Pirzola (Sebzeli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 190°C'ye ısıtmaya başlayın.
2. Patatesleri soyup ince dilimler halinde doğrayın.
3. Kuru soğanı küçük küp doğrayın; domatesleri dilimleyin.
4. Zeytinyağında kıymayı ve soğanı suyunu salıp çekene ve renk alana kadar kavurun; tuz ve karabiberi ekleyin.

**Isıl İşlem**
1. Fırınlama (190°C, 40 dk): Fırın kabının tabanına patates dilimlerinin yarısını dizin, üzerine kıymalı harcı yayın, kalan patatesleri üzerine örtün. 200 ml (200 g) sıcak suyu kenarlardan gezdirin, üzerine domates dilimlerini yerleştirin. Kabı folyoyla kapatıp 190°C'ye önceden ısıtılmış fırında 30 dakika pişirin. Folyoyu açıp patatesler yumuşayıp üzeri hafif renk alana kadar son 10 dakika folyosuz pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kıyma kavrulup patatesler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~32 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Fırında Patatesli Kıyma';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Patatesli Kıyma', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 170°C'ye ısıtmaya başlayın.
2. Kaburgaları kağıt havluyla kurulayıp tuz ve karabiberle ovun.
3. Kuru soğanı ve havucu iri doğrayın; domatesleri dilimleyin.

**Isıl İşlem**
1. Fırınlama (170°C, 110 dk): Sebzeleri fırın kabının tabanına yayın, kaburgaları üzerine yerleştirin. 250 ml (250 g) sıcak suyu ekleyin. Kabı folyoyla veya kapağıyla sıkıca kapatıp 170°C'ye önceden ısıtılmış fırında et kemikten kolayca ayrılana kadar (~100 dk) pişirin. Son 10 dakika folyoyu açıp üzeri hafif kızarana kadar pişirin.
2. Son işlemler: Fırından çıkarıp birkaç dakika dinlendirip servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken sebzeler doğranabilir; uzun pişirme süresinde başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~100 dk · Toplam ~130 dk$t$
    where isletme_id is null and ad = 'Fırında Sığır Kaburga';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Sığır Kaburga', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Kabak ve havuçları ince yarım ay dilimler halinde doğrayın.
3. Somon parçalarını kağıt havluyla kurulayın.

**Isıl İşlem**
1. Fırınlama (200°C, 20 dk): Sebzeleri yağlanmış fırın tepsisine yayın, üzerine zeytinyağının yarısını ve tuzu gezdirin. Somon parçalarını sebzelerin üzerine yerleştirin, kalan zeytinyağı ve tuzu somonlara sürün. 200°C'ye önceden ısıtılmış fırında somonun içi henüz parlak pembe kalacak, çatalla kolayca dağılacak kıvama gelene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Fırında Somon Sebzeli';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Somon Sebzeli', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 210°C'ye ısıtmaya başlayın.
2. Kanatları kağıt havluyla iyice kurulayın (kuru yüzey daha çıtır olur).
3. Sarımsakları ezip zeytinyağı, tuz ve pul biberle karıştırın; kanatlara sürün.

**Isıl İşlem**
1. Fırınlama (210°C, 30 dk): Kanatları tel ızgaralı bir fırın tepsisine, aralıklı ve tek kat dizin. 210°C'ye önceden ısıtılmış fırında, arada bir çevirerek her yüzü çıtır ve altın rengi olana kadar pişirin. En kalın kanatta iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kanatlar baharatlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~22 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Fırında Tavuk Kanat';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Fırında Tavuk Kanat', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Rokayı ayıklayıp yıkayın, iyice süzdürün.
2. Greyfurtu soyup zarlarından ayırarak fileto şeklinde dilimleyin (acılık yapan beyaz zarları temizleyin).
3. Rokayı, greyfurt dilimlerini, zeytinyağını ve tuzu bir kapta nazikçe karıştırın; hemen servis edin (roka bekleyince pörsür).

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Roka yıkanırken greyfurt dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Greyfurtlu Roka Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Greyfurtlu Roka Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Servis tepsisinin tabanına ilk güllaç yaprağını sert kısmı alta gelecek şekilde yerleştirin.
2. Cevizleri iri kırın.

**Isıl İşlem**
1. Süt Isıtma (~80°C, tencerede, 20 dk): Sütü ve şekeri bir tencerede, şeker eriyene kadar karıştırarak ısıtın; kaynatmadan, hafif buğulanmaya başlayınca ocaktan alın.
2. Son işlemler: Sıcak sütü kepçeyle güllaç yapraklarının üzerine, her yaprak iyice ıslanacak şekilde azar azar dökün ve yaprakları teker teker dizmeye devam edin. Son yaprağı da ıslattıktan sonra üzerine kalan sütü gezdirin. Süt tamamen çekilip yapraklar yumuşayana kadar (~10 dk) oda sıcaklığında bekletin, ardından buzdolabında soğutun (soğutma süresi özete dahil değildir). Servis ederken üzerine kırılmış cevizi serpin.

**PARALEL YAPILABİLİRLİK:** Süt ısıtılırken cevizler kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Güllaç (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Güllaç (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Marulu yıkayıp süzün, elinizle veya bıçakla parçalayın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 12 dk): Tencereye 1,2 litre (1200 g) su koyup kaynatın. Yumurtaları nazikçe suya bırakıp kaynamaya devam eden suda 9 dk (tam katı kıvam için) haşlayın.
2. Son işlemler: Yumurtaları hemen soğuk suya alıp soyun, iri doğrayın. Marul, zeytinyağı ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken marul hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~6 dk · Pasif bekleme ~9 dk · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Haşlanmış Yumurta Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Haşlanmış Yumurta Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, havucu ekleyip 2–3 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp havuç tamamen yumuşayana kadar (~17–18 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Havuç Çorbası (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Havuç Çorbası (Bahar)', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Fırında Dana But: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Dana But';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Dana But'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Dana But', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Fırında Hindi But: 150 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Hindi But';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Hindi But'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 150) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Hindi But', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Fırında Koyun Tandır: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Koyun Tandır';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Koyun Tandır'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Koyun Tandır', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Fırında Kuzu But (Bütün): 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Kuzu But (Bütün)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Kuzu But (Bütün)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Kuzu But (Bütün)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Fırında Kuzu Pirzola (Sebzeli): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Kuzu Pirzola (Sebzeli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Kuzu Pirzola (Sebzeli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Kuzu Pirzola (Sebzeli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Fırında Patatesli Kıyma: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Patatesli Kıyma';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Patatesli Kıyma'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Patatesli Kıyma', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Fırında Sığır Kaburga: 250 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Sığır Kaburga';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Fırında Sığır Kaburga'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 250) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Fırında Sığır Kaburga', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Haşlanmış Yumurta Salatası: 1200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Haşlanmış Yumurta Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Haşlanmış Yumurta Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Haşlanmış Yumurta Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Havuç Çorbası (Bahar): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç Çorbası (Bahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Havuç Çorbası (Bahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Havuç Çorbası (Bahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 15 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Fırında Dana Beyin', 'Fırında Dana But', 'Fırında Hindi But', 'Fırında Kalkan', 'Fırında Koyun Tandır', 'Fırında Kuzu But (Bütün)', 'Fırında Kuzu Pirzola (Sebzeli)', 'Fırında Patatesli Kıyma', 'Fırında Sığır Kaburga', 'Fırında Somon Sebzeli', 'Fırında Tavuk Kanat', 'Greyfurtlu Roka Salatası', 'Güllaç (Ev Usulü)', 'Haşlanmış Yumurta Salatası', 'Havuç Çorbası (Bahar)') order by ad;

-- Dogrulama 2: 9 satir; hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Fırında Dana But', 'Fırında Hindi But', 'Fırında Koyun Tandır', 'Fırında Kuzu But (Bütün)', 'Fırında Kuzu Pirzola (Sebzeli)', 'Fırında Patatesli Kıyma', 'Fırında Sığır Kaburga', 'Haşlanmış Yumurta Salatası', 'Havuç Çorbası (Bahar)')
order by r.ad;
