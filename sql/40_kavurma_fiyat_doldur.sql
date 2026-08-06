-- 40_kavurma_fiyat_doldur.sql
--
-- 38_kavurma_malzeme_ekle.sql, malzemeler.varsayilan_fiyat_eur alanina
-- 50.50 yazdi ama malzeme_fiyat_gecmisi'ne (uygulamanin gercekte okudugu
-- tablo) hic islemedi -- bu yuzden Tarif Kutuphanesi'nde "Eksik fiyat:
-- KAVURMA" gorunuyordu. Bu script o adimi tamamliyor (36/37 numarali
-- Iskender duzeltmelerindeki ayni adimin tekrari).

insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
select i.id, m.id, m.varsayilan_fiyat_eur, 'Varsayılan (tek perakende kaynağa dayanır, doğrulanması önerilir)'
from isletmeler i
cross join malzemeler m
where m.ad = 'KAVURMA'
  and m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id and mfg.malzeme_id = m.id
  );

-- DOGRULAMA
select i.ad as isletme, m.ad as malzeme, mfg.fiyat_eur
from malzeme_fiyat_gecmisi mfg
join isletmeler i on i.id = mfg.isletme_id
join malzemeler m on m.id = mfg.malzeme_id
where m.ad = 'KAVURMA';
