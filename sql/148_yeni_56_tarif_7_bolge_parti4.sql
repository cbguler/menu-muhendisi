-- 148_yeni_56_tarif_7_bolge_parti4.sql
-- 1000 tarif hedefi, Parti 4: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (8 tarif). Ayni _yeni_tarif_ekle fonksiyonunu kullanir
-- (create or replace ile guncellenir, zararsiz).
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
        'Yalova Usulü Zeytinyağlı Kestane', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "KESTANE", "miktar_gram": 60}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bilecik Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "BULGUR", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sakarya Usulü Mısırlı Tavuk Güveç', v_grup1_id, 1, 40,
        '["beyaz_et","etli_sebze"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "TAVUK BUT", "miktar_gram": 80}, {"ad": "MISIR", "miktar_gram": 30}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çorlu Usulü Kaşarlı Tavuklu Makarna', v_grup2_id, 1, 30,
        '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "MAKARNA", "miktar_gram": 60}, {"ad": "TAVUK GÖĞÜS", "miktar_gram": 40}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bursa Usulü Cevizli Erik Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "ERİK", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Zeytinyağlı Balkabağı', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "KABAK", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 1}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Nohutlu Tavuk Çorbası', v_grup2_id, 1, 25,
        '["corba"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 30}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "TAVUK SUYU", "miktar_gram": 90}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Armutlu Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "BAL", "miktar_gram": 6}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'Manisa Usulü Mesir Macunlu Tatlı - basitleştirilmiş', v_grup3_id, 1, 20,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "BAL", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 15}, {"ad": "TARÇIN", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Denizli Usulü Keşkek (Tavuklu)', v_grup1_id, 1, 70,
        '["beyaz_et"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "TAVUK BUT", "miktar_gram": 80}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Uşak Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ayvalık Usulü Zeytinli Ekmek Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "EKMEK (BEYAZ)", "miktar_gram": 30}, {"ad": "YEŞİL ZEYTİN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Urla Usulü Karidesli Zeytinyağlı Enginar', v_grup2_id, 1, 35,
        '["zeytinyagli"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "ENGİNAR", "miktar_gram": 40}, {"ad": "KARİDES", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tire Usulü Köftesi (Fırında)', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 90}, {"ad": "PATATES", "miktar_gram": 40}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ödemiş Usulü Patatesli Tavuk Sote', v_grup1_id, 1, 35,
        '["beyaz_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "TAVUK BUT", "miktar_gram": 80}, {"ad": "PATATES", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kütahya Usulü Kirazlı Yoğurt', v_grup3_id, 1, 15,
        '["tatli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "YOĞURT (TAM)", "miktar_gram": 50}, {"ad": "KİRAZ", "miktar_gram": 40}, {"ad": "ŞEKER", "miktar_gram": 10}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Isparta Usulü Gül Reçelli Yoğurt Tatlısı', v_grup3_id, 1, 15,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "YOĞURT (TAM)", "miktar_gram": 50}, {"ad": "BAL", "miktar_gram": 15}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Burdur Usulü Etli Nohutlu Pilav', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 40}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Osmaniye Usulü Zeytinyağlı Yer Fıstıklı Salata', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "MARUL", "miktar_gram": 25}, {"ad": "FINDIK (İÇ)", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2.5}, {"ad": "LİMON SUYU", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tarsus Usulü Şalgamlı Köfte - basitleştirilmiş (Şalgam Hariç)', v_grup1_id, 1, 30,
        '["kirmizi_et","izgara"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "KİMYON", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Manavgat Usulü Izgara Levrek', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "LEVREK", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Side Usulü Zeytinyağlı Enginar Turşusu', v_grup3_id, 1, 25,
        '["tursu","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "ENGİNAR", "miktar_gram": 50}, {"ad": "SİRKE", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 3.5}, {"ad": "SARIMSAK", "miktar_gram": 1.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kumluca Usulü Zeytinyağlı Domates Yemeği', v_grup2_id, 1, 25,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "DOMATES", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Usulü Portakallı Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 90}, {"ad": "PORTAKAL", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Eskişehir Usulü Çibörek (Kızartma)', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 50}, {"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "MISIR YAĞI", "miktar_gram": 30}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Etli Ekmek (İnce)', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 70}, {"ad": "KUZU KIYMA", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "PUL BİBER", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ankara Usulü Zeytinyağlı Havuç ve Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Etli Nohutlu Yahni', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nevşehir Usulü Elmalı Kabaklı Tatlı', v_grup3_id, 1, 35,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 40}, {"ad": "KABAK", "miktar_gram": 40}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Mantısı (Küçük Boy)', v_grup1_id, 1, 55,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 70}, {"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "YOĞURT (TAM)", "miktar_gram": 60}, {"ad": "SARIMSAK", "miktar_gram": 2}, {"ad": "TEREYAĞI", "miktar_gram": 8}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Yozgat Usulü Zeytinyağlı Kuru Fasulye', v_grup1_id, 1, 45,
        '["kuru_baklagil","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırşehir Usulü Nohutlu Ispanak Çorbası', v_grup2_id, 1, 30,
        '["corba","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 20}, {"ad": "ISPANAK", "miktar_gram": 30}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "TEREYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Gümüşhane Usulü Kuru Fasulye (Etli)', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kastamonu Usulü Tarhana Çorbası', v_grup2_id, 1, 25,
        '["corba"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "TARHANA", "miktar_gram": 20}, {"ad": "TAVUK SUYU", "miktar_gram": 120}, {"ad": "TEREYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bartın Usulü Pancarlı Pilav', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "PANCAR", "miktar_gram": 30}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karabük Usulü Etli Lahana Sarması', v_grup1_id, 1, 60,
        '["kirmizi_et","dolma"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "LAHANA", "miktar_gram": 70}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 25}, {"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Samsun Usulü Zeytinyağlı Karalahana', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KARALAHANA", "miktar_gram": 60}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 6}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Vişne Ekşili Kuzu Yahnisi', v_grup1_id, 1, 50,
        '["kirmizi_et"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "VİŞNE", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Mısır Ekmekli Peynirli Tabak', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "MISIR UNU", "miktar_gram": 20}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 30}, {"ad": "TEREYAĞI", "miktar_gram": 4}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Fındıklı Yoğurtlu Havuç Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 40}, {"ad": "FINDIK (İÇ)", "miktar_gram": 8}, {"ad": "YOĞURT (TAM)", "miktar_gram": 30}, {"ad": "SARIMSAK", "miktar_gram": 1}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Bingöl Usulü Kuzu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tunceli Usulü Mırığı (Yoğurtlu Bulgur Aşı)', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "YOĞURT (TAM)", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hakkari Usulü Kuzu Etli Nohut Yemeği', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ardahan Usulü Kaşarlı Kete', v_grup2_id, 1, 45,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 60}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Balı ile Kaymaklı Tatlı', v_grup3_id, 1, 10,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "BAL", "miktar_gram": 30}, {"ad": "KAYMAK", "miktar_gram": 30}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Zeytinyağlı Kuru Fasulye', v_grup1_id, 1, 45,
        '["kuru_baklagil","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Usulü Kayısılı Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 90}, {"ad": "KAYISI", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Nohutlu Bulgur Pilavı', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "TEREYAĞI", "miktar_gram": 5}, {"ad": "TAVUK SUYU", "miktar_gram": 70}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Adıyaman Usulü Etli Nohutlu Bulgur Köftesi', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 30}, {"ad": "DANA KIYMA", "miktar_gram": 60}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü İçli Köfte (Büyük Boy)', v_grup1_id, 1, 60,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "DANA KIYMA", "miktar_gram": 80}, {"ad": "KURU SOĞAN", "miktar_gram": 20}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Etli Nohutlu Şiveydiz - basitleştirilmiş', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'ilkbahar', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "TAZE SOĞAN", "miktar_gram": 30}, {"ad": "NOHUT", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Kaburgalı Nohut Çorbası', v_grup2_id, 1, 45,
        '["corba"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "SIĞIR KABURGA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Zeytinyağlı Nohutlu Patlıcan', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Kaşarlı Kuzu Güveç', v_grup1_id, 1, 55,
        '["kirmizi_et"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Zeytinyağlı Biberli Bulgur', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 40}, {"ad": "YEŞİL BİBER", "miktar_gram": 30}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

