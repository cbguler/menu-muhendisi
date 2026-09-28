-- 182_sube_ve_personel_yetki_modeli.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Isletme / Sube / Personel yetki modeli.
--
-- Bahri'nin istegi ve kararlari:
--  * Isletmeyi olusturan kisi PATRONDUR; ana isletmede ve butun subelerinde her seyi yapar.
--  * Subeler AYRI AYRI BIRER ISLETMEDIR (isletmeler satiri, ust_isletme_id = ana isletme) ve
--    ana isletme icinde ayni yetki kurallarina tabidir. Sube sayisini planin sube_limiti belirler
--    (ana isletme dahil; NULL = sinirsiz).
--  * Ana isletmenin ozel tarifleri butun subelerde ORTAK; sube kendi tarifini de ekleyebilir.
--  * Personeli SADECE patron ekler (e-posta + sifreyi patron belirler; hesap service role ile acilir).
--  * Yetkiler SUBE BASINA verilir (personel_sube_yetkileri.yetkiler, anahtar -> seviye).
--
-- CALISMA ILKESI: Mevcut butun politikalar "isletme_id = auth_isletme_id()" kalibinda.
-- auth_isletme_id() artik "kullanicinin su an CALISTIGI isletme" (aktif sube) doner:
-- patron icin varsayilan ana isletme (bugunku davranisin aynisi), personel icin yetkili
-- oldugu bir sube. Sube degistirme aktif_sube_sec() ile yapilir ve erisim kontrol edilir.
-- Personelin yetkileri, mevcut politikalara EK olarak RESTRICTIVE politikalarla zorlanir;
-- bu politikalar personel olmayan herkes icin (patronlar) her zaman "true" doner.
--
-- GUVENLIK KILIDI: degisiklikten once ve sonra her patronun kimligiyle ayni sayimlar
-- yapilir; tek fark bile varsa hata verilir ve HICBIR degisiklik kalmaz.

begin;

-- 0) On kontroller: eski tablolar bos olmali
do $$
begin
  if (select count(*) from public.personel_yetkileri) > 0 then
    raise exception 'personel_yetkileri bos degil; yeniden kurulamaz';
  end if;
  if (select count(*) from public.subeler) > 0 then
    raise exception 'subeler bos degil; kaldirilamaz';
  end if;
end $$;

-- 0b) ONCE sayimlari: her patronun kimligiyle
create temp table _kontrol (kullanici_id uuid, email text, once jsonb, sonra jsonb) on commit drop;
insert into _kontrol (kullanici_id, email)
select k.id, u.email from public.kullanicilar k join auth.users u on u.id = k.id where k.rol = 'sahip';


do $$
declare s record; v jsonb;
  q constant text := 'select jsonb_build_object(
    ''aktif_isletme'',        public.auth_isletme_id(),
    ''receteler'',            (select count(*) from public.receteler),
    ''recete_malzemeleri'',   (select count(*) from public.recete_malzemeleri),
    ''recete_asamalari'',     (select count(*) from public.recete_asamalari),
    ''fiyatlar'',             (select count(*) from public.malzeme_fiyat_gecmisi),
    ''maliyet_ayarlari'',     (select count(*) from public.isletme_maliyet_ayarlari),
    ''porsiyon_profilleri'',  (select count(*) from public.isletme_porsiyon_profilleri),
    ''menu_takvimi'',         (select count(*) from public.menu_takvimi),
    ''kayitli_menuler'',      (select count(*) from public.kayitli_aylik_menuler),
    ''menu_ogeleri'',         (select count(*) from public.menu_ogeleri),
    ''malzemeler'',           (select count(*) from public.malzemeler),
    ''abonelikler'',          (select count(*) from public.abonelikler),
    ''kullanicilar'',         (select count(*) from public.kullanicilar),
    ''isletmeler'',           (select count(*) from public.isletmeler),
    ''uretim_maliyeti'',      (select coalesce(round(sum(toplam_gercek_maliyet_eur), 4), 0)
                               from public.recete_uretim_maliyeti)
  )';
