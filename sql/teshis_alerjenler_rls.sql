-- teshis_alerjenler_rls.sql
--
-- HIPOTEZ: SQL Editor'den calistirilan sorgular RLS'i ATLIYOR (superuser
-- yetkisiyle calisiyor), ama canli uygulama anon/authenticated rolle
-- baglaniyor ve RLS'e TABI. Eger "alerjenler" tablosunda bu rollere
-- SELECT izni veren bir politika yoksa, uygulamadan yapilan JOIN
-- (malzeme_alerjen -> alerjenler) HATA VERMEDEN sessizce NULL doner --
-- tam da gozlemlenen "veri DB'de var ama uygulama gormuyor" belirtisi.

-- 1) alerjenler tablosunda RLS acik mi, ve hangi politikalar var?
select schemaname, tablename, rowsecurity
from pg_tables
where tablename in ('alerjenler', 'malzeme_alerjen');

select tablename, policyname, roles, cmd, qual
from pg_policies
where tablename in ('alerjenler', 'malzeme_alerjen');

-- 2) anon ve authenticated rollerinin bu iki tabloda GRANT SELECT izni
-- var mi? (RLS politikasi olsa bile, temel GRANT de olmali)
select grantee, table_name, privilege_type
from information_schema.role_table_grants
where table_name in ('alerjenler', 'malzeme_alerjen')
  and grantee in ('anon', 'authenticated');
