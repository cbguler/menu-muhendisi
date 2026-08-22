-- 61_sevketi_bostan_kok_unu_ve_kenger.sql
--
-- 13 Agustos 2026 (Oturum 11, devam): "hicbir veriyi uydurma" kurali
-- netlestirildikten sonra iki malzeme GERCEK akademik kaynaklardan
-- islendi.
--
-- SEVKETI BOSTAN KOK UNU (YENI malzeme): kurutulmus kok unu icin
-- gercek olculmus veri (Dulger Altiner & Sahan, 2021) -- orijinal
-- "SEVKETI BOSTAN" (taze sebze) icin KULLANILMADI, form uyumsuzlugu
-- nedeniyle donusturme yapilmadi, ayri malzeme olarak eklendi.
--
-- KENGER: Karaaslan/Coteli/Karatas (2014, Firat Univ.) -- TAZE bitki
-- orneginden HPLC olcumu. Vitamin A ve C yazildi. Vitamin E
-- YAZILMADI -- iki gercek akademik kaynak arasinda ~1400 kat fark
-- var (farkli bitki kismi olcumu), kullaniciya soruldu.

insert into malzemeler (isletme_id, kategori_id, ad, kalori, protein, yag, karbonhidrat, not_aciklama)
select null, 3, 'ŞEVKETİ BOSTAN KÖK UNU', 350.6, 10.126, 0.421, 76.587,
  '13 Agustos 2026: Dulger Altiner D, Sahan Y (2021), Igdir Univ. Fen Bil. Derg. 11(4):2823-2835 (Cizelge 1) -- gercek olculmus (nem %8.53, kul/protein/yag kuru madde uzerinden). Kalori Atwater faktorleriyle hesaplandi.'
where not exists (select 1 from malzemeler m where m.ad='ŞEVKETİ BOSTAN KÖK UNU' and m.isletme_id is null);

update malzemeler set
  vitamin_a_mcg = coalesce(vitamin_a_mcg, 98.0),
  vitamin_c_mg = coalesce(vitamin_c_mg, 1.972)
where isletme_id is null and ad = 'KENGER';

-- DOGRULAMA
select count(*) as toplam from malzemeler where isletme_id is null;
