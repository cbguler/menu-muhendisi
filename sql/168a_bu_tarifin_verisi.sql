-- ADIM 1/3: Giresun tarifinin tam verisi
select r.ad, r.hazirlik_talimati, r.hazirlik_dakika
from receteler r
where r.ad = 'Giresun Usulü Mısır Ekmekli Peynirli Tabak'
  and r.isletme_id is null;
