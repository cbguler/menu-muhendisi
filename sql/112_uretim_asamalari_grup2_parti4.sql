-- 112_uretim_asamalari_grup2_parti4.sql
-- Grup 2, 4. (SON) parti (61-83 / 84 -- "İç Pilav" HARIC, kaynak
-- bulunamadi). Ayni metodoloji. Zeytinyagli sebze yemekleri
-- genelde orta-uzun sure hafif kaynatma/pisirme (90C), tam kaynama
-- degil -- sebzenin dokusu/rengi korunsun diye.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Zeytinyağlı Enginar (İlkbahar) (50: 15+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Enginar (İlkbahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ENGİNAR', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 2) Zeytinyağlı Havuç (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Havuç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 6, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HAVUÇ', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 3) Zeytinyağlı Ispanak (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Ispanak';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 6, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ISPANAK', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 4) Zeytinyağlı Kabak (Yaz) (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kabak (Yaz)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 5) Zeytinyağlı Kabak Dolması (55: 20+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kabak Dolması';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 6) Zeytinyağlı Karalahana (Sonbahar) (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Karalahana (Sonbahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 33, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARALAHANA', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 7) Zeytinyağlı Kereviz (Bahar) (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kereviz (Bahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 33, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KEREVİZ', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 8) Zeytinyağlı Kuru Fasulye (Soğuk) (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Kuru Fasulye (Soğuk)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 33, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KURU FASULYE', 'DOMATES', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 9) Zeytinyağlı Lahana Dolması (65: 25+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Lahana Dolması';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('LAHANA', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 10) Zeytinyağlı Patatesli Havuç (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Patatesli Havuç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATATES', 'HAVUÇ', 'ZEYTİNYAĞI');

    -- 11) Zeytinyağlı Patlıcan (Yaz) (50: 15+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Patlıcan (Yaz)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATLICAN', 'DOMATES', 'KURU SOĞAN', 'SARIMSAK', 'ZEYTİNYAĞI');

    -- 12) Zeytinyağlı Pırasa (Bahar) (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Pırasa (Bahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 33, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PIRASA', 'PİRİNÇ (HAM)', 'HAVUÇ', 'ZEYTİNYAĞI');

    -- 13) Zeytinyağlı Semizotu (35: 10+25)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Semizotu';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 6, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SEMİZOTU', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 14) Zeytinyağlı Soya Fasulyesi (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Soya Fasulyesi';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SOYA FASULYESİ', 'DOMATES', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 15) Zeytinyağlı Taze Bakla (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Taze Bakla';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BAKLA', 'ZEYTİNYAĞI', 'TAZE SOĞAN');

    -- 16) Zeytinyağlı Taze Fasulye (Ev Usulü) (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Taze Fasulye (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAZE FASULYE', 'DOMATES', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 17) Zeytinyağlı Yaprak Sarma (Ev Usulü) (90: 30+60)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Yaprak Sarma (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Sarma)', 1, 30, 30, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 60, 10, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SALAMURA YAPRAK', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 18) İrmik Çorbası (Ev Usulü) (20: 5+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İrmik Çorbası (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 15, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('İRMİK', 'TEREYAĞI');

    -- 19) İşkembe Çorbası (90: 20+70)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İşkembe Çorbası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 70, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YENİLEBİLİR SAKATAT (DANA İŞKEMBE)', 'SARIMSAK', 'TEREYAĞI');

    -- 20) Şehriye Çorbası (Sade) (20: 5+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Şehriye Çorbası (Sade)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Çorba Pişirme', 2, 15, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ŞEHRİYE', 'TEREYAĞI');

    -- 21) Şehriyeli Bahar Pilavı (30: 10+20) -- Bahri'nin ilk ekran goruntusundeki tarif!
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Şehriyeli Bahar Pilavı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'ŞEHRİYE', 'TEREYAĞI');

    -- 22) Şehriyeli Bulgur Pilavı (Ev Usulü) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Şehriyeli Bulgur Pilavı (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BULGUR', 'ŞEHRİYE', 'TEREYAĞI');

    -- 23) Zeytinyağlı Siyah Fasulye (55: 15+40) -- Claude'un parti17'de ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Siyah Fasulye';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SİYAH FASULYE', 'DOMATES', 'KURU SOĞAN', 'ZEYTİNYAĞI');

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
    'Zeytinyağlı Enginar (İlkbahar)', 'Zeytinyağlı Havuç', 'Zeytinyağlı Ispanak', 'Zeytinyağlı Kabak (Yaz)', 'Zeytinyağlı Kabak Dolması',
    'Zeytinyağlı Karalahana (Sonbahar)', 'Zeytinyağlı Kereviz (Bahar)', 'Zeytinyağlı Kuru Fasulye (Soğuk)', 'Zeytinyağlı Lahana Dolması', 'Zeytinyağlı Patatesli Havuç',
    'Zeytinyağlı Patlıcan (Yaz)', 'Zeytinyağlı Pırasa (Bahar)', 'Zeytinyağlı Semizotu', 'Zeytinyağlı Soya Fasulyesi', 'Zeytinyağlı Taze Bakla',
    'Zeytinyağlı Taze Fasulye (Ev Usulü)', 'Zeytinyağlı Yaprak Sarma (Ev Usulü)', 'İrmik Çorbası (Ev Usulü)', 'İşkembe Çorbası', 'Şehriye Çorbası (Sade)',
    'Şehriyeli Bahar Pilavı', 'Şehriyeli Bulgur Pilavı (Ev Usulü)', 'Zeytinyağlı Siyah Fasulye'
  )
order by r.ad;
