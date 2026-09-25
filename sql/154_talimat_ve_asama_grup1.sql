-- 154_talimat_ve_asama_grup1.sql
-- 1000 tarif hedefi tamamlandiktan SONRAKI faz: yeni eklenen 515
-- tarifin hazirlik_talimati + recete_asamalari yazimi. Grup 1:
-- Parti1(tarif-ekleme)'in Marmara+Ege'si (16 tarif).
--
-- Bu tariflerde daha once recete_asamalari HIC yoktu (yukle_yeni_
-- tarifler.py sadece tarif+malzeme ekliyor, asama eklemiyor) --
-- bu yuzden asama verisi (sure, isil islem, hedef sicaklik, enerji
-- kaynagi) SIFIRDAN TASARLANDI (245'lik ilk gorevden FARKLI OLARAK,
-- orada asama verisi zaten vardi, sadece metin yazilmisti).
--
-- 5 tarifte kendi belirledigimiz hazirlik_dakika GERCEKCI DEGILDI
-- (ör. butun kaz dolmasina 45 dk verilmis, gercekte ~3 saat surer) --
-- bu tarifler icin hazirlik_dakika da DUZELTILDI (asagida listelenen
-- yeni_hazirlik_dakika degerleri).
--
-- Idempotent DEGIL bilerek: bir tarifte ZATEN asama varsa HATA verir
-- (guvenlik onlemi -- yanlislikla iki kez calistirip mukerrer asama
-- olusturmayi onler). Tek transaction.

create or replace function _talimat_ve_asama_ekle(
    p_ad text, p_yeni_hazirlik_dakika int, p_talimat text,
    p_asamalar jsonb, p_su_gram numeric, p_su_asama_sira int
) returns void language plpgsql as $f$
declare
    v_recete_id uuid;
    v_item jsonb;
    v_asama_id uuid;
    v_su_asama_id uuid;
    v_su_id uuid := '9f265c5f-7d22-43c8-8356-9f748af1c9ee';
    v_rm_id uuid;
begin
    select id into v_recete_id from receteler where isletme_id is null and ad = p_ad;
    if v_recete_id is null then
        raise exception 'Tarif bulunamadi: %', p_ad;
    end if;

    if exists (select 1 from recete_asamalari where recete_id = v_recete_id) then
        raise exception 'Bu tarifte ZATEN asama kayitli -- iptal: %', p_ad;
    end if;

    update receteler
    set hazirlik_talimati = p_talimat,
        hazirlik_dakika = coalesce(p_yeni_hazirlik_dakika, hazirlik_dakika)
    where id = v_recete_id;

    for v_item in select * from jsonb_array_elements(p_asamalar)
    loop
        insert into recete_asamalari (recete_id, sira, ad, sure_dakika, aktif_dakika,
                                       isil_islem_mi, baslangic_sicaklik, hedef_sicaklik, enerji_kaynagi)
        values (
            v_recete_id, (v_item->>'sira')::smallint, v_item->>'ad',
            (v_item->>'sure_dakika')::numeric, (v_item->>'aktif_dakika')::numeric,
            (v_item->>'isil_islem_mi')::boolean, (v_item->>'baslangic_sicaklik')::numeric,
            (v_item->>'hedef_sicaklik')::numeric, v_item->>'enerji_kaynagi'
        )
        returning id into v_asama_id;

        if p_su_gram is not null and (v_item->>'sira')::int = p_su_asama_sira then
            v_su_asama_id := v_asama_id;
        end if;
    end loop;

    if p_su_gram is not null then
        select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
        if v_rm_id is null then
            insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
            values (v_recete_id, v_su_id, p_su_gram)
            returning id into v_rm_id;
        else
            update recete_malzemeleri set miktar_gram = p_su_gram where id = v_rm_id;
        end if;
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_su_asama_id, v_rm_id);
    end if;
end;
$f$;

