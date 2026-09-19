-- 83_ilkbahar_tarifleri_parti2.sql
--
-- Bahri'nin talebi: 1000 tarif hedefine dogru, ilkbahar acigini
-- kapatmaya DEVAM (81 numarali migration'in ilk partisinden sonra
-- hala digerlerinin gerisinde: Grup1=9, Grup2=8, Grup3=8, digerleri
-- 11-21 arasi). Bu, IKINCI 12 tariflik parti (her grupta 4).
--
-- ONEMLI: bir onceki partide 2 isim carpismasi (Ispanaklı Börek,
-- Vişne Kompostosu) yasandi -- bu sefer, mevcut kutuphanede COK
-- YAYGIN olabilecek jenerik isimlerden (ör. sade "X Salatası")
-- kacinilip, daha AYIRT EDICI isimler secildi. Yine de -- Bahri'den
-- calistirmadan ONCE (opsiyonel) bir isim-carpismasi on-kontrolu
-- yapmasi istenebilir; bu dosyanin sonunda boyle bir kontrol sorgusu
-- da var (ayri calistirilabilir).
--
-- Besin degerleri yine HIC yazilmiyor -- sistem gercek malzeme
-- miktarlarindan otomatik hesapliyor.

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

    -- 1) Taze Fasulyeli Kuzu Güveç
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Taze Fasulyeli Kuzu Güveç (İlkbahar)', v_grup1, array['kirmizi_et','etli_sebze'], 'ilkbahar', 'Genel', 10, 65)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU ETİ (BUT)', 1000), ('TAZE FASULYE', 700), ('KURU SOĞAN', 250),
        ('DOMATES', 200), ('ZEYTİNYAĞI', 50), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 2) Havuçlu Fırın Tavuk But
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Havuçlu Fırın Tavuk But (Bahar)', v_grup1, array['beyaz_et','etli_sebze'], 'ilkbahar', 'Genel', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK BUT', 1200), ('HAVUÇ', 500), ('KURU SOĞAN', 200),
        ('SARIMSAK', 15), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 3) Nohutlu Sığır Kavurma (Bahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Nohutlu Sığır Kavurma (Bahar)', v_grup1, array['kirmizi_et','kuru_baklagil'], 'ilkbahar', 'İç Anadolu', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SIĞIR KIYMA', 800), ('NOHUT', 500), ('KURU SOĞAN', 200),
        ('DOMATES', 150), ('TEREYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 4) Pırasalı Kıymalı Bahar Yemeği
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Pırasalı Kıymalı Bahar Yemeği', v_grup1, array['kirmizi_et','etli_sebze'], 'ilkbahar', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA KIYMA', 800), ('PIRASA', 900), ('KURU SOĞAN', 150),
        ('PİRİNÇ (HAM)', 60), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 2 (Çorba/Pilav/Zeytinyağlı/Makarna/Börek) -- 4 tarif
    -- =====================================================================

    -- 5) Havuç Çorbası (Bahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Havuç Çorbası (Bahar)', v_grup2, array['corba','vejetaryen'], 'ilkbahar', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HAVUÇ', 800), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1500), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 6) Zeytinyağlı Pırasa (Bahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Pırasa (Bahar)', v_grup2, array['zeytinyagli','vejetaryen'], 'ilkbahar', 'Ege', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PIRASA', 1000), ('PİRİNÇ (HAM)', 60), ('HAVUÇ', 150),
        ('ZEYTİNYAĞI', 70), ('ŞEKER', 10), ('LİMON SUYU', 25), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 7) Şehriyeli Bahar Pilavı
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Şehriyeli Bahar Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'ilkbahar', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 600), ('ŞEHRİYE', 100), ('TEREYAĞI', 70), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 8) Zeytinyağlı Kereviz (Bahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Kereviz (Bahar)', v_grup2, array['zeytinyagli','vejetaryen'], 'ilkbahar', 'Marmara', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KEREVİZ', 900), ('HAVUÇ', 200), ('KURU SOĞAN', 100),
        ('ZEYTİNYAĞI', 70), ('LİMON SUYU', 30), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- =====================================================================
    -- GRUP 3 (Salata/Tatlı/Komposto/Yoğurt/Cacık/Turşu) -- 4 tarif
    -- =====================================================================

    -- 9) Bahar Cacığı
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Bahar Cacığı', v_grup3, array['cacik','vejetaryen'], 'ilkbahar', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SALATALIK', 500), ('YOĞURT (TAM)', 800), ('SARIMSAK', 15), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 10) Portakallı Havuç Salatası (Bahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Portakallı Havuç Salatası (Bahar)', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Akdeniz', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HAVUÇ', 500), ('PORTAKAL', 300), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 20), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 11) Elmalı Cevizli Bahar Salatası
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Elmalı Cevizli Bahar Salatası', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ELMA', 500), ('CEVİZ (İÇ)', 150), ('SÜZME YOĞURT', 300), ('ŞEKER', 30)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- 12) Barbunya Turşusu (Bahar)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Barbunya Turşusu (Bahar)', v_grup3, array['tursu','vejetaryen'], 'ilkbahar', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BARBUNYA', 800), ('SARIMSAK', 20), ('TUZ', 40), ('SİRKE', 60)
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
    'Taze Fasulyeli Kuzu Güveç (İlkbahar)', 'Havuçlu Fırın Tavuk But (Bahar)',
    'Nohutlu Sığır Kavurma (Bahar)', 'Pırasalı Kıymalı Bahar Yemeği',
    'Havuç Çorbası (Bahar)', 'Zeytinyağlı Pırasa (Bahar)', 'Şehriyeli Bahar Pilavı', 'Zeytinyağlı Kereviz (Bahar)',
    'Bahar Cacığı', 'Portakallı Havuç Salatası (Bahar)', 'Elmalı Cevizli Bahar Salatası', 'Barbunya Turşusu (Bahar)'
  )
group by r.ad, mk.sira, r.mevsim_etiketi, r.bolge
order by mk.sira, r.ad;

-- Yeni ilkbahar dagilimi
select mk.sira as grup, count(*) as ilkbahar_tarif_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
where r.isletme_id is null and r.mevsim_etiketi = 'ilkbahar'
group by mk.sira
order by mk.sira;
