-- teshis_uretim_asamasi_eksik.sql
--
-- AMAC: recete_asamalari tablosunda HIC kaydi olmayan (yani "Bu tarif
-- icin uretim asamasi verisi henuz eklenmedi" mesajini gosterecek)
-- GLOBAL (isletme_id NULL) tariflerin TAM LISTESINI cikarmak -- hangi
-- tariflerin doldurulmasi gerektigini gormek icin.

select
    mk.sira as grup,
    r.ad,
    r.mevsim_etiketi,
    r.bolge
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_asamalari ra on ra.recete_id = r.id
where r.isletme_id is null
  and ra.id is null
order by mk.sira, r.ad;

-- OZET: grup basina kac tarif eksik
select mk.sira as grup, count(*) as eksik_tarif_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
left join recete_asamalari ra on ra.recete_id = r.id
where r.isletme_id is null
  and ra.id is null
group by mk.sira
order by mk.sira;

-- Genel toplam (kac tarifin VAR, kac tarifin YOK oldugunu karsilastirmak icin)
select
    count(distinct r.id) filter (where ra.id is not null) as asamasi_olan,
    count(distinct r.id) filter (where ra.id is null) as asamasi_olmayan,
    count(distinct r.id) as toplam
from receteler r
left join recete_asamalari ra on ra.recete_id = r.id
where r.isletme_id is null;
