-- 169a: Duzeltme oncesi teshis -- gercek pisirme asamasi eklemek icin
-- once mevcut malzeme listelerini goruyoruz (tahmin etmiyoruz).

-- 1) Giresun'un TAM malzeme listesi
select 'GIRESUN' as tarif, m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Giresun Usulü Mısır Ekmekli Peynirli Tabak'
  and r.isletme_id is null
union all
-- 2) Rize'nin TAM malzeme listesi
select 'RIZE' as tarif, m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Rize Usulü Mısır Ekmekli Kaymak Tabağı'
  and r.isletme_id is null
union all
-- 3) Kutuphanedeki bagimsiz "Mısır Ekmeği" tarifinin TAM malzeme
-- listesi -- gercek ekmek yapimi icin referans/sablon olarak
select 'MISIR EKMEĞİ (referans tarif)' as tarif, m.ad, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'Mısır Ekmeği'
  and r.isletme_id is null
order by tarif, ad;

-- 4) Ayni referans tarifin hazirlik_dakika ve porsiyon_sayisi'si
select ad, hazirlik_dakika, porsiyon_sayisi
from receteler
where ad in ('Giresun Usulü Mısır Ekmekli Peynirli Tabak',
             'Rize Usulü Mısır Ekmekli Kaymak Tabağı',
             'Mısır Ekmeği')
  and isletme_id is null;
