-- 54_bolgesel_varyant_ekleme.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici, 51 no'lu migration'da
-- benzer TürKomp varyantlarini (bolgesel/laboratuvar ornekleri) tek
-- "temsilci" kavramda TOPLAMA kararima itiraz etti -- haklı bir
-- gerekce ile: gida degerleri/lezzeti benzese bile FIYATLARI genelde
-- farklidir, ve TürKomp'un bunlari ayri tutmasinin muhtemelen bir
-- nedeni vardir. Bu migration, o zaman DEDUPLIKE EDILEN 33 kavramdan
-- 30'unu (3'u -- Dana Eti, Sigir Eti, Pilic Eti -- mevcut kesim
-- isimlerimizle CAKISMA riski tasidigi icin AYRI tutuldu, kullaniciya
-- soruldu, bu migration'a DAHIL EDILMEDI) tam TürKomp granulerligine
-- geri aciyor:
--
--   (1) mevcut TEK malzeme, GERCEKTEN hangi spesifik TürKomp
--       varyantindan geldiyse o isimle (parantez icinde ayirt edici
--       bilgiyle) YENIDEN ADLANDIRILIYOR -- ör. "AYRAN" ->
--       "AYRAN (TAM YAĞLI)".
--   (2) O kavramin GERI KALAN varyantlari YENI, AYRI malzemeler olarak
--       ekleniyor -- ör. "AYRAN (YAYIK, BURSA)", "AYRAN (YAYIK,
--       DIYARBAKIR)" vb.
--
-- BESIN DEGERLERI yine BILEREK BOS -- sonraki asamada TürKomp'tan
-- gelecek (bu YENI varyantlarin her biri gercekte FARKLI bir TürKomp
-- sayfasindan/analizinden geliyor, o yuzden BIRBIRINDEN FARKLI degerler
-- alacaklar -- ayni degeri kopyalamak yanlis olurdu).
--
-- ERTELENEN 3 KAVRAM (kullaniciya soruldu, henuz yanit yok): DANA ETİ,
-- SIĞIR ETİ (5'er varyant, "bonfile" varyanti mevcut DANA BONFİLE/
-- SIĞIR BONFİLE ile birebir cakisiyor), PİLİÇ ETİ (3 varyant, mevcut
-- TAVUK BUT/KANAT/GÖĞÜS ile kavramsal cakisma riski -- piliç/tavuk
-- ayni mi sayilmali, netlesmeden eklenmedi).

update malzemeler set ad = 'DÖNER (KIYMA, ÇİĞ)' where isletme_id is null and ad = 'DÖNER';
update malzemeler set ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, DANA)' where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ';
update malzemeler set ad = 'HİNDİ ETİ (BUT, DERİSİZ)' where isletme_id is null and ad = 'HİNDİ ETİ';
update malzemeler set ad = 'KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)' where isletme_id is null and ad = 'KAZ ETİ';
update malzemeler set ad = 'KEÇİ ETİ (BEL)' where isletme_id is null and ad = 'KEÇİ ETİ';
update malzemeler set ad = 'KOYUN ETİ (BEL)' where isletme_id is null and ad = 'KOYUN ETİ';
update malzemeler set ad = 'KUZU ETİ (BEL)' where isletme_id is null and ad = 'KUZU ETİ';
update malzemeler set ad = 'YENİLEBİLİR SAKATAT (DANA KARACİĞER)' where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT';
update malzemeler set ad = 'KEFAL (PASİFİK, RUS KEFALİ)' where isletme_id is null and ad = 'KEFAL';
update malzemeler set ad = 'ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)' where isletme_id is null and ad = 'ARMUT';
update malzemeler set ad = 'MANDARİN (KLEMANTİN)' where isletme_id is null and ad = 'MANDARİN';
update malzemeler set ad = 'MARMELAT (KIZILCIK)' where isletme_id is null and ad = 'MARMELAT';
update malzemeler set ad = 'AYRAN (TAM YAĞLI)' where isletme_id is null and ad = 'AYRAN';
update malzemeler set ad = 'ARPA (ALTI SIRALI)' where isletme_id is null and ad = 'ARPA';
update malzemeler set ad = 'BÖREK (ISPANAKLI, DONDURULMUŞ)' where isletme_id is null and ad = 'BÖREK';
update malzemeler set ad = 'CİPS (MISIR)' where isletme_id is null and ad = 'CİPS';
update malzemeler set ad = 'KURU ÇORBA KARIŞIMI (EZOGELİN)' where isletme_id is null and ad = 'KURU ÇORBA KARIŞIMI';
update malzemeler set ad = 'AROMALI İÇECEK (GAZLI, PORTAKAL AROMALI)' where isletme_id is null and ad = 'AROMALI İÇECEK';
update malzemeler set ad = 'GOFRET (KAKAO KREMALI, SÜTLÜ ÇİKOLATA KAPLAMALI)' where isletme_id is null and ad = 'GOFRET';
update malzemeler set ad = 'KAZANDİBİ (ANKARA)' where isletme_id is null and ad = 'KAZANDİBİ';
update malzemeler set ad = 'KEŞKÜL (ANKARA)' where isletme_id is null and ad = 'KEŞKÜL';
update malzemeler set ad = 'LOKUM (KAYMAKLI, AFYON)' where isletme_id is null and ad = 'LOKUM';
update malzemeler set ad = 'MANTI (ÇİĞ, KAYSERİ)' where isletme_id is null and ad = 'MANTI';
update malzemeler set ad = 'PESTİL (DUT, ERZURUM)' where isletme_id is null and ad = 'PESTİL';
update malzemeler set ad = 'YAPRAK SARMA (ETLİ, SAFRANBOLU)' where isletme_id is null and ad = 'YAPRAK SARMA';
update malzemeler set ad = 'YAZ HELVASI (CEVİZLİ, İSTANBUL)' where isletme_id is null and ad = 'YAZ HELVASI';
update malzemeler set ad = 'ÇÖKELEK (ÇORUM)' where isletme_id is null and ad = 'ÇÖKELEK';
update malzemeler set ad = 'TATLANDIRICI (SODYUM SİKLAMAT, SODYUM SAKARİN BAZLI, TABLET)' where isletme_id is null and ad = 'TATLANDIRICI';
-- BÖRÜLCE ve MAYDANOZ'un TürKomp'taki ilk varyanti zaten ayirt edici
-- eksiz isimdi -- yeniden adlandirma gerekmedi.

