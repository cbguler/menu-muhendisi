-- 185b_teshis_malzeme_fire.sql
-- SALT OKUNUR teshis. Kutuphane tariflerinde kullanilan her malzemenin fire orani ve
-- kac tarifte kullanildigi (fire degerlerinin gozden gecirilmesi icin). 185'ten AYRI calistir.

select
  m.ad,
  m.fire_orani,
  count(distinct rm.recete_id) as tarif_sayisi
from public.malzemeler m
join public.recete_malzemeleri rm on rm.malzeme_id = m.id
join public.receteler r on r.id = rm.recete_id and r.isletme_id is null
group by m.ad, m.fire_orani
order by tarif_sayisi desc, m.ad;
