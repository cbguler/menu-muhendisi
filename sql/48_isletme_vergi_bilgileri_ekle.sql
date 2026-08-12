-- 48_isletme_vergi_bilgileri_ekle.sql
--
-- Kullanici talebi (12 Agustos 2026, Oturum 11): fatura adresinin
-- altina Vergi Dairesi ve Vergi Numarasi da eklensin. isletmeler
-- tablosuna iki yeni nullable sutun.
--
-- NOT: kasitli olarak text tipi kullanildi (numeric/integer DEGIL) --
-- vergi numaralari basinda sifir olabilir (ör. "0123456789") ve bu
-- durumda numeric tip basindaki sifiri SESSIZCE siler, veri kaybina yol
-- acar. Ayrica format/uzunluk kisitlamasi (ör. "tam 10 hane") EKLENMEDI
-- -- bireysel (TCKN, 11 hane) ile kurumsal (VKN, 10 hane) vergi
-- numaralari farkli uzunlukta olabiliyor, kullanicidan hangisinin
-- gecerli oldugu netlesmeden kisitlama eklemek yanlis kayitlari
-- reddedebilirdi.

alter table isletmeler add column if not exists vergi_dairesi text;
alter table isletmeler add column if not exists vergi_no text;

comment on column isletmeler.vergi_dairesi is 'Fatura icin vergi dairesi adi';
comment on column isletmeler.vergi_no is 'Vergi kimlik numarasi (VKN/TCKN) -- text, basindaki sifir korunur';

-- DOGRULAMA
select column_name, data_type, is_nullable
from information_schema.columns
where table_name = 'isletmeler'
order by ordinal_position;
