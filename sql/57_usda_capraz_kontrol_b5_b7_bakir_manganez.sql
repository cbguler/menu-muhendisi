-- 57_usda_capraz_kontrol_b5_b7_bakir_manganez.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): TürKomp'un SISTEMIK olarak
-- icermedigi 4 alan (Vitamin B5, B7, Bakir, Manganez) 111 malzeme icin
-- USDA FoodData Central'dan (Foundation + SR Legacy) cekildi.
--
-- AYRICA: DONYAĞI ve SADEYAĞ -- Turk kaynaklarinda (TürKomp dahil)
-- kapsamli arastirmaya ragmen bulunamadigi icin -- kullanicinin acik
-- onayiyla USDA'nin en yakin esdegerlerinden (sirasiyla "Fat, beef
-- tallow" ve "Clarified butter (ghee)") TAM PROFIL alindi.
--
-- ESLESTIRME SURECI (onemli, seffaflik icin): ilk otomatik arama
-- turunde CIDDI yanlis eslesmeler bulundu (ör. SIĞIR PİRZOLA -> domuz
-- eti, HİNDİ ETİ -> tavuk, KUZU ETİ -> kurbaga bacagi, KAZ ETİ ->
-- kaz CIGERI, BERLAM/ZARGANA -> "Abiyuch" adli tropik meyve). Bunlarin
-- hepsi anahtar-kelime dogrulamasiyla (sonuc aciklamasinda beklenen
-- kelimenin GECMESI, yasakli kelimenin GECMEMESI sarti) tek tek
-- bulunup duzeltildi. BUĞDAY NİŞASTASI icin dogru bir USDA karsiligi
-- bulunamadi (surekli ekmek/seker urunleriyle eslesti) -- bu malzeme
-- icin B5/B7/Bakir/Manganez BOS BIRAKILDI.
--
-- RENK KODU: USDA kaynakli degerler MAVI (mevcut SOMON gibi eski
-- USDA-kaynakli hucrelerle AYNI renk) ile isaretlendi Excel'de.
--
-- NOT: bazi USDA kayitlarinda (ozellikle SADEYAĞ/ghee gibi eski SR
-- Legacy kayitlari) Biotin hic olcumlenmemis -- TürKomp'ta da yoktu,
-- bu yuzden VİTAMİN B7 pek cok malzeme icin (111'in sadece 3'unde
-- USDA'da bile var) HALA BOS kalacak -- bu, kaynaklarin kendi
-- sistemik eksikligi, tek tek malzeme sorunu degil.

update malzemeler set vitamin_b5_mg = 0.772, bakir_mg = 0.507, manganez_mg = 0.019 where isletme_id is null and ad = 'BILDIRCIN ETİ';

update malzemeler set vitamin_b5_mg = 1.07, bakir_mg = 0.108, manganez_mg = 0.029 where isletme_id is null and ad = 'DANA BUT';

update malzemeler set vitamin_b5_mg = 1.26, bakir_mg = 0.12, manganez_mg = 0.028 where isletme_id is null and ad = 'DANA KOL';

update malzemeler set vitamin_b5_mg = 1.36, bakir_mg = 0.11, manganez_mg = 0.027 where isletme_id is null and ad = 'DANA KONTRFİLE';

update malzemeler set vitamin_b5_mg = 0.629, bakir_mg = 0.082, manganez_mg = 0.013 where isletme_id is null and ad = 'DANA PİRZOLA';

update malzemeler set bakir_mg = 0.05515, manganez_mg = 0.002875 where isletme_id is null and ad = 'SIĞIR BUT';

update malzemeler set bakir_mg = 0.05405, manganez_mg = 0.0 where isletme_id is null and ad = 'SIĞIR KOL';

update malzemeler set bakir_mg = 0.07023, manganez_mg = 0.001563 where isletme_id is null and ad = 'SIĞIR KONTRFİLE';

update malzemeler set bakir_mg = 0.04304, manganez_mg = 0.001563 where isletme_id is null and ad = 'SIĞIR PİRZOLA';

update malzemeler set bakir_mg = 0.062, manganez_mg = 0.013 where isletme_id is null and ad = 'PİLİÇ BUT';

update malzemeler set bakir_mg = 0.003638, manganez_mg = 0.0 where isletme_id is null and ad = 'PİLİÇ GÖĞÜS (DERİSİZ)';

update malzemeler set bakir_mg = 0.01053, manganez_mg = 0.003188 where isletme_id is null and ad = 'PİLİÇ KANAT';

update malzemeler set vitamin_b5_mg = 1.3, bakir_mg = 0.083, manganez_mg = 0.006 where isletme_id is null and ad = 'HİNDİ ETİ (BUT, DERİSİZ)';

update malzemeler set vitamin_b5_mg = 0.775, bakir_mg = 0.07, manganez_mg = 0.011 where isletme_id is null and ad = 'HİNDİ ETİ (GÖĞÜS FİLETO, DERİSİZ)';

update malzemeler set vitamin_b5_mg = 1.973, bakir_mg = 0.306, manganez_mg = 0.024 where isletme_id is null and ad = 'KAZ ETİ (BUT, DERİSİZ, TUZ İLAVELİ)';

update malzemeler set vitamin_b5_mg = 1.973, bakir_mg = 0.306, manganez_mg = 0.024 where isletme_id is null and ad = 'KAZ ETİ (GÖĞÜS, DERİSİZ, TUZ İLAVELİ)';

update malzemeler set bakir_mg = 0.256, manganez_mg = 0.038 where isletme_id is null and ad = 'KEÇİ ETİ (BEL)';

update malzemeler set bakir_mg = 0.256, manganez_mg = 0.038 where isletme_id is null and ad = 'KEÇİ ETİ (BUT)';

update malzemeler set bakir_mg = 0.256, manganez_mg = 0.038 where isletme_id is null and ad = 'KEÇİ ETİ (KOL)';

update malzemeler set bakir_mg = 0.256, manganez_mg = 0.038 where isletme_id is null and ad = 'KEÇİ ETİ (SIRT)';

update malzemeler set vitamin_b5_mg = 0.897, bakir_mg = 0.062, manganez_mg = 0.033 where isletme_id is null and ad = 'KOYUN ETİ (BEL)';

update malzemeler set vitamin_b5_mg = 0.897, bakir_mg = 0.062, manganez_mg = 0.033 where isletme_id is null and ad = 'KOYUN ETİ (BUT)';

update malzemeler set vitamin_b5_mg = 0.897, bakir_mg = 0.062, manganez_mg = 0.033 where isletme_id is null and ad = 'KOYUN ETİ (KOL)';

update malzemeler set vitamin_b5_mg = 0.897, bakir_mg = 0.062, manganez_mg = 0.033 where isletme_id is null and ad = 'KOYUN ETİ (SIRT)';

update malzemeler set vitamin_b5_mg = 0.65, bakir_mg = 0.101, manganez_mg = 0.019 where isletme_id is null and ad = 'KUZU ETİ (BEL)';

update malzemeler set vitamin_b5_mg = 0.65, bakir_mg = 0.101, manganez_mg = 0.019 where isletme_id is null and ad = 'KUZU ETİ (BUT)';

update malzemeler set vitamin_b5_mg = 0.65, bakir_mg = 0.101, manganez_mg = 0.019 where isletme_id is null and ad = 'KUZU ETİ (KOL)';

update malzemeler set vitamin_b5_mg = 0.65, bakir_mg = 0.101, manganez_mg = 0.019 where isletme_id is null and ad = 'KUZU ETİ (SIRT)';

update malzemeler set vitamin_b5_mg = 7.173, bakir_mg = 9.755, manganez_mg = 0.31 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA KARACİĞER)';

