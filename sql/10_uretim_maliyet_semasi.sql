-- 10_uretim_maliyet_semasi.sql
--
-- cafe_business_plan.xlsx'teki "isil islem blogu" mantiginin receteler
-- moduluna tasinmis hali. Dort gereksinimi karsilar:
--   1) Isil islem (enerji) maliyeti
--   2) Asama basi zaman -> iscilik maliyeti
--   3) Paralel yapilabilen isler (bagimlilik grafi altyapisi -- gercek
--      kritik yol hesaplamasi asagida aciklandigi gibi Python tarafinda
--      yapilir, bkz. NOT)
--   4) Genel gider payinin porsiyona yansitilmasi

-- =====================================================================
-- 1) İŞLETME MALİYET AYARLARI (varsayılan enerji/işçilik/genel gider)
-- =====================================================================

create table isletme_maliyet_ayarlari (
  isletme_id                     uuid primary key references isletmeler(id) on delete cascade,
  elektrik_birim_fiyat_eur_kwh   numeric not null default 0.12,
  dogalgaz_birim_fiyat_eur_kwh   numeric not null default 0.08,
  personel_saat_ucreti_eur       numeric not null default 5.0,
  genel_gider_yuzdesi            numeric not null default 15.0,  -- % (kira, sigorta, yonetim vb.)
  updated_at                     timestamptz not null default now()
);

alter table isletme_maliyet_ayarlari enable row level security;
create policy "kendi maliyet ayarini yonet" on isletme_maliyet_ayarlari
  for all using (isletme_id = auth_isletme_id());

-- =====================================================================
-- 2) REÇETE AŞAMALARI (üretim adımları)
-- =====================================================================

create table recete_asamalari (
  id                 uuid primary key default gen_random_uuid(),
  recete_id          uuid not null references receteler(id) on delete cascade,
  ad                 text not null,               -- 'Sebzeleri doğra', 'Haşlama', 'Kavurma' vb.
  sira               smallint not null,
  sure_dakika        numeric not null check (sure_dakika >= 0),
  isil_islem_mi      boolean not null default false,
  enerji_kaynagi     text check (enerji_kaynagi in ('elektrik', 'dogalgaz')),
  baslangic_sicaklik numeric,                      -- °C (isil islem ise zorunlu, uygulama katmaninda kontrol edilir)
  hedef_sicaklik     numeric,                      -- °C
  verimlilik_orani   numeric not null default 0.65 check (verimlilik_orani > 0 and verimlilik_orani <= 1),
  created_at         timestamptz not null default now()
);
create index recete_asamalari_recete_idx on recete_asamalari (recete_id);

comment on column recete_asamalari.verimlilik_orani is
  'Isi kaybi/ekipman verimsizligi faktoru (0-1). 1.0 = kayipsiz ideal, '
  'gercek ocak/firin icin tipik 0.5-0.7 arasi kullanilir.';

-- Bu asamada hangi recete malzemeleri isleniyor (recete_malzemeleri'nin alt kumesi)
create table asama_malzemeleri (
  id                 uuid primary key default gen_random_uuid(),
  asama_id           uuid not null references recete_asamalari(id) on delete cascade,
  recete_malzeme_id  uuid not null references recete_malzemeleri(id) on delete cascade,
  unique (asama_id, recete_malzeme_id)
);

-- Asama bagimliliklari (paralel is tespiti icin DAG) -- bir asamanin
-- baslayabilmesi icin BURADA LISTELENEN onceki asamalarin hepsinin bitmis
-- olmasi gerekir. Bagimliligi olmayan asamalar birbirine paralel sayilir.
create table asama_bagimliliklari (
  asama_id         uuid not null references recete_asamalari(id) on delete cascade,
  onceki_asama_id  uuid not null references recete_asamalari(id) on delete cascade,
  primary key (asama_id, onceki_asama_id)
);

-- =====================================================================
-- 3) ISIL İŞLEM (ENERJİ) MALİYETİ -- Q = m * c * ΔT
-- =====================================================================

create view asama_enerji_maliyeti as
select
  a.id as asama_id,
  a.recete_id,
  a.enerji_kaynagi,
  sum(rm.miktar_gram * m.ozgul_isi * (a.hedef_sicaklik - a.baslangic_sicaklik)) as toplam_joule,
  sum(rm.miktar_gram * m.ozgul_isi * (a.hedef_sicaklik - a.baslangic_sicaklik))
    / 3600000.0 / a.verimlilik_orani as gerekli_kwh,
  (sum(rm.miktar_gram * m.ozgul_isi * (a.hedef_sicaklik - a.baslangic_sicaklik))
    / 3600000.0 / a.verimlilik_orani)
  * case a.enerji_kaynagi
      when 'elektrik' then ima.elektrik_birim_fiyat_eur_kwh
      when 'dogalgaz' then ima.dogalgaz_birim_fiyat_eur_kwh
      else 0
    end as enerji_maliyeti_eur
