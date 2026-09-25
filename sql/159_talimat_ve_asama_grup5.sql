-- 159_talimat_ve_asama_grup5.sql
-- 515 yeni tarifin talimat+asama yazimi -- Grup 5: Parti4(tarif-
-- ekleme)'nin 56 tarifi, 7 bolgeye esit.
-- Ayni _talimat_ve_asama_ekle_v2 fonksiyonu (155-158 ile ayni).
-- Su eklemeleri orijinal Parti4 malzeme listeleriyle CAPRAZ
-- KONTROL EDILEREK dogrulandi. Hazirlik_dakika duzeltmesi YOK
-- (tum 56 deger gercekci bulundu).

create or replace function _talimat_ve_asama_ekle_v2(
    p_ad text, p_yeni_hazirlik_dakika int, p_talimat text, p_asamalar jsonb
) returns void language plpgsql as $f$
declare
    v_recete_id uuid;
    v_item jsonb;
    v_asama_id uuid;
    v_su_id uuid := '9f265c5f-7d22-43c8-8356-9f748af1c9ee';
    v_rm_id uuid;
    v_malzeme_ad text;
    v_yeni_su numeric;
begin
    select id into v_recete_id from receteler where isletme_id is null and ad = p_ad;
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', p_ad; end if;
    if exists (select 1 from recete_asamalari where recete_id = v_recete_id) then
        raise exception 'Bu tarifte ZATEN asama kayitli -- iptal: %', p_ad;
    end if;

    update receteler set hazirlik_talimati = p_talimat,
        hazirlik_dakika = coalesce(p_yeni_hazirlik_dakika, hazirlik_dakika)
    where id = v_recete_id;

    for v_item in select * from jsonb_array_elements(p_asamalar)
    loop
        insert into recete_asamalari (recete_id, sira, ad, sure_dakika, aktif_dakika,
                                       isil_islem_mi, baslangic_sicaklik, hedef_sicaklik, enerji_kaynagi)
        values (
            v_recete_id, (v_item->>'sira')::smallint, v_item->>'ad',
            (v_item->>'sure_dakika')::numeric, (v_item->>'aktif_dakika')::numeric,
            (v_item->>'isil_islem_mi')::boolean, (v_item->>'baslangic_sicaklik')::numeric,
            (v_item->>'hedef_sicaklik')::numeric, v_item->>'enerji_kaynagi'
        )
        returning id into v_asama_id;

        v_yeni_su := (v_item->>'yeni_su_gram')::numeric;
        if v_yeni_su is not null then
            select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id and malzeme_id = v_su_id;
            if v_rm_id is null then
                insert into recete_malzemeleri (recete_id, malzeme_id, miktar_gram)
                values (v_recete_id, v_su_id, v_yeni_su);
            else
                update recete_malzemeleri set miktar_gram = v_yeni_su where id = v_rm_id;
            end if;
        end if;

        for v_malzeme_ad in select jsonb_array_elements_text(v_item->'malzemeler')
        loop
            select rm.id into v_rm_id
            from recete_malzemeleri rm join malzemeler m on m.id = rm.malzeme_id
            where rm.recete_id = v_recete_id and m.ad = v_malzeme_ad;
            if v_rm_id is null then
                raise exception 'Malzeme tarifte yok: % (tarif: %, asama: %)', v_malzeme_ad, p_ad, v_item->>'ad';
            end if;
            insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
        end loop;
    end loop;
end;
$f$;

