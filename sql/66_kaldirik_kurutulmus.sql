-- 66_kaldirik_kurutulmus.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): KALDIRIK icin arastirma tamamlandi.
--
-- TUR KIMLIGI: Kullanicinin verdigi alternatif isimlerle (hodan, ispit,
-- sigirdili, zilbit, galdirik) arama yapildi -- bu isimlerin halk
-- arasinda birbirinin yerine kullanildigi, ama farkli botanik turlere
-- (Trachystemon orientalis, Borago officinalis, Anchusa officinalis)
-- karsilik geldigi ortaya cikti. AKADEMIK LITERATURDE "Kaldirik" adi
-- OZELLIKLE Trachystemon orientalis'e baglaniyor (Iğdır Univ. makalesi
-- basligi: "...G. Don (Kaldırık)'ın Herbisidal ve Antifungal
-- Potansiyeli") -- bu kimlik kullanildi.
--
-- VERI: Ozbakır Özer & Aksoy (2019). Acta Sci. Pol. Hortorum Cultus
-- 18(4):157-167 -- Samsun/Ordu populasyonlarindan mineral analizi,
-- dogal biyolojik varyasyon araligindan (kullanicinin onayiyla) orta
-- nokta hesaplandi.
--
-- TAZE/KURUTULMUS BELIRSIZLIGI: tam metne erisilemedi, kesin
-- dogrulanamadi -- ama potasyum degeri (~4838mg/100g) mevcut taze
-- yabani otlarimizdan (Madimak K=448, Kaymacik K=631) 8-10 kat
-- yuksek oldugu icin KURUTULMUS oldugu guclu sekilde tahmin edildi.
-- Bu yuzden "KALDIRIK" (taze, henuz kaynaksiz) olarak DEGIL, ayri
-- "KALDIRIK (KURUTULMUŞ)" malzemesi olarak eklendi.

insert into malzemeler (isletme_id, kategori_id, ad, sodyum_mg, kalsiyum_mg, demir_mg,
  magnezyum_mg, potasyum_mg, cinko_mg, fosfor_mg, bakir_mg, manganez_mg, not_aciklama)
select null, 3, 'KALDIRIK (KURUTULMUŞ)', 44.2, 295.9, 36.9, 142.2, 4837.6, 4.95, 440.3, 1.05, 2.55,
  '13 Agustos 2026: Ozbakır Özer & Aksoy (2019), Acta Sci. Pol. Hortorum Cultus 18(4):157-167 -- Trachystemon orientalis (tur kimligi akademik literaturden), dogal populasyon varyasyon araliginin orta noktasi. Taze/kurutulmus ayrimi tam metinden dogrulanamadi, yuksek potasyum degeri nedeniyle kurutulmus kabul edildi.'
where not exists (select 1 from malzemeler m where m.ad = 'KALDIRIK (KURUTULMUŞ)' and m.isletme_id is null);

-- DOGRULAMA
select ad, potasyum_mg from malzemeler where isletme_id is null and ad = 'KALDIRIK (KURUTULMUŞ)';
