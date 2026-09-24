-- 140_hazirlik_talimati_parti7.sql
-- 244/245 eksik talimat gorevi, Parti 7: alfabetik 121-150.
-- ONEMLI: bu partiden 5 tarif (Lahana Dolması, Limonlu Fırın Levrek,
-- Madımaklı Kavurma, Midye Dolma, Mısırlı Tavuk Sote) 139 numarali
-- migration'la TEMIZLENEN mukerrer-asama tariflerindendi -- 139 BU
-- DOSYADAN ONCE calistirilmis OLMALI, yoksa asagidaki su eklemeleri
-- (isil asama sayisi=1 kontrolu) FAIL verir.
-- Su miktarlari yerlesik tariflerle karsilastirmali arastirildi.
-- Gramajlar 10 porsiyon icin. Tek transaction; herhangi bir kontrol
-- tutmazsa HICBIR degisiklik yapilmaz. Idempotent.

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
1. Lahanayı iri parçalar veya şeritler halinde doğrayın.
2. Havuçları soyup ince çubuklar halinde kesin.
3. Sarımsakları soyun.
4. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin.
2. Son işlemler: Lahana ve havucu sarımsakla birlikte kavanoza sıkıca bastırarak dizin. Ilımış salamurayı sebzelerin üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Sebze ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kış Lahana Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kış Lahana Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kızılcıkları ayıklayıp yıkayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 14 dk): 500 ml (500 g) suyu ve şekeri bir tencerede kaynatın. Kızılcıkları ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak kızılcıklar yumuşayıp çatlamaya başlayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~11 dk · Pasif bekleme ~9 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Kızılcık Kompostosu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kızılcık Kompostosu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Konserve bezelyeyi süzüp durulayın.
2. 3,5 litre (3500 g) suyu tencereye koyup kaynatmaya başlayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 15 dk): Kaynayan suya tuz ekleyip makarnayı paket üzerindeki süreden 1 dk az haşlayın (al dente). Süzmeden 1–2 dk önce bezelyeyi de aynı suya ekleyip birlikte ısıtın. Süzün.
2. Son işlemler: Süzülen makarna ve bezelyeyi eritilmiş tereyağıyla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken bezelye süzülebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Konserve Bezelyeli Makarna';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Konserve Bezelyeli Makarna', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat (tercihen bir gece) önce bol soğuk suda ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Maydanozu ince kıyın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 15 dk): Tencereye 1,8 litre (1800 g) su koyup kaynatın. Islatılmış fasulyeyi ekleyip taneler yumuşayana kadar (ıslatma kalitesine göre süre değişebilir) haşlayın.
2. Son işlemler: Fasulyeyi süzüp ılımaya bırakın (soğuma süresi özete dahil değildir). Soğan, maydanoz, zeytinyağı, limon suyu ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken soğan ve maydanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~10 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Kuru Fasulye Piyazı (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuru Fasulye Piyazı (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru kayısıları isterseniz ikiye bölün.
2. Kuru üzümü ayıklayıp durulayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 20 dk): 1,2 litre (1200 g) suyu ve şekeri bir tencerede kaynatın. Kuru kayısı ve kuru üzümü ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak meyveler yumuşayıp şerbeti çekmeye başlayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kuru Kayısılı Kış Kompostosu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuru Kayısılı Kış Kompostosu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru üzümü ayıklayıp durulayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 14 dk): 800 ml (800 g) suyu ve şekeri bir tencerede kaynatın. Kuru üzümü ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak üzümler kabarıp yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~11 dk · Pasif bekleme ~9 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Kuru Üzümlü Komposto';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuru Üzümlü Komposto', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuşkonmazların sert alt uçlarını kırın, geri kalanını 2–3 cm parçalar halinde kesin.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 20 dk): Tereyağında soğanı 3–4 dk kavurun, kuşkonmazı ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp kuşkonmaz tamamen yumuşayana kadar (~13–14 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kuşkonmaz Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuşkonmaz Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuşkonmazların sert alt uçlarını kırın.
2. Zeytinyağı, limon suyu, ezilmiş sarımsak ve tuzu karıştırarak sosu hazırlayın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 8 dk): Tencereye 1,5 litre (1500 g) su koyup kaynatın. Kuşkonmazları ekleyip diri kalacak şekilde 3–4 dk haşlayın.
2. Son işlemler: Süzüp hemen soğuk suya alarak pişmeyi durdurun, iyice süzdürün. Sosla karıştırıp ılık veya soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Sos, su kaynarken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~3 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Kuşkonmaz Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuşkonmaz Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bonfileleri kağıt havluyla kurulayın, oda sıcaklığına gelmesini bekleyin.
2. Kuşkonmazların sert alt uçlarını kırın.
3. Sarımsakları ince kıyın.

