-- 104_uretim_asamalari_grup1_parti1.sql
--
-- AMAC: recete_asamalari eksik olan 245 tariften (73'u Grup 1) ilk
-- 10'u icin GERCEK uretim asamasi verisi eklemek. Yontem VII. Oturum'da
-- (3 Agustos) kurulan AYNI metodoloji: Hazirlik (isil islem DEGIL,
-- mise en place) + Isil Islem (ardisik ayni-kap adimlar TEK asamada
-- birlestirilmis) -- iki asamanin sure_dakika toplami, tarifin kendi
-- hazirlik_dakika alanina ESIT tutuldu (tutarlilik icin).
--
-- baslangic/hedef_sicaklik: YEMEGIN kendi ic sicakligi (firin/ocak
-- AYARI degil) -- Q=mcDeltaT hesaplamasi bunun uzerinden yapiliyor.
-- Degerler standart/bilinen pisirme sonuclarina dayanir (ornegin
-- kirmizi et rosto ic sicakligi ~75C, tavuk ~90C guvenlik icin,
-- somon ~65C nemli kalmasi icin, kaynatma/haslama 100C, vb.) --
-- TAHMINI degil, YAYGIN BILINEN pisirme parametreleri.
--
-- verimlilik_orani: acik ocak/tava/izgara icin daha dusuk (0.45-0.55,
-- daha fazla isi kacagi), kapali firin icin daha yuksek (0.65) --
-- VII. Oturum'daki ayni mantik.
--
-- enerji_kaynagi: firin = elektrik, ocak/tava/izgara = dogalgaz
-- (Turkiye'de yaygin mutfak kurulumu varsayimi).

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Fırında Dana But (hazirlik_dakika=100: 20+80)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Dana But';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 80, 10, true, 'elektrik', 20, 75, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA BUT', 'ZEYTİNYAĞI', 'KEKİK', 'SARIMSAK');

    -- 2) Izgara Kuzu Pirzola (hazirlik_dakika=30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Izgara Kuzu Pirzola';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Marinasyon)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Izgara', 2, 20, 20, true, 'dogalgaz', 20, 70, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU PİRZOLA', 'ZEYTİNYAĞI', 'KEKİK');

    -- 3) Kerevizli Tavuk Sote (hazirlik_dakika=35: 15+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Kerevizli Tavuk Sote';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'KEREVİZ', 'HAVUÇ', 'ZEYTİNYAĞI');

    -- 4) Etli Kuru Fasulye (Kış) (hazirlik_dakika=70: 15+55)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Etli Kuru Fasulye (Kış)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kaynatma/Pişirme', 2, 55, 10, true, 'dogalgaz', 20, 100, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KURU FASULYE', 'KUZU ETİ (KOL)', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 5) Domates Dolması (Etli) (hazirlik_dakika=60: 25+35)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Domates Dolması (Etli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doldurma)', 1, 25, 25, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Pişirme', 2, 35, 8, true, 'dogalgaz', 20, 95, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DOMATES', 'DANA KIYMA', 'PİRİNÇ (HAM)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 6) Sucuklu Yumurta (Tava) (hazirlik_dakika=15: 3+12)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Sucuklu Yumurta (Tava)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Dilimleme)', 1, 3, 3, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Tavada Pişirme', 2, 12, 12, true, 'dogalgaz', 20, 85, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SUCUK', 'TAVUK YUMURTASI');

    -- 7) Karadeniz Usulü Hamsi Tava (hazirlik_dakika=30: 15+15)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Karadeniz Usulü Hamsi Tava';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Unlama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Kızartma', 2, 15, 15, true, 'dogalgaz', 20, 90, 0.45)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HAMSİ', 'MISIR UNU', 'ZEYTİNYAĞI');

    -- 8) Nohutlu Tavuk Güveç (hazirlik_dakika=45: 15+30)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Nohutlu Tavuk Güveç';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Güveç Pişirme', 2, 30, 8, true, 'dogalgaz', 20, 95, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'NOHUT', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 9) Fırında Somon Sebzeli (hazirlik_dakika=30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Somon Sebzeli';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 20, 5, true, 'elektrik', 20, 65, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SOMON', 'KABAK', 'HAVUÇ', 'ZEYTİNYAĞI');

    -- 10) Ispanaklı Kıyma (Tavada) (hazirlik_dakika=30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ispanaklı Kıyma (Tavada)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Tavada Pişirme', 2, 20, 15, true, 'dogalgaz', 20, 90, 0.5)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'ISPANAK', 'KURU SOĞAN', 'TEREYAĞI');

end $$;

-- DOGRULAMA: her tarif icin kac asama VE kac asama-malzeme baglantisi olustu
select
    r.ad,
    count(distinct ra.id) as asama_sayisi,
    count(am.recete_malzeme_id) as asama_malzeme_baglantisi,
    sum(ra.sure_dakika) as toplam_sure_dakika
from receteler r
join recete_asamalari ra on ra.recete_id = r.id
left join asama_malzemeleri am on am.asama_id = ra.id
where r.isletme_id is null
  and r.ad in (
    'Fırında Dana But', 'Izgara Kuzu Pirzola', 'Kerevizli Tavuk Sote', 'Etli Kuru Fasulye (Kış)', 'Domates Dolması (Etli)',
    'Sucuklu Yumurta (Tava)', 'Karadeniz Usulü Hamsi Tava', 'Nohutlu Tavuk Güveç', 'Fırında Somon Sebzeli', 'Ispanaklı Kıyma (Tavada)'
  )
group by r.ad
order by r.ad;
