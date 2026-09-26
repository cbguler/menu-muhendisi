-- 168_teshis_mantik_hatalari.sql
-- AMAC: Bahri'nin "Giresun Usulu Misir Ekmekli Peynirli Tabak" tarifinde
-- bulduğu iki mantik hatasinin (1) bu tarife ozgu kok nedenini ve
-- (2) ayni hata kaliplarinin TUM 1000 tarifte ne olcude yaygin
-- oldugunu tespit eder. SADECE OKUMA yapar.

-- ADIM 1: Bu spesifik tarifin tam verisi (malzeme + talimat + asamalar)
select r.ad, r.hazirlik_talimati, r.hazirlik_dakika
from receteler r
where r.ad = 'Giresun Usulü Mısır Ekmekli Peynirli Tabak'
  and r.isletme_id is null;

-- ADIM 2: Katalogda "MISIR EKMEĞİ" (hazir/pismis) diye bir malzeme
-- var mi? Yoksa bu, "hazir X" talimati yazip X'in cig halini
-- malzeme secen bir kalip hatasinin somut kaniti olur.
select ad from malzemeler where ad ilike '%mısır ekmeği%' or ad ilike '%misir ekmegi%';

-- ADIM 3 (KRITIK, olcekli tarama): "Isil islem yok" diyen AMA
-- talimat metninde erit/kizart/pisir/kavur/haşla/firinla/izgara/
-- kaynat/buğula gibi isil-islem-ima-eden kelimeler gecen TUM
-- tarifler. Bu, Bahri'nin bulduguyla AYNI hata sinifinin librarideki
-- diger orneklerini bulur.
select r.ad, r.hazirlik_talimati
from receteler r
where r.isletme_id is null
  and r.hazirlik_talimati ilike '%Isıl İşlem%yok%'
  and (
      r.hazirlik_talimati ilike '%eritilmiş%' or
      r.hazirlik_talimati ilike '%eritin%' or
      r.hazirlik_talimati ilike '%erit %' or
      r.hazirlik_talimati ilike '%kızart%' or
      r.hazirlik_talimati ilike '%kavur%' or
      r.hazirlik_talimati ilike '%pişir%' or
      r.hazirlik_talimati ilike '%haşla%' or
      r.hazirlik_talimati ilike '%fırınla%' or
      r.hazirlik_talimati ilike '%ızgara%' or
      r.hazirlik_talimati ilike '%kaynat%' or
      r.hazirlik_talimati ilike '%buğula%' or
      r.hazirlik_talimati ilike '%kızgın%'
  )
order by r.ad;

-- ADIM 4 (aday liste, manuel gozden gecirme icin): Talimat metninde
-- "hazır " gecen TUM tarifler -- bunlarin bir kismi Bahri'nin
-- bulduguyla ayni kalipta (hazir bir urun varsayiliyor ama malzeme
-- listesinde onun cig hali var) olabilir, bir kismi zaten dogru
-- kullanim (or. "hazır erişte" gibi gercekten paket urun kullanan
-- tarifler) olabilir -- bu yuzden bu liste MANUEL goz gezdirme
-- icindir, otomatik hata listesi degildir.
select r.ad, r.hazirlik_talimati
from receteler r
where r.isletme_id is null
  and r.hazirlik_talimati ilike '%hazır %'
order by r.ad;
