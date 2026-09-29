-- 185_teshis_tarif_kalitesi.sql
-- SALT OKUNUR teshis (hicbir sey degistirmez). Emre'nin geri bildirimi (29 Eylul 2026):
-- su eksikligi, porsiyon gramajinin dusuk olmasi, fire orani. Uygulamanin 1000
-- kutuphane tarifinin TAMAMI icin tarif basina bir satir:
--   porsiyon basina cig net gram, SU malzemesi var mi, talimatta su/haslama/kaynatma
--   geciyor mu, fire orani bos olan malzeme sayisi.
-- Sonucu CSV olarak indir (1000 satir).

select
  r.id,
  r.ad,
  r.kategori,
  r.porsiyon_sayisi,
  round(sum(rm.miktar_gram)::numeric, 0)                                           as toplam_net_gram,
  round((sum(rm.miktar_gram) / nullif(r.porsiyon_sayisi, 0))::numeric, 1)          as porsiyon_basi_net_gram,
  bool_or(m.ad ~* '^su( |$|\()')                                                   as su_malzemesi_var,
  coalesce(r.hazirlik_talimati, '') ~* '(\ysu\y|\ysuyu|\ysuyla|haşla|hasla|kaynat|buharda|demle)' as talimatta_su_geciyor,
  count(*) filter (where m.fire_orani is null)                                     as fire_bos_malzeme,
  count(*)                                                                         as malzeme_sayisi
from public.receteler r
join public.recete_malzemeleri rm on rm.recete_id = r.id
join public.malzemeler m on m.id = rm.malzeme_id
where r.isletme_id is null
group by r.id, r.ad, r.kategori, r.porsiyon_sayisi, r.hazirlik_talimati
order by r.ad;
