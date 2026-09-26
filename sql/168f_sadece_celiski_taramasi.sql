-- SADECE celiski taramasi (168e'nin 1. sorgusu, ayri calistirmak icin)
select r.ad, r.hazirlik_talimati
from receteler r
where r.isletme_id is null
  and position('şlem' in r.hazirlik_talimati) > 0
  and lower(substring(
        r.hazirlik_talimati
        from position('şlem' in r.hazirlik_talimati)
        for 40
      )) like '%yok%'
  and (
      r.hazirlik_talimati ilike '%erit%' or
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
