-- 92_cesitlilik_tarifleri_parti11.sql
--
-- 1000 hedefine devam. Ilk kez: dana pirzola, findik, badem, antep
-- fistigi, yulaf. Muhallebi/Kesku SIFIRDAN (sut+seker+nisasta ile)
-- kuruldu -- hazir malzeme olarak degil, gercek bilesenlerle, boylece
-- tek-malzemeli "sahte tarif" riskinden kacinildi. 16 tarif (Grup1: 5,
-- Grup2: 5, Grup3: 6). Besin degerleri yine hic yazilmiyor.

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
    values (null, 'Izgara Dana Pirzola', v_grup1, array['kirmizi_et','izgara'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA PİRZOLA', 1200), ('ZEYTİNYAĞI', 40), ('KEKİK', 5), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fındıklı Tavuk Sote (Karadeniz Usulü)', v_grup1, array['beyaz_et','etli_sebze'], 'yil_boyunca', 'Karadeniz', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK GÖĞÜS', 900), ('FINDIK (İÇ)', 150), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Sade Kuzu Güveç (Et Suyu ile)', v_grup1, array['kirmizi_et','etli_sebze'], 'kis', 'Genel', 10, 70)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU ETİ (BUT)', 1000), ('ET SUYU', 500), ('KURU SOĞAN', 200), ('HAVUÇ', 200), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bademli Fırın Tavuk But', v_grup1, array['beyaz_et'], 'yil_boyunca', 'Genel', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK BUT', 1200), ('BADEM (İÇ)', 100), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Antep Fıstıklı Kavurma', v_grup1, array['kirmizi_et'], 'yil_boyunca', 'Güneydoğu Anadolu', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA KIYMA', 800), ('ANTEP FISTIĞI', 100), ('KURU SOĞAN', 150), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yulaflı Çorba', v_grup2, array['corba','vejetaryen'], 'kis', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YULAF EZMESİ', 200), ('TEREYAĞI', 40), ('TAVUK SUYU', 1200), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bademli Pirinç Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 600), ('BADEM (İÇ)', 100), ('TEREYAĞI', 60), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Antep Fıstıklı Bulgur Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Güneydoğu Anadolu', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BULGUR', 600), ('ANTEP FISTIĞI', 100), ('TEREYAĞI', 60), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Et Suyu Çorbası (Sade)', v_grup2, array['corba'], 'yil_boyunca', 'Genel', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ET SUYU', 1500), ('PİRİNÇ (HAM)', 80), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kaşarlı Bulgur Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BULGUR', 600), ('KAŞAR PEYNİRİ', 200), ('TEREYAĞI', 50), ('TAVUK SUYU', 800), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Muhallebi (Ev Usulü)', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SÜT (TAM YAĞ)', 1500), ('ŞEKER', 200), ('PİRİNÇ UNU', 100)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Keşkül (Ev Usulü)', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SÜT (TAM YAĞ)', 1500), ('ŞEKER', 200), ('BADEM (İÇ)', 150), ('MISIR NİŞASTASI', 80)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Badem Ezmesi Tabağı', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BADEM (İÇ)', 400), ('ŞEKER', 200)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yeşil Salata (Cevizli)', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MARUL', 300), ('ROKA', 150), ('CEVİZ (İÇ)', 100), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 15), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yulaf Ezmeli Yoğurt', v_grup3, array['yogurt','vejetaryen'], 'yil_boyunca', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YULAF EZMESİ', 150), ('SÜZME YOĞURT', 700), ('BAL', 60)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kayısı Kompostosu (Ev Usulü)', v_grup3, array['komposto','vejetaryen'], 'kis', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KURU KAYISI', 500), ('ŞEKER', 100)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Izgara Dana Pirzola', 'Fındıklı Tavuk Sote (Karadeniz Usulü)', 'Sade Kuzu Güveç (Et Suyu ile)', 'Bademli Fırın Tavuk But', 'Antep Fıstıklı Kavurma',
    'Yulaflı Çorba', 'Bademli Pirinç Pilavı', 'Antep Fıstıklı Bulgur Pilavı', 'Et Suyu Çorbası (Sade)', 'Kaşarlı Bulgur Pilavı',
    'Muhallebi (Ev Usulü)', 'Keşkül (Ev Usulü)', 'Badem Ezmesi Tabağı', 'Yeşil Salata (Cevizli)', 'Yulaf Ezmeli Yoğurt', 'Kayısı Kompostosu (Ev Usulü)'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
