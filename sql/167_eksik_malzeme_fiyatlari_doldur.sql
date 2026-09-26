-- 167_eksik_malzeme_fiyatlari_doldur.sql
-- AMAC: 165/166 teshisinde bulunan, tariflerde FIILEN kullanilan
-- ama katalogda (malzemeler.varsayilan_fiyat_eur) HIC fiyati
-- olmayan 36 malzemenin fiyatini doldurur. Fiyatlar kapsamli web
-- arastirmasi + Bahri'nin kendi arastirmasiyla belirlendi, Bahri
-- onayladi (23 Eylul 2026). Metodoloji: market zinciri (Migros/
-- CarrefourSA) + Metro toptan ESAS; sadece arpa gibi emtia
-- kalemlerinde ticaret borsasi esas alindi (kalici kural olarak
-- PROJE_NOTLARI'na islendi).
--
-- 5 kalem [TAHMIN] olarak isaretli -- dogrudan kaynak
-- bulunamadigi icin benzer bir urunden referans alindi (ayni
-- yontem KOYUN KIYMA'da daha once kullanilmisti):
--   KOYUN ETİ (KOL/BUT), KEÇİ ETİ (BUT) <- KUZU'nun ayni kesimi
--   KAZ ETİ (2 cesit, cig) <- HINDI etinin ~1.8 kati
--   DÖNER (ET, PİŞMİŞ, BURSA) <- cig kusbasi + pisirme kaybi + iscilik
--
-- Kur: 1 EUR = 55.93 TL (26 Eylul 2026, serbest piyasa).
--
-- Bu migration IKI ISI birden yapar:
-- 1) malzemeler.varsayilan_fiyat_eur'u doldurur (katalog).
-- 2) Her malzeme icin, HENUZ o malzemede fiyat kaydi olmayan
--    HER isletmenin malzeme_fiyat_gecmisi'ne bu fiyati kopyalar
--    (13/25/28 numarali migration'larla ayni yontem, idempotent).

do $$
declare
    v_malzeme_id uuid;
    v_isletme_id uuid;
    v_fiyat numeric;
    v_ad text;
    v_veri record;
begin
    for v_veri in
        select * from (values
            ('KUZU ETİ (KOL)', 17.8795::numeric),
            ('KUZU KIYMA', 21.4554::numeric),
            ('MAYDANOZ', 0.228::numeric),
            ('KUZU ETİ (BUT)', 18.7735::numeric),
            ('KOYUN ETİ (KOL)', 17.8795::numeric),
            ('DANA BUT', 15.1976::numeric),
            ('AYVA', 1.7078::numeric),
            ('KARNABAHAR', 0.9476::numeric),
            ('SOYA KIYMA', 3.1783::numeric),
            ('ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)', 0.894::numeric),
            ('LAVAŞ', 1.5198::numeric),
            ('KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)', 14.3036::numeric),
            ('ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)', 0.894::numeric),
            ('EDİRNE BEYAZ PEYNİRİ', 3.0216::numeric),
            ('PİLİÇ BUT', 1.7879::numeric),
            ('PİLİÇ GÖĞÜS (DERİSİZ)', 5.0599::numeric),
            ('REZENE', 1.3678::numeric),
            ('SALEP', 232.4334::numeric),
            ('SIĞIR PİRZOLA', 15.1976::numeric),
            ('YENİLEBİLİR SAKATAT (DANA BEYİN)', 8.4928::numeric),
            ('YENİLEBİLİR SAKATAT (DANA BÖBREK)', 1.7879::numeric),
            ('YENİLEBİLİR SAKATAT (DANA İŞKEMBE)', 6.2578::numeric),
            ('ZEYTİN EZMESİ', 4.1123::numeric),
            ('ARPA (ALTI SIRALI)', 0.1788::numeric),
            ('DANA PİRZOLA', 15.1976::numeric),
            ('DÖNER (ET, PİŞMİŞ, BURSA)', 25.0313::numeric),
            ('GÜLLAÇ', 5.9002::numeric),
            ('HİNDİ ETİ (BUT, DERİSİZ)', 8.0458::numeric),
            ('HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)', 8.0458::numeric),
            ('ISIRGAN', 12.1581::numeric),
            ('KALKAN', 35.759::numeric),
            ('KAZ ETİ (BÜTÜN, DERİLİ)', 14.3036::numeric),
            ('KEÇİ ETİ (BUT)', 18.7735::numeric),
            ('KIZILCIK', 1.2516::numeric),
            ('KOYUN ETİ (BUT)', 18.7735::numeric),
            ('MADIMAK', 3.5759::numeric)
        ) as t(ad, fiyat)
    loop
        -- 1) Katalog fiyatini guncelle
        update malzemeler set varsayilan_fiyat_eur = v_veri.fiyat
        where ad = v_veri.ad
        returning id into v_malzeme_id;

        if v_malzeme_id is null then
            raise exception 'Malzeme bulunamadi: %', v_veri.ad;
        end if;

        -- 2) Her isletmenin fiyat gecmisine, henuz kaydi yoksa ekle
        for v_isletme_id in select id from isletmeler
        loop
            if not exists (
                select 1 from malzeme_fiyat_gecmisi
                where isletme_id = v_isletme_id and malzeme_id = v_malzeme_id
            ) then
                insert into malzeme_fiyat_gecmisi
                    (isletme_id, malzeme_id, fiyat_eur, gecerlilik_tarihi, tedarikci, created_at)
                values
                    (v_isletme_id, v_malzeme_id, v_veri.fiyat, current_date,
                     'Piyasa arastirmasi (Eylul 2026)', now());
            end if;
        end loop;
    end loop;