**Isıl İşlem**
1. Sote (yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp bonfileleri her yüzü 3–4 dk olacak şekilde çevirerek mühürleyin (en kalın yerinde iç sıcaklık en az 55–60°C, damak zevkine göre ayarlayın); tavadan alıp dinlenmeye bırakın. Aynı tavada sarımsağı 1 dk kavurun, kuşkonmazı ekleyip 100 ml (100 g) su ile birlikte kapağı kapatarak 3–4 dk buharda pişirin. Tuz ve karabiberi ekleyip kapağı açık 1–2 dk çevirin.
2. Son işlemler: Bonfileleri dilimleyip kuşkonmazla birlikte servis edin.

**PARALEL YAPILABİLİRLİK:** Bonfile dinlenirken kuşkonmaz aynı tavada pişirilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kuşkonmazlı Dana Bonfile';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuşkonmazlı Dana Bonfile', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu kol etini 2 cm kuşbaşı doğrayın.
2. Kırmızı mercimeği ayıklayıp yıkayın.
3. Kuru soğanı soyup küçük küp doğrayın.
4. 1,5 litre (1500 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede kısık ateşte, 33 dk): Zeytinyağında eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk kavurun. 1,5 litre sıcak suyu ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar (~15 dk) pişirin. Mercimeği, tuzu ve karabiberi ekleyip mercimek dağılıp yumuşayana kadar (~10 dk) pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; yemek kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Kuzu Etli Kırmızı Mercimek Yemeği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kuzu Etli Kırmızı Mercimek Yemeği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Lahananın göbeğini bıçakla oyup çıkarın. Büyük bir tencerede kaynar tuzlu suda yaprakları teker teker yumuşayıp ayrılana kadar (aşağıdaki süreye dahil değildir) haşlayıp soğuk suya alın; kalın orta damarları inceltin.
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Kıyma, pirinç, soğan, tuz ve karabiberi harmanlayın.
4. Harcı yapraklara paylaştırıp sıkıca sarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 45 dk): Sarma dolmaları tencereye sıkı dizin. 600 ml (600 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısıp pirinç tamamen pişip yapraklar yumuşayana kadar pişirin.
2. Son işlemler: Dolmaları tencerede 5–10 dk dinlendirip servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~35 dk · Toplam ~70 dk$t$
    where isletme_id is null and ad = 'Lahana Dolması (Etli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Lahana Dolması (Etli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Lahanayı ince şeritler halinde doğrayıp tuzla ovarak birkaç dakika bekletin; hafif yumuşar.
2. Havuçları rendenin iri tarafıyla rendeleyin.
3. Zeytinyağı ve limon suyunu çırparak sosu hazırlayın.
4. Lahana ve havucu sosla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Lahana tuzla beklerken havuç rendelenip sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Lahana Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Lahana Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Kuru soğanı ince halkalar halinde dilimleyip fırın kabının tabanına yayın.
3. Levreği (temizletilmiş, pullarından arındırılmış) yıkayıp kağıt havluyla kurulayın, her iki yüzüne çapraz kesikler atın.
4. Limonu dilimleyin; zeytinyağı, tuz ve karabiberi karıştırın.

**Isıl İşlem**
1. Fırınlama (200°C, 28 dk): Balıkları soğan yatağının üzerine yerleştirin, zeytinyağı karışımını sürüp limon dilimlerini balıkların üzerine ve kesiklerin içine yerleştirin. 200°C'ye önceden ısıtılmış fırında, etin en kalın yerinde çatalla kolayca dağılana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken balık ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~22 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Limonlu Fırın Levrek';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Limonlu Fırın Levrek', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları rendenin iri tarafıyla rendeleyin.
2. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.
3. Havuçları sosla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Havuç rendelenirken sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Limonlu Zeytinyağlı Havuç Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Limonlu Zeytinyağlı Havuç Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Madımakı ayıklayıp toprağı gidene kadar bol suda birkaç kez yıkayın, süzüp iri kıyın.
2. Kuzu kol etini 1,5–2 cm kuşbaşı doğrayın.
3. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta-yüksek ateş, tencerede, 23 dk): Tereyağında eti suyunu salıp çekene ve renk alana kadar 10–12 dk kavurun. Soğanı ekleyip 3–4 dk kavurun. Madımakı ekleyin, tuz ve karabiberi serpin; madımak pörsüyüp suyunu salıp yumuşayana kadar (~8–9 dk) karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken madımak yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~8 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Madımaklı Kavurma';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Madımaklı Kavurma', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Mandalinaları soyup zarlarından mümkün olduğunca ayırın, dilimler halinde ayırın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 14 dk): 800 ml (800 g) suyu ve şekeri bir tencerede kaynatın. Mandalina dilimlerini ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak 5 dk kadar hafifçe pişirin (fazla pişirmeyin, dağılabilir).
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~11 dk · Pasif bekleme ~9 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Mandalina Kompostosu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mandalina Kompostosu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Domatesleri küçük küp doğrayın; suyunu ayrı bir kapta biriktirin.
2. Maydanozu ince kıyın.
3. İnce bulguru geniş bir kaba alın.

