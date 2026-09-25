-- 153_yeni_63_tarif_7_bolge_parti9_SON.sql
-- 1000 tarif hedefi, Parti 9 (SON): 63 yeni tarif,
-- 7 bolgeye esit dagitilmis. Ayni _yeni_tarif_ekle fonksiyonunu kullanir.
-- TUM malzemeler DOGRUDAN katalogda dogrulandi.
-- Malzeme miktarlari 1 porsiyon (kisi basi) bazinda. hazirlik_
-- talimati ve recete_asamalari BU DOSYADA YOK -- ayri sonraki asama.
-- Idempotent. Dogrulama UC-SAYI yontemiyle (sayim degil).
-- BU DOSYA CALISTIRILDIKTAN SONRA KUTUPHANE TAM 1000 TARIFE ULASMALI.

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
        'İstanbul Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bursa Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Edirne Usulü Kirazlı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KİRAZ", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 10}, {"ad": "SU", "miktar_gram": 60}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırklareli Usulü Izgara Levrek', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "LEVREK", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tekirdağ Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Balıkesir Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sakarya Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 25}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bilecik Usulü Zeytinyağlı Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "HAVUÇ", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'İzmir Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Manisa Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aydın Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muğla Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bodrum Usulü Izgara Karides (Sarımsaklı)', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Fethiye Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kuşadası Usulü Elmalı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'sonbahar', 'Ege',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "ŞEKER", "miktar_gram": 12}, {"ad": "SU", "miktar_gram": 60}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Salihli Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nazilli Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Silifke Usulü Izgara Levrek', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "LEVREK", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Anamur Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kaş Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Alanya Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Akdeniz',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kumluca Usulü Zeytinyağlı Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KABAK", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Ankara Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Eskişehir Usulü Izgara Tavuk Kanat', v_grup1_id, 1, 35,
        '["izgara","beyaz_et"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "TAVUK KANAT", "miktar_gram": 120}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çorum Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırşehir Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nevşehir Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'İç Anadolu',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çankırı Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Samsun Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Karadeniz',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Zonguldak Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kastamonu Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bartın Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karabük Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Erzincan Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KOYUN ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Doğu Anadolu',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Peynirli Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "LOR PEYNİRİ", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muş Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Doğu Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Etli Nohutlu Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Zeytinyağlı Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
        '[{"ad": "BAKLA", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Etli Kavurma (Kimyonlu)', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Zeytinyağlı Nohutlu Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adıyaman Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

end $$;