end $$;

-- Dogrulama 1: bu 36 malzemenin TAMAMINDA artik katalog fiyati
-- olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('KUZU ETİ (KOL)'),
    ('KUZU KIYMA'),
    ('MAYDANOZ'),
    ('KUZU ETİ (BUT)'),
    ('KOYUN ETİ (KOL)'),
    ('DANA BUT'),
    ('AYVA'),
    ('KARNABAHAR'),
    ('SOYA KIYMA'),
    ('ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)'),
    ('LAVAŞ'),
    ('KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)'),
    ('ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)'),
    ('EDİRNE BEYAZ PEYNİRİ'),
    ('PİLİÇ BUT'),
    ('PİLİÇ GÖĞÜS (DERİSİZ)'),
    ('REZENE'),
    ('SALEP'),
    ('SIĞIR PİRZOLA'),
    ('YENİLEBİLİR SAKATAT (DANA BEYİN)'),
    ('YENİLEBİLİR SAKATAT (DANA BÖBREK)'),
    ('YENİLEBİLİR SAKATAT (DANA İŞKEMBE)'),
    ('ZEYTİN EZMESİ'),
    ('ARPA (ALTI SIRALI)'),
    ('DANA PİRZOLA'),
    ('DÖNER (ET, PİŞMİŞ, BURSA)'),
    ('GÜLLAÇ'),
    ('HİNDİ ETİ (BUT, DERİSİZ)'),
    ('HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)'),
    ('ISIRGAN'),
    ('KALKAN'),
    ('KAZ ETİ (BÜTÜN, DERİLİ)'),
    ('KEÇİ ETİ (BUT)'),
    ('KIZILCIK'),
    ('KOYUN ETİ (BUT)'),
    ('MADIMAK')
)
select l.ad
from liste l
join malzemeler m on m.ad = l.ad
where m.varsayilan_fiyat_eur is null;

-- Dogrulama 2: her (malzeme x isletme) kombinasyonu icin artik
-- en az 1 fiyat_gecmisi kaydi olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('KUZU ETİ (KOL)'),
    ('KUZU KIYMA'),
    ('MAYDANOZ'),
    ('KUZU ETİ (BUT)'),
    ('KOYUN ETİ (KOL)'),
    ('DANA BUT'),
    ('AYVA'),
    ('KARNABAHAR'),
    ('SOYA KIYMA'),
    ('ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)'),
    ('LAVAŞ'),
    ('KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)'),
    ('ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)'),
    ('EDİRNE BEYAZ PEYNİRİ'),
    ('PİLİÇ BUT'),
    ('PİLİÇ GÖĞÜS (DERİSİZ)'),
    ('REZENE'),
    ('SALEP'),
    ('SIĞIR PİRZOLA'),
    ('YENİLEBİLİR SAKATAT (DANA BEYİN)'),
    ('YENİLEBİLİR SAKATAT (DANA BÖBREK)'),
    ('YENİLEBİLİR SAKATAT (DANA İŞKEMBE)'),
    ('ZEYTİN EZMESİ'),
    ('ARPA (ALTI SIRALI)'),
    ('DANA PİRZOLA'),
    ('DÖNER (ET, PİŞMİŞ, BURSA)'),
    ('GÜLLAÇ'),
    ('HİNDİ ETİ (BUT, DERİSİZ)'),
    ('HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)'),
    ('ISIRGAN'),
    ('KALKAN'),
    ('KAZ ETİ (BÜTÜN, DERİLİ)'),
    ('KEÇİ ETİ (BUT)'),
    ('KIZILCIK'),
    ('KOYUN ETİ (BUT)'),
    ('MADIMAK')
)
select l.ad, i.ad as isletme_ad
from liste l
join malzemeler m on m.ad = l.ad
cross join isletmeler i
where not exists (
    select 1 from malzeme_fiyat_gecmisi mfg
    where mfg.malzeme_id = m.id and mfg.isletme_id = i.id
);

-- Dogrulama 3 (genel): katalogda hala fiyati NULL olan, TARIFLERDE
-- FIILEN KULLANILAN baska malzeme kaldi mi? 0 satir donmesi beklenir
-- (kalan ~180 fiyatsiz malzeme hic tarifte kullanilmadigi icin bu
-- sorguya girmez).
select m.ad, count(distinct rm.recete_id) as kac_tarifte
from malzemeler m
join recete_malzemeleri rm on rm.malzeme_id = m.id
where m.varsayilan_fiyat_eur is null
group by m.ad
order by kac_tarifte desc;
