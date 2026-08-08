-- 43_aktif_abonelik_view_left_join.sql
--
-- isletme_aktif_abonelik view'i, abonelikler ile abonelik_planlari'ni
-- DUZ (INNER) JOIN ile birlestiriyordu. Yeni kayit tetikleyicisi
-- (42_kayit_tetikleyicisi_deneme_kaldir.sql) artik plan_id=NULL ile
-- satir olusturuyor (kullanici henuz plan secip odeme yapmadi) --
-- INNER JOIN'de NULL hicbir seye eslesmedigi icin bu kullanicilar view'de
-- HIC GORUNMUYORDU, bu da onlari yanlislikla "aboneliğin yok" (tamamen
-- bloklanmis) ekranina dusuruyordu -- oysa "sadece Kontrol Paneli'ni
-- gorebilsin" davranisini istiyorduk.
--
-- Tek degisiklik: join -> left join. Geri kalan her sey (secili sutunlar,
-- distinct on, order by) AYNEN korunuyor -- create or replace view zaten
-- ayni sutun listesini gerektiriyor, drop/create gerekmiyor.

create or replace view public.isletme_aktif_abonelik
with
  (security_invoker = on) as
select distinct
  on (a.isletme_id) a.isletme_id,
  a.durum,
  p.kod as plan_kodu,
  p.ad as plan_adi,
  p.sube_limiti,
  p.recete_limiti,
  p.ozellikler,
  a.donem_bitis,
  a.deneme_bitis_tarihi
from
  abonelikler a
  left join abonelik_planlari p on p.id = a.plan_id
order by
  a.isletme_id,
  a.created_at desc;

-- DOGRULAMA -- plan_id=NULL olan bir test satiri olsa bile artik burada
-- gorunmesi lazim (plan_kodu/plan_adi NULL olarak, ama satir KAYBOLMADAN).
select isletme_id, durum, plan_kodu, plan_adi
from isletme_aktif_abonelik;
