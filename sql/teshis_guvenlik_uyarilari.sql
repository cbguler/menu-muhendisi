-- Guvenlik uyarilarinin GERCEK tanimlarini gormek icin -- bunlarin
-- NASIL kullanildigini anlamadan (uygulama tarafindan mi cagriliyor,
-- sadece ic tetikleyici mi) kor bir duzeltme yapmak riskli olurdu.

-- 1) recete_guncel_maliyet GORUNUMUNUN tanimi
select pg_get_viewdef('public.recete_guncel_maliyet', true) as view_tanimi;

-- 2) Ucfonksiyonun tanimi
select proname, prosecdef as security_definer_mi, pg_get_functiondef(oid) as fonksiyon_tanimi
from pg_proc
where proname in ('auth_isletme_id', 'rls_auto_enable', 'yeni_kullanici_isle')
and pronamespace = 'public'::regnamespace;

-- 3) Bu fonksiyonlara hangi ROLLERIN (anon/authenticated/vb.) EXECUTE
--    izni var, tam olarak gormek icin
select routine_name, grantee, privilege_type
from information_schema.role_routine_grants
where routine_name in ('auth_isletme_id', 'rls_auto_enable', 'yeni_kullanici_isle')
and routine_schema = 'public';
