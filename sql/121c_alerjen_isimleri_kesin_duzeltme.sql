-- 121c_alerjen_isimleri_kesin_duzeltme.sql
--
-- KOK NEDEN BULUNDU: Sorun buyuk/kucuk harf degil -- veritabaninda
-- bu alerjenler TURKCE KARAKTERSIZ (ASCII) kayitliymis: "Balik"
-- (Balık degil), "Sut" (Süt degil), "Kabuklu Deniz Urunu" (Ürünü
-- degil) vb. Onceki iki denemenin ikisi de PROPER Turkce karakterli
-- eski-deger varsaydigi icin eslesmedi. Bu sefer TESHIS sorgusunda
-- GERCEKTEN gorulen ASCII degerler kullanildi.

update alerjenler set ad = 'Balık' where ad = 'Balik';
update alerjenler set ad = 'Kabuklular (Crustacea)' where ad = 'Kabuklu Deniz Urunu';
update alerjenler set ad = 'Sert kabuklu meyveler' where ad = 'Sert Kabuklu Yemis';
update alerjenler set ad = 'Kükürt dioksit ve sülfitler' where ad = 'Sulfit (SO2)';
update alerjenler set ad = 'Süt ve süt ürünleri (laktoz dâhil)' where ad = 'Sut';
update alerjenler set ad = 'Yer fıstığı' where ad = 'Yer Fistigi';
update alerjenler set ad = 'Yumuşakçalar' where ad = 'Yumusakca';

-- DOGRULAMA -- 14 satirin TAMAMI artik resmi metinle esit olmali
select ad from alerjenler order by ad;
