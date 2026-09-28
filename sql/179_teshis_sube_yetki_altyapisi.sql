-- 179_teshis_sube_yetki_altyapisi.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez). Isletme / Sube / Personel yetki
-- modeline gecmeden once, isletme verisi tasiyan HER seyi varsaymadan gormek icin:
--   isletme_id kolonu olan tablolar ve gorunumler (gorunumlerde security_invoker),
--   bu tablolarin RLS politikalari, auth_isletme_id() kullanan fonksiyonlar,
--   isletmeler tablosunun kolonlari.
-- Tek sorgu: Supabase SQL editoru sadece son sorgunun sonucunu gosterir.

select
  (select jsonb_agg(c.table_name order by c.table_name)
     from information_schema.columns c
     join information_schema.tables t
       on t.table_schema = c.table_schema and t.table_name = c.table_name
    where c.table_schema = 'public' and c.column_name = 'isletme_id'
      and t.table_type = 'BASE TABLE')                                        as isletme_id_tablolari,
  (select jsonb_agg(jsonb_build_object(
            'gorunum', cl.relname,
            'security_invoker', coalesce(cl.reloptions::text like '%security_invoker=true%', false))
          order by cl.relname)
     from pg_class cl
     join pg_namespace n on n.oid = cl.relnamespace
    where n.nspname = 'public' and cl.relkind in ('v', 'm'))                  as gorunumler,
  (select jsonb_agg(jsonb_build_object(
            'tablo', p.tablename, 'politika', p.policyname, 'komut', p.cmd,
            'using', p.qual, 'check', p.with_check)
          order by p.tablename, p.policyname)
     from pg_policies p
    where p.schemaname = 'public'
      and p.tablename in (select c.table_name from information_schema.columns c
                           where c.table_schema = 'public' and c.column_name = 'isletme_id')) as politikalar,
  (select jsonb_agg(p.proname order by p.proname)
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prosrc like '%auth_isletme_id%')          as auth_isletme_id_kullanan_fonksiyonlar,
  (select jsonb_agg(jsonb_build_object('kolon', column_name, 'tip', data_type)
          order by ordinal_position)
     from information_schema.columns
    where table_schema = 'public' and table_name = 'isletmeler')              as isletmeler_kolonlari,
  (select count(*) from public.isletmeler)                                    as isletme_sayisi;
