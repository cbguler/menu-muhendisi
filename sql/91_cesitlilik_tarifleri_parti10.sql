-- 91_cesitlilik_tarifleri_parti10.sql
--
-- 1000 hedefine devam. Ilk kez tarhana kullanildi. 16 tarif (Grup1: 5,
-- Grup2: 5, Grup3: 6), hepsi kavramsal olarak birbirinden farkli.
-- Besin degerleri yine hic yazilmiyor.

do $$
declare
    v_grup1 uuid;
    v_grup2 uuid;
    v_grup3 uuid;
    v_recete_id uuid;
begin
    select mk.id into v_grup1 from mutfak_kategorileri mk join mutfaklar m on m.id = mk.mutfak_id where m.kod = 'turk' and mk.sira = 1;
    select mk.id into v_grup2 from mutfak_kategorileri mk join mutfaklar m on m.id = mk.mutfak_id where m.kod = 'turk' and mk.sira = 2;
    select mk.id into v_grup3 from mutfak_kategorileri mk join mutfaklar m on m.id = mk.mutfak_id where m.kod = 'turk' and mk.sira = 3;

    -- GRUP 1 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bezelyeli Kuzu Yemeği', v_grup1, array['kirmizi_et','etli_sebze'], 'ilkbahar', 'Genel', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU ETİ (KOL)', 900), ('BEZELYE', 500), ('KURU SOĞAN', 150), ('DOMATES', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Roka Soslu Izgara Tavuk', v_grup1, array['beyaz_et','izgara'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK GÖĞÜS', 1000), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 25), ('SARIMSAK', 15), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kuşkonmazlı Dana Bonfile', v_grup1, array['kirmizi_et','etli_sebze'], 'ilkbahar', 'Marmara', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA BONFİLE', 900), ('KUŞKONMAZ', 500), ('ZEYTİNYAĞI', 40), ('SARIMSAK', 15), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Somon Sebzeli', v_grup1, array['balik'], 'yil_boyunca', 'Marmara', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SOMON', 1000), ('KABAK', 400), ('HAVUÇ', 200), ('ZEYTİNYAĞI', 40), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Patlıcanlı Kıyma Musakka', v_grup1, array['kirmizi_et','etli_sebze'], 'yaz', 'Genel', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA KIYMA', 800), ('PATLICAN', 900), ('KURU SOĞAN', 150), ('DOMATES', 200), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Tarhana Çorbası (Ev Usulü)', v_grup2, array['corba','vejetaryen'], 'kis', 'İç Anadolu', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TARHANA', 200), ('TEREYAĞI', 50), ('TAVUK SUYU', 1500), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Konserve Bezelyeli Makarna', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MAKARNA', 700), ('KONSERVE BEZELYE', 300), ('TEREYAĞI', 50), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Roka Soslu Makarna', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MAKARNA', 700), ('ROKA', 200), ('ZEYTİNYAĞI', 50), ('SARIMSAK', 15), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kuşkonmaz Çorbası', v_grup2, array['corba','vejetaryen'], 'ilkbahar', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUŞKONMAZ', 600), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Tavuk Suyu Çorbası (Sade)', v_grup2, array['corba'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK SUYU', 1500), ('PİRİNÇ (HAM)', 100), ('TAVUK YUMURTASI', 100), ('LİMON SUYU', 20), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Rokalı Domates Salatası', v_grup3, array['salata','vejetaryen'], 'yaz', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ROKA', 250), ('DOMATES', 400), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 15), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Haşlanmış Yumurta Salatası', v_grup3, array['salata','vejetaryen','yumurta'], 'yil_boyunca', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK YUMURTASI', 500), ('MARUL', 200), ('ZEYTİNYAĞI', 25), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Patlıcan Salatası (Közlenmiş)', v_grup3, array['salata','vejetaryen'], 'yaz', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PATLICAN', 700), ('SARIMSAK', 15), ('YOĞURT (TAM)', 300), ('ZEYTİNYAĞI', 30), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ispanaklı Cacık', v_grup3, array['cacik','vejetaryen'], 'kis', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ISPANAK', 300), ('YOĞURT (TAM)', 500), ('SARIMSAK', 12), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Patlıcan Turşusu', v_grup3, array['tursu','vejetaryen'], 'yaz', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PATLICAN', 700), ('SARIMSAK', 20), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karışık Meyve Kompostosu', v_grup3, array['komposto','vejetaryen'], 'sonbahar', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ELMA', 400), ('ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)', 400), ('ŞEKER', 130)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Bezelyeli Kuzu Yemeği', 'Roka Soslu Izgara Tavuk', 'Kuşkonmazlı Dana Bonfile', 'Fırında Somon Sebzeli', 'Patlıcanlı Kıyma Musakka',
    'Tarhana Çorbası (Ev Usulü)', 'Konserve Bezelyeli Makarna', 'Roka Soslu Makarna', 'Kuşkonmaz Çorbası', 'Tavuk Suyu Çorbası (Sade)',
    'Rokalı Domates Salatası', 'Haşlanmış Yumurta Salatası', 'Patlıcan Salatası (Közlenmiş)', 'Ispanaklı Cacık', 'Patlıcan Turşusu', 'Karışık Meyve Kompostosu'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
