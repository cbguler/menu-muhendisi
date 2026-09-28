-- 183_kullanim_olaylari.sql
-- YUZ ... DUZELTME (29 Eylul 2026, Menu Muhendisi 9): Admin icin kullanim istatistikleri.
-- Bahri'nin istegi: admin sayfasinda abonelerin uygulamaya giris, cikis, hangi sayfada
-- ne kadar kaldigi gibi istatistikler.
--
-- Uygulama her oturumda su olaylari yazar:
--   giris : oturum basladi (detay: 'sifre' = giris formu, 'hatirla' = "Beni hatirla" cerezi)
--   sayfa : sayfa goruntuleme (sayfa degisince veya ayni sayfada en az 60 sn arayla)
--   cikis : "Cikis yap" dugmesi
-- Sayfada kalma suresi olaylar arasindaki farktan TAHMIN edilir (Streamlit sekmenin
-- kapandigini sunucuya bildirmez; "cikis yap" demeden kapatilan oturumun bitisi bilinemez).
--
-- Guvenlik: her kullanici SADECE kendi olayini yazabilir; okuma SADECE admin.
-- Olaylar degistirilemez ve silinemez (guncelleme/silme politikasi yok).

begin;

create table public.kullanim_olaylari (
  id              bigint generated always as identity primary key,
  kullanici_id    uuid not null default auth.uid(),
  email           text,
  isletme_id      uuid,          -- calisilan isletme (sube olabilir)
  ana_isletme_id  uuid,          -- abonelik sahibi isletme
  oturum_kimligi  text not null, -- tarayici oturumu
  olay            text not null check (olay in ('giris', 'cikis', 'sayfa')),
  sayfa           text,
  detay           text,
  created_at      timestamptz not null default now()
);
create index kullanim_olaylari_zaman_idx on public.kullanim_olaylari (created_at desc);
create index kullanim_olaylari_oturum_idx on public.kullanim_olaylari (oturum_kimligi, created_at);
create index kullanim_olaylari_ana_isletme_idx on public.kullanim_olaylari (ana_isletme_id, created_at);

alter table public.kullanim_olaylari enable row level security;

create policy "kendi olayini yazar" on public.kullanim_olaylari
  for insert with check (kullanici_id = auth.uid());
create policy "admin olaylari gorur" on public.kullanim_olaylari
  for select using (auth_admin_mi());

revoke all on public.kullanim_olaylari from anon;

commit;

-- Dogrulama (tek sorgu): RLS acik, 2 politika, tablo bos
select
  (select relrowsecurity from pg_class where oid = 'public.kullanim_olaylari'::regclass) as rls_acik,
  (select count(*) from pg_policies where tablename = 'kullanim_olaylari')              as politika_sayisi,
  (select count(*) from public.kullanim_olaylari)                                       as satir_sayisi;
