-- =====================================================================
-- ABONELIK VE ODEME ALTYAPISI
-- Saglayici-bagimsiz tasarim: iyzico, LemonSqueezy/Paddle veya ileride
-- Stripe -- hepsi ayni tablolara sigar, sadece odeme_saglayici alani degisir.
--
-- Onkosul: menu_muhendisligi_schema.sql'in daha once calistirilmis olmasi
-- (isletmeler, auth_isletme_id() fonksiyonu burada kullanilir).
-- =====================================================================

create table abonelik_planlari (
  id                uuid primary key default gen_random_uuid(),
  kod               text not null unique,        -- 'deneme','temel','pro','kurumsal'
  ad                text not null,
  aylik_fiyat_eur   numeric,                      -- kurumsal'da NULL = "bize ulasin"
  yillik_fiyat_eur  numeric,
  sube_limiti       integer,                      -- NULL = sinirsiz
  recete_limiti     integer,                      -- NULL = sinirsiz
  ozellikler        jsonb not null default '{}',   -- {"boston_matrisi": true, ...}
  aktif_mi          boolean not null default true,
  created_at        timestamptz not null default now()
);

create table abonelikler (
  id                    uuid primary key default gen_random_uuid(),
  isletme_id            uuid not null references isletmeler(id) on delete cascade,
  plan_id               uuid not null references abonelik_planlari(id),
  durum                 text not null default 'deneme'
                          check (durum in ('deneme','aktif','odeme_gecikti','iptal_edildi','suresi_doldu')),
  odeme_saglayici       text check (odeme_saglayici in ('paytr','iyzico','lemonsqueezy','paddle','stripe','manuel')),
  saglayici_musteri_id  text,   -- saglayicidaki musteri kimligi
  saglayici_abonelik_id text,   -- saglayicidaki abonelik/subscription kimligi
  donem_baslangic       date not null default current_date,
  donem_bitis           date,
  deneme_bitis_tarihi   date,
  iptal_talebi_tarihi   date,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);
create index abonelikler_isletme_idx on abonelikler (isletme_id);

create table odeme_gecmisi (
  id                  uuid primary key default gen_random_uuid(),
  isletme_id          uuid not null references isletmeler(id) on delete cascade,
  abonelik_id         uuid references abonelikler(id) on delete set null,
  tutar               numeric not null,
  para_birimi         text not null default 'EUR',
  durum               text not null check (durum in ('basarili','basarisiz','iade')),
  saglayici_islem_id  text,     -- iyzico paymentId / lemonsqueezy order id vb.
  fatura_url          text,     -- saglayicinin urettigi fatura/makbuz linki
  tarih               timestamptz not null default now()
);
create index odeme_gecmisi_isletme_idx on odeme_gecmisi (isletme_id, tarih desc);

-- Webhook olaylarinin ham kaydi -- idempotent isleme icin sart.
-- Ayni webhook Stripe/iyzico/LemonSqueezy tarafindan birden fazla kez
-- gonderilebilir; saglayici_olay_id benzersizligi ayni olayi iki kez
-- islemeyi engeller.
create table webhook_olaylari (
  id                uuid primary key default gen_random_uuid(),
  saglayici         text not null,
  olay_tipi         text not null,
  saglayici_olay_id text unique,
  payload           jsonb not null,
  islendi_mi        boolean not null default false,
  hata_mesaji       text,
  created_at        timestamptz not null default now(),
  islendi_tarih     timestamptz
);

-- =====================================================================
-- RLS
-- Kural: abonelikler/odeme_gecmisi SADECE okunur (kullanicilar dogrudan
-- yazamaz) -- yazma islemi yalnizca Edge Function'in service_role
-- anahtariyla yapilir (RLS'i bypass eder). webhook_olaylari icin hic
-- policy tanimlanmadi -- varsayilan olarak kilitli, sadece service_role
-- erisir.
-- =====================================================================

alter table abonelik_planlari enable row level security;
alter table abonelikler enable row level security;
alter table odeme_gecmisi enable row level security;
alter table webhook_olaylari enable row level security;

create policy "planlar herkese acik" on abonelik_planlari
  for select using (true);

create policy "kendi abonelini gor" on abonelikler
  for select using (isletme_id = auth_isletme_id());

create policy "kendi odeme gecmisini gor" on odeme_gecmisi
  for select using (isletme_id = auth_isletme_id());

-- =====================================================================
-- Streamlit'in tek sorguda okuyacagi ozet view: aktif abonelik + plan
-- limitleri. Uygulama her sayfa yuklemesinde bunu kontrol eder.
-- =====================================================================

create view isletme_aktif_abonelik as
select distinct on (a.isletme_id)
  a.isletme_id,
  a.durum,
  p.kod as plan_kodu,
  p.ad as plan_adi,
  p.sube_limiti,
  p.recete_limiti,
  p.ozellikler,
  a.donem_bitis,
  a.deneme_bitis_tarihi
from abonelikler a
join abonelik_planlari p on p.id = a.plan_id
order by a.isletme_id, a.created_at desc;

-- =====================================================================
-- Taslak plan seed verisi -- fiyatlar ve limitler nihai degil, ilk
-- konumlandirma icin baslangic noktasidir.
-- =====================================================================

insert into abonelik_planlari (kod, ad, aylik_fiyat_eur, yillik_fiyat_eur, sube_limiti, recete_limiti, ozellikler) values
 ('deneme',   '14 Gunluk Deneme', 0,    0,    1,    20,   '{"boston_matrisi": false, "satis_analitik": false}'),
 ('temel',    'Temel',            19,   190,  1,    100,  '{"boston_matrisi": true,  "satis_analitik": false}'),
 ('pro',      'Pro',              39,   390,  3,    null, '{"boston_matrisi": true,  "satis_analitik": true}'),
 ('kurumsal', 'Kurumsal',         null, null, null, null, '{"boston_matrisi": true,  "satis_analitik": true, "ozel_destek": true}');
