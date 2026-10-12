-- 189_kopya_donusumu_parti3.sql
-- YUZ KOPYA DUZELTME, PARTI 3 (12 Ekim 2026)
-- Ayni yontem ve guvenlik kurallari (187/188). Bu parti 8 "X Usulü Etli Kavurma" kopyasini
-- o ilin Turk Patent Cografi Isaret (CI) tescilli yemegine donusturur:
--   Adıyaman, Ağrı, Erzurum, Kastamonu, Konya, Manisa -> grup 1 ana yemek
--   Şırnak (Cizre Meyre, corba) ve Kars (Erişte Pilavı) -> grup 2 (illerin belgeli ana yemegi yok)
-- CI belgeleri Turk Patent veri tabanindan toplu indirildi (Yemekler ve corbalar: 531 tescilli,
-- Hamur isleri/tatlilar: 387 tescilli). Adet/olcu cevirileri, belgede olmayan sureler ve secimler
-- PROJE_NOTLARI.md'de TAHMIN olarak listeli.
--
-- GUVENLIK: kullanimdaki kopyaya dokunulmaz; yeni ad varsa atlanir; eksik malzemede hicbir sey
-- degismez; tek transaction.

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
    from unnest(array['AYÇİÇEK YAĞI', 'BUĞDAY (TAM TANE)', 'BUĞDAY UNU', 'DANA BUT', 'DANA KIYMA', 'EKMEKLİK UN', 'ET SUYU', 'KABAK', 'KARABİBER', 'KONSERVE BİBER SALÇASI', 'KONSERVE DOMATES SALÇASI', 'KOYUN KIYMA', 'KURU NANE', 'KURU SOĞAN', 'MAYDANOZ', 'PATATES', 'PUL BİBER', 'PİDE', 'PİRİNÇ (HAM)', 'SADEYAĞ', 'SARIMSAK', 'SU', 'SİMİT', 'TAVUK YUMURTASI', 'TEREYAĞI', 'TUZ', 'YEŞİL MERCİMEK', 'YOĞURT (TAM)', 'İNCE BULGUR']::text[]) as a
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

    -- Adıyaman Usulü Etli Kavurma -> Adıyaman Kavurmalı Hıtap (CI 1895)
    select id into v_id from receteler where isletme_id is null and ad = 'Adıyaman Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Adıyaman Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Adıyaman Kavurmalı Hıtap') then
        raise notice 'Yeni ad zaten var, atlandi: Adıyaman Kavurmalı Hıtap';
    elsif _kopya_kullanimda_mi(v_id, 'Adıyaman Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Adıyaman Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Adıyaman Kavurmalı Hıtap', v_grup1_id, 1, 95,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "EKMEKLİK UN", "miktar_gram": 70.0}, {"ad": "SU", "miktar_gram": 20.0}, {"ad": "TUZ", "miktar_gram": 3.0}, {"ad": "DANA BUT", "miktar_gram": 60.0}, {"ad": "KURU SOĞAN", "miktar_gram": 33.0}, {"ad": "SARIMSAK", "miktar_gram": 10.0}, {"ad": "PUL BİBER", "miktar_gram": 2.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 5.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 5.0}, {"ad": "MAYDANOZ", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Adıyaman Kavurmalı Hıtap', null, '**Hazırlık / Mise en Place**
1. Unu, tuzu ve suyu yeterli büyüklükte bir kapta ortalama 15 dakika homojen olana kadar yoğurun ve dinlendirin.
2. İç harç: Kuşbaşı doğranmış dana etini ince doğranmış soğan, taze sarımsak, maydanoz, pul biber, biber salçası, domates salçası ve tuzla karıştırın. (Fırında pişirilecekse soğan çiğ olarak harca katılır.)
3. Hamuru 70-100 g''lık bezelere ayırın, elle 25 cm çapında daire şeklinde açın.
4. Hamurun yarısına iç harcı koyun, diğer yarısını üzerine yarım ay şeklinde kapatın ve kenarları parmak uçlarıyla bastırarak yapıştırın. İki elle hafifçe sündürerek uzatın.

**Isıl İşlem**
1. Fırınlama (taş/pide fırını, ~15 dk): Hıtapları küreğe alıp fırına sürün ve 15 dakika pişirin.

**Servis:** Bütün ya da dilimlenmiş olarak, sıcak ve ayranla servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~52 dk · Pasif bekleme ~43 dk · Toplam ~95 dk

**Kaynak:** Adıyaman Kavurmalı Hıtap, Türk Patent Coğrafi İşaret Tescil No 1895 (10 adet; fırın tipi üretim).',
            '[{"sira": 1, "ad": "Hamur Hazırlığı", "sure_dakika": 45, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Harç ve Şekillendirme", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "SU", "DANA BUT", "KURU SOĞAN"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ağrı Usulü Etli Kavurma -> Doğubayazıt Abdigör Köftesi (CI 310)
    select id into v_id from receteler where isletme_id is null and ad = 'Ağrı Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ağrı Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Doğubayazıt Abdigör Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Doğubayazıt Abdigör Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Ağrı Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ağrı Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Doğubayazıt Abdigör Köftesi', v_grup1_id, 1, 105,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "DANA BUT", "miktar_gram": 166.67}, {"ad": "KURU SOĞAN", "miktar_gram": 16.67}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 8.33}, {"ad": "BUĞDAY UNU", "miktar_gram": 1.67}, {"ad": "SU", "miktar_gram": 16.67}, {"ad": "TUZ", "miktar_gram": 1.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Doğubayazıt Abdigör Köftesi', null, '**Hazırlık / Mise en Place**
1. Yağsız sığır but etini taş tezgâha ("sal") yayın, bir tutam tuz atarak ahşap tokmakla dövün. Dövülürken çıkan sinirleri ayıklayın. Et macun kıvamını alana kadar yaklaşık 1 saat dövmeye devam edin.
2. Rendelenmiş soğanı ekleyin; et ve soğan bütünleşene kadar dövmeye devam edin.
3. Eti 15 dakika dinlendirip bir kaba alın. Yumurtayı, unu ve suyu ekleyip karıştırın.

**Isıl İşlem**
1. Haşlama (hafif ateş, ~15 dk): Yaklaşık 3 litre suyu tencerede kaynatın, 15 g tuz ekleyin. Et karışımından küre biçiminde toplar yapıp suya yavaşça bırakın; köfteler pişene kadar hafif ateşte kaynatın.

**Servis:** Sudan çıkarıp sade pirinç pilavı ile sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Et dinlenirken haşlama suyu ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~78 dk · Pasif bekleme ~27 dk · Toplam ~105 dk

**Kaynak:** Doğubayazıt Abdigör Köftesi, Türk Patent Coğrafi İşaret Tescil No 310 (1 kg kemiksiz et için).',
            '[{"sira": 1, "ad": "Et Dövme", "sure_dakika": 75, "aktif_dakika": 75, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Dinlendirme ve Harç", "sure_dakika": 15, "aktif_dakika": 1, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Haşlama", "sure_dakika": 15, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BUT", "KURU SOĞAN", "TAVUK YUMURTASI", "BUĞDAY UNU", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Etli Kavurma -> Hınıs Köftesi (CI 1655)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Hınıs Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Hınıs Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Hınıs Köftesi', v_grup1_id, 1, 96,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "DANA KIYMA", "miktar_gram": 181.82}, {"ad": "İNCE BULGUR", "miktar_gram": 50.0}, {"ad": "SU", "miktar_gram": 13.64}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 27.27}, {"ad": "KARABİBER", "miktar_gram": 4.55}, {"ad": "TUZ", "miktar_gram": 8.64}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15.85}, {"ad": "TEREYAĞI", "miktar_gram": 5.0}, {"ad": "KURU SOĞAN", "miktar_gram": 20.0}, {"ad": "MAYDANOZ", "miktar_gram": 3.18}, {"ad": "PUL BİBER", "miktar_gram": 1.36}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Hınıs Köftesi', null, '**Hazırlık / Mise en Place**
