-- 161_talimat_ve_asama_grup7.sql
-- 515 yeni tarifin talimat+asama yazimi -- Grup 7: Parti6(tarif-
-- ekleme)'nin 56 tarifi, 7 bolgeye esit.
-- Ayni _talimat_ve_asama_ekle_v2 fonksiyonu (155-160 ile ayni).
-- Su eklemeleri orijinal Parti6 malzeme listeleriyle CAPRAZ
-- KONTROL EDILEREK dogrulandi. Hazirlik_dakika duzeltmesi YOK.

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
        'İstanbul Usulü Zeytinyağlı Fırın Patates', null, '**Hazırlık / Mise en Place**
1. Fırını 200°C''ye ısıtmaya başlayın.
2. Patatesleri iyice yıkayın, kabuklu şekilde iri dilimler halinde kesin.
3. Zeytinyağı, kekik ve tuzla karıştırıp patateslere bulayın.

**Isıl İşlem**
1. Fırınlama (200°C, 35 dk): Patatesleri fırın tepsisine tek sıra halinde dizin. 200°C''ye önceden ısıtılmış fırında altın rengi ve içi yumuşayana kadar arada çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken patatesler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~27 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 35, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["PATATES", "ZEYTİNYAĞI", "KEKİK", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bursa Usulü Nar Ekşili Kırmızı Lahana Salatası', null, '**Hazırlık / Mise en Place**
1. Kırmızı lahanayı ince doğrayın.
2. Nar ekşisi, zeytinyağı ve tuzla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kocaeli Usulü Zeytinyağlı Kabak Yemeği', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3-4 dk pişirin. Kabağı ve tuzu ekleyip kapağı kapalı olarak kısık ateşte kabak yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tekirdağ Usulü Kirazlı Komposto', null, '**Hazırlık / Mise en Place**
1. Kirazları çekirdeklerinden ayırın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): 60 ml (60 g) su ve şekeri kaynatın. Kirazları ekleyip kısık ateşte 8-10 dk pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KİRAZ", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çanakkale Usulü Etli Enginar', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Enginarları dilimleyin, kararmaması için limonlu suda bekletin, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Enginarı, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve enginar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken enginar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~15 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "ENGİNAR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Balıkesir Usulü Zeytinyağlı Patates', null, '**Hazırlık / Mise en Place**
1. Patatesleri soyup kalın küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Patatesi ve tuzu ekleyip kapağı kapalı olarak kısık ateşte patates yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATATES", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Vişne Ekşili Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Sote (~90°C, tavada, 20 dk): Zeytinyağında tavuğu her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Vişneleri, tuz ve karabiberi ekleyip tavuk pişip vişneler yumuşayana kadar (~7-8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken vişneler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "VİŞNE", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İstanbul Usulü Zeytinyağlı Bezelye', null, '**Hazırlık / Mise en Place**
1. Havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Havucu ekleyip 2-3 dk çevirin. Bezelyeyi ve tuzu ekleyip kapağı kapalı olarak sebzeler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BEZELYE", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İzmir Usulü Etli Bamya', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Bamyaların saplarını temizleyin, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bamyaları, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve bamyalar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "BAMYA", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muğla Usulü Zeytinyağlı Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kereviz ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte sebzeler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Aydın Usulü İncirli Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın, kuru soğanı ince yarım ay dilimleyin, kuru incirleri ikiye bölün.

