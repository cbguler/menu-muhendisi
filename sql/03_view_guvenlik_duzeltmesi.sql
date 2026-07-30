-- 03_view_guvenlik_duzeltmesi.sql
--
-- ONEMLI GUVENLIK DUZELTMESI: Postgres'te view'ler varsayilan olarak view'i
-- OLUSTURAN rolun (Supabase'de bu genelde 'postgres' superuser) yetkileriyle
-- calisir, sorguyu YAPAN kullanicinin degil. Superuser RLS'yi tamamen
-- atladigi icin, bu duzeltme yapilmadan asagidaki 4 view herhangi bir
-- isletmenin verisini (maliyet, kar marji, abonelik durumu, fiyat) TUM
-- isletmeler icin ifsa edebilir.
--
-- security_invoker=on ayari, RLS kontrolunu view sahibi yerine sorguyu
-- yapan kullanicinin rolu uzerinden calistirir -- boylece auth_isletme_id()
-- filtreleri view uzerinden de dogru sekilde uygulanir.

alter view malzeme_guncel_fiyat set (security_invoker = on);
alter view recete_guncel_maliyet set (security_invoker = on);
alter view menu_ogesi_karlilik set (security_invoker = on);
alter view isletme_aktif_abonelik set (security_invoker = on);
