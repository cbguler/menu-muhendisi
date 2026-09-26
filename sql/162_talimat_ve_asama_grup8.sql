-- 162_talimat_ve_asama_grup8.sql
-- 515 yeni tarifin talimat+asama yazimi -- Grup 8: Parti7(tarif-
-- ekleme)'nin 56 tarifi, 7 bolgeye esit.
-- Ayni _talimat_ve_asama_ekle_v2 fonksiyonu (155-161 ile ayni).
-- Su eklemeleri orijinal Parti7 malzeme listeleriyle CAPRAZ
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
        'İstanbul Usulü Zeytinyağlı Enginar Turşusu', null, '**Hazırlık / Mise en Place**
1. Enginarları temizleyip dörde bölün, kararmaması için limonlu suda bekletin. Temiz bir kavanoza yerleştirin, soyulmuş sarımsak dişlerini ekleyin.

**Isıl İşlem**
1. Sirke Kaynatma (~100°C, tencerede, 10 dk): Sirke ve tuzu bir tencerede kaynatın.
2. Son işlemler: Kaynar sirkeli karışımı kavanozdaki enginarların üzerine dökün, kapağını kapatıp oda sıcaklığında birkaç gün (bu süre özete dahil değildir) fermantasyona bırakın.

**PARALEL YAPILABİLİRLİK:** Sirke kaynarken enginar kavanoza yerleştirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~8 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sirke Kaynatma", "sure_dakika": 10, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SİRKE", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bursa Usulü Etli Nohutlu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı küçük küp doğrayın, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 22 dk): Kıymayı kendi yağında suyunu salıp çekene kadar 12-15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, tuz ve karabiberi ekleyip 3-4 dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken soğan ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 22, "aktif_dakika": 22, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırklareli Usulü Elmalı Tatlı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 20 dk): Elma dilimlerini, şekeri ve tarçını bir tencerede kısık ateşte kendi suyunu bırakıp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme ~18 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER", "TARÇIN"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Kereviz ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte kereviz yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çanakkale Usulü Izgara Levrek', null, '**Hazırlık / Mise en Place**
1. Levreği temizletip pullarını aldırın, yıkayıp kurulayın.
2. Zeytinyağı, limon suyu ve tuzu karıştırıp balığın üzerine sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 15 dk): Iyice ısıtılmış ızgarada balığı her iki yüzü de eti kolayca kemikten ayrılana kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken balık hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LEVREK", "ZEYTİNYAĞI", "LİMON SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Balıkesir Usulü Kavurmalı Yumurta', null, '**Hazırlık / Mise en Place**
1. Yumurtaları çırpın.

