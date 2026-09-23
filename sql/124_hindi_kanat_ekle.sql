-- HINDI ETI (KANAT, DERISIZ) ekleme
-- Beslenme kaynagi: USDA FDC 171497 "Turkey, whole, wing, meat only,
-- raw" (dogrudan 100g icin)
-- Operasyonel alanlar (kategori_id, yogunluk, ozgul_isi, fire_orani,
-- saklama_isisi, mevsim, isi_iletkenlik, bozulma_suresi): TAVUK KANAT
-- kaydindan REFERANS alindi -- ayni kumes hayvani kategorisi ve ayni
-- kesim tipi oldugu icin makul, ama TAHMIN degil, DOGRULAMA gerekebilir.
-- NOT DOLDURULMAYAN (BILEREK BOS BIRAKILDI -- TAHMIN EDILMEDI):
--   yuzey_alani: hindi, tavuktan cok daha buyuk oldugu icin TAVUK
--     KANAT'in degeri (30) buraya KOPYALANMADI -- gercek deger
--     bilinmiyor.
--   varsayilan_fiyat_eur: piyasa/zaman'a bagli bir deger, tahmin
--     edilmedi.
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
  gen_random_uuid(), null, 1, 'HİNDİ ETİ (KANAT, DERİSİZ)', 1, 3.18, 3,
  0.05, 0, 'Yıl boyunca', 0.54,
  115, 23.7, 1.5, 0.14, 0,
  113, 0, 0.05, 0.29,
  6, 0.04, 0.14, 9.9,
  0.78, 0.81, 7, 0.63,
  0, 0.1, 0.06, 0,
  11, 0.73, 28, 242,
  1.3, 201, 0.07, 0.01, 22.7
);
