-- Onceki sorgudaki "fan-out" hatasi duzeltildi: sure_dakika toplami
-- ONCE (asama_malzemeleri'ye hic dokunmadan) alt sorguda hesaplaniyor.
select
    r.ad,
    (select count(*) from recete_asamalari ra2 where ra2.recete_id = r.id) as asama_sayisi,
    (select sum(ra2.sure_dakika) from recete_asamalari ra2 where ra2.recete_id = r.id) as toplam_sure_dakika,
    (select count(*) from asama_malzemeleri am2
       join recete_asamalari ra2 on ra2.id = am2.asama_id
       where ra2.recete_id = r.id) as asama_malzeme_baglantisi
from receteler r
where r.isletme_id is null
  and r.ad in (
    'Fırında Dana But', 'Izgara Kuzu Pirzola', 'Kerevizli Tavuk Sote', 'Etli Kuru Fasulye (Kış)', 'Domates Dolması (Etli)',
    'Sucuklu Yumurta (Tava)', 'Karadeniz Usulü Hamsi Tava', 'Nohutlu Tavuk Güveç', 'Fırında Somon Sebzeli', 'Ispanaklı Kıyma (Tavada)'
  )
order by r.ad;
