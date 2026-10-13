-- 192_kopya_donusumu_akademik_parti1.sql
-- YUZ KOPYA DUZELTME, BUYUK PARTI (parti 6: 5 donusum, akademik kaynak) - 13 Ekim 2026
-- Ayni yontem ve guvenlik kurallari (187-191). Her "X Usulü ..." kopyasi o ilin/ilcenin belgelenmis gercek
-- yemegine donusturulur (once Turk Patent CI tescil belgesi; CI yoksa miktarli akademik standart recete
-- calismasi). Miktarlar kaynaktaki toplamlarin porsiyon sayisina bolunmesiyle bulundu. Belgede olmayan sayilar (porsiyon sayisi, adet->gram, sure,
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
    from unnest(array['BUĞDAY (TAM TANE)', 'BUĞDAY UNU', 'CEVİZ (İÇ)', 'DANA KIYMA', 'DANA KOL', 'DOMATES', 'KABAK', 'KARABİBER', 'KONSERVE BİBER SALÇASI', 'KONSERVE DOMATES SALÇASI', 'KURU NANE', 'KURU SOĞAN', 'KURUTULMUŞ ERIK', 'KİMYON', 'LİMON SUYU', 'NOHUT', 'PANCAR', 'PATATES', 'SU', 'SÜT (TAM YAĞ)', 'TARÇIN', 'TATLIKA KIRMIZI BİBER', 'TEREYAĞI', 'TOZ ŞEKER', 'TUZ', 'ÜzÜM PEKMEZİ', 'İNCE BULGUR']::text[]) as a
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

    -- Mersin Usulü Etli Bamya -> Mersin Topalak Çorbası (Öktem SR1)
    select id into v_id from receteler where isletme_id is null and ad = 'Mersin Usulü Etli Bamya';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Mersin Usulü Etli Bamya';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mersin Topalak Çorbası') then
        raise notice 'Yeni ad zaten var, atlandi: Mersin Topalak Çorbası';
    elsif _kopya_kullanimda_mi(v_id, 'Mersin Usulü Etli Bamya') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Mersin Usulü Etli Bamya';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mersin Topalak Çorbası', v_grup2_id, 1, 130,
            '["corba", "kirmizi_et"]'::jsonb, 'kis', 'Akdeniz',
            '[{"ad": "DANA KIYMA", "miktar_gram": 62.5}, {"ad": "TEREYAĞI", "miktar_gram": 18.75}, {"ad": "İNCE BULGUR", "miktar_gram": 125.0}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 2.5}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 2.5}, {"ad": "DOMATES", "miktar_gram": 62.5}, {"ad": "DANA KOL", "miktar_gram": 62.5}, {"ad": "NOHUT", "miktar_gram": 25.0}, {"ad": "BUĞDAY UNU", "miktar_gram": 25.0}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.25}, {"ad": "KARABİBER", "miktar_gram": 1.25}, {"ad": "KURU NANE", "miktar_gram": 1.25}, {"ad": "KİMYON", "miktar_gram": 1.25}, {"ad": "LİMON SUYU", "miktar_gram": 7.5}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "SU", "miktar_gram": 250.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mersin Topalak Çorbası', null, '**Hazırlık / Mise en Place**
1. Kemikli eti ve nohudu önceden haşlayın; eti kemiğinden ayırıp didikleyin, et suyunu saklayın.
2. İnce bulgura domates ve biber salçası, kuru nane, karabiber, kimyon, kırmızı toz biber ve tuzu katıp yoğurun (yumuşaması için eli ara ara suya batırın). Yağsız kıyma ve unu ekleyip yoğurmaya devam edin.
3. Karışımdan nohut büyüklüğünde parçalar koparıp avuçta yuvarlayın; unlu tepsiye birbirine değmeden dizip tepsiyi silkeleyin.

**Isıl İşlem**
1. Kavurma (~5 dk): Tencerede tereyağını hafifçe kızdırın; salçaları 1 dakika kavurun, rendelenmiş domatesi ekleyin (mevsim dışında domatessiz).
2. Çorba (~25 dk): ~3 dakika sonra et suyu, didiklenmiş et ve nohudu ekleyip kaynatın. Topları atıp orta ateşte ~20 dakika pişirin; ocağı kapatmadan kuru naneyi serpip karıştırın.

