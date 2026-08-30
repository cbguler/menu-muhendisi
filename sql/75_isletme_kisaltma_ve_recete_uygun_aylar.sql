-- 75_isletme_kisaltma_ve_recete_uygun_aylar.sql
--
-- Kullanicinin 24 Agustos 2026 talebiyle iki yeni alan:
--
-- 1) isletmeler.kisaltma -- kullanicinin kendi reçete adlarina otomatik
--    eklenecek kisa isletme kisaltmasi (ör. "Tavuk Sote" -> "Tavuk Sote
--    (ACM)"). Abonelik sayfasinda isletme adinin yaninda ayri bir kutuda
--    girilecek. Nullable -- girilmemisse recete adina hicbir sey
--    eklenmez.
--
-- 2) receteler.uygun_aylar -- "bu recete yilin hangi aylarinda musteriye
--    sunulabilir?" (ör. sadece yaz aylarinda bulunan bir malzemeye
--    dayanan tarif). Yeni receteler artik SABIT 10 porsiyon olarak
--    uretiliyor (porsiyon sayisi kullanicidan artik sorulmuyor), bosalan
--    yerine bu alan eklendi. text[] -- AYLAR_SIRALI ile ayni Turkce ay
--    isimlerini tasir (ör. '{"Haziran","Temmuz","Agustos"}'). Bos dizi =
--    kisitlama yok, yilin her ayinda sunulabilir.

alter table isletmeler add column if not exists kisaltma text;

alter table receteler add column if not exists uygun_aylar text[] not null default '{}';

-- DOGRULAMA
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where (table_name = 'isletmeler' and column_name = 'kisaltma')
   or (table_name = 'receteler' and column_name = 'uygun_aylar');
