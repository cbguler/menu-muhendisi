-- 120_alerjenler_rls_okuma_politikasi_ekle.sql
--
-- KOK NEDEN: alerjenler tablosunda RLS acikti ama HICBIR politika
-- yoktu -- PostgreSQL'in varsayilan davranisi geregi bu, GRANT'ler
-- ne olursa olsun TUM erisimi engelliyordu. malzeme_alerjen'de zaten
-- dogru sekilde var olan "alerjen iliskisi oku" politikasinin
-- ESIYLE (public/SELECT/qual=true) alerjenler tablosuna da ekleniyor
-- -- bu 14 satirlik sade bir referans/lookup tablosu (alerjen adlari),
-- herkese acik okunmasinda sakinca yok.

create policy "alerjen adlarini oku"
on public.alerjenler
for select
to public
using (true);

-- DOGRULAMA
select tablename, policyname, roles, cmd, qual
from pg_policies
where tablename = 'alerjenler';