**Servis:** Limon suyu ilave ederek servis edin.

**PARALEL YAPILABİLİRLİK:** Et ve nohut haşlanırken topalaklar yuvarlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~55 dk · Pasif bekleme ~75 dk · Toplam ~130 dk

**Kaynak:** Öktem, Ş. "Turizm Sektöründe Standart Reçetelerin Önemi Kapsamında Bir Çalışma: Mersin Yöresel Yemekleri", Mersin Üniversitesi (Başkent Üniversitesi açık erişim arşivi), Standart Reçete No 1, 4 porsiyon.',
            '[{"sira": 1, "ad": "Et ve Nohut Haşlama", "sure_dakika": 60, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KOL", "NOHUT", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Topalak Hazırlığı", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 3, "ad": "Kavurma", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KONSERVE BİBER SALÇASI", "KONSERVE DOMATES SALÇASI", "DOMATES"], "yeni_su_gram": null}, {"sira": 4, "ad": "Çorba Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "İNCE BULGUR", "BUĞDAY UNU", "TATLIKA KIRMIZI BİBER", "KARABİBER", "KURU NANE", "KİMYON", "TUZ", "LİMON SUYU"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Silifke Usulü Zeytinyağlı Kereviz -> Mersin Sarı Kabak Yemeği (Öktem SR11)
    select id into v_id from receteler where isletme_id is null and ad = 'Silifke Usulü Zeytinyağlı Kereviz';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Silifke Usulü Zeytinyağlı Kereviz';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mersin Sarı Kabak Yemeği') then
        raise notice 'Yeni ad zaten var, atlandi: Mersin Sarı Kabak Yemeği';
    elsif _kopya_kullanimda_mi(v_id, 'Silifke Usulü Zeytinyağlı Kereviz') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Silifke Usulü Zeytinyağlı Kereviz';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mersin Sarı Kabak Yemeği', v_grup2_id, 1, 72,
            '["vejetaryen", "kuru_baklagil"]'::jsonb, 'sonbahar', 'Akdeniz',
            '[{"ad": "KABAK", "miktar_gram": 250.0}, {"ad": "NOHUT", "miktar_gram": 37.5}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "TEREYAĞI", "miktar_gram": 18.75}, {"ad": "TATLIKA KIRMIZI BİBER", "miktar_gram": 1.25}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 5.0}, {"ad": "TUZ", "miktar_gram": 1.25}, {"ad": "SU", "miktar_gram": 62.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mersin Sarı Kabak Yemeği', null, '**Hazırlık / Mise en Place**
1. Nohudu önceden ıslatın. Bal kabağını soyup küp küp doğrayın.

**Isıl İşlem**
1. Pişirme (~45 dk): Islatılmış nohudu tencereye koyun; üzerine kabak ve suyu ekleyip kabak eriyinceye kadar pişirin; kabakları kaşıkla ezin.
2. Soğan (~10 dk): Ayrı bir tavada 2 baş soğanı tereyağında sararıncaya kadar kavurun; kırmızı biber ve tuzu ekleyin.
3. Birleştirme: Kavrulan soğanı kabağa katın; bir tatlı kaşığı pekmez (veya toz şeker) ekleyin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~32 dk · Pasif bekleme ~40 dk · Toplam ~72 dk (nohut ıslatma hariç)

**Kaynak:** Öktem, Ş. "Turizm Sektöründe Standart Reçetelerin Önemi Kapsamında Bir Çalışma: Mersin Yöresel Yemekleri", Mersin Üniversitesi (Başkent Üniversitesi açık erişim arşivi), Standart Reçete No 11, 4 porsiyon.',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "NOHUT", "SU"], "yeni_su_gram": null}, {"sira": 3, "ad": "Soğan Kavurma ve Birleştirme", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "TEREYAĞI", "TATLIKA KIRMIZI BİBER", "TUZ", "ÜzÜM PEKMEZİ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Silifke Usulü Izgara Levrek -> Mersin Döğme Pilavı (Öktem SR16)
    select id into v_id from receteler where isletme_id is null and ad = 'Silifke Usulü Izgara Levrek';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Silifke Usulü Izgara Levrek';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mersin Döğme Pilavı') then
        raise notice 'Yeni ad zaten var, atlandi: Mersin Döğme Pilavı';
    elsif _kopya_kullanimda_mi(v_id, 'Silifke Usulü Izgara Levrek') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Silifke Usulü Izgara Levrek';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mersin Döğme Pilavı', v_grup2_id, 1, 50,
            '["pilav", "vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
            '[{"ad": "BUĞDAY (TAM TANE)", "miktar_gram": 100.0}, {"ad": "TEREYAĞI", "miktar_gram": 25.0}, {"ad": "KARABİBER", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 2.5}, {"ad": "SU", "miktar_gram": 375.0}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mersin Döğme Pilavı', null, '**Hazırlık / Mise en Place**
