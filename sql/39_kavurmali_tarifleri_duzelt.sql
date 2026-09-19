-- 39_kavurmali_tarifleri_duzelt.sql
--
-- "Kavurmalı X" adindaki 3 tarif, kavurma (korunmus et urunu) yerine
-- yanlislikla PASTIRMA veya SIĞIR KIYMA ile taniml anmis. KAVURMA
-- malzemesi 38_kavurma_malzeme_ekle.sql ile eklendikten SONRA bu
-- script calistirilmali.
--
-- Duzeltilen tarifler (miktar aynen korunuyor):
--   - Erzincan Usulü Kavurmalı Yumurta: PASTIRMA 40g -> KAVURMA 40g
--   - Erzurum Usulü Kavurmalı Kuru Fasulye: SIĞIR KIYMA 50g -> KAVURMA 50g
--   - Kavurmalı Nohut: PASTIRMA 40g -> KAVURMA 40g
--
-- Degistirilmeyenler (kavurma burada YONTEM/tarifin kendisi, malzeme
-- degil -- dogru oldugu icin dokunulmuyor): Pazı Kavurma (Etli),
-- Kavurma (Erzurum Usulü), Küşleme (Kuzu Kavurma).

update recete_malzemeleri
set malzeme_id = (select id from malzemeler where ad = 'KAVURMA' and isletme_id is null)
where recete_id = (select id from receteler where ad = 'Erzincan Usulü Kavurmalı Yumurta' and isletme_id is null)
  and malzeme_id = (select id from malzemeler where ad = 'PASTIRMA' and isletme_id is null);

update recete_malzemeleri
set malzeme_id = (select id from malzemeler where ad = 'KAVURMA' and isletme_id is null)
where recete_id = (select id from receteler where ad = 'Erzurum Usulü Kavurmalı Kuru Fasulye' and isletme_id is null)
  and malzeme_id = (select id from malzemeler where ad = 'SIĞIR KIYMA' and isletme_id is null);

update recete_malzemeleri
set malzeme_id = (select id from malzemeler where ad = 'KAVURMA' and isletme_id is null)
where recete_id = (select id from receteler where ad = 'Kavurmalı Nohut' and isletme_id is null)
  and malzeme_id = (select id from malzemeler where ad = 'PASTIRMA' and isletme_id is null);

-- DOGRULAMA -- bu sorgunun sonucuna bak. Her 3 tarifte de "KAVURMA"
-- gorunuyorsa duzeltme basarili demektir.
select r.ad as tarif, m.ad as malzeme, rm.miktar_gram
from receteler r
join recete_malzemeleri rm on rm.recete_id = r.id
join malzemeler m on m.id = rm.malzeme_id
where r.ad in ('Erzincan Usulü Kavurmalı Yumurta', 'Erzurum Usulü Kavurmalı Kuru Fasulye', 'Kavurmalı Nohut')
  and r.isletme_id is null
order by r.ad, m.ad;
