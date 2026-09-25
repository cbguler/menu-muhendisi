-- 157_talimat_ve_asama_grup3.sql (Revizyon 2)
-- 515 yeni tarifin talimat+asama yazimi -- Grup 3: Parti2(tarif-
-- ekleme)'nin 55 tarifi (56 degil -- REVIZYON 2'de aciklaniyor).
--
-- REVIZYON 2: Ilk deneme 'Karadeniz Usulü Hamsi Buğulama'da
-- 'Bu tarifte ZATEN asama kayitli' hatasiyla patladi. Arastirinca:
-- bu isim, Parti2'nin kendi orijinal yukleme sirasinda (762/763
-- arastirmasinda bulunan) ONCEDEN VAR OLAN bir tarifle carpisip
-- SESSIZCE ATLANMISTI -- yani bu isimdeki GERCEK kayit BASKA (daha
-- once tamamlanmis) bir tarif, bizim Parti2 tasarimimiz degil.
-- (Onceki arastirmada bu yanlislikla 'Parti 4' diye not edilmisti --
-- toplam sayi/sonuc dogruydu, sadece hangi parti oldugu yanlisti,
-- PROJE_NOTLARI'nda duzeltildi.) Bu isim GRUP 3'TEN CIKARILDI --
-- Grup 3 artik 55 tarif (56 degil).
--
-- Ayni _talimat_ve_asama_ekle_v2 fonksiyonu (155/156 ile ayni).

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
        'Tekirdağ Köftesi', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyin.
2. Kıyma, rendelenmiş soğan, ekmeklik un, karbonat, tuz ve karabiberi iyice yoğurun; 10 dk (bu süre aşağıdaki toplama dahildir) dinlendirin.
3. Harçtan yuvarlak, hafif basık köfte şekli verin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada köfteleri her yüzü 4-5 dk olacak şekilde çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte harcı dinlendirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık / Yoğurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "EKMEKLİK UN", "KARBONAT (YEM. SODA)", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Çanakkale Peynir Helvası', null, '**Hazırlık / Mise en Place**
1. Sütü ayrı bir kapta ısıtmaya hazır bulundurun.

**Isıl İşlem**
1. Kavurma ve Pişirme (~90°C, tencerede, 30 dk): Tereyağında unu kısık ateşte sürekli karıştırarak hafif renk alana kadar (~10 dk) kavurun. Lor peynirini ekleyip 3-4 dk çevirin. Şekeri ekleyip 2 dk karıştırın. Ilık sütü azar azar ekleyip topaklanmadan karıştırarak kıvam alana kadar (~14 dk) pişirin.
2. Son işlemler: Servis tabağına alıp dilimleyerek servis edin.

**PARALEL YAPILABİLİRLİK:** Un kavrulurken süt ayrı bir kapta ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma ve Pişirme", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LOR PEYNİRİ", "EKMEKLİK UN", "ŞEKER", "TEREYAĞI", "SÜT (TAM YAĞ)"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Balıkesir Kaymaklı Kayısı Tatlısı', null, '**Hazırlık / Mise en Place**
1. Kayısıları ikiye bölüp çekirdeklerini çıkarın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 15 dk): Kayısıları ve şekeri bir tencerede az suyla (kendi suyunu bırakacaktır) kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ilıyınca her kayısının ortasına bir kaşık kaymak koyarak servis edin.

**PARALEL YAPILABİLİRLİK:** Kayısı pişerken kaymak servise hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~5 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KAYISI", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İstanbul Usulü Etli Kuru Fasulye', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~20 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "DANA KIYMA", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Kabak Mücveri', null, '**Hazırlık / Mise en Place**
1. Kabakları rendeleyip hafif tuzlayın, 10 dk (aşağıdaki süreye dahil değildir) suyunu süzdürün, elinizle sıkarak fazla suyunu çıkarın.
2. Rendelenmiş kabağa un, yumurta, maydanoz, tuz ve karabiberi ekleyip karıştırın.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 15 dk): Mısır yağını tavada kızdırın. Harçtan kaşıkla aldığınız parçaları yassılaştırıp her iki yüzü altın rengi olana kadar kızartın.

**PARALEL YAPILABİLİRLİK:** Kabak suyunu süzerken tava ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~10 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "EKMEKLİK UN", "TAVUK YUMURTASI", "MAYDANOZ", "KARABİBER", "TUZ", "MISIR YAĞI"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bandırma Usulü Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk butunu kemikli veya kemiksiz parçalara ayırın.
2. Kuru soğanı, domatesi ve yeşil biberi küçük küp doğrayın.

