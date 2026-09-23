-- TAVUK KIYMA ekleme
-- Beslenme kaynagi: USDA FDC 171116 "Chicken, ground, raw" (112g
-- porsiyondan 100g'a olceklendi)
-- Operasyonel alanlar: ozgul_isi/fire_orani/saklama_isisi/mevsim/
-- isi_iletkenlik TAVUK'un kendi CUT-LEVEL (Göğüs/Kanat, Bütün'ün
-- whole-bird degerleri DEGIL) deseninden devam ediyor; bozulma_suresi
-- ISE DANA/SIĞIR/HINDI KIYMA'dan referans alindi (1 gun -- cekilmis
-- etin kisa raf omru), TAVUK'un kendi BUTUN kaydinin (2 gun) degil.
-- BILEREK BOS BIRAKILAN: yuzey_alani (dana/sığir/hindi kiymada da
-- NULL), varsayilan_fiyat_eur (piyasa verisi).
insert into malzemeler (
  id, isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, mevsim, isi_iletkenlik,
  kalori, protein, yag, karbonhidrat, glisemik_indeks,
  sodyum_mg, lif_g, seker_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg,
  vitamin_c_mg, vitamin_e_mg, vitamin_k_mcg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg,
  cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg
) values (
  gen_random_uuid(), null, 1, 'TAVUK KIYMA', 1, 3.18, 1,
  0.05, 0, 'Yıl boyunca', 0.54,
  142.9, 17.41, 8.13, 0, 0,
  60, 0, 0, 2.32,
  0, 0.107, 0.241, 5.54,
  1.07, 0.51, 0.98, 0.56,
  0, 0.27, 0.80,
  5.98, 0.82, 20.98, 521.96,
  1.43, 178.03, 0.063, 0.018, 10.18
);
-- vitamin_d_mcg, vitamin_b7_mcg (biyotin), iyot_mcg: kaynakta veri
-- YOK, sutun listesine dahil edilmedi (NULL kalacak).
