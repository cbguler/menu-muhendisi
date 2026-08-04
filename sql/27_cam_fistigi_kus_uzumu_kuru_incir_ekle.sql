-- 27_cam_fistigi_kus_uzumu_kuru_incir_ekle.sql
--
-- Kullanicinin bulduğu gercek eksiklik: zeytinyagli dolma/sarma, asure
-- ve ic pilav gibi klasik tariflerde vazgecilmez olan CAM FISTIGI
-- (dolmalik fistik) ve KUS UZUMU kataloga hic girmemisti. KURU INCIR de
-- eksikti (KURU KAYISI ve KURU UZUM zaten mevcuttu). Kategori 14 =
-- KURU MEYVELER VE KURUYEMIS.
--
-- CAM FISTIGI fiyati Agustos 2026 arastirmasina dayanir: perakende hizli
-- teslimat ~3700 TL/kg -- isletme toptan alimi icin biraz altinda bir
-- referans (~3300 TL/kg) kullanildi (EUR/TRY~54).

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 14, 'ÇAM FISTIĞI', 0.6, 2.0, 180,
  0.02, 21, 673, 14, 68, 13,
  15, 'Sonbahar', 0.3, null,
  '3 Ağustos 2026 eklendi (zeytinyağlı dolma/sarma, iç pilav icin vazgecilmez)',
  61.00
),
(
  null, 14, 'KUŞ ÜZÜMÜ', 0.65, 1.8, 365,
  0.02, 21, 283, 2.4, 0.4, 71,
  55, 'Yıl boyunca', 0.25, null,
  '3 Ağustos 2026 eklendi (zeytinyağlı dolma/sarma, ic pilav, asure icin)',
  4.50
),
(
  null, 14, 'KURU İNCİR', 0.65, 2.0, 180,
  0.05, 21, 249, 3.3, 0.9, 64,
  61, 'Yıl boyunca', 0.25, null,
  '3 Ağustos 2026 eklendi',
  5.50
)
on conflict do nothing;
