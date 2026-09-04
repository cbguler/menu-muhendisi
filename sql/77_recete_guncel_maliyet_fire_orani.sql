-- 77_recete_guncel_maliyet_fire_orani.sql
--
-- Bahri'nin tespiti (3 Eylul 2026): malzeme maliyeti hesaplamasi FIRE
-- ORANINI (soyma/ayiklama gibi hazirlik kaybini) hic hesaba katmiyordu
-- -- "100g temizlenmis sogan" icin recete gram uzerinden dogrudan fiyat
-- carpiliyordu, oysa gercekte bu net miktari elde etmek icin daha FAZLA
-- CIG malzeme satin alinmasi gerekiyor. Bu da TUM tarif maliyetlerinin
-- (fire orani > 0 olan her malzeme icin) OLDUGUNDAN DUSUK gorunmesine
-- yol aciyordu.
--
-- Formul: brut_miktar = net_miktar / (1 - fire_orani)
-- NULLIF ile fire_orani=1 (%100 kayip -- pratikte olmamasi gereken bir
-- veri hatasi) durumunda sifira bolme hatasi onleniyor.
--
-- NOT: porsiyon_kalori SATIRINA DOKUNULMADI -- besin degerleri
-- (kalori/protein/vb.) veritabaninda zaten NET/yenebilir kisim
-- uzerinden tutuluyor, fire orani bir SATINALMA/MALIYET kavrami,
-- beslenme kavrami degil.

CREATE OR REPLACE VIEW recete_guncel_maliyet AS
SELECT
    r.id AS recete_id,
    r.isletme_id,
    r.ad AS recete_adi,
    r.porsiyon_sayisi,
    sum(
        rm.miktar_gram / NULLIF(1 - COALESCE(m.fire_orani, 0), 0)
        / 1000.0 * COALESCE(gf.fiyat_eur, 0::numeric)
    ) AS toplam_maliyet_eur,
    sum(
        rm.miktar_gram / NULLIF(1 - COALESCE(m.fire_orani, 0), 0)
        / 1000.0 * COALESCE(gf.fiyat_eur, 0::numeric)
    ) / r.porsiyon_sayisi::numeric AS porsiyon_maliyeti_eur,
    sum(rm.miktar_gram * m.kalori / 100.0) / r.porsiyon_sayisi::numeric AS porsiyon_kalori
FROM receteler r
    JOIN recete_malzemeleri rm ON rm.recete_id = r.id
    JOIN malzemeler m ON m.id = rm.malzeme_id
    LEFT JOIN malzeme_guncel_fiyat gf ON gf.malzeme_id = rm.malzeme_id AND gf.isletme_id = r.isletme_id
GROUP BY r.id, r.isletme_id, r.ad, r.porsiyon_sayisi;