**Isıl İşlem**
1. Pişirme (~85°C, tavada, 10 dk): Tereyağında kıymayı suyunu salıp çekene kadar 5-6 dk kavurun. Çırpılmış yumurtaları ve tuzu ekleyip karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken yumurta çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Zeytinyağlı Kabaklı Pirinç', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, pirinci yıkayıp süzün, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Kabak ve pirinci, tuzu ekleyip kapağı kapalı olarak kısık ateşte kabak ve pirinç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "PİRİNÇ (HAM)", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İstanbul Usulü Kirazlı Yoğurt Tatlısı', null, '**Hazırlık / Mise en Place**
1. Kirazları çekirdeklerinden ayırıp ikiye bölün.
2. Yoğurt ve şekeri pürüzsüz olana kadar çırpın, kirazları ekleyip karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Kiraz hazırlanırken yoğurt çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İzmir Usulü Zeytinyağlı Kabaklı Nohut', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Kabak ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte kabak yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muğla Usulü Etli Bakla', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Baklaları ayıklayıp yıkayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Baklaları, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve bakla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken bakla hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~15 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "BAKLA", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bodrum Usulü Portakallı Zeytinyağlı Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın. Portakalın kabuğunu soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında kereviği 3-4 dk çevirin, şekeri ekleyip 1 dk karıştırın. Tuzu ekleyip kapağı kapalı olarak kısık ateşte kereviz yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp portakal dilimlerini ekleyerek soğuk servis edin (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Kereviz pişerken portakal hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Datça Usulü Izgara Karides', null, '**Hazırlık / Mise en Place**
1. Karidesleri kabuklarından ayıklayın.
2. Zeytinyağı, ezilmiş sarımsak, limon suyu ve tuzla marine edin; 5 dk (bu süre aşağıdaki toplama dahildir) bekletin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada veya tavada, 12 dk): Karidesleri her yüzü pembeleşip pişene kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken karidesler marine edilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~5 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARİDES", "ZEYTİNYAĞI", "SARIMSAK", "LİMON SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kuşadası Usulü Etli Enginar', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın. Enginarları dilimleyin, kararmaması için limonlu suda bekletin, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Enginarı, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve enginar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken enginar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~15 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "ENGİNAR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Foça Usulü Zeytinyağlı Nohutlu Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Pırasa ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ödemiş Usulü Nohutlu Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk butunu parçalara ayırın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Sote (~95°C, tencerede, 22 dk): Tavuğu kendi yağında her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Nohudu, tuz ve karabiberi ekleyip tavuk pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken nohut ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~12 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 22, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tire Usulü Üzümlü Ceviz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Üzümleri yıkayıp tanelerini ayırın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 10 dk): Üzüm ve şekeri bir tencerede kısık ateşte az suyla (kendi suyunu bırakacaktır) 8-10 dk pişirin.
2. Son işlemler: Ilıyınca üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Üzüm pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~6 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ÜZÜM", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Zeytinyağlı Nohutlu Bakla', null, '**Hazırlık / Mise en Place**
1. Baklaları ayıklayıp yıkayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Bakla ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte bakla yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAKLA", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mersin Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Adana Usulü Zeytinyağlı Biberli Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın, yeşil biberi doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Patlıcan ve biberi ekleyip 5 dk çevirin. Domatesi ve tuzu ekleyip kapağı kapalı olarak kısık ateşte patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "YEŞİL BİBER", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Hatay Usulü Etli Nohutlu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı küçük küp doğrayın, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 22 dk): Kıymayı kendi yağında suyunu salıp çekene kadar 12-15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, tuz ve karabiberi ekleyip 3-4 dk daha pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken soğan ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 22, "aktif_dakika": 22, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Silifke Usulü Zeytinyağlı Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kereviz ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte sebzeler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Anamur Usulü Izgara Karides', null, '**Hazırlık / Mise en Place**
1. Karidesleri kabuklarından ayıklayın.
2. Zeytinyağı, ezilmiş sarımsak, limon suyu ve tuzla marine edin; 5 dk (bu süre aşağıdaki toplama dahildir) bekletin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada veya tavada, 12 dk): Karidesleri her yüzü pembeleşip pişene kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken karidesler marine edilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~5 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARİDES", "ZEYTİNYAĞI", "SARIMSAK", "LİMON SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kaş Usulü Portakallı Zeytinyağlı Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın. Portakalın kabuğunu soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında havucu 2-3 dk çevirin, şekeri ekleyip 1 dk karıştırın. Tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp portakal dilimlerini ekleyerek soğuk servis edin (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Havuç pişerken portakal hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Alanya Usulü Kavurmalı Yumurta', null, '**Hazırlık / Mise en Place**
1. Yumurtaları çırpın.

**Isıl İşlem**
1. Pişirme (~85°C, tavada, 10 dk): Tereyağında kıymayı suyunu salıp çekene kadar 5-6 dk kavurun. Çırpılmış yumurtaları ve tuzu ekleyip karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken yumurta çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ankara Usulü Zeytinyağlı Nohutlu Bamya', null, '**Hazırlık / Mise en Place**
1. Bamyaların saplarını temizleyin, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bamya ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte bamya yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAMYA", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Konya Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kayseri Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sivas Usulü Etli Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulguru, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "BULGUR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Niğde Usulü Kayısılı Komposto', null, '**Hazırlık / Mise en Place**
1. Kayısıları yıkayıp ikiye bölün, çekirdeklerini çıkarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): 70 ml (70 g) su ve şekeri kaynatın. Kayısıları ekleyip kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KAYISI", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Patlıcanı ekleyip 5 dk çevirin. Domates ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırşehir Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çorum Usulü Zeytinyağlı Nohut', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu ve tuzu ekleyip kapağı kapalı olarak kısık ateşte lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Trabzon Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Rize Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Samsun Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Giresun Usulü Elmalı Fındıklı Tatlı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 20 dk): Elma dilimlerini ve şekeri bir tencerede kısık ateşte kendi suyunu bırakıp yumuşayana kadar pişirin.
2. Son işlemler: Üzerine kırılmış fındığı serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Elma pişerken fındık kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~12 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ordu Usulü Etli Lahana', null, '**Hazırlık / Mise en Place**
1. Lahanayı ince doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Lahanayı, tuz ve karabiberi ekleyip kapağı kapalı olarak lahana pörsüyüp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken lahana doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LAHANA", "DANA KIYMA", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Artvin Usulü Zeytinyağlı Kuru Fasulye', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bayburt Usulü Kavurmalı Yumurta', null, '**Hazırlık / Mise en Place**
1. Yumurtaları çırpın.

