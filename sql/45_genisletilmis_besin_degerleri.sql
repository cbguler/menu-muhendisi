-- 45_genisletilmis_besin_degerleri.sql
--
-- Kullanicinin talebiyle (6 Agustos 2026): kalori/protein/yag/
-- karbonhidrat/GI disinda saglik acisindan onemli sayilan ek besin
-- degerleri ekleniyor. TUMU NULL/bos olarak basliyor -- gercek
-- degerler kademeli olarak (once en cok kullanilan malzemeler, sonra
-- geri kalani) arastirilip doldurulacak, bu migration sadece SEMAYI
-- kuruyor.
--
-- Glisemik Yuk (GL) buraya DAHIL DEGIL -- yeni veri gerektirmiyor,
-- mevcut GI ve karbonhidrattan HESAPLANIYOR (koda eklendi, ayri sutun
-- gerekmiyor).

alter table malzemeler
  -- Oncelikli 4 deger (kullanicinin hedef kitlesiyle -- diyabetliler,
  -- kalp-damar/bobrek hastalari -- dogrudan orten)
  add column if not exists sodyum_mg numeric,
  add column if not exists lif_g numeric,
  add column if not exists seker_g numeric,
  add column if not exists doymus_yag_g numeric,

  -- Vitaminler (tumu)
  add column if not exists vitamin_a_mcg numeric,
  add column if not exists vitamin_b1_mg numeric,
  add column if not exists vitamin_b2_mg numeric,
  add column if not exists vitamin_b3_mg numeric,
  add column if not exists vitamin_b5_mg numeric,
  add column if not exists vitamin_b6_mg numeric,
  add column if not exists vitamin_b7_mcg numeric,
  add column if not exists vitamin_b9_mcg numeric,
  add column if not exists vitamin_b12_mcg numeric,
  add column if not exists vitamin_c_mg numeric,
  add column if not exists vitamin_d_mcg numeric,
  add column if not exists vitamin_e_mg numeric,
  add column if not exists vitamin_k_mcg numeric,

  -- Mineraller (tumu)
  add column if not exists kalsiyum_mg numeric,
  add column if not exists demir_mg numeric,
  add column if not exists magnezyum_mg numeric,
  add column if not exists potasyum_mg numeric,
  add column if not exists cinko_mg numeric,
  add column if not exists fosfor_mg numeric,
  add column if not exists bakir_mg numeric,
  add column if not exists manganez_mg numeric,
  add column if not exists selenyum_mcg numeric,
  add column if not exists iyot_mcg numeric;

-- DOGRULAMA
select column_name, data_type
from information_schema.columns
where table_name = 'malzemeler'
  and column_name in (
    'sodyum_mg','lif_g','seker_g','doymus_yag_g',
    'vitamin_a_mcg','vitamin_b1_mg','vitamin_b2_mg','vitamin_b3_mg',
    'vitamin_b5_mg','vitamin_b6_mg','vitamin_b7_mcg','vitamin_b9_mcg',
    'vitamin_b12_mcg','vitamin_c_mg','vitamin_d_mcg','vitamin_e_mg','vitamin_k_mcg',
    'kalsiyum_mg','demir_mg','magnezyum_mg','potasyum_mg','cinko_mg',
    'fosfor_mg','bakir_mg','manganez_mg','selenyum_mcg','iyot_mcg'
  )
order by column_name;