begin
  for s in select * from _kontrol loop
    perform set_config('request.jwt.claims',
      jsonb_build_object('sub', s.kullanici_id, 'email', s.email, 'role', 'authenticated')::text, true);
    execute 'set local role authenticated';
    execute q into v;
    execute 'reset role';
    update _kontrol set once = v where kullanici_id = s.kullanici_id;
  end loop;
end $$;

-- 1) Sube baglantisi ve rol
alter table public.isletmeler
  add column ust_isletme_id uuid references public.isletmeler(id) on delete cascade;
create index isletmeler_ust_isletme_idx on public.isletmeler (ust_isletme_id);

alter table public.kullanicilar drop constraint kullanicilar_rol_check;
alter table public.kullanicilar add constraint kullanicilar_rol_check
  check (rol = any (array['sahip','yonetici','mutfak','salt_okunur','muhasebe','personel']));

drop table public.subeler;            -- eski semadan, bos, kullanilmiyor
drop table public.personel_yetkileri; -- 175'teki tek-isletmeli taslak, bos

-- 2) Yeni tablolar
create table public.personel (
  id              uuid primary key default gen_random_uuid(),
  ana_isletme_id  uuid not null references public.isletmeler(id) on delete cascade,
  email           text not null,
  ad_soyad        text,
  kullanici_id    uuid unique references auth.users(id) on delete set null,
  aktif           boolean not null default true,
  created_at      timestamptz not null default now()
);
create unique index personel_email_uq on public.personel (lower(email));
create index personel_ana_isletme_idx on public.personel (ana_isletme_id);

create table public.personel_sube_yetkileri (
  personel_id  uuid not null references public.personel(id) on delete cascade,
  isletme_id   uuid not null references public.isletmeler(id) on delete cascade,
  rol_sablonu  text not null default 'ozel'
               check (rol_sablonu in ('asci','yonetici','muhasebe','ozel')),
  yetkiler     jsonb not null default '{}'::jsonb,
  created_at   timestamptz not null default now(),
  primary key (personel_id, isletme_id)
);
create index personel_sube_yetkileri_isletme_idx on public.personel_sube_yetkileri (isletme_id);

create table public.aktif_sube (
  kullanici_id  uuid primary key references auth.users(id) on delete cascade,
  isletme_id    uuid not null references public.isletmeler(id) on delete cascade,
  updated_at    timestamptz not null default now()
);

