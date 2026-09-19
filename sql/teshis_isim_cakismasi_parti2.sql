select ad from receteler
where isletme_id is null
and ad in (
    'Taze Fasulyeli Kuzu Güveç (İlkbahar)', 'Havuçlu Fırın Tavuk But (Bahar)',
    'Nohutlu Sığır Kavurma (Bahar)', 'Pırasalı Kıymalı Bahar Yemeği',
    'Havuç Çorbası (Bahar)', 'Zeytinyağlı Pırasa (Bahar)', 'Şehriyeli Bahar Pilavı', 'Zeytinyağlı Kereviz (Bahar)',
    'Bahar Cacığı', 'Portakallı Havuç Salatası (Bahar)', 'Elmalı Cevizli Bahar Salatası', 'Barbunya Turşusu (Bahar)'
);
