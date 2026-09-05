-- 80_isletme_porsiyon_profilleri_hedefler.sql
--
-- Bahri'nin gece biraktigi fikir (3->4 Eylul 2026): porsiyon
-- profilleri (isletme_porsiyon_profilleri, bkz. 79 numarali migration)
-- sadece porsiyon sayisi tutuyordu. Gercek senaryo: bir isletmenin
-- (yemek fabrikasi) farkli musteri TIPLERI olabilir -- ör. 1. musteri
-- hastane, 2. musteri spor salonu, 3. musteri ilkokul, 4. musteri
-- huzur evi, 5. musteri tatil koyu. Bunlarin besin hedefleri (kalori/
-- protein/sodyum/vb. araliklari) KOKTEN farkli olmali. Bu yuzden her
-- profile kendi besin hedefi setini de eklemek gerekiyor -- profil
-- secildiginde o profile ONCEDEN kaydedilmis hedefler otomatik gelsin.
--
-- Veri sekli: mevcut "hedefler" Python dict yapisiyla BIREBIR ayni
-- ({"Öğle": {"kalori": [900, 1200], ...}, "Akşam": {...}}) -- boylece
-- Aylik Menu sayfasindaki mevcut kod, bu JSONB'yi neredeyse hic
-- donusturmeden dogrudan kullanabiliyor.

alter table isletme_porsiyon_profilleri
    add column if not exists hedefler jsonb;

-- DOGRULAMA
select column_name, data_type
from information_schema.columns
where table_name = 'isletme_porsiyon_profilleri' and column_name = 'hedefler';
