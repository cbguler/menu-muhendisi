-- 169d: Referans "Mısır Ekmeği" tarifinin TAM asama detaylari
-- (verimlilik_orani, enerji_kaynagi, sicakliklar) -- Giresun/Rize
-- icin ayni fiziksel islemde AYNI degerleri kullanmak icin.
select ra.ad, ra.sira, ra.sure_dakika, ra.aktif_dakika, ra.isil_islem_mi,
       ra.enerji_kaynagi, ra.baslangic_sicaklik, ra.hedef_sicaklik,
       ra.verimlilik_orani
from recete_asamalari ra
join receteler r on r.id = ra.recete_id
where r.ad = 'Mısır Ekmeği'
  and r.isletme_id is null
order by ra.sira;

-- Ayni referans tarifte, o asamaya hangi malzemelerin baglandigini
-- da gorelim (asama_malzemeleri -> recete_malzemeleri -> malzemeler)
select ra.ad as asama_adi, m.ad as malzeme_adi
from recete_asamalari ra
join asama_malzemeleri am on am.asama_id = ra.id
join recete_malzemeleri rm on rm.id = am.recete_malzeme_id
join malzemeler m on m.id = rm.malzeme_id
join receteler r on r.id = ra.recete_id
where r.ad = 'Mısır Ekmeği'
  and r.isletme_id is null
order by ra.sira;
