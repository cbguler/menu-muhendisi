-- 12_tarif_kutuphanesi_global_receteler.sql
--
-- Yillik menu uretim motorunun 74 tariflik baslangic kutuphanesini
-- barindirabilmesi icin `receteler` tablosunu `malzemeler` ile ayni
-- desene tasir: isletme_id NULL = global/ortak tarif kutuphanesi,
-- isletme_id dolu = isletmenin kendi maliyet/karlilik tarifi.
--
-- Ayrica veri girisi sirasinda fark edilen bir katalog eksigini
-- (SALATALIK / salatalik, cacik ve salatalarda temel malzeme) düzeltir --
-- 337(8) kalemlik kaynak_duzeltilmis_v2.xlsx'te bu kalem hic yoktu.

-- =====================================================================
-- 0) EKSIK MALZEME: SALATALIK (SEBZELER, kategori_id = 2)
-- Degerler FAO/USDA referans degerlerine yakin standart cig salatalik
-- degerleridir; ALIM FIYATI diger kalemlerle ayni yontemle (Temmuz 2026,
-- EUR/TRY~54) yaklasik referans olarak verilmistir -- kaynak dosyadaki
-- diger kalemlerle ayni onemde, kesin tedarikci fiyati degildir.
-- =====================================================================

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
) values (
  null, 2, 'SALATALIK', 0.95, 4.0, 7,
  0.10, 4, 15, 0.7, 0.1, 3.6,
  15, 'Yaz', 0.6, 150, 'Kaynak dosyada eksikti, 30 Temmuz/1 Agustos 2026 tarif kutuphanesi oturumunda eklendi',
  0.30
)
on conflict do nothing;

-- =====================================================================
-- 1) RECETELER: isletme_id NULL destegi (malzemeler ile ayni desen)
-- =====================================================================

alter table receteler alter column isletme_id drop not null;

comment on column receteler.isletme_id is
  'NULL ise: global tarif kutuphanesi (yillik menu motoru icin ortak, '
  'salt-okunur baslangic tarifleri -- 74 tariflik Turk mutfagi seti). '
  'Dolu ise: isletmenin kendi maliyet/karlilik amacli tarifidir.';

create unique index if not exists receteler_global_ad_uidx
  on receteler (ad) where isletme_id is null;
create unique index if not exists receteler_ozel_ad_uidx
  on receteler (isletme_id, ad) where isletme_id is not null;

-- =====================================================================
-- 2) RECETELER ICIN MEVSIM ETIKETI (hizli filtreleme)
-- Gercek mevsimsellik malzemelerin `mevsim` alanindan da turetilebilir;
-- bu sutun sadece yillik menu motorunun agir join yapmadan hizlica
-- "bu tarif hangi mevsimde one cikar" sorgulayabilmesi icindir.
-- =====================================================================

alter table receteler add column if not exists mevsim_etiketi text
  check (mevsim_etiketi in ('ilkbahar','yaz','sonbahar','kis','yil_boyunca'));
comment on column receteler.mevsim_etiketi is
  'Tarifin baskin mevsimi (kürasyonla belirlenir); yil_boyunca = mevsimsel kisitlama yok.';

-- =====================================================================
-- 3) RLS: SELECT herkese (global + kendi), YAZMA sadece kendi tarifine
-- =====================================================================

drop policy if exists "kendi receteni yonet" on receteler;

create policy "recete oku" on receteler
  for select using (isletme_id is null or isletme_id = auth_isletme_id());
create policy "ozel recete ekle" on receteler
  for insert with check (isletme_id = auth_isletme_id());
create policy "ozel recete guncelle" on receteler
  for update using (isletme_id = auth_isletme_id());
create policy "ozel recete sil" on receteler
  for delete using (isletme_id = auth_isletme_id());

drop policy if exists "kendi recete malzemeni yonet" on recete_malzemeleri;

create policy "recete malzemesi oku" on recete_malzemeleri
  for select using (
    recete_id in (
      select id from receteler
      where isletme_id is null or isletme_id = auth_isletme_id()
    )
  );
create policy "ozel recete malzemesi ekle" on recete_malzemeleri
  for insert with check (
    recete_id in (select id from receteler where isletme_id = auth_isletme_id())
  );
create policy "ozel recete malzemesi guncelle" on recete_malzemeleri
  for update using (
    recete_id in (select id from receteler where isletme_id = auth_isletme_id())
  );
create policy "ozel recete malzemesi sil" on recete_malzemeleri
  for delete using (
    recete_id in (select id from receteler where isletme_id = auth_isletme_id())
  );