**Isıl İşlem**
1. Bulgur Haşlama (~90°C, kaseye kaynar su dökerek, 10 dk): 500 ml (500 g) suyu kaynatıp domates suyuyla karıştırın, sıcakken bulgurun üzerine dökün. Kabı kapatıp bulgur suyunu tamamen çekip yumuşayana kadar (~5 dk) demlenmeye bırakın.
2. Son işlemler: Bulguru çatalla havalandırıp domates, maydanoz, zeytinyağı, limon suyu ve tuzla karıştırın.

**PARALEL YAPILABİLİRLİK:** Su kaynarken domates ve maydanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~5 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Maydanozlu Bulgur Salatası (Kısır)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Maydanozlu Bulgur Salatası (Kısır)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru soğanı ve domatesi küçük küp doğrayın.
2. Maydanozu ince kıyın.
3. Kırmızı mercimeği ayıklayıp yıkayın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 25 dk): 750 ml (750 g) suyu kaynatın, mercimeği ekleyip tuzla birlikte suyunu çekip pürüzsüzce dağılana kadar (~15–17 dk) pişirin.
2. Son işlemler: Ocaktan alırken sıcak mercimeğin üzerine ince bulguru serpin, kapağı kapatıp 10 dk demlenmeye bırakın (bulgur kendi buharıyla yumuşar). Zeytinyağında soğanı kavurup domates salçası kıvamına gelene kadar domatesle pişirin, mercimekli karışıma ekleyin. Maydanoz ve limon suyunu ekleyip yoğurun, ceviz büyüklüğünde şekiller verin.

