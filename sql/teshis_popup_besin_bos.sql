-- Teshis sorgusu: bir tarifin malzemelerinin genisletilmis besin
-- ogelerine (vitamin/mineral) dair GERCEKTEN veri olup olmadigini
-- kontrol eder. TARIF_ADI yerine popup'in on yuzunde gordugun
-- yemeklerden birini yaz (ornek: 'Mercimek Çorbası').

select
  r.ad as tarif_adi,
  m.ad as malzeme_adi,
  rm.miktar_gram,
  m.vitamin_c_mg,
  m.kalsiyum_mg,
  m.demir_mg,
  m.vitamin_a_mcg,
  m.potasyum_mg
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad = 'TARIF_ADI'
order by m.ad;

-- Ayrica: KAC malzemenin vitamin_c_mg (ya da herhangi bir genisletilmis
-- alan) icin GERCEKTEN NULL oldugunu genel olarak kontrol edelim --
-- eger cogu malzeme NULL ise, bu VERI eksikligi (uydurulmamis, gercek
-- bir bosluk), kod hatasi degil:
select
  count(*) as toplam_malzeme,
  count(vitamin_c_mg) as vitc_dolu,
  count(kalsiyum_mg) as kalsiyum_dolu,
  count(demir_mg) as demir_dolu
from malzemeler
where isletme_id is null;
