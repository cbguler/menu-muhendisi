-- teshis_alerjen_listesi_bos.sql
--
-- AMAC: "Hariç tutulacak alerjenler" cok secim kutusunun bos cikmasinin
-- (kod tarafinda mantik dogru gorunuyor, daha once vejetaryen/vegan
-- filtresiyle basariyla test edilmisti) VERI kaynakli mi yoksa baska
-- bir sey mi oldugunu ayirt etmek icin.

-- 1) malzeme_alerjen tablosunda hic kayit var mi?
select count(*) as toplam_malzeme_alerjen_kaydi from malzeme_alerjen;

-- 2) alerjenler tablosunda tanimli kac FARKLI alerjen var?
select count(*) as toplam_tanimli_alerjen from alerjenler;
select ad from alerjenler order by ad;

-- 3) 485 global tarifin GERCEKTEN kullandigi malzemelerden kac tanesi
-- malzeme_alerjen'de alerjen kaydına sahip? (0 ise, sorun VERI
-- tarafinda -- alerjen atamalari hic yapilmamis ya da yanlis
-- malzeme_id'lere baglanmis)
select count(distinct rm.malzeme_id) as alerjenli_malzeme_kullanan_sayisi
from recete_malzemeleri rm
join receteler r on r.id = rm.recete_id
where r.isletme_id is null
  and rm.malzeme_id in (select malzeme_id from malzeme_alerjen);

-- 4) Ornek birkac malzeme_alerjen kaydi (ham -- kolon adlarini tahmin
-- etmeden, tabloyu oldugu gibi gormek icin)
select * from malzeme_alerjen limit 20;
