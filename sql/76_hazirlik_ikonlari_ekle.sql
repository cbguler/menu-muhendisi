-- 76_hazirlik_ikonlari_ekle.sql
--
-- AI tabanli ikon siniflandirmasinin SONUCUNU saklamak icin yeni sutun.
-- Format (JSONB):
--   {
--     "hash": "<hazirlik_talimati metninin SHA-256 ozeti>",
--     "ikonlar_by_satir": [["dograma_sogan"], [], ["kavurma","haslama"], ...]
--   }
-- "ikonlar_by_satir" listesi, hazirlik_talimati.splitlines() ile ayni
-- SIRADA ve ayni SAYIDA elemana sahiptir -- her satirin kendi ikon
-- listesi (bos olabilir).
--
-- "hash" alani, metin degismeden script'in GEREKSIZ YERE yeniden
-- calismasini onlemek icin -- script sadece hash uyusmayan (veya
-- hic hesaplanmamis) tarifleri isler.

alter table receteler
    add column if not exists hazirlik_ikonlari jsonb;

comment on column receteler.hazirlik_ikonlari is
    'AI tabanli hazirlik-asamasi ikon siniflandirmasinin onbellege alinmis sonucu. ikon_siniflandirma_calistir.py tarafindan doldurulur.';
