-- 181_gorunum_guvenligi.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Gorunumlerin RLS'e tabi olmasi.
--
-- 180 bulgusu: 6 gorunum security_invoker DEGIL (sahibinin yetkisiyle calisip
-- alttaki tablolarin RLS'ini atliyor) ve 7 gorunumun hepsi anon rolune de acik:
--   asama_enerji_maliyeti, asama_iscilik_maliyeti, isletme_aktif_abonelik,
--   malzeme_guncel_fiyat, menu_ogesi_karlilik, recete_uretim_maliyeti
--   (recete_guncel_maliyet zaten security_invoker).
-- Uygulama kodu bu gorunumleri her yerde kendi isletme_id'siyle suzerek
-- okuyor (0_Yillik_Menu, 1_Recete_Uretimi, 5_Tarif_Kutuphanesi kontrol edildi),
-- bu yuzden RLS'e tabi olmalari ekranlarda bir sey degistirmemeli.
--
-- TUZAK: recete_asamalari'nda sadece global tarif okuma politikasi var. Asama
-- gorunumleri RLS'e tabi olunca isletmenin KENDI tariflerinin enerji/iscilik
-- maliyeti sessizce 0 cikardi. Bu yuzden once kendi tarif asamalarini okuma
-- politikasi ekleniyor; asama_malzemeleri'nde RLS aciksa ona da.
--
-- GUVENLIK KILIDI: degisiklikten ONCE her isletme sahibinin gordugu maliyet
-- sonuclari kaydedilir; degisiklikten SONRA ayni sorgular o sahibin kimligiyle
-- (authenticated rolu + JWT) tekrar calistirilir. Tek bir fark bile varsa hata
-- verilir ve HICBIR degisiklik kalmaz (tamami geri alinir).

begin;

-- 0) ONCE: her sahip icin karsilastirma verisi (su anki davranis)
create temp table _once on commit drop as
select k.id as kullanici_id, u.email, k.isletme_id,
  (select coalesce(jsonb_agg(jsonb_build_array(v.recete_id, round(v.toplam_gercek_maliyet_eur, 4))
                             order by v.recete_id), '[]')
     from recete_uretim_maliyeti v where v.isletme_id = k.isletme_id)          as uretim,
  (select count(*) from malzeme_guncel_fiyat f where f.isletme_id = k.isletme_id) as fiyat_sayisi,
  (select coalesce(jsonb_agg(jsonb_build_array(m.menu_ogesi_id, round(m.kar_marji_eur, 4))
                             order by m.menu_ogesi_id), '[]')
     from menu_ogesi_karlilik m where m.isletme_id = k.isletme_id)             as karlilik,
  (select to_jsonb(a) from isletme_aktif_abonelik a where a.isletme_id = k.isletme_id) as abonelik
from public.kullanicilar k
join auth.users u on u.id = k.id
where k.rol = 'sahip';

-- 1) Kendi tariflerinin asamalarini okuma
create policy "kendi recete asamalarini oku" on public.recete_asamalari
  for select using (
    exists (select 1 from public.receteler r
             where r.id = recete_asamalari.recete_id
               and r.isletme_id = auth_isletme_id())
  );

do $$
begin
  if (select relrowsecurity from pg_class where oid = 'public.asama_malzemeleri'::regclass) then
    execute $p$
      create policy "asama malzemelerini oku" on public.asama_malzemeleri
        for select using (
          exists (select 1
                    from public.recete_asamalari a
                    join public.receteler r on r.id = a.recete_id
                   where a.id = asama_malzemeleri.asama_id
                     and (r.isletme_id is null or r.isletme_id = auth_isletme_id()))
        )
    $p$;
  end if;
end $$;

-- 2) Gorunumler RLS'e tabi
alter view public.asama_enerji_maliyeti   set (security_invoker = true);
alter view public.asama_iscilik_maliyeti  set (security_invoker = true);
alter view public.isletme_aktif_abonelik  set (security_invoker = true);
alter view public.malzeme_guncel_fiyat    set (security_invoker = true);
alter view public.menu_ogesi_karlilik     set (security_invoker = true);
alter view public.recete_uretim_maliyeti  set (security_invoker = true);

-- 3) Giris yapmamis ziyaretci (anon) hicbir gorunumu okuyamaz
revoke select on public.asama_enerji_maliyeti, public.asama_iscilik_maliyeti,
  public.isletme_aktif_abonelik, public.malzeme_guncel_fiyat, public.menu_ogesi_karlilik,
  public.recete_guncel_maliyet, public.recete_uretim_maliyeti from anon;

-- 4) SONRA: her sahibin kimligiyle ayni sorgular; fark varsa hepsini geri al
do $$
declare
  s record;
  sonra_uretim jsonb; sonra_fiyat bigint; sonra_karlilik jsonb; sonra_abonelik jsonb;
begin
  for s in select * from _once loop
    perform set_config('request.jwt.claims',
      jsonb_build_object('sub', s.kullanici_id, 'email', s.email, 'role', 'authenticated')::text, true);
    execute 'set local role authenticated';

    select coalesce(jsonb_agg(jsonb_build_array(v.recete_id, round(v.toplam_gercek_maliyet_eur, 4))
                              order by v.recete_id), '[]')
      into sonra_uretim from public.recete_uretim_maliyeti v where v.isletme_id = s.isletme_id;
    select count(*) into sonra_fiyat from public.malzeme_guncel_fiyat f where f.isletme_id = s.isletme_id;
    select coalesce(jsonb_agg(jsonb_build_array(m.menu_ogesi_id, round(m.kar_marji_eur, 4))
                              order by m.menu_ogesi_id), '[]')
      into sonra_karlilik from public.menu_ogesi_karlilik m where m.isletme_id = s.isletme_id;
    select to_jsonb(a) into sonra_abonelik from public.isletme_aktif_abonelik a where a.isletme_id = s.isletme_id;

    execute 'reset role';

    if sonra_uretim is distinct from s.uretim then
      raise exception 'Uretim maliyeti farkli (isletme %): once % satir, sonra % satir',
        s.isletme_id, jsonb_array_length(s.uretim), jsonb_array_length(sonra_uretim);
    end if;
    if sonra_fiyat is distinct from s.fiyat_sayisi then
      raise exception 'Fiyat sayisi farkli (isletme %): once %, sonra %', s.isletme_id, s.fiyat_sayisi, sonra_fiyat;
    end if;
    if sonra_karlilik is distinct from s.karlilik then
      raise exception 'Karlilik farkli (isletme %)', s.isletme_id;
    end if;
    if sonra_abonelik is distinct from s.abonelik then
      raise exception 'Abonelik gorunumu farkli (isletme %)', s.isletme_id;
    end if;
  end loop;
end $$;

-- Dogrulama sonucu (commit oncesi hazirlaniyor; commit'te temp tablo silinir)
create temp table _sonuc on commit preserve rows as
select count(*) as karsilastirilan_sahip_sayisi,
       sum(jsonb_array_length(uretim)) as karsilastirilan_uretim_satiri,
       sum(fiyat_sayisi) as karsilastirilan_fiyat_satiri
from _once;

commit;

select
  s.*,
  (select jsonb_agg(jsonb_build_object('gorunum', c.relname,
            'security_invoker', coalesce(c.reloptions::text like '%security_invoker=true%', false),
            'anon_okuyabilir', has_table_privilege('anon', c.oid, 'SELECT'))
          order by c.relname)
     from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relkind in ('v', 'm'))                   as gorunumler
from _sonuc s;
