-- 190_kopya_donusumu_buyuk_parti1.sql
-- YUZ KOPYA DUZELTME, BUYUK PARTI (parti 4: 69 donusum + 41 genel temsilci) - 13 Ekim 2026
-- Ayni yontem ve guvenlik kurallari (187-189). Her "X Usulü ..." kopyasi o ilin/ilcenin Turk Patent
-- Cografi Isaret (CI) tescil belgesindeki gercek yemegine donusturulur; miktarlar belgedeki toplamlarin
-- porsiyon sayisina bolunmesiyle bulundu. Belgede olmayan sayilar (porsiyon sayisi, adet->gram, sure,
-- katalogda olmayan malzemenin karsiligi) PROJE_NOTLARI.md'de tarif tarif TAHMIN olarak listeli.
-- Ayni kopya grubundan bir tarif, grubun genel adiyla (bolge Genel) tek temsilci olarak kalir.
--
-- GUVENLIK: kullanimdaki kopyaya dokunulmaz; yeni ad varsa atlanir; eksik malzemede hicbir sey
-- degismez; tek transaction. Sonuc tablosunun ilk satiri (_OZET) toplam durumu verir.

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
    from unnest(array['ACUR', 'AYÇİÇEK YAĞI', 'BADEM (İÇ)', 'BAKLA', 'BAL', 'BIRAKIN YUMURTA SARISI', 'BULGUR', 'BUĞDAY (TAM TANE)', 'BUĞDAY NİŞASTASI', 'BUĞDAY UNU', 'BÖRÜLCE (KURU)', 'CEVİZ (İÇ)', 'DANA BUT', 'DANA KIYMA', 'DANA KOL', 'DOMATES', 'DONYAĞI', 'EKMEK (BEYAZ)', 'ERİK', 'ET SUYU', 'FINDIK (İÇ)', 'HAMSİ', 'HAVUÇ', 'ISPANAK', 'KABAK', 'KALDIRIK', 'KARABİBER', 'KARALAHANA', 'KARBONAT (YEM. SODA)', 'KAYMAK', 'KEKİK', 'KEÇİ ETİ (BUT)', 'KEÇİ ETİ (KOL)', 'KIRMIZI BİBER', 'KONSERVE BİBER SALÇASI', 'KONSERVE DOMATES SALÇASI', 'KONSERVE TURŞU', 'KOYUN ETİ (KOL)', 'KOYUN KIYMA', 'KURU MAYA', 'KURU NANE', 'KURU SOĞAN', 'KURU ÜZÜM', 'KURUTULMUŞ ERIK', 'KUYRUKYAĞI', 'KUZU ETİ (BEL)', 'KUZU ETİ (BUT)', 'KUZU ETİ (KOL)', 'KUZU ETİ (SIRT)', 'KUZU KIYMA', 'KUZU PİRZOLA', 'KUŞ ÜZÜMÜ', 'KİMYON', 'LABADA', 'LAHANA', 'LOR PEYNİRİ', 'LİMON', 'LİMON SUYU', 'MAKARNA', 'MAYDANOZ', 'MISIR UNU', 'NAR', 'NAR EKŞİSİ', 'NOHUT', 'PATATES', 'PATLICAN', 'PAZI', 'PUL BİBER', 'PİDE', 'PİRİNÇ (HAM)', 'ROKA', 'SADEYAĞ', 'SALAMURA YAPRAK', 'SALATALIK', 'SARIMSAK', 'SEMİZOTU', 'SIĞIR KABURGA', 'SIĞIR KIYMA', 'SU', 'SUMAK', 'SUSAM', 'SÜT (TAM YAĞ)', 'SÜZME YOĞURT', 'SİRKE', 'TARÇIN', 'TATLIKA KIRMIZI BİBER', 'TAVUK BUT', 'TAVUK GÖĞÜS', 'TAVUK SUYU', 'TAVUK YUMURTASI', 'TAZE DEREOTU', 'TAZE FASULYE', 'TAZE FESLEĞEN', 'TAZE KİŞNİŞ', 'TAZE NANE', 'TAZE SOĞAN', 'TAZE TARRAGON', 'TEREYAĞI', 'TOZ ŞEKER', 'TUZ', 'YENİBAHAR', 'YENİLEBİLİR SAKATAT (DANA KARACİĞER)', 'YER FISTIĞI (KAVRULMUŞ)', 'YEŞİL BİBER', 'YEŞİL MERCİMEK', 'YOĞURT (TAM)', 'ZEYTİNYAĞI', 'ÇAM FISTIĞI', 'ÇİRİŞ', 'ÜzÜM PEKMEZİ', 'İNCE BULGUR', 'İRMİK', 'ŞEHRİYE']::text[]) as a
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

    -- Anamur Usulü Zeytinyağlı Bakla -> Anamur Batırığı (CI 1534)
    select id into v_id from receteler where isletme_id is null and ad = 'Anamur Usulü Zeytinyağlı Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Anamur Usulü Zeytinyağlı Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Anamur Batırığı') then
        raise notice 'Yeni ad zaten var, atlandi: Anamur Batırığı';
    elsif _kopya_kullanimda_mi(v_id, 'Anamur Usulü Zeytinyağlı Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Anamur Usulü Zeytinyağlı Bakla';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Anamur Batırığı', v_grup2_id, 1, 75,
            '["corba", "vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
            '[{"ad": "İNCE BULGUR", "miktar_gram": 50.0}, {"ad": "DOMATES", "miktar_gram": 135.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 7.5}, {"ad": "YER FISTIĞI (KAVRULMUŞ)", "miktar_gram": 125.0}, {"ad": "SUSAM", "miktar_gram": 30.0}, {"ad": "KURU SOĞAN", "miktar_gram": 150.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 4.0}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "LİMON SUYU", "miktar_gram": 4.0}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2.5}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "LAHANA", "miktar_gram": 125.0}, {"ad": "SALATALIK", "miktar_gram": 30.0}, {"ad": "TAZE SOĞAN", "miktar_gram": 15.0}, {"ad": "SU", "miktar_gram": 150.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Anamur Batırığı', null, '**Hazırlık / Mise en Place**
1. İnce bulguru (düğürcük) yoğurma kabına alın, üzerine rendelenmiş pembe domatesin (110 g) tamamını ekleyin ve 15 dakika bekletin.
2. Rendelenmiş soğanı (25 g) ve domates kurusunu ekleyin; tercihe göre çok az biber salçası katın.
3. Yer fıstığını ve susamı kavurup robotta çekin; az su ekleyerek pürüzsüz bir kıvam alın ve bulgurlu karışıma katın.
4. Fıstık ve susam yağı çıkana kadar macun kıvamında yoğurun. Biber salçası, limon suyu, nar ekşisi, tuz ve toz acı biberi ekleyip karıştırın.
5. Karışımın bir kısmından ceviz büyüklüğünde parçalar alıp elle oval şekil verin ("sıkma").

**Isıl İşlem**
1. Lahana ve soğan haşlama (~20 dk): Lahana yapraklarını (damarlarıyla) ve kalan soğanı (125 g) iyice haşlayıp doğrayın.

**Servis düzeni**
1. Karışımın kalan kısmına soğuk su ekleyip çorba kıvamına getirin.
2. Haşlanmış lahana ve soğanı, küp doğranmış domatesi (25 g), salatalığı ve yeşil soğanı ekleyin; üzerine kuru nane serpip sıkmalarla birlikte, tercihen acı biberle servis edin.

**PARALEL YAPILABİLİRLİK:** Bulgur domateste beklerken fıstık-susam kavrulup çekilebilir; lahana bu sırada haşlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~48 dk · Pasif bekleme ~27 dk · Toplam ~75 dk

**Kaynak:** Anamur Batırığı, Türk Patent Coğrafi İşaret Tescil No 1534 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık ve Yoğurma", "sure_dakika": 45, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Lahana ve Soğan Haşlama", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LAHANA", "KURU SOĞAN"], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis Düzeni", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ankara Usulü Etli Kavurma (Kimyonlu) -> Kazan Kavurması (CI 1225)
    select id into v_id from receteler where isletme_id is null and ad = 'Ankara Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ankara Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kazan Kavurması') then
        raise notice 'Yeni ad zaten var, atlandi: Kazan Kavurması';
    elsif _kopya_kullanimda_mi(v_id, 'Ankara Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ankara Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kazan Kavurması', v_grup1_id, 1, 250,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "DANA KOL", "miktar_gram": 123.0}, {"ad": "KURU SOĞAN", "miktar_gram": 13.5}, {"ad": "TEREYAĞI", "miktar_gram": 13.5}, {"ad": "TUZ", "miktar_gram": 7.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kazan Kavurması', null, '**Hazırlık / Mise en Place**
1. Dananın kol kısmından alınmış kemiksiz eti 0-4°C''de 1-2 gün dinlendirin; sinirini ve varsa yağını ayıklayın. Ete şoklama veya terbiye uygulanmaz.
2. Eti kuşbaşı doğrayın, kuru soğanı doğrayın.

**Isıl İşlem**
1. Kavurma (kısık ateş, 3-4 saat): Eti, soğanı ve tereyağını tencereye koyun. 1-2 dakikada bir tahta kaşıkla karıştırarak kısık ateşte kendi suyunda pişirin. Baharat dahil hiçbir katkı eklenmez; pişirme sırasında su eklenmez ve kavurmanın suyu alınmaz. Tuzu ekleyin.
2. Dinlendirme (30 dk): Piştikten sonra 30 dakika dinlendirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~80 dk · Pasif bekleme ~170 dk · Toplam ~250 dk (1-2 günlük et dinlendirme hariç)

**Kaynak:** Kazan Kavurması, Türk Patent Coğrafi İşaret Tescil No 1225 (porsiyon 150 g).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 210, "aktif_dakika": 70, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KOL", "KURU SOĞAN", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Dinlendirme", "sure_dakika": 30, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ankara Usulü Zeytinyağlı Pırasa -> Beypazarı Dolması (CI 1115)
    select id into v_id from receteler where isletme_id is null and ad = 'Ankara Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ankara Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Beypazarı Dolması') then
        raise notice 'Yeni ad zaten var, atlandi: Beypazarı Dolması';
    elsif _kopya_kullanimda_mi(v_id, 'Ankara Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ankara Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Beypazarı Dolması', v_grup2_id, 1, 120,
            '["dolma"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "SALAMURA YAPRAK", "miktar_gram": 100.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 36.0}, {"ad": "KUZU KIYMA", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 35.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 30.0}, {"ad": "TAZE SOĞAN", "miktar_gram": 20.0}, {"ad": "MAYDANOZ", "miktar_gram": 15.0}, {"ad": "TAZE DEREOTU", "miktar_gram": 10.0}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "PUL BİBER", "miktar_gram": 1.4}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 0.8}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15.6}, {"ad": "SU", "miktar_gram": 60.0}, {"ad": "LİMON SUYU", "miktar_gram": 6.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Beypazarı Dolması', null, '**Hazırlık / Mise en Place**
1. Salamura yaprağı bir gece önceden suda bekletip fazla tuzundan arındırın ve iyice yıkayın.
2. Kuru soğanı, yeşil soğanı, maydanozu ve dereotunu ince kıyın. Yıkanmış pirinç, kuzu kıyması, kırmızı toz biber, pul biber, karabiber, salça, tuz ve limon suyu ile iyice karıştırın.
3. Yaprakların üzerine birer miktar harç koyup sıkı, ince ve serçe parmak büyüklüğünde sarın. Tencereye sıralar halinde, boşluk kalmayacak şekilde dizin.

**Isıl İşlem**
1. Pişirme (kısık ateş, toplam 45 dk): Üzerine 100 ml su ve sıvı yağı ekleyip 15 dakika pişirin; ardından 500 ml su ekleyip 30 dakika daha pişirin.

**Servis:** Yemeğin suyu ile birlikte servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~80 dk · Pasif bekleme ~40 dk · Toplam ~120 dk (bir gece yaprak bekletme hariç)

**Kaynak:** Beypazarı Dolması, Türk Patent Coğrafi İşaret Tescil No 1115 (yaklaşık 10 kişilik).',
            '[{"sira": 1, "ad": "Harç Hazırlığı", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sarma ve Dizme", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SALAMURA YAPRAK", "PİRİNÇ (HAM)", "KUZU KIYMA", "AYÇİÇEK YAĞI", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Balıkesir Usulü Etli Kavurma -> Balıkesir Etli Çorba (CI 1785)
    select id into v_id from receteler where isletme_id is null and ad = 'Balıkesir Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Balıkesir Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Balıkesir Etli Çorba') then
        raise notice 'Yeni ad zaten var, atlandi: Balıkesir Etli Çorba';
    elsif _kopya_kullanimda_mi(v_id, 'Balıkesir Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Balıkesir Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Balıkesir Etli Çorba', v_grup2_id, 1, 575,
            '["corba"]'::jsonb, 'kis', 'Marmara',
            '[{"ad": "DANA KOL", "miktar_gram": 40.0}, {"ad": "KURU SOĞAN", "miktar_gram": 3.5}, {"ad": "LİMON", "miktar_gram": 0.55}, {"ad": "HAVUÇ", "miktar_gram": 0.55}, {"ad": "TUZ", "miktar_gram": 5.5}, {"ad": "SU", "miktar_gram": 175.0}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 2.7}, {"ad": "YOĞURT (TAM)", "miktar_gram": 5.5}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 0.55}, {"ad": "TEREYAĞI", "miktar_gram": 20.75}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 5.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 17.5}, {"ad": "SARIMSAK", "miktar_gram": 1.75}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Balıkesir Etli Çorba', null, '**Hazırlık / Mise en Place**
1. Kaval kemiklerini ikiye kırın; kemiksiz eti büyük parçalar halinde kazana koyun. Üzerini geçecek kadar soğuk su ekleyip yaklaşık 1 saat kanlı suyunu atmasını bekleyin, suyu boşaltın.

**Isıl İşlem**
1. Haşlama (7-8 saat): Üzerini geçecek kadar taze soğuk su, soğan, limon, havuç ve tuz ekleyin. Kaynarken çıkan köpüğü kevgirle tamamen alın, kapağı kapatıp 7-8 saat pişirin. Etleri çıkarın, kemik suyunu temiz bir tencereye süzün.
2. Soğuk meyane: Su, yumurta sarıları, yoğurt ve nişastayı pürüzsüz olana kadar çırpın.
3. Sıcak terbiye (30-40 dk): Tereyağı ve ayçiçek yağını kızdırın, pembeleşince ateşi kısıp unu ekleyerek çırpın; kum tanesi gibi gözenekli olana kadar kavurun. Soğuk meyaneyi ekleyip 5-10 dakika çırpın.
4. Birleştirme: Terbiyeyi kaynayan kemik suyuna ekleyin, kaynayana (kabarana) kadar çırpın ve ocağı kapatın.
5. Sos: Tereyağını eritip tatlı toz kırmızı biberle yakın.

**Servis:** Benmaride sıcak bekleyen çorbayı 150-200 g''lık kâselere koyun, satırla parçalanmış etten 20 g ekleyin, üzerine biberli tereyağı gezdirin. İsteğe göre sarımsak sos ve limonla sunun.

**PARALEL YAPILABİLİRLİK:** Et haşlanırken meyane ve sıcak terbiye hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~90 dk · Pasif bekleme ~485 dk · Toplam ~575 dk

**Kaynak:** Balıkesir Etli Çorba, Türk Patent Coğrafi İşaret Tescil No 1785 (100 porsiyon).',
            '[{"sira": 1, "ad": "Kan Alma", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 450, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KOL", "KURU SOĞAN", "LİMON", "HAVUÇ", "TUZ", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Meyane ve Terbiye", "sure_dakika": 45, "aktif_dakika": 45, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BIRAKIN YUMURTA SARISI", "YOĞURT (TAM)", "BUĞDAY NİŞASTASI", "TEREYAĞI", "AYÇİÇEK YAĞI", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Birleştirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Sos ve Servis", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SARIMSAK", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Balıkesir Usulü Kavurmalı Yumurta -> Balıkesir Düğün Çorbası (CI 1562)
    select id into v_id from receteler where isletme_id is null and ad = 'Balıkesir Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Balıkesir Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Balıkesir Düğün Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Balıkesir Düğün Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Balıkesir Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Balıkesir Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Balıkesir Düğün Çorbası', v_grup2_id, 1, 195,
            '["corba", "beyaz_et"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 160.0}, {"ad": "TUZ", "miktar_gram": 0.5}, {"ad": "SU", "miktar_gram": 180.0}, {"ad": "ŞEHRİYE", "miktar_gram": 7.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 2.34}, {"ad": "NOHUT", "miktar_gram": 15.0}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 3.4}, {"ad": "YOĞURT (TAM)", "miktar_gram": 2.0}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 0.5}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 5.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 0.2}, {"ad": "MAYDANOZ", "miktar_gram": 2.0}, {"ad": "KARABİBER", "miktar_gram": 0.5}, {"ad": "LİMON SUYU", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Balıkesir Düğün Çorbası', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gece önceden ıslatın (en az 8 saat).
2. Tavuk göğsünü yıkayıp süzün.

**Isıl İşlem**
1. Nohut haşlama (~1 saat): Islatılmış nohudu kısık ateşte haşlayın.
2. Tavuk haşlama (~45 dk): Tavuğu tuzlu suda orta ateşte haşlayın; çıkarıp 30 dakika soğutun ve elle 3-5 cm parçalara ayırın. Haşlama suyu kısık ateşte kaynamaya devam eder.
3. Şehriye (~15 dk): Arpa şehriyeyi ayçiçek yağında pembeleşinceye kadar (koyulaştırmadan) kavurun, su ekleyip 10 dakika karıştırarak kaynatın.
4. Soğuk meyane: Soğuk su, yumurta sarısı, yoğurt ve nişastayı homojen olana kadar çırpın.
5. Sıcak terbiye (~25 dk): Tereyağı ve ayçiçek yağını kızdırın, unu yavaş yavaş ekleyip kısık ateşte sürekli çırpın; buğday rengini alıp kum tanesi gibi akışkan olunca ocaktan alın. Soğuk meyaneyi dökün, 2 dakika çırpın.
6. Birleştirme: Terbiyeyi kaynayan tavuk suyuna ekleyip çırpın; kaynayınca ocağı kapatın. İnce süzgeçten süzün; nohut, şehriye ve tavuğu ekleyin.
7. Sos: Tereyağını eritip ocağı kapatın, 5 dakika bekletip tatlı toz kırmızı biberi ekleyin.

**Servis:** 150-200 ml''lik kâselere alın; maydanoz-karabiber karışımı ve biberli tereyağı ile sıcak servis edin. Limon suyu servis sırasında eklenir.

**PARALEL YAPILABİLİRLİK:** Nohut ve tavuk aynı anda haşlanabilir; tavuk soğurken şehriye ve meyane hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~78 dk · Pasif bekleme ~117 dk · Toplam ~195 dk (nohut ıslatma hariç)

**Kaynak:** Balıkesir Düğün Çorbası, Türk Patent Coğrafi İşaret Tescil No 1562 (100 kişilik).',
            '[{"sira": 1, "ad": "Nohut Haşlama", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT"], "yeni_su_gram": null}, {"sira": 2, "ad": "Tavuk Haşlama", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "TUZ", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğutma ve Didikleme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şehriye", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ŞEHRİYE", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Meyane ve Terbiye", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BIRAKIN YUMURTA SARISI", "YOĞURT (TAM)", "BUĞDAY NİŞASTASI", "TEREYAĞI", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 6, "ad": "Birleştirme ve Sos", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bayburt Usulü Etli Kavurma -> Bayburt Ekşi Lahana (CI 648)
    select id into v_id from receteler where isletme_id is null and ad = 'Bayburt Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bayburt Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bayburt Ekşi Lahana') then
        raise notice 'Yeni ad zaten var, atlandi: Bayburt Ekşi Lahana';
    elsif _kopya_kullanimda_mi(v_id, 'Bayburt Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bayburt Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bayburt Ekşi Lahana', v_grup1_id, 1, 83,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "KONSERVE TURŞU", "miktar_gram": 125.0}, {"ad": "SIĞIR KABURGA", "miktar_gram": 75.0}, {"ad": "BULGUR", "miktar_gram": 25.0}, {"ad": "KURU SOĞAN", "miktar_gram": 37.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 7.5}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 12.5}, {"ad": "SU", "miktar_gram": 200.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bayburt Ekşi Lahana', null, '**Hazırlık / Mise en Place**
1. Kışlık lahanadan kurulmuş lahana (kelem) turşusunu küçük doğrayın. Soğanı küp doğrayın.

**Isıl İşlem**
1. Kavurma (~8 dk): Tencereye sırasıyla tereyağı, kuyruk yağı ve soğanı koyup soğan pembeleşinceye kadar kavurun. Salçayı ekleyip 1 dakika daha kavurun.
2. Pişirme (~65 dk): Lahana turşusunu, ardından tuzlanıp taş fırında kurutulmuş kemikli kaburga etini ekleyin; bir iki kez çevirip bulguru katın. Lahanaların üzerini geçecek kadar kaynar su ekleyin. Bir taşım kaynadıktan sonra kısık ateşte ara ara karıştırarak 1 saat pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~26 dk · Pasif bekleme ~57 dk · Toplam ~83 dk (1-2 aylık turşu kurma hariç)

**Kaynak:** Bayburt Ekşi Lahana, Türk Patent Coğrafi İşaret Tescil No 648 (yaklaşık 4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KUYRUKYAĞI", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 65, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KONSERVE TURŞU", "SIĞIR KABURGA", "BULGUR", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bayburt Usulü Zeytinyağlı Nohutlu Havuç -> Bayburt Yalancı Dolma (CI 844)
    select id into v_id from receteler where isletme_id is null and ad = 'Bayburt Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bayburt Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bayburt Yalancı Dolma') then
        raise notice 'Yeni ad zaten var, atlandi: Bayburt Yalancı Dolma';
    elsif _kopya_kullanimda_mi(v_id, 'Bayburt Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bayburt Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bayburt Yalancı Dolma', v_grup2_id, 1, 123,
            '["dolma"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "LAHANA", "miktar_gram": 112.5}, {"ad": "BULGUR", "miktar_gram": 63.75}, {"ad": "SIĞIR KABURGA", "miktar_gram": 62.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 9.38}, {"ad": "TEREYAĞI", "miktar_gram": 31.25}, {"ad": "BUĞDAY UNU", "miktar_gram": 13.75}, {"ad": "KURU SOĞAN", "miktar_gram": 41.25}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.0}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "SU", "miktar_gram": 50.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bayburt Yalancı Dolma', null, '**Hazırlık / Mise en Place**
1. Bulguru haşlayın. Bir soğanı ince kıyıp tereyağında kavurun; haşlanmış bulguru ve unu ekleyip karıştırın (dolma içi).
2. Kışlık lahananın yapraklarını ayırıp tuzlu suda 2-3 dakika haşlayın, hemen soğuk suya alın. Damarlarını çıkarıp ~10 cm genişliğinde dilimleyin.
3. Dolma içini lahana dilimlerine koyup sarın.

**Isıl İşlem**
1. Bulgur haşlama (~15 dk) ve iç harcın kavrulması.
2. Lahana haşlama (2-3 dk).
3. Pişirme (~60 dk): Başka bir tencerede rendelenmiş 2 soğanı tereyağı ve salçayla kavurun. Kurutulmuş kemikli kaburga etini tencerenin en altına dizin, üzerine salçalı harçtan ekleyin; bir sıra dolma, bir sıra harç olacak şekilde dizin. Yaklaşık 2 su bardağı su ekleyip kısık ateşte 1 saat pişirin.

**Servis:** Üzerine kızdırılmış tereyağı dökerek sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~57 dk · Pasif bekleme ~66 dk · Toplam ~123 dk

**Kaynak:** Bayburt Yalancı Dolma, Türk Patent Coğrafi İşaret Tescil No 844 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Bulgur ve İç Harç", "sure_dakika": 20, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Lahana Haşlama", "sure_dakika": 8, "aktif_dakika": 4, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LAHANA"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sarma", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 60, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KABURGA", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "TEREYAĞI", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bayburt Usulü Kavurmalı Yumurta -> Bayburt Lor Dolması (CI 292)
    select id into v_id from receteler where isletme_id is null and ad = 'Bayburt Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bayburt Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bayburt Lor Dolması') then
        raise notice 'Yeni ad zaten var, atlandi: Bayburt Lor Dolması';
    elsif _kopya_kullanimda_mi(v_id, 'Bayburt Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bayburt Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bayburt Lor Dolması', v_grup1_id, 1, 80,
            '["vejetaryen", "dolma"]'::jsonb, 'ilkbahar', 'Karadeniz',
            '[{"ad": "LABADA", "miktar_gram": 125.0}, {"ad": "BULGUR", "miktar_gram": 25.0}, {"ad": "LOR PEYNİRİ", "miktar_gram": 125.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "KAYMAK", "miktar_gram": 25.0}, {"ad": "TEREYAĞI", "miktar_gram": 6.25}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "SU", "miktar_gram": 62.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bayburt Lor Dolması', null, '**Hazırlık / Mise en Place**
1. Evelik (labada) yapraklarını yıkayıp ayıklayın; yumuşaması için kaynar suda bir taşım haşlayın.

**Isıl İşlem**
1. Bulgur (~15 dk): 10 g tereyağıyla soğanları kavurun; bulgur ve tuzu ekleyin, 350 ml su ekleyip suyunu çekinceye kadar kısık ateşte haşlayın.
2. Harç ve sarma: Loru bir kaba alın, süt kaymağı ve haşlanmış bulgurla harmanlayın. Karışımı sıkarak yaprağa sarın.
3. Fırınlama (180°C, ~30 dk): Yağlanmış tepsiye düzgünce dizin, üzerine 150 ml su ekleyip pişirin.

**Servis:** Kalan tereyağını eritip üzerine dökerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~40 dk · Toplam ~80 dk

**Kaynak:** Bayburt Lor Dolması, Türk Patent Coğrafi İşaret Tescil No 292 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Yaprak Haşlama", "sure_dakika": 5, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LABADA"], "yeni_su_gram": null}, {"sira": 2, "ad": "Bulgur Pişirme", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "KURU SOĞAN"], "yeni_su_gram": null}, {"sira": 3, "ad": "Harç ve Sarma", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "elektrik", "malzemeler": ["LABADA", "LOR PEYNİRİ", "KAYMAK", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bayburt Usulü Zeytinyağlı Nohut -> Bayburt Kara Pancar Yemeği (CI 678)
    select id into v_id from receteler where isletme_id is null and ad = 'Bayburt Usulü Zeytinyağlı Nohut';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bayburt Usulü Zeytinyağlı Nohut';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bayburt Kara Pancar Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Bayburt Kara Pancar Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Bayburt Usulü Zeytinyağlı Nohut') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bayburt Usulü Zeytinyağlı Nohut';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bayburt Kara Pancar Yemeği', v_grup2_id, 1, 70,
            '["kuru_baklagil"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "LABADA", "miktar_gram": 41.67}, {"ad": "SIĞIR KABURGA", "miktar_gram": 83.33}, {"ad": "KURU SOĞAN", "miktar_gram": 36.67}, {"ad": "BULGUR", "miktar_gram": 14.0}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 31.67}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 7.5}, {"ad": "SU", "miktar_gram": 133.33}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bayburt Kara Pancar Yemeği', null, '**Hazırlık / Mise en Place**
1. Kuru evelikleri haşlayıp süzün ve küçük küçük doğrayın.

**Isıl İşlem**
1. Haşlama (~15 dk): Kuru evelikleri haşlayın.
2. Kavurma (~5 dk): Tencereye soğan, salça ve yağı koyup kavurun; evelikleri ekleyin.
3. Pişirme (~45 dk): 4 su bardağı kaynar su ekleyin. Kurutulmuş kemikli et, bulgur, yeşil mercimek, pul biber ve en son tuzu katıp pişmeye bırakın.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~52 dk · Toplam ~70 dk

**Kaynak:** Bayburt Kara Pancar Yemeği, Türk Patent Coğrafi İşaret Tescil No 678 (yaklaşık 6 kişilik).',
            '[{"sira": 1, "ad": "Evelik Haşlama ve Doğrama", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LABADA"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KABURGA", "BULGUR", "YEŞİL MERCİMEK", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bitlis Usulü Zeytinyağlı Nohutlu Havuç -> Bitlis Katıklı Dolma (CI 1614)
    select id into v_id from receteler where isletme_id is null and ad = 'Bitlis Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bitlis Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bitlis Katıklı Dolma') then
        raise notice 'Yeni ad zaten var, atlandi: Bitlis Katıklı Dolma';
    elsif _kopya_kullanimda_mi(v_id, 'Bitlis Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bitlis Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bitlis Katıklı Dolma', v_grup2_id, 1, 85,
            '["dolma"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "KABAK", "miktar_gram": 150.0}, {"ad": "KUZU KIYMA", "miktar_gram": 50.0}, {"ad": "İNCE BULGUR", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 22.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 5.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 6.0}, {"ad": "KARABİBER", "miktar_gram": 0.45}, {"ad": "PUL BİBER", "miktar_gram": 0.85}, {"ad": "KİMYON", "miktar_gram": 0.45}, {"ad": "TUZ", "miktar_gram": 0.75}, {"ad": "SU", "miktar_gram": 100.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 50.0}, {"ad": "SARIMSAK", "miktar_gram": 1.25}, {"ad": "TEREYAĞI", "miktar_gram": 5.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bitlis Katıklı Dolma', null, '**Hazırlık / Mise en Place**
1. Kış kabağını ortadan ikiye bölüp içini temizleyin, 2-3 mm kalınlığında şeritler halinde kesin. Tuzlayıp bir gün dinlendirin.
2. Orta yağlı kuzu etini, soğanı ve yeşil biberi makineden iki kez çekin. Köftelik bulgur, yumurta, reyhan, kimyon, karabiber, pul biber ve tuzu ekleyip harç ele yapışmayana kadar yoğurun.
3. Başparmak kalınlığında harç alın, avuçta sıkıp şekil verin ve kabak şeritlerine sarın. Elle sıkıp tencereye dik dizin.

**Isıl İşlem**
1. Pişirme (kısık ateş, 30 dk): Dolmaların üzerine çıkacak kadar sıcak su ekleyip pişirin, suyunu süzün.
2. Sos (~3 dk): Tereyağını pul biberle kızdırın.

**Servis:** Üzerine sarımsaklı yoğurt ve pul biberli tereyağı dökerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~58 dk · Pasif bekleme ~27 dk · Toplam ~85 dk (kabak şeritlerini 1 gün dinlendirme hariç)

**Kaynak:** Bitlis Katıklı Dolma, Türk Patent Coğrafi İşaret Tescil No 1614 (10 kişilik).',
            '[{"sira": 1, "ad": "Harç ve Sarma", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KUZU KIYMA", "İNCE BULGUR", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "YOĞURT (TAM)", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bitlis Usulü Zeytinyağlı Semizotu -> Bitlis Ciğer Taplaması (CI 1652)
    select id into v_id from receteler where isletme_id is null and ad = 'Bitlis Usulü Zeytinyağlı Semizotu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bitlis Usulü Zeytinyağlı Semizotu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bitlis Ciğer Taplaması') then
        raise notice 'Yeni ad zaten var, atlandi: Bitlis Ciğer Taplaması';
    elsif _kopya_kullanimda_mi(v_id, 'Bitlis Usulü Zeytinyağlı Semizotu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bitlis Usulü Zeytinyağlı Semizotu';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bitlis Ciğer Taplaması', v_grup1_id, 1, 68,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "YENİLEBİLİR SAKATAT (DANA KARACİĞER)", "miktar_gram": 62.5}, {"ad": "İNCE BULGUR", "miktar_gram": 31.25}, {"ad": "KURU SOĞAN", "miktar_gram": 13.75}, {"ad": "İRMİK", "miktar_gram": 18.75}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 6.25}, {"ad": "YEŞİL BİBER", "miktar_gram": 5.6}, {"ad": "BUĞDAY UNU", "miktar_gram": 1.25}, {"ad": "KARABİBER", "miktar_gram": 0.5}, {"ad": "KİMYON", "miktar_gram": 0.25}, {"ad": "PUL BİBER", "miktar_gram": 1.4}, {"ad": "TUZ", "miktar_gram": 1.9}, {"ad": "TEREYAĞI", "miktar_gram": 3.75}, {"ad": "SU", "miktar_gram": 31.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bitlis Ciğer Taplaması', null, '**Hazırlık / Mise en Place**
1. Kuzu/koyun karaciğerini, soğanı ve sivri biberi kıyma makinesinden çekin.
2. Karışıma bulgur, irmik, yumurta, baharatlar ve unu ekleyip yoğurun; eli 250 ml su ile ıslatarak harcın kurumasını önleyin. Harç ele yapışmayana kadar 10-15 dakika yoğurun.
3. Harçtan 5 g''lık parçalar koparın, yuvarlayıp bastırarak yassılaştırın.

**Isıl İşlem**
1. Haşlama (20-25 dk): 2,5 litre suyu tuzla kaynatın, taplamaları atıp haşlayın; suyunu süzün.
2. Sos (~3 dk): Tereyağını eritip pul biber ve tuz ekleyin.

**Servis:** Sunum tabaklarına alıp sosu dökün, sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~46 dk · Pasif bekleme ~22 dk · Toplam ~68 dk

**Kaynak:** Bitlis Ciğer Taplaması, Türk Patent Coğrafi İşaret Tescil No 1652 (8 kişilik).',
            '[{"sira": 1, "ad": "Harç ve Şekillendirme", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 25, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YENİLEBİLİR SAKATAT (DANA KARACİĞER)", "İNCE BULGUR", "İRMİK", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Burdur Usulü Zeytinyağlı Nohutlu Havuç -> Burdur Şiş Köftesi (CI 155)
    select id into v_id from receteler where isletme_id is null and ad = 'Burdur Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Burdur Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Burdur Şiş Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Burdur Şiş Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Burdur Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Burdur Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Burdur Şiş Köftesi', v_grup1_id, 1, 82,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "SIĞIR KIYMA", "miktar_gram": 120.0}, {"ad": "TUZ", "miktar_gram": 3.0}, {"ad": "PİDE", "miktar_gram": 110.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Burdur Şiş Köftesi', null, '**Hazırlık / Mise en Place**
1. %20-25 yağlı keçi veya sığır kaburga etini sinir, damar ve zarlarından ayıklayıp kıyma makinesinden tek çekin. İlave yağ kullanılmaz.
2. Kilogram ete en fazla 25 g tuz ekleyip homojen olana kadar elle yoğurun; +4°C''de 30-60 dakika dinlendirin.
3. Eli suya batırıp hafifçe ıslatın. 20 g''lık kıymayı şiş demirine 12-14 cm boyunda, 2 cm eninde dengeli sıvayın. Sıvanmış şişler +4°C''de 10 dakikadan fazla bekletilmez.

**Isıl İşlem**
1. Izgara (odun kömürü, alevsiz kor): Porsiyon başına 6 şişi ocağa koyun, sık sık çevirin. Etin yüzünde oluşan yağı pidelere sıkarak alın, yağın ateşe damlamasını önleyin. Yağlanan pideleri pişen köftenin üzerinde tutarak sıcak tutun. Vantilatör kullanılmaz; ateş küçük yelpazeyle güçlendirilir.

**Servis:** 6 pişmiş şiş köfteyi (100 g) yağlı pide üzerinde servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~37 dk · Pasif bekleme ~45 dk · Toplam ~82 dk

**Kaynak:** Burdur Şiş Köftesi, Türk Patent Coğrafi İşaret Tescil No 155 (porsiyon 120 g çiğ kıyma, 6 şiş).',
            '[{"sira": 1, "ad": "Kıyma Hazırlığı", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Dinlendirme", "sure_dakika": 45, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Şişe Sıvama", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KIYMA", "PİDE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bursa Usulü Etli Kavurma (Kimyonlu) -> İnegöl Büryanı (CI 1606)
    select id into v_id from receteler where isletme_id is null and ad = 'Bursa Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bursa Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'İnegöl Büryanı') then
        raise notice 'Yeni ad zaten var, atlandi: İnegöl Büryanı';
    elsif _kopya_kullanimda_mi(v_id, 'Bursa Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bursa Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'İnegöl Büryanı', v_grup1_id, 1, 105,
            '["beyaz_et", "pilav"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "TAVUK BUT", "miktar_gram": 150.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 72.0}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "DOMATES", "miktar_gram": 40.0}, {"ad": "TUZ", "miktar_gram": 1.7}, {"ad": "KARABİBER", "miktar_gram": 0.55}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}, {"ad": "SU", "miktar_gram": 200.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'İnegöl Büryanı', null, '**Hazırlık / Mise en Place**
1. Tavuk butlarını yıkayın. Soğanları küp küp doğrayın, domateslerin kabuğunu soyup rendeleyin. Pirinci yıkayın.

**Isıl İşlem**
1. Haşlama (40 dk): Tavuk butlarını düdüklü tencerede 1 litre suyla haşlayın.
2. Sos (~10 dk): 30 g tereyağında soğanları kavurun, domatesi ve karabiberi ekleyip kavurmaya devam edin.
3. Pilav (180°C fırın, 10 dk): Pirinci 70 g tereyağında kavurun, 1 litre su ekleyip suyu süzülmeden tepsiye yayın; fırında suyunu çekmeye bırakın. Su tamamen çekilirse sıcak haşlama suyundan 150 ml ekleyin.
4. Fırınlama (200°C, ~20 dk): Pilavın üzerine kavrulan soğan-domatesi, onun üzerine tavuk butlarını dizip pişirin.
5. Demleme (10 dk): Tepsiyi başka bir tepsiyle kapatıp demlendirin.

**Servis:** Sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk haşlanırken soğan-domates sosu ve pilav hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~75 dk · Toplam ~105 dk

**Kaynak:** İnegöl Büryanı, Türk Patent Coğrafi İşaret Tescil No 1606 (10 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Tavuk Haşlama", "sure_dakika": 40, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğan-Domates Sosu", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "DOMATES", "KARABİBER", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pilav Fırınlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["PİRİNÇ (HAM)", "TUZ"], "yeni_su_gram": null}, {"sira": 5, "ad": "Fırınlama", "sure_dakika": 20, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": [], "yeni_su_gram": null}, {"sira": 6, "ad": "Demleme", "sure_dakika": 10, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bursa Usulü Etli Nohutlu Kavurma -> Bursa Pideli Köfte (CI 930)
    select id into v_id from receteler where isletme_id is null and ad = 'Bursa Usulü Etli Nohutlu Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bursa Usulü Etli Nohutlu Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bursa Pideli Köfte') then
        raise notice 'Yeni ad zaten var, atlandi: Bursa Pideli Köfte';
    elsif _kopya_kullanimda_mi(v_id, 'Bursa Usulü Etli Nohutlu Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bursa Usulü Etli Nohutlu Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bursa Pideli Köfte', v_grup1_id, 1, 65,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "DANA KIYMA", "miktar_gram": 150.0}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 16.5}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "KARABİBER", "miktar_gram": 1.5}, {"ad": "KİMYON", "miktar_gram": 1.5}, {"ad": "PİDE", "miktar_gram": 110.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 15.0}, {"ad": "SU", "miktar_gram": 60.0}, {"ad": "TEREYAĞI", "miktar_gram": 15.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 80.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bursa Pideli Köfte', null, '**Hazırlık / Mise en Place**
1. Kıyma için %80-90 kaburga, kalanı but ve kol karışımı dana eti kullanın; soğan kullanılmaz. Eti iki kez çekin; ikinci çekimde kilogram ete 100-120 g bayat ekmek içi, 10 g tuz, 10 g karabiber ve 10 g kimyon katın.
2. Köfte hamurunu 10-15 dakika yoğurun, bir gece +4°C''de dinlendirin. 10-12 g''lık parçalar halinde yuvarlayıp pişirmeye kadar buzdolabında tutun.

**Isıl İşlem**
1. Sos: Oda sıcaklığındaki su ve domates salçasını karıştırıp kısık ateşte bekletin; kıvamını koruyun.
2. Pide tavlama (en az 5 dk): Pideyi kömür ateşinde elle bastırarak tavlatın.
3. Izgara: Köfteleri mangal ateşinde pişirin; sos ve tereyağı aynı anda hazır olmalıdır.
4. Tereyağı: Tereyağını kızdırın.

**Servis:** Yarım pideyi küp ya da dikdörtgen dilimleyip tabağa koyun. Sıcak salçalı sosu dökün, fazlasını süzün; 15-20 saniye içinde kızdırılmış tereyağını gezdirin. Köfteleri üçgen ya da dağınık dizin; yanında yoğurt, közlenmiş biber, kuru soğan ve domatesle sunun.

**PARALEL YAPILABİLİRLİK:** Sos, pide tavlama ve ızgara eş zamanlı yürütülür (belge en az iki usta önerir).

**SÜRE ÖZETİ:** Aktif işçilik ~58 dk · Pasif bekleme ~7 dk · Toplam ~65 dk (bir gece köfte hamuru dinlendirme hariç)

**Kaynak:** Bursa Pideli Köfte, Türk Patent Coğrafi İşaret Tescil No 930 (porsiyon TAHMİN).',
            '[{"sira": 1, "ad": "Köfte Hamuru", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şekillendirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KONSERVE DOMATES SALÇASI", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pide Tavlama", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİDE"], "yeni_su_gram": null}, {"sira": 5, "ad": "Izgara", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "EKMEK (BEYAZ)"], "yeni_su_gram": null}, {"sira": 6, "ad": "Tereyağı ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "YOĞURT (TAM)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bursa Usulü Zeytinyağlı Kereviz -> Bursa Dede Çorbası (CI 1888)
    select id into v_id from receteler where isletme_id is null and ad = 'Bursa Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bursa Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bursa Dede Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Bursa Dede Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Bursa Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bursa Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bursa Dede Çorbası', v_grup2_id, 1, 247,
            '["corba", "beyaz_et"]'::jsonb, 'kis', 'Marmara',
            '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 50.0}, {"ad": "TAVUK SUYU", "miktar_gram": 250.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 51.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 12.0}, {"ad": "NOHUT", "miktar_gram": 47.5}, {"ad": "TEREYAĞI", "miktar_gram": 6.25}, {"ad": "KURU NANE", "miktar_gram": 1.0}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "SU", "miktar_gram": 12.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bursa Dede Çorbası', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gün önceden en az 8 saat ıslatın.
2. Kesme hamur: Böreklik unu kaba alın, ortasını açıp yumurta ve 3 g tuz ekleyin; azar azar 50 ml su ekleyerek sert bir hamur yoğurun, 10-15 dakika dinlendirin. 1-2 mm inceliğinde açıp şeritler, ardından uzun kenarı 1 cm olan küçük dikdörtgenler halinde kesin. Bez üzerinde 1-2 saat kurutun.

**Isıl İşlem**
1. Nohut haşlama (45-60 dk): Süzülmüş nohudu üzerini 2-3 parmak geçen suda haşlayın, pişmeye yakın tuzlayın.
2. Tavuk haşlama (30-40 dk): Tavuğu üzerini geçen suda haşlayın; çıkarıp soğutun ve ince lifler halinde didikleyin. Suyunu çorbada kullanın.
3. Çorba (~25 dk): 1 litre tavuk suyunu kaynatın; kesme hamur, tavuk ve nohudu ekleyip 10 dakika kaynatın, 10-15 dakika kısık ateşte pişirin.
4. Naneli tereyağı: Tereyağını eritip kuru naneyi 25-30 saniye kavurun, çorbanın üzerine dökün.

**Servis:** Sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur kururken nohut ve tavuk haşlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~55 dk · Pasif bekleme ~192 dk · Toplam ~247 dk (nohut ıslatma hariç)

**Kaynak:** Bursa Dede Çorbası, Türk Patent Coğrafi İşaret Tescil No 1888 (4 kişilik).',
            '[{"sira": 1, "ad": "Kesme Hamur", "sure_dakika": 40, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kurutma", "sure_dakika": 90, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Nohut Haşlama", "sure_dakika": 55, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT"], "yeni_su_gram": null}, {"sira": 4, "ad": "Tavuk Haşlama", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS"], "yeni_su_gram": null}, {"sira": 5, "ad": "Çorba Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK SUYU", "BUĞDAY UNU", "TAVUK YUMURTASI", "SU"], "yeni_su_gram": null}, {"sira": 6, "ad": "Naneli Tereyağı", "sure_dakika": 2, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Datça Usulü Izgara Karides -> Bodrum Çökertme Kebabı (CI 1759)
    select id into v_id from receteler where isletme_id is null and ad = 'Datça Usulü Izgara Karides';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Datça Usulü Izgara Karides';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bodrum Çökertme Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Bodrum Çökertme Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Datça Usulü Izgara Karides') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Datça Usulü Izgara Karides';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bodrum Çökertme Kebabı', v_grup1_id, 1, 48,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "DANA BUT", "miktar_gram": 220.0}, {"ad": "PATATES", "miktar_gram": 150.0}, {"ad": "SÜZME YOĞURT", "miktar_gram": 200.0}, {"ad": "SARIMSAK", "miktar_gram": 5.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 30.0}, {"ad": "TEREYAĞI", "miktar_gram": 70.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 4.0}, {"ad": "KARABİBER", "miktar_gram": 2.0}, {"ad": "KİMYON", "miktar_gram": 3.0}, {"ad": "TAZE NANE", "miktar_gram": 15.0}, {"ad": "KEKİK", "miktar_gram": 15.0}, {"ad": "TUZ", "miktar_gram": 6.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15.0}, {"ad": "DOMATES", "miktar_gram": 100.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 30.0}, {"ad": "ROKA", "miktar_gram": 10.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bodrum Çökertme Kebabı', null, '**Hazırlık / Mise en Place**
1. Patatesleri kibrit çöpü inceliğinde doğrayın (ya da kalın rendeyle tek yöne rendeleyin); tuzlu suda nişastası çıkana kadar 10-15 dakika bekletin, süzüp kurulayın.
2. Süzme yoğurdu dövülmüş sarımsakla pürüzsüz ve akışkan olana kadar çırpın; koyu kalırsa biraz su ekleyin.
3. Dananın but kısmından tranç/sokum eti bifteklik doğrayıp dövererek inceltin.

**Isıl İşlem**
1. Kızartma: Patatesleri kızgın yağda derin ve şok kızartmayla kızartıp servis tabağına alın.
2. Mühürleme: Döküm tavayı 200-250°C''de 2 dakika ısıtın; et dilimlerini iki yüzünü yarım dakika mühürleyip alın, 9-10 cm''lik ince şeritler doğrayın.
3. Sote (~4 dk): Tavada kalan suya tereyağı ve zeytinyağını ekleyin; köpürünce etleri alıp sürekli çevirerek ~2 dakika pişirin. Tuz, karabiber, kimyon ve toz kırmızı biberi ekleyin; ocaktan almadan hemen önce nane ve kekiği katın.

**Servis:** Patateslerin üzerine sarımsaklı yoğurdu (patatesleri tamamen kapatmadan) koyun, üzerine etleri yağıyla birlikte alın. İnce domates ve biber dilimleri ile roka yapraklarıyla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~38 dk · Pasif bekleme ~10 dk · Toplam ~48 dk

**Kaynak:** Bodrum Çökertme Kebabı, Türk Patent Coğrafi İşaret Tescil No 1759 (1 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 25, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Patates Kızartma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 170, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATATES", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Mühürleme ve Doğrama", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 60, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BUT"], "yeni_su_gram": null}, {"sira": 4, "ad": "Sote", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 70, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "ZEYTİNYAĞI", "TATLIKA KIRMIZI BİBER", "KARABİBER", "KİMYON", "TAZE NANE", "KEKİK"], "yeni_su_gram": null}, {"sira": 5, "ad": "Servis Düzeni", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Fethiye Usulü Izgara Karides -> Muğla Sulu Kebabı (CI 1483)
    select id into v_id from receteler where isletme_id is null and ad = 'Fethiye Usulü Izgara Karides';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Fethiye Usulü Izgara Karides';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Muğla Sulu Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Muğla Sulu Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Fethiye Usulü Izgara Karides') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Fethiye Usulü Izgara Karides';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Muğla Sulu Kebabı', v_grup1_id, 1, 550,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "KEÇİ ETİ (BUT)", "miktar_gram": 166.67}, {"ad": "SU", "miktar_gram": 333.33}, {"ad": "DONYAĞI", "miktar_gram": 16.67}, {"ad": "TUZ", "miktar_gram": 1.33}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Muğla Sulu Kebabı', null, '**Hazırlık / Mise en Place**