1. İç harç (kıymalı): Kıymayı sıvı yağ ve tereyağında orta ateşte 10-15 dakika pişirin. İnce kıyılmış soğanı ekleyip 5-6 dakika daha pişirin. Baharatları ve maydanozu ekleyip 2-3 dakika pişirin, ocaktan alıp soğumaya bırakın.
2. Dış harç: İki kez çekilmiş kıyma ile bulguru elle yoğurun. Yoğururken karabiber, pul biber ve tuzu azar azar ekleyin; sakız kıvamı oluşsun diye ılık suyu devamlı ilave edin. Kıvama gelmeye yakın yumurtayı ekleyin.
3. Elleri aralıklı ıslatarak dış harçtan yuvarlak parçalar alın, ortasına soğumuş iç harçtan koyup kapatın ve avuç içiyle hafifçe bastırarak yassılaştırın.

**Isıl İşlem**
1. Haşlama (10-12 dk): Köfteleri tuzlu kaynar suda haşlayıp sudan çıkarın.
2. Kızartma (10-15 dk): Haşlanmış köfteleri yumurtaya batırıp kızdırılmış sıvı yağda pişirin.

**Servis:** Sıcak olarak tabaklayıp servis edin.

**PARALEL YAPILABİLİRLİK:** İç harç soğurken dış harç yoğrulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~88 dk · Pasif bekleme ~8 dk · Toplam ~96 dk

