-- 186_teshis_uygulama_sorgu_hizi.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez). Aylik Menu sayfasinin veri sorgularini
-- Bahri'nin KIMLIGIYLE (uygulamanin gordugu gibi, RLS dahil) calistirip sureyi olcer ve
-- yonetici (RLS'siz) sureyle karsilastirir. 182'de eklenen sube/yetki politikalarinin
-- sorgulari yavaslatip yavaslatmadigini ve satir sayilarinin dogru olup olmadigini gosterir.
-- Veritabaninda hicbir sey degismez; olcum sonuclari sadece bu oturumluk gecici tabloda tutulur.

begin;

drop table if exists _olcum186;
create temp table _olcum186 (sira int, sorgu text, kim text, satir bigint, sure_ms numeric);

do $$
declare
  t0 timestamptz; n bigint; uid uuid; eposta text;
  sorgular text[] := array[
    'select count(*) from public.receteler where isletme_id is null',
    'select count(*) from public.recete_malzemeleri rm join public.malzemeler m on m.id = rm.malzeme_id',
    'select count(*) from public.malzeme_guncel_fiyat',
    'select count(*) from public.recete_asamalari'
  ];
  i int; kim text; sure numeric;
begin
  select k.id, u.email into uid, eposta
    from public.kullanicilar k join auth.users u on u.id = k.id
   where lower(u.email) = 'bahriguler@gmail.com';

  foreach kim in array array['yonetici', 'bahri'] loop
    for i in 1 .. array_length(sorgular, 1) loop
      if kim = 'bahri' then
        perform set_config('request.jwt.claims',
          jsonb_build_object('sub', uid, 'email', eposta, 'role', 'authenticated')::text, true);
        execute 'set local role authenticated';
      end if;
      t0 := clock_timestamp();
      execute sorgular[i] into n;
      sure := round(extract(epoch from clock_timestamp() - t0)::numeric * 1000, 1);
      execute 'reset role';
      insert into _olcum186 values (i, sorgular[i], kim, n, sure);
    end loop;
  end loop;
end $$;

commit;

select o.sira, o.kim, o.satir, o.sure_ms, o.sorgu,
       (select array_to_string(rolconfig, ', ') from pg_roles where rolname = 'authenticated') as authenticated_ayarlari
from _olcum186 o
order by o.sira, o.kim;
