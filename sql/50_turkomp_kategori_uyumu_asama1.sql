-- 50_turkomp_kategori_uyumu_asama1.sql
--
-- Kullanici, TürKomp'un kendi 14 gida grubu sistemine yakinsamak
-- istedi (13 Agustos 2026, Oturum 11). Tam 1:1 gecis yerine (bazi
-- kategorilerimizin -- Baharatlar, Soslar, Konserveler vb. -- TürKomp'ta
-- dogrudan karsiligi yok) kullanicinin acikca istedigi IKI degisiklik
-- yapildi:
--
-- 1) "1. ET VE PROTEIN KAYNAKLARI" (41 kalem) ikiye ayrildi:
--    - "1. ET VE ET URUNLERI" (25 kalem, ayni id=1 korunuyor)
--    - "18. BALIK VE SU URUNLERI" (16 kalem, YENI id=18)
--
-- 2) "4. SIVI YAGLAR" -> "4. SIVI VE KATI YAGLAR" olarak genisletildi
--    (ayni id=4 korunuyor). TEREYAGI, SUT VE SUT URUNLERI'nden (id=7)
--    buraya tasindi. Ayrica 4 YENI malzeme eklendi: KUYRUKYAGI,
--    DONYAGI, SADEYAG, MARGARIN -- BUNLARIN BESIN DEGERLERI HENUZ
--    DOLDURULMADI (kasitli, uydurulmadi) -- kullanicinin kendi
--    plani geregi ("once kategori, sonra besin degerlerini
--    tamamlariz") bir sonraki asamada TürKomp'tan eklenecek.
--
-- Excel dosyasinda (kaynak_duzeltilmis_v2.xlsx -> v3) AYNI degisiklik
-- ayrica uygulandi, ikisi birbiriyle tutarli.

-- 1) Kategori adlarini guncelle + yeni kategoriyi ekle
update malzeme_kategorileri set ad = 'ET VE ET URUNLERI' where id = 1;
update malzeme_kategorileri set ad = 'SIVI VE KATI YAGLAR' where id = 4;
insert into malzeme_kategorileri (id, ad) values (18, 'BALIK VE SU URUNLERI')
  on conflict (id) do nothing;

-- 2) Balik/su urunlerini yeni kategoriye tasi (sadece ortak katalog,
--    isletme_id is null -- ozel/isletmeye ozgu malzemelere dokunulmuyor)
update malzemeler set kategori_id = 18
where isletme_id is null
  and kategori_id = 1
  and ad in (
    'FÜME SOMON','SOMON','LEVREK','ÇİPURA','LÜFER','PALAMUT','HAMSİ',
    'SARDALYA','İSTAVRİT','ORKİNOS','KARİDES','KALAMAR','MÜREKKEP BALIĞI',
    'AHTAPOT','MİDYE','MEZGİT'
  );

-- 3) Tereyagini Sut kategorisinden Yag kategorisine tasi
update malzemeler set kategori_id = 4
where isletme_id is null and ad = 'TEREYAĞI';

-- 4) 4 yeni yag malzemesi ekle -- BESIN DEGERLERI BILEREK BOS
--    birakildi (kaynak yok, uydurulmadi). not_aciklama alaninda acikca
--    belirtiliyor.
insert into malzemeler (isletme_id, kategori_id, ad, not_aciklama)
select null, 4, ad, '13 Agustos 2026: TürKomp''tan besin degerleri henuz eklenmedi, sonraki asamada tamamlanacak.'
from (values ('KUYRUKYAĞI'), ('DONYAĞI'), ('SADEYAĞ'), ('MARGARİN')) as yeni(ad)
where not exists (
  select 1 from malzemeler m where m.ad = yeni.ad and m.isletme_id is null
);

-- DOGRULAMA
select mk.id, mk.ad as kategori, count(m.id) as malzeme_sayisi
from malzeme_kategorileri mk
left join malzemeler m on m.kategori_id = mk.id and m.isletme_id is null
group by mk.id, mk.ad
order by mk.id;
