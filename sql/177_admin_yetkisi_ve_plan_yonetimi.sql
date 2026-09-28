-- 177_admin_yetkisi_ve_plan_yonetimi.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Admin sayfasinin genisletilmesi.
--
-- Bahri'nin kurali: platform admin'i SADECE Bahri; ileride YALNIZCA Emre ve esi
-- Gizem eklenebilir. Baska HICBIR abone asla admin olamaz.
-- Bu yuzden admin listesi bir tabloda DEGIL, asagidaki fonksiyonun icinde
-- sabit yazili: uygulamadan, admin sayfasindan veya herhangi bir kullanicidan
-- degistirilemez; SADECE yeni bir migration ile degisir.
-- Su an listede sadece bahriguler@gmail.com var. Emre/Gizem, Bahri'nin acik
-- karariyla ve ayri bir migration ile eklenir.
--
-- Degisiklikler:
--  1) public.auth_admin_mi(): tek dogruluk kaynagi (app.py de bunu cagiracak).
--  2) public semasinda sabit e-posta kontrolu iceren BUTUN politikalar
--     auth_admin_mi()'ye cevrilir (davranis ayni, admin listesi tek yerde).
--  3) abonelik_planlari: admin guncelleyebilir (plan fiyat/limit/ozellik duzenleme).
--  4) kullanicilar ve personel_yetkileri: admin okuyabilir (admin sayfasinda
--     isletme basina kullanici/personel listesi).

begin;

-- 1) Admin listesi
create or replace function public.auth_admin_mi()
returns boolean
language sql stable
set search_path to 'public'
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) = any (array[
    'bahriguler@gmail.com'
    -- Emre ve Gizem SADECE Bahri'nin acik karariyla, ayri migration ile eklenir.
  ])
$$;

-- 2) Sabit e-postali politikalari fonksiyona cevir
do $$
declare
  pol record;
  eski constant text := '((auth.jwt() ->> ''email''::text) = ''bahriguler@gmail.com''::text)';
  yeni_using text;
  yeni_check text;
begin
  for pol in
    select tablename, policyname, qual, with_check
      from pg_policies
     where schemaname = 'public'
       and (coalesce(qual, '') like '%bahriguler@gmail.com%'
            or coalesce(with_check, '') like '%bahriguler@gmail.com%')
  loop
    yeni_using := replace(pol.qual, eski, 'auth_admin_mi()');
    yeni_check := replace(pol.with_check, eski, 'auth_admin_mi()');
    if yeni_using is not null and yeni_check is not null then
      execute format('alter policy %I on public.%I using (%s) with check (%s)',
                     pol.policyname, pol.tablename, yeni_using, yeni_check);
    elsif yeni_using is not null then
      execute format('alter policy %I on public.%I using (%s)',
                     pol.policyname, pol.tablename, yeni_using);
    else
      execute format('alter policy %I on public.%I with check (%s)',
                     pol.policyname, pol.tablename, yeni_check);
    end if;
  end loop;
end $$;

-- 3) Plan duzenleme
create policy "admin planlari guncelleyebilir" on public.abonelik_planlari
  for update using (auth_admin_mi()) with check (auth_admin_mi());

-- 4) Admin okuma
create policy "admin tum kullanicilari gor" on public.kullanicilar
  for select using (auth_admin_mi());
create policy "admin tum personeli gor" on public.personel_yetkileri
  for select using (auth_admin_mi());

commit;

-- Dogrulama (tek sorgu, 1 satir):
--   kalan_sabit_eposta_politikalari 0 olmali (varsa adlari listelenir),
--   admin_politikalari fonksiyonu kullanan politikalarin listesi,
--   admin_listesi fonksiyon govdesi.
select
  (select coalesce(jsonb_agg(tablename || '.' || policyname), '[]'::jsonb)
     from pg_policies
    where schemaname = 'public'
      and (coalesce(qual, '') like '%bahriguler@gmail.com%'
           or coalesce(with_check, '') like '%bahriguler@gmail.com%'))  as kalan_sabit_eposta_politikalari,
  (select jsonb_agg(tablename || '.' || policyname order by tablename)
     from pg_policies
    where schemaname = 'public'
      and (coalesce(qual, '') like '%auth_admin_mi()%'
           or coalesce(with_check, '') like '%auth_admin_mi()%'))       as admin_politikalari,
  (select prosrc from pg_proc where proname = 'auth_admin_mi')          as admin_listesi;
