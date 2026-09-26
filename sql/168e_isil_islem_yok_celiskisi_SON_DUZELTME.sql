-- ADIM (SON DUZELTME): "şlem" ("işlem" kelimesinin I/İ harfinden
-- etkilenmeyen kismi) ile "yok" kelimesinin yakinligini arayarak,
-- buyuk/kucuk I/İ farkindan BAGIMSIZ sekilde gercek celiskileri bulur.
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

-- EK KONTROL: Humus (Ev Usulu)'nun malzeme listesi -- "hazir humus
-- mayasi" ifadesinin kok nedenini gormek icin.
select m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Humus (Ev Usulü)'
  and r.isletme_id is null;
