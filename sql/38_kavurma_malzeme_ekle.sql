-- 38_kavurma_malzeme_ekle.sql
--
-- Yeni malzeme: KAVURMA (dana/kuzu etinin kendi yaginda agir atesde
-- pisirilip saklanmasiyla yapilan, Turk mutfaginin geleneksel korunmus
-- et urunu -- PASTIRMA'dan (kurutulmus, cemenli) FARKLI bir urun).
--
-- ASAGIDAKI DEGERLERIN KAYNAK DURUMU (5 Agustos 2026 talimati geregi
-- acikca ayristirildi):
--
-- KAYNAKLANDI (web arastirmasi, birden fazla bagimsiz kaynak):
--   - kalori: 345 kcal/100g, protein: 20.62g/100g, yag: 28.53g/100g,
--     karbonhidrat: ~0g/100g -- diyetkolik.com, haberturk.com,
--     dytseydaertas.com, kaloriler.gen.tr kaynaklarinda tutarli.
--   - bozulma_suresi: buzdolabinda saklandiginda 4-7 gun taze kaliyor
--     (lezzet.com.tr) -- 6 gun olarak orta deger alindi. NOT: dondurucuda
--     3-4 ay saklanabiliyor ama bu katalogdaki "aktif kullanim/buzdolabi"
--     varsayimina uymuyor, o yuzden kullanilmadi.
--
-- TAHMIN EDILDI (dogrulanmadi -- kaynak bulunamadi, benzer urunlerden
-- yola cikilarak tahmin edildi, DOGRULANMASI ONERILIR):
--   - yogunluk (0.95 g/cm3), ozgul_isi (2.2 J/g°C), fire_orani (0.02),
--     isi_iletkenlik (0.4 W/m.K), yuzey_alani (120 cm2): hicbiri icin
--     spesifik kaynak bulunamadi, yagli et urunleri icin tipik araliklardan
--     tahmin edildi.
--   - varsayilan_fiyat_eur: TEK bir perakende kaynaktan (DANET markasi,
--     100g icin 278 TL = kg basina ~2780 TL, 5 Agustos 2026 EUR/TRY kuru
--     ~55 ile ~50.5 EUR/kg) -- bu GURME/PERAKENDE fiyati, toptan/esnaf
--     fiyatindan yuksek olabilir. KESINLIKLE kendi tedarikcinden dogrulayip
--     Malzeme Yonetimi sayfasindan guncellemen onerilir.
--
-- kategori_id: PASTIRMA ile ayni kategoriden alindi (tahmin degil,
-- veritabanindan okunuyor).

insert into malzemeler (
  isletme_id, kategori_id, ad, yogunluk, ozgul_isi, bozulma_suresi,
  fire_orani, saklama_isisi, kalori, protein, yag, karbonhidrat,
  glisemik_indeks, mevsim, isi_iletkenlik, yuzey_alani, not_aciklama,
  varsayilan_fiyat_eur
)
select
  null,
  (select kategori_id from malzemeler where ad = 'PASTIRMA' and isletme_id is null limit 1),
  'KAVURMA',
  0.95,   -- TAHMIN
  2.2,    -- TAHMIN
  6,      -- KAYNAKLI (buzdolabinda 4-7 gun, orta deger)
  0.02,   -- TAHMIN
  4,      -- KAYNAKLI (buzdolabi saklama sicakligi)
  345,    -- KAYNAKLI
  20.62,  -- KAYNAKLI
  28.53,  -- KAYNAKLI
  1,      -- KAYNAKLI (kaynaklarda ~0, guvenli yuvarlama)
  0,      -- KAYNAKLI (et urunu, karbonhidrati yok denecek kadar az)
  'Yıl boyunca',
  0.4,    -- TAHMIN
  120,    -- TAHMIN
  '5 Ağustos 2026 eklendi -- kavurmalı nohut vb. tariflerde kullanılan '
  'geleneksel korunmuş et ürünü. Fiyat TEK perakende kaynağa dayanıyor, '
  'doğrulanması önerilir (bkz. dosya başındaki not).',
  50.50   -- TAHMIN/DOGRULANMAMIS (tek perakende kaynagi)
where not exists (
  select 1 from malzemeler where ad = 'KAVURMA' and isletme_id is null
);

-- Dogrulama: yeni eklenen malzemeyi goster
select id, ad, kategori_id, kalori, protein, yag, varsayilan_fiyat_eur
from malzemeler where ad = 'KAVURMA' and isletme_id is null;
