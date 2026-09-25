-- 156_talimat_ve_asama_grup2.sql (Revizyon 2)
-- 515 yeni tarifin talimat+asama yazimi -- Grup 2: Parti1(tarif-
-- ekleme)'in kalani (Akdeniz 7 + İç Anadolu 6 + Karadeniz 8 +
-- Doğu Anadolu 8 + Güneydoğu Anadolu 8 = 38 tarif).
-- REVIZYON 2: 'Ankara Tava (Kuzu Etli)' icin unutulan su_ekle
-- (200g) eklendi -- ilk deneme bu yuzden 'Malzeme tarifte yok: SU'
-- hatasiyla HICBIR SEY eklemeden geri alinmisti.
--
-- Fonksiyon her isil asamada FIILEN isitilan TUM malzemeleri
-- asama_malzemeleri'ne bagliyor (155'teki duzeltmeyle ayni mantik).
-- 1 tarifte hazirlik_dakika duzeltildi: Siirt Usulü Büryan 30->150.

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
        'Antalya Usulü Nohut Piyazı', null, '**Hazırlık / Mise en Place**
1. Haşlanmış nohutu süzüp durulayın.
2. Kuru soğanı ince yarım ay dilimleyin, maydanozu ince kıyın.
3. Nohut, soğan ve maydanozu bir kapta birleştirin. Zeytinyağı, limon suyu, sumak ve tuzu ekleyip karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Soğan doğranırken maydanoz kıyılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mersin Tantunisi', null, '**Hazırlık / Mise en Place**
1. Bonfileyi çok ince şeritler halinde kesin.
2. Kuru soğanı ve yeşil biberi ince şeritler halinde doğrayın.

**Isıl İşlem**
1. Sote (~80°C, tavada yüksek ateşte, 17 dk): Mısır yağını iyice kızdırın. Eti ekleyip 3-4 dk yüksek ateşte suyunu salmadan mühürleyin. Soğan ve biberi ekleyip 5-6 dk daha çevirerek pişirin. Tuz ve karabiberi serpin.
2. Son işlemler: Lavaşı ısıtıp içine tantuniyi doldurun, üzerine sumak serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Et pişerken lavaş ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme yok · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 17, "aktif_dakika": 17, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 80, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA BONFİLE", "MISIR YAĞI", "KURU SOĞAN", "YEŞİL BİBER", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Hatay Usulü İçli Köfte (Etli)', null, '**Hazırlık / Mise en Place**
1. Bulguru ıslatıp yumuşamaya bırakın (bu bekleme aşağıdaki süreye dahil değildir).
2. İç harç için kıymanın yarısını kuru soğan, ceviz, tuz, karabiber ve pul biberle kavurup soğutun.
3. Kalan kıyma ile ıslatılmış bulguru yoğurup dış hamuru elde edin; avuç içinde şekillendirip ortasını iç harçla doldurarak kapatın.

**Isıl İşlem**
1. Haşlama (~100°C, tencerede, 20 dk): Tencereye 150 ml (150 g) su koyup kaynatın, tuz ekleyin. Köfteleri kaynayan suya bırakıp yüzeye çıkıp pişene kadar (~8 dk) haşlayın.

**PARALEL YAPILABİLİRLİK:** Haşlama suyu ısınırken köfteler şekillendirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~48 dk · Pasif bekleme ~12 dk · Toplam ~60 dk',
        '[{"sira": 1, "ad": "Hazırlık / İç Harç ve Dış Hamur", "sure_dakika": 40, "aktif_dakika": 40, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Haşlama", "sure_dakika": 20, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "DANA KIYMA", "KURU SOĞAN", "CEVİZ (İÇ)", "TUZ", "KARABİBER", "PUL BİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Şakşuka', null, '**Hazırlık / Mise en Place**
1. Patlıcan ve kabağı kalın küp doğrayın; sarımsağı ince kıyın.
2. Yeşil biberi iri doğrayın, domatesi kabuğunu soyup küçük küp kesin.

**Isıl İşlem**
1. Sote (~85°C, tavada, 25 dk): Zeytinyağında patlıcan ve kabağı 8-10 dk çevirerek kızartın. Biberi ekleyip 3 dk çevirin. Sarımsağı, domatesi, 30 ml (30 g) sıcak su ve tuzu ekleyip sebzeler yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılıtın (oda sıcaklığında servis edilir), üzerine sarımsaklı yoğurdu gezdirin.

