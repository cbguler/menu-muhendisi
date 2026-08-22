-- 60_yabani_ot_usda_kismi.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): yabani ot grubundan sadece 2
-- tanesi USDA'da gercekten eslesti -- TEKESAKALI (tam isabet: salsify)
-- ve DENİZ BÖRÜLCESİ (yakin familya: purslane). Geri kalan ~12 tanesi
-- USDA'nin "bulamadim" yedek sonucuna (Abiyuch) veya tamamen alakasiz
-- kategorilere dustugu icin ISLENMEDI.
--
-- Turk akademik literaturunde (Uludag Universitesi, Igdir Universitesi
-- dergileri) SEVKETI BOSTAN, KENGER, MADIMAK icin gercek kompozisyon
-- calismalari bulundu ama SEVKETI BOSTAN verisi KURUTULMUS KOK UNU
-- icin -- kullaniciya nasil uygulanacagi soruldu, henuz islenmedi.

update malzemeler set kalori = coalesce(kalori, 82.0), protein = coalesce(protein, 3.3), yag = coalesce(yag, 0.2), karbonhidrat = coalesce(karbonhidrat, 18.6), sodyum_mg = coalesce(sodyum_mg, 20.0), lif_g = coalesce(lif_g, 3.3), vitamin_a_mcg = coalesce(vitamin_a_mcg, 0.0), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.08), vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.22), vitamin_b3_mg = coalesce(vitamin_b3_mg, 0.5), vitamin_b5_mg = coalesce(vitamin_b5_mg, 0.371), vitamin_b6_mg = coalesce(vitamin_b6_mg, 0.277), vitamin_b9_mcg = coalesce(vitamin_b9_mcg, 26.0), vitamin_b12_mcg = coalesce(vitamin_b12_mcg, 0.0), vitamin_c_mg = coalesce(vitamin_c_mg, 8.0), vitamin_d_mcg = coalesce(vitamin_d_mcg, 0.0), kalsiyum_mg = coalesce(kalsiyum_mg, 60.0), demir_mg = coalesce(demir_mg, 0.7), magnezyum_mg = coalesce(magnezyum_mg, 23.0), potasyum_mg = coalesce(potasyum_mg, 380.0), cinko_mg = coalesce(cinko_mg, 0.38), fosfor_mg = coalesce(fosfor_mg, 75.0), bakir_mg = coalesce(bakir_mg, 0.089), manganez_mg = coalesce(manganez_mg, 0.268), selenyum_mcg = coalesce(selenyum_mcg, 0.8) where isletme_id is null and ad = 'TEKESAKALI';

update malzemeler set kalori = coalesce(kalori, 20.0), protein = coalesce(protein, 2.03), yag = coalesce(yag, 0.36), karbonhidrat = coalesce(karbonhidrat, 3.39), sodyum_mg = coalesce(sodyum_mg, 45.0), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.047), vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.112), vitamin_b3_mg = coalesce(vitamin_b3_mg, 0.48), vitamin_b5_mg = coalesce(vitamin_b5_mg, 0.036), vitamin_b6_mg = coalesce(vitamin_b6_mg, 0.073), vitamin_b9_mcg = coalesce(vitamin_b9_mcg, 12.0), vitamin_b12_mcg = coalesce(vitamin_b12_mcg, 0.0), vitamin_c_mg = coalesce(vitamin_c_mg, 21.0), vitamin_d_mcg = coalesce(vitamin_d_mcg, 0.0), kalsiyum_mg = coalesce(kalsiyum_mg, 65.0), demir_mg = coalesce(demir_mg, 1.99), magnezyum_mg = coalesce(magnezyum_mg, 68.0), potasyum_mg = coalesce(potasyum_mg, 494.0), cinko_mg = coalesce(cinko_mg, 0.17), fosfor_mg = coalesce(fosfor_mg, 44.0), bakir_mg = coalesce(bakir_mg, 0.113), manganez_mg = coalesce(manganez_mg, 0.303), selenyum_mcg = coalesce(selenyum_mcg, 0.9) where isletme_id is null and ad = 'DENİZ BÖRÜLCESİ';

-- DOGRULAMA
select count(*) as toplam from malzemeler where isletme_id is null;
