-- 158_talimat_ve_asama_grup4.sql
-- 515 yeni tarifin talimat+asama yazimi -- Grup 4: Parti3(tarif-
-- ekleme)'nin 56 tarifi, 7 bolgeye esit.
-- Ayni _talimat_ve_asama_ekle_v2 fonksiyonu (155/156/157 ile ayni).
-- Su eklemeleri orijinal Parti3 malzeme listeleriyle CAPRAZ
-- KONTROL EDILEREK dogrulandi.
-- 1 tarifte hazirlik_dakika duzeltildi: Siirt Usulü Kaburga Kavurma
-- 40->60 (kemikli kaburganin gercekci pisirme suresi icin).

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
        'Balıkesir Usulü Keşkek', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün.
2. Kuzu etini 3-4 cm parçalar halinde doğrayın, kuru soğanı iri dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 75 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. 600 ml (600 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et neredeyse dağılacak kadar yumuşayana kadar (~45 dk) pişirin. Bulguru ekleyip su iyice çekilene, et ve bulgur bulamaç kıvamına gelene kadar (~25-30 dk) karıştırarak pişirmeye devam edin.
2. Son işlemler: Servis öncesi tereyağını eritip üzerine gezdirin.

**PARALEL YAPILABİLİRLİK:** Et pişerken bulgur yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~65 dk · Toplam ~90 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 75, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "BULGUR", "KURU SOĞAN", "TEREYAĞI", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 600}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çanakkale Usulü Midye Pilavı', null, '**Hazırlık / Mise en Place**
1. Midyeleri temizleyip süzün. Pirinci yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun. Midyeleri ekleyip 3-4 dk çevirin. Pirinci, 60 ml (60 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Midye temizlenirken pirinç yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MİDYE", "PİRİNÇ (HAM)", "KURU SOĞAN", "ZEYTİNYAĞI", "KARABİBER", "TUZ", "SU"], "yeni_su_gram": 60}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırklareli Usulü Zeytinyağlı Barbunya', null, '**Hazırlık / Mise en Place**
1. Barbunyayı ayıklayıp yıkayın. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3-4 dk pişirin. Barbunyayı ve tuzu ekleyin; kapağı kapalı olarak kısık ateşte barbunya tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BARBUNYA", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Edirne Usulü Tavuklu Erişte', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın, kaşarı rendeleyin.

**Isıl İşlem**
1. Haşlama ve Karıştırma (~100°C, tencerede, 22 dk): Tencereye 600 ml (600 g) su koyup kaynatın, tuz ekleyin. Makarnayı paket üzerindeki süreye göre haşlayın. Ayrı bir tavada tereyağında tavuğu pişene kadar 10-12 dk çevirin. Süzülen makarnayı tavuklu tavaya ekleyip karıştırın, üzerine rendelenmiş kaşarı serpin.

**PARALEL YAPILABİLİRLİK:** Makarna haşlanırken tavuk ayrı tavada pişirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~12 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama ve Karıştırma", "sure_dakika": 22, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MAKARNA", "TAVUK GÖĞÜS", "TEREYAĞI", "KAŞAR PEYNİRİ", "TUZ", "SU"], "yeni_su_gram": 600}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tekirdağ Usulü Zeytinyağlı Karnabahar', null, '**Hazırlık / Mise en Place**
1. Karnabaharı küçük parçalara ayırıp yıkayın. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Karnabaharı ve tuzu ekleyip kapağı kapalı olarak kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~16 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARNABAHAR", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kocaeli Usulü Pilav Üstü Tavuk', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, tavuk butunu parçalara ayırın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağının yarısında tavuğu her tarafı renk alana kadar 8-10 dk çevirin, bir kaba alın. Pirinci kalan tereyağında 2 dk çevirin. Sıcak tavuk suyu, tuz ve karabiberi ekleyin; kaynayınca tavuğu geri ekleyip ateşi kısın, kapağı kapalı olarak pirinç suyunu çekip tavuk pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken pirinç yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "TAVUK BUT", "TEREYAĞI", "TAVUK SUYU", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Cevizli Ayva Tatlısı', null, '**Hazırlık / Mise en Place**
1. Ayvaları soyup çekirdek evlerini çıkararak dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): 50 ml (50 g) su ve şekeri kaynatın. Ayva dilimlerini ekleyip kısık ateşte yumuşayıp şerbeti çekmeye başlayana kadar pişirin.
2. Son işlemler: Ilıyınca üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Ayva pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["AYVA", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Zeytinli Domates Salatası', null, '**Hazırlık / Mise en Place**
1. Domatesi iri küp doğrayın, zeytini iri kıyın, kuru soğanı ince yarım ay dilimleyin.
2. Zeytinyağı ve tuzla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Domates doğranırken zeytin kıyılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Söke Usulü Pirinç Pilavı', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 20 dk): Tereyağında pirinci 2 dk çevirin. Sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken pirinç yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~7 dk · Pasif bekleme ~18 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bodrum Usulü Karidesli Salata', null, '**Hazırlık / Mise en Place**
1. Marulu ayıklayıp yıkayın, elinizle parçalayın. Zeytinyağı, limon suyu ve tuzu çırparak sosu hazırlayın.

**Isıl İşlem**
1. Haşlama (~95°C, tencerede, 10 dk): Tencereye 300 ml (300 g) su koyup kaynatın. Karidesleri ekleyip pembeleşip pişene kadar (~4-5 dk) haşlayın, süzün.
2. Son işlemler: Haşlanmış karidesleri ılıyınca marul ve sosla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Karides haşlanırken marul ve sos hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~5 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 10, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARİDES", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Milas Usulü Hellim Izgara', null, '**Hazırlık / Mise en Place**
1. Hellim peynirini 1 cm kalınlığında dilimleyin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, tavada, 10 dk): Zeytinyağını ince bir tavaya sürüp ısıtın. Hellim dilimlerini her iki yüzü altın rengi olana kadar 2-3 dk''şar pişirin.
2. Son işlemler: Üzerine limon suyu sıkarak sıcak servis edin.