insert into malzemeler (isletme_id, kategori_id, ad, not_aciklama)
select null, v.kategori_id, v.ad,
  '13 Agustos 2026: TürKomp''tan besin degerleri henuz eklenmedi, sonraki asamada tamamlanacak.'
from (values
  (1, 'DÖNER (PİLİÇ ETİ, ÇİĞ)'), (1, 'DÖNER (ET, KASTAMONU, PİŞMİŞ)'), (1, 'DÖNER (ET, PİŞMİŞ, BURSA)'),
  (1, 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, HİNDİ)'), (1, 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, PİLİÇ)'),
  (1, 'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, DANA)'), (1, 'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, HİNDİ)'),
  (1, 'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, PİLİÇ)'), (1, 'HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)'),
  (1, 'KAZ ETİ (GÖĞÜS, DERİSİZ, TUZ İLAVELİ)'), (1, 'KEÇİ ETİ (BUT)'), (1, 'KEÇİ ETİ (KOL)'),
  (1, 'KEÇİ ETİ (SIRT)'), (1, 'KOYUN ETİ (BUT)'), (1, 'KOYUN ETİ (KOL)'), (1, 'KOYUN ETİ (SIRT)'),
  (1, 'KUZU ETİ (BUT)'), (1, 'KUZU ETİ (KOL)'), (1, 'KUZU ETİ (SIRT)'),
  (1, 'YENİLEBİLİR SAKATAT (DANA AKCİĞER)'), (1, 'YENİLEBİLİR SAKATAT (DANA BEYİN)'),
  (1, 'YENİLEBİLİR SAKATAT (DANA BÖBREK)'), (1, 'YENİLEBİLİR SAKATAT (DANA DALAK)'),
  (1, 'YENİLEBİLİR SAKATAT (DANA DİL)'), (1, 'YENİLEBİLİR SAKATAT (DANA İŞKEMBE)'),
  (1, 'YENİLEBİLİR SAKATAT (DANA KALP)'), (1, 'YENİLEBİLİR SAKATAT (KOYUN BAĞIRSAK)'),
  (2, 'KEFAL (SARI KULAK)'),
  (3, 'BÖRÜLCE (KONSERVE)'), (3, 'BÖRÜLCE (KURU)'), (3, 'MAYDANOZ (KURU)'),
  (4, 'ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)'), (4, 'MANDARİN (NOVA)'), (4, 'MANDARİN (OKİTSU WASE)'),
  (4, 'MANDARİN (OVARİ SATSUMA)'), (4, 'MARMELAT (KUŞBURNU)'),
  (5, 'AYRAN (YAYIK, BURSA)'), (5, 'AYRAN (YAYIK, CEVİZLİ, ANTALYA)'), (5, 'AYRAN (YAYIK, DİYARBAKIR)'),
  (5, 'AYRAN (YAYIK, MERSİN)'),
  (7, 'ARPA (İKİ SIRALI)'), (7, 'BÖREK (PEYNİRLİ, DONDURULMUŞ)'), (7, 'CİPS (PATATES)'),
  (14, 'KURU ÇORBA KARIŞIMI (MERCİMEK)'),
  (16, 'AROMALI İÇECEK (GAZLI, SADE)'),
  (17, 'GOFRET (KREMALI, VANİLYA AROMALI)'),
  (18, 'KAZANDİBİ (İSTANBUL)'), (18, 'KAZANDİBİ (İZMİR)'), (18, 'KEŞKÜL (İSTANBUL)'),
  (18, 'KEŞKÜL (İZMİR)'), (18, 'LOKUM (SADE, İSTANBUL)'), (18, 'LOKUM (SAFRANLI, ANTEP FISTIKLI, SAFRANBOLU)'),
  (18, 'MANTI (ÇİĞ, SAFRANBOLU)'), (18, 'PESTİL (DUT, KEMALİYE, ERZİNCAN)'), (18, 'PESTİL (ÜZÜM, GAZİANTEP)'),
  (18, 'PESTİL (ÜZÜM, ÜRGÜP, NEVŞEHİR)'), (18, 'YAPRAK SARMA (ZEYTİNYAĞLI, BURSA)'),
  (18, 'YAPRAK SARMA (ZEYTİNYAĞLI, İZMİR)'), (18, 'YAPRAK SARMA (ZEYTİNYAĞLI, TOKAT)'),
  (18, 'YAZ HELVASI (CEVİZLİ, İZMİR)'), (18, 'YAZ HELVASI (CEVİZLİ, SAFRANBOLU)'), (18, 'ÇÖKELEK (MERSİN)'),
  (19, 'TATLANDIRICI (SORBİTOL VE SAKARİN BAZLI, TOZ)')
) as v(kategori_id, ad)
where not exists (
  select 1 from malzemeler m where m.ad = v.ad and m.isletme_id is null
);

-- DOGRULAMA
select count(*) as toplam_malzeme from malzemeler where isletme_id is null;