update malzemeler set vitamin_b5_mg = 1.0, bakir_mg = 0.26, manganez_mg = 0.019 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA AKCİĞER)';

update malzemeler set vitamin_b5_mg = 2.01, bakir_mg = 0.287, manganez_mg = 0.026 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA BEYİN)';

update malzemeler set vitamin_b5_mg = 3.97, bakir_mg = 0.426, manganez_mg = 0.142 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA BÖBREK)';

update malzemeler set vitamin_b5_mg = 1.081, bakir_mg = 0.168, manganez_mg = 0.073 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA DALAK)';

update malzemeler set vitamin_b5_mg = 0.653, bakir_mg = 0.17, manganez_mg = 0.026 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA DİL)';

update malzemeler set vitamin_b5_mg = 0.227, bakir_mg = 0.07, manganez_mg = 0.085 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA İŞKEMBE)';

update malzemeler set vitamin_b5_mg = 1.79, bakir_mg = 0.396, manganez_mg = 0.035 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (DANA KALP)';

update malzemeler set vitamin_b5_mg = 0.92, bakir_mg = 0.24, manganez_mg = 0.044 where isletme_id is null and ad = 'YENİLEBİLİR SAKATAT (KOYUN BAĞIRSAK)';

update malzemeler set vitamin_b5_mg = 0.828, bakir_mg = 0.053, manganez_mg = 0.021 where isletme_id is null and ad = 'BERLAM';

