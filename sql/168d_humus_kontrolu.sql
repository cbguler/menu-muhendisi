-- EK: Humus (Ev Usulu) tarifinin malzeme listesi -- "hazir humus
-- mayasi" ifadesinin kok nedenini kontrol etmek icin.
select r.ad, r.hazirlik_talimati
from receteler r
where r.ad = 'Humus (Ev Usulü)'
  and r.isletme_id is null;