1. Derin bir kabın tabanına kırılmış dana kemiklerini ve iç yağının yaklaşık yarısını, üzerine parçalara ayrılmış kemikli oğlak etini, en üste iç yağının kalanını dizin.

**Isıl İşlem**
1. Kızartma (fırın/ocak, ~1 saat): Etler iyice kızarana kadar pişirin.
2. Dinlendirme (~1 saat): Fırından çıkan eti dinlendirip soğumaya bırakın; sıcak ete hemen su katılmaz.
3. Pişirme (fırın, ~7 saat): Etleri tepsi, toprak tava ya da güveç kabına alın; tuz ve su ekleyip etler iyice yumuşayana kadar pişirin. İri yağları kevgirle toplayın; kemik iliklerini yemeğe aktarın. Etleri alıp suyu isteğe göre süzün, etleri suya geri koyun.

**Servis:** Sıcak olarak; isteğe göre karabiber, limon, pide ve kuru ya da taze biberle servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~520 dk · Toplam ~550 dk

**Kaynak:** Muğla Sulu Kebabı, Türk Patent Coğrafi İşaret Tescil No 1483 (30 kişilik).',
            '[{"sira": 1, "ad": "Dizme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KEÇİ ETİ (BUT)", "DONYAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Dinlendirme", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırında Pişirme", "sure_dakika": 420, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["KEÇİ ETİ (BUT)", "SU", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Muğla Usulü Zeytinyağlı Nohutlu Havuç -> Milas Vekilharcı (CI 1280)
    select id into v_id from receteler where isletme_id is null and ad = 'Muğla Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Muğla Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Milas Vekilharcı') then
        raise notice 'Yeni ad zaten var, atlandi: Milas Vekilharcı';
    elsif _kopya_kullanimda_mi(v_id, 'Muğla Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Muğla Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Milas Vekilharcı', v_grup2_id, 1, 170,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 100.0}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 22.75}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 5.0}, {"ad": "DANA KIYMA", "miktar_gram": 100.0}, {"ad": "MAYDANOZ", "miktar_gram": 10.0}, {"ad": "PUL BİBER", "miktar_gram": 1.0}, {"ad": "KARABİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "TAVUK SUYU", "miktar_gram": 80.0}, {"ad": "SÜZME YOĞURT", "miktar_gram": 100.0}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Milas Vekilharcı', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, su, zeytinyağı (150 ml) ve yumurtayı yoğurun; üzerini bezle örtüp 1 saat dinlendirin. 70 g''lık bezeler kesip oklavayla 60 cm çapında, 1 mm kalınlığında yufka açın.
2. İç harç: Orta yağlı kıymayı zeytinyağıyla (100 ml) kavururken tuz ve baharatları ekleyin; iyice kavrulunca ince kıyılmış maydanozu (yarısı) katıp yumuşayana kadar kavurun ve soğutun.
3. Yufkaları ortadan ikiye kesin; uzun kenara ~2 cm genişliğinde harç koyup sarın. Yağlanmış tepsiye merkezden dışa doğru daire şeklinde dizin; 2 cm''lik kareler halinde kesin.

**Isıl İşlem**
1. Fırınlama (180°C, ~30 dk): Rengi kızarınca çıkarıp soğutun.
2. Tereyağı: Tereyağını toz kırmızı biberle kızdırın.

**Servis:** Tabağa tek kat dizin; porsiyon başına 80 ml sıcak tavuk veya et suyu döküp çekmesini bekleyin. Üzerini tamamen kapatacak şekilde sarımsaklı, tuzlu süzme yoğurt dökün; biberli tereyağını gezdirin, karabiber ve iri kıyılmış maydanozla servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç hazırlanıp soğutulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~87 dk · Pasif bekleme ~83 dk · Toplam ~170 dk

**Kaynak:** Milas Vekilharcı, Türk Patent Coğrafi İşaret Tescil No 1280 (10 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 70, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "MAYDANOZ", "PUL BİBER", "KARABİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Yufka Açma ve Sarma", "sure_dakika": 45, "aktif_dakika": 45, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "SU", "ZEYTİNYAĞI", "TAVUK YUMURTASI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Servis Düzeni", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK SUYU", "SÜZME YOĞURT", "SARIMSAK", "TEREYAĞI", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kilis Usulü Zeytinyağlı Nohutlu Kereviz -> Kilis Şıhılmahşe (CI 1229)
    select id into v_id from receteler where isletme_id is null and ad = 'Kilis Usulü Zeytinyağlı Nohutlu Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kilis Usulü Zeytinyağlı Nohutlu Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kilis Şıhılmahşe') then
        raise notice 'Yeni ad zaten var, atlandi: Kilis Şıhılmahşe';
    elsif _kopya_kullanimda_mi(v_id, 'Kilis Usulü Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kilis Usulü Zeytinyağlı Nohutlu Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kilis Şıhılmahşe', v_grup2_id, 1, 113,
            '["dolma"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "ACUR", "miktar_gram": 100.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 22.75}, {"ad": "KOYUN KIYMA", "miktar_gram": 60.0}, {"ad": "KURU SOĞAN", "miktar_gram": 22.0}, {"ad": "NOHUT", "miktar_gram": 10.0}, {"ad": "DOMATES", "miktar_gram": 22.0}, {"ad": "MAYDANOZ", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "KARABİBER", "miktar_gram": 1.0}, {"ad": "KURU NANE", "miktar_gram": 1.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 1.6}, {"ad": "SÜZME YOĞURT", "miktar_gram": 36.0}, {"ad": "SARIMSAK", "miktar_gram": 2.0}, {"ad": "SU", "miktar_gram": 30.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kilis Şıhılmahşe', null, '**Hazırlık / Mise en Place**
1. İç harç: Nohudu (veya kırık leblebiyi) 30 dakika haşlayın, nohut kullandıysanız kabuklarını çıkarın. Küp doğranmış soğanı zeytinyağında pembeleşinceye kadar kavurun, kıymayı ekleyin. Kıyma suyunu çekince rendelenmiş domates, ince kıyılmış maydanoz, nohut, salça, tuz ve karabiberi ekleyin; suyunu çekince dinlendirin.
2. Dolmalık tüylü acurların dış kabuğunu dolma oyacağının tersiyle ince kesin, yıkayın, uçlarını kesin; içlerini kabuğa zarar vermeden oyun.

**Isıl İşlem**
1. Kızartma (2-3 dk): Kurulanmış acurları kızgın zeytinyağında renk koyulaşmadan çevirerek kızartın, kağıt havluya alıp tuzlayın ve soğutun.
2. Pişirme (kısık ateş 10-15 dk ya da 180°C fırın 30 dk): Acurları harçla doldurup iki acurun ağzı birbirine bakacak şekilde yayvan tencereye yatay dizin. Salça, tuz, kuru nane ve sudan oluşan sosu üzerine dökün, kapağı kapatıp pişirin.

**Servis:** Üzerine sarımsaklı yoğurt dökün, dereotu veya maydanozla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~70 dk · Pasif bekleme ~43 dk · Toplam ~113 dk

**Kaynak:** Kilis Şıhılmahşe, Türk Patent Coğrafi İşaret Tescil No 1229 (20 adet).',
            '[{"sira": 1, "ad": "Nohut Haşlama", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN KIYMA", "KURU SOĞAN", "DOMATES", "MAYDANOZ", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Acur Oyma", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 150, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ACUR", "ZEYTİNYAĞI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Doldurma ve Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ACUR", "KURU NANE", "SU", "SÜZME YOĞURT", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kilis Usulü Zeytinyağlı Nohutlu Pırasa -> Kübbülmişviyye (CI 1277)
    select id into v_id from receteler where isletme_id is null and ad = 'Kilis Usulü Zeytinyağlı Nohutlu Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kilis Usulü Zeytinyağlı Nohutlu Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kübbülmişviyye') then
        raise notice 'Yeni ad zaten var, atlandi: Kübbülmişviyye';
    elsif _kopya_kullanimda_mi(v_id, 'Kilis Usulü Zeytinyağlı Nohutlu Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kilis Usulü Zeytinyağlı Nohutlu Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kübbülmişviyye', v_grup2_id, 1, 165,
            '["pilav_makarna_borek"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
            '[{"ad": "DANA KIYMA", "miktar_gram": 41.67}, {"ad": "İNCE BULGUR", "miktar_gram": 83.33}, {"ad": "KURU SOĞAN", "miktar_gram": 8.33}, {"ad": "KURU NANE", "miktar_gram": 1.67}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.67}, {"ad": "BUĞDAY UNU", "miktar_gram": 3.33}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "SU", "miktar_gram": 33.33}, {"ad": "DONYAĞI", "miktar_gram": 20.83}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 20.83}, {"ad": "PUL BİBER", "miktar_gram": 1.67}, {"ad": "TARÇIN", "miktar_gram": 0.83}, {"ad": "KARABİBER", "miktar_gram": 0.83}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kübbülmişviyye', null, '**Hazırlık / Mise en Place**
1. Dış harç: İnce bulgur, küçük doğranmış soğan, nane, toz kırmızı biber, tuz ve suyu ıslak elle iyice yoğurun. Yağsız kıymayı ekleyip sakız kıvamına gelene kadar yoğurmaya devam edin. Kıyma makinesinden çekip un serpin, yoğurun ve 1 saat dinlendirin.
2. İç harç: Kuşbaşı doğranmış iç yağını küçük bir tepside sıcak suyla yoğurun; ceviz, nane, pul biber, tarçın, karabiber ve tuzu ekleyip karıştırın. Elleri çok soğuk suya batırarak iç harçtan badem içi büyüklüğünde parçalar şekillendirin.
3. Dış harçtan iri parçalar alıp içli köfte gibi (biraz daha büyük) oyun; içine bir parça iç harç koyup ağzını düz kapatın ve üçgen ya da yuvarlak şekil verin.

**Isıl İşlem**
1. Pişirme: Köftelerin iki yüzünü ızgarada veya tavada kendi yağında pembeleşinceye kadar pişirin; fazla kızartmayın. Fırında da pişirilebilir.

**Servis:** İç yağı donmasın diye sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Dış harç dinlenirken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~105 dk · Pasif bekleme ~60 dk · Toplam ~165 dk

**Kaynak:** Kübbülmişviyye, Türk Patent Coğrafi İşaret Tescil No 1277 (yaklaşık 12 kişilik).',
            '[{"sira": 1, "ad": "Dış Harç", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Dinlendirme", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şekillendirme", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Pişirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "İNCE BULGUR", "DONYAĞI", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kilis Usulü Etli Nohutlu Patlıcan -> Kilis Ekşili Kebabı (CI 1257)
    select id into v_id from receteler where isletme_id is null and ad = 'Kilis Usulü Etli Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kilis Usulü Etli Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kilis Ekşili Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Kilis Ekşili Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Kilis Usulü Etli Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kilis Usulü Etli Nohutlu Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kilis Ekşili Kebabı', v_grup1_id, 1, 86,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 125.0}, {"ad": "PİDE", "miktar_gram": 110.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 9.1}, {"ad": "KARABİBER", "miktar_gram": 2.5}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 8.0}, {"ad": "ET SUYU", "miktar_gram": 300.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 37.5}, {"ad": "KURU SOĞAN", "miktar_gram": 125.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 12.5}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 4.0}, {"ad": "DOMATES", "miktar_gram": 50.0}, {"ad": "NAR EKŞİSİ", "miktar_gram": 15.0}, {"ad": "MAYDANOZ", "miktar_gram": 18.75}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kilis Ekşili Kebabı', null, '**Hazırlık / Mise en Place**
