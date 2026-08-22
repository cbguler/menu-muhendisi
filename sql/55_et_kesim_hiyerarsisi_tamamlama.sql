-- 55_et_kesim_hiyerarsisi_tamamlama.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici DANA ETİ/SIĞIR ETİ/
-- PİLİÇ ETİ konusundaki 3 acik soruyu (54 no'lu migration'da ertelenen)
-- netlestirdi -- gonderdigi kasaplik semalari (Dana/Kuzu/Kumes hayvani)
-- eslıginde:
--
-- 1) BONFILE DAHIL EDILSIN: "bonfile ve kontrfile en lezzetli ve
--    degerli parcalar" -- ama "DANA BONFİLE"/"SIĞIR BONFİLE" ZATEN
--    mevcut oldugu icin (orijinal 358 listesinden) AYNI ISIMLE ikinci
--    bir kayit OLUSTURULMADI -- mevcut kayit zaten bu ihtiyaci
--    karsiliyor. Sadece EKSIK olan diger 4 kesim (but/kol/kontrfile/
--    pirzola) eklendi.
--
-- 2) PİLİÇ, TAVUK'TAN AYRI TUTULMALI: kullanici, Dana/Sığır (genc/
--    yasli sigir) ve Kuzu/Koyun (genc/yasli koyun) ayriminin ayni
--    mantikla Tavuk/Piliç (yasli/genc tavuk) icin de gecerli oldugunu
--    acikladi -- yas farki lezzeti degistiriyor, bu yuzden piyasada
--    ayri satiliyorlar. PİLİÇ ETİ bu yuzden KALDIRILMADI (ilk
--    onerimin aksine), tam tersine kendi kesimleriyle (but/gogus/
--    kanat) TAVUK'tan BAGIMSIZ, ayri bir kavram olarak tamamlandi.
--
-- Mevcut DANA ETİ/SIĞIR ETİ/PİLİÇ ETİ yer tutucu kayitlari, TürKomp
-- sirasindaki ILK kalan kesimin adiyla YENIDEN ADLANDIRILDI (ayni
-- desen: onceki migration'larda da boyle yapildi), geri kalanlar YENI
-- kayit olarak eklendi. Besin degerleri yine BILEREK BOS -- sonraki
-- asamada TürKomp'tan gelecek.

update malzemeler set ad = 'DANA BUT' where isletme_id is null and ad = 'DANA ETİ';
update malzemeler set ad = 'SIĞIR BUT' where isletme_id is null and ad = 'SIĞIR ETİ';
update malzemeler set ad = 'PİLİÇ BUT' where isletme_id is null and ad = 'PİLİÇ ETİ';

insert into malzemeler (isletme_id, kategori_id, ad, not_aciklama)
select null, 1, ad,
  '13 Agustos 2026: TürKomp''tan besin degerleri henuz eklenmedi, sonraki asamada tamamlanacak.'
from (values
  ('DANA KOL'), ('DANA KONTRFİLE'), ('DANA PİRZOLA'),
  ('SIĞIR KOL'), ('SIĞIR KONTRFİLE'), ('SIĞIR PİRZOLA'),
  ('PİLİÇ GÖĞÜS (DERİSİZ)'), ('PİLİÇ KANAT')
) as v(ad)
where not exists (
  select 1 from malzemeler m where m.ad = v.ad and m.isletme_id is null
);

-- DOGRULAMA
select count(*) as toplam_malzeme from malzemeler where isletme_id is null;