**PARALEL YAPILABİLİRLİK:** Sebzeler pişerken yoğurt sosu hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~10 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Sote", "sure_dakika": 25, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN", "KABAK", "YEŞİL BİBER", "DOMATES", "SARIMSAK", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 30}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Akdeniz Usulü Limonlu Zeytin Ezmesi', null, '**Hazırlık / Mise en Place**
1. Zeytin ezmesini bir kaba alın.
2. Kuru soğanı çok ince kıyın.
3. Zeytinyağı, limon suyu, pul biber ve soğanı ekleyip karıştırın.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Paralel fırsatı yok.

**SÜRE ÖZETİ:** Aktif işçilik ~10 dk · Pasif bekleme yok · Toplam ~10 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Adana Usulü Nar Ekşili Salata', null, '**Hazırlık / Mise en Place**
1. Marulu ayıklayıp yıkayın, elinizle parçalayın.
2. Narı tanelerine ayırın; cevizleri iri kırın.
3. Marul, nar ve cevizi bir kapta karıştırın. Nar ekşisi, zeytinyağı ve tuzla karıştırıp servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Nar taneleri ayrılırken marul yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antalya Usulü Şeftali Kompostosu', null, '**Hazırlık / Mise en Place**
1. Şeftalileri yıkayıp ikiye bölün, çekirdeklerini çıkarın, dilimleyin.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 17 dk): 70 ml (70 g) su ve şekeri kaynatın. Şeftali dilimlerini ekleyip yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["ŞEFTALİ", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Ankara Tava (Kuzu Etli)', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Pirinci yıkayıp süzün; kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~90°C, güveç kabında, 35 dk): Tereyağında eti suyunu salıp çekene ve renk alana kadar 10 dk kavurun. Soğanı ekleyip 3-4 dk kavurun. Pirinci, 200 ml (200 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve pirinç yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken pirinç yıkanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~25 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "PİRİNÇ (HAM)", "KURU SOĞAN", "TEREYAĞI", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 200}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Konya Etli Ekmek', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, az su ve tuzla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 10 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kuru soğanı rendeleyin, domatesin kabuğunu soyup küçük küp doğrayın.
3. Kıyma, rendelenmiş soğan, domates, tuz ve pul biberi karıştırıp harcı hazırlayın.
4. Hamuru ince, uzun oval şekilde açıp kenarlarını hafif kıvırın, üzerine harcı ince bir tabaka halinde yayın.

**Isıl İşlem**
1. Fırınlama (220°C, 15 dk): 220°C''ye önceden ısıtılmış, taş veya tepsi üzerinde hamurun kenarları kızarıp harç pişene kadar pişirin.
2. Son işlemler: Fırından çıkarıp üzerine taze maydanoz serperek dilimleyin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~10 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur ve Harç", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "KUZU KIYMA", "DOMATES", "KURU SOĞAN", "TUZ", "PUL BİBER", "SU"], "yeni_su_gram": 30}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Nevşehir Testi Kebabı', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın.
2. Domates ve yeşil biberi küçük küp doğrayın, mantarları dilimleyin, kuru soğanı küçük küp doğrayın.
3. Et ve sebzeleri toprak testiye (veya güveç kabına) katman katman yerleştirin, tuz ve karabiberi serpin.

**Isıl İşlem**
1. Güveç Pişirme / Fırınlama (~90°C, fırında, 70 dk): 50 ml (50 g) sıcak suyu ekleyip testinin ağzını hamur veya folyoyla kapatın. 180°C''ye önceden ısıtılmış fırında et ve sebzeler tamamen yumuşayana kadar pişirin.
2. Son işlemler: Servis anında testinin ağzını (geleneksel yönteme uygun şekilde) kırarak veya kapağını açarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken et ve sebzeler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~60 dk · Toplam ~90 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Güveç Pişirme / Fırınlama", "sure_dakika": 70, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (KOL)", "DOMATES", "YEŞİL BİBER", "KURU SOĞAN", "MANTAR", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 50}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kayseri Yağlaması', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyin.
2. Kıyma, rendelenmiş soğan, tuz ve pul biberi karıştırıp harcı hazırlayın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~85°C, sac tavada, 25 dk): Kıyma harcını tavada suyunu salıp çekene kadar 12-15 dk kavurun. Lavaşları eritilmiş tereyağıyla hafifçe ıslatıp üzerlerine kavrulmuş kıymayı yayın, sac tavada her iki yüzü de ısınıp hafif renk alana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Kıyma kavrulurken lavaşlar hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma ve Pişirme", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 85, "enerji_kaynagi": "dogalgaz", "malzemeler": ["LAVAŞ", "KUZU KIYMA", "KURU SOĞAN", "TEREYAĞI", "PUL BİBER", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kapadokya Kestaneli Komposto', null, '**Hazırlık / Mise en Place**
1. Kestaneleri (haşlanmış/kabuğu soyulmuş) iri parçalar halinde bölün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 22 dk): 70 ml (70 g) su ve şekeri kaynatın. Kestaneleri ekleyip kısık ateşte yumuşayana kadar pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KESTANE", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kayseri Usulü Nohutlu Bulgur Pilavı', null, '**Hazırlık / Mise en Place**
1. Bulguru yıkayıp süzün; nohut haşlanmışsa süzüp hazırlayın.
2. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 22 dk): Tereyağında soğanı 3-4 dk kavurun. Bulguru ekleyip 2 dk çevirin. Nohudu, sıcak tavuk suyunu ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak bulgur suyunu çekene kadar pişirin.
2. Son işlemler: Ocaktan alıp 5 dk demlenmeye bırakın (bu süre özete dahil değildir), çatalla karıştırıp servis edin.

