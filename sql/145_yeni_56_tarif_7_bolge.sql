-- 145_yeni_56_tarif_7_bolge.sql
-- 1000 tarif hedefi, ilk parti: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (Marmara, Ege, Akdeniz, İç Anadolu, Karadeniz, Doğu
-- Anadolu, Güneydoğu Anadolu -- 8 tarif). Python script yerine
-- SQL migration olarak hazirlandi (Bahri script calistirmayi zor
-- buldu, kimlik bilgisi paylasmadan Supabase SQL editorunde
-- calistirilabilsin diye). Malzeme miktarlari 1 porsiyon (kisi
-- basi) bazinda -- kutuphanenin geneliyle tutarli.
-- hazirlik_talimati ve recete_asamalari BU DOSYADA YOK -- ayri
-- bir sonraki asama.
-- NOT: ozel_etiketler sutunu text[] (Bahri'nin ilk denemesinde
-- dogrulandi, JSONB DEGIL) -- fonksiyon icinde jsonb->text[] donusumu yapiliyor.
-- Idempotent: her tarif isme gore 'yoksa ekle' mantigiyla eklenir,
-- tekrar calistirmak zarar vermez (mevcutsa sessizce atlanir).
-- Tek transaction: bir HATA (ör. malzeme bulunamadi) olursa TUMU
-- geri alinir.

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

do $$
declare
    v_mutfak_id uuid;
    v_grup1_id uuid;
    v_grup2_id uuid;
    v_grup3_id uuid;
    v_once int;
