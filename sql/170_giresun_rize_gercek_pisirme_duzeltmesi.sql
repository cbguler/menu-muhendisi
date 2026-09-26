-- 170_giresun_rize_gercek_pisirme_duzeltmesi.sql
-- AMAC: Bahri'nin bulduğu mantik hatasini duzeltir -- "Giresun Usulü
-- Mısır Ekmekli Peynirli Tabak" ve "Rize Usulü Mısır Ekmekli Kaymak
-- Tabağı" tariflerinde MISIR UNU (cig) vardi ama talimat "hazir
-- misir ekmegi" varsayiyordu, pisirme asamasi hic yoktu. Bahri'nin
-- karari: MISIR UNU korunacak, GERCEK pisirme asamasi eklenecek.
--
-- Kullanilan teknik parametreler, kutuphanedeki bagimsiz "Mısır
-- Ekmeği" tarifinin KENDI Firinlama asamasindan BIREBIR kopyalandi
-- (ayni fiziksel islem oldugu icin tahmin edilmedi):
--   Firinlama: 25 dk (aktif 3 dk), elektrik, 20->200C, verimlilik 0.58
--   Baglı malzemeler: MISIR UNU, BUĞDAY UNU, SU (TUZ haric -- referans
--   tarifte de TUZ baglanmamis, ihmal edilebilir isi kutlesi).
-- Tereyağı Eritme icin ise İskender Kebap'in dogalgaz/tava tipi
-- asamalarindaki tutarli verimlilik_orani=0.5 degeri kullanildi.
--
-- Malzeme oranlari, referans "Mısır Ekmeği" tarifinin kendi oranindan
-- (MISIR UNU:BUĞDAY UNU:SU:TUZ = 80:20:60:3) turetildi.

do $$
declare
    v_giresun_id uuid;
    v_rize_id uuid;
    v_asama_id uuid;
    v_rm_id uuid;
    v_bugday_unu_id uuid;
    v_su_id uuid;
    v_tuz_id uuid;
begin
    select id into v_giresun_id from receteler
        where ad = 'Giresun Usulü Mısır Ekmekli Peynirli Tabak' and isletme_id is null;
    select id into v_rize_id from receteler
        where ad = 'Rize Usulü Mısır Ekmekli Kaymak Tabağı' and isletme_id is null;
    select id into v_bugday_unu_id from malzemeler where ad = 'BUĞDAY UNU';
    select id into v_su_id from malzemeler where ad = 'SU';
    select id into v_tuz_id from malzemeler where ad = 'TUZ';

    if v_giresun_id is null or v_rize_id is null or v_bugday_unu_id is null
       or v_su_id is null or v_tuz_id is null then
        raise exception 'Beklenen kayitlardan biri bulunamadi -- giresun:%, rize:%, bugday_unu:%, su:%, tuz:%',
            v_giresun_id, v_rize_id, v_bugday_unu_id, v_su_id, v_tuz_id;
    end if;

    -- =================== GIRESUN ===================
    update receteler set
        hazirlik_dakika = 35,
        hazirlik_talimati =
E'**Hazırlık / Mise en Place**\n' ||
E'1. Mısır ununu, buğday ununu, suyu ve tuzu bir kapta pürüzsüz bir hamur olana kadar karıştırın; küçük bir kalıba/tepsiye dökün.\n' ||
E'2. Kaşarı dilimleyin veya ufalayın.\n\n' ||
E'**Isıl İşlem**\n' ||
E'1. Fırınlama (~200°C, fırında, 25 dk): Hamuru önceden ısıtılmış fırında kürdan temiz çıkana kadar pişirin.\n' ||
E'2. Tereyağı Eritme (~90°C, tavada, 2 dk): Ayrı bir tavada tereyağını eritin.\n' ||
E'3. Son işlemler: Pişen mısır ekmeğini dilimleyin, kaşarla birlikte tabakta yan yana dizin, üzerine eritilmiş tereyağını gezdirerek servis edin.\n\n' ||
E'**PARALEL YAPILABİLİRLİK:** Fırın ısınırken/ekmek pişerken kaşar dilimlenebilir; tereyağı, ekmek fırından çıkmadan az önce eritilebilir.\n\n' ||
E'**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme (fırınlama) ~22 dk · Toplam ~35 dk'
    where id = v_giresun_id;

    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram) values
        (v_giresun_id, v_bugday_unu_id, 5),
        (v_giresun_id, v_su_id, 15),
        (v_giresun_id, v_tuz_id, 0.75);

    -- Eski asama/asama_malzeme kayitlarini temizle (FK sirasina dikkat)
    delete from asama_malzemeleri where asama_id in
        (select id from recete_asamalari where recete_id = v_giresun_id);
    delete from recete_asamalari where recete_id = v_giresun_id;

    insert into recete_asamalari
        (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi,
         enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values
        (v_giresun_id, 'Hazırlık', 1, 8, null, false, null, null, null, 0.65),
        (v_giresun_id, 'Fırınlama', 2, 25, 3, true, 'elektrik', 20, 200, 0.58),
        (v_giresun_id, 'Tereyağı Eritme', 3, 2, 2, true, 'dogalgaz', 20, 90, 0.5);

    -- Firinlama'ya MISIR UNU, BUĞDAY UNU, SU baglaniyor (TUZ haric)
    select id into v_asama_id from recete_asamalari
        where recete_id = v_giresun_id and ad = 'Fırınlama';
    for v_rm_id in
        select rm.id from recete_malzemeleri rm
        join malzemeler m on m.id = rm.malzeme_id
        where rm.recete_id = v_giresun_id
          and m.ad in ('MISIR UNU', 'BUĞDAY UNU', 'SU')
    loop
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end loop;

    -- Tereyağı Eritme'ye sadece TEREYAĞI baglaniyor
    select id into v_asama_id from recete_asamalari
        where recete_id = v_giresun_id and ad = 'Tereyağı Eritme';
    select rm.id into v_rm_id from recete_malzemeleri rm
        join malzemeler m on m.id = rm.malzeme_id
        where rm.recete_id = v_giresun_id and m.ad = 'TEREYAĞI';
    insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);

    -- =================== RIZE ===================
    update receteler set
        hazirlik_dakika = 35,
        hazirlik_talimati =
