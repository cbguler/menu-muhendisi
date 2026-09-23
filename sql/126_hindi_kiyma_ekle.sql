-- HINDI KIYMA ekleme
-- Beslenme kaynagi: USDA FDC 172850 "Turkey, ground, 93% lean/7% fat,
-- raw" (dogrudan 100g icin)
-- Operasyonel alanlar: ozgul_isi/fire_orani/saklama_isisi/mevsim/
-- isi_iletkenlik HINDI'nin kendi kurulu deseninden (Göğüs/Kanat/Bütün,
-- TAVUK'tan referans alinmisti) devam ediyor; bozulma_suresi ISE
-- DANA KIYMA/SIĞIR KIYMA'dan referans alindi (ikisi de 1 gun --
-- cekilmis etin YUZEY ALANI arttigi icin BUTUN kesimlerden (2-3 gun)
-- cok daha KISA raf omru).
-- BILEREK BOS BIRAKILAN (TAHMIN EDILMEYEN): yuzey_alani (dana/sığir
-- kiymada da NULL), varsayilan_fiyat_eur (piyasa verisi).
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
  gen_random_uuid(), null, 1, 'HİNDİ KIYMA', 1, 3.18, 1,
  0.05, 0, 'Yıl boyunca', 0.53,
  150, 18.7, 8.3, 0, 0,
  69, 0, 0, 2.2,
  22, 0.07, 0.19, 5.4,
  1, 0.35, 7, 1.2,
  0, 0.4, 0.11, 0,
  21, 1.2, 21, 213,
  2.5, 193, 0.11, 0.01, 19
);
-- vitamin_b7_mcg (biyotin), iyot_mcg: USDA kaydinda veri YOK, sutun
-- listesine dahil edilmedi (NULL kalacak).
