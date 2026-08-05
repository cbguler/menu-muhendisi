-- 36_iskender_kesin_duzeltme.sql
--
-- 34/35 calistirildi ama "İskender Kebap" tarifinde PİDE/KORNİŞON TURŞU
-- hala gorunmuyor. En olasi neden: 35'teki tam esitlik (r.ad = 'İskender
-- Kebap') sessizce 0 satir eslesmis olabilir (isim farkli yazilmis olabilir,
-- veya 34 calismadan once 35 calistirilmis olabilir -- ikisi de INSERT...
-- SELECT oldugu icin 0 satir eklenince HATA VERMEZ, sessizce hicbir sey
-- yapmaz). Bu script: (1) malzemeleri garanti eder, (2) baglantiyi ILIKE
-- ile daha toleransli kurar, (3) sonunda gercek durumu gosteren bir SELECT
-- dondurur -- Supabase SQL Editor'de bu son sorgunun sonucuna bak.

-- 1) Malzemeler var mi, garanti altina al (34'un tekrari, zararsiz)
insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values
(
  null, 8, 'PİDE', 0.4, 2.8, 3,
  0.05, 21, 275, 9, 3, 53,
  70, 'Yıl boyunca', 0.3, 150,
  '3 Ağustos 2026 eklendi (İskender Kebap icin -- etin altina serilen pide)',
  2.00
),
(
  null, 2, 'KORNİŞON TURŞU', 0.9, 3.8, 180,
  0.02, 4, 12, 0.5, 0.2, 2,
  15, 'Yıl boyunca', 0.5, 100,
  '3 Ağustos 2026 eklendi (İskender Kebap servis garnitürü)',
  3.50
)
on conflict do nothing;

insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'PİDE' and m.isletme_id is null and a.ad = 'Gluten'
on conflict do nothing;

-- 2) Baglanti: ILIKE ile (buyuk/kucuk harf, olasi bosluk farkina karsi
--    35'ten daha toleransli), sadece global (isletme_id is null) tarif
insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
select r.id, m.id, v.miktar_gram
from receteler r
cross join (values
  ('PİDE', 100),
  ('KORNİŞON TURŞU', 20)
) as v(malzeme_adi, miktar_gram)
join malzemeler m on m.ad = v.malzeme_adi and m.isletme_id is null
where r.ad ilike '%iskender kebap%'
  and r.isletme_id is null
  and not exists (
    select 1 from recete_malzemeleri rm
    where rm.recete_id = r.id and rm.malzeme_id = m.id
  );

-- 3) Fiyat geriye donuk doldurma (35'in tekrari, zararsiz/idempotent)
insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
select i.id, m.id, m.varsayilan_fiyat_eur, 'Varsayılan (bölgesel genişletme oturumu)'
from isletmeler i
cross join malzemeler m
where m.ad in ('PİDE', 'KORNİŞON TURŞU')
  and m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id and mfg.malzeme_id = m.id
  );

-- 4) DOGRULAMA -- bu sorgunun sonucuna bak. "İskender Kebap" satirinda
--    PİDE ve KORNİŞON TURŞU gorunuyorsa duzeltme basarili demektir.
--    Hicbir satir donmuyorsa, r.ad'in gercek yazimini ogrenmek icin
--    ayrica calistir: select id, ad, isletme_id from receteler where ad ilike '%iskender%';
select r.ad as tarif, r.isletme_id, m.ad as malzeme, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad ilike '%iskender%'
order by r.ad, m.ad;
