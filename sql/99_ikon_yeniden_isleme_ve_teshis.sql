-- 99_ikon_yeniden_isleme_ve_teshis.sql
--
-- 1) VE/VEYA duzeltmesi (SISTEM_PROMPTU degisikligi) daha ONCE
--    islenmis tarifleri OTOMATIK yeniden islemez -- cunku script
--    ARTIMLI calisir (sadece hash uyusmayanlari isler), ve
--    hazirlik_talimati METNI degismedi, sadece PROMPT degisti.
--    Bu yuzden TUM ORTAK kutuphane tariflerinin hazirlik_ikonlari
--    alani TEMIZLENIYOR -- boylece script bir sonraki calistirmada
--    HEPSINI (duzeltilmis VE/VEYA mantigiyla) yeniden isleyecek.
update receteler
set hazirlik_ikonlari = null
where isletme_id is null;

-- 2) Kapsam boslugu icin GERCEK veri -- "doldurma" ve "sise dizme"
--    disinda hangi eylemlerin (yikama, kirma, vb.) GERCEKTEN degerli
--    olabilecegini gormek icin, TUM hazirlik_talimati metinlerini
--    disa aktar (kucuk model artik cok daha fazla tarifi islemis
--    olabilir, 405+ tarif -- taze bir sayim gerekiyor).
select id, ad, hazirlik_talimati
from receteler
where isletme_id is null
and hazirlik_talimati is not null;
