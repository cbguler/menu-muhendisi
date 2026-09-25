-- 149_yeni_56_tarif_7_bolge_parti5.sql
-- 1000 tarif hedefi, Parti 5: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (8 tarif). Ayni _yeni_tarif_ekle fonksiyonunu kullanir.
-- TUM malzemeler, senonim guvenilmeden DOGRUDAN katalogda
-- dogrulandi (148'deki ARMUT dersi geregi).
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
        'İstanbul Usulü Midye Salatası', v_grup3_id, 1, 20,
        '["salata"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "MİDYE", "miktar_gram": 70}, {"ad": "MARUL", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bursa Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırklareli Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tekirdağ Usulü Fırın Sütlaç', v_grup3_id, 1, 40,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 120}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 4}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Usulü Zeytinyağlı Taze Fasulye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "TAZE FASULYE", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Balıkesir Usulü Zeytinyağlı Enginarlı Bezelye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "BEZELYE", "miktar_gram": 40}, {"ad": "ENGİNAR", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü İncirli Kaşar Tabağı', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KURU İNCİR", "miktar_gram": 30}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 25}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Limonlu Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 90}, {"ad": "LİMON SUYU", "miktar_gram": 4}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'İzmir Usulü Zeytinyağlı Nohutlu Enginar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "ENGİNAR", "miktar_gram": 40}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı', v_grup3_id, 1, 10,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "BAL", "miktar_gram": 30}, {"ad": "KAYMAK", "miktar_gram": 30}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Datça Usulü Bademli Zeytinyağlı Salata', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "MARUL", "miktar_gram": 25}, {"ad": "BADEM", "miktar_gram": 8}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2.5}, {"ad": "LİMON SUYU", "miktar_gram": 1.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Fethiye Usulü Izgara Karides', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Salihli Usulü Üzümlü Pilav', v_grup2_id, 1, 25,
        '["pilav","vejetaryen"]'::jsonb, 'sonbahar', 'Ege',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "KURU ÜZÜM", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nazilli Usulü Etli Nohutlu Bamya', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "BAMYA", "miktar_gram": 40}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Dikili Usulü Zeytinyağlı Semizotu', v_grup2_id, 1, 25,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "SEMİZOTU", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İzmir Usulü Üzümlü Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'sonbahar', 'Ege',
        '[{"ad": "ÜZÜM", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 10}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Etli Bamya', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "BAMYA", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Nohutlu Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 70}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Zeytinyağlı Enginar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "ENGİNAR", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Silifke Usulü Zeytinyağlı Taze Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "BAKLA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TAZE DEREOTU", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Usulü Portakallı Muhallebi', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 100}, {"ad": "PORTAKAL", "miktar_gram": 20}, {"ad": "ŞEKER", "miktar_gram": 20}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kahramanmaraş Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 60}, {"ad": "BULGUR", "miktar_gram": 30}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Osmaniye Usulü Zeytinyağlı Taze Fasulye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "TAZE FASULYE", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Ankara Usulü Etli Nohutlu Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 30}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Niğde Usulü Elmalı Cevizli Tatlı', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aksaray Usulü Etli Kabak Yemeği', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırşehir Usulü Zeytinyağlı Enginar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'İç Anadolu',
        '[{"ad": "ENGİNAR", "miktar_gram": 50}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çorum Usulü Nohutlu Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "TAVUK BUT", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Zeytinyağlı Kuru Fasulye', v_grup1_id, 1, 40,
        '["kuru_baklagil","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Mısır Ekmekli Kaymak Tabağı', v_grup3_id, 1, 10,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "MISIR UNU", "miktar_gram": 15}, {"ad": "KAYMAK", "miktar_gram": 25}, {"ad": "BAL", "miktar_gram": 10}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Samsun Usulü Etli Lahana Yemeği', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "LAHANA", "miktar_gram": 60}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Fındıklı Muhallebi', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 100}, {"ad": "FINDIK (İÇ)", "miktar_gram": 15}, {"ad": "ŞEKER", "miktar_gram": 20}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Zeytinyağlı Taze Fasulye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "TAZE FASULYE", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Artvin Usulü Kaşarlı Mısır Ekmeği', v_grup2_id, 1, 35,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "MISIR UNU", "miktar_gram": 50}, {"ad": "EKMEKLİK UN", "miktar_gram": 15}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 20}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bayburt Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tokat Usulü Zeytinyağlı Nohutlu Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "PIRASA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Etli Nohutlu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Balı ile Ceviz Tabağı', v_grup3_id, 1, 10,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "BAL", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KOYUN ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Zeytinyağlı Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muş Usulü Etli Pazı Yemeği', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "PAZI", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Usulü Kayısılı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KAYISI", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 25}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bitlis Usulü Zeytinyağlı Semizotu', v_grup2_id, 1, 25,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "SEMİZOTU", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Etli Nohutlu Kabak', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 40}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Zeytinyağlı Mercimekli Bulgur', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KIRMIZI MERCİMEK", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Zeytinyağlı Biberli Patlıcan', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "YEŞİL BİBER", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Fıstıklı Pilav', v_grup2_id, 1, 25,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "ANTEP FISTIĞI", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 25}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Zeytinyağlı Nohutlu Ispanak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "ISPANAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

