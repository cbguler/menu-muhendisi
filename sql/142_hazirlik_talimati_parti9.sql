-- 142_hazirlik_talimati_parti9.sql
-- 244/245 eksik talimat gorevi, Parti 9: alfabetik 181-210.
-- Bu partiden bazi tarifler (Roka Soslu Izgara Tavuk, Sade Kuzu
-- Güveç, Semizotlu Etli Yemek, Soya Kıymalı Patlıcan Musakka,
-- Soyalı Biberli Sote, Taze Bakla Kavurma, Taze Fasulyeli Kuzu
-- Güveç, Taze Fasulyeli Tavuk Güveç) 139 numarali migration'la
-- TEMIZLENEN mukerrer-asama tarifleriydi -- 139'un DAHA ONCE
-- calistirilmis olmasi VARSAYILIYOR (dogrulandi).
-- 'Tereli/Turplu Yoğurt Salatası' ve benzeri CIG sebze+yogurt
-- 'salata'lara (cacik degil) BILINCLI olarak su EKLENMEDI --
-- kalin kivamda kalmasi amaclandi; sadece 'Cacık' adli tarifler
-- ve haslama/soteleme gerektiren 'Salata'lar sulandiriliyor.
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
1. Tavuk göğsünü kağıt havluyla kurulayın, kalın kısımlarını eşit kalınlığa getirin.
2. Sarımsakları ezip zeytinyağı, limon suyu ve tuzla karıştırın; tavuklara sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 17 dk): Iyice ısıtılmış ızgarada tavukları her yüzü 6–7 dk olacak şekilde çevirerek pişirin. En kalın yerinde iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken roka sosu (varsa ayrı tarif) hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Roka Soslu Izgara Tavuk';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Roka Soslu Izgara Tavuk', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Rokayı ayıklayıp yıkayın, iyice süzdürün, iri kıyın.
2. Sarımsakları ince kıyın.
3. 3,5 litre (3500 g) suyu tencereye koyup kaynatmaya başlayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede + tavada, 15 dk): Kaynayan suya tuz ekleyip makarnayı paket üzerindeki süreden 1 dk az haşlayın; haşlama suyundan 1 kepçe ayırıp makarnayı süzün. Makarna haşlanırken ayrı bir tavada zeytinyağında sarımsağı kısık ateşte 1–2 dk kavurun. Süzülen makarnayı, rokayı, tuzu ve ayrılan haşlama suyunu tavaya ekleyip roka pörsüyene kadar 1–2 dk karıştırın.

