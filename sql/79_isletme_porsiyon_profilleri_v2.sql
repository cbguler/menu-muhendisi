-- 79_isletme_porsiyon_profilleri_v2.sql
--
-- YENIDEN CALISTIRILABILIR (idempotent) versiyon -- ilk calistirmada
-- CREATE TABLE satirinda "IF NOT EXISTS" olmadigi icin, tablo zaten
-- olusmus haldeyken ikinci calistirma "relation already exists"
-- hatasi verdi. Bu versiyon HER satirda "zaten yapilmissa atla"
-- mantigi kullaniyor -- ne kadari zaten basariyla calismis olursa
-- olsun, bu dosyayi guvenle (tekrar tekrar) calistirabilirsin.

create table if not exists isletme_porsiyon_profilleri (
    id               uuid primary key default gen_random_uuid(),
    isletme_id       uuid not null references isletmeler(id) on delete cascade,
    ad               text not null,
    porsiyon_sayisi  integer not null check (porsiyon_sayisi > 0),
    sira             smallint not null default 0,
    created_at       timestamptz not null default now()
);

create index if not exists isletme_porsiyon_profilleri_isletme_idx
    on isletme_porsiyon_profilleri (isletme_id);

alter table isletme_porsiyon_profilleri enable row level security;

-- CREATE POLICY "IF NOT EXISTS" desteklemiyor -- once guvenle kaldirip
-- (yoksa hata vermez) yeniden olusturuyoruz.
drop policy if exists "kendi porsiyon profillerini yonet" on isletme_porsiyon_profilleri;
create policy "kendi porsiyon profillerini yonet" on isletme_porsiyon_profilleri
    for all using (isletme_id = auth_isletme_id());

-- Geriye donuk uyumluluk: HER mevcut isletme icin bir "Standart" profil
-- (10 porsiyon). "where not exists" zaten guvenli/tekrar-calistirilabilir.
insert into isletme_porsiyon_profilleri (isletme_id, ad, porsiyon_sayisi, sira)
select id, 'Standart', 10, 0
from isletmeler
where not exists (
    select 1 from isletme_porsiyon_profilleri p where p.isletme_id = isletmeler.id
);

-- 78 numarali migration'da eklenen, artik gereksiz kalan sutunu
-- guvenli sekilde kaldir ("if exists" -- zaten kaldirilmissa hata vermez).
alter table isletmeler drop column if exists standart_uretim_porsiyonu;

-- DOGRULAMA
select isletmeler.kisaltma, p.ad, p.porsiyon_sayisi
from isletme_porsiyon_profilleri p
join isletmeler on isletmeler.id = p.isletme_id
order by isletmeler.kisaltma, p.sira;