1. Köfte: İnce çekilmiş, az yağlı koyun kıymasını karabiber, toz biber ve tuzla iyice yoğurun; küçük toplar halinde yuvarlayın.

**Isıl İşlem**
1. Köfte fırınlama (180°C, 20-25 dk): Köfteleri fırın tepsisine dizip pişirin.
2. Sos: Kuyruk yağını tencerede kavurun, kıkırdaklarını alın. Arpacık soğanları bütün halde ekleyip pembeleşinceye kadar kavurun. Domates salçası, biber salçası ve domates rendesini katın; et suyunu ekleyip kaynatın. Fırında pişen köfteleri, nar ekşisini, tuzu ve karabiberi ekleyip sos katılaşıncaya kadar pişirin.
3. Pide (180°C, 7-8 dk): Tırnaklı pideleri doğrayıp tepsiye dizin, her pide için 10 ml zeytinyağı dökerek kızartın.

**Servis:** Kızaran pideleri tabağa dizin; üzerine sırasıyla sos, köfteler ve bütün arpacık soğanları koyun, ince kıyılmış maydanoz serpin. Sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Köfteler fırındayken sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~44 dk · Pasif bekleme ~42 dk · Toplam ~86 dk

**Kaynak:** Kilis Ekşili Kebabı, Türk Patent Coğrafi İşaret Tescil No 1257 (4 tırnaklı pide, 4 porsiyon).',
            '[{"sira": 1, "ad": "Köfte Hazırlığı", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Köfte Fırınlama", "sure_dakika": 23, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "elektrik", "malzemeler": ["KOYUN KIYMA", "KARABİBER", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 30, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ET SUYU", "KUYRUKYAĞI", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "DOMATES", "NAR EKŞİSİ", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pide Kızartma", "sure_dakika": 8, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "elektrik", "malzemeler": ["PİDE", "ZEYTİNYAĞI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Servis Düzeni", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["MAYDANOZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Usulü Zeytinyağlı Nohutlu Kabak -> Konya Ekşili Kabak (CI 997)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Ekşili Kabak') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Ekşili Kabak';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Ekşili Kabak', v_grup1_id, 1, 140,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
            '[{"ad": "KABAK", "miktar_gram": 375.0}, {"ad": "KOYUN ETİ (KOL)", "miktar_gram": 187.5}, {"ad": "DOMATES", "miktar_gram": 250.0}, {"ad": "KURU SOĞAN", "miktar_gram": 75.0}, {"ad": "SARIMSAK", "miktar_gram": 7.5}, {"ad": "NOHUT", "miktar_gram": 35.0}, {"ad": "LİMON SUYU", "miktar_gram": 20.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "TAZE FESLEĞEN", "miktar_gram": 0.5}, {"ad": "TAZE NANE", "miktar_gram": 12.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Ekşili Kabak', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gece önceden ıslatın.
2. Asma kabağının kabuklarını soyup çekirdeklerini çıkarın; 1,5 cm aralıkla verev doğrayın. Domatesleri küp doğrayın.

**Isıl İşlem**
1. Pişirme (kısık ateş, 2 saat): Tencerenin tabanına ıslatılmış nohudu serin; sırasıyla kemikli koyun eti (kaburga ve ön kol), soğan ve 3 diş sarımsak koyun, kabakları dizin. Domates, kadife yaprağı, fesleğen, nane, kalan sarımsak, tuz ve koruk ekşisini ekleyin. Su eklemeden kendi suyunda pişirin.

**Servis:** Tencereyi servis tabağına ters çevirip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~115 dk · Toplam ~140 dk (nohut ıslatma hariç)

**Kaynak:** Konya Ekşili Kabak, Türk Patent Coğrafi İşaret Tescil No 997 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 120, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KOYUN ETİ (KOL)", "DOMATES", "KURU SOĞAN", "NOHUT", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Usulü Zeytinyağlı Pırasa -> Konya Kuru Kabak Sarması (CI 901)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Kuru Kabak Sarması') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Kuru Kabak Sarması';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Kuru Kabak Sarması', v_grup2_id, 1, 90,
            '["dolma"]'::jsonb, 'kis', 'İç Anadolu',
            '[{"ad": "DANA KIYMA", "miktar_gram": 62.5}, {"ad": "KABAK", "miktar_gram": 100.0}, {"ad": "KURU SOĞAN", "miktar_gram": 27.5}, {"ad": "MAYDANOZ", "miktar_gram": 12.5}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6.25}, {"ad": "İNCE BULGUR", "miktar_gram": 12.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 25.0}, {"ad": "DOMATES", "miktar_gram": 27.5}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.25}, {"ad": "KURU NANE", "miktar_gram": 1.25}, {"ad": "KİMYON", "miktar_gram": 1.25}, {"ad": "TUZ", "miktar_gram": 3.0}, {"ad": "TEREYAĞI", "miktar_gram": 3.5}, {"ad": "SU", "miktar_gram": 100.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Kuru Kabak Sarması', null, '**Hazırlık / Mise en Place**
1. İç harç: İnce kıyılmış soğan ve maydanoz, rendelenmiş domates, kıyma, domates salçası (60 g), ince bulgur, pirinç ve baharatları bir kapta karıştırın.
2. Kuru kabakları yumuşayıncaya kadar haşlayın; ortalarına iç harç koyup verevine sarın.

**Isıl İşlem**
1. Haşlama (~15 dk): Kuru kabakları yumuşatın.
2. Pişirme (~40 dk): Tencerede tereyağı kızarınca salçayı (40 g) kavurun; ocağı söndürüp bir miktar sıcak su ekleyin. Sarmaları dizin, üzerini biraz geçecek kadar su ekleyin; açılmasınlar diye üzerine porselen tabak koyun ve kabaklar yumuşayıncaya kadar pişirin.

**Servis:** Servis tabağına alıp sunun.

**SÜRE ÖZETİ:** Aktif işçilik ~43 dk · Pasif bekleme ~47 dk · Toplam ~90 dk

**Kaynak:** Konya Kuru Kabak Sarması, Türk Patent Coğrafi İşaret Tescil No 901 (4 kişilik).',
            '[{"sira": 1, "ad": "Kabak Haşlama", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç ve Sarma", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 40, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "PİRİNÇ (HAM)", "İNCE BULGUR", "TEREYAĞI", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Usulü Etli Kabak Yemeği -> Konya Patlıcan Tiridi (CI 1002)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Usulü Etli Kabak Yemeği';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Usulü Etli Kabak Yemeği';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Patlıcan Tiridi') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Patlıcan Tiridi';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Usulü Etli Kabak Yemeği') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Usulü Etli Kabak Yemeği';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Patlıcan Tiridi', v_grup1_id, 1, 75,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
            '[{"ad": "PATLICAN", "miktar_gram": 150.0}, {"ad": "DANA KIYMA", "miktar_gram": 62.5}, {"ad": "DOMATES", "miktar_gram": 27.5}, {"ad": "KURU SOĞAN", "miktar_gram": 27.5}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 75.0}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 7.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 7.5}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.5}, {"ad": "KARABİBER", "miktar_gram": 1.0}, {"ad": "SÜZME YOĞURT", "miktar_gram": 75.0}, {"ad": "SARIMSAK", "miktar_gram": 3.0}, {"ad": "MAYDANOZ", "miktar_gram": 7.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 12.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Patlıcan Tiridi', null, '**Hazırlık / Mise en Place**
1. Patlıcanları alacalı soyup küp doğrayın; acı suyu çıksın diye 15 dakika tuzlu suda bekletin.
2. Süzme yoğurdu çatalla çırpıp rendelenmiş sarımsağı ekleyin. Tandır ekmeğini küp doğrayın.

**Isıl İşlem**
1. Kıymalı sos (~35 dk): Geniş tavada zeytinyağı ve doğranmış soğanı 1-2 dakika kavurun. Salça ve küp domatesi ekleyip domatesler yumuşayana kadar kavurun. Kıyma, tuz, karabiber ve kırmızı biberi ekleyip kapağı kapalı 30 dakika pişirin.
2. Kızartma (15 dk): Patlıcanları sıvı yağda kızartın, yağını iyice süzün ve tavadaki karışıma ekleyin; 2-3 dakika karıştırıp ocağı kapatın.

**Servis:** Küp ekmeği tabağa koyun; üzerine sarımsaklı yoğurdu yayın, ardından sıcak karışımı ekleyip ince kıyılmış maydanozla servis edin.

**PARALEL YAPILABİLİRLİK:** Kıymalı sos pişerken patlıcanlar kızartılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~38 dk · Pasif bekleme ~37 dk · Toplam ~75 dk

**Kaynak:** Konya Patlıcan Tiridi, Türk Patent Coğrafi İşaret Tescil No 1002 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kıymalı Sos", "sure_dakika": 35, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "KONSERVE DOMATES SALÇASI", "TATLIKA KIRMIZI BİBER", "KARABİBER", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Patlıcan Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 150, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis Düzeni", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["EKMEK (BEYAZ)", "SÜZME YOĞURT", "SARIMSAK", "MAYDANOZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Usulü Zeytinyağlı Enginar -> Konya Tiridi (CI 1233)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Usulü Zeytinyağlı Enginar';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Usulü Zeytinyağlı Enginar';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Tiridi') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Tiridi';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Usulü Zeytinyağlı Enginar') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Usulü Zeytinyağlı Enginar';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Tiridi', v_grup1_id, 1, 70,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 187.5}, {"ad": "SU", "miktar_gram": 300.0}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 150.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "SÜZME YOĞURT", "miktar_gram": 75.0}, {"ad": "SARIMSAK", "miktar_gram": 1.25}, {"ad": "DOMATES", "miktar_gram": 50.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 30.0}, {"ad": "SUMAK", "miktar_gram": 1.5}, {"ad": "KURU NANE", "miktar_gram": 1.25}, {"ad": "MAYDANOZ", "miktar_gram": 12.5}, {"ad": "TUZ", "miktar_gram": 2.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Tiridi', null, '**Hazırlık / Mise en Place**
1. Tandır ekmeklerini kuşbaşı boyutunda kesin. Mor soğanı ince dilimleyip 2 g tuzla avuç içinde sıkın, acı suyunu uzaklaştırıp yıkayın.
2. Yoğurda 100 ml su ve rendelenmiş sarımsak ekleyip homojen karıştırın.

**Isıl İşlem**
1. Haşlama (~45 dk): Kemikli kuzu etini 1 litre su ve 4 g tuzla etler kemikten kolayca ayrılana kadar haşlayın. Suyunu süzüp saklayın, etleri kemikten ayırın.

**Servis düzeni**
1. Ekmeklerin üzerine sırasıyla soğan, sarımsaklı yoğurt, ince doğranmış domates ve yeşil biber ile etleri yayın.
2. Üzerine haşlama suyunu gezdirin; sumak, nane, 2 g tuz ve ince kıyılmış maydanoz serpip servis edin.

**PARALEL YAPILABİLİRLİK:** Et haşlanırken ekmek, soğan ve yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~40 dk · Toplam ~70 dk

**Kaynak:** Konya Tiridi, Türk Patent Coğrafi İşaret Tescil No 1233 (4 kişilik).',
            '[{"sira": 1, "ad": "Haşlama", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "SU", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis Düzeni", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["EKMEK (BEYAZ)", "KURU SOĞAN", "SÜZME YOĞURT", "SARIMSAK", "DOMATES", "YEŞİL BİBER", "SUMAK", "KURU NANE", "MAYDANOZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Konya Usulü Etli Nohutlu Yahni -> Konya Çirli (CI 1048)
    select id into v_id from receteler where isletme_id is null and ad = 'Konya Usulü Etli Nohutlu Yahni';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Konya Usulü Etli Nohutlu Yahni';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Konya Çirli') then
        raise notice 'Yeni ad zaten var, atlandi: Konya Çirli';
    elsif _kopya_kullanimda_mi(v_id, 'Konya Usulü Etli Nohutlu Yahni') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Konya Usulü Etli Nohutlu Yahni';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Konya Çirli', v_grup1_id, 1, 85,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (SIRT)", "miktar_gram": 37.5}, {"ad": "KUZU ETİ (BUT)", "miktar_gram": 50.0}, {"ad": "KURU ÜZÜM", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "SU", "miktar_gram": 250.0}, {"ad": "TEREYAĞI", "miktar_gram": 6.25}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 2.3}, {"ad": "KUYRUKYAĞI", "miktar_gram": 1.25}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 0.75}, {"ad": "KARABİBER", "miktar_gram": 0.75}, {"ad": "TOZ ŞEKER", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Konya Çirli', null, '**Hazırlık / Mise en Place**
1. Kuzu kaburgasını kemikli, 4 cm uzunluğunda parçalayın; soğanların kabuğunu soyun, bütün bırakın.

**Isıl İşlem**
1. Kavurma (~12 dk): Tencereyi önceden ısıtın; sıvı yağ ve kuyruk yağını 2 dakika karıştırın, kuşbaşı ve kaburga etlerini ekleyip pembeleşinceye kadar ~10 dakika kavurun.
2. Haşlama (~20 dk): Bütün soğanları toz biberle ekleyin, suyu ilave edip etin sertliği geçinceye kadar pişirin.
3. Üzüm (30-35 dk): Çekirdekli kuru üzümleri ekleyin; şiştikten sonra pişirmeye devam edin.
4. Son kaynatma (5 dk): Karabiber ve şekeri ekleyip kaynatın, ateşten alın.
5. Dinlendirme (10 dk).

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~60 dk · Toplam ~85 dk

**Kaynak:** Konya Çirli, Türk Patent Coğrafi İşaret Tescil No 1048 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (SIRT)", "KUZU ETİ (BUT)", "AYÇİÇEK YAĞI", "KUYRUKYAĞI", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Haşlama", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "SU", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Üzümle Pişirme", "sure_dakika": 33, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU ÜZÜM"], "yeni_su_gram": null}, {"sira": 5, "ad": "Son Kaynatma", "sure_dakika": 5, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARABİBER", "TOZ ŞEKER", "TUZ"], "yeni_su_gram": null}, {"sira": 6, "ad": "Dinlendirme", "sure_dakika": 10, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Gaziantep Usulü Zeytinyağlı Nohutlu Kabak -> Gaziantep Kabaklama (CI 779)
    select id into v_id from receteler where isletme_id is null and ad = 'Gaziantep Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Gaziantep Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Gaziantep Kabaklama') then
        raise notice 'Yeni ad zaten var, atlandi: Gaziantep Kabaklama';
    elsif _kopya_kullanimda_mi(v_id, 'Gaziantep Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Gaziantep Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Gaziantep Kabaklama', v_grup1_id, 1, 103,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "KABAK", "miktar_gram": 318.0}, {"ad": "KUZU ETİ (KOL)", "miktar_gram": 91.0}, {"ad": "NOHUT", "miktar_gram": 15.0}, {"ad": "KURU SOĞAN", "miktar_gram": 22.7}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 7.3}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 7.3}, {"ad": "SARIMSAK", "miktar_gram": 4.5}, {"ad": "LİMON SUYU", "miktar_gram": 2.0}, {"ad": "SADEYAĞ", "miktar_gram": 9.5}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.6}, {"ad": "KARABİBER", "miktar_gram": 0.9}, {"ad": "KURU NANE", "miktar_gram": 0.45}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "SU", "miktar_gram": 150.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Gaziantep Kabaklama', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gece önceden ıslatın. Kış aylarında kışlık, yaz aylarında yazlık kabak kullanılır.
2. Kabakları soyup iç çekirdeklerini çıkarın, 2-4 cm büyüklüğünde doğrayın. Soğanı doğrayın.

**Isıl İşlem**
1. Et ve nohut (~60 dk): Etleri iyice yıkayıp tencerede kaynatın, köpüğünü alın. Islatılmış nohudu ekleyip et ve nohut iyice yumuşayıncaya kadar pişirin.
2. Kabak (~25 dk): Kabakları ve soğanı ekleyin. Biber ve domates salçasını yemeğin suyundan bir miktarla homojen karıştırıp ekleyin; tuzlayıp kapağı kapalı, kabaklar yumuşayana kadar pişirin. Sarımsak ve limon suyunu (veya sumak ekşisini) ekleyip ocaktan alın.
3. Sos: Yağı kızdırıp nane, karabiber ve kırmızı biberi ekleyin.

**Servis:** Sosu yemeğin üzerine gezdirerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~75 dk · Toplam ~103 dk (nohut ıslatma hariç)