**Kaynak:** Hınıs Köftesi, Türk Patent Coğrafi İşaret Tescil No 1655 (5-6 kişilik, kıymalı iç harç).',
            '[{"sira": 1, "ad": "İç Harç Pişirme", "sure_dakika": 22, "aktif_dakika": 22, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "AYÇİÇEK YAĞI", "TEREYAĞI", "KURU SOĞAN", "MAYDANOZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Dış Harç ve Şekillendirme", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Haşlama", "sure_dakika": 11, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "İNCE BULGUR", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 13, "aktif_dakika": 13, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AYÇİÇEK YAĞI", "TAVUK YUMURTASI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kastamonu Usulü Etli Kavurma -> Kastamonu Tiridi (CI 474)
    select id into v_id from receteler where isletme_id is null and ad = 'Kastamonu Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kastamonu Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kastamonu Tiridi') then
        raise notice 'Yeni ad zaten var, atlandi: Kastamonu Tiridi';
    elsif _kopya_kullanimda_mi(v_id, 'Kastamonu Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kastamonu Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kastamonu Tiridi', v_grup1_id, 1, 22,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "SİMİT", "miktar_gram": 110}, {"ad": "ET SUYU", "miktar_gram": 150}, {"ad": "SARIMSAK", "miktar_gram": 4.5}, {"ad": "DANA KIYMA", "miktar_gram": 55}, {"ad": "YOĞURT (TAM)", "miktar_gram": 150}, {"ad": "TUZ", "miktar_gram": 4}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kastamonu Tiridi', null, '**Hazırlık / Mise en Place**
1. Kemik suyu önceden hazırlanmış olmalıdır (büyükbaş kaval kemiği 3-4 parçaya bölünüp 2-2,5 saat kaynatılır, tuz eklenir).
2. Kastamonu simitlerini elle, başparmak uzunluğunda parçalara koparın (bıçak kullanılmaz).
3. Sarımsağı ezip yoğurtla karıştırın.

**Isıl İşlem**
1. Kavurma (~10 dk): Sırt etinden çekilmiş satır kıymasını kendi yağıyla suyunu çekene kadar kavurun.

