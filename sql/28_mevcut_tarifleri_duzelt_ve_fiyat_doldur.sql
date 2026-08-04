-- 28_mevcut_tarifleri_duzelt_ve_fiyat_doldur.sql
--
-- 1) Kullanicinin bulduğu gercek eksiklik: "Zeytinyağlı Yaprak Sarma"
--    cam fistigi/kus uzumu icermiyordu (sadece pirinc/sogan/zeytinyagi),
--    "Aşure" kuru incir icermiyordu. Bu klasik tariflerde bu malzemeler
--    vazgecilmez -- eksik oldugu icin eklenemiyorlardi, simdi ekleniyor.
--
-- 2) 27_...sql'de eklenen 3 yeni malzeme (CAM FISTIGI, KUS UZUMU,
--    KURU INCIR) icin, 13/25 numarali migration'larla ayni yontemle,
--    mevcut isletmelere geriye donuk fiyat dolduruluyor.

insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
select r.id, m.id, v.miktar_gram
from receteler r
cross join (values
  ('Zeytinyağlı Yaprak Sarma', 'ÇAM FISTIĞI', 15),
  ('Zeytinyağlı Yaprak Sarma', 'KUŞ ÜZÜMÜ', 10),
  ('Aşure', 'KURU İNCİR', 20)
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
where m.ad in ('ÇAM FISTIĞI', 'KUŞ ÜZÜMÜ', 'KURU İNCİR')
  and m.isletme_id is null
  and m.varsayilan_fiyat_eur is not null
  and not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.isletme_id = i.id and mfg.malzeme_id = m.id
  );
