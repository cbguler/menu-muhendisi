-- 08_fiyat_gecmisini_geriye_donuk_doldur.sql
--
-- 07_varsayilan_fiyat.sql'deki fiyat kopyalama mantigi sadece BUNDAN SONRA
-- kayit olan isletmelerde (tetikleyici uzerinden) calisir. Daha once
-- olusturulmus ya da geriye donuk tamamlanmis isletmeler (ornegin
-- 06_eksik_kullanicilari_tamamla.sql ile olusturulanlar) hic fiyat almadi --
-- bu yuzden recete maliyeti 0,00 EUR gorunuyordu.
--
-- Bu script, malzeme_fiyat_gecmisi'nde HENUZ HIC fiyati olmayan her
-- isletme icin varsayilan fiyatlari geriye donuk yukler. Birden fazla kez
-- calistirilsa da zararsizdir -- sadece hala fiyati olmayan isletmeleri isler.

insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
select i.id, m.id, m.varsayilan_fiyat_eur, 'Varsayılan (Temmuz 2026 piyasa araştırması)'
from isletmeler i
cross join malzemeler m
where m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id
  );
