-- 152_yeni_63_tarif_7_bolge_parti8.sql
-- 1000 tarif hedefi, Parti 8: 63 yeni tarif,
-- 7 bolgeye esit dagitilmis. Ayni _yeni_tarif_ekle fonksiyonunu kullanir.
-- TUM malzemeler DOGRUDAN katalogda dogrulandi.
-- Malzeme miktarlari 1 porsiyon (kisi basi) bazinda. hazirlik_
-- talimati ve recete_asamalari BU DOSYADA YOK -- ayri sonraki asama.
-- Idempotent. Dogrulama UC-SAYI yontemiyle (sayim degil).

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
        'Bursa Usulü Zeytinyağlı Enginarlı Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "ENGİNAR", "miktar_gram": 30}, {"ad": "HAVUÇ", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırklareli Usulü Vişneli Tatlı', v_grup3_id, 1, 20,
        '["tatli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "VİŞNE", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tekirdağ Usulü Izgara Karides', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Usulü Zeytinyağlı Bezelye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "BEZELYE", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Balıkesir Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Elmalı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "ŞEKER", "miktar_gram": 12}, {"ad": "SU", "miktar_gram": 60}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kocaeli Usulü Etli Kabak Yemeği', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Yalova Usulü Zeytinyağlı Enginar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "ENGİNAR", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'İzmir Usulü Zeytinyağlı Enginarlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "ENGİNAR", "miktar_gram": 30}, {"ad": "BAKLA", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Manisa Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aydın Usulü Zeytinyağlı İncirli Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "HAVUÇ", "miktar_gram": 40}, {"ad": "KURU İNCİR", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muğla Usulü Izgara Çipura', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "ÇİPURA", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Denizli Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Uşak Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kütahya Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Ege',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Afyon Usulü Kaymaklı Bal Tabağı', v_grup3_id, 1, 10,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "KAYMAK", "miktar_gram": 30}, {"ad": "BAL", "miktar_gram": 30}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Söke Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Izgara Karides', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Zeytinyağlı Enginarlı Bezelye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "ENGİNAR", "miktar_gram": 30}, {"ad": "BEZELYE", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kahramanmaraş Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Isparta Usulü Gülsuyu Aromalı Muhallebi', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "SÜT (TAM YAĞ)", "miktar_gram": 100}, {"ad": "ŞEKER", "miktar_gram": 20}, {"ad": "MISIR NİŞASTASI", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Burdur Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Osmaniye Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Silifke Usulü Elmalı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'sonbahar', 'Akdeniz',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "ŞEKER", "miktar_gram": 12}, {"ad": "SU", "miktar_gram": 60}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Ankara Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Zeytinyağlı Enginar', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'İç Anadolu',
        '[{"ad": "ENGİNAR", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Izgara Tavuk Kanat', v_grup1_id, 1, 35,
        '["izgara","beyaz_et"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "TAVUK KANAT", "miktar_gram": 120}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Yozgat Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Niğde Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aksaray Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karaman Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırıkkale Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Samsun Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Zeytinyağlı Fındıklı Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "KABAK", "miktar_gram": 60}, {"ad": "FINDIK (İÇ)", "miktar_gram": 8}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Elmalı Fındıklı Tatlı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "ELMA", "miktar_gram": 50}, {"ad": "FINDIK (İÇ)", "miktar_gram": 15}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Artvin Usulü Etli Lahana', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "LAHANA", "miktar_gram": 60}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bayburt Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tokat Usulü Izgara Alabalık - basitleştirilmiş (Levrek ile)', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "LEVREK", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sinop Usulü Zeytinyağlı Nohutlu Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "PIRASA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Etli Kavurma (Baharatlı)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KOYUN ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Doğu Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muş Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Kayısılı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KAYISI", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bitlis Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Iğdır Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Etli Kavurma (Baharatlı)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Etli Kavurma (Baharatlı)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Zeytinyağlı Nohutlu Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
        '[{"ad": "BAKLA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 40}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

end $$;

