-- 17_karadeniz_malzemeleri_ekle.sql
--
-- Karadeniz Bolgesi tarif partisi icin eksik iki malzeme:
-- KARALAHANA (SEBZELER) ve FINDIK (KURU MEYVELER VE KURUYEMIS).
-- Alim fiyatlari Agustos 2026 arastirmasina dayanir: findik icin TMO
-- 2025-2026 kabuklu findik alim fiyati (Giresun kalite, %50 randiman)
-- 200 TL/kg kabuklu -> ic findik esdegeri icin serbest piyasa/perakende
-- referansi ~300 TL/kg (EUR/TRY~54); karalahane icin net hal verisi
-- bulunamadi, benzer yapragli sebzelerle (SALATALIK, lahana ailesi)
-- tutarli bir referans kullanildi.

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 2, 'KARALAHANA', 0.35, 3.9, 10,
  0.15, 4, 32, 2.8, 0.5, 5.5,
  15, 'Sonbahar-Kış', 0.55, 150,
  '3 Ağustos 2026, Karadeniz bölgesi tarif partisi icin eklendi',
  0.28
),
(
  null, 14, 'FINDIK', 0.65, 2.0, 180,
  0.05, 21, 628, 15, 61, 17,
  15, 'Sonbahar', 0.3, null,
  '3 Ağustos 2026, Karadeniz bölgesi tarif partisi icin eklendi (TMO 2025-2026 kabuklu findik alim fiyati referans alindi)',
  5.56
)
on conflict do nothing;

-- FINDIK bir sert kabuklu yemis alerjenidir.
insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'FINDIK' and m.isletme_id is null and a.ad = 'Sert Kabuklu Yemis'
on conflict do nothing;
