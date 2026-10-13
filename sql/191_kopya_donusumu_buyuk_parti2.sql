-- 191_kopya_donusumu_buyuk_parti2.sql
-- YUZ KOPYA DUZELTME, BUYUK PARTI (parti 5: 80 donusum) - 13 Ekim 2026
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
    from unnest(array['AYÇİÇEK YAĞI', 'BADEM (İÇ)', 'BAL', 'BIRAKIN YUMURTA SARISI', 'BULGUR', 'BUĞDAY (TAM TANE)', 'BUĞDAY NİŞASTASI', 'BUĞDAY UNU', 'BÖRÜLCE (KURU)', 'CEVİZ (İÇ)', 'DANA BUT', 'DANA KIYMA', 'DANA KOL', 'DOMATES', 'DONYAĞI', 'EKMEK (BEYAZ)', 'ERİK', 'ET SUYU', 'FETA PEYNİRİ', 'FINDIK (İÇ)', 'HAŞHAŞ', 'ISPANAK', 'KABAK', 'KABARTMA TOZU', 'KADAYIF', 'KARABİBER', 'KARBONAT (YEM. SODA)', 'KEKİK', 'KEÇİ ETİ (BUT)', 'KEÇİ ETİ (KOL)', 'KEÇİ KIYMA', 'KIRMIZI BİBER', 'KIZILCIK', 'KONSERVE BİBER SALÇASI', 'KONSERVE DOMATES SALÇASI', 'KONSERVE TURŞU', 'KOYUN ETİ (SIRT)', 'KOYUN KIYMA', 'KURU FASULYE', 'KURU KAYISI', 'KURU MAYA', 'KURU NANE', 'KURU SOĞAN', 'KURUTULMUŞ ERIK', 'KUYRUKYAĞI', 'KUZU ETİ (BUT)', 'KUZU ETİ (KOL)', 'KUZU ETİ (SIRT)', 'KUZU KIYMA', 'KUZU PİRZOLA', 'KUŞ ÜZÜMÜ', 'KİMYON', 'LABADA', 'LAHANA', 'LAVAŞ', 'LOR PEYNİRİ', 'LİMON SUYU', 'MAHLEP', 'MAKARNA', 'MANTAR', 'MARGARİN', 'MARUL', 'MAYDANOZ', 'MISIR NİŞASTASI', 'MISIR UNU', 'NOHUT', 'PALAMUT', 'PANCAR', 'PATLICAN', 'PUL BİBER', 'PİDE', 'PİRİNÇ (HAM)', 'PİRİNÇ UNU', 'SADEYAĞ', 'SARIMSAK', 'SU', 'SUMAK', 'SUSAM', 'SÜT (TAM YAĞ)', 'SÜZME YOĞURT', 'SİRKE', 'TAHİN', 'TARÇIN', 'TATLIKA KIRMIZI BİBER', 'TAVUK BUT', 'TAVUK BÜTÜN', 'TAVUK GÖĞÜS', 'TAVUK SUYU', 'TAVUK YUMURTASI', 'TAZE DEREOTU', 'TAZE NANE', 'TAZE SOĞAN', 'TEREYAĞI', 'TOZ ŞEKER', 'TUZ', 'VANİLİN', 'YENİBAHAR', 'YENİLEBİLİR SAKATAT (DANA AKCİĞER)', 'YENİLEBİLİR SAKATAT (DANA DİL)', 'YENİLEBİLİR SAKATAT (DANA KALP)', 'YENİLEBİLİR SAKATAT (DANA KARACİĞER)', 'YENİLEBİLİR SAKATAT (DANA İŞKEMBE)', 'YEŞİL BİBER', 'YEŞİL MERCİMEK', 'YOĞURT (TAM)', 'YUFKA', 'ZERDEÇAL', 'ZEYTİNYAĞI', 'ÇAM FISTIĞI', 'ÇÖKELEK (ÇORUM)', 'ÇÖREKOTU', 'ÜZÜM', 'ÜzÜM PEKMEZİ', 'İNCE BULGUR', 'İRMİK']::text[]) as a
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

    -- Giresun Usulü Etli Kavurma -> Alucra Oğlak Kebabı (CI 582)
    select id into v_id from receteler where isletme_id is null and ad = 'Giresun Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Giresun Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Alucra Oğlak Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Alucra Oğlak Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Giresun Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Giresun Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Alucra Oğlak Kebabı', v_grup1_id, 1, 270,
            '["kirmizi_et"]'::jsonb, 'sonbahar', 'Karadeniz',
            '[{"ad": "KEÇİ ETİ (BUT)", "miktar_gram": 250.0}, {"ad": "TUZ", "miktar_gram": 3.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Alucra Oğlak Kebabı', null, '**Hazırlık / Mise en Place**
1. Temmuz başından ekim sonuna kadar, sütten kesilmiş, 1 yaşını geçmemiş 10-15 kg karkas ağırlığındaki kara oğlaklar kullanılır. Kesimden sonra iç organları çıkarılıp +4°C''de 1 gün dinlendirilir.
2. Karkasın içi, dışı ve etin kaba yerleri bıçakla kesilerek kaya tuzuyla terbiye edilir (10-15 kg karkas için 600-700 g); üzeri temiz bezle örtülüp 1 saat dinlendirilir.
3. Karın boşluğu hizasındaki ete kesikler açılır; ön ve arka ayaklar bu deliklere yerleştirilir.

**Isıl İşlem**
1. Fırın: Bir gün önceden kızılçam odunuyla yakılan fırın sabah 200-250°C''ye gelince köz ve kül kalmayacak şekilde temizlenir; tabanına "mara" tahtaları dizilir.
2. Pişirme (~2 saat 45 dk): Karkaslar fırına yerleştirilir, kapak kapatılıp çamur harçla hava almayacak şekilde sıvanır. Yaklaşık 1 saat sonra ters yüz edilip kapak yeniden sıvanır, 1 saat 45 dakika daha pişirilir.
3. Soğutma: Temiz bezler üzerinde soğutulur.

**Servis:** Parçalanarak servis edilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~235 dk · Toplam ~270 dk (1 gün karkas dinlendirme ve fırın yakma hariç)

**Kaynak:** Alucra Oğlak Kebabı, Türk Patent Coğrafi İşaret Tescil No 582 (bütün oğlak; porsiyon TAHMİN).',
            '[{"sira": 1, "ad": "Terbiye ve Dinlendirme", "sure_dakika": 75, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 165, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEÇİ ETİ (BUT)", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğutma ve Parçalama", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Giresun Usulü Kavurmalı Yumurta -> Giresun Fındık Ezmeli Kadayıf Tatlısı (CI 1345)
    select id into v_id from receteler where isletme_id is null and ad = 'Giresun Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Giresun Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Giresun Fındık Ezmeli Kadayıf Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Giresun Fındık Ezmeli Kadayıf Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Giresun Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Giresun Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Giresun Fındık Ezmeli Kadayıf Tatlısı', v_grup3_id, 1, 161,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "KADAYIF", "miktar_gram": 37.5}, {"ad": "FINDIK (İÇ)", "miktar_gram": 50.0}, {"ad": "TEREYAĞI", "miktar_gram": 6.25}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 53.6}, {"ad": "TOZ ŞEKER", "miktar_gram": 62.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Giresun Fındık Ezmeli Kadayıf Tatlısı', null, '**Hazırlık / Mise en Place**
1. Şerbet: Şeker ve sütü derin bir tencerede ~105°C''de 3 dakika kaynatın; 3 dakika bekletip ateşten alın ve oda sıcaklığında 30 dakika dinlendirin.
2. 35 x 45 cm tepsinin tabanına 450 g tel kadayıf yerleştirin; üzerine 200 g çifte kavrulup kıyılmış tombul fındık koyup kalan 450 g kadayıfla örtün. Tereyağını dilimler halinde üstüne dizin.

**Isıl İşlem**
1. Fırınlama (220°C): Alt ve üst kısmı homojen kızarana kadar pişirin.
2. Şerbetleme: 40°C''ye soğutulmuş şerbeti dökün, 1 saat dinlendirin.
3. Fındık ezmesi: Kavrulmuş fındığı un haline getirip kadayıfın üzerine dökün ve elle yoğurun. Helva kıvamına gelen karışımı tepsiye eşit yayıp bastırın.

**Servis:** ~8 x 9 cm kesip servis edin. Günlük üretilip tüketilir.

**PARALEL YAPILABİLİRLİK:** Kadayıf fırındayken şerbet dinlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~46 dk · Pasif bekleme ~115 dk · Toplam ~161 dk

**Kaynak:** Giresun Fındık Ezmeli Kadayıf Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1345 (24 porsiyon).',
            '[{"sira": 1, "ad": "Şerbet", "sure_dakika": 36, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜT (TAM YAĞ)", "TOZ ŞEKER"], "yeni_su_gram": null}, {"sira": 2, "ad": "Tepsiye Dizme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["KADAYIF", "FINDIK (İÇ)", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbetleme ve Dinlendirme", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Fındık Ezmesi ve Kesme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Rize Usulü Kavurmalı Yumurta -> Çayeli Kuru Fasulye Yemeği (CI 312)
    select id into v_id from receteler where isletme_id is null and ad = 'Rize Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Rize Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Çayeli Kuru Fasulye Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Çayeli Kuru Fasulye Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Rize Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Rize Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Çayeli Kuru Fasulye Yemeği', v_grup1_id, 1, 200,
            '["kuru_baklagil", "kirmizi_et"]'::jsonb, 'kis', 'Karadeniz',
            '[{"ad": "KURU FASULYE", "miktar_gram": 125.0}, {"ad": "DANA BUT", "miktar_gram": 62.5}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "TEREYAĞI", "miktar_gram": 50.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 25.0}, {"ad": "TUZ", "miktar_gram": 1.9}, {"ad": "SU", "miktar_gram": 250.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Çayeli Kuru Fasulye Yemeği', null, '**Hazırlık / Mise en Place**
1. Şeker fasulyesini 10 saat suda bekletin (1 kg fasulye 2 l su).
2. 1 gün dinlendirilmiş, sinirsiz ve yağsız dana/tosun but etini kuşbaşı doğrayın. Soğanı ince doğrayın.

**Isıl İşlem**
1. Fasulye (~10 dk): Suyunu boşaltıp 2 litre suyla bir taşım (~5 dk) kaynatın; köpükleri alın, suyu döküp fasulyeyi soğuk suyla yıkayın.
2. Et (5 dk): Kanlı suyu alınsın diye etleri 5 dakika suda kaynatıp suyunu dökün.
3. Kavurma (~20 dk): Soğan, tereyağı ve eti çelik/kalaylı bakır tencerede soğanlar pembeleşinceye kadar kavurun. Salçayı ekleyip kısık ateşte 10 dakika karıştırarak kavurun.
4. Sos (20 dk): 2 litre su ekleyip pişirin.
5. Pişirme (45-60 dk): Fasulyeyi ekleyip suyu ayarlayın, bir taşım kaynatın; fasulye pişince tuzu ekleyin.
6. Fırın (180°C, 45 dk) ve dinlendirme (45 dk): Üzeri kapalı fırında pişirin, fırın kapandıktan sonra kapalı dinlendirin.

**Servis:** 30 cm çapında porselen tabakta; pilav, yoğurt, kuru soğan ve turşuyla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~37 dk · Pasif bekleme ~163 dk · Toplam ~200 dk (10 saat fasulye ıslatma hariç)

**Kaynak:** Çayeli Kuru Fasulye Yemeği, Türk Patent Coğrafi İşaret Tescil No 312 (1 kg fasulye; yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Fasulye Ön Kaynatma", "sure_dakika": 10, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE"], "yeni_su_gram": null}, {"sira": 2, "ad": "Et Kan Alma", "sure_dakika": 5, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BUT"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "TEREYAĞI", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Sos", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU"], "yeni_su_gram": null}, {"sira": 5, "ad": "Pişirme", "sure_dakika": 55, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TUZ"], "yeni_su_gram": null}, {"sira": 6, "ad": "Fırınlama", "sure_dakika": 45, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": [], "yeni_su_gram": null}, {"sira": 7, "ad": "Fırında Dinlendirme", "sure_dakika": 45, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Rize Usulü Zeytinyağlı Nohutlu Kabak -> Derepazarı Pidesi (CI 324)
    select id into v_id from receteler where isletme_id is null and ad = 'Rize Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Rize Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Derepazarı Pidesi') then
        raise notice 'Yeni ad zaten var, atlandi: Derepazarı Pidesi';
    elsif _kopya_kullanimda_mi(v_id, 'Rize Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Rize Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Derepazarı Pidesi', v_grup2_id, 1, 136,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 152.0}, {"ad": "SU", "miktar_gram": 120.0}, {"ad": "KURU MAYA", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 4.5}, {"ad": "DANA KIYMA", "miktar_gram": 100.0}, {"ad": "KURU SOĞAN", "miktar_gram": 110.0}, {"ad": "SARIMSAK", "miktar_gram": 5.0}, {"ad": "DOMATES", "miktar_gram": 27.5}, {"ad": "YEŞİL BİBER", "miktar_gram": 15.0}, {"ad": "MAYDANOZ", "miktar_gram": 12.5}, {"ad": "KARABİBER", "miktar_gram": 0.5}, {"ad": "PUL BİBER", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Derepazarı Pidesi', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, su, tuz ve mayayı ~15 dakika yoğurup 45 dakika dinlendirin. 250-270 g''lık parçalara bölüp bez serili ahşap "pasa"ya dizin, üzerini örtüp 30 dakika mayalandırın.
2. Kıyma harcı (bir gün önceden): Orta yağlı dana kıymasını, ince doğranmış soğanı, tuzu ve ezilmiş sarımsağı kalaylı bakır tencerede soğan kaybolana kadar kavurun; soğutun. Ertesi gün çeyrek domates, 1 çarliston biberi, çeyrek bağ maydanoz, karabiber ve pul biberi ekleyin.
3. Hamuru ~25 cm daire açıp kenarlarını parmak kalınlığında içe kıvırın; harcı yayın.

**Isıl İşlem**
1. Kavurma (~15 dk, bir gün önceden).
2. Fırınlama (kara taş fırın, 270-300°C, 12-20 dk): Pide gevrek olana kadar pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~43 dk · Pasif bekleme ~93 dk · Toplam ~136 dk (bir gün önceden harç hazırlama ve soğutma hariç)

**Kaynak:** Derepazarı Pidesi, Türk Patent Coğrafi İşaret Tescil No 324 (1 pide 1 porsiyon (açık kıymalı)).',
            '[{"sira": 1, "ad": "Hamur ve Mayalanma", "sure_dakika": 90, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kıyma Harcı", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "SARIMSAK"], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma ve Harç", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 16, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "KURU MAYA", "TUZ", "DOMATES", "YEŞİL BİBER", "MAYDANOZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Rize Usulü Zeytinyağlı Pırasa -> Rize Pepeçurası (CI 703)
    select id into v_id from receteler where isletme_id is null and ad = 'Rize Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Rize Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Rize Pepeçurası') then
        raise notice 'Yeni ad zaten var, atlandi: Rize Pepeçurası';
    elsif _kopya_kullanimda_mi(v_id, 'Rize Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Rize Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Rize Pepeçurası', v_grup3_id, 1, 100,
            '["tatli", "vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
            '[{"ad": "ÜZÜM", "miktar_gram": 250.0}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 4.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 2.0}, {"ad": "MISIR UNU", "miktar_gram": 2.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 42.5}, {"ad": "SU", "miktar_gram": 300.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Rize Pepeçurası', null, '**Hazırlık / Mise en Place**
1. İsabella üzümünü bir kapta ezin.

**Isıl İşlem**
1. Kaynatma (~10 dk): Ezilmiş üzümü tencereye alıp 1 su bardağı suyla, üzüm rengini iyice verinceye kadar kaynatın. Süzgeçten süzüp posasını ayırın; tamamen arınması için tekrar süzün.
2. Pişirme (~20 dk): Üzüm suyuna mısır nişastası, buğday unu, ince elenmiş mısır unu, şeker ve 5 su bardağı suyu ekleyip homojen olana kadar karıştırarak pişirin.

**Servis:** Sıcakken kâselere koyun; soğuduktan sonra servis edin. Kapalı kâsede buzdolabında 5 güne kadar saklanır.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~67 dk · Toplam ~100 dk

**Kaynak:** Rize Pepeçurası, Türk Patent Coğrafi İşaret Tescil No 703 (4 porsiyon).',
            '[{"sira": 1, "ad": "Ezme", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kaynatma ve Süzme", "sure_dakika": 15, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ÜZÜM"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MISIR NİŞASTASI", "BUĞDAY UNU", "MISIR UNU", "TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Soğutma", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Samsun Usulü Etli Kavurma -> Yakakent Mantısı (CI 251)
    select id into v_id from receteler where isletme_id is null and ad = 'Samsun Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Samsun Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Yakakent Mantısı') then
        raise notice 'Yeni ad zaten var, atlandi: Yakakent Mantısı';
    elsif _kopya_kullanimda_mi(v_id, 'Samsun Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Samsun Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Yakakent Mantısı', v_grup2_id, 1, 135,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 112.5}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 12.5}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "DANA KIYMA", "miktar_gram": 62.5}, {"ad": "KURU SOĞAN", "miktar_gram": 27.5}, {"ad": "KARABİBER", "miktar_gram": 0.2}, {"ad": "SÜZME YOĞURT", "miktar_gram": 75.0}, {"ad": "SARIMSAK", "miktar_gram": 2.5}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Yakakent Mantısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, bir tutam tuz, yumurta ve alabildiği kadar suyu orta sertlikte yoğurun. Orta büyüklükte bezeler yapıp üzerini örtün, 15-20 dakika dinlendirin.
2. İç: Siniri alınmış dana kıymasına ince doğranmış soğan, karabiber ve tuz ekleyip iyice yoğurun.
3. Bezeleri 1,5-2 mm kalınlıkta, ~50 cm çapında açın; 3-4 cm''lik kareler kesin. İçlerine fındık tanesi kadar harç koyup karşılıklı kenarları birleştirerek muska şeklinde katlayın.

**Isıl İşlem**
1. Haşlama (15-18 dk): ~2 litre suyu kaynatıp bir yemek kaşığı kaya tuzu ekleyin; mantıları atıp hızlı ateşte pişirin, üste çıkanları tahta kaşığın tersiyle ortaya itin. Ateşten alıp 3-4 su bardağı su ekleyin, kevgirle karıştırıp süzün.
2. Tereyağı: Tereyağını eritin.

**Servis:** Süzme yoğurdu tuzla ezilmiş sarımsakla karıştırıp mantının üzerine dökün, hafifçe karıştırın; eritilmiş tereyağıyla sunun.

**SÜRE ÖZETİ:** Aktif işçilik ~100 dk · Pasif bekleme ~35 dk · Toplam ~135 dk

**Kaynak:** Yakakent Mantısı, Türk Patent Coğrafi İşaret Tescil No 251 (yaklaşık 8 kişilik (yoğurtlu)).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma, Kesme ve Katlama", "sure_dakika": 70, "aktif_dakika": 70, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Haşlama", "sure_dakika": 20, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "TAVUK YUMURTASI", "DANA KIYMA", "KURU SOĞAN"], "yeni_su_gram": null}, {"sira": 5, "ad": "Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜZME YOĞURT", "SARIMSAK", "TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Samsun Usulü Zeytinyağlı Nohutlu Havuç -> Çarşamba Pidesi (CI 333)
    select id into v_id from receteler where isletme_id is null and ad = 'Samsun Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Samsun Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Çarşamba Pidesi') then
        raise notice 'Yeni ad zaten var, atlandi: Çarşamba Pidesi';
    elsif _kopya_kullanimda_mi(v_id, 'Samsun Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Samsun Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Çarşamba Pidesi', v_grup2_id, 1, 85,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 87.0}, {"ad": "SU", "miktar_gram": 55.0}, {"ad": "TUZ", "miktar_gram": 4.7}, {"ad": "TOZ ŞEKER", "miktar_gram": 0.9}, {"ad": "KURU MAYA", "miktar_gram": 0.3}, {"ad": "DANA KIYMA", "miktar_gram": 122.5}, {"ad": "KURU SOĞAN", "miktar_gram": 195.0}, {"ad": "KARABİBER", "miktar_gram": 4.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Çarşamba Pidesi', null, '**Hazırlık / Mise en Place**
1. Hamur: 10 kg una 200 g tuz ve 100 g şeker serpip karıştırın. Ortasını açıp mayayı koyun, suyla eritin; unu yavaş yavaş katarak oldukça yumuşak ve sulu bir hamur yoğurun. Üzerini örtüp 30 dakika dinlendirin.
2. Hamuru 145 g''lık bezelere ayırıp payelere alın, üzerini örtüp 20-30 dakika daha dinlendirin.
3. İç: Kıymaya ince doğranmış, acı suyu çıkarılmış soğanı, karabiberi ve tuzu ekleyip iyice karıştırın; çiğ kullanılır.
4. Bezeyi açıp harcı yayın.

**Isıl İşlem**
1. Fırınlama (taş fırın): Pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~52 dk · Toplam ~85 dk

**Kaynak:** Çarşamba Pidesi, Türk Patent Coğrafi İşaret Tescil No 333 (1 pide 1 porsiyon).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 60, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "TUZ", "TOZ ŞEKER", "KURU MAYA", "DANA KIYMA", "KURU SOĞAN", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Samsun Usulü Zeytinyağlı Bakla -> Çarşamba Keşkeği (CI 1495)
    select id into v_id from receteler where isletme_id is null and ad = 'Samsun Usulü Zeytinyağlı Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Samsun Usulü Zeytinyağlı Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Çarşamba Keşkeği') then
        raise notice 'Yeni ad zaten var, atlandi: Çarşamba Keşkeği';
    elsif _kopya_kullanimda_mi(v_id, 'Samsun Usulü Zeytinyağlı Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Samsun Usulü Zeytinyağlı Bakla';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Çarşamba Keşkeği', v_grup2_id, 1, 115,
            '["pilav", "beyaz_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 62.5}, {"ad": "TAVUK BÜTÜN", "miktar_gram": 150.0}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "TAVUK SUYU", "miktar_gram": 62.5}, {"ad": "TEREYAĞI", "miktar_gram": 31.25}, {"ad": "TUZ", "miktar_gram": 3.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Çarşamba Keşkeği', null, '**Hazırlık / Mise en Place**
1. Döğmelik buğdayı bir gece önce yıkayıp bol suda bir taşım kaynatın ve sabaha kadar şişmeye bırakın.
2. Tavuğu bir gece önceden haşlayın, kemiklerini ayırıp etlerini didikleyin.

**Isıl İşlem**
1. Pişirme (~90 dk): Ertesi sabah buğdayın üzerini 5-9 cm geçecek kadar tavuk haşlama suyu koyun. Didiklenmiş tavuğun üzerine tereyağı ve tuzu koyup pişirin.
2. Güdelleme (~20 dk): Uzun saplı tahta kepçe veya tokmakla tüm bileşenleri lapa kıvamına gelene kadar ezin.

**Servis:** Servis tabağına alıp üzerine kızgın tereyağı dökerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~80 dk · Toplam ~115 dk (bir gece önceden buğday şişirme ve tavuk haşlama hariç)

**Kaynak:** Çarşamba Keşkeği, Türk Patent Coğrafi İşaret Tescil No 1495 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Pişirme", "sure_dakika": 90, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY (TAM TANE)", "TAVUK BÜTÜN", "SU", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Güdelleme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Tereyağı ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Samsun Usulü Elmalı Tatlı -> Çarşamba Kıvratması (CI 751)
    select id into v_id from receteler where isletme_id is null and ad = 'Samsun Usulü Elmalı Tatlı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Samsun Usulü Elmalı Tatlı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Çarşamba Kıvratması') then
        raise notice 'Yeni ad zaten var, atlandi: Çarşamba Kıvratması';
    elsif _kopya_kullanimda_mi(v_id, 'Samsun Usulü Elmalı Tatlı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Samsun Usulü Elmalı Tatlı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Çarşamba Kıvratması', v_grup3_id, 1, 190,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "YOĞURT (TAM)", "miktar_gram": 6.7}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 6.1}, {"ad": "SU", "miktar_gram": 6.7}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.1}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 5.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 33.3}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 3.3}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 25.0}, {"ad": "FINDIK (İÇ)", "miktar_gram": 8.3}, {"ad": "TOZ ŞEKER", "miktar_gram": 16.7}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Çarşamba Kıvratması', null, '**Hazırlık / Mise en Place**
1. Yoğurt, sıvı yağ, su, yumurta, karbonat ve unu kulak memesi yumuşaklığında yoğurun; 1 saat dinlendirin. Yumurta büyüklüğünde bezeler yapıp 10 dakika daha dinlendirin.
2. Bezeleri nişastayla 0,5 mm kalınlıkta, ~80 cm daire açın. Toz şeker, ceviz ve fındıktan hazırlanan iç harcı koyun; çok sıkı ya da gevşek olmadan oklavaya sarın, son kısmı içe katlayıp yufkayı büzerek oklavadan çıkarın.
3. Düz tepsiye dizip kare parçalar halinde kesin; üzerine eritilmiş tereyağı dökün.

**Isıl İşlem**
1. Fırınlama (180°C, 45 dk).

**Servis:** Şerbetsiz sunulur.

**SÜRE ÖZETİ:** Aktif işçilik ~77 dk · Pasif bekleme ~113 dk · Toplam ~190 dk

