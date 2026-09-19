-- 84_yaz_sonbahar_kis_tarifleri.sql
--
-- Bahri'nin talebi: 1000 tarif hedefine dogru devam. Ilkbahar partisi
-- (81+83) sonrasi en zayif nokta artik Grup 2 - Yaz (10, tablodaki EN
-- DUSUK tek hucre). Bu parti ONCELIKLE oraya (6 tarif), ayrica Grup 2
-- Sonbahar (11, 3 tarif) ve Grup 3 Kis (11, 3 tarif) icin de takviye
-- ekliyor -- toplam 12 tarif.
--
-- Isimler yine AYIRT EDICI secildi (mevsim ibaresi eklenerek) --
-- carpisma riskini azaltmak icin. Yine de calistirmadan ONCE ekteki
-- on-kontrol sorgusu (teshis_isim_cakismasi_parti3.sql) calistirilmali.
--
-- Besin degerleri yine HIC yazilmiyor -- sistem gercek malzeme
-- miktarlarindan otomatik hesapliyor.

do $$
declare
    v_grup2 uuid;
    v_grup3 uuid;
    v_recete_id uuid;
begin
    select mk.id into v_grup2 from mutfak_kategorileri mk join mutfaklar m on m.id = mk.mutfak_id where m.kod = 'turk' and mk.sira = 2;
    select mk.id into v_grup3 from mutfak_kategorileri mk join mutfaklar m on m.id = mk.mutfak_id where m.kod = 'turk' and mk.sira = 3;

    -- =====================================================================
    -- GRUP 2 - YAZ (6 tarif, oncelik)
    -- =====================================================================

    -- 1) Zeytinyağlı Patlıcan (Yaz)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Patlıcan (Yaz)', v_grup2, array['zeytinyagli','vejetaryen'], 'yaz', 'Ege', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PATLICAN', 1000), ('DOMATES', 300), ('KURU SOĞAN', 150),
        ('SARIMSAK', 15), ('ZEYTİNYAĞI', 90), ('ŞEKER', 15), ('TUZ', 12)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 2) Zeytinyağlı Kabak (Yaz)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Kabak (Yaz)', v_grup2, array['zeytinyagli','vejetaryen'], 'yaz', 'Ege', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KABAK', 1000), ('PİRİNÇ (HAM)', 60), ('KURU SOĞAN', 150),
        ('DOMATES', 150), ('ZEYTİNYAĞI', 70), ('ŞEKER', 12), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 3) Yaz Domates Çorbası
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yaz Domates Çorbası', v_grup2, array['corba','vejetaryen'], 'yaz', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DOMATES', 1000), ('KURU SOĞAN', 150), ('TEREYAĞI', 50),
        ('TAVUK SUYU', 1000), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 4) Mısırlı Yaz Pilavı
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Mısırlı Yaz Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yaz', 'Karadeniz', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 600), ('KONSERVE MISIR', 250), ('TEREYAĞI', 60), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 5) Zeytinyağlı Bamya (Yaz)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Bamya (Yaz)', v_grup2, array['zeytinyagli','vejetaryen'], 'yaz', 'Ege', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BAMYA', 900), ('DOMATES', 250), ('KURU SOĞAN', 150),
        ('ZEYTİNYAĞI', 70), ('LİMON SUYU', 20), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 6) Peynirli Yaz Böreği
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Peynirli Yaz Böreği', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yaz', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YUFKA', 500), ('FETA PEYNİRİ', 350), ('TAVUK YUMURTASI', 150), ('TEREYAĞI', 100), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 2 - SONBAHAR (3 tarif)
    -- =====================================================================

    -- 7) Kestaneli Sonbahar Pilavı
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kestaneli Sonbahar Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'sonbahar', 'Karadeniz', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 550), ('KESTANE', 350), ('TEREYAĞI', 70), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 8) Karnabahar Çorbası (Sonbahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karnabahar Çorbası (Sonbahar)', v_grup2, array['corba','vejetaryen'], 'sonbahar', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KARNABAHAR', 800), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 9) Zeytinyağlı Karalahana (Sonbahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Karalahana (Sonbahar)', v_grup2, array['zeytinyagli','vejetaryen'], 'sonbahar', 'Karadeniz', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KARALAHANA', 900), ('PİRİNÇ (HAM)', 60), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 70), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 3 - KIŞ (3 tarif)
    -- =====================================================================

    -- 10) Portakallı Mandalinalı Kış Salatası
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Portakallı Mandalinalı Kış Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Akdeniz', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PORTAKAL', 400), ('MANDALİNA', 400), ('ZEYTİNYAĞI', 20), ('ŞEKER', 15)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 11) Kuru Kayısılı Kış Kompostosu
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kuru Kayısılı Kış Kompostosu', v_grup3, array['komposto','vejetaryen'], 'kis', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KURU KAYISI', 400), ('KURU ÜZÜM', 200), ('ŞEKER', 100)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 12) Kış Lahana Turşusu
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kış Lahana Turşusu', v_grup3, array['tursu','vejetaryen'], 'kis', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('LAHANA', 900), ('HAVUÇ', 150), ('SARIMSAK', 20), ('TUZ', 40), ('SİRKE', 60)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA: 12 yeni tarifin hepsi eklendi mi?
select r.ad, mk.sira as grup, r.mevsim_etiketi, r.bolge,
       count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Zeytinyağlı Patlıcan (Yaz)', 'Zeytinyağlı Kabak (Yaz)', 'Yaz Domates Çorbası',
    'Mısırlı Yaz Pilavı', 'Zeytinyağlı Bamya (Yaz)', 'Peynirli Yaz Böreği',
    'Kestaneli Sonbahar Pilavı', 'Karnabahar Çorbası (Sonbahar)', 'Zeytinyağlı Karalahana (Sonbahar)',
    'Portakallı Mandalinalı Kış Salatası', 'Kuru Kayısılı Kış Kompostosu', 'Kış Lahana Turşusu'
  )
group by r.ad, mk.sira, r.mevsim_etiketi, r.bolge
order by mk.sira, r.mevsim_etiketi, r.ad;

-- Genel grup x mevsim dagilimi (guncel durum)
select mk.sira as grup, r.mevsim_etiketi, count(*) as tarif_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
where r.isletme_id is null
group by mk.sira, r.mevsim_etiketi
order by mk.sira, r.mevsim_etiketi;
