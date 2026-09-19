-- 107_uretim_asamalari_grup1_parti4.sql
-- Grup 1, 4. parti (31-50 / 73) -- ilk 20'lik parti. Ayni metodoloji.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Baharatlı Izgara Piliç Göğüs (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Baharatlı Izgara Piliç Göğüs';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİLİÇ GÖĞÜS (DERİSİZ)', 'ZEYTİNYAĞI', 'KEKİK');

    -- 2) Fırında Tavuk Kanat (45: 15+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Tavuk Kanat';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 30, 8, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK KANAT', 'ZEYTİNYAĞI', 'SARIMSAK');

    -- 3) Havuçlu Fırın Tavuk But (Bahar) (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuçlu Fırın Tavuk But (Bahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 40, 8, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK BUT', 'HAVUÇ', 'KURU SOĞAN', 'SARIMSAK', 'ZEYTİNYAĞI');

    -- 4) Hindi Sote (Ev Usulü) (35: 15+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Hindi Sote (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 5) Ispanaklı Yumurta (25: 10+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Yumurta';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Tavada Pişirme', 2, 15, 15, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ISPANAK', 'TAVUK YUMURTASI', 'KURU SOĞAN', 'TEREYAĞI');

    -- 6) Izgara Ahtapot (50: 15+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Ahtapot';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 35, 20, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('AHTAPOT', 'ZEYTİNYAĞI', 'LİMON SUYU', 'KEKİK');

    -- 7) Izgara Dana Böbrek (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Dana Böbrek';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 17, 17, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YENİLEBİLİR SAKATAT (DANA BÖBREK)', 'ZEYTİNYAĞI', 'KEKİK');

    -- 8) Izgara Dana Pirzola (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Dana Pirzola';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 20, 20, true, 'dogalgaz', 20, 70, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA PİRZOLA', 'ZEYTİNYAĞI', 'KEKİK');

    -- 9) Izgara Kalamar (25: 10+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Kalamar';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 15, 15, true, 'dogalgaz', 20, 80, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KALAMAR', 'ZEYTİNYAĞI', 'LİMON SUYU');

    -- 10) Izgara Palamut (Sonbahar) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Palamut (Sonbahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 20, 15, true, 'dogalgaz', 20, 75, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PALAMUT', 'ZEYTİNYAĞI', 'LİMON SUYU');

    -- 11) Izgara Piliç But (40: 15+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Piliç But';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Marinasyon)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 25, 20, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİLİÇ BUT', 'ZEYTİNYAĞI', 'LİMON SUYU', 'KEKİK');

    -- 12) Izgara Somon Fileto (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Somon Fileto';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 17, 15, true, 'dogalgaz', 20, 65, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SOMON', 'LİMON SUYU', 'ZEYTİNYAĞI');

    -- 13) Izgara Sığır Bonfile (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Sığır Bonfile';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 17, 17, true, 'dogalgaz', 20, 65, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SIĞIR BONFİLE', 'ZEYTİNYAĞI');

    -- 14) Izgara Sığır Pirzola (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Sığır Pirzola';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 20, 20, true, 'dogalgaz', 20, 70, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SIĞIR PİRZOLA', 'ZEYTİNYAĞI', 'KEKİK', 'SARIMSAK');

    -- 15) Kabak Dolması (Etli) (60: 25+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Dolması (Etli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK', 'DANA KIYMA', 'PİRİNÇ (HAM)', 'KURU SOĞAN');

    -- 16) Karides Güveç (Ege Usulü) (35: 12+23)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karides Güveç (Ege Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 23, 15, true, 'dogalgaz', 20, 85, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARİDES', 'DOMATES', 'KURU SOĞAN', 'SARIMSAK', 'ZEYTİNYAĞI');

    -- 17) Kerevizli Kuzu Yahnisi (60: 15+45)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Kuzu Yahnisi';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Yahni Pişirme', 2, 45, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (KOL)', 'KEREVİZ', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 18) Keçi Eti Güveç (100: 20+80)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Keçi Eti Güveç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 80, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KEÇİ ETİ (BUT)', 'PATATES', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 19) Kuzu Etli Kırmızı Mercimek Yemeği (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuzu Etli Kırmızı Mercimek Yemeği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 33, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (KOL)', 'KIRMIZI MERCİMEK', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 20) Kuşkonmazlı Dana Bonfile (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuşkonmazlı Dana Bonfile';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 65, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA BONFİLE', 'KUŞKONMAZ', 'ZEYTİNYAĞI', 'SARIMSAK');

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
    'Baharatlı Izgara Piliç Göğüs', 'Fırında Tavuk Kanat', 'Havuçlu Fırın Tavuk But (Bahar)', 'Hindi Sote (Ev Usulü)', 'Ispanaklı Yumurta',
    'Izgara Ahtapot', 'Izgara Dana Böbrek', 'Izgara Dana Pirzola', 'Izgara Kalamar', 'Izgara Palamut (Sonbahar)',
    'Izgara Piliç But', 'Izgara Somon Fileto', 'Izgara Sığır Bonfile', 'Izgara Sığır Pirzola', 'Kabak Dolması (Etli)',
    'Karides Güveç (Ege Usulü)', 'Kerevizli Kuzu Yahnisi', 'Keçi Eti Güveç', 'Kuzu Etli Kırmızı Mercimek Yemeği', 'Kuşkonmazlı Dana Bonfile'
  )
order by r.ad;
