select ad from receteler
where isletme_id is null
and ad in (
    'Izgara Dana Pirzola', 'Fındıklı Tavuk Sote', 'Sade Kuzu Güveç (Et Suyu ile)', 'Bademli Fırın Tavuk But', 'Antep Fıstıklı Kavurma',
    'Yulaflı Çorba', 'Bademli Pirinç Pilavı', 'Antep Fıstıklı Bulgur Pilavı', 'Et Suyu Çorbası (Sade)', 'Kaşarlı Bulgur Pilavı',
    'Muhallebi (Ev Usulü)', 'Keşkül (Ev Usulü)', 'Badem Ezmesi Tabağı', 'Yeşil Salata (Cevizli)', 'Yulaf Ezmeli Yoğurt', 'Kayısı Kompostosu'
);
