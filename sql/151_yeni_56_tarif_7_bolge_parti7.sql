-- 151_yeni_56_tarif_7_bolge_parti7.sql
-- 1000 tarif hedefi, Parti 7: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (8 tarif). Ayni _yeni_tarif_ekle fonksiyonunu kullanir.
-- TUM malzemeler DOGRUDAN katalogda dogrulandi.
-- Malzeme miktarlari 1 porsiyon (kisi basi) bazinda. hazirlik_
-- talimati ve recete_asamalari BU DOSYADA YOK -- ayri sonraki asama.
-- Idempotent: isme gore 'yoksa ekle', tekrar calistirmak zarar vermez.
--
-- ONEMLI: dogrulama sorgusu ARTIK SAYIM DEGIL, UC-SAYI yontemi
-- kullaniyor (beklenen malzeme sayisi = DB sayisi = tam eslesen cift
-- sayisi) -- onceki 'sadece sayim' yontemi Parti 4'te bir gizli
-- cakismayi (Karadeniz Usulü Hamsi Buğulama) kacirmisti.

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
        'İstanbul Usulü Zeytinyağlı Enginar Turşusu', v_grup3_id, 1, 25,
        '["tursu","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "ENGİNAR", "miktar_gram": 50}, {"ad": "SİRKE", "miktar_gram": 5}, {"ad": "TUZ", "miktar_gram": 3.5}, {"ad": "SARIMSAK", "miktar_gram": 1.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bursa Usulü Etli Nohutlu Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 70}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırklareli Usulü Elmalı Tatlı', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "ELMA", "miktar_gram": 70}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "TARÇIN", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Usulü Izgara Levrek', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "LEVREK", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Balıkesir Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Zeytinyağlı Kabaklı Pirinç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 10}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Kirazlı Yoğurt Tatlısı', v_grup3_id, 1, 15,
        '["tatli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "YOĞURT (TAM)", "miktar_gram": 50}, {"ad": "KİRAZ", "miktar_gram": 40}, {"ad": "ŞEKER", "miktar_gram": 10}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'İzmir Usulü Zeytinyağlı Kabaklı Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muğla Usulü Etli Bakla', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "BAKLA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bodrum Usulü Portakallı Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "PORTAKAL", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Datça Usulü Izgara Karides', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kuşadası Usulü Etli Enginar', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "ENGİNAR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Foça Usulü Zeytinyağlı Nohutlu Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "PIRASA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ödemiş Usulü Nohutlu Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "TAVUK BUT", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tire Usulü Üzümlü Ceviz Tatlısı', v_grup3_id, 1, 20,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Ege',
        '[{"ad": "ÜZÜM", "miktar_gram": 50}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 10}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Zeytinyağlı Nohutlu Bakla', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "BAKLA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Zeytinyağlı Biberli Patlıcan', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "YEŞİL BİBER", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Etli Nohutlu Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 70}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Silifke Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Anamur Usulü Izgara Karides', v_grup1_id, 1, 20,
        '["balik","izgara"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KARİDES", "miktar_gram": 100}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kaş Usulü Portakallı Zeytinyağlı Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "PORTAKAL", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Alanya Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Ankara Usulü Zeytinyağlı Nohutlu Bamya', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "BAMYA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Niğde Usulü Kayısılı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "KAYISI", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırşehir Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çorum Usulü Zeytinyağlı Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Samsun Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Elmalı Fındıklı Tatlı', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "ELMA", "miktar_gram": 50}, {"ad": "FINDIK (İÇ)", "miktar_gram": 15}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Etli Lahana', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "LAHANA", "miktar_gram": 60}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Artvin Usulü Zeytinyağlı Kuru Fasulye', v_grup1_id, 1, 45,
        '["kuru_baklagil","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KURU FASULYE", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bayburt Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tokat Usulü Zeytinyağlı Kabak', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Karadeniz',
        '[{"ad": "KABAK", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Erzincan Usulü Zeytinyağlı Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Doğu Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Kavurmalı Yumurta', v_grup1_id, 1, 15,
        '["yumurta"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.6}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muş Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 25}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 40}, {"ad": "YEŞİL BİBER", "miktar_gram": 30}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Nar Ekşili Etli Kabak', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 40}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Etli Nohutlu Bulgur', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 25}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Zeytinyağlı Nohutlu Patlıcan', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Zeytinyağlı Nohutlu Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Güneydoğu Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

