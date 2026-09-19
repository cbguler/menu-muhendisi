-- 101_ACIL_auth_isletme_id_authenticated_geri_ver.sql
--
-- ACIL DUZELTME -- ONCEKI OTURUMDA YAPILAN BIR HATA GERI ALINIYOR.
--
-- Daha once (95 numarali migration) "auth_isletme_id()" fonksiyonunun
-- "authenticated" rolunden EXECUTE yetkisi kaldirilmisti -- gerekce
-- "kod tabaninda dogrudan cagrilmiyor, sadece RLS kurallari icinde
-- kullaniliyor" idi. BU YANLIS BIR VARSAYIMDI: Postgres'te bir
-- fonksiyon RLS POLITIKASININ (USING/WITH CHECK) ICINDE referans
-- veriliyorsa, SORGUYU YAPAN ROLUN (bu durumda "authenticated") YINE
-- DE o fonksiyona EXECUTE yetkisi OLMASI GEREKIR -- SECURITY DEFINER
-- olmasi bu gereksinimi ORTADAN KALDIRMAZ (sadece fonksiyonun
-- GOVDESININ hangi yetkiyle CALISACAGINI belirler, fonksiyonun
-- CAGRILABILIR olup olmadigini DEGIL).
--
-- SONUC: "authenticated" rolunun auth_isletme_id() calistiramamasi,
-- bu fonksiyonu RLS kuralinda kullanan HER TABLONUN (ör. kullanicilar)
-- authenticated kullanicilar tarafindan sorgulanamamasina yol acti --
-- yani NEREDEYSE TUM GIRIS/KAYIT AKISI kirildi.

grant execute on function public.auth_isletme_id() to authenticated;

-- "anon" ve "PUBLIC" icin onceki kaldirma DOGRU KALIYOR (dokunulmuyor)
-- -- cunku anonim kullanicilarin auth.uid()'i zaten NULL olur, bu
-- fonksiyonu anonim baglamda cagirmanin/RLS'de kullanmanin bir
-- MANTIGI yok, ve bu SPESIFIK hatayla ILGISI YOK (hata authenticated
-- rolu icin olustu).

-- DOGRULAMA
select routine_name, grantee, privilege_type
from information_schema.role_routine_grants
where routine_name = 'auth_isletme_id'
and routine_schema = 'public'
order by grantee;
