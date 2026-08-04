-- 25_yeni_malzemeler_fiyat_geriye_donuk_doldur.sql
--
-- Bolgesel genisleme oturumunda eklenen TUM yeni malzemeler icin,
-- 13_salatalik_fiyat_geriye_donuk_doldur.sql'deki AYNI mantik ile
-- geriye donuk fiyat doldurma. Her yeni malzeme kendi migration'inda
-- SADECE malzemeler.varsayilan_fiyat_eur'a sahip oldu, ama bu deger
-- mevcut isletmelerin kendi malzeme_fiyat_gecmisi'ne otomatik
-- kopyalanmiyor -- bu script SADECE bu 13 malzeme icin, henuz fiyati
-- olmayan her isletmeye varsayilan fiyati ekliyor (idempotent, malzeme
-- bazinda kontrol ediyor).
--
-- Kapsanan malzemeler: YUFKA, KARALAHANA, FINDIK, BAKLA, PAZI, RADİKA,
-- BADEM, İSOT, BUĞDAY (TAM TANE), TARHANA, BAMYA, KESTANE,
-- EKMEK KADAYIFI, OTLU PEYNİR.
-- (SALATALIK zaten 13_...sql ile ayrica halledilmisti, tekrar gerekmiyor.)

insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
select i.id, m.id, m.varsayilan_fiyat_eur, 'Varsayılan (bölgesel genişletme oturumu)'
from isletmeler i
cross join malzemeler m
where m.ad in (
  'YUFKA', 'KARALAHANA', 'FINDIK', 'BAKLA', 'PAZI', 'RADİKA', 'BADEM',
  'İSOT', 'BUĞDAY (TAM TANE)', 'TARHANA', 'BAMYA', 'KESTANE',
  'EKMEK KADAYIFI', 'OTLU PEYNİR'
)
  and m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id and mfg.malzeme_id = m.id
  );