**PARALEL YAPILABİLİRLİK:** Tavuk suyu ısıtılırken soğan kavrulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~16 dk · Pasif bekleme ~14 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 22, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["BULGUR", "NOHUT", "KURU SOĞAN", "TEREYAĞI", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Niğde Bademli Un Helvası', null, '**Hazırlık / Mise en Place**
1. Sütü ayrı bir kapta ısıtmaya hazır bulundurun.
2. Bademleri kabaca kırın.

**Isıl İşlem**
1. Kavurma ve Pişirme (~90°C, tencerede, 25 dk): Tereyağında unu kısık ateşte sürekli karıştırarak fındık rengi alıp mis gibi koku çıkana kadar (~15 dk) kavurun. Şekeri ekleyip 2 dk çevirin. Ilık sütü azar azar ekleyip topaklanmadan karıştırarak kıvam alana kadar (~8 dk) pişirin.
2. Son işlemler: Ocaktan alıp üzerini kapatıp 10 dk demlenmeye bırakın (bu süre özete dahil değildir), üzerine kırılmış bademi serperek servis edin.

**PARALEL YAPILABİLİRLİK:** Un kavrulurken süt ayrı bir kapta ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma ve Pişirme", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["EKMEKLİK UN", "TEREYAĞI", "ŞEKER", "SÜT (TAM YAĞ)"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karadeniz Mıhlaması', null, '**Hazırlık / Mise en Place**
1. Kaşarı rendeleyin.

**Isıl İşlem**
1. Pişirme (~90°C, tavada, 15 dk): Tereyağını tavada eritin, mısır ununu ekleyip 2-3 dk kavurun. 60 ml (60 g) sıcak suyu ve tuzu ekleyip sürekli karıştırarak pürüzsüz bir kıvam alana kadar (~7 dk) pişirin. Kaşarı ekleyip eriyip tam kaynaşana kadar (~3-4 dk) karıştırmaya devam edin.

**PARALEL YAPILABİLİRLİK:** Mısır unu kavrulurken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme yok · Toplam ~20 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 5, "aktif_dakika": 5, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["MISIR UNU", "KAŞAR PEYNİRİ", "TEREYAĞI", "SU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karadeniz Kaymaklı Pide', null, '**Hazırlık / Mise en Place**
1. Ekmeklik unu, ılık su, tuz ve yumurtanın bir kısmıyla yoğurup pürüzsüz bir hamur elde edin; üzerini örtüp 15 dk (aşağıdaki süreye dahil değildir) dinlendirin.
2. Kaşarı rendeleyin.
3. Hamuru uzun oval şekilde açıp kenarlarını kıvırarak kayık pide formu verin, ortasına rendelenmiş kaşarı doldurun.

**Isıl İşlem**
1. Fırınlama (220°C, 15 dk): Pidenin kenarlarına kalan yumurtayı sürün. 220°C''ye önceden ısıtılmış fırında kenarları altın rengi olana kadar pişirin.
2. Son işlemler: Fırından çıkar çıkmaz üzerine tereyağını gezdirin.

**PARALEL YAPILABİLİRLİK:** Hamur dinlenirken kaşar rendelenebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~10 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık / Hamur", "sure_dakika": 30, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["EKMEKLİK UN", "KAŞAR PEYNİRİ", "TAVUK YUMURTASI", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 40}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Trabzon Usulü Hamsili Pilav', null, '**Hazırlık / Mise en Place**
1. Hamsileri ayıklayıp iç organlarını temizleyin, yıkayıp süzün.
2. Pirinci yıkayıp süzün; kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 25 dk): Tereyağının yarısında soğanı 3-4 dk kavurun. Pirinci ekleyip 2 dk çevirin. 100 ml (100 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak pirinç suyunu çekene kadar pişirin.
2. Son işlemler: Kalan tereyağında hamsileri her iki yüzü de pişene kadar (~5-6 dk) ayrı bir tavada çevirin, pilavın üzerine ve etrafına dizerek servis edin.

**PARALEL YAPILABİLİRLİK:** Pilav pişerken hamsiler ayrı tavada pişirilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~17 dk · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["HAMSİ", "PİRİNÇ (HAM)", "KURU SOĞAN", "TEREYAĞI", "KARABİBER", "TUZ", "SU"], "yeni_su_gram": 100}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Rize Usulü Karalahana Çorbası', null, '**Hazırlık / Mise en Place**
1. Karalahanayı yıkayıp kalın sap kısımlarını ayırın, yapraklarını ince doğrayın.
2. Kuru fasulye önceden ıslatılmış ve süzülmüş olmalı (ıslatma süresi aşağıdaki süreye dahil değildir).

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 30 dk): Tereyağını tencerede eritip mısır ununu 2 dk kavurun. 400 ml (400 g) sıcak su, ıslatılmış kuru fasulye ve tuzu ekleyin; kaynayınca ateşi kısıp fasulye yumuşamaya başlayana kadar (~15 dk) pişirin. Karalahanayı ekleyip pörsüyüp tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Fasulye pişerken karalahana yıkanıp doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KARALAHANA", "MISIR UNU", "KURU FASULYE", "TEREYAĞI", "TUZ", "SU"], "yeni_su_gram": 400}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Giresun Fındıklı Kuru Fasulye', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 35 dk): Zeytinyağında soğanı 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 300 ml (300 g) sıcak su ve tuzu ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak fasulye tamamen yumuşayana kadar pişirin.
2. Son işlemler: Kırılmış fındığı en son ekleyip 2-3 dk daha pişirip servis edin.

