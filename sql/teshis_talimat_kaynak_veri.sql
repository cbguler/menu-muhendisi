-- teshis_talimat_kaynak_veri.sql
-- Hazirlik talimati EKSIK olan global tariflerin, talimat yazimi icin
-- gereken TUM kaynak verisi: malzemeler (gram, 1 porsiyon bazli) +
-- mevcut uretim asamalari (sure/aktif/isil islem/hedef sicaklik).
-- Talimatlarin mevcut asama verisiyle TUTARLI yazilmasi icin gerekli.
-- Salt okunur -- hicbir sey degistirmez.
-- Sonucu CSV olarak indirip yukle (Supabase: Results > Export/Download CSV).

with eksik as (
    select id, ad, bolge, porsiyon_sayisi, hazirlik_dakika
    from receteler
    where isletme_id is null
      and (hazirlik_talimati is null or trim(hazirlik_talimati) = '')
)
select
    row_number() over (order by e.ad) as sira_no,
    e.ad,
    e.bolge,
    e.porsiyon_sayisi,
    e.hazirlik_dakika,
    (select string_agg(m.ad || ' ' || rm.miktar_gram || 'g', '; ' order by rm.miktar_gram desc)
       from recete_malzemeleri rm
       join malzemeler m on m.id = rm.malzeme_id
      where rm.recete_id = e.id) as malzemeler,
    (select string_agg(
                a.sira || '. ' || a.ad || ' (' || a.sure_dakika || ' dk, aktif '
                || coalesce(a.aktif_dakika, 0) || ' dk'
                || case when a.isil_islem_mi
                        then ', isil, hedef ' || coalesce(a.hedef_sicaklik::text, '?') || ' C, '
                             || coalesce(a.enerji_kaynagi, '?')
                        else '' end
                || ')',
            ' | ' order by a.sira)
       from recete_asamalari a
      where a.recete_id = e.id) as asamalar
from eksik e
order by e.ad;