**Kaynak:** Çarşamba Kıvratması, Türk Patent Coğrafi İşaret Tescil No 751 (yaklaşık 30 porsiyon).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 85, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma ve Sarma", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 45, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "CEVİZ (İÇ)", "FINDIK (İÇ)", "TOZ ŞEKER", "TEREYAĞI", "TAVUK YUMURTASI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Siirt Usulü Etli Kavurma -> Siirt Kiteli (CI 1574)
    select id into v_id from receteler where isletme_id is null and ad = 'Siirt Usulü Etli Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Siirt Usulü Etli Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Siirt Kiteli') then
        raise notice 'Yeni ad zaten var, atlandi: Siirt Kiteli';
    elsif _kopya_kullanimda_mi(v_id, 'Siirt Usulü Etli Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Siirt Usulü Etli Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Siirt Kiteli', v_grup1_id, 1, 141,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "İNCE BULGUR", "miktar_gram": 83.3}, {"ad": "TUZ", "miktar_gram": 3.2}, {"ad": "SU", "miktar_gram": 30.0}, {"ad": "KUZU KIYMA", "miktar_gram": 62.5}, {"ad": "TEREYAĞI", "miktar_gram": 13.3}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6.0}, {"ad": "KURU SOĞAN", "miktar_gram": 47.9}, {"ad": "MAYDANOZ", "miktar_gram": 8.3}, {"ad": "PUL BİBER", "miktar_gram": 1.3}, {"ad": "KARABİBER", "miktar_gram": 0.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Siirt Kiteli', null, '**Hazırlık / Mise en Place**
1. Dış hamur: Kitellik ince bulguru geniş kaba alıp ıslatacak kadar 30-40°C su gezdirin; ağzını kapatıp şişinceye kadar 30 dakika bekletin.
2. İç harç (çiğ): Pirinci haşlayıp soğutun. Soğanları çok ince doğrayın; kıyma, tereyağı, baharatlar ve tuzla özdeşleşene kadar yoğurun; en son pirinci ekleyip dinlendirin.
3. Dinlenen bulguru ıslak elle 15-20 dakika özleşene kadar yoğurun. ~70 g bezeler yapıp nemli bezle örtün.
4. Elleri yağlayıp bezeyi başparmakla oyun, kenarlardan döndürerek genişletip inceltin; ~50 g iç harç koyup büzerek kapatın. Havasını alıp saat yönünde bastırıp döndürerek büyütün.

**Isıl İşlem**
1. Pirinç haşlama (~10 dk).
2. Haşlama (10-15 dk): Yayvan tencerede suyu kaynatıp tuzlayın; köfteleri dikkatle bırakın, su yüzüne çıkana kadar haşlayın. Dibe yapışmasın diye arada kevgirle karıştırın; süzgece alın.
3. Sos: 60 g tereyağını eritip 10 g pul biberle kızdırın.

**Servis:** Servis tabağındaki köftelerin üzerine sosu dökerek sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~112 dk · Pasif bekleme ~29 dk · Toplam ~141 dk

**Kaynak:** Siirt İçli Köftesi / Siirt Kiteli, Türk Patent Coğrafi İşaret Tescil No 1574 (yaklaşık 12 kişilik (porsiyonda 2 köfte)).',
            '[{"sira": 1, "ad": "Bulgur Şişirme ve Pirinç", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Hamur Yoğurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şekillendirme", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Haşlama", "sure_dakika": 13, "aktif_dakika": 4, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İNCE BULGUR", "KUZU KIYMA", "KURU SOĞAN", "MAYDANOZ", "SU"], "yeni_su_gram": null}, {"sira": 6, "ad": "Sos", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "PUL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Siirt Usulü Zeytinyağlı Nohutlu Kereviz -> Siirt Pırtike Çorbası (CI 1817)
    select id into v_id from receteler where isletme_id is null and ad = 'Siirt Usulü Zeytinyağlı Nohutlu Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Siirt Usulü Zeytinyağlı Nohutlu Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Siirt Pırtike Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Siirt Pırtike Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Siirt Usulü Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Siirt Usulü Zeytinyağlı Nohutlu Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Siirt Pırtike Çorbası', v_grup2_id, 1, 88,
            '["corba", "vejetaryen"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
            '[{"ad": "ISPANAK", "miktar_gram": 166.7}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 8.3}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 7.7}, {"ad": "KURU SOĞAN", "miktar_gram": 37.5}, {"ad": "SUMAK", "miktar_gram": 41.7}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 8.3}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 0.8}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "SU", "miktar_gram": 216.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Siirt Pırtike Çorbası', null, '**Hazırlık / Mise en Place**
1. Tane sumağı rengini ve ekşisini suya bırakması için 300 ml ılık suda 30 dakika bekletin.
2. Ispanakları karbonatlı ve sirkeli sudan geçirerek temizleyin, ~1,5 cm doğrayın. Soğanları küp doğrayın.

**Isıl İşlem**
1. Kavurma (~8 dk): Soğanları sıvı yağla pembeleşinceye kadar kavurun; domates salçasını ekleyip 1-2 dakika daha kavurun.
2. Ispanak (~5 dk): Ispanak, pirinç, tuz ve baharatları ekleyip ıspanaklar suyunu salana kadar kavurun.
3. Pişirme (30 dk): 1 litre kaynar su ekleyip 10 dakika kaynatın. Islatılmış sumağın suyunu süzgeçten geçirerek ekleyin, 20 dakika daha pişirin.
4. Dinlendirme (15 dk).

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~55 dk · Toplam ~88 dk

**Kaynak:** Siirt Pırtike Çorbası, Türk Patent Coğrafi İşaret Tescil No 1817 (yaklaşık 6 kişilik).',
            '[{"sira": 1, "ad": "Sumak Bekletme ve Hazırlık", "sure_dakika": 30, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AYÇİÇEK YAĞI", "KURU SOĞAN", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Ispanak Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ISPANAK", "PİRİNÇ (HAM)", "TUZ", "KARABİBER", "PUL BİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "SUMAK"], "yeni_su_gram": null}, {"sira": 5, "ad": "Dinlendirme", "sure_dakika": 15, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Siirt Usulü Zeytinyağlı Nohutlu Patlıcan -> Siirt Gebole Tatlısı (CI 1675)
    select id into v_id from receteler where isletme_id is null and ad = 'Siirt Usulü Zeytinyağlı Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Siirt Usulü Zeytinyağlı Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Siirt Gebole Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Siirt Gebole Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Siirt Usulü Zeytinyağlı Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Siirt Usulü Zeytinyağlı Nohutlu Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Siirt Gebole Tatlısı', v_grup3_id, 1, 55,
            '["tatli", "vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
            '[{"ad": "TEREYAĞI", "miktar_gram": 6.25}, {"ad": "BUĞDAY UNU", "miktar_gram": 37.5}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 25.75}, {"ad": "SU", "miktar_gram": 75.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 25.0}, {"ad": "TUZ", "miktar_gram": 0.6}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 33.75}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 6.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Siirt Gebole Tatlısı', null, '**Hazırlık / Mise en Place**
1. 300 g un ile 200 ml sütü derin bir kâsede homojen olana kadar çırpın.

**Isıl İşlem**
1. Pişirme (~10 dk): 600 ml suyu 5 g tuzla kaynatın. Un-süt karışımını kontrollü ekleyin; şekeri ve tereyağını katıp sürekli karıştırın. Kaynayınca 2-3 dakika daha karıştırıp ocağı kapatın.
2. Soğutma (30-45 dk): Soğuk suyla ıslatılmış yayvan tepsiye ya da tabağa yayın; dilimleme kıvamına gelene kadar soğutun.

**Servis:** Kare ya da baklava dilimi kesin; tüm yüzeyine üzüm pekmezi dökün, dövülmüş cevizle süsleyip ılık ya da soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~38 dk · Toplam ~55 dk

**Kaynak:** Siirt Gebole Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1675 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Pişirme", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "BUĞDAY UNU", "SÜT (TAM YAĞ)", "SU", "TOZ ŞEKER", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Soğutma", "sure_dakika": 38, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Kesme ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["ÜzÜM PEKMEZİ", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Siirt Usulü Zeytinyağlı Nohutlu Bamya -> Siirt Varak Keek Tatlısı (CI 1799)
    select id into v_id from receteler where isletme_id is null and ad = 'Siirt Usulü Zeytinyağlı Nohutlu Bamya';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Siirt Usulü Zeytinyağlı Nohutlu Bamya';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Siirt Varak Keek Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Siirt Varak Keek Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Siirt Usulü Zeytinyağlı Nohutlu Bamya') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Siirt Usulü Zeytinyağlı Nohutlu Bamya';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Siirt Varak Keek Tatlısı', v_grup3_id, 1, 108,
            '["tatli", "vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 33.3}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "SU", "miktar_gram": 91.7}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 45.0}, {"ad": "TEREYAĞI", "miktar_gram": 1.7}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 33.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Siirt Varak Keek Tatlısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Un ve tuzu kaba alın, kontrollü su ekleyerek sert ve pürüzsüz olana kadar yoğurun. Üzerini bezle örtüp 20 dakika dinlendirin. Yarım santim kalınlıkta açıp 4 x 4 cm kareler kesin; bez üzerinde 30 dakika kurutun.

**Isıl İşlem**
1. Şerbet ve pişirme (~35 dk): Üzüm pekmezi, tereyağı ve suyu derin tencerede kaynatın; kaynayınca kurumuş hamurları kontrollü ekleyip kısık ateşte 30 dakika pişirin.

**Servis:** Hamurları şerbetle birlikte servis tabağına alın, üzerini çekilmiş cevizle süsleyip ılık ya da soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~80 dk · Toplam ~108 dk

**Kaynak:** Siirt Varak Keek Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1799 (6 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma, Kesme ve Kurutma", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Şerbette Pişirme", "sure_dakika": 35, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "ÜzÜM PEKMEZİ", "TEREYAĞI", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Söke Usulü Zeytinyağlı Nohutlu Havuç -> Söke Kulak Çorbası (CI 1761)
    select id into v_id from receteler where isletme_id is null and ad = 'Söke Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Söke Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Söke Kulak Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Söke Kulak Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Söke Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Söke Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Söke Kulak Çorbası', v_grup2_id, 1, 115,
            '["corba"]'::jsonb, 'kis', 'Ege',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 43.3}, {"ad": "SU", "miktar_gram": 12.5}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 8.3}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 2.8}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "DANA KIYMA", "miktar_gram": 25.0}, {"ad": "KURU SOĞAN", "miktar_gram": 18.3}, {"ad": "KARABİBER", "miktar_gram": 0.33}, {"ad": "ET SUYU", "miktar_gram": 200.0}, {"ad": "NOHUT", "miktar_gram": 10.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 33.3}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3.8}, {"ad": "TEREYAĞI", "miktar_gram": 3.3}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 0.8}, {"ad": "KURU NANE", "miktar_gram": 0.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Söke Kulak Çorbası', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, tuz, yumurta ve suyu yavaş yavaş karıştırıp parlak, nispeten sert, pürüzsüz ve elastik bir hamur yoğurun; en az 15 dakika dinlendirin.
2. İç harç: Kıyma, rendelenmiş soğan, tuz ve karabiberi yoğurun. Bir kısmından küçük nohut büyüklüğünde köfteler yuvarlayıp ayırın.
3. Hamuru 1-2 mm kalınlıkta açıp kenarı ~1 cm kareler kesin; her karenin ortasına nohut büyüklüğünde harç koyup iki karşılıklı köşeyi ortada sıkıca birleştirerek kulak şekli verin. Kalan hamurdan küçük kesme hamur ayırın.

**Isıl İşlem**
1. Kızartma (~3 dk): Kulakları derin tavada zeytinyağında iki yüzü sarı renk alana kadar kızartın.
2. Çorba (8-10 dk): Et suyunu kaynatıp kızarmış kulakları ekleyin; yumuşayıp yüzeye çıkana kadar pişirin, ateşi kısın. Haşlanmış nohudu, ardından kesme hamuru (nohuttan az) ekleyin.
3. Terbiye (5-10 dk): Yoğurt, yumurta sarısı ve unu çırpın; çorbanın suyundan 1-2 kepçe ekleyerek ılıştırın, sürekli karıştırarak çorbaya katın ve kısık ateşte kıvam alana kadar pişirin.
4. Sos: Tereyağını kızdırıp nane ve kırmızı biberi kavurun.

**Servis:** İsteğe göre tereyağlı sosla sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~95 dk · Pasif bekleme ~20 dk · Toplam ~115 dk

**Kaynak:** Söke Kulak Çorbası, Türk Patent Coğrafi İşaret Tescil No 1761 (6 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve İç Harç", "sure_dakika": 25, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kesme ve Kapatma", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Kızartma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 160, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "DANA KIYMA", "ZEYTİNYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Çorba", "sure_dakika": 12, "aktif_dakika": 4, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ET SUYU", "NOHUT"], "yeni_su_gram": null}, {"sira": 5, "ad": "Terbiye", "sure_dakika": 10, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YOĞURT (TAM)", "BIRAKIN YUMURTA SARISI"], "yeni_su_gram": null}, {"sira": 6, "ad": "Sos", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "TATLIKA KIRMIZI BİBER", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Söke Usulü Zeytinyağlı Pırasa -> Söke Pidesi (CI 1248)
    select id into v_id from receteler where isletme_id is null and ad = 'Söke Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Söke Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Söke Pidesi') then
        raise notice 'Yeni ad zaten var, atlandi: Söke Pidesi';
    elsif _kopya_kullanimda_mi(v_id, 'Söke Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Söke Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Söke Pidesi', v_grup2_id, 1, 286,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 141.0}, {"ad": "SU", "miktar_gram": 46.0}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KURU MAYA", "miktar_gram": 0.6}, {"ad": "DANA KIYMA", "miktar_gram": 109.0}, {"ad": "DOMATES", "miktar_gram": 55.0}, {"ad": "MAYDANOZ", "miktar_gram": 35.5}, {"ad": "ÇÖKELEK (ÇORUM)", "miktar_gram": 66.7}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 17.8}, {"ad": "TEREYAĞI", "miktar_gram": 17.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Söke Pidesi', null, '**Hazırlık / Mise en Place**
1. Birinci harç: Dana kol, boşluk ve kaburga etinin yağsız kısımlarından kıymayı tepside taş fırında 120-130°C''de 3-4 saat kavurun; %1 tuz ekleyip topaklananları havanda pirinç tanesi büyüklüğüne kadar ezin. Rendelenmiş ya da 2-3 mm küp domatesle karıştırın.
2. İkinci harç: Maydanozu 2-3 mm doğrayın, çökelek ve yumurtayla karıştırın (isteğe göre pul biber, karabiber). İki harcı ayrı kaplarda 4°C''de saklayın.
3. Hamur: Un, tuz, yaş maya ve suyu yoğurup 25-30 dakika mayalandırın; 2-3 dakika yoğurup 180-200 g''lık pazılara ayırın. 5 dakika dinlendirip 32-35 cm boyunda, 15-18 cm eninde, 1,5-1,7 cm kalınlıkta oval açın.
4. Harçları 1/1 karıştırıp her pideye 230-250 g koyun, yüzeye yayın.

**Isıl İşlem**
1. Kıyma kavurma (taş fırın, 3-4 saat; önceden).
2. Pişirme (taş fırın 350-380°C, 10-15 dk): Harç ve taban kızarana kadar pişirin. Eritilmiş tereyağını kalın kenarlara fırçayla sürün.

**Servis:** Dilimleyip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~56 dk · Pasif bekleme ~230 dk · Toplam ~286 dk (kıyma kavurma günlük toplu yapılır)

**Kaynak:** Söke Pidesi, Türk Patent Coğrafi İşaret Tescil No 1248 (1 pide 1 porsiyon).',
            '[{"sira": 1, "ad": "Kıyma Kavurma", "sure_dakika": 210, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Harçlar", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Hamur ve Mayalanma", "sure_dakika": 40, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Açma ve Harç", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Fırınlama", "sure_dakika": 13, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "KURU MAYA", "DOMATES", "MAYDANOZ", "ÇÖKELEK (ÇORUM)", "TAVUK YUMURTASI", "TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Trabzon Usulü Zeytinyağlı Nohutlu Havuç -> Sürmene Pidesi (CI 553)
    select id into v_id from receteler where isletme_id is null and ad = 'Trabzon Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Trabzon Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Sürmene Pidesi') then
        raise notice 'Yeni ad zaten var, atlandi: Sürmene Pidesi';
    elsif _kopya_kullanimda_mi(v_id, 'Trabzon Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Trabzon Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Sürmene Pidesi', v_grup2_id, 1, 68,
            '["pilav_makarna_borek", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 146.0}, {"ad": "SU", "miktar_gram": 90.0}, {"ad": "TUZ", "miktar_gram": 1.75}, {"ad": "KURU MAYA", "miktar_gram": 0.5}, {"ad": "FETA PEYNİRİ", "miktar_gram": 205.0}, {"ad": "TEREYAĞI", "miktar_gram": 50.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Sürmene Pidesi', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, yaş maya, tuz ve suyu şekersiz, sakız kıvamında yoğurun (sıcak havada biraz katı, soğukta biraz cıvık). Ahşap tezgâhta üzeri kapalı 30-45 dakika dinlendirin.
2. Köy peyniri (kolot + civil peyniri, iki kez salamura edilmiş) bir gece suda bekletilip tuzu alınır.
3. 230-250 g hamuru oklava kullanmadan elle 3-4 cm kalınlığında yuvarlak açıp kenarlarını içe kıvırın. Peyniri ve tereyağını ekleyin.

**Isıl İşlem**
1. Fırınlama (taş fırın, odun ateşi, 10-15 dk): Sıcaklık her yerde aynı olmadığından çevirerek pişirin. Kenarları pişkin, ortası biraz yumuşak olur.

**Servis:** Çatal-bıçak kullanılmadan kenarları elle koparılıp ekmekle yenir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~48 dk · Toplam ~68 dk (peynir salamura ve bir gece suda bekletme hariç)

**Kaynak:** Sürmene Pidesi, Türk Patent Coğrafi İşaret Tescil No 553 (1 pide 1 porsiyon).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 50, "aktif_dakika": 12, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 13, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "TUZ", "KURU MAYA", "FETA PEYNİRİ", "TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Trabzon Usulü Zeytinyağlı Pırasa -> Hamsiköy Sütlacı (CI 255)
    select id into v_id from receteler where isletme_id is null and ad = 'Trabzon Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Trabzon Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Hamsiköy Sütlacı') then
        raise notice 'Yeni ad zaten var, atlandi: Hamsiköy Sütlacı';
    elsif _kopya_kullanimda_mi(v_id, 'Trabzon Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Trabzon Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Hamsiköy Sütlacı', v_grup3_id, 1, 68,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 250.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 15.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 17.5}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Hamsiköy Sütlacı', null, '**Hazırlık / Mise en Place**
1. Birinci tencerede sütü kaynatıp ikinci tencereye alın.

**Isıl İşlem**
1. Pişirme (40-45 dk): Pirinci kaynayan süte aktarın; kevgirle pirinci kırmadan dikkatle karıştırarak kaynatın, kaynadıktan sonra ~5 dakikada bir karıştırın.
2. Şekerli pişirme (10-20 dk): Şeker ve tuzu ekleyip pişirmeye devam edin. Kaşıkla alınıp bırakıldığında bal gibi kesintisiz akıyorsa pişmiştir.

**Servis:** Sıcak, ılık ya da soğuk; isteğe göre tarçın ve/veya fındıkla servis edin. Soğukta saklayın.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~50 dk · Toplam ~68 dk

**Kaynak:** Hamsiköy Sütlacı, Türk Patent Coğrafi İşaret Tescil No 255 (oran: 1 l süt / 60 g pirinç / 70 g şeker).',
            '[{"sira": 1, "ad": "Süt Kaynatma", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜT (TAM YAĞ)"], "yeni_su_gram": null}, {"sira": 2, "ad": "Pirinçle Pişirme", "sure_dakika": 43, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Şekerli Pişirme", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Uşak Usulü Etli Bulgur Pilavı -> Karahallı Ciğeri (CI 1283)
    select id into v_id from receteler where isletme_id is null and ad = 'Uşak Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Uşak Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Karahallı Ciğeri') then
        raise notice 'Yeni ad zaten var, atlandi: Karahallı Ciğeri';
    elsif _kopya_kullanimda_mi(v_id, 'Uşak Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Uşak Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Karahallı Ciğeri', v_grup1_id, 1, 41,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "YENİLEBİLİR SAKATAT (DANA KARACİĞER)", "miktar_gram": 57.5}, {"ad": "MARGARİN", "miktar_gram": 16.0}, {"ad": "KURU SOĞAN", "miktar_gram": 16.0}, {"ad": "TUZ", "miktar_gram": 0.85}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 0.95}, {"ad": "YEŞİL BİBER", "miktar_gram": 30.0}, {"ad": "DOMATES", "miktar_gram": 22.5}, {"ad": "KİMYON", "miktar_gram": 0.3}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 105.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Karahallı Ciğeri', null, '**Hazırlık / Mise en Place**
1. 16-24 aylık danadan alınan karaciğeri 1-2 saat dinlendirin (+4°C''de en fazla 3 gün). Zar, sinir, damarlı kısımları ve yağları bıçağın tersiyle dikkatle temizleyin.
2. 10-15 cm parçalara ayırıp kalan zar ve sinirleri temizleyin; 2-3 mm kalınlıkta, 2-2,5 cm uzunlukta eşit kesin. Pişirene kadar +4°C''de tutun, en fazla 1-2 saat içinde pişirin.

**Isıl İşlem**
1. Sac pişirme (150-180°C, 15-20 dk): Ortası yağ biriktiren, en fazla 15-20° eğimli metal sacın ortasında mutfak margarinini eritin. Yağ kızınca ciğer, iri doğranmış soğan, %0,5-1 tuz ve %0,3-0,5 toz kırmızı biber ekleyin; yanmasın diye dakikada 4-5 kez spatulayla karıştırın. Bitmeden 3-4 dakika önce bütün sivri biberleri ortadaki yağa, dilimlenmiş domatesi sacın kenarına koyun.
2. Bekletme: Pişen ciğerleri sacın dışına daire şeklinde dizin; ateşi 45-55°C''ye indirip servise kadar bekletin.

**Servis:** Porsiyon 95-105 g ciğer; yağını iyice süzüp yarım ekmeğin arasına koyun. İsteğe göre toz biber, kimyon veya pul biber serpin; domates, biber ve soğanla sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~41 dk · Pasif bekleme ~0 dk · Toplam ~41 dk

**Kaynak:** Karahallı Ciğeri, Türk Patent Coğrafi İşaret Tescil No 1283 (1 porsiyon).',
            '[{"sira": 1, "ad": "Temizleme ve Doğrama", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sac Pişirme", "sure_dakika": 18, "aktif_dakika": 18, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YENİLEBİLİR SAKATAT (DANA KARACİĞER)", "MARGARİN", "KURU SOĞAN", "TUZ", "TATLIKA KIRMIZI BİBER", "YEŞİL BİBER", "DOMATES"], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["EKMEK (BEYAZ)", "KİMYON"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Aksaray Usulü Kavurmalı Yumurta -> Aksaray İnceelek Tatlısı (CI 464)
    select id into v_id from receteler where isletme_id is null and ad = 'Aksaray Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Aksaray Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Aksaray İnceelek Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Aksaray İnceelek Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Aksaray Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Aksaray Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Aksaray İnceelek Tatlısı', v_grup3_id, 1, 178,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 35.7}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 16.6}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 5.85}, {"ad": "YOĞURT (TAM)", "miktar_gram": 0.9}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 3.6}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 1.8}, {"ad": "LİMON SUYU", "miktar_gram": 1.0}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 1.4}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 17.9}, {"ad": "TOZ ŞEKER", "miktar_gram": 35.7}, {"ad": "SU", "miktar_gram": 32.1}, {"ad": "TUZ", "miktar_gram": 0.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Aksaray İnceelek Tatlısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, süt, zeytinyağı, yumurta, yoğurt, limon suyu ve karbonatı homojen olana kadar 10-12 dakika yoğurun; 20-25°C''de 1-1,5 saat fermantasyona bırakın.
2. Yufkalar: Hamuru 14 eşit parçaya bölün; nişasta serperek oklavayla 35-40 cm çapında, 0,3-0,35 mm kalınlıkta açın.

**Isıl İşlem**
1. Yufka kızartma (100-120°C, 5-10 dk): Yufkaları sacda ya da fırında çift yönlü hafifçe kızartın; 5 dakika dinlendirip iki yüzünü az suyla ıslatın.
2. Dizme: 7 yufkayı tepside üst üste dizin, küçük parçalanmış ceviz serpin, üzerine 7 yufka daha koyun. Dilimleyip tüm yüzeyi kaplayacak şekilde zeytinyağı dökün.
3. Fırınlama (180°C, 15 dk).
4. Şerbet (5 dk): Su, şeker ve tuzu kaynatın, limon suyunu ekleyin (briks 60-70). Fırından çıkan sıcak tepsiye soğumuş şerbeti dökün.

**Servis:** Sıcak servis edin; porsiyon 150 g''dan az olmalı. 24 saatten fazla bekletilmez.

**PARALEL YAPILABİLİRLİK:** Hamur mayalanırken şerbet hazırlanıp soğutulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~82 dk · Pasif bekleme ~96 dk · Toplam ~178 dk

**Kaynak:** Aksaray İnceelek Tatlısı, Türk Patent Coğrafi İşaret Tescil No 464 (porsiyon 150 g altı; ~14 porsiyon).',
            '[{"sira": 1, "ad": "Hamur ve Fermantasyon", "sure_dakika": 85, "aktif_dakika": 12, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Yufka Açma", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Yufka Kızartma ve Dizme", "sure_dakika": 30, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SÜT (TAM YAĞ)", "TAVUK YUMURTASI", "BUĞDAY NİŞASTASI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["CEVİZ (İÇ)", "ZEYTİNYAĞI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Şerbet", "sure_dakika": 8, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "TUZ", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kars Usulü Kaşarlı Kete -> Kars Ketesi (CI 1366)
    select id into v_id from receteler where isletme_id is null and ad = 'Kars Usulü Kaşarlı Kete';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kars Usulü Kaşarlı Kete';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kars Ketesi') then
        raise notice 'Yeni ad zaten var, atlandi: Kars Ketesi';
    elsif _kopya_kullanimda_mi(v_id, 'Kars Usulü Kaşarlı Kete') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kars Usulü Kaşarlı Kete';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kars Ketesi', v_grup3_id, 1, 188,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 72.75}, {"ad": "KURU MAYA", "miktar_gram": 1.45}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 34.8}, {"ad": "TUZ", "miktar_gram": 0.7}, {"ad": "TOZ ŞEKER", "miktar_gram": 0.15}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 20.7}, {"ad": "SADEYAĞ", "miktar_gram": 22.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kars Ketesi', null, '**Hazırlık / Mise en Place**
1. İç harç (tuzlu): Tencerede sadeyağ ve ayçiçek yağını ısıtın; sadeyağ eriyince unu azar azar ekleyip ocağı kapatın. Un yağla karışıp kıvam alınca tuzu ekleyin.
2. Hamur: Ilık süte maya, şeker ve tuzu karıştırın; unu azar azar katıp yumuşak bir hamur yoğurun. Üzerini örtüp ~1 saat mayalandırın.
3. Hamurdan 130-140 g''lık "pazı"lar ayırın. Az un serperek oklavayla 3 mm kalınlığında, 90-100 cm çapında açın. Yüzeyi fırçayla ayçiçek yağı ve sadeyağla dikkatle yağlayın.
4. Zarf gibi katlayıp ortasına ~55 g iç harç koyun, bohça şeklinde kapatın. Ters çevirip aralıklarla tepsiye dizin, çatalla delin; iç harcı parmak uçlarıyla bastırarak kalınlığı eşitleyin.

**Isıl İşlem**
1. Fırınlama (180-200°C, 40-45 dk ya da tandırda 30 dk): Üzerine yumurta sürüp pişirin.
2. Soğutma: Temiz bez serili tezgâhta, üst üste koymadan 6 saat soğutun.

**Servis:** Bıçakla dilimleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~87 dk · Pasif bekleme ~101 dk · Toplam ~188 dk (6 saat soğutma hariç)

**Kaynak:** Kars Ketesi, Türk Patent Coğrafi İşaret Tescil No 1366 (10 adet; porsiyonda 1 kete (tuzlu iç)).',
            '[{"sira": 1, "ad": "İç Harç", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SADEYAĞ", "AYÇİÇEK YAĞI", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hamur ve Mayalanma", "sure_dakika": 75, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma ve Kapatma", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 43, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "KURU MAYA", "SÜT (TAM YAĞ)", "TOZ ŞEKER", "TAVUK YUMURTASI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kırşehir Usulü Elmalı Ceviz Tatlısı -> Kırşehir Ahi Helvası (CI 1513)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırşehir Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırşehir Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kırşehir Ahi Helvası') then
        raise notice 'Yeni ad zaten var, atlandi: Kırşehir Ahi Helvası';
    elsif _kopya_kullanimda_mi(v_id, 'Kırşehir Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırşehir Usulü Elmalı Ceviz Tatlısı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kırşehir Ahi Helvası', v_grup3_id, 1, 65,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "TEREYAĞI", "miktar_gram": 20.8}, {"ad": "BUĞDAY UNU", "miktar_gram": 25.0}, {"ad": "BAL", "miktar_gram": 25.0}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 51.5}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 20.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kırşehir Ahi Helvası', null, '**Hazırlık / Mise en Place**
