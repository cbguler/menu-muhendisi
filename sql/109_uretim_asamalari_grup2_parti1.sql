-- 109_uretim_asamalari_grup2_parti1.sql
-- Grup 2, 1. parti (1-20 / 84). Ayni metodoloji. NOT: coguGrup2
-- tarifi corba/pilav -- bunlarin isil islemi genelde KAYNAMA
-- noktasina (100C) kadar cikiyor (haslama/pisirme), firin/izgara
-- degil. Humus istisna -- hic isil islem YOK (soguk meze, hazir
-- humus + zeytinyagi/limon/maydanoz karistirma), TEK asamali.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Antep Fıstıklı Bulgur Pilavı (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Antep Fıstıklı Bulgur Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BULGUR', 'ANTEP FISTIĞI', 'TEREYAĞI');

    -- 2) Bademli Pirinç Pilavı (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bademli Pirinç Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'BADEM (İÇ)', 'TEREYAĞI');

    -- 3) Bahar Ispanaklı Böreği (50: 25+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bahar Ispanaklı Böreği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Yufka Açma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 25, 5, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YUFKA', 'ISPANAK', 'FETA PEYNİRİ', 'TEREYAĞI', 'TAVUK YUMURTASI');

    -- 4) Bezelyeli Pilav (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'BEZELYE', 'TEREYAĞI');

    -- 5) Brokoli Çorbası (Ev Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Brokoli Çorbası (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BROKOLİ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 6) Domatesli Patates Yemeği (Etsiz) (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Patates Yemeği (Etsiz)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATATES', 'DOMATES', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 7) Domatesli Şehriye Çorbası (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Şehriye Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ŞEHRİYE', 'DOMATES', 'TEREYAĞI');

    -- 8) Enginar Kalpli Pilav (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Kalpli Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'ENGİNAR KALBİ', 'TEREYAĞI');

    -- 9) Enginar Çorbası (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ENGİNAR', 'KURU SOĞAN', 'PİRİNÇ (HAM)', 'TEREYAĞI');

    -- 10) Et Suyu Çorbası (Sade) (20: 5+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Et Suyu Çorbası (Sade)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 15, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ET SUYU', 'PİRİNÇ (HAM)');

    -- 11) Havuç ve Kereviz Çorbası (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç ve Kereviz Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HAVUÇ', 'KEREVİZ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 12) Havuç Çorbası (Bahar) (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç Çorbası (Bahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HAVUÇ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 13) Humus (Ev Usulü) (15) -- ISIL ISLEM YOK, TEK ASAMA
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Humus (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Karıştırma)', 1, 15, 15, false);

    -- 14) Ispanaklı Mercimek Çorbası (Kış) (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Mercimek Çorbası (Kış)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YEŞİL MERCİMEK', 'ISPANAK', 'KURU SOĞAN');

    -- 15) Kabak Çorbası (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK', 'KURU SOĞAN', 'TEREYAĞI');

    -- 16) Karidesli Makarna (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karidesli Makarna';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 15, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA', 'KARİDES', 'SARIMSAK', 'ZEYTİNYAĞI');

    -- 17) Karnabahar Çorbası (Sonbahar) (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnabahar Çorbası (Sonbahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARNABAHAR', 'KURU SOĞAN', 'TEREYAĞI');

    -- 18) Arpa Çorbası (45: 15+30) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Arpa Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 30, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ARPA (ALTI SIRALI)', 'HAVUÇ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 19) Brüksel Lahanalı Zeytinyağlı (40: 12+28) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Brüksel Lahanalı Zeytinyağlı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BRÜKSEL LAHANASI', 'KURU SOĞAN', 'HAVUÇ', 'ZEYTİNYAĞI');

    -- 20) Karabuğday Pilavı (30: 10+20) -- Claude'un parti17'de ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karabuğday Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARABUĞDAY', 'TEREYAĞI');

end $$;

-- DOGRULAMA
select
    r.ad,
    (select count(*) from recete_asamalari ra2 where ra2.recete_id = r.id) as asama_sayisi,
    (select sum(ra2.sure_dakika) from recete_asamalari ra2 where ra2.recete_id = r.id) as toplam_sure_dakika,
    (select count(*) from asama_malzemeleri am2
       join recete_asamalari ra2 on ra2.id = am2.asama_id
       where ra2.recete_id = r.id) as asama_malzeme_baglantisi
from receteler r
where r.isletme_id is null
  and r.ad in (
    'Antep Fıstıklı Bulgur Pilavı', 'Bademli Pirinç Pilavı', 'Bahar Ispanaklı Böreği', 'Bezelyeli Pilav', 'Brokoli Çorbası (Ev Usulü)',
    'Domatesli Patates Yemeği (Etsiz)', 'Domatesli Şehriye Çorbası', 'Enginar Kalpli Pilav', 'Enginar Çorbası', 'Et Suyu Çorbası (Sade)',
    'Havuç ve Kereviz Çorbası', 'Havuç Çorbası (Bahar)', 'Humus (Ev Usulü)', 'Ispanaklı Mercimek Çorbası (Kış)', 'Kabak Çorbası',
    'Karidesli Makarna', 'Karnabahar Çorbası (Sonbahar)', 'Arpa Çorbası', 'Brüksel Lahanalı Zeytinyağlı', 'Karabuğday Pilavı'
  )
order by r.ad;