-- SAGLAM Dogrulama (uc-sayi yontemi). 0 satir donmesi beklenir.
with beklenen(ad, malzeme_ad, miktar) as (
  values
    ('İstanbul Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('İstanbul Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('İstanbul Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('İstanbul Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('İstanbul Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8),
    ('Bursa Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Bursa Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Bursa Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Bursa Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Bursa Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Edirne Usulü Kirazlı Komposto', 'KİRAZ', 50),
    ('Edirne Usulü Kirazlı Komposto', 'ŞEKER', 10),
    ('Edirne Usulü Kirazlı Komposto', 'SU', 60),
    ('Kırklareli Usulü Izgara Levrek', 'LEVREK', 150),
    ('Kırklareli Usulü Izgara Levrek', 'ZEYTİNYAĞI', 3),
    ('Kırklareli Usulü Izgara Levrek', 'LİMON SUYU', 2),
    ('Kırklareli Usulü Izgara Levrek', 'TUZ', 0.8),
    ('Tekirdağ Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Tekirdağ Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Tekirdağ Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Tekirdağ Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Tekirdağ Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Çanakkale Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Çanakkale Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Çanakkale Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Çanakkale Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Balıkesir Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Balıkesir Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Balıkesir Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'DANA KIYMA', 50),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'BULGUR', 25),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'NOHUT', 20),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'KURU SOĞAN', 10),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'TUZ', 0.8),
    ('Sakarya Usulü Etli Nohutlu Bulgur', 'KARABİBER', 0.3),
    ('Bilecik Usulü Zeytinyağlı Havuç', 'HAVUÇ', 60),
    ('Bilecik Usulü Zeytinyağlı Havuç', 'KURU SOĞAN', 10),
    ('Bilecik Usulü Zeytinyağlı Havuç', 'ZEYTİNYAĞI', 3),
    ('Bilecik Usulü Zeytinyağlı Havuç', 'ŞEKER', 0.5),
    ('Bilecik Usulü Zeytinyağlı Havuç', 'TUZ', 0.8),
    ('İzmir Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('İzmir Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('İzmir Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('İzmir Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('İzmir Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Manisa Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Manisa Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Manisa Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Manisa Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Manisa Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Aydın Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Aydın Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Aydın Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Aydın Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Aydın Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Muğla Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Muğla Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Muğla Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Muğla Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Muğla Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Bodrum Usulü Izgara Karides (Sarımsaklı)', 'KARİDES', 100),
    ('Bodrum Usulü Izgara Karides (Sarımsaklı)', 'SARIMSAK', 2),
    ('Bodrum Usulü Izgara Karides (Sarımsaklı)', 'ZEYTİNYAĞI', 3),
    ('Bodrum Usulü Izgara Karides (Sarımsaklı)', 'LİMON SUYU', 2),
    ('Bodrum Usulü Izgara Karides (Sarımsaklı)', 'TUZ', 0.8),
    ('Fethiye Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Fethiye Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Fethiye Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Fethiye Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Fethiye Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Kuşadası Usulü Elmalı Komposto', 'ELMA', 60),
    ('Kuşadası Usulü Elmalı Komposto', 'ŞEKER', 12),
    ('Kuşadası Usulü Elmalı Komposto', 'SU', 60),
    ('Salihli Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Salihli Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Salihli Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Salihli Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'KEREVİZ', 60),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'HAVUÇ', 15),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'KURU SOĞAN', 10),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'ZEYTİNYAĞI', 3),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'ŞEKER', 0.5),
    ('Nazilli Usulü Zeytinyağlı Kereviz', 'TUZ', 0.8),
    ('Antalya Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Antalya Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Antalya Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Antalya Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Antalya Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Mersin Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('Mersin Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('Mersin Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('Mersin Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('Mersin Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8),
    ('Adana Usulü Etli Bulgur Pilavı', 'KUZU KIYMA', 50),
    ('Adana Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Adana Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Adana Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Adana Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Hatay Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Hatay Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Hatay Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Hatay Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Hatay Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Silifke Usulü Izgara Levrek', 'LEVREK', 150),
    ('Silifke Usulü Izgara Levrek', 'ZEYTİNYAĞI', 3),
    ('Silifke Usulü Izgara Levrek', 'LİMON SUYU', 2),
    ('Silifke Usulü Izgara Levrek', 'TUZ', 0.8),
    ('Anamur Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Anamur Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Anamur Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Anamur Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Anamur Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Kaş Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Kaş Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Kaş Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Kaş Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Alanya Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Alanya Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Alanya Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Kumluca Usulü Zeytinyağlı Kabak', 'KABAK', 70),
    ('Kumluca Usulü Zeytinyağlı Kabak', 'KURU SOĞAN', 10),
    ('Kumluca Usulü Zeytinyağlı Kabak', 'ZEYTİNYAĞI', 3),
    ('Kumluca Usulü Zeytinyağlı Kabak', 'ŞEKER', 0.5),
    ('Kumluca Usulü Zeytinyağlı Kabak', 'TUZ', 0.8),
    ('Ankara Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Ankara Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Ankara Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Ankara Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Ankara Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Konya Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Konya Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Konya Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Konya Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Konya Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'DANA KIYMA', 50),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Kayseri Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('Sivas Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8),
    ('Eskişehir Usulü Izgara Tavuk Kanat', 'TAVUK KANAT', 120),
    ('Eskişehir Usulü Izgara Tavuk Kanat', 'PUL BİBER', 0.8),
    ('Eskişehir Usulü Izgara Tavuk Kanat', 'SARIMSAK', 1.5),
    ('Eskişehir Usulü Izgara Tavuk Kanat', 'ZEYTİNYAĞI', 4),
    ('Eskişehir Usulü Izgara Tavuk Kanat', 'TUZ', 0.8),
    ('Çorum Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Çorum Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Çorum Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Çorum Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Kırşehir Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Kırşehir Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Kırşehir Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Nevşehir Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Nevşehir Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Nevşehir Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Nevşehir Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Nevşehir Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Çankırı Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Çankırı Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Çankırı Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Çankırı Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Çankırı Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Trabzon Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Trabzon Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Trabzon Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Trabzon Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Trabzon Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Rize Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Rize Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Rize Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Rize Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Rize Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Samsun Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Samsun Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Samsun Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Samsun Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Samsun Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'DANA KIYMA', 50),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Ordu Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Giresun Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Giresun Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Giresun Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Giresun Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Zonguldak Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Zonguldak Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Zonguldak Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Kastamonu Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Kastamonu Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Kastamonu Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Kastamonu Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Bartın Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Bartın Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Bartın Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Bartın Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Bartın Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Karabük Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Karabük Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Karabük Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Karabük Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Karabük Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'KUZU KIYMA', 50),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Erzurum Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Erzincan Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Erzincan Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Erzincan Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Erzincan Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Erzincan Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Van Usulü Etli Kavurma (Kimyonlu)', 'KOYUN ETİ (KOL)', 90),
    ('Van Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Van Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Van Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Van Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Kars Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Kars Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Kars Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Kars Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Kars Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Ağrı Usulü Peynirli Yumurta', 'LOR PEYNİRİ', 30),
    ('Ağrı Usulü Peynirli Yumurta', 'TAVUK YUMURTASI', 40),
    ('Ağrı Usulü Peynirli Yumurta', 'TEREYAĞI', 4),
    ('Ağrı Usulü Peynirli Yumurta', 'TUZ', 0.6),
    ('Muş Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Muş Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Muş Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Malatya Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Malatya Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Malatya Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Malatya Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Malatya Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Elazığ Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Elazığ Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Elazığ Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Elazığ Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Elazığ Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('Bingöl Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8),
    ('Gaziantep Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Gaziantep Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Gaziantep Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Gaziantep Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Gaziantep Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', 'KABAK', 50),
    ('Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', 'NOHUT', 20),
    ('Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', 'KURU SOĞAN', 10),
    ('Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', 'ZEYTİNYAĞI', 3),
    ('Şanlıurfa Usulü Zeytinyağlı Nohutlu Kabak', 'TUZ', 0.8),
    ('Diyarbakır Usulü Etli Bulgur Pilavı', 'KUZU KIYMA', 50),
    ('Diyarbakır Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Diyarbakır Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Diyarbakır Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Diyarbakır Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Mardin Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Mardin Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Mardin Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Mardin Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Mardin Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Siirt Usulü Etli Nohutlu Patlıcan', 'KUZU KIYMA', 50),
    ('Siirt Usulü Etli Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Siirt Usulü Etli Nohutlu Patlıcan', 'NOHUT', 15),
    ('Siirt Usulü Etli Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Siirt Usulü Etli Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Siirt Usulü Etli Nohutlu Patlıcan', 'KARABİBER', 0.3),
    ('Batman Usulü Zeytinyağlı Bakla', 'BAKLA', 60),
    ('Batman Usulü Zeytinyağlı Bakla', 'KURU SOĞAN', 10),
    ('Batman Usulü Zeytinyağlı Bakla', 'ZEYTİNYAĞI', 3),
    ('Batman Usulü Zeytinyağlı Bakla', 'ŞEKER', 0.5),
    ('Batman Usulü Zeytinyağlı Bakla', 'TUZ', 0.8),
    ('Şırnak Usulü Etli Kavurma (Kimyonlu)', 'KUZU ETİ (KOL)', 90),
    ('Şırnak Usulü Etli Kavurma (Kimyonlu)', 'KİMYON', 0.5),
    ('Şırnak Usulü Etli Kavurma (Kimyonlu)', 'KURU SOĞAN', 10),
    ('Şırnak Usulü Etli Kavurma (Kimyonlu)', 'TUZ', 0.8),
    ('Şırnak Usulü Etli Kavurma (Kimyonlu)', 'KARABİBER', 0.3),
    ('Kilis Usulü Zeytinyağlı Nohutlu Pırasa', 'PIRASA', 50),
    ('Kilis Usulü Zeytinyağlı Nohutlu Pırasa', 'NOHUT', 20),
    ('Kilis Usulü Zeytinyağlı Nohutlu Pırasa', 'KURU SOĞAN', 10),
    ('Kilis Usulü Zeytinyağlı Nohutlu Pırasa', 'ZEYTİNYAĞI', 3),
    ('Kilis Usulü Zeytinyağlı Nohutlu Pırasa', 'TUZ', 0.8),
    ('Adıyaman Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Adıyaman Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Adıyaman Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Adıyaman Usulü Etli Kavurma', 'KARABİBER', 0.3)
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

-- SON KONTROL: kutuphanedeki TOPLAM tarif sayisi. 1000 donmeli.
select count(*) as toplam_kutuphane from receteler where isletme_id is null;