1. Balı süte döküp tamamen çözününceye kadar karıştırın.

**Isıl İşlem**
1. Un kavurma (~55 dk): Tencerede tereyağı ve unu, un yağı iyice çekinceye kadar ~10 dakika karıştırın; sonra kısık ateşte ~45 dakika karıştırarak kavurun.
2. Birleştirme (5 dk): Unun rengi kahverengiye dönünce ballı sütü yavaş yavaş dökün, 5 dakika daha karıştırarak kavurun.
3. Ateşten alıp kıyılmış cevizi katın.

**Servis:** İstenen şekli verip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~65 dk · Pasif bekleme ~0 dk · Toplam ~65 dk

**Kaynak:** Kırşehir Ahi Helvası, Türk Patent Coğrafi İşaret Tescil No 1513 (yaklaşık 12 kişilik).',
            '[{"sira": 1, "ad": "Un Kavurma", "sure_dakika": 55, "aktif_dakika": 55, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Ballı Süt ile Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAL", "SÜT (TAM YAĞ)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Ceviz ve Şekil", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kütahya Usulü Elmalı Ceviz Tatlısı -> Gediz Höşmerimi (CI 1285)
    select id into v_id from receteler where isletme_id is null and ad = 'Kütahya Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kütahya Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Gediz Höşmerimi') then
        raise notice 'Yeni ad zaten var, atlandi: Gediz Höşmerimi';
    elsif _kopya_kullanimda_mi(v_id, 'Kütahya Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kütahya Usulü Elmalı Ceviz Tatlısı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Gediz Höşmerimi', v_grup3_id, 1, 150,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "İRMİK", "miktar_gram": 12.5}, {"ad": "BUĞDAY UNU", "miktar_gram": 20.0}, {"ad": "LOR PEYNİRİ", "miktar_gram": 75.0}, {"ad": "KABARTMA TOZU", "miktar_gram": 0.2}, {"ad": "TOZ ŞEKER", "miktar_gram": 65.0}, {"ad": "SU", "miktar_gram": 72.5}, {"ad": "LİMON SUYU", "miktar_gram": 0.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Gediz Höşmerimi', null, '**Hazırlık / Mise en Place**
1. Olgunlaşmamış taze inek peynirini tencerede 100°C''de tahta kaşıkla karıştırarak eritin, 10-15 dakika kaynatın.

**Isıl İşlem**
1. Hamur (25-30 dk): Un, irmik ve kabartma tozunu ekleyip kısık ateşte homojen ve yumuşak kıvama gelene kadar tahta kaşıkla karıştırın. 100 g şekeri ekleyip açık kahverengi renk alana kadar pişirin.
2. Fırınlama (200°C, ~1 saat): Yağlanmış tepsiye düzgünce yayın, eşit parçalara kesin ve kızarana kadar pişirin.
3. Şerbet: Şeker, su ve limon suyunu kısık ateşte kaynatın; sıcak şerbeti höşmerimin her yerine eşit gelecek şekilde gezdirin ve soğutun.
4. Son şerbet: 200 ml suya 200 g şeker katılan soğuk koyu şerbeti soğumuş höşmerimin üzerine dökün.

**Servis:** İsteğe göre kaymakla servis edin.

**PARALEL YAPILABİLİRLİK:** Höşmerim fırındayken şerbet hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~48 dk · Pasif bekleme ~102 dk · Toplam ~150 dk

**Kaynak:** Gediz Höşmerimi, Türk Patent Coğrafi İşaret Tescil No 1285 (yaklaşık 20 kişilik).',
            '[{"sira": 1, "ad": "Peynir Eritme", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LOR PEYNİRİ"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hamur Pişirme", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İRMİK", "BUĞDAY UNU", "KABARTMA TOZU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbet ve Soğutma", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kütahya Usulü Kirazlı Yoğurt -> Kütahya Tosunumu (CI 1665)
    select id into v_id from receteler where isletme_id is null and ad = 'Kütahya Usulü Kirazlı Yoğurt';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kütahya Usulü Kirazlı Yoğurt';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kütahya Tosunumu') then
        raise notice 'Yeni ad zaten var, atlandi: Kütahya Tosunumu';
    elsif _kopya_kullanimda_mi(v_id, 'Kütahya Usulü Kirazlı Yoğurt') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kütahya Usulü Kirazlı Yoğurt';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kütahya Tosunumu', v_grup2_id, 1, 125,
            '["pilav_makarna_borek", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 64.5}, {"ad": "TUZ", "miktar_gram": 2.6}, {"ad": "SU", "miktar_gram": 35.5}, {"ad": "HAŞHAŞ", "miktar_gram": 16.1}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 11.9}, {"ad": "TEREYAĞI", "miktar_gram": 9.7}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 16.1}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "KURU NANE", "miktar_gram": 0.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kütahya Tosunumu', null, '**Hazırlık / Mise en Place**
1. Hamur: Un, su ve tuzu orta yumuşaklıkta yoğurup 5-10 dakika dinlendirin. Haşhaş ezmesi ile ayçiçek yağını karıştırın; tereyağını oda sıcaklığına getirin.
2. Hamuru ~400 g''lık 4 bezeye bölün; çok ince yufkalar halinde açıp hafifçe çekiştirerek inceltin. Önce tereyağı, sonra haşhaş karışımı sürüp kenarlardan bohça gibi kat kat katlayın; 30 dakika dinlendirin.
3. İç harç: Yeşil mercimeği yumuşayana kadar haşlayıp süzün; tuz, karabiber ve naneyle karıştırıp soğutun.
4. Bezeleri ~1 cm kalınlıkta açıp 10x10 cm kareler kesin; ortasına bir yemek kaşığı harç koyup üst ve alt kenarı katlayarak kapatın, tepsiye dizin.

**Isıl İşlem**
1. Mercimek haşlama (~25 dk).
2. Fırınlama (200-220°C, 20-30 dk): Üzerlerine kalan haşhaş karışımını sürüp pişirin.

**Servis:** Günlük tüketilir.

**PARALEL YAPILABİLİRLİK:** Katlanmış hamur dinlenirken mercimek haşlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~65 dk · Pasif bekleme ~60 dk · Toplam ~125 dk

**Kaynak:** Kütahya Tosunumu, Türk Patent Coğrafi İşaret Tescil No 1665 (15-16 adet; porsiyonda 1 adet).',
            '[{"sira": 1, "ad": "Hamur ve Katlama", "sure_dakika": 50, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Mercimek Haşlama", "sure_dakika": 25, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YEŞİL MERCİMEK"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kesme ve Doldurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "SU", "TUZ", "HAŞHAŞ", "AYÇİÇEK YAĞI", "TEREYAĞI", "KARABİBER", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Niğde Usulü Elmalı Cevizli Tatlı -> Niğde Sarım Burma Tatlısı (CI 1715)
    select id into v_id from receteler where isletme_id is null and ad = 'Niğde Usulü Elmalı Cevizli Tatlı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Niğde Usulü Elmalı Cevizli Tatlı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Niğde Sarım Burma Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Niğde Sarım Burma Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Niğde Usulü Elmalı Cevizli Tatlı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Niğde Usulü Elmalı Cevizli Tatlı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Niğde Sarım Burma Tatlısı', v_grup3_id, 1, 180,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 41.7}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 3.3}, {"ad": "SU", "miktar_gram": 56.3}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 6.4}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 21.1}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 4.2}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "SİRKE", "miktar_gram": 0.4}, {"ad": "TEREYAĞI", "miktar_gram": 16.7}, {"ad": "TOZ ŞEKER", "miktar_gram": 62.5}, {"ad": "LİMON SUYU", "miktar_gram": 0.8}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 50.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Niğde Sarım Burma Tatlısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Yumurta, ayçiçek yağı, sirke, tuz, süt ve suyu homojen karıştırın; unu yavaş yavaş ekleyip yumuşak kıvamda yoğurun. ~30 dakika dinlendirin.
2. Hamuru ceviz büyüklüğünde parçalara ayırın; nişasta serperek olabildiğince ince açın ve her yufkayı 4 eşit parçaya bölün.
3. Cevizi havanda dövün. Yufkalara ceviz koyup oklavaya sarın, büzgüleyerek şekil verin ve oklavadan sıyırıp tepsiye dizin. Eritilmiş tereyağı-sıvı yağ karışımını eşit dökün.

**Isıl İşlem**
1. Şerbet (~20 dk): Şeker, su ve limon suyunu kaynatıp soğutun.
2. Fırınlama (180°C, ~30 dk): Rengi pembeleşinceye kadar pişirin; 15 dakika soğutun.
3. Şerbetleme: Soğuk şerbeti sıcak tatlının üzerine dökün.

**Servis:** Şerbetini çekince servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken şerbet hazırlanıp soğutulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~88 dk · Pasif bekleme ~92 dk · Toplam ~180 dk

**Kaynak:** Niğde Sarım Burma Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1715 (12 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma, Sarma ve Büzgüleme", "sure_dakika": 70, "aktif_dakika": 70, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Şerbet", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "CEVİZ (İÇ)", "TEREYAĞI", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Soğutma ve Şerbetleme", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Niğde Usulü Zeytinyağlı Kereviz -> Bor Söğürmesi (CI 317)
    select id into v_id from receteler where isletme_id is null and ad = 'Niğde Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Niğde Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bor Söğürmesi') then
        raise notice 'Yeni ad zaten var, atlandi: Bor Söğürmesi';
    elsif _kopya_kullanimda_mi(v_id, 'Niğde Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Niğde Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bor Söğürmesi', v_grup1_id, 1, 80,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (SIRT)", "miktar_gram": 250.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 22.5}, {"ad": "YEŞİL BİBER", "miktar_gram": 41.3}, {"ad": "TUZ", "miktar_gram": 3.1}, {"ad": "PİDE", "miktar_gram": 110.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bor Söğürmesi', null, '**Hazırlık / Mise en Place**
1. Akkaraman kuzusunun en az bir gün dinlendirilmiş sırt/kaburga etini karkastan bütün kesin; üçlü veya dörtlü dilimlere ayırın.
2. Omur parçalarını uzaklaştırıp kaburga uzantılarını satırın tersiyle kırarak düzleştirin; etli kısımları 0,2-0,5 cm kalınlığında tabakalar halinde kesip satırın düz yüzüyle dövün. Üzerine ~0,5 cm aralıkla kanallar çizin ve tek tek tuzlayın. Kuyruk yağını kuşbaşı doğrayın.
3. Tepsiye önce biberleri dizin; üzerini kapatacak şekilde etleri yerleştirin, kuyruk yağlarını ve tuzu serpin.

**Isıl İşlem**
1. Fırınlama (pide fırını, odun ateşi, 35-45 dk).

**Servis:** Fırından yeni çıkmış 40-60 cm çapında pide ile sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk · Pasif bekleme ~35 dk · Toplam ~80 dk

**Kaynak:** Bor Söğürmesi, Türk Patent Coğrafi İşaret Tescil No 317 (en az 1 kg et; yaklaşık 4 kişilik).',
            '[{"sira": 1, "ad": "Et Hazırlığı", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Dizme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (SIRT)", "KUYRUKYAĞI", "YEŞİL BİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Zonguldak Usulü Elmalı Ceviz Tatlısı -> Devrek Cevizli Kömeci (CI 516)
    select id into v_id from receteler where isletme_id is null and ad = 'Zonguldak Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Zonguldak Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Devrek Cevizli Kömeci') then
        raise notice 'Yeni ad zaten var, atlandi: Devrek Cevizli Kömeci';
    elsif _kopya_kullanimda_mi(v_id, 'Zonguldak Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Zonguldak Usulü Elmalı Ceviz Tatlısı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Devrek Cevizli Kömeci', v_grup3_id, 1, 145,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 50.0}, {"ad": "SU", "miktar_gram": 30.0}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 10.3}, {"ad": "YOĞURT (TAM)", "miktar_gram": 5.0}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 2.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4.55}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 25.0}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 0.85}, {"ad": "ÇÖREKOTU", "miktar_gram": 0.5}, {"ad": "SUSAM", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Devrek Cevizli Kömeci', null, '**Hazırlık / Mise en Place**
1. Hamur: Elenmiş unun ortasında havuz açın; tuz ve yumurtayı karıştırıp su ve sütü azar azar ekleyerek kulak memesi yumuşaklığında yoğurun. 15-20 dakika daha yoğurup üzerini bezle örtün, 10 dakika dinlendirin.
2. Hamuru 3-4 bezeye ayırıp yeniden yoğurun, 10 dakika dinlendirin. Kızılcık oklavasıyla açın; yufkaların üzerini sıvı yağla yağlayıp yeniden açarak inceltin.
3. Yufkaların her yanına dövülmüş cevizi eşit serpin, rulo yapın. Yağlanmış bakır tepsiye sarmal biçimde dizin; üzerine çırpılmış yumurta sarısı sürüp çörek otu ve susam serpin.

**Isıl İşlem**
1. Fırınlama (175-200°C, ~1 saat).

**Servis:** Dilimleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~68 dk · Pasif bekleme ~77 dk · Toplam ~145 dk

**Kaynak:** Devrek Kömeci / Devrek Cevizli Kömeci, Türk Patent Coğrafi İşaret Tescil No 516 (yaklaşık 20 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 45, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma ve Sarma", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "SU", "SÜT (TAM YAĞ)", "YOĞURT (TAM)", "TAVUK YUMURTASI", "ZEYTİNYAĞI", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzincan Usulü Zeytinyağlı Nohutlu Kabak -> Erzincan Kesme Kadayıfı (CI 760)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzincan Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzincan Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzincan Kesme Kadayıfı') then
        raise notice 'Yeni ad zaten var, atlandi: Erzincan Kesme Kadayıfı';
    elsif _kopya_kullanimda_mi(v_id, 'Erzincan Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzincan Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzincan Kesme Kadayıfı', v_grup3_id, 1, 255,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "YOĞURT (TAM)", "miktar_gram": 6.8}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 28.1}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 4.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 29.8}, {"ad": "LİMON SUYU", "miktar_gram": 0.4}, {"ad": "TEREYAĞI", "miktar_gram": 29.5}, {"ad": "SİRKE", "miktar_gram": 1.8}, {"ad": "TUZ", "miktar_gram": 0.2}, {"ad": "BUĞDAY UNU", "miktar_gram": 50.0}, {"ad": "KABARTMA TOZU", "miktar_gram": 0.9}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.2}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 90.9}, {"ad": "TOZ ŞEKER", "miktar_gram": 109.1}, {"ad": "SU", "miktar_gram": 109.1}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzincan Kesme Kadayıfı', null, '**Hazırlık / Mise en Place**
1. Hamur: Tüm hamur malzemelerini karıştırıp ~35 dakika yoğurarak çok sert bir hamur elde edin. 12 bezeye bölüp 20 dakika dinlendirin.
2. Şerbet: Şeker, su ve limon suyunu orta ateşte yarım saat kaynatarak yoğun kıvamlı şerbet hazırlayın.
3. Bezelerden 6''sını 45 cm çapında açıp ~20 dakika hafifçe kurutun; keskin bıçakla dökme kadayıf kalınlığında kesin. Yağlanmış tepsiye yayıp iri kıyılmış cevizi dökün. Kalan 6 bezeden kesilen telleri üst katman olarak yayın; eritilmiş tereyağı-sıvı yağ karışımını üste dökün.

**Isıl İşlem**
1. Fırınlama (155°C, 40 dk): Üzeri kızarana kadar pişirin, 40 dakika soğutun.
2. Şerbetleme: Soğuyan tatlıya sıcak şerbeti dökün, yarım saat çekmesini bekleyin.

**Servis:** 12x12 cm dilimleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken şerbet kaynatılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~83 dk · Pasif bekleme ~172 dk · Toplam ~255 dk

**Kaynak:** Erzincan Kesme Kadayıfı, Türk Patent Coğrafi İşaret Tescil No 760 (45 cm tepsi, 12x12 cm dilim (~11 porsiyon)).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 55, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şerbet", "sure_dakika": 30, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma, Kurutma ve Kesme", "sure_dakika": 60, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "CEVİZ (İÇ)", "TEREYAĞI", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 5, "ad": "Soğutma ve Şerbetleme", "sure_dakika": 70, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Erzincan Usulü Zeytinyağlı Nohut -> Erzincan Sütlacı (CI 1813)
    select id into v_id from receteler where isletme_id is null and ad = 'Erzincan Usulü Zeytinyağlı Nohut';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Erzincan Usulü Zeytinyağlı Nohut';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzincan Sütlacı') then
        raise notice 'Yeni ad zaten var, atlandi: Erzincan Sütlacı';
    elsif _kopya_kullanimda_mi(v_id, 'Erzincan Usulü Zeytinyağlı Nohut') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Erzincan Usulü Zeytinyağlı Nohut';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzincan Sütlacı', v_grup3_id, 1, 53,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 171.7}, {"ad": "SU", "miktar_gram": 100.0}, {"ad": "KADAYIF", "miktar_gram": 50.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 41.7}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 16.7}, {"ad": "PİRİNÇ UNU", "miktar_gram": 8.3}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 2.8}, {"ad": "VANİLİN", "miktar_gram": 0.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzincan Sütlacı', null, '**Hazırlık / Mise en Place**
1. Pirinçleri temizleyip yıkayın, süzün.
2. Ayrılan ~200 ml süte pirinç unu ve yumurta sarısını ekleyip homojen karıştırın.

**Isıl İşlem**
1. Pirinç (~20 dk): Su ve pirinci yumuşayana kadar pişirin.
2. Sütlü pişirme (~20 dk): Kalan süt, şeker ve vanilini ekleyip karıştırarak pişirin; nişastalı sütü azar azar, karıştırmaya devam ederek ekleyin. Kıvam alınca ocaktan alın.
3. Fırın (200°C, ~10 dk): Porsiyonluk kaplara pay edip üzeri pişecek şekilde fırında bekletin.

**Servis:** Üzerine kesme kadayıf tatlısı koyup soğuk ya da ılık servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~30 dk · Toplam ~53 dk

**Kaynak:** Erzincan Sütlacı, Türk Patent Coğrafi İşaret Tescil No 1813 (6 porsiyon).',
            '[{"sira": 1, "ad": "Pirinç Haşlama", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Sütlü Pişirme", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜT (TAM YAĞ)", "TOZ ŞEKER", "VANİLİN", "PİRİNÇ UNU", "BIRAKIN YUMURTA SARISI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 10, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["KADAYIF"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Dikili Usulü Zeytinyağlı Semizotu -> Bergama Çığırtması (CI 1588)
    select id into v_id from receteler where isletme_id is null and ad = 'Dikili Usulü Zeytinyağlı Semizotu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Dikili Usulü Zeytinyağlı Semizotu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bergama Çığırtması') then
        raise notice 'Yeni ad zaten var, atlandi: Bergama Çığırtması';
    elsif _kopya_kullanimda_mi(v_id, 'Dikili Usulü Zeytinyağlı Semizotu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Dikili Usulü Zeytinyağlı Semizotu';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bergama Çığırtması', v_grup2_id, 1, 69,
            '["zeytinyagli", "vejetaryen"]'::jsonb, 'yaz', 'Ege',
            '[{"ad": "PATLICAN", "miktar_gram": 200.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 100.0}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "SARIMSAK", "miktar_gram": 11.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 22.75}, {"ad": "DOMATES", "miktar_gram": 110.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bergama Çığırtması', null, '**Hazırlık / Mise en Place**
1. Yumuşak ve ince kırçıllı ya da mor patlıcanları seçin; saplarını kesip boyuna şeritler halinde alacalı soyun. Bir uçtan diğerine spiral şeklinde, fazla derin olmayan çizikler atın.
2. Patlıcanları 8 g tuz katılmış 2 litre suda 15 dakika bekletin; çıkarıp kurulayın.
3. Biberlerin sapını temizleyip ikiye ayırın. Domatesleri söğüş doğrayın, sarımsakları temizleyin.

**Isıl İşlem**
1. Kızartma (~15 dk): Zeytinyağını iyice ısıtıp patlıcanları dizin, zaman zaman çevirerek kızartıp tepsiye alın. Biberleri de aynı şekilde kızartın.
2. Sos (~6 dk): Aynı tavada sarımsakları iki üç kez çevirin, domatesleri ekleyip ~5 dakika pişirin; 4 g tuzu ekleyip ocağı kapatın.
3. Fırınlama (200°C, 20-25 dk): Domatesli karışımı patlıcanların üzerine dökün ve pişirin. (Ya da tepsi kapağı kapalı ocakta 7-8 dakika.)

**Servis:** Ilık ya da soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~36 dk · Toplam ~69 dk

**Kaynak:** Bergama Çığırtması, Türk Patent Coğrafi İşaret Tescil No 1588 (yaklaşık 5 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık ve Tuzlu Su", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 150, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "YEŞİL BİBER", "ZEYTİNYAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 6, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SARIMSAK", "DOMATES", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 23, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- İzmir Usulü Zeytinyağlı Kabaklı Nohut -> İzmir Şambalisi (CI 205)
    select id into v_id from receteler where isletme_id is null and ad = 'İzmir Usulü Zeytinyağlı Kabaklı Nohut';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: İzmir Usulü Zeytinyağlı Kabaklı Nohut';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'İzmir Şambalisi') then
        raise notice 'Yeni ad zaten var, atlandi: İzmir Şambalisi';
    elsif _kopya_kullanimda_mi(v_id, 'İzmir Usulü Zeytinyağlı Kabaklı Nohut') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: İzmir Usulü Zeytinyağlı Kabaklı Nohut';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'İzmir Şambalisi', v_grup3_id, 1, 121,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "İRMİK", "miktar_gram": 33.3}, {"ad": "TOZ ŞEKER", "miktar_gram": 57.5}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 11.2}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 0.7}, {"ad": "KABARTMA TOZU", "miktar_gram": 0.8}, {"ad": "BADEM (İÇ)", "miktar_gram": 2.0}, {"ad": "SU", "miktar_gram": 25.0}, {"ad": "LİMON SUYU", "miktar_gram": 0.5}, {"ad": "VANİLİN", "miktar_gram": 0.1}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'İzmir Şambalisi', null, '**Hazırlık / Mise en Place**
1. Şerbet: Su ve şekeri kaynatın; kaynadıktan sonra 10 dakika kaynama sıcaklığında tutun. Limon ve vanilya ekleyip en fazla 5 dakika daha kaynatın, soğutun.
2. Hamur: İrmik, şeker, nişasta ve kabartma tozunu karıştırın; süt (veya yoğurt) ekleyip homojen hamur olana kadar yoğurun.
3. Hamuru tepsiye 2,5-3,5 cm eşit kalınlıkta elle bastırarak yayın. Her dilime en az bir badem/fıstık gelecek şekilde eşit aralıklarla hafifçe bastırarak dizin.

**Isıl İşlem**
1. Fırınlama (180°C, 40-45 dk): Pişirin; tepside dikdörtgen dilimleyip 15 dakika daha pişirin.
2. Şerbetleme: Soğutulmuş şerbeti tepsi tabanından 0,5-0,6 cm yüksekliğe kadar dökün ve soğutun.

**Servis:** Dilim 7-10 cm uzunlukta, 2,5-3,5 cm kalınlıkta servis edilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~96 dk · Toplam ~121 dk

**Kaynak:** İzmir Şambalisi, Türk Patent Coğrafi İşaret Tescil No 205 (1 kg irmik oranı; yaklaşık 30 dilim).',
            '[{"sira": 1, "ad": "Şerbet", "sure_dakika": 18, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU", "VANİLİN"], "yeni_su_gram": null}, {"sira": 2, "ad": "Hamur ve Tepsi", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 58, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["İRMİK", "SÜT (TAM YAĞ)", "BUĞDAY NİŞASTASI", "KABARTMA TOZU", "BADEM (İÇ)"], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbetleme ve Soğutma", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- İzmir Usulü Etli Kavurma (Kimyonlu) -> Tire Şiş Köfte (CI 671)
    select id into v_id from receteler where isletme_id is null and ad = 'İzmir Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: İzmir Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Tire Şiş Köfte') then
        raise notice 'Yeni ad zaten var, atlandi: Tire Şiş Köfte';
    elsif _kopya_kullanimda_mi(v_id, 'İzmir Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: İzmir Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Tire Şiş Köfte', v_grup1_id, 1, 75,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "DANA KIYMA", "miktar_gram": 190.0}, {"ad": "TUZ", "miktar_gram": 3.8}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}, {"ad": "DOMATES", "miktar_gram": 50.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Tire Şiş Köfte', null, '**Hazırlık / Mise en Place**
1. Yağ oranı en fazla %20 dana/sığır etini kemik, damar, sinir, zar ve fazla yağından ayıklayın; en fazla %2 tuzlayın (isteğe göre en fazla %2 un). Başka bir şey eklenmez.
2. Eti 3-3,5''luk süzgeçten iki kez çekin; 0-4°C''de 16-24 saat dinlendirin. Tekrar çekip 50 cm''lik krom kare şişlere ince uzun köfte olarak sıkın.

**Isıl İşlem**
1. Tütsüleme (odun ateşi): Mangalda merkez ısı en az 72°C olana kadar ön pişirme yapın; şişten çıkarıp oda sıcaklığında soğutun, 0-4°C''de 16-24 saat dinlendirin.
2. Tavada pişirme: Bakır tavada tereyağında, isteğe göre domates ekleyerek pişirin.

**Servis:** 150 g''lık porsiyonlarda sıcak; isteğe göre yoğurtlu tabakta ve kıyılmış maydanozla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk · Pasif bekleme ~30 dk · Toplam ~75 dk (16-24 saatlik iki dinlendirme hariç)

**Kaynak:** Tire Şiş Köfte, Türk Patent Coğrafi İşaret Tescil No 671 (porsiyon 150 g).',
            '[{"sira": 1, "ad": "Kıyma Hazırlığı", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şişe Sıkma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Tütsüleme", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Soğutma", "sure_dakika": 30, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Tavada Pişirme", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "DOMATES"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Ödemiş Usulü Nohutlu Tavuk Sote -> Ödemiş Köftesi (CI 720)
    select id into v_id from receteler where isletme_id is null and ad = 'Ödemiş Usulü Nohutlu Tavuk Sote';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Ödemiş Usulü Nohutlu Tavuk Sote';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ödemiş Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Ödemiş Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Ödemiş Usulü Nohutlu Tavuk Sote') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Ödemiş Usulü Nohutlu Tavuk Sote';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ödemiş Köftesi', v_grup1_id, 1, 40,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "DANA KIYMA", "miktar_gram": 100.0}, {"ad": "İRMİK", "miktar_gram": 100.0}, {"ad": "TUZ", "miktar_gram": 0.65}, {"ad": "KİMYON", "miktar_gram": 0.3}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "KEKİK", "miktar_gram": 0.4}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 100.0}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.0}, {"ad": "DOMATES", "miktar_gram": 40.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ödemiş Köftesi', null, '**Hazırlık / Mise en Place**
1. Dana veya doğurmamış düve etinden kıyma çekip karıştırın. İrmik, tuz, kimyon, karabiber ve kekiği ekleyip karma makinesiyle irmik görünmez hale gelene kadar (yazın ~8, kışın ~5 dakika) karıştırın.
2. Hamuru yavaş devirli kıyma makinesinden geçirip silindir halinde çıkan hamurdan 14-15 cm köfteler kesin; tepsilere dizip 0-4°C''de 8-12 saat dinlendirin.

**Isıl İşlem**
1. Izgara: Odun kömürüyle normal ateşte, köfte ile ateş arasında ~10 cm olacak şekilde pişirin (pişmiş boy 9-11 cm).
2. Tereyağı: Tereyağını eritip acı olmayan kırmızı toz biber ekleyin. Domates dilimlerini bakır tavada tereyağında diriliğini kaybetmeden pişirin.

**Servis:** Dikey ve dikdörtgen dilimlenmiş ekmeği biberli yağa bandırın; porsiyonda 7 köfte, domates ve isteğe göre közlenmiş biberle servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~0 dk · Toplam ~40 dk (8-12 saat dinlendirme hariç)

**Kaynak:** Ödemiş Köftesi, Türk Patent Coğrafi İşaret Tescil No 720 (porsiyon 7 köfte; ~10 porsiyon).',
            '[{"sira": 1, "ad": "Karıştırma ve Şekil", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "İRMİK"], "yeni_su_gram": null}, {"sira": 3, "ad": "Tereyağı ve Domates", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "TATLIKA KIRMIZI BİBER", "DOMATES"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["EKMEK (BEYAZ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Elazığ Usulü Etli Kavurma (Kimyonlu) -> Palu Tava (CI 1814)
    select id into v_id from receteler where isletme_id is null and ad = 'Elazığ Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Elazığ Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Palu Tava') then
        raise notice 'Yeni ad zaten var, atlandi: Palu Tava';
    elsif _kopya_kullanimda_mi(v_id, 'Elazığ Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Elazığ Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Palu Tava', v_grup1_id, 1, 140,
            '["kirmizi_et"]'::jsonb, 'yaz', 'Doğu Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 250.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 166.7}, {"ad": "KUYRUKYAĞI", "miktar_gram": 33.3}, {"ad": "TEREYAĞI", "miktar_gram": 16.7}, {"ad": "TUZ", "miktar_gram": 2.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Palu Tava', null, '**Hazırlık / Mise en Place**
1. Biberleri yıkayıp istenen büyüklükte parçalayın; sap ve çekirdeklerini temizleyin.
2. Toprak tava ya da çömleğin zeminine biberleri serin. Etleri biberlerin üzerini örtecek şekilde dizin; doğranmış iç/kuyruk yağını ve tereyağını etin üzerine koyun, tuzu ekleyin.

**Isıl İşlem**
1. Pişirme (~2 saat): Üstü kapalı olarak, tercihen odun ateşinde ısıtılan taş zeminli fırında pişirin.

**Servis:** Ekmek ya da pide ile sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~115 dk · Toplam ~140 dk

**Kaynak:** Palu Tava, Türk Patent Coğrafi İşaret Tescil No 1814 (6 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık ve Dizme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 120, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (KOL)", "YEŞİL BİBER", "KUYRUKYAĞI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Elazığ Usulü Zeytinyağlı Pırasa -> Elazığ Taş Ekmeği Tatlısı (CI 1440)
    select id into v_id from receteler where isletme_id is null and ad = 'Elazığ Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Elazığ Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Elazığ Taş Ekmeği Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Elazığ Taş Ekmeği Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Elazığ Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Elazığ Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Elazığ Taş Ekmeği Tatlısı', v_grup3_id, 1, 85,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 31.25}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 12.5}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 106.2}, {"ad": "SU", "miktar_gram": 134.4}, {"ad": "KURU MAYA", "miktar_gram": 0.6}, {"ad": "TOZ ŞEKER", "miktar_gram": 125.6}, {"ad": "TUZ", "miktar_gram": 0.6}, {"ad": "TEREYAĞI", "miktar_gram": 12.5}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 31.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Elazığ Taş Ekmeği Tatlısı', null, '**Hazırlık / Mise en Place**
