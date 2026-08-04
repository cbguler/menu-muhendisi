-- 30_hazirlik_talimati_ekle.sql
--
-- Pisirme talimatlari ozelligi icin altyapi: receteler tablosuna
-- adim adim hazirlik talimati tutacak bir metin alani ekleniyor.
-- Baslangicta tum tarifler icin bos (NULL) -- kademeli olarak
-- doldurulacak. Porsiyon olcekleme icin ayri bir alan gerekmiyor --
-- recete_malzemeleri'ndeki miktar_gram degerleri zaten 1 porsiyon
-- baz alinarak tasarlandi, arayuz bunu direkt carpacak.

alter table receteler add column if not exists hazirlik_talimati text;
comment on column receteler.hazirlik_talimati is
  'Adim adim hazirlik/pisirme talimati (serbest metin, numarali adimlar). '
  'NULL = henuz girilmedi. Malzeme miktarlari (recete_malzemeleri) 1 '
  'porsiyon baz alinir; talimat metni porsiyon sayisindan bagimsizdir '
  '(sadece malzeme miktarlari olceklenir, sure/teknik degismez).';