update malzemeler set vitamin_b5_mg = 0.57, bakir_mg = 0.037, manganez_mg = 0.017 where isletme_id is null and ad = 'KALKAN';

update malzemeler set vitamin_b5_mg = 0.76, bakir_mg = 0.051, manganez_mg = 0.016 where isletme_id is null and ad = 'KEFAL (PASİFİK, RUS KEFALİ)';

update malzemeler set vitamin_b5_mg = 0.76, bakir_mg = 0.051, manganez_mg = 0.016 where isletme_id is null and ad = 'KEFAL (SARI KULAK)';

update malzemeler set vitamin_b5_mg = 0.75, bakir_mg = 0.064, manganez_mg = 0.042 where isletme_id is null and ad = 'TİRSİ';

update malzemeler set vitamin_b5_mg = 0.24, bakir_mg = 0.023, manganez_mg = 0.035 where isletme_id is null and ad = 'ZARGANA';

update malzemeler set vitamin_b5_mg = 0.24, bakir_mg = 0.071, manganez_mg = 0.073 where isletme_id is null and ad = 'ACUR';

update malzemeler set vitamin_b5_mg = 1.159, bakir_mg = 0.295, manganez_mg = 0.429 where isletme_id is null and ad = 'HİNDİBA';

update malzemeler set bakir_mg = 0.076, manganez_mg = 0.779 where isletme_id is null and ad = 'ISIRGAN';

update malzemeler set vitamin_b5_mg = 0.041, bakir_mg = 0.131, manganez_mg = 0.349 where isletme_id is null and ad = 'LABADA';

update malzemeler set vitamin_b7_mcg = 1.938, bakir_mg = 0.07339, manganez_mg = 0.1241 where isletme_id is null and ad = 'REZENE';

update malzemeler set vitamin_b5_mg = 0.049, bakir_mg = 0.082, manganez_mg = 0.048 where isletme_id is null and ad = 'ARMUT (KIŞLIK, DEVECİ ÇEŞİDİ)';

update malzemeler set vitamin_b5_mg = 0.049, bakir_mg = 0.082, manganez_mg = 0.048 where isletme_id is null and ad = 'ARMUT (YAZLIK, SANTA MARİA ÇEŞİDİ)';

update malzemeler set vitamin_b5_mg = 0.081, bakir_mg = 0.13 where isletme_id is null and ad = 'AYVA';

update malzemeler set vitamin_b5_mg = 0.185, bakir_mg = 0.086, manganez_mg = 0.054 where isletme_id is null and ad = 'NEKTARİN';

update malzemeler set vitamin_b5_mg = 0.295, bakir_mg = 0.056, manganez_mg = 0.267 where isletme_id is null and ad = 'KIZILCIK';