do $$
begin
    perform _talimat_ve_asama_ekle(
        'Bursa İskender Kebabı', null, '**Hazırlık / Mise en Place**
1. Pideyi kalın dilimler halinde kesip servis tabağına döşeyin.
2. Domatesleri yıkayıp kabuklarını soyun, rendeleyin.
3. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarın, pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Isıtma ve Birleştirme (~75°C, tavada, 15 dk): Pişmiş döner etini az miktarda tereyağıyla tavada ısıtın. Ayrı bir tavada kalan tereyağını eritip rendelenmiş domatesi ekleyip 3-4 dk pişirin. Isınan döneri pide dilimlerinin üzerine yerleştirin.
2. Son işlemler: Yoğurdu bir kenara, sıcak domates-tereyağı sosunu üzerine gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Domates sosu pişerken döner ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Isıtma ve Birleştirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'İnegöl Köfte', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyin.
2. Kıyma, rendelenmiş soğan, ekmeklik un, tuz, karabiber ve kimyonu bir kapta iyice yoğurun; en az 10 dk dinlendirin (bu bekleme aşağıdaki süreye dahildir).
3. Harçtan uzun köfte şekiller verin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada köfteleri her yüzü 4-5 dk olacak şekilde çevirerek pişirin. En kalın yerinde iç sıcaklık en az 75°C olmalı.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte harcı dinlendirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık / Yoğurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Bursa Kestaneli Kaz Dolması', 180, '**Hazırlık / Mise en Place**
1. Fırını 170°C''ye ısıtmaya başlayın.
2. Kazı için içini yıkayıp kağıt havluyla kurulayın.
3. Pirinci yıkayıp süzün; kestaneleri iri parçalar halinde bölün.
4. Zeytinyağında kuru soğanı 3-4 dk kavurun, pirinci ekleyip 1-2 dk çevirin. Kestane, kuş üzümü, tuz, karabiber ve yenibaharı ekleyip karıştırın.
5. Harcı kazın içine, pişerken şişeceği için gevşek doldurun; açıklığı kürdan veya iple kapatın.

**Isıl İşlem**
1. Fırınlama (170°C, 150 dk): Kazı fırın tepsisine göğsü üste gelecek şekilde yerleştirin. 170°C''ye önceden ısıtılmış fırında, arada bir kendi yağıyla üzerini gezdirerek pişirin. Butun en kalın yerinde iç sıcaklık en az 90°C olmalı, deri altın rengi ve gevrek olmalı.
2. Son işlemler: Fırından çıkarıp 15 dk dinlendirdikten sonra parçalayıp iç harcıyla birlikte servis edin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken iç harç hazırlanıp kaz doldurulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk · Pasif bekleme ~135 dk · Toplam ~180 dk',
        '[{"sira": 1, "ad": "Hazırlık / Doldurma", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 150, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'İstanbul Usulü Karnıyarık', 45, '**Hazırlık / Mise en Place**
1. Patlıcanları boydan ikiye kesip etli yüzlerine çapraz kesikler atın, hafif tuzlayıp 10 dk (aşağıdaki süreye dahil değildir) acı suyunu çıkarmaya bırakın, sonra kurulayın.
2. Kuru soğanı küçük küp doğrayın, sarımsağı ince kıyın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın; bir kısmını üstüne dizmek için dilimleyin.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 10 dk): Patlıcanları zeytinyağında her iki yüzü de yumuşayıp hafif renk alana kadar kızartın, bir kaba alın.
2. Pişirme / Fırınlama (~90°C, fırında, 25 dk): Aynı yağda soğanı 3-4 dk kavurun, sarımsağı ekleyip 1 dk çevirin. Kıymayı ekleyip suyunu salıp çekene kadar (~8 dk) kavurun. Doğranmış domatesi, 20 ml (20 g) sıcak su, tuz ve karabiberi ekleyip 5 dk pişirin. Patlıcanları fırın kabına dizin, ortalarını hafifçe açıp harcı doldurun, üzerine domates dilimlerini yerleştirin. 190°C''ye önceden ısıtılmış fırında patlıcanlar iyice yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Patlıcan kızartılırken kıyma sosu ayrı tavada hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~15 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz"}, {"sira": 3, "ad": "Pişirme / Fırınlama", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik"}]'::jsonb, 20, 3
    );
    perform _talimat_ve_asama_ekle(
        'Bandırma Mantısı', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu bir kaba eleyin, ortasını havuz gibi açın. Az tuzlu suyla yoğrulabilir bir hamur elde edin, üzerini nemli bir bezle örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kuru soğanı rendeleyin, kıyma ile karıştırıp tuz ekleyin.
3. Hamuru ince açıp küçük kareler halinde kesin, her karenin ortasına az miktarda iç harç koyup dört köşesini ortada birleştirerek kapatın.
4. Sarımsaklı yoğurdu hazırlayıp bir kenarda bekletin.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 15 dk): Tencereye 150 ml (150 g) su koyup kaynatın, tuz ekleyin. Mantıları kaynayan suya azar azar bırakıp üstüne çıkıp hafif şişene kadar (~10 dk) haşlayın.
2. Son işlemler: Mantıları süzüp servis tabağına alın, üzerine sarımsaklı yoğurdu, ardından eritilmiş tereyağı ve pul biberi gezdirin, kuru naneyi serpin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç ve sarımsaklı yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~10 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur ve Doldurma", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz"}]'::jsonb, 150, 2
    );
    perform _talimat_ve_asama_ekle(
        'Marmara Usulü Midye Tava', null, '**Hazırlık / Mise en Place**
1. Midyeleri temizleyip süzün.
2. Ekmeklik unu, karbonatı ve az suyla akıcı bir hamur/harç hazırlayın; midyeleri bu harca bulayın.
3. Ceviz, sarımsak ve ekmeği bir araya getirip tarator sosu hazırlayın, limon suyu ve tuzla tatlandırın.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 15 dk): Mısır yağını tavada kızdırın. Harca bulanan midyeleri partiler halinde her yüzü altın rengi olana kadar kızartın.
2. Son işlemler: Kızarmış midyeleri kağıt havlu serili bir tabağa alıp fazla yağını süzdürün, tarator sosuyla servis edin.

