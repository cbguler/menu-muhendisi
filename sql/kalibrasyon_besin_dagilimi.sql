-- Kalibrasyon sorgusu: TUM 27 genisletilmis besin ogesi (+ 5 temel
-- alan) icin, GERCEK tarif havuzunun urettigi degerlerin dagilimini
-- (min/ortalama/medyan/maks) hesaplar. Bu, hedef araliklarini
-- "kabaca tahmin" yerine gercek veriye dayali kalibre etmemizi
-- saglayacak.
--
-- NOT: Bu sorgu TEK BIR TARIFIN toplam degerini hesaplar (100g degil,
-- tarifin GERCEK porsiyon miktari). Bir ogun (ör. Ana Yemek + Yardimci
-- + Tamamlayici) YAKLASIK 3 tarifin TOPLAMI oldugu icin, "per ogun"
-- makul bir aralik icin bu sonuclari kabaca 2-3 ile carpmak
-- gerekebilir -- ama once TEK TARIF bazinda gercek dagilimi gormemiz
-- lazim.

with tarif_toplamlari as (
  select
    r.id,
    r.ad,
    sum(rm.miktar_gram / 100.0 * m.kalori) as kalori,
    sum(rm.miktar_gram / 100.0 * m.protein) as protein,
    sum(rm.miktar_gram / 100.0 * m.yag) as yag,
    sum(rm.miktar_gram / 100.0 * m.karbonhidrat) as karbonhidrat,
    sum(rm.miktar_gram / 100.0 * m.sodyum_mg) as sodyum_mg,
    sum(rm.miktar_gram / 100.0 * m.lif_g) as lif_g,
    sum(rm.miktar_gram / 100.0 * m.seker_g) as seker_g,
    sum(rm.miktar_gram / 100.0 * m.doymus_yag_g) as doymus_yag_g,
    sum(rm.miktar_gram / 100.0 * m.vitamin_a_mcg) as vitamin_a_mcg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b1_mg) as vitamin_b1_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b2_mg) as vitamin_b2_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b3_mg) as vitamin_b3_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b5_mg) as vitamin_b5_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b6_mg) as vitamin_b6_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b7_mcg) as vitamin_b7_mcg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b9_mcg) as vitamin_b9_mcg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_b12_mcg) as vitamin_b12_mcg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_c_mg) as vitamin_c_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_d_mcg) as vitamin_d_mcg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_e_mg) as vitamin_e_mg,
    sum(rm.miktar_gram / 100.0 * m.vitamin_k_mcg) as vitamin_k_mcg,
    sum(rm.miktar_gram / 100.0 * m.kalsiyum_mg) as kalsiyum_mg,
    sum(rm.miktar_gram / 100.0 * m.demir_mg) as demir_mg,
    sum(rm.miktar_gram / 100.0 * m.magnezyum_mg) as magnezyum_mg,
    sum(rm.miktar_gram / 100.0 * m.potasyum_mg) as potasyum_mg,
    sum(rm.miktar_gram / 100.0 * m.cinko_mg) as cinko_mg,
    sum(rm.miktar_gram / 100.0 * m.fosfor_mg) as fosfor_mg,
    sum(rm.miktar_gram / 100.0 * m.bakir_mg) as bakir_mg,
    sum(rm.miktar_gram / 100.0 * m.manganez_mg) as manganez_mg,
    sum(rm.miktar_gram / 100.0 * m.selenyum_mcg) as selenyum_mcg,
    sum(rm.miktar_gram / 100.0 * m.iyot_mcg) as iyot_mcg
  from receteler r
  join recete_malzemeleri rm on rm.recete_id = r.id
  join malzemeler m on m.id = rm.malzeme_id
  where r.isletme_id is null
  group by r.id, r.ad
)
select
  'kalori' as alan, round(min(kalori)::numeric,1) as min_deger, round(avg(kalori)::numeric,1) as ort_deger,
  round(percentile_cont(0.5) within group (order by kalori)::numeric,1) as medyan,
  round(percentile_cont(0.9) within group (order by kalori)::numeric,1) as p90, round(max(kalori)::numeric,1) as maks_deger
