-- =====================================================================
-- MENU MUHENDISLIGI SaaS -- VERI MODELI (Supabase / PostgreSQL)
-- Olusturulma: Temmuz 2026
--
-- Kapsam: coklu-kiraci (multi-tenant) restoran/cafe menu muhendisligi motoru.
-- kaynak_duzeltilmis_v2.xlsx dosyasindaki 337 malzeme + 14 alerjen +
-- beslenme/fiyat verisi bu semanin "malzemeler" ve "alerjenler" tablolarina
-- yuklenecek cekirdek veridir.
--
-- Kurulum sirasi: bu dosyayi tepeden asagi calistir (tablolar, sonra RLS,
-- sonra view'lar, en son seed verisi).
-- =====================================================================

create extension if not exists "pgcrypto"; -- gen_random_uuid() icin

-- =====================================================================
-- 1) COKLU KIRACI (TENANT) TEMEL TABLOLARI
-- =====================================================================

create table isletmeler (
  id            uuid primary key default gen_random_uuid(),
  ad            text not null,
  plan_tipi     text not null default 'deneme'
                  check (plan_tipi in ('deneme','temel','pro','kurumsal')),
  created_at    timestamptz not null default now()
);
comment on table isletmeler is 'Abone olan her restoran/cafe isletmesi (kiraci)';

create table subeler (
  id            uuid primary key default gen_random_uuid(),
  isletme_id    uuid not null references isletmeler(id) on delete cascade,
  ad            text not null,
  adres         text,
  created_at    timestamptz not null default now()
);
comment on table subeler is 'Coklu subeli isletmeler icin opsiyonel sube kirilimi';

-- kullanicilar: Supabase auth.users ile 1-1 esler, isletmeye ve role baglar
create table kullanicilar (
  id            uuid primary key references auth.users(id) on delete cascade,
  isletme_id    uuid not null references isletmeler(id) on delete cascade,
  rol           text not null default 'yonetici'
                  check (rol in ('sahip','yonetici','mutfak','salt_okunur')),
  ad_soyad      text,
  created_at    timestamptz not null default now()
);
comment on table kullanicilar is 'Her auth.users kaydini bir isletme + role baglar (RLS icin cekirdek tablo)';

-- =====================================================================
-- 2) MALZEME KATALOGU (kaynak_duzeltilmis_v2.xlsx buraya yuklenir)
-- =====================================================================

create table malzeme_kategorileri (
  id    smallint primary key,
  ad    text not null unique
);

create table malzemeler (
  id                uuid primary key default gen_random_uuid(),
  -- isletme_id NULL ise: global/ortak katalog malzemesi (337 malzemenin tamami)
  -- isletme_id dolu ise: sadece o isletmenin ekledigi ozel malzeme
  isletme_id        uuid references isletmeler(id) on delete cascade,
  kategori_id       smallint references malzeme_kategorileri(id),
  ad                text not null,
  yogunluk          numeric,        -- g/cm3
  ozgul_isi         numeric,        -- J/g.C
  bozulma_suresi    integer,        -- gun
  fire_orani        numeric,        -- 0-1 arasi oran
  saklama_isisi     numeric,        -- C
  kalori            numeric,        -- kcal / 100g
  protein           numeric,        -- g / 100g
  yag               numeric,        -- g / 100g
  karbonhidrat      numeric,        -- g / 100g
  glisemik_indeks   numeric,
  mevsim            text,
  isi_iletkenlik    numeric,        -- W/m.K
  yuzey_alani       numeric,        -- cm2
  not_aciklama      text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
comment on table malzemeler is 'Kaynak veri: kaynak_duzeltilmis_v2.xlsx (337 kalem, isletme_id NULL = ortak katalog)';

create unique index malzemeler_global_ad_uidx
  on malzemeler (ad) where isletme_id is null;
create unique index malzemeler_ozel_ad_uidx
  on malzemeler (isletme_id, ad) where isletme_id is not null;

create table alerjenler (
  id    smallint primary key,
  ad    text not null unique
);
comment on table alerjenler is 'AB 14 majör alerjen listesi';

create table malzeme_alerjen (
  malzeme_id  uuid not null references malzemeler(id) on delete cascade,
  alerjen_id  smallint not null references alerjenler(id) on delete cascade,
  primary key (malzeme_id, alerjen_id)
);

-- Fiyat, isletmeye ve zamana gore degisir -> ayri gecmis tablosu
create table malzeme_fiyat_gecmisi (
  id                  uuid primary key default gen_random_uuid(),
  isletme_id          uuid not null references isletmeler(id) on delete cascade,
  malzeme_id          uuid not null references malzemeler(id) on delete cascade,
  fiyat_eur           numeric not null check (fiyat_eur >= 0), -- EUR / kg veya EUR / lt
  gecerlilik_tarihi   date not null default current_date,
  tedarikci           text,
  created_at          timestamptz not null default now()
);
comment on table malzeme_fiyat_gecmisi is 'Her isletmenin kendi tedarikci fiyat gecmisi; kaynak dosyadaki fiyatlar baslangic degeri olarak tum isletmelere kopyalanir';

create index malzeme_fiyat_gecmisi_lookup_idx
  on malzeme_fiyat_gecmisi (isletme_id, malzeme_id, gecerlilik_tarihi desc);

-- =====================================================================
-- 3) RECETELER (yemekler) VE MALZEME LISTELERI
-- =====================================================================

