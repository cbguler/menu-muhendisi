-- 52_kategori_yeniden_numaralandirma.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici kendi kafasindaki
-- kategori sirasina gore TAM bir yeniden numaralandirma istedi (18
-- kategoriden 20 kategoriye, cogu numara degisiyor, bazi kategoriler
-- birlesiyor). Excel dosyasinda (kaynak_duzeltilmis_v4.xlsx ->
-- kaynak_duzeltilmis_v5.xlsx) AYNI yeniden numaralandirma zaten
-- uygulandi, bu migration veritabanini onunla ayni hizaya getiriyor.
--
-- ESKI -> YENI ESLEME:
--   1 (ET VE PROTEIN...) -> 1 (ET VE ET URUNLERI)              [ayni]
--   18 (BALIK VE SU URUNLERI) -> 2 (BALIK VE SU URUNLERI)      [yeni yerine tasindi]
--   2 (SEBZELER) -> 3 (SEBZE VE SEBZE URUNLERI)
--   3 (MEYVELER) -> 4 (MEYVE VE MEYVE URUNLERI)
--   7 (SUT VE SUT URUNLERI) -> 5 (SUT VE SUT URUNLERI)
--   11 (YUMURTA) -> 6 (YUMURTA VE YUMURTA URUNLERI)
--   8 (UN VE TAHILLAR) -> 7 (TAHILLAR VE TAHIL URUNLERI)
--   9 (KURU BAKLAGILLER) -> 8 (YAGLI TOHUMLAR VE KURU BAKLAGILLER) [BIRLESTI]
--     + eski 14'ten 3 yagli tohum (AYCICEGI/KETEN/KOLZA TOHUMU) da buraya
--   4 (SIVI YAGLAR) -> 9 (SIVI VE KATI YAGLAR)
--   14 (KURU MEYVELER VE KURUYEMIS) -> 10 (ayni, 3 yagli tohum haric)
--   10 (KONSERVELER) -> 11 (KONSERVELER)
--   5 (BAHARATLAR...) -> 12 (BAHARATLAR...)
--   6 (SOSLAR...) -> 13 (SOSLAR...)
--   12 (MAYA...) -> 14 (MAYA...)
--   15 (COKOLATA VE KAKAO) -> 15 (COKOLATA VE KAKAO URUNLERI)
--   16 (ICECEK HAMMADDELERI) -> 16 [ayni]
--   17 (TATLI VE PASTA...) -> 17 [ayni]
--   13 (SU VE TEMEL SIVI) -> 20 (SU VE TEMEL SIVI)
--   YENI, BOS: 18 (GELENEKSEL GIDALAR -- "GIDALAR" yazim hatasi
--     duzeltildi, kullanicinin dosyasinda "GİDALAR" yaziyordu)
--   YENI, BOS: 19 (OZEL BESLENME AMAÇLI GIDALAR)
--
-- ACIK SORU (kullaniciya soruldu, henuz yanit yok): 51 no'lu
-- migration'da eklenen "Geleneksel gidalar" kokenli malzemeler
-- (KAZANDIBI, MANTI, SIMIT, LOKUM, BOZA, PESTIL, vb. -- TürKomp'ta
-- "Geleneksel gidalar" kategorisinden geliyorlardi ama o zaman boyle
-- bir kategorimiz olmadigi icin kullanici onlari baska kategorilere
-- (8, 16, 17 vb.) isaretlemisti) simdi bu YENI 18 numarali kategoriye
-- TASINMALI MI? Bu migration'da TASINMADI -- kullanicinin acik onayi
-- bekleniyor, cunku bu ~23 malzemeyi etkileyen ayrica bir karar.
--
-- YONTEM: cakismayi onlemek icin once TUM malzemeler +1000 ofsetli
-- gecici ID'lere tasiniyor, sonra gecici ID'lerden gercek yeni ID'lere
-- gecirilyor. FK kisidi (malzemeler.kategori_id -> malzeme_kategorileri.id)
-- gecici olarak kaldirilip islem sonunda yeniden ekleniyor.

do $$
declare
  kisit_adi text;
