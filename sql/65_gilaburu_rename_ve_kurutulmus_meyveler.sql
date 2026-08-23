-- 65_gilaburu_rename_ve_kurutulmus_meyveler.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin talebiyle GELEBORU
-- daha yaygin kullanilan "GİLABURU" ismine cevrildi. Ayrica kurutulmus
-- form verisi (fresh kullanimin zaten TürKomp'tan teyitli oldugu
-- KARAYEMİŞ ve GİLABURU icin) ayri malzeme olarak eklendi.
--
-- KARAYEMİŞ (KURUTULMUŞ): Kalyoncu, Ersoy, Elidemir, Dolek (2013).
-- WASET 7(6):430-433 -- kurutulmus/ogutulmus ornekten (metinde
-- dogrulandi).
--
-- GİLABURU (KURUTULMUŞ): Taskin, Asik, Izli (2019). KSU Tar Doga
-- Derg 22(2):178-182 -- 105°C'de 24 saat kurutulmus meyve orneginden
-- (metinde dogrulandi), sadece meyve (fruit) sutunu kullanildi.
--
-- NOT: Bu iki YENI malzeme icin protein/kalori/yag/karbonhidrat
-- degerleri BILEREK yazilmadi -- kaynaklar sadece mineral analizi
-- yapmis, makro besin degeri olcmemis. Uydurulmadi, bos birakildi.

update malzemeler set ad = 'GİLABURU' where isletme_id is null and ad = 'GELEBORU';

insert into malzemeler (isletme_id, kategori_id, ad, sodyum_mg, kalsiyum_mg, demir_mg,
  magnezyum_mg, potasyum_mg, cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg, not_aciklama)
select null, 4, v.ad, v.sodyum_mg, v.kalsiyum_mg, v.demir_mg, v.magnezyum_mg, v.potasyum_mg,
  v.cinko_mg, v.fosfor_mg, v.bakir_mg, v.manganez_mg, v.selenyum_mcg, v.not_aciklama
from (values
  ('KARAYEMİŞ (KURUTULMUŞ)', 7.24, 115.89, 1.51, 124.22, 793.87, 0.731, 88.26, 0.433, 0.687, 21.1,
   '13 Agustos 2026: Kalyoncu ve ark. (2013), WASET 7(6):430-433 -- kurutulmus/ogutulmus ornekten (dogrulandi). Tazesi KARAYEMİŞ adiyla, TürKomp kaynakli olarak mevcut. Protein/kalori/yag/karbonhidrat bu kaynakta olculmemis, bos birakildi.'),
  ('GİLABURU (KURUTULMUŞ)', 40.0, 210.0, 1.281, 50.0, 930.0, 0.645, 90.0, 0.569, 0.156, null,
   '13 Agustos 2026: Taskin, Asik, Izli (2019), KSU Tar Doga Derg 22(2):178-182 -- 105 derecede 24 saat kurutulmus meyve orneginden (dogrulandi). Tazesi GİLABURU adiyla, TürKomp kaynakli olarak mevcut. Kalori/yag/karbonhidrat bu kaynakta olculmemis, bos birakildi.')
) as v(ad, sodyum_mg, kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg, cinko_mg, fosfor_mg, bakir_mg, manganez_mg, selenyum_mcg, not_aciklama)
where not exists (select 1 from malzemeler m where m.ad = v.ad and m.isletme_id is null);

-- protein ayri (GİLABURU KURUTULMUŞ icin var, KARAYEMİŞ icin yok)
update malzemeler set protein = coalesce(protein, 0.52)
where isletme_id is null and ad = 'GİLABURU (KURUTULMUŞ)';

-- DOGRULAMA
select ad from malzemeler where isletme_id is null and ad in ('GİLABURU','GELEBORU','KARAYEMİŞ (KURUTULMUŞ)','GİLABURU (KURUTULMUŞ)');
