-- 24_dogu_anadolu_malzemeleri_ekle.sql
--
-- Dogu Anadolu Bolgesi tarif partisi (VII. ve son parti) icin eksik tek
-- malzeme: OTLU PEYNIR (Van'a ozgu, yabani otlarla mayalanmis yari sert
-- peynir). Kategori 7 = SUT VE SUT URUNLERI. TULUM PEYNIRI ve BAL
-- zaten katalogda mevcuttu.

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values (
  null, 7, 'OTLU PEYNİR', 1.0, 2.5, 60,
  0.05, 4, 290, 20, 22, 2,
  0, 'Yıl boyunca', 0.4, 80,
  '3 Ağustos 2026, Doğu Anadolu bölgesi tarif partisi icin eklendi',
  12.00
)
on conflict do nothing;

-- OTLU PEYNIR bir sut urunudur.
insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'OTLU PEYNİR' and m.isletme_id is null and a.ad = 'Sut'
on conflict do nothing;
