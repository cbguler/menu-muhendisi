-- 35_iskender_duzelt_ve_fiyat_doldur.sql
--
-- 1) "İskender Kebap" tarifine PİDE (100g, etin altina serilen) ve
--    KORNİŞON TURŞU (20g, servis garnitürü) ekleniyor.
-- 2) 34_...sql'de eklenen 2 yeni malzeme icin mevcut isletmelere
--    geriye donuk fiyat dolduruluyor (13/25/28 ile ayni yontem).

insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
select r.id, m.id, v.miktar_gram
from receteler r
cross join (values
  ('İskender Kebap', 'PİDE', 100),
  ('İskender Kebap', 'KORNİŞON TURŞU', 20)
) as v(recete_adi, malzeme_adi, miktar_gram)
join malzemeler m on m.ad = v.malzeme_adi and m.isletme_id is null
where r.ad = v.recete_adi
  and r.isletme_id is null
  and not exists (
    select 1 from recete_malzemeleri rm
    where rm.recete_id = r.id and rm.malzeme_id = m.id
  );

insert into malzeme_fiyat_gecmisi (isletme_id, malzeme_id, fiyat_eur, tedarikci)
select i.id, m.id, m.varsayilan_fiyat_eur, 'Varsayılan (bölgesel genişletme oturumu)'
from isletmeler i
cross join malzemeler m
where m.ad in ('PİDE', 'KORNİŞON TURŞU')
  and m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id and mfg.malzeme_id = m.id
  );
