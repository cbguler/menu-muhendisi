-- 06_eksik_kullanicilari_tamamla.sql
--
-- Tetikleyici (05_kullanici_kayit_tetikleyicisi.sql) sadece BUNDAN SONRA
-- olusturulan hesaplarda otomatik calisir. Daha once (tetikleyiciden once)
-- kayit olmus ya da herhangi bir sebeple kullanicilar tablosunda satiri
-- eksik kalmis hesaplari bu script geriye donuk tamamlar. Birden fazla
-- kez calistirilsa da zarari yok -- sadece eksik olanlari isler.

do $$
declare
  kullanici       record;
  yeni_isletme_id uuid;
  deneme_plan_id  uuid;
begin
  select id into deneme_plan_id from abonelik_planlari where kod = 'deneme';

  for kullanici in
    select u.id, u.raw_user_meta_data, u.email
    from auth.users u
    left join kullanicilar k on k.id = u.id
    where k.id is null
  loop
    insert into isletmeler (ad)
    values (coalesce(kullanici.raw_user_meta_data ->> 'isletme_adi', kullanici.email))
    returning id into yeni_isletme_id;

    insert into kullanicilar (id, isletme_id, rol)
    values (kullanici.id, yeni_isletme_id, 'sahip');

    insert into abonelikler (isletme_id, plan_id, durum, deneme_bitis_tarihi)
    values (yeni_isletme_id, deneme_plan_id, 'deneme', (current_date + 14));
  end loop;
end;
$$;
