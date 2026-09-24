-- 141_hazirlik_talimati_parti8.sql
-- 244/245 eksik talimat gorevi, Parti 8: alfabetik 151-180.
-- Bu partiden bazi tarifler (Nar Ekşili Dana Rosto, Nohutlu Sığır
-- Kavurma, Otlu Izgara Çipura, Pastırmalı Kavurma, Patatesli Dana
-- Güveç, Patlıcanlı Kıyma Musakka, Pırasalı Kıymalı Bahar Yemeği)
-- 139 numarali migration'la TEMIZLENEN mukerrer-asama tarifleriydi --
-- 139'un DAHA ONCE calistirilmis olmasi VARSAYILIYOR (dogrulandi).
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
1. Salatalıkları yıkayın, uçlarını kesip küçük küp doğrayın veya iri rendeleyin; rendelenmişse suyunu hafifçe sıkın.
2. Taze naneyi ince kıyın.
3. Yoğurdu pürüzsüz olana kadar çırpın.
4. 300 ml (300 g) soğuk içme suyunu azar azar ekleyerek çırpın ve akışkan cacık kıvamı elde edin.
5. Salatalık ve naneyi ekleyip karıştırın; soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Naneli Cacık (Klasik)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Naneli Cacık (Klasik)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Yoğurdu geniş bir kapta pürüzsüz olana kadar çırpın.
2. 350 ml (350 g) soğuk içme suyunu azar azar ekleyerek çırpmaya devam edin.
3. Kuru naneyi ve tuzu ekleyip iyice karıştırın.
4. Soğuk servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk$t$
    where isletme_id is null and ad = 'Naneli Yoğurt';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Naneli Yoğurt', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 180°C'ye ısıtmaya başlayın.
2. Dana rostoyu kağıt havluyla kurulayın.
3. Kuru soğanı ince yarım ay dilimleyin.
4. Nar ekşisi, zeytinyağı, tuz ve karabiberi karıştırıp etin her yüzüne ovun.

**Isıl İşlem**
1. Rosto Pişirme (180°C, 70 dk): Soğanı fırın kabının tabanına yayın, eti üzerine yerleştirin. Tepsinin dibine 200 ml (200 g) su ekleyin. Kabı folyoyla sıkıca kapatıp 180°C'ye önceden ısıtılmış fırında 55 dakika pişirin. Folyoyu açıp üzeri hafif kızarana kadar son 15 dakika folyosuz pişirin. Etin en kalın yerinde iç sıcaklık en az 63°C (orta pişmişlik) olmalı.
2. Son işlemler: Fırından çıkarıp 10 dk dinlendirdikten sonra dilimleyin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken baharatlama yapılabilir; fırınlama sırasında garnitür hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~60 dk · Toplam ~90 dk$t$
    where isletme_id is null and ad = 'Nar Ekşili Dana Rosto';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Nar Ekşili Dana Rosto', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Maydanozu ince kıyın.
2. İnce bulguru geniş bir kaba alın.
3. Domates salçasını 500 ml (500 g) sıcak suyla açın.

**Isıl İşlem**
1. Bulgur Haşlama (~90°C, kaseye kaynar salçalı su dökerek, 12 dk): Sıcak salçalı suyu bulgurun üzerine dökün. Kabı kapatıp bulgur suyunu tamamen çekip yumuşayana kadar (~6 dk) demlenmeye bırakın.
2. Son işlemler: Bulguru çatalla havalandırıp nar ekşisi, maydanoz, zeytinyağı ve tuzla yoğurarak karıştırın.

