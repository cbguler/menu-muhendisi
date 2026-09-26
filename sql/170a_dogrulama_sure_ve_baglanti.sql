-- DOGRULAMA 1: hazirlik_dakika = asama sure_dakika toplami mi? 0 satir beklenir.
select r.ad, r.hazirlik_dakika, sum(ra.sure_dakika) as asama_toplami
from receteler r
join recete_asamalari ra on ra.recete_id = r.id
where r.ad in ('Giresun Usulü Mısır Ekmekli Peynirli Tabak',
               'Rize Usulü Mısır Ekmekli Kaymak Tabağı')
  and r.isletme_id is null
group by r.ad, r.hazirlik_dakika
having r.hazirlik_dakika <> sum(ra.sure_dakika);

-- DOGRULAMA 2: her isil_islem_mi=true asamada en az 1 bagli malzeme var mi? 0 satir beklenir.
select r.ad, ra.ad as asama_adi
from receteler r
join recete_asamalari ra on ra.recete_id = r.id
where r.ad in ('Giresun Usulü Mısır Ekmekli Peynirli Tabak',
               'Rize Usulü Mısır Ekmekli Kaymak Tabağı')
  and r.isletme_id is null
  and ra.isil_islem_mi = true
  and not exists (select 1 from asama_malzemeleri am where am.asama_id = ra.id);