**PARALEL YAPILABİLİRLİK:** Tava ısınırken hellim dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HELLİM PEYNİRİ", "ZEYTİNYAĞI"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kuşadası Usulü Izgara Çipura', null, '**Hazırlık / Mise en Place**
1. Çipurayı temizletip pullarını aldırın, yıkayıp kurulayın.
2. Zeytinyağı, limon suyu, kekik ve tuzu karıştırıp balığın üzerine ve içine sürün.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 15 dk): Iyice ısıtılmış ızgarada balığı her iki yüzü de eti kolayca kemikten ayrılana kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken balık hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ÇİPURA", "ZEYTİNYAĞI", "LİMON SUYU", "TUZ", "KEKİK"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Alaçatı Usulü Pazı Kavurması (Zeytinyağlı)', null, '**Hazırlık / Mise en Place**
1. Pazıyı yıkayıp iri kıyın. Kuru soğanı ince yarım ay dilimleyin, pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Pirinci ekleyip 1-2 dk çevirin. Tuzu ekleyip kısık ateşte pirinç yarı pişene kadar (~7 dk) pişirin. Pazıyı ekleyip pörsüyüp pirinç tamamen pişene kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken pazı yıkanıp kıyılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PAZI", "KURU SOĞAN", "PİRİNÇ (HAM)", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çeşme Usulü Karpuzlu Peynir Tabağı', null, '**Hazırlık / Mise en Place**
1. Karpuzu kalın küp veya dilim şeklinde kesin.
2. Otlu peyniri dilimleyin, taze naneyi ince kıyın.
3. Karpuz ve peyniri servis tabağında yan yana dizip üzerine naneyi serperek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Karpuz kesilirken peynir dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bergama Usulü Peynirli Domates Dolması (Etsiz)', null, '**Hazırlık / Mise en Place**
1. Domateslerin sap tarafından bir kapak kesin, içini kaşıkla oyun (iç kısmı ayrı bir kapta saklayın).
2. Lor peynirini, ayırdığınız domates içini, maydanoz, zeytinyağı ve tuzu karıştırın.
3. Harcı domateslerin içine doldurup kapaklarını kapatın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Domatesler oyulurken harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İzmir Usulü Portakallı Zeytinyağlı Pancar', null, '**Hazırlık / Mise en Place**
1. Pancarı soyup küçük küp veya dilim halinde doğrayın.
2. Portakalın kabuğunu soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 22 dk): Zeytinyağını tencereye alın, pancarı ekleyip 2-3 dk çevirin. 100 ml (100 g) sıcak su, şeker ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pancar tamamen yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp soğutun (soğuma süresi özete dahil değildir), üzerine portakal dilimlerini ekleyerek soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pancar pişerken portakal hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PANCAR", "ZEYTİNYAĞI", "ŞEKER", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Silifke Usulü Yoğurtlu Köfte', null, '**Hazırlık / Mise en Place**
1. Kıymayı tuz ve karabiberle yoğurup küçük yuvarlak köfteler şekillendirin.
2. Domatesin kabuğunu soyup rendeleyin. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarıp pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Izgara (orta ateş, tavada, 15 dk): Köfteleri yağsız bir tavada her yüzü mühürlenip içi pişene kadar çevirerek pişirin.
2. Sos (~85°C, tavada, 10 dk): Tereyağını ayrı bir tavada eritip rendelenmiş domatesi ekleyip suyunu salıp çekene kadar (~5-6 dk) pişirin.
3. Son işlemler: Köfteleri servis tabağına dizin, üzerine yoğurdu, ardından sıcak domates-tereyağı sosunu gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Köfteler pişerken domates sosu ayrı tavada hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "TUZ", "KARABİBER"], "yeni_su_gram": null}, {"sira": 3, "ad": "Sos", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TEREYAĞI", "DOMATES"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Anamur Usulü Portakallı Muz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Muzu dilimleyin, portakalın kabuğunu soyup dilimleyin.
2. Muz ve portakal dilimlerini bir kapta karıştırıp üzerine bal gezdirerek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Muz dilimlenirken portakal hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kaş Usulü Izgara Karides', null, '**Hazırlık / Mise en Place**
1. Karidesleri kabuklarından ayıklayın (kuyruk kısmı bırakılabilir).
2. Zeytinyağı, ezilmiş sarımsak, limon suyu ve tuzla karideslere marine edin; 5 dk (bu süre aşağıdaki toplama dahildir) bekletin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada veya tavada, 12 dk): Karidesleri her yüzü pembeleşip pişene kadar 2-3 dk''şar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken karidesler marine edilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~5 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARİDES", "ZEYTİNYAĞI", "LİMON SUYU", "SARIMSAK", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Alanya Usulü Karides Pilavı', null, '**Hazırlık / Mise en Place**
1. Karidesleri kabuklarından ayıklayın. Pirinci yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Karidesleri ekleyip 2-3 dk çevirin. Pirinci, 100 ml (100 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken karides ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARİDES", "PİRİNÇ (HAM)", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Zeytinyağlı Enginar Kalpli Pilav', null, '**Hazırlık / Mise en Place**
1. Enginar kalplerini dörde bölün. Pirinci yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Enginar kalplerini ekleyip 2 dk çevirin. Pirinci, 90 ml (90 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken enginar ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "ENGİNAR KALBİ", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 90}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mersin Usulü Tirit', null, '**Hazırlık / Mise en Place**
1. Kuzu etini büyük parçalar halinde doğrayın, kuru soğanı iri dilimleyin.
2. Ekmeği kalın dilimler halinde kesip hafif kızartın veya kurutun.

**Isıl İşlem**
1. Haşlama (~95°C, tencerede, 40 dk): Tencereye 700 ml (700 g) su koyup kaynatın. Eti ve soğanı ekleyin, tuz ve karabiberi serpin; kaynayınca ateşi kısıp kapağı kapalı olarak et kemikten kolayca ayrılacak kadar yumuşayana kadar pişirin.
2. Son işlemler: Ekmek dilimlerini servis tabağına dizin, üzerine sıcak et suyunu gezdirip ıslatın, etleri lif lif ayırarak üzerine yerleştirin.

**PARALEL YAPILABİLİRLİK:** Haşlama kapaklı ve kısık ateşte ilerlediği için bu sürede ekmek hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~30 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 700}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Hatay Usulü Kaytaz Böreği', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyip kıymayla, tuzla karıştırın.
2. Yufkayı küçük üçgenler halinde kesin, her üçgene bir tutam iç harç koyup sıkıca üçgen şeklinde katlayın.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 20 dk): Mısır yağını tavada kızdırın. Böreklerin her iki yüzünü de altın rengi ve kıyma pişene kadar kızartın.