do $$
begin
    perform _talimat_ve_asama_ekle_v2(
        'Yalova Usulü Zeytinyağlı Kestane', null, '**Hazırlık / Mise en Place**
1. Kestaneleri (haşlanmış/kabuğu soyulmuş) iri parçalar halinde bölün.
2. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kestaneleri ve tuzu ekleyip kapağı kapalı olarak kısık ateşte lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KESTANE", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bilecik Usulü Etli Nohutlu Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, nohut haşlanmışsa süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulgur ve nohudu, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "NOHUT", "BULGUR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sakarya Usulü Mısırlı Tavuk Güveç', null, '**Hazırlık / Mise en Place**
1. Tavuk butunu parçalara ayırın. Domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Tavuğu kendi yağında her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Domates ve mısırı, tuz ve karabiberi ekleyip kapağı kapalı olarak tavuk pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "MISIR", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çorlu Usulü Kaşarlı Tavuklu Makarna', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın, kaşarı rendeleyin.

**Isıl İşlem**
1. Haşlama ve Pişirme (~100°C, tencerede, 25 dk): Tencereye 600 ml (600 g) su koyup kaynatın, tuz ekleyin. Makarnayı paket üzerindeki süreye göre haşlayın. Ayrı bir tavada tereyağında tavuğu pişene kadar 10-12 dk çevirin. Süzülen makarnayı tavuklu tavaya ekleyip karıştırın, üzerine rendelenmiş kaşarı serpin.

**PARALEL YAPILABİLİRLİK:** Makarna haşlanırken tavuk ayrı tavada pişirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~12 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama ve Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MAKARNA", "TAVUK GÖĞÜS", "KAŞAR PEYNİRİ", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 600}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bursa Usulü Cevizli Erik Tatlısı', null, '**Hazırlık / Mise en Place**
1. Erikleri yıkayıp çekirdeklerini çıkarın, ikiye bölün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): Erikleri ve şekeri bir tencerede az suyla (kendi suyunu bırakacaktır) kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Erik pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ERİK", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İstanbul Usulü Zeytinyağlı Balkabağı', null, '**Hazırlık / Mise en Place**
1. Kabağı soyup kalın küp doğrayın. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kabağı ve tuzu ekleyip kapağı kapalı olarak kısık ateşte kabak yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Nohutlu Tavuk Çorbası', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü küçük küp doğrayın, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tavuk suyunu kaynatın. Tavuk ve nohudu, tuz ve karabiberi ekleyip tavuk pişene kadar (~15 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken tavuk ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme ~15 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "NOHUT", "TAVUK SUYU", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Armutlu Ceviz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Armutları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 17 dk): Armut dilimlerini az suyla (kendi suyunu bırakacaktır) kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ilıyınca üzerine kırılmış ceviz ve balı gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Armut pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~9 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Manisa Usulü Mesir Macunlu Tatlı - basitleştirilmiş', null, '**Hazırlık / Mise en Place**
1. Cevizleri kabaca kırın.
2. Balı, ceviz ve tarçınla karıştırıp servis kaselerine paylaştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Denizli Usulü Keşkek (Tavuklu)', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün. Tavuk butunu parçalara ayırın, kuru soğanı iri dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 55 dk): Tereyağında tavuğu her tarafı renk alana kadar çevirin. Soğanı ekleyip 3-4 dk kavurun. 500 ml (500 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak tavuk kemikten kolayca ayrılacak kadar yumuşayana kadar (~30 dk) pişirin. Bulguru ekleyip su iyice çekilene, bulamaç kıvamına gelene kadar (~20 dk) karıştırarak pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken bulgur yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~50 dk · Toplam ~70 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 55, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "BULGUR", "KURU SOĞAN", "TEREYAĞI", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 500}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Uşak Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ayvalık Usulü Zeytinli Ekmek Salatası', null, '**Hazırlık / Mise en Place**
1. Ekmeği küp doğrayın, domatesi küp doğrayın, zeytini iri kıyın.
2. Hepsini bir kapta karıştırıp zeytinyağı ve tuzla tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Ekmek doğranırken domates hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Urla Usulü Karidesli Zeytinyağlı Enginar', null, '**Hazırlık / Mise en Place**
1. Enginarları temizleyip dilimleyin, kararmaması için limonlu suda bekletin.
2. Karidesleri kabuklarından ayıklayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun. Enginarı ekleyip 3 dk çevirin. Karidesi ve tuzu ekleyip kapağı kapalı olarak enginar yumuşayıp karides pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ENGİNAR", "KARİDES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tire Usulü Köftesi (Fırında)', null, '**Hazırlık / Mise en Place**
1. Fırını 190°C''ye ısıtmaya başlayın.
2. Patatesleri soyup dilimleyin, domatesin kabuğunu soyup dilimleyin, kuru soğanı rendeleyin.
3. Kıyma, rendelenmiş soğanın yarısı, tuz ve karabiberi yoğurup yassı köfte şekli verin.

