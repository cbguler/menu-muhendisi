select ad from receteler
where isletme_id is null
and ad in (
    'Zeytinyağlı Patlıcan (Yaz)', 'Zeytinyağlı Kabak (Yaz)', 'Yaz Domates Çorbası',
    'Mısırlı Yaz Pilavı', 'Zeytinyağlı Bamya (Yaz)', 'Peynirli Yaz Böreği',
    'Kestaneli Sonbahar Pilavı', 'Karnabahar Çorbası (Sonbahar)', 'Zeytinyağlı Karalahana (Sonbahar)',
    'Portakallı Mandalinalı Kış Salatası', 'Kuru Kayısılı Kış Kompostosu', 'Kış Lahana Turşusu'
);
