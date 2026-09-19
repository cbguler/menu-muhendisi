-- 96_cesitlilik_tarifleri_parti12.sql
--
-- 1000 hedefine devam. Ilk kez: sakatat (dana bobrek/beyin/iskembe),
-- soya kiyma (etsiz kiyma alternatifi). 16 tarif (Grup1: 5, Grup2: 5,
-- Grup3: 6), hepsi kavramsal olarak birbirinden farkli. Besin
-- degerleri yine hic yazilmiyor.

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
    values (null, 'Izgara Dana Böbrek', v_grup1, array['kirmizi_et','izgara'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YENİLEBİLİR SAKATAT (DANA BÖBREK)', 1000), ('ZEYTİNYAĞI', 40), ('KEKİK', 5), ('TUZ', 12)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Soyalı Biberli Sote (Etsiz)', v_grup1, array['vejetaryen','etli_sebze'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SOYA KIYMA', 500), ('KIRMIZI BİBER', 300), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Soya Kıymalı Patlıcan Musakka (Etsiz)', v_grup1, array['vejetaryen','etli_sebze'], 'yaz', 'Genel', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SOYA KIYMA', 500), ('PATLICAN', 800), ('KURU SOĞAN', 150), ('DOMATES', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Dana Beyin', v_grup1, array['kirmizi_et'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YENİLEBİLİR SAKATAT (DANA BEYİN)', 900), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 20), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kuzu Etli Kırmızı Mercimek Yemeği', v_grup1, array['kirmizi_et','etli_sebze','kuru_baklagil'], 'kis', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU ETİ (KOL)', 700), ('KIRMIZI MERCİMEK', 400), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 30), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'İşkembe Çorbası', v_grup2, array['corba'], 'kis', 'Genel', 10, 90)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YENİLEBİLİR SAKATAT (DANA İŞKEMBE)', 700), ('SARIMSAK', 20), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Soya Kıymalı Zeytinyağlı Dolma', v_grup2, array['zeytinyagli','dolma','vejetaryen'], 'yaz', 'Genel', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SOYA KIYMA', 400), ('PİRİNÇ (HAM)', 300), ('KIRMIZI BİBER', 600), ('ZEYTİNYAĞI', 60), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kırmızı Mercimekli Pilav', v_grup2, array['pilav_makarna_borek','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 500), ('KIRMIZI MERCİMEK', 300), ('KURU SOĞAN', 150), ('TEREYAĞI', 60), ('TAVUK SUYU', 800), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Soya Fasulyesi', v_grup2, array['zeytinyagli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SOYA FASULYESİ', 600), ('DOMATES', 200), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 50), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Kuru Fasulye (Soğuk)', v_grup2, array['zeytinyagli','vejetaryen'], 'yaz', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KURU FASULYE', 700), ('DOMATES', 200), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 60), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Mercimek Köftesi (Ev Usulü)', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Güneydoğu Anadolu', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIRMIZI MERCİMEK', 300), ('İNCE BULGUR', 300), ('KURU SOĞAN', 100), ('DOMATES', 100), ('MAYDANOZ', 30), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 20), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yeşil Mercimekli Salata', v_grup3, array['salata','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YEŞİL MERCİMEK', 400), ('KURU SOĞAN', 80), ('MAYDANOZ', 20), ('LİMON SUYU', 20), ('ZEYTİNYAĞI', 30), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Elma Kompostosu (Ev Usulü)', v_grup3, array['komposto','vejetaryen'], 'sonbahar', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ELMA', 800), ('ŞEKER', 130)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Domatesli Cacık', v_grup3, array['cacik','vejetaryen'], 'yaz', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SALATALIK', 400), ('DOMATES', 200), ('YOĞURT (TAM)', 700), ('SARIMSAK', 12), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Havuç Turşusu', v_grup3, array['tursu','vejetaryen'], 'kis', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HAVUÇ', 800), ('SARIMSAK', 15), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Cevizli Pekmez', v_grup3, array['tatli','vejetaryen'], 'sonbahar', 'Genel', 10, 5)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('CEVİZ (İÇ)', 200), ('ÜzÜM PEKMEZİ', 400)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Izgara Dana Böbrek', 'Soyalı Biberli Sote (Etsiz)', 'Soya Kıymalı Patlıcan Musakka (Etsiz)', 'Fırında Dana Beyin', 'Kuzu Etli Kırmızı Mercimek Yemeği',
    'İşkembe Çorbası', 'Soya Kıymalı Zeytinyağlı Dolma', 'Kırmızı Mercimekli Pilav', 'Zeytinyağlı Soya Fasulyesi', 'Zeytinyağlı Kuru Fasulye (Soğuk)',
    'Mercimek Köftesi (Ev Usulü)', 'Yeşil Mercimekli Salata', 'Elma Kompostosu (Ev Usulü)', 'Domatesli Cacık', 'Havuç Turşusu', 'Cevizli Pekmez'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
