-- 41_deneme_plani_kaldir.sql
--
-- "Deneme" abonelik kavrami tamamen kaldiriliyor (6 Agustos 2026,
-- kullanici karari). Yeni model: kullanici parayi odeyip donemsel
-- (aylik/yillik) bir plan secer -> abonelikler.durum
-- 'odeme_alindi_onay_bekliyor' olur -> admin (sadece Bahri, koda
-- hardcode edilmis e-posta ile) onaylayinca durum 'aktif' olur.
--
-- ADIM SIRASI ONEMLI: once Bahri'nin kendi abonelik satirini "deneme"
-- planindan GERCEK bir plana (kurumsal, sinirsiz erisim icin) tasiyoruz
-- VE durumunu direkt 'aktif' yapiyoruz (kendisi zaten admin olacagi
-- icin onay beklemesine gerek yok) -- ANCAK BUNDAN SONRA "deneme" satirini
-- abonelik_planlari'ndan silebiliriz (yabanci anahtar kisitlamasi
-- yuzunden, hala referans eden bir satir varken silinemez).

update abonelikler
set
  plan_id = (select id from abonelik_planlari where kod = 'kurumsal'),
  durum = 'aktif'
where plan_id = (select id from abonelik_planlari where kod = 'deneme');

update isletmeler
set plan_tipi = 'kurumsal'
where plan_tipi = 'deneme';

delete from abonelik_planlari where kod = 'deneme';

-- DOGRULAMA
select a.durum, p.kod as plan_kodu, i.ad as isletme, i.plan_tipi
from abonelikler a
join abonelik_planlari p on p.id = a.plan_id
join isletmeler i on i.id = a.isletme_id;

select kod, ad from abonelik_planlari order by kod;
