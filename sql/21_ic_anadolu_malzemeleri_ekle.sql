-- 21_ic_anadolu_malzemeleri_ekle.sql
--
-- Ic Anadolu Bolgesi tarif partisi (V. parti) icin eksik uc malzeme:
-- BUGDAY (TAM TANE) (kategori 8, kelke icin), TARHANA (kategori 8,
-- fermente corba bazi) ve BAMYA (kategori 2, taze sebze).

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 8, 'BUĞDAY (TAM TANE)', 0.78, 1.5, 365,
  0.05, 21, 340, 12, 2, 71,
  45, 'Yıl boyunca', 0.2, null,
  '3 Ağustos 2026, İç Anadolu bölgesi tarif partisi icin eklendi (keşkek)',
  0.50
),
(
  null, 8, 'TARHANA', 0.4, 1.8, 365,
  0.02, 21, 355, 12, 4, 65,
  50, 'Yıl boyunca', 0.2, null,
  '3 Ağustos 2026, İç Anadolu bölgesi tarif partisi icin eklendi',
  3.50
),
(
  null, 2, 'BAMYA', 0.75, 3.7, 7,
  0.1, 7, 33, 2, 0.2, 7,
  20, 'Yaz', 0.5, 100,
  '3 Ağustos 2026, İç Anadolu bölgesi tarif partisi icin eklendi',
  2.00
)
on conflict do nothing;
