-- 42_kayit_tetikleyicisi_deneme_kaldir.sql
--
-- 05_kullanici_kayit_tetikleyicisi.sql'deki tetikleyici, her yeni kayitta
-- otomatik olarak "deneme" planina bagli bir abonelik satiri olusturuyordu.
-- "deneme" kavrami kaldirildigi icin (41_deneme_plani_kaldir.sql) bu
-- tetikleyici BOZULACAKTI -- deneme_plan_id NULL donerdi, abonelikler
-- satiri gecersiz/kirik olurdu. Bu migration tetikleyiciyi YENI 3 kademeli
-- modele gore yeniden yaziyor:
--
--   1) odeme_bekleniyor -- YENI kayit, henuz hic odeme yapmadi. Bu durumda
--      app.py navigasyonu SADECE Kontrol Paneli + Abonelik gosterir.
--   2) odeme_alindi_onay_bekliyor -- odedi ama admin henuz onaylamadi.
--      Yillik Menu/Recete Uretimi/Ozel Menu Uretimi/Tarif Kutuphanesi
--      GORUNUR ama salt okunur (islem yapilamaz).
--   3) aktif -- admin onayladi, tam erisim.
--
-- plan_id artik kayit aninda BILINMIYOR (kullanici hangi plani secip
-- odeyecegini sonra belirleyecek) -- bu yuzden once sutunu NULL'a izin
-- verecek sekilde gevsetiyoruz.

alter table abonelikler alter column plan_id drop not null;

create or replace function public.yeni_kullanici_isle()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  yeni_isletme_id uuid;
  isletme_adi     text;
begin
  isletme_adi := coalesce(new.raw_user_meta_data ->> 'isletme_adi', 'Yeni İşletme');

  insert into isletmeler (ad) values (isletme_adi)
  returning id into yeni_isletme_id;

  insert into kullanicilar (id, isletme_id, rol)
  values (new.id, yeni_isletme_id, 'sahip');

  insert into abonelikler (isletme_id, plan_id, durum)
  values (yeni_isletme_id, null, 'odeme_bekleniyor');

  return new;
end;
$$;

-- Tetikleyicinin kendisi zaten dogruydu (drop+create), yeniden olusturmaya
-- gerek yok, fonksiyon degistigi icin otomatik yeni davranisi kullanacak.

-- DOGRULAMA
select proname, prosrc like '%odeme_bekleniyor%' as guncel_mi
from pg_proc where proname = 'yeni_kullanici_isle';
