-- 139_recete_asamalari_mukerrer_temizligi.sql
-- TESHIS: 245 tariflik "eksik hazirlik_talimati" grubu taranirken,
-- 23 tarifte recete_asamalari'nin HER İKİ asamasinin da TAM OLARAK
-- IKI KEZ kayitli oldugu bulundu (2 asama yerine 4 satir -- muhtemelen
-- bir toplu yukleme betiginin idempotent olmamasindan). Bu, Tarif
-- Kutuphanesi'ndeki enerji/maliyet hesabini CIFT SAYIYOR olabilir
-- (tum isil asamalari topluyor).
--
-- Bu migration SADECE asagidaki 23 tarifi etkiler. Her tarifte, ayni
-- (recete_id, ad, sira, sure_dakika, isil_islem_mi) kombinasyonuna
-- sahip satirlardan yalnizca EN KUCUK id'li olan TUTULUR, digeri
-- SILINIR. Silinmeden once, silinecek satira bagli asama_malzemeleri
-- kayitlari (varsa) TUTULAN satira TASINIR -- veri kaybi olmaz.
-- Tek transaction: beklenen sayilar tutmazsa HICBIR degisiklik
-- yapilmadan iptal edilir.

do $$
declare
    v_once int;
    v_tasinan int;
    v_silinen int;
    v_sonra int;
begin
    -- ONCESI: bu 23 tarifte TOPLAM 92 satir olmali (23 x 4).
    select count(*) into v_once
    from recete_asamalari ra
    join receteler r on r.id = ra.recete_id
    where r.isletme_id is null
      and r.ad in (
        'Kırmızı Biberli Kıyma Sote',
        'Lahana Dolması (Etli)',
        'Limonlu Fırın Levrek',
        'Madımaklı Kavurma',
        'Midye Dolma (Pilavlı)',
        'Mısırlı Tavuk Sote',
        'Nar Ekşili Dana Rosto',
        'Nohutlu Sığır Kavurma (Bahar)',
        'Otlu Izgara Çipura',
        'Pastırmalı Kavurma',
        'Patatesli Dana Güveç',
        'Patlıcanlı Kıyma Musakka',
        'Pırasalı Kıymalı Bahar Yemeği',
        'Roka Soslu Izgara Tavuk',
        'Sade Kuzu Güveç (Et Suyu ile)',
        'Semizotlu Etli Yemek',
        'Soya Kıymalı Patlıcan Musakka (Etsiz)',
        'Soyalı Biberli Sote (Etsiz)',
        'Taze Bakla Kavurma (Etli)',
        'Taze Fasulyeli Kuzu Güveç (İlkbahar)',
        'Taze Fasulyeli Tavuk Güveç',
        'Yer Elmalı Kuzu Yahnisi',
        'Yoğurtlu Kebap (Ev Usulü)'
      );
    if v_once <> 92 then
        raise exception 'Once beklenen 92 satir degil, % bulundu -- iptal', v_once;
    end if;

    -- Silinecek satirlara bagli asama_malzemeleri (varsa) tutulan satira tasinir.
    with dup as (
        select ra.id, ra.recete_id, ra.ad, ra.sira, ra.sure_dakika, ra.isil_islem_mi,
               row_number() over (
                   partition by ra.recete_id, ra.ad, ra.sira, ra.sure_dakika, ra.isil_islem_mi
                   order by ra.id
               ) as rn,
               first_value(ra.id) over (
                   partition by ra.recete_id, ra.ad, ra.sira, ra.sure_dakika, ra.isil_islem_mi
                   order by ra.id
               ) as tutulacak_id
        from recete_asamalari ra
        join receteler r on r.id = ra.recete_id
        where r.isletme_id is null
          and r.ad in (
            'Kırmızı Biberli Kıyma Sote',
        'Lahana Dolması (Etli)',
        'Limonlu Fırın Levrek',
        'Madımaklı Kavurma',
        'Midye Dolma (Pilavlı)',
        'Mısırlı Tavuk Sote',
        'Nar Ekşili Dana Rosto',
        'Nohutlu Sığır Kavurma (Bahar)',
        'Otlu Izgara Çipura',
        'Pastırmalı Kavurma',
        'Patatesli Dana Güveç',
        'Patlıcanlı Kıyma Musakka',
        'Pırasalı Kıymalı Bahar Yemeği',
        'Roka Soslu Izgara Tavuk',
        'Sade Kuzu Güveç (Et Suyu ile)',
        'Semizotlu Etli Yemek',
        'Soya Kıymalı Patlıcan Musakka (Etsiz)',
        'Soyalı Biberli Sote (Etsiz)',
        'Taze Bakla Kavurma (Etli)',
        'Taze Fasulyeli Kuzu Güveç (İlkbahar)',
        'Taze Fasulyeli Tavuk Güveç',
        'Yer Elmalı Kuzu Yahnisi',
        'Yoğurtlu Kebap (Ev Usulü)'
          )
    )
    update asama_malzemeleri am
    set asama_id = dup.tutulacak_id
    from dup
    where am.asama_id = dup.id and dup.rn > 1;
    get diagnostics v_tasinan = row_count;

    -- Mukerrer (rn > 1) satirlar silinir.
    with dup as (
        select ra.id,
               row_number() over (
                   partition by ra.recete_id, ra.ad, ra.sira, ra.sure_dakika, ra.isil_islem_mi
                   order by ra.id
               ) as rn
        from recete_asamalari ra
        join receteler r on r.id = ra.recete_id
        where r.isletme_id is null
          and r.ad in (
            'Kırmızı Biberli Kıyma Sote',
        'Lahana Dolması (Etli)',
        'Limonlu Fırın Levrek',
        'Madımaklı Kavurma',
        'Midye Dolma (Pilavlı)',
        'Mısırlı Tavuk Sote',
        'Nar Ekşili Dana Rosto',
        'Nohutlu Sığır Kavurma (Bahar)',
        'Otlu Izgara Çipura',
        'Pastırmalı Kavurma',
        'Patatesli Dana Güveç',
        'Patlıcanlı Kıyma Musakka',
        'Pırasalı Kıymalı Bahar Yemeği',
        'Roka Soslu Izgara Tavuk',
        'Sade Kuzu Güveç (Et Suyu ile)',
        'Semizotlu Etli Yemek',
        'Soya Kıymalı Patlıcan Musakka (Etsiz)',
        'Soyalı Biberli Sote (Etsiz)',
        'Taze Bakla Kavurma (Etli)',
        'Taze Fasulyeli Kuzu Güveç (İlkbahar)',
        'Taze Fasulyeli Tavuk Güveç',
        'Yer Elmalı Kuzu Yahnisi',
        'Yoğurtlu Kebap (Ev Usulü)'
          )
    )
    delete from recete_asamalari ra
    using dup
    where ra.id = dup.id and dup.rn > 1;
    get diagnostics v_silinen = row_count;

    if v_silinen <> 46 then
        raise exception 'Silinen satir sayisi 46 degil, % -- iptal', v_silinen;
    end if;

    -- SONRASI: bu 23 tarifte TOPLAM 46 satir kalmali (23 x 2).
    select count(*) into v_sonra
    from recete_asamalari ra
    join receteler r on r.id = ra.recete_id
    where r.isletme_id is null
      and r.ad in (
        'Kırmızı Biberli Kıyma Sote',
        'Lahana Dolması (Etli)',
        'Limonlu Fırın Levrek',
        'Madımaklı Kavurma',
        'Midye Dolma (Pilavlı)',
        'Mısırlı Tavuk Sote',
        'Nar Ekşili Dana Rosto',
        'Nohutlu Sığır Kavurma (Bahar)',
        'Otlu Izgara Çipura',
        'Pastırmalı Kavurma',
        'Patatesli Dana Güveç',
        'Patlıcanlı Kıyma Musakka',
        'Pırasalı Kıymalı Bahar Yemeği',
        'Roka Soslu Izgara Tavuk',
        'Sade Kuzu Güveç (Et Suyu ile)',
        'Semizotlu Etli Yemek',
        'Soya Kıymalı Patlıcan Musakka (Etsiz)',
        'Soyalı Biberli Sote (Etsiz)',
        'Taze Bakla Kavurma (Etli)',
        'Taze Fasulyeli Kuzu Güveç (İlkbahar)',
        'Taze Fasulyeli Tavuk Güveç',
        'Yer Elmalı Kuzu Yahnisi',
        'Yoğurtlu Kebap (Ev Usulü)'
      );
    if v_sonra <> 46 then
        raise exception 'Sonra beklenen 46 satir degil, % bulundu -- iptal', v_sonra;
    end if;

    raise notice 'Tasinan asama_malzemeleri kaydi: %, silinen mukerrer satir: %', v_tasinan, v_silinen;
