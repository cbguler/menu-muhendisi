-- 166_teshis_fiyatsiz_malzeme_kullanim_sayisi.sql
-- AMAC: Fiyati NULL olan 215 malzemeden hangileri GERCEKTEN
-- tariflerde kullaniliyor, kac tarifte kullaniliyor? Bu, hangi
-- malzemelerin fiyatini once arastirmamiz gerektigini (etki
-- buyuklugune gore) belirleyecek. SADECE OKUMA yapar.

select
    m.ad,
    count(distinct rm.recete_id) as kac_tarifte_kullaniliyor
from malzemeler m
join recete_malzemeleri rm on rm.malzeme_id = m.id
where m.varsayilan_fiyat_eur is null
group by m.ad
order by kac_tarifte_kullaniliyor desc;
