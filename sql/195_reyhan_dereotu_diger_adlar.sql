-- 195_reyhan_dereotu_diger_adlar.sql
-- 15 Ekim 2026. Bahri: "Reyhan'i aradim bulamadim, malzeme database'ine eklenmeli."
-- Reyhan, fesleğenin (Ocimum basilicum) yöresel adıdır; katalogda besin değerleriyle
-- "TAZE FESLEĞEN" olarak zaten var. Ayrı kayıt açılmaz (aynı malzeme iki farklı değerle
-- tutulmasın); ad, mevcut kaydın diğer adlarına eklenir. Böylece tarif okumada ve malzeme
-- aramasında "reyhan" yazınca TAZE FESLEĞEN bulunur. Aynı şekilde "dereotu" -> TAZE DEREOTU.
-- Mevcut diğer adlar korunur, aynı ad iki kez eklenmez. Tekrar çalıştırmak güvenli.

begin;

do $$
declare
  v record;
  n int;
begin
  for v in select * from (values
      ('TAZE FESLEĞEN', 'REYHAN'),
      ('TAZE FESLEĞEN', 'MOR REYHAN'),
      ('TAZE FESLEĞEN', 'FESLEĞEN'),
      ('TAZE DEREOTU',  'DEREOTU')
    ) as t(ad, diger)
  loop
    update public.malzemeler
       set diger_adlar = array_append(coalesce(diger_adlar, '{}'::text[]), v.diger)
     where isletme_id is null and ad = v.ad
       and not (v.diger = any(coalesce(diger_adlar, '{}'::text[])));
    get diagnostics n = row_count;
    if n = 0 and not exists (select 1 from public.malzemeler where isletme_id is null and ad = v.ad) then
      raise exception 'Katalogda bulunamadı: % -- hiçbir değişiklik yapılmadı', v.ad;
    end if;
  end loop;
end $$;

commit;

-- Doğrulama (2 satır): diğer adlar listesinde REYHAN / DEREOTU görünmeli
select ad, diger_adlar
from public.malzemeler
where isletme_id is null and ad in ('TAZE FESLEĞEN', 'TAZE DEREOTU')
order by ad;
