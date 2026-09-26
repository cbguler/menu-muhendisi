select 'GIRESUN' as tarif, m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Giresun Usulü Mısır Ekmekli Peynirli Tabak'
  and r.isletme_id is null
union all
select 'RIZE' as tarif, m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Rize Usulü Mısır Ekmekli Kaymak Tabağı'
  and r.isletme_id is null
union all
select 'MISIR EKMEĞİ (referans tarif)' as tarif, m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Mısır Ekmeği'
  and r.isletme_id is null
order by tarif, ad;