**Isıl İşlem**
1. Sote (~90°C, tencerede, 25 dk): Tavuğu kendi yağında her tarafı renk alana kadar 8-10 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Biberi ekleyip 2 dk çevirin. Domatesi, tuz ve karabiberi ekleyip tavuk pişene kadar (~10 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK BUT", "KURU SOĞAN", "DOMATES", "YEŞİL BİBER", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Fırında Lüfer', null, '**Hazırlık / Mise en Place**
1. Fırını 190°C''ye ısıtmaya başlayın.
2. Lüferi temizletip pullarını aldırın; iç ve dış yüzeyini yıkayıp kurulayın.
3. Zeytinyağı, limon suyu, kekik ve tuzu karıştırıp balığın üzerine ve içine sürün.

**Isıl İşlem**
1. Fırınlama (190°C, 25 dk): Balığı fırın tepsisine yerleştirin. 190°C''ye önceden ısıtılmış fırında eti kolayca kemikten ayrılana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken balık hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "elektrik", "malzemeler": ["LÜFER", "ZEYTİNYAĞI", "LİMON SUYU", "TUZ", "KEKİK"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Marmara Usulü Vişneli Yoğurt Dondurması', null, '**Hazırlık / Mise en Place**
1. Vişneleri (çekirdekleri çıkarılmış) kabaca doğrayın.
2. Yoğurt ve şekeri pürüzsüz olana kadar çırpın, vişneleri ekleyip karıştırın.
3. Karışımı kapaklı bir kaba dökün, dondurucuya kaldırın; en az 4 saat (bu süre özete dahil değildir) dondurun, ilk 1-2 saatte arada bir çatalla karıştırarak buz kristali oluşumunu azaltın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok (dondurma süresi hariç) · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kemalpaşa Köftesi', null, '**Hazırlık / Mise en Place**
1. Fırını 190°C''ye ısıtmaya başlayın.
2. Kuru soğanı rendeleyin.
3. Kıyma, rendelenmiş soğan, ekmeklik un, tuz ve karabiberi yoğurup yassı köfte şekli verin.

**Isıl İşlem**
1. Fırınlama (190°C, 25 dk): Köfteleri fırın tepsisine dizin. 190°C''ye önceden ısıtılmış fırında üzeri hafif renk alıp pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken köfte harcı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~17 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["DANA KIYMA", "EKMEKLİK UN", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Aydın İncirli Kuzu Tandır', null, '**Hazırlık / Mise en Place**
1. Fırını 170°C''ye ısıtmaya başlayın.
2. Kuzu tandırı kağıt havluyla kurulayın, tuz ve karabiberi ovun.
3. Kuru soğanı iri dilimleyin, kuru incirleri ikiye bölün.

**Isıl İşlem**
1. Fırınlama (170°C, 80 dk): Soğan ve incirleri fırın kabının tabanına yayın, eti üzerine yerleştirin. 30 ml (30 g) su ekleyip kabı folyoyla sıkıca kapatın. 170°C''ye önceden ısıtılmış fırında 65 dakika pişirin, son 15 dakikayı folyosuz, üzeri hafif kızarana kadar pişirin.
2. Son işlemler: Fırından çıkarıp birkaç dakika dinlendirip parçalayarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken et baharatlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~70 dk · Toplam ~100 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 80, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU TANDIR", "KURU İNCİR", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 30}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muğla Yeşil Erik Salatası', null, '**Hazırlık / Mise en Place**
1. Yeşil erikleri yıkayıp ince dilimleyin.
2. Zeytinyağı ve tuzla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Foça Usulü Kalamar Tava', null, '**Hazırlık / Mise en Place**
1. Kalamarları halka halinde doğrayın.
2. Ekmeklik unu bir tabağa koyup tuzla karıştırın.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 15 dk): Mısır yağını tavada kızdırın. Kalamar halkalarını una bulayıp fazlasını silkeleyin, partiler halinde altın rengi olana kadar kızartın.
2. Son işlemler: Kağıt havlu üzerinde fazla yağını süzdürüp üzerine limon suyu sıkarak servis edin.

**PARALEL YAPILABİLİRLİK:** Bir parti kızarırken diğeri una bulanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KALAMAR", "EKMEKLİK UN", "MISIR YAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ege Yeşil Zeytinli Havuç Salatası', null, '**Hazırlık / Mise en Place**
1. Havuçları kazıyıp julyen doğrayın veya rendeleyin.
2. Zeytinleri iri kıyın.
3. Havuç, zeytin, zeytinyağı, limon suyu ve tuzu karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Havuç doğranırken zeytin kıyılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İzmir Usulü Nohutlu Bamya', null, '**Hazırlık / Mise en Place**
1. Bamyaların saplarını koni şeklinde temizleyin, yıkayıp süzün.
2. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 30 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 4 dk pişirin. Nohudu ve bamyaları ekleyin, tuzu serpin; kapağı kapalı olarak bamyalar yumuşayana kadar kısık ateşte pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~22 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAMYA", "NOHUT", "DOMATES", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ege Zeytinyağlı Bakla ve Enginar', null, '**Hazırlık / Mise en Place**
1. Baklaları ayıklayıp yıkayın.
2. Enginarları temizleyip dilimleyin, kararmaması için limonlu suda bekletin.
3. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Bakla ve enginarı, tuzu ekleyin; kapağı kapalı olarak sebzeler yumuşayana kadar kısık ateşte pişirin.
2. Son işlemler: Ocaktan alıp oda sıcaklığında soğutun (soğuma süresi özete dahil değildir), üzerine taze dereotu serperek soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BAKLA", "ENGİNAR", "KURU SOĞAN", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'İzmir Lokması', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, kabartma tozunu ve suyu karıştırıp pürüzsüz, akıcı bir hamur elde edin; üzerini örtüp 20 dk (bu süre aşağıdaki toplama dahildir) mayalanmaya/dinlenmeye bırakın.

**Isıl İşlem**
1. Kızartma ve Şerbet (~90°C, tavada, 25 dk): Şekeri az suyla kaynatıp koyu kıvamlı bir şerbet hazırlayın, bir kenara alın. Mısır yağını tavada kızdırın. Hamurdan elinizle veya kaşıkla küçük parçalar koparıp yağa bırakın, altın rengi ve içi pişene kadar kızartın.
2. Son işlemler: Sıcak lokmaları soğuk şerbete atıp birkaç dakika bekletin, süzüp servis edin.

**PARALEL YAPILABİLİRLİK:** Hamur mayalanırken şerbet hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~15 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kızartma ve Şerbet", "sure_dakika": 25, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEKLİK UN", "KABARTMA TOZU", "SU", "ŞEKER", "MISIR YAĞI"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Etli Nohut Yemeği', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp, domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Nohudu ekleyin, 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mersin Usulü Nohutlu Bulgur Aşı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün, kuru soğanı küçük küp, domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Bulgur ve nohudu, 100 ml (100 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "NOHUT", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Hatay Usulü Tepsi Kebabı', null, '**Hazırlık / Mise en Place**
1. Fırını 200°C''ye ısıtmaya başlayın.
2. Kuru soğanı rendeleyin, domates ve yeşil biberi ince doğrayın.
3. Kıyma, rendelenmiş soğanın yarısı, tuz ve karabiberi yoğurup tepsiye düz bir tabaka halinde yayın.

**Isıl İşlem**
1. Fırınlama (200°C, 25 dk): Kıyma tabakasının üzerine domates ve biber dilimlerini, kalan soğanı dizin. 200°C''ye önceden ısıtılmış fırında kıyma pişip üzeri hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kıyma tabakası hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~17 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU KIYMA", "DOMATES", "YEŞİL BİBER", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Adana Usulü Analı Kızlı Çorba', null, '**Hazırlık / Mise en Place**
1. Bulguru ıslatıp yumuşamaya bırakın (bu süre aşağıdaki toplama dahildir).
2. Kıyma ve yumuşamış bulguru tuzla yoğurup fındık büyüklüğünde küçük köfteler yuvarlayın.
3. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarıp pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Tavuk suyunu kaynatın, köfteleri ekleyip yüzeye çıkıp pişene kadar (~12 dk) haşlayın. Bir kepçe sıcak suyu yavaşça yoğurda ekleyip çırparak ısındırın, ardından tencereye geri, karıştırarak ve kaynatmadan ekleyin.
2. Son işlemler: Tereyağını eritip kuru naneyi ekleyerek nane yağı hazırlayın, servis anında üzerine gezdirin.

**PARALEL YAPILABİLİRLİK:** Köfteler haşlanırken yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~15 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık / Köfte Şekillendirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "DANA KIYMA", "YOĞURT (TAM)", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Yeşil Erik Hoşafı', null, '**Hazırlık / Mise en Place**
1. Yeşil erikleri yıkayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): 70 ml (70 g) su ve şekeri kaynatın. Erikleri ekleyip kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ERİK", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mersin Usulü Portakallı Zeytin Salatası', null, '**Hazırlık / Mise en Place**
1. Zeytinleri süzün. Portakalın kabuğunu soyup dilimleyin veya küp doğrayın.
2. Kuru soğanı ince yarım ay dilimleyin.
3. Zeytin, portakal ve soğanı bir kapta karıştırın, zeytinyağı ve sumakla tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Portakal soyulurken zeytin süzülebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Akdeniz Usulü Enginar Kalpli Salata', null, '**Hazırlık / Mise en Place**
1. Enginar kalplerini süzüp dilimleyin.
2. Rokayı yıkayıp süzün.
3. Enginar ve rokayı bir kapta karıştırın, zeytinyağı, limon suyu ve tuzla tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Enginar süzülürken roka yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Şeftalili Tavuk Sote', null, '**Hazırlık / Mise en Place**
1. Tavuk göğsünü kuşbaşı doğrayın.
2. Şeftaliyi dilimleyin, kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Sote (~90°C, tavada, 20 dk): Zeytinyağında tavuğu her tarafı renk alana kadar 6-8 dk çevirin. Soğanı ekleyip 3-4 dk kavurun. Şeftaliyi, tuz ve karabiberi ekleyip tavuk pişip şeftali yumuşayana kadar (~7-8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Tavuk pişerken şeftali dilimlenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["TAVUK GÖĞÜS", "ŞEFTALİ", "KURU SOĞAN", "ZEYTİNYAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Sivas Usulü Kes Kes', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın.
2. Patatesleri soyup iri küp doğrayın, erikleri yıkayıp bütün bırakın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et yumuşamaya başlayana kadar (~20 dk) pişirin. Patates ve erikleri ekleyip her ikisi de yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken patates ve erik hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~25 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "PATATES", "ERİK", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kırşehir Usulü Nohutlu Yahni', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Nohudu ekleyin, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve nohut yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "NOHUT", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Aksaray Usulü Bulgurlu Köfte (Fırında)', null, '**Hazırlık / Mise en Place**
1. Fırını 190°C''ye ısıtmaya başlayın.
2. Bulguru ıslatıp yumuşamaya bırakın (bu süre aşağıdaki toplama dahildir).
3. Kuru soğanı rendeleyin. Kıyma, yumuşamış bulgur, soğan, tuz ve karabiberi yoğurup köfte şekli verin.

**Isıl İşlem**
1. Fırınlama (190°C, 25 dk): Köfteleri fırın tepsisine dizin. 190°C''ye önceden ısıtılmış fırında pişip üzeri hafif renk alana kadar pişirin.
2. Son işlemler: Üzerine taze maydanoz serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken köfte harcı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~17 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["BULGUR", "DANA KIYMA", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Nevşehir Üzümlü Kabak Tatlısı', null, '**Hazırlık / Mise en Place**
1. Kabağı soyup kalın dilimler halinde kesin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Kabak dilimlerini ve şekeri bir tencerede katman katman dizin; kısık ateşte kabak kendi suyunu bırakıp yumuşayana ve şerbet koyulaşana kadar pişirin.
2. Son işlemler: Ilıyınca üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "ŞEKER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Konya Usulü Mercimekli Ekmek Aşı', null, '**Hazırlık / Mise en Place**
1. Ekmeği küp doğrayıp hafif kurumaya bırakın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 17 dk): Tavuk suyunu kaynatın, kırmızı mercimeği ekleyip yumuşayana kadar (~10 dk) pişirin. Ekmek küplerini, tereyağını, pul biberi ve tuzu ekleyip ekmek suyu emip yumuşayana kadar (~5 dk) pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Mercimek pişerken ekmek doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~13 dk · Pasif bekleme ~12 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEK (BEYAZ)", "KIRMIZI MERCİMEK", "TAVUK SUYU", "TEREYAĞI", "PUL BİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ankara Usulü Zerde', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün.
2. Safranı birkaç kaşık sıcak suda bekletip rengini çıkarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 22 dk): 120 ml (120 g) su ve şekeri kaynatın. Pirinci ekleyip kısık ateşte yumuşayana kadar (~15 dk) pişirin. Safranlı suyu ve kuş üzümünü ekleyip 3-4 dk daha pişirin.
2. Son işlemler: Servis kaselerine paylaştırıp soğutun (soğuma süresi özete dahil değildir).

**PARALEL YAPILABİLİRLİK:** Pirinç pişerken safran suya bırakılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "ŞEKER", "SAFRAN", "SU", "KUŞ ÜZÜMÜ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Niğde Usulü Zeytinyağlı Nohut', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı ince yarım ay dilimleyin, domatesin kabuğunu soyup küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 25 dk): Zeytinyağında soğanı 3-4 dk kavurun, şekeri ekleyip 1 dk çevirin. Domatesi ekleyip 3 dk pişirin. Nohudu ve tuzu ekleyip kapağı kapalı olarak kısık ateşte lezzetler kaynaşana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Pişirme kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~20 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["NOHUT", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "ŞEKER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kapadokya Usulü Karışık Kış Turşusu', null, '**Hazırlık / Mise en Place**
1. Lahanayı ince doğrayın, havucu kalın dilimleyin, patlıcanı küp doğrayın, sarımsağı soyun.
2. Sebzeleri temiz bir kavanoza sıkıca yerleştirin.

**Isıl İşlem**
1. Sirke Kaynatma (~100°C, tencerede, 15 dk): Sirke ve tuzu bir tencerede kaynatın.
2. Son işlemler: Kaynar sirkeli karışımı kavanozdaki sebzelerin üzerine dökün, kapağını kapatıp oda sıcaklığında birkaç gün (bu süre özete dahil değildir) fermantasyona bırakın.

**PARALEL YAPILABİLİRLİK:** Sirke kaynarken sebzeler kavanoza yerleştirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~5 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sirke Kaynatma", "sure_dakika": 15, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SİRKE", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Samsun Usulü Kaşarlı Sucuklu Pide', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, ılık su, tuz ve yumurtanın bir kısmıyla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Sucuğu ince dilimleyin, kaşarı rendeleyin.
3. Hamuru uzun oval açıp kenarlarını kıvırarak kayık pide formu verin, üzerine kaşar ve sucuğu dizin.

**Isıl İşlem**
1. Fırınlama (220°C, 15 dk): Pidenin kenarlarına kalan yumurtayı sürün. 220°C''ye önceden ısıtılmış fırında kenarları altın rengi, kaşar eriyip hafif kızarana kadar pişirin.
2. Son işlemler: Fırından çıkar çıkmaz tereyağını gezdirin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken sucuk ve kaşar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~10 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "KAŞAR PEYNİRİ", "SUCUK", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 40}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ordu Usulü Fındıklı Pilav', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, fındıkları kabaca kırın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında fındıkları 2 dk kavurun. Pirinci ekleyip 2 dk çevirin. Sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken fındık kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~16 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "FINDIK (İÇ)", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Rize Usulü Mantar Kavurması (Etli)', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Mantarları dilimleyin, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 12-15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Mantarları, tuz ve karabiberi ekleyip mantarlar suyunu bırakıp çekene kadar (~8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken mantar ve soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "MANTAR", "KURU SOĞAN", "TEREYAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Giresun Usulü Fasulye Turşusu', null, '**Hazırlık / Mise en Place**
1. Taze fasulyenin iplerini ayıklayın, uzun bırakabilir veya ikiye bölebilirsiniz.
2. Fasulyeleri ve soyulmuş sarımsak dişlerini temiz bir kavanoza sıkıca yerleştirin.

**Isıl İşlem**
1. Sirke Kaynatma (~100°C, tencerede, 10 dk): Sirke ve tuzu bir tencerede kaynatın.
2. Son işlemler: Kaynar sirkeli karışımı kavanozdaki fasulyelerin üzerine dökün, kapağını kapatıp oda sıcaklığında birkaç gün (bu süre özete dahil değildir) fermantasyona bırakın.

**PARALEL YAPILABİLİRLİK:** Sirke kaynarken fasulye kavanoza yerleştirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~17 dk · Pasif bekleme ~8 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sirke Kaynatma", "sure_dakika": 10, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SİRKE", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Trabzon Usulü Karalahana Sarması (Etli)', null, '**Hazırlık / Mise en Place**
1. Karalahana yapraklarını ayırıp kalın sap kısımlarını inceltin; kaynar suda kısaca haşlayıp (bu süre aşağıdaki toplama dahildir) yumuşatın.
2. Pirinci yıkayıp süzün, kuru soğanı rendeleyin. Pirinç, soğan, kıyma, tuz ve karabiberi harmanlayın.
3. Harcı yapraklara paylaştırıp sarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Sarmaları tencereye sıkı dizin. 200 ml (200 g) sıcak su ekleyin, üzerine ters bir tabak kapatıp tencerenin kapağını kapatın. Kaynayınca ateşi kısıp pirinç ve et tamamen pişene kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Yapraklar haşlanırken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~38 dk · Pasif bekleme ~17 dk · Toplam ~55 dk',
        '[{"sira": 1, "ad": "Hazırlık / Sarma", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARALAHANA", "PİRİNÇ (HAM)", "DANA KIYMA", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bayburt Usulü Kuru Fasulye Çorbası', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağında soğanı 3-4 dk kavurun. Islatılmış fasulyeyi ekleyin, 350 ml (350 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.
2. Son işlemler: El blenderiyle kısmen ezip kıvam vererek servis edin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "KURU SOĞAN", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 350}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karadeniz Usulü Elmalı Ceviz Tatlısı', null, '**Hazırlık / Mise en Place**
1. Elmaları soyup ince dilimleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tavada, 25 dk): Tereyağını tavada eritin, elma dilimlerini ekleyip 5-6 dk çevirin. Şekeri ekleyip elmalar yumuşayıp hafif karamelize olana kadar (~15-18 dk) kısık ateşte pişirin.
2. Son işlemler: Üzerine kırılmış cevizi serperek ılık servis edin.

**PARALEL YAPILABİLİRLİK:** Elma pişerken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~15 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ELMA", "ŞEKER", "TEREYAĞI"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Muş Usulü Kuzu Haşlama', null, '**Hazırlık / Mise en Place**
1. Kuzu butu kağıt havluyla kurulayın; büyükse tencereye sığacak parçalara ayırın.
2. Kuru soğanı iri dilimleyin.

**Isıl İşlem**
1. Haşlama (~95°C, tencerede, 75 dk): Tencereye 800 ml (800 g) su koyup kaynatın. Eti ve soğanı ekleyin, tuz ve karabiberi serpin; kaynayınca ateşi kısıp kapağı kapalı olarak et kemikten kolayca ayrılacak kadar yumuşayana kadar pişirin.
2. Son işlemler: Eti süzüp lif lif ayırarak veya bütün parçalar halinde, isteğe göre haşlama suyuyla birlikte servis edin.

**PARALEL YAPILABİLİRLİK:** Haşlama kapaklı ve kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~70 dk · Toplam ~90 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 75, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (BUT)", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 800}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ağrı Usulü Lorlu Kavurma (Etsiz)', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı ince yarım ay dilimleyin.
2. Cevizleri kabaca kırın.

**Isıl İşlem**
1. Kavurma (~80°C, tavada, 10 dk): Tereyağında soğanı 3-4 dk kavurun. Lor peynirini ekleyip pul biber ve tuzla birlikte 5-6 dk çevirerek kavurun.
2. Son işlemler: Üzerine kırılmış cevizi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Soğan kavrulurken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LOR PEYNİRİ", "KURU SOĞAN", "TEREYAĞI", "PUL BİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kars Usulü Kaşarlı Kete', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, ılık su, tuz ve tereyağının bir kısmıyla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kaşarı rendeleyin.
3. Hamuru açıp bir yarısına rendelenmiş kaşarı yayın, katlayıp yuvarlak veya oval şekil verin.

**Isıl İşlem**
1. Fırınlama (200°C, 15 dk): Üzerine kalan tereyağını sürün. 200°C''ye önceden ısıtılmış fırında kızarana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~10 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "KAŞAR PEYNİRİ", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 40}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Bitlis Usulü Karışık Dolma (Etli)', null, '**Hazırlık / Mise en Place**
1. Kabakların içini oyun, biberlerin sap kısmını kapak olarak kesip çekirdeklerini temizleyin.
2. Pirinci yıkayıp süzün, kuru soğanı rendeleyin. Pirinç, soğan, kıyma, tuz ve karabiberi harmanlayın.
3. Harcı kabak ve biberlere, pirincin şişme payı için boşluk bırakarak doldurun.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 30 dk): Dolmaları tencereye dizin. 250 ml (250 g) sıcak su ekleyin, üzerine ters bir tabak kapatıp kapağı kapatın. Kaynayınca ateşi kısıp pirinç ve et tamamen pişip sebzeler yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Sebzeler oyulurken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~28 dk · Pasif bekleme ~22 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık / Doldurma", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KABAK", "YEŞİL BİBER", "PİRİNÇ (HAM)", "DANA KIYMA", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Iğdır Usulü Kayısılı Pilav', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, kuru kayısıları ikiye bölün.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında pirinci 2 dk çevirin. Sıcak tavuk suyu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç yarı pişene kadar (~10 dk) pişirin. Kayısıları ekleyip pirinç suyunu tamamen çekene kadar pişirmeye devam edin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken kayısı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~16 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PİRİNÇ (HAM)", "KURU KAYISI", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzincan Usulü Tulumlu Makarna', null, '**Hazırlık / Mise en Place**
1. Tulum peynirini ufalayın.

