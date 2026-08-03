-- 16_yufka_fiziksel_degerler_duzeltme.sql
--
-- 15_yufka_malzeme_ekle.sql'deki fiziksel deger tahminlerim (yogunluk,
-- saklama isisi, yuzey alani vb.) kullanicinin kaynak dosyadaki komsu
-- satirlarla (EKMEK, BAZLAMA, PITA EKMEGI, MEKSIKA YUFLASI -- ayni
-- "ince hamur/yufka turu" grubu) paylastigi ekran goruntuleri sayesinde
-- daha isabetli kalibre edildi. Kalori/protein/yag/karbonhidrat/
-- glisemik indeks/mevsim/fiyat zaten dogruydu, degistirilmiyor.

update malzemeler
set
  yogunluk = 0.5,
  ozgul_isi = 3,
  bozulma_suresi = 5,
  fire_orani = 0.05,
  saklama_isisi = 21,
  isi_iletkenlik = null,
  yuzey_alani = 75
where ad = 'YUFKA' and isletme_id is null;
