-- 44_isletmeler_update_politikasi.sql
--
-- isletmeler tablosunda SADECE "kendi isletmeni gor" (SELECT) politikasi
-- vardi -- UPDATE icin hic politika yoktu, bu yuzden Abonelik sayfasindaki
-- isletme adi degisikligi RLS tarafindan SESSIZCE reddediliyordu (hata
-- firlatmiyor, sadece 0 satir etkileniyordu). Eksik UPDATE politikasi
-- ekleniyor -- SELECT politikasiyla ayni mantik: kullanici sadece KENDI
-- isletmesini guncelleyebilir.

create policy "kendi isletmeni guncelle"
on isletmeler
for update
to authenticated
using (
  id in (select isletme_id from kullanicilar where id = auth.uid())
)
with check (
  id in (select isletme_id from kullanicilar where id = auth.uid())
);

-- DOGRULAMA
select policyname, cmd, roles
from pg_policies
where tablename = 'isletmeler';