**Isıl İşlem**
1. Sote (~90°C, tavada, 20 dk): Zeytinyağında tavuğu her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. İncirleri, tuz ve karabiberi ekleyip tavuk pişip incirler yumuşayana kadar (~7-8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken incirler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "KURU İNCİR", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Denizli Usulü Etli Nohutlu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı küçük küp doğrayın, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 22 dk): Kıymayı kendi yağında suyunu salıp çekene kadar 12-15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, tuz ve karabiberi ekleyip 3-4 dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken soğan ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 22, "aktif_dakika": 22, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bodrum Usulü Izgara Levrek', null, '**Hazırlık / Mise en Place**
1. Levreği temizletip pullarını aldırın, yıkayıp kurulayın.
2. Zeytinyağı, limon suyu, kekik ve tuzu karıştırıp balığın üzerine sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 15 dk): Iyice ısıtılmış ızgarada balığı her iki yüzü de eti kolayca kemikten ayrılana kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken balık hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LEVREK", "ZEYTİNYAĞI", "LİMON SUYU", "KEKİK", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Foça Usulü Ahtapotlu Zeytinyağlı Salata', null, '**Hazırlık / Mise en Place**
1. Ahtapotu akan soğuk su altında yıkayın; gözlerini ve ağızdaki sert gagayı çıkarın.

**Isıl İşlem**
1. Haşlama (~90°C, tencerede, 12 dk): Tencereye 300 ml (300 g) su koyup kaynatın. Ahtapotu suya daldırıp çıkarma işlemini birkaç kez tekrarlayın, sonra tamamen batırıp çatal rahatça batana kadar haşlayın.
2. Son işlemler: Süzüp ılıyınca ince dilimleyin, zeytinyağı, limon suyu, maydanoz ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Ahtapot haşlanırken sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~6 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 12, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AHTAPOT", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Söke Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ege Usulü Ayvalı Ceviz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Ayvaları soyup çekirdek evlerini çıkararak dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 20 dk): Ayva dilimlerini ve şekeri bir tencerede az suyla (kendi suyunu bırakacaktır) kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Ayva pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~12 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AYVA", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Etli Kabak', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Kabak ve domatesi, tuz ve karabiberi ekleyip kapağı kapalı olarak kabak yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KABAK", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mersin Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Adana Usulü Izgara Tavuk Kanat', null, '**Hazırlık / Mise en Place**
1. Tavuk kanatlarını yıkayıp kurulayın.
2. Pul biber, ezilmiş sarımsak, zeytinyağı ve tuzla marine edin; 10 dk (bu süre aşağıdaki toplama dahildir) bekletin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 25 dk): Iyice ısıtılmış ızgarada kanatları her yüzü altın rengi ve içi pişene kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken kanatlar marine edilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~10 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK KANAT", "PUL BİBER", "SARIMSAK", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Hatay Usulü Nar Ekşili Etli Bamya', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Bamyaların saplarını temizleyin, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bamyaları, nar ekşisi, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve bamyalar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken bamya ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "BAMYA", "NAR EKŞİSİ", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kaş Usulü Zeytinyağlı Ahtapot Salatası', null, '**Hazırlık / Mise en Place**
1. Ahtapotu akan soğuk su altında yıkayın; gözlerini ve ağızdaki sert gagayı çıkarın.