**Servis düzeni**
1. Koparılan simitleri bakır sahana veya porselen tabağa yerleştirin, üzerine sıcak kemik suyu dökün. Kemik suyu yalnızca simitleri ıslatacak kadar kullanılır; fazlası boşaltılır.
2. Islanmış simitlerin üzerini örtecek kadar sarımsaklı yoğurdu ekleyin.
3. Üzerine sıcak kavrulmuş kıymayı koyun. İstenirse bakır tavada köpürene kadar kızdırılan 20-25 g tereyağı dökülerek servis edilir.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken simitler ıslatılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk · Pasif bekleme ~0 dk · Toplam ~22 dk (kemik suyu hazırlığı hariç)

**Kaynak:** Kastamonu Tiridi / Kastamonu Simit Tiridi, Türk Patent Coğrafi İşaret Tescil No 474.',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 7, "aktif_dakika": 7, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA"], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis Düzeni", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Usulü Etli Kavurma -> Konya Çullama (CI 1049)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Çullama') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Çullama';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Çullama', v_grup1_id, 1, 53,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 125.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 35.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "BUĞDAY UNU", "miktar_gram": 2.75}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 50.0}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Çullama', null, '**Hazırlık / Mise en Place**
1. Pirinci yarı haşlayın, soğanı ince kıyın.
2. İnce çekilmiş koyun kıyması, pirinç, soğan, tuz ve karabiberi bir kaba alıp homojen olana kadar yoğurun.
3. Harcı avuç içinde sıkarak 4 cm çapında parçalara ayırın ve yuvarlayın.
4. Ayrı bir kapta unu ve yumurtaları karıştırın.

**Isıl İşlem**
1. Pirinç yarı haşlama (~8 dk).
2. Haşlama (10 dk): 1 litre suyu 10 g tuzla kaynatın, köfteleri kaynayan suda 10 dakika haşlayın.
3. Kızartma (~10 dk): Haşlanan köfteleri un-yumurta karışımına bulayıp tereyağında kızartın.

**Servis:** Soğan ve maydanoz salatası ile servis edin.

**PARALEL YAPILABİLİRLİK:** Köfteler haşlanırken kaplama karışımı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~38 dk · Pasif bekleme ~15 dk · Toplam ~53 dk

