-- 53_geleneksel_ve_ozel_beslenme_tasima.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanici, 52 no'lu migration'da
-- acilan iki BOS kategoriye (18 GELENEKSEL GIDALAR, 19 OZEL BESLENME
-- AMAÇLI GIDALAR) daha once (51 no'lu migration'da) eklenmis olan,
-- TürKomp'ta zaten bu kategorilerden gelen malzemelerin tasinmasini
-- onayladi -- o zaman bu kategoriler yoktu, malzemeler baska
-- kategorilere isaretlenmisti.
--
-- Basit UPDATE'ler -- FK/collision riski yok (hedef kategoriler zaten
-- 52 no'lu migration'da olusturuldu), sadece kategori_id degeri
-- degisiyor.

update malzemeler set kategori_id = 18
where isletme_id is null
  and ad in (
    'BOZA','ÇÖKELEK','ÇORUM LEBLEBİSİ','DENİZLİ LEBLEBİSİ','EDİRNE BEYAZ PEYNİRİ',
    'ESKİ KAŞAR','GÜLLAÇ','HARDALİYE','İZMİT PİŞMANİYESİ','KAZANDİBİ','KEŞKÜL',
    'LOKUM','MANTI','MARAŞ DONDURMASI','MERSİN CEZERYESİ','OLTU CAĞ KEBABI',
    'PESTİL','SALEP','SİMİT','TAVŞANLI LEBLEBİSİ','YAPRAK SARMA','YAZ HELVASI',
    'ZİLE PEKMEZİ'
  );

update malzemeler set kategori_id = 19
where isletme_id is null
  and ad in ('İZOTONİK SPORCU İÇECEĞİ', 'MÜSLİ', 'TAM TAHILLI GEVREK', 'TATLANDIRICI');

-- DOGRULAMA
select mk.id, mk.ad as kategori, count(m.id) as malzeme_sayisi
from malzeme_kategorileri mk
left join malzemeler m on m.kategori_id = mk.id and m.isletme_id is null
group by mk.id, mk.ad
order by mk.id;
