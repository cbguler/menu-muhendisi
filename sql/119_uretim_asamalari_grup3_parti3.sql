-- 119_uretim_asamalari_grup3_parti3.sql
-- Grup 3, 3. (SON) parti (61-88 / 88). DELETE-once korumali.
--
-- Bu grup agirlikli olarak CIG YENEBILEN sebze/meyve + yogurt
-- kombinasyonlari (havuç, roka, marul, tere, turp, semizotu --
-- hepsi standart Turk mutfaginda CIG servis edilir) -- NON-THERMAL.
-- Patates/yeşil mercimek/patlıcan(közleme)/helva/salep gibi GERCEKTEN
-- pisirme gerektirenler THERMAL.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Pastırmalı Kaşar Tabağı (5) -- kurutulmus et+peynir, soguk tabak, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pastırmalı Kaşar Tabağı';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Dilimleme)', 1, 5, 5, false);

    -- 2) Patates Salatası (Yoğurtlu) (30: 10+20) -- patates cig yenmez
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patates Salatası (Yoğurtlu)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 20, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATATES');

    -- 3) Patlıcan Salatası (Közlenmiş) (30: 10+20) -- acik ateste kozleme
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patlıcan Salatası (Közlenmiş)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Közleme', 2, 20, 15, true, 'dogalgaz', 20, 100, 0.45)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATLICAN');

    -- 4) Patlıcan Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Patlıcan Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATLICAN', 'SARIMSAK', 'SİRKE');

    -- 5) Portakal Kompostosu (Ev Usulü) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Portakal Kompostosu (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PORTAKAL', 'ŞEKER');

    -- 6) Portakal ve Limon Kompostosu (20: 6+14)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Portakal ve Limon Kompostosu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 6, 6, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 14, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PORTAKAL', 'LİMON', 'ŞEKER');

    -- 7) Portakallı Havuç Salatası (Bahar) (15) -- cig, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Portakallı Havuç Salatası (Bahar)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 8) Portakallı Mandalinalı Kış Salatası (15) -- cig meyve, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Portakallı Mandalinalı Kış Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 9) Roka Marul Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Roka Marul Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 10) Rokalı Domates Salatası (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Rokalı Domates Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 11) Rokforlu Armut Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Rokforlu Armut Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 12) Salep (Ev Usulü) (20: 6+14) -- sicak sut icecegi
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Salep (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 6, 6, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Süt Pişirme', 2, 14, 10, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SALEP', 'SÜT (TAM YAĞ)', 'ŞEKER');

    -- 13) Semizotlu Yoğurt (15) -- cig semizotu, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Semizotlu Yoğurt';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 14) Tahin Pekmez (Klasik) (5) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Tahin Pekmez (Klasik)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Karıştırma)', 1, 5, 5, false);

    -- 15) Taze Soğanlı Cacık (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Soğanlı Cacık';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 16) Taze Vişne Kompostosu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Taze Vişne Kompostosu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('VİŞNE', 'ŞEKER');

    -- 17) Tereli Yoğurt Salatası (10) -- cig tere, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Tereli Yoğurt Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 18) Turplu Yoğurt Salatası (10) -- cig turp, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Turplu Yoğurt Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 19) Yeşil Mercimekli Salata (25: 8+17) -- kuru baklagil
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yeşil Mercimekli Salata';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YEŞİL MERCİMEK');

    -- 20) Yeşil Salata (Cevizli) (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yeşil Salata (Cevizli)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 21) Yoğurtlu Havuç Salatası (20) -- cig rendelenmis havuc (havuc taratoru), NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yoğurtlu Havuç Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 20, 20, false);

    -- 22) Yulaf Ezmeli Yoğurt (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Yulaf Ezmeli Yoğurt';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 23) Zeytin ve Peynir Tabağı (5) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytin ve Peynir Tabağı';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);

    -- 24) Zeytinyağlı Patates Salatası (25: 8+17) -- patates cig yenmez
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Zeytinyağlı Patates Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 17, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PATATES');

    -- 25) Çilekli Yoğurt (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Çilekli Yoğurt';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 26) Üzümlü Cevizli Yoğurt Salatası (Sonbahar) (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 27) İncirli Yoğurt (Yaz) (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İncirli Yoğurt (Yaz)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 28) İrmik Helvası (Ev Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İrmik Helvası (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 15, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('İRMİK', 'ŞEKER', 'TEREYAĞI', 'SÜT (TAM YAĞ)');

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
where r.isletme_id is null
  and r.ad in (
    'Pastırmalı Kaşar Tabağı', 'Patates Salatası (Yoğurtlu)', 'Patlıcan Salatası (Közlenmiş)', 'Patlıcan Turşusu', 'Portakal Kompostosu (Ev Usulü)',
    'Portakal ve Limon Kompostosu', 'Portakallı Havuç Salatası (Bahar)', 'Portakallı Mandalinalı Kış Salatası', 'Roka Marul Salatası', 'Rokalı Domates Salatası',
    'Rokforlu Armut Salatası', 'Salep (Ev Usulü)', 'Semizotlu Yoğurt', 'Tahin Pekmez (Klasik)', 'Taze Soğanlı Cacık',
    'Taze Vişne Kompostosu', 'Tereli Yoğurt Salatası', 'Turplu Yoğurt Salatası', 'Yeşil Mercimekli Salata', 'Yeşil Salata (Cevizli)',
    'Yoğurtlu Havuç Salatası', 'Yulaf Ezmeli Yoğurt', 'Zeytin ve Peynir Tabağı', 'Zeytinyağlı Patates Salatası', 'Çilekli Yoğurt',
    'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)', 'İncirli Yoğurt (Yaz)', 'İrmik Helvası (Ev Usulü)'
  )
order by r.ad;

-- GRUP 3 GENEL SAYIM
select
    (select count(distinct r.id) from receteler r join mutfak_kategorileri mk on mk.id=r.mutfak_kategori_id
     join recete_asamalari ra on ra.recete_id=r.id where r.isletme_id is null and mk.sira=3) as grup3_asamasi_olan,
    (select count(*) from receteler r join mutfak_kategorileri mk on mk.id=r.mutfak_kategori_id
     where r.isletme_id is null and mk.sira=3) as grup3_toplam;
