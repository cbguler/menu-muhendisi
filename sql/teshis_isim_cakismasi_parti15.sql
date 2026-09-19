select ad from receteler
where isletme_id is null
and ad in (
    'Fırında Dana But', 'Patatesli Dana Güveç', 'Kerevizli Tavuk Sote', 'Bezelyeli Dana Yahnisi', 'Taze Fasulyeli Tavuk Güveç',
    'Havuç ve Kereviz Çorbası', 'Naneli Bulgur Pilavı', 'Zeytinyağlı Patatesli Havuç', 'Zeytinyağlı Bezelyeli Havuç', 'Domatesli Patates Yemeği (Etsiz)',
    'İrmik Helvası (Ev Usulü)', 'Limonlu Zeytinyağlı Havuç Salatası', 'Zeytinyağlı Patates Salatası', 'Portakal ve Limon Kompostosu', 'Bezelyeli Yoğurt Salatası', 'Naneli Yoğurt'
);
