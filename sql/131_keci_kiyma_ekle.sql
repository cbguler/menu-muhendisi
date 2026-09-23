-- KEÇİ KIYMA ekleme
-- KAYNAK: Kıyma-spesifik bir kayit bulunamadi (ne USDA'da "goat, ground"
-- ne TürKomp'ta ayri bir kayit var). Bahri onayiyla GENEL "Keçi eti,
-- çiğ" verisi (USDA FDC 175303 "Game meat, goat, raw", 28g'den 100g'e
-- olceklendi) kullanildi -- DOGRU TUR ama kiyma-spesifik DEGIL.
-- Kaynakta MAGNEZYUM, B5, B6, D, E, K icin veri YOKTU -- sutun
-- listesine dahil edilmedi (NULL kalacak).
-- Fiziksel alanlar: KEÇİ'nin kendi kayitlari (But var, digger
-- kesimler kontrol edilmedi) SIĞIR KIYMA mantigiyla tutarli tutuldu
-- (Kuzu/Koyun Kıyma ile AYNI desen).
insert into malzemeler (
  id, isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, mevsim, isi_iletkenlik,
  kalori, protein, yag, karbonhidrat, glisemik_indeks,
  sodyum_mg, lif_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b9_mcg, vitamin_b12_mcg, vitamin_c_mg,
  kalsiyum_mg, demir_mg, potasyum_mg,
  cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg,
  not_aciklama
) values (
  gen_random_uuid(), null, 1, 'KEÇİ KIYMA', 1, 3.93, 1,
  0.05, 0, 'Yıl boyunca', 0.53,
  110.7, 21.07, 2.36, 0, 0,
  83.21, 0, 0.71,
  0, 0.107, 0.5, 3.93,
  5, 1.14, 0,
  13.21, 2.86, 390.36,
  3.93, 182.5, 0.25, 0.036, 8.93,
  'Kiyma-spesifik veri bulunamadi -- USDA FDC 175303 (genel "Keçi eti, çiğ") kullanildi. Magnezyum/B5/B6/D/E/K: kaynakta veri yok.'
);
