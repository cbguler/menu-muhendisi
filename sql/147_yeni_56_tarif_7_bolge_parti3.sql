-- 147_yeni_56_tarif_7_bolge_parti3.sql
-- 1000 tarif hedefi, Parti 3: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (8 tarif). Ayni _yeni_tarif_ekle fonksiyonunu
-- kullanir (145/146'da tanimlandi, burada create or replace ile
-- tekrar tanimlanir -- zaten varsa zararsizca gunceller).
-- Malzeme miktarlari 1 porsiyon (kisi basi) bazinda. hazirlik_
-- talimati ve recete_asamalari BU DOSYADA YOK -- ayri sonraki asama.
-- Idempotent: isme gore 'yoksa ekle', tekrar calistirmak zarar vermez.

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
        'Balıkesir Usulü Keşkek', v_grup1_id, 1, 90,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Usulü Midye Pilavı', v_grup2_id, 1, 35,
        '["pilav"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "MİDYE", "miktar_gram": 80}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırklareli Usulü Zeytinyağlı Barbunya', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "BARBUNYA", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Edirne Usulü Tavuklu Erişte', v_grup2_id, 1, 30,
        '["pilav_makarna_borek"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "MAKARNA", "miktar_gram": 60}, {"ad": "TAVUK GÖĞÜS", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tekirdağ Usulü Zeytinyağlı Karnabahar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KARNABAHAR", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kocaeli Usulü Pilav Üstü Tavuk', v_grup2_id, 1, 35,
        '["pilav"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "TAVUK BUT", "miktar_gram": 60}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Cevizli Ayva Tatlısı', v_grup3_id, 1, 35,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "AYVA", "miktar_gram": 70}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "SU", "miktar_gram": 50}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Zeytinli Domates Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "DOMATES", "miktar_gram": 50}, {"ad": "YEŞİL ZEYTİN", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'Söke Usulü Pirinç Pilavı', v_grup2_id, 1, 25,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 60}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TAVUK SUYU", "miktar_gram": 90}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bodrum Usulü Karidesli Salata', v_grup3_id, 1, 20,
        '["salata"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KARİDES", "miktar_gram": 50}, {"ad": "MARUL", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Milas Usulü Hellim Izgara', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "HELLİM PEYNİRİ", "miktar_gram": 50}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 1.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kuşadası Usulü Izgara Çipura', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "ÇİPURA", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KEKİK", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Alaçatı Usulü Pazı Kavurması (Zeytinyağlı)', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "PAZI", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çeşme Usulü Karpuzlu Peynir Tabağı', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KARPUZ", "miktar_gram": 60}, {"ad": "OTLU PEYNİR", "miktar_gram": 20}, {"ad": "TAZE NANE", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bergama Usulü Peynirli Domates Dolması (Etsiz)', v_grup2_id, 1, 25,
        '["dolma","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "DOMATES", "miktar_gram": 70}, {"ad": "LOR PEYNİRİ", "miktar_gram": 30}, {"ad": "MAYDANOZ", "miktar_gram": 2}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İzmir Usulü Portakallı Zeytinyağlı Pancar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "PANCAR", "miktar_gram": 60}, {"ad": "PORTAKAL", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Silifke Usulü Yoğurtlu Köfte', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 80}, {"ad": "YOĞURT (TAM)", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Anamur Usulü Portakallı Muz Tatlısı', v_grup3_id, 1, 15,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "MUZ", "miktar_gram": 50}, {"ad": "PORTAKAL", "miktar_gram": 30}, {"ad": "BAL", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kaş Usulü Izgara Karides', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Alanya Usulü Karides Pilavı', v_grup2_id, 1, 30,
        '["pilav"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KARİDES", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Usulü Zeytinyağlı Enginar Kalpli Pilav', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "ENGİNAR KALBİ", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Tirit', v_grup1_id, 1, 50,
        '["kirmizi_et"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "EKMEK (BEYAZ)", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Kaytaz Böreği', v_grup2_id, 1, 45,
        '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "YUFKA", "miktar_gram": 40}, {"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 6}, {"ad": "MISIR YAĞI", "miktar_gram": 30}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Zeytinyağlı Nohutlu Ispanak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "ISPANAK", "miktar_gram": 60}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Yozgat Usulü Çullama', v_grup1_id, 1, 40,
        '["beyaz_et"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 80}, {"ad": "YUFKA", "miktar_gram": 30}, {"ad": "YOĞURT (TAM)", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırıkkale Usulü Yoğurtlu Erişte', v_grup2_id, 1, 25,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "MAKARNA", "miktar_gram": 60}, {"ad": "YOĞURT (TAM)", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çankırı Usulü Kuru Fasulye Yahnisi', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karaman Usulü Etli Bamya', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "BAMYA", "miktar_gram": 50}, {"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nevşehir Usulü Üzümlü Bulgur Pilavı', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "KURU ÜZÜM", "miktar_gram": 10}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Cevizli Sucuk (Pekmezli)', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 50}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 30}, {"ad": "EKMEKLİK UN", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Kürtün Aşı', v_grup2_id, 1, 30,
        '["corba","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 30}, {"ad": "MAKARNA", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Ballı Kadayıf', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "EKMEK KADAYIFI", "miktar_gram": 50}, {"ad": "KAYMAK", "miktar_gram": 30}, {"ad": "BAL", "miktar_gram": 20}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Bolu Usulü Kestaneli Tavuk', v_grup1_id, 1, 40,
        '["beyaz_et"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "TAVUK BUT", "miktar_gram": 90}, {"ad": "KESTANE", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Zonguldak Usulü Pancar Turşusu', v_grup3_id, 1, 25,
        '["tursu","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "PANCAR", "miktar_gram": 60}, {"ad": "SİRKE", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 4}, {"ad": "SARIMSAK", "miktar_gram": 1.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sinop Usulü Balık Buğulama', v_grup1_id, 1, 30,
        '["balik"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "İSTAVRİT", "miktar_gram": 100}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "MAYDANOZ", "miktar_gram": 2}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Amasya Usulü Elma Tatlısı', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "ELMA", "miktar_gram": 80}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "TARÇIN", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tokat Usulü Kebabı (Patatesli, Fırında)', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 70}, {"ad": "PATATES", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Artvin Usulü Fasulye Pilaki', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "BARBUNYA", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Fındıklı Tatlı', v_grup3_id, 1, 20,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "FINDIK (İÇ)", "miktar_gram": 40}, {"ad": "ŞEKER", "miktar_gram": 20}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 30}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karadeniz Usulü Taze Fasulye Yemeği (Etli)', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "TAZE FASULYE", "miktar_gram": 60}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Su Böreği', v_grup2_id, 1, 45,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "YUFKA", "miktar_gram": 50}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 30}, {"ad": "TEREYAĞI", "miktar_gram": 8}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Erzincan Usulü Çökelekli Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "LOR PEYNİRİ", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Otlu Peynirli Salata', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'ilkbahar', 'Doğu Anadolu',
        '[{"ad": "OTLU PEYNİR", "miktar_gram": 30}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "ROKA", "miktar_gram": 15}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muş Usulü Zeytinyağlı Semizotu', v_grup2_id, 1, 25,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "SEMİZOTU", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Kaz Eti Pilavı', v_grup2_id, 1, 40,
        '["pilav"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Kaşarlı Pilav', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bitlis Usulü Nohutlu Etli Çorba', v_grup2_id, 1, 35,
        '["corba"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 25}, {"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Iğdır Usulü Kayısılı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KAYISI", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Beyran Çorbası', v_grup2_id, 1, 45,
        '["corba"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 10}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Nohutlu Kuzu Güveç', v_grup1_id, 1, 50,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Kaburga Pilavı', v_grup2_id, 1, 45,
        '["pilav"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "SIĞIR KABURGA", "miktar_gram": 70}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Zeytinyağlı Nohutlu Bulgur', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 40}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Kaburga Kavurma', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "SIĞIR KABURGA", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Nohutlu Pilav', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Etli Nohutlu Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 30}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Nar Ekşili Mercimek Çorbası', v_grup2_id, 1, 30,
        '["corba"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "KIRMIZI MERCİMEK", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

