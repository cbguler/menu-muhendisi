-- 15_yufka_malzeme_ekle.sql
--
-- Kutuphane genisletme calismasinin ilk adimi: YUFKA (hamur isleri
-- kategorisinin -- borek, gozleme, baklava, mantı -- temel malzemesi)
-- kaynak dosyada yoktu, kataloga ekleniyor. Kategori 8 = UN VE TAHILLAR.
--
-- Degerler standart yufka (ince, buğday unlu, çigi) referans degerleridir;
-- ALIM FIYATI Agustos 2026 market arastirmasina dayanir (perakende paketli
-- urunler ~41-115 TL/kg araliginda; toptan/isletme alimi icin daha dusuk
-- bir referans olan ~65 TL/kg kullanildi, EUR/TRY~54).

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values (
  null, 8, 'YUFKA', 0.6, 2.8, 5,
  0.05, 4, 275, 8.5, 1.5, 56,
  70, 'Yıl boyunca', 0.35, 1200, '3 Ağustos 2026 kütüphane genişletme oturumunda eklendi',
  1.20
)
on conflict do nothing;

-- YUFKA glutensiz degildir -- alerjen baglantisini ekle.
insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'YUFKA' and m.isletme_id is null and a.ad = 'Gluten'
on conflict do nothing;