**Isıl İşlem**
1. Pişirme (~85°C, tavada, 10 dk): Tereyağında kıymayı suyunu salıp çekene kadar 5-6 dk kavurun. Çırpılmış yumurtaları ve tuzu ekleyip karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken yumurta çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tokat Usulü Zeytinyağlı Kabak', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Kabağı ve tuzu ekleyip kapağı kapalı olarak kısık ateşte kabak yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzurum Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzincan Usulü Zeytinyağlı Nohut', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu ve tuzu ekleyip kapağı kapalı olarak kısık ateşte lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Van Usulü Elmalı Ceviz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 17 dk): Elma dilimlerini ve şekeri bir tencerede kısık ateşte kendi suyunu bırakıp yumuşayana kadar pişirin.
2. Son işlemler: Üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Elma pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~9 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kars Usulü Zeytinyağlı Pırasa', null, '**Hazırlık / Mise en Place**
1. Pırasayı temizleyip ince halkalar halinde doğrayın, havucu kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Pırasa ve havucu, tuzu ekleyip kapağı kapalı olarak kısık ateşte pırasa yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PIRASA", "HAVUÇ", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ağrı Usulü Kavurmalı Yumurta', null, '**Hazırlık / Mise en Place**
1. Yumurtaları çırpın.

