-- 64_isirgan_ve_ciris_akademik_veri.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin "baska kaynaklara
-- bak, isirgan otunu da arastir" talebi uzerine.
--
-- ISIRGAN: USDA'da "Stinging Nettles, blanched (Northern Plains
-- Indians)" (fdcId 169819) bulundu -- ama bu kaydin genel profili
-- (kalori, Ca, Fe, K, VitA gibi) bizim mevcut ISIRGAN verimizden
-- (muhtemelen TürKomp, farkli tur/hazirlama) belirgin sekilde farkli
-- cikti. SADECE gercekten BOS olan Selenyum (0.3 mcg/100g) yazildi,
-- digerlerine dokunulmadi.
--
-- ÇİRİŞ: Karataş F, Bektaş İ, Birişik A, Aydın Z, Kurtul A (2011).
-- "Çiriş Otu'nda (Asphodelus aestivus L.) Suda Çözünen Bazı
-- Bileşiklerin Araştırılması". SDU Journal of Science 6(1):35-39.
-- TAZE ornek (metinde acikca dogrulandi: "taze çiriş otu
-- örneklerinde"), HPLC olcumu. Sadece BOS olan B6 (2.197 mg/100g) ve
-- B9 (820 mcg/100g) yazildi -- B1/B2/B3/VitC zaten baska kaynaktan
-- doluydu.

update malzemeler set
  selenyum_mcg = coalesce(selenyum_mcg, 0.3)
where isletme_id is null and ad = 'ISIRGAN';

update malzemeler set
  vitamin_b6_mg = coalesce(vitamin_b6_mg, 2.197),
  vitamin_b9_mcg = coalesce(vitamin_b9_mcg, 820.0)
where isletme_id is null and ad = 'ÇİRİŞ';

-- DOGRULAMA
select ad, selenyum_mcg, vitamin_b6_mg, vitamin_b9_mcg from malzemeler
where isletme_id is null and ad in ('ISIRGAN', 'ÇİRİŞ');
