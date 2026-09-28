-- 184_kullanim_olaylari_12_ay_saklama.sql
-- YUZ ... DUZELTME (29 Eylul 2026, Menu Muhendisi 9): Bahri'nin karari --
-- kullanim_olaylari kayitlari 12 ay sonra OTOMATIK silinsin.
--
-- Yontem: harici zamanlayici (pg_cron) GEREKTIRMEYEN bir tetikleyici. Yeni kayitlar
-- yazilirken, ortalama her 100 yazma isleminde bir, 12 aydan eski kayitlar silinir.
-- Uygulama her gun kullanildigi surece eski kayitlar gecikmesiz temizlenir; hic
-- kullanilmayan donemde tablo zaten buyumez. created_at indeksi sayesinde silme hizlidir.
-- Tablodaki silme yasagi (RLS'te silme politikasi yok) korunuyor: silmeyi sadece bu
-- SECURITY DEFINER fonksiyon yapar, hicbir kullanici ve admin elle silemez.

begin;

create or replace function public.kullanim_olaylari_eskileri_sil()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $$
begin
  if random() < 0.01 then
    delete from kullanim_olaylari where created_at < now() - interval '12 months';
  end if;
  return null;
end $$;

revoke execute on function public.kullanim_olaylari_eskileri_sil() from public, anon, authenticated;

create trigger kullanim_olaylari_saklama
  after insert on public.kullanim_olaylari
  for each statement
  execute function public.kullanim_olaylari_eskileri_sil();

commit;

-- Dogrulama (tek sorgu): tetikleyici var, 12 aydan eski kayit sayisi (bugun 0 olmali)
select
  (select count(*) from pg_trigger where tgname = 'kullanim_olaylari_saklama') as tetikleyici_var,
  (select count(*) from public.kullanim_olaylari
    where created_at < now() - interval '12 months')                           as eski_kayit_sayisi;
