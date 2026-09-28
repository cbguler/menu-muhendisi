-- 175_personel_yetkileri_altyapi.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): "Personel ve Yetkiler" FAZ 1.
-- Sadece ALTYAPI: yeni tablo + yardimci fonksiyon + kayit tetikleyicisi + rol kisiti.
-- Mevcut tablolarin (receteler, recete_malzemeleri, maliyet gorunumleri) RLS
-- politikalarina DOKUNULMUYOR; mevcut kullanicilarin davranisi degismez.
-- Recete/maliyet gizleme ve sayfa yetkilerinin RLS ile zorlanmasi FAZ 2'de.
--
-- 174 teshisine dayanir:
--   * kayit tetikleyicisi on_auth_user_created -> public.yeni_kullanici_isle():
--     her yeni kullaniciya yeni isletme + 'sahip' + 'odeme_bekleniyor' abonelik aciyor.
--   * kullanicilar_rol_check: 'sahip','yonetici','mutfak','salt_okunur'.
-- Degisiklikler:
--   1) kullanicilar_rol_check'e 'muhasebe' eklenir (Asci='mutfak', Yonetici='yonetici').
--   2) personel_yetkileri tablosu: sahip personeli e-postasiyla ONCE buraya yazar;
--      hesap acilinca tetikleyici kisiyi yeni isletme ACMADAN sahibin isletmesine baglar.
--      Yetki bilgisi istemci metadata'sindan DEGIL bu tablodan okunur (baskasinin
--      isletmesine metadata ile sizma engellenir).
--   3) auth_sahip_mi(): RLS icin yardimci.
--   4) yeni_kullanici_isle(): personel_yetkileri'nde bekleyen kayit varsa personel yolu,
--      yoksa eskisiyle BIREBIR ayni sahip yolu.

begin;

-- 1) Rol kisiti
alter table public.kullanicilar drop constraint kullanicilar_rol_check;
alter table public.kullanicilar add constraint kullanicilar_rol_check
  check (rol = any (array['sahip','yonetici','mutfak','salt_okunur','muhasebe']));

-- 2) Personel yetkileri
create table public.personel_yetkileri (
  id                     uuid primary key default gen_random_uuid(),
  isletme_id             uuid not null references public.isletmeler(id) on delete cascade,
  email                  text not null,
  kullanici_id           uuid unique references public.kullanicilar(id) on delete cascade,
  ad_soyad               text,
  rol                    text not null check (rol in ('yonetici','mutfak','muhasebe')),
  -- sayfa anahtari -> 'yok' | 'goruntule' | 'duzenle'  (ornek: {"aylik_menu":"goruntule"})
  sayfa_yetkileri        jsonb not null default '{}'::jsonb,
  kendi_receteleri_gorur boolean not null default true,
  maliyet_gorur          boolean not null default false,
  aktif                  boolean not null default true,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);
-- Bir e-posta yalnizca TEK isletmenin personeli olabilir
create unique index personel_yetkileri_email_uq on public.personel_yetkileri (lower(email));
create index personel_yetkileri_isletme_idx on public.personel_yetkileri (isletme_id);

-- 3) Yardimci: oturumdaki kullanici kendi isletmesinin sahibi mi?
--    SECURITY DEFINER: kullanicilar RLS'ine takilmadan okur (auth_isletme_id ile ayni desen).
create or replace function public.auth_sahip_mi()
returns boolean
language sql stable security definer
set search_path to 'public'
as $$
  select exists (select 1 from kullanicilar where id = auth.uid() and rol = 'sahip')
$$;

alter table public.personel_yetkileri enable row level security;

create policy "sahip personelini gor" on public.personel_yetkileri
  for select using (isletme_id = auth_isletme_id() and auth_sahip_mi());
create policy "personel kendi yetkisini gor" on public.personel_yetkileri
  for select using (kullanici_id = auth.uid());
create policy "sahip personel ekle" on public.personel_yetkileri
  for insert with check (isletme_id = auth_isletme_id() and auth_sahip_mi());
create policy "sahip personel guncelle" on public.personel_yetkileri
  for update using (isletme_id = auth_isletme_id() and auth_sahip_mi())
  with check (isletme_id = auth_isletme_id() and auth_sahip_mi());
create policy "sahip personel sil" on public.personel_yetkileri
  for delete using (isletme_id = auth_isletme_id() and auth_sahip_mi());

-- 4) Kayit tetikleyicisi (tetikleyici tanimi ayni kalir, sadece fonksiyon govdesi)
create or replace function public.yeni_kullanici_isle()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  yeni_isletme_id uuid;
  isletme_adi     text;
  davet           public.personel_yetkileri%rowtype;
begin
  -- PERSONEL YOLU: sahip bu e-postayi onceden personel_yetkileri'ne yazdiysa
  select * into davet
    from personel_yetkileri
   where lower(email) = lower(new.email)
     and kullanici_id is null
     and aktif
   limit 1;

  if found then
    insert into kullanicilar (id, isletme_id, rol, ad_soyad)
    values (new.id, davet.isletme_id, davet.rol, davet.ad_soyad);

    update personel_yetkileri
       set kullanici_id = new.id, updated_at = now()
     where id = davet.id;

    return new;   -- yeni isletme ve abonelik ACILMAZ
  end if;

  -- SAHIP YOLU: 174'teki tanimla birebir ayni
  isletme_adi := coalesce(new.raw_user_meta_data ->> 'isletme_adi', 'Yeni İşletme');

  insert into isletmeler (ad) values (isletme_adi)
  returning id into yeni_isletme_id;

  insert into kullanicilar (id, isletme_id, rol)
  values (new.id, yeni_isletme_id, 'sahip');

  insert into abonelikler (isletme_id, plan_id, durum)
  values (yeni_isletme_id, null, 'odeme_bekleniyor');

  return new;
end;
$function$;

commit;

-- Dogrulama (tek sorgu, 1 satir): tablo var, RLS acik, 5 politika, rol kisiti yeni,
-- tetikleyici fonksiyonu personel_yetkileri'ni iceriyor.
select
  (select relrowsecurity from pg_class where oid = 'public.personel_yetkileri'::regclass) as rls_acik,
  (select count(*) from pg_policies where schemaname = 'public'
      and tablename = 'personel_yetkileri')                                             as politika_sayisi,
  (select pg_get_constraintdef(oid) from pg_constraint
    where conname = 'kullanicilar_rol_check')                                           as rol_kisiti,
  (select pg_get_functiondef('public.yeni_kullanici_isle()'::regprocedure)
      like '%personel_yetkileri%')                                                      as tetikleyici_guncel,
  (select count(*) from public.kullanicilar where rol = 'sahip')                        as sahip_sayisi_degismedi;