**PARALEL YAPILABİLİRLİK:** Bir parti kızarırken tarator sosu hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Kırklareli Rokalı Beyaz Peynir Salatası', null, '**Hazırlık / Mise en Place**
1. Rokayı ayıklayıp yıkayın, iyice süzdürün.
2. Beyaz peyniri küçük küp doğrayın.
3. Cevizleri iri kırın.
4. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.
5. Roka, peynir ve cevizi bir kapta nazikçe karıştırıp sosla servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Roka süzülürken peynir doğranıp sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Marmara Kestaneli Muhallebi', null, '**Hazırlık / Mise en Place**
1. Kestaneleri (haşlanmış/kabuğu soyulmuş) iri parçalar halinde bölün.
2. Mısır nişastasını birkaç kaşık soğuk sütle pürüzsüz bir bulamaç haline getirin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 20 dk): Kalan sütü, şekeri ve kestaneleri bir tencerede ısıtın. Kaynamaya yakın gelince nişasta bulamacını azar azar ekleyip sürekli karıştırarak kıvam koyulaşana kadar (~12 dk) pişirin.
2. Son işlemler: Servis kabına alıp üzerini streç filmle kapatarak kabuk bağlamasını önleyin, ılıyınca buzdolabına kaldırıp soğutun (soğutma süresi özete dahil değildir), üzerine kırılmış cevizi serpin.

**PARALEL YAPILABİLİRLİK:** Nişasta bulamacı, süt ısıtılırken hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk · Pasif bekleme ~8 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'İzmir Köfte (Fırında)', 45, '**Hazırlık / Mise en Place**
1. Fırını 190°C''ye ısıtmaya başlayın.
2. Patatesleri soyup kalın dilimler halinde kesin.
3. Kuru soğanı rendeleyin; domatesleri dilimleyin.
4. Kıyma, rendelenmiş soğan, ekmeklik un, tuz ve karabiberi yoğurup yassı köfte şekli verin.

