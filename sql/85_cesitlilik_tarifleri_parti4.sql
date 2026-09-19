-- 85_cesitlilik_tarifleri_parti4.sql
--
-- Bahri'nin talebi: acil mevsimsel dengesizlik cozuldukten sonra,
-- 1000 tarif hedefine dogru GENEL CESITLILIK icin devam. Bu parti
-- ozellikle daha once HIC kullanilmayan "balik" ve "dolma" etiketli
-- tarifler ekliyor, ayrica meyve tabanli Grup 3 cesitliligini
-- artiriyor -- toplam 16 tarif (Grup1: 5, Grup2: 6, Grup3: 5).
--
-- Isimler yine ayirt edici. Calistirmadan ONCE ekteki on-kontrol
-- sorgusu calistirilmali. Besin degerleri yine HIC yazilmiyor.

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
    -- GRUP 1 (Ana Yemek) -- 5 tarif -- ILK KEZ "balik" etiketi kullaniliyor
    -- =====================================================================

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Limonlu Fırın Levrek', v_grup1, array['balik'], 'yil_boyunca', 'Ege', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('LEVREK', 1200), ('LİMON', 100), ('ZEYTİNYAĞI', 50), ('KURU SOĞAN', 150), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karadeniz Usulü Hamsi Tava', v_grup1, array['balik'], 'kis', 'Karadeniz', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HAMSİ', 1200), ('MISIR UNU', 200), ('ZEYTİNYAĞI', 60), ('TUZ', 12)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Somon Fileto', v_grup1, array['balik','izgara'], 'yil_boyunca', 'Marmara', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SOMON', 1000), ('LİMON SUYU', 40), ('ZEYTİNYAĞI', 40), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Etli Kuru Fasulye (Kış)', v_grup1, array['kirmizi_et','kuru_baklagil'], 'kis', 'İç Anadolu', 10, 70)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KURU FASULYE', 700), ('KUZU ETİ (KOL)', 500), ('KURU SOĞAN', 200),
        ('DOMATES', 200), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Palamut (Sonbahar)', v_grup1, array['balik','izgara'], 'sonbahar', 'Marmara', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PALAMUT', 1200), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 30), ('TUZ', 12)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 2 (Çorba/Pilav/Zeytinyağlı/Makarna/Börek) -- 6 tarif
    -- =====================================================================

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kırmızı Mercimek Çorbası (Ev Usulü)', v_grup2, array['corba','vejetaryen'], 'yil_boyunca', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIRMIZI MERCİMEK', 500), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1500), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Yaprak Sarma (Ev Usulü)', v_grup2, array['zeytinyagli','dolma','vejetaryen'], 'yil_boyunca', 'Ege', 10, 90)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SALAMURA YAPRAK', 600), ('PİRİNÇ (HAM)', 400), ('KURU SOĞAN', 250),
        ('ZEYTİNYAĞI', 90), ('ŞEKER', 15), ('LİMON SUYU', 30), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Sarımsaklı Domates Soslu Makarna', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MAKARNA', 700), ('DOMATES', 500), ('KURU SOĞAN', 150),
        ('SARIMSAK', 15), ('ZEYTİNYAĞI', 50), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ispanaklı Mercimek Çorbası (Kış)', v_grup2, array['corba','vejetaryen'], 'kis', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YEŞİL MERCİMEK', 400), ('ISPANAK', 400), ('KURU SOĞAN', 150), ('TAVUK SUYU', 1500), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Enginar (İlkbahar)', v_grup2, array['zeytinyagli','vejetaryen'], 'ilkbahar', 'Ege', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ENGİNAR', 900), ('HAVUÇ', 200), ('KURU SOĞAN', 150),
        ('ZEYTİNYAĞI', 80), ('LİMON SUYU', 30), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kaşarlı Fırın Makarna', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MAKARNA', 700), ('KAŞAR PEYNİRİ', 300), ('TEREYAĞI', 60), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 3 (Salata/Tatlı/Komposto/Yoğurt/Cacık/Turşu) -- 5 tarif
    -- =====================================================================

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ayva Tatlısı (Kış)', v_grup3, array['tatli','vejetaryen'], 'kis', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('AYVA', 900), ('ŞEKER', 300)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'İncirli Yoğurt (Yaz)', v_grup3, array['yogurt','vejetaryen'], 'yaz', 'Ege', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('İNCİR', 500), ('SÜZME YOĞURT', 800), ('ŞEKER', 40)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)', v_grup3, array['salata','vejetaryen'], 'sonbahar', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ÜZÜM', 600), ('CEVİZ (İÇ)', 100), ('SÜZME YOĞURT', 300)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Mevsim Yeşillik Salatası', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MARUL', 300), ('ROKA', 200), ('TURP', 100), ('ZEYTİNYAĞI', 35), ('LİMON SUYU', 20), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Naneli Cacık (Klasik)', v_grup3, array['cacik','vejetaryen'], 'yil_boyunca', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SALATALIK', 500), ('YOĞURT (TAM)', 800), ('TAZE NANE', 15), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA: 16 yeni tarifin hepsi eklendi mi?
select r.ad, mk.sira as grup, r.mevsim_etiketi, r.bolge,
       count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Limonlu Fırın Levrek', 'Karadeniz Usulü Hamsi Tava', 'Izgara Somon Fileto',
    'Etli Kuru Fasulye (Kış)', 'Izgara Palamut (Sonbahar)',
    'Kırmızı Mercimek Çorbası (Ev Usulü)', 'Zeytinyağlı Yaprak Sarma (Ev Usulü)',
    'Sarımsaklı Domates Soslu Makarna', 'Ispanaklı Mercimek Çorbası (Kış)',
    'Zeytinyağlı Enginar (İlkbahar)', 'Kaşarlı Fırın Makarna',
    'Ayva Tatlısı (Kış)', 'İncirli Yoğurt (Yaz)', 'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)',
    'Mevsim Yeşillik Salatası', 'Naneli Cacık (Klasik)'
  )
group by r.ad, mk.sira, r.mevsim_etiketi, r.bolge
order by mk.sira, r.ad;

-- Genel grup x mevsim dagilimi (guncel durum) + toplam
select mk.sira as grup, r.mevsim_etiketi, count(*) as tarif_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
where r.isletme_id is null
group by mk.sira, r.mevsim_etiketi
order by mk.sira, r.mevsim_etiketi;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