**Kaynak:** Konya Çullama, Türk Patent Coğrafi İşaret Tescil No 1049 (4 kişilik).',
            '[{"sira": 1, "ad": "Pirinç Yarı Haşlama", "sure_dakika": 8, "aktif_dakika": 1, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hazırlık", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Haşlama", "sure_dakika": 10, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN KIYMA", "PİRİNÇ (HAM)", "KURU SOĞAN"], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "TAVUK YUMURTASI", "BUĞDAY UNU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Manisa Usulü Etli Kavurma -> Akhisar Köfte (CI 322)
    select id into v_id from receteler where isletme_id is null and ad = 'Manisa Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Manisa Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Akhisar Köfte') then
        raise notice 'Yeni ad zaten var, atlandi: Akhisar Köfte';
    elsif _kopya_kullanimda_mi(v_id, 'Manisa Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Manisa Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Akhisar Köfte', v_grup1_id, 1, 43,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "DANA KIYMA", "miktar_gram": 89.72}, {"ad": "KURU SOĞAN", "miktar_gram": 4.49}, {"ad": "TUZ", "miktar_gram": 1.79}, {"ad": "PİDE", "miktar_gram": 50}, {"ad": "TEREYAĞI", "miktar_gram": 5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Akhisar Köfte', null, '**Hazırlık / Mise en Place**
1. Köfte hamuru bir gece önceden hazırlanmalıdır: Dana etini ortalama 200 g''lık parçalara doğrayın. Kilogram ete ortalama 50 g doğranmış soğan ve 20 g tuz karıştırıp kıyma makinesinden çekin. Kıymayı 5-10 dakika, hamur homojen ve sert olana kadar yoğurun. Hamuru 8-12 saat dinlendirin.
2. Dinlenen hamurdan 15-17 g''lık parçaları avuç içinde sıkarak, parmak izleri belirgin kalacak şekilde köfte yapın (porsiyon başı 6 adet).

**Isıl İşlem**
1. Izgara (küllenmiş, orta ısıda odun kömürü; alevsiz): Köftenin üzeri hafif terledikten sonra çevirin. Birkaç kez çevirerek köfte suyunu salıp orta esneklik kazanana ve kiremit kahverenginden biraz koyu renge gelene kadar pişirin.
2. Pide ıslatma: Pideyi tereyağı ve su ile ıslatılmış tava ızgarada ıslatın.

**Servis:** Köfteleri tereyağıyla ıslatılmış pidenin üzerinde, geniş tabakta servis edin. Yanına mevsime göre roka, maydanoz, kuru soğan, pişmiş yeşil biber, domates konur.

**PARALEL YAPILABİLİRLİK:** Köfteler pişerken pide ıslatılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~43 dk · Pasif bekleme ~0 dk · Toplam ~43 dk (8-12 saatlik hamur dinlendirme hariç)

**Kaynak:** Akhisar Köfte, Türk Patent Coğrafi İşaret Tescil No 322 (porsiyon: 6 adet).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pide Islatma", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİDE", "TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şırnak Usulü Etli Kavurma -> Cizre Meyre (CI 1465)
    select id into v_id from receteler where isletme_id is null and ad = 'Şırnak Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şırnak Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Cizre Meyre') then
        raise notice 'Yeni ad zaten var, atlandi: Cizre Meyre';
    elsif _kopya_kullanimda_mi(v_id, 'Şırnak Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şırnak Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Cizre Meyre', v_grup2_id, 1, 90,
            '["corba", "vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "YOĞURT (TAM)", "miktar_gram": 120.0}, {"ad": "KABAK", "miktar_gram": 40.0}, {"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 30.0}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "SU", "miktar_gram": 180.0}, {"ad": "KURU NANE", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Cizre Meyre', null, '**Hazırlık / Mise en Place**
1. Dövme buğdayı bir gece önceden suda bekletin; yıkayıp süzün.
2. Kabakları yıkayın, çekirdeklerini çıkarıp kuşbaşı doğrayın.

**Isıl İşlem**
1. Pişirme (~80 dk): Dövme buğdayı tencerede suyla yüksek ateşte kaynamaya bırakın. Bu sırada yoğurdu ayrı bir kapta 30-35 dakika homojen olana kadar çırpın ve kaynayan tencereye ekleyin; sürekli karıştırın. Kabakları ekleyip karıştırmaya devam edin. 60. dakikada kuru yarpuzu ekleyin. Dövme buğday iyice yumuşayana kadar sürekli karıştırarak pişirin; tuzu ekleyin.

**Servis:** Sıcak, soğuk ya da soğuduktan sonra buz eklenerek servis edilebilir.

**PARALEL YAPILABİLİRLİK:** Buğday kaynarken yoğurt çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~70 dk · Pasif bekleme ~20 dk · Toplam ~90 dk (bir gece önceden buğday ıslatma hariç)

**Kaynak:** Cizre Meyre / Cizre Mehir, Türk Patent Coğrafi İşaret Tescil No 1465 (10 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 80, "aktif_dakika": 60, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YOĞURT (TAM)", "KABAK", "BUĞDAY (TAM TANE)", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kars Usulü Etli Kavurma -> Kars Erişte Pilavı (CI 1871)
    select id into v_id from receteler where isletme_id is null and ad = 'Kars Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kars Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kars Erişte Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Kars Erişte Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Kars Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kars Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kars Erişte Pilavı', v_grup2_id, 1, 175,
            '["pilav_makarna_borek", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 83.33}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 16.67}, {"ad": "TUZ", "miktar_gram": 5.0}, {"ad": "SU", "miktar_gram": 66.67}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 33.33}, {"ad": "SADEYAĞ", "miktar_gram": 5.0}, {"ad": "PATATES", "miktar_gram": 71.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kars Erişte Pilavı', null, '**Hazırlık / Mise en Place**
1. Yeşil mercimeği bir gece önceden 1 litre suda bekletin.
2. Erişte: Elenmiş una tuzu ekleyip karıştırın, yumurtaları kırın ve 22-23°C''deki suyu azar azar ekleyerek sert bir hamur yoğurun. Hamuru bezelere ayırıp unlu tepsiye dizin. Bezeyi merdaneyle daire yapın, sonra oklavayla yufka büyüklüğünde açın (bol un kullanın). Yufkayı 0,2-0,3 cm eninde, 2-3 cm boyunda şeritler halinde kesin (erişte makinesi de kullanılabilir). Erişteleri bez üzerine serip veya iplere asıp 1-2 gün havada kurutun.
3. Patatesleri soyup halka şeklinde dilimleyin.

**Isıl İşlem**
1. Fırında kurutma (70-80°C, ~60 dk): Havada kurumuş erişteleri ızgaralara dizip fırında kurutun.
2. Mercimek haşlama (20 dk): Islatılmış mercimeğin suyunu süzün, 1 litre su ekleyip 20 dakika kaynatın ve süzün.
3. Erişte haşlama (~10 dk): Erişteleri haşlayıp süzün; mercimekle karıştırıp bekletin.
4. Patates kızartma (~10 dk): Patates halkalarını hafifçe kızartıp tencerenin tabanına döşeyin.
5. Demleme (15 dk): Patateslerin üzerine erişte-mercimek karışımını koyun. Sarı yağı eritip üzerine dökün, kapağı kapatıp 15 dakika demlendirin.

**Servis:** Tencereyi servis tabağına ters çevirin; patatesler en üstte kalacak şekilde sunun.

**PARALEL YAPILABİLİRLİK:** Mercimek haşlanırken erişte haşlanabilir ve patates kızartılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~90 dk · Pasif bekleme ~85 dk · Toplam ~175 dk (mercimek ıslatma ve 1-2 gün erişte kurutma hariç)

**Kaynak:** Kars Erişte Pilavı, Türk Patent Coğrafi İşaret Tescil No 1871 (6 kişilik).',
            '[{"sira": 1, "ad": "Erişte Hamuru ve Kesme", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırında Kurutma", "sure_dakika": 60, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "TAVUK YUMURTASI", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Mercimek Haşlama", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YEŞİL MERCİMEK"], "yeni_su_gram": null}, {"sira": 4, "ad": "Erişte Haşlama", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 5, "ad": "Patates Kızartma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATATES", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 6, "ad": "Demleme", "sure_dakika": 15, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SADEYAĞ", "YEŞİL MERCİMEK", "PATATES"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    raise notice 'Degisen tarif sayisi: %', v_degisen;
end $$;

drop function _kopya_kullanimda_mi(uuid, text);

commit;

-- 4) DOGRULAMA (tek sonuc tablosu): her satir icin durum
with beklenen(eski_ad, yeni_ad, beklenen_malzeme, beklenen_asama) as (values
    ('Adıyaman Usulü Etli Kavurma', 'Adıyaman Kavurmalı Hıtap', 10, 3),
    ('Ağrı Usulü Etli Kavurma', 'Doğubayazıt Abdigör Köftesi', 6, 3),
    ('Erzurum Usulü Etli Kavurma', 'Hınıs Köftesi', 11, 4),
    ('Kastamonu Usulü Etli Kavurma', 'Kastamonu Tiridi', 6, 3),
    ('Konya Usulü Etli Kavurma', 'Konya Çullama', 8, 4),
    ('Manisa Usulü Etli Kavurma', 'Akhisar Köfte', 5, 3),
    ('Şırnak Usulü Etli Kavurma', 'Cizre Meyre', 6, 2),
    ('Kars Usulü Etli Kavurma', 'Kars Erişte Pilavı', 8, 6)
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