from tarif_toplamlari
union all
select 'protein', round(min(protein)::numeric,2), round(avg(protein)::numeric,2), round(percentile_cont(0.5) within group (order by protein)::numeric,2), round(percentile_cont(0.9) within group (order by protein)::numeric,2), round(max(protein)::numeric,2) from tarif_toplamlari
union all
select 'yag', round(min(yag)::numeric,2), round(avg(yag)::numeric,2), round(percentile_cont(0.5) within group (order by yag)::numeric,2), round(percentile_cont(0.9) within group (order by yag)::numeric,2), round(max(yag)::numeric,2) from tarif_toplamlari
union all
select 'karbonhidrat', round(min(karbonhidrat)::numeric,2), round(avg(karbonhidrat)::numeric,2), round(percentile_cont(0.5) within group (order by karbonhidrat)::numeric,2), round(percentile_cont(0.9) within group (order by karbonhidrat)::numeric,2), round(max(karbonhidrat)::numeric,2) from tarif_toplamlari
union all
select 'sodyum_mg', round(min(sodyum_mg)::numeric,1), round(avg(sodyum_mg)::numeric,1), round(percentile_cont(0.5) within group (order by sodyum_mg)::numeric,1), round(percentile_cont(0.9) within group (order by sodyum_mg)::numeric,1), round(max(sodyum_mg)::numeric,1) from tarif_toplamlari
union all
select 'lif_g', round(min(lif_g)::numeric,2), round(avg(lif_g)::numeric,2), round(percentile_cont(0.5) within group (order by lif_g)::numeric,2), round(percentile_cont(0.9) within group (order by lif_g)::numeric,2), round(max(lif_g)::numeric,2) from tarif_toplamlari
union all
select 'seker_g', round(min(seker_g)::numeric,2), round(avg(seker_g)::numeric,2), round(percentile_cont(0.5) within group (order by seker_g)::numeric,2), round(percentile_cont(0.9) within group (order by seker_g)::numeric,2), round(max(seker_g)::numeric,2) from tarif_toplamlari
union all
select 'doymus_yag_g', round(min(doymus_yag_g)::numeric,2), round(avg(doymus_yag_g)::numeric,2), round(percentile_cont(0.5) within group (order by doymus_yag_g)::numeric,2), round(percentile_cont(0.9) within group (order by doymus_yag_g)::numeric,2), round(max(doymus_yag_g)::numeric,2) from tarif_toplamlari
union all
select 'vitamin_a_mcg', round(min(vitamin_a_mcg)::numeric,1), round(avg(vitamin_a_mcg)::numeric,1), round(percentile_cont(0.5) within group (order by vitamin_a_mcg)::numeric,1), round(percentile_cont(0.9) within group (order by vitamin_a_mcg)::numeric,1), round(max(vitamin_a_mcg)::numeric,1) from tarif_toplamlari
union all
select 'vitamin_b1_mg', round(min(vitamin_b1_mg)::numeric,3), round(avg(vitamin_b1_mg)::numeric,3), round(percentile_cont(0.5) within group (order by vitamin_b1_mg)::numeric,3), round(percentile_cont(0.9) within group (order by vitamin_b1_mg)::numeric,3), round(max(vitamin_b1_mg)::numeric,3) from tarif_toplamlari
union all
select 'vitamin_b2_mg', round(min(vitamin_b2_mg)::numeric,3), round(avg(vitamin_b2_mg)::numeric,3), round(percentile_cont(0.5) within group (order by vitamin_b2_mg)::numeric,3), round(percentile_cont(0.9) within group (order by vitamin_b2_mg)::numeric,3), round(max(vitamin_b2_mg)::numeric,3) from tarif_toplamlari
union all
select 'vitamin_b3_mg', round(min(vitamin_b3_mg)::numeric,2), round(avg(vitamin_b3_mg)::numeric,2), round(percentile_cont(0.5) within group (order by vitamin_b3_mg)::numeric,2), round(percentile_cont(0.9) within group (order by vitamin_b3_mg)::numeric,2), round(max(vitamin_b3_mg)::numeric,2) from tarif_toplamlari
union all
select 'vitamin_b5_mg', round(min(vitamin_b5_mg)::numeric,3), round(avg(vitamin_b5_mg)::numeric,3), round(percentile_cont(0.5) within group (order by vitamin_b5_mg)::numeric,3), round(percentile_cont(0.9) within group (order by vitamin_b5_mg)::numeric,3), round(max(vitamin_b5_mg)::numeric,3) from tarif_toplamlari
union all
select 'vitamin_b6_mg', round(min(vitamin_b6_mg)::numeric,3), round(avg(vitamin_b6_mg)::numeric,3), round(percentile_cont(0.5) within group (order by vitamin_b6_mg)::numeric,3), round(percentile_cont(0.9) within group (order by vitamin_b6_mg)::numeric,3), round(max(vitamin_b6_mg)::numeric,3) from tarif_toplamlari
union all
select 'vitamin_b7_mcg', round(min(vitamin_b7_mcg)::numeric,2), round(avg(vitamin_b7_mcg)::numeric,2), round(percentile_cont(0.5) within group (order by vitamin_b7_mcg)::numeric,2), round(percentile_cont(0.9) within group (order by vitamin_b7_mcg)::numeric,2), round(max(vitamin_b7_mcg)::numeric,2) from tarif_toplamlari
union all
select 'vitamin_b9_mcg', round(min(vitamin_b9_mcg)::numeric,1), round(avg(vitamin_b9_mcg)::numeric,1), round(percentile_cont(0.5) within group (order by vitamin_b9_mcg)::numeric,1), round(percentile_cont(0.9) within group (order by vitamin_b9_mcg)::numeric,1), round(max(vitamin_b9_mcg)::numeric,1) from tarif_toplamlari
union all
select 'vitamin_b12_mcg', round(min(vitamin_b12_mcg)::numeric,2), round(avg(vitamin_b12_mcg)::numeric,2), round(percentile_cont(0.5) within group (order by vitamin_b12_mcg)::numeric,2), round(percentile_cont(0.9) within group (order by vitamin_b12_mcg)::numeric,2), round(max(vitamin_b12_mcg)::numeric,2) from tarif_toplamlari
union all
select 'vitamin_c_mg', round(min(vitamin_c_mg)::numeric,1), round(avg(vitamin_c_mg)::numeric,1), round(percentile_cont(0.5) within group (order by vitamin_c_mg)::numeric,1), round(percentile_cont(0.9) within group (order by vitamin_c_mg)::numeric,1), round(max(vitamin_c_mg)::numeric,1) from tarif_toplamlari
union all
select 'vitamin_d_mcg', round(min(vitamin_d_mcg)::numeric,2), round(avg(vitamin_d_mcg)::numeric,2), round(percentile_cont(0.5) within group (order by vitamin_d_mcg)::numeric,2), round(percentile_cont(0.9) within group (order by vitamin_d_mcg)::numeric,2), round(max(vitamin_d_mcg)::numeric,2) from tarif_toplamlari
union all
select 'vitamin_e_mg', round(min(vitamin_e_mg)::numeric,2), round(avg(vitamin_e_mg)::numeric,2), round(percentile_cont(0.5) within group (order by vitamin_e_mg)::numeric,2), round(percentile_cont(0.9) within group (order by vitamin_e_mg)::numeric,2), round(max(vitamin_e_mg)::numeric,2) from tarif_toplamlari
union all
select 'vitamin_k_mcg', round(min(vitamin_k_mcg)::numeric,1), round(avg(vitamin_k_mcg)::numeric,1), round(percentile_cont(0.5) within group (order by vitamin_k_mcg)::numeric,1), round(percentile_cont(0.9) within group (order by vitamin_k_mcg)::numeric,1), round(max(vitamin_k_mcg)::numeric,1) from tarif_toplamlari
union all
select 'kalsiyum_mg', round(min(kalsiyum_mg)::numeric,1), round(avg(kalsiyum_mg)::numeric,1), round(percentile_cont(0.5) within group (order by kalsiyum_mg)::numeric,1), round(percentile_cont(0.9) within group (order by kalsiyum_mg)::numeric,1), round(max(kalsiyum_mg)::numeric,1) from tarif_toplamlari
union all
select 'demir_mg', round(min(demir_mg)::numeric,2), round(avg(demir_mg)::numeric,2), round(percentile_cont(0.5) within group (order by demir_mg)::numeric,2), round(percentile_cont(0.9) within group (order by demir_mg)::numeric,2), round(max(demir_mg)::numeric,2) from tarif_toplamlari
union all
select 'magnezyum_mg', round(min(magnezyum_mg)::numeric,1), round(avg(magnezyum_mg)::numeric,1), round(percentile_cont(0.5) within group (order by magnezyum_mg)::numeric,1), round(percentile_cont(0.9) within group (order by magnezyum_mg)::numeric,1), round(max(magnezyum_mg)::numeric,1) from tarif_toplamlari
union all
select 'potasyum_mg', round(min(potasyum_mg)::numeric,1), round(avg(potasyum_mg)::numeric,1), round(percentile_cont(0.5) within group (order by potasyum_mg)::numeric,1), round(percentile_cont(0.9) within group (order by potasyum_mg)::numeric,1), round(max(potasyum_mg)::numeric,1) from tarif_toplamlari
union all
select 'cinko_mg', round(min(cinko_mg)::numeric,2), round(avg(cinko_mg)::numeric,2), round(percentile_cont(0.5) within group (order by cinko_mg)::numeric,2), round(percentile_cont(0.9) within group (order by cinko_mg)::numeric,2), round(max(cinko_mg)::numeric,2) from tarif_toplamlari
union all
select 'fosfor_mg', round(min(fosfor_mg)::numeric,1), round(avg(fosfor_mg)::numeric,1), round(percentile_cont(0.5) within group (order by fosfor_mg)::numeric,1), round(percentile_cont(0.9) within group (order by fosfor_mg)::numeric,1), round(max(fosfor_mg)::numeric,1) from tarif_toplamlari
union all
select 'bakir_mg', round(min(bakir_mg)::numeric,3), round(avg(bakir_mg)::numeric,3), round(percentile_cont(0.5) within group (order by bakir_mg)::numeric,3), round(percentile_cont(0.9) within group (order by bakir_mg)::numeric,3), round(max(bakir_mg)::numeric,3) from tarif_toplamlari
union all
select 'manganez_mg', round(min(manganez_mg)::numeric,3), round(avg(manganez_mg)::numeric,3), round(percentile_cont(0.5) within group (order by manganez_mg)::numeric,3), round(percentile_cont(0.9) within group (order by manganez_mg)::numeric,3), round(max(manganez_mg)::numeric,3) from tarif_toplamlari
union all
select 'selenyum_mcg', round(min(selenyum_mcg)::numeric,2), round(avg(selenyum_mcg)::numeric,2), round(percentile_cont(0.5) within group (order by selenyum_mcg)::numeric,2), round(percentile_cont(0.9) within group (order by selenyum_mcg)::numeric,2), round(max(selenyum_mcg)::numeric,2) from tarif_toplamlari
union all
select 'iyot_mcg', round(min(iyot_mcg)::numeric,2), round(avg(iyot_mcg)::numeric,2), round(percentile_cont(0.5) within group (order by iyot_mcg)::numeric,2), round(percentile_cont(0.9) within group (order by iyot_mcg)::numeric,2), round(max(iyot_mcg)::numeric,2) from tarif_toplamlari;
