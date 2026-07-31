-- 05_kullanici_kayit_tetikleyicisi.sql
--
-- HATA: app.py'deki kayit mantigi, isletme/kullanici/abonelik satirlarini
-- olusturmak icin sign_up() sonrasi bir oturumun (session) var olmasina
-- guveniyordu. E-posta dogrulamasi zorunlu oldugunda Supabase, dogrulama
-- tamamlanana kadar oturum donmez -- bu yuzden kayit satirlari hic
-- olusmuyordu, kullanici sonra giris yapinca "kullanicilar" tablosunda
-- kendine ait satir bulunamiyordu (PGRST116).
--
-- DUZELTME: Bu isi client'tan (Streamlit) veritabani tetikleyicisine
-- tasiyoruz. auth.users tablosuna her yeni kayit girdiginde -- oturum
-- olsun olmasin, e-posta dogrulansin dogrulanmasin -- otomatik olarak
-- isletmeler + kullanicilar + abonelikler (deneme) satirlari olusur.

create or replace function public.yeni_kullanici_isle()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  yeni_isletme_id uuid;
  deneme_plan_id  uuid;
  isletme_adi     text;
begin
  isletme_adi := coalesce(new.raw_user_meta_data ->> 'isletme_adi', 'Yeni İşletme');

  insert into isletmeler (ad) values (isletme_adi)
  returning id into yeni_isletme_id;

  insert into kullanicilar (id, isletme_id, rol)
  values (new.id, yeni_isletme_id, 'sahip');

  select id into deneme_plan_id from abonelik_planlari where kod = 'deneme';

  insert into abonelikler (isletme_id, plan_id, durum, deneme_bitis_tarihi)
  values (yeni_isletme_id, deneme_plan_id, 'deneme', (current_date + 14));

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.yeni_kullanici_isle();
