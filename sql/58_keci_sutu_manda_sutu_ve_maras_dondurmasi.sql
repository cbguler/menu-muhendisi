-- 58_keci_sutu_manda_sutu_ve_maras_dondurmasi.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici KEÇİ SÜTÜ ve MANDA
-- SÜTÜ'nün mutlaka kataloga eklenmesini istedi (hic yoktu), ve
-- SALEP/MARAŞ DONDURMASI'nin derinlemesine arastirilmasini istedi.
--
-- KEÇİ SÜTÜ, MANDA SÜTÜ: USDA FoodData Central'dan (Milk, goat, fluid
-- / Milk, indian buffalo, fluid), yeni malzeme olarak eklendi.
--
-- SALEP: zaten TürKomp kaynakli gercek verisi vardi (kalori/protein/
-- karbonhidrat/lif/seker), SADECE yag alani (0 olarak, akademik
-- kaynaklarda -- Sezik 1967, Tekinsen&Guner 2010 -- yag icerigi hic
-- belirtilmemis) dolduruldu.
--
-- MARAŞ DONDURMASI: ana makrolar zaten TürKomp'tan doluydu, dokunulmadi.
-- TÜRKPATENT cografi isaret tescil belgesinden (No 344) hesaplanan
-- degerlerle (KEÇİ SÜTÜ + ŞEKER + SALEP karisimindan, sut yagi >=%4
-- standardina gore olceklenerek) SADECE bos olan mikrobesin (vitamin/
-- mineral) alanlari dolduruldu.
--
-- ONEMLI DUZELTME: ilk taslakta Vitamin D alani icin USDA'nin IU
-- birimindeki degerini yanlislikla mcg olarak almisim (KEÇİ SÜTÜ icin
-- 51 IU'yu 51 mcg sanmis -- gercek deger 1.3 mcg). Bu, calistirmadan
-- ONCE fark edilip duzeltildi.

insert into malzemeler (isletme_id, kategori_id, ad, kalori, protein, yag, karbonhidrat,
  sodyum_mg, lif_g, seker_g, doymus_yag_g, vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg,
  vitamin_b3_mg, vitamin_b5_mg, vitamin_b9_mcg, vitamin_b12_mcg, vitamin_c_mg, vitamin_d_mcg,
  vitamin_e_mg, vitamin_k_mcg, kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg, cinko_mg,
  fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg, not_aciklama)
select null, 5, v.ad, v.kalori, v.protein, v.yag, v.karbonhidrat, v.sodyum_mg, v.lif_g,
  v.seker_g, v.doymus_yag_g, v.vitamin_a_mcg, v.vitamin_b1_mg, v.vitamin_b2_mg, v.vitamin_b3_mg,
  v.vitamin_b5_mg, v.vitamin_b9_mcg, v.vitamin_b12_mcg, v.vitamin_c_mg, v.vitamin_d_mcg,
  v.vitamin_e_mg, v.vitamin_k_mcg, v.kalsiyum_mg, v.demir_mg, v.magnezyum_mg, v.potasyum_mg,
  v.cinko_mg, v.fosfor_mg, v.bakir_mg, v.manganez_mg, v.selenyum_mcg,
  '13 Agustos 2026: Bizim katalogumuzda hic bulunmuyordu, kullanicinin istegiyle eklendi. USDA FoodData Central''dan.'
from (values
  ('KEÇİ SÜTÜ', 69.0, 3.56, 4.14, 4.45, 50.0, 0.0, 4.45, 2.667, 57.0, 0.048, 0.138, 0.277, 0.31, 1.0, 0.07, 1.3, 1.3, 0.07, 0.3, 134.0, 0.05, 14.0, 204.0, 0.3, 111.0, 0.046, 0.018, 1.4),
  ('MANDA SÜTÜ', 97.0, 3.75, 6.89, 5.18, 52.0, 0.0, null, 4.597, 53.0, 0.052, 0.135, 0.091, 0.192, 6.0, 0.36, 2.3, null, null, null, 169.0, 0.12, 31.0, 178.0, 0.22, 117.0, 0.046, 0.018, null)
) as v(ad, kalori, protein, yag, karbonhidrat, sodyum_mg, lif_g, seker_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg, vitamin_b5_mg, vitamin_b9_mcg,
  vitamin_b12_mcg, vitamin_c_mg, vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg, kalsiyum_mg,
  demir_mg, magnezyum_mg, potasyum_mg, cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg)
where not exists (select 1 from malzemeler m where m.ad = v.ad and m.isletme_id is null);

-- SALEP: sadece yag alani (digerleri zaten TürKomp'tan doluydu)
update malzemeler set yag = 0,
  not_aciklama = '13 Agustos 2026: Diger degerler zaten TürKomp kaynakli. Yag alani akademik kaynaklarda (Sezik 1967; Tekinsen&Guner 2010) hic belirtilmedigi icin 0 kabul edildi.'
where isletme_id is null and ad = 'SALEP' and yag is null;

-- MARAŞ DONDURMASI: sadece bos olan mikrobesin alanlari (ana makrolar zaten TürKomp'tan dolu)
update malzemeler set
  glisemik_indeks = coalesce(glisemik_indeks, 12.58),
  sodyum_mg = coalesce(sodyum_mg, 48.4942),
  lif_g = coalesce(lif_g, 1.6986),
  seker_g = coalesce(seker_g, 22.7787),
  vitamin_a_mcg = coalesce(vitamin_a_mcg, 55.0725),
  vitamin_b5_mg = coalesce(vitamin_b5_mg, 0.3143),
  vitamin_b9_mcg = coalesce(vitamin_b9_mcg, 0.9662),
  vitamin_c_mg = coalesce(vitamin_c_mg, 1.256),
  vitamin_d_mcg = coalesce(vitamin_d_mcg, 1.256),
  vitamin_e_mg = coalesce(vitamin_e_mg, 0.0676),
  vitamin_k_mcg = coalesce(vitamin_k_mcg, 0.2899),
  kalsiyum_mg = coalesce(kalsiyum_mg, 129.6536),
  demir_mg = coalesce(demir_mg, 0.0576),
  magnezyum_mg = coalesce(magnezyum_mg, 13.5821),
  potasyum_mg = coalesce(potasyum_mg, 197.4714),
  cinko_mg = coalesce(cinko_mg, 0.2917),
  fosfor_mg = coalesce(fosfor_mg, 107.2464),
  bakir_mg = coalesce(bakir_mg, 0.0457),
  manganez_mg = coalesce(manganez_mg, 0.0181),
  selenyum_mcg = coalesce(selenyum_mcg, 1.3527),
  not_aciklama = 'TÜRKPATENT cografi isaret tescil belgesinden (No 344) hesaplandi -- ayrintilar Excel notunda.'
where isletme_id is null and ad = 'MARAŞ DONDURMASI';

-- DOGRULAMA
select count(*) as toplam_malzeme from malzemeler where isletme_id is null;
