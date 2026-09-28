-- 176_teshis_abonelik_planlari.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez). Admin sayfasina plan secimi ve
-- abonelik yonetimi eklemeden once mevcut yapiyi varsaymadan gormek icin:
--   abonelik_planlari satirlari ve kolonlari, abonelikler kolonlari ve durum kisiti,
--   isletme_aktif_abonelik gorunumunun tanimi, iki tablonun RLS politikalari,
--   durum bazinda abonelik sayilari.
-- Tek sorgu: Supabase SQL editoru sadece son sorgunun sonucunu gosterir.

select
  (select jsonb_agg(to_jsonb(p)) from public.abonelik_planlari p)              as plan_satirlari,
  (select jsonb_agg(jsonb_build_object('kolon', column_name, 'tip', data_type,
                                       'bos_olabilir', is_nullable)
                    order by ordinal_position)
     from information_schema.columns
    where table_schema = 'public' and table_name = 'abonelik_planlari')          as plan_kolonlari,
  (select jsonb_agg(jsonb_build_object('kolon', column_name, 'tip', data_type,
                                       'bos_olabilir', is_nullable)
                    order by ordinal_position)
     from information_schema.columns
    where table_schema = 'public' and table_name = 'abonelikler')                as abonelik_kolonlari,
  (select jsonb_agg(jsonb_build_object('ad', conname, 'tanim', pg_get_constraintdef(oid)))
     from pg_constraint
    where conrelid in ('public.abonelikler'::regclass,
                       'public.abonelik_planlari'::regclass)
      and contype in ('c', 'f', 'u'))                                            as kisitlar,
  (select pg_get_viewdef('public.isletme_aktif_abonelik'::regclass, true))      as gorunum_tanimi,
  (select jsonb_agg(jsonb_build_object('tablo', tablename, 'politika', policyname,
                                       'komut', cmd, 'using', qual, 'check', with_check))
     from pg_policies
    where schemaname = 'public'
      and tablename in ('abonelik_planlari', 'abonelikler'))                     as politikalar,
  (select jsonb_object_agg(durum, sayi)
     from (select durum, count(*) as sayi from public.abonelikler group by durum) d) as durum_sayilari;
