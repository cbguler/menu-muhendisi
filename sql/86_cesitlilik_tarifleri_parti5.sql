-- 86_cesitlilik_tarifleri_parti5.sql
--
-- 1000 tarif hedefine dogru devam. 16 tarif (Grup1: 5, Grup2: 5, Grup3: 6)
-- -- ilk kez "sporcu_uygun" etiketi kullanildi (Izgara Bonfile, Brokolili
-- Tavuk Sote). Besin degerleri yine hic yazilmiyor.
--
-- NOT: "ÜzÜM PEKMEZİ" (ortasinda kucuk 'z') malzeme tablosundaki GERCEK
-- (muhtemelen eski bir veri girisi hatasindan kaynaklanan) yazim -- SQL'de
-- BIREBIR bu sekilde kullanildi, JOIN'in calismasi icin. (Bahri'ye ayrica
-- not: bu, malzeme tablosunda kucuk bir veri kalitesi sorunu, istersen
-- ayrica duzeltebiliriz.)

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
    values (null, 'Izgara Kuzu Pirzola', v_grup1, array['kirmizi_et','izgara'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU PİRZOLA', 1200), ('ZEYTİNYAĞI', 40), ('KEKİK', 5), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Sığır Bonfile', v_grup1, array['kirmizi_et','izgara','sporcu_uygun'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SIĞIR BONFİLE', 1200), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Tavuk Kanat', v_grup1, array['beyaz_et'], 'yil_boyunca', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK KANAT', 1300), ('ZEYTİNYAĞI', 50), ('SARIMSAK', 20), ('PUL BİBER', 5), ('TUZ', 12)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Brokolili Tavuk Sote (Sporcu)', v_grup1, array['beyaz_et','etli_sebze','sporcu_uygun'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK GÖĞÜS', 900), ('BROKOLİ', 500), ('SARIMSAK', 15), ('ZEYTİNYAĞI', 40), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Bütün Tavuk (Ev Usulü)', v_grup1, array['beyaz_et'], 'yil_boyunca', 'Genel', 10, 90)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK BÜTÜN', 1800), ('ZEYTİNYAĞI', 50), ('KEKİK', 5), ('LİMON', 100), ('TUZ', 15), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Brokoli Çorbası (Ev Usulü)', v_grup2, array['corba','vejetaryen','sporcu_uygun'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BROKOLİ', 800), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yayla Çorbası (Ev Usulü)', v_grup2, array['corba','vejetaryen'], 'yil_boyunca', 'İç Anadolu', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 150), ('YOĞURT (TAM)', 600), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TAZE NANE', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Şehriyeli Bulgur Pilavı (Ev Usulü)', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BULGUR', 600), ('ŞEHRİYE', 100), ('TEREYAĞI', 70), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)', v_grup2, array['zeytinyagli','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Ege', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BARBUNYA', 700), ('HAVUÇ', 150), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 70), ('DOMATES', 150), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'İrmik Çorbası (Ev Usulü)', v_grup2, array['corba','vejetaryen'], 'yil_boyunca', 'Genel', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('İRMİK', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1500), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kadayıflı Süt Tatlısı', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KADAYIF', 400), ('SÜT (TAM YAĞ)', 1500), ('ŞEKER', 300)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Muzlu Yoğurt (Ev Usulü)', v_grup3, array['yogurt','vejetaryen'], 'yil_boyunca', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MUZ', 500), ('SÜZME YOĞURT', 800), ('ŞEKER', 30)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Tahin Pekmez (Klasik)', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 5)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAHİN', 300), ('ÜzÜM PEKMEZİ', 400)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ayran (Ev Usulü)', v_grup3, array['yogurt','vejetaryen'], 'yaz', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YOĞURT (TAM)', 600), ('SÜT (TAM YAĞ)', 400), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Muzlu Meyve Salatası', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MUZ', 400), ('ELMA', 300), ('PORTAKAL', 300), ('ŞEKER', 20)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karnabahar Turşusu', v_grup3, array['tursu','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KARNABAHAR', 700), ('HAVUÇ', 150), ('SARIMSAK', 15), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Izgara Kuzu Pirzola', 'Izgara Sığır Bonfile', 'Fırında Tavuk Kanat',
    'Brokolili Tavuk Sote (Sporcu)', 'Fırında Bütün Tavuk (Ev Usulü)',
    'Brokoli Çorbası (Ev Usulü)', 'Yayla Çorbası (Ev Usulü)', 'Şehriyeli Bulgur Pilavı (Ev Usulü)',
    'Zeytinyağlı Barbunya Pilaki (Ev Usulü)', 'İrmik Çorbası (Ev Usulü)',
    'Kadayıflı Süt Tatlısı', 'Muzlu Yoğurt (Ev Usulü)', 'Tahin Pekmez (Klasik)',
    'Ayran (Ev Usulü)', 'Muzlu Meyve Salatası', 'Karnabahar Turşusu'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
