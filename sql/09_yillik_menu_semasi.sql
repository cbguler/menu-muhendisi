-- 09_yillik_menu_semasi.sql
--
-- Yillik menu uretim motoru icin sema genislemesi. Mevcut receteler/
-- malzemeler tablolarini temel alir, ustune anayasa kurallarini (madde
-- 8, 11, 13) uygulayabilecek siniflandirma + kural tablolari ekler.

-- =====================================================================
-- 1) RECETE SINIFLANDIRMASI (Anayasa madde 8)
-- =====================================================================

alter table receteler add column if not exists yemek_grubu smallint
  check (yemek_grubu in (1, 2, 3));
comment on column receteler.yemek_grubu is
  'Madde 8: 1=et/tavuk/balik/etli sebze/kuru baklagil/yumurta, '
  '2=corba/pilav/zeytinyagli/makarna/borek, '
  '3=salata/tatli/komposto/yogurt/cacik/tursu';

alter table receteler add column if not exists ozel_etiketler text[] default '{}';
comment on column receteler.ozel_etiketler is
  'Uyumsuzluk (madde 11) ve tamamlayici eslestirme (madde 13) kurallarinda '
  'kullanilan serbest etiketler: dolma, zeytinyagli, etli_sebze, izgara, '
  'kuru_baklagil, balik, pilav_makarna_borek, tatli, salata, tursu, yogurt, '
  'sporcu_uygun, vb.';

-- =====================================================================
-- 2) UYUMSUZLUK KURALLARI (Madde 11)
-- =====================================================================

create table uyumsuzluk_kurallari (
  id             smallint primary key generated always as identity,
  etiket_a       text not null,
  etiket_b       text not null,
  aciklama       text,
  istisna_etiket text  -- bu etiket receteде varsa kural gecersiz sayilir (ornek: 'sporcu_uygun')
);

insert into uyumsuzluk_kurallari (etiket_a, etiket_b, aciklama, istisna_etiket) values
 ('zeytinyagli', 'etli_sebze', 'Zeytinyağlı sebze yanına etli sebze/dolma verilmez', null),
 ('pilav_makarna_borek', 'tatli', 'Pilav/makarna/börek yanına tatlı verilmez', 'sporcu_uygun'),
 ('zeytinyagli', 'salata', 'Zeytinyağlı yemek yanına salata verilmez', null),
 ('etli_zeytinyagli_dolma', 'pilav_makarna_borek', 'Etli/zeytinyağlı dolma yanına pilav/makarna verilmez', null);

-- =====================================================================
-- 3) TAMAMLAYICI EŞLEŞTİRME (Madde 13)
-- =====================================================================

create table tamamlayici_eslestirme (
  id                   smallint primary key generated always as identity,
  ana_etiket           text not null,
  onerilen_tamamlayici text not null,
  oncelik              smallint not null default 1
);

insert into tamamlayici_eslestirme (ana_etiket, onerilen_tamamlayici, oncelik) values
 ('dolma', 'yogurt', 1),
 ('izgara', 'salata', 1),
 ('izgara', 'tursu', 2),
 ('kuru_baklagil', 'tursu', 1),
 ('kuru_baklagil', 'salata', 2),
 ('balik', 'salata', 1);

-- =====================================================================
-- 4) KİŞİSEL BESLENME PROFİLİ (Madde 5)
-- =====================================================================

create table kisisel_beslenme_profilleri (
  id                   uuid primary key default gen_random_uuid(),
  isletme_id           uuid not null references isletmeler(id) on delete cascade,
  ad                   text not null,          -- 'Ahmet', 'Genel Aile Profili' vb.
  yas                  integer,
  cinsiyet             text check (cinsiyet in ('erkek', 'kadin')),
  gunluk_kalori_hedef  numeric,                 -- bos ise yas/cinsiyete gore otomatik hesaplanir
  protein_hedef_g      numeric,
  yag_hedef_g          numeric,
  kh_hedef_g           numeric,
  gi_ust_sinir         numeric,
  kisitli_malzemeler   uuid[] default '{}',     -- malzemeler.id referanslari (alerji/sevmeme)
  created_at           timestamptz not null default now()
);

alter table kisisel_beslenme_profilleri enable row level security;
create policy "kendi profillerini yonet" on kisisel_beslenme_profilleri
  for all using (isletme_id = auth_isletme_id());

-- =====================================================================
-- 5) YILLIK MENÜ TAKVİMİ
-- =====================================================================

create table menu_takvimi (
  id                 uuid primary key default gen_random_uuid(),
  isletme_id         uuid not null references isletmeler(id) on delete cascade,
  profil_id          uuid references kisisel_beslenme_profilleri(id) on delete set null,
  tarih              date not null,
  ogun               text not null check (ogun in ('ogle', 'aksam')),
  olusturma_tarihi   timestamptz not null default now(),
  unique (isletme_id, profil_id, tarih, ogun)
);

alter table menu_takvimi enable row level security;
create policy "kendi takvimini yonet" on menu_takvimi
  for all using (isletme_id = auth_isletme_id());

create table menu_takvimi_ogeleri (
  id               uuid primary key default gen_random_uuid(),
  menu_takvimi_id  uuid not null references menu_takvimi(id) on delete cascade,
  recete_id        uuid not null references receteler(id),
  grup             smallint not null check (grup in (1, 2, 3)),
  sira             smallint not null default 1
);

alter table menu_takvimi_ogeleri enable row level security;
create policy "kendi takvim ogesini yonet" on menu_takvimi_ogeleri
  for all using (
    menu_takvimi_id in (select id from menu_takvimi where isletme_id = auth_isletme_id())
  );
