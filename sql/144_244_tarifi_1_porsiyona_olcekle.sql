-- 144_244_tarifi_1_porsiyona_olcekle.sql
-- KARAR (23 Eylul 2026, Bahri): Kutuphanenin TAMAMI ayni porsiyon
-- biriminde olmali. Orijinal ~241 kutuphane tarifi porsiyon_sayisi=1
-- (kisi basi) ile tasarlanmisti; bu oturumda doldurulan 244 tarif
-- (Ic Pilav haric) porsiyon_sayisi=10 (10 kisilik toplu miktar) ile
-- girilmisti -- bu, kutuphane genelinde birim tutarsizligi yaratiyordu.
--
-- BU MIGRATION: bu 244 tarifin TUM recete_malzemeleri.miktar_gram
-- degerlerini 10'a boler VE receteler.porsiyon_sayisi'sini 1'e ceker.
-- miktar_gram sutunu `numeric` (sinirsiz hassasiyet) oldugu icin
-- (dogrulandi) kucuk baharat miktarlari (ör. 3g -> 0.3g) KAYBOLMAZ.
--
-- NOT (Bahri onayli): hazirlik_talimati METNI (ör. "2 litre su")
-- BILEREK DEGISTIRILMIYOR -- metin, gercekci bir 10 kisilik pisirme
-- surecini anlatan bagimsiz bir tarif karti gibi kalacak; veritabani
-- sadece maliyet/besin degeri hesabi icin dogrusal bir referans.
--
-- su malzemesi (SU, id 9f265c5f-...) dahil TUM malzeme kayitlari ayni
-- islemle olceklenir -- ayri bir isleme gerek yok, zaten recete_
-- malzemeleri tablosunun bir parcasi.
--
-- Tek transaction; beklenen sayilar tutmazsa HICBIR degisiklik
-- yapilmadan iptal edilir.

do $$
declare
    v_tarif_once int;
    v_malzeme_guncellenen int;
    v_tarif_guncellenen int;
    v_tutarsiz_sonra int;
begin
    -- ONCESI: tam olarak 244 tarif porsiyon_sayisi=10 olmali.
    select count(*) into v_tarif_once
    from receteler
    where isletme_id is null and porsiyon_sayisi = 10;
    if v_tarif_once <> 244 then
        raise exception 'Beklenen 244 tarif degil, % bulundu (porsiyon_sayisi=10) -- iptal', v_tarif_once;
    end if;

    -- A) Bu 244 tarife ait TUM malzeme miktarlarini 10'a bol.
    update recete_malzemeleri
    set miktar_gram = miktar_gram / 10
    where recete_id in (
        select id from receteler
        where isletme_id is null and porsiyon_sayisi = 10
    );
    get diagnostics v_malzeme_guncellenen = row_count;

    -- B) Bu 244 tarifin porsiyon_sayisi'sini 1'e cek.
    update receteler
    set porsiyon_sayisi = 1
    where isletme_id is null and porsiyon_sayisi = 10;
    get diagnostics v_tarif_guncellenen = row_count;

    if v_tarif_guncellenen <> 244 then
        raise exception 'Guncellenen tarif sayisi 244 degil, % -- iptal', v_tarif_guncellenen;
    end if;

    -- SONRASI: kutuphanede (isletme_id is null) porsiyon_sayisi <> 1
    -- olan HICBIR tarif kalmamali.
    select count(*) into v_tutarsiz_sonra
    from receteler
    where isletme_id is null and porsiyon_sayisi <> 1;
    if v_tutarsiz_sonra <> 0 then
        raise exception 'Hala porsiyon_sayisi <> 1 olan % tarif var -- iptal', v_tutarsiz_sonra;
    end if;

    raise notice 'Olceklenen malzeme satiri: %, guncellenen tarif: %', v_malzeme_guncellenen, v_tarif_guncellenen;
end $$;

-- Dogrulama 1: kutuphanenin TAMAMI artik porsiyon_sayisi=1 olmali.
-- Tek satir donmeli: porsiyon_sayisi=1, count=485.
select porsiyon_sayisi, count(*)
from receteler
where isletme_id is null
group by porsiyon_sayisi
order by porsiyon_sayisi;

-- Dogrulama 2: ornek kontrol -- "Ahtapot Salatası (Soğuk)" artik
-- 60g ahtapot, 200g su gostermeli (oncesi: 600g / 2000g, 10'a bolundu).
select m.ad, rm.miktar_gram
from recete_malzemeleri rm
join malzemeler m on m.id = rm.malzeme_id
join receteler r on r.id = rm.recete_id
where r.isletme_id is null and r.ad = 'Ahtapot Salatası (Soğuk)'
order by rm.miktar_gram desc;
