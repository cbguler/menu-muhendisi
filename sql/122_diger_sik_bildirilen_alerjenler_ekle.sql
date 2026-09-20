-- 122_diger_sik_bildirilen_alerjenler_ekle.sql
--
-- Bahri'nin verdigi Excel tablosundaki (Baklagiller, Diger tahillar,
-- Tohumlar, Meyve ve sebzeler, Et ve hayvansal urunler, Baharatlar)
-- 6 grup + orneklerini isliyor. Bunlar T.C. Tarim ve Orman Bakanligi'nin
-- ZORUNLU 14'luk listesinde DEGIL -- "sik bildirilen ama zorunlu
-- olmayan" ek alerjenler/duyarliliklar. Bu yuzden mevcut "alerjenler"
-- tablosuna YENI bir "kategori" sutunu eklenip bu 23 madde o sutunla
-- (Excel'deki Grup adiyla) etiketlendi -- resmi 14 zorunlu maddeden
-- ayirt edilebilsinler diye (kategori=NULL onlar icin).
--
-- KLINIK NOT (Bahri'nin verdigi bilgi, dogrulama icin FARE ve NHS
-- kaynak gosterdi): Polen alerjisi olanlarda cig elma, seftali, havuc,
-- domates, muz TUKETIMINDEN sonra agiz-bogaz kasintisi gorulebilir
-- ("polen-gida sendromu / oral alerji sendromu") -- pismis hali cogu
-- zaman sorun olusturmaz. Bu, asagida ayni 5 maddenin zaten "Meyve ve
-- sebzeler" grubunda bulunmasinin klinik gerekcesidir -- ayri bir
-- veritabani alani gerektirmiyor, sadece bu notla belgeleniyor.
--
-- 2 madde (Ayçekirdeği, Domuz Eti) icin projede eslesen malzeme
-- BULUNAMADI -- yine de secenek olarak eklendi (ileride ilgili
-- malzeme eklenirse baglanti kurulabilir), ama simdilik hicbir
-- tarifi filtrelemeyecekler.

alter table alerjenler add column if not exists kategori text;

-- DUZELTME v2: alerjenler.id UUID DEGIL, SMALLINT -- ikinci denemede
-- "column id is of type smallint but expression is of type uuid"
-- hatasi verdi. Bu sefer mevcut MAX(id)'den devam eden gercek
-- smallint degerler, CTE + row_number() ile DINAMIK olarak
-- hesaplaniyor -- hangi id'nin bos oldugunu tahmin etmeye gerek yok.
with yeni_alerjenler(ad, kategori) as (
    values
        ('Nohut', 'Baklagiller'),
        ('Mercimek', 'Baklagiller'),
        ('Bezelye', 'Baklagiller'),
        ('Kuru Fasulye', 'Baklagiller'),
        ('Mısır', 'Diğer tahıllar'),
        ('Pirinç', 'Diğer tahıllar'),
        ('Karabuğday', 'Diğer tahıllar'),
        ('Ayçekirdeği', 'Tohumlar'),
        ('Haşhaş', 'Tohumlar'),
        ('Keten Tohumu', 'Tohumlar'),
        ('Kivi', 'Meyve ve sebzeler'),
        ('Elma', 'Meyve ve sebzeler'),
        ('Şeftali', 'Meyve ve sebzeler'),
        ('Muz', 'Meyve ve sebzeler'),
        ('Avokado', 'Meyve ve sebzeler'),
        ('Havuç', 'Meyve ve sebzeler'),
        ('Domates', 'Meyve ve sebzeler'),
        ('Patates', 'Meyve ve sebzeler'),
        ('Sığır Eti', 'Et ve hayvansal ürünler'),
        ('Kuzu Eti', 'Et ve hayvansal ürünler'),
        ('Tavuk', 'Et ve hayvansal ürünler'),
        ('Domuz Eti', 'Et ve hayvansal ürünler'),
        ('Jelatin', 'Et ve hayvansal ürünler'),
        ('Sarımsak', 'Baharatlar'),
        ('Kişniş', 'Baharatlar')
)
insert into alerjenler (id, ad, kategori)
select
    (select coalesce(max(id), 0) from alerjenler) + row_number() over (),
    ad, kategori
from yeni_alerjenler;

-- Malzeme eslestirmeleri (isim uzerinden, mevcut malzemeler tablosuyla)
do $$
declare
    v_alerjen_id smallint;
begin
    select id into v_alerjen_id from alerjenler where ad = 'Nohut';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('NOHUT');

    select id into v_alerjen_id from alerjenler where ad = 'Mercimek';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('KIRMIZI MERCİMEK', 'YEŞİL MERCİMEK', 'KURU ÇORBA KARIŞIMI (MERCİMEK)');

    select id into v_alerjen_id from alerjenler where ad = 'Bezelye';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('BEZELYE', 'KONSERVE BEZELYE');

    select id into v_alerjen_id from alerjenler where ad = 'Kuru Fasulye';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('KURU FASULYE');

    select id into v_alerjen_id from alerjenler where ad = 'Mısır';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('MISIR', 'KONSERVE MISIR', 'MISIR UNU', 'MISIR NİŞASTASI', 'MISIR ŞURUBU', 'MISIR YAĞI', 'CİPS (MISIR)');

    select id into v_alerjen_id from alerjenler where ad = 'Pirinç';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('PİRİNÇ (HAM)', 'PİRİNÇ (PİŞMİŞ)', 'BASMATİ PİRİNÇ (HAM)', 'SİYAH PİRİNÇ (HAM)', 'PİRİNÇ UNU');

    select id into v_alerjen_id from alerjenler where ad = 'Karabuğday';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('KARABUĞDAY');

    select id into v_alerjen_id from alerjenler where ad = 'Haşhaş';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('HAŞHAŞ');

    select id into v_alerjen_id from alerjenler where ad = 'Keten Tohumu';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('KETEN TOHUMU');

    select id into v_alerjen_id from alerjenler where ad = 'Kivi';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('KİVİ');

    select id into v_alerjen_id from alerjenler where ad = 'Elma';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('ELMA');

    select id into v_alerjen_id from alerjenler where ad = 'Şeftali';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('ŞEFTALİ');

    select id into v_alerjen_id from alerjenler where ad = 'Muz';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('MUZ');

    select id into v_alerjen_id from alerjenler where ad = 'Avokado';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('AVOKADO');

    select id into v_alerjen_id from alerjenler where ad = 'Havuç';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('HAVUÇ');

    select id into v_alerjen_id from alerjenler where ad = 'Domates';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('DOMATES', 'KONSERVE DOMATES', 'KONSERVE DOMATES SALÇASI');

    select id into v_alerjen_id from alerjenler where ad = 'Patates';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('PATATES', 'CİPS (PATATES)');

    select id into v_alerjen_id from alerjenler where ad = 'Sığır Eti';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in (
        'SIĞIR BİFTEK', 'SIĞIR BONFİLE', 'SIĞIR BUT', 'SIĞIR KABURGA', 'SIĞIR KIYMA', 'SIĞIR KOL', 'SIĞIR KONTRFİLE', 'SIĞIR PİRZOLA',
        'DANA BİFTEK', 'DANA BONFİLE', 'DANA BUT', 'DANA KIYMA', 'DANA KOL', 'DANA KONTRFİLE', 'DANA PİRZOLA', 'DANA ROSTO',
        'EMÜLSİFİYE ET ÜRÜNÜ (SALAM, DANA)', 'EMÜLSİFİYE ET ÜRÜNÜ (SOSİS, DANA)',
        'YENİLEBİLİR SAKATAT (DANA AKCİĞER)', 'YENİLEBİLİR SAKATAT (DANA BEYİN)', 'YENİLEBİLİR SAKATAT (DANA BÖBREK)',
        'YENİLEBİLİR SAKATAT (DANA DALAK)', 'YENİLEBİLİR SAKATAT (DANA DİL)', 'YENİLEBİLİR SAKATAT (DANA İŞKEMBE)',
        'YENİLEBİLİR SAKATAT (DANA KALP)', 'YENİLEBİLİR SAKATAT (DANA KARACİĞER)'
    );

    -- KUZU KULAĞI (kuzukulagi/sorrel bitkisi) ve KUZUKEMİRDİ BILEREK
    -- DISLANDI -- bunlar kuzu ETI degil, isminde "kuzu" gecen ayri
    -- bitki/ot turleri.
    select id into v_alerjen_id from alerjenler where ad = 'Kuzu Eti';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in (
        'KUZU ETİ (BEL)', 'KUZU ETİ (BUT)', 'KUZU ETİ (KOL)', 'KUZU ETİ (SIRT)', 'KUZU PİRZOLA', 'KUZU ŞİŞ', 'KUZU TANDIR'
    );

    -- TAVUK YUMURTASI BILEREK DISLANDI -- yumurta zaten ayri (resmi/
    -- zorunlu) "Yumurta" alerjeni altinda kapsanıyor.
    select id into v_alerjen_id from alerjenler where ad = 'Tavuk';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('TAVUK BUT', 'TAVUK BÜTÜN', 'TAVUK GÖĞSÜ (TATLI)', 'TAVUK GÖĞÜS', 'TAVUK KANAT', 'TAVUK SUYU');

    select id into v_alerjen_id from alerjenler where ad = 'Jelatin';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('JELATİN');

    select id into v_alerjen_id from alerjenler where ad = 'Sarımsak';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('SARIMSAK');

    select id into v_alerjen_id from alerjenler where ad = 'Kişniş';
    insert into malzeme_alerjen (malzeme_id, alerjen_id)
    select id, v_alerjen_id from malzemeler where ad in ('KİŞNİŞ (KURU)', 'TAZE KİŞNİŞ');

end $$;

-- DOGRULAMA
select a.ad, a.kategori, count(ma.malzeme_id) as eslesen_malzeme_sayisi
from alerjenler a
left join malzeme_alerjen ma on ma.alerjen_id = a.id
where a.kategori is not null
group by a.ad, a.kategori
order by a.kategori, a.ad;
