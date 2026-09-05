-- 81_kayitli_aylik_menuler.sql
--
-- Bahri'nin talebi (4 Eylul 2026): uretilen aylik menu, kullanici
-- BEGENDIGINDE (tum gunler hedefteyken) kaydedilebilsin -- su ana kadar
-- uretilen menu SADECE st.session_state'te (tarayici oturumu boyunca,
-- sayfa yenilenince kaybolan) tutuluyordu, veritabanina HIC yazilmiyordu.
--
-- Her kayit, bir (isletme, porsiyon profili, yil, ay) UCLUSUNE bagli --
-- Bahri'nin kararı: AYNI ay/profil icin tekrar kaydedilirse ONCEKININ
-- UZERINE YAZILSIN (birden fazla versiyon SAKLANMAZ) -- bu yuzden bu
-- uclu UNIQUE.

create table kayitli_aylik_menuler (
    id                  uuid primary key default gen_random_uuid(),
    isletme_id          uuid not null references isletmeler(id) on delete cascade,
    porsiyon_profil_id  uuid not null references isletme_porsiyon_profilleri(id) on delete cascade,
    yil                 integer not null,
    ay                  text not null,
    menu_verisi         jsonb not null,  -- {"haftalar": [...]} -- yillik_menu_aylik ile ayni sekil
    guncelleme_zamani   timestamptz not null default now(),
    unique (isletme_id, porsiyon_profil_id, yil, ay)
);
create index kayitli_aylik_menuler_isletme_profil_idx
    on kayitli_aylik_menuler (isletme_id, porsiyon_profil_id);

alter table kayitli_aylik_menuler enable row level security;
drop policy if exists "kendi kayitli menulerini yonet" on kayitli_aylik_menuler;
create policy "kendi kayitli menulerini yonet" on kayitli_aylik_menuler
    for all using (isletme_id = auth_isletme_id());

-- DOGRULAMA
select column_name, data_type
from information_schema.columns
where table_name = 'kayitli_aylik_menuler'
order by ordinal_position;
