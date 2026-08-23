-- 69_oncelikli_malzemeler_besin_degeri.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin oncelik sorgusuyla
-- (oncelik_eksik_malzemeler.sql) bulunan, EN COK tarifte kullanilan
-- AMA temel besin ogeleri (VitC/Kalsiyum/Demir/VitA/Potasyum) eksik
-- olan malzemelerden ilk 6'si tamamlandi (kalan ~33 satir kullanicidan
-- bekleniyor):
--
-- PATLICAN, KESTANE, NAR EKŞİSİ (Gaziantep) -- TürKomp'tan.
-- MISIR NİŞASTASI -- TürKomp'tan.
-- İNCE BULGUR -- TürKomp'ta tam "ince/köftelik" varyanti yok, en
--   yakin mevcut esdeger olan "Bulgur, pilavlik, Gaziantep" kullanildi
--   (ayni temel tahil urunu, ogutme inceligi farkli -- besin degeri
--   acisindan cok farkli olmasi beklenmez).
-- YEŞİL BİBER -- USDA'dan ("Peppers, sweet, green, raw").
--
-- İSOT icin GERCEK bir akademik kaynak arandi (Korkmaz ve ark. 2016,
-- Harran Tarim ve Gida Bilimleri Dergisi) ama bu makale SADECE renk/
-- nem/pH ozelliklerini olcmus, besin degeri (protein/vitamin/mineral)
-- verisi HIC YOK -- ISLENMEDI, bos birakildi. Diger kaynaklar (kac-
-- kalori sitesi, bloglar) guvenilir olmadigi icin kullanilmadi.

update malzemeler set kalori = coalesce(kalori, 23.0), protein = coalesce(protein, 0.94), yag = coalesce(yag, 0.23), karbonhidrat = coalesce(karbonhidrat, 3.13), sodyum_mg = coalesce(sodyum_mg, 3.0), lif_g = coalesce(lif_g, 2.51), vitamin_a_mcg = coalesce(vitamin_a_mcg, 7.0), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.013), vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.037), vitamin_b3_mg = coalesce(vitamin_b3_mg, 0.527), vitamin_c_mg = coalesce(vitamin_c_mg, 3.7), kalsiyum_mg = coalesce(kalsiyum_mg, 10.0), demir_mg = coalesce(demir_mg, 0.26), magnezyum_mg = coalesce(magnezyum_mg, 18.0), potasyum_mg = coalesce(potasyum_mg, 213.0), cinko_mg = coalesce(cinko_mg, 0.2), fosfor_mg = coalesce(fosfor_mg, 29.0) where isletme_id is null and ad = 'PATLICAN';

update malzemeler set kalori = coalesce(kalori, 176.0), protein = coalesce(protein, 1.01), yag = coalesce(yag, 0.93), karbonhidrat = coalesce(karbonhidrat, 39.28), sodyum_mg = coalesce(sodyum_mg, 2.0), lif_g = coalesce(lif_g, 3.32), vitamin_a_mcg = coalesce(vitamin_a_mcg, 24.0), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.02), vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.045), vitamin_b3_mg = coalesce(vitamin_b3_mg, 1.19), vitamin_c_mg = coalesce(vitamin_c_mg, 37.4), kalsiyum_mg = coalesce(kalsiyum_mg, 25.0), demir_mg = coalesce(demir_mg, 0.93), magnezyum_mg = coalesce(magnezyum_mg, 41.0), potasyum_mg = coalesce(potasyum_mg, 486.0), cinko_mg = coalesce(cinko_mg, 0.39), fosfor_mg = coalesce(fosfor_mg, 130.0) where isletme_id is null and ad = 'KESTANE';

update malzemeler set kalori = coalesce(kalori, 310.0), protein = coalesce(protein, 0.0), yag = coalesce(yag, 0.0), karbonhidrat = coalesce(karbonhidrat, 77.55), sodyum_mg = coalesce(sodyum_mg, 1.0), lif_g = coalesce(lif_g, 0.05), kalsiyum_mg = coalesce(kalsiyum_mg, 46.0), demir_mg = coalesce(demir_mg, 0.63), magnezyum_mg = coalesce(magnezyum_mg, 30.0), potasyum_mg = coalesce(potasyum_mg, 1083.0), cinko_mg = coalesce(cinko_mg, 0.35), fosfor_mg = coalesce(fosfor_mg, 67.0) where isletme_id is null and ad = 'NAR EKŞİSİ';

