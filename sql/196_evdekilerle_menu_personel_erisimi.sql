-- 196_evdekilerle_menu_personel_erisimi.sql
-- 16 Ekim 2026 (acik is #12). Evdekilerle Menu'ye personel erisimi.
--   Yetki anahtari: "ev_menu" (yetkiler.py). Gorur (1): menu kurar, listeyi/PDF'i alir; evdeki malzemeleri gorur.
--   Duzenler (2): evdeki malzemeleri ekler/siler, menuyu onaylayip stoktan duser. Patron her zaman 2.
--   1) ev_stogu politikasi: eskiden sadece sahip ("isletme_id = auth_isletme_id() and auth_sahip_mi()").
--      Simdi auth_yetki_seviye('ev_menu') ile: okuma >= 1, yazma >= 2. Sahip icin sonuc ayni (seviye 2).
--      Eski modeldeki sahip olmayan roller (yonetici/mutfak/salt_okunur) icin seviye 0 -> yine erisemez.
--   2) ev_menu_hizmeti_acik(): personel ana isletmenin satirini okuyamayabilir (sadece calistigi subeleri
--      gorur); hizmetin acik olup olmadigini bu fonksiyon soyler. Sadece true/false doner, baska veri vermez.
-- Tekrar calistirmak guvenli.

begin;

drop policy if exists "sahip kendi ev stogunu yonetir" on public.ev_stogu;
drop policy if exists "ev stogunu oku" on public.ev_stogu;
drop policy if exists "ev stoguna ekle" on public.ev_stogu;
drop policy if exists "ev stogunu degistir" on public.ev_stogu;
drop policy if exists "ev stogundan sil" on public.ev_stogu;

create policy "ev stogunu oku" on public.ev_stogu for select
  using (isletme_id = auth_isletme_id() and (select public.auth_yetki_seviye('ev_menu')) >= 1);
create policy "ev stoguna ekle" on public.ev_stogu for insert
  with check (isletme_id = auth_isletme_id() and (select public.auth_yetki_seviye('ev_menu')) >= 2);
create policy "ev stogunu degistir" on public.ev_stogu for update
  using (isletme_id = auth_isletme_id() and (select public.auth_yetki_seviye('ev_menu')) >= 2)
  with check (isletme_id = auth_isletme_id() and (select public.auth_yetki_seviye('ev_menu')) >= 2);
create policy "ev stogundan sil" on public.ev_stogu for delete
  using (isletme_id = auth_isletme_id() and (select public.auth_yetki_seviye('ev_menu')) >= 2);

create or replace function public.ev_menu_hizmeti_acik() returns boolean
language sql stable security definer set search_path to 'public' as $$
  select coalesce((
    select i.ev_menu_hizmeti from isletmeler i
     where i.id = isletme_ana_id(auth_isletme_id())
       and auth_isletmeye_erisebilir(auth_isletme_id())
  ), false)
$$;
revoke all on function public.ev_menu_hizmeti_acik() from public, anon;
grant execute on function public.ev_menu_hizmeti_acik() to authenticated;

commit;

-- Dogrulama (tek satir)
select
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'ev_stogu')            as politika_sayisi_4_olmali,
  (select count(*) from pg_policies where schemaname = 'public' and tablename = 'ev_stogu'
      and policyname = 'sahip kendi ev stogunu yonetir')                                              as eski_politika_0_olmali,
  (select relrowsecurity from pg_class where oid = 'public.ev_stogu'::regclass)                       as rls_acik_true_olmali,
  has_function_privilege('anon', 'public.ev_menu_hizmeti_acik()', 'execute')                          as anon_calistirabilir_false_olmali,
  has_function_privilege('authenticated', 'public.ev_menu_hizmeti_acik()', 'execute')                 as uye_calistirabilir_true_olmali,
  (select count(*) from public.ev_stogu)                                                              as stok_satiri_sayisi;