end $$;

-- Dogrulama: her tarifin ADI + malzeme sayisi karsilastirmasi --
-- 'ONCEDEN VARDI (atlandi)' gorunenler onceki kutuphanede ayni
-- isimle zaten mevcuttu, bizimki eklenmedi (zarasiz).
with beklenen(ad, beklenen_sayi) as (
  values
    ('Balıkesir Usulü Keşkek', 6),
    ('Çanakkale Usulü Midye Pilavı', 6),
    ('Kırklareli Usulü Zeytinyağlı Barbunya', 6),
    ('Edirne Usulü Tavuklu Erişte', 5),
    ('Tekirdağ Usulü Zeytinyağlı Karnabahar', 5),
    ('Kocaeli Usulü Pilav Üstü Tavuk', 6),
    ('Marmara Usulü Cevizli Ayva Tatlısı', 4),
    ('Marmara Usulü Zeytinli Domates Salatası', 5),
    ('Söke Usulü Pirinç Pilavı', 4),
    ('Bodrum Usulü Karidesli Salata', 5),
    ('Milas Usulü Hellim Izgara', 3),
    ('Kuşadası Usulü Izgara Çipura', 5),
    ('Alaçatı Usulü Pazı Kavurması (Zeytinyağlı)', 5),
    ('Çeşme Usulü Karpuzlu Peynir Tabağı', 3),
    ('Bergama Usulü Peynirli Domates Dolması (Etsiz)', 5),
    ('İzmir Usulü Portakallı Zeytinyağlı Pancar', 5),
    ('Silifke Usulü Yoğurtlu Köfte', 6),
    ('Anamur Usulü Portakallı Muz Tatlısı', 3),
    ('Kaş Usulü Izgara Karides', 5),
    ('Alanya Usulü Karides Pilavı', 5),
    ('Antalya Usulü Zeytinyağlı Enginar Kalpli Pilav', 5),
    ('Mersin Usulü Tirit', 5),
    ('Hatay Usulü Kaytaz Böreği', 5),
    ('Adana Usulü Zeytinyağlı Nohutlu Ispanak', 5),
    ('Yozgat Usulü Çullama', 5),
    ('Kırıkkale Usulü Yoğurtlu Erişte', 6),
    ('Çankırı Usulü Kuru Fasulye Yahnisi', 6),
    ('Karaman Usulü Etli Bamya', 6),
    ('Nevşehir Usulü Üzümlü Bulgur Pilavı', 6),
    ('Kayseri Usulü Cevizli Sucuk (Pekmezli)', 3),
    ('Sivas Usulü Kürtün Aşı', 5),
    ('Konya Usulü Ballı Kadayıf', 3),
    ('Bolu Usulü Kestaneli Tavuk', 6),
    ('Zonguldak Usulü Pancar Turşusu', 4),
    ('Sinop Usulü Balık Buğulama', 5),
    ('Amasya Usulü Elma Tatlısı', 3),
    ('Tokat Usulü Kebabı (Patatesli, Fırında)', 6),
    ('Artvin Usulü Fasulye Pilaki', 6),
    ('Ordu Usulü Fındıklı Tatlı', 3),
    ('Karadeniz Usulü Taze Fasulye Yemeği (Etli)', 6),
    ('Erzurum Usulü Su Böreği', 5),
    ('Erzincan Usulü Çökelekli Yumurta', 4),
    ('Van Usulü Otlu Peynirli Salata', 4),
    ('Muş Usulü Zeytinyağlı Semizotu', 5),
    ('Ağrı Usulü Kaz Eti Pilavı', 4),
    ('Kars Usulü Kaşarlı Pilav', 5),
    ('Bitlis Usulü Nohutlu Etli Çorba', 6),
    ('Iğdır Usulü Kayısılı Komposto', 3),
    ('Gaziantep Usulü Beyran Çorbası', 5),
    ('Şanlıurfa Usulü Nohutlu Kuzu Güveç', 6),
    ('Diyarbakır Usulü Kaburga Pilavı', 5),
    ('Mardin Usulü Zeytinyağlı Nohutlu Bulgur', 5),
    ('Siirt Usulü Kaburga Kavurma', 4),
    ('Batman Usulü Nohutlu Pilav', 5),
    ('Şırnak Usulü Etli Nohutlu Bulgur Pilavı', 6),
    ('Kilis Usulü Nar Ekşili Mercimek Çorbası', 5)
)
select b.ad, b.beklenen_sayi, count(rm.id) as db_sayisi,
       case when count(rm.id) = b.beklenen_sayi then 'YENI EKLENDI' else 'ONCEDEN VARDI (atlandi)' end as durum
from beklenen b
join receteler r on r.ad = b.ad and r.isletme_id is null
left join recete_malzemeleri rm on rm.recete_id = r.id
group by b.ad, b.beklenen_sayi
order by durum desc, b.ad;