**Kaynak:** Gaziantep Kabaklama, Türk Patent Coğrafi İşaret Tescil No 779 (5-6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Et ve Nohut Pişirme", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kabakla Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "SARIMSAK", "LİMON SUYU", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Sos", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SADEYAĞ", "TATLIKA KIRMIZI BİBER", "KARABİBER", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa -> Gaziantep Pirpirim Aşı (CI 964)
    select id into v_id from receteler where isletme_id is null and ad = 'Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Gaziantep Pirpirim Aşı') then
        raise notice 'Yeni ad zaten var, atlandi: Gaziantep Pirpirim Aşı';
    elsif _kopya_kullanimda_mi(v_id, 'Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Gaziantep Pirpirim Aşı', v_grup2_id, 1, 125,
            '["kuru_baklagil", "vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "SEMİZOTU", "miktar_gram": 123.0}, {"ad": "NOHUT", "miktar_gram": 12.7}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 13.6}, {"ad": "BÖRÜLCE (KURU)", "miktar_gram": 12.7}, {"ad": "BULGUR", "miktar_gram": 13.6}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 3.2}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 3.2}, {"ad": "LİMON SUYU", "miktar_gram": 2.3}, {"ad": "KURU SOĞAN", "miktar_gram": 12.7}, {"ad": "SARIMSAK", "miktar_gram": 4.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 16.4}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.4}, {"ad": "KURU NANE", "miktar_gram": 1.4}, {"ad": "TUZ", "miktar_gram": 0.7}, {"ad": "SU", "miktar_gram": 200.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Gaziantep Pirpirim Aşı', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gece önceden ıslatın. Taze pirpirimi (semizotu) ayıklayıp yıkayın, iri doğrayıp süzgeçte bekletin.
2. Ertesi gün nohudun suyunu süzüp pişirin; ayıklanmış loğlazı (börülce) ayrı bir kapta pişirin.

**Isıl İşlem**
1. Nohut ve börülce haşlama (~50 dk).
2. Kavurma (~5 dk): Derin tencerede 2-3 yemek kaşığı zeytinyağında ince doğranmış soğanı kavurun, biber ve domates salçasını ekleyip kavurmaya devam edin.
3. Pişirme (~40 dk): 5-6 su bardağı sıcak su ekleyip kaynatın; yeşil mercimeği ekleyin. Mercimek pişince nohut, börülce, pirpirim, bulgur, dövülmüş sarımsak, sumak ekşisi ve tuzu ekleyin; hafif ateşte pirpirim yumuşayana kadar pişirin.
4. Sos: Kalan yağı kızdırıp kırmızı toz biber ve kuru naneyi ekleyin, yemeğin üzerine gezdirin. 10-15 dakika dinlendirin.

**Servis:** Dinlendirdikten sonra servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~34 dk · Pasif bekleme ~91 dk · Toplam ~125 dk (nohut ıslatma hariç)

**Kaynak:** Gaziantep Pirpirim Aşı, Türk Patent Coğrafi İşaret Tescil No 964 (5-6 porsiyon).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Nohut ve Börülce Haşlama", "sure_dakika": 50, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "BÖRÜLCE (KURU)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "ZEYTİNYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 40, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SEMİZOTU", "YEŞİL MERCİMEK", "BULGUR", "SARIMSAK", "LİMON SUYU", "TUZ", "SU"], "yeni_su_gram": null}, {"sira": 5, "ad": "Sos ve Dinlendirme", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TATLIKA KIRMIZI BİBER", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Hatay Usulü Zeytinyağlı Nohutlu Havuç -> Hatay Adesiye Yemeği (CI 1851)
    select id into v_id from receteler where isletme_id is null and ad = 'Hatay Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Hatay Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Hatay Adesiye Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Hatay Adesiye Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Hatay Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Hatay Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Hatay Adesiye Yemeği', v_grup2_id, 1, 55,
            '["zeytinyagli", "vejetaryen"]'::jsonb, 'sonbahar', 'Akdeniz',
            '[{"ad": "KABAK", "miktar_gram": 214.0}, {"ad": "KURU SOĞAN", "miktar_gram": 60.7}, {"ad": "KIRMIZI BİBER", "miktar_gram": 39.3}, {"ad": "SARIMSAK", "miktar_gram": 5.0}, {"ad": "NOHUT", "miktar_gram": 6.3}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 8.6}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 16.25}, {"ad": "SU", "miktar_gram": 32.0}, {"ad": "NAR EKŞİSİ", "miktar_gram": 1.8}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.5}, {"ad": "KURU NANE", "miktar_gram": 1.8}, {"ad": "TUZ", "miktar_gram": 1.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Hatay Adesiye Yemeği', null, '**Hazırlık / Mise en Place**
1. Bal kabağının kabuğunu soyup 1-1,5 cm iri küpler halinde doğrayın.
2. Soğanları ve kırmızı biberleri jülyen (piyazlık) doğrayıp tencereye alın. Sarımsakları ince doğrayıp haşlanmış nohut ve az haşlanmış yeşil mercimekle birlikte ekleyin.

**Isıl İşlem**
1. Pişirme (kısık ateş, 30-40 dk): Zeytinyağını ekleyip iyice karıştırın. Nar ekşisi, su, domates salçası ve tuzu ilave edip pişirin.

**Servis:** Üzerine kuru nane serpip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~30 dk · Toplam ~55 dk

**Kaynak:** Hatay Adesiye Yemeği, Türk Patent Coğrafi İşaret Tescil No 1851 (6-8 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KURU SOĞAN", "KIRMIZI BİBER", "NOHUT", "YEŞİL MERCİMEK", "ZEYTİNYAĞI", "SU", "NAR EKŞİSİ", "KONSERVE DOMATES SALÇASI", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Hatay Usulü Zeytinyağlı Enginar -> Antakya Zılk Sarması (CI 1583)
    select id into v_id from receteler where isletme_id is null and ad = 'Hatay Usulü Zeytinyağlı Enginar';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Hatay Usulü Zeytinyağlı Enginar';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Antakya Zılk Sarması') then
        raise notice 'Yeni ad zaten var, atlandi: Antakya Zılk Sarması';
    elsif _kopya_kullanimda_mi(v_id, 'Hatay Usulü Zeytinyağlı Enginar') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Hatay Usulü Zeytinyağlı Enginar';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Antakya Zılk Sarması', v_grup2_id, 1, 135,
            '["zeytinyagli", "dolma", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "PAZI", "miktar_gram": 100.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 83.3}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 22.75}, {"ad": "NAR EKŞİSİ", "miktar_gram": 10.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 5.0}, {"ad": "SARIMSAK", "miktar_gram": 1.7}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KİMYON", "miktar_gram": 0.8}, {"ad": "KURU NANE", "miktar_gram": 0.8}, {"ad": "TOZ ŞEKER", "miktar_gram": 0.5}, {"ad": "KARABİBER", "miktar_gram": 0.5}, {"ad": "YENİBAHAR", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Antakya Zılk Sarması', null, '**Hazırlık / Mise en Place**
1. Pazıları soğuk suda yıkayıp saplarından ayırın. Yaprakları kaynar suya batırıp çıkararak haşlayın, soğuk sudan geçirip süzün.
2. Pirinci tuzlu suda yarım saat bekletin.
3. Pazıları el ayası büyüklüğünde kesip kalın damarlarını ayırın.

**Isıl İşlem**
1. İç harç (~15 dk): Zeytinyağında ince doğranmış soğanı ve dövülmüş sarımsağı kavurun. Süzülmüş pirinci ekleyip 5 dakika pişirin; tuz ve baharatları katın. Sıcak su ekleyip 5 dakika daha pişirin, şekeri ekleyip karıştırın.
2. Sarma: Pazıları harçla parmak kalınlığında sarın. Tencerenin dibine kalın damarları serip sarmaları dizin.
3. Pişirme (~45 dk): Zeytinyağı, nar ekşisi, sıcak su ve salçayı ekleyin; önce 5 dakika hızlı, sonra kısık ateşte ~40 dakika pişirin.

**Servis:** İsteğe göre soğuk ya da sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~75 dk · Pasif bekleme ~60 dk · Toplam ~135 dk

**Kaynak:** Antakya Zılk Sarması, Türk Patent Coğrafi İşaret Tescil No 1583 (6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 35, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PAZI"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "KURU SOĞAN", "SARIMSAK", "PUL BİBER", "TUZ", "KİMYON", "KURU NANE", "TOZ ŞEKER", "KARABİBER", "YENİBAHAR"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sarma", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PAZI", "ZEYTİNYAĞI", "NAR EKŞİSİ", "KONSERVE BİBER SALÇASI", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kayseri Usulü Etli Nohutlu Patlıcan -> Kayseri Fırın Ağzı Kebabı (CI 1064)
    select id into v_id from receteler where isletme_id is null and ad = 'Kayseri Usulü Etli Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kayseri Usulü Etli Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kayseri Fırın Ağzı Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Kayseri Fırın Ağzı Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Kayseri Usulü Etli Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kayseri Usulü Etli Nohutlu Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kayseri Fırın Ağzı Kebabı', v_grup1_id, 1, 215,
            '["kirmizi_et"]'::jsonb, 'yaz', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 125.0}, {"ad": "KUZU PİRZOLA", "miktar_gram": 200.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 25.0}, {"ad": "DOMATES", "miktar_gram": 206.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 125.0}, {"ad": "SARIMSAK", "miktar_gram": 62.5}, {"ad": "KEKİK", "miktar_gram": 0.35}, {"ad": "TUZ", "miktar_gram": 2.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kayseri Fırın Ağzı Kebabı', null, '**Hazırlık / Mise en Place**
1. Kuyruk yağının 150 g''ını bakır tepsinin tabanını kaplayacak şekilde dizin.
2. Kekik ile harmanlanmış sinirsiz kuzu kuşbaşı ve kemikli kuzu pirzolaları tepsiye yayın.
3. Üzerine soyulmuş sarımsak dişlerini, halka dilimlenmiş domatesleri ve 6-9 cm uzunluğunda ikiye bölünmüş yeşil biberleri yerleştirin. En üste kalan 50 g kuyruk yağını yayıp tuzlayın.

**Isıl İşlem**
1. Fırınlama (taş fırın ağzı, 3-3,5 saat): Tepsinin üzerini alüminyum folyoyla kapatıp fırının ağız kısmına yakın en serin yerinde pişirin.

**Servis:** Sıcak olarak, sıcak pide ile servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~190 dk · Toplam ~215 dk

**Kaynak:** Kayseri Fırın Ağzı Kebabı, Türk Patent Coğrafi İşaret Tescil No 1064 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Tepsiye Dizme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 195, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (BUT)", "KUZU PİRZOLA", "KUYRUKYAĞI", "DOMATES", "YEŞİL BİBER", "SARIMSAK", "KEKİK", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kayseri Usulü Izgara Tavuk Kanat -> Kayseri Tepsi Mantısı (CI 1059)
    select id into v_id from receteler where isletme_id is null and ad = 'Kayseri Usulü Izgara Tavuk Kanat';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kayseri Usulü Izgara Tavuk Kanat';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kayseri Tepsi Mantısı') then
        raise notice 'Yeni ad zaten var, atlandi: Kayseri Tepsi Mantısı';
    elsif _kopya_kullanimda_mi(v_id, 'Kayseri Usulü Izgara Tavuk Kanat') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kayseri Usulü Izgara Tavuk Kanat';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kayseri Tepsi Mantısı', v_grup2_id, 1, 152,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 150.0}, {"ad": "TUZ", "miktar_gram": 7.25}, {"ad": "SU", "miktar_gram": 250.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 25.0}, {"ad": "DANA KIYMA", "miktar_gram": 200.0}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 2.5}, {"ad": "KURU SOĞAN", "miktar_gram": 75.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 10.0}, {"ad": "TEREYAĞI", "miktar_gram": 16.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 27.5}, {"ad": "SÜZME YOĞURT", "miktar_gram": 112.5}, {"ad": "SARIMSAK", "miktar_gram": 2.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kayseri Tepsi Mantısı', null, '**Hazırlık / Mise en Place**
1. Kıymalı harç: Kıyma, tuz, karabiber, kırmızı toz biber ve ince kıyılıp suyu sıkılmış soğanı homojen olana kadar yoğurun; bekletmeden çiğ kullanın.
2. Hamur: Un, su, tuz ve yumurtayı yumuşak kıvamda yoğurun; 15-20 dakika dinlendirin. 0,3-0,5 cm kalınlığında açıp 3x3 cm kareler kesin.
3. Her karenin ortasına 8-10 g harç koyup ikiye katlayın, kenarlarını birleştirin; harç ortada ve üstü açık kalmalı. Tabanı tereyağlı tepsiye kıymalı kısım yukarıda, boşluksuz ve dik dizin.
4. Salçalı sos: Su ve salçayı orta ateşte 1-2 dakika kaynatın. Yoğurtlu sos: Süzme yoğurda sarımsak ve tuz ekleyin.

**Isıl İşlem**
1. Fırınlama: Mantıların üzerine zeytinyağı-tereyağı karışımını gezdirin. 230°C''de 3-5 dakika ısıtılmış fırında, 180-200°C''de 25 dakika kızartın.
2. Soğutma (15-20 dk): Tepsiyi ortam sıcaklığında bekletin.
3. Sos ile pişirme (5-6 dk): Üzerine sıcak salçalı sosu gezdirip tepsiyi ocakta orta ateşte pişirin.

**Servis:** Tepside, ortasına yoğurtlu sos konarak sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~91 dk · Pasif bekleme ~61 dk · Toplam ~152 dk

**Kaynak:** Kayseri Tepsi Mantısı, Türk Patent Coğrafi İşaret Tescil No 1059 (4 kişilik).',
            '[{"sira": 1, "ad": "Harç ve Hamur", "sure_dakika": 35, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma, Kesme ve Kapatma", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "TAVUK YUMURTASI", "DANA KIYMA", "KURU SOĞAN", "ZEYTİNYAĞI", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Soğutma", "sure_dakika": 18, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Sosla Pişirme", "sure_dakika": 6, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KONSERVE DOMATES SALÇASI", "SU"], "yeni_su_gram": null}, {"sira": 6, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["SÜZME YOĞURT", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Malatya Usulü Zeytinyağlı Nohutlu Havuç -> Malatya Tevek Yaprağı Sarması (CI 1116)
    select id into v_id from receteler where isletme_id is null and ad = 'Malatya Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Malatya Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Malatya Tevek Yaprağı Sarması') then
        raise notice 'Yeni ad zaten var, atlandi: Malatya Tevek Yaprağı Sarması';
    elsif _kopya_kullanimda_mi(v_id, 'Malatya Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Malatya Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Malatya Tevek Yaprağı Sarması', v_grup2_id, 1, 145,
            '["dolma"]'::jsonb, 'yaz', 'Doğu Anadolu',
            '[{"ad": "SALAMURA YAPRAK", "miktar_gram": 71.4}, {"ad": "BULGUR", "miktar_gram": 28.6}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 35.7}, {"ad": "DANA KIYMA", "miktar_gram": 42.9}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 65.7}, {"ad": "KURU SOĞAN", "miktar_gram": 15.7}, {"ad": "MAYDANOZ", "miktar_gram": 7.1}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 9.9}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 4.0}, {"ad": "PUL BİBER", "miktar_gram": 0.3}, {"ad": "KARABİBER", "miktar_gram": 0.8}, {"ad": "LİMON", "miktar_gram": 15.7}, {"ad": "SU", "miktar_gram": 142.9}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Malatya Tevek Yaprağı Sarması', null, '**Hazırlık / Mise en Place**
1. Salamura Arapgir Köhnü üzüm yapraklarını (tevek) tuzu çıksın diye bir gece sıcak suda bekletin (taze yaprak haşlanır). Saplarını koparın.
2. İç harç: Kıyma, pilavlık bulgur, yıkanmış pirinç, küp doğranmış soğan, ince doğranmış maydanoz, domates ve biber salçası (45 g + 15 g), baharatlar ve ayçiçek yağını (300 ml) 5-10 dakika yoğurun.
3. Yaprakları parlak yüzü dışta kalacak şekilde koyup harcı yerleştirin, kenarları içe kıvırarak sıkıca sarın. Tencerenin dibine bir sıra yaprak serip sarmaları dizin; en üste halka limon dilimleri koyun.

**Isıl İşlem**
1. Pişirme (kısık ateş, 1-1,5 saat): Su, salça (24 g + 13 g) ve ayçiçek yağını (200 ml) karıştırıp tencereye ekleyin; kaynayınca kısık ateşte pişirin. Salamura yaprakta tuz eklenmez.

**Servis:** Sıcak olarak, isteğe göre yoğurtla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~70 dk · Pasif bekleme ~75 dk · Toplam ~145 dk (bir gece yaprak bekletme hariç)

**Kaynak:** Malatya Tevek Yaprağı Sarması, Türk Patent Coğrafi İşaret Tescil No 1116 (6-8 kişilik).',
            '[{"sira": 1, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sarma", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 80, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SALAMURA YAPRAK", "BULGUR", "PİRİNÇ (HAM)", "DANA KIYMA", "AYÇİÇEK YAĞI", "SU", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "LİMON"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Malatya Usulü Zeytinyağlı Nohutlu Kabak -> Malatya Ispanaklı Ekşili Köftesi (CI 1259)
    select id into v_id from receteler where isletme_id is null and ad = 'Malatya Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Malatya Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Malatya Ispanaklı Ekşili Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Malatya Ispanaklı Ekşili Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Malatya Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Malatya Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Malatya Ispanaklı Ekşili Köftesi', v_grup2_id, 1, 97,
            '["corba", "vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "BULGUR", "miktar_gram": 83.3}, {"ad": "ISPANAK", "miktar_gram": 50.0}, {"ad": "SU", "miktar_gram": 416.7}, {"ad": "KURU SOĞAN", "miktar_gram": 33.3}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 27.6}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 16.7}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 6.7}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 6.7}, {"ad": "NAR EKŞİSİ", "miktar_gram": 8.3}, {"ad": "TUZ", "miktar_gram": 4.2}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Malatya Ispanaklı Ekşili Köftesi', null, '**Hazırlık / Mise en Place**
1. Yarmayı 500 ml sıcak su ve 12,5 g tuzla karıştırıp 10 dakika dinlendirin. Suyunu çekip yumuşayan yarmayı yapışkan bir hamur olana kadar yoğurun.
2. Hamuru 1,5 cm''lik parçalara bölüp ıslak elle avuç içinde yuvarlayın.

**Isıl İşlem**
1. Kavurma (~7 dk): İnce doğranmış soğanları sıvı yağda pembeleşinceye kadar kavurun; biber ve domates salçasını eriyene kadar karıştırın.
2. Kaynatma (20 dk): 2 litre su, 12,5 g tuz ve mercimeği ekleyip kaynatın.
3. Köfte (5 dk): Köfteleri tencerede haşlayın.
4. Ispanaklı pişirme (30 dk): İnce doğranmış ıspanağı ekleyip kısık ateşte pişirin. Malatya erik ekşisini ekleyip ocaktan indirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~39 dk · Pasif bekleme ~58 dk · Toplam ~97 dk

**Kaynak:** Malatya Ispanaklı Ekşili Köftesi, Türk Patent Coğrafi İşaret Tescil No 1259 (6 kişilik).',
            '[{"sira": 1, "ad": "Yarma Hamuru ve Köfte", "sure_dakika": 35, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 7, "aktif_dakika": 7, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI", "KONSERVE BİBER SALÇASI", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Mercimek Kaynatma", "sure_dakika": 20, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "YEŞİL MERCİMEK", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Köfte Haşlama", "sure_dakika": 5, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR"], "yeni_su_gram": null}, {"sira": 5, "ad": "Ispanakla Pişirme", "sure_dakika": 30, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ISPANAK", "NAR EKŞİSİ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Malatya Usulü Etli Bulgur Pilavı -> Malatya Simit Pilavı (CI 1182)
    select id into v_id from receteler where isletme_id is null and ad = 'Malatya Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Malatya Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Malatya Simit Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Malatya Simit Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Malatya Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Malatya Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Malatya Simit Pilavı', v_grup2_id, 1, 35,
            '["pilav", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "SU", "miktar_gram": 200.0}, {"ad": "İNCE BULGUR", "miktar_gram": 75.0}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 7.5}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 7.5}, {"ad": "TEREYAĞI", "miktar_gram": 30.0}, {"ad": "TUZ", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Malatya Simit Pilavı', null, '**Hazırlık / Mise en Place**
1. Soğanları ince yemeklik doğrayın.

**Isıl İşlem**
1. Kavurma (~8 dk): Soğanları eritilmiş tereyağında kavurun; domates ve biber salçasını ekleyip kavurun.
2. Pişirme (10 dk): Suyu ekleyin; kaynayınca tuz ve köftelik ince bulguru katıp kısık ateşte pişirin.
3. Demleme (10 dk): Kapağı kapatıp dinlendirin. İsteğe göre üzerine eritilmiş 40 g tereyağı gezdirin.

**Servis:** İsteğe göre yeşil soğan, turşu ve ayranla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~19 dk · Toplam ~35 dk

**Kaynak:** Malatya Simit Pilavı, Türk Patent Coğrafi İşaret Tescil No 1182 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "TEREYAĞI", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 12, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "İNCE BULGUR", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Demleme", "sure_dakika": 10, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mardin Usulü Zeytinyağlı Nohutlu Havuç -> Mardin Alluciye (CI 1429)
    select id into v_id from receteler where isletme_id is null and ad = 'Mardin Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mardin Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mardin Alluciye') then
        raise notice 'Yeni ad zaten var, atlandi: Mardin Alluciye';
    elsif _kopya_kullanimda_mi(v_id, 'Mardin Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mardin Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mardin Alluciye', v_grup1_id, 1, 130,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 200.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 20.0}, {"ad": "TAZE SOĞAN", "miktar_gram": 100.0}, {"ad": "ERİK", "miktar_gram": 200.0}, {"ad": "SU", "miktar_gram": 200.0}, {"ad": "TUZ", "miktar_gram": 1.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mardin Alluciye', null, '**Hazırlık / Mise en Place**
1. Papaz eriği taze ya da salamura kullanılır (salamura: 1 kg erik, 20 g kaya tuzu ve 1 l sıcak su ile kavanozda, erikler sararana kadar).
2. Kuyruk yağını şerit şeklinde, taze soğanı ince doğrayın.

**Isıl İşlem**
1. Pişirme (kısık ateş, 2 saat): Tencereye sırasıyla kuyruk yağı, yağlı kuşbaşı kuzu eti, taze soğan ve papaz eriğini yerleştirin. Su ve tuzu ekleyip pişirin. Bileşenler dağılmasın diye pişirirken karıştırmayın.

**Servis:** Sıcak olarak, isteğe göre üzerine maydanoz serperek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~117 dk · Toplam ~130 dk

**Kaynak:** Mardin Alluciye, Türk Patent Coğrafi İşaret Tescil No 1429 (4-6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 120, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KUYRUKYAĞI", "TAZE SOĞAN", "ERİK", "SU", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mardin Usulü Etli Kavurma (Baharatlı) -> Mardin Kebabı (CI 1538)
    select id into v_id from receteler where isletme_id is null and ad = 'Mardin Usulü Etli Kavurma (Baharatlı)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mardin Usulü Etli Kavurma (Baharatlı)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mardin Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Mardin Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Mardin Usulü Etli Kavurma (Baharatlı)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mardin Usulü Etli Kavurma (Baharatlı)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mardin Kebabı', v_grup1_id, 1, 65,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "SIĞIR KABURGA", "miktar_gram": 83.3}, {"ad": "KUZU ETİ (BEL)", "miktar_gram": 83.3}, {"ad": "KUYRUKYAĞI", "miktar_gram": 16.7}, {"ad": "YEŞİL BİBER", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mardin Kebabı', null, '**Hazırlık / Mise en Place**
1. Dana kaburga eti, kuzunun boşluk kısmından alınan et ve kuyruk yağını kuşbaşı doğrayın; tuz ve biber ekleyip hepsini zırhla çekin (~30 dk). Dondurulmuş kuyruk yağı kullanılmaz.
2. Karışımı oval ince şişlere 50''şer g olacak şekilde ince takın; pişirmeden önce en az 15-20 dakika dinlendirin.

**Isıl İşlem**
1. Izgara (6-8 dk): Alevsiz, durgun, korlu odun ateşinde iki tarafı eşit pişecek şekilde pişirin.

**Servis:** Şişlerden çıkarıp porsiyonda 4 şiş olacak şekilde tabağa koyun; isteğe göre lavaş, sumaklı soğan, közlenmiş domates ve biberle sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~47 dk · Pasif bekleme ~18 dk · Toplam ~65 dk

**Kaynak:** Mardin Kebabı, Türk Patent Coğrafi İşaret Tescil No 1538 (4-6 kişilik, porsiyonda 4 şiş).',
            '[{"sira": 1, "ad": "Zırhla Çekme", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şişe Takma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Dinlendirme", "sure_dakika": 18, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Izgara", "sure_dakika": 7, "aktif_dakika": 7, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KABURGA", "KUZU ETİ (BEL)", "KUYRUKYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mardin Usulü Etli Bulgur Pilavı -> Mardin İncasiyye (CI 1627)
    select id into v_id from receteler where isletme_id is null and ad = 'Mardin Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mardin Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mardin İncasiyye') then
        raise notice 'Yeni ad zaten var, atlandi: Mardin İncasiyye';
    elsif _kopya_kullanimda_mi(v_id, 'Mardin Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mardin Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mardin İncasiyye', v_grup1_id, 1, 165,
            '["kirmizi_et"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 200.0}, {"ad": "KURUTULMUŞ ERIK", "miktar_gram": 200.0}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 32.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 7.0}, {"ad": "TUZ", "miktar_gram": 0.4}, {"ad": "LİMON SUYU", "miktar_gram": 3.0}, {"ad": "KURU SOĞAN", "miktar_gram": 15.0}, {"ad": "SU", "miktar_gram": 200.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mardin İncasiyye', null, '**Hazırlık / Mise en Place**
1. Kuru mürdüm eriklerini yumuşaması için 1 saat sıcak suda bekletin.

**Isıl İşlem**
1. Haşlama (1 saat): Yağlı kuşbaşı kuzu etini tencereye alıp üzerine su ekleyerek haşlayın.
2. Erikli pişirme (30 dk): Arpacık soğanları ve erikleri ekleyin.
3. Son pişirme (~15 dk): Şeker, üzüm pekmezi, tuz ve limon suyunu ekleyip kısık ateşte pişirin.

**Servis:** Sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Erikler suda beklerken et haşlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~155 dk · Toplam ~165 dk

**Kaynak:** Mardin İncasiyye, Türk Patent Coğrafi İşaret Tescil No 1627 (4-6 kişilik).',
            '[{"sira": 1, "ad": "Erik Bekletme", "sure_dakika": 60, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Erikli Pişirme", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURUTULMUŞ ERIK", "KURU SOĞAN"], "yeni_su_gram": null}, {"sira": 4, "ad": "Son Pişirme", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ÜzÜM PEKMEZİ", "TOZ ŞEKER", "TUZ", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mardin Usulü Etli Nohutlu Bulgur -> Mardin Irok (CI 1473)
    select id into v_id from receteler where isletme_id is null and ad = 'Mardin Usulü Etli Nohutlu Bulgur';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mardin Usulü Etli Nohutlu Bulgur';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mardin Irok') then
        raise notice 'Yeni ad zaten var, atlandi: Mardin Irok';
    elsif _kopya_kullanimda_mi(v_id, 'Mardin Usulü Etli Nohutlu Bulgur') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mardin Usulü Etli Nohutlu Bulgur';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mardin Irok', v_grup1_id, 1, 125,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "BULGUR", "miktar_gram": 88.9}, {"ad": "KUYRUKYAĞI", "miktar_gram": 7.4}, {"ad": "DANA KIYMA", "miktar_gram": 88.9}, {"ad": "TAZE KİŞNİŞ", "miktar_gram": 4.4}, {"ad": "TUZ", "miktar_gram": 0.9}, {"ad": "SU", "miktar_gram": 22.2}, {"ad": "MAYDANOZ", "miktar_gram": 11.1}, {"ad": "KURU SOĞAN", "miktar_gram": 18.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 3.7}, {"ad": "PUL BİBER", "miktar_gram": 0.45}, {"ad": "KARABİBER", "miktar_gram": 0.15}, {"ad": "YENİBAHAR", "miktar_gram": 0.15}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 12.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mardin Irok', null, '**Hazırlık / Mise en Place**
