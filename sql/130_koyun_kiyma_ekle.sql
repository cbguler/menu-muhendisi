-- KOYUN KIYMA ekleme
-- KAYNAK: Ne USDA'da ("mutton, ground" yok, sadece "lamb, ground") ne
-- TürKomp'ta ("Koyun eti, kıyma" yok -- ID siralamasi 46/48/49 sadece
-- Kol/Bel/Sırt'i kapsiyor, Kıyma icin bosluk yok) AYRI bir kayit
-- bulunamadi. BAHRI ONAYIYLA: KUZU KIYMA'nin (USDA FDC 174370, "Lamb,
-- ground, raw") degerleri buraya KABA BIR TAHMIN olarak kopyalandi.
-- ONEMLI UYARI: Koyun (yetiskin) eti gercekte Kuzu'dan (genc)
-- TIPIK OLARAK daha yagli/farkli lezzet profiline sahiptir -- bu
-- kayit GERCEK/olcume dayali degil, sadece bir YER TUTUCUDUR.
-- Fiziksel alanlar KUZU KIYMA ile AYNI mantikla (SIĞIR KIYMA
-- referans) dolduruldu.
insert into malzemeler (
  id, isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, mevsim, isi_iletkenlik,
  kalori, protein, yag, karbonhidrat, glisemik_indeks,
  sodyum_mg, lif_g, seker_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg,
  vitamin_c_mg, vitamin_d_mcg, vitamin_e_mg, vitamin_k_mcg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg,
  cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg,
  not_aciklama
) values (
  gen_random_uuid(), null, 1, 'KOYUN KIYMA', 1, 3.93, 1,
  0.05, 0, 'Yıl boyunca', 0.53,
  285.7, 16.79, 23.57, 0, 0,
  60, 0, 0, 10.36,
  0, 0.107, 0.214, 6.07,
  0.64, 0.14, 18.21, 2.36,
  0, 0.11, 0.21, 3.57,
  16.07, 1.57, 21.43, 225,
  3.46, 159.29, 0.107, 0.036, 18.93,
  'TAHMINI VERI -- ayri bir Koyun kaynagi BULUNAMADI, KUZU KIYMA (USDA FDC 174370) degerleri kopyalandi. Gercek olcum degil.'
);