**PARALEL YAPILABİLİRLİK:** Mercimek demlenirken soğan-domates sotesi ayrı tavada hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~17 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Mercimek Köftesi (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mercimek Köftesi (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bulguru süzgeçte durulayıp süzün.
2. Yeşil mercimeği ayıklayıp yıkayın.
3. Kuru soğanı küçük küp doğrayın.
4. Tavuk suyu ile 300 ml (300 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun. Mercimeği ekleyip 2 dk çevirin. Sıcak sıvının yarısını ekleyip mercimek yarı yumuşayana kadar (~8–10 dk) pişirin. Bulguru ve kalan sıvıyı, tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak suyunu çekene kadar (~10 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebze ve tahıllar hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Mercimekli Bulgur Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mercimekli Bulgur Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Marul ve rokayı ayıklayıp yıkayın, iyice süzdürün, elinizle parçalayın.
2. Turpları ince dilimleyin.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın; servisten hemen önce yeşilliklerle karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yeşillikler süzülürken sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Mevsim Yeşillik Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mevsim Yeşillik Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Midyeleri kabuklarını çizmeden, fırçayla ovarak iyice temizleyin; kabuklarını bir bıçakla menteşe kısmından hafifçe aralayın (koparmadan).
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Zeytinyağında soğanı 3–4 dk kavurun, pirinci ve tuzu ekleyip 1–2 dk çevirin.
4. Harcı, pirincin şişme payını düşünerek midyelerin içine kaşıkla doldurun ve kabuklarını kapatın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 40 dk): Doldurulmuş midyeleri tencereye üst üste, sıkı dizin. 300 ml (300 g) sıcak suyu ekleyin (midyeler de pişerken kendi suyunu bırakır). Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısıp pirinç tamamen pişene kadar buharda pişirin.
2. Son işlemler: Midyeleri tencerede birkaç dakika dinlendirip soğuk veya ılık, limonla servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~30 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Midye Dolma (Pilavlı)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Midye Dolma (Pilavlı)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Konserve mısırı süzüp durulayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 20 dk): Tereyağında soğanı 3–4 dk kavurun, mısırı ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp 12–13 dk pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin (isterseniz bir miktar mısır tanesini bütün bırakabilirsiniz).

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Mısır Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mısır Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Konserve mısırı süzüp durulayın.
2. Marulu ayıklayıp yıkayın, elinizle parçalayın.
3. Havuçları rendeleyin.
4. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın; servisten hemen önce karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Sebzeler hazırlanırken sos karıştırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Mısırlı Salata';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mısırlı Salata', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2 cm kuşbaşı doğrayın.
2. Kırmızı biberi çekirdeklerinden ayıklayıp iri doğrayın.
3. Konserve mısırı süzüp durulayın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp tavukları tavayı doldurmadan her yüzü renk alana kadar soteleyin (~6–7 dk). Biberi ekleyip 3–4 dk çevirin. Mısırı, tuz ve karabiberi ekleyip 4–5 dk daha pişirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Sote sürekli takip gerektirdiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Mısırlı Tavuk Sote';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mısırlı Tavuk Sote', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Konserve mısırı süzüp durulayın.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip mısırı 1–2 dk çevirin. Pirinci ekleyip taneler şeffaflaşana kadar 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, pirinç yıkanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Mısırlı Yaz Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mısırlı Yaz Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinç ununu birkaç kaşık soğuk sütle pürüzsüz bir bulamaç haline getirin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 22 dk): Kalan sütü ve şekeri bir tencerede ısıtın. Kaynamaya yakın gelince pirinç unu bulamacını azar azar ekleyip sürekli karıştırarak kıvam koyulaşana kadar (~12–15 dk) pişirin.
2. Son işlemler: Servis kaplarına paylaştırıp üzerini streç filmle kapatarak kabuk bağlamasını önleyin, oda sıcaklığında ılıyınca buzdolabına kaldırıp soğutun (soğutma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Bulamaç, süt ısıtılırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~7 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Muhallebi (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Muhallebi (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Mung fasulyesini ayıklayıp yıkayın.
2. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
3. Kuru soğanı küçük küp doğrayın.
4. 1 litre (1000 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun. Mung fasulyesini ekleyip 2 dk çevirin. Sıcak suyun yarısını ekleyip fasulye yarı yumuşayana kadar (~8 dk) pişirin. Pirinci, kalan suyu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak suyunu çekene kadar (~12 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Su, fasulye ve pirinç hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Mung Fasulyeli Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Mung Fasulyeli Pilav', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Muzları soyup dilimleyin.
2. Elmaları yıkayıp çekirdek evlerini çıkarın, küçük küp doğrayın.
3. Portakalları soyup zarlarından ayırarak fileto şeklinde dilimleyin.
4. Meyveleri bir kapta şekerle nazikçe karıştırın; hemen servis edin (muz kararmadan).

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Meyveler sırayla hazırlanıp aynı kapta biriktirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Muzlu Meyve Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Muzlu Meyve Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Muzları soyup dilimleyin.
2. Süzme yoğurdu şekerle çırpın.
3. Muzların çoğunu yoğurda ekleyip nazikçe karıştırın; kalanını servis sırasında üzerine dizin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yoğurt çırpılırken muzlar dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Muzlu Yoğurt (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Muzlu Yoğurt (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bulguru süzgeçte durulayıp süzün.
2. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip bulguru 2 dk kavurun. Sıcak tavuk suyunu, kuru naneyi ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak bulgur suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, bulgur yıkanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Naneli Bulgur Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Naneli Bulgur Pilavı', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Kış Lahana Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kış Lahana Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kış Lahana Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kış Lahana Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kızılcık Kompostosu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kızılcık Kompostosu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kızılcık Kompostosu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kızılcık Kompostosu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Konserve Bezelyeli Makarna: 3500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Konserve Bezelyeli Makarna';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Konserve Bezelyeli Makarna'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 3500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Konserve Bezelyeli Makarna', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuru Fasulye Piyazı (Ev Usulü): 1800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuru Fasulye Piyazı (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuru Fasulye Piyazı (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuru Fasulye Piyazı (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuru Kayısılı Kış Kompostosu: 1200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuru Kayısılı Kış Kompostosu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuru Kayısılı Kış Kompostosu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuru Kayısılı Kış Kompostosu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuru Üzümlü Komposto: 800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuru Üzümlü Komposto';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuru Üzümlü Komposto'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuru Üzümlü Komposto', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuşkonmaz Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuşkonmaz Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuşkonmaz Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuşkonmaz Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuşkonmaz Salatası: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuşkonmaz Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuşkonmaz Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuşkonmaz Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuşkonmazlı Dana Bonfile: 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuşkonmazlı Dana Bonfile';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuşkonmazlı Dana Bonfile'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuşkonmazlı Dana Bonfile', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kuzu Etli Kırmızı Mercimek Yemeği: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuzu Etli Kırmızı Mercimek Yemeği';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kuzu Etli Kırmızı Mercimek Yemeği'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kuzu Etli Kırmızı Mercimek Yemeği', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Lahana Dolması (Etli): 600 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Lahana Dolması (Etli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Lahana Dolması (Etli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 600) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Lahana Dolması (Etli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Mandalina Kompostosu: 800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mandalina Kompostosu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Mandalina Kompostosu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Mandalina Kompostosu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Maydanozlu Bulgur Salatası (Kısır): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Maydanozlu Bulgur Salatası (Kısır)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Maydanozlu Bulgur Salatası (Kısır)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Maydanozlu Bulgur Salatası (Kısır)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Mercimek Köftesi (Ev Usulü): 750 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mercimek Köftesi (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Mercimek Köftesi (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 750) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Mercimek Köftesi (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Mercimekli Bulgur Pilavı: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mercimekli Bulgur Pilavı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Mercimekli Bulgur Pilavı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Mercimekli Bulgur Pilavı', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Midye Dolma (Pilavlı): 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Midye Dolma (Pilavlı)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Midye Dolma (Pilavlı)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Midye Dolma (Pilavlı)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Mısır Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mısır Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Mısır Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Mısır Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Mung Fasulyeli Pilav: 1000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mung Fasulyeli Pilav';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Mung Fasulyeli Pilav'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Mung Fasulyeli Pilav', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 30 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Kış Lahana Turşusu', 'Kızılcık Kompostosu', 'Konserve Bezelyeli Makarna', 'Kuru Fasulye Piyazı (Ev Usulü)', 'Kuru Kayısılı Kış Kompostosu', 'Kuru Üzümlü Komposto', 'Kuşkonmaz Çorbası', 'Kuşkonmaz Salatası', 'Kuşkonmazlı Dana Bonfile', 'Kuzu Etli Kırmızı Mercimek Yemeği', 'Lahana Dolması (Etli)', 'Lahana Salatası', 'Limonlu Fırın Levrek', 'Limonlu Zeytinyağlı Havuç Salatası', 'Madımaklı Kavurma', 'Mandalina Kompostosu', 'Maydanozlu Bulgur Salatası (Kısır)', 'Mercimek Köftesi (Ev Usulü)', 'Mercimekli Bulgur Pilavı', 'Mevsim Yeşillik Salatası', 'Midye Dolma (Pilavlı)', 'Mısır Çorbası', 'Mısırlı Salata', 'Mısırlı Tavuk Sote', 'Mısırlı Yaz Pilavı', 'Muhallebi (Ev Usulü)', 'Mung Fasulyeli Pilav', 'Muzlu Meyve Salatası', 'Muzlu Yoğurt (Ev Usulü)', 'Naneli Bulgur Pilavı') order by ad;

-- Dogrulama 2: 18 satir; hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Kış Lahana Turşusu', 'Kızılcık Kompostosu', 'Konserve Bezelyeli Makarna', 'Kuru Fasulye Piyazı (Ev Usulü)', 'Kuru Kayısılı Kış Kompostosu', 'Kuru Üzümlü Komposto', 'Kuşkonmaz Çorbası', 'Kuşkonmaz Salatası', 'Kuşkonmazlı Dana Bonfile', 'Kuzu Etli Kırmızı Mercimek Yemeği', 'Lahana Dolması (Etli)', 'Mandalina Kompostosu', 'Maydanozlu Bulgur Salatası (Kısır)', 'Mercimek Köftesi (Ev Usulü)', 'Mercimekli Bulgur Pilavı', 'Midye Dolma (Pilavlı)', 'Mısır Çorbası', 'Mung Fasulyeli Pilav')
order by r.ad;