**Isıl İşlem**
1. Fırınlama (190°C, 20 dk): Patates dilimlerini fırın kabının tabanına yayın, köfteleri üzerine dizin, domates ve kalan soğanı araya yerleştirin. 190°C''ye önceden ısıtılmış fırında patatesler ve köfte pişip üzeri hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken malzemeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~12 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["DANA KIYMA", "PATATES", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ödemiş Usulü Patatesli Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk butunu parçalara ayırın, patatesleri soyup küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Sote (~90°C, tencerede, 25 dk): Zeytinyağında tavuğu her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Patatesi, tuz ve karabiberi ekleyip kapağı kapalı olarak tavuk ve patates yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken patates ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "PATATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kütahya Usulü Kirazlı Yoğurt', null, '**Hazırlık / Mise en Place**
1. Kirazları çekirdeklerinden ayırıp ikiye bölün.
2. Yoğurt ve şekeri pürüzsüz olana kadar çırpın, kirazları ekleyip karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Kiraz hazırlanırken yoğurt çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Isparta Usulü Gül Reçelli Yoğurt Tatlısı', null, '**Hazırlık / Mise en Place**
1. Yoğurdu servis kaselerine paylaştırın.
2. Üzerine balı gezdirip kırılmış cevizi serperek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Burdur Usulü Etli Nohutlu Pilav', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, nohut haşlanmışsa süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 27 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Pirinç ve nohudu, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~19 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 27, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "PİRİNÇ (HAM)", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Osmaniye Usulü Zeytinyağlı Yer Fıstıklı Salata', null, '**Hazırlık / Mise en Place**
1. Marulu ayıklayıp yıkayın, elinizle parçalayın.
2. Fındıkları kabaca kırın.
3. Marul ve fındığı bir kapta karıştırın, zeytinyağı, limon suyu ve tuzla tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Marul yıkanırken fındık kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tarsus Usulü Şalgamlı Köfte - basitleştirilmiş (Şalgam Hariç)', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyin.
2. Kıyma, rendelenmiş soğan, kimyon, tuz ve karabiberi iyice yoğurup ince uzun köfte şekli verin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada köfteleri her yüzü çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte harcı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "KURU SOĞAN", "KİMYON", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Manavgat Usulü Izgara Levrek', null, '**Hazırlık / Mise en Place**
1. Levreği temizletip pullarını aldırın, yıkayıp kurulayın.
2. Zeytinyağı, limon suyu ve tuzu karıştırıp balığın üzerine sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 15 dk): Iyice ısıtılmış ızgarada balığı her iki yüzü de eti kolayca kemikten ayrılana kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken balık hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LEVREK", "ZEYTİNYAĞI", "LİMON SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Side Usulü Zeytinyağlı Enginar Turşusu', null, '**Hazırlık / Mise en Place**
1. Enginarları temizleyip dörde bölün, kararmaması için limonlu suda bekletin. Temiz bir kavanoza yerleştirin, sarımsak dişlerini ekleyin.

**Isıl İşlem**
1. Sirke Kaynatma (~100°C, tencerede, 10 dk): Sirke ve tuzu bir tencerede kaynatın.
2. Son işlemler: Kaynar sirkeli karışımı kavanozdaki enginarların üzerine dökün, kapağını kapatıp oda sıcaklığında birkaç gün (bu süre özete dahil değildir) fermantasyona bırakın.

**PARALEL YAPILABİLİRLİK:** Sirke kaynarken enginar kavanoza yerleştirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~8 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sirke Kaynatma", "sure_dakika": 10, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SİRKE", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kumluca Usulü Zeytinyağlı Domates Yemeği', null, '**Hazırlık / Mise en Place**
1. Domatesin kabuğunu soyup iri küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 17 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ve tuzu ekleyip kapağı kapalı olarak kısık ateşte domates dağılıp koyulaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Portakallı Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın. Portakalın kabuğunu soyup dilimleyin, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Sote (~90°C, tavada, 20 dk): Zeytinyağında tavuğu her tarafı renk alana kadar 6-8 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Portakalı, tuz ve karabiberi ekleyip tavuk pişip portakal hafif yumuşayana kadar (~7-8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken portakal hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "PORTAKAL", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Eskişehir Usulü Çibörek (Kızartma)', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, az su ve tuzla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kuru soğanı rendeleyip kıymayla ve tuzla karıştırın.
3. Hamuru ince açıp daire şeklinde kesin, her daireye iç harç koyup yarım ay şeklinde kapatıp kenarlarını bastırın.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 20 dk): Mısır yağını tavada kızdırın. Çibörekleri her iki yüzü de altın rengi ve kıyma pişene kadar kızartın.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~15 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEKLİK UN", "DANA KIYMA", "KURU SOĞAN", "MISIR YAĞI", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 40}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kayseri Usulü Etli Ekmek (İnce)', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, az su ve tuzla yoğurup ince açılabilir bir hamur elde edin; üzerini örtüp 10 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kuru soğanı rendeleyin, domatesin kabuğunu soyup küçük küp doğrayın. Kıyma, soğan, domates, tuz ve pul biberi karıştırıp harcı hazırlayın.
3. Hamuru çok ince, uzun oval şekilde açıp üzerine harcı ince bir tabaka halinde yayın.

