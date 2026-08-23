-- 72_isot_pul_biber_esdegeri.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): kullanicinin acik onayiyla --
-- "ikisi de ayni, ikisi de kurutulmus pul olarak kullaniliyor, isot
-- daha aci olani" -- İSOT icin, daha once TürKomp'tan (biber-kirmizi-
-- acili-pul-184) gercek veriyle doldurulan PUL BİBER'in degerleri
-- uygulaniyor. Bu, benim kendi inisiyatifimle veri uydurmam DEGIL --
-- kullanicinin kendi urun bilgisine dayanarak yaptigi, gercek bir
-- kaynaktan (TürKomp) turetilen bilincli bir esdeğerlik karari.
--
-- TürKomp'un PUL BİBER kaydinda sadece 4 alan olculmus (kalori,
-- protein, karbonhidrat, lif) -- digerleri (vitamin/mineral) o kayitta
-- da yoktu, bu yuzden İSOT icin de sadece bu 4 alan doldurulabiliyor.

update malzemeler set
  kalori = coalesce(kalori, 286.0),
  protein = coalesce(protein, 11.69),
  karbonhidrat = coalesce(karbonhidrat, 43.67),
  lif_g = coalesce(lif_g, 32.25)
where isletme_id is null and ad = 'İSOT';

-- DOGRULAMA
select ad, kalori, protein, karbonhidrat, lif_g from malzemeler where isletme_id is null and ad = 'İSOT';
