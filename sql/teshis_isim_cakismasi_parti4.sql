select ad from receteler
where isletme_id is null
and ad in (
    'Fırında Levrek', 'Karadeniz Usulü Hamsi Tava', 'Izgara Somon Fileto',
    'Etli Kuru Fasulye (Kış)', 'Izgara Palamut (Sonbahar)',
    'Kırmızı Mercimek Çorbası (Ev Usulü)', 'Zeytinyağlı Yaprak Sarma (Ev Usulü)',
    'Domates Soslu Makarna', 'Ispanaklı Mercimek Çorbası (Kış)',
    'Zeytinyağlı Enginar (İlkbahar)', 'Kaşarlı Fırın Makarna',
    'Ayva Tatlısı (Kış)', 'İncirli Yoğurt (Yaz)', 'Üzümlü Cevizli Yoğurt Salatası (Sonbahar)',
    'Mevsim Yeşillik Salatası', 'Naneli Cacık (Klasik)'
);
