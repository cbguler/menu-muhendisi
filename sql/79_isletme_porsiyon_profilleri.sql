-- 79_isletme_porsiyon_profilleri.sql
--
-- Bahri'nin gerceklestirdigi onemli mimari duzeltme (3 Eylul 2026):
-- Yillik Menu pop-up'inin maliyet hesabi icin TEK bir "standart porsiyon"
-- sayisi (78 numarali migration'da isletmeler.standart_uretim_porsiyonu
-- olarak eklenmisti) YETERSIZ -- bir isletme (ör. bir yemek fabrikasi)
-- AYNI ANDA birden fazla musteriye, HER BIRINE FARKLI porsiyon sayisiyla
-- (ör. Musteri A: 100, Musteri B: 30, Musteri C: 75) uretim yapiyor
-- olabilir. Tek bir sayi bu durumu temsil edemez.
--
-- COZUM: isletme basina BIRDEN FAZLA "porsiyon profili" (ad + porsiyon
-- sayisi) tutan yeni bir tablo. Tek musterili (ör. tek bir restoran/
-- hastane) isletmeler icin otomatik olarak TEK bir "Standart" profil
-- olusturuluyor -- bu isletmeler hicbir ekstra karmasiklik gormez,
-- sanki hala tek bir sayi varmis gibi calisir. Cok musterili isletmeler
-- Abonelik sayfasindan istedigi kadar profil ekleyebilir.

create table isletme_porsiyon_profilleri (
    id               uuid primary key default gen_random_uuid(),
    isletme_id       uuid not null references isletmeler(id) on delete cascade,
    ad               text not null,
    porsiyon_sayisi  integer not null check (porsiyon_sayisi > 0),
    sira             smallint not null default 0,
    created_at       timestamptz not null default now()
);
create index isletme_porsiyon_profilleri_isletme_idx on isletme_porsiyon_profilleri (isletme_id);

alter table isletme_porsiyon_profilleri enable row level security;
create policy "kendi porsiyon profillerini yonet" on isletme_porsiyon_profilleri
    for all using (isletme_id = auth_isletme_id());

-- Geriye donuk uyumluluk: HER mevcut isletme icin bir "Standart" profil
-- (10 porsiyon -- eski sabit degerle BIREBIR ayni, davranis degismiyor).
insert into isletme_porsiyon_profilleri (isletme_id, ad, porsiyon_sayisi, sira)
select id, 'Standart', 10, 0
from isletmeler
where not exists (
    select 1 from isletme_porsiyon_profilleri p where p.isletme_id = isletmeler.id
);

-- 78 numarali migration'da eklenen, artik gereksiz kalan sutunu guvenli
-- sekilde kaldir ("if exists" -- 78 hic calistirilmamis olsa bile hata
-- vermez).
alter table isletmeler drop column if exists standart_uretim_porsiyonu;

-- DOGRULAMA
select isletmeler.kisaltma, p.ad, p.porsiyon_sayisi
from isletme_porsiyon_profilleri p
join isletmeler on isletmeler.id = p.isletme_id
order by isletmeler.kisaltma, p.sira;
