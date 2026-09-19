select ad from receteler
where isletme_id is null
and ad in (
    'Semizotlu Etli Yemek', 'Madımaklı Kavurma', 'Yoğurtlu Kebap (Ev Usulü)', 'Fırında Kuzu But (Bütün)', 'Nohutlu Tavuk Güveç',
    'Zeytinyağlı Semizotu', 'Domatesli Şehriye Çorbası', 'Kaşarlı Şehriyeli Pilav', 'Zeytinyağlı Havuç', 'Sade Ispanak Çorbası',
    'Salep (Ev Usulü)', 'Semizotlu Yoğurt', 'Nohut Ezmesi (Ev Usulü)', 'Yoğurtlu Havuç Salatası', 'Kuru Üzümlü Komposto', 'Zeytin ve Peynir Tabağı'
);
