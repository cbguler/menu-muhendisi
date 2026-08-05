-- 34_pide_kornison_ekle.sql
--
-- Kullanicinin bulduğu gercek eksiklik: "İskender Kebap" pide icermiyordu
-- (geleneksel tarifte etin altina serilen kucuk dogranmis pide parcalari
-- vazgecilmezdir), kornison tursu da eksikti (geleneksel servis
-- garnitürü). Ikisi de kataloga hic girmemisti.

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 8, 'PİDE', 0.4, 2.8, 3,
  0.05, 21, 275, 9, 3, 53,
  70, 'Yıl boyunca', 0.3, 150,
  '3 Ağustos 2026 eklendi (İskender Kebap icin -- etin altina serilen pide)',
  2.00
),
(
  null, 2, 'KORNİŞON TURŞU', 0.9, 3.8, 180,
  0.02, 4, 12, 0.5, 0.2, 2,
  15, 'Yıl boyunca', 0.5, 100,
  '3 Ağustos 2026 eklendi (İskender Kebap servis garnitürü)',
  3.50
)
on conflict do nothing;

insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'PİDE' and m.isletme_id is null and a.ad = 'Gluten'
on conflict do nothing;