**PARALEL YAPILABİLİRLİK:** Salçalı su hazırlanırken maydanoz kıyılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~24 dk · Pasif bekleme ~6 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Nar Ekşili Kısır';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Nar Ekşili Kısır', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iyice süzdürün, iri kıyın veya bütün yapraklar halinde bırakın.
2. Narı taneleyin.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.
4. Ispanak, nar taneleri ve sosu servisten hemen önce karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Ispanak süzülürken nar taneleneb ilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Narlı Ispanak Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Narlı Ispanak Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Nohudu pişirmeden en az 8 saat (tercihen bir gece) önce bol soğuk suda ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Sarımsakları soyun.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 15 dk): Tencereye 1,5 litre (1500 g) su koyup kaynatın. Islatılmış nohudu ekleyip taneler yumuşayana kadar (ıslatma kalitesine göre süre değişebilir) haşlayın.
2. Son işlemler: Nohudu süzüp ılımaya bırakın (soğuma süresi özete dahil değildir). Sarımsak, zeytinyağı, limon suyu ve tuzla birlikte pürüzsüz olana kadar parçalayıcıdan geçirin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken sarımsak hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~10 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Nohut Ezmesi (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Nohut Ezmesi (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pirinci suyu berraklaşana kadar birkaç kez yıkayıp süzün.
2. Nohudu (haşlanmış/konserve) süzüp durulayın.
3. Tavuk suyu ile 200 ml (200 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağını tencerede eritip nohudu 2 dk çevirin. Pirinci ekleyip taneler şeffaflaşana kadar 2 dk kavurun. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi en kısığa alıp kapağı kapalı olarak pirinç suyunu çekene kadar (~17 dk) pişirin.
2. Son işlemler: Ocağı kapatın, kapağın altına temiz bir bez koyarak kısa süre demlendirin.

**PARALEL YAPILABİLİRLİK:** Sıvı, pirinç ve nohut hazırlanırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Nohutlu Pilav (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Nohutlu Pilav (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Kuru soğanı küçük küp doğrayın.
2. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
3. Nohudu (haşlanmış/konserve) süzüp durulayın.

**Isıl İşlem**
1. Kavurma (orta-yüksek ateş, tencerede, 40 dk): Tereyağında kıymayı iri topaklarını dağıtarak suyunu salıp çekene ve tane tane olana kadar (~12–15 dk) kavurun. Soğanı ekleyip 3–4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu, tuz ve karabiberi ekleyip 8–10 dk daha karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~30 dk · Toplam ~55 dk$t$
    where isletme_id is null and ad = 'Nohutlu Sığır Kavurma (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Nohutlu Sığır Kavurma (Bahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Tavuk göğsünü kurulayıp 2–3 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Nohudu (haşlanmış/konserve) süzüp durulayın.

**Isıl İşlem**
1. Güveç Pişirme (~95°C, güveç kabında veya tencerede kısık ateşte, 30 dk): Zeytinyağında soğanı 3–4 dk kavurun, tavukları ekleyip her yüzü renk alana kadar 5–6 dk çevirin. Domatesi ekleyip 3 dk pişirin. Nohudu, tuz ve karabiberi ekleyin. 200 ml (200 g) sıcak suyu ekleyin; kapağı kapatıp tavuk tamamen yumuşayana kadar kısık ateşte pişirin. Tavuğun en kalın parçasında iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~22 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Nohutlu Tavuk Güveç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Nohutlu Tavuk Güveç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Çipuraları (temizletilmiş, pullarından arındırılmış) yıkayıp kağıt havluyla kurulayın, her iki yüzüne çapraz kesikler atın.
2. Feslegeni ince kıyıp zeytinyağı, limon suyu ve tuzla karıştırın; balıkların içine ve her yüzüne sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 18 dk): Iyice ısıtılmış ızgarada balıkları her yüzü 7–8 dk olacak şekilde çevirerek, etin en kalın yerinde çatalla kolayca dağılana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken balıklar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~3 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Otlu Izgara Çipura';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Otlu Izgara Çipura', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pancarları soyup küçük küp doğrayın (eldiven kullanmanız önerilir, boya lekesi yapar).
2. Kuru soğanı soyup küçük küp doğrayın.
3. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 28 dk): Tereyağında soğanı 3–4 dk kavurun, pancarı ekleyip 2 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp pancar tamamen yumuşayana kadar (~20 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Pancar Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Pancar Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pancarları iyice yıkayın, saplarını kısa bırakarak temizleyin.
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.

**Isıl İşlem**
1. Haşlama (~95°C, tencerede, 17 dk): Tencereye 1,5 litre (1500 g) su koyup kaynatın. Pancarları ekleyip çatal rahatça batana kadar haşlayın (boyutlarına göre bu süre uzayabilir).
2. Son işlemler: Pancarları süzüp ılınca kabuklarını soyun, küçük küp doğrayıp sarımsaklı yoğurtla karıştırın, soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Sarımsaklı yoğurt, pancarlar haşlanırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Pancar Salatası (Yoğurtlu)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Pancar Salatası (Yoğurtlu)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pastırmayı ince dilimler halinde kesin veya hazır dilimli kullanın.
2. Kaşarı ince dilimler halinde kesin.
3. Pastırma ve kaşarı servis tabağına art arda veya iç içe dizin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~5 dk · Pasif bekleme yok · Toplam ~5 dk$t$
    where isletme_id is null and ad = 'Pastırmalı Kaşar Tabağı';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Pastırmalı Kaşar Tabağı', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pastırmayı ince şeritler halinde doğrayın.
2. Dana bonfileyi 1,5–2 cm kuşbaşı doğrayın.
3. Kuru soğanı küçük küp doğrayın.
4. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (yüksek ateş, tencerede, 17 dk): Yağsız bir tencerede pastırmayı 2–3 dk kendi yağını salana kadar kavurun. Bonfileyi ekleyip her yüzü renk alana kadar 4–5 dk çevirin (pastırmanın tuzu ve baharatı nedeniyle ayrıca tuz eklemeden önce tadına bakın). Soğanı ekleyip 3–4 dk kavurun. Domates ve karabiberi ekleyip domates suyunu salıp çekene kadar (~5–6 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Pastırma ve et kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Pastırmalı Kavurma';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Pastırmalı Kavurma', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patatesleri iyice yıkayın (kabuklarıyla haşlanacak).
2. Maydanozu ince kıyın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 20 dk): Tencereye 2 litre (2000 g) su koyup kaynatın. Patatesleri ekleyip çatal rahatça batana kadar haşlayın.
2. Son işlemler: Patatesleri süzüp ılınca kabuklarını soyup küp doğrayın. Yoğurt, zeytinyağı, maydanoz ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken maydanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Patates Salatası (Yoğurtlu)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Patates Salatası (Yoğurtlu)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Dana butu 2–2,5 cm kuşbaşı doğrayın.
2. Patatesleri soyup iri küp doğrayın; kararmaması için soğuk suda bekletin.
3. Havuçları kazıyıp iri küp doğrayın.
4. Kuru soğanı küçük küp doğrayın.
5. 1,8 litre (1800 g) suyu ayrı bir kapta ısıtın.

**Isıl İşlem**
1. Güveç Pişirme (~95°C, güveç kabında veya tencerede kısık ateşte, 55 dk): Zeytinyağında eti yüksek ateşte suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3–4 dk kavurun. 1,8 litre sıcak suyu, tuzu ve karabiberi ekleyin; kaynayınca ateşi kısın, kapağı kapalı olarak et yumuşamaya başlayana kadar (~25 dk) pişirin. Süzülmüş patatesleri ve havucu ekleyip sebzeler ve et tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, doğrama sırasında ısıtılabilir; güveç kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~45 dk · Toplam ~75 dk$t$
    where isletme_id is null and ad = 'Patatesli Dana Güveç';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Patatesli Dana Güveç', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patatesleri soyup küçük küp doğrayın.
2. Havuçları kazıyıp küçük küp doğrayın.
3. Kuru soğanı soyup küçük küp doğrayın.
4. Tavuk suyu ile 500 ml (500 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, havuç ve patatesi ekleyip 2–3 dk çevirin. Sıcak sıvıyı ve tuzu ekleyin; kaynayınca ateşi kısıp sebzeler tamamen yumuşayana kadar (~17 dk) pişirin.
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin (isterseniz bir kısmını parçalı bırakabilirsiniz).

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Patatesli Sebze Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Patatesli Sebze Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patlıcanları yıkayıp kurulayın; birkaç yerinden çatalla delin (közlerken patlamasını önler).
2. Sarımsakları soyup tuzla birlikte ezin.
3. Yoğurdu pürüzsüz olana kadar çırpıp sarımsakla karıştırın.

**Isıl İşlem**
1. Közleme (ocak alevinde veya fırın ızgarasında ~200°C, 20 dk): Patlıcanları doğrudan alev üzerinde veya fırının ızgara moduna yakın konumunda, kabukları her yüzden simsiyah kömürleşip için tamamen yumuşayana kadar arada çevirerek közleyin.
2. Son işlemler: Közlenen patlıcanları ılıyınca kabuklarını soyun (soğuk suda çalkalamak kabuk soyma işlemini kolaylaştırır ama lezzeti hafif azaltabilir), etini çatalla ezin. Sarımsaklı yoğurt ve zeytinyağıyla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Patlıcanlar közlenirken sarımsaklı yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Patlıcan Salatası (Közlenmiş)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Patlıcan Salatası (Közlenmiş)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Küçük boy patlıcanları yıkayıp saplarını kısaltın; kabuklarını yer yer soyarak çizgili bırakın (turşuda acılığı azaltır).
2. Sarımsakları soyun.
3. Turşu kavanozunu kaynar suyla çalkalayıp kurumaya bırakın.

**Isıl İşlem**
1. Salamura Kaynatma (~100°C, tencerede, 20 dk): 500 ml (500 g) su ile tuzu kaynatın, tuz tamamen eriyene kadar kaynatmaya devam edin. Ocaktan alıp ılımaya bırakın, ardından sirkeyi ekleyin.
2. Son işlemler: Patlıcanları sarımsakla birlikte kavanoza sıkıca dizin. Ilımış salamurayı patlıcanların üzerini tamamen örtecek şekilde dökün. Kavanozu kapatıp serin, güneş görmeyen bir yerde olgunlaşmaya bırakın (olgunlaşma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Patlıcan ve kavanoz hazırlığı salamura kaynarken ve ılırken yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk$t$
    where isletme_id is null and ad = 'Patlıcan Turşusu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Patlıcan Turşusu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Patlıcanları 1 cm kalınlığında dilimleyip hafif tuzlayarak 10 dk (aşağıdaki süreye dahil değildir) acı suyunu çıkarmaya bırakın, sonra kurulayın.
2. Kuru soğanı küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede/tavada, 40 dk): Patlıcan dilimlerini zeytinyağında her iki yüzü hafif kızarana kadar 2–3 dk'şar sote edip bir kaba alın. Aynı yağda soğanı 3–4 dk kavurun, kıymayı ekleyip suyunu salıp çekene kadar (~8 dk) kavurun. Domatesi, tuz ve karabiberi ekleyip 300 ml (300 g) sıcak su ile 15–18 dk kısık ateşte pişirin. Patlıcanları harca ekleyip 3–4 dk daha kaynatın.

**PARALEL YAPILABİLİRLİK:** Kıyma sosu pişerken patlıcanlar sotelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~30 dk · Toplam ~60 dk$t$
    where isletme_id is null and ad = 'Patlıcanlı Kıyma Musakka';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Patlıcanlı Kıyma Musakka', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pazıyı yıkayıp sap kısımlarını ince, yaprak kısımlarını iri doğrayın.
2. Kuru soğanı küçük küp doğrayın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın.
4. Nohudu (haşlanmış/konserve) süzüp durulayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 35 dk): Zeytinyağında soğanı 3–4 dk kavurun, pazının sap kısmını ekleyip 2–3 dk çevirin. Domatesi ekleyip 3 dk pişirin. Nohut, tuz ve 500 ml (500 g) sıcak suyu ekleyin; kaynayınca ateşi kısıp 12–13 dk pişirin. Pazının yaprak kısmını ekleyip pörsüyene kadar (~5 dk) pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Su, sebzeler doğranırken ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~27 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Pazılı Nohut Yemeği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Pazılı Nohut Yemeği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 190°C'ye ısıtmaya başlayın.
2. Kabakları rendenin iri tarafıyla rendeleyip tuzla ovun, 10 dk (aşağıdaki süreye dahil değildir) bekletip suyunu avuçla iyice sıkın.
3. Feta peynirini ufalayıp sıkılmış kabakla karıştırın.
4. Tereyağını eritin; yumurtaları çırpıp erimiş tereyağının yarısıyla karıştırın (üstüne sürmek için birkaç kaşık ayırın).
5. Tepsiyi yağlayın. Yufkaları kat kat serin, her katın arasına yağlı yumurta karışımı sürün. Harcı ortadaki kata eşit yayın, kalan yufkalarla kapatın.
6. Üst yüzeye ayırdığınız karışımı sürün ve böreği pişirmeden önce servis dilimlerine kesin.

**Isıl İşlem**
1. Fırınlama (~190°C, fırında, 25 dk): 190°C'ye önceden ısıtılmış fırının orta rafında üstü ve altı altın rengi olana kadar pişirin.
2. Son işlemler: Birkaç dakika dinlendirip kesik yerlerinden ayırarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kabak ve harç hazırlığı yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~20 dk · Toplam ~50 dk$t$
    where isletme_id is null and ad = 'Peynirli Kabak Böreği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Peynirli Kabak Böreği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Fırını 190°C'ye ısıtmaya başlayın.
2. Feta peynirini ufalayın.
3. Tereyağını eritin; yumurtaları çırpıp erimiş tereyağının yarısıyla karıştırın (üstüne sürmek için birkaç kaşık ayırın).
4. Tepsiyi yağlayın. Yufkaları kat kat serin, her katın arasına yağlı yumurta karışımı sürün. Peyniri ortadaki kata eşit yayın, kalan yufkalarla kapatın.
5. Üst yüzeye ayırdığınız karışımı sürün ve böreği pişirmeden önce servis dilimlerine kesin.

**Isıl İşlem**
1. Fırınlama (~190°C, fırında, 23 dk): 190°C'ye önceden ısıtılmış fırının orta rafında üstü ve altı altın rengi olana kadar pişirin.
2. Son işlemler: Birkaç dakika dinlendirip kesik yerlerinden ayırarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken harç hazırlığı yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~18 dk · Toplam ~45 dk$t$
    where isletme_id is null and ad = 'Peynirli Yaz Böreği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Peynirli Yaz Böreği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Pırasayı temizleyip yıkayın, ince halkalar halinde doğrayın.
2. Kuru soğanı küçük küp doğrayın.
3. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 28 dk): Zeytinyağında soğanı 3–4 dk kavurun, kıymayı ekleyip suyunu salıp çekene kadar (~8 dk) kavurun. Pırasayı ekleyip 3–4 dk çevirin. Pirinç, tuz, karabiber ve 500 ml (500 g) sıcak suyu ekleyin; kaynayınca ateşi kısıp pirinç ve pırasa tamamen yumuşayana kadar (~12–13 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken pırasa ve pirinç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk$t$
    where isletme_id is null and ad = 'Pırasalı Kıymalı Bahar Yemeği';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Pırasalı Kıymalı Bahar Yemeği', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Portakalları soyup zarlarından ayırarak fileto şeklinde dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 17 dk): 800 ml (800 g) suyu ve şekeri bir tencerede kaynatın. Portakal dilimlerini ekleyip kaynayınca ateşi kısıp kapağı kapalı olarak 5–6 dk hafifçe pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk$t$
    where isletme_id is null and ad = 'Portakal Kompostosu (Ev Usulü)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Portakal Kompostosu (Ev Usulü)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Portakal ve limonları soyup zarlarından ayırarak fileto şeklinde dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 14 dk): 600 ml (600 g) suyu ve şekeri bir tencerede kaynatın. Meyve dilimlerini ekleyip kaynayınca ateşi kısıp kapağı kapalı olarak 4–5 dk hafifçe pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~11 dk · Pasif bekleme ~9 dk · Toplam ~20 dk$t$
    where isletme_id is null and ad = 'Portakal ve Limon Kompostosu';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Portakal ve Limon Kompostosu', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Havuçları rendenin iri tarafıyla rendeleyin.
2. Portakalları soyup zarlarından ayırarak fileto şeklinde dilimleyin.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.
4. Havuç ve portakalı sosla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Havuç rendelenirken portakal dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Portakallı Havuç Salatası (Bahar)';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Portakallı Havuç Salatası (Bahar)', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Portakal ve mandalinaları soyup zarlarından ayırarak fileto şeklinde dilimleyin.
2. Zeytinyağı ve şekeri karıştırarak hafif bir sos hazırlayın.
3. Meyveleri sosla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Meyveler hazırlanırken sos karıştırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Portakallı Mandalinalı Kış Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Portakallı Mandalinalı Kış Salatası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Rezeneyi yıkayıp sert dış yapraklarını ayıklayın, küçük küp doğrayın.
2. Kuru soğanı soyup küçük küp doğrayın.
3. Süt ile 600 ml (600 g) suyu birlikte ölçün.

**Isıl İşlem**
1. Çorba Pişirme (~95°C, tencerede, 25 dk): Tereyağında soğanı 3–4 dk kavurun, rezeneyi ekleyip 2–3 dk çevirin. Süt-su karışımını ve tuzu ekleyin; kaynamaya yakın gelince ateşi kısıp rezene tamamen yumuşayana kadar (~17 dk) pişirin (süt kaynarsa kesilebilir, dikkatli ısıtın).
2. Son işlemler: Ocaktan alıp el blenderiyle pürüzsüz olana kadar çekin.

**PARALEL YAPILABİLİRLİK:** Sıvı, sebzeler doğranırken ısıtılabilir; çorba kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk$t$
    where isletme_id is null and ad = 'Rezene Çorbası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Rezene Çorbası', v_n; end if;

    update receteler set hazirlik_talimati = $t$**Hazırlık / Mise en Place**
1. Roka ve marulu ayıklayıp yıkayın, iyice süzdürün, elinizle parçalayın.
2. Turpları ince dilimleyin.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın; servisten hemen önce yeşilliklerle karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yeşillikler süzülürken turp dilimlenip sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk$t$
    where isletme_id is null and ad = 'Roka Marul Salatası';
    get diagnostics v_n = row_count;
    if v_n <> 1 then raise exception 'Talimat: beklenmeyen satir sayisi (%) -- Roka Marul Salatası', v_n; end if;

    ---------------- B) SU MALZEMESI ----------------
    -- Naneli Cacık (Klasik): 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Naneli Cacık (Klasik)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Naneli Cacık (Klasik)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Naneli Yoğurt: 350 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Naneli Yoğurt';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Naneli Yoğurt'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 350) returning id into v_rm_id;
    -- Isil islem asamasi yok (soguk karistirma) -- asama_malzemeleri eklenmez.

    -- Nar Ekşili Dana Rosto: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nar Ekşili Dana Rosto';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Nar Ekşili Dana Rosto'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Nar Ekşili Dana Rosto', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Nar Ekşili Kısır: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nar Ekşili Kısır';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Nar Ekşili Kısır'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Nar Ekşili Kısır', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Nohut Ezmesi (Ev Usulü): 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohut Ezmesi (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Nohut Ezmesi (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Nohut Ezmesi (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Nohutlu Pilav (Ev Usulü): 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohutlu Pilav (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Nohutlu Pilav (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Nohutlu Pilav (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Nohutlu Tavuk Güveç: 200 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohutlu Tavuk Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Nohutlu Tavuk Güveç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 200) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Nohutlu Tavuk Güveç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Pancar Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pancar Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Pancar Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Pancar Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Pancar Salatası (Yoğurtlu): 1500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pancar Salatası (Yoğurtlu)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Pancar Salatası (Yoğurtlu)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Pancar Salatası (Yoğurtlu)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Patates Salatası (Yoğurtlu): 2000 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patates Salatası (Yoğurtlu)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Patates Salatası (Yoğurtlu)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 2000) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Patates Salatası (Yoğurtlu)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Patatesli Dana Güveç: 1800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patatesli Dana Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Patatesli Dana Güveç'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 1800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Patatesli Dana Güveç', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Patatesli Sebze Çorbası: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patatesli Sebze Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Patatesli Sebze Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Patatesli Sebze Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Patlıcan Turşusu: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patlıcan Turşusu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Patlıcan Turşusu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Patlıcan Turşusu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Patlıcanlı Kıyma Musakka: 300 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patlıcanlı Kıyma Musakka';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Patlıcanlı Kıyma Musakka'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 300) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Patlıcanlı Kıyma Musakka', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Pazılı Nohut Yemeği: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pazılı Nohut Yemeği';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Pazılı Nohut Yemeği'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Pazılı Nohut Yemeği', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Pırasalı Kıymalı Bahar Yemeği: 500 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pırasalı Kıymalı Bahar Yemeği';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Pırasalı Kıymalı Bahar Yemeği'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 500) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Pırasalı Kıymalı Bahar Yemeği', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Portakal Kompostosu (Ev Usulü): 800 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Portakal Kompostosu (Ev Usulü)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Portakal Kompostosu (Ev Usulü)'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 800) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Portakal Kompostosu (Ev Usulü)', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Portakal ve Limon Kompostosu: 600 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Portakal ve Limon Kompostosu';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Portakal ve Limon Kompostosu'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 600) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Portakal ve Limon Kompostosu', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- Rezene Çorbası: 600 g su
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Rezene Çorbası';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: Rezene Çorbası'; end if;
    delete from asama_malzemeleri where recete_malzeme_id in
        (select id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id);
    delete from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    values (v_recete_id, v_su_id, 600) returning id into v_rm_id;
    select count(*) into v_n from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    if v_n <> 1 then raise exception 'Isil asama sayisi 1 degil (%) -- Rezene Çorbası', v_n; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and isil_islem_mi;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

end $$;

-- Dogrulama 1: 30 satir, hepsi dolu uzunlukta olmali.
select ad, length(hazirlik_talimati) as uzunluk from receteler where isletme_id is null and ad in ('Naneli Cacık (Klasik)', 'Naneli Yoğurt', 'Nar Ekşili Dana Rosto', 'Nar Ekşili Kısır', 'Narlı Ispanak Salatası', 'Nohut Ezmesi (Ev Usulü)', 'Nohutlu Pilav (Ev Usulü)', 'Nohutlu Sığır Kavurma (Bahar)', 'Nohutlu Tavuk Güveç', 'Otlu Izgara Çipura', 'Pancar Çorbası', 'Pancar Salatası (Yoğurtlu)', 'Pastırmalı Kaşar Tabağı', 'Pastırmalı Kavurma', 'Patates Salatası (Yoğurtlu)', 'Patatesli Dana Güveç', 'Patatesli Sebze Çorbası', 'Patlıcan Salatası (Közlenmiş)', 'Patlıcan Turşusu', 'Patlıcanlı Kıyma Musakka', 'Pazılı Nohut Yemeği', 'Peynirli Kabak Böreği', 'Peynirli Yaz Böreği', 'Pırasalı Kıymalı Bahar Yemeği', 'Portakal Kompostosu (Ev Usulü)', 'Portakal ve Limon Kompostosu', 'Portakallı Havuç Salatası (Bahar)', 'Portakallı Mandalinalı Kış Salatası', 'Rezene Çorbası', 'Roka Marul Salatası') order by ad;

-- Dogrulama 2: 19 satir; Naneli Cacık ve Naneli Yoğurt disinda hepsinde isil_asama dolu olmali.
select r.ad, rm.miktar_gram as su_gram, a.ad as isil_asama
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
left join asama_malzemeleri am on am.recete_malzeme_id = rm.id
left join recete_asamalari a on a.id = am.asama_id
where rm.malzeme_id = '9f265c5f-7d22-43c8-8356-9f748af1c9ee' and r.isletme_id is null
  and r.ad in ('Naneli Cacık (Klasik)', 'Naneli Yoğurt', 'Nar Ekşili Dana Rosto', 'Nar Ekşili Kısır', 'Nohut Ezmesi (Ev Usulü)', 'Nohutlu Pilav (Ev Usulü)', 'Nohutlu Tavuk Güveç', 'Pancar Çorbası', 'Pancar Salatası (Yoğurtlu)', 'Patates Salatası (Yoğurtlu)', 'Patatesli Dana Güveç', 'Patatesli Sebze Çorbası', 'Patlıcan Turşusu', 'Patlıcanlı Kıyma Musakka', 'Pazılı Nohut Yemeği', 'Pırasalı Kıymalı Bahar Yemeği', 'Portakal Kompostosu (Ev Usulü)', 'Portakal ve Limon Kompostosu', 'Rezene Çorbası')
order by r.ad;
