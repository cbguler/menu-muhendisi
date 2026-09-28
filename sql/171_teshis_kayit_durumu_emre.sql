-- 171_teshis_kayit_durumu_emre.sql
-- SALT OKUNUR teshis sorgusu (hicbir sey degistirmez).
-- Amac: "Kayit basarisiz: The read operation timed out" hatasindan sonra
-- emreguler98@hotmail.com hesabinin Supabase tarafinda GERCEKTE olusup
-- olusmadigini ve kayit tetikleyicisinin (05_kullanici_kayit_tetikleyicisi)
-- isletme/kullanici satirlarini yaratip yaratmadigini gormek.
-- Zaman asimi uygulama tarafinda oldugu icin istek sunucuda tamamlanmis olabilir.
-- Tek sorgu: Supabase SQL editoru sadece son sorgunun sonucunu gosterir.
-- kullanicilar/isletmeler kolon adlarini varsaymamak icin satirlar to_jsonb ile
-- kullanici id'sinin herhangi bir kolonda gecip gecmedigine gore bulunuyor.

select
  u.id                         as kullanici_id,
  u.email,
  u.created_at                 as olusturulma,
  u.confirmation_sent_at       as dogrulama_epostasi_gonderildi,
  u.email_confirmed_at         as eposta_dogrulandi,
  u.raw_user_meta_data         as meta,
  (select jsonb_agg(to_jsonb(k))
     from public.kullanicilar k
    where exists (select 1 from jsonb_each_text(to_jsonb(k)) e
                   where e.value = u.id::text))          as kullanicilar_satiri,
  (select jsonb_agg(to_jsonb(i))
     from public.isletmeler i
    where i.ad ilike '%EM RESTAURANT%')                  as isletmeler_satiri
from auth.users u
where lower(u.email) = 'emreguler98@hotmail.com';
