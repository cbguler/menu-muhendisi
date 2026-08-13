-- 49_abonelik_durum_kisit_duzelt.sql
--
-- BULUNAN HATA (12 Agustos 2026, Oturum 11 -- Bahri'nin oglu Emre icin
-- gercek bir hesap acmaya calismasi sirasinda ortaya cikti): kayit
-- "Database error saving new user" ile basarisiz oldu.
--
-- KOK NEDEN: abonelikler tablosunun ORIJINAL semasinda (02_abonelik_ve_
-- odeme_altyapisi.sql) durum sutununun CHECK kisiti sadece su degerlere
-- izin veriyordu:
--   ('deneme','aktif','odeme_gecikti','iptal_edildi','suresi_doldu')
--
-- 41/42 no'lu migration'lar uc kademeli modele gecerken (deneme plani
-- kaldirildi) yeni tetikleyici artik durum='odeme_bekleniyor' ile satir
-- ekliyor (bkz. 42_kayit_tetikleyicisi_deneme_kaldir.sql) -- ama bu
-- ESKI CHECK KISITI GUNCELLENMEDI. 'odeme_bekleniyor' (ve daha sonra
-- app.py'nin bekledigi 'odeme_alindi_onay_bekliyor') bu listede
-- OLMADIGI icin, tetikleyicinin INSERT'i CHECK kisitini ihlal edip
-- exception firlatiyordu -- bu da auth.users satirinin OLUSTURULMASINI
-- BILE engelliyordu (AFTER INSERT tetikleyicisindeki hata tum
-- transaction'i geri aliyor), Supabase Auth bunu genel "Database error
-- saving new user" mesajiyla sariyor.
--
-- Bu sekilde henuz kimse fark edemedi cunku 41/42'den beri GERCEK bir
-- kayit denemesi hic yapilmamisti (test edilmesi gereken ama daha once
-- hep "sirada" kalan madde -- tam da bu yuzden bulundu).
--
-- DUZELTME: kisit dinamik olarak bulunup (isim tahmin edilmeden --
-- pg_constraint'ten sorgulanarak) kaldiriliyor, YENI kisit ESKI TUM
-- degerleri + IKI YENI degeri icerecek sekilde ekleniyor. Eski
-- degerlerin hepsi KORUNDU -- yoksa tabloda halihazirda o degerlerden
-- birini tasiyan bir satir varsa (ör. deneme), yeni kisidi eklerken
-- ALTER TABLE'in kendisi BASARISIZ olurdu (Postgres yeni kisidi mevcut
-- tum satirlara karsi da dogrular).

do $$
declare
  kisit_adi text;
begin
  select con.conname into kisit_adi
  from pg_constraint con
  join pg_attribute att
    on att.attrelid = con.conrelid and att.attnum = any(con.conkey)
  where con.conrelid = 'abonelikler'::regclass
    and con.contype = 'c'
    and att.attname = 'durum';

  if kisit_adi is not null then
    execute format('alter table abonelikler drop constraint %I', kisit_adi);
  end if;
end $$;

alter table abonelikler add constraint abonelikler_durum_check
  check (durum in (
    'deneme', 'aktif', 'odeme_gecikti', 'iptal_edildi', 'suresi_doldu',
    'odeme_bekleniyor', 'odeme_alindi_onay_bekliyor'
  ));

-- NOT: bu duzeltmeden sonra kayit HALA basarisiz olursa, ikinci suphe:
-- plan_id sutunu -- 42 no'lu migration'da "not null" kaldirilmisti,
-- ama gercekten calistirildigini asagidaki dogrulamayla kontrol et.

-- DOGRULAMA
select conname, pg_get_constraintdef(oid) as tanim
from pg_constraint
where conrelid = 'abonelikler'::regclass and contype = 'c';

select column_name, is_nullable
from information_schema.columns
where table_name = 'abonelikler' and column_name = 'plan_id';