-- 3) Yardimci fonksiyonlar (SECURITY DEFINER: RLS'e takilmadan okur)
create or replace function public.auth_ana_isletme_id() returns uuid
language sql stable security definer set search_path to 'public' as $$
  select isletme_id from kullanicilar where id = auth.uid()
$$;

create or replace function public.auth_personel_mi() returns boolean
language sql stable security definer set search_path to 'public' as $$
  select exists (select 1 from kullanicilar where id = auth.uid() and rol = 'personel')
$$;

create or replace function public.isletme_ana_id(p_isletme uuid) returns uuid
language sql stable security definer set search_path to 'public' as $$
  select coalesce(ust_isletme_id, id) from isletmeler where id = p_isletme
$$;

create or replace function public.auth_isletmeye_erisebilir(p_isletme uuid) returns boolean
language sql stable security definer set search_path to 'public' as $$
  select
    (auth_sahip_mi() and isletme_ana_id(p_isletme) = auth_ana_isletme_id())
    or exists (select 1
                 from personel_sube_yetkileri y
                 join personel pe on pe.id = y.personel_id
                where pe.kullanici_id = auth.uid() and pe.aktif and y.isletme_id = p_isletme)
$$;

-- Aktif (calisilan) isletme. Patronda aktif_sube bos ise ana isletme -> bugunku davranis.
create or replace function public.auth_isletme_id() returns uuid
language sql stable security definer set search_path to 'public' as $$
  select coalesce(
    (select a.isletme_id from aktif_sube a
      where a.kullanici_id = auth.uid() and auth_isletmeye_erisebilir(a.isletme_id)),
    (select y.isletme_id
       from personel_sube_yetkileri y join personel pe on pe.id = y.personel_id
      where pe.kullanici_id = auth.uid() and pe.aktif
      order by y.created_at limit 1),
    (select isletme_id from kullanicilar where id = auth.uid() and rol <> 'personel')
  )
$$;

-- Aktif subedeki yetki seviyesi: 0 = yok/gizli, 1 = gor/indir, 2 = duzenle. Patron her zaman 2.
create or replace function public.auth_yetki_seviye(p_anahtar text) returns integer
language sql stable security definer set search_path to 'public' as $$
  select case
    when not auth_personel_mi() then
      case when auth_sahip_mi() then 2 else 0 end
    else coalesce((
      select max(case y.yetkiler ->> p_anahtar
                   when 'duzenle' then 2 when 'gor' then 1 when 'indir' then 1 else 0 end)
        from personel_sube_yetkileri y join personel pe on pe.id = y.personel_id
       where pe.kullanici_id = auth.uid() and pe.aktif and y.isletme_id = auth_isletme_id()), 0)
  end
$$;

-- Uygulama icin: aktif subedeki yetkiler (patron icin {"_tam": true})
create or replace function public.aktif_yetkilerim() returns jsonb
language sql stable security definer set search_path to 'public' as $$
  select case
    when not auth_personel_mi() then '{"_tam": true}'::jsonb
    else coalesce((
      select y.yetkiler || jsonb_build_object('_rol', y.rol_sablonu)
        from personel_sube_yetkileri y join personel pe on pe.id = y.personel_id
       where pe.kullanici_id = auth.uid() and pe.aktif and y.isletme_id = auth_isletme_id()), '{}'::jsonb)
  end
$$;

create or replace function public.erisilebilir_isletmeler()
returns table (id uuid, ad text, ust_isletme_id uuid)
language sql stable security definer set search_path to 'public' as $$
  select i.id, i.ad, i.ust_isletme_id
    from isletmeler i
   where auth_isletmeye_erisebilir(i.id)
   order by (i.ust_isletme_id is not null), i.ad
$$;

create or replace function public.aktif_sube_sec(p_isletme uuid) returns boolean
language plpgsql security definer set search_path to 'public' as $$
begin
  if not auth_isletmeye_erisebilir(p_isletme) then
    return false;
  end if;
  insert into aktif_sube (kullanici_id, isletme_id, updated_at)
  values (auth.uid(), p_isletme, now())
  on conflict (kullanici_id) do update set isletme_id = excluded.isletme_id, updated_at = now();
  return true;
end $$;

-- Ic yardimci: bir isletmenin satirlarini yeni subeye kopyalar (kolonlari dinamik okur)
create or replace function public._isletme_verisi_kopyala(p_tablo text, p_kaynak uuid, p_hedef uuid)
returns void language plpgsql security definer set search_path to 'public' as $$
declare kolonlar text; var_mi boolean;
begin
  execute format('select exists (select 1 from public.%I where isletme_id = $1)', p_tablo)
    into var_mi using p_hedef;
  if var_mi then return; end if;   -- hedefte zaten veri varsa (baska bir tetikleyici eklediyse) dokunma
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position) into kolonlar
    from information_schema.columns
   where table_schema = 'public' and table_name = p_tablo
     and column_name not in ('id', 'isletme_id', 'created_at', 'updated_at')
     and is_generated = 'NEVER';
  execute format('insert into public.%I (isletme_id, %s) select $1, %s from public.%I where isletme_id = $2',
                 p_tablo, kolonlar, kolonlar, p_tablo) using p_hedef, p_kaynak;
end $$;
revoke execute on function public._isletme_verisi_kopyala(text, uuid, uuid) from public, anon, authenticated;