**PARALEL YAPILABİLİRLİK:** Fasulye pişerken fındık kırılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~27 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 35, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "FINDIK (İÇ)", "KURU SOĞAN", "DOMATES", "ZEYTİNYAĞI", "TUZ", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karadeniz Mısır Ekmeği', null, '**Hazırlık / Mise en Place**
1. Fırını 200°C''ye ısıtmaya başlayın, kalıbı yağlayın.
2. Mısır unu, ekmeklik un, kabartma tozu ve tuzu bir kapta karıştırın. Yoğurt ve yumurtayı ekleyip pürüzsüz bir hamur elde edin.

**Isıl İşlem**
1. Fırınlama (200°C, 25 dk): Hamuru kalıba dökün. 200°C''ye önceden ısıtılmış fırında üzeri altın rengi olup ortasına batırılan kürdan temiz çıkana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken hamur hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 25, "aktif_dakika": 5, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["MISIR UNU", "EKMEKLİK UN", "YOĞURT (TAM)", "TAVUK YUMURTASI", "KABARTMA TOZU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Trabzon Usulü Akçaabat Köfte', null, '**Hazırlık / Mise en Place**
1. Kuru soğanı rendeleyin.
2. Kıyma, rendelenmiş soğan, galeta unu, tuz, karabiber ve kimyonu iyice yoğurup ince uzun köfte şekli verin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 20 dk): Iyice ısıtılmış ızgarada köfteleri her yüzü 4-5 dk olacak şekilde çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Izgara ısınırken köfte harcı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme yok · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DANA KIYMA", "KURU SOĞAN", "GALETA UNU (PANKO)", "TUZ", "KARABİBER", "KİMYON"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Karadeniz Dutlu Komposto', null, '**Hazırlık / Mise en Place**
1. Dutları ayıklayıp yıkayın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 17 dk): 60 ml (60 g) su ve şekeri kaynatın. Dutları ekleyip kısık ateşte 8-10 dk pişirin.
2. Son işlemler: Ocaktan alıp ılımaya bırakın (soğuma süresi özete dahil değildir), soğuk servis edin.

