-- 67_kaldirik_taze_borage.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin gonderdigi
-- fotograflarda (nefis.com, bim.com.tr tarifleri) KALDIRIK OTU'nun
-- mavi, yildiz seklinde cicekleri goruldu -- bu klasik Borago
-- officinalis (Borage) cicegi, Trachystemon orientalis'in can/tup
-- seklindeki cicegi degil. Tur kimligi bu gorsel kanitla yeniden
-- degerlendirildi.
--
-- USDA'da "Borage, raw" (fdcId 170481) TAM ve GERCEK bir kayit
-- bulundu -- %93 su icerigi ACIKCA belirtilmis (TAZE ornek), ve
-- potasyum degeri (470mg/100g) bizim diger taze yabani otlarimizla
-- (Madimak K=448, Kaymacik K=631) tutarli -- daha once Trachystemon
-- verisindeki (4837.6mg/100g) 10 kat fazla degerden cok daha makul.
--
-- Bu bulgu hem gorsel kanitla hem buyukluk tutarliligiyla Borage'in
-- (Borago officinalis) daha dogru tur oldugunu guclu sekilde
-- destekliyor. KALDIRIK (KURUTULMUS) -- Trachystemon verisi -- SILINMEDI,
-- kullaniciya iki turun de (halk arasinda karisik kullanildigi icin)
-- ayri ayri tutulmasi mi yoksa Trachystemon kaydinin kaldirilmasi mi
-- istendigi sorulacak.

insert into malzemeler (isletme_id, kategori_id, ad, kalori, protein, yag, karbonhidrat,
  sodyum_mg, doymus_yag_g, vitamin_a_mcg, vitamin_b1_mg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg, vitamin_c_mg, vitamin_d_mcg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg, cinko_mg, fosfor_mg, bakir_mg,
  manganez_mg, selenyum_mcg, not_aciklama)
select null, 3, 'KALDIRIK', 21.0, 1.8, 0.7, 3.06, 80.0, 0.17, 210.0, 0.06, 0.15, 0.9, 0.041,
  0.084, 13.0, 0.0, 35.0, 0.0, 93.0, 3.3, 52.0, 470.0, 0.2, 53.0, 0.13, 0.349, 0.9,
  '13 Agustos 2026: USDA FoodData Central, Borage, raw (fdcId 170481). Tur kimligi kullanicinin '
  'gonderdigi fotograflardaki mavi yildiz sekilli ciceklerle (Borago officinalis''e ozgu) ve '
  'buyukluk tutarliligiyla (K=470mg/100g, diger taze yabani otlarla uyumlu) dogrulandi. %93 su -- '
  'TAZE ornek, acikca belirtilmis.'
where not exists (select 1 from malzemeler m where m.ad = 'KALDIRIK' and m.isletme_id is null);

-- DOGRULAMA
select ad, kalori, potasyum_mg from malzemeler where isletme_id is null and ad in ('KALDIRIK', 'KALDIRIK (KURUTULMUŞ)');