-- Sube acma: sadece patron, plan limiti kontrollu; ana isletmenin fiyatlari, maliyet
-- ayarlari ve porsiyon profilleri yeni subeye kopyalanir (sube kendi degerlerini sonra degistirir).
create or replace function public.sube_olustur(p_ad text, p_adres text default null) returns uuid
language plpgsql security definer set search_path to 'public' as $$
declare ana uuid; limit_ int; mevcut int; yeni uuid;
begin
  if not auth_sahip_mi() then
    raise exception 'Şube açma yetkisi sadece işletme sahibine aittir.';
  end if;
  if coalesce(trim(p_ad), '') = '' then
    raise exception 'Şube adı boş olamaz.';
  end if;
  ana := auth_ana_isletme_id();
  select sube_limiti into limit_ from isletme_aktif_abonelik where isletme_id = ana;
  select count(*) into mevcut from isletmeler where coalesce(ust_isletme_id, id) = ana;
  if limit_ is not null and mevcut >= limit_ then
    raise exception 'Planının şube limiti (%) doldu.', limit_;
  end if;
  insert into isletmeler (ad, adres, ust_isletme_id) values (trim(p_ad), p_adres, ana)
  returning id into yeni;
  perform _isletme_verisi_kopyala('malzeme_fiyat_gecmisi', ana, yeni);
  perform _isletme_verisi_kopyala('isletme_maliyet_ayarlari', ana, yeni);
  perform _isletme_verisi_kopyala('isletme_porsiyon_profilleri', ana, yeni);
  return yeni;
end $$;

-- 4) Kayit tetikleyicisi: bekleyen personel kaydi varsa patronun isletmesine baglar
create or replace function public.yeni_kullanici_isle()
returns trigger language plpgsql security definer set search_path to 'public' as $function$
declare
  yeni_isletme_id uuid;
  isletme_adi     text;
  p               public.personel%rowtype;
begin
  select * into p from personel
   where lower(email) = lower(new.email) and kullanici_id is null and aktif
   limit 1;
  if found then
    insert into kullanicilar (id, isletme_id, rol, ad_soyad)
    values (new.id, p.ana_isletme_id, 'personel', p.ad_soyad);
    update personel set kullanici_id = new.id where id = p.id;
    return new;   -- yeni isletme ve abonelik ACILMAZ
  end if;

  -- SAHIP YOLU: 174/175'teki tanimla birebir ayni
  isletme_adi := coalesce(new.raw_user_meta_data ->> 'isletme_adi', 'Yeni İşletme');
  insert into isletmeler (ad) values (isletme_adi) returning id into yeni_isletme_id;
  insert into kullanicilar (id, isletme_id, rol) values (new.id, yeni_isletme_id, 'sahip');
  insert into abonelikler (isletme_id, plan_id, durum) values (yeni_isletme_id, null, 'odeme_bekleniyor');
  return new;
end;
$function$;

-- 5) Yeni tablolarin RLS'i
alter table public.personel enable row level security;
alter table public.personel_sube_yetkileri enable row level security;
alter table public.aktif_sube enable row level security;

create policy "patron personelini yonetir" on public.personel for all
  using (ana_isletme_id = auth_ana_isletme_id() and auth_sahip_mi())
  with check (ana_isletme_id = auth_ana_isletme_id() and auth_sahip_mi());
create policy "personel kendi kaydini gorur" on public.personel for select
  using (kullanici_id = auth.uid());
create policy "admin personeli gorur" on public.personel for select using (auth_admin_mi());

create policy "patron sube yetkilerini yonetir" on public.personel_sube_yetkileri for all
  using (auth_sahip_mi() and isletme_ana_id(isletme_id) = auth_ana_isletme_id()
         and exists (select 1 from public.personel pe where pe.id = personel_id
                      and pe.ana_isletme_id = auth_ana_isletme_id()))
  with check (auth_sahip_mi() and isletme_ana_id(isletme_id) = auth_ana_isletme_id()
         and exists (select 1 from public.personel pe where pe.id = personel_id
                      and pe.ana_isletme_id = auth_ana_isletme_id()));
create policy "personel kendi yetkilerini gorur" on public.personel_sube_yetkileri for select
  using (exists (select 1 from public.personel pe where pe.id = personel_id and pe.kullanici_id = auth.uid()));
create policy "admin sube yetkilerini gorur" on public.personel_sube_yetkileri for select
  using (auth_admin_mi());

create policy "kendi aktif subesini gorur" on public.aktif_sube for select
  using (kullanici_id = auth.uid());

-- 6) Ana isletmeye bagli (subeden bagimsiz) politikalar
alter policy "kendi abonelini gor" on public.abonelikler using (isletme_id = auth_ana_isletme_id());
alter policy "kendi isletme kullanicilarini gor" on public.kullanicilar using (isletme_id = auth_ana_isletme_id());
alter policy "kendi odeme gecmisini gor" on public.odeme_gecmisi using (isletme_id = auth_ana_isletme_id());

