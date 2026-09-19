select ad from receteler
where isletme_id is null
and ad in (
    'Domates Dolması (Etli)', 'Lahana Dolması (Etli)', 'Kabak Dolması (Etli)', 'Biber Dolması (Etli)', 'Enginar Dolması (Etli)',
    'Zeytinyağlı Kabak Dolması', 'Zeytinyağlı Lahana Dolması', 'Zeytinyağlı Domates Dolması', 'Peynirli Kabak Böreği', 'Kabak Çorbası',
    'Lahana Salatası', 'Kabaklı Yoğurt Salatası', 'Enginar Salatası', 'Domates Turşusu', 'Kabak Turşusu', 'Enginarlı Yoğurt'
);
