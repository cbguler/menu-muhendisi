-- 143_hazirlik_talimati_parti10_SON.sql
-- 244/245 eksik talimat gorevi, Parti 10 (SON PARTI): alfabetik
-- 211-245 (35 tarif). Bu partiyle 245 tarifin TAMAMI tamamlaniyor.
-- Zeytinyagli sebze yemekleri (bu partinin cogunlugu) icin su miktari
-- yerlesik tariflerle karsilastirmali arastirildi -- ortak bulgu:
-- 'az su kullanip domatesin/sebzenin suyunda pisirmek' prensibi,
-- kuru baklagiller (kuru fasulye, siyah fasulye) haric genellikle
-- 200-500g gibi DUSUK miktarlarda su yeterli oluyor.
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
1. Pirinci yıkayıp süzün.
2. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarın, pürüzsüz olana kadar çırpın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~90°C, tencerede, 20 dk): Sıcak sıvıyı kaynatın, pirinci ve tuzu ekleyip pirinç yumuşayana kadar (~12 dk) pişirin. Bir kepçe sıcak çorbayı yavaşça yoğurda ekleyip çırparak ısındırın (kesilmemesi için), ardından yoğurt karışımını çorbaya geri, karıştırarak ve kaynatmadan ekleyin.
2. Son işlemler: Tereyağını eritip üzerine kuru nane ekleyerek nane yağı hazırlayın, servis anında çorbanın üzerine gezdirin.