update malzemeler set vitamin_b5_mg = 0.113, bakir_mg = 0.454, manganez_mg = 0.856 where isletme_id is null and ad = 'ZEYTİN EZMESİ';

update malzemeler set vitamin_b5_mg = 0.125, bakir_mg = 0.025, manganez_mg = 0.037 where isletme_id is null and ad = 'MANDARİN (KLEMANTİN)';

update malzemeler set vitamin_b5_mg = 0.125, bakir_mg = 0.025, manganez_mg = 0.037 where isletme_id is null and ad = 'MANDARİN (NOVA)';

update malzemeler set vitamin_b5_mg = 0.125, bakir_mg = 0.025, manganez_mg = 0.037 where isletme_id is null and ad = 'MANDARİN (OKİTSU WASE)';

update malzemeler set vitamin_b5_mg = 0.125, bakir_mg = 0.025, manganez_mg = 0.037 where isletme_id is null and ad = 'MANDARİN (OVARİ SATSUMA)';

update malzemeler set vitamin_b5_mg = 0.015, bakir_mg = 0.09, manganez_mg = 0.02 where isletme_id is null and ad = 'MARMELAT (KIZILCIK)';

update malzemeler set vitamin_b5_mg = 0.015, bakir_mg = 0.09, manganez_mg = 0.02 where isletme_id is null and ad = 'MARMELAT (KUŞBURNU)';

update malzemeler set vitamin_b5_mg = 0.282, bakir_mg = 0.42, manganez_mg = 1.322 where isletme_id is null and ad = 'ARPA (ALTI SIRALI)';

update malzemeler set vitamin_b5_mg = 0.282, bakir_mg = 0.42, manganez_mg = 1.322 where isletme_id is null and ad = 'ARPA (İKİ SIRALI)';

update malzemeler set vitamin_b7_mcg = 8.614, bakir_mg = 0.3936, manganez_mg = 1.181 where isletme_id is null and ad = 'ARPA UNU';

update malzemeler set vitamin_b5_mg = 2.181, bakir_mg = 0.998, manganez_mg = 11.5 where isletme_id is null and ad = 'BUĞDAY KEPEĞİ';

update malzemeler set vitamin_b5_mg = 2.257, bakir_mg = 0.796, manganez_mg = 13.301 where isletme_id is null and ad = 'BUĞDAY RUŞEYMİ';

update malzemeler set vitamin_b5_mg = 0.848, bakir_mg = 0.75, manganez_mg = 1.632 where isletme_id is null and ad = 'KOCA DARI';

update malzemeler set vitamin_b5_mg = 1.323, bakir_mg = 0.457, manganez_mg = 3.21 where isletme_id is null and ad = 'TRİTİKALE';

update malzemeler set vitamin_b5_mg = 0.522, bakir_mg = 0.318, manganez_mg = 1.781 where isletme_id is null and ad = 'KRAKER';

update malzemeler set vitamin_b5_mg = 0.645, bakir_mg = 0.091, manganez_mg = 0.364 where isletme_id is null and ad = 'LAVAŞ';

update malzemeler set vitamin_b5_mg = 0.19, bakir_mg = 0.101, manganez_mg = 0.333 where isletme_id is null and ad = 'CİPS (MISIR)';

update malzemeler set vitamin_b5_mg = 0.595, bakir_mg = 0.136, manganez_mg = 0.26 where isletme_id is null and ad = 'CİPS (PATATES)';

update malzemeler set vitamin_b5_mg = 1.13, bakir_mg = 1.8, manganez_mg = 1.95 where isletme_id is null and ad = 'AYÇİÇEĞİ TOHUMU';

update malzemeler set vitamin_b7_mcg = 33.8, bakir_mg = 1.344, manganez_mg = 2.405 where isletme_id is null and ad = 'KETEN TOHUMU';

update malzemeler set vitamin_b5_mg = 0.084 where isletme_id is null and ad = 'MARGARİN';

update malzemeler set vitamin_b5_mg = 0.0, bakir_mg = 0.0 where isletme_id is null and ad = 'DONYAĞI';

