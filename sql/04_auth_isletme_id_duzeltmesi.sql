-- 04_auth_isletme_id_duzeltmesi.sql
--
-- HATA: auth_isletme_id() fonksiyonu kullanicilar tablosunu sorguluyor,
-- ama kullanicilar tablosunun RLS politikasi da bu fonksiyonu cagiriyor.
-- Fonksiyon SECURITY INVOKER (varsayilan) oldugu icin, kendi ic sorgusu da
-- RLS'e tabi oluyor ve bu sonsuz donguye (stack depth limit exceeded)
-- yol aciyordu.
--
-- DUZELTME: fonksiyonu SECURITY DEFINER yapip search_path'i sabitliyoruz.
-- Boylece ic sorgu, fonksiyonu tanimlayan rolun (postgres, RLS'i atlar)
-- yetkisiyle calisir ve dongu kirilir.

create or replace function auth_isletme_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select isletme_id from kullanicilar where id = auth.uid()
$$;
