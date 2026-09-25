-- 146_yeni_56_tarif_7_bolge_parti2.sql
-- 1000 tarif hedefi, Parti 2: 56 yeni tarif, 7 bolgeye esit
-- dagitilmis (8 tarif). Ayni yapiyi kullanir (145'te tanimlanan
-- _yeni_tarif_ekle fonksiyonunu YENIDEN kullanir -- fonksiyon zaten
-- mevcutsa bu dosya sadece onu cagirir; degilse (145 hic
-- calistirilmamissa) create or replace ile burada da tanimlanir).
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
        'Tekirdağ Köftesi', v_grup1_id, 1, 30,
        '["izgara","kirmizi_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "DANA KIYMA", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "EKMEKLİK UN", "miktar_gram": 4}, {"ad": "KARBONAT (YEM. SODA)", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Çanakkale Peynir Helvası', v_grup3_id, 1, 35,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "LOR PEYNİRİ", "miktar_gram": 60}, {"ad": "EKMEKLİK UN", "miktar_gram": 30}, {"ad": "ŞEKER", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 15}, {"ad": "SÜT (TAM YAĞ)", "miktar_gram": 40}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Balıkesir Kaymaklı Kayısı Tatlısı', v_grup3_id, 1, 25,
        '["tatli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KAYISI", "miktar_gram": 80}, {"ad": "KAYMAK", "miktar_gram": 30}, {"ad": "ŞEKER", "miktar_gram": 15}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İstanbul Usulü Etli Kuru Fasulye', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'Marmara',
        '[{"ad": "KURU FASULYE", "miktar_gram": 60}, {"ad": "DANA KIYMA", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Kabak Mücveri', v_grup3_id, 1, 30,
        '["salata","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "KABAK", "miktar_gram": 80}, {"ad": "EKMEKLİK UN", "miktar_gram": 15}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 20}, {"ad": "MAYDANOZ", "miktar_gram": 3}, {"ad": "KARABİBER", "miktar_gram": 0.3}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "MISIR YAĞI", "miktar_gram": 30}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bandırma Usulü Tavuk Sote', v_grup1_id, 1, 35,
        '["beyaz_et"]'::jsonb, 'yil_boyunca', 'Marmara',
        '[{"ad": "TAVUK BUT", "miktar_gram": 100}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Fırında Lüfer', v_grup1_id, 1, 35,
        '["balik"]'::jsonb, 'sonbahar', 'Marmara',
        '[{"ad": "LÜFER", "miktar_gram": 150}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "LİMON SUYU", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KEKİK", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Marmara Usulü Vişneli Yoğurt Dondurması', v_grup3_id, 1, 20,
        '["tatli","vejetaryen"]'::jsonb, 'yaz', 'Marmara',
        '[{"ad": "YOĞURT (TAM)", "miktar_gram": 60}, {"ad": "VİŞNE", "miktar_gram": 30}, {"ad": "ŞEKER", "miktar_gram": 15}]'::jsonb
    );

    ---------------- Ege ----------------
    perform _yeni_tarif_ekle(
        'Kemalpaşa Köftesi', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "DANA KIYMA", "miktar_gram": 90}, {"ad": "EKMEKLİK UN", "miktar_gram": 6}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aydın İncirli Kuzu Tandır', v_grup1_id, 1, 100,
        '["kirmizi_et"]'::jsonb, 'sonbahar', 'Ege',
        '[{"ad": "KUZU TANDIR", "miktar_gram": 150}, {"ad": "KURU İNCİR", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Muğla Yeşil Erik Salatası', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "ERİK", "miktar_gram": 40}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Foça Usulü Kalamar Tava', v_grup1_id, 1, 25,
        '["balik"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "KALAMAR", "miktar_gram": 100}, {"ad": "EKMEKLİK UN", "miktar_gram": 20}, {"ad": "MISIR YAĞI", "miktar_gram": 30}, {"ad": "LİMON SUYU", "miktar_gram": 2.5}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Yeşil Zeytinli Havuç Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "HAVUÇ", "miktar_gram": 50}, {"ad": "YEŞİL ZEYTİN", "miktar_gram": 15}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İzmir Usulü Nohutlu Bamya', v_grup2_id, 1, 40,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yaz', 'Ege',
        '[{"ad": "BAMYA", "miktar_gram": 60}, {"ad": "NOHUT", "miktar_gram": 20}, {"ad": "DOMATES", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ege Zeytinyağlı Bakla ve Enginar', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'ilkbahar', 'Ege',
        '[{"ad": "BAKLA", "miktar_gram": 50}, {"ad": "ENGİNAR", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TAZE DEREOTU", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'İzmir Lokması', v_grup3_id, 1, 45,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'Ege',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 50}, {"ad": "KABARTMA TOZU", "miktar_gram": 1.5}, {"ad": "SU", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 40}, {"ad": "MISIR YAĞI", "miktar_gram": 40}]'::jsonb
    );

    ---------------- Akdeniz ----------------
    perform _yeni_tarif_ekle(
        'Antalya Usulü Etli Nohut Yemeği', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Nohutlu Bulgur Aşı', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "BULGUR", "miktar_gram": 50}, {"ad": "NOHUT", "miktar_gram": 25}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Hatay Usulü Tepsi Kebabı', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Akdeniz',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 90}, {"ad": "DOMATES", "miktar_gram": 25}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Adana Usulü Analı Kızlı Çorba', v_grup2_id, 1, 40,
        '["corba"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "BULGUR", "miktar_gram": 20}, {"ad": "DANA KIYMA", "miktar_gram": 30}, {"ad": "YOĞURT (TAM)", "miktar_gram": 40}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "KURU NANE", "miktar_gram": 0.5}, {"ad": "TEREYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Yeşil Erik Hoşafı', v_grup3_id, 1, 25,
        '["komposto","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "ERİK", "miktar_gram": 50}, {"ad": "ŞEKER", "miktar_gram": 15}, {"ad": "SU", "miktar_gram": 70}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mersin Usulü Portakallı Zeytin Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'kis', 'Akdeniz',
        '[{"ad": "YEŞİL ZEYTİN", "miktar_gram": 30}, {"ad": "PORTAKAL", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SUMAK", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Akdeniz Usulü Enginar Kalpli Salata', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'ilkbahar', 'Akdeniz',
        '[{"ad": "ENGİNAR KALBİ", "miktar_gram": 40}, {"ad": "ROKA", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Antalya Usulü Şeftalili Tavuk Sote', v_grup1_id, 1, 30,
        '["beyaz_et"]'::jsonb, 'yaz', 'Akdeniz',
        '[{"ad": "TAVUK GÖĞÜS", "miktar_gram": 90}, {"ad": "ŞEFTALİ", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );

    ---------------- İç Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Sivas Usulü Kes Kes', v_grup1_id, 1, 50,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "PATATES", "miktar_gram": 40}, {"ad": "ERİK", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kırşehir Usulü Nohutlu Yahni', v_grup1_id, 1, 45,
        '["kirmizi_et"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 80}, {"ad": "NOHUT", "miktar_gram": 30}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Aksaray Usulü Bulgurlu Köfte (Fırında)', v_grup1_id, 1, 40,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "BULGUR", "miktar_gram": 30}, {"ad": "DANA KIYMA", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "MAYDANOZ", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Nevşehir Üzümlü Kabak Tatlısı', v_grup3_id, 1, 35,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'İç Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 80}, {"ad": "ŞEKER", "miktar_gram": 30}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Konya Usulü Mercimekli Ekmek Aşı', v_grup2_id, 1, 25,
        '["corba"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "EKMEK (BEYAZ)", "miktar_gram": 30}, {"ad": "KIRMIZI MERCİMEK", "miktar_gram": 20}, {"ad": "TAVUK SUYU", "miktar_gram": 90}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ankara Usulü Zerde', v_grup3_id, 1, 30,
        '["tatli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 20}, {"ad": "ŞEKER", "miktar_gram": 40}, {"ad": "SAFRAN", "miktar_gram": 0.1}, {"ad": "SU", "miktar_gram": 120}, {"ad": "KUŞ ÜZÜMÜ", "miktar_gram": 5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Niğde Usulü Zeytinyağlı Nohut', v_grup2_id, 1, 35,
        '["zeytinyagli","vejetaryen"]'::jsonb, 'yil_boyunca', 'İç Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 4}, {"ad": "ŞEKER", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kapadokya Usulü Karışık Kış Turşusu', v_grup3_id, 1, 30,
        '["tursu","vejetaryen"]'::jsonb, 'kis', 'İç Anadolu',
        '[{"ad": "LAHANA", "miktar_gram": 40}, {"ad": "HAVUÇ", "miktar_gram": 20}, {"ad": "PATLICAN", "miktar_gram": 20}, {"ad": "SİRKE", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 4}, {"ad": "SARIMSAK", "miktar_gram": 1.5}]'::jsonb
    );

    ---------------- Karadeniz ----------------
    perform _yeni_tarif_ekle(
        'Samsun Usulü Kaşarlı Sucuklu Pide', v_grup2_id, 1, 45,
        '["pilav_makarna_borek"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 70}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 30}, {"ad": "SUCUK", "miktar_gram": 25}, {"ad": "TAVUK YUMURTASI", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ordu Usulü Fındıklı Pilav', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 60}, {"ad": "FINDIK (İÇ)", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TAVUK SUYU", "miktar_gram": 90}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Rize Usulü Mantar Kavurması (Etli)', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "MANTAR", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Giresun Usulü Fasulye Turşusu', v_grup3_id, 1, 25,
        '["tursu","vejetaryen"]'::jsonb, 'yil_boyunca', 'Karadeniz',
        '[{"ad": "TAZE FASULYE", "miktar_gram": 70}, {"ad": "SİRKE", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 4}, {"ad": "SARIMSAK", "miktar_gram": 2}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Trabzon Usulü Karalahana Sarması (Etli)', v_grup1_id, 1, 55,
        '["kirmizi_et","dolma"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KARALAHANA", "miktar_gram": 80}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 25}, {"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bayburt Usulü Kuru Fasulye Çorbası', v_grup2_id, 1, 35,
        '["corba","vejetaryen"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "KURU FASULYE", "miktar_gram": 40}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karadeniz Usulü Hamsi Buğulama', v_grup1_id, 1, 25,
        '["balik"]'::jsonb, 'kis', 'Karadeniz',
        '[{"ad": "HAMSİ", "miktar_gram": 120}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "MAYDANOZ", "miktar_gram": 2}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Karadeniz Usulü Elmalı Ceviz Tatlısı', v_grup3_id, 1, 35,
        '["tatli","vejetaryen"]'::jsonb, 'sonbahar', 'Karadeniz',
        '[{"ad": "ELMA", "miktar_gram": 60}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 15}, {"ad": "ŞEKER", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 4}]'::jsonb
    );

    ---------------- Doğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Muş Usulü Kuzu Haşlama', v_grup1_id, 1, 90,
        '["kirmizi_et"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (BUT)", "miktar_gram": 120}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1.2}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Ağrı Usulü Lorlu Kavurma (Etsiz)', v_grup3_id, 1, 20,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "LOR PEYNİRİ", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TEREYAĞI", "miktar_gram": 4}, {"ad": "PUL BİBER", "miktar_gram": 0.5}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kars Usulü Kaşarlı Kete', v_grup2_id, 1, 45,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "EKMEKLİK UN", "miktar_gram": 60}, {"ad": "KAŞAR PEYNİRİ", "miktar_gram": 40}, {"ad": "TEREYAĞI", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Bitlis Usulü Karışık Dolma (Etli)', v_grup1_id, 1, 50,
        '["kirmizi_et","dolma"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "KABAK", "miktar_gram": 50}, {"ad": "YEŞİL BİBER", "miktar_gram": 40}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 25}, {"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Iğdır Usulü Kayısılı Pilav', v_grup2_id, 1, 30,
        '["pilav","vejetaryen"]'::jsonb, 'yaz', 'Doğu Anadolu',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "KURU KAYISI", "miktar_gram": 20}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TAVUK SUYU", "miktar_gram": 90}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Erzincan Usulü Tulumlu Makarna', v_grup2_id, 1, 25,
        '["pilav_makarna_borek","vejetaryen"]'::jsonb, 'yil_boyunca', 'Doğu Anadolu',
        '[{"ad": "MAKARNA", "miktar_gram": 70}, {"ad": "TULUM PEYNİRİ", "miktar_gram": 30}, {"ad": "TEREYAĞI", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Van Usulü Pazılı Kavurma (Etli)', v_grup1_id, 1, 35,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 70}, {"ad": "PAZI", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Doğu Anadolu Cevizli Kayısı Kurusu Tatlısı', v_grup3_id, 1, 15,
        '["tatli","vejetaryen"]'::jsonb, 'kis', 'Doğu Anadolu',
        '[{"ad": "KURU KAYISI", "miktar_gram": 40}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 15}, {"ad": "BAL", "miktar_gram": 10}]'::jsonb
    );

    ---------------- Güneydoğu Anadolu ----------------
    perform _yeni_tarif_ekle(
        'Gaziantep Usulü Fıstıklı Kebap', v_grup1_id, 1, 35,
        '["izgara","kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU KIYMA", "miktar_gram": 90}, {"ad": "ANTEP FISTIĞI", "miktar_gram": 10}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şanlıurfa Usulü Patlıcan Kebabı', v_grup1_id, 1, 40,
        '["kirmizi_et","etli_sebze"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "PATLICAN", "miktar_gram": 70}, {"ad": "KUZU KIYMA", "miktar_gram": 70}, {"ad": "KURU SOĞAN", "miktar_gram": 15}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Diyarbakır Usulü Cevizli Biber Salatası', v_grup3_id, 1, 15,
        '["salata","vejetaryen"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "YEŞİL BİBER", "miktar_gram": 40}, {"ad": "CEVİZ (İÇ)", "miktar_gram": 10}, {"ad": "SARIMSAK", "miktar_gram": 1.5}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Mardin Usulü Susamlı Marul Salatası', v_grup3_id, 1, 10,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "MARUL", "miktar_gram": 30}, {"ad": "SUSAM", "miktar_gram": 3}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "NAR EKŞİSİ", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.5}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Siirt Usulü Perde Pilavı', v_grup2_id, 1, 60,
        '["pilav"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "PİRİNÇ (HAM)", "miktar_gram": 50}, {"ad": "TAVUK GÖĞÜS", "miktar_gram": 50}, {"ad": "YUFKA", "miktar_gram": 20}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TAVUK SUYU", "miktar_gram": 80}, {"ad": "ANTEP FISTIĞI", "miktar_gram": 4}, {"ad": "TEREYAĞI", "miktar_gram": 6}, {"ad": "TUZ", "miktar_gram": 1}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Batman Usulü Etli Yaprak Sarma', v_grup1_id, 1, 60,
        '["kirmizi_et","dolma"]'::jsonb, 'yaz', 'Güneydoğu Anadolu',
        '[{"ad": "SALAMURA YAPRAK", "miktar_gram": 40}, {"ad": "PİRİNÇ (HAM)", "miktar_gram": 20}, {"ad": "DANA KIYMA", "miktar_gram": 50}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "LİMON SUYU", "miktar_gram": 2}, {"ad": "TUZ", "miktar_gram": 0.8}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Şırnak Usulü Kuzu Kavurma', v_grup1_id, 1, 35,
        '["kirmizi_et"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "KUZU ETİ (KOL)", "miktar_gram": 90}, {"ad": "KURU SOĞAN", "miktar_gram": 10}, {"ad": "TUZ", "miktar_gram": 1}, {"ad": "KARABİBER", "miktar_gram": 0.3}]'::jsonb
    );
    perform _yeni_tarif_ekle(
        'Kilis Usulü Zeytinyağlı Nohutlu Salata', v_grup3_id, 1, 20,
        '["salata","vejetaryen"]'::jsonb, 'yil_boyunca', 'Güneydoğu Anadolu',
        '[{"ad": "NOHUT", "miktar_gram": 50}, {"ad": "DOMATES", "miktar_gram": 20}, {"ad": "YEŞİL BİBER", "miktar_gram": 15}, {"ad": "ZEYTİNYAĞI", "miktar_gram": 3}, {"ad": "SUMAK", "miktar_gram": 0.5}, {"ad": "TUZ", "miktar_gram": 0.8}]'::jsonb
    );

