-- hazirlik_ikonlari sutununun gercekten dolup dolmadigini kontrol et
select
    count(*) as toplam_tarif,
    count(hazirlik_ikonlari) as ikon_dolu_olan,
    count(*) filter (where hazirlik_ikonlari is null) as ikon_bos_olan
from receteler
where isletme_id is null
  and hazirlik_talimati is not null;

-- Ornek olarak "Marmara Usulü Yeşil Salata" (ilk basarili OK) icin
-- gercekten ne kaydedildigini gor
select ad, hazirlik_ikonlari
from receteler
where ad = 'Marmara Usulü Yeşil Salata';
