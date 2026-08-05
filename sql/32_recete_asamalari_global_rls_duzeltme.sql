-- 32_recete_asamalari_global_rls_duzeltme.sql
--
-- recete_asamalari/asama_malzemeleri/asama_bagimliliklari muhtemelen
-- sadece "kendi isletmenin recetesi" icin RLS izni tasiyor -- global
-- (isletme_id NULL) tariflere ait asamalar hicbir kullaniciya
-- gorunmuyordu (asama_yukle.py service_role ile yazdigi icin RLS'i
-- atlamis, ama normal oturum okurken engelleniyor). Bu, EKLEME nitelikli
-- bir politika -- mevcut "kendi isletmesi" politikasini degistirmiyor,
-- sadece global tarifler icin ayrica herkese acik okuma izni ekliyor.

create policy "herkese acik global tarif asamalarini oku" on recete_asamalari
  for select using (
    exists (
      select 1 from receteler r
      where r.id = recete_asamalari.recete_id and r.isletme_id is null
    )
  );

create policy "herkese acik global tarif asama malzemelerini oku" on asama_malzemeleri
  for select using (
    exists (
      select 1 from recete_asamalari a
      join receteler r on r.id = a.recete_id
      where a.id = asama_malzemeleri.asama_id and r.isletme_id is null
    )
  );

create policy "herkese acik global tarif asama bagimliliklarini oku" on asama_bagimliliklari
  for select using (
    exists (
      select 1 from recete_asamalari a
      join receteler r on r.id = a.recete_id
      where a.id = asama_bagimliliklari.asama_id and r.isletme_id is null
    )
  );
