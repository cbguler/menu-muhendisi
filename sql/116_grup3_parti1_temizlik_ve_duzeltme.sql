-- 116_grup3_parti1_temizlik_ve_duzeltme.sql
--
-- SORUN: 114 dosyasi muhtemelen 3 kez calistirildi -- TUM 30 tarifte
-- asama_sayisi ve toplam_sure_dakika TAM 3 KATI cikti (dogrulama
-- sonucundan tespit edildi). Insert'lerde tekrar-calistirmaya karsi
-- koruma (DELETE-once ilkesi) yoktu.
--
-- BU DOSYA: Ahtapot/Enginar Salatası/Enginarlı Yoğurt HARIC (o 3'u
-- 115'te zaten DELETE+INSERT ile temizlenip dogru hale getirildi)
-- kalan 27 tarif icin: ONCE mevcut (kirli/3x) recete_asamalari
-- silinir (cascade asama_malzemeleri), SONRA temiz veri TEK SEFER
-- eklenir.
--
-- AYRICA: Bahri'nin talimatiyla artik HICBIR tarifte "on-pismis/hazir
-- malzeme" varsayimi yapilmiyor -- bu dosyada zaten sadece Ahtapot/
-- Enginar konusuydu (114'te digerleri zaten sifirdan pisirme
-- varsayimiyla yazilmisti), yeni bir degisiklik gerekmedi.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Armutlu Cevizli Salata (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Armutlu Cevizli Salata';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 2) Ayran (Ev Usulü) (10) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayran (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Çırpma)', 1, 10, 10, false);

    -- 3) Ayva Tatlısı (Kış) (45: 15+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayva Tatlısı (Kış)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Soyma)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Şerbette Pişirme', 2, 30, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('AYVA', 'ŞEKER');

    -- 4) Badem Ezmesi Tabağı (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Badem Ezmesi Tabağı';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 5) Bahar Cacığı (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bahar Cacığı';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 6) Barbunya Turşusu (Bahar) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Barbunya Turşusu (Bahar)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BARBUNYA', 'SARIMSAK', 'SİRKE');

    -- 7) Bezelyeli Yoğurt Salatası (15: 8+7)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Yoğurt Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 7, 7, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BEZELYE');

    -- 8) Cevizli Kırmızı Lahana Salatası (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Cevizli Kırmızı Lahana Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 9) Cevizli Pekmez (5) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Cevizli Pekmez';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Karıştırma)', 1, 5, 5, false);

    -- 10) Domates Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domates Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DOMATES', 'SARIMSAK', 'SİRKE');

    -- 11) Domatesli Cacık (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Cacık';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 12) Ekmek Kadayıfı (Kaymaklı) (40: 10+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ekmek Kadayıfı (Kaymaklı)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Şerbet Pişirme', 2, 30, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('EKMEK KADAYIFI', 'ŞEKER');

    -- 13) Elma Kompostosu (Ev Usulü) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Elma Kompostosu (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Soyma)', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ELMA', 'ŞEKER');

    -- 14) Elmalı Cevizli Bahar Salatası (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Elmalı Cevizli Bahar Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 15) Greyfurtlu Roka Salatası (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Greyfurtlu Roka Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 16) Güllaç (Ev Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Güllaç (Ev Usulü)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Süt Isıtma', 2, 20, 10, true, 'dogalgaz', 20, 80, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('GÜLLAÇ', 'SÜT (TAM YAĞ)', 'ŞEKER');

    -- 17) Havuç Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HAVUÇ', 'SARIMSAK', 'SİRKE');

    -- 18) Haşlanmış Yumurta Salatası (15: 3+12)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Haşlanmış Yumurta Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 3, 3, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 12, 3, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK YUMURTASI');

    -- 19) Hurma ve Süt Tatlısı (30: 8+22)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Hurma ve Süt Tatlısı';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 22, 15, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HURMA', 'SÜT (TAM YAĞ)', 'PİRİNÇ UNU', 'ŞEKER');

    -- 20) Ispanaklı Cacık (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Cacık';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 21) Ispanaklı Yoğurt (Borani) (20: 8+12)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Yoğurt (Borani)';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Soteleme', 2, 12, 12, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ISPANAK', 'TEREYAĞI');

    -- 22) Kabak Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK', 'SARIMSAK', 'SİRKE');

    -- 23) Kabaklı Yoğurt Salatası (15: 8+7)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabaklı Yoğurt Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Soteleme', 2, 7, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK');

    -- 24) Kadayıflı Süt Tatlısı (40: 10+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kadayıflı Süt Tatlısı';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Süt Pişirme', 2, 30, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KADAYIF', 'SÜT (TAM YAĞ)', 'ŞEKER');

    -- 25) Kajulu Havuç Salatası (15) NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kajulu Havuç Salatası';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 26) Karnabahar Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnabahar Turşusu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARNABAHAR', 'HAVUÇ', 'SARIMSAK', 'SİRKE');

    -- 27) Karışık Meyve Kompostosu (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karışık Meyve Kompostosu';
    delete from recete_asamalari where recete_id = v_recete_id;
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Soyma)', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ELMA', 'ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)', 'ŞEKER');

end $$;

-- DOGRULAMA (Grup3 Parti1'in TAMAMI icin -- Ahtapot/Enginar dahil,
-- artik hepsi TUTARLI olmali)
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
    'Ahtapot Salatası (Soğuk)', 'Armutlu Cevizli Salata', 'Ayran (Ev Usulü)', 'Ayva Tatlısı (Kış)', 'Badem Ezmesi Tabağı',
    'Bahar Cacığı', 'Barbunya Turşusu (Bahar)', 'Bezelyeli Yoğurt Salatası', 'Cevizli Kırmızı Lahana Salatası', 'Cevizli Pekmez',
    'Domates Turşusu', 'Domatesli Cacık', 'Ekmek Kadayıfı (Kaymaklı)', 'Elma Kompostosu (Ev Usulü)', 'Elmalı Cevizli Bahar Salatası',
    'Enginar Salatası', 'Enginarlı Yoğurt', 'Greyfurtlu Roka Salatası', 'Güllaç (Ev Usulü)', 'Havuç Turşusu',
    'Haşlanmış Yumurta Salatası', 'Hurma ve Süt Tatlısı', 'Ispanaklı Cacık', 'Ispanaklı Yoğurt (Borani)', 'Kabak Turşusu',
    'Kabaklı Yoğurt Salatası', 'Kadayıflı Süt Tatlısı', 'Kajulu Havuç Salatası', 'Karnabahar Turşusu', 'Karışık Meyve Kompostosu'
  )
order by r.ad;
