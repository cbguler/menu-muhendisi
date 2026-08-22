-- 62_kenger_ve_madimak_akademik_veri.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin yukledigi Kenger
-- kulinar kullanim makalesi (Onur, Yilmaz, Zivali 2025) araciligiyla
-- Bilgir (1982) kaynagi arastirildi -- ORIJINAL 1982 makale
-- BULUNAMADI (Ege Univ. Ziraat Fak. Derg.'nin dijital arsivi sadece
-- 2001'e kadar gidiyor). Kullanicinin "emin oldugunu yaz, bulamadigini
-- bos birak" talimatina gore: KENGER icin bu kaynaktan HICBIR SEY
-- YAZILMADI (kul sutunumuzda yok, protein zaten TürKomp'tan doluydu,
-- demir/fosfor kuru-madde/taze-madde belirsizligi cozulemedi).
--
-- MADIMAK icin GERCEK, TAM VERI bulundu: Demir H (2006). "Erzurum'da
-- Yetisen Madimak, Yemlik ve Kizamik Bitkilerinin Bazi Kimyasal
-- Bilesimi". Bahce, 35(1-2):55-60 -- Atomik Absorbsiyon
-- Spektrofotometresi ile olculmus, FRESH bazli (makalenin kendi
-- kultur-bitkisi karsilastirmasi bunu dogruluyor). Sadece BOS olan
-- Bakir ve Manganez alanlari dolduruldu, geri kalani zaten TürKomp'tan
-- doluydu.

update malzemeler set
  bakir_mg = coalesce(bakir_mg, 0.21),
  manganez_mg = coalesce(manganez_mg, 0.86)
where isletme_id is null and ad = 'MADIMAK';

-- DOGRULAMA
select ad, bakir_mg, manganez_mg from malzemeler where isletme_id is null and ad in ('MADIMAK', 'KENGER');
