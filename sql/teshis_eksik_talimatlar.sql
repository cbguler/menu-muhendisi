-- Hic talimat olmayanlar
select id, ad, 'YOK' as durum, 0 as satir_sayisi
from receteler
where isletme_id is null
  and (hazirlik_talimati is null or trim(hazirlik_talimati) = '')

union all

-- Talimat var ama cok kisa (5 satirdan az -- Hazirlik+en az 1 adim+Isil Islem+Paralel+Sure Ozeti'nin altinda)
select id, ad, 'KISA' as durum,
       array_length(string_to_array(hazirlik_talimati, E'\n'), 1) as satir_sayisi
from receteler
where isletme_id is null
  and hazirlik_talimati is not null
  and trim(hazirlik_talimati) != ''
  and array_length(string_to_array(hazirlik_talimati, E'\n'), 1) < 5

order by durum, ad;
