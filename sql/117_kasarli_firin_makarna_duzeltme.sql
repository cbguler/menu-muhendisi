-- 117_kasarli_firin_makarna_duzeltme.sql
--
-- SORUN: 110'da "Kaşarlı Fırın Makarna" icin "Hazırlık (Haşlama+
-- Karıştırma)" asamasi ISIL ISLEM OLARAK ISARETLENMEMISTI -- ama
-- makarna haslamak GERCEK bir isil islem (kaynar suda pisirme).
-- Bu, "on-pismis malzeme" varsayimiyla ayni turden bir hata --
-- makarnanin haslanma enerjisi hesaba katilmiyordu.
--
-- DUZELTME: 3 ayri asamaya bolundu -- gercek Hazirlik (peynir rendeleme,
-- 5dk, isil islem yok) + Haslama (makarna, 10dk, 100C) + Firinlama
-- (makarna+kasar+tereyagi, 25dk, 90C). Toplam 40dk (5+10+25) -- tarifin
-- kendi hazirlik_dakika alaniyla AYNI kaliyor, degistirmeye gerek yok.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kaşarlı Fırın Makarna';
    delete from recete_asamalari where recete_id = v_recete_id;

    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Rendeleme)', 1, 5, 5, false);

    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 10, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA');

    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 3, 25, 5, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MAKARNA', 'KAŞAR PEYNİRİ', 'TEREYAĞI');

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
where r.isletme_id is null and r.ad = 'Kaşarlı Fırın Makarna';
