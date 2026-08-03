-- 18_ege_malzemeleri_ekle.sql
--
-- Ege Bolgesi tarif partisi (II. parti) icin eksik dort malzeme:
-- BAKLA, PAZI, RADIKA (SEBZELER) ve BADEM (KURU MEYVELER VE KURUYEMIS).
-- Alim fiyatlari Agustos 2026 arastirmasina dayanir; badem icin
-- perakende marka fiyatlari (~600-900 TL/kg) yerine toptan/isletme
-- alimina daha yakin bir referans (~450-500 TL/kg) kullanildi.

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 2, 'BAKLA', 0.85, 3.5, 7,
  0.15, 7, 88, 7.6, 0.4, 15,
  40, 'İlkbahar', 0.5, 100,
  '3 Ağustos 2026, Ege bölgesi tarif partisi icin eklendi',
  1.50
),
(
  null, 2, 'PAZI', 0.3, 3.9, 7,
  0.15, 4, 19, 1.8, 0.2, 3.7,
  15, 'Sonbahar-Kış', 0.55, 150,
  '3 Ağustos 2026, Ege bölgesi tarif partisi icin eklendi',
  0.90
),
(
  null, 2, 'RADİKA', 0.3, 3.8, 5,
  0.2, 4, 23, 1.7, 0.3, 4.7,
  15, 'Kış-İlkbahar', 0.55, 100,
  '3 Ağustos 2026, Ege bölgesi tarif partisi icin eklendi (yabani ot)',
  1.80
),
(
  null, 14, 'BADEM', 0.6, 2.0, 180,
  0.05, 21, 579, 21, 50, 22,
  15, 'Sonbahar', 0.3, null,
  '3 Ağustos 2026, Ege bölgesi tarif partisi icin eklendi (toptan/isletme alimi referansi)',
  9.00
)
on conflict do nothing;

-- BADEM bir sert kabuklu yemis alerjenidir.
insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'BADEM' and m.isletme_id is null and a.ad = 'Sert Kabuklu Yemis'
on conflict do nothing;
