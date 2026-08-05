-- 33_aktif_dakika_ekle.sql
--
-- Kullanicinin bulgusu: uzun PASIF asamalarda (ör. 165 dk'lik firin
-- suresi) mevcut sistem sure_dakika'nin TAMAMINI ucretli iscilik
-- sayiyordu -- oysa personel bu surenin cogunda baska is yapabilir,
-- sadece periyodik kontrol (ör. 5-10 dk) gercek aktif iscilik.
--
-- Coz: recete_asamalari'ye ayri bir aktif_dakika alani eklendi.
-- NULL = eski davranis (sure_dakika ile ayni, geriye uyumlu -- mevcut
-- kullanici tarifleri hic bozulmadan calismaya devam eder). Sadece
-- acikca girilirse sure_dakika'dan FARKLI bir iscilik suresi kullanilir.

alter table recete_asamalari add column if not exists aktif_dakika numeric;
comment on column recete_asamalari.aktif_dakika is
  'Bu asamada personelin GERCEKTEN mesgul oldugu sure (dakika) -- iscilik '
  'maliyeti hesabinda kullanilir. NULL ise sure_dakika ile ayni kabul '
  'edilir (eski/varsayilan davranis). Uzun pasif asamalarda (firin, '
  'haslama, bekletme) sure_dakika toplam gecen sureyi (kritik yol '
  'hesabinda kullanilir), aktif_dakika ise sadece periyodik kontrol gibi '
  'gercekten ucretli calisma suresini temsil eder.';

-- Iscilik maliyeti view'i artik aktif_dakika'yi (varsa) kullanacak
-- sekilde guncelleniyor -- geriye uyumlu (NULL ise eski davranis).
-- NOT: yeni sutun (ucretlendirilen_dakika) EN SONA eklendi -- Postgres
-- CREATE OR REPLACE VIEW ile mevcut sutunlarin sirasini degistirmeye
-- izin vermiyor (42P16 hatasi), yeni sutunlar sadece sona eklenebilir.
create or replace view asama_iscilik_maliyeti as
select
  a.id as asama_id,
  a.recete_id,
  a.sure_dakika,
  (coalesce(a.aktif_dakika, a.sure_dakika) / 60.0) * ima.personel_saat_ucreti_eur as iscilik_maliyeti_eur,
  coalesce(a.aktif_dakika, a.sure_dakika) as ucretlendirilen_dakika
from recete_asamalari a
join receteler r on r.id = a.recete_id
join isletme_maliyet_ayarlari ima on ima.isletme_id = r.isletme_id;

alter view asama_iscilik_maliyeti set (security_invoker = on);