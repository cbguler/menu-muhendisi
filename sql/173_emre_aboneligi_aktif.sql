-- 173_emre_aboneligi_aktif.sql
-- YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Bahri'nin talebiyle
-- oglu Emre'nin (emreguler98@hotmail.com, GİZ-EM RESTAURANT LTD. ŞTİ.)
-- aboneligi odeme ve e-posta dogrulama akisi beklenmeden baslatiliyor.
-- E-posta dogrulamasi ve isletme adi 172'de yapildi.
--
-- Degisen: abonelikler.durum 'odeme_bekleniyor' -> 'aktif',
--          donem_baslangic = bugun.
-- BILINCLI OLARAK DOKUNULMAYAN (Bahri'nin karari bekleniyor):
--   plan_id NULL kaliyor (app.py erisimi sadece durum'a gore veriyor;
--     recete_limiti NULL = sinirsiz),
--   donem_bitis NULL kaliyor (bitis tarihi belirtilmedi).
-- UPDATE tam 1 satir etkilemezse hata verir ve geri alinir.

begin;

do $$
declare n int;
begin
  update public.abonelikler
     set durum = 'aktif',
         donem_baslangic = current_date,
         updated_at = now()
   where id = '68e0d627-d5eb-4846-988d-5aca32e2d78f'
     and isletme_id = '46ad7857-581e-4e1b-9d24-d6d1c9e2916f'
     and durum = 'odeme_bekleniyor';
  get diagnostics n = row_count;
  if n <> 1 then
    raise exception 'Abonelik: beklenen 1 satir, etkilenen %', n;
  end if;
end $$;

commit;

-- Dogrulama: uygulamanin okudugu gorunum (app.py isletme_aktif_abonelik'e bakar).
-- 1 satir ve durum = 'aktif' donmeli. BOS donerse gorunum plan_id NULL satiri
-- disliyor demektir; o zaman bir sonraki adimda plan atanacak.
select to_jsonb(v) as uygulamanin_gordugu_abonelik
from public.isletme_aktif_abonelik v
where v.isletme_id = '46ad7857-581e-4e1b-9d24-d6d1c9e2916f';