1. Döğme buğdayını akşamdan ıslatıp bekletin.

**Isıl İşlem**
1. Haşlama (~45 dk): Ertesi gün ıslatıldığı suyla haşlayın; tencerenin yanmamasına dikkat ederek suyunu çektirin.
2. Tereyağı: Tavada tereyağını yakıp pilavın üzerine dökün; karabiber ve tuz serpip karıştırın.

**Servis:** Yanında mutlaka yahni pişirilir; döğme pilavının üzerine yahniden dökülerek yenir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~40 dk · Toplam ~50 dk (bir gece ıslatma hariç)

**Kaynak:** Öktem, Ş. "Turizm Sektöründe Standart Reçetelerin Önemi Kapsamında Bir Çalışma: Mersin Yöresel Yemekleri", Mersin Üniversitesi (Başkent Üniversitesi açık erişim arşivi), Standart Reçete No 16, 4 porsiyon.',
            '[{"sira": 1, "ad": "Haşlama", "sure_dakika": 45, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BUĞDAY (TAM TANE)", "SU"], "yeni_su_gram": null}, {"sira": 2, "ad": "Tereyağı ve Servis", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 120, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "KARABİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Silifke Usulü Elmalı Komposto -> Mersin Sütlü Tatlı Kabağı (Öktem SR25)
    select id into v_id from receteler where isletme_id is null and ad = 'Silifke Usulü Elmalı Komposto';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Silifke Usulü Elmalı Komposto';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mersin Sütlü Tatlı Kabağı') then
        raise notice 'Yeni ad zaten var, atlandi: Mersin Sütlü Tatlı Kabağı';
    elsif _kopya_kullanimda_mi(v_id, 'Silifke Usulü Elmalı Komposto') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Silifke Usulü Elmalı Komposto';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mersin Sütlü Tatlı Kabağı', v_grup3_id, 1, 115,
            '["tatli", "vejetaryen"]'::jsonb, 'sonbahar', 'Akdeniz',
            '[{"ad": "KABAK", "miktar_gram": 250.0}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 386.0}, {"ad": "TOZ ŞEKER", "miktar_gram": 50.0}, {"ad": "TARÇIN", "miktar_gram": 5.0}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 37.5}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mersin Sütlü Tatlı Kabağı', null, '**Hazırlık / Mise en Place**
1. Tatlı kabağını yıkayıp soyun ve dilimleyin.

**Isıl İşlem**
1. Pişirme (~40 dk): Tencereye kabağın üzerini örtecek kadar süt ekleyip kaynatın; kabak eriyinceye kadar pişirin.
2. Şeker (~5 dk): Şekeri ekleyip bir taşım kaynatın.

**Servis:** Kâselere koyup üzerine dövülmüş ceviz ve tarçın serpin; soğuyunca servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~21 dk · Pasif bekleme ~94 dk · Toplam ~115 dk

