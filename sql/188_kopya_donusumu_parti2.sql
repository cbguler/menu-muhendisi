-- 188_kopya_donusumu_parti2.sql
-- YUZ KOPYA DUZELTME, PARTI 2 (12 Ekim 2026)
-- Ayni yontem (sql/187 ile): kopya -> Turk Patent Cografi Isaret (CI) tescil belgesindeki gercek
-- yoresel tarif. Bu parti:
--   4 "X Usulü Etli Kavurma" kopyasi (Iğdır, Batman, Elazığ, Kırşehir) -> o ilin CI tarifi
--   "Konya Etli Ekmek" / "Etli Ekmek (Konya)" kopya cifti -> CI 214'e gore "Konya Etliekmek"
--     + genel "Etli Ekmek"
-- Malzeme miktarlari = CI belgesindeki toplam / porsiyon sayisi (1 porsiyon bazinda). Adet ve olcu
-- birimi cevirileri, belgede olmayan sureler ve secimler PROJE_NOTLARI.md'de TAHMIN olarak listeli.
--
-- GUVENLIK (187 ile ayni):
--  * Kopya; menu_ogeleri, menu_takvimi_ogeleri veya kayitli_aylik_menuler'de kullaniliyorsa
--    DOKUNULMAZ (dogrulama tablosunda "ATLANDI").
--  * Yeni ad kutuphanede zaten varsa atlanir.
--  * Malzemeler once kontrol edilir; biri eksikse HICBIR degisiklik yapilmadan durur.
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
    from unnest(array['CANLI MAYA', 'DANA BUT', 'DANA KIYMA', 'DOMATES', 'EKMEKLİK UN', 'KARABİBER', 'KONSERVE DOMATES SALÇASI', 'KOYUN ETİ (KOL)', 'KURU KAYISI', 'KURU SOĞAN', 'KUYRUKYAĞI', 'MAYDANOZ', 'NOHUT', 'PUL BİBER', 'SARIMSAK', 'SU', 'TEREYAĞI', 'TUZ', 'YEŞİL BİBER', 'YOĞURT (TAM)', 'ZERDEÇAL', 'ÜzÜM PEKMEZİ', 'İNCE BULGUR']::text[]) as a
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
    v_grup2_id uuid;
    v_grup3_id uuid;
    v_id uuid;
    v_degisen int := 0;