**Isıl İşlem**
1. Fırınlama (230°C, 10 dk): 230°C''ye önceden ısıtılmış, taş veya tepsi üzerinde hamurun kenarları kızarıp harç pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~5 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur ve Harç", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 10, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "KUZU KIYMA", "DOMATES", "KURU SOĞAN", "TUZ", "PUL BİBER", "SU"], "yeni_su_gram": 30}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ankara Usulü Zeytinyağlı Havuç ve Nohut', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Konya Usulü Etli Nohutlu Yahni', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Nevşehir Usulü Elmalı Kabaklı Tatlı', null, '**Hazırlık / Mise en Place**
1. Elma ve kabağı soyup ince dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Elma ve kabak dilimlerini şekerle bir tencerede katman katman dizin. Kısık ateşte kendi sularını bırakıp yumuşayana kadar pişirin.
2. Son işlemler: Ilıyınca üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "KABAK", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sivas Usulü Mantısı (Küçük Boy)', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, az tuzlu suyla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kuru soğanı rendeleyip kıyma ve tuzla karıştırın.
3. Hamuru ince açıp küçük kareler halinde kesin, her karenin ortasına az miktarda iç harç koyup dört köşesini ortada birleştirerek kapatın.
4. Sarımsaklı yoğurdu hazırlayıp bir kenarda bekletin.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 15 dk): Tencereye 150 ml (150 g) su koyup kaynatın, tuz ekleyin. Mantıları kaynayan suya azar azar bırakıp üstüne çıkıp hafif şişene kadar haşlayın.
2. Son işlemler: Mantıları süzüp servis tabağına alın, üzerine sarımsaklı yoğurdu, ardından eritilmiş tereyağını gezdirin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken iç harç ve sarımsaklı yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~45 dk · Pasif bekleme ~10 dk · Toplam ~55 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur ve Doldurma", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 15, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEKLİK UN", "KUZU KIYMA", "KURU SOĞAN", "TUZ", "SU", "TEREYAĞI"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Yozgat Usulü Zeytinyağlı Kuru Fasulye', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırşehir Usulü Nohutlu Ispanak Çorbası', null, '**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın. Nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında nohudu 2 dk çevirin. Sıcak tavuk suyu ve tuzu ekleyip kaynatın. Ispanağı ekleyip pörsüyüp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken ıspanak hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "ISPANAK", "TAVUK SUYU", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gümüşhane Usulü Kuru Fasulye (Etli)', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "DANA KIYMA", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kastamonu Usulü Tarhana Çorbası', null, '**Hazırlık / Mise en Place**
1. Tarhanayı birkaç kaşık soğuk tavuk suyuyla pürüzsüz bir bulamaç haline getirin.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Kalan tavuk suyunu kaynatın. Tarhana bulamacını ekleyip topaklanmadan karıştırarak kaynatın, tuzu ekleyip 12-15 dk kısık ateşte pişirin.
2. Son işlemler: Tereyağını eritip üzerine gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken tarhana bulamacı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TARHANA", "TAVUK SUYU", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bartın Usulü Pancarlı Pilav', null, '**Hazırlık / Mise en Place**
1. Pancarı soyup küçük küp doğrayın, pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında pancarı 3-4 dk çevirin. Pirinci ekleyip 2 dk çevirin. Sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekip pancar yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken pancar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PANCAR", "PİRİNÇ (HAM)", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karabük Usulü Etli Lahana Sarması', null, '**Hazırlık / Mise en Place**
1. Lahananın göbeğini oyup çıkarın, yapraklarını kaynar tuzlu suda yumuşayıp ayrılana kadar (bu süre aşağıdaki toplama dahil değildir) haşlayın, kalın orta damarları inceltin.
2. Pirinci yıkayıp süzün, kuru soğanı rendeleyin. Pirinç, soğan, kıyma, tuz ve karabiberi harmanlayın.
3. Harcı yapraklara paylaştırıp sarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Sarmaları tencereye sıkı dizin. 200 ml (200 g) sıcak su ekleyin, üzerine ters bir tabak kapatıp kapağı kapatın. Kaynayınca ateşi kısıp pirinç ve et tamamen pişip yapraklar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Yapraklar haşlanırken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~43 dk · Pasif bekleme ~17 dk · Toplam ~60 dk',
        '[{"sira": 1, "ad": "Hazırlık / Sarma", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LAHANA", "PİRİNÇ (HAM)", "DANA KIYMA", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Samsun Usulü Zeytinyağlı Karalahana', null, '**Hazırlık / Mise en Place**
