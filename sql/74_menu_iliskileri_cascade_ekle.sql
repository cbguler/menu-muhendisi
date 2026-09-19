-- 74_menu_iliskileri_cascade_ekle.sql
--
-- BULUNAN HATA (24 Agustos 2026): kullanici Recete Uretimi sayfasinda bir
-- receteyi silmeye calisirken postgrest.exceptions.APIError aldi.
--
-- KOK NEDEN (teshis sorgusuyla dogrulandi -- pg_constraint uzerinden):
-- receteler tablosuna bagli 4 foreign key'den 2'si (recete_malzemeleri,
-- recete_asamalari -- ve onlarin altindaki asama_malzemeleri/
-- asama_bagimliliklari) zaten ON DELETE CASCADE ile kuruluydu, sorun
-- degildi. Ama DIGER IKI tablo CASCADE'siz kalmisti:
--   menu_ogeleri_recete_id_fkey         -- CASCADE YOK
--   menu_takvimi_ogeleri_recete_id_fkey -- CASCADE YOK
-- menu_ogeleri, "Ozel Menu Uretimi" sayfasinda bir receteyi satisa
-- actiginda ("Menuye ekle") satir olusturuyor -- receteyi Menuye
-- eklenmis bir kullanici, o receteyi Recete Uretimi'nde silmeye
-- calistiginda bu FK ihlal ediliyordu (menu_takvimi_ogeleri henuz
-- hicbir sayfa tarafindan yazilmiyor, o yuzden bu hatayi henuz kimse
-- bu tablodan almadi, ama ayni sorunu ileride yasatirdi).
--
-- URUN KARARI (kullaniciyla teyit edildi, 24 Agustos 2026): receteler
-- tamamen isletmenin kendi ozel verisi (241 tariflik genel kutuphaneden
-- AYRI) -- kullanici bir receteyi ISTEDIGI GIBI silebilmeli/
-- degistirebilmeli, ve bu degisiklik kendi menusune de OTOMATIK
-- yansimali. Yani receteler(id) silinince menu_ogeleri/
-- menu_takvimi_ogeleri'ndeki karsilik gelen satirlarin da SESSIZCE
-- silinmesi (CASCADE) dogru davranis -- bir engelleme/uyari mesaji
-- DEGIL.

alter table menu_ogeleri drop constraint menu_ogeleri_recete_id_fkey;
alter table menu_ogeleri add constraint menu_ogeleri_recete_id_fkey
  foreign key (recete_id) references receteler(id) on delete cascade;

alter table menu_takvimi_ogeleri drop constraint menu_takvimi_ogeleri_recete_id_fkey;
alter table menu_takvimi_ogeleri add constraint menu_takvimi_ogeleri_recete_id_fkey
  foreign key (recete_id) references receteler(id) on delete cascade;

-- DOGRULAMA -- artik butun satirlarda "ON DELETE CASCADE" gorunmeli
select
  con.conname as kisit_adi,
  con.conrelid::regclass as bagimli_tablo,
  pg_get_constraintdef(con.oid) as tanim
from pg_constraint con
where con.contype = 'f'
  and con.confrelid in ('receteler'::regclass, 'recete_asamalari'::regclass)
order by bagimli_tablo;
