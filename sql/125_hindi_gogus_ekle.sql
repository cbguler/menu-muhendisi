-- HINDI GOGUS (derisiz, cig) ekleme
-- Kaynak: USDA FDC 174515 "Turkey, retail parts, breast, meat only, raw"
-- (85g porsiyondan 100g'a olceklendi)
-- NOT: kategori_id, fire_orani, bozulma_suresi, saklama_isisi, ozgul_isi
-- gibi beslenme-disi alanlar TAHMIN EDILMEDI -- bu migration SADECE
-- beslenme degerlerini dolduruyor. Digger zorunlu sutunlar varsa
-- Supabase INSERT hata verecektir -- o zaman eksik sutunlari birlikte
-- tamamlariz.
insert into malzemeler (
  id, ad, kalori, protein, yag, karbonhidrat, gi,
  sodyum_mg, lif_g, seker_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg,
  vitamin_c_mg, vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg,
  cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg
) values (
  gen_random_uuid(), 'HİNDİ ETİ (GÖĞÜS, DERİSİZ)', 114, 23.29, 2.35, 0, 0,
  74.0, 0, 0, 0.34,
  5.06, 0.047, 0.165, 10.35,
  1.05, 0.81, 7.1, 1.29,
  0, 0.2, 0.09, 0,
  9.06, 0.77, 27.06, 267.06,
  1.16, 185.06, 0.059, 0.012, 22.12
);
-- vitamin_b7_mcg (biyotin) ve iyot_mcg: USDA kaydinda veri YOK,
-- sutun listesine dahil edilmedi (NULL kalacak).
