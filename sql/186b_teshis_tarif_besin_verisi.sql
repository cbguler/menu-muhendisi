-- 186b_teshis_tarif_besin_verisi.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez). Aylik Menu uretim motorunun kullandigi
-- 1000 kutuphane tarifinin besin degerlerini, uygulamadaki formulle AYNI sekilde
-- (pages/0_Yillik_Menu.py _tarif_detaylarini_getir) hesaplayip tek tabloda verir.
-- Amac: menu motorunu gercek veriyle Claude'un ortaminda calistirip hangi hedeflerin
-- tutturulabildigini ve surenin neden uzadigini olcmek. Sonucu CSV olarak indir.

with turk_kategori as (
  select k.id, k.sira
  from public.mutfak_kategorileri k
  join public.mutfaklar mu on mu.id = k.mutfak_id and mu.kod = 'turk'
)
select
  r.ad,
  tk.sira as grup,
  coalesce(r.mevsim_etiketi, 'yil_boyunca') as mevsim_etiketi,
  array_to_string(coalesce(r.ozel_etiketler, '{}'), '|') as etiketler,
  coalesce(r.bolge, 'Genel') as bolge,
  sum(coalesce(m.kalori, 0) * rm.miktar_gram / 100.0) as kalori,
  sum(coalesce(m.protein, 0) * rm.miktar_gram / 100.0) as protein,
  sum(coalesce(m.yag, 0) * rm.miktar_gram / 100.0) as yag,
  sum(coalesce(m.karbonhidrat, 0) * rm.miktar_gram / 100.0) as karbonhidrat,
  sum(m.glisemik_indeks * coalesce(m.karbonhidrat, 0) * rm.miktar_gram / 100.0)
      filter (where m.glisemik_indeks is not null and coalesce(m.karbonhidrat, 0) * rm.miktar_gram > 0)
    / nullif(sum(coalesce(m.karbonhidrat, 0) * rm.miktar_gram / 100.0)
      filter (where m.glisemik_indeks is not null and coalesce(m.karbonhidrat, 0) * rm.miktar_gram > 0), 0) as gi,
  sum(m.sodyum_mg * rm.miktar_gram / 100.0) as sodyum_mg,
  sum(m.lif_g * rm.miktar_gram / 100.0) as lif_g,
  sum(m.seker_g * rm.miktar_gram / 100.0) as seker_g,
  sum(m.doymus_yag_g * rm.miktar_gram / 100.0) as doymus_yag_g,
  sum(m.vitamin_a_mcg * rm.miktar_gram / 100.0) as vitamin_a_mcg,
  sum(m.vitamin_b1_mg * rm.miktar_gram / 100.0) as vitamin_b1_mg,
  sum(m.vitamin_b2_mg * rm.miktar_gram / 100.0) as vitamin_b2_mg,
  sum(m.vitamin_b3_mg * rm.miktar_gram / 100.0) as vitamin_b3_mg,
  sum(m.vitamin_b5_mg * rm.miktar_gram / 100.0) as vitamin_b5_mg,
  sum(m.vitamin_b6_mg * rm.miktar_gram / 100.0) as vitamin_b6_mg,
  sum(m.vitamin_b7_mcg * rm.miktar_gram / 100.0) as vitamin_b7_mcg,
  sum(m.vitamin_b9_mcg * rm.miktar_gram / 100.0) as vitamin_b9_mcg,
  sum(m.vitamin_b12_mcg * rm.miktar_gram / 100.0) as vitamin_b12_mcg,
  sum(m.vitamin_c_mg * rm.miktar_gram / 100.0) as vitamin_c_mg,
  sum(m.vitamin_d_mcg * rm.miktar_gram / 100.0) as vitamin_d_mcg,
  sum(m.vitamin_e_mg * rm.miktar_gram / 100.0) as vitamin_e_mg,
  sum(m.vitamin_k_mcg * rm.miktar_gram / 100.0) as vitamin_k_mcg,
  sum(m.kalsiyum_mg * rm.miktar_gram / 100.0) as kalsiyum_mg,
  sum(m.demir_mg * rm.miktar_gram / 100.0) as demir_mg,
  sum(m.magnezyum_mg * rm.miktar_gram / 100.0) as magnezyum_mg,
  sum(m.potasyum_mg * rm.miktar_gram / 100.0) as potasyum_mg,
  sum(m.cinko_mg * rm.miktar_gram / 100.0) as cinko_mg,
  sum(m.fosfor_mg * rm.miktar_gram / 100.0) as fosfor_mg,
  sum(m.bakir_mg * rm.miktar_gram / 100.0) as bakir_mg,
  sum(m.manganez_mg * rm.miktar_gram / 100.0) as manganez_mg,
  sum(m.selenyum_mcg * rm.miktar_gram / 100.0) as selenyum_mcg,
  sum(m.iyot_mcg * rm.miktar_gram / 100.0) as iyot_mcg
from public.receteler r
join turk_kategori tk on tk.id = r.mutfak_kategori_id
join public.recete_malzemeleri rm on rm.recete_id = r.id
join public.malzemeler m on m.id = rm.malzeme_id
where r.isletme_id is null
group by r.id, r.ad, tk.sira, r.mevsim_etiketi, r.ozel_etiketler, r.bolge
order by r.ad;
