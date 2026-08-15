-- 51_turkomp_kategori_uyumu_asama2.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici, TürKomp'un 644
-- maddesiyle bizim katalogumuz arasindaki 124 farkli aday malzemeyi
-- (bulanik/fuzzy karsilastirmayla bulunup kullaniciya Excel olarak
-- sunulan liste) tek tek gozden gecirip HANGI kategorimize
-- girmeleri gerektigini isaretledi. Bu migration o isaretlemeyi
-- birebir uyguluyor.
--
-- AYRICA: kullanici NUTELLA'nin bir marka adi oldugunu, jenerik
-- "FINDIK KREMASI" ile degistirilmesi gerektigini belirtti.
--
-- BILINCLI KARAR: 124 yeni malzemenin BESIN DEGERLERI (kalori, protein,
-- vb.) BURADA DOLDURULMADI -- kullanicinin kendi plani geregi ("once
-- kategori uyumu, sonra besin degerlerini tamamlariz") bu ayri, sonraki
-- bir asamada TürKomp'tan cekilecek. Kaynak olmadan deger uydurulmadi.
--
-- NOT (dikkat cekilmesi gereken bir nokta): Berlam, Kalkan, Kefal,
-- Tirsi, Zargana -- TürKomp'ta "Balik ve su urunleri" kategorisinde
-- olmalarina ragmen kullanici bunlari "1" (ET VE ET URUNLERI) olarak
-- isaretledi, "18" (BALIK VE SU URUNLERI) degil. Kullanicinin yazdigi
-- GIBI uygulandi -- kasitli mi yoksa gozden kacma mi oldugu asagida
-- ayrica soruldu.

-- 1) Nutella -> Findik Kremasi (marka adi degil, jenerik isim)
update malzemeler set ad = 'FINDIK KREMASI'
where isletme_id is null and ad = 'NUTELLA';

-- 2) 124 yeni malzeme
insert into malzemeler (isletme_id, kategori_id, ad, not_aciklama)
select null, v.kategori_id, v.ad,
  '13 Agustos 2026: TürKomp''tan besin degerleri henuz eklenmedi, sonraki asamada tamamlanacak.'
