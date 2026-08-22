-- 63_ebegumeci_ege_otlari.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin "Ege otlari" arama
-- onerisiyle bulunan Kaya, Incekara, Nemli (2004, YYU Zir. Fak. Derg.
-- 14(1):1-6) makalesinden EBEGÜMECİ icin Bakir ve Manganez dolduruldu
-- (Demir/Cinko zaten baska kaynaktan doluydu, dokunulmadi).
--
-- ONEMLI: ayni makalenin Na/K/Ca/Mg/P degerleri KULLANILMADI --
-- kaynagin kendi metniyle karsilastirildiginda (ör. ispanak K
-- karsilastirmasi) birim tutarsizligi/hatasi tespit edildi, tahmin/
-- duzeltme yapilmadan atlandi.

update malzemeler set
  bakir_mg = coalesce(bakir_mg, 1.71),
  manganez_mg = coalesce(manganez_mg, 5.46)
where isletme_id is null and ad = 'EBEGÜMECİ';

-- DOGRULAMA
select ad, demir_mg, cinko_mg, bakir_mg, manganez_mg from malzemeler where isletme_id is null and ad = 'EBEGÜMECİ';