**PARALEL YAPILABİLİRLİK:** Yağ ısınırken börekler kıvrılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~40 dk · Pasif bekleme ~5 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YUFKA", "DANA KIYMA", "KURU SOĞAN", "MISIR YAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Adana Usulü Zeytinyağlı Nohutlu Ispanak', null, '**Hazırlık / Mise en Place**
1. Ispanağı ayıklayıp yıkayın, iri kıyın. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Nohudu ekleyip 2 dk çevirin. Tuzu ekleyip kısık ateşte 3-4 dk pişirin. Ispanağı ekleyip pörsüyüp yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Soğan kavrulurken ıspanak yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ISPANAK", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Yozgat Usulü Çullama', null, '**Hazırlık / Mise en Place**
1. Yufkayı küçük parçalara ayırın. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarıp pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Haşlama ve Pişirme (~95°C, tencerede, 30 dk): Tencereye 400 ml (400 g) su koyup kaynatın, tuz ekleyin. Tavuk göğsünü ekleyip iyice pişene kadar (~20 dk) haşlayın, çıkarıp lif lif ayırın. Kalan sıcak suya yufka parçalarını atıp 2-3 dk yumuşatın, süzün. Tereyağını eritin.
2. Son işlemler: Yufka parçalarını servis tabağına yayın, üzerine yoğurdu, ardından tavuğu ve son olarak sıcak eritilmiş tereyağını gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk haşlanırken yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama ve Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 400}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırıkkale Usulü Yoğurtlu Erişte', null, '**Hazırlık / Mise en Place**
1. Sarımsağı tuzla ezip yoğurtla karıştırın, pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 20 dk): Tencereye 600 ml (600 g) su koyup kaynatın, tuz ekleyin. Makarnayı paket üzerindeki süreye göre haşlayıp süzün. Tereyağını tencerede eritip pul biberle karıştırın.
2. Son işlemler: Makarnayı servis tabağına alın, üzerine sarımsaklı yoğurdu, ardından sıcak pul biberli tereyağını gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken sarımsaklı yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 20, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MAKARNA", "TUZ", "SU", "TEREYAĞI"], "yeni_su_gram": 600}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çankırı Usulü Kuru Fasulye Yahnisi', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "DANA KIYMA", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karaman Usulü Etli Bamya', null, '**Hazırlık / Mise en Place**
1. Bamyaların saplarını temizleyin, yıkayıp süzün.
2. Kuzu etini 2 cm kuşbaşı doğrayın, domatesin kabuğunu soyup küçük küp doğrayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bamyaları, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kapağı kapalı olarak kısık ateşte et ve bamyalar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAMYA", "KUZU ETİ (KOL)", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Nevşehir Usulü Üzümlü Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında soğanı 3-4 dk kavurun. Bulguru ekleyip 2 dk çevirin. Kuru üzümü, sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken soğan kavrulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "KURU ÜZÜM", "KURU SOĞAN", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kayseri Usulü Cevizli Sucuk (Pekmezli)', null, '**Hazırlık / Mise en Place**
1. Cevizleri kabaca kırın.
2. Mısır nişastası yerine ekmeklik unu birkaç kaşık pekmezle pürüzsüz bir bulamaç haline getirin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 20 dk): Kalan pekmezi ısıtın, un bulamacını ekleyip sürekli karıştırarak koyulaşana kadar (~12-15 dk) pişirin. Cevizleri ekleyip karıştırın.
2. Son işlemler: Karışımı kalıba dökün, soğutup (soğuma süresi özete dahil değildir) dilimleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Pekmez ısıtılırken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~5 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ÜzÜM PEKMEZİ", "CEVİZ (İÇ)", "EKMEKLİK UN"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sivas Usulü Kürtün Aşı', null, '**Hazırlık / Mise en Place**
1. Nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında pul biberi 1 dk kavurun. 500 ml (500 g) sıcak su, nohut ve tuzu ekleyin; kaynayınca makarnayı ekleyip paket üzerindeki süreye göre pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısınırken nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~16 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "MAKARNA", "TEREYAĞI", "PUL BİBER", "TUZ", "SU"], "yeni_su_gram": 500}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Konya Usulü Ballı Kadayıf', null, '**Hazırlık / Mise en Place**
1. Fırını 180°C''ye ısıtmaya başlayın.
2. Ekmek kadayıfını tellerini dağıtmadan hafifçe açın.

