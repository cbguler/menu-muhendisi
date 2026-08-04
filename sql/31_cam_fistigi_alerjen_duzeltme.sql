-- 31_cam_fistigi_alerjen_duzeltme.sql
--
-- 27_...sql'de CAM FISTIGI eklenirken alerjen baglantisi unutulmustu.
-- Cam fistigi botanik olarak bir tohum olsa da, gida alerjeni
-- etiketlemesinde (FALCPA, AB gida bilgisi yonetmeligi) genellikle
-- "sert kabuklu yemis" kategorisinde sayilir -- guvenlik acisindan
-- onemli bir eksiklikti.

insert into malzeme_alerjen (malzeme_id, alerjen_id)
select m.id, a.id
from malzemeler m, alerjenler a
where m.ad = 'ÇAM FISTIĞI' and m.isletme_id is null and a.ad = 'Sert Kabuklu Yemis'
on conflict do nothing;
