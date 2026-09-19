select ad from receteler
where isletme_id is null
and ad in (
    'Fırında Kuzu Pirzola (Sebzeli)', 'Fırında Kalkan', 'Baharatlı Izgara Piliç Göğüs', 'Keçi Eti Güveç', 'Izgara Sığır Pirzola',
    'Karabuğday Pilavı', 'Zeytinyağlı Siyah Fasulye', 'Rezene Çorbası', 'Sebzeli Quinoa Pilavı', 'Mung Fasulyeli Pilav',
    'Rokforlu Armut Salatası', 'Kefirli Salatalık', 'Greyfurtlu Roka Salatası', 'Hurma ve Süt Tatlısı', 'Kızılcık Kompostosu', 'Kajulu Havuç Salatası'
);