**Isıl İşlem**
1. Fırınlama (180°C, 20 dk): Kadayıfı fırın tepsisine yayın, üzerine balı gezdirin. 180°C''ye önceden ısıtılmış fırında altın rengi ve gevrek olana kadar pişirin.
2. Son işlemler: Fırından çıkarıp üzerine kaymağı ekleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kadayıf hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~12 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEK KADAYIFI", "BAL"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bolu Usulü Kestaneli Tavuk', null, '**Hazırlık / Mise en Place**
1. Tavuk butunu parçalara ayırın, kestaneleri iri parçalar halinde bölün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Tereyağında tavuğu her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Kestaneleri, tuz ve karabiberi ekleyip kapağı kapalı olarak tavuk ve kestane yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken kestane ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "KESTANE", "KURU SOĞAN", "TEREYAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Zonguldak Usulü Pancar Turşusu', null, '**Hazırlık / Mise en Place**
1. Pancarı soyup dilimleyin veya küp doğrayın.

**Isıl İşlem**
1. Haşlama (~95°C, tencerede, 15 dk): Tencereye 300 ml (300 g) su koyup kaynatın. Pancarı ekleyip çatal batacak kıvamda (tam yumuşamadan) haşlayın.
2. Son işlemler: Haşlanmış pancarı süzüp temiz bir kavanoza yerleştirin, üzerine sarımsak dişlerini ekleyin. Sirke ve tuzu soğuk suyla karıştırıp kavanoza dökün, kapağını kapatıp birkaç gün (bu süre özete dahil değildir) buzdolabında veya serin yerde bekletin.

