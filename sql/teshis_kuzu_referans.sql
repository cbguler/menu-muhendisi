select ad, kategori_id, yogunluk, ozgul_isi, bozulma_suresi, fire_orani,
       saklama_isisi, mevsim, isi_iletkenlik, yuzey_alani
from malzemeler
where ad ilike '%KUZU ET%';
