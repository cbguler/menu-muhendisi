-- 134_hazirlik_ikonlari_sutununu_kaldir.sql
-- Tarif Kutuphanesi ikon sistemi 23 Eylul 2026'da TAMAMEN KALDIRILDI
-- (ikonlar tarif icerigiyle sistematik uyusmuyordu). Kodda artik
-- kullanilmayan receteler.hazirlik_ikonlari sutunu (migration 76 ile
-- eklenmisti) kaldiriliyor.
-- DIKKAT: GERI ALINAMAZ -- sutundaki onbellek verisi silinir.
-- CALISTIRMADAN ONCE: projede bu sutunu okuyan kod kalmadigindan emin ol
-- (findstr kontrolu bos donmeli).

alter table receteler drop column if exists hazirlik_ikonlari;

-- Dogrulama: 0 satir donmeli.
select column_name from information_schema.columns
where table_name = 'receteler' and column_name = 'hazirlik_ikonlari';