update malzemeler set vitamin_b5_mg = 0.014, bakir_mg = 0.118, manganez_mg = 0.011 where isletme_id is null and ad = 'JÖLE';

update malzemeler set vitamin_b5_mg = 0.06, bakir_mg = 1.599, manganez_mg = 1.493 where isletme_id is null and ad = 'SOYA KIYMA';

update malzemeler set vitamin_b5_mg = 0.0, bakir_mg = 0.013, manganez_mg = 0.036 where isletme_id is null and ad = 'AROMALI İÇECEK (GAZLI, PORTAKAL AROMALI)';

update malzemeler set vitamin_b5_mg = 0.0, bakir_mg = 0.015, manganez_mg = 0.013 where isletme_id is null and ad = 'AROMALI İÇECEK (GAZLI, SADE)';

update malzemeler set vitamin_b5_mg = 0.0, bakir_mg = 0.006, manganez_mg = 0.001 where isletme_id is null and ad = 'DOĞAL ZENGİN MİNERALLİ GAZLI İÇECEK';

update malzemeler set vitamin_b5_mg = 0.0, bakir_mg = 0.006, manganez_mg = 0.001 where isletme_id is null and ad = 'TONİK';

update malzemeler set vitamin_b5_mg = 0.316, bakir_mg = 0.2 where isletme_id is null and ad = 'TOZ MEŞRUBAT';

update malzemeler set bakir_mg = 0.0 where isletme_id is null and ad = 'KAHVE KREMASI';

update malzemeler set vitamin_b5_mg = 0.244, bakir_mg = 0.092, manganez_mg = 0.118 where isletme_id is null and ad = 'PUDİNG';

update malzemeler set vitamin_b5_mg = 0.381, bakir_mg = 0.463, manganez_mg = 0.696 where isletme_id is null and ad = 'GOFRET (KAKAO KREMALI, SÜTLÜ ÇİKOLATA KAPLAMALI)';

update malzemeler set vitamin_b5_mg = 0.351, bakir_mg = 0.07, manganez_mg = 0.29 where isletme_id is null and ad = 'GOFRET (KREMALI, VANİLYA AROMALI)';

update malzemeler set bakir_mg = 0.3 where isletme_id is null and ad = 'MÜSLİ';

update malzemeler set bakir_mg = 0.622 where isletme_id is null and ad = 'TAM TAHILLI GEVREK';

update malzemeler set vitamin_b5_mg = 0.961, bakir_mg = 0.192, manganez_mg = 0.269 where isletme_id is null and ad = 'İZOTONİK SPORCU İÇECEĞİ';

update malzemeler set bakir_mg = 0.8376, manganez_mg = 1.569 where isletme_id is null and ad = 'KURU ÇORBA KARIŞIMI (EZOGELİN)';

update malzemeler set bakir_mg = 0.8376, manganez_mg = 1.569 where isletme_id is null and ad = 'KURU ÇORBA KARIŞIMI (MERCİMEK)';

update malzemeler set vitamin_b5_mg = 0.525, bakir_mg = 0.077, manganez_mg = 0.048 where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, DANA)';

update malzemeler set vitamin_b5_mg = 0.797, bakir_mg = 0.111, manganez_mg = 0.066 where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, HİNDİ)';

update malzemeler set vitamin_b5_mg = 0.45, bakir_mg = 0.09, manganez_mg = 0.049 where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, PİLİÇ)';

update malzemeler set vitamin_b5_mg = 0.385, bakir_mg = 0.053, manganez_mg = 0.04 where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, DANA)';

update malzemeler set vitamin_b5_mg = 0.466, bakir_mg = 0.072, manganez_mg = 0.051 where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, HİNDİ)';

update malzemeler set vitamin_b5_mg = 0.776, bakir_mg = 0.039, manganez_mg = 0.042 where isletme_id is null and ad = 'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, PİLİÇ)';

