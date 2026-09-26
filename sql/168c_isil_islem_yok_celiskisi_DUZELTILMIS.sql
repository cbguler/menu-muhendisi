-- ADIM 3/3 (DUZELTILMIS -- once gevsekti, artik tam ifadeyi ariyor):
-- "Isıl işlem yok" TAM ifadesini iceren AMA ayni zamanda erit/kizart/
-- pisir/kavur/hasla/firinla/izgara/kaynat/buğula gibi kelimeler de
-- gecen tarifler -- gercek celiski adaylari.
select r.ad, r.hazirlik_talimati
from receteler r
where r.isletme_id is null
  and r.hazirlik_talimati ilike '%ısıl işlem yok%'
  and (
      r.hazirlik_talimati ilike '%eritilmiş%' or
      r.hazirlik_talimati ilike '%eritin%' or
      r.hazirlik_talimati ilike '%erit %' or
      r.hazirlik_talimati ilike '%kızart%' or
      r.hazirlik_talimati ilike '%kavur%' or
      r.hazirlik_talimati ilike '%pişir%' or
      r.hazirlik_talimati ilike '%haşla%' or
      r.hazirlik_talimati ilike '%fırınla%' or
      r.hazirlik_talimati ilike '%ızgara%' or
      r.hazirlik_talimati ilike '%kaynat%' or
      r.hazirlik_talimati ilike '%buğula%' or
      r.hazirlik_talimati ilike '%kızgın%'
  )
order by r.ad;
