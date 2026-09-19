-- 108_uretim_asamalari_grup1_parti5.sql
-- Grup 1, 5. (SON) parti (51-73 / 73). Ayni metodoloji -- bu parti
-- Grup 1'i TAMAMEN tamamlar.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Kırmızı Biberli Kıyma Sote (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Biberli Kıyma Sote';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'KIRMIZI BİBER', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 2) Lahana Dolması (Etli) (70: 25+45)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Lahana Dolması (Etli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 45, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('LAHANA', 'DANA KIYMA', 'PİRİNÇ (HAM)', 'KURU SOĞAN');

    -- 3) Limonlu Fırın Levrek (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Limonlu Fırın Levrek';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 28, 6, true, 'elektrik', 20, 65, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('LEVREK', 'LİMON', 'ZEYTİNYAĞI', 'KURU SOĞAN');

    -- 4) Madımaklı Kavurma (35: 12+23)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Madımaklı Kavurma';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kavurma', 2, 23, 15, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (KOL)', 'MADIMAK', 'KURU SOĞAN', 'TEREYAĞI');

    -- 5) Midye Dolma (Pilavlı) (60: 20+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Midye Dolma (Pilavlı)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MİDYE', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 6) Mısırlı Tavuk Sote (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mısırlı Tavuk Sote';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'KONSERVE MISIR', 'KIRMIZI BİBER', 'ZEYTİNYAĞI');

    -- 7) Nohutlu Sığır Kavurma (Bahar) (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohutlu Sığır Kavurma (Bahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kavurma', 2, 40, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SIĞIR KIYMA', 'NOHUT', 'KURU SOĞAN', 'DOMATES', 'TEREYAĞI');

    -- 8) Pastırmalı Kavurma (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pastırmalı Kavurma';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kavurma', 2, 17, 17, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PASTIRMA', 'DANA BONFİLE', 'KURU SOĞAN', 'DOMATES');

    -- 9) Patatesli Dana Güveç (75: 20+55)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patatesli Dana Güveç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 55, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA BUT', 'PATATES', 'HAVUÇ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 10) Patlıcanlı Kıyma Musakka (60: 20+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patlıcanlı Kıyma Musakka';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 40, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'PATLICAN', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 11) Pırasalı Kıymalı Bahar Yemeği (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pırasalı Kıymalı Bahar Yemeği';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'PIRASA', 'KURU SOĞAN', 'PİRİNÇ (HAM)', 'ZEYTİNYAĞI');

    -- 12) Roka Soslu Izgara Tavuk (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Roka Soslu Izgara Tavuk';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 17, 17, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'ZEYTİNYAĞI', 'LİMON SUYU', 'SARIMSAK');

    -- 13) Sade Kuzu Güveç (Et Suyu ile) (70: 15+55)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sade Kuzu Güveç (Et Suyu ile)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 55, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (BUT)', 'ET SUYU', 'KURU SOĞAN', 'HAVUÇ');

    -- 14) Semizotlu Etli Yemek (40: 12+28)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Semizotlu Etli Yemek';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 28, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'SEMİZOTU', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 15) Soya Kıymalı Patlıcan Musakka (Etsiz) (50: 15+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Soya Kıymalı Patlıcan Musakka (Etsiz)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SOYA KIYMA', 'PATLICAN', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 16) Soyalı Biberli Sote (Etsiz) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Soyalı Biberli Sote (Etsiz)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 17, 17, true, 'dogalgaz', 20, 85, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SOYA KIYMA', 'KIRMIZI BİBER', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 17) Taze Bakla Kavurma (Etli) (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Bakla Kavurma (Etli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kavurma', 2, 33, 15, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'BAKLA', 'TAZE SOĞAN', 'TEREYAĞI');

    -- 18) Taze Fasulyeli Kuzu Güveç (İlkbahar) (65: 15+50)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Fasulyeli Kuzu Güveç (İlkbahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 50, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (BUT)', 'TAZE FASULYE', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 19) Taze Fasulyeli Tavuk Güveç (45: 12+33)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Fasulyeli Tavuk Güveç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 33, 10, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK BUT', 'TAZE FASULYE', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 20) Yer Elmalı Kuzu Yahnisi (65: 15+50)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yer Elmalı Kuzu Yahnisi';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Yahni Pişirme', 2, 50, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (KOL)', 'YER ELMASI', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 21) Yoğurtlu Kebap (Ev Usulü) (35: 12+23) -- yogurt SOGUK servis edilir, isil islem disi birakildi
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yoğurtlu Kebap (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Şekil Verme + Yoğurt Sosu)', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 23, 20, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'DOMATES', 'TEREYAĞI');

    -- 22) Nar Ekşili Dana Rosto (90: 20+70) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nar Ekşili Dana Rosto';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Rosto Pişirme', 2, 70, 10, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA ROSTO', 'NAR EKŞİSİ', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 23) Otlu Izgara Çipura (30: 12+18) -- Claude'un parti16'da ekledigi tarif
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Otlu Izgara Çipura';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 18, 15, true, 'dogalgaz', 20, 65, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ÇİPURA', 'ZEYTİNYAĞI', 'LİMON SUYU', 'TAZE FESLEĞEN');

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
    'Kırmızı Biberli Kıyma Sote', 'Lahana Dolması (Etli)', 'Limonlu Fırın Levrek', 'Madımaklı Kavurma', 'Midye Dolma (Pilavlı)',
    'Mısırlı Tavuk Sote', 'Nohutlu Sığır Kavurma (Bahar)', 'Pastırmalı Kavurma', 'Patatesli Dana Güveç', 'Patlıcanlı Kıyma Musakka',
    'Pırasalı Kıymalı Bahar Yemeği', 'Roka Soslu Izgara Tavuk', 'Sade Kuzu Güveç (Et Suyu ile)', 'Semizotlu Etli Yemek', 'Soya Kıymalı Patlıcan Musakka (Etsiz)',
    'Soyalı Biberli Sote (Etsiz)', 'Taze Bakla Kavurma (Etli)', 'Taze Fasulyeli Kuzu Güveç (İlkbahar)', 'Taze Fasulyeli Tavuk Güveç', 'Yer Elmalı Kuzu Yahnisi',
    'Yoğurtlu Kebap (Ev Usulü)', 'Nar Ekşili Dana Rosto', 'Otlu Izgara Çipura'
  )
order by r.ad;

-- Grup 1 GENEL SAYIM (bu partiden sonra 73/73 olmali)
select
    (select count(distinct r.id) from receteler r join mutfak_kategorileri mk on mk.id=r.mutfak_kategori_id
     join recete_asamalari ra on ra.recete_id=r.id where r.isletme_id is null and mk.sira=1) as grup1_asamasi_olan,
    (select count(*) from receteler r join mutfak_kategorileri mk on mk.id=r.mutfak_kategori_id
     where r.isletme_id is null and mk.sira=1) as grup1_toplam;
