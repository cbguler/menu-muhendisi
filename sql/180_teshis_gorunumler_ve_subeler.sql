-- 180_teshis_gorunumler_ve_subeler.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez).
-- 179 bulgulari: (a) 7 gorunumden 6'si security_invoker DEGIL -> sahibinin
-- yetkisiyle calisir, alttaki tablolarin RLS'ini ATLAYABILIR; hangi veriyi
-- disari actiklarini tanimlarindan gormek gerekiyor. (b) Eski semadan kalma
-- bir "subeler" tablosu var; ne icerdigi ve kullanilip kullanilmadigi bilinmiyor.
-- Bu sorgu: gorunum tanimlari + anon/authenticated okuma izinleri, subeler
-- tablosunun kolonlari ve satir sayisi, isletme_id tasiyan tablolarda RLS acik mi.
-- Tek sorgu: Supabase SQL editoru sadece son sorgunun sonucunu gosterir.

select
  (select jsonb_agg(jsonb_build_object(
            'gorunum', c.relname,
            'security_invoker', coalesce(c.reloptions::text like '%security_invoker=true%', false),
            'anon_okuyabilir', has_table_privilege('anon', c.oid, 'SELECT'),
            'authenticated_okuyabilir', has_table_privilege('authenticated', c.oid, 'SELECT'),
            'tanim', pg_get_viewdef(c.oid, true))
          order by c.relname)
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind in ('v', 'm'))                    as gorunumler,
  (select jsonb_agg(jsonb_build_object('kolon', column_name, 'tip', data_type)
          order by ordinal_position)
     from information_schema.columns
    where table_schema = 'public' and table_name = 'subeler')                  as subeler_kolonlari,
  (select count(*) from public.subeler)                                        as subeler_satir_sayisi,
  (select jsonb_agg(jsonb_build_object('tablo', c.relname, 'rls_acik', c.relrowsecurity)
          order by c.relname)
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind = 'r'
      and exists (select 1 from information_schema.columns col
                   where col.table_schema = 'public' and col.table_name = c.relname
                     and col.column_name in ('isletme_id', 'recete_id')))       as tablo_rls_durumu;
