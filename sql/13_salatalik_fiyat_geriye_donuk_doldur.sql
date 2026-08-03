-- 13_salatalik_fiyat_geriye_donuk_doldur.sql
--
-- SALATALIK, 74 tariflik tarif kutuphanesi hazirlanirken (bkz.
-- 12_tarif_kutuphanesi_global_receteler.sql) kaynak dosyada eksik
-- oldugu icin sonradan eklendi. 08_fiyat_gecmisini_geriye_donuk_doldur.sql
-- o tarihten ONCE calistigi icin, o tarihte zaten var olan isletmeler
-- SALATALIK icin hic varsayilan fiyat almadi (08'in kontrolu "isletmenin
-- HICBIR fiyati var mi" seklindeydi, "bu MALZEME icin fiyati var mi"
-- degil -- yani zaten baska malzemeleri fiyatli olan isletmeler atlandi).
--
-- Bu script SADECE SALATALIK icin, malzeme bazinda kontrol ederek,
-- henuz bu malzemenin fiyatini hic almamis her isletmeye varsayilan
-- fiyati geriye donuk ekler. Birden fazla kez calistirilsa da zararsizdir.

insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
select i.id, m.id, m.varsayilan_fiyat_eur, 'Varsayılan (Temmuz 2026 piyasa araştırması)'
from isletmeler i
cross join malzemeler m
where m.ad = 'SALATALIK'
  and m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id and mfg.malzeme_id = m.id
  );
