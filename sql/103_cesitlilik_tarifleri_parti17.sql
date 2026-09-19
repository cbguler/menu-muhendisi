-- 103_cesitlilik_tarifleri_parti17.sql
--
-- 1000 hedefine devam (469 -> 485). Yine hic kullanilmamis malzemelere
-- oncelik: KUZU PIRZOLA, KALKAN, PILIC GOGUS (DERISIZ), KECI ETI (BUT),
-- SIGIR PIRZOLA, KARABUGDAY, SIYAH FASULYE, REZENE, QUINOA, MUNG
-- FASULYESI, ARMUT (KISLIK), ROKFOR PEYNIRI, KEFIR, GREYFURT, HURMA,
-- KIZILCIK, KAJU. 16 tarif (Grup1: 5, Grup2: 5, Grup3: 6).
--
-- YUZ OTUZ YEDINCI DUZELTME (9 Eylul 2026) DERSI UYGULANDI: bu partiden
-- ITIBAREN, tarifleri YAZMADAN ONCE tum isimler
-- teshis_isim_cakismasi_parti17.sql ile TARANDI -- "Success. No rows
-- returned" ile TEMIZ oldugu dogrulandi (do $$ tek transaction oldugu
-- icin bir tek isim carpsa TUM parti geri alinirdi). Tum malzeme
-- adlari da malzeme_listesi.txt'ye karsi tek tek dogrulandi.

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
    values (null, 'Fırında Kuzu Pirzola (Sebzeli)', v_grup1, array['kirmizi_et'], 'ilkbahar', 'Genel', 10, 85)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU PİRZOLA', 1600), ('HAVUÇ', 200), ('PATATES', 300), ('ZEYTİNYAĞI', 40), ('TUZ', 14), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Kalkan', v_grup1, array['balik'], 'sonbahar', 'Karadeniz', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KALKAN', 1900), ('ZEYTİNYAĞI', 35), ('LİMON SUYU', 25), ('MAYDANOZ', 15), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Baharatlı Izgara Piliç Göğüs', v_grup1, array['beyaz_et'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİLİÇ GÖĞÜS (DERİSİZ)', 1500), ('ZEYTİNYAĞI', 35), ('PUL BİBER', 8), ('KEKİK', 6), ('TUZ', 12)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Keçi Eti Güveç', v_grup1, array['kirmizi_et'], 'kis', 'Genel', 10, 100)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KEÇİ ETİ (BUT)', 1500), ('PATATES', 400), ('KURU SOĞAN', 200), ('DOMATES', 150), ('ZEYTİNYAĞI', 30), ('TUZ', 14), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Sığır Pirzola', v_grup1, array['kirmizi_et'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SIĞIR PİRZOLA', 1700), ('ZEYTİNYAĞI', 35), ('KEKİK', 6), ('SARIMSAK', 15), ('TUZ', 14), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karabuğday Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KARABUĞDAY', 550), ('TEREYAĞI', 55), ('TAVUK SUYU', 850), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Siyah Fasulye', v_grup2, array['zeytinyagli','vejetaryen','kuru_baklagil'], 'kis', 'Genel', 10, 55)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SİYAH FASULYE', 500), ('DOMATES', 200), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 45), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Rezene Çorbası', v_grup2, array['corba','vejetaryen'], 'kis', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('REZENE', 500), ('TEREYAĞI', 50), ('SÜT (TAM YAĞ)', 400), ('KURU SOĞAN', 100), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Sebzeli Quinoa Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'ilkbahar', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('QUINOA', 500), ('HAVUÇ', 200), ('BEZELYE', 200), ('ZEYTİNYAĞI', 40), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Mung Fasulyeli Pilav', v_grup2, array['pilav_makarna_borek','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MUNG FASULYESİ', 350), ('PİRİNÇ (HAM)', 300), ('KURU SOĞAN', 120), ('TEREYAĞI', 50), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Rokforlu Armut Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)', 500), ('ROKFOR PEYNİRİ', 150), ('CEVİZ (İÇ)', 80), ('ZEYTİNYAĞI', 25), ('LİMON SUYU', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kefirli Salatalık', v_grup3, array['yogurt','vejetaryen'], 'yaz', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KEFİR', 700), ('SALATALIK', 400), ('SARIMSAK', 10), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Greyfurtlu Roka Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('GREYFURT', 400), ('ROKA', 250), ('ZEYTİNYAĞI', 30), ('TUZ', 5)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Hurma ve Süt Tatlısı', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HURMA', 350), ('SÜT (TAM YAĞ)', 800), ('PİRİNÇ UNU', 60), ('ŞEKER', 100)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kızılcık Kompostosu', v_grup3, array['komposto','vejetaryen'], 'sonbahar', 'Genel', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIZILCIK', 500), ('ŞEKER', 200)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kajulu Havuç Salatası', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KAJU', 100), ('HAVUÇ', 500), ('LİMON SUYU', 15), ('ZEYTİNYAĞI', 25), ('TUZ', 5)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Fırında Kuzu Pirzola (Sebzeli)', 'Fırında Kalkan', 'Baharatlı Izgara Piliç Göğüs', 'Keçi Eti Güveç', 'Izgara Sığır Pirzola',
    'Karabuğday Pilavı', 'Zeytinyağlı Siyah Fasulye', 'Rezene Çorbası', 'Sebzeli Quinoa Pilavı', 'Mung Fasulyeli Pilav',
    'Rokforlu Armut Salatası', 'Kefirli Salatalık', 'Greyfurtlu Roka Salatası', 'Hurma ve Süt Tatlısı', 'Kızılcık Kompostosu', 'Kajulu Havuç Salatası'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
