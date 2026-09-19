select ad from receteler
where isletme_id is null
and ad in (
    'Izgara Kuzu Pirzola', 'Izgara Sığır Bonfile', 'Fırında Tavuk Kanat',
    'Brokolili Tavuk Sote (Sporcu)', 'Fırında Bütün Tavuk (Ev Usulü)',
    'Brokoli Çorbası (Ev Usulü)', 'Yayla Çorbası (Ev Usulü)', 'Şehriyeli Bulgur Pilavı (Ev Usulü)',
    'Zeytinyağlı Barbunya Pilaki', 'İrmik Çorbası (Ev Usulü)',
    'Kadayıflı Süt Tatlısı', 'Muzlu Yoğurt (Ev Usulü)', 'Tahin Pekmez (Klasik)',
    'Ayran (Ev Usulü)', 'Muzlu Meyve Salatası', 'Karnabahar Turşusu'
);
