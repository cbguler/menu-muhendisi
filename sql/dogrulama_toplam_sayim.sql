-- Dogrulama sorgusu: veritabanindaki toplam malzeme sayisini kontrol eder.
-- Excel'deki guncel sayi ile karsilastirilmak icin.

select count(*) as toplam_malzeme
from malzemeler
where isletme_id is null;

-- Eger sayilar tutmuyorsa, hangi migration'larin eksik kaldigini
-- bulmak icin asagidaki sorgu son eklenen birkac malzemenin
-- veritabaninda olup olmadigini gosterir:
select ad
from malzemeler
where isletme_id is null
  and ad in (
    'KALDIRIK', 'KALDIRIK (KURUTULMUŞ, TRACHYSTEMON)', 'KEÇİ SÜTÜ',
    'MANDA SÜTÜ', 'ŞEVKETİ BOSTAN KÖK UNU', 'GİLABURU',
    'KARAYEMİŞ (KURUTULMUŞ)', 'GİLABURU (KURUTULMUŞ)'
  )
order by ad;