1. Dış harç: Mardin bulgurunu tuzla, azar azar su ekleyerek yoğurun. Kişnişi ekleyip 30 dakika yoğurun; çift çekilmiş dana eti ve kuyruk yağını ekleyip karıştırın.
2. İç harç: Ayçiçek yağında ince doğranmış soğanı kavurun, kıymayı ekleyip kavurun. Salçayı, ardından pul biber, tuz, karabiber ve yenibaharı ekleyin; en son ince doğranmış maydanozu katıp ocaktan alın ve soğutun.
3. Dış harçtan 30-35 g parçalar alıp yuvarlayın, parmakla ortasını açın; 20-25 g iç harç koyup kapatın ve hafif yassı yuvarlak şekil verin.

**Isıl İşlem**
1. Kızartma: Irokları ayçiçek yağında kızartın.

**Servis:** Sıcak olarak, isteğe göre yoğurtla servis edin.

**PARALEL YAPILABİLİRLİK:** Dış harç yoğrulurken iç harç pişirilip soğutulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~120 dk · Pasif bekleme ~5 dk · Toplam ~125 dk

**Kaynak:** Mardin Irok, Türk Patent Coğrafi İşaret Tescil No 1473 (54 adet).',
            '[{"sira": 1, "ad": "Dış Harç", "sure_dakika": 40, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "MAYDANOZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Şekillendirme", "sure_dakika": 45, "aktif_dakika": 45, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 170, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "KUYRUKYAĞI", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mardin Usulü Zeytinyağlı Biberli Patlıcan -> Mardin Harire (CI 1543)
    select id into v_id from receteler where isletme_id is null and ad = 'Mardin Usulü Zeytinyağlı Biberli Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mardin Usulü Zeytinyağlı Biberli Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mardin Harire') then
        raise notice 'Yeni ad zaten var, atlandi: Mardin Harire';
    elsif _kopya_kullanimda_mi(v_id, 'Mardin Usulü Zeytinyağlı Biberli Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mardin Usulü Zeytinyağlı Biberli Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mardin Harire', v_grup3_id, 1, 50,
            '["tatli", "vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
            '[{"ad": "TOZ ŞEKER", "miktar_gram": 15.6}, {"ad": "BUĞDAY UNU", "miktar_gram": 11.25}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 33.75}, {"ad": "SU", "miktar_gram": 125.0}, {"ad": "TARÇIN", "miktar_gram": 0.25}, {"ad": "YENİBAHAR", "miktar_gram": 0.25}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 0.6}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mardin Harire', null, '**Hazırlık / Mise en Place**
1. Tencereye sırasıyla şeker, un, üzüm pekmezi, su, yenibahar ve tarçını koyup karıştırın.

**Isıl İşlem**
1. Pişirme (~20 dk): Orta ateşte, muhallebi kıvamına gelene kadar karıştırarak pişirin; kaplara doldurun.
2. Dinlendirme: Oda sıcaklığına gelince buzdolabında 12 saat dinlendirin.

**Servis:** Üzerine ceviz içi ekleyip soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~22 dk · Pasif bekleme ~28 dk · Toplam ~50 dk (12 saat buzdolabında dinlendirme hariç)

**Kaynak:** Mardin Harire, Türk Patent Coğrafi İşaret Tescil No 1543 (8 kişilik).',
            '[{"sira": 1, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "BUĞDAY UNU", "ÜzÜM PEKMEZİ", "SU", "TARÇIN", "YENİBAHAR"], "yeni_su_gram": null}, {"sira": 2, "ad": "Soğutma ve Servis", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ordu Usulü Zeytinyağlı Kereviz -> Ordu Zeytinyağlı Karalahana Sarması (CI 1426)
    select id into v_id from receteler where isletme_id is null and ad = 'Ordu Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ordu Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ordu Zeytinyağlı Karalahana Sarması') then
        raise notice 'Yeni ad zaten var, atlandi: Ordu Zeytinyağlı Karalahana Sarması';
    elsif _kopya_kullanimda_mi(v_id, 'Ordu Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ordu Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ordu Zeytinyağlı Karalahana Sarması', v_grup2_id, 1, 103,
            '["zeytinyagli", "dolma", "vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "KARALAHANA", "miktar_gram": 208.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15.75}, {"ad": "KURU SOĞAN", "miktar_gram": 36.7}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 54.2}, {"ad": "MAYDANOZ", "miktar_gram": 8.3}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.9}, {"ad": "SARIMSAK", "miktar_gram": 1.25}, {"ad": "PUL BİBER", "miktar_gram": 0.9}, {"ad": "KARABİBER", "miktar_gram": 0.4}, {"ad": "SU", "miktar_gram": 100.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ordu Zeytinyağlı Karalahana Sarması', null, '**Hazırlık / Mise en Place**
1. Karalahanaları temizleyip sap kısımlarını yapraktan ayırın.
2. Soğanları küp doğrayın; pirinci yıkayın.

**Isıl İşlem**
1. Haşlama (5-10 dk): Yaprakları kaynayan suda damarları yumuşayana kadar haşlayıp soğuk suya alın.
2. İç harç (~20 dk): Tavaya sıvı yağ, soğan, sarımsak ve salçayı koyup soğanlar pembeleşinceye kadar kavurun. Pirinci ekleyip karıştırın; ince kıyılmış maydanoz, pul biber, karabiber ve tuzu katın. 200 ml su ekleyip suyunu çekene kadar pişirin, pilav gibi dinlendirin.
3. Sarma: Yaprakların suyunu süzüp damarlarını alın; iç harcı koyup serçe parmak kalınlığında sıkıca sarın.
4. Pişirme (20-25 dk): Sarmaları tencereye dizip üzeri kapanıncaya kadar sıcak su ekleyin; 10-15 ml sıvı yağ ve tuzu ekleyin. Üzerine düz bir tabak kapatıp kısık ateşte pişirin.

**Servis:** Tercihe göre limon dilimleriyle sıcak ya da soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~58 dk · Pasif bekleme ~45 dk · Toplam ~103 dk

**Kaynak:** Ordu Zeytinyağlı Karalahana Sarması, Türk Patent Coğrafi İşaret Tescil No 1426 (yaklaşık 6 kişilik).',
            '[{"sira": 1, "ad": "Yaprak Haşlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARALAHANA"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "PİRİNÇ (HAM)", "MAYDANOZ", "KONSERVE DOMATES SALÇASI", "SARIMSAK", "PUL BİBER", "KARABİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sarma", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 23, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARALAHANA", "AYÇİÇEK YAĞI", "TUZ", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ordu Usulü Etli Nohutlu Patlıcan -> Ordu İçli Tava (CI 1427)
    select id into v_id from receteler where isletme_id is null and ad = 'Ordu Usulü Etli Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ordu Usulü Etli Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ordu İçli Tava') then
        raise notice 'Yeni ad zaten var, atlandi: Ordu İçli Tava';
    elsif _kopya_kullanimda_mi(v_id, 'Ordu Usulü Etli Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ordu Usulü Etli Nohutlu Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ordu İçli Tava', v_grup1_id, 1, 105,
            '["balik", "pilav"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "HAMSİ", "miktar_gram": 222.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 8.3}, {"ad": "TUZ", "miktar_gram": 3.7}, {"ad": "MISIR UNU", "miktar_gram": 22.2}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 42.2}, {"ad": "KURU SOĞAN", "miktar_gram": 73.3}, {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 5.6}, {"ad": "ÇAM FISTIĞI", "miktar_gram": 5.0}, {"ad": "KARABİBER", "miktar_gram": 0.9}, {"ad": "PUL BİBER", "miktar_gram": 1.3}, {"ad": "MAYDANOZ", "miktar_gram": 5.6}, {"ad": "SU", "miktar_gram": 22.2}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ordu İçli Tava', null, '**Hazırlık / Mise en Place**
1. İç pilav: Küp doğranmış soğanları sıvı yağda pembeleşinceye kadar kavurun; dolmalık fıstığı ekleyip rengi hafif değişene kadar kavurun. Pirinci ekleyip kavurmaya devam edin. Karabiber, pul biber, ince doğranmış maydanoz, kuş üzümü ve 100 ml suyu ekleyip kapağı kapatın; suyunu çekene kadar pişirip dinlendirin.
2. Hamsileri temizleyip kılçıklarından ayırarak fileto yapın (büyük hamsi tercih edilir). Tuzlayıp mısır ununa bulayın.
3. 28-30 cm çapındaki tavanın tabanını yağlayın. Hamsileri sırtları tabana gelecek ve yarı yarıya üst üste binecek şekilde dizin; kenarlara da yarısı dışarıda kalacak şekilde dik dizin. İç pilavı eşit yayın, sarkan hamsileri pilavın üzerine kapatın, açık kalan yerleri kalan hamsilerle örtün.

**Isıl İşlem**
1. Pişirme (ocakta kısık ateş): Alt yüzey kızarınca balık tava kapağıyla ters çevirip diğer yüzü de pişirin. (Fırında: 180°C''de kızarana kadar.)

**Servis:** Ters çevirerek sunum kabına alın, sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** İç pilav dinlenirken hamsiler temizlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~75 dk · Pasif bekleme ~30 dk · Toplam ~105 dk

**Kaynak:** Ordu İçli Tava, Türk Patent Coğrafi İşaret Tescil No 1427 (4-5 kişilik).',
            '[{"sira": 1, "ad": "İç Pilav", "sure_dakika": 30, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "KURU SOĞAN", "KUŞ ÜZÜMÜ", "ÇAM FISTIĞI", "KARABİBER", "PUL BİBER", "MAYDANOZ", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hamsi Temizleme", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Dizme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAMSİ", "AYÇİÇEK YAĞI", "TUZ", "MISIR UNU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ordu Usulü Zeytinyağlı Taze Fasulye -> Ordu Fırın Fasulyesi Kavurması (CI 1747)
    select id into v_id from receteler where isletme_id is null and ad = 'Ordu Usulü Zeytinyağlı Taze Fasulye';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ordu Usulü Zeytinyağlı Taze Fasulye';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ordu Fırın Fasulyesi Kavurması') then
        raise notice 'Yeni ad zaten var, atlandi: Ordu Fırın Fasulyesi Kavurması';
    elsif _kopya_kullanimda_mi(v_id, 'Ordu Usulü Zeytinyağlı Taze Fasulye') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ordu Usulü Zeytinyağlı Taze Fasulye';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ordu Fırın Fasulyesi Kavurması', v_grup2_id, 1, 30,
            '["zeytinyagli", "vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "TAZE FASULYE", "miktar_gram": 57.1}, {"ad": "KURU SOĞAN", "miktar_gram": 62.9}, {"ad": "PUL BİBER", "miktar_gram": 2.9}, {"ad": "KARABİBER", "miktar_gram": 1.4}, {"ad": "TUZ", "miktar_gram": 1.4}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 5.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ordu Fırın Fasulyesi Kavurması', null, '**Hazırlık / Mise en Place**
1. Yaz aylarında toplanan yeşil fasulyeler ayıklanır, ıslatılır ve fırınlarda 24 saat kurutulur (kışlık).

**Isıl İşlem**
1. Haşlama (10-15 dk): Kurutulmuş fasulyeleri yumuşayıncaya kadar haşlayın, süzüp istenen boyda kesin.
2. Kavurma (~15 dk): Kuşbaşı doğranmış soğanları ayçiçek yağında pembeleşinceye kadar kavurun. Fasulyeleri, tuzu, pul biber ve karabiberi ekleyip kısık ateşte 5-10 dakika kavurun.

**Servis:** Sıcak ya da soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~17 dk · Toplam ~30 dk

**Kaynak:** Ordu Fırın Fasulyesi Kavurması, Türk Patent Coğrafi İşaret Tescil No 1747 (3-4 kişilik).',
            '[{"sira": 1, "ad": "Haşlama", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAZE FASULYE"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI", "PUL BİBER", "KARABİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ordu Usulü Elmalı Fındıklı Tatlı -> Ordu Fındıklı Burma Tatlısı (CI 1325)
    select id into v_id from receteler where isletme_id is null and ad = 'Ordu Usulü Elmalı Fındıklı Tatlı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ordu Usulü Elmalı Fındıklı Tatlı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ordu Fındıklı Burma Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Ordu Fındıklı Burma Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Ordu Usulü Elmalı Fındıklı Tatlı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ordu Usulü Elmalı Fındıklı Tatlı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ordu Fındıklı Burma Tatlısı', v_grup3_id, 1, 210,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "TAVUK YUMURTASI", "miktar_gram": 2.4}, {"ad": "SU", "miktar_gram": 41.2}, {"ad": "YOĞURT (TAM)", "miktar_gram": 3.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 3.7}, {"ad": "SİRKE", "miktar_gram": 2.4}, {"ad": "TUZ", "miktar_gram": 0.4}, {"ad": "TEREYAĞI", "miktar_gram": 12.4}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.2}, {"ad": "BUĞDAY UNU", "miktar_gram": 26.2}, {"ad": "FINDIK (İÇ)", "miktar_gram": 23.8}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 10.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 40.5}, {"ad": "LİMON SUYU", "miktar_gram": 0.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ordu Fındıklı Burma Tatlısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Un dışındaki bileşenleri homojen karıştırıp unu azar azar ekleyerek yumuşak bir hamur yoğurun; 30 dakika dinlendirin. 65-70 g''lık bezeler kesin.
2. Bezeleri nişastayla 80-85 cm çapında açın. Her yufkanın bir ucunu 5-10 cm katlayıp üzerine ~35 g kıyılmış fındık koyun; oklavaya sıkıca sarıp iki uçtan ortaya doğru sıkıştırarak tepside oklavadan çıkarın. 5-8 cm boyunda kesin.

**Isıl İşlem**
1. Fırınlama (180°C): Üzerine eritilip süzülmüş tereyağı gezdirip pembeleşinceye kadar pişirin.
2. Şerbet: Şeker ve suyu kaynatın, limon suyunu ekleyip 10 dakika kaynatın ve soğutun.
3. Şerbetleme: Ilık şerbeti soğumuş tatlıların üzerine dökün; tamamen çekmesini bekleyin.

**Servis:** Porsiyonda 4 adet olacak şekilde servis edin.

**PARALEL YAPILABİLİRLİK:** Tatlılar fırındayken şerbet hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~84 dk · Pasif bekleme ~126 dk · Toplam ~210 dk

**Kaynak:** Ordu Fındıklı Burma Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1325 (80-90 adet, porsiyonda 4 adet).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 45, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma ve Sarma", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "FINDIK (İÇ)", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbet", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}, {"sira": 5, "ad": "Soğutma ve Şerbetleme", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ordu Usulü Etli Lahana -> Ordu Galdirik Kavurması (CI 1193)
    select id into v_id from receteler where isletme_id is null and ad = 'Ordu Usulü Etli Lahana';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ordu Usulü Etli Lahana';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ordu Galdirik Kavurması') then
        raise notice 'Yeni ad zaten var, atlandi: Ordu Galdirik Kavurması';
    elsif _kopya_kullanimda_mi(v_id, 'Ordu Usulü Etli Lahana') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ordu Usulü Etli Lahana';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ordu Galdirik Kavurması', v_grup2_id, 1, 38,
            '["zeytinyagli", "vejetaryen"]'::jsonb, 'ilkbahar', 'Karadeniz',
            '[{"ad": "KALDIRIK", "miktar_gram": 142.9}, {"ad": "KURU SOĞAN", "miktar_gram": 31.4}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 7.2}, {"ad": "TEREYAĞI", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 1.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "PUL BİBER", "miktar_gram": 0.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ordu Galdirik Kavurması', null, '**Hazırlık / Mise en Place**
1. Galdirik bitkilerini temizleyin, yaprak ve çiçeklerini ayıklayın. Gövdeleri yıkayıp 2-3 cm doğrayın.

**Isıl İşlem**
1. Haşlama (10-15 dk): Kaynayan suda haşlayıp süzün, soğuk sudan geçirin.
2. Kavurma (~10 dk): Küp doğranmış soğanları ayçiçek yağında pembeleşinceye kadar kavurun; isteğe göre tereyağı, galdirik ve tuzu ekleyip kısık ateşte 3-5 dakika ara ara karıştırarak kavurun.

**Servis:** Üzerine pul biber ve karabiber serpip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~26 dk · Pasif bekleme ~12 dk · Toplam ~38 dk

**Kaynak:** Ordu Galdirik Kavurması, Türk Patent Coğrafi İşaret Tescil No 1193 (6-8 kişilik).',
            '[{"sira": 1, "ad": "Ayıklama", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 13, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KALDIRIK"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kavurma", "sure_dakika": 10, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Van Usulü Zeytinyağlı Nohutlu Havuç -> Van Erişte Aşı (CI 1712)
    select id into v_id from receteler where isletme_id is null and ad = 'Van Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Van Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Van Erişte Aşı') then
        raise notice 'Yeni ad zaten var, atlandi: Van Erişte Aşı';
    elsif _kopya_kullanimda_mi(v_id, 'Van Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Van Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Van Erişte Aşı', v_grup2_id, 1, 55,
            '["pilav_makarna_borek"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "SU", "miktar_gram": 250.0}, {"ad": "MAKARNA", "miktar_gram": 66.7}, {"ad": "YOĞURT (TAM)", "miktar_gram": 66.7}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 25.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 16.7}, {"ad": "KIRMIZI BİBER", "miktar_gram": 16.7}, {"ad": "TUZ", "miktar_gram": 5.0}, {"ad": "PUL BİBER", "miktar_gram": 1.7}, {"ad": "KURU NANE", "miktar_gram": 0.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Van Erişte Aşı', null, '**Hazırlık / Mise en Place**
1. Yeşil mercimeği yıkayıp haşlayın, suyunu süzün.

**Isıl İşlem**
1. Mercimek haşlama (~20 dk).
2. Kavurma (~7 dk): Tencereye tereyağı, salça, rendelenmiş/doğranmış kuru soğan, kırmızı biber ve tuzu koyup kavurun.
3. Pişirme (~25 dk): Sıcak su ve/veya et suyu ile mercimeği ekleyin; ara sıra karıştırarak mercimeğin iyice pişmesini sağlayın. Erişteleri ekleyip yumuşayıncaya kadar pişirin.

**Servis:** Servis tabaklarına alın; isteğe göre üzerine yoğurt, eritilmiş tereyağı-pul biber ve kuru nane dökerek sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~37 dk · Toplam ~55 dk

**Kaynak:** Van Erişte Aşı, Türk Patent Coğrafi İşaret Tescil No 1712 (6 kişilik).',
            '[{"sira": 1, "ad": "Mercimek Haşlama", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YEŞİL MERCİMEK"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 7, "aktif_dakika": 7, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KONSERVE BİBER SALÇASI", "KURU SOĞAN", "KIRMIZI BİBER", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "MAKARNA"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["YOĞURT (TAM)", "PUL BİBER", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Van Usulü Elmalı Ceviz Tatlısı -> Van Pastası (CI 805)
    select id into v_id from receteler where isletme_id is null and ad = 'Van Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Van Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Van Pastası') then
        raise notice 'Yeni ad zaten var, atlandi: Van Pastası';
    elsif _kopya_kullanimda_mi(v_id, 'Van Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Van Usulü Elmalı Ceviz Tatlısı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Van Pastası', v_grup3_id, 1, 80,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 83.3}, {"ad": "YOĞURT (TAM)", "miktar_gram": 22.2}, {"ad": "TOZ ŞEKER", "miktar_gram": 44.4}, {"ad": "TEREYAĞI", "miktar_gram": 27.8}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 2.2}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 11.1}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 1.9}, {"ad": "FINDIK (İÇ)", "miktar_gram": 11.1}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Van Pastası', null, '**Hazırlık / Mise en Place**
1. Karbonat, yoğurt ve toz şekeri 5 dakika karıştırın. Sırasıyla eritilmiş yağı ve yumurtaları ekleyip karıştırmaya devam edin; 5 dakika sonra unu ekleyip 10-15 dakika daha karıştırın.
2. Hamurdan birer kaşıklık parçalar alıp yağlanmış 40x40 cm tepsiye dizin; üzerlerine yumurta sarısı sürüp birer fındık koyun.

**Isıl İşlem**
1. Fırınlama (170°C, ~40 dk).

**Servis:** Fırından çıkarıp servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~42 dk · Pasif bekleme ~38 dk · Toplam ~80 dk

**Kaynak:** Van Pastası, Türk Patent Coğrafi İşaret Tescil No 805 (8-10 kişilik).',
            '[{"sira": 1, "ad": "Hamur", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Dizme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "YOĞURT (TAM)", "TOZ ŞEKER", "TEREYAĞI", "TAVUK YUMURTASI", "FINDIK (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Van Usulü Balı ile Kaymaklı Tatlı -> Cembeli Tatlı (CI 1837)
    select id into v_id from receteler where isletme_id is null and ad = 'Van Usulü Balı ile Kaymaklı Tatlı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Van Usulü Balı ile Kaymaklı Tatlı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Cembeli Tatlı') then
        raise notice 'Yeni ad zaten var, atlandi: Cembeli Tatlı';
    elsif _kopya_kullanimda_mi(v_id, 'Van Usulü Balı ile Kaymaklı Tatlı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Van Usulü Balı ile Kaymaklı Tatlı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Cembeli Tatlı', v_grup3_id, 1, 19,
            '["tatli", "vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "EKMEK (BEYAZ)", "miktar_gram": 83.3}, {"ad": "TEREYAĞI", "miktar_gram": 41.7}, {"ad": "BAL", "miktar_gram": 41.7}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 16.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Cembeli Tatlı', null, '**Hazırlık / Mise en Place**
1. Ekmekleri küçük parçalara bölün.

**Isıl İşlem**
1. Kavurma (~10 dk): Tereyağını eritin; ekmekleri ekleyip hafifçe kızarana kadar karıştırarak kavurun.
2. Karıştırma: Ekmekler tereyağını çekince bal ve/veya pekmezi ekleyip iyice karıştırın.

**Servis:** Servis tabağına alıp üzerine parçalanmış ceviz koyun; sıcak ya da ılık servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~19 dk · Pasif bekleme ~0 dk · Toplam ~19 dk

**Kaynak:** Cembeli Tatlı, Türk Patent Coğrafi İşaret Tescil No 1837 (6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma ve Karıştırma", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEK (BEYAZ)", "TEREYAĞI", "BAL"], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis", "sure_dakika": 2, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Van Usulü Balı ile Ceviz Tabağı -> Murtuğa (CI 243)
    select id into v_id from receteler where isletme_id is null and ad = 'Van Usulü Balı ile Ceviz Tabağı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Van Usulü Balı ile Ceviz Tabağı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Murtuğa') then
        raise notice 'Yeni ad zaten var, atlandi: Murtuğa';
    elsif _kopya_kullanimda_mi(v_id, 'Van Usulü Balı ile Ceviz Tabağı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Van Usulü Balı ile Ceviz Tabağı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Murtuğa', v_grup3_id, 1, 13,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 30.0}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 15.0}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Murtuğa', null, '**Hazırlık / Mise en Place**
1. Yumurtayı ayrı bir kapta çırpın.

**Isıl İşlem**
1. Çörek içi (~10 dk): Bakır tencerede tereyağını kısık ateşte eritin, tuzu ekleyin. Tam buğday ununu ekleyip tahta kaşıkla aralıksız karıştırarak kavurun.
2. Yumurta (~3 dk): Çırpılmış yumurtayı kavrulan una azar azar ekleyerek karıştırın; kabarıp pişinceye kadar ara ara karıştırarak 2 dakika daha pişirin.

**Servis:** Kahvaltıda sıcak olarak; sade, tuzlu ya da bal veya reçelle servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~0 dk · Toplam ~13 dk

**Kaynak:** Murtuğa, Türk Patent Coğrafi İşaret Tescil No 243 (4 kişilik).',
            '[{"sira": 1, "ad": "Un Kavurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Yumurta ile Pişirme", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK YUMURTASI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Van Usulü Etli Nohutlu Kavurma -> Van Tava Yemeği (CI 1711)
    select id into v_id from receteler where isletme_id is null and ad = 'Van Usulü Etli Nohutlu Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Van Usulü Etli Nohutlu Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Van Tava Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Van Tava Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Van Usulü Etli Nohutlu Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Van Usulü Etli Nohutlu Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Van Tava Yemeği', v_grup1_id, 1, 170,
            '["kirmizi_et"]'::jsonb, 'yaz', 'Doğu Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 300.0}, {"ad": "DOMATES", "miktar_gram": 300.0}, {"ad": "KURU SOĞAN", "miktar_gram": 75.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 75.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 25.0}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 10.0}, {"ad": "SARIMSAK", "miktar_gram": 5.0}, {"ad": "TUZ", "miktar_gram": 3.0}, {"ad": "PUL BİBER", "miktar_gram": 3.0}, {"ad": "KARABİBER", "miktar_gram": 1.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Van Tava Yemeği', null, '**Hazırlık / Mise en Place**