begin
  select con.conname into kisit_adi
  from pg_constraint con
  where con.conrelid = 'malzemeler'::regclass
    and con.contype = 'f'
    and exists (
      select 1 from pg_attribute att
      where att.attrelid = con.conrelid
        and att.attnum = any(con.conkey)
        and att.attname = 'kategori_id'
    );
  if kisit_adi is not null then
    execute format('alter table malzemeler drop constraint %I', kisit_adi);
  end if;
end $$;

-- 1) Herkesi gecici (+1000) alana tasi
update malzemeler set kategori_id = kategori_id + 1000
where kategori_id between 1 and 18;

-- 2) Ozel durum: 3 yagli tohum, eski-14'ten (simdi 1014) yeni-8'e
update malzemeler set kategori_id = 8
where kategori_id = 1014
  and ad in ('AYÇİÇEĞİ TOHUMU', 'KETEN TOHUMU', 'KOLZA TOHUMU');

-- 3) Genel gecici -> yeni esleme
update malzemeler set kategori_id = 1  where kategori_id = 1001;
update malzemeler set kategori_id = 2  where kategori_id = 1018;
update malzemeler set kategori_id = 3  where kategori_id = 1002;
update malzemeler set kategori_id = 4  where kategori_id = 1003;
update malzemeler set kategori_id = 5  where kategori_id = 1007;
update malzemeler set kategori_id = 6  where kategori_id = 1011;
update malzemeler set kategori_id = 7  where kategori_id = 1008;
update malzemeler set kategori_id = 8  where kategori_id = 1009;  -- kalan kuru baklagiller
update malzemeler set kategori_id = 9  where kategori_id = 1004;
update malzemeler set kategori_id = 10 where kategori_id = 1014;  -- kalanlar (yagli tohumlar zaten tasindi)
update malzemeler set kategori_id = 11 where kategori_id = 1010;
update malzemeler set kategori_id = 12 where kategori_id = 1005;
update malzemeler set kategori_id = 13 where kategori_id = 1006;
update malzemeler set kategori_id = 14 where kategori_id = 1012;
update malzemeler set kategori_id = 15 where kategori_id = 1015;
update malzemeler set kategori_id = 16 where kategori_id = 1016;
update malzemeler set kategori_id = 17 where kategori_id = 1017;
update malzemeler set kategori_id = 20 where kategori_id = 1013;

-- 4) malzeme_kategorileri tablosunu tamamen yeniden kur
delete from malzeme_kategorileri;
insert into malzeme_kategorileri (id, ad) values
  (1,  'ET VE ET URUNLERI'),
  (2,  'BALIK VE SU URUNLERI'),
  (3,  'SEBZE VE SEBZE URUNLERI'),
  (4,  'MEYVE VE MEYVE URUNLERI'),
  (5,  'SUT VE SUT URUNLERI'),
  (6,  'YUMURTA VE YUMURTA URUNLERI'),
  (7,  'TAHILLAR VE TAHIL URUNLERI'),
  (8,  'YAGLI TOHUMLAR VE KURU BAKLAGILLER'),
  (9,  'SIVI VE KATI YAGLAR'),
  (10, 'KURU MEYVELER VE KURUYEMISLER'),
  (11, 'KONSERVELER'),
  (12, 'BAHARATLAR VE TATLANDIRICILAR'),
  (13, 'SOSLAR, PASTALAR VE FONDLAR'),
  (14, 'MAYA VE PISIRME MALZEMELERI'),
  (15, 'COKOLATA VE KAKAO URUNLERI'),
  (16, 'ICECEK HAMMADDELERI'),
  (17, 'TATLI VE PASTA MALZEMELERI'),
  (18, 'GELENEKSEL GIDALAR'),
  (19, 'OZEL BESLENME AMAÇLI GIDALAR'),
  (20, 'SU VE TEMEL SIVI');

-- 5) FK kisidini geri ekle
alter table malzemeler
  add constraint malzemeler_kategori_id_fkey
  foreign key (kategori_id) references malzeme_kategorileri(id);

-- DOGRULAMA
select mk.id, mk.ad as kategori, count(m.id) as malzeme_sayisi
from malzeme_kategorileri mk
left join malzemeler m on m.kategori_id = mk.id and m.isletme_id is null
group by mk.id, mk.ad
order by mk.id;