from (values
  (1, 'BILDIRCIN ETİ'), (1, 'DANA ETİ'), (1, 'DÖNER'), (1, 'EMÜLSİFİYE ET ÜRÜNÜ'),
  (1, 'HİNDİ ETİ'), (1, 'KASAP KÖFTE'), (1, 'KAZ ETİ'), (1, 'KEÇİ ETİ'),
  (1, 'KOYUN ETİ'), (1, 'KUZU ETİ'), (1, 'PİLİÇ ETİ'), (1, 'SIĞIR ETİ'),
  (1, 'TAVŞAN ETİ'), (1, 'YENİLEBİLİR SAKATAT'), (1, 'BERLAM'), (1, 'KALKAN'),
  (1, 'KEFAL'), (1, 'TİRSİ'), (1, 'ZARGANA'), (1, 'OLTU CAĞ KEBABI'),
  (2, 'ACUR'), (2, 'ALAGÖMEÇ'), (2, 'BÖRÜLCE'), (2, 'ÇAĞ'), (2, 'ÇİRİŞ'),
  (2, 'ÇOBAN ÇANTASI'), (2, 'ÇÖVEN'), (2, 'DELİ MAYDANOZ'), (2, 'DENİZ BÖRÜLCESİ'),
  (2, 'DİKENUCU'), (2, 'DOLAMBAÇ'), (2, 'EBEGÜMECİ'), (2, 'ECİBÜCÜ'), (2, 'HELEVAN'),
  (2, 'HİNDİBA'), (2, 'ISIRGAN'), (2, 'KALDİRİK'), (2, 'KARAKAVUK'), (2, 'KARNABAHAR'),
  (2, 'KAYA KORUĞU'), (2, 'KAYMACIK'), (2, 'KEÇİ AYAĞI'), (2, 'KENGER'),
  (2, 'KUZUKEMİRDİ'), (2, 'LABADA'), (2, 'MADIMAK'), (2, 'MAYDANOZ'), (2, 'REZENE'),
  (2, 'ŞALGAM'), (2, 'ŞEVKETİ BOSTAN'), (2, 'TEKESAKALI'),
  (3, 'ARMUT'), (3, 'ASMA YAPRAĞI'), (3, 'AYVA'), (3, 'BERGAMOT'), (3, 'GELEBORU'),
  (3, 'İĞDE'), (3, 'KARAMUK'), (3, 'KARAYEMİŞ'), (3, 'KEBERE'), (3, 'KEÇİBOYNUZU'),
  (3, 'KIZILCIK'), (3, 'MANDARİN'), (3, 'MARMELAT'), (3, 'NEKTARİN'),
  (3, 'YENİDÜNYA'), (3, 'ZEYTİN EZMESİ'), (3, 'ZİNGİT'),
  (5, 'BAHARAT KARIŞIMI'),
  (7, 'AYRAN'), (7, 'ERİTME PEYNİRİ'), (7, 'ÇÖKELEK'), (7, 'EDİRNE BEYAZ PEYNİRİ'),
  (7, 'ESKİ KAŞAR'),
  (8, 'ARPA'), (8, 'ARPA UNU'), (8, 'BÖREK'), (8, 'BUĞDAY KEPEĞİ'),
  (8, 'BUĞDAY NİŞASTASI'), (8, 'BUĞDAY RUŞEYMİ'), (8, 'KATMER'), (8, 'KOCA DARI'),
  (8, 'KRAKER'), (8, 'LAVAŞ'), (8, 'MİLFÖY HAMURU'), (8, 'TRİTİKALE'), (8, 'CİPS'),
  (8, 'GÜLLAÇ'), (8, 'MANTI'), (8, 'SİMİT'), (8, 'TAM TAHILLI GEVREK'),
  (10, 'YAPRAK SARMA'),
  (12, 'JÖLE'), (12, 'KURU ÇORBA KARIŞIMI'), (12, 'SOYA KIYMA'), (12, 'TATLANDIRICI'),
  (14, 'AYÇİÇEĞİ TOHUMU'), (14, 'KETEN TOHUMU'), (14, 'KOLZA TOHUMU'),
  (14, 'ÇORUM LEBLEBİSİ'), (14, 'DENİZLİ LEBLEBİSİ'), (14, 'TAVŞANLI LEBLEBİSİ'),
  (14, 'MÜSLİ'),
  (16, 'AROMALI İÇECEK'), (16, 'DOĞAL ZENGİN MİNERALLİ GAZLI İÇECEK'), (16, 'TONİK'),
  (16, 'TOZ MEŞRUBAT'), (16, 'IHLAMUR'), (16, 'KAHVE KREMASI'), (16, 'BOZA'),
  (16, 'HARDALİYE'), (16, 'SALEP'), (16, 'İZOTONİK SPORCU İÇECEĞİ'),
  (17, 'GOFRET'), (17, 'PUDİNG'), (17, 'İZMİT PİŞMANİYESİ'), (17, 'KAZANDİBİ'),
  (17, 'KEŞKÜL'), (17, 'LOKUM'), (17, 'MARAŞ DONDURMASI'), (17, 'MERSİN CEZERYESİ'),
  (17, 'PESTİL'), (17, 'YAZ HELVASI'), (17, 'ZİLE PEKMEZİ')
) as v(kategori_id, ad)
where not exists (
  select 1 from malzemeler m where m.ad = v.ad and m.isletme_id is null
);

-- DOGRULAMA
select mk.id, mk.ad as kategori, count(m.id) as malzeme_sayisi
from malzeme_kategorileri mk
left join malzemeler m on m.kategori_id = mk.id and m.isletme_id is null
group by mk.id, mk.ad
order by mk.id;
