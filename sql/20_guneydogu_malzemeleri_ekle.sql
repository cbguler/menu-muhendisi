-- 20_guneydogu_malzemeleri_ekle.sql
--
-- Guneydogu Anadolu Bolgesi tarif partisi (IV. parti) icin eksik tek
-- malzeme: İSOT (Urfa biberi -- yagda islenmis, tatlimsi/dumanli kirmizi
-- biber, PUL BIBER'den farkli ayri bir baharat). Kategori 5 =
-- BAHARATLAR VE TATLANDIRICILAR.

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values (
  null, 5, 'İSOT', 0.35, 1.8, 365,
  0.02, 21, 280, 12, 10, 50,
  15, 'Yıl boyunca', 0.2, null,
  '3 Ağustos 2026, Güneydoğu Anadolu bölgesi tarif partisi icin eklendi',
  9.00
)
on conflict do nothing;