**PARALEL YAPILABİLİRLİK:** Pancar haşlanırken kavanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PANCAR", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sinop Usulü Balık Buğulama', null, '**Hazırlık / Mise en Place**
1. İstavritleri temizletip yıkayın.
2. Kuru soğanı ince yarım ay dilimleyin, maydanozu ince kıyın.

**Isıl İşlem**
1. Buğulama (~85°C, tencerede, 18 dk): Zeytinyağını tencerenin tabanına gezdirin, soğanları yayın. Balıkları üzerine dizin, tuzu serpin. Kapağı kapatıp kısık ateşte balıklar pişene kadar kendi buharında pişirin.
2. Son işlemler: Üzerine maydanozu serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Balık temizlenirken soğan ve maydanoz hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 12, "aktif_dakika": 12, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Buğulama", "sure_dakika": 18, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["İSTAVRİT", "KURU SOĞAN", "MAYDANOZ", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Amasya Usulü Elma Tatlısı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 20 dk): Elma dilimlerini ve şekeri bir tencerede katman katman dizin, tarçını serpin. Kısık ateşte elmalar kendi suyunu bırakıp yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~12 dk · Pasif bekleme ~18 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER", "TARÇIN"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Tokat Usulü Kebabı (Patatesli, Fırında)', null, '**Hazırlık / Mise en Place**
1. Fırını 200°C''ye ısıtmaya başlayın.
2. Patatesleri soyup ince dilimleyin, domatesin kabuğunu soyup dilimleyin, kuru soğanı ince yarım ay dilimleyin.
3. Kıymayı tuz ve karabiberle yoğurup yassı köfte şekli verin.

