-- 07_varsayilan_fiyat.sql
--
-- malzemeler tablosuna, arastirilmis Temmuz 2026 referans fiyatini tasiyan
-- bir sutun ekliyoruz (varsayilan_fiyat_eur). Bu, isletmeye ozel
-- malzeme_fiyat_gecmisi'nden farkli: sadece "yeni bir isletme kayit
-- olunca baslangic degeri ne olsun" sorusuna cevap verir.
--
-- Tetikleyici de guncelleniyor: yeni isletme olusunca, global katalogdaki
-- her malzeme icin bu varsayilan fiyati kendi malzeme_fiyat_gecmisi'ne
-- kopyalar. Isletme sonradan kendi fiyatlarini serbestce degistirebilir.

alter table malzemeler add column if not exists varsayilan_fiyat_eur numeric;

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

  -- Global katalogdaki varsayilan fiyatlari yeni isletmenin kendi fiyat
  -- gecmisine baslangic degeri olarak kopyala.
  insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
  select yeni_isletme_id, id, varsayilan_fiyat_eur, 'Varsayılan (Temmuz 2026 piyasa araştırması)'
  from malzemeler
  where isletme_id is null and varsayilan_fiyat_eur is not null;

  return new;
end;
$$;
