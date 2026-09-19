select ad from receteler
where isletme_id is null
and ad in (
    'Hindi Sote (Ev Usulü)', 'Fırında Hindi But', 'Yer Elmalı Kuzu Yahnisi',
    'Enginar Kalpli Tavuk Güveç', 'Kırmızı Biberli Kıyma Sote',
    'Pancar Çorbası', 'Yer Elması Zeytinyağlısı', 'Zeytinyağlı Biber Dolması',
    'Enginar Kalpli Pilav', 'Şehriye Çorbası (Sade)',
    'Kuru Fasulye Piyazı', 'Pancar Salatası (Yoğurtlu)', 'Armutlu Cevizli Salata',
    'Mandalina Kompostosu', 'Turplu Yoğurt Salatası', 'Kırmızı Biber Turşusu'
);