create table receteler (
  id                uuid primary key default gen_random_uuid(),
  isletme_id        uuid not null references isletmeler(id) on delete cascade,
  ad                text not null,
  kategori          text,              -- 'corba','ana_yemek','salata','tatli','icecek', vb (serbest metin)
  porsiyon_sayisi   integer not null default 1 check (porsiyon_sayisi > 0),
  hazirlik_dakika   integer,
  aktif_mi          boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table recete_malzemeleri (
  id                uuid primary key default gen_random_uuid(),
  recete_id         uuid not null references receteler(id) on delete cascade,
  malzeme_id        uuid not null references malzemeler(id),
  miktar_gram       numeric not null check (miktar_gram > 0), -- gram ya da ml esdegeri
  pisirme_asamasi   text,   -- opsiyonel: hangi isil islem blogunda kullanildigi
  created_at        timestamptz not null default now()
);
create index recete_malzemeleri_recete_idx on recete_malzemeleri (recete_id);

-- =====================================================================
-- 4) MENU OGELERI, SATISLAR VE ANALIZ (Boston Matrisi)
-- =====================================================================

create table menu_ogeleri (
  id                uuid primary key default gen_random_uuid(),
  isletme_id        uuid not null references isletmeler(id) on delete cascade,
  recete_id         uuid not null references receteler(id),
  menu_adi          text not null,
  aciklama          text,
  satis_fiyati      numeric not null check (satis_fiyati >= 0),
  kategori          text,               -- menudeki bolum (baslangic, ana yemek, tatli...)
  aktif_mi          boolean not null default true,
  menude_sira       integer,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table satislar (
  id                uuid primary key default gen_random_uuid(),
  isletme_id        uuid not null references isletmeler(id) on delete cascade,
  menu_ogesi_id     uuid not null references menu_ogeleri(id) on delete cascade,
  tarih             date not null,
  adet              integer not null check (adet >= 0),
  birim_fiyat       numeric not null,
  created_at        timestamptz not null default now(),
  unique (menu_ogesi_id, tarih)
);
comment on table satislar is 'Gunluk satis ozeti (POS entegrasyonundan veya manuel Excel yuklemesinden doldurulur)';

create table menu_analiz (
  id                   uuid primary key default gen_random_uuid(),
  isletme_id           uuid not null references isletmeler(id) on delete cascade,
  menu_ogesi_id        uuid not null references menu_ogeleri(id) on delete cascade,
  donem_baslangic      date not null,
  donem_bitis          date not null,
  toplam_satis_adedi   integer not null,
  porsiyon_maliyeti    numeric not null,
  kar_marji            numeric not null,       -- satis_fiyati - porsiyon_maliyeti
  kar_marji_yuzde      numeric not null,
  kategori             text not null
                         check (kategori in ('yildiz','bulmaca','atli','kopek')),
  oneri_metni          text,
  hesaplama_tarihi     timestamptz not null default now()
);
comment on table menu_analiz is 'Donemsel Boston Matrisi (Yildiz/Bulmaca/Atli/Kopek) siniflandirma sonuclari, batch job ile doldurulur';

-- =====================================================================
-- 5) MALIYET/KARLILIK VIEW'LARI (canli hesap, cache gerektirmez)
-- =====================================================================

-- Her malzemenin bir isletme icin en guncel fiyati
create view malzeme_guncel_fiyat as
select distinct on (mfg.isletme_id, mfg.malzeme_id)
  mfg.isletme_id,
  mfg.malzeme_id,
  mfg.fiyat_eur,
  mfg.gecerlilik_tarihi
from malzeme_fiyat_gecmisi mfg
order by mfg.isletme_id, mfg.malzeme_id, mfg.gecerlilik_tarihi desc;

-- Recete basi porsiyon maliyeti (guncel fiyatlarla)
create view recete_guncel_maliyet as
select
  r.id as recete_id,
  r.isletme_id,
  r.ad as recete_adi,
  r.porsiyon_sayisi,
  sum(rm.miktar_gram / 1000.0 * coalesce(gf.fiyat_eur, 0)) as toplam_maliyet_eur,
  sum(rm.miktar_gram / 1000.0 * coalesce(gf.fiyat_eur, 0)) / r.porsiyon_sayisi as porsiyon_maliyeti_eur,
  sum(rm.miktar_gram * m.kalori / 100.0) / r.porsiyon_sayisi as porsiyon_kalori
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
left join malzeme_guncel_fiyat gf
  on gf.malzeme_id = rm.malzeme_id and gf.isletme_id = r.isletme_id
group by r.id, r.isletme_id, r.ad, r.porsiyon_sayisi;

