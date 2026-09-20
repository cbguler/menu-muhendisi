-- 121_alerjen_isimleri_resmi_metinle_esitle.sql
--
-- T.C. Tarim ve Orman Bakanligi'nin resmi zorunlu alerjen listesiyle
-- (guvenilirgida.tarimorman.gov.tr/Haber/Detay/15071) birebir
-- uyusacak sekilde alerjenler.ad alanlari guncelleniyor. Mevcut 14
-- alerjen zaten kategori olarak resmi listeyle TAM orttusuyordu
-- (14/14) -- bu sadece ISIMLENDIRMEYI resmi metne yaklastiriyor.

update alerjenler set ad = 'Gluten içeren tahıllar' where ad = 'Gluten';
update alerjenler set ad = 'Kabuklular (Crustacea)' where ad = 'Kabuklu Deniz Ürünü';
update alerjenler set ad = 'Yer fıstığı' where ad = 'Yer Fıstığı';
update alerjenler set ad = 'Soya fasulyesi' where ad = 'Soya';
update alerjenler set ad = 'Süt ve süt ürünleri (laktoz dâhil)' where ad = 'Süt';
update alerjenler set ad = 'Sert kabuklu meyveler' where ad = 'Sert Kabuklu Yemiş';
update alerjenler set ad = 'Susam tohumu' where ad = 'Susam';
update alerjenler set ad = 'Kükürt dioksit ve sülfitler' where ad = 'Sülfit (SO2)';
update alerjenler set ad = 'Acı bakla (lupin)' where ad = 'Lupin';
update alerjenler set ad = 'Yumuşakçalar' where ad = 'Yumuşakça';
-- Degismeyenler (zaten resmi adla ayni): Yumurta, Balık, Kereviz, Hardal

-- DOGRULAMA -- 14 satir da resmi metinle esit gelmeli
select ad from alerjenler order by ad;
