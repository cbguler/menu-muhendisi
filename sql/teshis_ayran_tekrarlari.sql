-- Ayran ve benzeri, "ayni yemegin farkli isimli kopyalari" olabilecek
-- durumlari tespit etmek icin -- SADECE isim iceriginde eslesenleri
-- gosteriyor, gercekten ayni yemek mi degil mi Bahri karar verecek.

select id, ad, mevsim_etiketi, bolge
from receteler
where isletme_id is null
and (
    ad ilike '%ayran%'
)
order by ad;
