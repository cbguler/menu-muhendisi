-- KUZU KIYMA ekleme
-- Beslenme kaynagi: USDA FDC 174370 "Lamb, ground, raw" (28g
-- porsiyondan 100g'a olceklendi)
-- Operasyonel alanlar: KUZU'nun kendi mevcut kayitlari (Bel/But/Kol/
-- Sırt) TUMU BOS oldugu icin, Bahri onayiyla SIĞIR KIYMA'dan
-- referans alindi (ayni "kirmizi et + kiyma" mantigi, kisa raf omru
-- dahil).
-- BILEREK BOS BIRAKILAN: yuzey_alani (sığır kiymada da NULL),
-- varsayilan_fiyat_eur (piyasa verisi).
insert into malzemeler (
  id, isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, mevsim, isi_iletkenlik,
  kalori, protein, yag, karbonhidrat, glisemik_indeks,
  sodyum_mg, lif_g, seker_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg,
  vitamin_c_mg, vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg,
  cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg
) values (
  gen_random_uuid(), null, 1, 'KUZU KIYMA', 1, 3.93, 1,
  0.05, 0, 'Yıl boyunca', 0.53,
  285.7, 16.79, 23.57, 0, 0,
  60, 0, 0, 10.36,
  0, 0.107, 0.214, 6.07,
  0.64, 0.14, 18.21, 2.36,
  0, 0.11, 0.21, 3.57,
  16.07, 1.57, 21.43, 225,
  3.46, 159.29, 0.107, 0.036, 18.93
);
