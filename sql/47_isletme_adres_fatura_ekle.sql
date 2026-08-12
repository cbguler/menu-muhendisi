-- 47_isletme_adres_fatura_ekle.sql
--
-- Kullanici, Abonelik sayfasinin daha kapsamli isletme/fatura bilgisi
-- toplamasini istedi (12 Agustos 2026, Oturum 11). isletmeler tablosunda
-- su an SADECE "ad" sutunu var (subeler tablosunda "adres" zaten vardi,
-- isletmeler'de hic yoktu) -- iki yeni sutun ekleniyor: isletme adresi
-- ve fatura adresi (ikisi FARKLI olabilir -- ör. is yeri adresi ile
-- fatura kesilecek adres ayni olmayabilir, bu yuzden ayri tutuldu).
--
-- Her ikisi de nullable -- mevcut kayitlarda bu bilgi yok, doldurulmasi
-- kullaniciya birakiliyor.
--
-- NOT: vergi no/vergi dairesi/yetkili kisi/telefon gibi diger "kurumsal
-- abonelik" alanlari BILEREK bu migration'a EKLENMEDI -- kullanicidan
-- hangi spesifik alanlari istedigi netlesince ayri bir migration'la
-- eklenecek (asla tahmin/uydurma yapilmiyor).

alter table isletmeler add column if not exists adres text;
alter table isletmeler add column if not exists fatura_adresi text;

comment on column isletmeler.adres is 'Isletmenin fiziksel/operasyonel adresi';
comment on column isletmeler.fatura_adresi is 'Fatura kesilecek adres (isletme adresinden farkli olabilir)';

-- DOGRULAMA
select column_name, data_type, is_nullable
from information_schema.columns
where table_name = 'isletmeler'
order by ordinal_position;
