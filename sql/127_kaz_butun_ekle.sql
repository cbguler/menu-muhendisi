-- KAZ BUTUN (derili, cig) ekleme
-- Beslenme kaynagi: USDA FDC 174470 "Goose, domesticated, meat and
-- skin, raw" (85g porsiyondan 100g'a olceklendi)
-- Operasyonel alanlar: mevcut KAZ ETİ (BUT/GÖĞÜS) kayitlariyla TUTARLI
-- olacak sekilde BILEREK BOS BIRAKILDI (Bahri onayi) -- SADECE
-- kategori_id (1) dolduruldu.
-- NOT: Kaynak veride yagsizlik/vitamin D/E/K/biyotin/iyot/seker_g
-- eksikti -- sutun listesine dahil edilmedi (NULL kalacak).
insert into malzemeler (
  id, isletme_id, kategori_id, ad,
  kalori, protein, yag, karbonhidrat, glisemik_indeks,
  sodyum_mg, lif_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg,
  vitamin_c_mg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg,
  cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg
) values (
  gen_random_uuid(), null, 1, 'KAZ ETİ (BÜTÜN, DERİLİ)',
  370.6, 15.88, 33.65, 0, 0,
  73.06, 0, 9.76,
  17.06, 0.082, 0.247, 3.65,
  1.29, 0.388, 4, 0.34,
  4.24,
  12, 2.47, 18, 308,
  1.76, 234, 0.27, 0.024, 14.35
);
