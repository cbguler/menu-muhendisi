-- 26_karalahane_isim_duzeltme.sql
--
-- "KARALAHANE" yanlis yazilmisti, dogrusu "KARALAHANA" (lahana kelimesi
-- "lahane" degil "lahana"). Tarifler ve malzeme_fiyat_gecmisi zaten
-- malzeme ID'sine bagli oldugu icin, sadece adi guncellemek yeterli --
-- hicbir baglanti bozulmaz.

update malzemeler
set ad = 'KARALAHANA'
where ad = 'KARALAHANE' and isletme_id is null;
