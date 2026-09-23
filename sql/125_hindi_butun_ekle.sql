-- HINDI BUTUN (derili, karkas ortalamasi) ekleme
-- Beslenme kaynagi: IKI kaynagin ORTALAMASI (recipal.com "all classes,
-- meat and skin, raw" = 160 kcal/8.02g yag/20.42g protein VE
-- eatthismuch.com "meat and skin,522" 28g'den olceklenen = 146.4 kcal/
-- 7.14g yag/21.4g protein) -- kalori/protein/yag bu IKISININ ortalamasi,
-- geri kalan detay alanlar SADECE eatthismuch kaynagindan (tek kaynak,
-- dusuk hassasiyet -- orijinal veri 1 basamakli yuvarlanmisti).
-- DIKKAT: bu satir digger 2 hindi kesiminden (Göğüs/Kanat) DAHA DUSUK
-- KESINLIKTE -- Bahri'ye acikca belirtildi, "ortalama olarak devam et"
-- onayi alindi.
-- Operasyonel alanlar TAVUK BÜTÜN'den referans alindi -- ONEMLI FARK:
-- fire_orani burada 0.30 (digger kesimlerin 0.05'i degil) çünkü TAVUK
-- BÜTÜN kaydinda da "Kemik/sakatat fire ~30%" notuyla ayni sekilde
-- yuksek -- butun govde icin kemik/sakatat kaybi mantikli.
-- BILEREK BOS BIRAKILAN (TAHMIN EDILMEYEN) ALANLAR:
--   isi_iletkenlik: TAVUK BÜTÜN'de de BOS (referans alinan kayitta yok).
--   yuzey_alani: hindi tavuktan cok daha buyuk, TAVUK'un degeri (500)
--     KOPYALANMADI -- gercek deger bilinmiyor.
--   bakir_mg, manganez_mg: kaynakta veri YOK.
--   varsayilan_fiyat_eur: piyasa verisi, tahmin edilmedi.
insert into malzemeler (
  id, isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, mevsim,
  kalori, protein, yag, karbonhidrat, glisemik_indeks,
  sodyum_mg, lif_g, seker_g, doymus_yag_g,
  vitamin_a_mcg, vitamin_b2_mg, vitamin_b3_mg,
  vitamin_b5_mg, vitamin_b6_mg, vitamin_b9_mcg, vitamin_b12_mcg,
  vitamin_c_mg, vitamin_d_mcg, vitamin_k_mcg,
  kalsiyum_mg, demir_mg, magnezyum_mg, potasyum_mg,
  cinko_mg, fosfor_mg, selenyum_mcg
) values (
  gen_random_uuid(), null, 1, 'HİNDİ ETİ (BÜTÜN, DERİLİ)', 1, 3.18, 2,
  0.30, 0, 'Yıl boyunca',
  153.2, 20.91, 7.58, 0, 0,
  114.3, 0, 0, 1.43,
  17.9, 0.36, 7.14,
  0.71, 0.71, 7.14, 1.07,
  0, 0.36, 0,
  10.7, 0.71, 25, 228.6,
  3.57, 185.7, 21.4
);
-- vitamin_b1_mg ve vitamin_e_mg: kaynakta "0" gibi gorunuyordu ama
-- degerin gercekten sifir mi yoksa yuvarlanmis cok kucuk bir sayi mi
-- oldugu BELIRSIZDI -- YANLIS BIR SIFIR yazmamak icin sutun listesine
-- HIC DAHIL EDILMEDI (NULL kalacak). bakir_mg, manganez_mg: kaynakta
-- veri yoktu, ayni sekilde disarida birakildi.
