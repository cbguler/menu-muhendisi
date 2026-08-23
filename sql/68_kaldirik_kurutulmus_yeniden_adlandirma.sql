-- 68_kaldirik_kurutulmus_yeniden_adlandirma.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin talebiyle iki
-- KALDIRIK kaydi (Borage/taze ve Trachystemon/kurutulmus) ayri ayri
-- tutulacak -- karisikligi onlemek icin kurutulmus (Trachystemon)
-- kaydi tur adiyla yeniden adlandirildi.

update malzemeler set ad = 'KALDIRIK (KURUTULMUŞ, TRACHYSTEMON)'
where isletme_id is null and ad = 'KALDIRIK (KURUTULMUŞ)';

-- DOGRULAMA
select ad from malzemeler where isletme_id is null and ad like 'KALDIRIK%';
