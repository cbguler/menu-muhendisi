-- 111_uretim_asamalari_grup2_parti3.sql
-- Grup 2, 3. parti (41-60 / 84). Ayni metodoloji.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Peynirli Kabak Böreği (50: 25+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Peynirli Kabak Böreği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Yufka Açma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 25, 5, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YUFKA', 'KABAK', 'FETA PEYNİRİ', 'TEREYAĞI', 'TAVUK YUMURTASI');

    -- 2) Peynirli Yaz Böreği (45: 22+23)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Peynirli Yaz Böreği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Yufka Açma)', 1, 22, 22, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 23, 5, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YUFKA', 'FETA PEYNİRİ', 'TAVUK YUMURTASI', 'TEREYAĞI');

    -- 3) Roka Soslu Makarna (25: 10+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Roka Soslu Makarna';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 15, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA', 'ROKA', 'ZEYTİNYAĞI', 'SARIMSAK');

    -- 4) Sade Ispanak Çorbası (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sade Ispanak Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ISPANAK', 'KURU SOĞAN', 'TEREYAĞI');

    -- 5) Sarımsaklı Domates Soslu Makarna (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sarımsaklı Domates Soslu Makarna';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA', 'DOMATES', 'KURU SOĞAN', 'SARIMSAK', 'ZEYTİNYAĞI');

    -- 6) Soya Kıymalı Zeytinyağlı Dolma (60: 20+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Soya Kıymalı Zeytinyağlı Dolma';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SOYA KIYMA', 'PİRİNÇ (HAM)', 'KIRMIZI BİBER', 'ZEYTİNYAĞI');

    -- 7) Sucuklu Pilav (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sucuklu Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'SUCUK', 'TEREYAĞI');

    -- 8) Tarhana Çorbası (Ev Usulü) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Tarhana Çorbası (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TARHANA', 'TEREYAĞI');

    -- 9) Tavuk Suyu Çorbası (Sade) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Tavuk Suyu Çorbası (Sade)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK SUYU', 'PİRİNÇ (HAM)', 'TAVUK YUMURTASI', 'LİMON SUYU');

    -- 10) Yayla Çorbası (Ev Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yayla Çorbası (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 20, 10, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'YOĞURT (TAM)', 'TEREYAĞI', 'TAZE NANE');

    -- 11) Yaz Domates Çorbası (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yaz Domates Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DOMATES', 'KURU SOĞAN', 'TEREYAĞI');

    -- 12) Yer Elması Zeytinyağlısı (45: 15+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yer Elması Zeytinyağlısı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 30, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YER ELMASI', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 13) Yulaflı Çorba (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yulaflı Çorba';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YULAF EZMESİ', 'TEREYAĞI');

    -- 14) Zeytinyağlı Bamya (Yaz) (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Bamya (Yaz)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BAMYA', 'DOMATES', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 15) Zeytinyağlı Barbunya Pilaki (Ev Usulü) (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BARBUNYA', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI', 'DOMATES');

    -- 16) Zeytinyağlı Bezelyeli Havuç (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Bezelyeli Havuç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BEZELYE', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 17) Zeytinyağlı Biber Dolması (70: 25+45)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Biber Dolması';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 45, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KIRMIZI BİBER', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 18) Zeytinyağlı Domates Dolması (55: 20+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Domates Dolması';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DOMATES', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 19) Rezene Çorbası (35: 10+25) -- Claude'un parti17'de ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Rezene Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('REZENE', 'TEREYAĞI', 'SÜT (TAM YAĞ)', 'KURU SOĞAN');

    -- 20) Sebzeli Quinoa Pilavı (25: 8+17) -- Claude'un parti17'de ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sebzeli Quinoa Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('QUINOA', 'HAVUÇ', 'BEZELYE', 'ZEYTİNYAĞI');

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
    'Peynirli Kabak Böreği', 'Peynirli Yaz Böreği', 'Roka Soslu Makarna', 'Sade Ispanak Çorbası', 'Sarımsaklı Domates Soslu Makarna',
    'Soya Kıymalı Zeytinyağlı Dolma', 'Sucuklu Pilav', 'Tarhana Çorbası (Ev Usulü)', 'Tavuk Suyu Çorbası (Sade)', 'Yayla Çorbası (Ev Usulü)',
    'Yaz Domates Çorbası', 'Yer Elması Zeytinyağlısı', 'Yulaflı Çorba', 'Zeytinyağlı Bamya (Yaz)', 'Zeytinyağlı Barbunya Pilaki (Ev Usulü)',
    'Zeytinyağlı Bezelyeli Havuç', 'Zeytinyağlı Biber Dolması', 'Zeytinyağlı Domates Dolması', 'Rezene Çorbası', 'Sebzeli Quinoa Pilavı'
  )
order by r.ad;