1. Kuyruk iç yağını kıyma makinesinden çekin veya ince doğrayın. Sivri biberleri doğrayın, domatesleri dilimleyin.
2. Tavaya kuyruk iç yağı ve/veya tereyağını koyun; üstüne kemikli etleri dizin. Etlerin üzerine doğranmış sivri biber, soğan, sarımsak ve salça, en üste domatesleri koyun; tuz ve baharatları serpin.

**Isıl İşlem**
1. Fırınlama (düşük sıcaklık, yavaş): Su eklemeden pişirin; tavanın yanmaması için ara sıra kontrol edip konumunu değiştirin.

**Servis:** Servis tabaklarına alıp sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~140 dk · Toplam ~170 dk

**Kaynak:** Van Tava Yemeği, Türk Patent Coğrafi İşaret Tescil No 1711 (10 kişilik).',
            '[{"sira": 1, "ad": "Dizme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 150, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (KOL)", "DOMATES", "KURU SOĞAN", "YEŞİL BİBER", "KUYRUKYAĞI", "TEREYAĞI", "KONSERVE DOMATES SALÇASI", "SARIMSAK", "TUZ", "PUL BİBER", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Van Usulü Etli Kavurma (Kimyonlu) -> Van Acem Köftesi (CI 1710)
    select id into v_id from receteler where isletme_id is null and ad = 'Van Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Van Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Van Acem Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Van Acem Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Van Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Van Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Van Acem Köftesi', v_grup1_id, 1, 92,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "SU", "miktar_gram": 250.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 100.0}, {"ad": "PATATES", "miktar_gram": 166.7}, {"ad": "DANA KIYMA", "miktar_gram": 100.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15.3}, {"ad": "NOHUT", "miktar_gram": 6.7}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 16.7}, {"ad": "KURU SOĞAN", "miktar_gram": 16.7}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 16.7}, {"ad": "İNCE BULGUR", "miktar_gram": 8.3}, {"ad": "TUZ", "miktar_gram": 4.2}, {"ad": "TAZE TARRAGON", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 1.7}, {"ad": "KİMYON", "miktar_gram": 1.7}, {"ad": "PUL BİBER", "miktar_gram": 1.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Van Acem Köftesi', null, '**Hazırlık / Mise en Place**
1. Yumurtaları haşlayıp kabuklarını soyun.
2. Kıyma, bulgur, pirinç, haşlanmış (tercihen kırık) nohut, rendelenmiş soğan, baharatlar ve tuzu homojen olana kadar iyice yoğurun.
3. Harçtan bir avuç içi kadar alıp yuvarlayın, ortasını açıp bütün haşlanmış yumurtayı yerleştirin ve harçla özenle kapatın.

**Isıl İşlem**
1. Yumurta haşlama (~12 dk).
2. Pişirme (~40 dk): Ayrı bir tencerede ayçiçek yağı ve salçayı kavurup su ekleyin. Isınınca köfteleri ve doğranmış patatesleri ekleyip pişirin.

**Servis:** Yemeğin suyuyla birlikte sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Yumurtalar haşlanırken harç yoğrulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~42 dk · Pasif bekleme ~50 dk · Toplam ~92 dk

**Kaynak:** Van Acem Köftesi, Türk Patent Coğrafi İşaret Tescil No 1710 (6 kişilik).',
            '[{"sira": 1, "ad": "Yumurta Haşlama", "sure_dakika": 12, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK YUMURTASI"], "yeni_su_gram": null}, {"sira": 2, "ad": "Harç ve Şekillendirme", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "PATATES", "DANA KIYMA", "AYÇİÇEK YAĞI", "NOHUT", "PİRİNÇ (HAM)", "KONSERVE DOMATES SALÇASI", "İNCE BULGUR"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak -> Urfa Su Kabağı Yemeği (CI 328)
    select id into v_id from receteler where isletme_id is null and ad = 'Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Urfa Su Kabağı Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Urfa Su Kabağı Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Urfa Su Kabağı Yemeği', v_grup1_id, 1, 120,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "KABAK", "miktar_gram": 375.0}, {"ad": "KOYUN ETİ (KOL)", "miktar_gram": 62.5}, {"ad": "NOHUT", "miktar_gram": 21.25}, {"ad": "NAR", "miktar_gram": 75.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 1.25}, {"ad": "DOMATES", "miktar_gram": 375.0}, {"ad": "TUZ", "miktar_gram": 0.6}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 1.9}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Urfa Su Kabağı Yemeği', null, '**Hazırlık / Mise en Place**
1. Nohudu önceden ıslatın.
2. Su kabağını yıkayıp sapını kesin; ikiye, sonra dilimlere bölün. Çekirdeklerini iyice ayıklayıp kabuğun yeşil kısmını soyun ve küp doğrayın.
3. Eti kuşbaşı doğrayın. Narları tanelerine ayırıp süzgeçten geçirerek suyunu çıkarın (veya koruk suyu kullanın).
4. Domatesleri yıkayıp süzgeçte ezin; suyunu bir kaba alın (yemeğe su yerine domates suyu konur).

**Isıl İşlem**
1. Et ve nohut (~60 dk): Kuşbaşı et, ilikli kemikler, nohut, domates suyu ve salçayı tencerede pişirin.
2. Kabak (~30 dk): Kaynayan yemeğe su kabaklarını, nar suyunu, şekeri ve tuzu katıp kısık ateşte kabaklar yumuşayana kadar pişirin.

**Servis:** Pilav, aya köftesi veya iri yuvalak eşliğinde taze isotla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~38 dk · Pasif bekleme ~82 dk · Toplam ~120 dk (nohut ıslatma hariç)

**Kaynak:** Urfa (Şanlıurfa) Su Kabağı Yemeği, Türk Patent Coğrafi İşaret Tescil No 328 (8 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Et ve Nohut Pişirme", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN ETİ (KOL)", "NOHUT", "DOMATES", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kabakla Pişirme", "sure_dakika": 30, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "NAR", "TOZ ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şanlıurfa Usulü Etli Bulgur Pilavı -> Urfa Üzlemeli Pilavı (CI 246)
    select id into v_id from receteler where isletme_id is null and ad = 'Şanlıurfa Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şanlıurfa Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Urfa Üzlemeli Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Urfa Üzlemeli Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Şanlıurfa Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şanlıurfa Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Urfa Üzlemeli Pilavı', v_grup2_id, 1, 170,
            '["pilav"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 83.3}, {"ad": "SADEYAĞ", "miktar_gram": 31.7}, {"ad": "TUZ", "miktar_gram": 0.5}, {"ad": "SU", "miktar_gram": 366.7}, {"ad": "KURU ÜZÜM", "miktar_gram": 83.3}, {"ad": "NOHUT", "miktar_gram": 36.7}, {"ad": "KUZU ETİ (KOL)", "miktar_gram": 50.0}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 56.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Urfa Üzlemeli Pilavı', null, '**Hazırlık / Mise en Place**
1. Nohudu 12 saat önceden ıslatın; kabuklarını soyup ("mükaşşer") ikiye ayırın.
2. Çekirdeksiz sarı kuru üzümü ayıklayıp yıkayın, 1 saat suda bekletip süzün.
3. Pirinci ayıklayıp yıkayın.

**Isıl İşlem**
1. Üzleme (~40 dk): Eti fındık büyüklüğünde doğrayıp kendi yağında kavurun. Nohutla birlikte su ekleyip 30 dakika iyice pişirin, suyunu çektirin. Kuru üzüm, pekmez ve sadeyağı (40 g) ekleyip kaynatın, ateşten alın.
2. Pilav (~20 dk): Sadeyağı (150 g) kızdırın; pirinci kısık ateşte şeffaflaşana kadar kavurun. Tuz ve kaynamış sıcak suyu (1,2 l) ekleyip pişirin.
3. Demleme (1-2 saat).

**Servis:** Pilavı yavaşça karıştırıp tabaklara alın; üzlemeyi pilavın üzerini örtecek şekilde serin. Zerde ile birlikte ikram edilir.

**PARALEL YAPILABİLİRLİK:** Pilav demlenirken üzleme hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~137 dk · Toplam ~170 dk (nohut ıslatma hariç)

**Kaynak:** Urfa (Şanlıurfa) Üzlemeli Pilavı, Türk Patent Coğrafi İşaret Tescil No 246 (6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Üzleme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU ÜZÜM", "ÜzÜM PEKMEZİ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pilav", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "SADEYAĞ", "TUZ", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Demleme", "sure_dakika": 90, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur -> Urfa Lebenisi (CI 320)
    select id into v_id from receteler where isletme_id is null and ad = 'Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Urfa Lebenisi') then
        raise notice 'Yeni ad zaten var, atlandi: Urfa Lebenisi';
    elsif _kopya_kullanimda_mi(v_id, 'Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Urfa Lebenisi', v_grup2_id, 1, 130,
            '["corba", "vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 62.5}, {"ad": "NOHUT", "miktar_gram": 12.5}, {"ad": "SU", "miktar_gram": 150.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 250.0}, {"ad": "TUZ", "miktar_gram": 1.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Urfa Lebenisi', null, '**Hazırlık / Mise en Place**
1. Nohut ve dövmeyi bir gece önceden ıslatıp yumuşatın.
2. Yoğurdu ayrı bir kapta tuzla çırpın.

**Isıl İşlem**
1. Pişirme (~60 dk): Dövme ve nohudun üzerine iki katı su ekleyip suyunu çekene kadar pişirin.
2. Yoğurtlama (~10 dk): Kaynamaya devam ederken çırpılmış yoğurdu ekleyin; karışım tekrar kaynama noktasına gelene kadar sürekli karıştırın.

**Servis:** Kâselere doldurup soğutun; ana yemek öncesinde soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~113 dk · Toplam ~130 dk (bir gece ıslatma hariç)

**Kaynak:** Urfa Lebenisi, Türk Patent Coğrafi İşaret Tescil No 320 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Pişirme", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY (TAM TANE)", "NOHUT", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Yoğurtlama", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YOĞURT (TAM)", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğutma", "sure_dakika": 60, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç -> Diyarbakır Ekşili Dolması (CI 1009)
    select id into v_id from receteler where isletme_id is null and ad = 'Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Diyarbakır Ekşili Dolması') then
        raise notice 'Yeni ad zaten var, atlandi: Diyarbakır Ekşili Dolması';
    elsif _kopya_kullanimda_mi(v_id, 'Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Diyarbakır Ekşili Dolması', v_grup2_id, 1, 140,
            '["dolma"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "KUZU KIYMA", "miktar_gram": 166.7}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 90.0}, {"ad": "KURU SOĞAN", "miktar_gram": 36.7}, {"ad": "MAYDANOZ", "miktar_gram": 8.3}, {"ad": "SUMAK", "miktar_gram": 26.7}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 5.0}, {"ad": "PATLICAN", "miktar_gram": 166.7}, {"ad": "KABAK", "miktar_gram": 166.7}, {"ad": "YEŞİL BİBER", "miktar_gram": 89.2}, {"ad": "DOMATES", "miktar_gram": 36.7}, {"ad": "TUZ", "miktar_gram": 3.3}, {"ad": "KARABİBER", "miktar_gram": 1.7}, {"ad": "PUL BİBER", "miktar_gram": 1.7}, {"ad": "KURU NANE", "miktar_gram": 1.7}, {"ad": "SADEYAĞ", "miktar_gram": 8.3}, {"ad": "SU", "miktar_gram": 150.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Diyarbakır Ekşili Dolması', null, '**Hazırlık / Mise en Place**
1. Tane sumağı demlenmesi için sıcak suda bekletin.
2. Patlıcanları kesip içlerini oyun, tuzlu suda bekletin. Kabakları çok ince soyup ikiye bölün, içlerini oyup hafif tuzlayarak yıkayın. Biberlerin üstten kapağını kesip çekirdeklerini çıkarın.
3. İç harç: Soğanı doğrayıp sadeyağda kavurun, baharatları ekleyin. Salça, küçük doğranmış sivri biber, kıyma, maydanoz ve pirinci ekleyip karıştırın; sumak suyundan bir miktar katın.
4. Harcı sebzelere doldurun; farklı sebzeler karşılıklı gelecek ve ağızları birbirini kapatacak şekilde tencereye yatay dizin.

**Isıl İşlem**
1. Pişirme (~55 dk): Kalan sumak suyunu ve üzerini kapatacak kadar sıcak su ekleyin; dağılmasın diye delikli dolma taşı koyun. Kaynayınca ateşi kısıp yaklaşık 50 dakika pişirin, suyunu süzün.

**Servis:** Sıcak olarak, yanında küçük bir kâsede dolma suyuyla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~80 dk · Pasif bekleme ~60 dk · Toplam ~140 dk

**Kaynak:** Diyarbakır Ekşili Dolması, Türk Patent Coğrafi İşaret Tescil No 1009 (6 kişilik).',
            '[{"sira": 1, "ad": "Sumak Demleme ve Sebze Oyma", "sure_dakika": 40, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "PİRİNÇ (HAM)", "KURU SOĞAN", "MAYDANOZ", "KONSERVE DOMATES SALÇASI", "SADEYAĞ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Doldurma ve Dizme", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 55, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "KABAK", "YEŞİL BİBER", "SUMAK", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Diyarbakır Usulü Etli Bulgur Pilavı -> Diyarbakır Duvaklı Pilavı (CI 1140)
    select id into v_id from receteler where isletme_id is null and ad = 'Diyarbakır Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Diyarbakır Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Diyarbakır Duvaklı Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Diyarbakır Duvaklı Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Diyarbakır Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Diyarbakır Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Diyarbakır Duvaklı Pilavı', v_grup2_id, 1, 75,
            '["pilav"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "KUZU KIYMA", "miktar_gram": 83.3}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 66.7}, {"ad": "BADEM (İÇ)", "miktar_gram": 33.3}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}, {"ad": "TUZ", "miktar_gram": 3.3}, {"ad": "KARABİBER", "miktar_gram": 0.8}, {"ad": "YENİBAHAR", "miktar_gram": 0.8}, {"ad": "TARÇIN", "miktar_gram": 0.8}, {"ad": "SU", "miktar_gram": 166.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Diyarbakır Duvaklı Pilavı', null, '**Hazırlık / Mise en Place**
1. Bademleri haşlayıp kabuklarını soyun ve kavurun.

**Isıl İşlem**
1. Kıyma (~25 dk): Kuzu satır kıymasını tavada yaklaşık 20 dakika kavurun; baharatları ve kavrulmuş bademleri ekleyip 5 dakika daha kavurun.
2. Pilav (~20 dk): Tereyağını eritip Karacadağ pirincini renk değiştirinceye kadar kavurun; suyu ekleyip kısık ateşte pişirin.
3. Demleme (~15 dk).

**Servis:** Pilavı servis tabağına alın, üzerine kıymalı badem karışımını ekleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~50 dk · Toplam ~75 dk

**Kaynak:** Diyarbakır Duvaklı Pilavı, Türk Patent Coğrafi İşaret Tescil No 1140 (6 kişilik).',
            '[{"sira": 1, "ad": "Badem Hazırlığı", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BADEM (İÇ)"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kıyma Kavurma", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "KARABİBER", "YENİBAHAR", "TARÇIN"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pilav", "sure_dakika": 20, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Demleme", "sure_dakika": 15, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Kavurmalı Yumurta -> Erzurum Çılbır (CI 1433)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzurum Çılbır') then
        raise notice 'Yeni ad zaten var, atlandi: Erzurum Çılbır';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzurum Çılbır', v_grup1_id, 1, 29,
            '["yumurta"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "EKMEK (BEYAZ)", "miktar_gram": 75.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 10.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 6.9}, {"ad": "TEREYAĞI", "miktar_gram": 8.75}, {"ad": "KURU SOĞAN", "miktar_gram": 37.5}, {"ad": "YEŞİL BİBER", "miktar_gram": 37.5}, {"ad": "DOMATES", "miktar_gram": 30.0}, {"ad": "SU", "miktar_gram": 200.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 50.0}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "KARABİBER", "miktar_gram": 0.8}, {"ad": "PUL BİBER", "miktar_gram": 0.65}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzurum Çılbır', null, '**Hazırlık / Mise en Place**
1. Bayat ekmeği geniş ve derin bir tabağa doğrayın.
2. Yumurtaları bir kâsede kısa süre homojen olana kadar çırpın.

**Isıl İşlem**
1. Kavurma (~10 dk): Sıvı yağı (isteğe göre tereyağıyla) orta ateşte kızdırın; halka doğranmış soğanları pembeleşinceye kadar kavurun. Küçük doğranmış yeşil biberleri, tuzu, karabiberi ve pul biberi ekleyip 2 dakika karıştırarak kavurun.
2. Pişirme (~5 dk): Kaşıkla ezilmiş salça ve küçük doğranmış domatesi ekleyip 5 dakika pişirin.
3. Yumurta (~5 dk): Suyu ekleyin; kaynayınca ateşi kısın ve çırpılmış yumurtayı azar azar, karıştırarak ekleyin. 2 dakika karıştırarak pişirin.

**Servis:** Karışımı doğranmış ekmeğin üzerine gezdirerek dökün; sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~2 dk · Toplam ~29 dk

**Kaynak:** Erzurum Cılbıra / Erzurum Çılbır, Türk Patent Coğrafi İşaret Tescil No 1433 (4 porsiyon).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AYÇİÇEK YAĞI", "TEREYAĞI", "KURU SOĞAN", "YEŞİL BİBER", "TUZ", "KARABİBER", "PUL BİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sebze Pişirme", "sure_dakika": 5, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KONSERVE BİBER SALÇASI", "DOMATES"], "yeni_su_gram": null}, {"sira": 4, "ad": "Yumurtalı Pişirme", "sure_dakika": 6, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "TAVUK YUMURTASI", "EKMEK (BEYAZ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Zeytinyağlı Pırasa -> Erzurum Çiriş Yemeği (CI 1194)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzurum Çiriş Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Erzurum Çiriş Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzurum Çiriş Yemeği', v_grup2_id, 1, 37,
            '["zeytinyagli", "vejetaryen"]'::jsonb, 'ilkbahar', 'Doğu Anadolu',
            '[{"ad": "ÇİRİŞ", "miktar_gram": 125.0}, {"ad": "BULGUR", "miktar_gram": 6.25}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 6.8}, {"ad": "KURU SOĞAN", "miktar_gram": 27.5}, {"ad": "SU", "miktar_gram": 75.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzurum Çiriş Yemeği', null, '**Hazırlık / Mise en Place**
1. Çiriş otunu ayıklayın, yıkayın ve iri doğrayın. Soğanı yemeklik doğrayın.

**Isıl İşlem**
1. Kavurma (~5 dk): Zeytinyağını ısıtıp soğanı kavurun; domates salçasını ekleyip kavurmaya devam edin.
2. Pişirme (~10 dk): Çiriş otlarını, bulguru ve tuzu ekleyin. Üzerine çıkacak kadar sıcak su ilave edip kapağı kapatın; bulgurlar yumuşayınca karabiberi ekleyip karıştırın.
3. Dinlendirme (10-15 dk).

**Servis:** Dinlendirdikten sonra servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~19 dk · Toplam ~37 dk

**Kaynak:** Erzurum Çiriş Yemeği, Türk Patent Coğrafi İşaret Tescil No 1194 (4 kişilik (etsiz)).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ZEYTİNYAĞI", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ÇİRİŞ", "BULGUR", "SU", "TUZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Dinlendirme", "sure_dakika": 12, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Etli Nohutlu Patlıcan -> Erzurum Ekşili Dolma (CI 1246)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Etli Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Etli Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzurum Ekşili Dolma') then
        raise notice 'Yeni ad zaten var, atlandi: Erzurum Ekşili Dolma';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Etli Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Etli Nohutlu Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzurum Ekşili Dolma', v_grup2_id, 1, 75,
            '["dolma"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "DANA KIYMA", "miktar_gram": 125.0}, {"ad": "SALAMURA YAPRAK", "miktar_gram": 62.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 10.0}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "KURUTULMUŞ ERIK", "miktar_gram": 62.5}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 18.75}, {"ad": "SU", "miktar_gram": 112.5}, {"ad": "KARABİBER", "miktar_gram": 1.75}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "SÜZME YOĞURT", "miktar_gram": 125.0}, {"ad": "SARIMSAK", "miktar_gram": 6.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzurum Ekşili Dolma', null, '**Hazırlık / Mise en Place**
1. Dağ eriği (salor) veya kızılcık pestilini ince kıyıp tencereye alın; 150 ml su ekleyip 10-15 dakika ısıtarak homojen eritin.
2. İç harç: Yemeklik doğranmış soğan, pirinç, dana kıyma, eritilmiş pestil, domates salçası, tuz, karabiber ve 100 ml suyu karıştırın.
3. Salamura yaprağı tuzu azalsın diye bir süre sıcak suda bekletip süzün; sert kısımlarını ayırın. Parlak yüzü dışta kalacak şekilde ortasına harç koyup sıkıca sarın. Dibine yaprak serilmiş tencereye dizin, üzerine tabak kapatın.

**Isıl İşlem**
1. Pestil eritme (10-15 dk).
2. Pişirme (~15 dk): 100 ml su ekleyip yapraklar yumuşayıncaya kadar kısık ateşte pişirin; gerekirse 200 ml sıcak su daha ekleyin.

**Servis:** Rendelenmiş sarımsağı süzme yoğurtla karıştırın; dolmaların üzerine dökerek sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~54 dk · Pasif bekleme ~21 dk · Toplam ~75 dk

**Kaynak:** Erzurum Ekşili Dolma, Türk Patent Coğrafi İşaret Tescil No 1246 (4 kişilik).',
            '[{"sira": 1, "ad": "Pestil Eritme", "sure_dakika": 12, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURUTULMUŞ ERIK"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç ve Sarma", "sure_dakika": 45, "aktif_dakika": 45, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "SALAMURA YAPRAK", "PİRİNÇ (HAM)", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["SÜZME YOĞURT", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Zeytinyağlı Kuru Fasulye -> Erzurum Patates Boranisi (CI 1641)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Zeytinyağlı Kuru Fasulye';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Zeytinyağlı Kuru Fasulye';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzurum Patates Boranisi') then
        raise notice 'Yeni ad zaten var, atlandi: Erzurum Patates Boranisi';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Zeytinyağlı Kuru Fasulye') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Zeytinyağlı Kuru Fasulye';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzurum Patates Boranisi', v_grup2_id, 1, 40,
            '["vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "PATATES", "miktar_gram": 150.0}, {"ad": "SARIMSAK", "miktar_gram": 2.9}, {"ad": "YOĞURT (TAM)", "miktar_gram": 32.1}, {"ad": "TUZ", "miktar_gram": 4.3}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "KURU NANE", "miktar_gram": 1.1}, {"ad": "PUL BİBER", "miktar_gram": 2.1}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzurum Patates Boranisi', null, '**Hazırlık / Mise en Place**
1. Yoğurt, sarımsak ve tuzu geniş bir kapta 2-3 dakika çırpın.

**Isıl İşlem**
1. Haşlama (25-30 dk): Patatesleri yıkayıp tencerede suyla haşlayın.
2. Tereyağı: Tereyağını ayrı bir tavada eritip kızdırın.
3. Ezme: Haşlanan patatesleri kabuklarından ayırıp eritilmiş tereyağının yarısıyla homojen ezin.

**Servis:** Sarımsaklı yoğurdun üzerine kalan tereyağını ekleyip ezilmiş patateslerin üzerine dökün; toz nane ve pul biber serpip servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~25 dk · Toplam ~40 dk

**Kaynak:** Erzurum Patates Boranisi, Türk Patent Coğrafi İşaret Tescil No 1641 (6-8 kişilik).',
            '[{"sira": 1, "ad": "Haşlama", "sure_dakika": 28, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATATES"], "yeni_su_gram": null}, {"sira": 2, "ad": "Ezme ve Sos", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "YOĞURT (TAM)", "SARIMSAK", "TUZ", "KURU NANE", "PUL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Kete -> Erzurum Ketesi (CI 1318)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Kete';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Kete';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzurum Ketesi') then
        raise notice 'Yeni ad zaten var, atlandi: Erzurum Ketesi';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Kete') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Kete';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzurum Ketesi', v_grup3_id, 1, 143,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 56.0}, {"ad": "TEREYAĞI", "miktar_gram": 62.0}, {"ad": "SU", "miktar_gram": 20.0}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 5.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzurum Ketesi', null, '**Hazırlık / Mise en Place**
1. İç harç: Un, tereyağı ve tuzu tencerede un kokusu gidinceye kadar ~100°C''de 15 dakika karıştırarak kavurun; oda sıcaklığına soğutun.
2. Açma için nişasta/un karışımını (1/2) hazırlayın.
3. Hamur: Su, tereyağı ve tuzu karıştırıp unu azar azar ekleyerek yoğurun; 30 dakika dinlendirin.
4. Hamurdan 50 g''lık parçalar alın; her biri için 15 g nişasta/un serpip oklavayla 1-2 mm kalınlığında, 25 cm çapında açın. Üzerini ~50 g tereyağıyla yağlayın. Kenarları ortaya katlayıp 25-30 g iç harç koyun, kare şeklinde katlayıp tepsiye dizin.

**Isıl İşlem**
1. Fırınlama (250°C, 30-45 dk): Üzerine yumurta sürüp pişirin.

**Servis:** Porsiyonda 1 kete olarak servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç kavrulup soğutulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~77 dk · Pasif bekleme ~66 dk · Toplam ~143 dk

**Kaynak:** Erzurum Ketesi, Türk Patent Coğrafi İşaret Tescil No 1318 (25 adet sini ketesi, porsiyonda 1 adet).',
            '[{"sira": 1, "ad": "İç Harç Kavurma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hamur ve Dinlendirme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma ve Katlama", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 38, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "TEREYAĞI", "SU", "BUĞDAY NİŞASTASI", "TAVUK YUMURTASI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Çorum Usulü Kavurmalı Yumurta -> Alaca Çılbır Yemeği (CI 1624)
    select id into v_id from receteler where isletme_id is null and ad = 'Çorum Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çorum Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Alaca Çılbır Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Alaca Çılbır Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Çorum Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çorum Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Alaca Çılbır Yemeği', v_grup1_id, 1, 21,
            '["yumurta", "kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "TEREYAĞI", "miktar_gram": 6.25}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 6.25}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 37.5}, {"ad": "SU", "miktar_gram": 62.5}, {"ad": "PUL BİBER", "miktar_gram": 1.25}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "DANA KIYMA", "miktar_gram": 62.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Alaca Çılbır Yemeği', null, '**Hazırlık / Mise en Place**
