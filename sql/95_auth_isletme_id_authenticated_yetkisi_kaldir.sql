-- 95_auth_isletme_id_authenticated_yetkisi_kaldir.sql
--
-- Kod tabaninda "auth_isletme_id" veya herhangi bir ".rpc(...)"
-- cagrisi HIC bulunamadi (grep ile dogrulandi) -- bu fonksiyon SADECE
-- RLS politikalarinin ICINDE kullaniliyor, uygulama tarafindan
-- DOGRUDAN cagrilmiyor. RLS kurallari, cagiran kullanicinin
-- fonksiyona DOGRUDAN EXECUTE yetkisi olmasa bile kendi ic
-- mekanizmasiyla dogru calisir (Postgres'in bilinen bir davranisi).
-- Bu yuzden "authenticated" yetkisini de guvenle kaldirabiliriz --
-- uygulamanin normal islevini ETKILEMEZ.

revoke execute on function public.auth_isletme_id() from authenticated;

-- DOGRULAMA
select routine_name, grantee, privilege_type
from information_schema.role_routine_grants
where routine_name = 'auth_isletme_id'
and routine_schema = 'public'
order by grantee;
