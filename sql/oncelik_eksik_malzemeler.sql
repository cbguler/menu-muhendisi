-- Onceliklendirme sorgusu: HANGI malzemeler EN COK tarifte kullaniliyor
-- AMA en cok genisletilmis besin ogesi (vitamin/mineral) eksik?
-- Bunlari once doldurmak, en fazla sayida gunun/ogunun "veri yok"
-- notundan kurtulmasini saglar (en yuksek etki/emek orani).

select
  m.ad as malzeme_adi,
  count(distinct rm.recete_id) as kac_tarifte_kullaniliyor,
  m.vitamin_c_mg, m.kalsiyum_mg, m.demir_mg, m.vitamin_a_mcg, m.potasyum_mg,
  m.vitamin_b1_mg, m.vitamin_b3_mg, m.magnezyum_mg, m.fosfor_mg, m.cinko_mg
from malzemeler m
join recete_malzemeleri rm on rm.malzeme_id = m.id
where m.isletme_id is null
group by m.id, m.ad, m.vitamin_c_mg, m.kalsiyum_mg, m.demir_mg, m.vitamin_a_mcg,
  m.potasyum_mg, m.vitamin_b1_mg, m.vitamin_b3_mg, m.magnezyum_mg, m.fosfor_mg, m.cinko_mg
having count(distinct rm.recete_id) >= 5  -- en az 5 tarifte gecenler (yaygin kullanilanlar)
  and (m.vitamin_c_mg is null or m.kalsiyum_mg is null or m.demir_mg is null
       or m.vitamin_a_mcg is null or m.potasyum_mg is null)
order by kac_tarifte_kullaniliyor desc
limit 40;