**Isıl İşlem**
1. Haşlama ve Karıştırma (~100°C, tencerede, 20 dk): Tencereye 700 ml (700 g) su koyup kaynatın, tuz ekleyin. Makarnayı paket üzerindeki süreye göre haşlayıp süzün (haşlama suyundan birkaç kaşık ayırın). Tereyağını tencerede eritip haşlanmış makarnayı, tulum peynirini ve ayrılan haşlama suyunu ekleyip peynir eriyip makarnaya bulaşana kadar karıştırın.

**PARALEL YAPILABİLİRLİK:** Su kaynarken tulum peyniri ufalanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme ~10 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama ve Karıştırma", "sure_dakika": 20, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MAKARNA", "TULUM PEYNİRİ", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 700}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Van Usulü Pazılı Kavurma (Etli)', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Pazıyı yıkayıp iri kıyın, kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 12-15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Pazıyı, tuz ve karabiberi ekleyip pörsüyüp yumuşayana kadar (~7-8 dk) pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken pazı yıkanıp kıyılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "PAZI", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Doğu Anadolu Cevizli Kayısı Kurusu Tatlısı', null, '**Hazırlık / Mise en Place**
1. Kuru kayısıları ortasından kesip açın.
2. Cevizleri kabaca kırın, her kayısının içine bir parça ceviz yerleştirip üzerine bal gezdirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Kayısı hazırlanırken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gaziantep Usulü Fıstıklı Kebap', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyin.
2. Kıyma, rendelenmiş soğan, antep fıstığı, tuz ve karabiberi iyice yoğurup şiş etrafında veya elde uzun köfte şekli verin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 25 dk): Iyice ısıtılmış ızgarada köfteleri her yüzü 5-6 dk olacak şekilde çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte harcı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "ANTEP FISTIĞI", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şanlıurfa Usulü Patlıcan Kebabı', null, '**Hazırlık / Mise en Place**
1. Fırını 200°C''ye ısıtmaya başlayın.
2. Patlıcanları kalın dilimler halinde kesin, hafif tuzlayıp 10 dk (aşağıdaki süreye dahil değildir) acı suyunu çıkarmaya bırakın, sonra kurulayın.
3. Kuru soğanı rendeleyin. Kıyma, rendelenmiş soğan, tuz ve karabiberi yoğurup köfte şekli verin.