1. Yumurtaları bir kâsede çırpın.

**Isıl İşlem**
1. Kavurma (~8 dk): Tavada tereyağını eritip kıymayı kavurun.
2. Pişirme (~7 dk): Salça, sıcak su ve tuzu ekleyip pişirin.
3. Yumurta (~3 dk): Çırpılmış yumurtaları kaynayan karışıma ekleyin.

**Servis:** Üzerine pul biber serpip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~4 dk · Toplam ~21 dk

**Kaynak:** Alaca Çılbır Yemeği, Türk Patent Coğrafi İşaret Tescil No 1624 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "DANA KIYMA"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 7, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KONSERVE DOMATES SALÇASI", "SU", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Yumurta", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK YUMURTASI", "PUL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Çorum Usulü Zeytinyağlı Nohut -> Osmancık Yaprak İçi Yemeği (CI 1750)
    select id into v_id from receteler where isletme_id is null and ad = 'Çorum Usulü Zeytinyağlı Nohut';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çorum Usulü Zeytinyağlı Nohut';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Osmancık Yaprak İçi Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Osmancık Yaprak İçi Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Çorum Usulü Zeytinyağlı Nohut') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çorum Usulü Zeytinyağlı Nohut';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Osmancık Yaprak İçi Yemeği', v_grup2_id, 1, 33,
            '["kuru_baklagil", "vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
            '[{"ad": "SALAMURA YAPRAK", "miktar_gram": 12.5}, {"ad": "NOHUT", "miktar_gram": 5.0}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 5.0}, {"ad": "BÖRÜLCE (KURU)", "miktar_gram": 5.0}, {"ad": "BAKLA", "miktar_gram": 5.0}, {"ad": "BULGUR", "miktar_gram": 2.5}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 0.5}, {"ad": "TEREYAĞI", "miktar_gram": 1.25}, {"ad": "KURU SOĞAN", "miktar_gram": 5.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 1.4}, {"ad": "DOMATES", "miktar_gram": 5.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 1.5}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "MAYDANOZ", "miktar_gram": 0.5}, {"ad": "TAZE DEREOTU", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Osmancık Yaprak İçi Yemeği', null, '**Hazırlık / Mise en Place**
1. Nohut, mercimek ve börülceyi bir gün önceden haşlayın. Kuru baklayı değirmende öğütün.

**Isıl İşlem**
1. Bakliyat (15-20 dk): Tencerede ½ litre suyla nohut, yeşil mercimek, börülce, öğütülmüş bakla ve bulguru pişirin.
2. Sos (~8 dk): İkinci tencerede doğranmış kuru soğanı sıvı yağ ve salçayla kavurun; isteğe göre doğranmış yeşil biber ve domatesi ekleyin. ½ litre su ekleyip 5 dakika pişirin.
3. Birleştirme (5 dk): İki tencereyi birleştirip tuzlayın; 5 dakika daha pişirin. Tereyağı, kuru nane ve pul biberle hazırlanan sosu üzerine dökün. İnce doğranmış yaş nane, dereotu, maydanoz ve yaş soğanı karıştırın. Yemek az sulu ve bol salçalı olmalıdır.

**Servis:** Tuzlu suda haşlanmış taze ya da salamura asma yaprağını yanına koyun; yaprağın içi kaşıkla yemekle doldurularak elle veya kaşıkla yenir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~17 dk · Toplam ~33 dk (bir gün önceden bakliyat haşlama hariç)

**Kaynak:** Osmancık Yaprak İçi Yemeği, Türk Patent Coğrafi İşaret Tescil No 1750 (20 kişilik).',
            '[{"sira": 1, "ad": "Bakliyat Pişirme", "sure_dakika": 18, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "YEŞİL MERCİMEK", "BÖRÜLCE (KURU)", "BAKLA", "BULGUR", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Sos", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI", "KONSERVE DOMATES SALÇASI", "DOMATES", "YEŞİL BİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Birleştirme", "sure_dakika": 7, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TUZ", "TEREYAĞI", "KURU NANE", "PUL BİBER", "MAYDANOZ", "TAZE DEREOTU", "SALAMURA YAPRAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Çankırı Usulü Etli Bulgur Pilavı -> Çankırı Bütün Et (CI 1399)
    select id into v_id from receteler where isletme_id is null and ad = 'Çankırı Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çankırı Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Çankırı Bütün Et') then
        raise notice 'Yeni ad zaten var, atlandi: Çankırı Bütün Et';
    elsif _kopya_kullanimda_mi(v_id, 'Çankırı Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çankırı Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Çankırı Bütün Et', v_grup1_id, 1, 120,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KEÇİ ETİ (KOL)", "miktar_gram": 500.0}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "KİMYON", "miktar_gram": 3.0}, {"ad": "PUL BİBER", "miktar_gram": 1.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 4.0}, {"ad": "TUZ", "miktar_gram": 4.0}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}, {"ad": "SU", "miktar_gram": 150.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Çankırı Bütün Et', null, '**Hazırlık / Mise en Place**
1. Erkeç (keçi) veya kuzunun kol, incik, kaski, gerdan ve kaburga kısımlarından alınan etleri 8-10 parçaya bölün.
2. İnce doğranmış kuru soğan, tuz, pul biber, kimyon ve salçayı karıştırıp etlerin üzerine sürün. Tencereye üst üste yerleştirip ağzını kapatın; buzdolabında 8-9 saat dinlendirin.

**Isıl İşlem**
1. Kızartma (~15 dk): Başka bir tencerede tereyağını eritip etleri suyunu çekinceye kadar kızartın.
2. Pişirme (~90 dk): Sıcak su ekleyip etler yumuşayana kadar pişirin.

**Servis:** Sıcak olarak, pirinç pilavı ile servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~90 dk · Toplam ~120 dk (8-9 saat buzdolabında dinlendirme hariç)

**Kaynak:** Çankırı Bütün Et, Türk Patent Coğrafi İşaret Tescil No 1399 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEÇİ ETİ (KOL)", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 90, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "KURU SOĞAN", "KİMYON", "PUL BİBER", "KONSERVE DOMATES SALÇASI", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Sivas Usulü Zeytinyağlı Nohutlu Havuç -> Divriği Pilavı (CI 564)
    select id into v_id from receteler where isletme_id is null and ad = 'Sivas Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Sivas Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Divriği Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Divriği Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Sivas Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Sivas Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Divriği Pilavı', v_grup2_id, 1, 153,
            '["pilav"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "DANA BUT", "miktar_gram": 100.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 100.0}, {"ad": "NOHUT", "miktar_gram": 17.0}, {"ad": "KURU ÜZÜM", "miktar_gram": 15.0}, {"ad": "KURU SOĞAN", "miktar_gram": 11.0}, {"ad": "KARABİBER", "miktar_gram": 0.7}, {"ad": "YENİBAHAR", "miktar_gram": 0.7}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 4.1}, {"ad": "ET SUYU", "miktar_gram": 60.0}, {"ad": "SU", "miktar_gram": 80.0}, {"ad": "TUZ", "miktar_gram": 1.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Divriği Pilavı', null, '**Hazırlık / Mise en Place**
1. Bir gün önceden eti haşlayıp parmak büyüklüğünde didikleyin; baharatlar ve tuzla harmanlayıp dinlendirin.
2. Nohudu haşlayıp kabuklarını soyun.
3. Pirinci yaklaşık 1 saat tuzlu kaynar suda bekletin, üç kez yıkayıp süzün.

**Isıl İşlem**
1. Kavurma (~8 dk): Soğanı ince doğrayıp tencerede sıvı yağda kavurun; eti ekleyip harmanlayın ve tencerenin dibine düzgünce yayın.
2. Pişirme (~25 dk): Üzerine nohut ve yıkanmış Besni üzümünü, ardından pirinci ekleyin. 3 su bardağı et suyu ve 4 bardak su ilave edin; harlı ateşte pirinç suyunu bir miktar çekinceye kadar kaynatıp en kısık ateşte suyunu tamamen çekene kadar pişirin.
3. Demleme (~60 dk): Tereyağını pembeleştirip üzerine dökün; tencerenin ağzına bez örtüp kalın örtüyle sararak dinlendirin.

**Servis:** Tencereyi tepsiye ters çevirip servis edin; yanında üzüm hoşafı ikram edilir.

**SÜRE ÖZETİ:** Aktif işçilik ~21 dk · Pasif bekleme ~132 dk · Toplam ~153 dk (bir gün önceden et haşlama ve nohut haşlama hariç)

**Kaynak:** Divriği Pilavı / Alatlı Pilavı, Türk Patent Coğrafi İşaret Tescil No 564 (10 kişilik).',
            '[{"sira": 1, "ad": "Pirinç Bekletme", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI", "DANA BUT", "KARABİBER", "YENİBAHAR", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "NOHUT", "KURU ÜZÜM", "ET SUYU", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Tereyağı ve Demleme", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Sivas Usulü Etli Bulgur Pilavı -> Ulaş Yaprak Döneri (CI 503)
    select id into v_id from receteler where isletme_id is null and ad = 'Sivas Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Sivas Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ulaş Yaprak Döneri') then
        raise notice 'Yeni ad zaten var, atlandi: Ulaş Yaprak Döneri';
    elsif _kopya_kullanimda_mi(v_id, 'Sivas Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Sivas Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ulaş Yaprak Döneri', v_grup1_id, 1, 75,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "DANA BUT", "miktar_gram": 105.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 35.0}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 5.25}, {"ad": "KARABİBER", "miktar_gram": 0.16}, {"ad": "YENİBAHAR", "miktar_gram": 0.21}, {"ad": "KİMYON", "miktar_gram": 0.42}, {"ad": "TUZ", "miktar_gram": 1.05}, {"ad": "KURU SOĞAN", "miktar_gram": 5.25}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 1.9}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ulaş Yaprak Döneri', null, '**Hazırlık / Mise en Place**
1. Akşamdan dananın (genellikle) but kısmından sinirleri temizlenmiş etleri parçalara ayırıp ince yaprak şeklinde açın.
2. Süt, karabiber, yenibahar, kimyon, tuz, rendelenmiş soğan ve zeytinyağıyla hazırlanan sosla terbiye edip sabaha kadar bekletin.
3. Etleri döner şişine üç sıra et, bir sıra koyun kuyruk yağı olacak şekilde dizin (yağ en çok %25, tuz en çok %2).

**Isıl İşlem**
1. Pişirme: Döner şişini ocağa takıp dikey konumda yavaş yavaş çevirerek pişirin. Pişen etleri döner bıçağıyla yüzeyden ince keserek küreğe toplayın.

**Servis:** 100 g olarak; yanında pirinç ya da bulgur pilavı, pide, lavaş ve garnitürle servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk · Pasif bekleme ~30 dk · Toplam ~75 dk (bir gece terbiye hariç)

**Kaynak:** Ulaş Yaprak Döneri, Türk Patent Coğrafi İşaret Tescil No 503 (porsiyon 100 g).',
            '[{"sira": 1, "ad": "Yaprak Açma ve Terbiye", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şişe Dizme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Döner Pişirme", "sure_dakika": 45, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BUT", "KUYRUKYAĞI", "SÜT (TAM YAĞ)", "KURU SOĞAN", "ZEYTİNYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Sivas Usulü Zeytinyağlı Nohutlu Kereviz -> Ulaş Etli Pidesi (CI 502)
    select id into v_id from receteler where isletme_id is null and ad = 'Sivas Usulü Zeytinyağlı Nohutlu Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Sivas Usulü Zeytinyağlı Nohutlu Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ulaş Etli Pidesi') then
        raise notice 'Yeni ad zaten var, atlandi: Ulaş Etli Pidesi';
    elsif _kopya_kullanimda_mi(v_id, 'Sivas Usulü Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Sivas Usulü Zeytinyağlı Nohutlu Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ulaş Etli Pidesi', v_grup2_id, 1, 98,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 110.0}, {"ad": "SU", "miktar_gram": 66.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KURU MAYA", "miktar_gram": 1.0}, {"ad": "DANA KIYMA", "miktar_gram": 110.0}, {"ad": "DOMATES", "miktar_gram": 30.0}, {"ad": "KURU SOĞAN", "miktar_gram": 20.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 15.0}, {"ad": "MAYDANOZ", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ulaş Etli Pidesi', null, '**Hazırlık / Mise en Place**
1. Zeron buğdayı unu, maya, su ve tuzu yoğurarak yumuşak ve esnek bir hamur elde edin. Yaklaşık 180 g''lık toplara bölüp pasalara dizin, 1 saat mayalandırın.
2. İç harç: Dana kaburga etinden kıyma (veya kuşbaşı) hazırlayıp küp doğranmış domates, soğan, yeşil biber ve tuzla karıştırın.
3. Hamuru tezgâhta yayvan açın, iç harcı hafifçe dokunarak hamur yüzeyiyle birleştirin; kenarlarını kıvırın.

**Isıl İşlem**
1. Fırınlama (taş fırın, odun ateşi): Fırıncı küreğiyle fırına yerleştirip pişirin.

**Servis:** Üzerine doğranmış maydanoz ekleyin; sumaklı soğan salatası ve limonla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~65 dk · Toplam ~98 dk

**Kaynak:** Ulaş Etli Pidesi, Türk Patent Coğrafi İşaret Tescil No 502 (porsiyon 180 g hamur + 110 g et).',
            '[{"sira": 1, "ad": "Hamur", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Mayalanma", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Harç ve Açma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 8, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "TUZ", "KURU MAYA", "DANA KIYMA", "DOMATES", "KURU SOĞAN", "YEŞİL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Yozgat Usulü Etli Bulgur Pilavı -> Yozgat Desti Kebabı (CI 1471)
    select id into v_id from receteler where isletme_id is null and ad = 'Yozgat Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Yozgat Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Yozgat Desti Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Yozgat Desti Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Yozgat Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Yozgat Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Yozgat Desti Kebabı', v_grup1_id, 1, 180,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 250.0}, {"ad": "DOMATES", "miktar_gram": 83.3}, {"ad": "SARIMSAK", "miktar_gram": 25.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 16.7}, {"ad": "TEREYAĞI", "miktar_gram": 16.7}, {"ad": "KARABİBER", "miktar_gram": 0.8}, {"ad": "TUZ", "miktar_gram": 3.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Yozgat Desti Kebabı', null, '**Hazırlık / Mise en Place**
1. Testiye su koyup 30 dakika bekletin (yemeğin suyunu çekmesin diye), sonra boşaltın.
2. Domates, sivri biber ve sarımsağı doğrayın; kuşbaşı kuzu eti, karabiber ve tuzla karıştırıp testiye doldurun. Tereyağını en üste koyun.
3. Un, su ve tuzla hamur yapıp testinin ağzını kapatın; buhar çıksın diye ortasını delin.

**Isıl İşlem**
1. Pişirme (~2 saat): Odun ve kömürle yakılan ocak köz haline gelince testiyi közün içine gömün; buhar çıkmaya başladıktan sonra yaklaşık 2 saat pişirin.

**Servis:** Testinin ağız kısmına çekiçle bir kez vurup kırın ve servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~153 dk · Toplam ~180 dk

**Kaynak:** Yozgat Desti Kebabı, Türk Patent Coğrafi İşaret Tescil No 1471 (yaklaşık 12 kişilik).',
            '[{"sira": 1, "ad": "Testi Islatma", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Hazırlık ve Doldurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 130, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (BUT)", "DOMATES", "SARIMSAK", "YEŞİL BİBER", "TEREYAĞI", "KARABİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Yozgat Usulü Zeytinyağlı Kuru Fasulye -> Yozgat Tandır Kebabı (CI 265)
    select id into v_id from receteler where isletme_id is null and ad = 'Yozgat Usulü Zeytinyağlı Kuru Fasulye';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Yozgat Usulü Zeytinyağlı Kuru Fasulye';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Yozgat Tandır Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Yozgat Tandır Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Yozgat Usulü Zeytinyağlı Kuru Fasulye') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Yozgat Usulü Zeytinyağlı Kuru Fasulye';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Yozgat Tandır Kebabı', v_grup1_id, 1, 133,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 250.0}, {"ad": "DOMATES", "miktar_gram": 13.75}, {"ad": "YEŞİL BİBER", "miktar_gram": 62.5}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Yozgat Tandır Kebabı', null, '**Hazırlık / Mise en Place**
1. Kuzu etinin sinirlerini çıkarıp yağlarından arındırın, büyük parçalara bölün. Tuza batırıp 24 saat buzdolabında bekletin.
2. Tandırın iki kenarına meşe odunları yerleştirip yakın.

**Isıl İşlem**
1. Tandır (~1 saat): Ateş köz haline gelince etleri demir şişe batırıp tandıra verin. Yaklaşık 1 saat sonra çıkarın, bıçakla birkaç yerinden delin.
2. İkinci pişirme (25-30 dk): Tekrar tandıra verip pişirin.
3. Dinlendirme (30 dk).

**Servis:** Etleri yaprak biçiminde dilimleyip domates, maydanoz, biber, soğan ve lavaş ekmeğiyle servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~110 dk · Toplam ~133 dk (24 saat tuzda bekletme hariç)