end $$;

-- Dogrulama: her tarifin ADI + malzeme sayisi karsilastirmasi.
with beklenen(ad, beklenen_sayi) as (
  values
    ('İstanbul Usulü Midye Salatası', 5),
    ('Bursa Usulü Zeytinyağlı Kereviz', 6),
    ('Kırklareli Usulü Kavurmalı Yumurta', 4),
    ('Tekirdağ Usulü Fırın Sütlaç', 4),
    ('Çanakkale Usulü Zeytinyağlı Taze Fasulye', 6),
    ('Balıkesir Usulü Zeytinyağlı Enginarlı Bezelye', 6),
    ('Marmara Usulü İncirli Kaşar Tabağı', 3),
    ('İstanbul Usulü Limonlu Tavuk Sote', 6),
    ('İzmir Usulü Zeytinyağlı Nohutlu Enginar', 5),
    ('Muğla Usulü Bal Kaymaklı Kahvaltı Tabağı', 2),
    ('Datça Usulü Bademli Zeytinyağlı Salata', 4),
    ('Fethiye Usulü Izgara Karides', 5),
    ('Salihli Usulü Üzümlü Pilav', 5),
    ('Nazilli Usulü Etli Nohutlu Bamya', 6),
    ('Dikili Usulü Zeytinyağlı Semizotu', 5),
    ('İzmir Usulü Üzümlü Komposto', 3),
    ('Antalya Usulü Zeytinyağlı Kereviz', 6),
    ('Mersin Usulü Etli Bamya', 6),
    ('Adana Usulü Nohutlu Kavurma', 5),
    ('Hatay Usulü Zeytinyağlı Enginar', 5),
    ('Silifke Usulü Zeytinyağlı Taze Bakla', 5),
    ('Antalya Usulü Portakallı Muhallebi', 4),
    ('Kahramanmaraş Usulü Etli Nohutlu Bulgur', 6),
    ('Osmaniye Usulü Zeytinyağlı Taze Fasulye', 6),
    ('Ankara Usulü Etli Nohutlu Bulgur Pilavı', 6),
    ('Konya Usulü Zeytinyağlı Pırasa', 6),
    ('Kayseri Usulü Kavurmalı Yumurta', 4),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kabak', 6),
    ('Niğde Usulü Elmalı Cevizli Tatlı', 3),
    ('Aksaray Usulü Etli Kabak Yemeği', 6),
    ('Kırşehir Usulü Zeytinyağlı Enginar', 5),
    ('Çorum Usulü Nohutlu Tavuk Sote', 5),
    ('Trabzon Usulü Zeytinyağlı Kuru Fasulye', 5),
    ('Rize Usulü Mısır Ekmekli Kaymak Tabağı', 3),
    ('Samsun Usulü Etli Lahana Yemeği', 5),
    ('Giresun Usulü Fındıklı Muhallebi', 4),
    ('Ordu Usulü Zeytinyağlı Taze Fasulye', 6),
    ('Artvin Usulü Kaşarlı Mısır Ekmeği', 5),
    ('Bayburt Usulü Etli Kavurma', 4),
    ('Tokat Usulü Zeytinyağlı Nohutlu Pırasa', 5),
    ('Erzurum Usulü Etli Nohutlu Kavurma', 5),
    ('Van Usulü Balı ile Ceviz Tabağı', 2),
    ('Kars Usulü Etli Kavurma', 4),
    ('Ağrı Usulü Zeytinyağlı Nohut', 5),
    ('Muş Usulü Etli Pazı Yemeği', 5),
    ('Malatya Usulü Kayısılı Komposto', 3),
    ('Elazığ Usulü Etli Nohutlu Bulgur', 6),
    ('Bitlis Usulü Zeytinyağlı Semizotu', 5),
    ('Gaziantep Usulü Etli Nohutlu Kabak', 6),
    ('Şanlıurfa Usulü Zeytinyağlı Mercimekli Bulgur', 5),
    ('Diyarbakır Usulü Etli Kavurma', 4),
    ('Mardin Usulü Zeytinyağlı Biberli Patlıcan', 6),
    ('Siirt Usulü Fıstıklı Pilav', 5),
    ('Batman Usulü Etli Nohutlu Bulgur', 6),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Ispanak', 5),
    ('Kilis Usulü Etli Kavurma', 5)
)
select b.ad, b.beklenen_sayi, count(rm.id) as db_sayisi,
       case when count(rm.id) = b.beklenen_sayi then 'YENI EKLENDI' else 'ONCEDEN VARDI (atlandi)' end as durum
from beklenen b
join receteler r on r.ad = b.ad and r.isletme_id is null
left join recete_malzemeleri rm on rm.recete_id = r.id
group by b.ad, b.beklenen_sayi
order by durum desc, b.ad;
