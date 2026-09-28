-- 172_emre_hesabi_dogrula_ve_isletme_adi.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Emre'nin hesabi.
-- 171 teshisi: emreguler98@hotmail.com hesabi 13 Agustos 2026'da OLUSMUS
-- (kullanici id b4c1411a-..., isletme id 46ad7857-..., isletme adi "Gocek"),
-- dogrulama e-postasi gonderilmis ama e-posta HIC dogrulanmamis. Bugunku
-- "Hesap olustur" denemesi yeni hesap acmadi (e-posta zaten kayitli).
-- Bu dosya:
--   1) e-postayi elle dogrulanmis isaretler (giris yapabilsin diye),
--   2) isletme adini bugun formda yazilan unvana cevirir,
--   3) sonda hesabi, isletmeyi ve abonelik satirini gosterir (degistirmez).
-- Abonelik durumu BU DOSYADA DEGISTIRILMIYOR: kolonlari/durumu gormeden
-- varsayim yapmamak icin once sonucu gorecegiz.
-- Her UPDATE tam 1 satir etkilemezse hata verir ve her sey geri alinir.

begin;

do $$
declare n int;
begin
  update auth.users
     set email_confirmed_at = now()
   where id = 'b4c1411a-0d01-48b3-b240-02d77fc0a837'
     and lower(email) = 'emreguler98@hotmail.com'
     and email_confirmed_at is null;
  get diagnostics n = row_count;
  if n <> 1 then
    raise exception 'E-posta dogrulama: beklenen 1 satir, etkilenen %', n;
  end if;

  update public.isletmeler
     set ad = 'GİZ-EM RESTAURANT LTD. ŞTİ.'
   where id = '46ad7857-581e-4e1b-9d24-d6d1c9e2916f';
  get diagnostics n = row_count;
  if n <> 1 then
    raise exception 'Isletme adi: beklenen 1 satir, etkilenen %', n;
  end if;
end $$;

commit;

-- Dogrulama (tek sorgu, 1 satir donmeli)
select
  u.email,
  u.email_confirmed_at                                       as eposta_dogrulandi,
  (select i.ad from public.isletmeler i
    where i.id = '46ad7857-581e-4e1b-9d24-d6d1c9e2916f')     as isletme_adi,
  (select jsonb_agg(to_jsonb(a)) from public.abonelikler a
    where exists (select 1 from jsonb_each_text(to_jsonb(a)) e
                   where e.value = '46ad7857-581e-4e1b-9d24-d6d1c9e2916f')) as abonelik_satirlari
from auth.users u
where u.id = 'b4c1411a-0d01-48b3-b240-02d77fc0a837';