1. Taş ekmeği hamuru: Yumurtaları tuzla 4-5 dakika tahta kaşıkla çırpın; sütü ekleyip karıştırın. Ilık suda erittiğiniz mayayı ve şekeri ekleyin; unu katarak akıcı kıvamda hamur elde edin.

**Isıl İşlem**
1. Şerbet (10 dk): Şeker ve suyu kaynatıp soğutun.
2. Taş ekmekleri: Bez sarılı ahşap spatulayı eritilmiş tereyağına batırıp ısıtılmış sacı 5 dakika yağlayın. Kepçeyle 100''er g hamur dökün, iki yüzünü ikişer dakika kızartın.
3. Tatlı: Taş ekmeklerini soğumuş şerbete batırıp çıkarın, üzerlerine eritilmiş tereyağı sürün; ikinci ve beşinci katlara ceviz serperek üst üste dizin.

**Servis:** Servis edin; buzdolabında 3 güne kadar saklanır.

**SÜRE ÖZETİ:** Aktif işçilik ~73 dk · Pasif bekleme ~12 dk · Toplam ~85 dk

**Kaynak:** Elazığ Taş Ekmeği Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1440 (8 kişilik).',
            '[{"sira": 1, "ad": "Hamur", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şerbet", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sacda Pişirme", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "TAVUK YUMURTASI", "SÜT (TAM YAĞ)", "KURU MAYA", "TUZ", "TEREYAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbetleme ve Dizme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kayseri Usulü Zeytinyağlı Pırasa -> Kayseri Kurşun Aşı Çorbası (CI 950)
    select id into v_id from receteler where isletme_id is null and ad = 'Kayseri Usulü Zeytinyağlı Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kayseri Usulü Zeytinyağlı Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kayseri Kurşun Aşı Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Kayseri Kurşun Aşı Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Kayseri Usulü Zeytinyağlı Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kayseri Usulü Zeytinyağlı Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kayseri Kurşun Aşı Çorbası', v_grup2_id, 1, 120,
            '["corba"]'::jsonb, 'kis', 'İç Anadolu',
            '[{"ad": "İNCE BULGUR", "miktar_gram": 48.6}, {"ad": "BUĞDAY UNU", "miktar_gram": 2.9}, {"ad": "İRMİK", "miktar_gram": 6.9}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 7.1}, {"ad": "SU", "miktar_gram": 257.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 4.3}, {"ad": "TUZ", "miktar_gram": 1.4}, {"ad": "KUZU ETİ (BUT)", "miktar_gram": 57.1}, {"ad": "NOHUT", "miktar_gram": 9.7}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 10.9}, {"ad": "KURU SOĞAN", "miktar_gram": 31.4}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 9.2}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.1}, {"ad": "KURU NANE", "miktar_gram": 0.7}, {"ad": "PUL BİBER", "miktar_gram": 0.3}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "KİMYON", "miktar_gram": 0.3}, {"ad": "LİMON SUYU", "miktar_gram": 2.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kayseri Kurşun Aşı Çorbası', null, '**Hazırlık / Mise en Place**
1. Bulgur köftesi: Bulgur ve irmiği bir kaba alın, sıcak su ekleyip üzerini bezle örterek suyunu çekmesini bekleyin. Un, biber salçası ve tuzu ekleyip yoğurun; yumurtayı kırıp macun kıvamına gelene kadar yoğurun.
2. Birkaç damla yağ damlatılmış suyla elleri ıslatarak nohut büyüklüğünde (1-1,5 cm, ~2 g) köfteler yuvarlayın; unlanmış tepsiye dizin.

**Isıl İşlem**
1. Kavurma (~10 dk): Küçük doğranmış kuzu etini suyunu çekene kadar kavurun; ayçiçek yağı ve çekilmiş soğanı ekleyin. Soğan pembeleşince salçaları ekleyip kavurun.
2. Su (15 dk): 1,5 litre ılık su, karabiber, tuz ve kimyonu ekleyip kaynatın. Kıvam koyu olmalıdır.
3. Pişirme (20 dk): Bulgur köfteleri, haşlanmış nohut ve mercimeği ekleyip kapağı kapalı kısık ateşte az sulu kıvama kadar pişirin.
4. Dinlendirme (~30 dk).

**Servis:** Üzerine kuru nane ve limon suyu gezdirip servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~47 dk · Pasif bekleme ~73 dk · Toplam ~120 dk

**Kaynak:** Kayseri Kurşun Aşı Çorbası, Türk Patent Coğrafi İşaret Tescil No 950 (6-8 kişilik).',
            '[{"sira": 1, "ad": "Bulgur Köftesi", "sure_dakika": 45, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (BUT)", "KURU SOĞAN", "AYÇİÇEK YAĞI", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Su Kaynatma", "sure_dakika": 15, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "TUZ", "KARABİBER", "KİMYON"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İNCE BULGUR", "İRMİK", "BUĞDAY UNU", "TAVUK YUMURTASI", "NOHUT", "YEŞİL MERCİMEK"], "yeni_su_gram": null}, {"sira": 5, "ad": "Dinlendirme ve Servis", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["KURU NANE", "PUL BİBER", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kırıkkale Usulü Etli Bulgur Pilavı -> Karaahmetli Tokmak Köfte (CI 1781)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırıkkale Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırıkkale Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Karaahmetli Tokmak Köfte') then
        raise notice 'Yeni ad zaten var, atlandi: Karaahmetli Tokmak Köfte';
    elsif _kopya_kullanimda_mi(v_id, 'Kırıkkale Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırıkkale Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Karaahmetli Tokmak Köfte', v_grup1_id, 1, 90,
            '["beyaz_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "BULGUR", "miktar_gram": 118.4}, {"ad": "TAVUK BUT", "miktar_gram": 78.9}, {"ad": "TAVUK GÖĞÜS", "miktar_gram": 19.7}, {"ad": "DONYAĞI", "miktar_gram": 7.9}, {"ad": "KURU SOĞAN", "miktar_gram": 39.5}, {"ad": "SARIMSAK", "miktar_gram": 7.9}, {"ad": "PUL BİBER", "miktar_gram": 1.2}, {"ad": "TUZ", "miktar_gram": 1.6}, {"ad": "KURU NANE", "miktar_gram": 0.4}, {"ad": "SU", "miktar_gram": 23.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Karaahmetli Tokmak Köfte', null, '**Hazırlık / Mise en Place**
1. Kaba önce tavukları koyun, üzerine bulgurun yarısını dökün ve tokmakla dövmeye başlayın. Tavuk ve bulgur özdeşleşmeye başlayınca kavrulmuş iç yağını ekleyip dövmeye devam edin.
2. Soğan ve sarımsağı birlikte ekleyin; ara ara ~50 ml su dökün, köfteyi elle alt üst edin. Kuru nane, biber ve tuzu katıp yoğurun. Hamur haline gelinceye kadar (~1 saat) dövmeye devam edin.
3. Hamuru 150 g''lık avuç içi büyüklüğünde bezelere ayırın; bir eli suyla ıslatarak daire şekli verip yan yana dizin.

**Isıl İşlem**
1. Pişirme: Meşe kömürü mangalında (veya kızgın yağda) pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~90 dk · Pasif bekleme ~0 dk · Toplam ~90 dk

**Kaynak:** Karaahmetli Tokmak Köfte, Türk Patent Coğrafi İşaret Tescil No 1781 (porsiyonda 2 beze (150 g)).',
            '[{"sira": 1, "ad": "Tokmakla Dövme", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şekillendirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Mangalda Pişirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "TAVUK BUT", "TAVUK GÖĞÜS", "DONYAĞI", "KURU SOĞAN", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya -> Kırıkkale Keskin Tava (CI 311)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kırıkkale Keskin Tava') then
        raise notice 'Yeni ad zaten var, atlandi: Kırıkkale Keskin Tava';
    elsif _kopya_kullanimda_mi(v_id, 'Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kırıkkale Keskin Tava', v_grup1_id, 1, 75,
            '["kirmizi_et"]'::jsonb, 'yaz', 'İç Anadolu',
            '[{"ad": "KUZU PİRZOLA", "miktar_gram": 250.0}, {"ad": "DOMATES", "miktar_gram": 110.0}, {"ad": "SARIMSAK", "miktar_gram": 12.5}, {"ad": "YEŞİL BİBER", "miktar_gram": 15.0}, {"ad": "TEREYAĞI", "miktar_gram": 7.5}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "PUL BİBER", "miktar_gram": 1.75}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kırıkkale Keskin Tava', null, '**Hazırlık / Mise en Place**
1. Fırın tepsisini yağlayın; üzerine biber ve domatesleri doğrayın. Sarımsakları birkaç parçaya bölüp tepsiye ekleyin.
2. Kuzu pirzolaları malzemelerin üzerine düzgünce dizin. Etlerin üzerine ufak parçalar halinde tereyağı koyun; tuz ve pul biber serpin. Tepsiyi alüminyum folyoyla tamamen sarın.

**Isıl İşlem**
1. Fırınlama (200°C, 1 saat): Önceden ısıtılmış (tercihen odun) fırında pişirin; son 10 dakika folyoyu açıp pişirmeye devam edin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~57 dk · Toplam ~75 dk

**Kaynak:** Kırıkkale Keskin Tava, Türk Patent Coğrafi İşaret Tescil No 311 (1 kg pirzola; yaklaşık 4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU PİRZOLA", "DOMATES", "SARIMSAK", "YEŞİL BİBER", "TEREYAĞI", "TUZ", "PUL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Osmaniye Usulü Etli Bulgur Pilavı -> Osmaniye Zorkun Tava (CI 1477)
    select id into v_id from receteler where isletme_id is null and ad = 'Osmaniye Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Osmaniye Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Osmaniye Zorkun Tava') then
        raise notice 'Yeni ad zaten var, atlandi: Osmaniye Zorkun Tava';
    elsif _kopya_kullanimda_mi(v_id, 'Osmaniye Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Osmaniye Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Osmaniye Zorkun Tava', v_grup1_id, 1, 110,
            '["kirmizi_et"]'::jsonb, 'yaz', 'Akdeniz',
            '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 250.0}, {"ad": "KUYRUKYAĞI", "miktar_gram": 25.0}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "DOMATES", "miktar_gram": 250.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 11.25}, {"ad": "KIRMIZI BİBER", "miktar_gram": 30.0}, {"ad": "SARIMSAK", "miktar_gram": 18.75}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Osmaniye Zorkun Tava', null, '**Hazırlık / Mise en Place**
1. Kuzunun but ve ön kol etlerini kuşbaşı doğrayıp tepsiye koyun. Üzerine ince doğranmış kırmızı kuru soğan, sarımsak ve biberleri ekleyin; tuz ve toz biber serpin.
2. Domateslerin kabuklarını soyup doğrayın ve karışımın üzerine yayın; domateslerin üzerini kuyruk yağıyla kaplayın.

**Isıl İşlem**
1. Fırınlama (taş fırın, ~1,5 saat): Tepsinin üzerine sac kapatıp pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~87 dk · Toplam ~110 dk

**Kaynak:** Osmaniye Zorkun Tava, Türk Patent Coğrafi İşaret Tescil No 1477 (1 kg et; yaklaşık 4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık ve Dizme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 90, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (BUT)", "KUYRUKYAĞI", "KURU SOĞAN", "DOMATES", "YEŞİL BİBER", "KIRMIZI BİBER", "SARIMSAK", "TATLIKA KIRMIZI BİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Batman Usulü Zeytinyağlı Bakla -> Batman Şam Böreği (CI 302)
    select id into v_id from receteler where isletme_id is null and ad = 'Batman Usulü Zeytinyağlı Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Batman Usulü Zeytinyağlı Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Batman Şam Böreği') then
        raise notice 'Yeni ad zaten var, atlandi: Batman Şam Böreği';
    elsif _kopya_kullanimda_mi(v_id, 'Batman Usulü Zeytinyağlı Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Batman Usulü Zeytinyağlı Bakla';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Batman Şam Böreği', v_grup2_id, 1, 130,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 100.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 5.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 1.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 9.7}, {"ad": "SU", "miktar_gram": 25.0}, {"ad": "TUZ", "miktar_gram": 2.0}, {"ad": "DANA KIYMA", "miktar_gram": 100.0}, {"ad": "KURU SOĞAN", "miktar_gram": 60.5}, {"ad": "MAYDANOZ", "miktar_gram": 5.0}, {"ad": "PUL BİBER", "miktar_gram": 1.0}, {"ad": "KARABİBER", "miktar_gram": 1.0}, {"ad": "YENİBAHAR", "miktar_gram": 1.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Batman Şam Böreği', null, '**Hazırlık / Mise en Place**
1. Hamur: Unu yumurtayla karıştırıp yoğurmaya başlayın; yoğurt, sıvı yağ, ılık su ve tuzu ekleyip iyice yoğurun. 30 dakika dinlendirin.
2. İç harç: Soğan ve maydanozu ince kıyın. Soğanları tencerede yağla öldürün; az yağlı kıymayı ekleyip kavurun. Maydanoz, pul biber, karabiber, yenibahar ve tuzu ekleyip soğutun.
3. Hamuru ceviz büyüklüğünde eşit parçalara bölüp merdaneyle 10 cm çapında açın; ortalarına harcı paylaştırıp yarım ay şeklinde kapatın.

**Isıl İşlem**
1. Kızartma: Sıvı yağı tavada kızdırıp börekleri iki yüzü altın sarısı olana kadar kızartın; kağıt havlu üzerinde yağını süzdürün.

**Servis:** Tüm börekler kızartıldıktan sonra servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~95 dk · Pasif bekleme ~35 dk · Toplam ~130 dk

**Kaynak:** Batman Şam Böreği, Türk Patent Coğrafi İşaret Tescil No 302 (yaklaşık 10 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "MAYDANOZ", "PUL BİBER", "KARABİBER", "YENİBAHAR"], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma ve Kapatma", "sure_dakika": 45, "aktif_dakika": 45, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 170, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "TAVUK YUMURTASI", "YOĞURT (TAM)", "AYÇİÇEK YAĞI", "SU", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Muğla Usulü Zeytinyağlı Kereviz -> Milas Ekşili Köfte (CI 1209)
    select id into v_id from receteler where isletme_id is null and ad = 'Muğla Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Muğla Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Milas Ekşili Köfte') then
        raise notice 'Yeni ad zaten var, atlandi: Milas Ekşili Köfte';
    elsif _kopya_kullanimda_mi(v_id, 'Muğla Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Muğla Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Milas Ekşili Köfte', v_grup1_id, 1, 95,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "DANA KIYMA", "miktar_gram": 125.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 62.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 22.75}, {"ad": "KURU SOĞAN", "miktar_gram": 37.5}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 2.5}, {"ad": "DOMATES", "miktar_gram": 13.75}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 5.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 5.0}, {"ad": "NOHUT", "miktar_gram": 5.0}, {"ad": "SU", "miktar_gram": 125.0}, {"ad": "SARIMSAK", "miktar_gram": 1.9}, {"ad": "LİMON SUYU", "miktar_gram": 5.0}, {"ad": "MAYDANOZ", "miktar_gram": 3.1}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Milas Ekşili Köfte', null, '**Hazırlık / Mise en Place**
1. Köfte: İnce rendelenmiş soğan, kıyma, tuz, karabiber ve unu yoğurun; eller zeytinyağıyla yağlanır. Soğanlar ayırt edilmez hale gelince bırakın.
2. Hamuru ~100 g''lık bezelere ayırın; unlanmış tahtada 1-1,5 cm kalınlığında yuvarlayıp 2,5-3 cm kesin, unlanmış elde mekik şekli verin.

**Isıl İşlem**
1. Kızartma: Derin kapta 150 ml zeytinyağını kızdırıp köfteleri kızartın, süzün.
2. Sos (~8 dk): 50 ml zeytinyağında ince doğranmış soğanı sararıncaya kadar kavurun; domates ve salçaları ekleyip karıştırın, sıcak suyu ekleyin.
3. Pişirme (~30 dk): Kaynayınca nohut ve köfteleri ekleyip köfteler yumuşayana kadar orta ateşte pişirin. Dövülmüş sarımsağı limon suyunda çırpıp ekleyin, bir taşım daha kaynatın.

**Servis:** Tabakta, üzerine birkaç yaprak maydanozla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~67 dk · Pasif bekleme ~28 dk · Toplam ~95 dk

