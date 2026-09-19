-- 102_cesitlilik_tarifleri_parti16.sql
--
-- 1000 hedefine devam (453 -> 469). Bu partide, kaynak_duzeltilmis_v29.xlsx
-- ile malzeme_listesi.txt karsilastirilarak bulunan, hic bir tarifte
-- kullanilmamis malzemelere ONCELIK verildi (KOYUN TANDIR, PILIC BUT,
-- SIGIR KABURGA, CIPURA, DANA ROSTO, KESTANE MANTARI, KARNIBAHAR,
-- ARPA, BRUKSEL LAHANASI, KIRMIZI LAHANA, KEÇI PEYNIRI, NAR gibi).
-- 16 tarif (Grup1: 5, Grup2: 5, Grup3: 6), hepsi kavramsal olarak
-- birbirinden farkli. Tum malzeme adlari malzeme_listesi.txt'ye
-- (veritabanindan disa aktarilmis, 564 malzeme) karsi TEK TEK
-- dogrulandi. Besin degerleri yine hic yazilmiyor (malzeme bazinda
-- otomatik hesaplaniyor).

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
    values (null, 'Fırında Koyun Tandır', v_grup1, array['kirmizi_et'], 'sonbahar', 'Genel', 10, 110)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KOYUN TANDIR', 1400), ('ZEYTİNYAĞI', 40), ('KEKİK', 8), ('SARIMSAK', 20), ('TUZ', 15), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Izgara Piliç But', v_grup1, array['beyaz_et'], 'yil_boyunca', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİLİÇ BUT', 1600), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 30), ('KEKİK', 6), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Sığır Kaburga', v_grup1, array['kirmizi_et'], 'kis', 'Genel', 10, 130)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('SIĞIR KABURGA', 1800), ('KURU SOĞAN', 200), ('HAVUÇ', 150), ('DOMATES', 150), ('TUZ', 15), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Otlu Izgara Çipura', v_grup1, array['balik'], 'sonbahar', 'Ege', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ÇİPURA', 2000), ('ZEYTİNYAĞI', 40), ('LİMON SUYU', 30), ('TAZE FESLEĞEN', 15), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Nar Ekşili Dana Rosto', v_grup1, array['kirmizi_et'], 'kis', 'Genel', 10, 90)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA ROSTO', 1500), ('NAR EKŞİSİ', 40), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 30), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kestane Mantarlı Pirinç Pilavı', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'sonbahar', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 600), ('KESTANE MANTARI', 300), ('TEREYAĞI', 60), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Pazılı Nohut Yemeği', v_grup2, array['zeytinyagli','vejetaryen'], 'kis', 'Genel', 10, 50)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PAZI', 600), ('NOHUT', 400), ('KURU SOĞAN', 150), ('DOMATES', 150), ('ZEYTİNYAĞI', 50), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Karnıbahar Çorbası', v_grup2, array['corba','vejetaryen'], 'kis', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KARNIBAHAR', 600), ('TEREYAĞI', 50), ('SÜT (TAM YAĞ)', 500), ('KURU SOĞAN', 100), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Arpa Çorbası', v_grup2, array['corba','vejetaryen'], 'kis', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ARPA (ALTI SIRALI)', 300), ('HAVUÇ', 200), ('KURU SOĞAN', 150), ('TEREYAĞI', 40), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Brüksel Lahanalı Zeytinyağlı', v_grup2, array['zeytinyagli','vejetaryen'], 'kis', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('BRÜKSEL LAHANASI', 700), ('KURU SOĞAN', 100), ('HAVUÇ', 100), ('ZEYTİNYAĞI', 50), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Cevizli Kırmızı Lahana Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIRMIZI LAHANA', 600), ('CEVİZ (İÇ)', 60), ('LİMON SUYU', 30), ('ZEYTİNYAĞI', 30), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Keçi Peynirli Pancar Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PANCAR', 500), ('KEÇİ PEYNİRİ', 200), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 15), ('TUZ', 5)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Narlı Ispanak Salatası', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ISPANAK', 500), ('NAR', 200), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 15), ('TUZ', 5)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kayısılı Yoğurt', v_grup3, array['yogurt','vejetaryen'], 'yaz', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YOĞURT (TAM)', 700), ('KAYISI', 300), ('ŞEKER', 30)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Ekmek Kadayıfı (Kaymaklı)', v_grup3, array['tatli','vejetaryen'], 'yil_boyunca', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('EKMEK KADAYIFI', 500), ('ŞEKER', 400), ('KAYMAK', 300)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Nar Ekşili Kısır', v_grup3, array['salata','vejetaryen'], 'yil_boyunca', 'Güneydoğu Anadolu', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('İNCE BULGUR', 400), ('KONSERVE DOMATES SALÇASI', 100), ('NAR EKŞİSİ', 40), ('MAYDANOZ', 40), ('ZEYTİNYAĞI', 40), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Fırında Koyun Tandır', 'Izgara Piliç But', 'Fırında Sığır Kaburga', 'Otlu Izgara Çipura', 'Nar Ekşili Dana Rosto',
    'Kestane Mantarlı Pirinç Pilavı', 'Pazılı Nohut Yemeği', 'Karnıbahar Çorbası', 'Arpa Çorbası', 'Brüksel Lahanalı Zeytinyağlı',
    'Cevizli Kırmızı Lahana Salatası', 'Keçi Peynirli Pancar Salatası', 'Narlı Ispanak Salatası', 'Kayısılı Yoğurt', 'Ekmek Kadayıfı (Kaymaklı)', 'Nar Ekşili Kısır'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
