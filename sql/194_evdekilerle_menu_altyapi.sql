-- 194_evdekilerle_menu_altyapi.sql
-- 13 Ekim 2026. "Evdekilerle Menü" (oneri: Efe Turkoglu; tasarim: ev_stok_menu_tasarim_v3.md).
-- Sadece altyapi: yeni sutunlar ve stok tablosu. Mevcut hicbir veri degismez.
--
--   1) isletmeler.ev_menu_hizmeti  boolean  -- NULL = henuz sorulmadi, true = acik, false = kapali
--   2) isletmeler.ev_menu_ayarlari jsonb    -- son secimler (porsiyon, ogun, gun, iki_tarif,
--                                              temel_haric); kullanici her seferinde bastan secmesin
--      Ikisini de isletmenin sahibi degistirir (mevcut "isletme bilgisini sadece patron degistirir"
--      politikasi gecerli; personel degistiremez).
--   3) ev_stogu: isletmenin elindeki malzemeler (malzeme_id + gram). Ilk surumde sadece sahip
--      gorur ve degistirir (tasarim: personel erisimi Faz 2).
-- Tekrar calistirmak guvenli (if not exists).

begin;

alter table public.isletmeler add column if not exists ev_menu_hizmeti boolean;
alter table public.isletmeler add column if not exists ev_menu_ayarlari jsonb;

create table if not exists public.ev_stogu (
  id           uuid primary key default gen_random_uuid(),
  isletme_id   uuid not null references public.isletmeler(id) on delete cascade,
  malzeme_id   uuid not null references public.malzemeler(id) on delete cascade,
  miktar_gram  numeric not null check (miktar_gram > 0),
  updated_at   timestamptz not null default now(),
  unique (isletme_id, malzeme_id)
);
create index if not exists ev_stogu_isletme_idx on public.ev_stogu (isletme_id);

alter table public.ev_stogu enable row level security;

drop policy if exists "sahip kendi ev stogunu yonetir" on public.ev_stogu;
create policy "sahip kendi ev stogunu yonetir" on public.ev_stogu for all
  using (isletme_id = auth_isletme_id() and auth_sahip_mi())
  with check (isletme_id = auth_isletme_id() and auth_sahip_mi());

revoke all on public.ev_stogu from anon;
grant select, insert, update, delete on public.ev_stogu to authenticated;

commit;

-- Dogrulama (tek satir): iki sutun var, tablo var, RLS acik, 1 politika, anon erisemiyor.
select
  (select count(*) from information_schema.columns
    where table_schema = 'public' and table_name = 'isletmeler'
      and column_name in ('ev_menu_hizmeti', 'ev_menu_ayarlari'))            as yeni_sutun_sayisi_2_olmali,
  (select relrowsecurity from pg_class where oid = 'public.ev_stogu'::regclass) as ev_stogu_rls_acik,
  (select count(*) from pg_policies
    where schemaname = 'public' and tablename = 'ev_stogu')                  as politika_sayisi_1_olmali,
  has_table_privilege('anon', 'public.ev_stogu', 'select')                   as anon_okuyabilir_false_olmali,
  (select count(*) from public.ev_stogu)                                     as stok_satiri_0_olmali;