**Kaynak:** Milas Ekşili Köfte, Türk Patent Coğrafi İşaret Tescil No 1209 (1 kg kıyma; yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Köfte Hamuru ve Şekil", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 160, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "BUĞDAY UNU", "ZEYTİNYAĞI", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DOMATES", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 32, "aktif_dakika": 4, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "SARIMSAK", "LİMON SUYU", "MAYDANOZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Fethiye Usulü Zeytinyağlı Bakla -> Milas Çıntar Kavurması (CI 1490)
    select id into v_id from receteler where isletme_id is null and ad = 'Fethiye Usulü Zeytinyağlı Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Fethiye Usulü Zeytinyağlı Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Milas Çıntar Kavurması') then
        raise notice 'Yeni ad zaten var, atlandi: Milas Çıntar Kavurması';
    elsif _kopya_kullanimda_mi(v_id, 'Fethiye Usulü Zeytinyağlı Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Fethiye Usulü Zeytinyağlı Bakla';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Milas Çıntar Kavurması', v_grup2_id, 1, 42,
            '["zeytinyagli", "vejetaryen"]'::jsonb, 'sonbahar', 'Ege',
            '[{"ad": "MANTAR", "miktar_gram": 150.0}, {"ad": "KURU SOĞAN", "miktar_gram": 27.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 22.75}, {"ad": "PUL BİBER", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 1.4}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "LİMON SUYU", "miktar_gram": 2.5}, {"ad": "MAYDANOZ", "miktar_gram": 2.0}, {"ad": "TAZE DEREOTU", "miktar_gram": 2.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Milas Çıntar Kavurması', null, '**Hazırlık / Mise en Place**
1. Ormandan toplanan çıntar mantarlarını parçalamadan bol suyla iyice yıkayıp süzün.

**Isıl İşlem**
1. Haşlama (15 dk): Kaynayan suya koyup kaynatın; çıkarıp istenen büyüklükte doğrayın.
2. Kavurma (~15 dk): İnce doğranmış soğanları kızgın zeytinyağında pembeleşinceye kadar kavurun. Sırasıyla mantar, tuz, karabiber ve pul biberi ekleyip mantarların saldığı su tamamen çekilinceye kadar kavurun.

**Servis:** Porselen tabakta, üzerine çeyrek limon sıkıp yanına bir dilim limon, birkaç dal maydanoz ve dereotuyla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~15 dk · Toplam ~42 dk

**Kaynak:** Milas Çıntar Kavurması, Türk Patent Coğrafi İşaret Tescil No 1490 (4 porsiyon).',
            '[{"sira": 1, "ad": "Yıkama", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MANTAR"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kavurma", "sure_dakika": 15, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "ZEYTİNYAĞI", "PUL BİBER", "KARABİBER", "TUZ"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 2, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["LİMON SUYU", "MAYDANOZ", "TAZE DEREOTU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı -> Muğla Saraylısı (CI 346)
    select id into v_id from receteler where isletme_id is null and ad = 'Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Muğla Saraylısı') then
        raise notice 'Yeni ad zaten var, atlandi: Muğla Saraylısı';
    elsif _kopya_kullanimda_mi(v_id, 'Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Muğla Saraylısı', v_grup3_id, 1, 225,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "YUFKA", "miktar_gram": 18.0}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 17.0}, {"ad": "SADEYAĞ", "miktar_gram": 15.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 24.0}, {"ad": "SU", "miktar_gram": 16.0}, {"ad": "BUĞDAY NİŞASTASI", "miktar_gram": 2.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Muğla Saraylısı', null, '**Hazırlık / Mise en Place**
1. Yufka hamurunu yumurta büyüklüğünde bezelere ayırıp 15 dakika dinlendirin; kurumadan nişasta yardımıyla baklava hamurundan biraz kalın açın.
2. Açılan yufkayı temiz bir bez üzerine alıp iri dövülmüş cevizi serpin; bezin kenarından tutarak rulo yapın. Kendi etrafında döndürüp yuvarlak tepsinin ortasına koyun; diğer bezeleri de ortadakinin etrafına sarın.
3. Üzerine bol sadeyağ gezdirip yağı çekene kadar bekleyin.

**Isıl İşlem**
1. Fırınlama (215°C).
2. Şerbet: %60 şeker, %40 su ve eser miktarda limon tuzunu kaynatın.
3. Şerbetleme: Pişen saraylının üzerine ılık şerbeti dökün (saraylı ve şerbet aynı sıcaklıkta olmalı); birkaç saat dinlendirin.

**Servis:** Dilimleyip servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~68 dk · Pasif bekleme ~157 dk · Toplam ~225 dk

**Kaynak:** Muğla Saraylısı, Türk Patent Coğrafi İşaret Tescil No 346 (1 kg ürün; porsiyon 100 g).',
            '[{"sira": 1, "ad": "Bezeleme ve Açma", "sure_dakika": 40, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sarma ve Dizme", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 35, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["YUFKA", "CEVİZ (İÇ)", "SADEYAĞ", "BUĞDAY NİŞASTASI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbet ve Dinlendirme", "sure_dakika": 120, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Tekirdağ Usulü Zeytinyağlı Bakla -> Küçükyoncalı Keşkeği (CI 1654)
    select id into v_id from receteler where isletme_id is null and ad = 'Tekirdağ Usulü Zeytinyağlı Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Tekirdağ Usulü Zeytinyağlı Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Küçükyoncalı Keşkeği') then
        raise notice 'Yeni ad zaten var, atlandi: Küçükyoncalı Keşkeği';
    elsif _kopya_kullanimda_mi(v_id, 'Tekirdağ Usulü Zeytinyağlı Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Tekirdağ Usulü Zeytinyağlı Bakla';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Küçükyoncalı Keşkeği', v_grup2_id, 1, 120,
            '["pilav", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 142.9}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 220.7}, {"ad": "TEREYAĞI", "miktar_gram": 71.4}, {"ad": "TUZ", "miktar_gram": 3.9}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 19.7}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.8}, {"ad": "SU", "miktar_gram": 150.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Küçükyoncalı Keşkeği', null, '**Hazırlık / Mise en Place**
1. Keşkeklik buğdayı ayıklayıp bol suda yıkayın.

**Isıl İşlem**
1. Pişirme (1-1,5 saat): Üzerini 3-4 parmak geçecek kadar su ekleyip (tercihen odun ateşinde kazanda) pişirin. Kaynayıp biraz yumuşayınca inek sütü ve tereyağını (250 g) ekleyin; 45-50 dakika daha pişirin. Yeterince yumuşayınca büyük tahta kaşıklarla tüm malzemeler birleşinceye kadar dövün.
2. Demleme (30-40 dk): Ateşten alıp kazanın üzerini örterek demlendirin.
3. Sos: Tereyağı (250 g) ve sıvı yağı tavada çiğ kalmayıncaya kadar kaynatın; 1-2 dakika dinlendirip kırmızı toz biberi ekleyin.

**Servis:** Keşkeği iyice karıştırıp kâseye alın, üzerine biberli yağı dökerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~95 dk · Toplam ~120 dk

**Kaynak:** Küçükyoncalı Keşkeği, Türk Patent Coğrafi İşaret Tescil No 1654 (6-8 kişilik).',
            '[{"sira": 1, "ad": "Pişirme ve Dövme", "sure_dakika": 80, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY (TAM TANE)", "SÜT (TAM YAĞ)", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Demleme", "sure_dakika": 35, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AYÇİÇEK YAĞI", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz -> Çorlu Kuzu Ciğer Sarma (CI 1604)
    select id into v_id from receteler where isletme_id is null and ad = 'Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Çorlu Kuzu Ciğer Sarma') then
        raise notice 'Yeni ad zaten var, atlandi: Çorlu Kuzu Ciğer Sarma';
    elsif _kopya_kullanimda_mi(v_id, 'Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Çorlu Kuzu Ciğer Sarma', v_grup1_id, 1, 110,
            '["kirmizi_et", "pilav"]'::jsonb, 'ilkbahar', 'Marmara',
            '[{"ad": "YENİLEBİLİR SAKATAT (DANA KARACİĞER)", "miktar_gram": 80.0}, {"ad": "YENİLEBİLİR SAKATAT (DANA AKCİĞER)", "miktar_gram": 40.0}, {"ad": "YENİLEBİLİR SAKATAT (DANA KALP)", "miktar_gram": 20.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 100.0}, {"ad": "KURU SOĞAN", "miktar_gram": 66.0}, {"ad": "TEREYAĞI", "miktar_gram": 20.0}, {"ad": "TAZE NANE", "miktar_gram": 10.0}, {"ad": "MAYDANOZ", "miktar_gram": 5.0}, {"ad": "ÇAM FISTIĞI", "miktar_gram": 20.0}, {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 20.0}, {"ad": "TUZ", "miktar_gram": 3.0}, {"ad": "KARABİBER", "miktar_gram": 1.6}, {"ad": "KEKİK", "miktar_gram": 1.4}, {"ad": "ET SUYU", "miktar_gram": 60.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 20.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 30.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Çorlu Kuzu Ciğer Sarma', null, '**Hazırlık / Mise en Place**
1. Kuzu gömleğini tepsiye koyup üzerine sıcak su ekleyerek çözülmeye bırakın.
2. Pirinci önceden ıslatıp yıkayın.

**Isıl İşlem**
1. Ciğer haşlama (~20 dk): Kuzu ciğer takımını (karaciğer, akciğer, böbrek, dalak, yürek) haşlayıp küp doğrayın.
2. İç harç (~20 dk): İnce doğranmış soğan ve dolmalık fıstığı tereyağında kavurun; ciğerleri ekleyip kavurmaya devam edin. Pirinç, kuş üzümü, tuz, karabiber, kekik ve çok ince kıyılmış maydanoz-naneyi ekleyip kavurun. Sıcak et suyunu (200 ml) ekleyip demlenmeye bırakın.
3. Sarma: Gömleği ~10x10 cm kareler kesip tek tek kâseye yerleştirin; bol harç koyup taşırmadan kapatın, kâseden ters çevirerek tepsiye dizin.
4. Fırınlama (200°C): Üzerlerine et suyu (100 ml) dökün; çırpılmış yumurta-yoğurt karışımını sürün ve üzerleri kızarana kadar pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~52 dk · Pasif bekleme ~58 dk · Toplam ~110 dk

**Kaynak:** Çorlu Kuzu Ciğer Sarma, Türk Patent Coğrafi İşaret Tescil No 1604 (5 kişilik).',
            '[{"sira": 1, "ad": "Gömlek Çözdürme ve Hazırlık", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Ciğer Haşlama", "sure_dakika": 20, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YENİLEBİLİR SAKATAT (DANA KARACİĞER)", "YENİLEBİLİR SAKATAT (DANA AKCİĞER)", "YENİLEBİLİR SAKATAT (DANA KALP)"], "yeni_su_gram": null}, {"sira": 3, "ad": "İç Harç", "sure_dakika": 25, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "KURU SOĞAN", "TEREYAĞI", "TAZE NANE", "MAYDANOZ", "ÇAM FISTIĞI", "KUŞ ÜZÜMÜ", "TUZ", "KARABİBER", "KEKİK", "ET SUYU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Sarma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["TAVUK YUMURTASI", "YOĞURT (TAM)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Tekirdağ Usulü Kirazlı Komposto -> Hayrabolu Tatlısı (CI 839)
    select id into v_id from receteler where isletme_id is null and ad = 'Tekirdağ Usulü Kirazlı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Tekirdağ Usulü Kirazlı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Hayrabolu Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Hayrabolu Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Tekirdağ Usulü Kirazlı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Tekirdağ Usulü Kirazlı Komposto';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Hayrabolu Tatlısı', v_grup3_id, 1, 76,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "LOR PEYNİRİ", "miktar_gram": 57.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 11.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 3.0}, {"ad": "İRMİK", "miktar_gram": 28.0}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 1.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 25.0}, {"ad": "SU", "miktar_gram": 25.0}, {"ad": "LİMON SUYU", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Hayrabolu Tatlısı', null, '**Hazırlık / Mise en Place**
1. Taze tuzsuz peynir: Süzülmüş çiğ sütü 70°C''ye ısıtıp 35±5°C''ye soğutun; 100 kg süte 20 g peynir mayası katıp 1-2 saat mayalayın. Pıhtıyı kırıp peynir altı suyunun tamamı gidene kadar süzün.
2. Peyniri kıyma makinesinde iyice parçalayın; yumurta, irmik, un ve karbonatı katıp yoğurun. Hamuru bekletmeden yarım küre şeklinde kesip tepsilere dizin.

**Isıl İşlem**
1. Fırınlama (330°C, 15-17 dk): Pişirip oda sıcaklığında soğutun.
2. Şerbetleme: Şeker, su ve limon suyundan oluşan şerbette tatlıları eş zamanlı kaynatın; her yüzeyin şerbetlenmesi için ara ara çevirin. Şerbetini çekince ayrı kaba alıp soğutun.

**Servis:** İsteğe göre kırık ceviz, fındık, tahin ve kaymakla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~32 dk · Pasif bekleme ~44 dk · Toplam ~76 dk (peynir yapımı (1-2 saat mayalama ve süzme) hariç)

**Kaynak:** Hayrabolu Tatlısı, Türk Patent Coğrafi İşaret Tescil No 839 (porsiyon 100 g hamur).',
            '[{"sira": 1, "ad": "Hamur ve Şekil", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 16, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["LOR PEYNİRİ", "TAVUK YUMURTASI", "BUĞDAY UNU", "İRMİK", "KARBONAT (YEM. SODA)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğutma", "sure_dakika": 20, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbette Kaynatma", "sure_dakika": 20, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- İstanbul Usulü Etli Nohutlu Patlıcan -> Eminönü Balık Ekmek (CI 1860)
    select id into v_id from receteler where isletme_id is null and ad = 'İstanbul Usulü Etli Nohutlu Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: İstanbul Usulü Etli Nohutlu Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Eminönü Balık Ekmek') then
        raise notice 'Yeni ad zaten var, atlandi: Eminönü Balık Ekmek';
    elsif _kopya_kullanimda_mi(v_id, 'İstanbul Usulü Etli Nohutlu Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: İstanbul Usulü Etli Nohutlu Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Eminönü Balık Ekmek', v_grup1_id, 1, 21,
            '["balik"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "EKMEK (BEYAZ)", "miktar_gram": 120.0}, {"ad": "PALAMUT", "miktar_gram": 100.0}, {"ad": "MARUL", "miktar_gram": 20.0}, {"ad": "KURU SOĞAN", "miktar_gram": 20.0}, {"ad": "LİMON SUYU", "miktar_gram": 5.0}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Eminönü Balık Ekmek', null, '**Hazırlık / Mise en Place**
1. Balıkları hijyenik koşullarda temizleyip genellikle fileto hazırlayın. Dondurulmuş balık tekniğine uygun çözündürülür ve tekrar dondurulmaz.

**Isıl İşlem**
1. Izgara/tava (~8 dk): Balıkları ara sıra çevirerek iki yüzü yeterince pişip kızarana kadar pişirin.

**Servis:** Ekmek arasına ya da tabağa koyarak; isteğe göre marul, soğan, limon ve tuzla sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~21 dk · Pasif bekleme ~0 dk · Toplam ~21 dk

**Kaynak:** Eminönü Balık Ekmek, Türk Patent Coğrafi İşaret Tescil No 1860 (1 porsiyon).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PALAMUT", "TUZ"], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["EKMEK (BEYAZ)", "MARUL", "KURU SOĞAN", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Karaman Usulü Zeytinyağlı Kereviz -> Karaman Şebit Pilavı (CI 1464)
    select id into v_id from receteler where isletme_id is null and ad = 'Karaman Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Karaman Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Karaman Şebit Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Karaman Şebit Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Karaman Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Karaman Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Karaman Şebit Pilavı', v_grup1_id, 1, 118,
            '["kirmizi_et", "pilav"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
            '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 100.0}, {"ad": "TEREYAĞI", "miktar_gram": 7.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 10.5}, {"ad": "YEŞİL BİBER", "miktar_gram": 15.0}, {"ad": "DOMATES", "miktar_gram": 35.0}, {"ad": "NOHUT", "miktar_gram": 6.8}, {"ad": "BULGUR", "miktar_gram": 57.0}, {"ad": "ET SUYU", "miktar_gram": 80.0}, {"ad": "SU", "miktar_gram": 60.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 0.6}, {"ad": "KARABİBER", "miktar_gram": 0.6}, {"ad": "TUZ", "miktar_gram": 1.6}, {"ad": "BUĞDAY UNU", "miktar_gram": 28.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Karaman Şebit Pilavı', null, '**Hazırlık / Mise en Place**
1. Eti önceden haşlayın. Nohudu önceden haşlayın.
2. Şebit ekmeği: Un, tuz ve ılık suyu yoğurup 20-22°C''de 1 saat dinlendirin; 6 eşit bezeye bölüp oklavayla 55-60 cm çapında açın.

**Isıl İşlem**
1. Şebit (sac, odun ateşi): Ekmekleri sacda pişirin.
2. Et (5 dk): 30 g tereyağını eritip 70 g salça, haşlanmış et ve toz kırmızı biberi 5 dakika kavurun, dinlendirin.
3. Pilav (15-20 dk): 45 g tereyağında küçük doğranmış yeşil biberi kavurun. 35 g salça, tuz, kabuğu soyulup doğranmış domates, yıkanmış bulgur, haşlanmış nohut, 800 ml et suyu ve 400 ml suyu ekleyip kısık ateşte pişirin.
4. Demleme (10 dk).

**Servis:** Pilavı tabaklara koyup üzerine baharatlı eti dökün; şebit ekmeğiyle (genellikle şebite sarılarak) ve ayranla servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken pilav ve et hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~83 dk · Toplam ~118 dk (et ve nohut haşlama hariç)

**Kaynak:** Karaman Şebit Pilavı, Türk Patent Coğrafi İşaret Tescil No 1464 (10 porsiyon).',
            '[{"sira": 1, "ad": "Şebit Hamuru ve Dinlendirme", "sure_dakika": 70, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şebit Pişirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Et Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pilav", "sure_dakika": 18, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KONSERVE DOMATES SALÇASI", "YEŞİL BİBER", "DOMATES", "NOHUT", "BULGUR", "ET SUYU", "SU", "TUZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 5, "ad": "Demleme", "sure_dakika": 10, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Nazilli Usulü Zeytinyağlı Kereviz -> Nazilli Pidesi (CI 594)
    select id into v_id from receteler where isletme_id is null and ad = 'Nazilli Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Nazilli Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Nazilli Pidesi') then
        raise notice 'Yeni ad zaten var, atlandi: Nazilli Pidesi';
    elsif _kopya_kullanimda_mi(v_id, 'Nazilli Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Nazilli Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Nazilli Pidesi', v_grup2_id, 1, 158,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 97.0}, {"ad": "SU", "miktar_gram": 53.0}, {"ad": "KURU MAYA", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "DANA KIYMA", "miktar_gram": 90.0}, {"ad": "DOMATES", "miktar_gram": 30.0}, {"ad": "KURU SOĞAN", "miktar_gram": 22.5}, {"ad": "MAYDANOZ", "miktar_gram": 7.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Nazilli Pidesi', null, '**Hazırlık / Mise en Place**
1. Hamur: Beyaz buğday ununa unun %50-60''ı kadar su, %0,3 maya ve %0,7 tuz ekleyip elle yoğurun; serin ortamda en az 2 saat dinlendirip kabartın. ~150 g''lık toplara ayırıp unlanmış tahta muhafazalarda bekletin (günlük yapılır).
2. Kıyma harcı: Dananın koltuk altı bölgesinden az yağlı kıyma, kabuğu soyulup çok küçük doğranmış domates ve soğan, maydanoz ve tuzu ~3 dakika karıştırın (1 kg harç: 600 g kıyma, 200 g domates, 150 g soğan, 50 g maydanoz, 2 g tuz).
3. Hamuru tezgâhta tokatlayarak ve havada döndürerek eşit kalınlıkta açın. Harcı ortaya koyup tüm yüzeye eşit yayın; kenarları 1-1,5 cm içe kıvırın.

**Isıl İşlem**
1. Fırınlama (taş fırın): Pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~33 dk · Pasif bekleme ~125 dk · Toplam ~158 dk

**Kaynak:** Nazilli Pidesi, Türk Patent Coğrafi İşaret Tescil No 594 (1 pide 1 porsiyon (kıymalı)).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 135, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Harç", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 8, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "KURU MAYA", "TUZ", "DANA KIYMA", "DOMATES", "KURU SOĞAN", "MAYDANOZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Sinop Usulü Zeytinyağlı Nohutlu Pırasa -> Sinop Mantısı (CI 973)
    select id into v_id from receteler where isletme_id is null and ad = 'Sinop Usulü Zeytinyağlı Nohutlu Pırasa';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Sinop Usulü Zeytinyağlı Nohutlu Pırasa';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Sinop Mantısı') then
        raise notice 'Yeni ad zaten var, atlandi: Sinop Mantısı';
    elsif _kopya_kullanimda_mi(v_id, 'Sinop Usulü Zeytinyağlı Nohutlu Pırasa') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Sinop Usulü Zeytinyağlı Nohutlu Pırasa';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Sinop Mantısı', v_grup2_id, 1, 90,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Karadeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 75.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 25.0}, {"ad": "TUZ", "miktar_gram": 3.0}, {"ad": "SU", "miktar_gram": 37.5}, {"ad": "DANA KIYMA", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 25.0}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 2.3}, {"ad": "TEREYAĞI", "miktar_gram": 50.0}, {"ad": "YOĞURT (TAM)", "miktar_gram": 62.5}, {"ad": "SARIMSAK", "miktar_gram": 2.5}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 32.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Sinop Mantısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Yumurta ve suyu çırpın; un ve tuzu ekleyip kulak memesi kıvamında yoğurun. Üzerini kapatıp 15-20 dakika dinlendirin.
2. İç harç: Yağsız dana kıymasına ince rendelenip suyu sıkılmış soğan, tuz ve karabiber ekleyip yoğurun.
3. Hamuru ikiye bölüp unlayarak 1-2 mm kalınlıkta açın; hızlıca 4-5 cm kareler kesin. Her kareye silme 1 çay kaşığı harç koyup üçgen katlayın, alt iki köşeyi birleştirip kalan köşeyi yukarı kaldırarak kulak şekli verin.
4. Sos: Sarımsağı havanda dövüp yoğurtla karıştırın; cevizi ince dövün.

**Isıl İşlem**
1. Haşlama (7-8 dk): Kaynayan suya tuz ve sıvı yağ koyup mantıları tamamen suyun içinde kalacak şekilde kısık ateşte pişirin. 1 bardak soğuk su ekleyip 1 dakika bekleyin, süzün.
2. Tereyağı: Tereyağını hafifçe kızdırın.

**Servis:** Mantıları tabağa alıp bir yemek kaşığı tereyağı gezdirin; yarısına sarımsaklı yoğurt, diğer yarısına ceviz dökün. Üzerine tekrar tereyağı gezdirip isteğe göre pul biber ve nane serperek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~68 dk · Pasif bekleme ~22 dk · Toplam ~90 dk

**Kaynak:** Sinop Mantısı, Türk Patent Coğrafi İşaret Tescil No 973 (4 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve İç Harç", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma, Kesme ve Kapatma", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Haşlama", "sure_dakika": 10, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "TAVUK YUMURTASI", "DANA KIYMA", "KURU SOĞAN", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Sos ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "YOĞURT (TAM)", "SARIMSAK", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Eskişehir Usulü Izgara Tavuk Kanat -> Sivrihisar Kelem Dolması (CI 1189)
    select id into v_id from receteler where isletme_id is null and ad = 'Eskişehir Usulü Izgara Tavuk Kanat';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Eskişehir Usulü Izgara Tavuk Kanat';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Sivrihisar Kelem Dolması') then
        raise notice 'Yeni ad zaten var, atlandi: Sivrihisar Kelem Dolması';
    elsif _kopya_kullanimda_mi(v_id, 'Eskişehir Usulü Izgara Tavuk Kanat') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Eskişehir Usulü Izgara Tavuk Kanat';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Sivrihisar Kelem Dolması', v_grup2_id, 1, 132,
            '["dolma"]'::jsonb, 'sonbahar', 'İç Anadolu',
            '[{"ad": "DANA KIYMA", "miktar_gram": 83.3}, {"ad": "BULGUR", "miktar_gram": 25.0}, {"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 25.0}, {"ad": "SU", "miktar_gram": 116.7}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 3.0}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1.0}, {"ad": "LAHANA", "miktar_gram": 83.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Sivrihisar Kelem Dolması', null, '**Hazırlık / Mise en Place**
1. Kepen kelemi yapraklarını gruplar halinde, 5 dakikada bir ters yüz ederek ~15''er dakika haşlayın (dondurulmuş yaprak çözdürülüp doğrudan kullanılır). Birbirine değmeyecek şekilde tepsiye dizip 3 g tuz serpin, 10 dakika soğutun.
2. İç harç: Kıyma, ince dene (eşit pilavlık bulgur ve göce), su, salça, pul biber ve tuzu iyice yoğurun; dene şişmesin diye bekletmeden kullanın.
3. Yaprakların kalın damarlarını kesip en fazla 3-4 cm kalınlığında uzun şeritler kesin. Fındık büyüklüğünde harç koyup ince taraftan başlayarak üçgen (muska) şeklinde sıkıca sarın.

**Isıl İşlem**
1. Yaprak haşlama (~15 dk).
2. Pişirme (~40 dk): Dolmaları geniş tabanlı tencereye dizip üzerlerini geçmeyecek kadar (~400 ml) oda sıcaklığında su ekleyin. Kaynayınca ateşi kısıp 30 dakika pişirin; 200 ml su ekleyip 10 dakika daha pişirin.
3. Dinlendirme (15 dk).

**Servis:** Dinlendirdikten sonra servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~61 dk · Pasif bekleme ~71 dk · Toplam ~132 dk

**Kaynak:** Sivrihisar Kelem Dolması, Türk Patent Coğrafi İşaret Tescil No 1189 (6 kişilik).',
            '[{"sira": 1, "ad": "Yaprak Haşlama", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LAHANA", "TUZ"], "yeni_su_gram": null}, {"sira": 2, "ad": "İç Harç ve Sarma", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 42, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "BULGUR", "BUĞDAY (TAM TANE)", "SU", "KONSERVE DOMATES SALÇASI", "PUL BİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Dinlendirme", "sure_dakika": 15, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Iğdır Usulü Kayısılı Komposto -> Iğdır Omaç Aşı Çorbası (CI 876)
    select id into v_id from receteler where isletme_id is null and ad = 'Iğdır Usulü Kayısılı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Iğdır Usulü Kayısılı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Iğdır Omaç Aşı Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Iğdır Omaç Aşı Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Iğdır Usulü Kayısılı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Iğdır Usulü Kayısılı Komposto';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Iğdır Omaç Aşı Çorbası', v_grup2_id, 1, 90,
            '["corba", "vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 25.0}, {"ad": "TUZ", "miktar_gram": 2.2}, {"ad": "SU", "miktar_gram": 425.0}, {"ad": "ERİK", "miktar_gram": 16.7}, {"ad": "LABADA", "miktar_gram": 12.5}, {"ad": "BÖRÜLCE (KURU)", "miktar_gram": 83.3}, {"ad": "KIRMIZI BİBER", "miktar_gram": 3.3}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 5.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 4.2}, {"ad": "DOMATES", "miktar_gram": 4.2}, {"ad": "KURU SOĞAN", "miktar_gram": 9.2}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 12.5}, {"ad": "PUL BİBER", "miktar_gram": 1.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Iğdır Omaç Aşı Çorbası', null, '**Hazırlık / Mise en Place**
1. Omaç: Un ve tuzu geniş kapta karıştırın; yavaş yavaş su ekleyerek topak topak oluncaya kadar ovun. Omaçları tepsiye serip üstü açık 1 saat kurutun.
2. Börülceyi 1 saat önceden ıslatın. Alça eriğini iyice yıkayın; alça ve evelik otunu ayrı kaplarda 1 saat suda bekletip süzün.

**Isıl İşlem**
1. Kavurma (~5 dk): Soğanları kısık ateşte karamelleşinceye kadar ~3 dakika kavurun; biber salçası, domates salçası ve isteğe göre domates suyunu ekleyin.
2. Pişirme: 2 dakika sonra börülce, acı biber, pul biber ve tuzu ekleyin; suyu ilave edin. En son sırayla evelik otu, alça ve omaçları koyup 20 dakika pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~65 dk · Toplam ~90 dk

**Kaynak:** Iğdır Omaç Aşı Çorbası, Türk Patent Coğrafi İşaret Tescil No 876 (yaklaşık 12 kişilik).',
            '[{"sira": 1, "ad": "Omaç ve Islatma", "sure_dakika": 60, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "DOMATES"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "ERİK", "LABADA", "BÖRÜLCE (KURU)", "KIRMIZI BİBER", "PUL BİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Malatya Usulü Kayısılı Komposto -> Arapgir Gelin Kız Helvası (CI 1843)
    select id into v_id from receteler where isletme_id is null and ad = 'Malatya Usulü Kayısılı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Malatya Usulü Kayısılı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Arapgir Gelin Kız Helvası') then
        raise notice 'Yeni ad zaten var, atlandi: Arapgir Gelin Kız Helvası';
    elsif _kopya_kullanimda_mi(v_id, 'Malatya Usulü Kayısılı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Malatya Usulü Kayısılı Komposto';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Arapgir Gelin Kız Helvası', v_grup3_id, 1, 125,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "TEREYAĞI", "miktar_gram": 31.25}, {"ad": "TOZ ŞEKER", "miktar_gram": 31.25}, {"ad": "BUĞDAY UNU", "miktar_gram": 50.0}, {"ad": "BADEM (İÇ)", "miktar_gram": 12.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Arapgir Gelin Kız Helvası', null, '**Isıl İşlem**
1. Kavurma (~25 dk): Derin tencerede tereyağını eritin. 200 g unu ekleyip topaklanmasın diye sürekli karıştırın; 2-3 dakika sonra kalan unu ekleyin. Un pembeleşinceye kadar kısık ateşte ~20 dakika kavurun.
2. Şeker: Ocağı kapatıp pudra şekerini ekleyin.
3. Kalıplama: Soğumadan 25x35x4 cm tepsiye yayıp kaşıkla bastırın; üzerini düzeltip kabuğu soyulmuş badem veya cevizle süsleyin.
4. Dinlendirme (1-2 saat).

**Servis:** Kare kesip soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~90 dk · Toplam ~125 dk

**Kaynak:** Arapgir Gelin Kız Helvası, Türk Patent Coğrafi İşaret Tescil No 1843 (8 porsiyon).',
            '[{"sira": 1, "ad": "Un Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Şeker ve Kalıplama", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["TOZ ŞEKER", "BADEM (İÇ)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Dinlendirme", "sure_dakika": 90, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kocaeli Usulü Etli Kabak Yemeği -> Karamürsel Simit Dolması (CI 1407)
    select id into v_id from receteler where isletme_id is null and ad = 'Kocaeli Usulü Etli Kabak Yemeği';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kocaeli Usulü Etli Kabak Yemeği';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Karamürsel Simit Dolması') then
        raise notice 'Yeni ad zaten var, atlandi: Karamürsel Simit Dolması';
    elsif _kopya_kullanimda_mi(v_id, 'Kocaeli Usulü Etli Kabak Yemeği') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kocaeli Usulü Etli Kabak Yemeği';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Karamürsel Simit Dolması', v_grup2_id, 1, 106,
            '["pilav_makarna_borek", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 55.0}, {"ad": "SU", "miktar_gram": 49.0}, {"ad": "TUZ", "miktar_gram": 0.7}, {"ad": "KURU MAYA", "miktar_gram": 0.2}, {"ad": "FETA PEYNİRİ", "miktar_gram": 75.0}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 25.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 12.5}, {"ad": "TEREYAĞI", "miktar_gram": 10.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Karamürsel Simit Dolması', null, '**Hazırlık / Mise en Place**
1. Hamur: 50 kg un, 40 l su, 600 g tuz ve 500 g mayayı 25 dakika yoğurup 30 dakika mayalandırın. 400 g''lık bezelere ayırıp 30 dakika daha dinlendirin; 50-60 cm uzun simit şekli verin.
2. Peynirli harç: Coğrafi sınırda "kırık peynir" denen inek sütü yağlı peynirinden 300 g (bir simit için).
3. Süt-su karışımı (200 ml + 200 ml) ve yarım bardak sütle çırpılmış yumurtayı hazırlayın.

**Isıl İşlem**
1. Simit (taş fırın, 320°C, 4-5 dk): Un-kepek karışımına bulayıp kızartmadan beyaz pişirin.
2. Doldurma: Simitleri parçalara ayırıp uzunlamasına kesin, peyniri doldurun. Süt-su karışımına batırıp elle sıkın; yumurtalı süte batırın.
3. Kızartma (~6 dk): Tavada kızdırılmış tereyağında önlü arkalı kızartın.

**Servis:** Sade ya da salata, maydanoz, domatesle servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~43 dk · Pasif bekleme ~63 dk · Toplam ~106 dk

