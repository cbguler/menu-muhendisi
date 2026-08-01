-- 11_coklu_mutfak_capraz_kesim.sql
--
-- 09_yillik_menu_semasi.sql'deki Turk mutfagina ozel sekilde sabitlenmis
-- (hardcoded) kisimlari, birden fazla mutfak (Fransiz, fast-food vb.)
-- destekleyecek sekilde genelleştirir. 09'un daha once calistirilip
-- calistirilmadigina bakmaksizin guvenle calisir (if not exists / if
-- exists korumalariyla).

-- =====================================================================
-- 1) MUTFAKLAR
-- =====================================================================

create table if not exists mutfaklar (
  id         uuid primary key default gen_random_uuid(),
  kod        text not null unique,      -- 'turk', 'fransiz', 'fastfood' vb.
  ad         text not null,
  aciklama   text,
  aktif_mi   boolean not null default true,
  created_at timestamptz not null default now()
);

insert into mutfaklar (kod, ad, aciklama)
values ('turk', 'Türk Mutfağı', 'Anayasa v3 kurallarına göre yapılandırılmış başlangıç mutfağı')
on conflict (kod) do nothing;

-- =====================================================================
-- 2) MUTFAĞA ÖZEL KATEGORİ ŞEMASI
-- Turk: I/II/III Grup. Fransiz olsaydi: Entree/Plat/Dessert. Fast-food
-- olsaydi: Ana Urun/Yan Urun/Icecek. Her mutfak kendi siniflandirmasini
-- tanimlar, ortak bir "grup 1/2/3" zorunlulugu yoktur.
-- =====================================================================

create table if not exists mutfak_kategorileri (
  id        uuid primary key default gen_random_uuid(),
  mutfak_id uuid not null references mutfaklar(id) on delete cascade,
  sira      smallint not null,
  kod       text not null,
  ad        text not null,
  unique (mutfak_id, sira)
);

insert into mutfak_kategorileri (mutfak_id, sira, kod, ad)
select m.id, v.sira, v.kod, v.ad
from mutfaklar m
cross join (values
  (1, 'grup1', 'I. Grup (Et/Tavuk/Balık/Etli Sebze/Kuru Baklagil/Yumurta)'),
  (2, 'grup2', 'II. Grup (Çorba/Pilav/Zeytinyağlı/Makarna/Börek)'),
  (3, 'grup3', 'III. Grup (Salata/Tatlı/Komposto/Yoğurt/Cacık/Turşu)')
) as v(sira, kod, ad)
where m.kod = 'turk'
on conflict (mutfak_id, sira) do nothing;

-- =====================================================================
-- 3) RECETELER: yemek_grubu (sabit 1/2/3) -> mutfak_kategori_id (esnek)
-- =====================================================================

alter table receteler add column if not exists mutfak_kategori_id uuid
  references mutfak_kategorileri(id);

-- 09 daha once calistirilip yemek_grubu sutunu olusmussa, mevcut
-- degerleri yeni mutfak_kategori_id'ye Turk mutfagi varsayimiyla tasi,
-- sonra eski sutunu kaldir.
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_name = 'receteler' and column_name = 'yemek_grubu'
  ) then
    update receteler r
    set mutfak_kategori_id = mk.id
    from mutfak_kategorileri mk
    join mutfaklar mu on mu.id = mk.mutfak_id
    where mu.kod = 'turk' and mk.sira = r.yemek_grubu
      and r.mutfak_kategori_id is null;

    alter table receteler drop column yemek_grubu;
  end if;
end $$;

-- =====================================================================
-- 4) UYUMSUZLUK VE TAMAMLAYICI KURALLARI: mutfağa göre kapsam
-- =====================================================================

alter table uyumsuzluk_kurallari add column if not exists mutfak_id uuid
  references mutfaklar(id);
update uyumsuzluk_kurallari set mutfak_id = (select id from mutfaklar where kod = 'turk')
where mutfak_id is null;
alter table uyumsuzluk_kurallari alter column mutfak_id set not null;

alter table tamamlayici_eslestirme add column if not exists mutfak_id uuid
  references mutfaklar(id);
update tamamlayici_eslestirme set mutfak_id = (select id from mutfaklar where kod = 'turk')
where mutfak_id is null;
alter table tamamlayici_eslestirme alter column mutfak_id set not null;

-- =====================================================================
-- 5) MENÜ TAKVİMİ: hangi mutfak için üretildiği
-- =====================================================================

alter table menu_takvimi add column if not exists mutfak_id uuid
  references mutfaklar(id);
update menu_takvimi set mutfak_id = (select id from mutfaklar where kod = 'turk')
where mutfak_id is null;

-- =====================================================================
-- 6) MALZEME-MUTFAK İLİŞKİSİ (bilgilendirici, kısıtlayıcı değil)
-- Bir malzeme birden fazla mutfakta kullanilabilir (domates hem Turk hem
-- Fransiz hem fast-food'ta var); bu tablo sadece "hangi mutfakta yaygin
-- kullanilir" bilgisini tutar -- UI filtreleme/oneri icin, zorunluluk icin degil.
-- =====================================================================

create table if not exists mutfak_malzeme (
  mutfak_id  uuid not null references mutfaklar(id) on delete cascade,
  malzeme_id uuid not null references malzemeler(id) on delete cascade,
  primary key (mutfak_id, malzeme_id)
);

-- Mevcut 337 malzemenin tamami Turk mutfagi icin toplandigindan, baslangicta
-- hepsi Turk mutfagina bagli sayilir. Yeni mutfak eklendiginde o mutfaga
-- ozel yeni malzemeler + ortak malzemelerden uygun olanlar bu tabloya eklenir.
insert into mutfak_malzeme (mutfak_id, malzeme_id)
select (select id from mutfaklar where kod = 'turk'), m.id
from malzemeler m
where m.isletme_id is null
on conflict do nothing;

-- =====================================================================
-- 7) RLS -- mutfak/kategori/malzeme-iliskisi herkese acik okunur
-- (isletmeye ozel gizli veri degil, ortak referans veri)
-- =====================================================================

alter table mutfaklar enable row level security;
create policy "mutfaklar herkese acik" on mutfaklar for select using (true);

alter table mutfak_kategorileri enable row level security;
create policy "mutfak kategorileri herkese acik" on mutfak_kategorileri for select using (true);

alter table mutfak_malzeme enable row level security;
create policy "mutfak malzeme herkese acik" on mutfak_malzeme for select using (true);
