-- 187_kopya_donusumu_parti1_etli_kavurma.sql
-- YUZ KOPYA DUZELTME, PARTI 1 (12 Ekim 2026)
-- Bahri'nin karari: ayni tarifin il adiyla cogaltilmis kopyalari GERCEK yoresel tariflere
-- donusturulecek; belgelenmis bir varyanti olmayan kopya, o ilin gercek ve belgelenmis bir
-- yemegiyle degistirilecek. Bu parti "X Usulü Etli Kavurma" kopya grubundan 8 tarif:
--   7 kopya -> Turk Patent Cografi Isaret (CI) tescil belgesinden alinmis gercek tarif
--   1 kopya (Mersin) -> genel "Etli Kavurma" adiyla tek temsilci olarak kalir
--     (Mersin'in belgelenmis ana yemegi Tantuni kutuphanede zaten var).
-- Malzeme miktarlari CI belgelerindeki toplam miktarlarin porsiyon sayisina bolunmesiyle
-- bulundu (kutuphane kurali: 1 porsiyon bazinda). Adet/olcu birimi -> gram cevirileri ve
-- belgede olmayan sureler TAHMIN olarak PROJE_NOTLARI.md'de tek tek listelendi.
--
-- GUVENLIK:
--  * Kopya; menu_ogeleri, menu_takvimi_ogeleri veya kayitli_aylik_menuler'de kullaniliyorsa
--    DOKUNULMAZ, sadece NOTICE yazilir (kullanicinin kayitli menusu bozulmasin).
--  * Yeni ad kutuphanede zaten varsa atlanir.
--  * Malzemelerin hepsi once kontrol edilir; biri eksikse HICBIR degisiklik yapilmadan durur.
--  * Tek transaction (begin/commit).

begin;
-- 153 ile birebir ayni fonksiyon
create or replace function _yeni_tarif_ekle(
    p_ad text, p_grup_id uuid, p_porsiyon int, p_hazirlik int,
    p_etiketler jsonb, p_mevsim text, p_bolge text, p_malzemeler jsonb
) returns void language plpgsql as $f$
declare
    v_recete_id uuid;
    v_kategori text;
    v_item jsonb;
    v_malzeme_id uuid;
    v_oncelik text[] := array['izgara','kirmizi_et','beyaz_et','balik','etli_sebze',
        'kuru_baklagil','yumurta','corba','pilav','zeytinyagli','dolma',
        'pilav_makarna_borek','salata','cacik','yogurt','tursu','komposto','tatli'];
begin
    if exists (select 1 from receteler where isletme_id is null and ad = p_ad) then
        raise notice 'Atlandi (zaten var): %', p_ad;
        return;
    end if;

    select e into v_kategori
    from unnest(v_oncelik) with ordinality as o(e, sira_)
    where e in (select jsonb_array_elements_text(p_etiketler))
    order by sira_ limit 1;

    insert into receteler (isletme_id, ad, kategori, porsiyon_sayisi, hazirlik_dakika,
                            mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge)
    values (null, p_ad, v_kategori, p_porsiyon, p_hazirlik, p_grup_id,
            array(select jsonb_array_elements_text(p_etiketler))::text[], p_mevsim, p_bolge)
    returning id into v_recete_id;

    for v_item in select * from jsonb_array_elements(p_malzemeler)
    loop
        select id into v_malzeme_id from malzemeler
        where isletme_id is null and ad = v_item->>'ad';
        if v_malzeme_id is null then
            raise exception 'Malzeme bulunamadi: % (tarif: %)', v_item->>'ad', p_ad;
        end if;
        insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
        values (v_recete_id, v_malzeme_id, (v_item->>'miktar_gram')::numeric);
    end loop;
end;
$f$;
-- 164 ile birebir ayni fonksiyon
create or replace function _talimat_ve_asama_ekle_v2(
    p_ad text, p_yeni_hazirlik_dakika int, p_talimat text, p_asamalar jsonb
) returns void language plpgsql as $f$
declare
    v_recete_id uuid;
    v_item jsonb;
    v_asama_id uuid;
    v_su_id uuid := '9f265c5f-7d22-43c8-8356-9f748af1c9ee';
    v_rm_id uuid;
    v_malzeme_ad text;
    v_yeni_su numeric;
begin
    select id into v_recete_id from receteler where isletme_id is null and ad = p_ad;
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', p_ad; end if;
    if exists (select 1 from recete_asamalari where recete_id = v_recete_id) then
        raise exception 'Bu tarifte ZATEN asama kayitli -- iptal: %', p_ad;
    end if;

    update receteler set hazirlik_talimati = p_talimat,
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

        v_yeni_su := (v_item->>'yeni_su_gram')::numeric;
        if v_yeni_su is not null then
            select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
            if v_rm_id is null then
                insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
                values (v_recete_id, v_su_id, v_yeni_su);
            else
                update recete_malzemeleri set miktar_gram = v_yeni_su where id = v_rm_id;
            end if;
        end if;

        for v_malzeme_ad in select jsonb_array_elements_text(v_item->'malzemeler')
        loop
            select rm.id into v_rm_id
            from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
            where rm.recete_id = v_recete_id and m.ad = v_malzeme_ad;
            if v_rm_id is null then
                raise exception 'Malzeme tarifte yok: % (tarif: %, asama: %)', v_malzeme_ad, p_ad, v_item->>'ad';
            end if;
            insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
        end loop;
    end loop;
end;
$f$;
-- 1) On kontrol: malzemeler
do $$
declare v_eksik text;
begin
    select string_agg(a, ', ') into v_eksik
    from unnest(array['AYVA', 'DOMATES', 'KARABİBER', 'KOYUN KIYMA', 'KURU SOĞAN', 'KUYRUKYAĞI', 'KUZU ETİ (BUT)', 'KUZU ETİ (KOL)', 'KİMYON', 'PATATES', 'PATLICAN', 'PUL BİBER', 'PİDE', 'SARIMSAK', 'SU', 'TEREYAĞI', 'TUZ', 'YENİDÜNYA', 'YEŞİL BİBER', 'İNCE BULGUR']::text[]) as a
    where not exists (select 1 from malzemeler m where m.isletme_id is null and m.ad = a);
    if v_eksik is not null then
        raise exception 'Katalogda olmayan malzeme(ler): % -- hicbir degisiklik yapilmadi', v_eksik;
    end if;