1. Karalahanayı yıkayıp kalın sap kısımlarını ayırın, yapraklarını ince doğrayın. Kuru soğanı ince yarım ay dilimleyin, pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Pirinci ekleyip 1-2 dk çevirin. Tuzu ekleyip kısık ateşte pirinç yarı pişene kadar (~7 dk) pişirin. Karalahanayı ekleyip pörsüyüp pirinç tamamen pişene kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARALAHANA", "PİRİNÇ (HAM)", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Trabzon Usulü Vişne Ekşili Kuzu Yahnisi', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 40 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et yumuşamaya başlayana kadar (~25 dk) pişirin. Vişneleri ekleyip et tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Et pişerken vişneler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~30 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "VİŞNE", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Giresun Usulü Mısır Ekmekli Peynirli Tabak', null, '**Hazırlık / Mise en Place**
1. Hazır mısır ekmeğini dilimleyin.
2. Kaşarı dilimleyin veya ufalayın.
3. Mısır ekmeği ve kaşarı tabakta yan yana dizin, üzerine eritilmiş tereyağını gezdirerek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ordu Usulü Fındıklı Yoğurtlu Havuç Salatası', null, '**Hazırlık / Mise en Place**
1. Havuçları rendenin iri tarafıyla rendeleyin.
2. Sarımsağı ezip yoğurtla karıştırın. Havucu ekleyip karıştırın, üzerine kırılmış fındığı serperek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Havuç rendelenirken sarımsaklı yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bingöl Usulü Kuzu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 4-5 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tunceli Usulü Mırığı (Yoğurtlu Bulgur Aşı)', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarıp pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağında bulguru 2 dk çevirin. 150 ml (150 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), üzerine yoğurdu gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken yoğurt çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Hakkari Usulü Kuzu Etli Nohut Yemeği', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ardahan Usulü Kaşarlı Kete', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, ılık su, tuz ve tereyağının bir kısmıyla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kaşarı rendeleyin. Hamuru açıp bir yarısına rendelenmiş kaşarı yayın, katlayıp yuvarlak şekil verin.

**Isıl İşlem**
1. Fırınlama (200°C, 15 dk): Üzerine kalan tereyağını sürün. 200°C''ye önceden ısıtılmış fırında kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~10 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "KAŞAR PEYNİRİ", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 40}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Van Usulü Balı ile Kaymaklı Tatlı', null, '**Hazırlık / Mise en Place**
1. Kaymağı servis tabağına yayın.
2. Üzerine balı gezdirerek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzurum Usulü Zeytinyağlı Kuru Fasulye', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Malatya Usulü Kayısılı Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın, kuru soğanı ince yarım ay dilimleyin, kayısıları ikiye bölün.