**Isıl İşlem**
1. Haşlama (~90°C, tencerede, 12 dk): Tencereye 300 ml (300 g) su koyup kaynatın. Ahtapotu birkaç kez suya daldırıp çıkarın, sonra tamamen batırıp çatal rahatça batana kadar haşlayın.
2. Son işlemler: Süzüp ılıyınca ince dilimleyin, zeytinyağı, limon suyu ve tuzla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Ahtapot haşlanırken sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~6 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 12, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AHTAPOT", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Alanya Usulü Portakallı Zeytinyağlı Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın. Portakalın kabuğunu soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında havucu 2-3 dk çevirin, şekeri ekleyip 1 dk karıştırın. Tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp portakal dilimlerini ekleyerek soğuk servis edin (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Havuç pişerken portakal hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Silifke Usulü Etli Nohutlu Yahni', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kahramanmaraş Usulü Zeytinyağlı Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Patlıcanı ekleyip 5 dk çevirin. Domatesi ve tuzu ekleyip kapağı kapalı olarak kısık ateşte patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ankara Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Konya Usulü Etli Kabak Yemeği', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Kabak ve domatesi, tuz ve karabiberi ekleyip kapağı kapalı olarak kabak yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KABAK", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kayseri Usulü Elmalı Pekmezli Tatlı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): Elma dilimlerini ve pekmezi bir tencerede kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Elma pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ÜzÜM PEKMEZİ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sivas Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Yozgat Usulü Etli Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulguru, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "BULGUR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Niğde Usulü Zeytinyağlı Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kereviz ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte sebzeler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karaman Usulü Kayısılı Tavuk Güveç', null, '**Hazırlık / Mise en Place**
1. Tavuk butunu parçalara ayırın, kayısıları ikiye bölün, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Tavuğu kendi yağında her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Kayısı ve domatesi, tuz ve karabiberi ekleyip kapağı kapalı olarak tavuk pişip kayısılar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken kayısı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "KAYISI", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya', null, '**Hazırlık / Mise en Place**
1. Bamyaların saplarını temizleyin, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bamya ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte bamya yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAMYA", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Trabzon Usulü Etli Karalahana', null, '**Hazırlık / Mise en Place**
1. Karalahanayı yıkayıp kalın sap kısımlarını ayırın, ince doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Karalahanayı, tuz ve karabiberi ekleyip kapağı kapalı olarak lahana pörsüyüp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken lahana doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KARALAHANA", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Rize Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Samsun Usulü Elmalı Tatlı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 20 dk): Elma dilimlerini ve şekeri bir tencerede tarçınla birlikte kısık ateşte kendi suyunu bırakıp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme ~18 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER", "TARÇIN"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Giresun Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ordu Usulü Zeytinyağlı Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kereviz ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte sebzeler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Artvin Usulü Cevizli Bal Tatlısı', null, '**Hazırlık / Mise en Place**
1. Cevizleri kabaca kırıp servis kaselerine paylaştırın.
2. Üzerine balı gezdirerek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bayburt Usulü Zeytinyağlı Nohut', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu ve tuzu ekleyip kapağı kapalı olarak kısık ateşte lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tokat Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzurum Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Van Usulü Etli Nohutlu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kars Usulü Elmalı Ceviz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 17 dk): Elma dilimlerini ve şekeri bir tencerede kısık ateşte kendi suyunu bırakıp yumuşayana kadar pişirin.
2. Son işlemler: Üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Elma pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~9 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ağrı Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Koyun etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muş Usulü Zeytinyağlı Nohut', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu ve tuzu ekleyip kapağı kapalı olarak kısık ateşte lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Malatya Usulü Etli Kayısılı Bamya', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Bamyaların saplarını temizleyin, kuru kayısıları ikiye bölün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bamya ve kayısıları, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve bamyalar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken bamya ve kayısı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "BAMYA", "KURU KAYISI", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Elazığ Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bitlis Usulü Etli Nohutlu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı küçük küp doğrayın, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, tuz ve karabiberi ekleyip 5-6 dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken soğan ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gaziantep Usulü Nar Ekşili Etli Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Patlıcanı, nar ekşisi, tuz ve karabiberi ekleyip kapağı kapalı olarak patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken patlıcan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~15 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "PATLICAN", "NAR EKŞİSİ", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şanlıurfa Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, pul biber, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "PUL BİBER", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mardin Usulü Etli Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulguru, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~15 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "BULGUR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Siirt Usulü Zeytinyağlı Nohutlu Bamya', null, '**Hazırlık / Mise en Place**
1. Bamyaların saplarını temizleyin, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bamya ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte bamya yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAMYA", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Batman Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şırnak Usulü Zeytinyağlı Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Patlıcanı ekleyip 5 dk çevirin. Domatesi ve tuzu ekleyip kapağı kapalı olarak kısık ateşte patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kilis Usulü Nar Ekşili Zeytinyağlı Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bulguru, nar ekşisi, 100 ml (100 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "NAR EKŞİSİ", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
end $$;