**PARALEL YAPILABİLİRLİK:** Sıvı kaynarken yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Yayla Çorbası (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yayla Çorbası (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Domatesleri yıkayıp kabuklarını soyun ve iri doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, domatesi ekleyip 4–5 dk pişirin. Tavuk suyunu, şekeri ve tuzu ekleyin; kaynayınca ateşi kısıp domatesler tamamen dağılana kadar (~15 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin, isterseniz ince süzgeçten geçirin.

**PARALEL YAPILABİLİRLİK:** Domates ve soğan hazırlanırken tavuk suyu ölçülebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Yaz Domates Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yaz Domates Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu kol etini kemik ve fazla yağından ayırıp 2–2,5 cm kuşbaşı doğrayın.
2. Yer elmasını soyup iri küp doğrayın; kararmaması için soğuk suda bekletin.
3. Kuru soğanı soyup küçük küp doğrayın.
4. 1,5 litre (1500 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Yahni Pişirme (~95°C, tencerede kısık ateşte, 50 dk): Zeytinyağında eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk kavurun. 1,5 litre sıcak suyu, tuzu ve karabiberi ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar (~25 dk) pişirin. Süzülmüş yer elmasını ekleyip et ve yer elması tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; yahni kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~40 dk · Toplam ~65 dk$t$
    where isletme_id is null and ad = 'Yer Elmalı Kuzu Yahnisi';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yer Elmalı Kuzu Yahnisi', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Yer elmasını soyup iri küp doğrayın; kararmaması için limonlu suda bekletin.
2. Havuçları kazıyıp iri küp doğrayın.
3. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 30 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Yer elması ve havucu ekleyip 2–3 dk çevirin. 300 ml (300 g) sıcak su, limon suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak sebzeler yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~22 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Yer Elması Zeytinyağlısı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yer Elması Zeytinyağlısı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Yeşil mercimeği ayıklayıp yıkayın.
2. Kuru soğanı küçük küp doğrayın.
3. Maydanozu ince kıyın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 17 dk): Tencereye 1,2 litre (1200 g) su koyup kaynatın. Mercimeği ekleyip diri kalacak (dağılmayacak) şekilde 12–13 dk haşlayın.
2. Son işlemler: Süzüp ılımaya bırakın (soğuma süresi özete dahil değildir). Soğan, maydanoz, zeytinyağı, limon suyu ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken soğan ve maydanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Yeşil Mercimekli Salata';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yeşil Mercimekli Salata', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Marul ve rokayı ayıklayıp yıkayın, iyice süzdürün, elinizle parçalayın.
2. Cevizleri iri kırın.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın; servisten hemen önce yeşilliklerle karıştırın, cevizi üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yeşillikler süzülürken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Yeşil Salata (Cevizli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yeşil Salata (Cevizli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları rendenin iri tarafıyla rendeleyin.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
4. Havucu ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Havuç rendelenirken yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Yoğurtlu Havuç Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yoğurtlu Havuç Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kıymayı yoğurup elle veya kebap şişine parmak kalınlığında şekiller verin.
2. Domatesleri yıkayıp kabuklarını soyun ve rendeleyin.
3. Yoğurdu pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 23 dk): Iyice ısıtılmış ızgarada kebapları her yüzü mühürlenip içi tamamen pişene kadar (~15–17 dk) çevirerek pişirin.
2. Son işlemler: Tereyağını tavada eritip rendelenmiş domatesi ve tuzu ekleyip domates suyunu salıp çekene kadar (~5 dk) pişirin. Kebapları servis tabağına dizin, üzerine çırpılmış yoğurdu, ardından sıcak domates-tereyağı sosunu gezdirin.

**PARALEL YAPILABİLİRLİK:** Izgara pişerken domates sosu ayrı tavada hazırlanır.

**SÜRE ÖZETİ:** Aktif işçilik ~32 dk · Pasif bekleme ~3 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Yoğurtlu Kebap (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yoğurtlu Kebap (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Süzme yoğurdu servis kaselerine paylaştırın.
2. Üzerine yulaf ezmesini serpin.
3. Balı gezdirip servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Yulaf Ezmeli Yoğurt';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yulaf Ezmeli Yoğurt', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 17 dk): Tereyağını tencerede eritip yulaf ezmesini hafif renk alana kadar 2 dk kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp yulaf yumuşayıp kıvam alana kadar (~9–10 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, yulaf kavrulurken ayrı bir kapta ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Yulaflı Çorba';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Yulaflı Çorba', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Peyniri küp veya dilim şeklinde kesin.
2. Zeytinleri süzüp servis tabağına alın.
3. Peynir ve zeytinleri tabakta düzenleyip servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk$t$
    where isletme_id is null and ad = 'Zeytin ve Peynir Tabağı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytin ve Peynir Tabağı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bamyaların saplarını koni şeklinde, tohum yatağına değmeden temizleyin; yıkayıp süzün. İsterseniz limon suyuyla ovup salyalı yapısını azaltın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 40 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 4–5 dk pişirin. Bamyaları ekleyin, 300 ml (300 g) sıcak su, limon suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bamyalar yumuşayana kadar (kepçeyle nazikçe karıştırın, bamya kırılmasın) pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~32 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Bamya (Yaz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Bamya (Yaz)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Barbunyayı ayıklayıp yıkayın (taze/haşlanmaya hazır kullanılıyorsa doğrudan; kuru kullanılıyorsa bir gece önceden ıslatılmış ve süzülmüş olmalı — ıslatma süresi aşağıdaki süreye dahil değildir).
2. Havuçları kazıyıp küçük küp doğrayın.
3. Kuru soğanı küçük küp doğrayın.
4. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 40 dk): Zeytinyağında soğan ve havucu 4–5 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3–4 dk pişirin. Barbunyayı ekleyin, 500 ml (500 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak barbunya tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~32 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Barbunya Pilaki (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın.
2. Taze bezelyeyi ayıklayıp yıkayın; dondurulmuş bezelye kullanılıyorsa çözdürmeden kullanın.
3. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 25 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Havucu ekleyip 2–3 dk çevirin. 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak havuç yarı yumuşayana kadar (~8 dk) pişirin. Bezelyeyi ekleyip her ikisi de tamamen yumuşayana kadar pişirmeye devam edin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Bezelyeli Havuç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Bezelyeli Havuç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kırmızı biberleri yıkayın; sap kısımlarını kapak olarak yuvarlak kesin, çekirdeklerini ve iç zarlarını temizleyin.
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Pirinç, soğan, zeytinyağının yarısı, şeker ve tuzu harmanlayın.
4. Harcı biberlere, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun ve kapaklarını kapatın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 45 dk): Dolmaları tencereye dik ve sıkı dizin. Kalan zeytinyağını ve 400 ml (400 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısın ve pirinç tamamen pişip biberler yumuşayana kadar pişirin.
2. Son işlemler: Dolmaları tencerede oda sıcaklığına gelene kadar soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Su, dolmalar doldurulurken ısıtılabilir; pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~37 dk · Toplam ~70 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Biber Dolması';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Biber Dolması', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Sert ve iri domatesleri yıkayın; sap tarafından ince bir kapak kesin.
2. Domateslerin içini kaşıkla, kabuğa 0,5–1 cm et payı bırakarak oyun; çıkan iç kısmı ayırın.
3. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
4. Pirinç, soğan, ayırdığınız domates içinin yarısı, zeytinyağının yarısı, şeker ve tuzu harmanlayın.
5. Harcı domateslere, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun ve kapaklarını kapatın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 35 dk): Dolmaları tencereye dik dizin. Kalan domates içini ve zeytinyağını 200 ml (200 g) sıcak suyla karıştırıp kenarlardan ekleyin. Kapağı kapatın; kaynayınca ateşi kısıp pirinç tamamen pişene kadar pişirin.
2. Son işlemler: Tencerede oda sıcaklığına gelene kadar soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~27 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Domates Dolması';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Domates Dolması', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Enginarları temizleyin: sert dış yapraklarını ve tüylü iç kısmını çıkarıp kalan etli kısımlarını dilimleyin; kararmaması için limonlu suda bekletin.
2. Havuçları kazıyıp küçük küp doğrayın.
3. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 35 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Havucu ekleyip 2–3 dk çevirin. Enginarları, 400 ml (400 g) sıcak su, limon suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak enginar ve havuç tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~27 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Enginar (İlkbahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Enginar (İlkbahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları kazıyıp yuvarlak veya çubuk şeklinde doğrayın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 25 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Havucu ekleyip 2–3 dk çevirin. Pirinci, 400 ml (400 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak havuç ve pirinç yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~19 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Havuç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Havuç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 25 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun. Pirinci ekleyip 1–2 dk çevirin. 200 ml (200 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp pirinç yarı pişene kadar (~7–8 dk) kapağı kapalı pişirin. Ispanağı ekleyip pörsüyüp pirinç tamamen pişene kadar pişirmeye devam edin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~19 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Ispanak';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Ispanak', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kabakları yuvarlak veya yarım ay dilimleyin.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3 dk pişirin. Kabak ve pirinci, 200 ml (200 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak kabak ve pirinç tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~19 dk · Pasif bekleme ~21 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Kabak (Yaz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Kabak (Yaz)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kabakların uçlarını kesip içini bir kabak oyacağı veya kaşıkla, kabuğa 0,5 cm et payı bırakarak oyun.
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Pirinç, soğan, zeytinyağının yarısı, şeker ve tuzu harmanlayın.
4. Harcı kabaklara, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 35 dk): Dolmaları tencereye dik dizin. Kalan zeytinyağını ve 400 ml (400 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Kapağı kapatın; kaynayınca ateşi kısıp pirinç tamamen pişip kabaklar yumuşayana kadar pişirin.
2. Son işlemler: Tencerede oda sıcaklığına gelene kadar soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~27 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Kabak Dolması';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Kabak Dolması', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karalahanayı yıkayıp kalın sap kısımlarını ayırın, yapraklarını iri doğrayın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 33 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun. Pirinci ekleyip 1–2 dk çevirin. 400 ml (400 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp pirinç yarı pişene kadar (~8 dk) kapağı kapalı pişirin. Karalahanayı ekleyip pörsüyüp pirinç tamamen pişene kadar (~15–17 dk) pişirmeye devam edin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Karalahana (Sonbahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Karalahana (Sonbahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kereviği soyup iri küp doğrayın; kararmaması için limonlu suda bekletin.
2. Havuçları kazıyıp küçük küp doğrayın.
3. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 33 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Havucu ekleyip 2–3 dk çevirin. Kereviği, 400 ml (400 g) sıcak su, limon suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak sebzeler tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Kereviz (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Kereviz (Bahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat (tercihen bir gece) önce bol soğuk suda ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 33 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun. Domatesi ekleyip 3–4 dk pişirin. Islatılmış fasulyeyi ekleyin, 1,8 litre (1800 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Su, sebzeler kavrulurken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Kuru Fasulye (Soğuk)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Kuru Fasulye (Soğuk)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Lahananın göbeğini bıçakla oyup çıkarın. Büyük bir tencerede kaynar tuzlu suda yaprakları teker teker yumuşayıp ayrılana kadar (aşağıdaki süreye dahil değildir) haşlayıp soğuk suya alın; kalın orta damarları inceltin.
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Pirinç, soğan, zeytinyağının yarısı, şeker ve tuzu harmanlayın.
4. Harcı yapraklara paylaştırıp sıkıca sarın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 40 dk): Sarma dolmaları tencereye sıkı dizin. Kalan zeytinyağını ve 500 ml (500 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısıp pirinç tamamen pişip yapraklar yumuşayana kadar pişirin.
2. Son işlemler: Tencerede oda sıcaklığına gelene kadar soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~32 dk · Toplam ~65 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Lahana Dolması';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Lahana Dolması', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patatesleri iyice yıkayın (kabuklarıyla haşlanacak).
2. Maydanozu ince kıyın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 17 dk): Tencereye 1,5 litre (1500 g) su koyup kaynatın. Patatesleri ekleyip çatal rahatça batana kadar haşlayın.
2. Son işlemler: Patatesleri süzüp ılınca kabuklarını soyup küp doğrayın. Zeytinyağı, limon suyu, maydanoz ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken maydanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Patates Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Patates Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patatesleri ve havuçları soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 28 dk): Zeytinyağında havuç ve patatesi 3–4 dk çevirin, şekeri ekleyip 1 dk karıştırın. 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak sebzeler tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~19 dk · Pasif bekleme ~21 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Patatesli Havuç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Patatesli Havuç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patlıcanları soyup enine dilimleyin veya küp doğrayın; tuzla ovup 10 dk (aşağıdaki süreye dahil değildir) acı suyunu çıkarmaya bırakın, sonra kurulayın.
2. Kuru soğanı ince yarım ay dilimleyin, sarımsakları ince kıyın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 35 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, sarımsağı ekleyip 1 dk çevirin, şekeri ekleyin. Domatesi ekleyip 3–4 dk pişirin. Patlıcanları, 200 ml (200 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak patlıcanlar tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~27 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Patlıcan (Yaz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Patlıcan (Yaz)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pırasayı temizleyip yıkayın, ince halkalar halinde doğrayın.
2. Havuçları kazıyıp küçük küp doğrayın.
3. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 33 dk): Zeytinyağında pırasa ve havucu 4–5 dk çevirin, şekeri ekleyip 1 dk karıştırın. Pirinci, 400 ml (400 g) sıcak su, limon suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pırasa, havuç ve pirinç tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Pırasa (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Pırasa (Bahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Semizotunu ayıklayıp yıkayın, iri kıyın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Pirinci yıkayıp süzün.
4. Yoğurdu servis için oda sıcaklığında bekletin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 25 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun. Pirinci ekleyip 1–2 dk çevirin. 200 ml (200 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp pirinç yarı pişene kadar (~7–8 dk) kapağı kapalı pişirin. Semizotunu ekleyip pörsüyüp pirinç tamamen pişene kadar pişirmeye devam edin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin; isteğe göre yanında yoğurt sunun.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~19 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Semizotu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Semizotu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Siyah fasulyeyi pişirmeden en az 8 saat (tercihen bir gece) önce bol soğuk suda ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 40 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun. Domatesi ekleyip 3–4 dk pişirin. Islatılmış fasulyeyi ekleyin, 1,5 litre (1500 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Su, sebzeler kavrulurken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~32 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Siyah Fasulye';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Siyah Fasulye', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Soya fasulyesini (taze/dondurulmuş) ayıklayın; dondurulmuşsa çözdürmeden kullanın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Soya fasulyesini, 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~19 dk · Pasif bekleme ~21 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Soya Fasulyesi';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Soya Fasulyesi', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Baklaları ayıklayıp yıkayın; körpe ise bütün, iri ise iki parça halinde kesin.
2. Taze soğanı yıkayıp doğrayın.
3. Dereotunu ince kıyın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 28 dk): Zeytinyağında taze soğanı 2–3 dk çevirin, şekeri ekleyip 1 dk karıştırın. Baklaları, 200 ml (200 g) sıcak su, limon suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bakla tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp dereotunu ekleyin, oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~19 dk · Pasif bekleme ~21 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Taze Bakla';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Taze Bakla', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Taze fasulyenin iplerini ayıklayıp uzunlamasına ikiye bölün.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı cam gibi olana kadar 3–4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3–4 dk pişirin. Taze fasulyeyi, 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~19 dk · Pasif bekleme ~21 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Taze Fasulye (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Taze Fasulye (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Salamura yaprakları tuzunu gidermek için birkaç kez ılık suda durulayın (bu durulama süreye dahil değildir).
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Pirinç, soğan, zeytinyağının yarısı, şeker ve tuzu harmanlayın.
4. Harcı yapraklara paylaştırıp sıkıca sarın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 60 dk): Sarmaları tencereye sıkı ve iç içe dizin. Kalan zeytinyağını, limon suyunu ve 600 ml (600 g) sıcak suyu ekleyin; su sarmaların yaklaşık yarısına gelmelidir. Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısıp pirinç tamamen pişip yapraklar yumuşayana kadar pişirin.
2. Son işlemler: Tencerede oda sıcaklığına gelene kadar soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Su, sarma yapılırken ısıtılabilir; pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~50 dk · Toplam ~90 dk$t$
    where isletme_id is null and ad = 'Zeytinyağlı Yaprak Sarma (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Zeytinyağlı Yaprak Sarma (Ev Usulü)', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Yayla Çorbası (Ev Usulü): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yayla Çorbası (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Yayla Çorbası (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Yayla Çorbası (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Yer Elmalı Kuzu Yahnisi: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yer Elmalı Kuzu Yahnisi';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Yer Elmalı Kuzu Yahnisi'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Yer Elmalı Kuzu Yahnisi', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Yer Elması Zeytinyağlısı: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yer Elması Zeytinyağlısı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Yer Elması Zeytinyağlısı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Yer Elması Zeytinyağlısı', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Yeşil Mercimekli Salata: 1200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yeşil Mercimekli Salata';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Yeşil Mercimekli Salata'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Yeşil Mercimekli Salata', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Yulaflı Çorba: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yulaflı Çorba';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Yulaflı Çorba'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Yulaflı Çorba', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Bamya (Yaz): 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Bamya (Yaz)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Bamya (Yaz)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Bamya (Yaz)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Barbunya Pilaki (Ev Usulü): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Barbunya Pilaki (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Barbunya Pilaki (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Bezelyeli Havuç: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Bezelyeli Havuç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Bezelyeli Havuç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Bezelyeli Havuç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Biber Dolması: 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Biber Dolması';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Biber Dolması'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Biber Dolması', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Domates Dolması: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Domates Dolması';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Domates Dolması'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Domates Dolması', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Enginar (İlkbahar): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Enginar (İlkbahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Enginar (İlkbahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Enginar (İlkbahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Havuç: 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Havuç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Havuç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Havuç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Ispanak: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Ispanak';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Ispanak'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Ispanak', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Kabak (Yaz): 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kabak (Yaz)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Kabak (Yaz)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Kabak (Yaz)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Kabak Dolması: 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kabak Dolması';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Kabak Dolması'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Kabak Dolması', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Karalahana (Sonbahar): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Karalahana (Sonbahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Karalahana (Sonbahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Karalahana (Sonbahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Kereviz (Bahar): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kereviz (Bahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Kereviz (Bahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Kereviz (Bahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Kuru Fasulye (Soğuk): 1800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kuru Fasulye (Soğuk)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Kuru Fasulye (Soğuk)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Kuru Fasulye (Soğuk)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Lahana Dolması: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Lahana Dolması';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Lahana Dolması'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Lahana Dolması', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Patates Salatası: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Patates Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Patates Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Patates Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Patatesli Havuç: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Patatesli Havuç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Patatesli Havuç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Patatesli Havuç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Patlıcan (Yaz): 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Patlıcan (Yaz)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Patlıcan (Yaz)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Patlıcan (Yaz)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Pırasa (Bahar): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Pırasa (Bahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Pırasa (Bahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Pırasa (Bahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Semizotu: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Semizotu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Semizotu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Semizotu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Siyah Fasulye: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Siyah Fasulye';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Siyah Fasulye'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Siyah Fasulye', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Soya Fasulyesi: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Soya Fasulyesi';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Soya Fasulyesi'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Soya Fasulyesi', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Taze Bakla: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Taze Bakla';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Taze Bakla'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Taze Bakla', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Taze Fasulye (Ev Usulü): 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Taze Fasulye (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Taze Fasulye (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Taze Fasulye (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Zeytinyağlı Yaprak Sarma (Ev Usulü): 600 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Yaprak Sarma (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Zeytinyağlı Yaprak Sarma (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 600) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Zeytinyağlı Yaprak Sarma (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 35 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Yayla Çorbası (Ev Usulü)', 'Yaz Domates Çorbası', 'Yer Elmalı Kuzu Yahnisi', 'Yer Elması Zeytinyağlısı', 'Yeşil Mercimekli Salata', 'Yeşil Salata (Cevizli)', 'Yoğurtlu Havuç Salatası', 'Yoğurtlu Kebap (Ev Usulü)', 'Yulaf Ezmeli Yoğurt', 'Yulaflı Çorba', 'Zeytin ve Peynir Tabağı', 'Zeytinyağlı Bamya (Yaz)', 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)', 'Zeytinyağlı Bezelyeli Havuç', 'Zeytinyağlı Biber Dolması', 'Zeytinyağlı Domates Dolması', 'Zeytinyağlı Enginar (İlkbahar)', 'Zeytinyağlı Havuç', 'Zeytinyağlı Ispanak', 'Zeytinyağlı Kabak (Yaz)', 'Zeytinyağlı Kabak Dolması', 'Zeytinyağlı Karalahana (Sonbahar)', 'Zeytinyağlı Kereviz (Bahar)', 'Zeytinyağlı Kuru Fasulye (Soğuk)', 'Zeytinyağlı Lahana Dolması', 'Zeytinyağlı Patates Salatası', 'Zeytinyağlı Patatesli Havuç', 'Zeytinyağlı Patlıcan (Yaz)', 'Zeytinyağlı Pırasa (Bahar)', 'Zeytinyağlı Semizotu', 'Zeytinyağlı Siyah Fasulye', 'Zeytinyağlı Soya Fasulyesi', 'Zeytinyağlı Taze Bakla', 'Zeytinyağlı Taze Fasulye (Ev Usulü)', 'Zeytinyağlı Yaprak Sarma (Ev Usulü)') order by ad;

-- Dogrulama 2: 29 satir; hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Yayla Çorbası (Ev Usulü)', 'Yer Elmalı Kuzu Yahnisi', 'Yer Elması Zeytinyağlısı', 'Yeşil Mercimekli Salata', 'Yulaflı Çorba', 'Zeytinyağlı Bamya (Yaz)', 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)', 'Zeytinyağlı Bezelyeli Havuç', 'Zeytinyağlı Biber Dolması', 'Zeytinyağlı Domates Dolması', 'Zeytinyağlı Enginar (İlkbahar)', 'Zeytinyağlı Havuç', 'Zeytinyağlı Ispanak', 'Zeytinyağlı Kabak (Yaz)', 'Zeytinyağlı Kabak Dolması', 'Zeytinyağlı Karalahana (Sonbahar)', 'Zeytinyağlı Kereviz (Bahar)', 'Zeytinyağlı Kuru Fasulye (Soğuk)', 'Zeytinyağlı Lahana Dolması', 'Zeytinyağlı Patates Salatası', 'Zeytinyağlı Patatesli Havuç', 'Zeytinyağlı Patlıcan (Yaz)', 'Zeytinyağlı Pırasa (Bahar)', 'Zeytinyağlı Semizotu', 'Zeytinyağlı Siyah Fasulye', 'Zeytinyağlı Soya Fasulyesi', 'Zeytinyağlı Taze Bakla', 'Zeytinyağlı Taze Fasulye (Ev Usulü)', 'Zeytinyağlı Yaprak Sarma (Ev Usulü)')
order by r.ad;

-- Dogrulama 3 (SON KONTROL -- TUM PROJE): kutuphanede (isletme_id is
-- null) hazirlik_talimati BOS kalan tarif kalmamali. 0 satir donmeli.
select id, ad from receteler
where isletme_id is null
  and (hazirlik_talimati is null or trim(hazirlik_talimati) = '');
