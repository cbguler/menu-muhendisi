select ad from receteler
where isletme_id is null
and ad in (
    'Karides Güveç', 'Izgara Kalamar', 'Midye Dolma (Pilavlı)', 'Izgara Ahtapot', 'Fırında Patatesli Kıyma',
    'Patatesli Sebze Çorbası', 'Zeytinyağlı Taze Fasulye (Ev Usulü)', 'Karidesli Makarna',
    'Mercimekli Bulgur Pilavı', 'Humus (Ev Usulü)',
    'Tereli Yoğurt Salatası', 'Maydanozlu Bulgur Salatası (Kısır)', 'Ahtapot Salatası (Soğuk)',
    'Patates Salatası (Yoğurtlu)', 'Karışık Turşu (Ev Usulü, Sirkeli)', 'Portakal Kompostosu (Ev Usulü)'
);