**Isıl İşlem**
1. Fırınlama (200°C, 25 dk): Patlıcan dilimlerini fırın tepsisine yayın, köfteleri araya yerleştirin, domatesi dilimleyip üzerine dizin. 200°C''ye önceden ısıtılmış fırında patlıcan ve köfte pişip üzeri hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken köfte harcı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~17 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["PATLICAN", "KUZU KIYMA", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Diyarbakır Usulü Cevizli Biber Salatası', null, '**Hazırlık / Mise en Place**
1. Yeşil biberleri ince şeritler halinde doğrayın.
2. Cevizleri kabaca kırın, sarımsağı ezin.
3. Biber, ceviz ve sarımsağı bir kapta karıştırın, zeytinyağı ve nar ekşisiyle tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Biber doğranırken ceviz kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mardin Usulü Susamlı Marul Salatası', null, '**Hazırlık / Mise en Place**
1. Marulu ayıklayıp yıkayın, elinizle parçalayın.
2. Susamı kuru bir tavada hafifçe kavurabilirsiniz (isteğe bağlı).
3. Marulu susam, zeytinyağı, nar ekşisi ve tuzla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Siirt Usulü Perde Pilavı', null, '**Hazırlık / Mise en Place**
1. Fırını 180°C''ye ısıtmaya başlayın, kalıbı (kase veya küçük fırın kabı) yağlayın.
2. Pirinci yıkayıp süzün, kuru soğanı küçük küp doğrayın, tavuk göğsünü kuşbaşı doğrayın.
3. Tereyağının bir kısmında soğanı 3-4 dk kavurun, tavuğu ekleyip 5 dk çevirin. Pirinci ekleyip 2 dk karıştırın, antep fıstığını ve tuzu ekleyin.
4. Kalıbı yufkayla kaplayın, harcı içine doldurup yufkayla üzerini kapatın.

**Isıl İşlem**
1. Fırınlama (180°C, 35 dk): Kalıbı fırın tepsisine yerleştirin. Sıcak tavuk suyunu yufkanın kenarından ekleyin. 180°C''ye önceden ısıtılmış fırında yufka altın rengi olup pirinç tamamen pişene kadar pişirin.
2. Son işlemler: Fırından çıkarıp birkaç dakika dinlendirin (dinlenme süresi özete dahil değildir), ters çevirerek kalıptan çıkarıp dilimleyin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~25 dk · Toplam ~60 dk',
        '[{"sira": 1, "ad": "Hazırlık / Kalıp Hazırlama", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["PİRİNÇ (HAM)", "TAVUK GÖĞÜS", "YUFKA", "KURU SOĞAN", "TAVUK SUYU", "ANTEP FISTIĞI", "TEREYAĞI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Batman Usulü Etli Yaprak Sarma', null, '**Hazırlık / Mise en Place**
1. Salamura yaprakları tuzunu gidermek için birkaç kez ılık suda durulayın (bu süre aşağıdaki toplama dahil değildir).
2. Pirinci yıkayıp süzün, kuru soğanı rendeleyin. Pirinç, soğan, kıyma, tuz ve karabiberi harmanlayın.
3. Harcı yapraklara paylaştırıp sıkıca sarın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Sarmaları tencereye sıkı dizin. 250 ml (250 g) sıcak su ve limon suyunu ekleyin, üzerine ters bir tabak kapatıp kapağı kapatın. Kaynayınca ateşi kısıp pirinç ve et tamamen pişip yapraklar yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Yapraklar durulanırken iç harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~43 dk · Pasif bekleme ~17 dk · Toplam ~60 dk',
        '[{"sira": 1, "ad": "Hazırlık / Sarma", "sure_dakika": 35, "aktif_dakika": 35, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SALAMURA YAPRAK", "PİRİNÇ (HAM)", "DANA KIYMA", "KURU SOĞAN", "LİMON SUYU", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şırnak Usulü Kuzu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 4-5 dk kavurun, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kilis Usulü Zeytinyağlı Nohutlu Salata', null, '**Hazırlık / Mise en Place**
1. Haşlanmış nohutu süzün.
2. Domates ve yeşil biberi küçük küp doğrayın.
3. Nohut, domates ve biberi bir kapta karıştırın, zeytinyağı, sumak ve tuzla tatlandırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Sebzeler doğranırken nohut süzülebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
end $$;

-- Dogrulama: hazirlik_dakika = asama_toplami olmali VE her ISIL
-- asamada en az 1 baglı malzeme olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('Tekirdağ Köftesi'),
    ('Çanakkale Peynir Helvası'),
    ('Balıkesir Kaymaklı Kayısı Tatlısı'),
    ('İstanbul Usulü Etli Kuru Fasulye'),
    ('Marmara Usulü Kabak Mücveri'),
    ('Bandırma Usulü Tavuk Sote'),
    ('Marmara Usulü Fırında Lüfer'),
    ('Marmara Usulü Vişneli Yoğurt Dondurması'),
    ('Kemalpaşa Köftesi'),
    ('Aydın İncirli Kuzu Tandır'),
    ('Muğla Yeşil Erik Salatası'),
    ('Foça Usulü Kalamar Tava'),
    ('Ege Yeşil Zeytinli Havuç Salatası'),
    ('İzmir Usulü Nohutlu Bamya'),
    ('Ege Zeytinyağlı Bakla ve Enginar'),
    ('İzmir Lokması'),
    ('Antalya Usulü Etli Nohut Yemeği'),
    ('Mersin Usulü Nohutlu Bulgur Aşı'),
    ('Hatay Usulü Tepsi Kebabı'),
    ('Adana Usulü Analı Kızlı Çorba'),
    ('Antalya Yeşil Erik Hoşafı'),
    ('Mersin Usulü Portakallı Zeytin Salatası'),
    ('Akdeniz Usulü Enginar Kalpli Salata'),
    ('Antalya Usulü Şeftalili Tavuk Sote'),
    ('Sivas Usulü Kes Kes'),
    ('Kırşehir Usulü Nohutlu Yahni'),
    ('Aksaray Usulü Bulgurlu Köfte (Fırında)'),
    ('Nevşehir Üzümlü Kabak Tatlısı'),
    ('Konya Usulü Mercimekli Ekmek Aşı'),
    ('Ankara Usulü Zerde'),
    ('Niğde Usulü Zeytinyağlı Nohut'),
    ('Kapadokya Usulü Karışık Kış Turşusu'),
    ('Samsun Usulü Kaşarlı Sucuklu Pide'),
    ('Ordu Usulü Fındıklı Pilav'),
    ('Rize Usulü Mantar Kavurması (Etli)'),
    ('Giresun Usulü Fasulye Turşusu'),
    ('Trabzon Usulü Karalahana Sarması (Etli)'),
    ('Bayburt Usulü Kuru Fasulye Çorbası'),
    ('Karadeniz Usulü Elmalı Ceviz Tatlısı'),
    ('Muş Usulü Kuzu Haşlama'),
    ('Ağrı Usulü Lorlu Kavurma (Etsiz)'),
    ('Kars Usulü Kaşarlı Kete'),
    ('Bitlis Usulü Karışık Dolma (Etli)'),
    ('Iğdır Usulü Kayısılı Pilav'),
    ('Erzincan Usulü Tulumlu Makarna'),
    ('Van Usulü Pazılı Kavurma (Etli)'),
    ('Doğu Anadolu Cevizli Kayısı Kurusu Tatlısı'),
    ('Gaziantep Usulü Fıstıklı Kebap'),
    ('Şanlıurfa Usulü Patlıcan Kebabı'),
    ('Diyarbakır Usulü Cevizli Biber Salatası'),
    ('Mardin Usulü Susamlı Marul Salatası'),
    ('Siirt Usulü Perde Pilavı'),
    ('Batman Usulü Etli Yaprak Sarma'),
    ('Şırnak Usulü Kuzu Kavurma'),
    ('Kilis Usulü Zeytinyağlı Nohutlu Salata')
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