**Isıl İşlem**
1. Sote (~90°C, tavada, 20 dk): Zeytinyağında tavuğu her tarafı renk alana kadar 6-8 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Kayısıları, tuz ve karabiberi ekleyip tavuk pişip kayısı yumuşayana kadar (~7-8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken kayısı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "KAYISI", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Elazığ Usulü Nohutlu Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında bulguru 2 dk çevirin. Nohudu, sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken bulgur ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "NOHUT", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Adıyaman Usulü Etli Nohutlu Bulgur Köftesi', null, '**Hazırlık / Mise en Place**
1. Bulguru ıslatıp yumuşamaya bırakın (bu süre aşağıdaki toplama dahildir). Nohut haşlanmışsa süzün.
2. Kuru soğanı rendeleyin. Kıyma, yumuşamış bulgur, nohut, soğan, tuz ve karabiberi yoğurup köfte şekli verin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 15 dk): Köfteleri 100 ml (100 g) sıcak suyla birlikte tencereye yerleştirin, kapağı kapatıp kısık ateşte köfteler pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Bulgur yumuşarken diğer malzemeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~38 dk · Pasif bekleme ~7 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 15, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "DANA KIYMA", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Pırasa ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şanlıurfa Usulü İçli Köfte (Büyük Boy)', null, '**Hazırlık / Mise en Place**
1. Bulguru ıslatıp yumuşamaya bırakın (bu süre aşağıdaki toplama dahildir).
2. İç harç için kıymanın yarısını kuru soğan, ceviz, tuz ve pul biberle kavurup soğutun.
3. Kalan kıyma ile ıslatılmış bulguru yoğurup dış hamuru elde edin; büyük boy köfte şekli verip ortasını iç harçla doldurarak kapatın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 20 dk): Tencereye 150 ml (150 g) su koyup kaynatın, tuz ekleyin. Köfteleri kaynayan suya bırakıp yüzeye çıkıp iyice pişene kadar haşlayın.

**PARALEL YAPILABİLİRLİK:** Haşlama suyu ısınırken köfteler şekillendirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~48 dk · Pasif bekleme ~12 dk · Toplam ~60 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "DANA KIYMA", "KURU SOĞAN", "CEVİZ (İÇ)", "PUL BİBER", "TUZ", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Diyarbakır Usulü Etli Nohutlu Şiveydiz - basitleştirilmiş', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, taze soğanı doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Taze soğanı ekleyip 3-4 dk çevirin. Nohudu, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken taze soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "TAZE SOĞAN", "NOHUT", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mardin Usulü Kaburgalı Nohut Çorbası', null, '**Hazırlık / Mise en Place**
1. Sığır kaburgayı parçalara ayırın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Kaburgaları kendi yağında her tarafı renk alana kadar 10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. 500 ml (500 g) sıcak su, nohut, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KABURGA", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 500}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Siirt Usulü Zeytinyağlı Nohutlu Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun. Patlıcanı ekleyip 5 dk çevirin. Domates ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Batman Usulü Kaşarlı Kuzu Güveç', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın, kaşarı rendeleyin.

