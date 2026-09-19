-- 94_auth_isletme_id_public_yetkisi_kaldir.sql
--
-- Onceki duzeltmede (93) auth_isletme_id() icin SADECE "anon"
-- rolunden EXECUTE kaldirilmisti -- ama dogrulama sonucu gosterdi ki
-- "PUBLIC" (Postgres'te "herkes" anlamina gelen ozel bir rol/kural)
-- HALA EXECUTE yetkisine sahipti. PUBLIC yetkisi VARKEN, tek basina
-- "anon"dan REVOKE etmek ETKISIZ kalir -- cunku anon, PUBLIC'in
-- KENDISI araciligiyla YINE erisebilir (Postgres'te her rol, PUBLIC'in
-- dolayli bir uyesidir). Simdi PUBLIC'ten de kaldiriliyor --
-- "authenticated" icin AYRI, DOGRUDAN bir yetki zaten var (onceki
-- dogrulamada goruldu), o YETKI BU ISLEMDEN ETKILENMEZ (PUBLIC'ten
-- kaldirmak, authenticated'in KENDI ayri yetkisini SILMEZ).

revoke execute on function public.auth_isletme_id() from public;

-- DOGRULAMA
select routine_name, grantee, privilege_type
from information_schema.role_routine_grants
where routine_name = 'auth_isletme_id'
and routine_schema = 'public'
order by grantee;
