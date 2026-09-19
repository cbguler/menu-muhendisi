-- teshis_kutuphane_genisletme.sql
--
-- Amac: 241 tariflik ORTAK kutuphaneyi (isletme_id IS NULL) genisletmeden
-- once, gercek veriyi gormek -- boylece UYDURMA besin degeri KULLANMADAN,
-- gercek malzemelerle, dogru grup/mevsim/etiket siniflandirmasiyla yeni
-- tarifler tasarlayabilirim.

-- 1) Kategori (grup) tanimlari -- hangi sira numarasi hangi yemek turune
--    karsilik geliyor?
select mk.id, mk.sira, mk.ad, m.kod as mutfak_kodu
from mutfak_kategorileri mk
join mutfaklar m on m.id = mk.mutfak_id
order by m.kod, mk.sira;

-- 2) Grup x Mevsim dagilimi -- HANGI kombinasyonlar zayif/az sayida?
--    (algoritmanin en cok zorlandigi yerler muhtemelen buradaki
--    dusuk sayili hucrelerdir)
select mk.sira as grup, r.mevsim_etiketi, count(*) as tarif_sayisi
from receteler r
join mutfak_kategorileri mk on mk.id = r.mutfak_kategori_id
where r.isletme_id is null
group by mk.sira, r.mevsim_etiketi
order by mk.sira, r.mevsim_etiketi;

-- 3) Kullanilan TUM ozel_etiketler degerleri (tekil) -- uyumluluk
--    sistemi hangi etiketleri taniyor, hepsini gormek icin
select distinct unnest(ozel_etiketler) as etiket
from receteler
where isletme_id is null
order by etiket;

-- 4) Kullanilan TUM bolge degerleri (tekil)
select distinct bolge, count(*) as tarif_sayisi
from receteler
where isletme_id is null
group by bolge
order by tarif_sayisi desc;

-- 5) Malzeme kataloğu -- YENI tariflerde SADECE burada var olan
--    malzemeleri kullanabilirim (isim BIREBIR eslesmeli). Bu CSV
--    olarak disa aktarilip (Supabase SQL Editor'de "Export" butonu)
--    bana yuklenmeli -- 500+ satir oldugu icin sohbette gosterilemez.
select id, ad, kalori, protein, yag, karbonhidrat, glisemik_indeks
from malzemeler
where isletme_id is null
order by ad;
