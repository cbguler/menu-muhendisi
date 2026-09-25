-- 150_yeni_56_tarif_7_bolge_parti6.sql
-- 1000 tarif hedefi, Parti 6: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (8 tarif). Ayni _yeni_tarif_ekle fonksiyonunu kullanir.
-- TUM malzemeler DOGRUDAN katalogda dogrulandi (senonime guvenilmedi).
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
        'İstanbul Usulü Zeytinyağlı Fırın Patates', v_grup2_id, 1, 45,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "PATATES", "miktar_gram": 80}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "KEKİK", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bursa Usulü Nar Ekşili Kırmızı Lahana Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KIRMIZI LAHANA", "miktar_gram": 50}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kocaeli Usulü Zeytinyağlı Kabak Yemeği', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KABAK", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tekirdağ Usulü Kirazlı Komposto', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KİRAZ", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 10}, {"ad": "SU", "miktar_gram": 60}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Usulü Etli Enginar', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "ENGİNAR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Balıkesir Usulü Zeytinyağlı Patates', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "PATATES", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Vişne Ekşili Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 90}, {"ad": "VİŞNE", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Zeytinyağlı Bezelye', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Marmara',
        '[{"ad": "BEZELYE", "miktar_gram": 50}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'İzmir Usulü Etli Bamya', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "BAMYA", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muğla Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aydın Usulü İncirli Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 90}, {"ad": "KURU İNCİR", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Denizli Usulü Etli Nohutlu Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 70}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bodrum Usulü Izgara Levrek', v_grup1_id, 1, 25,
        '["balik","izgara"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "LEVREK", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "KEKİK", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Foça Usulü Ahtapotlu Zeytinyağlı Salata', v_grup3_id, 1, 20,
        '["salata"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "AHTAPOT", "miktar_gram": 50}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 2.5}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "MAYDANOZ", "miktar_gram": 1.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Söke Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Usulü Ayvalı Ceviz Tatlısı', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Ege',
        '[{"ad": "AYVA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 25}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Etli Kabak', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Izgara Tavuk Kanat', v_grup1_id, 1, 35,
        '["izgara","beyaz_et"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "TAVUK KANAT", "miktar_gram": 120}, {"ad": "PUL BİBER", "miktar_gram": 0.8}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Nar Ekşili Etli Bamya', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "BAMYA", "miktar_gram": 50}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kaş Usulü Zeytinyağlı Ahtapot Salatası', v_grup3_id, 1, 20,
        '["salata"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "AHTAPOT", "miktar_gram": 60}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Alanya Usulü Portakallı Zeytinyağlı Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "PORTAKAL", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Silifke Usulü Etli Nohutlu Yahni', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kahramanmaraş Usulü Zeytinyağlı Patlıcan', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "PATLICAN", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Ankara Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Etli Kabak Yemeği', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KABAK", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kayseri Usulü Elmalı Pekmezli Tatlı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "ÜzÜM PEKMEZİ", "miktar_gram": 15}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Sivas Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Yozgat Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Niğde Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karaman Usulü Kayısılı Tavuk Güveç', v_grup1_id, 1, 40,
        '["beyaz_et","etli_sebze"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "TAVUK BUT", "miktar_gram": 80}, {"ad": "KAYISI", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'İç Anadolu',
        '[{"ad": "BAMYA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Etli Karalahana', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KARALAHANA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Samsun Usulü Elmalı Tatlı', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "ELMA", "miktar_gram": 70}, {"ad": "ŞEKER", "miktar_gram": 25}, {"ad": "TARÇIN", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Zeytinyağlı Kereviz', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KEREVİZ", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Artvin Usulü Cevizli Bal Tatlısı', v_grup3_id, 1, 10,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "BAL", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bayburt Usulü Zeytinyağlı Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Tokat Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Erzurum Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Etli Nohutlu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Doğu Anadolu',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "ŞEKER", "miktar_gram": 20}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "KOYUN ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muş Usulü Zeytinyağlı Nohut', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Malatya Usulü Etli Kayısılı Bamya', v_grup1_id, 1, 45,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "BAMYA", "miktar_gram": 40}, {"ad": "KURU KAYISI", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Elazığ Usulü Zeytinyağlı Pırasa', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "PIRASA", "miktar_gram": 60}, {"ad": "HAVUÇ", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bitlis Usulü Etli Nohutlu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Nar Ekşili Etli Patlıcan', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "PATLICAN", "miktar_gram": 50}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Etli Bulgur Pilavı', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 50}, {"ad": "BULGUR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Zeytinyağlı Nohutlu Bamya', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "BAMYA", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Etli Kavurma', v_grup1_id, 1, 30,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Zeytinyağlı Patlıcan', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 60}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Nar Ekşili Zeytinyağlı Bulgur', v_grup2_id, 1, 30,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 40}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