**Isıl İşlem**
1. Fırınlama (190°C, 30 dk): Patates dilimlerini zeytinyağıyla karıştırıp fırın kabının tabanına yayın. Köfteleri üzerine dizin, domates dilimlerini araya yerleştirin. 50 ml (50 g) sıcak suyu kenarlardan gezdirin. 190°C''ye önceden ısıtılmış fırında patatesler ve köfteler pişip üzeri hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken köfte harcı hazırlanıp patates dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~22 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik"}]'::jsonb, 50, 2
    );
    perform _talimat_ve_asama_ekle(
        'Çeşme Usulü Ahtapot Güveç', 70, '**Hazırlık / Mise en Place**
1. Ahtapotu akan soğuk su altında yıkayın; gözlerini ve ağızdaki sert gagayı çıkarın.
2. Kuru soğanı, yeşil biberi ve domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Haşlama (~85°C, tencerede, 30 dk): Tencereye 200 ml (200 g) su koyup kaynamaya yakın ısıtın. Ahtapotu dokunaçlarından tutup suya 3 kez daldırıp çıkarın, sonra tamamen batırıp kısık ateşte çatal rahatça batana kadar haşlayın. Süzüp 2-3 cm parçalar halinde doğrayın.
2. Güveç Pişirme (~90°C, güveç kabında, 30 dk): Zeytinyağında soğanı 3-4 dk kavurun, biberi ekleyip 2 dk çevirin. Domatesi, tuz ve karabiberi ekleyip 5 dk pişirin. Haşlanmış ahtapotu ekleyip kapağı kapatarak lezzetler kaynaşana kadar kısık ateşte pişirin.

**PARALEL YAPILABİLİRLİK:** Ahtapot haşlanırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~43 dk · Toplam ~70 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 30, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz"}, {"sira": 3, "ad": "Güveç Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz"}]'::jsonb, 200, 2
    );
    perform _talimat_ve_asama_ekle(
        'Ege Otlu Peynirli Gözleme', null, '**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, ince kıyın.
2. Otlu peyniri ufalayıp ıspanakla karıştırın.
3. Yufkayı açıp harcı bir yarısına yayın, üzerine tereyağının bir kısmını gezdirip katlayın.

**Isıl İşlem**
1. Tavada Pişirme (~85°C, sac tavada, 10 dk): Kalan tereyağını sac tavaya sürüp katlanmış yufkayı her iki yüzü altın rengi olana kadar 4-5 dk''şar pişirin.

**PARALEL YAPILABİLİRLİK:** Tava ısınırken harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Tavada Pişirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Ege Usulü Isırgan Kavurması (Etli)', null, '**Hazırlık / Mise en Place**
1. Isırganı (eldivenle) ayıklayıp toprağı gidene kadar bol suda birkaç kez yıkayın, süzüp iri kıyın.
2. Kuzu etini 1,5-2 cm kuşbaşı doğrayın.
3. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Zeytinyağında eti suyunu salıp çekene ve renk alana kadar 10 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Isırganı ekleyin, tuz ve karabiberi serpin; ısırgan pörsüyüp yumuşayana kadar (~6-7 dk) karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken ısırgan yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Ege Yaylası Kuzu Tandır', null, '**Hazırlık / Mise en Place**
1. Fırını 170°C''ye ısıtmaya başlayın.
2. Kuzu tandırı kağıt havluyla kurulayın.
3. Zeytinyağı, tuz, kekik ve karabiberi karıştırıp ete ovun.
4. Kuru soğanı iri dilimleyin.

**Isıl İşlem**
1. Fırınlama (170°C, 80 dk): Soğanı fırın kabının tabanına yayın, eti üzerine yerleştirin. 20 ml (20 g) su ekleyip kabı folyoyla sıkıca kapatın. 170°C''ye önceden ısıtılmış fırında 65 dakika pişirin. Folyoyu açıp üzeri hafif kızarana kadar son 15 dakika folyosuz pişirin. Et lif lif ayrılacak kıvamda yumuşamalı.
2. Son işlemler: Fırından çıkarıp birkaç dakika dinlendirip parçalayarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken et baharatlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~70 dk · Toplam ~100 dk',
        '[{"sira": 1, "ad": "Hazırlık / Baharatlama", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 80, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik"}]'::jsonb, 20, 2
    );
    perform _talimat_ve_asama_ekle(
        'Ege Portakallı Zeytinyağlı Kek', 55, '**Hazırlık / Mise en Place**
1. Fırını 175°C''ye ısıtmaya başlayın, kek kalıbını yağlayın.
2. Portakalın kabuğunu rendeleyip suyunu sıkın.
3. Yumurta ve şekeri açık renkli, hafif kabarana kadar çırpın. Zeytinyağını, portakal suyunu ve kabuğunu ekleyip karıştırın.
4. Un ve kabartma tozunu eleyip azar azar ekleyerek pürüzsüz bir hamur elde edin.

**Isıl İşlem**
1. Fırınlama (175°C, 40 dk): Hamuru kalıba dökün. 175°C''ye önceden ısıtılmış fırında ortasına batırılan kürdan temiz çıkana kadar pişirin.
2. Son işlemler: Kalıptan çıkarmadan önce 5 dk dinlendirin (dinlenme süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken hamur hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~35 dk · Toplam ~55 dk',
        '[{"sira": 1, "ad": "Hazırlık / Karıştırma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik"}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Datça Bademli Yeşil Salata', null, '**Hazırlık / Mise en Place**
1. Roka ve marulu ayıklayıp yıkayın, iyice süzdürün, elinizle parçalayın.
2. Bademleri kabaca kırın.
3. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın; servisten hemen önce yeşilliklerle karıştırın, bademi üzerine serpin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Yeşillikler süzülürken badem kırılıp sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}]'::jsonb, null, null
    );
    perform _talimat_ve_asama_ekle(
        'Ege İnciri ile Komposto', null, '**Hazırlık / Mise en Place**
1. Kuru incirleri isterseniz ikiye bölün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 17 dk): 80 ml (80 g) suyu ve şekeri bir tencerede kaynatın. Kuru incirleri ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak incirler yumuşayıp şerbeti çekmeye başlayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), incirleri kendi şerbetiyle birlikte soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz"}]'::jsonb, 80, 2
    );
