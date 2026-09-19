-- 110_uretim_asamalari_grup2_parti2.sql
-- Grup 2, 2. parti (21-40 / 84). Ayni metodoloji.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Karnıbahar Çorbası (35: 10+25) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnıbahar Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARNIBAHAR', 'TEREYAĞI', 'SÜT (TAM YAĞ)', 'KURU SOĞAN');

    -- 2) Kaşarlı Bulgur Pilavı (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kaşarlı Bulgur Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BULGUR', 'KAŞAR PEYNİRİ', 'TEREYAĞI');

    -- 3) Kaşarlı Fırın Makarna (40: 15+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kaşarlı Fırın Makarna';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Haşlama+Karıştırma)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 25, 5, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA', 'KAŞAR PEYNİRİ', 'TEREYAĞI');

    -- 4) Kaşarlı Şehriyeli Pilav (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kaşarlı Şehriyeli Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'ŞEHRİYE', 'KAŞAR PEYNİRİ', 'TEREYAĞI');

    -- 5) Kerevizli Çorba (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Çorba';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KEREVİZ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 6) Kestaneli Sonbahar Pilavı (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kestaneli Sonbahar Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'KESTANE', 'TEREYAĞI');

    -- 7) Konserve Bezelyeli Makarna (25: 10+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Konserve Bezelyeli Makarna';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 15, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA', 'KONSERVE BEZELYE', 'TEREYAĞI');

    -- 8) Kuşkonmaz Çorbası (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuşkonmaz Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUŞKONMAZ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 9) Kırmızı Mercimek Çorbası (Ev Usulü) (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Mercimek Çorbası (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KIRMIZI MERCİMEK', 'KURU SOĞAN', 'TEREYAĞI');

    -- 10) Kırmızı Mercimekli Pilav (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Mercimekli Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'KIRMIZI MERCİMEK', 'KURU SOĞAN', 'TEREYAĞI');

    -- 11) Mercimekli Bulgur Pilavı (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mercimekli Bulgur Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BULGUR', 'YEŞİL MERCİMEK', 'KURU SOĞAN', 'TEREYAĞI');

    -- 12) Mısır Çorbası (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mısır Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KONSERVE MISIR', 'KURU SOĞAN', 'TEREYAĞI');

    -- 13) Mısırlı Yaz Pilavı (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mısırlı Yaz Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'KONSERVE MISIR', 'TEREYAĞI');

    -- 14) Naneli Bulgur Pilavı (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Naneli Bulgur Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BULGUR', 'KURU NANE', 'TEREYAĞI');

    -- 15) Nohutlu Pilav (Ev Usulü) (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohutlu Pilav (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'NOHUT', 'TEREYAĞI');

    -- 16) Pancar Çorbası (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pancar Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PANCAR', 'KURU SOĞAN', 'TEREYAĞI');

    -- 17) Patatesli Sebze Çorbası (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patatesli Sebze Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATATES', 'HAVUÇ', 'KURU SOĞAN', 'TEREYAĞI');

    -- 18) Kestane Mantarlı Pirinç Pilavı (35: 10+25) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kestane Mantarlı Pirinç Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'KESTANE MANTARI', 'TEREYAĞI');

    -- 19) Mung Fasulyeli Pilav (35: 10+25) -- Claude'un parti17'de ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mung Fasulyeli Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MUNG FASULYESİ', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'TEREYAĞI');

    -- 20) Pazılı Nohut Yemeği (50: 15+35) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pazılı Nohut Yemeği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PAZI', 'NOHUT', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

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
    'Karnıbahar Çorbası', 'Kaşarlı Bulgur Pilavı', 'Kaşarlı Fırın Makarna', 'Kaşarlı Şehriyeli Pilav', 'Kerevizli Çorba',
    'Kestaneli Sonbahar Pilavı', 'Konserve Bezelyeli Makarna', 'Kuşkonmaz Çorbası', 'Kırmızı Mercimek Çorbası (Ev Usulü)', 'Kırmızı Mercimekli Pilav',
    'Mercimekli Bulgur Pilavı', 'Mısır Çorbası', 'Mısırlı Yaz Pilavı', 'Naneli Bulgur Pilavı', 'Nohutlu Pilav (Ev Usulü)',
    'Pancar Çorbası', 'Patatesli Sebze Çorbası', 'Kestane Mantarlı Pirinç Pilavı', 'Mung Fasulyeli Pilav', 'Pazılı Nohut Yemeği'
  )
order by r.ad;
