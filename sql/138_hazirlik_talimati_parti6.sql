-- 138_hazirlik_talimati_parti6.sql
-- 244/245 eksik talimat gorevi, Parti 6: alfabetik 91-120.
-- NOT: 'Kaşarlı Fırın Makarna' tarifinde 2 isil asama var (Haşlama +
-- Fırınlama) -- su bu yuzden GENEL FILTRE degil, ASAMA ADINA GORE
-- ('Haşlama') baglaniyor, ayrica isleniyor.
-- NOT: 'Kırmızı Biberli Kıyma Sote' tarifinde recete_asamalari'nda
-- MUKERRER (duplicate) satirlar tespit edildi -- Hazırlık ve Sote
-- asamalari IKISER KEZ kayitli. Bu talimat/su gorevini ETKILEMIYOR
-- (bu tarife su eklenmiyor) ama enerji hesabini CIFT SAYIYOR olabilir --
-- Bahri'ye ayrica bildirildi, bu dosyada DUZELTILMEDI.
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
1. Tel kadayıfı elinizle havalandırıp kabaca kısaltarak servis kabına serin.

**Isıl İşlem**
1. Süt Pişirme (~95°C, tencerede, 30 dk): Sütü ve şekeri bir tencerede, şeker eriyene kadar karıştırarak ısıtın; kaynamaya yakın gelince ateşi kısın ve hafifçe koyulaşana kadar (~15 dk) pişirin.
2. Son işlemler: Sıcak sütü kadayıfın üzerine yavaşça, her yer eşit ıslanacak şekilde dökün. Süt tamamen çekilip kadayıf yumuşayana kadar (~10 dk) kendi halinde bekletin, ardından buzdolabında soğutup servis edin (soğutma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Kadayıf hazırlanırken süt ayrı ocakta pişirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Kadayıflı Süt Tatlısı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kadayıflı Süt Tatlısı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları rendenin iri tarafıyla rendeleyin.
2. Kajuları kabaca kırın.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.
4. Havuçları sosla karıştırıp servis öncesi kajuları üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Havuç rendelenirken sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Kajulu Havuç Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kajulu Havuç Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karabuğdayı süzgeçte durulayıp süzün.
2. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip karabuğdayı 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, karabuğday yıkanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Karabuğday Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karabuğday Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Hamsileri ayıklayıp iç organlarını ve kılçıklarını temizleyin (istenirse fileto bırakılabilir), yıkayıp süzün.
2. Mısır ununu tuzla karıştırın.
3. Hamsileri mısır ununa her yüzünden bulayın, fazla unu silkeleyin.

**Isıl İşlem**
1. Kızartma (orta-yüksek ateş, bol zeytinyağında, 15 dk): Zeytinyağını tavada kızdırın. Hamsileri tavayı sıkıştırmadan partiler halinde her yüzü altın rengi ve çıtır olana kadar (~2–3 dk her yüz) kızartın.
2. Son işlemler: Kızartılan hamsileri kağıt havlu serili bir tabağa alarak fazla yağını süzdürün.

**PARALEL YAPILABİLİRLİK:** Bir parti kızarırken diğer parti unlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Karadeniz Usulü Hamsi Tava';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karadeniz Usulü Hamsi Tava', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karidesleri kabuklarından ve damarlarından ayıklayın (istenirse kuyruk kısmı bırakılabilir).
2. Kuru soğanı küçük küp doğrayın, sarımsakları ince kıyın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Güveç Pişirme (~85°C, güveç kabında veya tavada, 23 dk): Zeytinyağında soğanı 3–4 dk kavurun, sarımsağı ekleyip 1 dk çevirin. Domatesi ekleyip 3–4 dk pişirin. 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyip 3–4 dk kaynatın. Karidesleri ekleyin; pembeleşip opak hale gelene kadar (~4–5 dk, fazla pişirmeyin) pişirin.

**PARALEL YAPILABİLİRLİK:** Sos hazırlanırken karidesler ayıklanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~8 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Karides Güveç (Ege Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karides Güveç (Ege Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karidesleri kabuklarından ve damarlarından ayıklayın.
2. Sarımsakları ince kıyın.
3. 3,5 litre (3500 g) suyu tencereye koyup kaynatmaya başlayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede + tavada, 20 dk): Kaynayan 3,5 litre suya tuz ekleyip makarnayı paket üzerindeki süreden 1 dk az haşlayın (al dente); haşlama suyundan 1 kepçe ayırıp makarnayı süzün. Makarna haşlanırken ayrı bir tavada zeytinyağında sarımsağı kısık ateşte 1–2 dk kavurun (yakmayın), karidesleri ekleyip pembeleşene kadar 3–4 dk soteleyin. Süzülen makarnayı, tuzu ve ayrılan haşlama suyunu tavaya ekleyip 1–2 dk karıştırarak birleştirin.

**PARALEL YAPILABİLİRLİK:** Makarna kaynayan suda haşlanırken karides sote ayrı tavada hazırlanır.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Karidesli Makarna';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karidesli Makarna', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Elmaları ve armutları yıkayıp soyun, çekirdek evlerini çıkarıp iri dilimler halinde doğrayın; kararmaması için pişirmeye kadar soğuk suda bekletin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 17 dk): 800 ml (800 g) suyu ve şekeri bir tencerede kaynatın. Meyveleri ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak meyveler yumuşayıp diri kalacak şekilde pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), meyveleri kendi şerbetiyle birlikte soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Karışık Meyve Kompostosu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karışık Meyve Kompostosu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Lahanayı ince şeritler halinde doğrayın.
2. Havuçları soyup ince çubuklar halinde kesin.
3. Salatalığı yıkayıp uçlarını kesin, ister bütün ister dilimli bırakın.
4. Sarımsakları soyun.
5. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin.
2. Son işlemler: Sebzeleri sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı sebzelerin üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Sebze ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Karışık Turşu (Ev Usulü, Sirkeli)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karışık Turşu (Ev Usulü, Sirkeli)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karnabaharı küçük çiçeklerine ayırıp yıkayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, karnabaharı ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp karnabahar tamamen yumuşayana kadar (~17–18 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Karnabahar Çorbası (Sonbahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karnabahar Çorbası (Sonbahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karnabaharı küçük çiçeklerine ayırıp yıkayın.
2. Havuçları soyup ince çubuklar halinde kesin.
3. Sarımsakları soyun.
4. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin.
2. Son işlemler: Karnabahar ve havucu sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı sebzelerin üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Sebze ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Karnabahar Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karnabahar Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Karnıbaharı küçük çiçeklerine ayırıp yıkayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Süt ile 700 ml (700 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, karnıbaharı ekleyip 2 dk çevirin. Süt-su karışımını ve tuzu ekleyin; kaynamaya yakın gelince ateşi kısıp karnıbahar tamamen yumuşayana kadar (~17–18 dk) pişirin (süt kaynarsa kesilebilir, dikkatli ısıtın).
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Karnıbahar Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Karnıbahar Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bulguru süzgeçte hızlıca durulayıp iyice süzdürün.
2. Kaşarı rendeleyin.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip bulguru 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak bulgur suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kaşarı serpip kapağı kapatarak kısa süre demlendirin, kaşar eridikten sonra karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, bulgur yıkanırken ısıtılabilir; kaşar rendelenirken pilav kısık ateşte pişebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kaşarlı Bulgur Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kaşarlı Bulgur Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 200°C'ye ısıtmaya başlayın.
2. Kaşarı rendeleyin.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 10 dk): Bol kaynar tuzlu suda makarnayı paket üzerindeki süreden 1–2 dk az haşlayın (al dente); süzün.
2. Fırınlama (200°C, 25 dk): Süzülen makarnayı eritilmiş tereyağının yarısıyla karıştırıp fırın kabına yayın. Üzerine rendelenmiş kaşarın çoğunu serpin, kalan tereyağını gezdirin, kalan kaşarı üzerine ekleyin. 200°C'ye önceden ısıtılmış fırında kaşar eriyip üzeri hafif kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken makarna haşlanıp kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~22 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Kaşarlı Fırın Makarna';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kaşarlı Fırın Makarna', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Kaşarı rendeleyin.
3. Tavuk suyu ile 100 ml (100 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağını tencerede eritip şehriyeyi hafif renk alana kadar 1–2 dk kavurun. Pirinci ekleyip 2 dk daha kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~15 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kaşarı serpip kapağı kapatarak kısa süre demlendirin, kaşar eridikten sonra karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Sıvı, pirinç yıkanırken ısıtılabilir; kaşar rendelenirken pilav kısık ateşte pişebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kaşarlı Şehriyeli Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kaşarlı Şehriyeli Pilav', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru kayısıları isterseniz ikiye bölün (daha çabuk yumuşar ve şerbeti çeker).

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 17 dk): 1 litre (1000 g) suyu ve şekeri bir tencerede kaynatın. Kuru kayısıları ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak kayısılar yumuşayıp şerbeti çekmeye başlayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), kayısıları kendi şerbetiyle birlikte soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Kayısı Kompostosu (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kayısı Kompostosu (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kayısıları yıkayıp çekirdeklerini çıkarın, küçük dilimler halinde kesin.
2. Süzme yoğurdu şekerle çırpın.
3. Kayısıların çoğunu yoğurda ekleyip nazikçe karıştırın; kalanını servis sırasında üzerine dizin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yoğurt çırpılırken kayısılar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Kayısılı Yoğurt';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kayısılı Yoğurt', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Keçi etini 2–2,5 cm kuşbaşı doğrayın.
2. Patatesleri soyup iri küp doğrayın; kararmaması için soğuk suda bekletin.
3. Kuru soğanı küçük küp doğrayın.
4. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
5. 1,8 litre (1800 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Güveç Pişirme (~95°C, güveç kabında veya tencerede kısık ateşte, 80 dk): Zeytinyağında eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk, domatesi ekleyip 2–3 dk daha kavurun. 1,8 litre sıcak suyu, tuzu ve karabiberi ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar pişirin. Pişirmenin son 20 dakikasında süzülmüş patatesleri ekleyip et ve patatesler tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; güveç kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~70 dk · Toplam ~100 dk$t$
    where isletme_id is null and ad = 'Keçi Eti Güveç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Keçi Eti Güveç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pancarları iyice yıkayın, saplarını kısa bırakarak (kabuğu haşlarken soyulacak) temizleyin.
2. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.

**Isıl İşlem**
1. Haşlama (~95°C, tencerede, 17 dk): Tencereye 1,5 litre (1500 g) su koyup kaynatın. Pancarları ekleyip çatal rahatça batana kadar haşlayın (boyutlarına göre bu süre uzayabilir).
2. Son işlemler: Pancarları süzüp ılınca kabuklarını soyun (eldiven kullanmanız önerilir, boya lekesi yapar), dilimleyip sosla ve ufalanmış keçi peyniriyle servis edin.

**PARALEL YAPILABİLİRLİK:** Sos, pancarlar haşlanırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Keçi Peynirli Pancar Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Keçi Peynirli Pancar Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Salatalıkları yıkayın, uçlarını kesip küçük küp doğrayın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Kefiri sarımsakla karıştırın, salatalığı ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Kefirli Salatalık';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kefirli Salatalık', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, kereviği ekleyip 2–3 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp kereviz tamamen yumuşayana kadar (~17–18 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Kerevizli Çorba';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kerevizli Çorba', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuzu kol etini kemik ve fazla yağından ayırıp 2–2,5 cm kuşbaşı doğrayın.
2. Kereviği soyup iri küp doğrayın.
3. Havuçları kazıyıp iri küp doğrayın.
4. Kuru soğanı soyup küçük küp doğrayın.
5. 1,3 litre (1300 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Yahni Pişirme (~95°C, tencerede kısık ateşte, 45 dk): Zeytinyağında eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk kavurun. 1,3 litre sıcak suyu ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar pişirin. Pişirmenin son 20 dakikasında kereviz, havuç, tuz ve karabiberi ekleyin; et ve sebzeler tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; yahni kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~35 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Kerevizli Kuzu Yahnisi';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kerevizli Kuzu Yahnisi', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2 cm kuşbaşı doğrayın.
2. Kereviği ve havuçları küçük küp doğrayın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağını kızdırıp tavukları tavayı doldurmadan her yüzü renk alana kadar soteleyin (~6–7 dk). Kereviği ve havucu ekleyip 3–4 dk çevirin. 100 ml (100 g) suyu ekleyip kapağı kapatarak sebzeler yumuşayana kadar 5–6 dk buharda pişirin. Kapağı açıp kalan suyu uçurun, tuz ve karabiberi ekleyip 1–2 dk çevirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Sote sürekli takip gerektirdiği için paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Kerevizli Tavuk Sote';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kerevizli Tavuk Sote', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kereviği küçük küp doğrayın.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 10 dk): Tencereye 1 litre (1000 g) su koyup kaynatın. Kereviği ekleyip diri kalacak şekilde 5–6 dk haşlayın. Süzüp hemen soğuk suya alarak pişmeyi durdurun, iyice süzdürün.
2. Son işlemler: Soğumuş kereviz, sarımsaklı yoğurtla karıştırılıp soğuk servis edilir.

**PARALEL YAPILABİLİRLİK:** Sarımsaklı yoğurt, haşlama suyu kaynarken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~8 dk · Pasif bekleme ~7 dk · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Kerevizli Yoğurt Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kerevizli Yoğurt Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Bademleri kabuklarını soyup ince öğütün veya iyice kıyın.
2. Mısır nişastasını birkaç kaşık soğuk sütle pürüzsüz bir bulamaç haline getirin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 20 dk): Kalan sütü, şekeri ve öğütülmüş bademi bir tencerede ısıtın; kaynamaya yakın gelince nişasta bulamacını azar azar ekleyip sürekli karıştırarak kıvam koyulaşana kadar (~10–12 dk) pişirin.
2. Son işlemler: Servis kaplarına paylaştırıp üzerini streç filmle (yüzeyine değecek şekilde) kapatarak kabuk bağlamasını önleyin. Oda sıcaklığında ılıyınca buzdolabına kaldırıp soğutun (soğutma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Nişasta bulamacı, süt ısıtılırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk · Pasif bekleme ~8 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Keşkül (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Keşkül (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Kestane mantarlarını temizleyip dilimleyin.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağında mantarları suyunu salıp çekene kadar 4–5 dk kavurun. Pirinci ekleyip taneler şeffaflaşana kadar 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~18 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, mantar ve pirinç hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Kestane Mantarlı Pirinç Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kestane Mantarlı Pirinç Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Kestaneleri (haşlanmış/kabuğu soyulmuş) iri parçalar halinde bölün.
3. Tavuk suyunu ölçüp ocağın yanında hazır tutun.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 28 dk): Tereyağını tencerede eritip kestaneleri 2–3 dk çevirin. Pirinci ekleyip taneler şeffaflaşana kadar 2 dk kavurun. Sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~20 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu, kestane ve pirinç hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Kestaneli Sonbahar Pilavı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kestaneli Sonbahar Pilavı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kırmızı biberleri yıkayın; sap ve çekirdeklerini çıkarıp iri parçalar veya bütün bırakın (kürdanla birkaç yerinden delin).
2. Sarımsakları soyun.
3. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin.
2. Son işlemler: Biberleri sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı biberlerin üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Biber ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kırmızı Biber Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kırmızı Biber Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kırmızı biberleri çekirdeklerinden ayıklayıp iri doğrayın.
2. Kuru soğanı küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Sote (orta-yüksek ateş, geniş tavada, 20 dk): Zeytinyağında soğanı 2–3 dk kavurun. Kıymayı ekleyip suyunu salıp çekene ve renk alana kadar (~8 dk) kavurun. Biberi ekleyip 3–4 dk çevirin. Domates, tuz ve karabiberi ekleyin; domates suyunu salıp çekene kadar (~5–6 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kırmızı Biberli Kıyma Sote';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kırmızı Biberli Kıyma Sote', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kırmızı mercimeği ayıklayıp yıkayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun. Mercimeği ekleyip 1–2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp mercimek tamamen dağılıp yumuşayana kadar (~17–18 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler hazırlanırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Kırmızı Mercimek Çorbası (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kırmızı Mercimek Çorbası (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Kırmızı mercimeği ayıklayıp yıkayın.
3. Kuru soğanı küçük küp doğrayın.
4. Tavuk suyu ile 300 ml (300 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağında soğanı 3–4 dk kavurun. Mercimeği ekleyip 2 dk çevirin. Pirinci ekleyip 1–2 dk daha kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak suyunu çekene kadar (~13–14 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebze ve tahıllar hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Kırmızı Mercimekli Pilav';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Kırmızı Mercimekli Pilav', v_n; end if;

    ---------------- B) SU MALZEMESI (genel -- tek isil asama) ----------------
    -- Karides Güveç (Ege Usulü): 150 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karides Güveç (Ege Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karides Güveç (Ege Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 150) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karides Güveç (Ege Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Karidesli Makarna: 3500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karidesli Makarna';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karidesli Makarna'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 3500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karidesli Makarna', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Karışık Meyve Kompostosu: 800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karışık Meyve Kompostosu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karışık Meyve Kompostosu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karışık Meyve Kompostosu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Karışık Turşu (Ev Usulü, Sirkeli): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karışık Turşu (Ev Usulü, Sirkeli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karışık Turşu (Ev Usulü, Sirkeli)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karışık Turşu (Ev Usulü, Sirkeli)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Karnabahar Çorbası (Sonbahar): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnabahar Çorbası (Sonbahar)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karnabahar Çorbası (Sonbahar)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karnabahar Çorbası (Sonbahar)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Karnabahar Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnabahar Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karnabahar Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karnabahar Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Karnıbahar Çorbası: 700 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnıbahar Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Karnıbahar Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 700) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Karnıbahar Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kaşarlı Şehriyeli Pilav: 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kaşarlı Şehriyeli Pilav';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kaşarlı Şehriyeli Pilav'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kaşarlı Şehriyeli Pilav', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kayısı Kompostosu (Ev Usulü): 1000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kayısı Kompostosu (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kayısı Kompostosu (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kayısı Kompostosu (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Keçi Eti Güveç: 1800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Keçi Eti Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Keçi Eti Güveç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Keçi Eti Güveç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Keçi Peynirli Pancar Salatası: 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Keçi Peynirli Pancar Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Keçi Peynirli Pancar Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Keçi Peynirli Pancar Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kerevizli Çorba: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Çorba';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kerevizli Çorba'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kerevizli Çorba', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kerevizli Kuzu Yahnisi: 1300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Kuzu Yahnisi';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kerevizli Kuzu Yahnisi'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kerevizli Kuzu Yahnisi', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kerevizli Tavuk Sote: 100 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Tavuk Sote';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kerevizli Tavuk Sote'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 100) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kerevizli Tavuk Sote', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kerevizli Yoğurt Salatası: 1000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Yoğurt Salatası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kerevizli Yoğurt Salatası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kerevizli Yoğurt Salatası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kırmızı Biber Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Biber Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kırmızı Biber Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kırmızı Biber Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kırmızı Mercimek Çorbası (Ev Usulü): 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Mercimek Çorbası (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kırmızı Mercimek Çorbası (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kırmızı Mercimek Çorbası (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Kırmızı Mercimekli Pilav: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Mercimekli Pilav';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kırmızı Mercimekli Pilav'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Kırmızı Mercimekli Pilav', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    ---------------- C) SU MALZEMESI (ozel -- Kaşarlı Fırın Makarna, ASAMA ADINA GORE) ----------------
    -- Kaşarlı Fırın Makarna: 3500 g su (Haşlama asamasina baglanir)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kaşarlı Fırın Makarna';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Kaşarlı Fırın Makarna'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 3500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and ad = 'Haşlama' and isil_islem_mi;
    if v_n <> 1 then raise exception 'Haşlama asamasi sayisi 1 degil (%) -- Kaşarlı Fırın Makarna', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and ad = 'Haşlama' and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 30 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Kadayıflı Süt Tatlısı', 'Kajulu Havuç Salatası', 'Karabuğday Pilavı', 'Karadeniz Usulü Hamsi Tava', 'Karides Güveç (Ege Usulü)', 'Karidesli Makarna', 'Karışık Meyve Kompostosu', 'Karışık Turşu (Ev Usulü, Sirkeli)', 'Karnabahar Çorbası (Sonbahar)', 'Karnabahar Turşusu', 'Karnıbahar Çorbası', 'Kaşarlı Bulgur Pilavı', 'Kaşarlı Fırın Makarna', 'Kaşarlı Şehriyeli Pilav', 'Kayısı Kompostosu (Ev Usulü)', 'Kayısılı Yoğurt', 'Keçi Eti Güveç', 'Keçi Peynirli Pancar Salatası', 'Kefirli Salatalık', 'Kerevizli Çorba', 'Kerevizli Kuzu Yahnisi', 'Kerevizli Tavuk Sote', 'Kerevizli Yoğurt Salatası', 'Keşkül (Ev Usulü)', 'Kestane Mantarlı Pirinç Pilavı', 'Kestaneli Sonbahar Pilavı', 'Kırmızı Biber Turşusu', 'Kırmızı Biberli Kıyma Sote', 'Kırmızı Mercimek Çorbası (Ev Usulü)', 'Kırmızı Mercimekli Pilav') order by ad;

-- Dogrulama 2: 19 satir; hepsinde isil_asama dolu olmali (Kaşarlı Fırın
-- Makarna'da 'Haşlama' gorunmeli, 'Fırınlama' degil).
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Karides Güveç (Ege Usulü)', 'Karidesli Makarna', 'Karışık Meyve Kompostosu', 'Karışık Turşu (Ev Usulü, Sirkeli)', 'Karnabahar Çorbası (Sonbahar)', 'Karnabahar Turşusu', 'Karnıbahar Çorbası', 'Kaşarlı Şehriyeli Pilav', 'Kayısı Kompostosu (Ev Usulü)', 'Keçi Eti Güveç', 'Keçi Peynirli Pancar Salatası', 'Kerevizli Çorba', 'Kerevizli Kuzu Yahnisi', 'Kerevizli Tavuk Sote', 'Kerevizli Yoğurt Salatası', 'Kırmızı Biber Turşusu', 'Kırmızı Mercimek Çorbası (Ev Usulü)', 'Kırmızı Mercimekli Pilav', 'Kaşarlı Fırın Makarna')
order by r.ad;

-- Dogrulama 3 (BILGI AMACLI -- bu dosya bunu DUZELTMIYOR): 'Kırmızı
-- Biberli Kıyma Sote' icin mukerrer asama satirlarini goster.
select ad, sira, sure_dakika, isil_islem_mi, count(*) as tekrar_sayisi
from recete_asamalari
where recete_id = (select id from receteler where isletme_id is null and ad = 'Kırmızı Biberli Kıyma Sote')
group by ad, sira, sure_dakika, isil_islem_mi
order by sira;