**Kaynak:** Karamürsel Simit Dolması, Türk Patent Coğrafi İşaret Tescil No 1407 (porsiyon 1/4 simit (peynirli)).',
            '[{"sira": 1, "ad": "Hamur ve Mayalanma", "sure_dakika": 85, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Simit Pişirme", "sure_dakika": 5, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "TUZ", "KURU MAYA"], "yeni_su_gram": null}, {"sira": 3, "ad": "Doldurma ve Islatma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["FETA PEYNİRİ", "SÜT (TAM YAĞ)", "TAVUK YUMURTASI"], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 6, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 140, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Sakarya Usulü Etli Nohutlu Bulgur -> Adapazarı Islama Köftesi (CI 167)
    select id into v_id from receteler where isletme_id is null and ad = 'Sakarya Usulü Etli Nohutlu Bulgur';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Sakarya Usulü Etli Nohutlu Bulgur';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Adapazarı Islama Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Adapazarı Islama Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Sakarya Usulü Etli Nohutlu Bulgur') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Sakarya Usulü Etli Nohutlu Bulgur';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Adapazarı Islama Köftesi', v_grup1_id, 1, 115,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "DANA KIYMA", "miktar_gram": 125.0}, {"ad": "KURU SOĞAN", "miktar_gram": 13.75}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 70.0}, {"ad": "KİMYON", "miktar_gram": 1.25}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 7.5}, {"ad": "TUZ", "miktar_gram": 4.4}, {"ad": "ET SUYU", "miktar_gram": 125.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 12.5}, {"ad": "DOMATES", "miktar_gram": 27.5}, {"ad": "YEŞİL BİBER", "miktar_gram": 15.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Adapazarı Islama Köftesi', null, '**Hazırlık / Mise en Place**
1. Kemik suyu (önceden): Dananın kalın kaburga ve kaval kemiklerini kırıp 12 litre su ve 2 büyük soğanla ~12 saat ağır ateşte kaynatın; tülbentten süzün.
2. Köfte: Kıymaya (500 g kaburga + 500 g kol) soğanı rendeleyin; baharatları ve rendeden geçirilmiş bayat ekmek içini (80 g) ekleyip kıvamına gelene kadar yoğurun. En az 1 saat dinlendirin. Porsiyona 10 adet gelecek şekilde (toplam 80) şekillendirin.
3. Islama suyu: Kemik suyuna kırmızı toz biber, sıvı yağ ve tuzu karıştırın.

**Isıl İşlem**
1. Izgara (meşe kömürü, üstü beyazlamış): Köfteleri sırayla dizip pişirin. Domates ve biberleri hafifçe közleyin.
2. Islama: İnce dilimlenmiş bayat kara fırın ekmeğini ıslama suyuna bandırıp ızgarada az kızartın.

**Servis:** Tabağa 2 dilim ekmek, üzerine 10 köfte koyun; çeyrek közlenmiş domates ve 1 közlenmiş biberle, tercihen piyaz, üzüm şırası veya ayranla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~55 dk · Pasif bekleme ~60 dk · Toplam ~115 dk (12 saatlik kemik suyu hariç)

**Kaynak:** Adapazarı Islama Köftesi, Türk Patent Coğrafi İşaret Tescil No 167 (8 kişilik).',
            '[{"sira": 1, "ad": "Köfte Hamuru", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Dinlendirme", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Şekillendirme", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Izgara ve Islama", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "EKMEK (BEYAZ)", "KİMYON", "KARABİBER", "TATLIKA KIRMIZI BİBER", "TUZ", "ET SUYU", "AYÇİÇEK YAĞI", "DOMATES", "YEŞİL BİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kuşadası Usulü Etli Enginar -> Aydın Yuvarlaması (CI 1198)
    select id into v_id from receteler where isletme_id is null and ad = 'Kuşadası Usulü Etli Enginar';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kuşadası Usulü Etli Enginar';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Aydın Yuvarlaması') then
        raise notice 'Yeni ad zaten var, atlandi: Aydın Yuvarlaması';
    elsif _kopya_kullanimda_mi(v_id, 'Kuşadası Usulü Etli Enginar') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kuşadası Usulü Etli Enginar';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Aydın Yuvarlaması', v_grup1_id, 1, 200,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "DANA KIYMA", "miktar_gram": 41.7}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 8.3}, {"ad": "KARABİBER", "miktar_gram": 2.5}, {"ad": "KURU SOĞAN", "miktar_gram": 36.7}, {"ad": "TUZ", "miktar_gram": 1.7}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 15.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 83.3}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 12.5}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 12.5}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 4.2}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "NOHUT", "miktar_gram": 8.0}, {"ad": "ET SUYU", "miktar_gram": 50.0}, {"ad": "SÜZME YOĞURT", "miktar_gram": 41.7}, {"ad": "SARIMSAK", "miktar_gram": 0.8}, {"ad": "SU", "miktar_gram": 16.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Aydın Yuvarlaması', null, '**Hazırlık / Mise en Place**
1. Nohudu bir gün önceden ılık suda 6-8 saat ıslatın.
2. Hamur: Çırpılmış yumurta, rendelenmiş soğan, tuz, karabiber ve iki kez çekilmiş az yağlı dana kıymayı karıştırın; homojen olunca unu azar azar ekleyip yumuşak bir hamur yoğurun. Tahta üzerinde 15 dakika dinlendirin.
3. Hamuru birkaç kez yoğurup silindir yapın, eşit bezelere bölün; 1 cm kalınlıkta açıp 2 cm şeritler kesin. Şeritleri 25-30 cm rulo yapıp 1,5-2 cm parçalar kesin; avuçta yuvarlayıp iki ucu ince 2-4 cm silindirik şekil verin. Unlu tepsiye dizin, kızartmadan önce elekten geçirip fazla unu alın.

**Isıl İşlem**
1. Nohut haşlama (30 dk).
2. Kızartma: Köfteleri bakır kapta kızdırılmış sıvı yağda yapıştırmadan kızartın, kâğıt havluya alın.
3. Sos ve pişirme (~45 dk): Tereyağını eritip sıvı yağ, salça, toz kırmızı biber, köpüğü alınmış et suyu ve suyu ekleyip salça kokusu gidene kadar pişirin. Köfteleri ve nohudu ekleyip ~45 dakika pişirin; 10 dakikada bir su kontrol edin, gerekirse üstteki köfteleri örtecek kadar soğuk su ekleyin.
4. Dinlendirme (15 dk).

**Servis:** Üzerine sarımsaklı ya da sade süzme yoğurt koyarak; isteğe göre maydanoz veya eritilmiş tereyağıyla servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken nohut haşlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~102 dk · Pasif bekleme ~98 dk · Toplam ~200 dk (nohut ıslatma hariç)

**Kaynak:** Aydın Yuvarlaması, Türk Patent Coğrafi İşaret Tescil No 1198 (6 kişilik).',
            '[{"sira": 1, "ad": "Hamur ve Dinlendirme", "sure_dakika": 30, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şekillendirme", "sure_dakika": 60, "aktif_dakika": 60, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Nohut Haşlama", "sure_dakika": 30, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT"], "yeni_su_gram": null}, {"sira": 4, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 160, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TAVUK YUMURTASI", "BUĞDAY UNU", "KURU SOĞAN", "AYÇİÇEK YAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 5, "ad": "Sosta Pişirme", "sure_dakika": 50, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "TATLIKA KIRMIZI BİBER", "ET SUYU", "SU"], "yeni_su_gram": null}, {"sira": 6, "ad": "Dinlendirme ve Servis", "sure_dakika": 15, "aktif_dakika": 2, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["SÜZME YOĞURT", "SARIMSAK"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şırnak Usulü Etli Kavurma (Kimyonlu) -> Şırnak Soryaz (CI 1679)
    select id into v_id from receteler where isletme_id is null and ad = 'Şırnak Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şırnak Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Şırnak Soryaz') then
        raise notice 'Yeni ad zaten var, atlandi: Şırnak Soryaz';
    elsif _kopya_kullanimda_mi(v_id, 'Şırnak Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şırnak Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Şırnak Soryaz', v_grup1_id, 1, 26,
            '["yumurta", "vejetaryen"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
            '[{"ad": "KURU SOĞAN", "miktar_gram": 77.8}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 50.0}, {"ad": "TAZE SOĞAN", "miktar_gram": 127.8}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 46.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Şırnak Soryaz', null, '**Hazırlık / Mise en Place**
1. Soğanları soyup küp doğrayın.
2. Salamura soryazı sudan geçirerek tuzunu azaltın; sıkarak suyunu süzdürün.

**Isıl İşlem**
1. Kavurma (~8 dk): Yayvan tavada ayçiçek yağına soğanları ekleyip yüksek ateşte, soğan yağı çekene kadar sürekli karıştırın; pembeleşinceye kadar kavurun.
2. Yumurta ve soryaz (5-10 dk): Yumurtaları ekleyip karıştırın; yıkanıp süzülmüş soryazı ekleyip yumurtalar iyice pişene kadar karıştırmaya devam edin.

**Servis:** Ateşten alıp sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~26 dk · Pasif bekleme ~0 dk · Toplam ~26 dk

**Kaynak:** Şırnak Soryaz, Türk Patent Coğrafi İşaret Tescil No 1679 (4-5 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Soğan Kavurma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Yumurta ve Soryaz", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK YUMURTASI", "TAZE SOĞAN"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şırnak Usulü Zeytinyağlı Nohutlu Bakla -> Cizre Bırınczer (CI 1509)
    select id into v_id from receteler where isletme_id is null and ad = 'Şırnak Usulü Zeytinyağlı Nohutlu Bakla';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şırnak Usulü Zeytinyağlı Nohutlu Bakla';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Cizre Bırınczer') then
        raise notice 'Yeni ad zaten var, atlandi: Cizre Bırınczer';
    elsif _kopya_kullanimda_mi(v_id, 'Şırnak Usulü Zeytinyağlı Nohutlu Bakla') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şırnak Usulü Zeytinyağlı Nohutlu Bakla';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Cizre Bırınczer', v_grup3_id, 1, 27,
            '["tatli", "vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "TOZ ŞEKER", "miktar_gram": 71.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 12.3}, {"ad": "SU", "miktar_gram": 122.6}, {"ad": "TARÇIN", "miktar_gram": 0.6}, {"ad": "ZERDEÇAL", "miktar_gram": 0.1}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 0.9}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Cizre Bırınczer', null, '**Isıl İşlem**
1. Pirinç (15-20 dk): Pirinci yıkayıp tencereye koyun, suyu ekleyip orta ateşte pişirin. Tercihe göre ayçiçek yağı ekleyip karıştırın.
2. Şeker (~4 dk): Şekeri ekleyip 1-2 dakika pişirin; sırasıyla zerdeçal (veya safran) ve toz tarçını ekleyip 1-2 dakika karıştırın, ocaktan alın.
3. Soğutma (5-6 saat): Kâselere dökün, üzerine toz tarçın serpip oda sıcaklığında veya buzdolabında bekletin.

**Servis:** Soğuk servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme ~15 dk · Toplam ~27 dk (5-6 saat soğutma hariç)

**Kaynak:** Cizre Bırınczer, Türk Patent Coğrafi İşaret Tescil No 1509 (15-16 porsiyon).',
            '[{"sira": 1, "ad": "Pirinç Pişirme", "sure_dakika": 18, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "SU", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 2, "ad": "Şeker ve Baharat", "sure_dakika": 4, "aktif_dakika": 4, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "TARÇIN", "ZERDEÇAL"], "yeni_su_gram": null}, {"sira": 3, "ad": "Kâseleme", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şırnak Usulü Zeytinyağlı Patlıcan -> Şımşıpe (CI 301)
    select id into v_id from receteler where isletme_id is null and ad = 'Şırnak Usulü Zeytinyağlı Patlıcan';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şırnak Usulü Zeytinyağlı Patlıcan';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Şımşıpe') then
        raise notice 'Yeni ad zaten var, atlandi: Şımşıpe';
    elsif _kopya_kullanimda_mi(v_id, 'Şırnak Usulü Zeytinyağlı Patlıcan') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şırnak Usulü Zeytinyağlı Patlıcan';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Şımşıpe', v_grup2_id, 1, 135,
            '["dolma"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 55.6}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 55.6}, {"ad": "TUZ", "miktar_gram": 0.6}, {"ad": "KARABİBER", "miktar_gram": 0.15}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 1.5}, {"ad": "PUL BİBER", "miktar_gram": 0.15}, {"ad": "PANCAR", "miktar_gram": 27.8}, {"ad": "KURU SOĞAN", "miktar_gram": 36.7}, {"ad": "KABAK", "miktar_gram": 33.3}, {"ad": "PATLICAN", "miktar_gram": 27.8}, {"ad": "YEŞİL BİBER", "miktar_gram": 13.3}, {"ad": "DOMATES", "miktar_gram": 24.4}, {"ad": "SUMAK", "miktar_gram": 7.8}, {"ad": "SU", "miktar_gram": 66.7}, {"ad": "MAYDANOZ", "miktar_gram": 5.6}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 1.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Şımşıpe', null, '**Hazırlık / Mise en Place**
1. Sebzeleri ve kıymayı yıkayın; kabak, patlıcan, domates ve biberlerin üst kısmını açıp içlerini oyun. Pancar yapraklarının kalın damarlarını kesin. Soğanları sıcak suda 5-10 dakika bekletip ya da bez üzerinde yavaşça vurarak katlarına ayırın.
2. Çiğ kıyma, çiğ pirinç, tuz, baharatlar ve isteğe göre maydanoz ve sebze içlerini karıştırın.
3. Soğan katlarına iç koyup dürün; kabak ve patlıcanları doldurup açık başlarını birbirine geçirerek tencerenin dibine yerleştirin. Yaprakları doldurup sarın.

**Isıl İşlem**
1. Pişirme (~45 dk): Üzerine 3 bardak suda çözülmüş sumak suyunu ve salçayı ekleyin; üzerine kil sarma-dolma taşı (yoksa 7-8 yassı nehir taşı) koyup ateşe verin. Kaynadıktan 15 dakika sonra ateşi hafifletin; suyunu çekip pişince indirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~95 dk · Pasif bekleme ~40 dk · Toplam ~135 dk

**Kaynak:** Şımşıpe, Türk Patent Coğrafi İşaret Tescil No 301 (8-10 kişilik).',
            '[{"sira": 1, "ad": "Oyma ve Hazırlık", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Doldurma ve Sarma", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN KIYMA", "PİRİNÇ (HAM)", "PANCAR", "KURU SOĞAN", "KABAK", "PATLICAN", "YEŞİL BİBER", "DOMATES", "SUMAK", "SU", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Şırnak Usulü Kuzu Kavurma -> Cizre Luzine Tatlısı (CI 939)
    select id into v_id from receteler where isletme_id is null and ad = 'Şırnak Usulü Kuzu Kavurma';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Şırnak Usulü Kuzu Kavurma';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Cizre Luzine Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Cizre Luzine Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Şırnak Usulü Kuzu Kavurma') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Şırnak Usulü Kuzu Kavurma';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Cizre Luzine Tatlısı', v_grup3_id, 1, 90,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
            '[{"ad": "İRMİK", "miktar_gram": 66.7}, {"ad": "TOZ ŞEKER", "miktar_gram": 66.7}, {"ad": "BUĞDAY UNU", "miktar_gram": 5.0}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 16.7}, {"ad": "SU", "miktar_gram": 33.3}, {"ad": "MARGARİN", "miktar_gram": 0.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Cizre Luzine Tatlısı', null, '**Hazırlık / Mise en Place**
1. 400 g cevizi 1/8 oranında elle ufaltın; 100 g cevizi süsleme için dörde bölün. Tepsinin dibini margarinle yağlayın.

**Isıl İşlem**
1. Şurup ve karıştırma (~15 dk): Su ve şekeri kaynatın; kaynayınca ocaktan indirip sırasıyla ufaltılmış ceviz, irmik ve unu ekleyerek sakız kıvamına gelene kadar sürekli karıştırın.
2. Tepsileme: Sıcakken tepsiye dökün, hafifçe sallayarak eşit yayın. Katılaşmadan süsleme cevizlerini muntazam dizip parmak ucuyla bastırın.
3. Soğutma (1 saat).

**Servis:** Eşkenar dikdörtgen kesip oda sıcaklığında servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~60 dk · Toplam ~90 dk

**Kaynak:** Cizre Luzine Tatlısı, Türk Patent Coğrafi İşaret Tescil No 939 (34x44 cm tepsi; yaklaşık 30 dilim).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şurup ve Karıştırma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "İRMİK", "BUĞDAY UNU", "CEVİZ (İÇ)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Tepsileme", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["MARGARİN"], "yeni_su_gram": null}, {"sira": 4, "ad": "Soğutma", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Doğu Anadolu Usulü Karışık Turşu -> Hakkari Lalaped Tatlısı (CI 1601)
    select id into v_id from receteler where isletme_id is null and ad = 'Doğu Anadolu Usulü Karışık Turşu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Doğu Anadolu Usulü Karışık Turşu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Hakkari Lalaped Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Hakkari Lalaped Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Doğu Anadolu Usulü Karışık Turşu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Doğu Anadolu Usulü Karışık Turşu';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Hakkari Lalaped Tatlısı', v_grup3_id, 1, 53,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 34.3}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 45.0}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 25.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 16.7}, {"ad": "TOZ ŞEKER", "miktar_gram": 97.5}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 1.3}, {"ad": "YOĞURT (TAM)", "miktar_gram": 6.7}, {"ad": "BUĞDAY UNU", "miktar_gram": 41.7}, {"ad": "SU", "miktar_gram": 83.3}, {"ad": "LİMON SUYU", "miktar_gram": 3.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Hakkari Lalaped Tatlısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Yumurta ve şekeri çırpın. Süt, sıvı yağ, dövülmüş ceviz (50 g), karbonat/kabartma tozu, yoğurt, un ve isteğe göre vanilini ekleyerek cıvık bir hamur elde edin; 10 dakika bekletin.
2. Şerbet: Şeker ve suyu kısık ateşte kaynatın; ocağı söndürmeye yakın limonu ekleyip ılımaya bırakın.

**Isıl İşlem**
1. Kızartma: Sıvı yağ kızınca hamuru tatlı kaşığıyla atın; kevgirle çevirerek her yanını kızartın.
2. Şerbetleme: Kızaranları ılık şerbete atıp 5-10 saniye bekletin, servis tabaklarına alın.

**Servis:** Üzerine dövülmüş ceviz (100 g) ekleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~13 dk · Toplam ~53 dk

**Kaynak:** Hakkari Lalaped Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1601 (6 porsiyon).',
            '[{"sira": 1, "ad": "Hamur ve Şerbet", "sure_dakika": 25, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma ve Şerbetleme", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 170, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜT (TAM YAĞ)", "AYÇİÇEK YAĞI", "TAVUK YUMURTASI", "KARBONAT (YEM. SODA)", "YOĞURT (TAM)", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Doğu Anadolu Usulü Kayısı Kompostosu -> Erzurum Kuru Kayısı Kaysefesi (CI 1643)
    select id into v_id from receteler where isletme_id is null and ad = 'Doğu Anadolu Usulü Kayısı Kompostosu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Doğu Anadolu Usulü Kayısı Kompostosu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Erzurum Kuru Kayısı Kaysefesi') then
        raise notice 'Yeni ad zaten var, atlandi: Erzurum Kuru Kayısı Kaysefesi';
    elsif _kopya_kullanimda_mi(v_id, 'Doğu Anadolu Usulü Kayısı Kompostosu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Doğu Anadolu Usulü Kayısı Kompostosu';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Erzurum Kuru Kayısı Kaysefesi', v_grup3_id, 1, 31,
            '["tatli", "vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "KURU KAYISI", "miktar_gram": 64.3}, {"ad": "TEREYAĞI", "miktar_gram": 30.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 40.0}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 18.6}, {"ad": "SU", "miktar_gram": 60.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Erzurum Kuru Kayısı Kaysefesi', null, '**Hazırlık / Mise en Place**
1. Kuru kayısıları yumuşaması ve tozu çıkması için ılık suda 15 dakika bekletip yıkayın.

**Isıl İşlem**
1. Pişirme (10-15 dk): Kayısıları tencereye alıp şeker ve su ekleyin; yumuşayıp şerbetini çekinceye kadar orta ateşte pişirin.
2. Tereyağı (2-3 dk): Tereyağını ekleyip pişirin, servis tabağına alın.

**Servis:** Üzerine isteğe göre erimiş tereyağı ve ceviz gezdirip sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~9 dk · Pasif bekleme ~22 dk · Toplam ~31 dk

**Kaynak:** Erzurum Kuru Kayısı Kaysefesi, Türk Patent Coğrafi İşaret Tescil No 1643 (3-4 kişilik).',
            '[{"sira": 1, "ad": "Bekletme ve Yıkama", "sure_dakika": 15, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 13, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU KAYISI", "TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Tereyağı ve Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Marmara Usulü Karışık Turşu -> Uzunköprü Köftesi (CI 1777)
    select id into v_id from receteler where isletme_id is null and ad = 'Marmara Usulü Karışık Turşu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Marmara Usulü Karışık Turşu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Uzunköprü Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Uzunköprü Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Marmara Usulü Karışık Turşu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Marmara Usulü Karışık Turşu';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Uzunköprü Köftesi', v_grup1_id, 1, 27,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "DANA KOL", "miktar_gram": 171.3}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 17.1}, {"ad": "KURU SOĞAN", "miktar_gram": 8.6}, {"ad": "TUZ", "miktar_gram": 0.26}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.7}, {"ad": "KİMYON", "miktar_gram": 1.4}, {"ad": "KARABİBER", "miktar_gram": 0.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Uzunköprü Köftesi', null, '**Hazırlık / Mise en Place**
1. Dananın ön kol, döş ve kaburga etlerini sinir ve kıkırdaklarından ayıklayın; çiğ halde ~3 gün buzdolabında dinlendirin.
2. Eti bayat ekmek içi ve beyaz soğanla birlikte bir kez kıyma makinesinden geçirip ~1 gün dinlendirin.
3. Tuz, karbonat, taze çekilmiş kimyon ve karabiberi ekleyip tekrar makineden geçirin; ~1 gün daha dinlendirin.
4. Kıymayı ~50 g''lık, ~15 mm kalınlığında ve ~55 mm genişliğinde köfteler halinde elle şekillendirin.

**Isıl İşlem**
1. Izgara (mangal kömürü; ~3 mm sac, 8 mm aralık): Pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~27 dk · Pasif bekleme ~0 dk · Toplam ~27 dk (toplam ~5 günlük et ve kıyma dinlendirme hariç)

**Kaynak:** Uzunköprü Köftesi, Türk Patent Coğrafi İşaret Tescil No 1777 (köfte 50 g çiğ; porsiyonda 4 köfte).',
            '[{"sira": 1, "ad": "Şekillendirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KOL", "EKMEK (BEYAZ)", "KURU SOĞAN", "TUZ", "KARBONAT (YEM. SODA)", "KİMYON", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Marmara Usulü Elmalı Komposto -> Bilecik Pazaryeri Helvası (CI 290)
    select id into v_id from receteler where isletme_id is null and ad = 'Marmara Usulü Elmalı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Marmara Usulü Elmalı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bilecik Pazaryeri Helvası') then
        raise notice 'Yeni ad zaten var, atlandi: Bilecik Pazaryeri Helvası';
    elsif _kopya_kullanimda_mi(v_id, 'Marmara Usulü Elmalı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Marmara Usulü Elmalı Komposto';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bilecik Pazaryeri Helvası', v_grup3_id, 1, 155,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "TAHİN", "miktar_gram": 23.25}, {"ad": "TOZ ŞEKER", "miktar_gram": 21.5}, {"ad": "SU", "miktar_gram": 5.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bilecik Pazaryeri Helvası', null, '**Hazırlık / Mise en Place**
1. Oran: kütlece %45-48 tahin, %41-45 şeker, %8-12 su. İrmik, un, sitrik asit veya ceviz gibi katkı kullanılmaz.

**Isıl İşlem**
1. Şeker kaynatma (~20 dk): Şekeri suyla eritip ağdalı yapı için karıştırarak ~117-118°C''ye kadar kaynatın.
2. Tahin: Kaynamış şekeri pişirme kazanına alın; karıştırmaya devam ederken tahini ekleyin. Pişme, helvanın yapısına bakılarak usta tarafından belirlenir.
3. Dinlendirme: Uygun yapıya ulaşınca bekletmeden dinlendirme tavalarına alın; soğutup dinlendirin.

**Servis:** Dilimleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~130 dk · Toplam ~155 dk

**Kaynak:** Bilecik Pazaryeri Helvası, Türk Patent Coğrafi İşaret Tescil No 290 (porsiyon 50 g).',
            '[{"sira": 1, "ad": "Şeker Kaynatma", "sure_dakika": 20, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 118, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Tahinle Karıştırma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAHİN"], "yeni_su_gram": null}, {"sira": 3, "ad": "Dinlendirme", "sure_dakika": 120, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Marmara Usulü Vişne Kompostosu -> Bilecik Ekşili Kesme Çorba (CI 1796)
    select id into v_id from receteler where isletme_id is null and ad = 'Marmara Usulü Vişne Kompostosu';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Marmara Usulü Vişne Kompostosu';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bilecik Ekşili Kesme Çorba') then
        raise notice 'Yeni ad zaten var, atlandi: Bilecik Ekşili Kesme Çorba';
    elsif _kopya_kullanimda_mi(v_id, 'Marmara Usulü Vişne Kompostosu') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Marmara Usulü Vişne Kompostosu';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bilecik Ekşili Kesme Çorba', v_grup2_id, 1, 52,
            '["corba"]'::jsonb, 'kis', 'Marmara',
            '[{"ad": "ET SUYU", "miktar_gram": 200.0}, {"ad": "KURU SOĞAN", "miktar_gram": 33.3}, {"ad": "MAKARNA", "miktar_gram": 25.0}, {"ad": "YEŞİL MERCİMEK", "miktar_gram": 25.0}, {"ad": "KURUTULMUŞ ERIK", "miktar_gram": 8.3}, {"ad": "KIZILCIK", "miktar_gram": 8.3}, {"ad": "TEREYAĞI", "miktar_gram": 8.3}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 3.8}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 3.3}, {"ad": "SARIMSAK", "miktar_gram": 1.7}, {"ad": "TUZ", "miktar_gram": 1.7}, {"ad": "KİMYON", "miktar_gram": 0.8}, {"ad": "KURU NANE", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bilecik Ekşili Kesme Çorba', null, '**Hazırlık / Mise en Place**
1. Yeşil mercimeği haşlayın. Ekşi erik ve kızılcık kurusunu hazırlayın.

**Isıl İşlem**
1. Kavurma (~7 dk): Tencerede sıvı yağ ve tereyağıyla ince doğranmış soğan, sarımsak ve salçayı yeterince kavurun.
2. Pişirme (~25 dk): Önce et suyunu, ardından haşlanmış mercimek ve kesme makarnayı (erişte) ekleyip iyice karıştırın. Erik-kızılcık karışımını, baharatları ve tuzu ekleyip kısık ateşte kıvamına gelene kadar pişirin.

**Servis:** Sıcak servis edin; isteğe göre üzerine tereyağında kavrulmuş sarımsak, salça, karabiber, kimyon ve nane sosu ile maydanoz, nane, pul biber konabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~38 dk · Toplam ~52 dk

