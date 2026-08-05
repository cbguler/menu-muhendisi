-- 37_iskender_kesin_duzeltme_v2.sql
--
-- 36'daki ILIKE '%iskender kebap%' eslesmesi calismamis olabilir: Turkce'de
-- buyuk I (noktali Ilar ve noktasiz I) farkli karakterlerdir, veritabani
-- tr_TR yapilandirilmadiysa Postgres'in standart kucuk harfe cevirme kurali
-- bunlari esitlemez. Bu script, isim eslestirmesinde I/İ harfi HİÇ
-- gecmeyen '%skender%' alt-dizesini kullaniyor -- hangi yazim olursa olsun
-- (İskender, Iskender, ıskender) garanti eslesir.

-- 1) Malzemeler garanti altina al (34/36'nin tekrari, zararsiz)
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

-- 2) Tani: tarifin veritabanindaki GERCEK adini ve id'sini goster
--    (I/İ sorunundan tamamen bagimsiz, 'skender' alt-dizesiyle)
select id, ad, isletme_id from receteler where ad ilike '%skender%';

-- 3) Baglanti -- 'skender' alt-dizesi ile, I/İ sorunundan bagimsiz
insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
select r.id, m.id, v.miktar_gram
from receteler r
cross join (values
  ('PİDE', 100),
  ('KORNİŞON TURŞU', 20)
) as v(malzeme_adi, miktar_gram)
join malzemeler m on m.ad = v.malzeme_adi and m.isletme_id is null
where r.ad ilike '%skender%kebap%'
  and r.isletme_id is null
  and not exists (
    select 1 from recete_malzemeleri rm
    where rm.recete_id = r.id and rm.malzeme_id = m.id
  );

-- 4) Fiyat geriye donuk doldurma (35/36'nin tekrari, zararsiz)
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

-- 5) DOGRULAMA -- Supabase SQL Editor'de bu son sorgunun sonucuna bak.
--    "...kebap" satirinda PİDE ve KORNİŞON TURŞU gorunuyorsa duzelmis demektir.
select r.id, r.ad as tarif, r.isletme_id, m.ad as malzeme, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad ilike '%skender%'
order by r.ad, m.ad;
