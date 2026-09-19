-- Teshis sorgusu: 3 tarifin GERCEK malzeme+fiyat dokumunu, herhangi
-- bir Streamlit onbellegi (cache) araya girmeden dogrudan veritabanindan
-- gosterir. Ayni tarif ADININ birden fazla kayitta (ör. hem genel hem
-- isletmeye ozel) olup olmadigini da kontrol eder.

-- 1) Bu 3 tarif adindan kac KAYIT var? (ayni isimde birden fazla
-- tarif olup olmadigini kontrol eder -- eger >1 ciktiysa, ISTE SORUN
-- BU: iki sayfa farkli kayitlara bakiyor olabilir)
select id, ad, isletme_id, bolge, mevsim_etiketi
from receteler
where ad in ('Kayısılı Kuzu Tandır', 'Ezo Gelin Çorbası', 'Kayısı Tatlısı (Cevizli)')
order by ad, id;

-- 2) Her tarifin GERCEK malzeme dokumu ve porsiyon-basi (1x) maliyeti
-- (yukaridaki sorgudan gelen HER id icin ayri ayri calisir):
select
  r.ad as tarif_adi,
  r.id as tarif_id,
  m.ad as malzeme_adi,
  rm.miktar_gram,
  f.fiyat_eur as birim_fiyat_eur_kg,
  round((rm.miktar_gram / 1000.0 * f.fiyat_eur)::numeric, 4) as bu_malzemenin_maliyeti_eur,
  case when f.fiyat_eur is null then 'FIYAT YOK' else '' end as uyari
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
left join malzeme_guncel_fiyat f on f.malzeme_id = m.id
  and f.isletme_id = (select id from isletmeler limit 1) -- KENDI isletme_id'nizle degistirin gerekirse
where r.ad in ('Kayısılı Kuzu Tandır', 'Ezo Gelin Çorbası', 'Kayısı Tatlısı (Cevizli)')
order by r.ad, rm.miktar_gram desc;

-- 3) Her tarifin TOPLAM (1x porsiyon) maliyeti -- bu, hem Yillik Menu
-- hem Tarif Kutuphanesi'nin AYNI formulle hesaplamasi gereken sayi:
select
  r.ad as tarif_adi,
  r.id as tarif_id,
  round(sum(rm.miktar_gram / 1000.0 * f.fiyat_eur)::numeric, 4) as toplam_1x_porsiyon_maliyeti_eur,
  count(*) filter (where f.fiyat_eur is null) as fiyati_eksik_malzeme_sayisi
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
left join malzeme_guncel_fiyat f on f.malzeme_id = m.id
  and f.isletme_id = (select id from isletmeler limit 1)
where r.ad in ('Kayısılı Kuzu Tandır', 'Ezo Gelin Çorbası', 'Kayısı Tatlısı (Cevizli)')
group by r.ad, r.id
order by r.ad;
