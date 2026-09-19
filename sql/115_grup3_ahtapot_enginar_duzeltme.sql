-- 115_grup3_ahtapot_enginar_duzeltme.sql
--
-- DUZELTME: 114'te Ahtapot Salatası (Soğuk), Enginar Salatası,
-- Enginarlı Yoğurt "on-pismis/hazir malzeme" varsayimiyla NON-THERMAL
-- isaretlenmisti. Bahri bunu ONAYLAMADI -- gercekten CIGDEN pisirilen
-- (dondurularak yumusatilmis ahtapot, cig enginar haslamasi) tarifler.
--
-- Gercekci haslama sureleri kayitli hazirlik_dakika'dan (15-20dk)
-- UZUN oldugu icin, TUTARLILIK icin receteler.hazirlik_dakika alani
-- da guncellendi (Bahri'nin onayina acikca sunularak).
--
-- Once eski (114'teki) tek-asamali kayitlar silinir (varsa), sonra
-- dogru 2 asamali (Hazirlik+Haslama) veri eklenir.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Ahtapot Salatası (Soğuk): 20 -> 40 dk (10+30, dondurulmus
    -- ahtapotun orta atesle yumusatilmasi -- tam kaynama degil, 85C)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ahtapot Salatası (Soğuk)';
    delete from recete_asamalari where recete_id = v_recete_id;
    update receteler set hazirlik_dakika = 40 where id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Temizleme)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 30, 8, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('AHTAPOT');

    -- 2) Enginar Salatası: 15 -> 30 dk (10+20, tam haslama, 100C)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    update receteler set hazirlik_dakika = 30 where id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Temizleme)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ENGİNAR');

    -- 3) Enginarlı Yoğurt: 20 -> 30 dk (10+20, tam haslama, 100C)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginarlı Yoğurt';
    delete from recete_asamalari where recete_id = v_recete_id;
    update receteler set hazirlik_dakika = 30 where id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Temizleme)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ENGİNAR');

end $$;

-- DOGRULAMA
select
    r.ad,
    r.hazirlik_dakika as tarif_hazirlik_dakika,
    (select count(*) from recete_asamalari ra2 where ra2.recete_id = r.id) as asama_sayisi,
    (select sum(ra2.sure_dakika) from recete_asamalari ra2 where ra2.recete_id = r.id) as toplam_asama_suresi,
    (select count(*) from asama_malzemeleri am2
       join recete_asamalari ra2 on ra2.id = am2.asama_id
       where ra2.recete_id = r.id) as asama_malzeme_baglantisi
from receteler r
where r.isletme_id is null
  and r.ad in ('Ahtapot Salatası (Soğuk)', 'Enginar Salatası', 'Enginarlı Yoğurt')
order by r.ad;