**PARALEL YAPILABİLİRLİK:** Makarna kaynayan suda haşlanırken sarımsak-roka tabanı ayrı tavada hazırlanır.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~5 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Roka Soslu Makarna';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Roka Soslu Makarna', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Domatesleri yıkayıp küçük dilimler veya küp halinde doğrayın.
2. Rokayı ayıklayıp yıkayın, iyice süzdürün.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.
4. Domates ve rokayı sosla karıştırıp servisten hemen önce sunun.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Domates doğranırken roka süzülebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Rokalı Domates Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Rokalı Domates Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Armutları yıkayın, çekirdek evlerini çıkarıp ince dilimler halinde kesin.
2. Rokforu ufalayın.
3. Cevizleri iri kırın.
4. Zeytinyağı ve limon suyunu çırparak sosu hazırlayın.
5. Armut dilimlerini servis tabağına dizin, üzerine rokfor ve cevizi serpip sosu gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Armut dilimlenirken rokfor ufalanıp ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Rokforlu Armut Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Rokforlu Armut Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 20 dk): Tereyağında soğanı 3–4 dk kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ıspanağı ekleyip pörsüyüp yumuşayana kadar (~8–9 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, ıspanak ve soğan hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Sade Ispanak Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Sade Ispanak Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu butu 2–2,5 cm kuşbaşı doğrayın.
2. Kuru soğanı iri doğrayın.
3. Havuçları kazıyıp iri doğrayın.
4. Et suyu ile 1,2 litre (1200 g) suyu birlikte ısıtın.

**Isıl İşlem**
1. Güveç Pişirme (~95°C, güveç kabında veya tencerede kısık ateşte, 55 dk): Eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk kavurun. Sıcak sıvıyı, tuzu ve karabiberi ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar (~25 dk) pişirin. Havucu ekleyip et ve havuç tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Sıvı, doğrama sırasında ısıtılabilir; güveç kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~45 dk · Toplam ~70 dk$t$
    where isletme_id is null and ad = 'Sade Kuzu Güveç (Et Suyu ile)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Sade Kuzu Güveç (Et Suyu ile)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Salebi birkaç kaşık soğuk sütle pürüzsüz bir bulamaç haline getirin (topaklanmayı önler).

**Isıl İşlem**
1. Süt Pişirme (~90°C, tencerede, 14 dk): Kalan sütü ve şekeri bir tencerede ısıtın. Kaynamaya yakın gelince salep bulamacını azar azar, sürekli karıştırarak ekleyin. Kısık ateşte, sürekli karıştırarak kıvam koyulaşana kadar (~8–10 dk) pişirin.
2. Son işlemler: Sıcak fincanlara paylaştırıp üzerine tarçın serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Bulamaç, süt ısıtılırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~4 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Salep (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Salep (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
2. Kuru soğanı küçük küp doğrayın; sarımsakları ince kıyın.
3. 3,5 litre (3500 g) suyu tencereye koyup kaynatmaya başlayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede + tavada, 20 dk): Kaynayan suya tuz ekleyip makarnayı paket üzerindeki süreden 1 dk az haşlayın; süzün. Makarna haşlanırken ayrı bir tavada zeytinyağında soğanı 3–4 dk kavurun, sarımsağı ekleyip 1 dk çevirin. Domatesi ekleyip tuzla birlikte sos kıvamına gelene kadar (~10–12 dk) pişirin.
2. Son işlemler: Süzülen makarnayı sosla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Makarna kaynayan suda haşlanırken domates sosu ayrı tavada hazırlanır.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Sarımsaklı Domates Soslu Makarna';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Sarımsaklı Domates Soslu Makarna', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kinoayı süzgeçte bol suyla durulayıp süzün (dış kabuğundaki acı saponin tabakasını gideri).
2. 1 litre (1000 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): Zeytinyağında kinoayı 1–2 dk çevirin. Sıcak suyu ve tuzu ekleyin; kaynayınca ateşi kısıp havuç ve bezelyeyi ekleyin, kapağı kapalı olarak kinoa suyunu çekip taneleri açılana kadar (~12 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin, çatalla havalandırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su, kinoa durulanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Sebzeli Quinoa Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Sebzeli Quinoa Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 15 dk): Tereyağını tencerede eritip şehriyeyi hafif renk alana kadar 2–3 dk kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp şehriye yumuşayana kadar (~7–8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, şehriye kavrulurken ayrı bir kapta ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~10 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Şehriye Çorbası (Sade)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Şehriye Çorbası (Sade)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Tavuk suyu ile 200 ml (200 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip şehriyeyi hafif renk alana kadar 1–2 dk kavurun. Pirinci ekleyip 2 dk daha kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, pirinç yıkanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Şehriyeli Bahar Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Şehriyeli Bahar Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bulguru süzgeçte durulayıp süzün.
2. Tavuk suyu ile 100 ml (100 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 17 dk): Tereyağını tencerede eritip şehriyeyi hafif renk alana kadar 1–2 dk kavurun. Bulguru ekleyip 2 dk daha kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak suyunu çekene kadar (~12 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, bulgur hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Şehriyeli Bulgur Pilavı (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Şehriyeli Bulgur Pilavı (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Semizotunu ayıklayıp yıkayın, iri kıyın.
2. Kuru soğanı küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı 3–4 dk kavurun, kıymayı ekleyip suyunu salıp çekene kadar (~8 dk) kavurun. Domatesi ekleyip 3 dk pişirin. 400 ml (400 g) sıcak su, tuz ve karabiberi ekleyip 5 dk kaynatın. Semizotunu ekleyip pörsüyüp yumuşayana kadar (~6–7 dk) pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken semizotu yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Semizotlu Etli Yemek';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Semizotlu Etli Yemek', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Semizotunu ayıklayıp yıkayın, ince kıyın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
4. 300 ml (300 g) soğuk içme suyunu azar azar ekleyerek çırpın ve akışkan kıvam elde edin.
5. Semizotunu ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Semizotlu Yoğurt';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Semizotlu Yoğurt', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patlıcanları 1 cm kalınlığında dilimleyip hafif tuzlayarak 10 dk (aşağıdaki süreye dahil değildir) acı suyunu çıkarmaya bırakın, sonra kurulayın.
2. Kuru soğanı küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede/tavada, 35 dk): Patlıcan dilimlerini zeytinyağında her iki yüzü hafif kızarana kadar 2–3 dk'şar sote edip bir kaba alın. Aynı yağda soğanı 3–4 dk kavurun, soya kıymayı ekleyip 3–4 dk çevirin (soya kıyma su çektiği için lastik gibi olmasın diye fazla kavurmayın). Domatesi, tuzu ve 400 ml (400 g) sıcak suyu ekleyip 12–15 dk kısık ateşte pişirin. Patlıcanları harca ekleyip 3–4 dk daha kaynatın.

**PARALEL YAPILABİLİRLİK:** Soya kıymalı sos pişerken patlıcanlar sotelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~27 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Soya Kıymalı Patlıcan Musakka (Etsiz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Soya Kıymalı Patlıcan Musakka (Etsiz)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kırmızı biberleri yıkayın; sap kısımlarını kapak olarak yuvarlak kesin, çekirdeklerini ve iç zarlarını temizleyin.
2. Pirinci yıkayıp süzün.
3. Soya kıyma, pirinç, zeytinyağının yarısı, tuz ve biraz su (soya kıymayı hafifçe yumuşatmak için) bir kapta harmanlayın.
4. Harcı biberlere, pirincin şişme payı için ağızlarında boşluk bırakarak doldurun ve kapaklarını kapatın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede kısık ateşte, 40 dk): Dolmaları tencereye dik ve sıkı dizin. Kalan zeytinyağını ve 300 ml (300 g) sıcak suyu kenarlardan ekleyin; su dolmaların yaklaşık yarısına gelmelidir. Üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısın ve pirinç tamamen pişip biberler yumuşayana kadar pişirin.
2. Son işlemler: Dolmaları tencerede ılımaya bırakın, ılık veya soğuk servis edin (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Su, dolmalar doldurulurken ısıtılabilir; pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~32 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Soya Kıymalı Zeytinyağlı Dolma';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Soya Kıymalı Zeytinyağlı Dolma', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Soya kıymayı, paketindeki talimata göre ılık suda kısa süre bekletip yumuşatın (bu bekleme süreye dahil değildir), süzün.
2. Kırmızı biberi çekirdeklerinden ayıklayıp iri doğrayın.
3. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 17 dk): Zeytinyağında soğanı 2–3 dk kavurun. Soya kıymayı ekleyip 100 ml (100 g) su ile birlikte 4–5 dk çevirerek pişirin. Biberi, tuzu ekleyip biber diri-yumuşak kalacak kıvamda (~6–7 dk) pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Soya kıyma yumuşarken biber ve soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Soyalı Biberli Sote (Etsiz)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Soyalı Biberli Sote (Etsiz)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Sucuğu ince yarım ay dilimler halinde kesin.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağında sucuğu kendi yağını salana kadar 2–3 dk kavurup bir kaba alın. Aynı tencerede pirinci taneler şeffaflaşana kadar 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, sucukları serpip kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, sucuk ve pirinç hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Sucuklu Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Sucuklu Pilav', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Sucuğu yuvarlak veya yarım ay dilimler halinde kesin.
2. Yumurtaları bir kapta çırpın veya kırılmış halde hazır bekletin (tarife göre çırpılmadan da yapılabilir).

**Isıl İşlem**
1. Tavada Pişirme (orta ateş, tavada, 12 dk): Sucukları yağsız bir tavada kendi yağını salıp hafif kızarana kadar 4–5 dk kavurun. Yumurtaları ve tuzu ekleyip istenilen kıvama gelene kadar (çırpılmışsa karıştırarak, kırılmışsa sarı kısmı istenilen pişkinlikte) 5–6 dk pişirin.

**PARALEL YAPILABİLİRLİK:** Sucuk kavrulurken yumurtalar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Sucuklu Yumurta (Tava)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Sucuklu Yumurta (Tava)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tahini iyice karıştırıp yağı ile katısını birleştirin (kavanozun dibinde ayrışmış olabilir).
2. Pekmez ve tahini bir kapta, homojen ve krema kıvamına gelene kadar çırpın.
3. Servis tabağına alıp, isterseniz üzerini tahin veya pekmezle süsleyin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk$t$
    where isletme_id is null and ad = 'Tahin Pekmez (Klasik)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Tahin Pekmez (Klasik)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tarhanayı birkaç kaşık soğuk tavuk suyu veya su ile pürüzsüz bir bulamaç haline getirin (topaklanmayı önler).

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 17 dk): Kalan tavuk suyunu tereyağıyla birlikte kaynatın. Tarhana bulamacını azar azar, sürekli karıştırarak ekleyin. Tuzu ekleyip kısık ateşte, ara sıra karıştırarak kıvam alana kadar (~10 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken tarhana bulamacı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Tarhana Çorbası (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Tarhana Çorbası (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk suyu ile 700 ml (700 g) suyu birlikte ölçün.
2. Yumurtaları çırpıp limon suyuyla karıştırın (terbiye için).

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 17 dk): Sıcak sıvıyı kaynatın, pirinci ve tuzu ekleyip pirinç yumuşayana kadar (~10 dk) pişirin. Ocaktan hafif çekip bir kepçe sıcak çorbayı yumurta-limon karışımına azar azar ekleyerek terbiyeyi ısıtın (kesilmemesi için), ardından terbiyeyi çorbaya geri, karıştırarak ve kaynatmadan ekleyin.

**PARALEL YAPILABİLİRLİK:** Sıvı kaynarken terbiye hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Tavuk Suyu Çorbası (Sade)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Tavuk Suyu Çorbası (Sade)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Baklaları ayıklayıp yıkayın; körpe ise bütün, iri ise iki parça halinde kesin.
2. Taze soğanı yıkayıp doğrayın (beyaz ve yeşil kısmını ayrı tutun).
3. Dereotunu ince kıyın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede kısık ateşte, 33 dk): Tereyağında kıymayı suyunu salıp çekene ve renk alana kadar (~10–12 dk) kavurun. Taze soğanın beyaz kısmını ekleyip 2–3 dk çevirin. Baklaları, tuz ve karabiberi ekleyip kapağı kapatarak kendi suyunda yumuşayana kadar (~18–20 dk) kısık ateşte pişirin; gerekirse tabandan yapışmaması için birkaç kaşık su ekleyin.
2. Son işlemler: Dereotu ve taze soğanın yeşil kısmını ocaktan almadan hemen önce ekleyin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken bakla ve taze soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~18 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Taze Bakla Kavurma (Etli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Taze Bakla Kavurma (Etli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu butu 2–2,5 cm kuşbaşı doğrayın.
2. Taze fasulyenin iplerini ayıklayıp ikiye veya üçe kesin.
3. Kuru soğanı iri doğrayın.
4. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
5. 1,5 litre (1500 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Güveç Pişirme (~95°C, güveç kabında veya tencerede kısık ateşte, 50 dk): Zeytinyağında eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk, domatesi ekleyip 2–3 dk daha kavurun. 1,5 litre sıcak suyu, tuzu ve karabiberi ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar (~25 dk) pişirin. Taze fasulyeyi ekleyip et ve fasulye tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; güveç kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~40 dk · Toplam ~65 dk$t$
    where isletme_id is null and ad = 'Taze Fasulyeli Kuzu Güveç (İlkbahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Taze Fasulyeli Kuzu Güveç (İlkbahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk butlarını kağıt havluyla kurulayın.
2. Taze fasulyenin iplerini ayıklayıp ikiye veya üçe kesin.
3. Kuru soğanı iri doğrayın.
4. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Güveç Pişirme (~90°C, güveç kabında veya tencerede kısık ateşte, 33 dk): Zeytinyağında soğanı 3–4 dk kavurun, butları ekleyip her yüzü renk alana kadar 5–6 dk çevirin. Domatesi ekleyip 3 dk pişirin. Taze fasulye, tuz ve 300 ml (300 g) sıcak suyu ekleyin; kapağı kapatıp tavuk ve fasulye tamamen yumuşayana kadar kısık ateşte pişirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk · Pasif bekleme ~23 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Taze Fasulyeli Tavuk Güveç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Taze Fasulyeli Tavuk Güveç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Salatalıkları yıkayın, uçlarını kesip küçük küp doğrayın veya iri rendeleyin; rendelenmişse suyunu hafifçe sıkın.
2. Taze soğanı ince doğrayın.
3. Yoğurdu pürüzsüz olana kadar çırpın.
4. 300 ml (300 g) soğuk içme suyunu azar azar ekleyerek çırpın ve akışkan cacık kıvamı elde edin.
5. Salatalık ve taze soğanı ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Taze Soğanlı Cacık';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Taze Soğanlı Cacık', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Vişneleri ayıklayıp yıkayın, isterseniz çekirdeklerini çıkarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 20 dk): 600 ml (600 g) suyu ve şekeri bir tencerede kaynatın. Vişneleri ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak vişneler yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Taze Vişne Kompostosu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Taze Vişne Kompostosu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tereyi ayıklayıp yıkayın, iyice süzdürün, ince kıyın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
4. Tereyi ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yoğurt çırpılırken tere hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Tereli Yoğurt Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Tereli Yoğurt Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Turpları yıkayıp ince dilimleyin veya rendeleyin.
2. Taze naneyi ince kıyın.
3. Sarımsakları soyup tuzla birlikte ezin.
4. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.
5. Turp ve naneyi ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yoğurt çırpılırken turp hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Turplu Yoğurt Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Turplu Yoğurt Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Üzümleri yıkayıp taneleyin, isterseniz ikiye bölün.
2. Süzme yoğurdu pürüzsüz olana kadar çırpın.
3. Cevizleri iri kırın.
4. Üzümlerin çoğunu yoğurda ekleyip nazikçe karıştırın; kalanı ve cevizi servis sırasında üzerine dizin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yoğurt çırpılırken üzüm ve ceviz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Üzümlü Cevizli Yoğurt Salatası (Sonbahar)', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Roka Soslu Makarna: 3500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Roka Soslu Makarna';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Roka Soslu Makarna'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 3500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Roka Soslu Makarna', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Sade Ispanak Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sade Ispanak Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Sade Ispanak Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Sade Ispanak Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Sade Kuzu Güveç (Et Suyu ile): 1200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sade Kuzu Güveç (Et Suyu ile)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Sade Kuzu Güveç (Et Suyu ile)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Sade Kuzu Güveç (Et Suyu ile)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Sarımsaklı Domates Soslu Makarna: 3500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sarımsaklı Domates Soslu Makarna';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Sarımsaklı Domates Soslu Makarna'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 3500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Sarımsaklı Domates Soslu Makarna', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Sebzeli Quinoa Pilavı: 1000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sebzeli Quinoa Pilavı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Sebzeli Quinoa Pilavı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Sebzeli Quinoa Pilavı', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Şehriye Çorbası (Sade): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Şehriye Çorbası (Sade)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Şehriye Çorbası (Sade)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Şehriye Çorbası (Sade)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Şehriyeli Bahar Pilavı: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Şehriyeli Bahar Pilavı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Şehriyeli Bahar Pilavı'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Şehriyeli Bahar Pilavı', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Şehriyeli Bulgur Pilavı (Ev Usulü): 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Şehriyeli Bulgur Pilavı (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Şehriyeli Bulgur Pilavı (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Şehriyeli Bulgur Pilavı (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Semizotlu Etli Yemek: 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Semizotlu Etli Yemek';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Semizotlu Etli Yemek'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Semizotlu Etli Yemek', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Semizotlu Yoğurt: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Semizotlu Yoğurt';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Semizotlu Yoğurt'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Soya Kıymalı Patlıcan Musakka (Etsiz): 400 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Soya Kıymalı Patlıcan Musakka (Etsiz)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Soya Kıymalı Patlıcan Musakka (Etsiz)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 400) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Soya Kıymalı Patlıcan Musakka (Etsiz)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Soya Kıymalı Zeytinyağlı Dolma: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Soya Kıymalı Zeytinyağlı Dolma';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Soya Kıymalı Zeytinyağlı Dolma'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Soya Kıymalı Zeytinyağlı Dolma', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Soyalı Biberli Sote (Etsiz): 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Soyalı Biberli Sote (Etsiz)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Soyalı Biberli Sote (Etsiz)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Soyalı Biberli Sote (Etsiz)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Tavuk Suyu Çorbası (Sade): 700 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Tavuk Suyu Çorbası (Sade)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Tavuk Suyu Çorbası (Sade)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 700) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Tavuk Suyu Çorbası (Sade)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Taze Fasulyeli Kuzu Güveç (İlkbahar): 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Fasulyeli Kuzu Güveç (İlkbahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Taze Fasulyeli Kuzu Güveç (İlkbahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Taze Fasulyeli Kuzu Güveç (İlkbahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Taze Fasulyeli Tavuk Güveç: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Fasulyeli Tavuk Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Taze Fasulyeli Tavuk Güveç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Taze Fasulyeli Tavuk Güveç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Taze Soğanlı Cacık: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Soğanlı Cacık';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Taze Soğanlı Cacık'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Taze Vişne Kompostosu: 600 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Vişne Kompostosu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Taze Vişne Kompostosu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 600) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Taze Vişne Kompostosu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 30 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Roka Soslu Izgara Tavuk', 'Roka Soslu Makarna', 'Rokalı Domates Salatası', 'Rokforlu Armut Salatası', 'Sade Ispanak Çorbası', 'Sade Kuzu Güveç (Et Suyu ile)', 'Salep (Ev Usulü)', 'Sarımsaklı Domates Soslu Makarna', 'Sebzeli Quinoa Pilavı', 'Şehriye Çorbası (Sade)', 'Şehriyeli Bahar Pilavı', 'Şehriyeli Bulgur Pilavı (Ev Usulü)', 'Semizotlu Etli Yemek', 'Semizotlu Yoğurt', 'Soya Kıymalı Patlıcan Musakka (Etsiz)', 'Soya Kıymalı Zeytinyağlı Dolma', 'Soyalı Biberli Sote (Etsiz)', 'Sucuklu Pilav', 'Sucuklu Yumurta (Tava)', 'Tahin Pekmez (Klasik)', 'Tarhana Çorbası (Ev Usulü)', 'Tavuk Suyu Çorbası (Sade)', 'Taze Bakla Kavurma (Etli)', 'Taze Fasulyeli Kuzu Güveç (İlkbahar)', 'Taze Fasulyeli Tavuk Güveç', 'Taze Soğanlı Cacık', 'Taze Vişne Kompostosu', 'Tereli Yoğurt Salatası', 'Turplu Yoğurt Salatası', 'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)') order by ad;

-- Dogrulama 2: 18 satir; Semizotlu Yoğurt ve Taze Soğanlı Cacık
-- disinda hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Roka Soslu Makarna', 'Sade Ispanak Çorbası', 'Sade Kuzu Güveç (Et Suyu ile)', 'Sarımsaklı Domates Soslu Makarna', 'Sebzeli Quinoa Pilavı', 'Şehriye Çorbası (Sade)', 'Şehriyeli Bahar Pilavı', 'Şehriyeli Bulgur Pilavı (Ev Usulü)', 'Semizotlu Etli Yemek', 'Semizotlu Yoğurt', 'Soya Kıymalı Patlıcan Musakka (Etsiz)', 'Soya Kıymalı Zeytinyağlı Dolma', 'Soyalı Biberli Sote (Etsiz)', 'Tavuk Suyu Çorbası (Sade)', 'Taze Fasulyeli Kuzu Güveç (İlkbahar)', 'Taze Fasulyeli Tavuk Güveç', 'Taze Soğanlı Cacık', 'Taze Vişne Kompostosu')
order by r.ad;
