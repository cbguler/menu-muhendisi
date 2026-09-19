select ad from receteler
where isletme_id is null
and ad in (
    'Enginarlı Kuzu Yahnisi', 'Bahar Sebzeli Tavuk Sote', 'Taze Bakla Kavurma (Etli)', 'Ispanaklı Yumurta',
    'Enginar Çorbası', 'Zeytinyağlı Taze Bakla', 'Bezelyeli Pilav', 'Ispanaklı Börek',
    'Roka Marul Salatası', 'Kuşkonmaz Salatası', 'Çilekli Yoğurt', 'Vişne Kompostosu'
);