end $$;
-- 2) Yardimci: kopya kullanimda mi?
create or replace function _kopya_kullanimda_mi(p_id uuid, p_ad text) returns boolean
language sql stable as $f$
    select exists (select 1 from menu_ogeleri where recete_id = p_id)
        or exists (select 1 from menu_takvimi_ogeleri where recete_id = p_id)
        or exists (select 1 from kayitli_aylik_menuler
                   where menu_verisi::text like '%' || p_id::text || '%'
                      or menu_verisi::text like '%"' || p_ad || '"%');
$f$;
-- 3) Donusumler
do $$
declare
    v_mutfak_id uuid;
    v_grup1_id uuid;
    v_id uuid;
    v_degisen int := 0;
begin
    select id into v_mutfak_id from mutfaklar where kod = 'turk';
    select id into v_grup1_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 1;
    if v_grup1_id is null then raise exception 'Grup 1 bulunamadi'; end if;

    -- Kilis Usulü Etli Kavurma -> Kilis Tava (CI 1017)
    select id into v_id from receteler where isletme_id is null and ad = 'Kilis Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kilis Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kilis Tava') then
        raise notice 'Yeni ad zaten var, atlandi: Kilis Tava';
    elsif _kopya_kullanimda_mi(v_id, 'Kilis Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kilis Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kilis Tava', v_grup1_id, 1, 55,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 125.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "PATATES", "miktar_gram": 62.5}, {"ad": "DOMATES", "miktar_gram": 75.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 25.0}, {"ad": "KARABİBER", "miktar_gram": 2.5}, {"ad": "PUL BİBER", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 2.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kilis Tava', null, '**Hazırlık / Mise en Place**
1. Fırını 250°C''ye ısıtmaya başlayın.
2. Kuru soğanın yarısını ve yeşil biberin yarısını çok ince doğrayın (veya kıyma makinesinden geçirin). Koyun kaburga kıymasına (orta yağlı) bu soğan ve biberi, karabiber, pul biber ve tuzu ekleyip harç homojen ve kıvamlı olana kadar elle yoğurun.
3. Patatesleri soyup ince dilimleyin ve tepsinin tabanına dizin.
4. Kıymalı harcı ıslak elle patateslerin üzerine yaklaşık 0,5 cm kalınlığında yayın.
5. Kalan soğanı ve domatesleri 4 eşit parçaya bölün; tepsinin kenarına bir soğan bir domates olacak şekilde dizin.
6. Kıymayı tepsinin ortasından kenara doğru 8 eşit dilime kesin. Kalan biberleri uzunlamasına ikiye bölüp dilimlerin arasına yerleştirin.

**Isıl İşlem**
1. Fırınlama (250°C, elektrikli fırın, 25 dk): Tepsiyi ısınmış fırında 25 dakika pişirin. (Patlıcanla yapılırsa 20 dk. Taş fırında patatesli yaklaşık 30 dk.)

**Servis:** Tırnaklı pide ve ayranla sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın pişirirken başka tariflerin hazırlığı yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~22 dk · Toplam ~55 dk

**Kaynak:** Kilis Tava, Türk Patent Coğrafi İşaret Tescil No 1017.',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KOYUN KIYMA", "KURU SOĞAN", "PATATES", "DOMATES", "YEŞİL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Niğde Usulü Etli Kavurma -> Niğde Tavası (CI 1421)
    select id into v_id from receteler where isletme_id is null and ad = 'Niğde Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Niğde Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Niğde Tavası') then
        raise notice 'Yeni ad zaten var, atlandi: Niğde Tavası';
    elsif _kopya_kullanimda_mi(v_id, 'Niğde Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Niğde Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Niğde Tavası', v_grup1_id, 1, 60,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 250.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 25.0}, {"ad": "SARIMSAK", "miktar_gram": 15.0}, {"ad": "DOMATES", "miktar_gram": 250.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 125.0}, {"ad": "TUZ", "miktar_gram": 3.75}, {"ad": "PUL BİBER", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Niğde Tavası', null, '**Hazırlık / Mise en Place**
1. Et en az bir gün önceden buzdolabında dinlendirilmiş olmalıdır.
2. Fırını 200°C''ye ısıtmaya başlayın.
3. Eti, kuyruk yağını ve domatesleri iri lokma büyüklüğünde küp doğrayın. Sivri yeşil biberleri halka doğrayın, sarımsak dişlerini soyun.
4. Tepsiye et, sarımsak, biber, domates ve kuyruk yağını yerleştirin; üzerine kırmızı biber ve tuzu serpin.

**Isıl İşlem**
1. Fırınlama (200°C, elektrikli fırın, toplam ~40 dk): Tepsiyi fırında kuyruk yağı eriyip etin yüzeyi pembeleşene kadar 10-15 dk pişirin. Çıkarıp altları kızarsın diye hafifçe karıştırın, 10-15 dk daha pişirin. Tekrar çıkarıp karıştırın ve et kızarana kadar pişirmeye devam edin (toplam 35-45 dk).

**Servis:** Tepside ya da tabakta, sıcak pide ile servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın aralarında başka tariflerin hazırlığı yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~26 dk · Pasif bekleme ~34 dk · Toplam ~60 dk (bir gün önceden et dinlendirme hariç)

**Kaynak:** Niğde Tavası, Türk Patent Coğrafi İşaret Tescil No 1421 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (BUT)", "KUYRUKYAĞI", "SARIMSAK", "DOMATES", "YEŞİL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kahramanmaraş Usulü Etli Kavurma -> Maraş Eli Böğründe (CI 1250)
    select id into v_id from receteler where isletme_id is null and ad = 'Kahramanmaraş Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kahramanmaraş Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Maraş Eli Böğründe') then
        raise notice 'Yeni ad zaten var, atlandi: Maraş Eli Böğründe';
    elsif _kopya_kullanimda_mi(v_id, 'Kahramanmaraş Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kahramanmaraş Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Maraş Eli Böğründe', v_grup1_id, 1, 28,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 150}, {"ad": "DOMATES", "miktar_gram": 182}, {"ad": "YEŞİL BİBER", "miktar_gram": 82.5}, {"ad": "SARIMSAK", "miktar_gram": 16.5}, {"ad": "TUZ", "miktar_gram": 4}, {"ad": "PUL BİBER", "miktar_gram": 2.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Maraş Eli Böğründe', null, '**Hazırlık / Mise en Place**
1. Fırını 270-300°C''ye ısıtmaya başlayın.
2. Eti 1-2 cm kuşbaşı veya jülyen doğrayın. (Dana eti kullanılırsa ete 20-30 g kuyruk yağı karıştırılır.)
3. Domates ve biberleri etin 4-5 katı büyüklüğünde doğrayın, sarımsak dişlerini soyun.
4. İnce alüminyum tepsiye veya güvece et, domates, sarımsak ve biberi gruplar halinde yan yana dizin; tuz ve Maraş biberini serpin.

**Isıl İşlem**
1. Fırınlama (270-300°C, 10-15 dk): Tepsiyi çok sıcak fırında et pişip sebzeler hafif kızarana kadar pişirin.

**Servis:** Lavaş ve ayranla sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken doğrama yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~11 dk · Toplam ~28 dk

**Kaynak:** Maraş Eli Böğründe / Maraş Yanyana, Türk Patent Coğrafi İşaret Tescil No 1250 (150 g et esasıyla).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 13, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (BUT)", "DOMATES", "YEŞİL BİBER", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Gaziantep Usulü Etli Kavurma -> Gaziantep Simit Kebabı (CI 729)
    select id into v_id from receteler where isletme_id is null and ad = 'Gaziantep Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Gaziantep Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Gaziantep Simit Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Gaziantep Simit Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Gaziantep Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Gaziantep Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Gaziantep Simit Kebabı', v_grup1_id, 1, 35,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 180}, {"ad": "İNCE BULGUR", "miktar_gram": 20}, {"ad": "SU", "miktar_gram": 20}, {"ad": "SARIMSAK", "miktar_gram": 3.5}, {"ad": "KİMYON", "miktar_gram": 3.5}, {"ad": "TUZ", "miktar_gram": 3.5}, {"ad": "KARABİBER", "miktar_gram": 3.5}, {"ad": "PUL BİBER", "miktar_gram": 3.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Gaziantep Simit Kebabı', null, '**Hazırlık / Mise en Place**
1. İnce bulguru (simit) geniş bir yoğurma kabına alın, ılık suyu ekleyip 10-15 dk şişmeye bırakın.
2. Kuru sarımsağı soyup çok ince kıyın.
3. Şişen bulgura zırh koyun kıymasını, kırmızı biberi, kimyonu, karabiberi, tuzu ve sarımsağı ekleyin. İsteğe göre 2-5 g kuru nane ve 5-10 g çam fıstığı da eklenebilir.
4. Harcı köfte harcı gibi 5-10 dk yoğurun.
5. Harçtan bir porsiyon alıp kare kesitli kıyma şişine geçirin; hafif nemli parmaklarla şiş boyunca eşit kalınlıkta yayın.

**Isıl İşlem**
1. Izgara (mangal/ızgara, ~8 dk): Şişi ızgara üzerinde sürekli aynı yöne çevirerek pişirin.

**Servis:** İnce pide, maydanoz piyazı, közlenmiş domates ve biber ve ayranla servis edin.

**PARALEL YAPILABİLİRLİK:** Bulgur şişerken sarımsak ve baharatlar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~12 dk · Toplam ~35 dk

**Kaynak:** Gaziantep Simit Kebabı / Antep Simit Kebabı, Türk Patent Coğrafi İşaret Tescil No 729 (1 porsiyon).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 27, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN KIYMA", "İNCE BULGUR", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Gaziantep Usulü Etli Kavurma (Kimyonlu) -> Gaziantep Yenidünya Kebabı (CI 743)
    select id into v_id from receteler where isletme_id is null and ad = 'Gaziantep Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Gaziantep Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Gaziantep Yenidünya Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Gaziantep Yenidünya Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Gaziantep Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Gaziantep Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Gaziantep Yenidünya Kebabı', v_grup1_id, 1, 75,
            '["kirmizi_et"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 155.0}, {"ad": "YENİDÜNYA", "miktar_gram": 300.0}, {"ad": "KARABİBER", "miktar_gram": 0.6}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "SU", "miktar_gram": 20.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Gaziantep Yenidünya Kebabı', null, '**Hazırlık / Mise en Place**
1. Fırını 180-200°C''ye ısıtmaya başlayın.
2. Yenidünyaları yıkayın, baştan sapa doğru ikiye bölün ve sivri bir bıçakla çekirdeklerini çıkarın. İç yüzlerine tuz-karabiber karışımı sürün.
3. Zırh koyun kıymasına tuz ve karabiber ekleyip karıştırın; ceviz büyüklüğünde toplar yapın.
4. Düz fırın tepsisine iki yenidünya arasına bir kıyma topu gelecek şekilde, yenidünyalar arasında 2-2,5 cm boşluk bırakarak yatay dizin.
5. Tepsiye bir çay bardağı su gezdirin.

**Isıl İşlem**
1. Fırınlama (180-200°C, ~45 dk): Tepsiyi fırında pişirin. İlk 40 dakika fırın kapağını açmayın, yalnızca son 5 dakikada açabilirsiniz.

**Servis:** Taze soğan-maydanozlu piyaz, közlenmiş biber ve domatesle servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın pişirirken başka tariflerin hazırlığı yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~32 dk · Pasif bekleme ~43 dk · Toplam ~75 dk

**Kaynak:** Gaziantep Yenidünya Kebabı / Antep Yenidünya Kebabı, Türk Patent Coğrafi İşaret Tescil No 743 (tepside pişirme yöntemi, 4-6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 45, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KOYUN KIYMA", "YENİDÜNYA", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şanlıurfa Usulü Etli Kavurma -> Şanlıurfa Tepsi Kebabı (CI 1171)
    select id into v_id from receteler where isletme_id is null and ad = 'Şanlıurfa Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şanlıurfa Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Şanlıurfa Tepsi Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Şanlıurfa Tepsi Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Şanlıurfa Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şanlıurfa Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Şanlıurfa Tepsi Kebabı', v_grup1_id, 1, 90,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 112.5}, {"ad": "KUYRUKYAĞI", "miktar_gram": 37.5}, {"ad": "PATLICAN", "miktar_gram": 180.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 75.0}, {"ad": "TUZ", "miktar_gram": 1.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Şanlıurfa Tepsi Kebabı', null, '**Hazırlık / Mise en Place**
1. Kuzu eti ve kuyruk yağı bir gün önceden buzdolabında dinlendirilmiş olmalıdır.
2. Fırını 200°C''ye ısıtmaya başlayın.
3. Et ve kuyruk yağına tuzu ekleyip birlikte kıyma makinesinden çekin (veya zırhla kıyın).
4. Kıymadan elde 40 g''lık yuvarlak köfteler yapın.
5. Patlıcanların sapını kesin; şekli bozulmayacak biçimde 4-6 cm genişliğinde dilimleyin. Baştan başlayarak dilimlerin arasına köfteleri yerleştirip tepsiye dizin.
6. Biberleri şişe dizin.

**Isıl İşlem**
1. Fırınlama (200°C, 50-60 dk): Tepsiyi fırında pişirin.
2. Biber közleme (200°C, 5 dk): Şişteki biberleri fırında 5 dakika pişirin.
3. Kebabı ve biberleri fırından alıp 5 dakika dinlendirin.

**Servis:** Közlenmiş biber, dilimlenmiş kuru soğan, Urfa açık ekmeği ve ayranla servis edin.

**PARALEL YAPILABİLİRLİK:** Kebap fırındayken biberler şişe dizilebilir; biberler kebabın son 5 dakikasında aynı fırına konabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~29 dk · Pasif bekleme ~61 dk · Toplam ~90 dk (bir gün önceden et dinlendirme hariç)

**Kaynak:** Şanlıurfa Tepsi Kebabı / Urfa Tepsi Kebabı, Türk Patent Coğrafi İşaret Tescil No 1171 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 55, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (KOL)", "KUYRUKYAĞI", "PATLICAN", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Biber Közleme", "sure_dakika": 5, "aktif_dakika": 1, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "elektrik", "malzemeler": ["YEŞİL BİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Dinlendirme", "sure_dakika": 5, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Diyarbakır Usulü Etli Kavurma -> Diyarbakır Ayvalı Kavurma (CI 1139)
    select id into v_id from receteler where isletme_id is null and ad = 'Diyarbakır Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Diyarbakır Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Diyarbakır Ayvalı Kavurma') then
        raise notice 'Yeni ad zaten var, atlandi: Diyarbakır Ayvalı Kavurma';
    elsif _kopya_kullanimda_mi(v_id, 'Diyarbakır Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Diyarbakır Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Diyarbakır Ayvalı Kavurma', v_grup1_id, 1, 105,
            '["kirmizi_et"]'::jsonb, 'sonbahar', 'Güneydoğu Anadolu',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 100.0}, {"ad": "AYVA", "miktar_gram": 50.0}, {"ad": "TEREYAĞI", "miktar_gram": 4.0}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "PİDE", "miktar_gram": 40}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Diyarbakır Ayvalı Kavurma', null, '**Hazırlık / Mise en Place**
1. Kemiksiz kuzu etini kuşbaşı doğrayın.
2. Ayvaları yıkayın; kabuklarını soymayın.
3. Tırnaklı pideyi yaklaşık 2 cm''lik kareler halinde kesin.

**Isıl İşlem**
1. Pişirme (kısık ateş, tencerede, ~60 dk): Kuşbaşı eti kapaklı tencerede kısık ateşte kendi suyunda yaklaşık bir saat pişirin.
2. Sote (orta ateş, ayrı tencerede, ~20 dk): Tereyağını eritin; pişmiş eti, tuzu ve bütün (kabuklu) ayvaları ekleyip yaklaşık 20 dakika soteleyin. Et ve ayvaları tencereden alın, yağı tencerede bırakın.
3. Pide kızartma (~5 dk): Pide karelerini tencerede kalan yağda yağı çekene kadar çevirin ve servis tabağına yayın.

**Servis düzeni:** Eti pidelerin üzerine yerleştirin. Ayvaları ikiye bölüp çekirdeklerini çıkarın, et büyüklüğünde doğrayıp etin üzerine dizin. Tencerede kalan sıcak suyu üzerine gezdirip sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Et kısık ateşte pişerken başka tariflerin hazırlığı yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~37 dk · Pasif bekleme ~68 dk · Toplam ~105 dk

**Kaynak:** Diyarbakır Ayvalı Kavurma, Türk Patent Coğrafi İşaret Tescil No 1139 (10 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (BUT)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sote", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "AYVA", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pide Kızartma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİDE"], "yeni_su_gram": null}, {"sira": 5, "ad": "Servis Düzeni", "sure_dakika": 8, "aktif_dakika": 7, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mersin Usulü Etli Kavurma -> Etli Kavurma (genel temsilci, malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Mersin Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mersin Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Kavurma') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Kavurma';
    elsif _kopya_kullanimda_mi(v_id, 'Mersin Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mersin Usulü Etli Kavurma';
    else
        update receteler set ad = 'Etli Kavurma', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    raise notice 'Degisen tarif sayisi: %', v_degisen;
end $$;

drop function _kopya_kullanimda_mi(uuid, text);

commit;

-- 4) DOGRULAMA (tek sonuc tablosu): her satir icin durum
with beklenen(eski_ad, yeni_ad, beklenen_malzeme, beklenen_asama) as (values
    ('Kilis Usulü Etli Kavurma', 'Kilis Tava', 8, 2),
    ('Niğde Usulü Etli Kavurma', 'Niğde Tavası', 7, 2),
    ('Kahramanmaraş Usulü Etli Kavurma', 'Maraş Eli Böğründe', 6, 2),
    ('Gaziantep Usulü Etli Kavurma', 'Gaziantep Simit Kebabı', 8, 2),
    ('Gaziantep Usulü Etli Kavurma (Kimyonlu)', 'Gaziantep Yenidünya Kebabı', 5, 2),
    ('Şanlıurfa Usulü Etli Kavurma', 'Şanlıurfa Tepsi Kebabı', 5, 4),
    ('Diyarbakır Usulü Etli Kavurma', 'Diyarbakır Ayvalı Kavurma', 5, 5),
    ('Mersin Usulü Etli Kavurma', 'Etli Kavurma', null, null)
)
select b.yeni_ad,
       case when r.id is not null then 'TAMAM'
            when (select count(*) from receteler r2 where r2.isletme_id is null and r2.ad = b.eski_ad) > 0
                 then 'ATLANDI: kopya bir menude kullaniliyor'
            else 'HATA: ne eski ne yeni var' end as durum,
       (select count(*) from receteler r where r.isletme_id is null and r.ad = b.eski_ad) as eski_kalan,
       r.id is not null as yeni_var,
       r.mevsim_etiketi, r.hazirlik_dakika,
       (select count(*) from recete_malzemeleri rm where rm.recete_id = r.id) as malzeme,
       b.beklenen_malzeme,
       (select count(*) from recete_asamalari ra where ra.recete_id = r.id) as asama,
       b.beklenen_asama,
       (select round(sum(rm.miktar_gram), 1) from recete_malzemeleri rm where rm.recete_id = r.id) as porsiyon_cig_gram,
       r.hazirlik_talimati like '%Tescil No%' as kaynak_yazili
from beklenen b
left join receteler r on r.isletme_id is null and r.ad = b.yeni_ad
order by b.yeni_ad;
