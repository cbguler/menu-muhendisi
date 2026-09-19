select ad from receteler
where isletme_id is null
and ad in (
    'Sucuklu Yumurta (Tava)', 'Pastırmalı Kavurma', 'Kerevizli Kuzu Yahnisi', 'Mısırlı Tavuk Sote', 'Ispanaklı Kıyma (Tavada)',
    'Mısır Çorbası', 'Sucuklu Pilav', 'Nohutlu Pilav', 'Kerevizli Çorba', 'Zeytinyağlı Ispanak',
    'Güllaç (Ev Usulü)', 'Pastırmalı Kaşar Tabağı', 'Kerevizli Yoğurt Salatası', 'Mısırlı Salata', 'Taze Soğanlı Cacık', 'Ispanaklı Yoğurt (Borani)'
);
