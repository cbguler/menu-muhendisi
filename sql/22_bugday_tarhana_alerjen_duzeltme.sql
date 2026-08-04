-- 22_bugday_tarhana_alerjen_duzeltme.sql
--
-- 21_ic_anadolu_malzemeleri_ekle.sql'de BUĞDAY (TAM TANE) ve TARHANA
-- eklenirken alerjen baglantilari unutulmustu -- ikisi de bugday
-- (gluten) icerir, TARHANA ayrica yogurt (sut) icerir. Celyak/glüten
-- hassasiyeti olan biri icin bu onemli bir eksiklikti, duzeltiliyor.

insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'BUĞDAY (TAM TANE)' and m.isletme_id is null and a.ad = 'Gluten'
on conflict do nothing;

insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'TARHANA' and m.isletme_id is null and a.ad in ('Gluten', 'Sut')
on conflict do nothing;