begin
    select id into v_mutfak_id from mutfaklar where kod = 'turk';
    select id into v_grup1_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 1;
    select id into v_grup2_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 2;
    select id into v_grup3_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 3;
    if v_grup1_id is null or v_grup2_id is null or v_grup3_id is null then raise exception 'Grup bulunamadi'; end if;

    -- Iğdır Usulü Etli Kavurma -> Iğdır Bozbaş (CI 792)
    select id into v_id from receteler where isletme_id is null and ad = 'Iğdır Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Iğdır Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Iğdır Bozbaş') then
        raise notice 'Yeni ad zaten var, atlandi: Iğdır Bozbaş';
    elsif _kopya_kullanimda_mi(v_id, 'Iğdır Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Iğdır Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Iğdır Bozbaş', v_grup1_id, 1, 460,
            '["kirmizi_et", "kuru_baklagil"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "KOYUN ETİ (KOL)", "miktar_gram": 250}, {"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KUYRUKYAĞI", "miktar_gram": 10}, {"ad": "ZERDEÇAL", "miktar_gram": 4}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 110}, {"ad": "SU", "miktar_gram": 150}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Iğdır Bozbaş', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gün önceden bol suda ıslatın.
2. Kuru soğanı soyun, domatesten bir dilim kesin.

**Isıl İşlem**
1. Haşlama (düdüklü tencere): Islatılmış nohudu 1,5 saat, koyun incik etini ayrı düdüklü tencerede 30 dakika haşlayın. Et suyunu saklayın.
2. Fırınlama (taş fırın veya kısık fırın, 150°C, 6 saat): Maşrapaya (toprak güveç kabı) haşlanmış nohudu, eti, kuyruk yağını ve soğanı koyun. Üzerine etin haşlama suyunu ekleyip sarıkökü (zerdeçal) serpin. Fırında 6 saat pişirin. Pişmenin bitmesine yaklaşık 10 dakika kala üzerine domates dilimini koyun.

**Servis:** Maşrapada sıcak servis edin (kişi başı bir maşrapa).

**PARALEL YAPILABİLİRLİK:** Nohut ve et aynı anda iki ayrı düdüklüde haşlanabilir; 6 saatlik fırın süresince başka işler yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~440 dk · Toplam ~460 dk (bir gün önceden nohut ıslatma hariç)

**Kaynak:** Iğdır Bozbaş Yemeği, Türk Patent Coğrafi İşaret Tescil No 792 (1 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 90, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "KOYUN ETİ (KOL)", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 360, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["NOHUT", "KOYUN ETİ (KOL)", "KUYRUKYAĞI", "KURU SOĞAN", "SU", "DOMATES"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Batman Usulü Etli Kavurma -> Batman Piçik Yemeği (CI 1508)
    select id into v_id from receteler where isletme_id is null and ad = 'Batman Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Batman Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Batman Piçik Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Batman Piçik Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Batman Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Batman Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Batman Piçik Yemeği', v_grup1_id, 1, 63,
            '["vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "İNCE BULGUR", "miktar_gram": 83.33}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "EKMEKLİK UN", "miktar_gram": 5}, {"ad": "YOĞURT (TAM)", "miktar_gram": 83.33}, {"ad": "TEREYAĞI", "miktar_gram": 16.67}, {"ad": "SARIMSAK", "miktar_gram": 1.0}, {"ad": "PUL BİBER", "miktar_gram": 1}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Batman Piçik Yemeği', null, '**Hazırlık / Mise en Place**
1. Köftelik bulgur ile ince bulguru karıştırın, üzerine su ekleyip hamur kıvamına gelene kadar yoğurun. Hamuru 30 dakika dinlendirin.
2. Hamurdan yaklaşık 2 cm çapında köfteler yuvarlayın ve una bulayın.
3. Sarımsağı ince doğrayın.

**Isıl İşlem**
1. Haşlama (kaynar su, ~10 dk): Köfteleri kaynayan tuzlu suda yüzeye çıkana kadar haşlayın, süzüp servis tabağına alın.
2. Sos (tavada, ~3 dk): Tereyağını eritin, pul biberi ve sarımsağı ekleyip kızdırın.

**Servis:** Köftelerin üzerine yoğurdu ve sıcak sosu gezdirip sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken sarımsak hazırlanabilir ve haşlama suyu ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~36 dk · Pasif bekleme ~27 dk · Toplam ~63 dk

**Kaynak:** Batman Piçik Yemeği, Türk Patent Coğrafi İşaret Tescil No 1508 (yaklaşık 6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 50, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İNCE BULGUR", "SU", "EKMEKLİK UN"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "PUL BİBER", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Elazığ Usulü Etli Kavurma -> Elazığ Sırın Yemeği (CI 1355)
    select id into v_id from receteler where isletme_id is null and ad = 'Elazığ Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Elazığ Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Elazığ Sırın Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Elazığ Sırın Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Elazığ Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Elazığ Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Elazığ Sırın Yemeği', v_grup1_id, 1, 118,
            '["vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "EKMEKLİK UN", "miktar_gram": 125.0}, {"ad": "SU", "miktar_gram": 31.25}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "SARIMSAK", "miktar_gram": 2.81}, {"ad": "YOĞURT (TAM)", "miktar_gram": 250.0}, {"ad": "TEREYAĞI", "miktar_gram": 31.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Elazığ Sırın Yemeği', null, '**Hazırlık / Mise en Place**
1. Unu, suyu ve tuzu karıştırıp yumuşak ve homojen bir hamur olana kadar yoğurun. Hamuru 30 dakika dinlendirin.
2. Hamuru yaklaşık 50 g''lık bezelere ayırın.

**Isıl İşlem**
1. Yufka pişirme (sac): Her bezeyi 50-60 cm çapında, yaklaşık 1 mm kalınlığında açın ve sacda iki yüzünü de pişirin.
2. Tereyağı kızdırma (~3 dk): Tereyağını tavada kızdırın.

**Dizme ve Servis**
1. Pişen yufkaları ikiye katlayıp rulo yapın, 6-8 cm kalınlığında kesin.
2. Kesilen parçaları rulo şekli bozulmadan, 50-60 cm çapındaki tepsiye dik ve sıkı dizin.
3. Dövülmüş sarımsağı yoğurtla homojen olana kadar karıştırın; tepsinin tüm yüzeyini kaplayacak şekilde azar azar dökün.
4. Üzerine kızdırılmış tereyağını dökün (isteğe göre pul biber serpilir) ve sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Bir kişi yufka açarken diğeri sacda pişirebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~88 dk · Pasif bekleme ~30 dk · Toplam ~118 dk

**Kaynak:** Elazığ Sırın Yemeği, Türk Patent Coğrafi İşaret Tescil No 1355 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Hamur Hazırlığı", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Yufka Pişirme", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEKLİK UN", "SU", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Tereyağı Kızdırma", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Dizme ve Servis", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kırşehir Usulü Etli Kavurma -> Kırşehir Çirleme Yemeği (CI 948)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırşehir Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırşehir Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kırşehir Çirleme Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Kırşehir Çirleme Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Kırşehir Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırşehir Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kırşehir Çirleme Yemeği', v_grup1_id, 1, 345,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "DANA BUT", "miktar_gram": 200.0}, {"ad": "KURU KAYISI", "miktar_gram": 150.0}, {"ad": "NOHUT", "miktar_gram": 50.0}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 54.8}, {"ad": "KURU SOĞAN", "miktar_gram": 22.0}, {"ad": "TEREYAĞI", "miktar_gram": 6.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 8.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "PUL BİBER", "miktar_gram": 1.5}, {"ad": "KARABİBER", "miktar_gram": 1.5}, {"ad": "SU", "miktar_gram": 100}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kırşehir Çirleme Yemeği', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gün önceden suda ıslatın.
2. Dana etini kuşbaşı doğrayın. Gün kurusu kayısıları suda yumuşamaya bırakın. Soğanı çok ince doğrayın.

**Isıl İşlem**
1. Haşlama (~60 dk): Dana etini ve nohudu ayrı tencerelerde yumuşayana kadar haşlayın. Eti küçük parçalara ayırın, et suyunu saklayın.
2. Kavurma (yayvan tencerede, ~5 dk): Tereyağını eritin, soğanı pembeleşene kadar kavurun, domates salçasını ekleyip kısa süre çevirin.
3. Pişirme (~30 dk): Eti, nohudu ve suda bekletilmiş kayısıları ekleyin. Üzerini örtecek kadar et suyu ekleyip kapağı kapalı kaynatın. Kaynamaya başlayınca pekmezi, pul biberi, tuzu ve karabiberi ekleyin; kapak kapalı, kayısılar yumuşayana kadar pişirin.
4. Dinlendirme (en az 4 saat): Yemeği servisten önce en az 4 saat dinlendirin.

**PARALEL YAPILABİLİRLİK:** Et ve nohut aynı anda haşlanabilir; kayısılar bu sırada suda bekler.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~315 dk · Toplam ~345 dk (bir gün önceden nohut ıslatma hariç; 240 dk dinlendirme dahil)

**Kaynak:** Kırşehir Çirleme Yemeği, Türk Patent Coğrafi İşaret Tescil No 948 (4-6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BUT", "NOHUT", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BUT", "NOHUT", "KURU KAYISI", "ÜzÜM PEKMEZİ", "SU", "TUZ", "PUL BİBER", "KARABİBER"], "yeni_su_gram": null}, {"sira": 5, "ad": "Dinlendirme", "sure_dakika": 240, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Etli Ekmek -> Konya Etliekmek (CI 214)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Etli Ekmek';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Etli Ekmek';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Etliekmek') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Etliekmek';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Etli Ekmek') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Etli Ekmek';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Etliekmek', v_grup1_id, 1, 90,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "EKMEKLİK UN", "miktar_gram": 111.7}, {"ad": "SU", "miktar_gram": 67.02}, {"ad": "TUZ", "miktar_gram": 1.62}, {"ad": "CANLI MAYA", "miktar_gram": 0.17}, {"ad": "DOMATES", "miktar_gram": 40}, {"ad": "YEŞİL BİBER", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 28.5}, {"ad": "MAYDANOZ", "miktar_gram": 1}, {"ad": "DANA KIYMA", "miktar_gram": 100}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Etliekmek', null, '**Hazırlık / Mise en Place**
1. Unu, tuzu, yaş mayayı ve suyu kulak memesi kıvamında olgun bir hamur olana kadar yoğurun. Hamuru 180 g''lık bezelere ayırıp oda sıcaklığında yaklaşık 1 saat dinlendirin; kullanılana kadar serin yerde tutun.
2. Dana (veya düve) kaburga kıymasını bir kez çekin ya da ince kıyın. Domates, yeşil biber ve kuru soğanı ince çekin (maydanoz hariç). Sebzeleri kıymayla homojen olana kadar yoğurun; tuzu ekleyin.
3. Hamuru ince kepek serpilmiş tezgâhta elle yaklaşık 85-90 cm boyunda, 15-20 cm eninde açın, harcı eşit yayın.

**Isıl İşlem**
1. Fırınlama (300-320°C, 4-5 dk): Odun ateşli taş fırında (veya en yüksek ısıdaki fırında) pişirin.

**Servis:** 4 veya 6 eşit parçaya kesin, üzerine maydanoz serpip sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~63 dk · Toplam ~90 dk

**Kaynak:** Konya Etliekmek, Türk Patent Coğrafi İşaret Tescil No 214 (bir adet: 180 g hamur, 100 g sebze karışımı, 100 g kıyma).',
            '[{"sira": 1, "ad": "Hamur Hazırlığı", "sure_dakika": 70, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Harç ve Açma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 5, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "SU", "DOMATES", "YEŞİL BİBER", "KURU SOĞAN", "DANA KIYMA"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Etli Ekmek (Konya) -> Etli Ekmek (genel temsilci, malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Etli Ekmek (Konya)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Etli Ekmek (Konya)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Ekmek') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Ekmek';
    elsif _kopya_kullanimda_mi(v_id, 'Etli Ekmek (Konya)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Etli Ekmek (Konya)';
    else
        update receteler set ad = 'Etli Ekmek', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    raise notice 'Degisen tarif sayisi: %', v_degisen;
end $$;

drop function _kopya_kullanimda_mi(uuid, text);

commit;

-- 4) DOGRULAMA (tek sonuc tablosu): her satir icin durum
with beklenen(eski_ad, yeni_ad, beklenen_malzeme, beklenen_asama) as (values
    ('Iğdır Usulü Etli Kavurma', 'Iğdır Bozbaş', 7, 3),
    ('Batman Usulü Etli Kavurma', 'Batman Piçik Yemeği', 8, 3),
    ('Elazığ Usulü Etli Kavurma', 'Elazığ Sırın Yemeği', 6, 4),
    ('Kırşehir Usulü Etli Kavurma', 'Kırşehir Çirleme Yemeği', 11, 5),
    ('Konya Etli Ekmek', 'Konya Etliekmek', 9, 3),
    ('Etli Ekmek (Konya)', 'Etli Ekmek', null, null)
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
