-- 19_recete_bolge_ekle.sql
--
-- Yillik menu motoruna bolgesel mutfak secimi eklemek icin `receteler`
-- tablosuna `bolge` sutunu ekleniyor. Mevcut 120 tarif (74 genel +
-- 20 Karadeniz + 26 Ege) geriye donuk olarak isimlerine gore
-- etiketleniyor. Bundan sonraki partiler (Akdeniz, Guneydogu, Ic
-- Anadolu, Marmara, Dogu Anadolu) yukle_yeni_tarifler.py ile eklenirken
-- BOLGE_ADI sabiti uzerinden otomatik isaretlenecek, bu geriye donuk
-- guncellemeye bir daha gerek kalmayacak.

alter table receteler add column if not exists bolge text;
comment on column receteler.bolge is
  'Tarifin ait oldugu cografi bolge (Karadeniz, Ege, Akdeniz, ...). '
  '''Genel'' = belirli bir bolgeye ozgu olmayan, yaygin Turk mutfagi tarifi.';

update receteler set bolge = 'Karadeniz'
where isletme_id is null and ad in (
  'Karadeniz Usulü Hamsi Buğulama', 'Akçaabat Köfte', 'Karalahana Sarması (Etli)',
  'Hamsili Pilav', 'Kuymak (Muhlama)', 'Karadeniz Usulü Palamut Izgara',
  'Fındıklı Tavuk Sote', 'Karadeniz Usulü Fasulye Pilaki', 'Karalahana Çorbası',
  'Mısır Çorbası (Karadeniz Usulü)', 'Karadeniz Pidesi (Kıymalı)', 'Mısır Ekmeği',
  'Fındıklı Pirinç Pilavı', 'Kolot Böreği (Peynirli)', 'Laz Böreği',
  'Kete (Karadeniz Tatlısı)', 'Fındıklı Kurabiye', 'Karadeniz Yeşil Salata',
  'Karalahana Turşusu', 'Fındıklı Sütlaç'
);

update receteler set bolge = 'Ege'
where isletme_id is null and ad in (
  'Zeytinyağlı Bakla', 'Ahtapot Izgara', 'Pazı Kavurma (Etli)',
  'Fırında Çipura (Sebzeli)', 'İzmir Köfte', 'Etli Enginar Dolması',
  'Midyeli Pilav', 'Domates Dolması (Zeytinyağlı)', 'Ege Usulü Fırın Tavuk (Zeytinli)',
  'Bademli Tavuk Sote', 'Pazı Çorbası', 'Ege Otlu Bulgur Pilavı',
  'Zeytinyağlı Enginar Kalbi', 'Zeytinyağlı Radika', 'Bademli Pilav',
  'Ispanaklı Makarna (Ege Usulü)', 'Zeytinyağlı Yer Elması', 'Ege Peynirli Gözleme',
  'Radika Salatası (Haşlanmış)', 'Midye Dolma', 'Bademli Kurabiye',
  'Şeftalili Komposto', 'Üzüm Salatası', 'İncir Tatlısı (Kremalı)',
  'Zeytin Ezmesi', 'Limonlu Kek'
);

-- Geri kalan her sey (orijinal 74 tariflik baslangic kutuphanesi) = Genel.
update receteler set bolge = 'Genel'
where isletme_id is null and bolge is null;
