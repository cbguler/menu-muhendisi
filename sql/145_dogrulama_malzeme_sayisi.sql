-- Her tarifin GERCEK malzeme sayisini, bizim BEKLEDIGIMIZ sayiyla
-- karsilastirir. Uyusmayan satir varsa (fark != 0), o tarif bizim
-- eklemedigimiz, ONCEDEN VAR OLAN ayni isimli bir tariftir.
with beklenen(ad, beklenen_sayi) as (
  values
    ('Bursa İskender Kebabı', 6),
    ('İnegöl Köfte', 6),
    ('Bursa Kestaneli Kaz Dolması', 8),
    ('İstanbul Usulü Karnıyarık', 9),
    ('Bandırma Mantısı', 9),
    ('Marmara Usulü Midye Tava', 9),
    ('Kırklareli Rokalı Beyaz Peynir Salatası', 6),
    ('Marmara Kestaneli Muhallebi', 5),
    ('İzmir Köfte (Fırında)', 8),
    ('Çeşme Usulü Ahtapot Güveç', 7),
    ('Ege Otlu Peynirli Gözleme', 5),
    ('Ege Usulü Isırgan Kavurması (Etli)', 6),
    ('Ege Yaylası Kuzu Tandır', 6),
    ('Ege Portakallı Zeytinyağlı Kek', 6),
    ('Datça Bademli Yeşil Salata', 6),
    ('Ege İnciri ile Komposto', 3),
    ('Antalya Usulü Nohut Piyazı', 7),
    ('Mersin Tantunisi', 8),
    ('Adana Kebap', 5),
    ('Hatay Usulü İçli Köfte (Etli)', 7),
    ('Antalya Şakşuka', 8),
    ('Akdeniz Usulü Limonlu Zeytin Ezmesi', 5),
    ('Adana Usulü Nar Ekşili Salata', 6),
    ('Antalya Usulü Şeftali Kompostosu', 3),
    ('Kayseri Mantısı', 9),
    ('Ankara Tava (Kuzu Etli)', 6),
    ('Konya Etli Ekmek', 7),
    ('Nevşehir Testi Kebabı', 7),
    ('Kayseri Yağlaması', 6),
    ('Kapadokya Kestaneli Komposto', 3),
    ('Kayseri Usulü Nohutlu Bulgur Pilavı', 6),
    ('Niğde Bademli Un Helvası', 5),
    ('Karadeniz Mıhlaması', 5),
    ('Karadeniz Kaymaklı Pide', 5),
    ('Trabzon Usulü Hamsili Pilav', 6),
    ('Rize Usulü Karalahana Çorbası', 5),
    ('Giresun Fındıklı Kuru Fasulye', 6),
    ('Karadeniz Mısır Ekmeği', 6),
    ('Trabzon Usulü Akçaabat Köfte', 6),
    ('Karadeniz Dutlu Komposto', 3),
    ('Erzurum Cağ Kebabı', 4),
    ('Erzincan Tulumlu Kavurma', 5),
    ('Van Otlu Peynirli Kahvaltı Böreği', 5),
    ('Malatya Kayısılı Kuzu Yahnisi', 5),
    ('Elazığ Usulü Kuru Fasulye Kavurması', 6),
    ('Kars Usulü Kaz Eti Kavurması', 4),
    ('Doğu Anadolu Pekmezli Ceviz Ezmesi', 3),
    ('Doğu Anadolu Kayısı ve Ceviz Salatası', 4),
    ('Gaziantep Alinazik Kebabı', 7),
    ('Şanlıurfa Usulü Çiğ Köfte (Etsiz)', 7),
    ('Urfa Usulü Kuzu Kavurma', 5),
    ('Mardin Usulü Kaburga Dolması', 6),
    ('Diyarbakır Usulü Meftune', 8),
    ('Antep Usulü Yuvalama Çorbası', 7),
    ('Siirt Usulü Büryan', 3),
    ('Antep Fıstıklı Muhallebi', 4)
)
select b.ad, b.beklenen_sayi, count(rm.id) as db_sayisi,
       (count(rm.id) - b.beklenen_sayi) as fark
from beklenen b
join receteler r on r.ad = b.ad and r.isletme_id is null
left join recete_malzemeleri rm on rm.recete_id = r.id
group by b.ad, b.beklenen_sayi
having count(rm.id) <> b.beklenen_sayi
order by b.ad;