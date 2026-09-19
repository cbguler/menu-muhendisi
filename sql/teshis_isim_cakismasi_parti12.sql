select ad from receteler
where isletme_id is null
and ad in (
    'Izgara Dana Böbrek', 'Soyalı Biberli Sote (Etsiz)', 'Soya Kıymalı Patlıcan Musakka (Etsiz)', 'Fırında Dana Beyin', 'Kuzu Etli Kırmızı Mercimek Yemeği',
    'İşkembe Çorbası', 'Soya Kıymalı Zeytinyağlı Dolma', 'Kırmızı Mercimekli Pilav', 'Zeytinyağlı Soya Fasulyesi', 'Zeytinyağlı Kuru Fasulye (Soğuk)',
    'Mercimek Köftesi (Ev Usulü)', 'Yeşil Mercimekli Salata', 'Elma Kompostosu', 'Domatesli Cacık', 'Havuç Turşusu', 'Cevizli Pekmez'
);
