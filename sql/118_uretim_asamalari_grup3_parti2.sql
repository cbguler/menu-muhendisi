-- 118_uretim_asamalari_grup3_parti2.sql
-- Grup 3, 2. parti (31-60 / 88). TUM insert'lerden ONCE artik
-- `delete from recete_asamalari where recete_id = v_recete_id;`
-- var (114'teki 3x-calisma sorununun bir daha olmamasi icin).
--
-- Bahri'nin YENI kuralina uygun: HICBIR yerde on-pismis/hazir malzeme
-- varsayilmadi. Kereviz, pancar, kuskonmaz gibi normalde CIG YENMEYEN
-- sebzeler THERMAL isaretlendi (Zeytinyağlı Kereviz/Pancar gibi
-- kardesleriyle tutarli). Kisir/Mercimek Koftesi'nde bulgurun sicak
-- suyla/salcayla haslanmasi/islatilmasi da gercek bir isil islem
-- olarak sayildi. Havuc/lahana/ispanak gibi CIG YENEBILEN sebzeler
-- (zaten Turk mutfaginda standart cig salata malzemesi) NON-THERMAL
-- birakildi -- bu "on-pismis varsayimi" degil, gercekten cig servis
-- edilen bir yemek turu.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Karışık Turşu (Ev Usulü, Sirkeli) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karışık Turşu (Ev Usulü, Sirkeli)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('LAHANA', 'HAVUÇ', 'SALATALIK', 'SARIMSAK', 'SİRKE');

    -- 2) Kayısı Kompostosu (Ev Usulü) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kayısı Kompostosu (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KURU KAYISI', 'ŞEKER');

    -- 3) Kayısılı Yoğurt (10) -- taze kayisi, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kayısılı Yoğurt';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 4) Kefirli Salatalık (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kefirli Salatalık';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 5) Kerevizli Yoğurt Salatası (15: 5+10) -- kereviz cig yenmez
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Yoğurt Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 10, 3, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KEREVİZ');

    -- 6) Keçi Peynirli Pancar Salatası (25: 8+17) -- pancar cig yenmez
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Keçi Peynirli Pancar Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 17, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PANCAR');

    -- 7) Keşkül (Ev Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Keşkül (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 12, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SÜT (TAM YAĞ)', 'ŞEKER', 'MISIR NİŞASTASI');

    -- 8) Kuru Fasulye Piyazı (Ev Usulü) (20: 5+15) -- kuru baklagil
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuru Fasulye Piyazı (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 15, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KURU FASULYE');

    -- 9) Kuru Kayısılı Kış Kompostosu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuru Kayısılı Kış Kompostosu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 20, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KURU KAYISI', 'KURU ÜZÜM', 'ŞEKER');

    -- 10) Kuru Üzümlü Komposto (20: 6+14)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuru Üzümlü Komposto';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 6, 6, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 14, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KURU ÜZÜM', 'ŞEKER');

    -- 11) Kuşkonmaz Salatası (20: 12+8) -- kuskonmaz cig yenmez (fibroz)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kuşkonmaz Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 8, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUŞKONMAZ');

    -- 12) Kırmızı Biber Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kırmızı Biber Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KIRMIZI BİBER', 'SARIMSAK', 'SİRKE');

    -- 13) Kızılcık Kompostosu (20: 6+14)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kızılcık Kompostosu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 6, 6, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 14, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KIZILCIK', 'ŞEKER');

    -- 14) Kış Lahana Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kış Lahana Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('LAHANA', 'HAVUÇ', 'SARIMSAK', 'SİRKE');

    -- 15) Lahana Salatası (15) -- cig lahana, standart, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Lahana Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 16) Limonlu Zeytinyağlı Havuç Salatası (15) -- cig rendelenmis havuc, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Limonlu Zeytinyağlı Havuç Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 17) Mandalina Kompostosu (20: 6+14)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mandalina Kompostosu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 6, 6, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 14, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('MANDALİNA', 'ŞEKER');

    -- 18) Maydanozlu Bulgur Salatası (Kısır) (25: 15+10) -- bulgur sicak suyla haslanir
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Maydanozlu Bulgur Salatası (Kısır)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Bulgur Haşlama', 2, 10, 5, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('İNCE BULGUR', 'DOMATES');

    -- 19) Mercimek Köftesi (Ev Usulü) (40: 15+25) -- mercimek+bulgur haslanir
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mercimek Köftesi (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 25, 8, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KIRMIZI MERCİMEK', 'İNCE BULGUR');

    -- 20) Mevsim Yeşillik Salatası (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mevsim Yeşillik Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 21) Muhallebi (Ev Usulü) (30: 8+22)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Muhallebi (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 22, 15, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SÜT (TAM YAĞ)', 'ŞEKER', 'PİRİNÇ UNU');

    -- 22) Muzlu Meyve Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Muzlu Meyve Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 23) Muzlu Yoğurt (Ev Usulü) (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Muzlu Yoğurt (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 24) Mısırlı Salata (15) -- konserve misir (kutu urun, kendi dogasi geregi pismis)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Mısırlı Salata';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 25) Naneli Cacık (Klasik) (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Naneli Cacık (Klasik)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 26) Naneli Yoğurt (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Naneli Yoğurt';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);

    -- 27) Nar Ekşili Kısır (30: 18+12) -- bulgur sicak salcayla haslanir
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nar Ekşili Kısır';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 18, 18, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Bulgur Haşlama', 2, 12, 6, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('İNCE BULGUR', 'KONSERVE DOMATES SALÇASI');

    -- 28) Narlı Ispanak Salatası (15) -- cig ispanak, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Narlı Ispanak Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 29) Nohut Ezmesi (Ev Usulü) (20: 5+15) -- kuru baklagil
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohut Ezmesi (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 5, 5, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 15, 5, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('NOHUT');

    -- 30) Pancar Salatası (Yoğurtlu) (25: 8+17) -- pancar cig yenmez
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Pancar Salatası (Yoğurtlu)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 17, 5, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('PANCAR');

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
    'Karışık Turşu (Ev Usulü, Sirkeli)', 'Kayısı Kompostosu (Ev Usulü)', 'Kayısılı Yoğurt', 'Kefirli Salatalık', 'Kerevizli Yoğurt Salatası',
    'Keçi Peynirli Pancar Salatası', 'Keşkül (Ev Usulü)', 'Kuru Fasulye Piyazı (Ev Usulü)', 'Kuru Kayısılı Kış Kompostosu', 'Kuru Üzümlü Komposto',
    'Kuşkonmaz Salatası', 'Kırmızı Biber Turşusu', 'Kızılcık Kompostosu', 'Kış Lahana Turşusu', 'Lahana Salatası',
    'Limonlu Zeytinyağlı Havuç Salatası', 'Mandalina Kompostosu', 'Maydanozlu Bulgur Salatası (Kısır)', 'Mercimek Köftesi (Ev Usulü)', 'Mevsim Yeşillik Salatası',
    'Muhallebi (Ev Usulü)', 'Muzlu Meyve Salatası', 'Muzlu Yoğurt (Ev Usulü)', 'Mısırlı Salata', 'Naneli Cacık (Klasik)',
    'Naneli Yoğurt', 'Nar Ekşili Kısır', 'Narlı Ispanak Salatası', 'Nohut Ezmesi (Ev Usulü)', 'Pancar Salatası (Yoğurtlu)'
  )
order by r.ad;