-- SAGLAM Dogrulama (uc-sayi yontemi). 0 satir donmesi beklenir.
with beklenen(ad, malzeme_ad, miktar) as (
  values
    ('Bursa Usulü Zeytinyağlı Enginarlı Havuç', 'ENGİNAR', 30),
    ('Bursa Usulü Zeytinyağlı Enginarlı Havuç', 'HAVUÇ', 30),
    ('Bursa Usulü Zeytinyağlı Enginarlı Havuç', 'KURU SOĞAN', 10),
    ('Bursa Usulü Zeytinyağlı Enginarlı Havuç', 'ZEYTİNYAĞI', 3),
    ('Bursa Usulü Zeytinyağlı Enginarlı Havuç', 'TUZ', 0.8),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'DANA KIYMA', 50),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('İstanbul Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Kırklareli Usulü Vişneli Tatlı', 'VİŞNE', 50),
    ('Kırklareli Usulü Vişneli Tatlı', 'ŞEKER', 15),
    ('Kırklareli Usulü Vişneli Tatlı', 'MISIR NİŞASTASI', 3),
    ('Tekirdağ Usulü Izgara Karides', 'KARİDES', 100),
    ('Tekirdağ Usulü Izgara Karides', 'ZEYTİNYAĞI', 3),
    ('Tekirdağ Usulü Izgara Karides', 'SARIMSAK', 1.5),
    ('Tekirdağ Usulü Izgara Karides', 'LİMON SUYU', 2),
    ('Tekirdağ Usulü Izgara Karides', 'TUZ', 0.8),
    ('Çanakkale Usulü Zeytinyağlı Bezelye', 'BEZELYE', 50),
    ('Çanakkale Usulü Zeytinyağlı Bezelye', 'KURU SOĞAN', 10),
    ('Çanakkale Usulü Zeytinyağlı Bezelye', 'ZEYTİNYAĞI', 3),
    ('Çanakkale Usulü Zeytinyağlı Bezelye', 'ŞEKER', 0.5),
    ('Çanakkale Usulü Zeytinyağlı Bezelye', 'TUZ', 0.8),
    ('Balıkesir Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Balıkesir Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Balıkesir Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Balıkesir Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Marmara Usulü Elmalı Komposto', 'ELMA', 60),
    ('Marmara Usulü Elmalı Komposto', 'ŞEKER', 12),
    ('Marmara Usulü Elmalı Komposto', 'SU', 60),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'DANA KIYMA', 50),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'KABAK', 50),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'DOMATES', 20),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'KURU SOĞAN', 10),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'TUZ', 0.8),
    ('Kocaeli Usulü Etli Kabak Yemeği', 'KARABİBER', 0.3),
    ('Yalova Usulü Zeytinyağlı Enginar', 'ENGİNAR', 50),
    ('Yalova Usulü Zeytinyağlı Enginar', 'KURU SOĞAN', 10),
    ('Yalova Usulü Zeytinyağlı Enginar', 'ZEYTİNYAĞI', 3),
    ('Yalova Usulü Zeytinyağlı Enginar', 'LİMON SUYU', 1.5),
    ('Yalova Usulü Zeytinyağlı Enginar', 'TUZ', 0.8),
    ('İzmir Usulü Zeytinyağlı Enginarlı Bakla', 'ENGİNAR', 30),
    ('İzmir Usulü Zeytinyağlı Enginarlı Bakla', 'BAKLA', 30),
    ('İzmir Usulü Zeytinyağlı Enginarlı Bakla', 'KURU SOĞAN', 10),
    ('İzmir Usulü Zeytinyağlı Enginarlı Bakla', 'ZEYTİNYAĞI', 3),
    ('İzmir Usulü Zeytinyağlı Enginarlı Bakla', 'TUZ', 0.8),
    ('Manisa Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Manisa Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Manisa Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Manisa Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Aydın Usulü Zeytinyağlı İncirli Havuç', 'HAVUÇ', 40),
    ('Aydın Usulü Zeytinyağlı İncirli Havuç', 'KURU İNCİR', 15),
    ('Aydın Usulü Zeytinyağlı İncirli Havuç', 'KURU SOĞAN', 10),
    ('Aydın Usulü Zeytinyağlı İncirli Havuç', 'ZEYTİNYAĞI', 3),
    ('Aydın Usulü Zeytinyağlı İncirli Havuç', 'TUZ', 0.8),
    ('Muğla Usulü Izgara Çipura', 'ÇİPURA', 150),
    ('Muğla Usulü Izgara Çipura', 'ZEYTİNYAĞI', 3),
    ('Muğla Usulü Izgara Çipura', 'LİMON SUYU', 2),
    ('Muğla Usulü Izgara Çipura', 'TUZ', 0.8),
    ('Denizli Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Denizli Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Denizli Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Denizli Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Denizli Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Uşak Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Uşak Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Uşak Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Uşak Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Uşak Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Kütahya Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Kütahya Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Kütahya Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Afyon Usulü Kaymaklı Bal Tabağı', 'KAYMAK', 30),
    ('Afyon Usulü Kaymaklı Bal Tabağı', 'BAL', 30),
    ('Söke Usulü Zeytinyağlı Pırasa', 'PIRASA', 60),
    ('Söke Usulü Zeytinyağlı Pırasa', 'HAVUÇ', 15),
    ('Söke Usulü Zeytinyağlı Pırasa', 'KURU SOĞAN', 10),
    ('Söke Usulü Zeytinyağlı Pırasa', 'ZEYTİNYAĞI', 3),
    ('Söke Usulü Zeytinyağlı Pırasa', 'ŞEKER', 0.5),
    ('Söke Usulü Zeytinyağlı Pırasa', 'TUZ', 0.8),
    ('Antalya Usulü Etli Nohutlu Patlıcan', 'KUZU KIYMA', 50),
    ('Antalya Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Antalya Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Antalya Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Antalya Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Antalya Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Mersin Usulü Izgara Karides', 'KARİDES', 100),
    ('Mersin Usulü Izgara Karides', 'ZEYTİNYAĞI', 3),
    ('Mersin Usulü Izgara Karides', 'SARIMSAK', 1.5),
    ('Mersin Usulü Izgara Karides', 'LİMON SUYU', 2),
    ('Mersin Usulü Izgara Karides', 'TUZ', 0.8),
    ('Adana Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Adana Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Adana Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Adana Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Adana Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Hatay Usulü Zeytinyağlı Enginarlı Bezelye', 'ENGİNAR', 30),
    ('Hatay Usulü Zeytinyağlı Enginarlı Bezelye', 'BEZELYE', 30),
    ('Hatay Usulü Zeytinyağlı Enginarlı Bezelye', 'KURU SOĞAN', 10),
    ('Hatay Usulü Zeytinyağlı Enginarlı Bezelye', 'ZEYTİNYAĞI', 3),
    ('Hatay Usulü Zeytinyağlı Enginarlı Bezelye', 'ŞEKER', 0.5),
    ('Hatay Usulü Zeytinyağlı Enginarlı Bezelye', 'TUZ', 0.8),
    ('Kahramanmaraş Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Kahramanmaraş Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Kahramanmaraş Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Kahramanmaraş Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Isparta Usulü Gülsuyu Aromalı Muhallebi', 'SÜT (TAM YAĞ)', 100),
    ('Isparta Usulü Gülsuyu Aromalı Muhallebi', 'ŞEKER', 20),
    ('Isparta Usulü Gülsuyu Aromalı Muhallebi', 'MISIR NİŞASTASI', 6),
    ('Burdur Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Burdur Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Burdur Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Burdur Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Burdur Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Osmaniye Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Osmaniye Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Osmaniye Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Osmaniye Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Osmaniye Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Silifke Usulü Elmalı Komposto', 'ELMA', 60),
    ('Silifke Usulü Elmalı Komposto', 'ŞEKER', 12),
    ('Silifke Usulü Elmalı Komposto', 'SU', 60),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'DANA KIYMA', 50),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Ankara Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Konya Usulü Zeytinyağlı Enginar', 'ENGİNAR', 50),
    ('Konya Usulü Zeytinyağlı Enginar', 'KURU SOĞAN', 10),
    ('Konya Usulü Zeytinyağlı Enginar', 'ZEYTİNYAĞI', 3),
    ('Konya Usulü Zeytinyağlı Enginar', 'LİMON SUYU', 1.5),
    ('Konya Usulü Zeytinyağlı Enginar', 'TUZ', 0.8),
    ('Kayseri Usulü Izgara Tavuk Kanat', 'TAVUK KANAT', 120),
    ('Kayseri Usulü Izgara Tavuk Kanat', 'PUL BİBER', 0.8),
    ('Kayseri Usulü Izgara Tavuk Kanat', 'SARIMSAK', 1.5),
    ('Kayseri Usulü Izgara Tavuk Kanat', 'ZEYTİNYAĞI', 4),
    ('Kayseri Usulü Izgara Tavuk Kanat', 'TUZ', 0.8),
    ('Sivas Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Sivas Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Sivas Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Yozgat Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Yozgat Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Yozgat Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Yozgat Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Yozgat Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Niğde Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Niğde Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Niğde Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Niğde Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Aksaray Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Aksaray Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Aksaray Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Aksaray Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'KEREVİZ', 60),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'HAVUÇ', 15),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'KURU SOĞAN', 10),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'ZEYTİNYAĞI', 3),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'ŞEKER', 0.5),
    ('Karaman Usulü Zeytinyağlı Kereviz', 'TUZ', 0.8),
    ('Kırıkkale Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Kırıkkale Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Kırıkkale Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Kırıkkale Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Kırıkkale Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Trabzon Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Trabzon Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Trabzon Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Trabzon Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Trabzon Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Rize Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Rize Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Rize Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Rize Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Samsun Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Samsun Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Samsun Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Samsun Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Giresun Usulü Zeytinyağlı Fındıklı Kabak', 'KABAK', 60),
    ('Giresun Usulü Zeytinyağlı Fındıklı Kabak', 'FINDIK (İÇ)', 8),
    ('Giresun Usulü Zeytinyağlı Fındıklı Kabak', 'KURU SOĞAN', 10),
    ('Giresun Usulü Zeytinyağlı Fındıklı Kabak', 'ZEYTİNYAĞI', 3),
    ('Giresun Usulü Zeytinyağlı Fındıklı Kabak', 'ŞEKER', 0.5),
    ('Giresun Usulü Zeytinyağlı Fındıklı Kabak', 'TUZ', 0.8),
    ('Ordu Usulü Elmalı Fındıklı Tatlı', 'ELMA', 50),
    ('Ordu Usulü Elmalı Fındıklı Tatlı', 'FINDIK (İÇ)', 15),
    ('Ordu Usulü Elmalı Fındıklı Tatlı', 'ŞEKER', 20),
    ('Artvin Usulü Etli Lahana', 'LAHANA', 60),
    ('Artvin Usulü Etli Lahana', 'DANA KIYMA', 40),
    ('Artvin Usulü Etli Lahana', 'KURU SOĞAN', 10),
    ('Artvin Usulü Etli Lahana', 'TUZ', 0.8),
    ('Artvin Usulü Etli Lahana', 'KARABİBER', 0.3),
    ('Bayburt Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Bayburt Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Bayburt Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Bayburt Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Bayburt Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Tokat Usulü Izgara Alabalık - basitleştirilmiş (Levrek ile)', 'LEVREK', 150),
    ('Tokat Usulü Izgara Alabalık - basitleştirilmiş (Levrek ile)', 'ZEYTİNYAĞI', 3),
    ('Tokat Usulü Izgara Alabalık - basitleştirilmiş (Levrek ile)', 'LİMON SUYU', 2),
    ('Tokat Usulü Izgara Alabalık - basitleştirilmiş (Levrek ile)', 'TUZ', 0.8),
    ('Sinop Usulü Zeytinyağlı Nohutlu Pırasa', 'PIRASA', 50),
    ('Sinop Usulü Zeytinyağlı Nohutlu Pırasa', 'NOHUT', 20),
    ('Sinop Usulü Zeytinyağlı Nohutlu Pırasa', 'KURU SOĞAN', 10),
    ('Sinop Usulü Zeytinyağlı Nohutlu Pırasa', 'ZEYTİNYAĞI', 3),
    ('Sinop Usulü Zeytinyağlı Nohutlu Pırasa', 'TUZ', 0.8),
    ('Erzurum Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Erzurum Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Erzurum Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Erzurum Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Van Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Van Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Van Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Van Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Van Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Kars Usulü Etli Kavurma (Baharatlı)', 'KOYUN ETİ (KOL)', 90),
    ('Kars Usulü Etli Kavurma (Baharatlı)', 'KURU SOĞAN', 10),
    ('Kars Usulü Etli Kavurma (Baharatlı)', 'KİMYON', 0.5),
    ('Kars Usulü Etli Kavurma (Baharatlı)', 'TUZ', 0.8),
    ('Kars Usulü Etli Kavurma (Baharatlı)', 'KARABİBER', 0.3),
    ('Ağrı Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Ağrı Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Ağrı Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Muş Usulü Zeytinyağlı Kereviz', 'KEREVİZ', 60),
    ('Muş Usulü Zeytinyağlı Kereviz', 'HAVUÇ', 15),
    ('Muş Usulü Zeytinyağlı Kereviz', 'KURU SOĞAN', 10),
    ('Muş Usulü Zeytinyağlı Kereviz', 'ZEYTİNYAĞI', 3),
    ('Muş Usulü Zeytinyağlı Kereviz', 'ŞEKER', 0.5),
    ('Muş Usulü Zeytinyağlı Kereviz', 'TUZ', 0.8),
    ('Malatya Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Malatya Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Malatya Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Malatya Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Malatya Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Elazığ Usulü Kayısılı Komposto', 'KAYISI', 50),
    ('Elazığ Usulü Kayısılı Komposto', 'ŞEKER', 15),
    ('Elazığ Usulü Kayısılı Komposto', 'SU', 70),
    ('Bitlis Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Bitlis Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Bitlis Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Bitlis Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Bitlis Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Iğdır Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Iğdır Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Iğdır Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Iğdır Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Şanlıurfa Usulü Etli Bulgur Pilavı', 'KUZU KIYMA', 50),
    ('Şanlıurfa Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Şanlıurfa Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Şanlıurfa Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Şanlıurfa Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', 'PIRASA', 50),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', 'NOHUT', 20),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', 'KURU SOĞAN', 10),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', 'ZEYTİNYAĞI', 3),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Pırasa', 'TUZ', 0.8),
    ('Mardin Usulü Etli Kavurma (Baharatlı)', 'KUZU ETİ (KOL)', 90),
    ('Mardin Usulü Etli Kavurma (Baharatlı)', 'KİMYON', 0.5),
    ('Mardin Usulü Etli Kavurma (Baharatlı)', 'KURU SOĞAN', 10),
    ('Mardin Usulü Etli Kavurma (Baharatlı)', 'TUZ', 0.8),
    ('Mardin Usulü Etli Kavurma (Baharatlı)', 'KARABİBER', 0.3),
    ('Siirt Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('Siirt Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('Siirt Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('Siirt Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('Siirt Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8),
    ('Batman Usulü Etli Kavurma (Baharatlı)', 'KUZU ETİ (KOL)', 90),
    ('Batman Usulü Etli Kavurma (Baharatlı)', 'PUL BİBER', 0.5),
    ('Batman Usulü Etli Kavurma (Baharatlı)', 'KURU SOĞAN', 10),
    ('Batman Usulü Etli Kavurma (Baharatlı)', 'TUZ', 0.8),
    ('Batman Usulü Etli Kavurma (Baharatlı)', 'KARABİBER', 0.3),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Bakla', 'BAKLA', 50),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Bakla', 'NOHUT', 20),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Bakla', 'KURU SOĞAN', 10),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Bakla', 'ZEYTİNYAĞI', 3),
    ('Şırnak Usulü Zeytinyağlı Nohutlu Bakla', 'TUZ', 0.8),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'KUZU KIYMA', 50),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Kilis Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', 'BULGUR', 40),
    ('Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', 'NOHUT', 20),
    ('Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', 'DOMATES', 20),
    ('Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', 'KURU SOĞAN', 10),
    ('Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', 'ZEYTİNYAĞI', 3),
    ('Adıyaman Usulü Zeytinyağlı Nohutlu Bulgur', 'TUZ', 0.8)
)
select b.ad,
    (select count(*) from beklenen x where x.ad = b.ad) as beklenen_sayisi,
    (select count(*) from recete_malzemeleri rm
       join receteler r on r.id = rm.recete_id
      where r.ad = b.ad and r.isletme_id is null) as db_sayisi,
    (select count(*) from beklenen x
       join receteler r on r.ad = x.ad and r.isletme_id is null
       join recete_malzemeleri rm on rm.recete_id = r.id
       join malzemeler m on m.id = rm.malzeme_id
      where x.ad = b.ad and m.ad = x.malzeme_ad and rm.miktar_gram = x.miktar) as tam_eslesen
from (select distinct ad from beklenen) b
where not (
    (select count(*) from beklenen x where x.ad = b.ad) =
    (select count(*) from recete_malzemeleri rm join receteler r on r.id = rm.recete_id where r.ad = b.ad and r.isletme_id is null)
    and
    (select count(*) from beklenen x where x.ad = b.ad) =
    (select count(*) from beklenen x
       join receteler r on r.ad = x.ad and r.isletme_id is null
       join recete_malzemeleri rm on rm.recete_id = r.id
       join malzemeler m on m.id = rm.malzeme_id
      where x.ad = b.ad and m.ad = x.malzeme_ad and rm.miktar_gram = x.miktar)
)
order by b.ad;