from recete_asamalari a
join asama_malzemeleri am on am.asama_id = a.id
join recete_malzemeleri rm on rm.id = am.recete_malzeme_id
join malzemeler m on m.id = rm.malzeme_id
join receteler r on r.id = a.recete_id
join isletme_maliyet_ayarlari ima on ima.isletme_id = r.isletme_id
where a.isil_islem_mi
group by a.id, a.recete_id, a.enerji_kaynagi, ima.elektrik_birim_fiyat_eur_kwh, ima.dogalgaz_birim_fiyat_eur_kwh;

comment on view asama_enerji_maliyeti is
  'Duyulur isi formulu (Q=mcΔT) ile hesaplanan enerji maliyeti. '
  'malzemelerin ozgul_isi (J/g.C) alanini kullanir. Isi iletkenligi/yuzey '
  'alani suan bu hesaba dahil degil -- ileride sure tahmini/dogrulamasi '
  'icin kullanilabilir (Fourier yasasi), ama v1 sadece kullaniciyi verdigi '
  'sure_dakika degerine guveniyor.';

-- =====================================================================
-- 4) İŞÇİLİK MALİYETİ (asama basi sure -> ucret)
-- =====================================================================

create view asama_iscilik_maliyeti as
select
  a.id as asama_id,
  a.recete_id,
  a.sure_dakika,
  (a.sure_dakika / 60.0) * ima.personel_saat_ucreti_eur as iscilik_maliyeti_eur
from recete_asamalari a
join receteler r on r.id = a.recete_id
join isletme_maliyet_ayarlari ima on ima.isletme_id = r.isletme_id;

-- =====================================================================
-- 5) REÇETE BAZINDA TOPLAM ÜRETİM MALİYETİ (malzeme + enerji + işçilik + genel gider)
-- =====================================================================
-- NOT: Toplam SURE (paralel isler dikkate alinarak kritik yol) burada
-- HESAPLANMIYOR -- genel bir bagimlilik grafinde (ozellikle bir asamanin
-- birden fazla onceki asamaya bagli oldugu "elmas" durumlarda) doğru
-- kritik yol hesaplamasi saf SQL'de kirilgan/hataya acik oluyor. Bunun
-- yerine Streamlit tarafinda basit bir topolojik siralama + en uzun yol
-- algoritmasiyla (bkz. hesapla_kritik_yol.py) hesaplaniyor. Iscilik
-- MALIYETI (ucret) burada dogru -- cunku her calisanin harcadigi sure
-- paralel de olsa ayri ayri ucretlendirilir; sadece TOPLAM GECEN SURE
-- (musteriye servis suresi) paralellikten etkilenir.

create view recete_uretim_maliyeti as
select
  r.id as recete_id,
  r.isletme_id,
  r.ad as recete_adi,
  r.porsiyon_sayisi,
  rgm.toplam_maliyet_eur as malzeme_maliyeti_eur,
  coalesce(enerji.toplam_enerji_eur, 0) as enerji_maliyeti_eur,
  coalesce(iscilik.toplam_iscilik_eur, 0) as iscilik_maliyeti_eur,
  (rgm.toplam_maliyet_eur + coalesce(enerji.toplam_enerji_eur, 0) + coalesce(iscilik.toplam_iscilik_eur, 0))
    * (ima.genel_gider_yuzdesi / 100.0) as genel_gider_payi_eur,
  (rgm.toplam_maliyet_eur + coalesce(enerji.toplam_enerji_eur, 0) + coalesce(iscilik.toplam_iscilik_eur, 0))
    * (1 + ima.genel_gider_yuzdesi / 100.0) as toplam_gercek_maliyet_eur,
  (rgm.toplam_maliyet_eur + coalesce(enerji.toplam_enerji_eur, 0) + coalesce(iscilik.toplam_iscilik_eur, 0))
    * (1 + ima.genel_gider_yuzdesi / 100.0) / r.porsiyon_sayisi as porsiyon_gercek_maliyet_eur
from receteler r
join recete_guncel_maliyet rgm on rgm.recete_id = r.id
join isletme_maliyet_ayarlari ima on ima.isletme_id = r.isletme_id
left join (
  select recete_id, sum(enerji_maliyeti_eur) as toplam_enerji_eur
  from asama_enerji_maliyeti
  group by recete_id
) enerji on enerji.recete_id = r.id
left join (
  select recete_id, sum(iscilik_maliyeti_eur) as toplam_iscilik_eur
  from asama_iscilik_maliyeti
  group by recete_id
) iscilik on iscilik.recete_id = r.id;

comment on view recete_uretim_maliyeti is
  'Madde 4''teki (genel gider payi) tam maliyet zinciri: malzeme + enerji + '
  'iscilik toplanir, uzerine genel_gider_yuzdesi eklenir, porsiyon sayisina '
  'bolunur. Bu, menu_ogesi_karlilik view''inin kullandigi basit '
  'recete_guncel_maliyet''ten daha detayli/gercekci bir alternatif -- ikisi '
  'de bir arada durur, hangisinin kullanilacagi uygulama tarafinda secilir.';

-- security_invoker: yeni view'ler de RLS'e tabi olmali (bkz. 03_view_guvenlik_duzeltmesi.sql'deki ayni gerekce)
alter view asama_enerji_maliyeti set (security_invoker = on);
alter view asama_iscilik_maliyeti set (security_invoker = on);
alter view recete_uretim_maliyeti set (security_invoker = on);
