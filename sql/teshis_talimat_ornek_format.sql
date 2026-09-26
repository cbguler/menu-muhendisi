-- teshis_talimat_ornek_format.sql
-- Format referansi: iyi ornek kabul edilen 2 tarifin GERCEK talimat metni.
-- Yeni talimatlar bu metinlerin yapisi birebir kopyalanarak yazilacak.
-- Salt okunur.

select ad, hazirlik_talimati
from receteler
where isletme_id is null
  and ad in ('Roka Salatası (Parmesanlı)', 'Pastırmalı Yumurta')
order by ad;