**PARALEL YAPILABİLİRLİK:** Pişirme kısık ateşte ilerlediği için bu sürede başka tarifler hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~14 dk · Pasif bekleme ~11 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 6, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["DUT", "ŞEKER", "SU"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzurum Cağ Kebabı', null, '**Hazırlık / Mise en Place**
1. Koyun butunu ince dilimler halinde kesin.
2. Kuru soğanı rendeleyip suyuyla birlikte eti ovun, tuz ve karabiberi serpin; en az 15 dk (bu süre aşağıdaki toplam süreye dahildir) marine edin.

**Isıl İşlem**
1. Izgara (orta-yüksek ateş, ızgarada, 25 dk): Marine edilmiş et dilimlerini ızgarada veya dövme şişte her iki yüzü de mühürlenip iyice pişene kadar çevirerek pişirin.

**PARALEL YAPILABİLİRLİK:** Et marine olurken ızgara ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~15 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık / Marinasyon", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Izgara", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 75, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KOYUN ETİ (BUT)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Erzincan Tulumlu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp doğrayın; tulum peynirini ufalayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 12-15 dk kavurun. Soğanı ekleyip 3-4 dk kavurun, tuz ve karabiberi serpin. Ocaktan almadan hemen önce tulum peynirini ekleyip eriyene kadar (~2 dk) karıştırın.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken tulum peyniri ufalanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "TULUM PEYNİRİ", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Van Otlu Peynirli Kahvaltı Böreği', null, '**Hazırlık / Mise en Place**
1. Otlu peyniri ufalayın, yumurtanın bir kısmıyla karıştırın.
2. Yufkayı açıp harcı bir yarısına yayın, üzerine tereyağının bir kısmını gezdirip katlayın, üzerine kalan yumurtayı sürün.

**Isıl İşlem**
1. Fırınlama (~90°C, sac tavada veya fırında, 15 dk): Kalan tereyağını sürüp katlanmış yufkayı her iki yüzü altın rengi olana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Tava/fırın ısınırken harç hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~23 dk · Pasif bekleme ~7 dk · Toplam ~30 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 15, "aktif_dakika": 8, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["YUFKA", "OTLU PEYNİR", "TEREYAĞI", "TAVUK YUMURTASI", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Malatya Kayısılı Kuzu Yahnisi', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2-2,5 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp doğrayın; kuru kayısıları ikiye bölün.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede kısık ateşte, 40 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. 300 ml (300 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et yumuşamaya başlayana kadar (~25 dk) pişirin. Kayısıları ekleyip et ve kayısı tamamen yumuşayana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Yahni kapaklı ve kısık ateşte pişerken ocak başında beklemek gerekmez.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~30 dk · Toplam ~55 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 40, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU KAYISI", "KURU SOĞAN", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Elazığ Usulü Kuru Fasulye Kavurması', null, '**Hazırlık / Mise en Place**
1. Kuru fasulyeyi pişirmeden en az 8 saat önceden ıslatın; ıslatma süresi aşağıdaki süreye dahil değildir. Pişirmeden önce suyunu süzüp durulayın.
2. Kuru soğanı küçük küp, domatesi küçük küp doğrayın.

**Isıl İşlem**
1. Pişirme (~100°C, tencerede, 30 dk): Kıymayı kendi yağında suyunu salıp çekene kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Domatesi ekleyip 3 dk pişirin. Islatılmış fasulyeyi ekleyin, 250 ml (250 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp fasulye tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Su ısıtılırken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~20 dk · Pasif bekleme ~20 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 30, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 100, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KURU FASULYE", "DANA KIYMA", "KURU SOĞAN", "DOMATES", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 250}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Kars Usulü Kaz Eti Kavurması', null, '**Hazırlık / Mise en Place**
1. Kaz etini parçalara ayırın.
2. Kuru soğanı ince yarım ay dilimleyin.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 35 dk): Kaz etini kendi yağında kısık-orta ateşte, arada çevirerek 25-28 dk kavurun (et zaten tuzlu olduğu için tuzu azar azar ekleyin). Soğanı ekleyip 3-4 dk kavurun, karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~15 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 35, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)", "KURU SOĞAN", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Doğu Anadolu Pekmezli Ceviz Ezmesi', null, '**Hazırlık / Mise en Place**
1. Cevizleri kabaca kırın.
2. Mısır nişastasını birkaç kaşık pekmezle pürüzsüz bir bulamaç haline getirin, kalan pekmezle karıştırın.
3. Ceviz parçalarını ekleyip karıştırın, kalıba dökülüp soğutulabilir (soğutma süresi özete dahil değildir).

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Ceviz kırılırken pekmez karışımı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Doğu Anadolu Kayısı ve Ceviz Salatası', null, '**Hazırlık / Mise en Place**
1. Kayısıları dörde bölün; cevizleri iri kırın.
2. Yoğurdu şekerle çırpın. Kayısı ve cevizi ekleyip karıştırın veya üzerine serperek servis edin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Kayısı doğranırken yoğurt karışımı hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~15 dk · Pasif bekleme yok · Toplam ~15 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Gaziantep Alinazik Kebabı', null, '**Hazırlık / Mise en Place**
1. Sarımsağı ezip yoğurtla karıştırın, buzdolabında bekletin.
2. Kuzu kıymayı tuz ve karabiberle harmanlayın.

**Isıl İşlem**
1. Közleme (~95°C, ocak alevinde veya ızgarada, 20 dk): Patlıcanları çatalla delip doğrudan alevde veya ızgarada kabukları simsiyah olup içi tamamen yumuşayana kadar çevirerek közleyin.
2. Kavurma (~90°C, tavada, 25 dk): Közlenmiş patlıcanların kabuklarını soyup etini bıçakla döverek ezin. Tereyağında kıymayı suyunu salıp çekene ve renk alana kadar kavurun.

**Son işlemler:** Ezilmiş patlıcanı sarımsaklı yoğurtla karıştırın (bu karışım pişirilmez). Servis tabağına yayıp üzerine sıcak kavrulmuş kıymayı gezdirerek servis edin.

**PARALEL YAPILABİLİRLİK:** Patlıcan közlenirken sarımsaklı yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~10 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Közleme", "sure_dakika": 20, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["PATLICAN"], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 15, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU KIYMA", "TEREYAĞI", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Şanlıurfa Usulü Çiğ Köfte (Etsiz)', null, '**Hazırlık / Mise en Place**
1. İnce bulguru 60 ml (60 g) ılık suyla nemlendirip 10 dk (bu süre aşağıdaki toplam süreye dahildir) yumuşamaya bırakın.
2. Sarımsağı tuzla ezin.
3. Yumuşayan bulguru biber salçası, ezilmiş sarımsak, pul biber ve tuzla iyice yoğurun; hamur pürüzsüz ve yapışkan kıvama gelene kadar yoğurmaya devam edin.
4. Nar ekşisini ekleyip son kez yoğurun, küçük parçalar halinde şekil verin, üzerine kırılmış cevizi serpiştirin.

**Isıl İşlem**
Isıl işlem yok.

**PARALEL YAPILABİLİRLİK:** Bulgur yumuşarken sarımsak ezilebilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~10 dk · Toplam ~40 dk',
        '[{"sira": 1, "ad": "Hazırlık / Yoğurma", "sure_dakika": 40, "aktif_dakika": 30, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": 60}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Urfa Usulü Kuzu Kavurma', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Kuru soğanı küçük küp doğrayın.

**Isıl İşlem**
1. Kavurma (orta ateş, tencerede, 25 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar 15 dk kavurun. Soğanı ekleyip 4-5 dk kavurun, pul biber, tuz ve karabiberi serpin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken soğan doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme yok · Toplam ~35 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 10, "aktif_dakika": 10, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Kavurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "KURU SOĞAN", "PUL BİBER", "TUZ", "KARABİBER"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Mardin Usulü Kaburga Dolması', null, '**Hazırlık / Mise en Place**
1. Sığır kaburgayı, aralarına harç doldurulacak şekilde kemikler arasından cep açarak hazırlayın (kasaptan bu şekilde temizletilmesi önerilir).
2. Pirinci yıkayıp süzün, kuru soğanı rendeleyin. Pirinç, soğan, kimyon, tuz ve karabiberi harmanlayın.
3. Harcı kaburganın cebine, pirincin şişme payı için gevşek doldurun, açık ağzını dikip veya kürdanla kapatın.

**Isıl İşlem**
1. Fırınlama (~90°C, fırında, 65 dk): Kaburgayı fırın tepsisine yerleştirin, 300 ml (300 g) sıcak suyu tepsiye ekleyin, tepsiyi folyoyla sıkıca kapatın. 180°C''ye önceden ısıtılmış fırında et ve iç pirinç tamamen pişene kadar pişirin.
2. Son işlemler: Son 10 dakika folyoyu açıp üzeri hafif kızarana kadar pişirmeye devam edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken kaburga doldurulabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~55 dk · Toplam ~90 dk',
        '[{"sira": 1, "ad": "Hazırlık / Doldurma", "sure_dakika": 25, "aktif_dakika": 25, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama", "sure_dakika": 65, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "elektrik", "malzemeler": ["SIĞIR KABURGA", "PİRİNÇ (HAM)", "KURU SOĞAN", "KİMYON", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 300}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Diyarbakır Usulü Meftune', null, '**Hazırlık / Mise en Place**
1. Kuzu etini 2 cm kuşbaşı doğrayın.
2. Patlıcan ve kabağı kalın küp, domatesi küçük küp doğrayın. Kuru soğanı küçük küp doğrayın, sarımsağı ince kıyın.

**Isıl İşlem**
1. Güveç Pişirme (~90°C, güveç kabında, 35 dk): Eti kendi yağında suyunu salıp çekene ve renk alana kadar kavurun. Soğanı ekleyip 3-4 dk kavurun. Patlıcan ve kabağı ekleyip 5 dk çevirin. Sarımsağı, domatesi, 150 ml (150 g) sıcak su, tuz ve karabiberi ekleyin; kaynayınca ateşi kısıp kapağı kapalı olarak et ve sebzeler tamamen yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Et kavrulurken sebzeler doğranabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~25 dk · Toplam ~50 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Güveç Pişirme", "sure_dakika": 35, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["KUZU ETİ (KOL)", "PATLICAN", "KABAK", "DOMATES", "KURU SOĞAN", "SARIMSAK", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 150}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antep Usulü Yuvalama Çorbası', null, '**Hazırlık / Mise en Place**
1. Pirinci yıkayıp süzün, kıyma ile karıştırıp tuz ekleyin; fındık büyüklüğünde küçük köfteler yuvarlayın.
2. Yoğurdu oda sıcaklığına gelmesi için önceden çıkarın, pürüzsüz olana kadar çırpın.

**Isıl İşlem**
1. Pişirme (~95°C, tencerede, 25 dk): Tavuk suyunu kaynatın, köfteleri ekleyip yüzeye çıkıp pişene kadar (~12-15 dk) haşlayın. Bir kepçe sıcak suyu yavaşça yoğurda ekleyip çırparak ısındırın (kesilmemesi için), ardından yoğurt karışımını tencereye geri, karıştırarak ve kaynatmadan ekleyin.
2. Son işlemler: Tereyağını eritip üzerine kuru nane ekleyerek nane yağı hazırlayın, servis anında çorbanın üzerine gezdirin.

**PARALEL YAPILABİLİRLİK:** Köfteler haşlanırken yoğurt hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~35 dk · Pasif bekleme ~10 dk · Toplam ~45 dk',
        '[{"sira": 1, "ad": "Hazırlık / Köfte Şekillendirme", "sure_dakika": 20, "aktif_dakika": 20, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 25, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "dogalgaz", "malzemeler": ["YOĞURT (TAM)", "PİRİNÇ (HAM)", "DANA KIYMA", "TAVUK SUYU", "TUZ"], "yeni_su_gram": null}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Siirt Usulü Büryan', 150, '**Hazırlık / Mise en Place**
1. Fırını 160°C''ye ısıtmaya başlayın.
2. Kuzu butu kağıt havluyla kurulayın, tuz ve karabiberi her tarafına ovun.

**Isıl İşlem**
1. Fırınlama (Kapalı Kapta) (160°C, 135 dk): Butu derin bir güveç veya döküm tencereye yerleştirin. 30 ml (30 g) suyu kabın dibine ekleyin, kabın kapağını sıkıca kapatın (kapak yoksa folyoyla sıkıca örtün). 160°C''ye önceden ısıtılmış fırında et kemikten kolayca ayrılacak kadar yumuşayana kadar (kendi buharında) pişirin.
2. Son işlemler: Fırından çıkarıp 10 dk dinlendirin (dinlenme süresi özete dahil değildir), eti lif lif ayırarak servis edin.

**PARALEL YAPILABİLİRLİK:** Fırın ısınırken et hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~25 dk · Pasif bekleme ~125 dk · Toplam ~150 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 15, "aktif_dakika": 15, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Fırınlama (Kapalı Kapta)", "sure_dakika": 135, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 95, "enerji_kaynagi": "elektrik", "malzemeler": ["KUZU ETİ (BUT)", "TUZ", "KARABİBER", "SU"], "yeni_su_gram": 30}]'::jsonb
    );
    perform _talimat_ve_asama_ekle_v2(
        'Antep Fıstıklı Muhallebi', null, '**Hazırlık / Mise en Place**
1. Pirinç ununu birkaç kaşık soğuk sütle pürüzsüz bir bulamaç haline getirin.
2. Antep fıstığını kabaca kırın.

**Isıl İşlem**
1. Pişirme (~90°C, tencerede, 17 dk): Kalan sütü ve şekeri bir tencerede ısıtın. Kaynamaya yakın gelince pirinç unu bulamacını azar azar ekleyip sürekli karıştırarak kıvam koyulaşana kadar (~10 dk) pişirin.
2. Son işlemler: Servis kabına alıp üzerini streç filmle kapatarak kabuk bağlamasını önleyin, ılıyınca buzdolabına kaldırıp soğutun (soğutma süresi özete dahil değildir), üzerine kırılmış Antep fıstığını serpin.

**PARALEL YAPILABİLİRLİK:** Bulamaç hazırlanırken süt ısıtılabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~18 dk · Pasif bekleme ~7 dk · Toplam ~25 dk',
        '[{"sira": 1, "ad": "Hazırlık", "sure_dakika": 8, "aktif_dakika": 8, "isil_islem_mi": false, "baslangic_sicaklik": null, "hedef_sicaklik": null, "enerji_kaynagi": null, "malzemeler": [], "yeni_su_gram": null}, {"sira": 2, "ad": "Pişirme", "sure_dakika": 17, "aktif_dakika": 10, "isil_islem_mi": true, "baslangic_sicaklik": 20, "hedef_sicaklik": 90, "enerji_kaynagi": "dogalgaz", "malzemeler": ["SÜT (TAM YAĞ)", "ANTEP FISTIĞI", "ŞEKER", "PİRİNÇ UNU"], "yeni_su_gram": null}]'::jsonb
    );
end $$;

-- Dogrulama: hazirlik_dakika = asama_toplami olmali VE her ISIL
-- asamada en az 1 baglı malzeme olmali. 0 satir donmesi beklenir.
with liste(ad) as (values
    ('Antalya Usulü Nohut Piyazı'),
    ('Mersin Tantunisi'),
    ('Hatay Usulü İçli Köfte (Etli)'),
    ('Antalya Şakşuka'),
    ('Akdeniz Usulü Limonlu Zeytin Ezmesi'),
    ('Adana Usulü Nar Ekşili Salata'),
    ('Antalya Usulü Şeftali Kompostosu'),
    ('Ankara Tava (Kuzu Etli)'),
    ('Konya Etli Ekmek'),
    ('Nevşehir Testi Kebabı'),
    ('Kayseri Yağlaması'),
    ('Kapadokya Kestaneli Komposto'),
    ('Kayseri Usulü Nohutlu Bulgur Pilavı'),
    ('Niğde Bademli Un Helvası'),
    ('Karadeniz Mıhlaması'),
    ('Karadeniz Kaymaklı Pide'),
    ('Trabzon Usulü Hamsili Pilav'),
    ('Rize Usulü Karalahana Çorbası'),
    ('Giresun Fındıklı Kuru Fasulye'),
    ('Karadeniz Mısır Ekmeği'),
    ('Trabzon Usulü Akçaabat Köfte'),
    ('Karadeniz Dutlu Komposto'),
    ('Erzurum Cağ Kebabı'),
    ('Erzincan Tulumlu Kavurma'),
    ('Van Otlu Peynirli Kahvaltı Böreği'),
    ('Malatya Kayısılı Kuzu Yahnisi'),
    ('Elazığ Usulü Kuru Fasulye Kavurması'),
    ('Kars Usulü Kaz Eti Kavurması'),
    ('Doğu Anadolu Pekmezli Ceviz Ezmesi'),
    ('Doğu Anadolu Kayısı ve Ceviz Salatası'),
    ('Gaziantep Alinazik Kebabı'),
    ('Şanlıurfa Usulü Çiğ Köfte (Etsiz)'),
    ('Urfa Usulü Kuzu Kavurma'),
    ('Mardin Usulü Kaburga Dolması'),
    ('Diyarbakır Usulü Meftune'),
    ('Antep Usulü Yuvalama Çorbası'),
    ('Siirt Usulü Büryan'),
    ('Antep Fıstıklı Muhallebi')
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