end $$;

-- Dogrulama: her tarifin ADI + malzeme sayisi karsilastirmasi.
with beklenen(ad, beklenen_sayi) as (
  values
    ('İstanbul Usulü Zeytinyağlı Fırın Patates', 4),
    ('Bursa Usulü Nar Ekşili Kırmızı Lahana Salatası', 4),
    ('Kocaeli Usulü Zeytinyağlı Kabak Yemeği', 6),
    ('Tekirdağ Usulü Kirazlı Komposto', 3),
    ('Çanakkale Usulü Etli Enginar', 5),
    ('Balıkesir Usulü Zeytinyağlı Patates', 5),
    ('Marmara Usulü Vişne Ekşili Tavuk Sote', 5),
    ('İstanbul Usulü Zeytinyağlı Bezelye', 6),
    ('İzmir Usulü Etli Bamya', 6),
    ('Muğla Usulü Zeytinyağlı Kereviz', 6),
    ('Aydın Usulü İncirli Tavuk Sote', 5),
    ('Denizli Usulü Etli Nohutlu Kavurma', 5),
    ('Bodrum Usulü Izgara Levrek', 5),
    ('Foça Usulü Ahtapotlu Zeytinyağlı Salata', 5),
    ('Söke Usulü Zeytinyağlı Nohutlu Havuç', 5),
    ('Ege Usulü Ayvalı Ceviz Tatlısı', 3),
    ('Antalya Usulü Etli Kabak', 6),
    ('Mersin Usulü Zeytinyağlı Nohutlu Havuç', 5),
    ('Adana Usulü Izgara Tavuk Kanat', 5),
    ('Hatay Usulü Nar Ekşili Etli Bamya', 6),
    ('Kaş Usulü Zeytinyağlı Ahtapot Salatası', 4),
    ('Alanya Usulü Portakallı Zeytinyağlı Havuç', 5),
    ('Silifke Usulü Etli Nohutlu Yahni', 5),
    ('Kahramanmaraş Usulü Zeytinyağlı Patlıcan', 5),
    ('Ankara Usulü Zeytinyağlı Pırasa', 6),
    ('Konya Usulü Etli Kabak Yemeği', 6),
    ('Kayseri Usulü Elmalı Pekmezli Tatlı', 3),
    ('Sivas Usulü Zeytinyağlı Nohutlu Havuç', 5),
    ('Yozgat Usulü Etli Bulgur Pilavı', 5),
    ('Niğde Usulü Zeytinyağlı Kereviz', 6),
    ('Karaman Usulü Kayısılı Tavuk Güveç', 6),
    ('Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya', 6),
    ('Trabzon Usulü Etli Karalahana', 5),
    ('Rize Usulü Zeytinyağlı Pırasa', 6),
    ('Samsun Usulü Elmalı Tatlı', 3),
    ('Giresun Usulü Etli Kavurma', 4),
    ('Ordu Usulü Zeytinyağlı Kereviz', 6),
    ('Artvin Usulü Cevizli Bal Tatlısı', 2),
    ('Bayburt Usulü Zeytinyağlı Nohut', 5),
    ('Tokat Usulü Etli Kavurma', 4),
    ('Erzurum Usulü Zeytinyağlı Pırasa', 6),
    ('Van Usulü Etli Nohutlu Kavurma', 5),
    ('Kars Usulü Elmalı Ceviz Tatlısı', 3),
    ('Ağrı Usulü Etli Kavurma', 4),
    ('Muş Usulü Zeytinyağlı Nohut', 5),
    ('Malatya Usulü Etli Kayısılı Bamya', 6),
    ('Elazığ Usulü Zeytinyağlı Pırasa', 6),
    ('Bitlis Usulü Etli Nohutlu Kavurma', 5),
    ('Gaziantep Usulü Nar Ekşili Etli Patlıcan', 6),
    ('Şanlıurfa Usulü Etli Kavurma', 5),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç', 5),
    ('Mardin Usulü Etli Bulgur Pilavı', 5),
    ('Siirt Usulü Zeytinyağlı Nohutlu Bamya', 6),
    ('Batman Usulü Etli Kavurma', 4),
    ('Şırnak Usulü Zeytinyağlı Patlıcan', 5),
    ('Kilis Usulü Nar Ekşili Zeytinyağlı Bulgur', 6)
)
select b.ad, b.beklenen_sayi, count(rm.id) as db_sayisi,
       case when count(rm.id) = b.beklenen_sayi then 'YENI EKLENDI' else 'ONCEDEN VARDI (atlandi)' end as durum
from beklenen b
join receteler r on r.ad = b.ad and r.isletme_id is null
left join recete_malzemeleri rm on rm.recete_id = r.id
group by b.ad, b.beklenen_sayi
order by durum desc, b.ad;