**Isıl İşlem**
1. Fırınlama (200°C, 25 dk): Fırın kabına patates dilimlerini yayın, köfteleri üzerine dizin, soğan ve domates dilimlerini araya yerleştirin. 200°C''ye önceden ısıtılmış fırında patatesler ve köfte pişip üzeri hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken malzemeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~17 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU KIYMA", "PATATES", "DOMATES", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Artvin Usulü Fasulye Pilaki', null, '**Hazırlık / Mise en Place**
1. Barbunyayı ayıklayıp yıkayın. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3 dk pişirin. Barbunyayı ve tuzu ekleyip kapağı kapalı olarak kısık ateşte barbunya yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BARBUNYA", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ordu Usulü Fındıklı Tatlı', null, '**Hazırlık / Mise en Place**
1. Fındıkları kabaca kırın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 15 dk): Sütü ve şekeri ısıtın, fındıkları ekleyip sürekli karıştırarak kıvam alana kadar pişirin.
2. Son işlemler: Kalıba dökün, soğutup (soğuma süresi özete dahil değildir) dilimleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Süt ısıtılırken fındık kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~5 dk · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["FINDIK (İÇ)", "ŞEKER", "SÜT (TAM YAĞ)"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karadeniz Usulü Taze Fasulye Yemeği (Etli)', null, '**Hazırlık / Mise en Place**
1. Taze fasulyenin iplerini ayıklayıp uzunlamasına ikiye bölün.
2. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Taze fasulyeyi ve tuzu ekleyip kapağı kapalı olarak kısık ateşte fasulye yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAZE FASULYE", "DANA KIYMA", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzurum Usulü Su Böreği', null, '**Hazırlık / Mise en Place**
1. Kaşarı rendeleyin. Yufkaları uygun boyutta kesin.

**Isıl İşlem**
1. Haşlama ve Fırınlama (~95°C, tencerede+fırında, 30 dk): Fırını 190°C''ye ısıtmaya başlayın. Tencereye 800 ml (800 g) su koyup kaynatın, tuz ekleyin. Yufkaları teker teker kaynar suda 30-40 saniye haşlayıp soğuk suya alın, süzün. Bir fırın tepsisine yufka, yumurta, kaşar katmanları halinde dizip üzerine eritilmiş tereyağını gezdirin. 190°C fırında üzeri hafif renk alana kadar 15 dk pişirin.

**PARALEL YAPILABİLİRLİK:** Su kaynarken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~15 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama ve Fırınlama", "sure_dakika": 30, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["YUFKA", "KAŞAR PEYNİRİ", "TEREYAĞI", "TAVUK YUMURTASI", "TUZ", "SU"], "yeni_su_gram": 800}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzincan Usulü Çökelekli Yumurta', null, '**Hazırlık / Mise en Place**
1. Lor peynirini ufalayın, yumurtaları çırpın.

**Isıl İşlem**
1. Pişirme (~85°C, tavada, 10 dk): Tereyağını tavada eritin, lor peynirini ekleyip 2-3 dk çevirin. Çırpılmış yumurtaları ve tuzu ekleyip karıştırarak pişirin.

**PARALEL YAPILABİLİRLİK:** Tereyağı ısınırken yumurta çırpılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LOR PEYNİRİ", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Van Usulü Otlu Peynirli Salata', null, '**Hazırlık / Mise en Place**
1. Otlu peyniri küçük küp doğrayın, domatesi küçük küp doğrayın.
2. Rokayı yıkayıp süzün.
3. Peynir, domates ve rokayı bir kapta karıştırın, zeytinyağıyla tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Peynir doğranırken domates hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muş Usulü Zeytinyağlı Semizotu', null, '**Hazırlık / Mise en Place**
1. Semizotunu ayıklayıp yıkayın, iri kıyın. Kuru soğanı ince yarım ay dilimleyin, pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 17 dk): Zeytinyağında soğanı 3-4 dk kavurun. Pirinci ekleyip 1-2 dk çevirin. Tuzu ekleyip kısık ateşte pirinç yarı pişene kadar (~6 dk) pişirin. Semizotunu ekleyip pörsüyüp pirinç tamamen pişene kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Pişirme ilerlerken semizotu yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SEMİZOTU", "PİRİNÇ (HAM)", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ağrı Usulü Kaz Eti Pilavı', null, '**Hazırlık / Mise en Place**
1. Kaz etini parçalara ayırın. Pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Kaz etini kendi yağında 10 dk çevirerek kavurun. Pirinci ekleyip 2 dk çevirin. 150 ml (150 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekip et yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kaz eti kavrulurken pirinç yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)", "PİRİNÇ (HAM)", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kars Usulü Kaşarlı Pilav', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, kaşarı rendeleyin.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında pirinci 2 dk çevirin. Sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp üzerine rendelenmiş kaşarı serpip 5 dk demlenmeye bırakın (bu süre özete dahil değildir), karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "KAŞAR PEYNİRİ", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bitlis Usulü Nohutlu Etli Çorba', null, '**Hazırlık / Mise en Place**
1. Nohut haşlanmışsa süzün. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu, sıcak tavuk suyu, tuz ve karabiberi ekleyip kaynatıp lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken nohut ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "DANA KIYMA", "KURU SOĞAN", "TAVUK SUYU", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Iğdır Usulü Kayısılı Komposto', null, '**Hazırlık / Mise en Place**
1. Kayısıları yıkayıp ikiye bölün, çekirdeklerini çıkarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): 70 ml (70 g) su ve şekeri kaynatın. Kayısıları ekleyip kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KAYISI", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gaziantep Usulü Beyran Çorbası', null, '**Hazırlık / Mise en Place**
1. Kuzu etini büyük parçalar halinde doğrayın. Sarımsağı ezin, pirinci yıkayıp süzün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Tencereye 600 ml (600 g) su koyup kaynatın. Eti ekleyin, tuz ve karabiberi serpin; kaynayınca ateşi kısıp kapağı kapalı olarak et neredeyse dağılacak kadar yumuşayana kadar (~25 dk) pişirin. Pirinci ve ezilmiş sarımsağı ekleyip pirinç pişene kadar pişirmeye devam edin.
2. Son işlemler: Eti lif lif ayırıp çorbaya geri ekleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Et pişerken sarımsak ezilip pirinç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "PİRİNÇ (HAM)", "SARIMSAK", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 600}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şanlıurfa Usulü Nohutlu Kuzu Güveç', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın. Kuru soğanı küçük küp, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu, 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~25 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Diyarbakır Usulü Kaburga Pilavı', null, '**Hazırlık / Mise en Place**
1. Sığır kaburgayı parçalara ayırın. Pirinci yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 30 dk): Kaburgaları kendi yağında her tarafı renk alana kadar 10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Pirinci, 300 ml (300 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekip et yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kaburga kavrulurken pirinç yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KABURGA", "PİRİNÇ (HAM)", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mardin Usulü Zeytinyağlı Nohutlu Bulgur', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Bulgur ve nohudu, 100 ml (100 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan kavrulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "NOHUT", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Siirt Usulü Kaburga Kavurma', 60, '**Hazırlık / Mise en Place**
1. Sığır kaburgayı parçalara ayırın. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta-kısık ateş, tencerede, 50 dk): Kaburgaları kendi yağında her tarafı renk alana kadar 15 dk çevirin. Ateşi kısıp kapağı kapalı olarak arada karıştırarak et kemikten kolayca ayrılacak kadar yumuşayana kadar (~30 dk) pişirin. Soğanı ekleyip 5 dk daha kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Kavurma kapaklı ilerlerken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~35 dk · Toplam ~60 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 50, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SIĞIR KABURGA", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Batman Usulü Nohutlu Pilav', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, nohut haşlanmışsa süzün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında pirinci 2 dk çevirin. Nohudu, sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken pirinç ve nohut hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "NOHUT", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şırnak Usulü Etli Nohutlu Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, nohut haşlanmışsa süzün, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Bulgur ve nohudu, 100 ml (100 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "BULGUR", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kilis Usulü Nar Ekşili Mercimek Çorbası', null, '**Hazırlık / Mise en Place**
1. Kırmızı mercimeği ayıklayıp yıkayın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Sıcak tavuk suyuna mercimek ve soğanı ekleyip mercimek dağılana kadar (~15 dk) pişirin. Nar ekşisi ve tuzu ekleyip 3-4 dk daha pişirin.
2. Son işlemler: El blenderiyle pürüzsüz olana kadar çekip servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken mercimek ve soğan hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KIRMIZI MERCİMEK", "KURU SOĞAN", "NAR EKŞİSİ", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
end $$;

