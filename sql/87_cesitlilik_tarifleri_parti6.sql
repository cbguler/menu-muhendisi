-- 87_cesitlilik_tarifleri_parti6.sql
--
-- 1000 tarif hedefine dogru devam. Bahri'nin haklı uyarisi uzerine
-- ("Ayran/Ev Yapimi Ayran/Yayik Ayrani ayni seyse bu uc kagitcilik") --
-- bu partide ozellikle GERCEKTEN birbirinden FARKLI yemek KATEGORILERI
-- secildi (deniz urunleri -- ilk kez KARIDES/KALAMAR/MIDYE/AHTAPOT,
-- patates/tere salatalari, karisik tursu) -- kozmetik isim varyasyonu
-- DEGIL, gercek mutfak cesitliligi. 16 tarif (Grup1: 5, Grup2: 5,
-- Grup3: 6). Besin degerleri yine hic yazilmiyor.

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

    -- GRUP 1 (5) -- ilk kez KARIDES/KALAMAR/MIDYE/AHTAPOT
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karides Güveç (Ege Usulü)', v_grup1, array['balik'], 'yil_boyunca', 'Ege', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KARİDES', 900), ('DOMATES', 250), ('KURU SOĞAN', 150), ('SARIMSAK', 15), ('ZEYTİNYAĞI', 40), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Kalamar', v_grup1, array['balik','izgara'], 'yil_boyunca', 'Ege', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KALAMAR', 1000), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 30), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Midye Dolma (Pilavlı)', v_grup1, array['balik','dolma'], 'yil_boyunca', 'Marmara', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MİDYE', 1000), ('PİRİNÇ (HAM)', 300), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Ahtapot', v_grup1, array['balik','izgara'], 'yil_boyunca', 'Ege', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('AHTAPOT', 1200), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 30), ('KEKİK', 5), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Patatesli Kıyma', v_grup1, array['kirmizi_et','etli_sebze'], 'yil_boyunca', 'Genel', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA KIYMA', 800), ('PATATES', 900), ('KURU SOĞAN', 200), ('DOMATES', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Patatesli Sebze Çorbası', v_grup2, array['corba','vejetaryen'], 'yil_boyunca', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PATATES', 500), ('HAVUÇ', 200), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Taze Fasulye (Ev Usulü)', v_grup2, array['zeytinyagli','vejetaryen'], 'yaz', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAZE FASULYE', 1000), ('DOMATES', 250), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 70), ('ŞEKER', 12), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karidesli Makarna', v_grup2, array['pilav_makarna_borek','balik'], 'yil_boyunca', 'Ege', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MAKARNA', 700), ('KARİDES', 400), ('SARIMSAK', 20), ('ZEYTİNYAĞI', 50), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Mercimekli Bulgur Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BULGUR', 500), ('YEŞİL MERCİMEK', 250), ('KURU SOĞAN', 150), ('TEREYAĞI', 60), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Humus (Ev Usulü)', v_grup2, array['zeytinyagli','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Güneydoğu Anadolu', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HUMUS', 800), ('ZEYTİNYAĞI', 40), ('MAYDANOZ', 30), ('LİMON SUYU', 20)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Tereli Yoğurt Salatası', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TERE', 300), ('YOĞURT (TAM)', 400), ('SARIMSAK', 10), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Maydanozlu Bulgur Salatası (Kısır)', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Güneydoğu Anadolu', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('İNCE BULGUR', 400), ('MAYDANOZ', 150), ('DOMATES', 200), ('LİMON SUYU', 30), ('ZEYTİNYAĞI', 40), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ahtapot Salatası (Soğuk)', v_grup3, array['salata'], 'yaz', 'Ege', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('AHTAPOT', 600), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 25), ('MAYDANOZ', 20), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Patates Salatası (Yoğurtlu)', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PATATES', 800), ('YOĞURT (TAM)', 200), ('MAYDANOZ', 20), ('ZEYTİNYAĞI', 30), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karışık Turşu (Ev Usulü, Sirkeli)', v_grup3, array['tursu','vejetaryen'], 'kis', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('LAHANA', 400), ('HAVUÇ', 200), ('SALATALIK', 200), ('SARIMSAK', 15), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Portakal Kompostosu (Ev Usulü)', v_grup3, array['komposto','vejetaryen'], 'kis', 'Akdeniz', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PORTAKAL', 800), ('ŞEKER', 150)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Karides Güveç (Ege Usulü)', 'Izgara Kalamar', 'Midye Dolma (Pilavlı)', 'Izgara Ahtapot', 'Fırında Patatesli Kıyma',
    'Patatesli Sebze Çorbası', 'Zeytinyağlı Taze Fasulye (Ev Usulü)', 'Karidesli Makarna',
    'Mercimekli Bulgur Pilavı', 'Humus (Ev Usulü)',
    'Tereli Yoğurt Salatası', 'Maydanozlu Bulgur Salatası (Kısır)', 'Ahtapot Salatası (Soğuk)',
    'Patates Salatası (Yoğurtlu)', 'Karışık Turşu (Ev Usulü, Sirkeli)', 'Portakal Kompostosu (Ev Usulü)'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