end $$;

-- Dogrulama 1: Parti 2'deki 56 tarifin ADI + malzeme sayisi -- bu,
-- onceden var olup ATLANMIS olanlari (varsa) tespit eder (isim ayni
-- ama malzeme sayisi farkli olan satirlar = onceden vardi, atlandi).
with beklenen(ad, beklenen_sayi) as (
  values
    ('Tekirdağ Köftesi', 6),
    ('Çanakkale Peynir Helvası', 5),
    ('Balıkesir Kaymaklı Kayısı Tatlısı', 3),
    ('İstanbul Usulü Etli Kuru Fasulye', 6),
    ('Marmara Usulü Kabak Mücveri', 7),
    ('Bandırma Usulü Tavuk Sote', 6),
    ('Marmara Usulü Fırında Lüfer', 5),
    ('Marmara Usulü Vişneli Yoğurt Dondurması', 3),
    ('Kemalpaşa Köftesi', 5),
    ('Aydın İncirli Kuzu Tandır', 5),
    ('Muğla Yeşil Erik Salatası', 3),
    ('Foça Usulü Kalamar Tava', 5),
    ('Ege Yeşil Zeytinli Havuç Salatası', 5),
    ('İzmir Usulü Nohutlu Bamya', 7),
    ('Ege Zeytinyağlı Bakla ve Enginar', 7),
    ('İzmir Lokması', 5),
    ('Antalya Usulü Etli Nohut Yemeği', 6),
    ('Mersin Usulü Nohutlu Bulgur Aşı', 6),
    ('Hatay Usulü Tepsi Kebabı', 6),
    ('Adana Usulü Analı Kızlı Çorba', 7),
    ('Antalya Yeşil Erik Hoşafı', 3),
    ('Mersin Usulü Portakallı Zeytin Salatası', 5),
    ('Akdeniz Usulü Enginar Kalpli Salata', 5),
    ('Antalya Usulü Şeftalili Tavuk Sote', 6),
    ('Sivas Usulü Kes Kes', 6),
    ('Kırşehir Usulü Nohutlu Yahni', 5),
    ('Aksaray Usulü Bulgurlu Köfte (Fırında)', 6),
    ('Nevşehir Üzümlü Kabak Tatlısı', 3),
    ('Konya Usulü Mercimekli Ekmek Aşı', 6),
    ('Ankara Usulü Zerde', 5),
    ('Niğde Usulü Zeytinyağlı Nohut', 6),
    ('Kapadokya Usulü Karışık Kış Turşusu', 6),
    ('Samsun Usulü Kaşarlı Sucuklu Pide', 6),
    ('Ordu Usulü Fındıklı Pilav', 5),
    ('Rize Usulü Mantar Kavurması (Etli)', 6),
    ('Giresun Usulü Fasulye Turşusu', 4),
    ('Trabzon Usulü Karalahana Sarması (Etli)', 6),
    ('Bayburt Usulü Kuru Fasulye Çorbası', 4),
    ('Karadeniz Usulü Hamsi Buğulama', 5),
    ('Karadeniz Usulü Elmalı Ceviz Tatlısı', 4),
    ('Muş Usulü Kuzu Haşlama', 4),
    ('Ağrı Usulü Lorlu Kavurma (Etsiz)', 6),
    ('Kars Usulü Kaşarlı Kete', 4),
    ('Bitlis Usulü Karışık Dolma (Etli)', 7),
    ('Iğdır Usulü Kayısılı Pilav', 5),
    ('Erzincan Usulü Tulumlu Makarna', 4),
    ('Van Usulü Pazılı Kavurma (Etli)', 5),
    ('Doğu Anadolu Cevizli Kayısı Kurusu Tatlısı', 3),
    ('Gaziantep Usulü Fıstıklı Kebap', 5),
    ('Şanlıurfa Usulü Patlıcan Kebabı', 6),
    ('Diyarbakır Usulü Cevizli Biber Salatası', 6),
    ('Mardin Usulü Susamlı Marul Salatası', 5),
    ('Siirt Usulü Perde Pilavı', 8),
    ('Batman Usulü Etli Yaprak Sarma', 7),
    ('Şırnak Usulü Kuzu Kavurma', 4),
    ('Kilis Usulü Zeytinyağlı Nohutlu Salata', 6)
)
select b.ad, b.beklenen_sayi, count(rm.id) as db_sayisi,
       case when count(rm.id) = b.beklenen_sayi then 'YENI EKLENDI' else 'ONCEDEN VARDI (atlandi)' end as durum
from beklenen b
join receteler r on r.ad = b.ad and r.isletme_id is null
left join recete_malzemeleri rm on rm.recete_id = r.id
group by b.ad, b.beklenen_sayi
order by durum desc, b.ad;
