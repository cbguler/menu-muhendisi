-- 174_teshis_personel_altyapisi.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez). "Personel ve Yetkiler" ozelligi
-- icin mevcut semayi varsaymadan gormek amaciyla:
--   kayit tetikleyicisinin (05) guncel tanimi, kullanicilar kisitlari (rol),
--   auth_isletme_id() tanimi, recete ile ilgili tablolarin RLS politikalari,
--   recete_id kolonu tasiyan tablolar.
-- Tek sorgu: Supabase SQL editoru sadece son sorgunun sonucunu gosterir.

select
  (select jsonb_agg(jsonb_build_object(
            'tetikleyici', t.tgname,
            'fonksiyon', pg_get_functiondef(t.tgfoid)))
     from pg_trigger t
    where t.tgrelid = 'auth.users'::regclass
      and not t.tgisinternal)                                   as kayit_tetikleyicileri,
  (select jsonb_agg(jsonb_build_object(
            'ad', c.conname, 'tanim', pg_get_constraintdef(c.oid)))
     from pg_constraint c
    where c.conrelid = 'public.kullanicilar'::regclass)          as kullanicilar_kisitlari,
  (select jsonb_agg(jsonb_build_object(
            'kolon', column_name, 'tip', data_type, 'bos_olabilir', is_nullable))
     from information_schema.columns
    where table_schema = 'public' and table_name = 'kullanicilar') as kullanicilar_kolonlari,
  (select string_agg(pg_get_functiondef(p.oid), E'\n---\n')
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'auth_isletme_id') as auth_isletme_id_tanimi,
  (select jsonb_agg(distinct table_name)
     from information_schema.columns
    where table_schema = 'public' and column_name = 'recete_id')  as recete_id_tasiyan_tablolar,
  (select jsonb_agg(jsonb_build_object(
            'tablo', tablename, 'politika', policyname, 'komut', cmd,
            'using', qual, 'check', with_check) order by tablename, policyname)
     from pg_policies
    where schemaname = 'public'
      and (tablename ilike '%recete%'
           or tablename in ('kullanicilar', 'isletmeler', 'abonelikler'))) as politikalar;
