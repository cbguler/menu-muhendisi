-- 105_uretim_asamalari_grup1_parti2.sql
--
-- Grup 1 icin 2. parti (11-20 / 73). Ayni metodoloji: Hazirlik +
-- Isil Islem, sure toplami hazirlik_dakika'ya esit, sicakliklar
-- yemegin ic sicakligi (firin ayari degil).

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Antep Fıstıklı Kavurma (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Antep Fıstıklı Kavurma';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kavurma', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'ANTEP FISTIĞI', 'KURU SOĞAN');

    -- 2) Bademli Fırın Tavuk But (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bademli Fırın Tavuk But';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 40, 8, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK BUT', 'BADEM (İÇ)', 'ZEYTİNYAĞI');

    -- 3) Bahar Sebzeli Tavuk Sote (35: 15+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bahar Sebzeli Tavuk Sote';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'BEZELYE', 'TAZE SOĞAN', 'SARIMSAK', 'ZEYTİNYAĞI', 'DOMATES');

    -- 4) Bezelyeli Dana Yahnisi (60: 15+45)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Dana Yahnisi';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Yahni Pişirme', 2, 45, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA BUT', 'BEZELYE', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 5) Bezelyeli Kuzu Yemeği (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Kuzu Yemeği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (KOL)', 'BEZELYE', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 6) Biber Dolması (Etli) (65: 25+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Biber Dolması (Etli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KIRMIZI BİBER', 'DANA KIYMA', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'DOMATES');

    -- 7) Brokolili Tavuk Sote (Sporcu) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Brokolili Tavuk Sote (Sporcu)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'BROKOLİ', 'SARIMSAK', 'ZEYTİNYAĞI');

    -- 8) Enginar Dolması (Etli) (55: 20+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Dolması (Etli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ENGİNAR', 'DANA KIYMA', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'LİMON SUYU');

    -- 9) Enginar Kalpli Tavuk Güveç (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Kalpli Tavuk Güveç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'ENGİNAR KALBİ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 10) Enginarlı Kuzu Yahnisi (60: 15+45)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginarlı Kuzu Yahnisi';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Yahni Pişirme', 2, 45, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (KOL)', 'ENGİNAR', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI', 'LİMON SUYU');

end $$;

-- DOGRULAMA (fan-out hatasi olmayan, alt-sorgulu temiz versiyon)
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
    'Antep Fıstıklı Kavurma', 'Bademli Fırın Tavuk But', 'Bahar Sebzeli Tavuk Sote', 'Bezelyeli Dana Yahnisi', 'Bezelyeli Kuzu Yemeği',
    'Biber Dolması (Etli)', 'Brokolili Tavuk Sote (Sporcu)', 'Enginar Dolması (Etli)', 'Enginar Kalpli Tavuk Güveç', 'Enginarlı Kuzu Yahnisi'
  )
order by r.ad;
