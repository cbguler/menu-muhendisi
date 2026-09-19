-- 113_uretim_asamalari_grup2_ic_pilav.sql
-- Grup 2'nin SON eksik tarifi. Malzemeler PROJE_NOTLARI'ndaki 3 Agustos
-- (VII. Oturum) olusturma kaydindan alindi (ek_tarifler.py/tarif_verisi.py
-- ile eklenmisti, bu zip'te SQL kaynagi yok). hazirlik_dakika Bahri
-- tarafindan dogrudan sorgulanip dogrulandi (35).

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İç Pilav';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PİRİNÇ (HAM)', 'ÇAM FISTIĞI', 'KUŞ ÜZÜMÜ', 'KURU SOĞAN', 'TEREYAĞI', 'YENİBAHAR');

end $$;

-- DOGRULAMA
select
    r.ad,
    (select count(*) from recete_asamalari ra2 where ra2.recete_id = r.id) as asama_sayisi,
    (select sum(ra2.sure_dakika) from recete_asamalari ra2 where ra2.recete_id = r.id) as toplam_sure_dakika,
    (select count(*) from asama_malzemeleri am2
       join recete_asamalari ra2 on ra2.id = am2.asama_id
       where ra2.recete_id = r.id) as asama_malzeme_baglantisi
from receteler r
where r.isletme_id is null and r.ad = 'İç Pilav';

-- GRUP 2 GENEL SAYIM (84/84 olmali)
select
    (select count(distinct r.id) from receteler r join mutfak_kategorileri mk on mk.id=r.mutfak_kategori_id
     join recete_asamalari ra on ra.recete_id=r.id where r.isletme_id is null and mk.sira=2) as grup2_asamasi_olan,
    (select count(*) from receteler r join mutfak_kategorileri mk on mk.id=r.mutfak_kategori_id
     where r.isletme_id is null and mk.sira=2) as grup2_toplam;
