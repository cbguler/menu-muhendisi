-- 114_uretim_asamalari_grup3_parti1.sql
-- Grup 3, 1. parti (1-30 / 88). ILK KEZ 30'luk parti (Bahri onayiyla,
-- yontem kanitlandigi icin).
--
-- Grup 3 salata/cacik/tursu/tatli agirlikli -- COK farkli bir dogasi
-- var: bircok tarif (kisa hazirlik suresi + dondurulmus/hazir malzeme
-- varsayimi) HIC ISIL ISLEM icermiyor (Ayran, cig salatalar, cacik
-- cesitleri, Cevizli Pekmez, Badem Ezmesi -- hepsi TEK asamali).
-- Tursu turunde: SALAMURA (su+sirke+tuz) kaynatilip sicak dokulur --
-- TUZ haric sebze+sarimsak+sirke isil isleme baglandi (kurulmus
-- yontem: sade tuz/baharat baglanmiyor).
-- Kisa toplam sureli (15dk) Ahtapot/Enginar tarifleri -- gercek
-- haslama suresi (45-60dk+) bu kadar kisa siga olmayacagi icin
-- ON-PISMIS/hazir malzeme varsayimiyla NON-THERMAL isaretlendi.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Ahtapot Salatası (Soğuk) (20) -- on-pismis ahtapot varsayimi, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ahtapot Salatası (Soğuk)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Karıştırma)', 1, 20, 20, false);

    -- 2) Armutlu Cevizli Salata (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Armutlu Cevizli Salata';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 3) Ayran (Ev Usulü) (10) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayran (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Çırpma)', 1, 10, 10, false);

    -- 4) Ayva Tatlısı (Kış) (45: 15+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ayva Tatlısı (Kış)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Soyma)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Şerbette Pişirme', 2, 30, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('AYVA', 'ŞEKER');

    -- 5) Badem Ezmesi Tabağı (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Badem Ezmesi Tabağı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 6) Bahar Cacığı (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bahar Cacığı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 7) Barbunya Turşusu (Bahar) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Barbunya Turşusu (Bahar)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BARBUNYA', 'SARIMSAK', 'SİRKE');

    -- 8) Bezelyeli Yoğurt Salatası (15: 8+7)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bezelyeli Yoğurt Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 7, 7, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('BEZELYE');

    -- 9) Cevizli Kırmızı Lahana Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Cevizli Kırmızı Lahana Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 10) Cevizli Pekmez (5) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Cevizli Pekmez';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Karıştırma)', 1, 5, 5, false);

    -- 11) Domates Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domates Turşusu';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DOMATES', 'SARIMSAK', 'SİRKE');

    -- 12) Domatesli Cacık (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domatesli Cacık';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 13) Ekmek Kadayıfı (Kaymaklı) (40: 10+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ekmek Kadayıfı (Kaymaklı)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Şerbet Pişirme', 2, 30, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('EKMEK KADAYIFI', 'ŞEKER');

    -- 14) Elma Kompostosu (Ev Usulü) (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Elma Kompostosu (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Soyma)', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ELMA', 'ŞEKER');

    -- 15) Elmalı Cevizli Bahar Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Elmalı Cevizli Bahar Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 16) Enginar Salatası (15) -- on-pismis enginar varsayimi, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginar Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 17) Enginarlı Yoğurt (20) -- on-pismis enginar varsayimi, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Enginarlı Yoğurt';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 20, 20, false);

    -- 18) Greyfurtlu Roka Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Greyfurtlu Roka Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 19) Güllaç (Ev Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Güllaç (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Süt Isıtma', 2, 20, 10, true, 'dogalgaz', 20, 80, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('GÜLLAÇ', 'SÜT (TAM YAĞ)', 'ŞEKER');

    -- 20) Havuç Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Havuç Turşusu';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HAVUÇ', 'SARIMSAK', 'SİRKE');

    -- 21) Haşlanmış Yumurta Salatası (15: 3+12)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Haşlanmış Yumurta Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 3, 3, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Haşlama', 2, 12, 3, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK YUMURTASI');

    -- 22) Hurma ve Süt Tatlısı (30: 8+22)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Hurma ve Süt Tatlısı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 22, 15, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HURMA', 'SÜT (TAM YAĞ)', 'PİRİNÇ UNU', 'ŞEKER');

    -- 23) Ispanaklı Cacık (15) -- taze ispanak varsayimi, NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Cacık';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 24) Ispanaklı Yoğurt (Borani) (20: 8+12)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Yoğurt (Borani)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Soteleme', 2, 12, 12, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ISPANAK', 'TEREYAĞI');

    -- 25) Kabak Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabak Turşusu';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK', 'SARIMSAK', 'SİRKE');

    -- 26) Kabaklı Yoğurt Salatası (15: 8+7)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kabaklı Yoğurt Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Soteleme', 2, 7, 7, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KABAK');

    -- 27) Kadayıflı Süt Tatlısı (40: 10+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kadayıflı Süt Tatlısı';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Süt Pişirme', 2, 30, 10, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KADAYIF', 'SÜT (TAM YAĞ)', 'ŞEKER');

    -- 28) Kajulu Havuç Salatası (15) -- NON-THERMAL
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kajulu Havuç Salatası';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 15, 15, false);

    -- 29) Karnabahar Turşusu (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karnabahar Turşusu';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Salamura Kaynatma', 2, 20, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KARNABAHAR', 'HAVUÇ', 'SARIMSAK', 'SİRKE');

    -- 30) Karışık Meyve Kompostosu (25: 8+17)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karışık Meyve Kompostosu';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Soyma)', 1, 8, 8, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 17, 6, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('ELMA', 'ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)', 'ŞEKER');

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
    'Ahtapot Salatası (Soğuk)', 'Armutlu Cevizli Salata', 'Ayran (Ev Usulü)', 'Ayva Tatlısı (Kış)', 'Badem Ezmesi Tabağı',
    'Bahar Cacığı', 'Barbunya Turşusu (Bahar)', 'Bezelyeli Yoğurt Salatası', 'Cevizli Kırmızı Lahana Salatası', 'Cevizli Pekmez',
    'Domates Turşusu', 'Domatesli Cacık', 'Ekmek Kadayıfı (Kaymaklı)', 'Elma Kompostosu (Ev Usulü)', 'Elmalı Cevizli Bahar Salatası',
    'Enginar Salatası', 'Enginarlı Yoğurt', 'Greyfurtlu Roka Salatası', 'Güllaç (Ev Usulü)', 'Havuç Turşusu',
    'Haşlanmış Yumurta Salatası', 'Hurma ve Süt Tatlısı', 'Ispanaklı Cacık', 'Ispanaklı Yoğurt (Borani)', 'Kabak Turşusu',
    'Kabaklı Yoğurt Salatası', 'Kadayıflı Süt Tatlısı', 'Kajulu Havuç Salatası', 'Karnabahar Turşusu', 'Karışık Meyve Kompostosu'
  )
order by r.ad;