update malzemeler set vitamin_b5_mg = 0.576, bakir_mg = 0.063, manganez_mg = 0.01 where isletme_id is null and ad = 'KASAP KÖFTE';

update malzemeler set vitamin_b5_mg = 0.576, bakir_mg = 0.063, manganez_mg = 0.01 where isletme_id is null and ad = 'DÖNER (KIYMA, ÇİĞ)';

update malzemeler set vitamin_b5_mg = 1.092, bakir_mg = 0.065, manganez_mg = 0.016 where isletme_id is null and ad = 'DÖNER (PİLİÇ ETİ, ÇİĞ)';

update malzemeler set bakir_mg = 0.101 where isletme_id is null and ad = 'DÖNER (ET, KASTAMONU, PİŞMİŞ)';

update malzemeler set bakir_mg = 0.101 where isletme_id is null and ad = 'DÖNER (ET, PİŞMİŞ, BURSA)';

update malzemeler set vitamin_b5_mg = 0.156, bakir_mg = 0.09, manganez_mg = 0.007 where isletme_id is null and ad = 'OLTU CAĞ KEBABI';

update malzemeler set vitamin_b5_mg = 0.446, bakir_mg = 0.03, manganez_mg = 0.022 where isletme_id is null and ad = 'ÇÖKELEK (ÇORUM)';

update malzemeler set vitamin_b5_mg = 0.446, bakir_mg = 0.03, manganez_mg = 0.022 where isletme_id is null and ad = 'ÇÖKELEK (MERSİN)';

update malzemeler set vitamin_b5_mg = 0.967, bakir_mg = 0.032, manganez_mg = 0.028 where isletme_id is null and ad = 'EDİRNE BEYAZ PEYNİRİ';

update malzemeler set vitamin_b5_mg = 0.476, bakir_mg = 0.026, manganez_mg = 0.01 where isletme_id is null and ad = 'ESKİ KAŞAR';

update malzemeler set vitamin_b5_mg = 0.485, bakir_mg = 0.033, manganez_mg = 0.016 where isletme_id is null and ad = 'ERİTME PEYNİRİ';

update malzemeler set kalori = 902.0, protein = 0.0, yag = 100.0, karbonhidrat = 0.0, sodyum_mg = 0.0, lif_g = 0.0, seker_g = 0.0, doymus_yag_g = 49.8, vitamin_a_mcg = 0.0, vitamin_b1_mg = 0.0, vitamin_b2_mg = 0.0, vitamin_b3_mg = 0.0, vitamin_b5_mg = 0.0, vitamin_b6_mg = 0.0, vitamin_b9_mcg = 0.0, vitamin_b12_mcg = 0.0, vitamin_c_mg = 0.0, vitamin_d_mcg = 0.7, vitamin_e_mg = 2.7, vitamin_k_mcg = 0.0, kalsiyum_mg = 0.0, demir_mg = 0.0, magnezyum_mg = 0.0, potasyum_mg = 0.0, cinko_mg = 0.0, fosfor_mg = 0.0, bakir_mg = 0.0, selenyum_mcg = 0.2, not_aciklama = '13 Ağustos 2026: TürKomp''ta bulunamadı, en yakın eşdeğeri USDA''dan (Fat, beef tallow) alındı.' where isletme_id is null and ad = 'DONYAĞI';

update malzemeler set kalori = 900.0, protein = 0.0, yag = 100.0, karbonhidrat = 0.0, sodyum_mg = 0.0, lif_g = 0.0, seker_g = 0.0, doymus_yag_g = 60.0, vitamin_a_mcg = 1200.0, vitamin_c_mg = 0.0, kalsiyum_mg = 0.0, demir_mg = 0.0, not_aciklama = '13 Ağustos 2026: TürKomp''ta bulunamadı, en yakın eşdeğeri USDA''dan (Clarified butter (ghee)) alındı.' where isletme_id is null and ad = 'SADEYAĞ';

-- DOGRULAMA
select count(*) as b5_dolu from malzemeler where isletme_id is null and vitamin_b5_mg is not null;
