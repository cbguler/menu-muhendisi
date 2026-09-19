-- 98_cesitlilik_tarifleri_parti14.sql
--
-- 1000 hedefine devam. Bu parti "dolma" cesitliligine odaklaniyor --
-- domates/lahana/kabak/biber/enginar, hem ETLI (Grup1) hem
-- ZEYTINYAGLI/vejetaryen (Grup2) versiyonlari ile -- her cift
-- KAVRAMSAL olarak GERCEKTEN farkli (farkli sebze VEYA farkli
-- hazirlik yontemi). 16 tarif (Grup1: 5, Grup2: 5, Grup3: 6). Besin
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

    -- GRUP 1 (5) -- ETLI dolmalar
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Domates Dolması (Etli)', v_grup1, array['kirmizi_et','dolma'], 'yaz', 'Genel', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DOMATES', 1200), ('DANA KIYMA', 500), ('PİRİNÇ (HAM)', 200), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 30), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Lahana Dolması (Etli)', v_grup1, array['kirmizi_et','dolma'], 'kis', 'Genel', 10, 70)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('LAHANA', 1000), ('DANA KIYMA', 600), ('PİRİNÇ (HAM)', 200), ('KURU SOĞAN', 150), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kabak Dolması (Etli)', v_grup1, array['kirmizi_et','dolma'], 'yaz', 'Genel', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KABAK', 1200), ('DANA KIYMA', 500), ('PİRİNÇ (HAM)', 150), ('KURU SOĞAN', 150), ('YOĞURT (TAM)', 300), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Biber Dolması (Etli)', v_grup1, array['kirmizi_et','dolma'], 'yaz', 'Genel', 10, 65)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIRMIZI BİBER', 1200), ('DANA KIYMA', 600), ('PİRİNÇ (HAM)', 200), ('KURU SOĞAN', 150), ('DOMATES', 100), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginar Dolması (Etli)', v_grup1, array['kirmizi_et','dolma','etli_sebze'], 'ilkbahar', 'Ege', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ENGİNAR', 1000), ('DANA KIYMA', 500), ('PİRİNÇ (HAM)', 150), ('KURU SOĞAN', 100), ('LİMON SUYU', 30), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5) -- ZEYTINYAGLI/vejetaryen dolmalar + iki farkli tarif
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Kabak Dolması', v_grup2, array['zeytinyagli','dolma','vejetaryen'], 'yaz', 'Ege', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KABAK', 1200), ('PİRİNÇ (HAM)', 300), ('KURU SOĞAN', 200), ('ZEYTİNYAĞI', 60), ('ŞEKER', 15), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Lahana Dolması', v_grup2, array['zeytinyagli','dolma','vejetaryen'], 'kis', 'Ege', 10, 65)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('LAHANA', 1000), ('PİRİNÇ (HAM)', 350), ('KURU SOĞAN', 200), ('ZEYTİNYAĞI', 70), ('ŞEKER', 15), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Domates Dolması', v_grup2, array['zeytinyagli','dolma','vejetaryen'], 'yaz', 'Ege', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DOMATES', 1200), ('PİRİNÇ (HAM)', 300), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 60), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Peynirli Kabak Böreği', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yaz', 'Genel', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YUFKA', 500), ('KABAK', 400), ('FETA PEYNİRİ', 250), ('TAVUK YUMURTASI', 100), ('TEREYAĞI', 80), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kabak Çorbası', v_grup2, array['corba','vejetaryen'], 'yaz', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KABAK', 700), ('KURU SOĞAN', 150), ('TEREYAĞI', 40), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Lahana Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('LAHANA', 500), ('HAVUÇ', 150), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 20), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kabaklı Yoğurt Salatası', v_grup3, array['salata','vejetaryen'], 'yaz', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KABAK', 400), ('YOĞURT (TAM)', 400), ('SARIMSAK', 12), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginar Salatası', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Ege', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ENGİNAR', 500), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 25), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Domates Turşusu', v_grup3, array['tursu','vejetaryen'], 'yaz', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DOMATES', 700), ('SARIMSAK', 15), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kabak Turşusu', v_grup3, array['tursu','vejetaryen'], 'yaz', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KABAK', 700), ('SARIMSAK', 15), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginarlı Yoğurt', v_grup3, array['yogurt','vejetaryen'], 'ilkbahar', 'Genel', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ENGİNAR', 400), ('YOĞURT (TAM)', 500), ('SARIMSAK', 12), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Domates Dolması (Etli)', 'Lahana Dolması (Etli)', 'Kabak Dolması (Etli)', 'Biber Dolması (Etli)', 'Enginar Dolması (Etli)',
    'Zeytinyağlı Kabak Dolması', 'Zeytinyağlı Lahana Dolması', 'Zeytinyağlı Domates Dolması', 'Peynirli Kabak Böreği', 'Kabak Çorbası',
    'Lahana Salatası', 'Kabaklı Yoğurt Salatası', 'Enginar Salatası', 'Domates Turşusu', 'Kabak Turşusu', 'Enginarlı Yoğurt'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
