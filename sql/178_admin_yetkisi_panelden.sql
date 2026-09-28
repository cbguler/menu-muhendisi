-- 178_admin_yetkisi_panelden.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Admin yetkisinin panelden
-- verilip alinabilmesi.
--
-- Bahri'nin kurali: platform admin'i Bahri; YALNIZCA Emre ve esi Gizem'e admin
-- hakki verilebilir, baska HICBIR abone ASLA. Emre ve Gizem once abone olarak
-- girip denetim yapacak; admin hakkini Bahri admin panelinden ACIP KAPATACAK.
--
-- Tasarim (iki kilit):
--  1) ADAY LISTESI sabit: kimin admin olabilecegi fonksiyonun ve tablo
--     kisitinin icinde yazili. Panelden yeni aday EKLENEMEZ; aday listesi
--     sadece migration ile degisir. Su an aday: Emre. Gizem'in e-postasi
--     bilinmedigi icin henuz yok; e-postasi gelince kucuk bir migration ile
--     eklenecek.
--  2) ACIK/KAPALI anahtari tabloda: admin_yetkileri.aktif. Bu tabloyu SADECE
--     ana admin (Bahri) gorebilir ve guncelleyebilir; satir ekleme/silme
--     politikasi YOK. Emre admin olsa bile kendisinin veya baskasinin
--     yetkisini degistiremez.
-- Baslangic: Emre'nin satiri aktif = false (Bahri'nin karari: simdilik admin degil).

begin;

-- Ana admin: sabit, panelden asla degismez
create or replace function public.auth_ana_admin_mi()
returns boolean
language sql stable
set search_path to 'public'
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) = 'bahriguler@gmail.com'
$$;

create table public.admin_yetkileri (
  email          text primary key,
  aktif          boolean not null default false,
  updated_at     timestamptz not null default now(),
  -- KILIT 1 (tablo tarafi): aday listesi disinda satir olamaz
  constraint admin_yetkileri_aday_check
    check (email = any (array['emreguler98@hotmail.com']))
);

insert into public.admin_yetkileri (email, aktif)
values ('emreguler98@hotmail.com', false);

alter table public.admin_yetkileri enable row level security;

create policy "ana admin admin yetkilerini gor" on public.admin_yetkileri
  for select using (auth_ana_admin_mi());
create policy "ana admin admin yetkilerini guncelle" on public.admin_yetkileri
  for update using (auth_ana_admin_mi()) with check (auth_ana_admin_mi());
-- INSERT ve DELETE politikasi bilerek YOK.

-- auth_admin_mi: ana admin VEYA (aday listesinde VE panelden acilmis).
-- SECURITY DEFINER: admin_yetkileri'ni RLS'e takilmadan okur.
create or replace function public.auth_admin_mi()
returns boolean
language sql stable security definer
set search_path to 'public'
as $$
  select auth_ana_admin_mi()
      or exists (
           select 1
             from admin_yetkileri y
            where y.aktif
              and y.email = lower(coalesce(auth.jwt() ->> 'email', ''))
              -- KILIT 1 (fonksiyon tarafi): aday listesi
              and y.email = any (array['emreguler98@hotmail.com'])
         )
$$;

commit;

-- Dogrulama (tek sorgu, 1 satir): Emre satiri aktif=false, 2 politika,
-- auth_admin_mi govdesi admin_yetkileri'ni iceriyor.
select
  (select jsonb_agg(to_jsonb(y)) from public.admin_yetkileri y)                  as admin_yetkileri,
  (select count(*) from pg_policies
    where schemaname = 'public' and tablename = 'admin_yetkileri')               as politika_sayisi,
  (select prosrc like '%admin_yetkileri%' from pg_proc
    where proname = 'auth_admin_mi')                                             as fonksiyon_guncel;
