-- 82_ilkbahar_tarifleri_ekle.sql
--
-- Bahri'nin sorusu (5 Eylul 2026): "Neden bu kadar cok hedef disi var?"
-- uzerine yapilan teshis (bkz. teshis_kutuphane_genisletme.sql sonuclari)
-- carpici bir dengesizlik ortaya cikardi: 241 tariflik ORTAK kutuphanede
-- ILKBAHAR, her uc grupta da DIGER mevsimlerin ~1/4'u kadar tarife sahip:
--   Grup 1 (Ana Yemek):        ilkbahar=5   (kis=17, yaz=21, sonbahar=19)
--   Grup 2 (Corba/Pilav/vb.):  ilkbahar=4   (kis=19, yaz=10, sonbahar=11)
--   Grup 3 (Salata/Tatli/vb.): ilkbahar=4   (kis=11, yaz=13, sonbahar=12)
-- Bu, bahar aylarina sarkan haftalarda algoritmanin SECENEK HAVUZUNUN
-- kucuk kalmasina, dolayisiyla hedefi tutturma sansinin dusmesine
-- katkida bulunuyor.
--
-- Bu migration, ILKBAHAR icin 12 YENI tarif ekliyor (her grupta 4) --
-- SADECE gercekten var olan malzemeler kullanilarak (bkz.
-- teshis_kutuphane_genisletme.sql sorgu 5 sonucu, 564 malzeme listesi).
-- ONEMLI: besin degerleri (kalori/protein/vb.) BURADA HIC YAZILMIYOR --
-- sistem bunlari recete_malzemeleri'ndeki GERCEK malzeme miktarlarindan
-- OTOMATIK hesapliyor (bkz. _tarif_detaylarini_getir, 0_Yillik_Menu.py).
-- Miktarlar 10 PORSIYONLUK bir uretim icin (projedeki standart).

-- Grup ID'lerini degiskene al (okunabilirlik icin)
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

    -- =====================================================================
    -- GRUP 1 (Ana Yemek) -- 4 tarif
    -- =====================================================================

    -- 1) Enginarlı Kuzu Yahnisi
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginarlı Kuzu Yahnisi', v_grup1, array['kirmizi_et','etli_sebze'], 'ilkbahar', 'Ege', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU ETİ (KOL)', 1000), ('ENGİNAR', 800), ('KURU SOĞAN', 300),
        ('DOMATES', 200), ('ZEYTİNYAĞI', 60), ('LİMON SUYU', 30), ('TUZ', 15), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 2) Bahar Sebzeli Tavuk Sote
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bahar Sebzeli Tavuk Sote', v_grup1, array['beyaz_et','etli_sebze'], 'ilkbahar', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK GÖĞÜS', 900), ('BEZELYE', 400), ('TAZE SOĞAN', 150),
        ('SARIMSAK', 20), ('ZEYTİNYAĞI', 50), ('DOMATES', 200), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 3) Taze Bakla Kavurma (Etli)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Taze Bakla Kavurma (Etli)', v_grup1, array['kirmizi_et','etli_sebze'], 'ilkbahar', 'Ege', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA KIYMA', 800), ('BAKLA', 900), ('TAZE SOĞAN', 150),
        ('TAZE DEREOTU', 30), ('TEREYAĞI', 60), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 4) Ispanaklı Yumurta
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ispanaklı Yumurta', v_grup1, array['yumurta','vejetaryen'], 'ilkbahar', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ISPANAK', 900), ('TAVUK YUMURTASI', 600), ('KURU SOĞAN', 150),
        ('TEREYAĞI', 50), ('TUZ', 10), ('KARABİBER', 2)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 2 (Çorba/Pilav/Zeytinyağlı/Makarna/Börek) -- 4 tarif
    -- =====================================================================

    -- 5) Enginar Çorbası
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginar Çorbası', v_grup2, array['corba','vejetaryen'], 'ilkbahar', 'Ege', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ENGİNAR', 600), ('KURU SOĞAN', 150), ('PİRİNÇ (HAM)', 100),
        ('TAVUK SUYU', 1500), ('TEREYAĞI', 40), ('LİMON SUYU', 30), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 6) Zeytinyağlı Taze Bakla
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Taze Bakla', v_grup2, array['zeytinyagli','vejetaryen'], 'ilkbahar', 'Ege', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BAKLA', 1000), ('ZEYTİNYAĞI', 80), ('TAZE SOĞAN', 150),
        ('TAZE DEREOTU', 20), ('ŞEKER', 15), ('LİMON SUYU', 30), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 7) Bezelyeli Pilav
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bezelyeli Pilav', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'ilkbahar', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 600), ('BEZELYE', 300), ('TEREYAĞI', 70), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 8) Bahar Ispanaklı Böreği
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bahar Ispanaklı Böreği', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'ilkbahar', 'Genel', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YUFKA', 500), ('ISPANAK', 600), ('FETA PEYNİRİ', 300),
        ('TEREYAĞI', 100), ('TAVUK YUMURTASI', 150), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 3 (Salata/Tatlı/Komposto/Yoğurt/Cacık/Turşu) -- 4 tarif
    -- =====================================================================

    -- 9) Roka Marul Salatası
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Roka Marul Salatası', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ROKA', 250), ('MARUL', 300), ('TURP', 150), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 25), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 10) Kuşkonmaz Salatası
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kuşkonmaz Salatası', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Marmara', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUŞKONMAZ', 600), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 30), ('SARIMSAK', 10), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 11) Çilekli Yoğurt
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Çilekli Yoğurt', v_grup3, array['yogurt','vejetaryen'], 'ilkbahar', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ÇİLEK', 600), ('SÜZME YOĞURT', 800), ('ŞEKER', 60)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 12) Taze Vişne Kompostosu
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Taze Vişne Kompostosu', v_grup3, array['komposto','vejetaryen'], 'ilkbahar', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('VİŞNE', 600), ('ŞEKER', 150)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA: 12 yeni tarifin hepsi eklendi mi, malzemeleri dogru
-- baglandi mi?
select r.ad, mk.sira as grup, r.mevsim_etiketi, r.bolge,
       count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Enginarlı Kuzu Yahnisi', 'Bahar Sebzeli Tavuk Sote', 'Taze Bakla Kavurma (Etli)', 'Ispanaklı Yumurta',
    'Enginar Çorbası', 'Zeytinyağlı Taze Bakla', 'Bezelyeli Pilav', 'Bahar Ispanaklı Böreği',
    'Roka Marul Salatası', 'Kuşkonmaz Salatası', 'Çilekli Yoğurt', 'Taze Vişne Kompostosu'
  )
group by r.ad, mk.sira, r.mevsim_etiketi, r.bolge
order by mk.sira, r.ad;

-- Yeni durumda ILKBAHAR dagilimi nasil (once/sonra karsilastirmasi icin)
select mk.sira as grup, count(*) as ilkbahar_tarif_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
where r.isletme_id is null and r.mevsim_etiketi = 'ilkbahar'
group by mk.sira
order by mk.sira;
