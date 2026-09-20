-- 121b_alerjen_isimleri_kalan_duzeltme.sql
--
-- 121'deki 10 guncellemeden 6'si (buyuk/kucuk harf uyusmazligi
-- yuzunden WHERE kosulu eslesmedi, hata vermeden 0 satir etkiledi)
-- calismadi. Bu sefer case-INSENSITIVE (lower()) eslestirme
-- kullanildi -- kirilganligi tamamen ortadan kaldirir.

update alerjenler set ad = 'Kabuklular (Crustacea)' where lower(ad) = lower('Kabuklu Deniz Ürünü');
update alerjenler set ad = 'Sert kabuklu meyveler' where lower(ad) = lower('Sert Kabuklu Yemiş');
update alerjenler set ad = 'Kükürt dioksit ve sülfitler' where lower(ad) = lower('Sülfit (SO2)');
update alerjenler set ad = 'Süt ve süt ürünleri (laktoz dâhil)' where lower(ad) = lower('Süt');
update alerjenler set ad = 'Yer fıstığı' where lower(ad) = lower('Yer Fıstığı');
update alerjenler set ad = 'Yumuşakçalar' where lower(ad) = lower('Yumuşakça');

-- DOGRULAMA -- 14 satirin TAMAMI artik resmi metinle esit olmali
select ad from alerjenler order by ad;