**Kaynak:** Yozgat Tandır Kebabı, Türk Patent Coğrafi İşaret Tescil No 265 (4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Tandır", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (BUT)", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "İkinci Pişirme", "sure_dakika": 28, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Dinlendirme ve Servis", "sure_dakika": 35, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["DOMATES", "YEŞİL BİBER", "KURU SOĞAN", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Bartın Usulü Zeytinyağlı Nohutlu Havuç -> Zeytinyağlı Nohutlu Havuç (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Bartın Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bartın Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Havuç';
    elsif _kopya_kullanimda_mi(v_id, 'Bartın Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bartın Usulü Zeytinyağlı Nohutlu Havuç';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Havuç', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Ağrı Usulü Kavurmalı Yumurta -> Kavurmalı Yumurta (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Ağrı Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ağrı Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kavurmalı Yumurta') then
        raise notice 'Yeni ad zaten var, atlandi: Kavurmalı Yumurta';
    elsif _kopya_kullanimda_mi(v_id, 'Ağrı Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ağrı Usulü Kavurmalı Yumurta';
    else
        update receteler set ad = 'Kavurmalı Yumurta', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Ağrı Usulü Elmalı Ceviz Tatlısı -> Elmalı Ceviz Tatlısı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Ağrı Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ağrı Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Elmalı Ceviz Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Elmalı Ceviz Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Ağrı Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ağrı Usulü Elmalı Ceviz Tatlısı';
    else
        update receteler set ad = 'Elmalı Ceviz Tatlısı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Adana Usulü Zeytinyağlı Nohutlu Kabak -> Zeytinyağlı Nohutlu Kabak (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Adana Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Adana Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Kabak';
    elsif _kopya_kullanimda_mi(v_id, 'Adana Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Adana Usulü Zeytinyağlı Nohutlu Kabak';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Kabak', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Aydın Usulü Etli Bulgur Pilavı -> Etli Bulgur Pilavı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Aydın Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Aydın Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Bulgur Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Bulgur Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Aydın Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Aydın Usulü Etli Bulgur Pilavı';
    else
        update receteler set ad = 'Etli Bulgur Pilavı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Bingöl Usulü Zeytinyağlı Nohutlu Kereviz -> Zeytinyağlı Nohutlu Kereviz (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Bingöl Usulü Zeytinyağlı Nohutlu Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bingöl Usulü Zeytinyağlı Nohutlu Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Kereviz';
    elsif _kopya_kullanimda_mi(v_id, 'Bingöl Usulü Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bingöl Usulü Zeytinyağlı Nohutlu Kereviz';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Kereviz', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Anamur Usulü Izgara Karides -> Izgara Karides (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Anamur Usulü Izgara Karides';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Anamur Usulü Izgara Karides';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Izgara Karides') then
        raise notice 'Yeni ad zaten var, atlandi: Izgara Karides';
    elsif _kopya_kullanimda_mi(v_id, 'Anamur Usulü Izgara Karides') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Anamur Usulü Izgara Karides';
    else
        update receteler set ad = 'Izgara Karides', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa -> Zeytinyağlı Nohutlu Pırasa (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Pırasa') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Pırasa';
    elsif _kopya_kullanimda_mi(v_id, 'Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Pırasa', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Ağrı Usulü Zeytinyağlı Nohut -> Zeytinyağlı Nohut (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Ağrı Usulü Zeytinyağlı Nohut';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ağrı Usulü Zeytinyağlı Nohut';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohut') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohut';
    elsif _kopya_kullanimda_mi(v_id, 'Ağrı Usulü Zeytinyağlı Nohut') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ağrı Usulü Zeytinyağlı Nohut';
    else
        update receteler set ad = 'Zeytinyağlı Nohut', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Çanakkale Usulü Izgara Levrek -> Izgara Levrek (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Çanakkale Usulü Izgara Levrek';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çanakkale Usulü Izgara Levrek';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Izgara Levrek') then
        raise notice 'Yeni ad zaten var, atlandi: Izgara Levrek';
    elsif _kopya_kullanimda_mi(v_id, 'Çanakkale Usulü Izgara Levrek') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çanakkale Usulü Izgara Levrek';
    else
        update receteler set ad = 'Izgara Levrek', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Aksaray Usulü Etli Kabak Yemeği -> Etli Kabak Yemeği (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Aksaray Usulü Etli Kabak Yemeği';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Aksaray Usulü Etli Kabak Yemeği';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Kabak Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Kabak Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Aksaray Usulü Etli Kabak Yemeği') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Aksaray Usulü Etli Kabak Yemeği';
    else
        update receteler set ad = 'Etli Kabak Yemeği', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Ankara Usulü Etli Nohutlu Patlıcan -> Etli Nohutlu Patlıcan (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Ankara Usulü Etli Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ankara Usulü Etli Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Nohutlu Patlıcan') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Nohutlu Patlıcan';
    elsif _kopya_kullanimda_mi(v_id, 'Ankara Usulü Etli Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ankara Usulü Etli Nohutlu Patlıcan';
    else
        update receteler set ad = 'Etli Nohutlu Patlıcan', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Artvin Usulü Zeytinyağlı Kuru Fasulye -> Zeytinyağlı Kuru Fasulye (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Artvin Usulü Zeytinyağlı Kuru Fasulye';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Artvin Usulü Zeytinyağlı Kuru Fasulye';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Kuru Fasulye') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Kuru Fasulye';
    elsif _kopya_kullanimda_mi(v_id, 'Artvin Usulü Zeytinyağlı Kuru Fasulye') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Artvin Usulü Zeytinyağlı Kuru Fasulye';
    else
        update receteler set ad = 'Zeytinyağlı Kuru Fasulye', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Elazığ Usulü Kayısılı Komposto -> Kayısılı Komposto (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Elazığ Usulü Kayısılı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Elazığ Usulü Kayısılı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kayısılı Komposto') then
        raise notice 'Yeni ad zaten var, atlandi: Kayısılı Komposto';
    elsif _kopya_kullanimda_mi(v_id, 'Elazığ Usulü Kayısılı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Elazığ Usulü Kayısılı Komposto';
    else
        update receteler set ad = 'Kayısılı Komposto', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Adana Usulü Izgara Tavuk Kanat -> Izgara Tavuk Kanat (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Adana Usulü Izgara Tavuk Kanat';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Adana Usulü Izgara Tavuk Kanat';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Izgara Tavuk Kanat') then
        raise notice 'Yeni ad zaten var, atlandi: Izgara Tavuk Kanat';
    elsif _kopya_kullanimda_mi(v_id, 'Adana Usulü Izgara Tavuk Kanat') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Adana Usulü Izgara Tavuk Kanat';
    else
        update receteler set ad = 'Izgara Tavuk Kanat', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Adana Usulü Nohutlu Kavurma -> Nohutlu Kavurma (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Adana Usulü Nohutlu Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Adana Usulü Nohutlu Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Nohutlu Kavurma') then
        raise notice 'Yeni ad zaten var, atlandi: Nohutlu Kavurma';
    elsif _kopya_kullanimda_mi(v_id, 'Adana Usulü Nohutlu Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Adana Usulü Nohutlu Kavurma';
    else
        update receteler set ad = 'Nohutlu Kavurma', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Afyon Usulü Kaymaklı Bal Tabağı -> Kaymaklı Bal Tabağı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Afyon Usulü Kaymaklı Bal Tabağı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Afyon Usulü Kaymaklı Bal Tabağı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kaymaklı Bal Tabağı') then
        raise notice 'Yeni ad zaten var, atlandi: Kaymaklı Bal Tabağı';
    elsif _kopya_kullanimda_mi(v_id, 'Afyon Usulü Kaymaklı Bal Tabağı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Afyon Usulü Kaymaklı Bal Tabağı';
    else
        update receteler set ad = 'Kaymaklı Bal Tabağı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan -> Zeytinyağlı Nohutlu Patlıcan (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Patlıcan') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Patlıcan';
    elsif _kopya_kullanimda_mi(v_id, 'Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Patlıcan', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Ankara Usulü Zeytinyağlı Nohutlu Bamya -> Zeytinyağlı Nohutlu Bamya (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Ankara Usulü Zeytinyağlı Nohutlu Bamya';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ankara Usulü Zeytinyağlı Nohutlu Bamya';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Bamya') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Bamya';
    elsif _kopya_kullanimda_mi(v_id, 'Ankara Usulü Zeytinyağlı Nohutlu Bamya') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ankara Usulü Zeytinyağlı Nohutlu Bamya';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Bamya', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Artvin Usulü Etli Lahana -> Etli Lahana (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Artvin Usulü Etli Lahana';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Artvin Usulü Etli Lahana';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Lahana') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Lahana';
    elsif _kopya_kullanimda_mi(v_id, 'Artvin Usulü Etli Lahana') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Artvin Usulü Etli Lahana';
    else
        update receteler set ad = 'Etli Lahana', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Batman Usulü Etli Nohutlu Bulgur -> Etli Nohutlu Bulgur (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Batman Usulü Etli Nohutlu Bulgur';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Batman Usulü Etli Nohutlu Bulgur';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Nohutlu Bulgur') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Nohutlu Bulgur';
    elsif _kopya_kullanimda_mi(v_id, 'Batman Usulü Etli Nohutlu Bulgur') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Batman Usulü Etli Nohutlu Bulgur';
    else
        update receteler set ad = 'Etli Nohutlu Bulgur', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Kuşadası Usulü Elmalı Komposto -> Elmalı Komposto (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Kuşadası Usulü Elmalı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kuşadası Usulü Elmalı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Elmalı Komposto') then
        raise notice 'Yeni ad zaten var, atlandi: Elmalı Komposto';
    elsif _kopya_kullanimda_mi(v_id, 'Kuşadası Usulü Elmalı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kuşadası Usulü Elmalı Komposto';
    else
        update receteler set ad = 'Elmalı Komposto', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Adana Usulü Zeytinyağlı Biberli Patlıcan -> Zeytinyağlı Biberli Patlıcan (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Adana Usulü Zeytinyağlı Biberli Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Adana Usulü Zeytinyağlı Biberli Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Biberli Patlıcan') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Biberli Patlıcan';
    elsif _kopya_kullanimda_mi(v_id, 'Adana Usulü Zeytinyağlı Biberli Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Adana Usulü Zeytinyağlı Biberli Patlıcan';
    else
        update receteler set ad = 'Zeytinyağlı Biberli Patlıcan', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Alanya Usulü Portakallı Zeytinyağlı Havuç -> Portakallı Zeytinyağlı Havuç (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Alanya Usulü Portakallı Zeytinyağlı Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Alanya Usulü Portakallı Zeytinyağlı Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Portakallı Zeytinyağlı Havuç') then
        raise notice 'Yeni ad zaten var, atlandi: Portakallı Zeytinyağlı Havuç';
    elsif _kopya_kullanimda_mi(v_id, 'Alanya Usulü Portakallı Zeytinyağlı Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Alanya Usulü Portakallı Zeytinyağlı Havuç';
    else
        update receteler set ad = 'Portakallı Zeytinyağlı Havuç', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Antalya Usulü Zeytinyağlı Nohutlu Bakla -> Zeytinyağlı Nohutlu Bakla (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Antalya Usulü Zeytinyağlı Nohutlu Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Antalya Usulü Zeytinyağlı Nohutlu Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Nohutlu Bakla') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Nohutlu Bakla';
    elsif _kopya_kullanimda_mi(v_id, 'Antalya Usulü Zeytinyağlı Nohutlu Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Antalya Usulü Zeytinyağlı Nohutlu Bakla';
    else
        update receteler set ad = 'Zeytinyağlı Nohutlu Bakla', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Ardahan Usulü Kaşarlı Kete -> Kaşarlı Kete (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Ardahan Usulü Kaşarlı Kete';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ardahan Usulü Kaşarlı Kete';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kaşarlı Kete') then
        raise notice 'Yeni ad zaten var, atlandi: Kaşarlı Kete';
    elsif _kopya_kullanimda_mi(v_id, 'Ardahan Usulü Kaşarlı Kete') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ardahan Usulü Kaşarlı Kete';
    else
        update receteler set ad = 'Kaşarlı Kete', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Artvin Usulü Cevizli Bal Tatlısı -> Cevizli Bal Tatlısı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Artvin Usulü Cevizli Bal Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Artvin Usulü Cevizli Bal Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Cevizli Bal Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Cevizli Bal Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Artvin Usulü Cevizli Bal Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Artvin Usulü Cevizli Bal Tatlısı';
    else
        update receteler set ad = 'Cevizli Bal Tatlısı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Bingöl Usulü Kuzu Kavurma -> Kuzu Kavurma (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Bingöl Usulü Kuzu Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Bingöl Usulü Kuzu Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kuzu Kavurma') then
        raise notice 'Yeni ad zaten var, atlandi: Kuzu Kavurma';
    elsif _kopya_kullanimda_mi(v_id, 'Bingöl Usulü Kuzu Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Bingöl Usulü Kuzu Kavurma';
    else
        update receteler set ad = 'Kuzu Kavurma', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Çanakkale Usulü Etli Enginar -> Etli Enginar (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Çanakkale Usulü Etli Enginar';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çanakkale Usulü Etli Enginar';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Enginar') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Enginar';
    elsif _kopya_kullanimda_mi(v_id, 'Çanakkale Usulü Etli Enginar') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çanakkale Usulü Etli Enginar';
    else
        update receteler set ad = 'Etli Enginar', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Çorum Usulü Nohutlu Tavuk Sote -> Nohutlu Tavuk Sote (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Çorum Usulü Nohutlu Tavuk Sote';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çorum Usulü Nohutlu Tavuk Sote';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Nohutlu Tavuk Sote') then
        raise notice 'Yeni ad zaten var, atlandi: Nohutlu Tavuk Sote';
    elsif _kopya_kullanimda_mi(v_id, 'Çorum Usulü Nohutlu Tavuk Sote') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çorum Usulü Nohutlu Tavuk Sote';
    else
        update receteler set ad = 'Nohutlu Tavuk Sote', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Edirne Usulü Kirazlı Komposto -> Kirazlı Komposto (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Edirne Usulü Kirazlı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Edirne Usulü Kirazlı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kirazlı Komposto') then
        raise notice 'Yeni ad zaten var, atlandi: Kirazlı Komposto';
    elsif _kopya_kullanimda_mi(v_id, 'Edirne Usulü Kirazlı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Edirne Usulü Kirazlı Komposto';
    else
        update receteler set ad = 'Kirazlı Komposto', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Erzurum Usulü Etli Nohutlu Kavurma -> Etli Nohutlu Kavurma (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzurum Usulü Etli Nohutlu Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzurum Usulü Etli Nohutlu Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Nohutlu Kavurma') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Nohutlu Kavurma';
    elsif _kopya_kullanimda_mi(v_id, 'Erzurum Usulü Etli Nohutlu Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzurum Usulü Etli Nohutlu Kavurma';
    else
        update receteler set ad = 'Etli Nohutlu Kavurma', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Giresun Usulü Elmalı Fındıklı Tatlı -> Elmalı Fındıklı Tatlı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Giresun Usulü Elmalı Fındıklı Tatlı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Giresun Usulü Elmalı Fındıklı Tatlı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Elmalı Fındıklı Tatlı') then
        raise notice 'Yeni ad zaten var, atlandi: Elmalı Fındıklı Tatlı';
    elsif _kopya_kullanimda_mi(v_id, 'Giresun Usulü Elmalı Fındıklı Tatlı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Giresun Usulü Elmalı Fındıklı Tatlı';
    else
        update receteler set ad = 'Elmalı Fındıklı Tatlı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- İstanbul Usulü Kirazlı Yoğurt Tatlısı -> Kirazlı Yoğurt Tatlısı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'İstanbul Usulü Kirazlı Yoğurt Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: İstanbul Usulü Kirazlı Yoğurt Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kirazlı Yoğurt Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Kirazlı Yoğurt Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'İstanbul Usulü Kirazlı Yoğurt Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: İstanbul Usulü Kirazlı Yoğurt Tatlısı';
    else
        update receteler set ad = 'Kirazlı Yoğurt Tatlısı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- İstanbul Usulü Zeytinyağlı Enginar Turşusu -> Zeytinyağlı Enginar Turşusu (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'İstanbul Usulü Zeytinyağlı Enginar Turşusu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: İstanbul Usulü Zeytinyağlı Enginar Turşusu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Enginar Turşusu') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Enginar Turşusu';
    elsif _kopya_kullanimda_mi(v_id, 'İstanbul Usulü Zeytinyağlı Enginar Turşusu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: İstanbul Usulü Zeytinyağlı Enginar Turşusu';
    else
        update receteler set ad = 'Zeytinyağlı Enginar Turşusu', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- İzmir Usulü Etli Bamya -> Etli Bamya (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'İzmir Usulü Etli Bamya';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: İzmir Usulü Etli Bamya';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Etli Bamya') then
        raise notice 'Yeni ad zaten var, atlandi: Etli Bamya';
    elsif _kopya_kullanimda_mi(v_id, 'İzmir Usulü Etli Bamya') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: İzmir Usulü Etli Bamya';
    else
        update receteler set ad = 'Etli Bamya', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Kahramanmaraş Usulü Zeytinyağlı Patlıcan -> Zeytinyağlı Patlıcan (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Kahramanmaraş Usulü Zeytinyağlı Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kahramanmaraş Usulü Zeytinyağlı Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Patlıcan') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Patlıcan';
    elsif _kopya_kullanimda_mi(v_id, 'Kahramanmaraş Usulü Zeytinyağlı Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kahramanmaraş Usulü Zeytinyağlı Patlıcan';
    else
        update receteler set ad = 'Zeytinyağlı Patlıcan', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Kilis Usulü Zeytinyağlı Biberli Bulgur -> Zeytinyağlı Biberli Bulgur (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Kilis Usulü Zeytinyağlı Biberli Bulgur';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kilis Usulü Zeytinyağlı Biberli Bulgur';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Biberli Bulgur') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Biberli Bulgur';
    elsif _kopya_kullanimda_mi(v_id, 'Kilis Usulü Zeytinyağlı Biberli Bulgur') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kilis Usulü Zeytinyağlı Biberli Bulgur';
    else
        update receteler set ad = 'Zeytinyağlı Biberli Bulgur', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Kırklareli Usulü Elmalı Tatlı -> Elmalı Tatlı (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırklareli Usulü Elmalı Tatlı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırklareli Usulü Elmalı Tatlı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Elmalı Tatlı') then
        raise notice 'Yeni ad zaten var, atlandi: Elmalı Tatlı';
    elsif _kopya_kullanimda_mi(v_id, 'Kırklareli Usulü Elmalı Tatlı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırklareli Usulü Elmalı Tatlı';
    else
        update receteler set ad = 'Elmalı Tatlı', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Kırşehir Usulü Nohutlu Yahni -> Nohutlu Yahni (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırşehir Usulü Nohutlu Yahni';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırşehir Usulü Nohutlu Yahni';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Nohutlu Yahni') then
        raise notice 'Yeni ad zaten var, atlandi: Nohutlu Yahni';
    elsif _kopya_kullanimda_mi(v_id, 'Kırşehir Usulü Nohutlu Yahni') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırşehir Usulü Nohutlu Yahni';
    else
        update receteler set ad = 'Nohutlu Yahni', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    -- Kumluca Usulü Zeytinyağlı Kabak -> Zeytinyağlı Kabak (genel temsilci; malzeme ve talimat ayni kalir)
    select id into v_id from receteler where isletme_id is null and ad = 'Kumluca Usulü Zeytinyağlı Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kumluca Usulü Zeytinyağlı Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Zeytinyağlı Kabak') then
        raise notice 'Yeni ad zaten var, atlandi: Zeytinyağlı Kabak';
    elsif _kopya_kullanimda_mi(v_id, 'Kumluca Usulü Zeytinyağlı Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kumluca Usulü Zeytinyağlı Kabak';
    else
        update receteler set ad = 'Zeytinyağlı Kabak', bolge = 'Genel' where id = v_id;
        v_degisen := v_degisen + 1;
    end if;

    raise notice 'Degisen tarif sayisi: %', v_degisen;
end $$;

drop function _kopya_kullanimda_mi(uuid, text);

commit;

-- 4) DOGRULAMA (tek sonuc tablosu): her satir icin durum. Ozet satiri en ustte.
with beklenen(eski_ad, yeni_ad, beklenen_malzeme, beklenen_asama) as (values
    ('Anamur Usulü Zeytinyağlı Bakla', 'Anamur Batırığı', 16, 3),
    ('Ankara Usulü Etli Kavurma (Kimyonlu)', 'Kazan Kavurması', 4, 3),
    ('Ankara Usulü Zeytinyağlı Pırasa', 'Beypazarı Dolması', 15, 3),
    ('Balıkesir Usulü Etli Kavurma', 'Balıkesir Etli Çorba', 14, 5),
    ('Balıkesir Usulü Kavurmalı Yumurta', 'Balıkesir Düğün Çorbası', 15, 6),
    ('Bayburt Usulü Etli Kavurma', 'Bayburt Ekşi Lahana', 8, 3),
    ('Bayburt Usulü Zeytinyağlı Nohutlu Havuç', 'Bayburt Yalancı Dolma', 10, 4),
    ('Bayburt Usulü Kavurmalı Yumurta', 'Bayburt Lor Dolması', 8, 4),
    ('Bayburt Usulü Zeytinyağlı Nohut', 'Bayburt Kara Pancar Yemeği', 10, 3),
    ('Bitlis Usulü Zeytinyağlı Nohutlu Havuç', 'Bitlis Katıklı Dolma', 14, 3),
    ('Bitlis Usulü Zeytinyağlı Semizotu', 'Bitlis Ciğer Taplaması', 13, 3),
    ('Burdur Usulü Zeytinyağlı Nohutlu Havuç', 'Burdur Şiş Köftesi', 3, 4),
    ('Bursa Usulü Etli Kavurma (Kimyonlu)', 'İnegöl Büryanı', 8, 6),
    ('Bursa Usulü Etli Nohutlu Kavurma', 'Bursa Pideli Köfte', 10, 6),
    ('Bursa Usulü Zeytinyağlı Kereviz', 'Bursa Dede Çorbası', 9, 6),
    ('Datça Usulü Izgara Karides', 'Bodrum Çökertme Kebabı', 16, 5),
    ('Fethiye Usulü Izgara Karides', 'Muğla Sulu Kebabı', 4, 4),
    ('Muğla Usulü Zeytinyağlı Nohutlu Havuç', 'Milas Vekilharcı', 14, 5),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz', 'Kilis Şıhılmahşe', 14, 5),
    ('Kilis Usulü Zeytinyağlı Nohutlu Pırasa', 'Kübbülmişviyye', 13, 5),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'Kilis Ekşili Kebabı', 14, 5),
    ('Konya Usulü Zeytinyağlı Nohutlu Kabak', 'Konya Ekşili Kabak', 10, 2),
    ('Konya Usulü Zeytinyağlı Pırasa', 'Konya Kuru Kabak Sarması', 15, 3),
    ('Konya Usulü Etli Kabak Yemeği', 'Konya Patlıcan Tiridi', 14, 4),
    ('Konya Usulü Zeytinyağlı Enginar', 'Konya Tiridi', 12, 3),
    ('Konya Usulü Etli Nohutlu Yahni', 'Konya Çirli', 12, 6),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', 'Gaziantep Kabaklama', 14, 4),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa', 'Gaziantep Pirpirim Aşı', 15, 5),
    ('Hatay Usulü Zeytinyağlı Nohutlu Havuç', 'Hatay Adesiye Yemeği', 12, 2),
    ('Hatay Usulü Zeytinyağlı Enginar', 'Antakya Zılk Sarması', 15, 4),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'Kayseri Fırın Ağzı Kebabı', 8, 2),
    ('Kayseri Usulü Izgara Tavuk Kanat', 'Kayseri Tepsi Mantısı', 13, 6),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç', 'Malatya Tevek Yaprağı Sarması', 13, 3),
    ('Malatya Usulü Zeytinyağlı Nohutlu Kabak', 'Malatya Ispanaklı Ekşili Köftesi', 10, 5),
    ('Malatya Usulü Etli Bulgur Pilavı', 'Malatya Simit Pilavı', 7, 4),
    ('Mardin Usulü Zeytinyağlı Nohutlu Havuç', 'Mardin Alluciye', 6, 2),
    ('Mardin Usulü Etli Kavurma (Baharatlı)', 'Mardin Kebabı', 5, 4),
    ('Mardin Usulü Etli Bulgur Pilavı', 'Mardin İncasiyye', 8, 4),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'Mardin Irok', 13, 4),
    ('Mardin Usulü Zeytinyağlı Biberli Patlıcan', 'Mardin Harire', 7, 2),
    ('Ordu Usulü Zeytinyağlı Kereviz', 'Ordu Zeytinyağlı Karalahana Sarması', 11, 4),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'Ordu İçli Tava', 12, 4),
    ('Ordu Usulü Zeytinyağlı Taze Fasulye', 'Ordu Fırın Fasulyesi Kavurması', 6, 2),
    ('Ordu Usulü Elmalı Fındıklı Tatlı', 'Ordu Fındıklı Burma Tatlısı', 13, 5),
    ('Ordu Usulü Etli Lahana', 'Ordu Galdirik Kavurması', 7, 3),
    ('Van Usulü Zeytinyağlı Nohutlu Havuç', 'Van Erişte Aşı', 11, 4),
    ('Van Usulü Elmalı Ceviz Tatlısı', 'Van Pastası', 8, 3),
    ('Van Usulü Balı ile Kaymaklı Tatlı', 'Cembeli Tatlı', 4, 3),
    ('Van Usulü Balı ile Ceviz Tabağı', 'Murtuğa', 4, 2),
    ('Van Usulü Etli Nohutlu Kavurma', 'Van Tava Yemeği', 11, 2),
    ('Van Usulü Etli Kavurma (Kimyonlu)', 'Van Acem Köftesi', 15, 3),
    ('Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', 'Urfa Su Kabağı Yemeği', 8, 3),
    ('Şanlıurfa Usulü Etli Bulgur Pilavı', 'Urfa Üzlemeli Pilavı', 8, 4),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'Urfa Lebenisi', 5, 3),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç', 'Diyarbakır Ekşili Dolması', 16, 4),
    ('Diyarbakır Usulü Etli Bulgur Pilavı', 'Diyarbakır Duvaklı Pilavı', 9, 4),
    ('Erzurum Usulü Kavurmalı Yumurta', 'Erzurum Çılbır', 12, 4),
    ('Erzurum Usulü Zeytinyağlı Pırasa', 'Erzurum Çiriş Yemeği', 8, 4),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'Erzurum Ekşili Dolma', 11, 4),
    ('Erzurum Usulü Zeytinyağlı Kuru Fasulye', 'Erzurum Patates Boranisi', 7, 2),
    ('Erzurum Usulü Kete', 'Erzurum Ketesi', 6, 4),
    ('Çorum Usulü Kavurmalı Yumurta', 'Alaca Çılbır Yemeği', 7, 4),
    ('Çorum Usulü Zeytinyağlı Nohut', 'Osmancık Yaprak İçi Yemeği', 18, 3),
    ('Çankırı Usulü Etli Bulgur Pilavı', 'Çankırı Bütün Et', 8, 3),
    ('Sivas Usulü Zeytinyağlı Nohutlu Havuç', 'Divriği Pilavı', 12, 4),
    ('Sivas Usulü Etli Bulgur Pilavı', 'Ulaş Yaprak Döneri', 9, 3),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kereviz', 'Ulaş Etli Pidesi', 9, 4),
    ('Yozgat Usulü Etli Bulgur Pilavı', 'Yozgat Desti Kebabı', 7, 3),
    ('Yozgat Usulü Zeytinyağlı Kuru Fasulye', 'Yozgat Tandır Kebabı', 6, 4),
    ('Bartın Usulü Zeytinyağlı Nohutlu Havuç', 'Zeytinyağlı Nohutlu Havuç', null::int, null::int),
    ('Ağrı Usulü Kavurmalı Yumurta', 'Kavurmalı Yumurta', null::int, null::int),
    ('Ağrı Usulü Elmalı Ceviz Tatlısı', 'Elmalı Ceviz Tatlısı', null::int, null::int),
    ('Adana Usulü Zeytinyağlı Nohutlu Kabak', 'Zeytinyağlı Nohutlu Kabak', null::int, null::int),
    ('Aydın Usulü Etli Bulgur Pilavı', 'Etli Bulgur Pilavı', null::int, null::int),
    ('Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', 'Zeytinyağlı Nohutlu Kereviz', null::int, null::int),
    ('Anamur Usulü Izgara Karides', 'Izgara Karides', null::int, null::int),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', 'Zeytinyağlı Nohutlu Pırasa', null::int, null::int),
    ('Ağrı Usulü Zeytinyağlı Nohut', 'Zeytinyağlı Nohut', null::int, null::int),
    ('Çanakkale Usulü Izgara Levrek', 'Izgara Levrek', null::int, null::int),
    ('Aksaray Usulü Etli Kabak Yemeği', 'Etli Kabak Yemeği', null::int, null::int),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'Etli Nohutlu Patlıcan', null::int, null::int),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye', 'Zeytinyağlı Kuru Fasulye', null::int, null::int),
    ('Elazığ Usulü Kayısılı Komposto', 'Kayısılı Komposto', null::int, null::int),
    ('Adana Usulü Izgara Tavuk Kanat', 'Izgara Tavuk Kanat', null::int, null::int),
    ('Adana Usulü Nohutlu Kavurma', 'Nohutlu Kavurma', null::int, null::int),
    ('Afyon Usulü Kaymaklı Bal Tabağı', 'Kaymaklı Bal Tabağı', null::int, null::int),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'Zeytinyağlı Nohutlu Patlıcan', null::int, null::int),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'Zeytinyağlı Nohutlu Bamya', null::int, null::int),
    ('Artvin Usulü Etli Lahana', 'Etli Lahana', null::int, null::int),
    ('Batman Usulü Etli Nohutlu Bulgur', 'Etli Nohutlu Bulgur', null::int, null::int),
    ('Kuşadası Usulü Elmalı Komposto', 'Elmalı Komposto', null::int, null::int),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'Zeytinyağlı Biberli Patlıcan', null::int, null::int),
    ('Alanya Usulü Portakallı Zeytinyağlı Havuç', 'Portakallı Zeytinyağlı Havuç', null::int, null::int),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla', 'Zeytinyağlı Nohutlu Bakla', null::int, null::int),
    ('Ardahan Usulü Kaşarlı Kete', 'Kaşarlı Kete', null::int, null::int),
    ('Artvin Usulü Cevizli Bal Tatlısı', 'Cevizli Bal Tatlısı', null::int, null::int),
    ('Bingöl Usulü Kuzu Kavurma', 'Kuzu Kavurma', null::int, null::int),
    ('Çanakkale Usulü Etli Enginar', 'Etli Enginar', null::int, null::int),
    ('Çorum Usulü Nohutlu Tavuk Sote', 'Nohutlu Tavuk Sote', null::int, null::int),
    ('Edirne Usulü Kirazlı Komposto', 'Kirazlı Komposto', null::int, null::int),
    ('Erzurum Usulü Etli Nohutlu Kavurma', 'Etli Nohutlu Kavurma', null::int, null::int),
    ('Giresun Usulü Elmalı Fındıklı Tatlı', 'Elmalı Fındıklı Tatlı', null::int, null::int),
    ('İstanbul Usulü Kirazlı Yoğurt Tatlısı', 'Kirazlı Yoğurt Tatlısı', null::int, null::int),
    ('İstanbul Usulü Zeytinyağlı Enginar Turşusu', 'Zeytinyağlı Enginar Turşusu', null::int, null::int),
    ('İzmir Usulü Etli Bamya', 'Etli Bamya', null::int, null::int),
    ('Kahramanmaraş Usulü Zeytinyağlı Patlıcan', 'Zeytinyağlı Patlıcan', null::int, null::int),
    ('Kilis Usulü Zeytinyağlı Biberli Bulgur', 'Zeytinyağlı Biberli Bulgur', null::int, null::int),
    ('Kırklareli Usulü Elmalı Tatlı', 'Elmalı Tatlı', null::int, null::int),
    ('Kırşehir Usulü Nohutlu Yahni', 'Nohutlu Yahni', null::int, null::int),
    ('Kumluca Usulü Zeytinyağlı Kabak', 'Zeytinyağlı Kabak', null::int, null::int)
), sonuc as (
select b.yeni_ad,
       case when r.id is not null and (b.beklenen_malzeme is null or
                 ((select count(*) from recete_malzemeleri rm where rm.recete_id = r.id) = b.beklenen_malzeme
                  and (select count(*) from recete_asamalari ra where ra.recete_id = r.id) = b.beklenen_asama))
                 then 'TAMAM'
            when r.id is not null then 'HATA: malzeme/asama sayisi tutmuyor'
            when (select count(*) from receteler r2 where r2.isletme_id is null and r2.ad = b.eski_ad) > 0
                 then 'ATLANDI: kopya bir menude kullaniliyor'
            else 'HATA: ne eski ne yeni var' end as durum,
       (select count(*) from receteler r where r.isletme_id is null and r.ad = b.eski_ad) as eski_kalan,
       r.mevsim_etiketi, r.hazirlik_dakika,
       (select count(*) from recete_malzemeleri rm where rm.recete_id = r.id) as malzeme,
       b.beklenen_malzeme,
       (select count(*) from recete_asamalari ra where ra.recete_id = r.id) as asama,
       b.beklenen_asama,
       (select round(sum(rm.miktar_gram), 1) from recete_malzemeleri rm where rm.recete_id = r.id) as porsiyon_cig_gram,
       (b.beklenen_malzeme is null or r.hazirlik_talimati like '%Tescil No%') as kaynak_yazili
from beklenen b
left join receteler r on r.isletme_id is null and r.ad = b.yeni_ad
)
select '_OZET' as yeni_ad,
       count(*) filter (where durum = 'TAMAM') || ' TAMAM / ' || count(*) filter (where durum like 'ATLANDI%')
         || ' ATLANDI / ' || count(*) filter (where durum like 'HATA%') || ' HATA / toplam ' || count(*) as durum,
       null::bigint as eski_kalan, null::text as mevsim_etiketi, null::int as hazirlik_dakika, null::bigint as malzeme,
       null::int as beklenen_malzeme, null::bigint as asama, null::int as beklenen_asama, null::numeric as porsiyon_cig_gram,
       null::boolean as kaynak_yazili
from sonuc
union all
(select * from sonuc order by (durum = 'TAMAM'), yeni_ad);