**Isıl İşlem**
1. Pişirme (~95°C, güveç kabında, 40 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et tamamen yumuşayana kadar pişirin. Servisten hemen önce üzerine kaşarı serpip eriyene kadar (~2-3 dk) bekletin.

**PARALEL YAPILABİLİRLİK:** Et pişerken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~30 dk · Toplam ~55 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KAŞAR PEYNİRİ", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kilis Usulü Zeytinyağlı Biberli Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün. Yeşil biberi, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Biberi ekleyip 3 dk çevirin. Domatesi ekleyip 3 dk pişirin. Bulguru, 100 ml (100 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "YEŞİL BİBER", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
end $$;

-- Dogrulama: hazirlik_dakika = asama_toplami olmali VE her ISIL
-- asamada en az 1 baglı malzeme olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('Yalova Usulü Zeytinyağlı Kestane'),
    ('Bilecik Usulü Etli Nohutlu Bulgur'),
    ('Sakarya Usulü Mısırlı Tavuk Güveç'),
    ('Çorlu Usulü Kaşarlı Tavuklu Makarna'),
    ('Bursa Usulü Cevizli Erik Tatlısı'),
    ('İstanbul Usulü Zeytinyağlı Balkabağı'),
    ('Marmara Usulü Nohutlu Tavuk Çorbası'),
    ('Marmara Usulü Armutlu Ceviz Tatlısı'),
    ('Manisa Usulü Mesir Macunlu Tatlı - basitleştirilmiş'),
    ('Denizli Usulü Keşkek (Tavuklu)'),
    ('Uşak Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Ayvalık Usulü Zeytinli Ekmek Salatası'),
    ('Urla Usulü Karidesli Zeytinyağlı Enginar'),
    ('Tire Usulü Köftesi (Fırında)'),
    ('Ödemiş Usulü Patatesli Tavuk Sote'),
    ('Kütahya Usulü Kirazlı Yoğurt'),
    ('Isparta Usulü Gül Reçelli Yoğurt Tatlısı'),
    ('Burdur Usulü Etli Nohutlu Pilav'),
    ('Osmaniye Usulü Zeytinyağlı Yer Fıstıklı Salata'),
    ('Tarsus Usulü Şalgamlı Köfte - basitleştirilmiş (Şalgam Hariç)'),
    ('Manavgat Usulü Izgara Levrek'),
    ('Side Usulü Zeytinyağlı Enginar Turşusu'),
    ('Kumluca Usulü Zeytinyağlı Domates Yemeği'),
    ('Antalya Usulü Portakallı Tavuk Sote'),
    ('Eskişehir Usulü Çibörek (Kızartma)'),
    ('Kayseri Usulü Etli Ekmek (İnce)'),
    ('Ankara Usulü Zeytinyağlı Havuç ve Nohut'),
    ('Konya Usulü Etli Nohutlu Yahni'),
    ('Nevşehir Usulü Elmalı Kabaklı Tatlı'),
    ('Sivas Usulü Mantısı (Küçük Boy)'),
    ('Yozgat Usulü Zeytinyağlı Kuru Fasulye'),
    ('Kırşehir Usulü Nohutlu Ispanak Çorbası'),
    ('Gümüşhane Usulü Kuru Fasulye (Etli)'),
    ('Kastamonu Usulü Tarhana Çorbası'),
    ('Bartın Usulü Pancarlı Pilav'),
    ('Karabük Usulü Etli Lahana Sarması'),
    ('Samsun Usulü Zeytinyağlı Karalahana'),
    ('Trabzon Usulü Vişne Ekşili Kuzu Yahnisi'),
    ('Giresun Usulü Mısır Ekmekli Peynirli Tabak'),
    ('Ordu Usulü Fındıklı Yoğurtlu Havuç Salatası'),
    ('Bingöl Usulü Kuzu Kavurma'),
    ('Tunceli Usulü Mırığı (Yoğurtlu Bulgur Aşı)'),
    ('Hakkari Usulü Kuzu Etli Nohut Yemeği'),
    ('Ardahan Usulü Kaşarlı Kete'),
    ('Van Usulü Balı ile Kaymaklı Tatlı'),
    ('Erzurum Usulü Zeytinyağlı Kuru Fasulye'),
    ('Malatya Usulü Kayısılı Tavuk Sote'),
    ('Elazığ Usulü Nohutlu Bulgur Pilavı'),
    ('Adıyaman Usulü Etli Nohutlu Bulgur Köftesi'),
    ('Gaziantep Usulü Zeytinyağlı Nohutlu Pırasa'),
    ('Şanlıurfa Usulü İçli Köfte (Büyük Boy)'),
    ('Diyarbakır Usulü Etli Nohutlu Şiveydiz - basitleştirilmiş'),
    ('Mardin Usulü Kaburgalı Nohut Çorbası'),
    ('Siirt Usulü Zeytinyağlı Nohutlu Patlıcan'),
    ('Batman Usulü Kaşarlı Kuzu Güveç'),
    ('Kilis Usulü Zeytinyağlı Biberli Bulgur')
)
select r.ad, r.hazirlik_dakika,
    (select coalesce(sum(a.sure_dakika),0) from recete_asamalari a where a.recete_id = r.id) as asama_toplami,
    (select count(*) from recete_asamalari a where a.recete_id = r.id and a.isil_islem_mi
       and not exists (select 1 from asama_malzemeleri am where am.asama_id = a.id)) as bos_isil_asama_sayisi
from liste l
join receteler r on r.ad = l.ad and r.isletme_id is null
where r.hazirlik_dakika <> (select coalesce(sum(a.sure_dakika),0) from recete_asamalari a where a.recete_id = r.id)
   or exists (select 1 from recete_asamalari a where a.recete_id = r.id and a.isil_islem_mi
              and not exists (select 1 from asama_malzemeleri am where am.asama_id = a.id))
order by r.ad;