**Kaynak:** Öktem, Ş. "Turizm Sektöründe Standart Reçetelerin Önemi Kapsamında Bir Çalışma: Mersin Yöresel Yemekleri", Mersin Üniversitesi (Başkent Üniversitesi açık erişim arşivi), Standart Reçete No 25, 4 porsiyon.',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sütte Pişirme", "sure_dakika": 40, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "SÜT (TAM YAĞ)"], "yeni_su_gram": null}, {"sira": 3, "ad": "Şeker", "sure_dakika": 5, "aktif_dakika": 3, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TOZ ŞEKER"], "yeni_su_gram": null}, {"sira": 4, "ad": "Kâseleme ve Soğutma", "sure_dakika": 60, "aktif_dakika": 3, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": ["TARÇIN", "CEVİZ (İÇ)"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    -- Silifke Usulü Yoğurtlu Köfte -> Mersin Bastısı (Öktem SR10)
    select id into v_id from receteler where isletme_id is null and ad = 'Silifke Usulü Yoğurtlu Köfte';
    if v_id is null then
        raise notice 'Kopya bulunamadi, atlandi: Silifke Usulü Yoğurtlu Köfte';
    elsif exists (select 1 from receteler where isletme_id is null and ad = 'Mersin Bastısı') then
        raise notice 'Yeni ad zaten var, atlandi: Mersin Bastısı';
    elsif _kopya_kullanimda_mi(v_id, 'Silifke Usulü Yoğurtlu Köfte') then
        raise notice 'Kopya bir menude kullaniliyor, DOKUNULMADI: Silifke Usulü Yoğurtlu Köfte';
    else
        delete from receteler where id = v_id;
        perform _yeni_tarif_ekle(
            'Mersin Bastısı', v_grup2_id, 1, 50,
            '["vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
            '[{"ad": "PANCAR", "miktar_gram": 75.0}, {"ad": "KURUTULMUŞ ERIK", "miktar_gram": 25.0}, {"ad": "NOHUT", "miktar_gram": 10.0}, {"ad": "PATATES", "miktar_gram": 106.5}, {"ad": "KURU SOĞAN", "miktar_gram": 55.0}, {"ad": "KONSERVE DOMATES SALÇASI", "miktar_gram": 12.5}, {"ad": "TEREYAĞI", "miktar_gram": 18.75}, {"ad": "SU", "miktar_gram": 62.5}, {"ad": "TUZ", "miktar_gram": 1.25}]'::jsonb
        );
        perform _talimat_ve_asama_ekle_v2(
            'Mersin Bastısı', null, '**Hazırlık / Mise en Place**
1. Kuru eriği önceden ıslatıp bekletin. Nohudu haşlayın.
2. Soğanı iri doğrayın; pancarı "yalman yalman" (ince yassı) doğrayın; patatesi doğrayın.

**Isıl İşlem**
1. Kavurma (~10 dk): Soğanı yağda hafifçe kavurun; pancar ve dövülmüş domates kurusunu ekleyip birlikte kavurun.
2. Pişirme (~25 dk): Haşlanmış nohut ve patatesi ekleyin; kıvamına göre kaynamış su koyun. Pişmeye yakın eriği ekleyip 10 dakika daha pişirin.

**Servis:** Sıcak servis edin.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~20 dk · Toplam ~50 dk (erik ıslatma ve nohut haşlama hariç)

**Kaynak:** Öktem, Ş. "Turizm Sektöründe Standart Reçetelerin Önemi Kapsamında Bir Çalışma: Mersin Yöresel Yemekleri", Mersin Üniversitesi (Başkent Üniversitesi açık erişim arşivi), Standart Reçete No 10, 4 porsiyon.',
            '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU SOĞAN", "TEREYAĞI", "PANCAR", "KONSERVE DOMATES SALÇASI"], "yeni_su_gram": null}, {"sira": 3, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "PATATES", "SU", "KURUTULMUŞ ERIK", "TUZ"], "yeni_su_gram": null}]'::jsonb
        );
        v_degisen := v_degisen + 1;
    end if;

    raise notice 'Degisen tarif sayisi: %', v_degisen;
end $$;

drop function _kopya_kullanimda_mi(uuid, text);

commit;

-- 4) DOGRULAMA (tek sonuc tablosu): her satir icin durum. Ozet satiri en ustte.
with beklenen(eski_ad, yeni_ad, beklenen_malzeme, beklenen_asama) as (values
    ('Mersin Usulü Etli Bamya', 'Mersin Topalak Çorbası', 16, 4),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'Mersin Sarı Kabak Yemeği', 8, 3),
    ('Silifke Usulü Izgara Levrek', 'Mersin Döğme Pilavı', 5, 2),
    ('Silifke Usulü Elmalı Komposto', 'Mersin Sütlü Tatlı Kabağı', 5, 4),
    ('Silifke Usulü Yoğurtlu Köfte', 'Mersin Bastısı', 9, 3)
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
       (b.beklenen_malzeme is null or r.hazirlik_talimati like '%**Kaynak:**%') as kaynak_yazili
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
