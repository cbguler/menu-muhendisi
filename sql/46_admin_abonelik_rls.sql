-- 46_admin_abonelik_rls.sql
--
-- BULUNAN HATA (12 Agustos 2026, Oturum 11 -- ucuncu kademe abonelik/
-- admin sisteminin uctan uca testine hazirlanirken kod incelemesiyle
-- bulundu, canli test edilmeden once): abonelikler tablosunda SADECE
-- "kendi abonelini gor" SELECT politikasi var (02_abonelik_ve_odeme_
-- altyapisi.sql) -- UPDATE politikasi hic yok. Orijinal tasarimda yazma
-- isleminin sadece service_role/Edge Function ile yapilmasi
-- planlanmisti (yorumda acikca yaziyor), ama pages/7_Admin.py normal
-- oturumla (admin'in kendi authenticated client'i) dogrudan .update()
-- cagiriyor.
--
-- SONUC: (1) Admin sayfasindaki sorgu RLS tarafindan admin'in KENDI
-- isletmesine filtreleniyor -- admin'in kendi aboneligi zaten 'aktif'
-- oldugu icin "bekleyenler" listesi HER ZAMAN BOS donuyor, gercek
-- bekleyen musteriler olsa bile. (2) "Onayla" butonu bir satira
-- erisebilse bile UPDATE politikasi olmadigi icin RLS SESSIZCE
-- reddediyor (44_isletmeler_update_politikasi.sql'de bulunanla AYNI
-- sinif hata) -- sayfa kontrol etmedigi icin yine de "onaylandi" mesaji
-- gosteriyor.
--
-- DUZELTME: admin'e (hardcoded e-posta, app.py'deki ADMIN_EPOSTA ile
-- AYNI mantik -- kullanicilar.rol gibi genel bir alan KULLANILMIYOR)
-- ozel iki yeni politika ekleniyor. Postgres'te ayni komut icin birden
-- fazla PERMISSIVE politika birbirine OR ile baglanir -- yani mevcut
-- "kendi abonelini gor" politikasina DOKUNMUYORUZ, sadece admin icin
-- EK bir SELECT + bir UPDATE politikasi ekliyoruz.
--
-- auth.jwt() ->> 'email' kullanildi (auth.users tablosunu sorgulamak
-- yerine) -- bu, Supabase'in kendi dokumantasyonunda onerilen, JWT
-- claim'inden dogrudan okuyan standart yontem, ekstra bir sorguya/
-- olasi RLS dongusune gerek birakmiyor.

create policy "admin_tum_abonelikleri_gor" on abonelikler
  for select
  using (auth.jwt() ->> 'email' = 'bahriguler@gmail.com');

create policy "admin_abonelik_onaylayabilir" on abonelikler
  for update
  using (auth.jwt() ->> 'email' = 'bahriguler@gmail.com')
  with check (auth.jwt() ->> 'email' = 'bahriguler@gmail.com');

-- EK BULUNAN HATA (ayni inceleme sirasinda): pages/7_Admin.py, abonelik
-- satirlarini isletmeler(ad) gomulu (embedded) sorgusuyla birlikte
-- cekiyor -- PostgREST, gomulu sorgularda da HEDEF tablonun (burada
-- isletmeler) kendi RLS'ini uyguluyor. isletmeler'in tek SELECT
-- politikasi "kendi isletmeni gor" (sadece kendi isletmesi) oldugu icin,
-- admin satiri gorse bile (yukaridaki duzeltmeyle) isletme adi BOS/"?"
-- gelecekti. Ayni mantikla admin'e buraya da bir SELECT bypass'i
-- ekleniyor.
create policy "admin_tum_isletmeleri_gor" on isletmeler
  for select
  using (auth.jwt() ->> 'email' = 'bahriguler@gmail.com');

-- DOGRULAMA
select policyname, cmd, roles
from pg_policies
where tablename in ('abonelikler', 'isletmeler')
order by tablename, policyname;
