-- HINDI ETI (GOGUS, DERISIZ) ekleme
-- Beslenme kaynagi: USDA FDC 174515 "Turkey, retail parts, breast, meat
-- only, raw" (85g porsiyondan 100g'a olceklendi)
-- Operasyonel alanlar (kategori_id, yogunluk, ozgul_isi, fire_orani,
-- saklama_isisi, mevsim, isi_iletkenlik, bozulma_suresi): TAVUK GOGUS
-- kaydindan REFERANS alindi -- ayni kumes hayvani kategorisi ve ayni
-- kesim tipi oldugu icin makul, ama TAHMIN degil, DOGRULAMA gerekebilir.
-- NOT DOLDURULMAYAN (BILEREK BOS BIRAKILDI -- TAHMIN EDILMEDI):
--   yuzey_alani: hindi, tavuktan cok daha buyuk oldugu icin TAVUK
--     GOGUS'un degeri (300) buraya KOPYALANMADI -- gercek deger
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
  gen_random_uuid(), null, 1, 'HİNDİ ETİ (GÖĞÜS, DERİSİZ)', 1, 3.18, 2,
  0.05, 0, 'Yıl boyunca', 0.54,
  114, 23.29, 2.35, 0, 0,
  74.0, 0, 0, 0.34,
  5.06, 0.047, 0.165, 10.35,
  1.05, 0.81, 7.1, 1.29,
  0, 0.2, 0.09, 0,
  9.06, 0.77, 27.06, 267.06,
  1.16, 185.06, 0.059, 0.012, 22.12
);
