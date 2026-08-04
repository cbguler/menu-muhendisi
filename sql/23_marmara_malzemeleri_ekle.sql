-- 23_marmara_malzemeleri_ekle.sql
--
-- Marmara Bolgesi tarif partisi (VI. parti) icin eksik iki malzeme:
-- KESTANE (kategori 14, kuru meyve/kuruyemis) ve EKMEK KADAYIFI
-- (kategori 17, tatli/pasta malzemesi -- normal KADAYIF'tan farkli,
-- sungerimsi ekmek dokulu ayri bir urun).

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 14, 'KESTANE', 0.6, 2.5, 30,
  0.15, 4, 213, 2.4, 2.3, 45,
  60, 'Sonbahar-Kış', 0.3, null,
  '3 Ağustos 2026, Marmara bölgesi tarif partisi icin eklendi',
  4.50
),
(
  null, 17, 'EKMEK KADAYIFI', 0.35, 2.8, 5,
  0.05, 21, 265, 8, 3, 52,
  70, 'Yıl boyunca', 0.3, 150,
  '3 Ağustos 2026, Marmara bölgesi tarif partisi icin eklendi',
  2.50
)
on conflict do nothing;

-- EKMEK KADAYIFI bugday bazlidir -- gluten alerjeni.
insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'EKMEK KADAYIFI' and m.isletme_id is null and a.ad = 'Gluten'
on conflict do nothing;