end $$;

-- SAGLAM Dogrulama (uc-sayi yontemi -- Karadeniz Usulü Hamsi Buğulama
-- dersi geregi): her tarif icin (a) beklenen malzeme sayisi, (b) DB'deki
-- gercek sayi, (c) tam eslesen (ayni malzeme+ayni miktar) cift sayisi
-- karsilastirilir. Sadece UCU DE ESIT DEGILSE satir doner (= sorun var).
-- 0 satir donmesi beklenir.
with beklenen(ad, malzeme_ad, miktar) as (
  values
    ('İstanbul Usulü Zeytinyağlı Enginar Turşusu', 'ENGİNAR', 50),
    ('İstanbul Usulü Zeytinyağlı Enginar Turşusu', 'SİRKE', 5),
    ('İstanbul Usulü Zeytinyağlı Enginar Turşusu', 'TUZ', 3.5),
    ('İstanbul Usulü Zeytinyağlı Enginar Turşusu', 'SARIMSAK', 1.5),
    ('Bursa Usulü Etli Nohutlu Kavurma', 'DANA KIYMA', 70),
    ('Bursa Usulü Etli Nohutlu Kavurma', 'NOHUT', 25),
    ('Bursa Usulü Etli Nohutlu Kavurma', 'KURU SOĞAN', 10),
    ('Bursa Usulü Etli Nohutlu Kavurma', 'TUZ', 0.8),
    ('Bursa Usulü Etli Nohutlu Kavurma', 'KARABİBER', 0.3),
    ('Kırklareli Usulü Elmalı Tatlı', 'ELMA', 70),
    ('Kırklareli Usulü Elmalı Tatlı', 'ŞEKER', 25),
    ('Kırklareli Usulü Elmalı Tatlı', 'TARÇIN', 0.3),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8),
    ('Çanakkale Usulü Izgara Levrek', 'LEVREK', 150),
    ('Çanakkale Usulü Izgara Levrek', 'ZEYTİNYAĞI', 3),
    ('Çanakkale Usulü Izgara Levrek', 'LİMON SUYU', 2),
    ('Çanakkale Usulü Izgara Levrek', 'TUZ', 0.8),
    ('Balıkesir Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Balıkesir Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Balıkesir Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Balıkesir Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Marmara Usulü Zeytinyağlı Kabaklı Pirinç', 'KABAK', 50),
    ('Marmara Usulü Zeytinyağlı Kabaklı Pirinç', 'PİRİNÇ (HAM)', 10),
    ('Marmara Usulü Zeytinyağlı Kabaklı Pirinç', 'KURU SOĞAN', 10),
    ('Marmara Usulü Zeytinyağlı Kabaklı Pirinç', 'ZEYTİNYAĞI', 3),
    ('Marmara Usulü Zeytinyağlı Kabaklı Pirinç', 'TUZ', 0.8),
    ('İstanbul Usulü Kirazlı Yoğurt Tatlısı', 'YOĞURT (TAM)', 50),
    ('İstanbul Usulü Kirazlı Yoğurt Tatlısı', 'KİRAZ', 40),
    ('İstanbul Usulü Kirazlı Yoğurt Tatlısı', 'ŞEKER', 10),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut', 'KABAK', 50),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut', 'NOHUT', 20),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut', 'KURU SOĞAN', 10),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut', 'ZEYTİNYAĞI', 3),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut', 'TUZ', 0.8),
    ('Muğla Usulü Etli Bakla', 'KUZU ETİ (KOL)', 70),
    ('Muğla Usulü Etli Bakla', 'BAKLA', 50),
    ('Muğla Usulü Etli Bakla', 'KURU SOĞAN', 10),
    ('Muğla Usulü Etli Bakla', 'TUZ', 0.8),
    ('Muğla Usulü Etli Bakla', 'KARABİBER', 0.3),
    ('Bodrum Usulü Portakallı Zeytinyağlı Kereviz', 'KEREVİZ', 50),
    ('Bodrum Usulü Portakallı Zeytinyağlı Kereviz', 'PORTAKAL', 20),
    ('Bodrum Usulü Portakallı Zeytinyağlı Kereviz', 'ZEYTİNYAĞI', 3),
    ('Bodrum Usulü Portakallı Zeytinyağlı Kereviz', 'ŞEKER', 0.5),
    ('Bodrum Usulü Portakallı Zeytinyağlı Kereviz', 'TUZ', 0.8),
    ('Datça Usulü Izgara Karides', 'KARİDES', 100),
    ('Datça Usulü Izgara Karides', 'ZEYTİNYAĞI', 3),
    ('Datça Usulü Izgara Karides', 'SARIMSAK', 1.5),
    ('Datça Usulü Izgara Karides', 'LİMON SUYU', 2),
    ('Datça Usulü Izgara Karides', 'TUZ', 0.8),
    ('Kuşadası Usulü Etli Enginar', 'KUZU ETİ (KOL)', 70),
    ('Kuşadası Usulü Etli Enginar', 'ENGİNAR', 40),
    ('Kuşadası Usulü Etli Enginar', 'KURU SOĞAN', 10),
    ('Kuşadası Usulü Etli Enginar', 'TUZ', 0.8),
    ('Kuşadası Usulü Etli Enginar', 'KARABİBER', 0.3),
    ('Foça Usulü Zeytinyağlı Nohutlu Pırasa', 'PIRASA', 50),
    ('Foça Usulü Zeytinyağlı Nohutlu Pırasa', 'NOHUT', 20),
    ('Foça Usulü Zeytinyağlı Nohutlu Pırasa', 'KURU SOĞAN', 10),
    ('Foça Usulü Zeytinyağlı Nohutlu Pırasa', 'ZEYTİNYAĞI', 3),
    ('Foça Usulü Zeytinyağlı Nohutlu Pırasa', 'TUZ', 0.8),
    ('Ödemiş Usulü Nohutlu Tavuk Sote', 'TAVUK BUT', 80),
    ('Ödemiş Usulü Nohutlu Tavuk Sote', 'NOHUT', 20),
    ('Ödemiş Usulü Nohutlu Tavuk Sote', 'KURU SOĞAN', 10),
    ('Ödemiş Usulü Nohutlu Tavuk Sote', 'TUZ', 0.8),
    ('Ödemiş Usulü Nohutlu Tavuk Sote', 'KARABİBER', 0.3),
    ('Tire Usulü Üzümlü Ceviz Tatlısı', 'ÜZÜM', 50),
    ('Tire Usulü Üzümlü Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Tire Usulü Üzümlü Ceviz Tatlısı', 'ŞEKER', 10),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla', 'BAKLA', 50),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla', 'NOHUT', 20),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla', 'KURU SOĞAN', 10),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla', 'ZEYTİNYAĞI', 3),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla', 'TUZ', 0.8),
    ('Mersin Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Mersin Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Mersin Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Mersin Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'PATLICAN', 50),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'YEŞİL BİBER', 20),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'DOMATES', 25),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'KURU SOĞAN', 10),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'ZEYTİNYAĞI', 3),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan', 'TUZ', 0.8),
    ('Hatay Usulü Etli Nohutlu Kavurma', 'KUZU KIYMA', 70),
    ('Hatay Usulü Etli Nohutlu Kavurma', 'NOHUT', 25),
    ('Hatay Usulü Etli Nohutlu Kavurma', 'KURU SOĞAN', 10),
    ('Hatay Usulü Etli Nohutlu Kavurma', 'TUZ', 0.8),
    ('Hatay Usulü Etli Nohutlu Kavurma', 'KARABİBER', 0.3),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'KEREVİZ', 60),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'HAVUÇ', 15),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'KURU SOĞAN', 10),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'ZEYTİNYAĞI', 3),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'ŞEKER', 0.5),
    ('Silifke Usulü Zeytinyağlı Kereviz', 'TUZ', 0.8),
    ('Anamur Usulü Izgara Karides', 'KARİDES', 100),
    ('Anamur Usulü Izgara Karides', 'ZEYTİNYAĞI', 3),
    ('Anamur Usulü Izgara Karides', 'SARIMSAK', 1.5),
    ('Anamur Usulü Izgara Karides', 'LİMON SUYU', 2),
    ('Anamur Usulü Izgara Karides', 'TUZ', 0.8),
    ('Kaş Usulü Portakallı Zeytinyağlı Havuç', 'HAVUÇ', 50),
    ('Kaş Usulü Portakallı Zeytinyağlı Havuç', 'PORTAKAL', 20),
    ('Kaş Usulü Portakallı Zeytinyağlı Havuç', 'ZEYTİNYAĞI', 3),
    ('Kaş Usulü Portakallı Zeytinyağlı Havuç', 'ŞEKER', 0.5),
    ('Kaş Usulü Portakallı Zeytinyağlı Havuç', 'TUZ', 0.8),
    ('Alanya Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Alanya Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Alanya Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Alanya Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'BAMYA', 50),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'NOHUT', 20),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'DOMATES', 20),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'KURU SOĞAN', 10),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'ZEYTİNYAĞI', 3),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya', 'TUZ', 0.8),
    ('Konya Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Konya Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Konya Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Konya Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'PIRASA', 60),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'HAVUÇ', 15),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'KURU SOĞAN', 10),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'ZEYTİNYAĞI', 3),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'ŞEKER', 0.5),
    ('Kayseri Usulü Zeytinyağlı Pırasa', 'TUZ', 0.8),
    ('Sivas Usulü Etli Bulgur Pilavı', 'DANA KIYMA', 50),
    ('Sivas Usulü Etli Bulgur Pilavı', 'BULGUR', 40),
    ('Sivas Usulü Etli Bulgur Pilavı', 'KURU SOĞAN', 10),
    ('Sivas Usulü Etli Bulgur Pilavı', 'TUZ', 0.8),
    ('Sivas Usulü Etli Bulgur Pilavı', 'KARABİBER', 0.3),
    ('Niğde Usulü Kayısılı Komposto', 'KAYISI', 50),
    ('Niğde Usulü Kayısılı Komposto', 'ŞEKER', 15),
    ('Niğde Usulü Kayısılı Komposto', 'SU', 70),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'NOHUT', 20),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'DOMATES', 25),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'ZEYTİNYAĞI', 3),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Kırşehir Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Kırşehir Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Kırşehir Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Kırşehir Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Çorum Usulü Zeytinyağlı Nohut', 'NOHUT', 50),
    ('Çorum Usulü Zeytinyağlı Nohut', 'KURU SOĞAN', 10),
    ('Çorum Usulü Zeytinyağlı Nohut', 'DOMATES', 20),
    ('Çorum Usulü Zeytinyağlı Nohut', 'ZEYTİNYAĞI', 3),
    ('Çorum Usulü Zeytinyağlı Nohut', 'TUZ', 0.8),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'PIRASA', 60),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'HAVUÇ', 15),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'KURU SOĞAN', 10),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'ZEYTİNYAĞI', 3),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'ŞEKER', 0.5),
    ('Trabzon Usulü Zeytinyağlı Pırasa', 'TUZ', 0.8),
    ('Rize Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Rize Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Rize Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Rize Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Giresun Usulü Elmalı Fındıklı Tatlı', 'ELMA', 50),
    ('Giresun Usulü Elmalı Fındıklı Tatlı', 'FINDIK (İÇ)', 15),
    ('Giresun Usulü Elmalı Fındıklı Tatlı', 'ŞEKER', 20),
    ('Ordu Usulü Etli Lahana', 'LAHANA', 60),
    ('Ordu Usulü Etli Lahana', 'DANA KIYMA', 40),
    ('Ordu Usulü Etli Lahana', 'KURU SOĞAN', 10),
    ('Ordu Usulü Etli Lahana', 'TUZ', 0.8),
    ('Ordu Usulü Etli Lahana', 'KARABİBER', 0.3),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye', 'KURU FASULYE', 50),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye', 'KURU SOĞAN', 10),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye', 'DOMATES', 20),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye', 'ZEYTİNYAĞI', 3),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye', 'TUZ', 0.8),
    ('Bayburt Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Bayburt Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Bayburt Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Bayburt Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Tokat Usulü Zeytinyağlı Kabak', 'KABAK', 70),
    ('Tokat Usulü Zeytinyağlı Kabak', 'KURU SOĞAN', 10),
    ('Tokat Usulü Zeytinyağlı Kabak', 'ZEYTİNYAĞI', 3),
    ('Tokat Usulü Zeytinyağlı Kabak', 'ŞEKER', 0.5),
    ('Tokat Usulü Zeytinyağlı Kabak', 'TUZ', 0.8),
    ('Erzurum Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Erzurum Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Erzurum Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Erzurum Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Erzincan Usulü Zeytinyağlı Nohut', 'NOHUT', 50),
    ('Erzincan Usulü Zeytinyağlı Nohut', 'KURU SOĞAN', 10),
    ('Erzincan Usulü Zeytinyağlı Nohut', 'DOMATES', 20),
    ('Erzincan Usulü Zeytinyağlı Nohut', 'ZEYTİNYAĞI', 3),
    ('Erzincan Usulü Zeytinyağlı Nohut', 'TUZ', 0.8),
    ('Van Usulü Elmalı Ceviz Tatlısı', 'ELMA', 60),
    ('Van Usulü Elmalı Ceviz Tatlısı', 'CEVİZ (İÇ)', 10),
    ('Van Usulü Elmalı Ceviz Tatlısı', 'ŞEKER', 20),
    ('Kars Usulü Zeytinyağlı Pırasa', 'PIRASA', 60),
    ('Kars Usulü Zeytinyağlı Pırasa', 'HAVUÇ', 15),
    ('Kars Usulü Zeytinyağlı Pırasa', 'KURU SOĞAN', 10),
    ('Kars Usulü Zeytinyağlı Pırasa', 'ZEYTİNYAĞI', 3),
    ('Kars Usulü Zeytinyağlı Pırasa', 'ŞEKER', 0.5),
    ('Kars Usulü Zeytinyağlı Pırasa', 'TUZ', 0.8),
    ('Ağrı Usulü Kavurmalı Yumurta', 'DANA KIYMA', 30),
    ('Ağrı Usulü Kavurmalı Yumurta', 'TAVUK YUMURTASI', 40),
    ('Ağrı Usulü Kavurmalı Yumurta', 'TEREYAĞI', 4),
    ('Ağrı Usulü Kavurmalı Yumurta', 'TUZ', 0.6),
    ('Muş Usulü Etli Nohutlu Bulgur', 'KUZU KIYMA', 50),
    ('Muş Usulü Etli Nohutlu Bulgur', 'BULGUR', 25),
    ('Muş Usulü Etli Nohutlu Bulgur', 'NOHUT', 20),
    ('Muş Usulü Etli Nohutlu Bulgur', 'KURU SOĞAN', 10),
    ('Muş Usulü Etli Nohutlu Bulgur', 'TUZ', 0.8),
    ('Muş Usulü Etli Nohutlu Bulgur', 'KARABİBER', 0.3),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç', 'HAVUÇ', 50),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç', 'NOHUT', 20),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç', 'KURU SOĞAN', 10),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç', 'ZEYTİNYAĞI', 3),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç', 'TUZ', 0.8),
    ('Elazığ Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Elazığ Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Elazığ Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Elazığ Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Gaziantep Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Gaziantep Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Gaziantep Usulü Etli Kavurma', 'PUL BİBER', 0.5),
    ('Gaziantep Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Gaziantep Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'BULGUR', 40),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'YEŞİL BİBER', 30),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'DOMATES', 25),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'KURU SOĞAN', 10),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'ZEYTİNYAĞI', 3),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', 'TUZ', 0.8),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak', 'KUZU KIYMA', 50),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak', 'KABAK', 40),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak', 'NAR EKŞİSİ', 2),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak', 'KURU SOĞAN', 10),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak', 'TUZ', 0.8),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak', 'KARABİBER', 0.3),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'KUZU KIYMA', 50),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'BULGUR', 25),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'NOHUT', 20),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'KURU SOĞAN', 10),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'TUZ', 0.8),
    ('Mardin Usulü Etli Nohutlu Bulgur', 'KARABİBER', 0.3),
    ('Siirt Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Siirt Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Siirt Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Siirt Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan', 'PATLICAN', 50),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan', 'NOHUT', 20),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan', 'DOMATES', 25),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan', 'KURU SOĞAN', 10),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan', 'ZEYTİNYAĞI', 3),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan', 'TUZ', 0.8),
    ('Şırnak Usulü Etli Kavurma', 'KUZU ETİ (KOL)', 90),
    ('Şırnak Usulü Etli Kavurma', 'KURU SOĞAN', 10),
    ('Şırnak Usulü Etli Kavurma', 'TUZ', 0.8),
    ('Şırnak Usulü Etli Kavurma', 'KARABİBER', 0.3),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz', 'KEREVİZ', 50),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz', 'NOHUT', 20),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz', 'KURU SOĞAN', 10),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz', 'ZEYTİNYAĞI', 3),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz', 'TUZ', 0.8)
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