-- Dogrulama: hazirlik_dakika = asama_toplami olmali VE her ISIL
-- asamada en az 1 baglı malzeme olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('Balıkesir Usulü Keşkek'),
    ('Çanakkale Usulü Midye Pilavı'),
    ('Kırklareli Usulü Zeytinyağlı Barbunya'),
    ('Edirne Usulü Tavuklu Erişte'),
    ('Tekirdağ Usulü Zeytinyağlı Karnabahar'),
    ('Kocaeli Usulü Pilav Üstü Tavuk'),
    ('Marmara Usulü Cevizli Ayva Tatlısı'),
    ('Marmara Usulü Zeytinli Domates Salatası'),
    ('Söke Usulü Pirinç Pilavı'),
    ('Bodrum Usulü Karidesli Salata'),
    ('Milas Usulü Hellim Izgara'),
    ('Kuşadası Usulü Izgara Çipura'),
    ('Alaçatı Usulü Pazı Kavurması (Zeytinyağlı)'),
    ('Çeşme Usulü Karpuzlu Peynir Tabağı'),
    ('Bergama Usulü Peynirli Domates Dolması (Etsiz)'),
    ('İzmir Usulü Portakallı Zeytinyağlı Pancar'),
    ('Silifke Usulü Yoğurtlu Köfte'),
    ('Anamur Usulü Portakallı Muz Tatlısı'),
    ('Kaş Usulü Izgara Karides'),
    ('Alanya Usulü Karides Pilavı'),
    ('Antalya Usulü Zeytinyağlı Enginar Kalpli Pilav'),
    ('Mersin Usulü Tirit'),
    ('Hatay Usulü Kaytaz Böreği'),
    ('Adana Usulü Zeytinyağlı Nohutlu Ispanak'),
    ('Yozgat Usulü Çullama'),
    ('Kırıkkale Usulü Yoğurtlu Erişte'),
    ('Çankırı Usulü Kuru Fasulye Yahnisi'),
    ('Karaman Usulü Etli Bamya'),
    ('Nevşehir Usulü Üzümlü Bulgur Pilavı'),
    ('Kayseri Usulü Cevizli Sucuk (Pekmezli)'),
    ('Sivas Usulü Kürtün Aşı'),
    ('Konya Usulü Ballı Kadayıf'),
    ('Bolu Usulü Kestaneli Tavuk'),
    ('Zonguldak Usulü Pancar Turşusu'),
    ('Sinop Usulü Balık Buğulama'),
    ('Amasya Usulü Elma Tatlısı'),
    ('Tokat Usulü Kebabı (Patatesli, Fırında)'),
    ('Artvin Usulü Fasulye Pilaki'),
    ('Ordu Usulü Fındıklı Tatlı'),
    ('Karadeniz Usulü Taze Fasulye Yemeği (Etli)'),
    ('Erzurum Usulü Su Böreği'),
    ('Erzincan Usulü Çökelekli Yumurta'),
    ('Van Usulü Otlu Peynirli Salata'),
    ('Muş Usulü Zeytinyağlı Semizotu'),
    ('Ağrı Usulü Kaz Eti Pilavı'),
    ('Kars Usulü Kaşarlı Pilav'),
    ('Bitlis Usulü Nohutlu Etli Çorba'),
    ('Iğdır Usulü Kayısılı Komposto'),
    ('Gaziantep Usulü Beyran Çorbası'),
    ('Şanlıurfa Usulü Nohutlu Kuzu Güveç'),
    ('Diyarbakır Usulü Kaburga Pilavı'),
    ('Mardin Usulü Zeytinyağlı Nohutlu Bulgur'),
    ('Siirt Usulü Kaburga Kavurma'),
    ('Batman Usulü Nohutlu Pilav'),
    ('Şırnak Usulü Etli Nohutlu Bulgur Pilavı'),
    ('Kilis Usulü Nar Ekşili Mercimek Çorbası')
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
