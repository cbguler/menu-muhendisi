-- 14_malzeme_diger_adlar_ve_fiyat_duzeltme.sql
--
-- 1) SALATALIK icin gercek hal fiyati arastirmasina dayanan duzeltme:
--    12_...sql'de gecici olarak 0.30 EUR/kg konulmustu; Temmuz 2026 hal
--    fiyati arastirmasi (~21.28 TL/kg, EUR/TRY~54) 0.39 EUR/kg'a isaret
--    ediyor. Hem malzemeler.varsayilan_fiyat_eur hem -- eger
--    13_salatalik_fiyat_geriye_donuk_doldur.sql zaten calistirildiysa --
--    o script'in yazdigi malzeme_fiyat_gecmisi satirlari guncelleniyor.
--
-- 2) "diger_adlar" destegi: bazi tariflerde ayni malzeme farkli isimle
--    (ornegin SALATALIK yerine HIYAR) gecebiliyor. Tek bir kanonik ad
--    (malzemeler.ad) uzerinde durmaya devam ediyoruz, ama esanlamlilari
--    ayri bir sutunda tutup tarif yukleme script'inin (yukle_tarifler.py)
--    esleme sozlugune bunlari da eklemesini sagliyoruz.

alter table malzemeler add column if not exists diger_adlar text[];
comment on column malzemeler.diger_adlar is
  'Bu malzemenin tariflerde gecebilecek esanlamli/alternatif adlari '
  '(ornegin SALATALIK icin HIYAR). Kanonik ad hala malzemeler.ad''dir; '
  'bu sutun sadece tarif yukleme scriptinin esleme sozlugunu genisletmek icindir.';

update malzemeler
set diger_adlar = array['HIYAR'],
    varsayilan_fiyat_eur = 0.39
where ad = 'SALATALIK' and isletme_id is null;

update malzeme_fiyat_gecmisi mfg
set fiyat_eur = 0.39
from malzemeler m
where mfg.malzeme_id = m.id
  and m.ad = 'SALATALIK'
  and mfg.tedarikci = 'Varsayılan (Temmuz 2026 piyasa araştırması)'
  and mfg.fiyat_eur = 0.30;