**Kaynak:** Bilecik Ekşili Kesme Çorba, Türk Patent Coğrafi İşaret Tescil No 1796 (6 kişilik).',
            '[{"sira": 1, "ad": "Mercimek Haşlama", "sure_dakika": 20, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YEŞİL MERCİMEK"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 7, "aktif_dakika": 7, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "TEREYAĞI", "AYÇİÇEK YAĞI", "KONSERVE DOMATES SALÇASI", "SARIMSAK"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ET SUYU", "MAKARNA", "KURUTULMUŞ ERIK", "KIZILCIK", "TUZ", "KİMYON", "KURU NANE", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Adana Usulü Etli Bulgur Pilavı -> Adana Şırdan (CI 575)
    select id into v_id from receteler where isletme_id is null and ad = 'Adana Usulü Etli Bulgur Pilavı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Adana Usulü Etli Bulgur Pilavı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Adana Şırdan') then
        raise notice 'Yeni ad zaten var, atlandi: Adana Şırdan';
    elsif _kopya_kullanimda_mi(v_id, 'Adana Usulü Etli Bulgur Pilavı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Adana Usulü Etli Bulgur Pilavı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Adana Şırdan', v_grup1_id, 1, 175,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "YENİLEBİLİR SAKATAT (DANA İŞKEMBE)", "miktar_gram": 150.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 18.0}, {"ad": "DONYAĞI", "miktar_gram": 10.0}, {"ad": "KARABİBER", "miktar_gram": 1.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 6.0}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "KİMYON", "miktar_gram": 0.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Adana Şırdan', null, '**Hazırlık / Mise en Place**
1. Koyun şırdanını bol tuzla ovup bol suyla birkaç kez yıkayın; limonlu tuzlu suda birkaç saat bekletip temiz suyla durulayın. Üzerindeki iç (perde) yağını ayırıp kıyın.
2. İç: Soğuk suda yıkanmış nemli pirinci iç yağı, karabiber, kimyon, tuz ve biber salçasıyla harmanlayın.
3. Şırdanın içine 1,5 yemek kaşığı iç koyup ustalıkla ters çevirerek doldurun; ~6 mm paslanmaz iğne ve pişirmede kopmayan iple dikin. Üç kez yıkayın.

**Isıl İşlem**
1. Haşlama (1 saat 45 dk): Kazanda 5 l suya 50 g kaya tuzu ekleyip kaynatın; şırdanları atın. Kapak açık kaynatın, köpüğü alın, her 15 dakikada bir kepçeyle karıştırın.
2. Dinlendirme (30 dk): Ateşi kapatıp kapağı kapalı buharda dinlendirin.

**Servis:** Tabakta ya da kâğıt arasında elde; ipi çıkarılarak sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~135 dk · Toplam ~175 dk (şırdanı limonlu suda bekletme hariç)

**Kaynak:** Adana Şırdan, Türk Patent Coğrafi İşaret Tescil No 575 (1 adet 1 porsiyon).',
            '[{"sira": 1, "ad": "Temizleme ve Doldurma", "sure_dakika": 40, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 105, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YENİLEBİLİR SAKATAT (DANA İŞKEMBE)", "PİRİNÇ (HAM)", "DONYAĞI", "KARABİBER", "KONSERVE BİBER SALÇASI", "TUZ", "KİMYON"], "yeni_su_gram": null}, {"sira": 3, "ad": "Dinlendirme", "sure_dakika": 30, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Manisa Usulü Zeytinyağlı Nohutlu Kabak -> Alaşehir Kapaması (CI 1032)
    select id into v_id from receteler where isletme_id is null and ad = 'Manisa Usulü Zeytinyağlı Nohutlu Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Manisa Usulü Zeytinyağlı Nohutlu Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Alaşehir Kapaması') then
        raise notice 'Yeni ad zaten var, atlandi: Alaşehir Kapaması';
    elsif _kopya_kullanimda_mi(v_id, 'Manisa Usulü Zeytinyağlı Nohutlu Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Manisa Usulü Zeytinyağlı Nohutlu Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Alaşehir Kapaması', v_grup2_id, 1, 193,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Ege',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 100.0}, {"ad": "SU", "miktar_gram": 25.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 22.5}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "DANA KIYMA", "miktar_gram": 75.0}, {"ad": "KUZU KIYMA", "miktar_gram": 25.0}, {"ad": "KURU SOĞAN", "miktar_gram": 50.0}, {"ad": "MAYDANOZ", "miktar_gram": 2.5}, {"ad": "KARABİBER", "miktar_gram": 1.4}, {"ad": "SADEYAĞ", "miktar_gram": 17.5}, {"ad": "ET SUYU", "miktar_gram": 30.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Alaşehir Kapaması', null, '**Hazırlık / Mise en Place**
1. Yufka: Un, su ve tuzu yoğurup 30 dakika dinlendirin; 13-15 cm çapında bezelere ayırıp ayçiçek yağında 1 saat bekletin (yağ tüm yüzeyi kaplamalı).
2. Bezeleri büyük mermer tezgâhta yağlı merdaneyle açıp elle çekiştirerek 1,5-2 mm inceltin (tezgâh görünene kadar); sarkan kısımları kesin.
3. İç harç: Dana kaburga ve kuzu kıymasına rendelenmiş soğan, ince kıyılmış maydanoz, karabiber ve tuzu ekleyip yoğurun; 4°C''de 30 dakika bekletin.
4. Harçtan 20-25 g''lık parçaları yağlı yufkaya 6-7 cm aralıkla koyun; 6x6 veya 7x7 cm kareler kesip köşeleri sırayla kapatarak bohça yapın, katlı kısım altta kalsın. Yuvarlak tepsiye dıştan içe, birbirine hafif değecek şekilde dizin.

**Isıl İşlem**
1. Kızartma (180°C, 5-8 dk): Mantıları %25 sadeyağ, %75 ayçiçek yağı karışımında pişirip süzün; tandır ocağında sıcak tutun.
2. Sos: Kaval kemiklerini %3 tuzlu suda 90-95°C''de 2 saat pişirip süzün; 2/3 kemik suyu ve 1/3 sadeyağ karışımını sıcak tutun.

**Servis:** Porsiyonda 6 mantıyı tabağa alıp üzerine sıcak kemik suyu-sadeyağ karışımını kepçeyle gezdirin.

**SÜRE ÖZETİ:** Aktif işçilik ~113 dk · Pasif bekleme ~80 dk · Toplam ~193 dk (kemik suyu (2 saat) önceden hazırlanır)

**Kaynak:** Alaşehir Kapaması / Alaşehir Kapatması, Türk Patent Coğrafi İşaret Tescil No 1032 (10 porsiyon, porsiyonda 6 mantı).',
            '[{"sira": 1, "ad": "Hamur ve Yağda Bekletme", "sure_dakika": 90, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Açma", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "İç Harç", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Kesme ve Kapatma", "sure_dakika": 45, "aktif_dakika": 45, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 5, "ad": "Kızartma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 180, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY UNU", "SU", "AYÇİÇEK YAĞI", "TUZ", "DANA KIYMA", "KUZU KIYMA", "KURU SOĞAN", "MAYDANOZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 6, "ad": "Sos ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SADEYAĞ", "ET SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Salihli Usulü Kavurmalı Yumurta -> Kırkağaç Pideli Paça (CI 1579)
    select id into v_id from receteler where isletme_id is null and ad = 'Salihli Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Salihli Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Kırkağaç Pideli Paça') then
        raise notice 'Yeni ad zaten var, atlandi: Kırkağaç Pideli Paça';
    elsif _kopya_kullanimda_mi(v_id, 'Salihli Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Salihli Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Kırkağaç Pideli Paça', v_grup1_id, 1, 15,
            '["kirmizi_et"]'::jsonb, 'kis', 'Ege',
            '[{"ad": "YENİLEBİLİR SAKATAT (DANA DİL)", "miktar_gram": 157.5}, {"ad": "PİDE", "miktar_gram": 117.5}, {"ad": "ET SUYU", "miktar_gram": 110.0}, {"ad": "TEREYAĞI", "miktar_gram": 27.5}, {"ad": "SİRKE", "miktar_gram": 5.0}, {"ad": "SARIMSAK", "miktar_gram": 5.0}, {"ad": "PUL BİBER", "miktar_gram": 2.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Kırkağaç Pideli Paça', null, '**Hazırlık / Mise en Place**
1. Kelle ve kemik suyu (önceden): Temizlenmiş büyükbaş başını bütün olarak ve kaval kemiklerini büyük parçalar halinde kaba koyun; üzerini kapatacak kadar su ve hacmin %1-1,5''i kadar kaya tuzu ekleyip tercihen odun ateşinde 8-10 saat haşlayın, köpükleri alın. Kemik suyunu süzüp 80-90°C''de tutun. Baş etini tiftikleyip etin yarısı kadar kemik suyuyla sıcak tutun.
2. Pide: Hamuru 225-275 g''lık parçalara bölüp kepekle 7-8 x 17-19 cm açın; odun ateşinin yalazasında ~5 dakika pişirin.
3. Sos: 5 g üzüm sirkesine 1 diş dövülmüş sarımsak ekleyin.

**Isıl İşlem**
1. Pide pişirme (~5 dk).
2. Tereyağı: Tereyağını ateşte kızdırın.

**Servis:** Pideyi 3-4 cm kare/dikdörtgen kesip en fazla iki kat tabağa dizin; sıcak kemik suyuyla yumuşayana kadar ıslatın. Tiftiklenmiş kelle etini koyup 1-2 kepçe kemik suyu daha ekleyin; isteğe göre biber, ardından sirke-sarımsak sosu ve kızdırılmış tereyağı dökerek sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~0 dk · Toplam ~15 dk (8-10 saatlik kelle ve kemik suyu haşlama önceden yapılır)

**Kaynak:** Kırkağaç Pideli Paça / Kırkağaç Çakal Pideli Paça, Türk Patent Coğrafi İşaret Tescil No 1579 (1 porsiyon).',
            '[{"sira": 1, "ad": "Pide Pişirme", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİDE"], "yeni_su_gram": null}, {"sira": 2, "ad": "Servis Düzeni", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YENİLEBİLİR SAKATAT (DANA DİL)", "ET SUYU", "SİRKE", "SARIMSAK", "PUL BİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Tereyağı", "sure_dakika": 2, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Kırklareli Usulü Izgara Levrek -> Brakana Tatlısı (CI 1494)
    select id into v_id from receteler where isletme_id is null and ad = 'Kırklareli Usulü Izgara Levrek';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Kırklareli Usulü Izgara Levrek';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Brakana Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Brakana Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Kırklareli Usulü Izgara Levrek') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Kırklareli Usulü Izgara Levrek';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Brakana Tatlısı', v_grup3_id, 1, 150,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 20.0}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 20.6}, {"ad": "MARGARİN", "miktar_gram": 12.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 18.4}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 7.5}, {"ad": "BIRAKIN YUMURTA SARISI", "miktar_gram": 1.7}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.1}, {"ad": "KABARTMA TOZU", "miktar_gram": 0.5}, {"ad": "TOZ ŞEKER", "miktar_gram": 40.0}, {"ad": "SU", "miktar_gram": 50.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Brakana Tatlısı', null, '**Hazırlık / Mise en Place**
1. Katı yağ, sıvı yağ ve sütü tencerede kaynatın; unu ekleyip ateşi kapatın, karıştırarak yoğurun ve soğutun.
2. Soğuyan karışıma 2 tam yumurta ve 2 yumurta sarısı ekleyin (hamur yumurtayı pişirmeyecek kadar soğuk olmalı); kabartma tozu ve karbonatı katıp yoğurun. Yumuşaksa biraz un ekleyin.
3. Hamuru bezelere ayırıp yuvarlayın, ortasına parmakla bastırıp hafif çukurlaştırın ve tepsiye dizin.

**Isıl İşlem**
1. Fırınlama (180°C): Pembeleşmeye başlayana kadar pişirin.
2. Şerbet: Şeker ve suyu kaynatın.
3. İlk şerbet ve ikinci fırın (5-6 dk): Sıcak şerbetin yarısını sıcak bezelerin üzerine dökün; rengi hafif kahverengileşene kadar tekrar fırınlayın.
4. Demleme: Şerbetin diğer yarısını dökün; üzerine ters bir tepsi kapatıp demlendirin.

**Servis:** Soğuduktan sonra servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~47 dk · Pasif bekleme ~103 dk · Toplam ~150 dk

**Kaynak:** Brakana Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1494 (yaklaşık 20 adet).',
            '[{"sira": 1, "ad": "Hamur", "sure_dakika": 30, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜT (TAM YAĞ)", "MARGARİN", "AYÇİÇEK YAĞI", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Şekillendirme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["TAVUK YUMURTASI", "BIRAKIN YUMURTA SARISI", "KARBONAT (YEM. SODA)", "KABARTMA TOZU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbet ve İkinci Fırın", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 5, "ad": "Demleme ve Soğutma", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Çanakkale Usulü Kavurmalı Yumurta -> Bayramiç Tahin Helvası (CI 843)
    select id into v_id from receteler where isletme_id is null and ad = 'Çanakkale Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çanakkale Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Bayramiç Tahin Helvası') then
        raise notice 'Yeni ad zaten var, atlandi: Bayramiç Tahin Helvası';
    elsif _kopya_kullanimda_mi(v_id, 'Çanakkale Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çanakkale Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Bayramiç Tahin Helvası', v_grup3_id, 1, 90,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "TAHİN", "miktar_gram": 27.5}, {"ad": "TOZ ŞEKER", "miktar_gram": 22.5}, {"ad": "SU", "miktar_gram": 10.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Bayramiç Tahin Helvası', null, '**Isıl İşlem**
1. Ağda (140°C, ~40 dk): Helva pişirme makinesine şeker, sitrik asit ve suyu koyup kaynatın. Çöven ekstraktını ekleyip ısıtmayı sonlandırın; karışım 60-70°C''ye düşünce ağda olgunlaşır.
2. Yoğurma: Ağdayı bakır kazanlara alıp tahinle, tahin helvasına uygun yapı, görünüş ve tekstür oluşana kadar yoğurun.
3. Kalıplama: Tartıp kalıplara koyun.

**Servis:** Dilimleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~55 dk · Toplam ~90 dk

**Kaynak:** Bayramiç Tahin Helvası, Türk Patent Coğrafi İşaret Tescil No 843 (porsiyon 50 g).',
            '[{"sira": 1, "ad": "Ağda Kaynatma", "sure_dakika": 40, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 140, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Soğuma", "sure_dakika": 20, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Tahinle Yoğurma ve Kalıp", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["TAHİN"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Çanakkale Usulü Zeytinyağlı Taze Fasulye -> Biga Peynir Tatlısı (CI 1312)
    select id into v_id from receteler where isletme_id is null and ad = 'Çanakkale Usulü Zeytinyağlı Taze Fasulye';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Çanakkale Usulü Zeytinyağlı Taze Fasulye';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Biga Peynir Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Biga Peynir Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Çanakkale Usulü Zeytinyağlı Taze Fasulye') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Çanakkale Usulü Zeytinyağlı Taze Fasulye';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Biga Peynir Tatlısı', v_grup3_id, 1, 110,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "LOR PEYNİRİ", "miktar_gram": 40.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 35.0}, {"ad": "SU", "miktar_gram": 43.0}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 6.0}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 1.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 25.0}, {"ad": "LİMON SUYU", "miktar_gram": 0.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Biga Peynir Tatlısı', null, '**Hazırlık / Mise en Place**
1. Hamur: Sırasıyla yumurta, öğütülmüş teleme/tuzsuz taze peynir, un, karbonat ve suyu kazana koyup yumuşak kıvama gelene kadar yoğurun (%40 peynir, %35 un, %18 su, %6 yumurta, %1 karbonat).
2. Hamuru elle ya da aparatla yarım küre şeklinde şekillendirip tepsiye dizin.

**Isıl İşlem**
1. Fırınlama (buharlı 250°C 20 dk ya da buharsız 170°C 40 dk): Pişirip soğutun.
2. Şerbet (~10 dk): Şeker ve suyu kaynatın; isteğe göre limon suyu ekleyip ~10 dakika daha kaynatın.
3. Şerbette kaynatma (~20 dk): Tatlıları şerbete ekleyip şerbetini çekene kadar kaynatın.

**Servis:** Tabaklara alıp isteğe göre kaymak veya dondurmayla servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~80 dk · Toplam ~110 dk

**Kaynak:** Biga Peynir Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1312 (porsiyon 100 g hamur).',
            '[{"sira": 1, "ad": "Hamur ve Şekil", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["LOR PEYNİRİ", "BUĞDAY UNU", "TAVUK YUMURTASI", "KARBONAT (YEM. SODA)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğutma", "sure_dakika": 20, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbette Kaynatma", "sure_dakika": 30, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Balıkesir Usulü Elmalı Ceviz Tatlısı -> Ayvalık Lor Tatlısı (CI 1305)
    select id into v_id from receteler where isletme_id is null and ad = 'Balıkesir Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Balıkesir Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Ayvalık Lor Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Ayvalık Lor Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Balıkesir Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Balıkesir Usulü Elmalı Ceviz Tatlısı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Ayvalık Lor Tatlısı', v_grup3_id, 1, 168,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
            '[{"ad": "LOR PEYNİRİ", "miktar_gram": 66.7}, {"ad": "BUĞDAY UNU", "miktar_gram": 13.3}, {"ad": "SU", "miktar_gram": 140.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 66.7}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Ayvalık Lor Tatlısı', null, '**Hazırlık / Mise en Place**
1. Tuzsuz tam yağlı taze loru çırpıcı kazanda macun kıvamına getirin; unu (veya irmik-karbonat karışımını) ekleyip elle karıştırın.
2. Karışımın ağırlığının yarısı kadar su ekleyip yumuşak bir hamur yoğurun.
3. Hamuru özel hunili bez torbayla 2 cm kalınlık ve 10-12 cm çap olacak şekilde 80x40 cm tepsiye sıkın.

**Isıl İşlem**
1. Fırınlama (odun fırını, 180°C, 40 dk): Pişirip oda sıcaklığında soğutun.
2. Şerbetleme: 1 kg şeker ve 1-2 l sudan şerbeti kaynatın; soğumuş tatlıları ekleyip 10-15 dakika kaynatın. Şerbet içinde 1 saat bekletin, kevgirle çıkarın.

**Servis:** Servis edin; oda sıcaklığında en fazla 3 gün saklanır.

**SÜRE ÖZETİ:** Aktif işçilik ~32 dk · Pasif bekleme ~136 dk · Toplam ~168 dk

**Kaynak:** Ayvalık Lor Tatlısı, Türk Patent Coğrafi İşaret Tescil No 1305 (45 adet; porsiyonda 3 adet).',
            '[{"sira": 1, "ad": "Hamur ve Sıkma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 40, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["LOR PEYNİRİ", "BUĞDAY UNU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğutma", "sure_dakika": 30, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Şerbette Kaynatma", "sure_dakika": 13, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 105, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER", "SU"], "yeni_su_gram": null}, {"sira": 5, "ad": "Şerbette Bekletme", "sure_dakika": 60, "aktif_dakika": 0, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mersin Usulü Zeytinyağlı Nohutlu Havuç -> Mersin Kerebici (CI 426)
    select id into v_id from receteler where isletme_id is null and ad = 'Mersin Usulü Zeytinyağlı Nohutlu Havuç';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mersin Usulü Zeytinyağlı Nohutlu Havuç';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mersin Kerebici') then
        raise notice 'Yeni ad zaten var, atlandi: Mersin Kerebici';
    elsif _kopya_kullanimda_mi(v_id, 'Mersin Usulü Zeytinyağlı Nohutlu Havuç') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mersin Usulü Zeytinyağlı Nohutlu Havuç';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mersin Kerebici', v_grup3_id, 1, 93,
            '["tatli", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "İRMİK", "miktar_gram": 40.0}, {"ad": "MARGARİN", "miktar_gram": 7.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 7.5}, {"ad": "SU", "miktar_gram": 70.0}, {"ad": "MAHLEP", "miktar_gram": 0.3}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.25}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 1.5}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 35.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 35.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mersin Kerebici', null, '**Hazırlık / Mise en Place**
1. Hamur: İrmik, pastalık margarin, ayçiçek yağı, su, mahlep, karbonat ve az pekmezi oda sıcaklığında (~25°C) elastik olana kadar 10-15 dakika yoğurun; 5-8 dakika dinlendirin.
2. Hamuru 25-30 g''lık bezelere ayırıp avuçta yuvarlayın, içini oyun; 15-20 g iri çekilmiş ceviz (veya Antep fıstığı) doldurup kapatın (kerebiç köftesi 45-55 g).
3. Kerebiç köpüğü: Çöven kökünü kaynatıp elde edilen çözeltiyi köpürtün ve şekerle karıştırın.

**Isıl İşlem**
1. Fırınlama (odun ateşi, 300-350°C, 15-20 dk): Yağlanmış ve ısıtılmış tepsiye dizip üstü kızarana kadar pişirin; oda sıcaklığında soğutun.

**Servis:** Sunumdan önce kerebiçlerin üzerini kapatacak kadar köpük koyun.

**SÜRE ÖZETİ:** Aktif işçilik ~57 dk · Pasif bekleme ~36 dk · Toplam ~93 dk

**Kaynak:** Mersin Kerebici, Türk Patent Coğrafi İşaret Tescil No 426 (~200 adet; porsiyonda 2 adet).',
            '[{"sira": 1, "ad": "Hamur ve Doldurma", "sure_dakika": 45, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 18, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İRMİK", "MARGARİN", "AYÇİÇEK YAĞI", "SU", "MAHLEP", "KARBONAT (YEM. SODA)", "ÜzÜM PEKMEZİ", "CEVİZ (İÇ)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Köpük ve Servis", "sure_dakika": 30, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mersin Usulü Zeytinyağlı Nohutlu Kereviz -> Tarsus Fındık Lahmacunu (CI 538)
    select id into v_id from receteler where isletme_id is null and ad = 'Mersin Usulü Zeytinyağlı Nohutlu Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mersin Usulü Zeytinyağlı Nohutlu Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Tarsus Fındık Lahmacunu') then
        raise notice 'Yeni ad zaten var, atlandi: Tarsus Fındık Lahmacunu';
    elsif _kopya_kullanimda_mi(v_id, 'Mersin Usulü Zeytinyağlı Nohutlu Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mersin Usulü Zeytinyağlı Nohutlu Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Tarsus Fındık Lahmacunu', v_grup2_id, 1, 183,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "KOYUN KIYMA", "miktar_gram": 100.0}, {"ad": "KURU SOĞAN", "miktar_gram": 20.0}, {"ad": "KIRMIZI BİBER", "miktar_gram": 15.0}, {"ad": "DOMATES", "miktar_gram": 15.0}, {"ad": "MAYDANOZ", "miktar_gram": 15.0}, {"ad": "TUZ", "miktar_gram": 8.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 100.0}, {"ad": "SU", "miktar_gram": 50.0}, {"ad": "KURU MAYA", "miktar_gram": 3.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Tarsus Fındık Lahmacunu', null, '**Hazırlık / Mise en Place**
1. Etli harç: Kekik vb. otlarla beslenen erkek koyunun etini kemik ve sinirden ayırıp küçük doğrayın, tuzlayın. Etin ~%60''ını zırhla, ~%40''ını kıyma makinesiyle kıyın; ~4°C''de 2 saat dinlendirin. Ete yağ eklenmez.
2. Soğan, kapya biber, soyulmuş domates ve ince kıyılmış maydanozu zırhla çekin; isteğe göre kırmızı toz biber ekleyip etle karıştırın.
3. Hamur: Un, su, yaş maya ve tuzu ~25°C''de 10-15 dakika yoğurun; 15 dakika fermantasyona bırakın. ~20 g''lık parçalar kesip yuvarlayın.
4. Hamurları sac tavaya eşit aralıkla dizip elle ~1 cm kalınlıkta, en fazla 8 cm çapında açın; her birine ~20 g harç koyup bastırmadan yayın.

**Isıl İşlem**
1. Fırınlama (taş fırın, odun alevi, ~250°C, 7-8 dk).

**Servis:** Porsiyonda 8-10 adet sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~53 dk · Pasif bekleme ~130 dk · Toplam ~183 dk

**Kaynak:** Tarsus Fındık Lahmacunu, Türk Patent Coğrafi İşaret Tescil No 538 (1 porsiyon (8-10 adet)).',
            '[{"sira": 1, "ad": "Et Hazırlığı ve Dinlendirme", "sure_dakika": 130, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Hamur ve Fermantasyon", "sure_dakika": 30, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Şekillendirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 8, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN KIYMA", "KURU SOĞAN", "KIRMIZI BİBER", "DOMATES", "MAYDANOZ", "TUZ", "TATLIKA KIRMIZI BİBER", "BUĞDAY UNU", "SU", "KURU MAYA"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Mersin Usulü Izgara Karides -> Tarsus Kebabı (CI 539)
    select id into v_id from receteler where isletme_id is null and ad = 'Mersin Usulü Izgara Karides';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mersin Usulü Izgara Karides';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Tarsus Kebabı') then
        raise notice 'Yeni ad zaten var, atlandi: Tarsus Kebabı';
    elsif _kopya_kullanimda_mi(v_id, 'Mersin Usulü Izgara Karides') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mersin Usulü Izgara Karides';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Tarsus Kebabı', v_grup1_id, 1, 45,
            '["kirmizi_et", "izgara"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "KOYUN ETİ (SIRT)", "miktar_gram": 91.3}, {"ad": "KUYRUKYAĞI", "miktar_gram": 16.0}, {"ad": "KURU SOĞAN", "miktar_gram": 18.3}, {"ad": "KIRMIZI BİBER", "miktar_gram": 13.7}, {"ad": "MAYDANOZ", "miktar_gram": 1.4}, {"ad": "TUZ", "miktar_gram": 1.1}, {"ad": "LAVAŞ", "miktar_gram": 60.0}, {"ad": "DOMATES", "miktar_gram": 50.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 15.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Tarsus Kebabı', null, '**Hazırlık / Mise en Place**
1. Erkek koyunun kaburga etini sinir, damar ve zarlarından ayıklayıp en az 12 saat dinlendirin; kuyruk yağını da dinlendirin.
2. Ete tuz serpip zırhla el kıyması hazırlayın; salça ve karabiber eklenmez. Etin %15-20''si kadar kuyruk yağını ayrıca zırhla kıyıp karıştırın.
3. Soğan, kapya biber ve maydanozu zırhla çekin, suyunu iyice sıkıp ete ekleyin ve yoğurun (isteğe göre kırmızı toz biber).
4. Porsiyon için ~130 g harcı ıslak elle 3 cm eninde, 80 cm boyunda yassı krom şişe 0,5 cm kalınlıkta dengeli sıvayın; uçlarını bastırın.

**Isıl İşlem**
1. Izgara (meşe kömürü, durgun kor): Devamlı çevirerek kahverengi olana kadar pişirin; damlayan yağı açık ekmekle alın. Domates ve yeşil biberi kebapla birlikte pişirin.

**Servis:** Geniş tabakta açık ekmeğin bir parçasını kebabın altına, diğerlerini üstüne koyun; domates ve biberle süsleyin. Yanında sumaklı soğan ve ezme salata ile servis edin (pişmiş porsiyon ~110 g).

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk · Pasif bekleme ~0 dk · Toplam ~45 dk (12 saat et dinlendirme hariç)

