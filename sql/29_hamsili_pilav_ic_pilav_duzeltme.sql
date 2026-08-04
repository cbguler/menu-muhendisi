-- 29_hamsili_pilav_ic_pilav_duzeltme.sql
--
-- Kullanicinin bulduğu gercek eksiklik: "Hamsili Pilav" (Karadeniz)
-- sade pirincle yazilmisti, oysa geleneksel tarifte pirinc "Ic Pilav"
-- teknigiyle (cam fistigi + kus uzumu ile) pisirilir. 27_...sql'de bu
-- malzemeler eklendigi icin artik ekleyebiliyoruz.

insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
select r.id, m.id, v.miktar_gram
from receteler r
cross join (values
  ('Hamsili Pilav', 'ÇAM FISTIĞI', 10),
  ('Hamsili Pilav', 'KUŞ ÜZÜMÜ', 10)
) as v(recete_adi, malzeme_adi, miktar_gram)
join malzemeler m on m.ad = v.malzeme_adi and m.isletme_id is null
where r.ad = v.recete_adi
  and r.isletme_id is null
  and not exists (
    select 1 from recete_malzemeleri rm
    where rm.recete_id = r.id and rm.malzeme_id = m.id
  );