-- Isletme adlari: erisebildigi isletmeleri gorur; isletme bilgisini sadece patron/admin degistirir
create policy "erisebildigi isletmeleri gor" on public.isletmeler for select
  using (auth_isletmeye_erisebilir(id));
create policy "isletme bilgisini sadece patron degistirir" on public.isletmeler
  as restrictive for update
  using (not auth_personel_mi()) with check (not auth_personel_mi());

-- Ana isletmenin tarifleri subelerde ortak (ve maliyetleri icin fiyat/ayar okuma)
create policy "ana isletme tariflerini oku" on public.receteler for select
  using (isletme_id = isletme_ana_id(auth_isletme_id()));
create policy "ana isletme tarif malzemelerini oku" on public.recete_malzemeleri for select
  using (exists (select 1 from public.receteler r where r.id = recete_id
                  and r.isletme_id = isletme_ana_id(auth_isletme_id())));
create policy "ana isletme tarif asamalarini oku" on public.recete_asamalari for select
  using (exists (select 1 from public.receteler r where r.id = recete_id
                  and r.isletme_id = isletme_ana_id(auth_isletme_id())));
create policy "ana isletme fiyatlarini oku" on public.malzeme_fiyat_gecmisi for select
  using (isletme_id = isletme_ana_id(auth_isletme_id()));
create policy "ana isletme maliyet ayarini oku" on public.isletme_maliyet_ayarlari for select
  using (isletme_id = isletme_ana_id(auth_isletme_id()));

-- 7) Personel yetkileri: RESTRICTIVE politikalar (personel olmayanlar icin her zaman true)
do $$
declare
  t record;
  on_ek constant text := 'case when not (select public.auth_personel_mi()) then true else (';
  son_ek constant text := ') end';
begin
  for t in
    select * from (values
      -- tablo,                      okuma kosulu,                                                          yazma kosulu
      ('receteler',
         '(isletme_id is null and (select public.auth_yetki_seviye(''uygulama_tarifleri'')) >= 1) or (isletme_id is not null and (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 1)',
         '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2 or (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 2'),
      ('recete_malzemeleri',
         'exists (select 1 from public.receteler r where r.id = recete_id)',
         '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2 or (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 2'),
      ('recete_asamalari',
         'exists (select 1 from public.receteler r where r.id = recete_id)',
         '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2 or (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 2'),
      ('malzeme_fiyat_gecmisi',
         '(select public.auth_yetki_seviye(''maliyetler'')) >= 1',
         '(select public.auth_yetki_seviye(''fiyat_guncelleme'')) >= 2'),
      ('isletme_maliyet_ayarlari',
         '(select public.auth_yetki_seviye(''maliyetler'')) >= 1 or (select public.auth_yetki_seviye(''maliyet_ayarlari'')) >= 1',
         '(select public.auth_yetki_seviye(''maliyet_ayarlari'')) >= 2'),
      ('isletme_porsiyon_profilleri',
         null,
         '(select public.auth_yetki_seviye(''porsiyon_profilleri'')) >= 2'),
      ('menu_takvimi',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 1',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 2'),
      ('menu_takvimi_ogeleri',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 1',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 2'),
      ('kayitli_aylik_menuler',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 1',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 2'),
      ('kisisel_beslenme_profilleri',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 1',
         '(select public.auth_yetki_seviye(''aylik_menu'')) >= 2'),
      ('menu_ogeleri',
         '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 1',
         '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2'),
      ('menu_analiz',
         '(select public.auth_yetki_seviye(''maliyetler'')) >= 1',
         'false'),
      ('satislar',
         '(select public.auth_yetki_seviye(''maliyetler'')) >= 1',
         'false'),
      ('malzemeler',
         null,
         '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2'),
      ('odeme_gecmisi',
         'false',
         'false')
    ) as v(tablo, okuma, yazma)
  loop
    if t.okuma is not null then
      execute format('create policy "yetki okuma" on public.%I as restrictive for select using (%s%s%s)',
                     t.tablo, on_ek, t.okuma, son_ek);
    end if;
    if t.yazma is not null then
      execute format('create policy "yetki ekleme" on public.%I as restrictive for insert with check (%s%s%s)',
                     t.tablo, on_ek, t.yazma, son_ek);
      execute format('create policy "yetki guncelleme" on public.%I as restrictive for update using (%s%s%s) with check (%s%s%s)',
                     t.tablo, on_ek, t.yazma, son_ek, on_ek, t.yazma, son_ek);
      execute format('create policy "yetki silme" on public.%I as restrictive for delete using (%s%s%s)',
                     t.tablo, on_ek, t.yazma, son_ek);
    end if;
  end loop;

  -- asama_malzemeleri: RLS aciksa ana isletme okumasi + yazma yetkisi
  if (select relrowsecurity from pg_class where oid = 'public.asama_malzemeleri'::regclass) then
    execute 'create policy "ana isletme asama malzemelerini oku" on public.asama_malzemeleri for select using (
               exists (select 1 from public.recete_asamalari a join public.receteler r on r.id = a.recete_id
                        where a.id = asama_id and r.isletme_id = public.isletme_ana_id(public.auth_isletme_id())))';
    execute format('create policy "yetki ekleme" on public.asama_malzemeleri as restrictive for insert with check (%s%s%s)',
      on_ek, '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2 or (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 2', son_ek);
    execute format('create policy "yetki guncelleme" on public.asama_malzemeleri as restrictive for update using (%s%s%s)',
      on_ek, '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2 or (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 2', son_ek);
    execute format('create policy "yetki silme" on public.asama_malzemeleri as restrictive for delete using (%s%s%s)',
      on_ek, '(select public.auth_yetki_seviye(''recete_uretimi'')) >= 2 or (select public.auth_yetki_seviye(''ozel_tarifler'')) >= 2', son_ek);
  end if;
