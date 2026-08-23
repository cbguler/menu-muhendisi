-- 71_maydonoz_maydanoz_ayni_malzeme.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici, katalogda gorulen
-- "MAYDANOZ" (bu oturumda daha once USDA'dan islenmisti) ile oncelik
-- listesinde cikan "MAYDONOZ" yazim farkinin AYNI malzemeyi (sadece
-- iki farkli yazim sekli) temsil ettigini dogruladi. Ayni USDA
-- verisi ("Parsley, fresh", fdcId 170416) HER İKİ yaziliş için de
-- coalesce() ile (sadece bos olan alanlara) uygulaniyor -- boylece
-- hangi yaziliş kullanilmis olursa olsun veri tutarli.
--
-- NOT: bu, veritabanindaki olasi "iki ayri satir" veri kalitesi
-- sorununu (aynı malzemenin farkli yazimlarla iki kez kayitli olmasi)
-- COZMUYOR -- sadece her iki satirin besin degerlerini tutarli hale
-- getiriyor. Katalogun uzun vadede tek bir yaziliş etrafinda
-- birlestirilmesi ayri bir konu olarak degerlendirilebilir.

update malzemeler set
  kalori = coalesce(kalori, 36.0), protein = coalesce(protein, 2.97),
  yag = coalesce(yag, 0.79), karbonhidrat = coalesce(karbonhidrat, 6.33),
  lif_g = coalesce(lif_g, 3.3), sodyum_mg = coalesce(sodyum_mg, 56.0),
  demir_mg = coalesce(demir_mg, 6.2), fosfor_mg = coalesce(fosfor_mg, 58.0),
  kalsiyum_mg = coalesce(kalsiyum_mg, 138.0), magnezyum_mg = coalesce(magnezyum_mg, 50.0),
  potasyum_mg = coalesce(potasyum_mg, 554.0), cinko_mg = coalesce(cinko_mg, 1.07),
  bakir_mg = coalesce(bakir_mg, 0.149), manganez_mg = coalesce(manganez_mg, 0.16),
  selenyum_mcg = coalesce(selenyum_mcg, 0.1), vitamin_c_mg = coalesce(vitamin_c_mg, 133.0),
  vitamin_a_mcg = coalesce(vitamin_a_mcg, 421.0), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.086),
  vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.098), vitamin_b3_mg = coalesce(vitamin_b3_mg, 1.313),
  vitamin_b6_mg = coalesce(vitamin_b6_mg, 0.09), vitamin_b9_mcg = coalesce(vitamin_b9_mcg, 152.0),
  vitamin_e_mg = coalesce(vitamin_e_mg, 0.75), vitamin_k_mcg = coalesce(vitamin_k_mcg, 1640.0)
where isletme_id is null and ad in ('MAYDANOZ', 'MAYDONOZ');

-- DOGRULAMA
select ad, kalori, vitamin_c_mg from malzemeler where isletme_id is null and ad in ('MAYDANOZ', 'MAYDONOZ');
