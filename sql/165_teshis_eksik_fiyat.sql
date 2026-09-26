-- 165_teshis_eksik_fiyat.sql
-- AMAC: Kullanicinin bildirdigi "malzeme fiyati eksik" sorununu
-- teshis etmek. Sutun adlarini TAHMIN ETMIYORUM (gecmis derse gore) --
-- once gercek semayi goruyoruz, sonra asil teshisi yapiyoruz.
-- Bu dosya SADECE OKUMA yapar, hicbir veri degistirmez.

-- ADIM 1: malzeme_fiyat_gecmisi tablosunun TAM sutun listesi
-- (bu tabloyu daha once hic dogrudan sorgulamadim, sutun adlarini
-- varsaymak yerine burada goruyoruz)
select column_name, data_type, is_nullable
from information_schema.columns
where table_name = 'malzeme_fiyat_gecmisi'
order by ordinal_position;

-- ADIM 2: isletmeler tablosunun TAM sutun listesi (hangi isletmeyi
-- test ettigimizi/kac isletme oldugunu anlamak icin)
select column_name, data_type, is_nullable
from information_schema.columns
where table_name = 'isletmeler'
order by ordinal_position;

-- ADIM 3: Ekran goruntusundeki 5 malzemenin KATALOG seviyesinde
-- (malzemeler.varsayilan_fiyat_eur) fiyati var mi? Bu, sadece
-- onceden dogrulanmis sutun adlarini (ad, varsayilan_fiyat_eur)
-- kullaniyor.
select ad, varsayilan_fiyat_eur
from malzemeler
where ad in ('KUZU ETİ (KOL)', 'MAYDANOZ', 'ZEYTİN EZMESİ', 'KUZU KIYMA', 'EDİRNE BEYAZ PEYNİRİ')
order by ad;

-- ADIM 4: Katalogda KAC malzemenin varsayilan_fiyat_eur'u NULL
-- (hic fiyatlanmamis) -- bu, 22-23 Eylul'deki et kesimleri
-- arastirmasinda bilerek bos birakilanlari da kapsar.
select count(*) as fiyati_null_olan_malzeme_sayisi
from malzemeler
where varsayilan_fiyat_eur is null;

-- ADIM 5: Fiyati NULL olan malzemelerin TAM listesi (hangileri
-- oldugunu gormek icin -- muhtemelen KUZU KIYMA, KOYUN KIYMA,
-- KEÇİ KIYMA, HİNDİ/KAZ/TAVUK yeni kesimleri burada cikacak)
select ad, kategori_id
from malzemeler
where varsayilan_fiyat_eur is null
order by ad;

-- ADIM 6: Toplam isletme sayisi (referans icin)
select count(*) as toplam_isletme_sayisi from isletmeler;