end $$;

-- Dogrulama: bu 16 tarifin hepsinde artik hazirlik_talimati DOLU,
-- ve asama sureleri toplami hazirlik_dakika ile ESIT olmali (fark 0).
with liste(ad) as (values
    ('Bursa İskender Kebabı'),
    ('İnegöl Köfte'),
    ('Bursa Kestaneli Kaz Dolması'),
    ('İstanbul Usulü Karnıyarık'),
    ('Bandırma Mantısı'),
    ('Marmara Usulü Midye Tava'),
    ('Kırklareli Rokalı Beyaz Peynir Salatası'),
    ('Marmara Kestaneli Muhallebi'),
    ('İzmir Köfte (Fırında)'),
    ('Çeşme Usulü Ahtapot Güveç'),
    ('Ege Otlu Peynirli Gözleme'),
    ('Ege Usulü Isırgan Kavurması (Etli)'),
    ('Ege Yaylası Kuzu Tandır'),
    ('Ege Portakallı Zeytinyağlı Kek'),
    ('Datça Bademli Yeşil Salata'),
    ('Ege İnciri ile Komposto')
)
select r.ad, r.hazirlik_dakika,
    (select coalesce(sum(a.sure_dakika),0) from recete_asamalari a where a.recete_id = r.id) as asama_toplami,
    length(r.hazirlik_talimati) as talimat_uzunlugu,
    (select count(*) from recete_asamalari a where a.recete_id = r.id) as asama_sayisi
from liste l
join receteler r on r.ad = l.ad and r.isletme_id is null
order by r.ad;