begin
    select id into v_mutfak_id from mutfaklar where kod = 'turk';
    select id into v_grup1_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 1;
    select id into v_grup2_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 2;
    select id into v_grup3_id from mutfak_kategorileri where mutfak_id = v_mutfak_id and sira = 3;

    select count(*) into v_once from receteler where isletme_id is null;
    raise notice 'Baslangictaki tarif sayisi: %', v_once;

    ---------------- Marmara ----------------
    perform _yeni_tarif_ekle(
        'Bursa İskender Kebabı', v_grup1_id, 1, 25,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DÖNER (ET, PİŞMİŞ, BURSA)", "miktar_gram": 120}, {"ad": "PİDE", "miktar_gram": 70}, {"ad": "TEREYAĞI", "miktar_gram": 12}, {"ad": "YOĞURT (TAM)", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 40}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İnegöl Köfte', v_grup1_id, 1, 30,
        '["izgara","kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "EKMEKLİK UN", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "KİMYON", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bursa Kestaneli Kaz Dolması', v_grup1_id, 1, 45,
        '["kirmizi_et","dolma"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KAZ ETİ (BÜTÜN, DERİLİ)", "miktar_gram": 180}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30}, {"ad": "KESTANE", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "YENİBAHAR", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Karnıyarık', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "PATLICAN", "miktar_gram": 120}, {"ad": "DANA KIYMA", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 40}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bandırma Mantısı', v_grup1_id, 1, 50,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 70}, {"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "YOĞURT (TAM)", "miktar_gram": 60}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "TEREYAĞI", "miktar_gram": 8}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1.2}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Midye Tava', v_grup1_id, 1, 30,
        '["balik"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "MİDYE", "miktar_gram": 120}, {"ad": "EKMEKLİK UN", "miktar_gram": 25}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.5}, {"ad": "MISIR YAĞI", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 8}, {"ad": "LİMON SUYU", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırklareli Rokalı Beyaz Peynir Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "ROKA", "miktar_gram": 40}, {"ad": "EDİRNE BEYAZ PEYNİRİ", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "LİMON SUYU", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Kestaneli Muhallebi', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 150}, {"ad": "KESTANE", "miktar_gram": 40}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 8}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 6}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'İzmir Köfte (Fırında)', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 90}, {"ad": "PATATES", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "EKMEKLİK UN", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çeşme Usulü Ahtapot Güveç', v_grup1_id, 1, 40,
        '["balik","etli_sebze"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "AHTAPOT", "miktar_gram": 100}, {"ad": "DOMATES", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Otlu Peynirli Gözleme', v_grup2_id, 1, 25,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "YUFKA", "miktar_gram": 60}, {"ad": "OTLU PEYNİR", "miktar_gram": 40}, {"ad": "ISPANAK", "miktar_gram": 30}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Usulü Isırgan Kavurması (Etli)', v_grup1_id, 1, 30,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "ISIRGAN", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Yaylası Kuzu Tandır', v_grup1_id, 1, 100,
        '["kirmizi_et"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "KUZU TANDIR", "miktar_gram": 150}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "KEKİK", "miktar_gram": 0.5}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Portakallı Zeytinyağlı Kek', v_grup3_id, 1, 50,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 35}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 20}, {"ad": "PORTAKAL", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 30}, {"ad": "KABARTMA TOZU", "miktar_gram": 1.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Datça Bademli Yeşil Salata', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "ROKA", "miktar_gram": 30}, {"ad": "MARUL", "miktar_gram": 20}, {"ad": "BADEM", "miktar_gram": 8}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "LİMON SUYU", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege İnciri ile Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KURU İNCİR", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 10}, {"ad": "SU", "miktar_gram": 80}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Nohut Piyazı', v_grup3_id, 1, 20,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "NOHUT", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "MAYDANOZ", "miktar_gram": 3}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "LİMON SUYU", "miktar_gram": 2.5}, {"ad": "SUMAK", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Tantunisi', v_grup1_id, 1, 25,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "DANA BONFİLE", "miktar_gram": 100}, {"ad": "MISIR YAĞI", "miktar_gram": 6}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "SUMAK", "miktar_gram": 0.5}, {"ad": "LAVAŞ", "miktar_gram": 50}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Kebap', v_grup1_id, 1, 30,
        '["izgara","kirmizi_et"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 90}, {"ad": "KIRMIZI BİBER", "miktar_gram": 15}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü İçli Köfte (Etli)', v_grup1_id, 1, 60,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "DANA KIYMA", "miktar_gram": 80}, {"ad": "KURU SOĞAN", "miktar_gram": 20}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "PUL BİBER", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Şakşuka', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 30}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 40}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "YOĞURT (TAM)", "miktar_gram": 30}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Akdeniz Usulü Limonlu Zeytin Ezmesi', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "ZEYTİN EZMESİ", "miktar_gram": 40}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Nar Ekşili Salata', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'sonbahar', 'Akdeniz',
        '[{"ad": "MARUL", "miktar_gram": 30}, {"ad": "NAR", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 8}, {"ad": "NAR EKŞİSİ", "miktar_gram": 3}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Usulü Şeftali Kompostosu', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "ŞEFTALİ", "miktar_gram": 80}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Kayseri Mantısı', v_grup1_id, 1, 60,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 70}, {"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "YOĞURT (TAM)", "miktar_gram": 60}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "TEREYAĞI", "miktar_gram": 8}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1.2}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ankara Tava (Kuzu Etli)', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 120}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Etli Ekmek', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 80}, {"ad": "KUZU KIYMA", "miktar_gram": 70}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "MAYDANOZ", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "PUL BİBER", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nevşehir Testi Kebabı', v_grup1_id, 1, 90,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 100}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "YEŞİL BİBER", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "MANTAR", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Yağlaması', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "LAVAŞ", "miktar_gram": 60}, {"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kapadokya Kestaneli Komposto', v_grup3_id, 1, 30,
        '["komposto","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "KESTANE", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Nohutlu Bulgur Pilavı', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 60}, {"ad": "NOHUT", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TAVUK SUYU", "miktar_gram": 90}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Niğde Bademli Un Helvası', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 50}, {"ad": "TEREYAĞI", "miktar_gram": 30}, {"ad": "ŞEKER", "miktar_gram": 40}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 60}, {"ad": "BADEM (İÇ)", "miktar_gram": 6}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Karadeniz Mıhlaması', v_grup2_id, 1, 20,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "MISIR UNU", "miktar_gram": 40}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 50}, {"ad": "TEREYAĞI", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 60}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karadeniz Kaymaklı Pide', v_grup2_id, 1, 45,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 70}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 40}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 30}, {"ad": "TEREYAĞI", "miktar_gram": 8}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Hamsili Pilav', v_grup2_id, 1, 35,
        '["pilav"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "HAMSİ", "miktar_gram": 60}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TEREYAĞI", "miktar_gram": 8}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Karalahana Çorbası', v_grup2_id, 1, 40,
        '["corba","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KARALAHANA", "miktar_gram": 50}, {"ad": "MISIR UNU", "miktar_gram": 10}, {"ad": "KURU FASULYE", "miktar_gram": 15}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Fındıklı Kuru Fasulye', v_grup1_id, 1, 45,
        '["kuru_baklagil","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "FINDIK (İÇ)", "miktar_gram": 10}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karadeniz Mısır Ekmeği', v_grup2_id, 1, 40,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "MISIR UNU", "miktar_gram": 60}, {"ad": "EKMEKLİK UN", "miktar_gram": 20}, {"ad": "YOĞURT (TAM)", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 20}, {"ad": "KABARTMA TOZU", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Akçaabat Köfte', v_grup1_id, 1, 30,
        '["izgara","kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "GALETA UNU (PANKO)", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "KİMYON", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karadeniz Dutlu Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "DUT", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 12}, {"ad": "SU", "miktar_gram": 60}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Cağ Kebabı', v_grup1_id, 1, 40,
        '["izgara","kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KOYUN ETİ (BUT)", "miktar_gram": 150}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Erzincan Tulumlu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "TULUM PEYNİRİ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Otlu Peynirli Kahvaltı Böreği', v_grup2_id, 1, 30,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'ilkbahar', 'Doğu Anadolu',
        '[{"ad": "YUFKA", "miktar_gram": 50}, {"ad": "OTLU PEYNİR", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Kayısılı Kuzu Yahnisi', v_grup1_id, 1, 55,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 100}, {"ad": "KURU KAYISI", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Kuru Fasulye Kavurması', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Kaz Eti Kavurması', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)", "miktar_gram": 120}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 0.6}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Doğu Anadolu Pekmezli Ceviz Ezmesi', v_grup3_id, 1, 15,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 50}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 30}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 10}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Doğu Anadolu Kayısı ve Ceviz Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KAYISI", "miktar_gram": 40}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "YOĞURT (TAM)", "miktar_gram": 30}, {"ad": "ŞEKER", "miktar_gram": 3}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Alinazik Kebabı', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 80}, {"ad": "KUZU KIYMA", "miktar_gram": 60}, {"ad": "YOĞURT (TAM)", "miktar_gram": 40}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Çiğ Köfte (Etsiz)', v_grup3_id, 1, 40,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "KONSERVE BİBER SALÇASI", "miktar_gram": 15}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "NAR EKŞİSİ", "miktar_gram": 4}, {"ad": "PUL BİBER", "miktar_gram": 1}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Urfa Usulü Kuzu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 100}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "PUL BİBER", "miktar_gram": 1}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Kaburga Dolması', v_grup1_id, 1, 90,
        '["kirmizi_et","dolma"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "SIĞIR KABURGA", "miktar_gram": 150}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Meftune', v_grup1_id, 1, 50,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "PATLICAN", "miktar_gram": 40}, {"ad": "KABAK", "miktar_gram": 30}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antep Usulü Yuvalama Çorbası', v_grup2_id, 1, 45,
        '["corba"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "YOĞURT (TAM)", "miktar_gram": 60}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 15}, {"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Büryan', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 180}, {"ad": "TUZ", "miktar_gram": 1.5}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antep Fıstıklı Muhallebi', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 150}, {"ad": "ANTEP FISTIĞI", "miktar_gram": 15}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "PİRİNÇ UNU", "miktar_gram": 8}]'::jsonb
    );

end $$;

-- Dogrulama: bolge basina eklenen tarif sayisi + toplam kutuphane buyuklugu.
select bolge, count(*) as tarif_sayisi
from receteler
where isletme_id is null
  and bolge in ('Marmara','Ege','Akdeniz','İç Anadolu','Karadeniz','Doğu Anadolu','Güneydoğu Anadolu')
group by bolge
order by bolge;