**Isıl İşlem**
1. Pişirme (~85°C, tavada, 10 dk): Tereyağında kıymayı suyunu salıp çekene kadar 5-6 dk kavurun. Çırpılmış yumurtaları ve tuzu ekleyip karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken yumurta çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muş Usulü Etli Nohutlu Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, nohut haşlanmışsa süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulgur ve nohudu, 100 ml (100 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "BULGUR", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Malatya Usulü Zeytinyağlı Nohutlu Havuç', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Havucu ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte havuç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAVUÇ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Elazığ Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gaziantep Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, pul biber, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "PUL BİBER", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, yeşil biberi doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Biberi ekleyip 3 dk çevirin. Domatesi ekleyip 3 dk pişirin. Bulguru, 100 ml (100 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "YEŞİL BİBER", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Diyarbakır Usulü Nar Ekşili Etli Kabak', null, '**Hazırlık / Mise en Place**
1. Kabağı kalın küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Kabak, nar ekşisi, tuz ve karabiberi ekleyip kapağı kapalı olarak kabak yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken kabak doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "KABAK", "NAR EKŞİSİ", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mardin Usulü Etli Nohutlu Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, nohut haşlanmışsa süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulgur ve nohudu, 100 ml (100 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "BULGUR", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Siirt Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Batman Usulü Zeytinyağlı Nohutlu Patlıcan', null, '**Hazırlık / Mise en Place**
1. Patlıcanı kalın küp doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Patlıcanı ekleyip 5 dk çevirin. Domates ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte patlıcan yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken servis hazırlıkları yapılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şırnak Usulü Etli Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 20 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kilis Usulü Zeytinyağlı Nohutlu Kereviz', null, '**Hazırlık / Mise en Place**
1. Kereviği soyup küçük küp doğrayın, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Kereviz ve nohudu, tuzu ekleyip kapağı kapalı olarak kısık ateşte kereviz yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KEREVİZ", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
end $$;

-- Dogrulama: hazirlik_dakika = asama_toplami olmali VE her ISIL
-- asamada en az 1 baglı malzeme olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('İstanbul Usulü Zeytinyağlı Enginar Turşusu'),
    ('Bursa Usulü Etli Nohutlu Kavurma'),
    ('Kırklareli Usulü Elmalı Tatlı'),
    ('Tekirdağ Usulü Zeytinyağlı Nohutlu Kereviz'),
    ('Çanakkale Usulü Izgara Levrek'),
    ('Balıkesir Usulü Kavurmalı Yumurta'),
    ('Marmara Usulü Zeytinyağlı Kabaklı Pirinç'),
    ('İstanbul Usulü Kirazlı Yoğurt Tatlısı'),
    ('İzmir Usulü Zeytinyağlı Kabaklı Nohut'),
    ('Muğla Usulü Etli Bakla'),
    ('Bodrum Usulü Portakallı Zeytinyağlı Kereviz'),
    ('Datça Usulü Izgara Karides'),
    ('Kuşadası Usulü Etli Enginar'),
    ('Foça Usulü Zeytinyağlı Nohutlu Pırasa'),
    ('Ödemiş Usulü Nohutlu Tavuk Sote'),
    ('Tire Usulü Üzümlü Ceviz Tatlısı'),
    ('Antalya Usulü Zeytinyağlı Nohutlu Bakla'),
    ('Mersin Usulü Etli Kavurma'),
    ('Adana Usulü Zeytinyağlı Biberli Patlıcan'),
    ('Hatay Usulü Etli Nohutlu Kavurma'),
    ('Silifke Usulü Zeytinyağlı Kereviz'),
    ('Anamur Usulü Izgara Karides'),
    ('Kaş Usulü Portakallı Zeytinyağlı Havuç'),
    ('Alanya Usulü Kavurmalı Yumurta'),
    ('Ankara Usulü Zeytinyağlı Nohutlu Bamya'),
    ('Konya Usulü Etli Kavurma'),
    ('Kayseri Usulü Zeytinyağlı Pırasa'),
    ('Sivas Usulü Etli Bulgur Pilavı'),
    ('Niğde Usulü Kayısılı Komposto'),
    ('Aksaray Usulü Zeytinyağlı Nohutlu Patlıcan'),
    ('Kırşehir Usulü Etli Kavurma'),
    ('Çorum Usulü Zeytinyağlı Nohut'),
    ('Trabzon Usulü Zeytinyağlı Pırasa'),
    ('Rize Usulü Etli Kavurma'),
    ('Samsun Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Giresun Usulü Elmalı Fındıklı Tatlı'),
    ('Ordu Usulü Etli Lahana'),
    ('Artvin Usulü Zeytinyağlı Kuru Fasulye'),
    ('Bayburt Usulü Kavurmalı Yumurta'),
    ('Tokat Usulü Zeytinyağlı Kabak'),
    ('Erzurum Usulü Etli Kavurma'),
    ('Erzincan Usulü Zeytinyağlı Nohut'),
    ('Van Usulü Elmalı Ceviz Tatlısı'),
    ('Kars Usulü Zeytinyağlı Pırasa'),
    ('Ağrı Usulü Kavurmalı Yumurta'),
    ('Muş Usulü Etli Nohutlu Bulgur'),
    ('Malatya Usulü Zeytinyağlı Nohutlu Havuç'),
    ('Elazığ Usulü Etli Kavurma'),
    ('Gaziantep Usulü Etli Kavurma'),
    ('Şanlıurfa Usulü Zeytinyağlı Biberli Bulgur'),
    ('Diyarbakır Usulü Nar Ekşili Etli Kabak'),
    ('Mardin Usulü Etli Nohutlu Bulgur'),
    ('Siirt Usulü Etli Kavurma'),
    ('Batman Usulü Zeytinyağlı Nohutlu Patlıcan'),
    ('Şırnak Usulü Etli Kavurma'),
    ('Kilis Usulü Zeytinyağlı Nohutlu Kereviz')
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