**Kaynak:** Tarsus Kebabı, Türk Patent Coğrafi İşaret Tescil No 539 (porsiyon 130 g çiğ harç).',
            '[{"sira": 1, "ad": "Harç Hazırlığı", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Şişe Sıvama", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN ETİ (SIRT)", "KUYRUKYAĞI", "KURU SOĞAN", "KIRMIZI BİBER", "MAYDANOZ", "TUZ", "DOMATES", "YEŞİL BİBER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["LAVAŞ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Alanya Usulü Kavurmalı Yumurta -> Alanya Gülüklü Çorba (CI 459)
    select id into v_id from receteler where isletme_id is null and ad = 'Alanya Usulü Kavurmalı Yumurta';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Alanya Usulü Kavurmalı Yumurta';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Alanya Gülüklü Çorba') then
        raise notice 'Yeni ad zaten var, atlandi: Alanya Gülüklü Çorba';
    elsif _kopya_kullanimda_mi(v_id, 'Alanya Usulü Kavurmalı Yumurta') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Alanya Usulü Kavurmalı Yumurta';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Alanya Gülüklü Çorba', v_grup2_id, 1, 195,
            '["corba", "kirmizi_et"]'::jsonb, 'kis', 'Akdeniz',
            '[{"ad": "YENİLEBİLİR SAKATAT (DANA İŞKEMBE)", "miktar_gram": 250.0}, {"ad": "SU", "miktar_gram": 200.0}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30.0}, {"ad": "NOHUT", "miktar_gram": 20.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 10.0}, {"ad": "DOMATES", "miktar_gram": 73.3}, {"ad": "TEREYAĞI", "miktar_gram": 20.0}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 2.0}, {"ad": "TUZ", "miktar_gram": 1.7}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "LİMON SUYU", "miktar_gram": 27.7}, {"ad": "KEÇİ KIYMA", "miktar_gram": 33.3}, {"ad": "KARABİBER", "miktar_gram": 0.8}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Alanya Gülüklü Çorba', null, '**Hazırlık / Mise en Place**
1. Pirinci nişastası gidene kadar yıkayıp yarım litre tuzlu ılık suda 1 saat bekletin. Nohudu bir gece önceden 1 l suda ıslatın, ertesi gün kısık ateşte haşlayın.
2. İşkembenin tırtıklı yüzünü soyup 10x20 cm parçalar kesin; kuru soğan, kabuklu dilimlenmiş limon ve tuzla 10-15 dakika ovalayıp ~10 dakika bol suyla yıkayın.
3. Gülük: Yağsız keçi etini iki kez çekin; karabiber ve tuzla 6-7 dakika yoğurun, haşlanmış nohut büyüklüğünde toplar yapın (avuç içine arada limon suyu sürün).

**Isıl İşlem**
1. İşkembe haşlama (30-50 dk): 4 l suda köpüğünü alarak haşlayın; bütün soğan, kesik atılmış domates ve tuz ekleyin. Pişen işkembeyi çıkarıp zar büyüklüğünde kıyın.
2. Gülük kızartma (10-15 dk): Gülükleri düz tabanlı tencerede tereyağı ve zeytinyağıyla orta ateşte kızartın; rendelenmiş domatesi ekleyip 5-6 dakika, salça ve kırmızı biberi ekleyip ~10 dakika daha kavurun.
3. Çorba (~25 dk): 1200 ml su (veya kemik suyu) ve tuzu ekleyip kaynatın. İşkembe ve nohudu katıp 10 dakika kaynatın; limon suyu ve ıslatılmış pirinci ekleyip pirinç yumuşayana kadar (10-15 dk) pişirin.

**Servis:** Ocaktan alıp kuru nane serpin; kıvam için isteğe göre sıcak su ekleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Nohut ve işkembe aynı anda haşlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~68 dk · Pasif bekleme ~127 dk · Toplam ~195 dk (nohut ıslatma hariç)

**Kaynak:** Alanya Gülüklü (Hülüklü) Çorba, Türk Patent Coğrafi İşaret Tescil No 459 (yaklaşık 6 kişilik (işkembeli)).',
            '[{"sira": 1, "ad": "Islatma ve Temizleme", "sure_dakika": 60, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Nohut Haşlama", "sure_dakika": 40, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT"], "yeni_su_gram": null}, {"sira": 3, "ad": "İşkembe Haşlama", "sure_dakika": 40, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YENİLEBİLİR SAKATAT (DANA İŞKEMBE)"], "yeni_su_gram": null}, {"sira": 4, "ad": "Gülük ve Kavurma", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEÇİ KIYMA", "KARABİBER", "TEREYAĞI", "ZEYTİNYAĞI", "DOMATES", "KONSERVE DOMATES SALÇASI", "TATLIKA KIRMIZI BİBER"], "yeni_su_gram": null}, {"sira": 5, "ad": "Çorba", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SU", "TUZ", "PİRİNÇ (HAM)", "LİMON SUYU", "KURU NANE"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Alanya Usulü Elmalı Ceviz Tatlısı -> Antalya Kabak Tatlısı (CI 719)
    select id into v_id from receteler where isletme_id is null and ad = 'Alanya Usulü Elmalı Ceviz Tatlısı';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Alanya Usulü Elmalı Ceviz Tatlısı';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Antalya Kabak Tatlısı') then
        raise notice 'Yeni ad zaten var, atlandi: Antalya Kabak Tatlısı';
    elsif _kopya_kullanimda_mi(v_id, 'Alanya Usulü Elmalı Ceviz Tatlısı') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Alanya Usulü Elmalı Ceviz Tatlısı';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Antalya Kabak Tatlısı', v_grup3_id, 1, 191,
            '["tatli", "vejetaryen"]'::jsonb, 'sonbahar', 'Akdeniz',
            '[{"ad": "KABAK", "miktar_gram": 187.5}, {"ad": "TOZ ŞEKER", "miktar_gram": 75.0}, {"ad": "TAHİN", "miktar_gram": 12.5}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 12.5}, {"ad": "LİMON SUYU", "miktar_gram": 2.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Antalya Kabak Tatlısı', null, '**Hazırlık / Mise en Place**
1. Bal kabağını (Döşemealtı, Camili köyü) dilimleyip sert kabuğunu ustalıkla soyun; beyaz zar ne kalın ne ince kalmalı. Her dilimi 3 eşit parçaya bölün.
2. Kabakları şekere yatırıp berraklık için yarım limonun suyunu ekleyin; 12-24 saat bekletin.

**Isıl İşlem**
1. Ocakta pişirme (2-3 saat): Şekere yatırılıp sulanan kabağı kendi suyunda, ters yüz ederek ağır ateşte pişirin; köpüğünü alın. Şeker yoğunlaşıp kıvam alınca tamamdır.
2. Fırınlama (175°C, 15-20 dk): Kabakları tepsiye alıp üstü kızarana kadar fırınlayın.

**Servis:** Üzerine çifte kavrulmuş tahin dökün, ceviz serpip oda sıcaklığında servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~151 dk · Toplam ~191 dk (12-24 saat şekerde bekletme hariç)

**Kaynak:** Antalya Kabak Tatlısı, Türk Patent Coğrafi İşaret Tescil No 719 (yaklaşık 8 kişilik).',
            '[{"sira": 1, "ad": "Soyma ve Doğrama", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Ocakta Pişirme", "sure_dakika": 150, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "TOZ ŞEKER", "LİMON SUYU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Fırınlama", "sure_dakika": 18, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Servis", "sure_dakika": 3, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["TAHİN", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Antalya Usulü Etli Kavurma (Kimyonlu) -> Antalya Topak Kızartması (CI 1613)
    select id into v_id from receteler where isletme_id is null and ad = 'Antalya Usulü Etli Kavurma (Kimyonlu)';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Antalya Usulü Etli Kavurma (Kimyonlu)';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Antalya Topak Kızartması') then
        raise notice 'Yeni ad zaten var, atlandi: Antalya Topak Kızartması';
    elsif _kopya_kullanimda_mi(v_id, 'Antalya Usulü Etli Kavurma (Kimyonlu)') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Antalya Usulü Etli Kavurma (Kimyonlu)';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Antalya Topak Kızartması', v_grup1_id, 1, 92,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "KEÇİ ETİ (KOL)", "miktar_gram": 125.0}, {"ad": "KURU SOĞAN", "miktar_gram": 22.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 12.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 12.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 12.0}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 32.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 3.5}, {"ad": "YENİBAHAR", "miktar_gram": 0.3}, {"ad": "TARÇIN", "miktar_gram": 0.5}, {"ad": "SU", "miktar_gram": 145.0}, {"ad": "DOMATES", "miktar_gram": 33.0}, {"ad": "YEŞİL BİBER", "miktar_gram": 4.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Antalya Topak Kızartması', null, '**Hazırlık / Mise en Place**
1. Kemikli keçi etini (kol ya da bacak) doğrayın. Soğan, domates ve yeşil biberi ince doğrayın.

**Isıl İşlem**
1. Kızartma (~10 dk): Etleri kızgın sıvı yağda kızartın.
2. Sos (~10 dk): Ayrı bir tencerede soğan, domates ve yeşil biberi yağda kavurun; salçaları ve kırmızı toz biberi ekleyin. Suyu ilave edin.
3. Pişirme (1 saat): Karışım kaynayınca kızarmış etleri koyup kısık ateşte pişirin. Bitmesine 15 dakika kala defne yaprağı veya karanfil, tane karabiber, tane yenibahar, kabuk tarçın ve tuzu ekleyip 10 dakika kaynatın; en son isteğe göre arpacık soğanları ekleyip 2 dakika daha kaynatın.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~57 dk · Toplam ~92 dk

**Kaynak:** Antalya Topak Kızartması, Türk Patent Coğrafi İşaret Tescil No 1613 (5 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Et Kızartma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 160, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEÇİ ETİ (KOL)", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "DOMATES", "YEŞİL BİBER", "KONSERVE DOMATES SALÇASI", "KONSERVE BİBER SALÇASI", "TATLIKA KIRMIZI BİBER", "SU"], "yeni_su_gram": null}, {"sira": 4, "ad": "Pişirme", "sure_dakika": 62, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARABİBER", "TUZ", "YENİBAHAR", "TARÇIN"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Antalya Usulü Etli Kabak -> Antalya Serpme Böreği (CI 736)
    select id into v_id from receteler where isletme_id is null and ad = 'Antalya Usulü Etli Kabak';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Antalya Usulü Etli Kabak';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Antalya Serpme Böreği') then
        raise notice 'Yeni ad zaten var, atlandi: Antalya Serpme Böreği';
    elsif _kopya_kullanimda_mi(v_id, 'Antalya Usulü Etli Kabak') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Antalya Usulü Etli Kabak';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Antalya Serpme Böreği', v_grup2_id, 1, 60,
            '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "BUĞDAY UNU", "miktar_gram": 79.0}, {"ad": "TUZ", "miktar_gram": 2.7}, {"ad": "SU", "miktar_gram": 43.5}, {"ad": "AYÇİÇEK YAĞI", "miktar_gram": 17.0}, {"ad": "DANA KIYMA", "miktar_gram": 50.0}, {"ad": "KURU SOĞAN", "miktar_gram": 15.0}, {"ad": "MAYDANOZ", "miktar_gram": 3.0}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Antalya Serpme Böreği', null, '**Hazırlık / Mise en Place**
1. Hamur: Baklavalık/böreklik un, tuz ve suyu kulak memesi kıvamına gelene kadar 7-10 dakikalık aralarla 2-3 kez yoğurun. Silindir yapıp 120 g''lık bezeler tartın; yağlanmış tepsilere dizip üzerini yağlayın, streç filmle örtüp buzdolabında 1 gün bekletin.
2. Kıymalı iç: Soğan ve kıymayı ayrı tavalarda kavurup birleştirin, 5 dakika birlikte kavurun; karabiber, maydanoz ve tuz ekleyin.
3. Bezeleri yağlayıp mermerde merdaneyle 12-25 cm daireye büyütün (ortası kenarlardan biraz kalın); oklava kullanmadan 6-7 kez havada savurarak kâğıt inceliğinde 50-60 cm açın.
4. Hamuru tezgâha yayıp alttan ve yanlardan ortaya katlayın; 60-80 g kıymalı harç koyup karşılıklı kenarları katlayarak dikdörtgen kapatın.

**Isıl İşlem**
1. Kavurma (~10 dk).
2. Fırınlama (200-220°C, en fazla 10 dk): Yağlanmış sac tepsiye dizip altı üstü kızarana kadar pişirin.

**Servis:** Dilimleyerek servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~47 dk · Pasif bekleme ~13 dk · Toplam ~60 dk (bezelerin 1 gün buzdolabında bekletilmesi hariç)

**Kaynak:** Antalya Serpme Böreği, Türk Patent Coğrafi İşaret Tescil No 736 (1 börek 1 porsiyon (kıymalı)).',
            '[{"sira": 1, "ad": "Hamur ve Bezeleme", "sure_dakika": 30, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kıymalı İç", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "MAYDANOZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Açma ve Kapatma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Fırınlama", "sure_dakika": 10, "aktif_dakika": 2, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["BUĞDAY UNU", "TUZ", "SU", "AYÇİÇEK YAĞI"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Muş Usulü Etli Nohutlu Bulgur -> Muş Köftesi (CI 966)
    select id into v_id from receteler where isletme_id is null and ad = 'Muş Usulü Etli Nohutlu Bulgur';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Muş Usulü Etli Nohutlu Bulgur';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Muş Köftesi') then
        raise notice 'Yeni ad zaten var, atlandi: Muş Köftesi';
    elsif _kopya_kullanimda_mi(v_id, 'Muş Usulü Etli Nohutlu Bulgur') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Muş Usulü Etli Nohutlu Bulgur';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Muş Köftesi', v_grup1_id, 1, 138,
            '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
            '[{"ad": "İNCE BULGUR", "miktar_gram": 62.5}, {"ad": "DANA KIYMA", "miktar_gram": 83.3}, {"ad": "KUZU KIYMA", "miktar_gram": 20.8}, {"ad": "KURU SOĞAN", "miktar_gram": 83.3}, {"ad": "KEKİK", "miktar_gram": 8.3}, {"ad": "MAYDANOZ", "miktar_gram": 4.2}, {"ad": "PUL BİBER", "miktar_gram": 8.3}, {"ad": "KARABİBER", "miktar_gram": 4.2}, {"ad": "TUZ", "miktar_gram": 6.25}, {"ad": "KİMYON", "miktar_gram": 4.2}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 4.2}, {"ad": "TEREYAĞI", "miktar_gram": 20.8}, {"ad": "SU", "miktar_gram": 83.3}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Muş Köftesi', null, '**Hazırlık / Mise en Place**
1. İç harç: İnce doğranmış soğanı, yağlı kıyma, pul biber (50 g), kimyon, tuz (15 g), kekik ve karabiberle tereyağında kavurup soğutun.
2. Dış harç: İnce bulguru yoğurma kabına alın; satırla kıyılmış yağsız eti ekleyip en az yarım saat yoğurun. Ilık suyu ekleyerek hamur kıvamına gelene kadar yoğurmaya devam edin (yumurta ve tuzu bu aşamada katın).
3. Ceviz büyüklüğünde parçalar koparıp avuçta yuvarlayın, içini açıp iç harçtan koyun ve kapatın.

**Isıl İşlem**
1. Haşlama (~20 dk): Suyu kaynatıp tuz, tereyağı ve köfteleri koyun; haşlayın.
2. Kavurma: Tereyağını eritip pul biber ekleyin; haşlanan köfteleri bu yağda hafifçe kavurun.
3. Sos: Tavada tereyağını eritip tuz, pul biber ve çok az kekik ekleyin.

**Servis:** Tabağa aldığınız köftelerin üzerine tereyağlı sosu gezdirip servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~116 dk · Pasif bekleme ~22 dk · Toplam ~138 dk

**Kaynak:** Muş Köftesi, Türk Patent Coğrafi İşaret Tescil No 966 (yaklaşık 12 kişilik).',
            '[{"sira": 1, "ad": "İç Harç", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "KURU SOĞAN", "KEKİK", "KİMYON"], "yeni_su_gram": null}, {"sira": 2, "ad": "Dış Harç", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Şekillendirme", "sure_dakika": 50, "aktif_dakika": 50, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 4, "ad": "Haşlama", "sure_dakika": 20, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İNCE BULGUR", "DANA KIYMA", "TAVUK YUMURTASI", "SU", "MAYDANOZ"], "yeni_su_gram": null}, {"sira": 5, "ad": "Kavurma ve Sos", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 110, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "PUL BİBER", "KARABİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Muş Usulü Zeytinyağlı Nohut -> Muş Çorti Aşı (CI 409)
    select id into v_id from receteler where isletme_id is null and ad = 'Muş Usulü Zeytinyağlı Nohut';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Muş Usulü Zeytinyağlı Nohut';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Muş Çorti Aşı') then
        raise notice 'Yeni ad zaten var, atlandi: Muş Çorti Aşı';
    elsif _kopya_kullanimda_mi(v_id, 'Muş Usulü Zeytinyağlı Nohut') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Muş Usulü Zeytinyağlı Nohut';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Muş Çorti Aşı', v_grup1_id, 1, 73,
            '["kirmizi_et", "etli_sebze"]'::jsonb, 'kis', 'Doğu Anadolu',
            '[{"ad": "KONSERVE TURŞU", "miktar_gram": 250.0}, {"ad": "KUZU ETİ (KOL)", "miktar_gram": 187.5}, {"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 37.5}, {"ad": "TEREYAĞI", "miktar_gram": 15.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 5.0}, {"ad": "SU", "miktar_gram": 250.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Muş Çorti Aşı', null, '**Isıl İşlem**
1. Kızartma (~8 dk): Parçalanmış kemikli kuzu etini tereyağında rengi değişene kadar kızartın; salçayı ekleyip 1-2 dakika soteleyin.
2. Pişirme (~1 saat): Çorti turşusu ve yarma buğdayı tencereye koyun; üzerini kaplayacak kadar su ekleyip orta ateşte, et kemikten kolayca ayrılana kadar pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~55 dk · Toplam ~73 dk

**Kaynak:** Muş Çorti Aşı (Yemeği), Türk Patent Coğrafi İşaret Tescil No 409 (yaklaşık 4 kişilik).',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "TEREYAĞI", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KONSERVE TURŞU", "BUĞDAY (TAM TANE)", "SU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    raise notice 'Degisen tarif sayisi: %', v_degisen;
end $$;

drop function _kopya_kullanimda_mi(uuid, text);

commit;

-- 4) DOGRULAMA (tek sonuc tablosu): her satir icin durum. Ozet satiri en ustte.
with beklenen(eski_ad, yeni_ad, beklenen_malzeme, beklenen_asama) as (values
    ('Giresun Usulü Etli Kavurma', 'Alucra Oğlak Kebabı', 2, 3),
    ('Giresun Usulü Kavurmalı Yumurta', 'Giresun Fındık Ezmeli Kadayıf Tatlısı', 5, 5),
    ('Rize Usulü Kavurmalı Yumurta', 'Çayeli Kuru Fasulye Yemeği', 7, 7),
    ('Rize Usulü Zeytinyağlı Nohutlu Kabak', 'Derepazarı Pidesi', 12, 4),
    ('Rize Usulü Zeytinyağlı Pırasa', 'Rize Pepeçurası', 6, 4),
    ('Samsun Usulü Etli Kavurma', 'Yakakent Mantısı', 10, 5),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç', 'Çarşamba Pidesi', 8, 4),
    ('Samsun Usulü Zeytinyağlı Bakla', 'Çarşamba Keşkeği', 6, 3),
    ('Samsun Usulü Elmalı Tatlı', 'Çarşamba Kıvratması', 11, 3),
    ('Siirt Usulü Etli Kavurma', 'Siirt Kiteli', 10, 6),
    ('Siirt Usulü Zeytinyağlı Nohutlu Kereviz', 'Siirt Pırtike Çorbası', 10, 5),
    ('Siirt Usulü Zeytinyağlı Nohutlu Patlıcan', 'Siirt Gebole Tatlısı', 8, 3),
    ('Siirt Usulü Zeytinyağlı Nohutlu Bamya', 'Siirt Varak Keek Tatlısı', 6, 4),
    ('Söke Usulü Zeytinyağlı Nohutlu Havuç', 'Söke Kulak Çorbası', 15, 6),
    ('Söke Usulü Zeytinyağlı Pırasa', 'Söke Pidesi', 10, 5),
    ('Trabzon Usulü Zeytinyağlı Nohutlu Havuç', 'Sürmene Pidesi', 6, 3),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'Hamsiköy Sütlacı', 4, 3),
    ('Uşak Usulü Etli Bulgur Pilavı', 'Karahallı Ciğeri', 9, 3),
    ('Aksaray Usulü Kavurmalı Yumurta', 'Aksaray İnceelek Tatlısı', 12, 5),
    ('Kars Usulü Kaşarlı Kete', 'Kars Ketesi', 8, 4),
    ('Kırşehir Usulü Elmalı Ceviz Tatlısı', 'Kırşehir Ahi Helvası', 5, 3),
    ('Kütahya Usulü Elmalı Ceviz Tatlısı', 'Gediz Höşmerimi', 7, 4),
    ('Kütahya Usulü Kirazlı Yoğurt', 'Kütahya Tosunumu', 9, 4),
    ('Niğde Usulü Elmalı Cevizli Tatlı', 'Niğde Sarım Burma Tatlısı', 12, 5),
    ('Niğde Usulü Zeytinyağlı Kereviz', 'Bor Söğürmesi', 5, 3),
    ('Zonguldak Usulü Elmalı Ceviz Tatlısı', 'Devrek Cevizli Kömeci', 11, 3),
    ('Erzincan Usulü Zeytinyağlı Nohutlu Kabak', 'Erzincan Kesme Kadayıfı', 14, 5),
    ('Erzincan Usulü Zeytinyağlı Nohut', 'Erzincan Sütlacı', 8, 4),
    ('Dikili Usulü Zeytinyağlı Semizotu', 'Bergama Çığırtması', 6, 4),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut', 'İzmir Şambalisi', 9, 4),
    ('İzmir Usulü Etli Kavurma (Kimyonlu)', 'Tire Şiş Köfte', 4, 5),
    ('Ödemiş Usulü Nohutlu Tavuk Sote', 'Ödemiş Köftesi', 10, 4),
    ('Elazığ Usulü Etli Kavurma (Kimyonlu)', 'Palu Tava', 5, 2),
    ('Elazığ Usulü Zeytinyağlı Pırasa', 'Elazığ Taş Ekmeği Tatlısı', 9, 4),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'Kayseri Kurşun Aşı Çorbası', 18, 5),
    ('Kırıkkale Usulü Etli Bulgur Pilavı', 'Karaahmetli Tokmak Köfte', 10, 3),
    ('Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya', 'Kırıkkale Keskin Tava', 7, 2),
    ('Osmaniye Usulü Etli Bulgur Pilavı', 'Osmaniye Zorkun Tava', 9, 2),
    ('Batman Usulü Zeytinyağlı Bakla', 'Batman Şam Böreği', 12, 4),
    ('Muğla Usulü Zeytinyağlı Kereviz', 'Milas Ekşili Köfte', 14, 4),
    ('Fethiye Usulü Zeytinyağlı Bakla', 'Milas Çıntar Kavurması', 9, 4),
    ('Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı', 'Muğla Saraylısı', 6, 4),
    ('Tekirdağ Usulü Zeytinyağlı Bakla', 'Küçükyoncalı Keşkeği', 7, 3),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', 'Çorlu Kuzu Ciğer Sarma', 16, 5),
    ('Tekirdağ Usulü Kirazlı Komposto', 'Hayrabolu Tatlısı', 8, 4),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'Eminönü Balık Ekmek', 6, 3),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'Karaman Şebit Pilavı', 13, 5),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'Nazilli Pidesi', 8, 4),
    ('Sinop Usulü Zeytinyağlı Nohutlu Pırasa', 'Sinop Mantısı', 12, 4),
    ('Eskişehir Usulü Izgara Tavuk Kanat', 'Sivrihisar Kelem Dolması', 8, 4),
    ('Iğdır Usulü Kayısılı Komposto', 'Iğdır Omaç Aşı Çorbası', 13, 3),
    ('Malatya Usulü Kayısılı Komposto', 'Arapgir Gelin Kız Helvası', 4, 3),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'Karamürsel Simit Dolması', 8, 4),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'Adapazarı Islama Köftesi', 11, 4),
    ('Kuşadası Usulü Etli Enginar', 'Aydın Yuvarlaması', 16, 6),
    ('Şırnak Usulü Etli Kavurma (Kimyonlu)', 'Şırnak Soryaz', 4, 3),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Bakla', 'Cizre Bırınczer', 6, 3),
    ('Şırnak Usulü Zeytinyağlı Patlıcan', 'Şımşıpe', 16, 3),
    ('Şırnak Usulü Kuzu Kavurma', 'Cizre Luzine Tatlısı', 6, 4),
    ('Doğu Anadolu Usulü Karışık Turşu', 'Hakkari Lalaped Tatlısı', 10, 3),
    ('Doğu Anadolu Usulü Kayısı Kompostosu', 'Erzurum Kuru Kayısı Kaysefesi', 5, 3),
    ('Marmara Usulü Karışık Turşu', 'Uzunköprü Köftesi', 7, 2),
    ('Marmara Usulü Elmalı Komposto', 'Bilecik Pazaryeri Helvası', 3, 3),
    ('Marmara Usulü Vişne Kompostosu', 'Bilecik Ekşili Kesme Çorba', 14, 3),
    ('Adana Usulü Etli Bulgur Pilavı', 'Adana Şırdan', 7, 3),
    ('Manisa Usulü Zeytinyağlı Nohutlu Kabak', 'Alaşehir Kapaması', 11, 6),
    ('Salihli Usulü Kavurmalı Yumurta', 'Kırkağaç Pideli Paça', 7, 3),
    ('Kırklareli Usulü Izgara Levrek', 'Brakana Tatlısı', 10, 5),
    ('Çanakkale Usulü Kavurmalı Yumurta', 'Bayramiç Tahin Helvası', 3, 3),
    ('Çanakkale Usulü Zeytinyağlı Taze Fasulye', 'Biga Peynir Tatlısı', 7, 4),
    ('Balıkesir Usulü Elmalı Ceviz Tatlısı', 'Ayvalık Lor Tatlısı', 4, 5),
    ('Mersin Usulü Zeytinyağlı Nohutlu Havuç', 'Mersin Kerebici', 9, 3),
    ('Mersin Usulü Zeytinyağlı Nohutlu Kereviz', 'Tarsus Fındık Lahmacunu', 10, 4),
    ('Mersin Usulü Izgara Karides', 'Tarsus Kebabı', 9, 4),
    ('Alanya Usulü Kavurmalı Yumurta', 'Alanya Gülüklü Çorba', 14, 5),
    ('Alanya Usulü Elmalı Ceviz Tatlısı', 'Antalya Kabak Tatlısı', 5, 4),
    ('Antalya Usulü Etli Kavurma (Kimyonlu)', 'Antalya Topak Kızartması', 13, 4),
    ('Antalya Usulü Etli Kabak', 'Antalya Serpme Böreği', 8, 4),
    ('Muş Usulü Etli Nohutlu Bulgur', 'Muş Köftesi', 13, 5),
    ('Muş Usulü Zeytinyağlı Nohut', 'Muş Çorti Aşı', 6, 3)
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