-- Menu ogesi bazinda kar marji (Boston Matrisi'nin canli/on-hesabi)
create view menu_ogesi_karlilik as
select
  mo.id as menu_ogesi_id,
  mo.isletme_id,
  mo.menu_adi,
  mo.satis_fiyati,
  rgm.porsiyon_maliyeti_eur,
  (mo.satis_fiyati - rgm.porsiyon_maliyeti_eur) as kar_marji_eur,
  case when mo.satis_fiyati > 0
    then round((mo.satis_fiyati - rgm.porsiyon_maliyeti_eur) / mo.satis_fiyati * 100, 1)
    else null
  end as kar_marji_yuzde
from menu_ogeleri mo
join recete_guncel_maliyet rgm on rgm.recete_id = mo.recete_id;

-- =====================================================================
-- 6) ROW LEVEL SECURITY
-- Kural: her tablo isletme_id uzerinden, kullanicinin kendi isletmesiyle
-- eslesen satirlari gorur/degistirir. Global malzeme kataloğu (isletme_id
-- NULL) herkese acik okunur.
-- =====================================================================

alter table isletmeler enable row level security;
alter table subeler enable row level security;
alter table kullanicilar enable row level security;
alter table malzemeler enable row level security;
alter table malzeme_alerjen enable row level security;
alter table malzeme_fiyat_gecmisi enable row level security;
alter table receteler enable row level security;
alter table recete_malzemeleri enable row level security;
alter table menu_ogeleri enable row level security;
alter table satislar enable row level security;
alter table menu_analiz enable row level security;

-- Yardimci fonksiyon: giris yapan kullanicinin isletme_id'si
create or replace function auth_isletme_id()
returns uuid
language sql stable
as $$
  select isletme_id from kullanicilar where id = auth.uid()
$$;

create policy "kendi isletmeni gor" on isletmeler
  for select using (id = auth_isletme_id());

create policy "kendi subeni yonet" on subeler
  for all using (isletme_id = auth_isletme_id());

create policy "kendi isletme kullanicilarini gor" on kullanicilar
  for select using (isletme_id = auth_isletme_id());

-- malzemeler: global katalog (isletme_id IS NULL) + kendi ozel malzemen
create policy "malzeme oku" on malzemeler
  for select using (isletme_id is null or isletme_id = auth_isletme_id());
create policy "ozel malzeme yonet" on malzemeler
  for insert with check (isletme_id = auth_isletme_id());
create policy "ozel malzeme guncelle" on malzemeler
  for update using (isletme_id = auth_isletme_id());
create policy "ozel malzeme sil" on malzemeler
  for delete using (isletme_id = auth_isletme_id());

create policy "alerjen iliskisi oku" on malzeme_alerjen
  for select using (true); -- alerjen bilgisi guvenlik acisindan hassas degil, herkese acik

create policy "kendi fiyat gecmisini yonet" on malzeme_fiyat_gecmisi
  for all using (isletme_id = auth_isletme_id());

create policy "kendi receteni yonet" on receteler
  for all using (isletme_id = auth_isletme_id());

create policy "kendi recete malzemeni yonet" on recete_malzemeleri
  for all using (
    recete_id in (select id from receteler where isletme_id = auth_isletme_id())
  );

create policy "kendi menuni yonet" on menu_ogeleri
  for all using (isletme_id = auth_isletme_id());

create policy "kendi satisini yonet" on satislar
  for all using (isletme_id = auth_isletme_id());

create policy "kendi analizini gor" on menu_analiz
  for all using (isletme_id = auth_isletme_id());

-- =====================================================================
-- 7) SEED VERISI -- 17 kategori + 14 alerjen
-- (337 malzeme + fiyat + alerjen iliskileri kaynak_duzeltilmis_v2.xlsx'ten
--  ayri bir ETL scripti ile yuklenmelidir -- bkz. proje notlari)
-- =====================================================================

insert into malzeme_kategorileri (id, ad) values
 (1,'ET VE PROTEIN KAYNAKLARI'),(2,'SEBZELER'),(3,'MEYVELER'),(4,'SIVI YAGLAR'),
 (5,'BAHARATLAR VE TATLANDIRICILAR'),(6,'SOSLAR, PASTALAR VE FONDLAR'),
 (7,'SUT VE SUT URUNLERI'),(8,'UN VE TAHILLAR'),(9,'KURU BAKLAGILLER (HAM)'),
 (10,'KONSERVELER'),(11,'YUMURTA'),(12,'MAYA VE PISIRME MALZEMELERI'),
 (13,'SU VE TEMEL SIVI'),(14,'KURU MEYVELER VE KURUYEMIS'),
 (15,'CIKOLATA VE KAKAO'),(16,'ICECEK HAMMADDELERI'),(17,'TATLI VE PASTA MALZEMELERI');

insert into alerjenler (id, ad) values
 (1,'Gluten'),(2,'Kabuklu Deniz Urunu'),(3,'Yumurta'),(4,'Balik'),(5,'Yer Fistigi'),
 (6,'Soya'),(7,'Sut'),(8,'Sert Kabuklu Yemis'),(9,'Kereviz'),(10,'Hardal'),
 (11,'Susam'),(12,'Sulfit (SO2)'),(13,'Yumusakca'),(14,'Lupin');
