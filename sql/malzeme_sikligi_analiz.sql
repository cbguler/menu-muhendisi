-- malzeme_sikligi_analiz.sql
--
-- Amac: dograma/dilimleme/rendeleme/soyma icin hangi malzemelerin
-- gercekten en sik gectigini OLCMEK -- tahmin etmek yerine.
--
-- Yontem: hazirlik_talimati metnini SATIRLARA bolup, sadece
-- dograma/dilim/rende/soy fiillerinden biri GECEN satirlari alip,
-- o satirlarda hangi aday malzemelerin kac kez gectigini sayiyor.
-- Boylece "genel olarak sik gecen" degil, "GERCEKTEN bu islemle
-- birlikte kullanilan" malzemeler olculmus oluyor.

with satirlar as (
    select
        r.id as recete_id,
        unnest(regexp_split_to_array(r.hazirlik_talimati, E'\n')) as satir
    from receteler r
    where r.isletme_id is null  -- sadece 241 kutuphane tarifi
      and r.hazirlik_talimati is not null
),
islem_satirlari as (
    select recete_id, lower(satir) as satir_kucuk
    from satirlar
    where satir ilike '%doğra%' or satir ilike '%dilim%'
       or satir ilike '%rende%' or satir ilike '%soy%'
),
adaylar (malzeme) as (
    values
        ('soğan'), ('domates'), ('sarımsak'), ('biber'), ('maydanoz'),
        ('salatalık'), ('limon'), ('peynir'), ('patates'), ('havuç'),
        ('elma'), ('şeftali'), ('armut'), ('portakal'), ('kereviz'),
        ('pırasa'), ('lahana'), ('patlıcan'), ('kabak'), ('nane'),
        ('dereotu'), ('ıspanak'), ('mantar')
)
select
    a.malzeme,
    count(*) filter (where s.satir_kucuk ilike '%' || a.malzeme || '%') as kac_satirda_geciyor,
    count(distinct s.recete_id) filter (where s.satir_kucuk ilike '%' || a.malzeme || '%') as kac_farkli_tarifte
from adaylar a
left join islem_satirlari s on true
group by a.malzeme
order by kac_satirda_geciyor desc;