end $$;

-- Dogrulama: her tarifin ADI + malzeme sayisi karsilastirmasi.
with beklenen(ad, beklenen_sayi) as (
  values
    ('Yalova Usulü Zeytinyağlı Kestane', 5),
    ('Bilecik Usulü Etli Nohutlu Bulgur', 6),
    ('Sakarya Usulü Mısırlı Tavuk Güveç', 6),
    ('Çorlu Usulü Kaşarlı Tavuklu Makarna', 5),
    ('Bursa Usulü Cevizli Erik Tatlısı', 3),
    ('İstanbul Usulü Zeytinyağlı Balkabağı', 5),
    ('Marmara Usulü Nohutlu Tavuk Çorbası', 5),
    ('Marmara Usulü Armutlu Ceviz Tatlısı', 3),
    ('Manisa Usulü Mesir Macunlu Tatlı - basitleştirilmiş', 3),
    ('Denizli Usulü Keşkek (Tavuklu)', 6),
    ('Uşak Usulü Zeytinyağlı Nohutlu Havuç', 5),
    ('Ayvalık Usulü Zeytinli Ekmek Salatası', 5),
    ('Urla Usulü Karidesli Zeytinyağlı Enginar', 5),
    ('Tire Usulü Köftesi (Fırında)', 6),
    ('Ödemiş Usulü Patatesli Tavuk Sote', 6),
    ('Kütahya Usulü Kirazlı Yoğurt', 3),
    ('Isparta Usulü Gül Reçelli Yoğurt Tatlısı', 3),
    ('Burdur Usulü Etli Nohutlu Pilav', 6),
    ('Osmaniye Usulü Zeytinyağlı Yer Fıstıklı Salata', 5),
    ('Tarsus Usulü Şalgamlı Köfte - basitleştirilmiş (Şalgam Hariç)', 5),
    ('Manavgat Usulü Izgara Levrek', 4),
    ('Side Usulü Zeytinyağlı Enginar Turşusu', 4),
    ('Kumluca Usulü Zeytinyağlı Domates Yemeği', 5),
    ('Antalya Usulü Portakallı Tavuk Sote', 6),
    ('Eskişehir Usulü Çibörek (Kızartma)', 6),
    ('Kayseri Usulü Etli Ekmek (İnce)', 6),
    ('Ankara Usulü Zeytinyağlı Havuç ve Nohut', 5),
    ('Konya Usulü Etli Nohutlu Yahni', 5),
    ('Nevşehir Usulü Elmalı Kabaklı Tatlı', 4),
    ('Sivas Usulü Mantısı (Küçük Boy)', 7),
    ('Yozgat Usulü Zeytinyağlı Kuru Fasulye', 5),
    ('Kırşehir Usulü Nohutlu Ispanak Çorbası', 5),
    ('Gümüşhane Usulü Kuru Fasulye (Etli)', 6),
    ('Kastamonu Usulü Tarhana Çorbası', 4),
    ('Bartın Usulü Pancarlı Pilav', 5),
    ('Karabük Usulü Etli Lahana Sarması', 6),
    ('Samsun Usulü Zeytinyağlı Karalahana', 5),
    ('Trabzon Usulü Vişne Ekşili Kuzu Yahnisi', 5),
    ('Giresun Usulü Mısır Ekmekli Peynirli Tabak', 3),
    ('Ordu Usulü Fındıklı Yoğurtlu Havuç Salatası', 4),
    ('Bingöl Usulü Kuzu Kavurma', 4),
    ('Tunceli Usulü Mırığı (Yoğurtlu Bulgur Aşı)', 4),
    ('Hakkari Usulü Kuzu Etli Nohut Yemeği', 5),
    ('Ardahan Usulü Kaşarlı Kete', 4),
    ('Van Usulü Balı ile Kaymaklı Tatlı', 2),
    ('Erzurum Usulü Zeytinyağlı Kuru Fasulye', 5),
    ('Malatya Usulü Kayısılı Tavuk Sote', 5),
    ('Elazığ Usulü Nohutlu Bulgur Pilavı', 5),
    ('Adıyaman Usulü Etli Nohutlu Bulgur Köftesi', 6),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa', 5),
    ('Şanlıurfa Usulü İçli Köfte (Büyük Boy)', 6),
    ('Diyarbakır Usulü Etli Nohutlu Şiveydiz - basitleştirilmiş', 5),
    ('Mardin Usulü Kaburgalı Nohut Çorbası', 5),
    ('Siirt Usulü Zeytinyağlı Nohutlu Patlıcan', 6),
    ('Batman Usulü Kaşarlı Kuzu Güveç', 5),
    ('Kilis Usulü Zeytinyağlı Biberli Bulgur', 6)
)
select b.ad, b.beklenen_sayi, count(rm.id) as db_sayisi,
       case when count(rm.id) = b.beklenen_sayi then 'YENI EKLENDI' else 'ONCEDEN VARDI (atlandi)' end as durum
from beklenen b
join receteler r on r.ad = b.ad and r.isletme_id is null
left join recete_malzemeleri rm on rm.recete_id = r.id
group by b.ad, b.beklenen_sayi
order by durum desc, b.ad;
