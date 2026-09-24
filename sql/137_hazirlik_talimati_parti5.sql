-- 137_hazirlik_talimati_parti5.sql
-- 244/245 eksik talimat gorevi, Parti 5: alfabetik 61-90 (parti buyuklugu
-- 15'ten 30'a cikarildi, Bahri onayiyla).
-- NOT: 'Iç Pilav' tarifi digerlerinden FARKLI OLARAK porsiyon_sayisi=1
-- (10 degil) -- su miktari buna gore (90g) hesaplandi, olcek farkli.
-- Su miktarlari yerlesik tariflerle karsilastirmali arastirildi (ozellikle
-- Izgara Ahtapot: haslama+izgara TEK isil asama olarak kayitli, haslama
-- suyu o asamaya baglandi). Bahri'nin standing onayi geregince tablo
-- onaya sunulmadan dogrudan uygulandi.
-- Gramajlar 10 porsiyon icin (Iç Pilav haric, o 1 porsiyon).
-- Tek transaction; herhangi bir kontrol tutmazsa HICBIR degisiklik yapilmaz.
-- Idempotent.

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
1. Havuçları soyup uzun çubuklar veya yuvarlak dilimler halinde kesin.
2. Sarımsakları soyun.
3. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin (sirke kaynatılmaz, aroması uçar).
2. Son işlemler: Havuçları sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı havuçların üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Havuç ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Havuç Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Havuç Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın.
2. Kereviği soyup küçük küp doğrayın.
3. Kuru soğanı soyup küçük küp doğrayın.
4. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, havuç ve kereviği ekleyip 2–3 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp sebzeler tamamen yumuşayana kadar (~17–18 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Havuç ve Kereviz Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Havuç ve Kereviz Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Havuçları soyup iri çubuklar halinde doğrayın; kuru soğanı yarım ay şeklinde dilimleyin.
3. Tavuk butlarını kağıt havluyla kurulayın.
4. Sarımsakları ezip zeytinyağı, tuz ve karabiberle karıştırın; hem butlara hem sebzelere sürün.

**Isıl İşlem**
1. Fırınlama (200°C, 40 dk): Havuç ve soğanı fırın tepsisine yayın, butları derili yüzü üstte olacak şekilde üzerine yerleştirin. 200°C'ye önceden ısıtılmış fırında sebzeler yumuşayıp butun derisi altın rengi olana kadar pişirin. Butun en kalın yerinde iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken sebzeler doğranıp butlar baharatlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~32 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Havuçlu Fırın Tavuk But (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Havuçlu Fırın Tavuk But (Bahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Hindi göğüs filetosunu kurulayıp 2 cm kuşbaşı doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp soğanı 2–3 dk kavurun. Hindileri ekleyip her yüzü renk alana kadar 6–7 dk soteleyin. Domates, tuz ve karabiberi ekleyin; domates suyunu salıp çekene ve hindi tamamen pişene kadar (~8–9 dk) pişirin. Etin en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Sote sürekli takip gerektirdiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Hindi Sote (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Hindi Sote (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Hazır humus mayasını (nohut ezmesi bazını) geniş bir kaba alın.
2. Limon suyu ve zeytinyağının yarısını ekleyip pürüzsüz ve akışkan bir kıvam elde edene kadar karıştırın.
3. Servis tabağına alıp kaşık sırtıyla ortasında girinti oluşturun; kalan zeytinyağını gezdirin.
4. Maydanozu ince kıyıp üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Humus (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Humus (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Hurmaları çekirdeklerinden ayırıp küçük parçalar halinde doğrayın.
2. Pirinç ununu birkaç kaşık soğuk sütle pürüzsüz bir bulamaç haline getirin (topaklanmayı önler).

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 22 dk): Kalan sütü ve şekeri bir tencerede ısıtın. Kaynamaya yakın hurmaları ekleyip 3–4 dk yumuşayana kadar pişirin. Pirinç unu bulamacını azar azar ekleyip sürekli karıştırarak kıvam koyulaşana kadar (~10 dk) pişirmeye devam edin.
2. Son işlemler: Servis kaplarına paylaştırıp ılımaya bırakın (soğuma süresi özete dahil değildir), ardından buzdolabında soğutup servis edin.

**PARALEL YAPILABİLİRLİK:** Hurmalar doğranırken pirinç unu bulamacı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~7 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Hurma ve Süt Tatlısı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Hurma ve Süt Tatlısı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Kuru soğanı ince küp doğrayın.
3. 90 ml (90 g) suyu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 2–3 dk kavurun. Çam fıstığını ekleyip hafif renk alana kadar çevirin, kuş üzümü ve pirinci ekleyip 1–2 dk daha kavurun. Sıcak suyu, tuzu ve yenibaharı ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Su, soğan kavrulurken ısıtılabilir; pilav kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'İç Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- İç Pilav', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. İncirleri yıkayıp saplarını çıkarın, dörde bölün veya dilimleyin.
2. Süzme yoğurdu şekerle çırpın.
3. İncirlerin çoğunu yoğurda ekleyip nazikçe karıştırın; kalanını servis sırasında üzerine dizin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yoğurt çırpılırken incirler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'İncirli Yoğurt (Yaz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- İncirli Yoğurt (Yaz)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 15 dk): Tereyağını tencerede eritip irmiği hafif renk alana kadar 3–4 dk kavurun. Sıcak sıvıyı ve tuzu azar azar, sürekli karıştırarak ekleyin (topaklanmayı önler). Kaynayınca ateşi kısıp irmik pişip kıvam alana kadar (~6–7 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, irmik kavrulurken ayrı bir kapta ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~5 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'İrmik Çorbası (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- İrmik Çorbası (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Süt ile 300 ml (300 g) suyu ve şekeri bir kapta karıştırıp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını geniş bir tencerede eritin, irmiği ekleyip sürekli karıştırarak kızarmadan koyu altın rengi alana kadar (~10–12 dk) kavurun. Süt-su-şeker karışımını sıcak haldeyken azar azar, dikkatle (sıçrayabilir) ekleyip karıştırmaya devam edin. Sıvıyı tamamen çekip kabarcıklar oluşana kadar kısık ateşte pişirin.
2. Son işlemler: Ocaktan alıp üzerini kapatarak 5 dk demlendirin, ardından karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Süt-su karışımı, irmik kavrulurken hazır bekletilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'İrmik Helvası (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- İrmik Helvası (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. İşkembeyi akan soğuk suda iyice yıkayın, gerekirse kokusunu gidermek için birkaç kez suyunu değiştirerek ovarak temizleyin. İnce şeritler halinde doğrayın.
2. Sarımsakları ince kıyın.
3. Tavuk suyu ile 800 ml (800 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 70 dk): Sıcak sıvıyı tencerede kaynatın, işkembeyi ekleyin. Kaynayınca ateşi kısıp kapağı kapalı olarak işkembe tamamen yumuşayana kadar (~55–60 dk) pişirin; arada oluşan köpüğü alın. Son 5 dakikada tereyağında kavrulmuş sarımsağı ve tuzu ekleyin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte uzun sürdüğü için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~60 dk · Toplam ~90 dk$t$
    where isletme_id is null and ad = 'İşkembe Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- İşkembe Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, ince kıyın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
4. 300 ml (300 g) soğuk içme suyunu azar azar ekleyerek çırpın ve akışkan cacık kıvamı elde edin.
5. Ispanağı ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Ispanaklı Cacık';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ispanaklı Cacık', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın.
2. Kuru soğanı soyup küçük küp doğrayın.

**Isıl İşlem**
1. Tavada Pişirme (orta-yüksek ateş, geniş tavada, 20 dk): Tereyağında soğanı 2–3 dk kavurun. Kıymayı ekleyip suyunu salıp çekene ve renk alana kadar (~8 dk) kavurun. Ispanağı ekleyin, tuz ve karabiberi serpin; ıspanak pörsüyüp suyunu salana kadar (~7–8 dk) karıştırarak pişirin. Fazla su kalırsa açık tavada uçurun.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken ıspanak yıkanıp hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Ispanaklı Kıyma (Tavada)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ispanaklı Kıyma (Tavada)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Yeşil mercimeği ayıklayıp yıkayın.
2. Ispanağı ayıklayıp yıkayın, iri kıyın.
3. Kuru soğanı soyup küçük küp doğrayın.
4. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Soğanı zeytinyağı veya tereyağında 3–4 dk kavurun. Mercimeği ekleyip 1–2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp mercimek yumuşayana kadar (~15 dk) pişirin. Son 3–4 dakikada ıspanağı ekleyip pörsüyene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler hazırlanırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Ispanaklı Mercimek Çorbası (Kış)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ispanaklı Mercimek Çorbası (Kış)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp yarım sarımsakla karıştırın.

**Isıl İşlem**
1. Soteleme (orta ateş, tavada, 12 dk): Tereyağında kalan sarımsağı 1 dk kavurun. Ispanağı ekleyip pörsüyüp suyunu salana ve salıverdiği su çekilene kadar (~10–11 dk) karıştırarak pişirin.
2. Son işlemler: Sotelenen ıspanağı ılımaya bırakın (soğuma süresi özete dahil değildir), ardından sarımsaklı yoğurtla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Yoğurt, ıspanak sotelenirken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Ispanaklı Yoğurt (Borani)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ispanaklı Yoğurt (Borani)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Yumurtaları bir kapta çırpın.

**Isıl İşlem**
1. Tavada Pişirme (orta ateş, tavada, 15 dk): Tereyağında soğanı 2–3 dk kavurun. Ispanağı ekleyip pörsüyüp suyunu salana kadar (~6–7 dk) pişirin; fazla su kalırsa açık tavada uçurun. Çırpılmış yumurtaları, tuz ve karabiberi ekleyip yumurta pişip kıvam alana kadar (~5–6 dk) karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Yumurtalar, ıspanak pişerken çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Ispanaklı Yumurta';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Ispanaklı Yumurta', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ahtapotu akan soğuk su altında yıkayın; gözleri ve ağızdaki sert gagayı bıçakla çıkarıp başın içini boşaltın.
2. Zeytinyağı, limon suyu, tuz ve kekiği karıştırıp marinat hazırlayın.

**Isıl İşlem**
1. Izgara (haşlama ~85°C ardından ızgarada mühürleme, 35 dk): Tencereye 3 litre (3000 g) su koyup kaynamaya yakın ısıtın. Ahtapotu dokunaçlarından tutup suya 3 kez daldırıp çıkarın (dokunaçlar kıvrılır), sonra tamamen batırıp kısık ateşte çatal rahatça batana kadar (~15 dk) haşlayın. Süzüp ılıyınca marinatla karıştırıp en az 15 dk (mümkünse daha uzun) marine edin. Iyice ısıtılmış ızgarada dokunaçları her yüzü mühürlenip hafif kömürleşene kadar (~8–10 dk) çevirmeden pişirin.
2. Son işlemler: Parçalara ayırıp üzerine zeytinyağı gezdirerek sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Marinat, ahtapot haşlanırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~15 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Izgara Ahtapot';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Ahtapot', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Böbrekleri ortadan ikiye kesip beyaz iç zarını ve yağ kısımlarını temizleyin.
2. Kokusunu gidermek için bol tuzlu soğuk suda 20–30 dk bekletin (bu bekleme aşağıdaki süreye dahil değildir), ardından durulayıp kurulayın.
3. Zeytinyağı, tuz ve kekikle ovun.

**Isıl İşlem**
1. Izgara (yüksek ateş, ızgarada, 17 dk): Iyice ısıtılmış ızgarada her yüzü mühürlenip içi hafif pembe kalacak kıvamda pişirin; fazla pişirmeyin, sertleşir.

**PARALEL YAPILABİLİRLİK:** Böbrekler bekletilirken ızgara ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Izgara Dana Böbrek';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Dana Böbrek', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirzolaları kağıt havluyla kurulayın, oda sıcaklığına gelmesini bekleyin.
2. Zeytinyağı, tuz, kekik ve karabiberle her yüzünden ovun.

**Isıl İşlem**
1. Izgara (yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada pirzolaları her yüzü 4–5 dk olacak şekilde çevirerek mühürleyin. En kalın yerinde iç sıcaklık en az 63°C (orta pişmişlik) olmalı.
2. Son işlemler: Birkaç dakika dinlendirip servis edin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken baharatlama yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Izgara Dana Pirzola';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Dana Pirzola', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kalamarları temizleyin (iç organları ve kılçığı çıkarın), gövdelerini halka halka kesin veya bütün bırakıp çapraz kesikler atın.
2. Zeytinyağı, limon suyu ve tuzla karıştırın.

**Isıl İşlem**
1. Izgara (yüksek ateş, ızgarada, 15 dk): Iyice ısıtılmış ızgarada kalamarları her yüzü hafif renk alana kadar 2–3 dk gibi kısa sürede pişirin; uzun pişirmek lastik gibi sertleştirir.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken kalamarlar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Izgara Kalamar';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Kalamar', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirzolaları kağıt havluyla kurulayın.
2. Zeytinyağı, tuz, kekik ve karabiberle karıştırıp pirzolalara sürün; en az 10 dk (mümkünse daha uzun) marine edin.

**Isıl İşlem**
1. Izgara (yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada pirzolaları her yüzü 4–5 dk olacak şekilde çevirerek mühürleyin. En kalın yerinde iç sıcaklık en az 63°C (orta pişmişlik) olmalı.
2. Son işlemler: Birkaç dakika dinlendirip servis edin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken marinasyon yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Izgara Kuzu Pirzola';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Kuzu Pirzola', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Palamutları temizletilmiş, pullarından arındırılmış olarak temin edin; yıkayıp kağıt havluyla kurulayın.
2. Balığın her iki yüzüne çapraz kesikler atın.
3. Zeytinyağı, limon suyu ve tuzu karıştırıp balıkların her yüzüne ve kesiklerin içine sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada balıkları her yüzü 7–8 dk olacak şekilde çevirerek, etin en kalın yerinde çatalla kolayca dağılana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken balıklar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Izgara Palamut (Sonbahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Palamut (Sonbahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Piliç butlarını kağıt havluyla kurulayın.
2. Zeytinyağı, limon suyu, tuz, kekik ve karabiberi karıştırıp butlara sürün; en az 15 dk (mümkünse daha uzun) marine edin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 25 dk): Iyice ısıtılmış ızgarada butları kapak kapalı (varsa) her yüzü 6–7 dk olacak şekilde çevirerek pişirin. En kalın yerinde iç sıcaklık en az 75°C olmalı.
2. Son işlemler: Birkaç dakika dinlendirip servis edin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken marinasyon yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~5 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Izgara Piliç But';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Piliç But', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bonfileleri kağıt havluyla kurulayın, oda sıcaklığına gelmesini bekleyin.
2. Zeytinyağı, tuz ve karabiberle her yüzünden ovun.

**Isıl İşlem**
1. Izgara (yüksek ateş, ızgarada, 17 dk): Iyice ısıtılmış ızgarada bonfileleri her yüzü 3–4 dk olacak şekilde çevirerek mühürleyin. En kalın yerinde iç sıcaklık en az 55–60°C (az pişmiş-orta) olmalı; damak zevkine göre süreyi ayarlayın.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken baharatlama yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Izgara Sığır Bonfile';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Sığır Bonfile', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirzolaları kağıt havluyla kurulayın, oda sıcaklığına gelmesini bekleyin.
2. Sarımsakları ezip zeytinyağı, tuz, kekik ve karabiberle karıştırın; pirzolalara sürün.

**Isıl İşlem**
1. Izgara (yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada pirzolaları her yüzü 4–5 dk olacak şekilde çevirerek mühürleyin. En kalın yerinde iç sıcaklık en az 63°C (orta pişmişlik) olmalı.
2. Son işlemler: Birkaç dakika dinlendirip servis edin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken baharatlama yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Izgara Sığır Pirzola';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Sığır Pirzola', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Somon filetolarını kağıt havluyla kurulayın.
2. Limon suyu, zeytinyağı, tuz ve karabiberi karıştırıp filetoların her yüzüne sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 17 dk): Iyice ısıtılmış ızgarada filetoları derili yüzden başlayarak her yüzü 5–6 dk olacak şekilde çevirerek, içi henüz parlak pembe kalacak, çatalla kolayca dağılacak kıvama gelene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken somonlar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~2 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Izgara Somon Fileto';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Izgara Somon Fileto', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kabakları soyup küçük küp doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 20 dk): Tereyağında soğanı 3–4 dk kavurun, kabağı ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp kabak tamamen yumuşayana kadar (~13–14 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kabak Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kabak Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kabakların uçlarını kesip içini bir kabak oyacağı veya kaşıkla, kabuğa 0,5 cm et payı bırakarak oyun.
2. Pirinci yıkayıp süzün; kuru soğanı rendeleyin.
3. Kıyma, pirinç, soğan ve tuzu harmanlayın.
4. Harcı kabaklara, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 35 dk): Dolmaları tencereye dik dizin. 500 ml (500 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Kapağı kapatın; kaynayınca ateşi kısıp pirinç tamamen pişip kabaklar yumuşayana kadar pişirin.
2. Son işlemler: Yoğurdu tarifin kıvamına göre üzerine gezdirerek veya ayrıca servis ederek sunun.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~27 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Kabak Dolması (Etli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kabak Dolması (Etli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kabakları yıkayıp uçlarını kesin, uzun çubuklar veya yuvarlak dilimler halinde kesin.
2. Sarımsakları soyun.
3. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin.
2. Son işlemler: Kabakları sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı kabakların üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Kabak ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kabak Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kabak Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kabakları rendenin iri tarafıyla rendeleyin veya küçük küp doğrayın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.

**Isıl İşlem**
1. Soteleme (orta ateş, tavada, 7 dk): Kabakları az miktarda zeytinyağıyla tavada, suyunu salıp hafif yumuşayana kadar çevirerek pişirin.
2. Son işlemler: Sotelenen kabağı ılımaya bırakın (soğuma süresi özete dahil değildir), ardından sarımsaklı yoğurtla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Yoğurt, kabak sotelenirken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Kabaklı Yoğurt Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kabaklı Yoğurt Salatası', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Havuç Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Havuç Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Havuç Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Havuç ve Kereviz Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç ve Kereviz Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Havuç ve Kereviz Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Havuç ve Kereviz Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- İç Pilav: 90 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İç Pilav';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: İç Pilav'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 90) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- İç Pilav', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- İrmik Çorbası (Ev Usulü): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İrmik Çorbası (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: İrmik Çorbası (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- İrmik Çorbası (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- İrmik Helvası (Ev Usulü): 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İrmik Helvası (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: İrmik Helvası (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- İrmik Helvası (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- İşkembe Çorbası: 800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İşkembe Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: İşkembe Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- İşkembe Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Ispanaklı Cacık: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Cacık';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Ispanaklı Cacık'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Ispanaklı Cacık', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Ispanaklı Mercimek Çorbası (Kış): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Mercimek Çorbası (Kış)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Ispanaklı Mercimek Çorbası (Kış)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Ispanaklı Mercimek Çorbası (Kış)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Izgara Ahtapot: 3000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Ahtapot';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Izgara Ahtapot'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 3000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Izgara Ahtapot', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kabak Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kabak Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kabak Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kabak Dolması (Etli): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Dolması (Etli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kabak Dolması (Etli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kabak Dolması (Etli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kabak Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kabak Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kabak Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 30 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Havuç Turşusu', 'Havuç ve Kereviz Çorbası', 'Havuçlu Fırın Tavuk But (Bahar)', 'Hindi Sote (Ev Usulü)', 'Humus (Ev Usulü)', 'Hurma ve Süt Tatlısı', 'İç Pilav', 'İncirli Yoğurt (Yaz)', 'İrmik Çorbası (Ev Usulü)', 'İrmik Helvası (Ev Usulü)', 'İşkembe Çorbası', 'Ispanaklı Cacık', 'Ispanaklı Kıyma (Tavada)', 'Ispanaklı Mercimek Çorbası (Kış)', 'Ispanaklı Yoğurt (Borani)', 'Ispanaklı Yumurta', 'Izgara Ahtapot', 'Izgara Dana Böbrek', 'Izgara Dana Pirzola', 'Izgara Kalamar', 'Izgara Kuzu Pirzola', 'Izgara Palamut (Sonbahar)', 'Izgara Piliç But', 'Izgara Sığır Bonfile', 'Izgara Sığır Pirzola', 'Izgara Somon Fileto', 'Kabak Çorbası', 'Kabak Dolması (Etli)', 'Kabak Turşusu', 'Kabaklı Yoğurt Salatası') order by ad;

-- Dogrulama 2: 12 satir; hepsinde isil_asama dolu olmali.
select r.ad, r.porsiyon_sayisi, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Havuç Turşusu', 'Havuç ve Kereviz Çorbası', 'İç Pilav', 'İrmik Çorbası (Ev Usulü)', 'İrmik Helvası (Ev Usulü)', 'İşkembe Çorbası', 'Ispanaklı Cacık', 'Ispanaklı Mercimek Çorbası (Kış)', 'Izgara Ahtapot', 'Kabak Çorbası', 'Kabak Dolması (Etli)', 'Kabak Turşusu')
order by r.ad;
