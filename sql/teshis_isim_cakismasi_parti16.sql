select ad from receteler
where isletme_id is null
and ad in (
    'Fırında Koyun Tandır', 'Izgara Piliç But', 'Fırında Sığır Kaburga', 'Otlu Izgara Çipura', 'Nar Ekşili Dana Rosto',
    'Kestane Mantarlı Pirinç Pilavı', 'Pazılı Nohut Yemeği', 'Karnıbahar Çorbası', 'Arpa Çorbası', 'Brüksel Lahanalı Zeytinyağlı',
    'Cevizli Kırmızı Lahana Salatası', 'Keçi Peynirli Pancar Salatası', 'Narlı Ispanak Salatası', 'Kayısılı Yoğurt', 'Ekmek Kadayıfı (Kaymaklı)', 'Nar Ekşili Kısır'
);