-- Dogrulama: hazirlik_dakika = asama_toplami olmali VE her ISIL
-- asamada en az 1 baglı malzeme olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('İstanbul Usulü Zeytinyağlı Fırın Patates'),
    ('Bursa Usulü Nar Ekşili Kırmızı Lahana Salatası'),
    ('Kocaeli Usulü Zeytinyağlı Kabak Yemeği'),
    ('Tekirdağ Usulü Kirazlı Komposto'),
    ('Çanakkale Usulü Etli Enginar'),
    ('Balıkesir Usulü Zeytinyağlı Patates'),
    ('Marmara Usulü Vişne Ekşili Tavuk Sote'),
    ('İstanbul Usulü Zeytinyağlı Bezelye'),
    ('İzmir Usulü Etli Bamya'),
    ('Muğla Usulü Zeytinyağlı Kereviz'),
    ('Aydın Usulü İncirli Tavuk Sote'),
    ('Denizli Usulü Etli Nohutlu Kavurma'),
    ('Bodrum Usulü Izgara Levrek'),
    ('Foça Usulü Ahtapotlu Zeytinyağlı Salata'),
    ('Söke Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Ege Usulü Ayvalı Ceviz Tatlısı'),
    ('Antalya Usulü Etli Kabak'),
    ('Mersin Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Adana Usulü Izgara Tavuk Kanat'),
    ('Hatay Usulü Nar Ekşili Etli Bamya'),
    ('Kaş Usulü Zeytinyağlı Ahtapot Salatası'),
    ('Alanya Usulü Portakallı Zeytinyağlı Havuç'),
    ('Silifke Usulü Etli Nohutlu Yahni'),
    ('Kahramanmaraş Usulü Zeytinyağlı Patlıcan'),
    ('Ankara Usulü Zeytinyağlı Pırasa'),
    ('Konya Usulü Etli Kabak Yemeği'),
    ('Kayseri Usulü Elmalı Pekmezli Tatlı'),
    ('Sivas Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Yozgat Usulü Etli Bulgur Pilavı'),
    ('Niğde Usulü Zeytinyağlı Kereviz'),
    ('Karaman Usulü Kayısılı Tavuk Güveç'),
    ('Kırıkkale Usulü Zeytinyağlı Nohutlu Bamya'),
    ('Trabzon Usulü Etli Karalahana'),
    ('Rize Usulü Zeytinyağlı Pırasa'),
    ('Samsun Usulü Elmalı Tatlı'),
    ('Giresun Usulü Etli Kavurma'),
    ('Ordu Usulü Zeytinyağlı Kereviz'),
    ('Artvin Usulü Cevizli Bal Tatlısı'),
    ('Bayburt Usulü Zeytinyağlı Nohut'),
    ('Tokat Usulü Etli Kavurma'),
    ('Erzurum Usulü Zeytinyağlı Pırasa'),
    ('Van Usulü Etli Nohutlu Kavurma'),
    ('Kars Usulü Elmalı Ceviz Tatlısı'),
    ('Ağrı Usulü Etli Kavurma'),
    ('Muş Usulü Zeytinyağlı Nohut'),
    ('Malatya Usulü Etli Kayısılı Bamya'),
    ('Elazığ Usulü Zeytinyağlı Pırasa'),
    ('Bitlis Usulü Etli Nohutlu Kavurma'),
    ('Gaziantep Usulü Nar Ekşili Etli Patlıcan'),
    ('Şanlıurfa Usulü Etli Kavurma'),
    ('Diyarbakır Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Mardin Usulü Etli Bulgur Pilavı'),
    ('Siirt Usulü Zeytinyağlı Nohutlu Bamya'),
    ('Batman Usulü Etli Kavurma'),
    ('Şırnak Usulü Zeytinyağlı Patlıcan'),
    ('Kilis Usulü Nar Ekşili Zeytinyağlı Bulgur')
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