end $$;

-- Dogrulama 1: 0 satir donmeli -- artik HICBIR tarifte (sadece bu 23'u
-- degil, TUM kutuphanede) mukerrer asama kalmamali.
select r.ad, ra.ad as asama_adi, ra.sira, count(*) as tekrar_sayisi
from recete_asamalari ra
join receteler r on r.id = ra.recete_id
where r.isletme_id is null
group by r.ad, ra.ad, ra.sira
having count(*) > 1
order by r.ad;

-- Dogrulama 2: bu 23 tarifin her birinde TAM 2 asama olmali.
select r.ad, count(*) as asama_sayisi
from recete_asamalari ra
join receteler r on r.id = ra.recete_id
where r.isletme_id is null
  and r.ad in (
    'Kırmızı Biberli Kıyma Sote',
        'Lahana Dolması (Etli)',
        'Limonlu Fırın Levrek',
        'Madımaklı Kavurma',
        'Midye Dolma (Pilavlı)',
        'Mısırlı Tavuk Sote',
        'Nar Ekşili Dana Rosto',
        'Nohutlu Sığır Kavurma (Bahar)',
        'Otlu Izgara Çipura',
        'Pastırmalı Kavurma',
        'Patatesli Dana Güveç',
        'Patlıcanlı Kıyma Musakka',
        'Pırasalı Kıymalı Bahar Yemeği',
        'Roka Soslu Izgara Tavuk',
        'Sade Kuzu Güveç (Et Suyu ile)',
        'Semizotlu Etli Yemek',
        'Soya Kıymalı Patlıcan Musakka (Etsiz)',
        'Soyalı Biberli Sote (Etsiz)',
        'Taze Bakla Kavurma (Etli)',
        'Taze Fasulyeli Kuzu Güveç (İlkbahar)',
        'Taze Fasulyeli Tavuk Güveç',
        'Yer Elmalı Kuzu Yahnisi',
        'Yoğurtlu Kebap (Ev Usulü)'
  )
group by r.ad
order by r.ad;
