-- 106_uretim_asamalari_grup1_parti3.sql
-- Grup 1, 3. parti (21-30 / 73). Ayni metodoloji.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
begin
    -- 1) Fındıklı Tavuk Sote (Karadeniz Usulü) (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fındıklı Tavuk Sote (Karadeniz Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Sote', 2, 20, 20, true, 'dogalgaz', 20, 90, 0.55)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK GÖĞÜS', 'FINDIK (İÇ)', 'KURU SOĞAN', 'ZEYTİNYAĞI');

    -- 2) Fırında Bütün Tavuk (Ev Usulü) (90: 20+70)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Bütün Tavuk (Ev Usulü)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 70, 8, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('TAVUK BÜTÜN', 'ZEYTİNYAĞI', 'KEKİK', 'LİMON');

    -- 3) Fırında Dana Beyin (30: 10+20)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Dana Beyin';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 10, 10, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 20, 5, true, 'elektrik', 20, 80, 0.6)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('YENİLEBİLİR SAKATAT (DANA BEYİN)', 'ZEYTİNYAĞI');

    -- 4) Fırında Hindi But (60: 15+45)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Hindi But';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 45, 8, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('HİNDİ ETİ (BUT, DERİSİZ)', 'ZEYTİNYAĞI', 'KEKİK');

    -- 5) Fırında Kuzu But (Bütün) (110: 20+90)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Kuzu But (Bütün)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 90, 10, true, 'elektrik', 20, 75, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU ETİ (BUT)', 'ZEYTİNYAĞI', 'KEKİK', 'SARIMSAK');

    -- 6) Fırında Patatesli Kıyma (55: 15+40)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Patatesli Kıyma';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 15, 15, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 40, 8, true, 'elektrik', 20, 90, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('DANA KIYMA', 'PATATES', 'KURU SOĞAN', 'DOMATES', 'ZEYTİNYAĞI');

    -- 7) Fırında Kalkan (35: 12+23)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Kalkan';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık', 1, 12, 12, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 23, 5, true, 'elektrik', 20, 65, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KALKAN', 'ZEYTİNYAĞI', 'LİMON SUYU');

    -- 8) Fırında Koyun Tandır (110: 20+90)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Koyun Tandır';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Baharatlama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 90, 10, true, 'elektrik', 20, 85, 0.6)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KOYUN TANDIR', 'ZEYTİNYAĞI', 'KEKİK', 'SARIMSAK');

    -- 9) Fırında Kuzu Pirzola (Sebzeli) (85: 20+65)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Kuzu Pirzola (Sebzeli)';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 65, 8, true, 'elektrik', 20, 75, 0.65)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('KUZU PİRZOLA', 'HAVUÇ', 'PATATES', 'ZEYTİNYAĞI');

    -- 10) Fırında Sığır Kaburga (130: 20+110)
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Fırında Sığır Kaburga';
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi)
    values (v_recete_id, 'Hazırlık (Doğrama)', 1, 20, 20, false);
    insert into recete_asamalari (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values (v_recete_id, 'Fırınlama', 2, 110, 10, true, 'elektrik', 20, 90, 0.6)
    returning id into v_asama_id;
    insert into asama_malzemeleri (asama_id, recete_malzeme_id)
    select v_asama_id, rm.id from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
    where rm.recete_id = v_recete_id and m.ad in ('SIĞIR KABURGA', 'KURU SOĞAN', 'HAVUÇ', 'DOMATES');

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
    'Fındıklı Tavuk Sote (Karadeniz Usulü)', 'Fırında Bütün Tavuk (Ev Usulü)', 'Fırında Dana Beyin', 'Fırında Hindi But', 'Fırında Kuzu But (Bütün)',
    'Fırında Patatesli Kıyma', 'Fırında Kalkan', 'Fırında Koyun Tandır', 'Fırında Kuzu Pirzola (Sebzeli)', 'Fırında Sığır Kaburga'
  )
order by r.ad;
