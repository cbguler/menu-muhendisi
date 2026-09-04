-- 78_isletme_standart_uretim_porsiyonu.sql
--
-- Bahri'nin talebi (3 Eylul 2026): Yillik Menu pop-up'indaki maliyet
-- hesabi icin kullanilan "10 porsiyon" STANDART URETIM PARTISI degeri
-- (pages/0_Yillik_Menu.py icinde PORSIYON_STANDART) sabit kodlanmisti.
-- Isletmeler arasinda tipik uretim parti buyuklugu farkli olabilir
-- (ör. bir restoran 10, bir hastane/huzurevi 50-200 porsiyon
-- uretebilir) -- bu yuzden isletme bazli, degistirilebilir bir
-- varsayilan olarak eklendi. Mevcut TUM isletmeler icin varsayilan
-- 10 (eski davranisla BIREBIR ayni, geriye donuk kirilma yok).
--
-- NOT: bu, receteler.porsiyon_sayisi (75 numarali migration'da
-- YENI receteler icin SABIT 10 yapilan, tarif olusturma anindaki alan)
-- ile KARISTIRILMAMALI -- bu AYRI bir kavram: Yillik Menu'nun GUN
-- BAZLI maliyet GORUNTULEME olcegi.

alter table isletmeler
    add column if not exists standart_uretim_porsiyonu integer not null default 10;

-- DOGRULAMA
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_name = 'isletmeler' and column_name = 'standart_uretim_porsiyonu';
