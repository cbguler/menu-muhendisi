-- Bu tarifin "hazirlik_talimati" metnini TAM OLARAK (satir sonlari
-- dahil) gormek icin -- ekran goruntusundeki tuhaf ikon siralamasini
-- teshis etmek amaciyla.
select
    ad,
    hazirlik_talimati
from receteler
where hazirlik_talimati ilike '%tuzla su%'
limit 3;
