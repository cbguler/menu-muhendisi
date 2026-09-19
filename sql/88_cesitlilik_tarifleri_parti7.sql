-- 88_cesitlilik_tarifleri_parti7.sql
--
-- 1000 hedefine devam. Ilk kez HINDI ETI ve YER ELMASI kullanildi.
-- 16 tarif (Grup1: 5, Grup2: 5, Grup3: 6), hepsi kavramsal olarak
-- birbirinden farkli. Besin degerleri yine hic yazilmiyor.

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
    values (null, 'Hindi Sote (Ev Usulü)', v_grup1, array['beyaz_et','etli_sebze'], 'yil_boyunca', 'Genel', 10, 35)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)', 900), ('KURU SOĞAN', 150), ('DOMATES', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Fırında Hindi But', v_grup1, array['beyaz_et'], 'yil_boyunca', 'Genel', 10, 60)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('HİNDİ ETİ (BUT, DERİSİZ)', 1200), ('ZEYTİNYAĞI', 40), ('KEKİK', 5), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yer Elmalı Kuzu Yahnisi', v_grup1, array['kirmizi_et','etli_sebze'], 'kis', 'Genel', 10, 65)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KUZU ETİ (KOL)', 900), ('YER ELMASI', 700), ('KURU SOĞAN', 200), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginar Kalpli Tavuk Güveç', v_grup1, array['beyaz_et','etli_sebze'], 'ilkbahar', 'Ege', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TAVUK GÖĞÜS', 900), ('ENGİNAR KALBİ', 500), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 10), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kırmızı Biberli Kıyma Sote', v_grup1, array['kirmizi_et','etli_sebze'], 'yil_boyunca', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('DANA KIYMA', 800), ('KIRMIZI BİBER', 400), ('KURU SOĞAN', 200), ('DOMATES', 150), ('ZEYTİNYAĞI', 40), ('TUZ', 12), ('KARABİBER', 3)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 2 (5)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Pancar Çorbası', v_grup2, array['corba','vejetaryen'], 'kis', 'Genel', 10, 40)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PANCAR', 700), ('KURU SOĞAN', 150), ('TEREYAĞI', 50), ('TAVUK SUYU', 1200), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Yer Elması Zeytinyağlısı', v_grup2, array['zeytinyagli','vejetaryen'], 'kis', 'Genel', 10, 45)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('YER ELMASI', 900), ('HAVUÇ', 150), ('KURU SOĞAN', 150), ('ZEYTİNYAĞI', 70), ('LİMON SUYU', 30), ('ŞEKER', 10), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Zeytinyağlı Biber Dolması', v_grup2, array['zeytinyagli','dolma','vejetaryen'], 'yaz', 'Ege', 10, 70)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIRMIZI BİBER', 1000), ('PİRİNÇ (HAM)', 350), ('KURU SOĞAN', 200), ('ZEYTİNYAĞI', 80), ('ŞEKER', 15), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Enginar Kalpli Pilav', v_grup2, array['pilav_makarna_borek','vejetaryen'], 'ilkbahar', 'Ege', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PİRİNÇ (HAM)', 600), ('ENGİNAR KALBİ', 300), ('TEREYAĞI', 70), ('TAVUK SUYU', 900), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Şehriye Çorbası (Sade)', v_grup2, array['corba','vejetaryen'], 'yil_boyunca', 'Genel', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ŞEHRİYE', 200), ('TEREYAĞI', 50), ('TAVUK SUYU', 1500), ('TUZ', 10)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    -- GRUP 3 (6)
    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kuru Fasulye Piyazı (Ev Usulü)', v_grup3, array['salata','vejetaryen','kuru_baklagil'], 'yil_boyunca', 'Genel', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KURU FASULYE', 600), ('KURU SOĞAN', 100), ('MAYDANOZ', 20), ('ZEYTİNYAĞI', 30), ('LİMON SUYU', 20), ('TUZ', 8)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Pancar Salatası (Yoğurtlu)', v_grup3, array['salata','vejetaryen'], 'kis', 'Genel', 10, 25)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('PANCAR', 600), ('YOĞURT (TAM)', 300), ('SARIMSAK', 10), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Armutlu Cevizli Salata', v_grup3, array['salata','vejetaryen'], 'sonbahar', 'Genel', 10, 15)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)', 500), ('CEVİZ (İÇ)', 100), ('SÜZME YOĞURT', 300)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Mandalina Kompostosu', v_grup3, array['komposto','vejetaryen'], 'kis', 'Akdeniz', 10, 20)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('MANDALİNA', 800), ('ŞEKER', 130)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Turplu Yoğurt Salatası', v_grup3, array['salata','vejetaryen'], 'ilkbahar', 'Genel', 10, 10)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('TURP', 400), ('YOĞURT (TAM)', 400), ('SARIMSAK', 10), ('TAZE NANE', 10), ('TUZ', 6)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

    insert into receteler (isletme_id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge, porsiyon_sayisi, hazirlik_dakika)
    values (null, 'Kırmızı Biber Turşusu', v_grup3, array['tursu','vejetaryen'], 'yaz', 'Genel', 10, 30)
    returning id into v_recete_id;
    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
    select v_recete_id, id, miktar from (values
        ('KIRMIZI BİBER', 700), ('SARIMSAK', 15), ('TUZ', 35), ('SİRKE', 50)
    ) as veri(ad, miktar) join malzemeler on malzemeler.ad = veri.ad and malzemeler.isletme_id is null;

end $$;

-- DOGRULAMA
select r.ad, mk.sira as grup, r.mevsim_etiketi, count(rm.malzeme_id) as malzeme_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_malzemeleri rm on rm.recete_id = r.id
where r.isletme_id is null
  and r.ad in (
    'Hindi Sote (Ev Usulü)', 'Fırında Hindi But', 'Yer Elmalı Kuzu Yahnisi',
    'Enginar Kalpli Tavuk Güveç', 'Kırmızı Biberli Kıyma Sote',
    'Pancar Çorbası', 'Yer Elması Zeytinyağlısı', 'Zeytinyağlı Biber Dolması',
    'Enginar Kalpli Pilav', 'Şehriye Çorbası (Sade)',
    'Kuru Fasulye Piyazı (Ev Usulü)', 'Pancar Salatası (Yoğurtlu)', 'Armutlu Cevizli Salata',
    'Mandalina Kompostosu', 'Turplu Yoğurt Salatası', 'Kırmızı Biber Turşusu'
  )
group by r.ad, mk.sira, r.mevsim_etiketi
order by mk.sira, r.ad;

select count(*) as toplam_tarif_sayisi from receteler where isletme_id is null;