end $$;

-- 8) SONRA sayimlari ve karsilastirma
do $$
declare s record; v jsonb;
  q constant text := 'select jsonb_build_object(
    ''aktif_isletme'',        public.auth_isletme_id(),
    ''receteler'',            (select count(*) from public.receteler),
    ''recete_malzemeleri'',   (select count(*) from public.recete_malzemeleri),
    ''recete_asamalari'',     (select count(*) from public.recete_asamalari),
    ''fiyatlar'',             (select count(*) from public.malzeme_fiyat_gecmisi),
    ''maliyet_ayarlari'',     (select count(*) from public.isletme_maliyet_ayarlari),
    ''porsiyon_profilleri'',  (select count(*) from public.isletme_porsiyon_profilleri),
    ''menu_takvimi'',         (select count(*) from public.menu_takvimi),
    ''kayitli_menuler'',      (select count(*) from public.kayitli_aylik_menuler),
    ''menu_ogeleri'',         (select count(*) from public.menu_ogeleri),
    ''malzemeler'',           (select count(*) from public.malzemeler),
    ''abonelikler'',          (select count(*) from public.abonelikler),
    ''kullanicilar'',         (select count(*) from public.kullanicilar),
    ''isletmeler'',           (select count(*) from public.isletmeler),
    ''uretim_maliyeti'',      (select coalesce(round(sum(toplam_gercek_maliyet_eur), 4), 0)
                               from public.recete_uretim_maliyeti)
  )';
begin
  for s in select * from _kontrol loop
    perform set_config('request.jwt.claims',
      jsonb_build_object('sub', s.kullanici_id, 'email', s.email, 'role', 'authenticated')::text, true);
    execute 'set local role authenticated';
    execute q into v;
    execute 'reset role';
    if v is distinct from s.once then
      raise exception 'Patron % icin sonuc degisti. Once: % Sonra: %', s.email, s.once, v;
    end if;
    update _kontrol set sonra = v where kullanici_id = s.kullanici_id;
  end loop;
end $$;

create temp table _sonuc as
select count(*) as karsilastirilan_patron_sayisi,
       bool_and(once = sonra) as hepsi_ayni,
       jsonb_agg(once) as sayimlar
from _kontrol;

commit;

select * from _sonuc;