E'**Hazırlık / Mise en Place**\n' ||
E'1. Mısır ununu, buğday ununu, suyu ve tuzu bir kapta pürüzsüz bir hamur olana kadar karıştırın; küçük bir kalıba/tepsiye dökün.\n\n' ||
E'**Isıl İşlem**\n' ||
E'1. Fırınlama (~200°C, fırında, 25 dk): Hamuru önceden ısıtılmış fırında kürdan temiz çıkana kadar pişirin.\n\n' ||
E'**Servis**\n' ||
E'1. Pişen mısır ekmeğini dilimleyin. Kaymağı tabağa yayıp üzerine balı gezdirin, mısır ekmeğiyle birlikte servis edin.\n\n' ||
E'**PARALEL YAPILABİLİRLİK:** Ekmek fırında pişerken kaymak ve bal servis tabağına hazırlanabilir.\n\n' ||
E'**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme (fırınlama) ~22 dk · Toplam ~35 dk'
    where id = v_rize_id;

    insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram) values
        (v_rize_id, v_bugday_unu_id, 3.75),
        (v_rize_id, v_su_id, 11.25),
        (v_rize_id, v_tuz_id, 0.5625);

    delete from asama_malzemeleri where asama_id in
        (select id from recete_asamalari where recete_id = v_rize_id);
    delete from recete_asamalari where recete_id = v_rize_id;

    insert into recete_asamalari
        (recete_id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi,
         enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani)
    values
        (v_rize_id, 'Hazırlık', 1, 7, null, false, null, null, null, 0.65),
        (v_rize_id, 'Fırınlama', 2, 25, 3, true, 'elektrik', 20, 200, 0.58),
        (v_rize_id, 'Servis', 3, 3, null, false, null, null, null, 0.65);

    select id into v_asama_id from recete_asamalari
        where recete_id = v_rize_id and ad = 'Fırınlama';
    for v_rm_id in
        select rm.id from recete_malzemeleri rm
        join malzemeler m on m.id = rm.malzeme_id
        where rm.recete_id = v_rize_id
          and m.ad in ('MISIR UNU', 'BUĞDAY UNU', 'SU')
    loop
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end loop;

end $$;

-- DOGRULAMA 1: iki tarifin de hazirlik_dakika'si asama sure_dakika
-- toplamiyla eslesiyor mu? 0 satir donmesi beklenir.
select r.ad, r.hazirlik_dakika, sum(ra.sure_dakika) as asama_toplami
from receteler r
join recete_asamalari ra on ra.recete_id = r.id
where r.ad in ('Giresun Usulü Mısır Ekmekli Peynirli Tabak',
               'Rize Usulü Mısır Ekmekli Kaymak Tabağı')
  and r.isletme_id is null
group by r.ad, r.hazirlik_dakika
having r.hazirlik_dakika <> sum(ra.sure_dakika);

-- DOGRULAMA 2: her isil_islem_mi=true asamada en az 1 bagli malzeme
-- var mi? 0 satir donmesi beklenir.
select r.ad, ra.ad as asama_adi
from receteler r
join recete_asamalari ra on ra.recete_id = r.id
where r.ad in ('Giresun Usulü Mısır Ekmekli Peynirli Tabak',
               'Rize Usulü Mısır Ekmekli Kaymak Tabağı')
  and r.isletme_id is null
  and ra.isil_islem_mi = true
  and not exists (select 1 from asama_malzemeleri am where am.asama_id = ra.id);

-- DOGRULAMA 3: guncel malzeme listelerini goster
select r.ad as tarif, m.ad as malzeme, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad in ('Giresun Usulü Mısır Ekmekli Peynirli Tabak',
               'Rize Usulü Mısır Ekmekli Kaymak Tabağı')
  and r.isletme_id is null
order by tarif, malzeme;
