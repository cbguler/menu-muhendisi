select ra.ad, ra.sira, ra.sure_dakika, ra.aktif_dakika, ra.isil_islem_mi,
       ra.enerji_kaynagi, ra.baslangic_sicaklik, ra.hedef_sicaklik,
       ra.verimlilik_orani
from recete_asamalari ra
join receteler r on r.id = ra.recete_id
where r.ad = 'İskender Kebap'
  and r.isletme_id is null
order by ra.sira;
