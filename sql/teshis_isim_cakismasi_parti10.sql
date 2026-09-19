select ad from receteler
where isletme_id is null
and ad in (
    'Bezelyeli Kuzu Yemeği', 'Roka Soslu Izgara Tavuk', 'Kuşkonmazlı Dana Bonfile', 'Fırında Somon Sebzeli', 'Patlıcanlı Kıyma Musakka',
    'Tarhana Çorbası', 'Konserve Bezelyeli Makarna', 'Roka Soslu Makarna', 'Kuşkonmaz Çorbası', 'Tavuk Suyu Çorbası (Sade)',
    'Rokalı Domates Salatası', 'Haşlanmış Yumurta Salatası', 'Patlıcan Salatası (Közlenmiş)', 'Ispanaklı Cacık', 'Patlıcan Turşusu', 'Karışık Meyve Kompostosu'
);
