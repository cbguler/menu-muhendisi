-- Basitlestirilmis teshis -- isletme_id tahmini kaldirildi, Turkce
-- "i/İ" karakter bozulmasi riskini onlemek icin ozel karaktersiz
-- kelime parcalari kullanildi (Kuzu, Ezo, Cevizli).

-- SORU 1 (EN ONEMLISI): Bu 3 tarif adindan HERHANGI BIRI birden fazla
-- KAYIT olarak mi duruyor? (id sutununa bak -- ayni ad icin 2+ farkli
-- id ciktiysa, ISTE SORUN BU: iki sayfa farkli kayitlara bakiyor.)
select id, ad, isletme_id, bolge, mevsim_etiketi
from receteler
where ad like '%Kuzu%' or ad like 'Ezo%' or ad like '%Cevizli%';

-- SORU 2: Kac tane isletme kaydi var? (birden fazlaysa, hangi
-- fiyatin kullanildigi onemli olur)
select id, ad from isletmeler;

-- SORU 3: Her tarifin TUM fiyat kayitlariyla (hangi isletme_id'ye ait
-- olursa olsun) birlikte GERCEK 1x porsiyon maliyeti -- isletme_id
-- FILTRESI OLMADAN (yanlis tahmin riskini ortadan kaldirmak icin):
select
  r.ad as tarif_adi,
  r.id as tarif_id,
  f.isletme_id as fiyatin_ait_oldugu_isletme,
  round(sum(rm.miktar_gram / 1000.0 * f.fiyat_eur)::numeric, 4) as toplam_1x_porsiyon_maliyeti_eur,
  count(*) filter (where f.fiyat_eur is null) as fiyati_eksik_malzeme_sayisi
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
left join malzeme_guncel_fiyat f on f.malzeme_id = m.id
where r.ad like '%Kuzu%' or r.ad like 'Ezo%' or r.ad like '%Cevizli%'
group by r.ad, r.id, f.isletme_id
order by r.ad;