update malzemeler set kalori = coalesce(kalori, 370.0), protein = coalesce(protein, 0.19), yag = coalesce(yag, 0.78), karbonhidrat = coalesce(karbonhidrat, 90.58), sodyum_mg = coalesce(sodyum_mg, 2.0), kalsiyum_mg = coalesce(kalsiyum_mg, 14.0), demir_mg = coalesce(demir_mg, 0.18), magnezyum_mg = coalesce(magnezyum_mg, 3.0), potasyum_mg = coalesce(potasyum_mg, 8.0), cinko_mg = coalesce(cinko_mg, 0.26), fosfor_mg = coalesce(fosfor_mg, 103.0) where isletme_id is null and ad = 'MISIR NİŞASTASI';

update malzemeler set kalori = coalesce(kalori, 357.0), protein = coalesce(protein, 12.08), yag = coalesce(yag, 3.95), karbonhidrat = coalesce(karbonhidrat, 64.97), sodyum_mg = coalesce(sodyum_mg, 3.0), lif_g = coalesce(lif_g, 6.79), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.248), vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.112), vitamin_b3_mg = coalesce(vitamin_b3_mg, 6.222), kalsiyum_mg = coalesce(kalsiyum_mg, 19.0), demir_mg = coalesce(demir_mg, 0.98), magnezyum_mg = coalesce(magnezyum_mg, 59.0), potasyum_mg = coalesce(potasyum_mg, 273.0), cinko_mg = coalesce(cinko_mg, 1.05), fosfor_mg = coalesce(fosfor_mg, 182.0) where isletme_id is null and ad = 'İNCE BULGUR';

update malzemeler set kalori = coalesce(kalori, 20.0), protein = coalesce(protein, 0.86), yag = coalesce(yag, 0.17), karbonhidrat = coalesce(karbonhidrat, 4.64), sodyum_mg = coalesce(sodyum_mg, 3.0), lif_g = coalesce(lif_g, 1.7), seker_g = coalesce(seker_g, 2.4), vitamin_a_mcg = coalesce(vitamin_a_mcg, 18.0), vitamin_b1_mg = coalesce(vitamin_b1_mg, 0.057), vitamin_b2_mg = coalesce(vitamin_b2_mg, 0.028), vitamin_b3_mg = coalesce(vitamin_b3_mg, 0.48), vitamin_b6_mg = coalesce(vitamin_b6_mg, 0.224), vitamin_b9_mcg = coalesce(vitamin_b9_mcg, 10.0), vitamin_c_mg = coalesce(vitamin_c_mg, 80.4), vitamin_e_mg = coalesce(vitamin_e_mg, 0.37), vitamin_k_mcg = coalesce(vitamin_k_mcg, 7.4), kalsiyum_mg = coalesce(kalsiyum_mg, 10.0), demir_mg = coalesce(demir_mg, 0.34), magnezyum_mg = coalesce(magnezyum_mg, 10.0), potasyum_mg = coalesce(potasyum_mg, 175.0), cinko_mg = coalesce(cinko_mg, 0.13), fosfor_mg = coalesce(fosfor_mg, 20.0), bakir_mg = coalesce(bakir_mg, 0.066), manganez_mg = coalesce(manganez_mg, 0.122), selenyum_mcg = coalesce(selenyum_mcg, 0.0) where isletme_id is null and ad = 'YEŞİL BİBER';

-- DOGRULAMA
select ad, kalori, vitamin_c_mg, kalsiyum_mg, demir_mg from malzemeler where isletme_id is null and ad in ('PATLICAN','KESTANE','NAR EKŞİSİ','MISIR NİŞASTASI','İNCE BULGUR','YEŞİL BİBER');
