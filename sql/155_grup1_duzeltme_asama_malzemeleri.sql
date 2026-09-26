-- 155_grup1_duzeltme_asama_malzemeleri.sql
-- 154'te ATLANAN bir adim duzeltiliyor: enerji hesabi icin, bir
-- asamada ISITILAN TUM malzemelerin (sadece su degil) asama_
-- malzemeleri'ne baglanmasi gerekiyordu. 154'te sadece SU baglandi.
-- Bu dosya, ayni 16 tarif icin EKSIK KALAN malzeme-asama
-- baglantilarini kuruyor (su HARIC -- o zaten bagliydi, tekrar
-- eklenirse mukerrer olur).
-- Ayrica: 'İstanbul Usulü Karnıyarık' metninde YEŞİL BİBER hic
-- gecmiyordu (malzeme listesinde var) -- metin de duzeltiliyor.

do $$
declare
    v_recete_id uuid;
    v_asama_id uuid;
    v_rm_id uuid;
    v_ad text;
begin
    update receteler set hazirlik_talimati = '**Hazırlık / Mise en Place**
1. Patlıcanları boydan ikiye kesip etli yüzlerine çapraz kesikler atın, hafif tuzlayıp 10 dk (aşağıdaki süreye dahil değildir) acı suyunu çıkarmaya bırakın, sonra kurulayın.
2. Kuru soğanı ve yeşil biberi küçük küp doğrayın, sarımsağı ince kıyın.
3. Domatesleri yıkayıp kabuklarını soyun ve küçük küp doğrayın; bir kısmını üstüne dizmek için dilimleyin.

**Isıl İşlem**
1. Kızartma (~85°C, tavada, 10 dk): Patlıcanları zeytinyağında her iki yüzü de yumuşayıp hafif renk alana kadar kızartın, bir kaba alın.
2. Pişirme / Fırınlama (~90°C, fırında, 25 dk): Aynı yağda soğanı 3-4 dk kavurun, yeşil biberi ve sarımsağı ekleyip 2 dk çevirin. Kıymayı ekleyip suyunu salıp çekene kadar (~6 dk) kavurun. Doğranmış domatesi, 20 ml (20 g) sıcak su, tuz ve karabiberi ekleyip 5 dk pişirin. Patlıcanları fırın kabına dizin, ortalarını hafifçe açıp harcı doldurun, üzerine domates dilimlerini yerleştirin. 190°C''ye önceden ısıtılmış fırında patlıcanlar iyice yumuşayana kadar pişirin.

**PARALEL YAPILABİLİRLİK:** Patlıcan kızartılırken kıyma sosu ayrı tavada hazırlanabilir.

**SÜRE ÖZETİ:** Aktif işçilik ~30 dk · Pasif bekleme ~15 dk · Toplam ~45 dk'
    where isletme_id is null and ad = 'İstanbul Usulü Karnıyarık';

    -- Bursa İskender Kebabı / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bursa İskender Kebabı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Bursa İskender Kebabı'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Bursa İskender Kebabı'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DÖNER (ET, PİŞMİŞ, BURSA)' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DÖNER (ET, PİŞMİŞ, BURSA)', 'Bursa İskender Kebabı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TEREYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TEREYAĞI', 'Bursa İskender Kebabı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DOMATES' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DOMATES', 'Bursa İskender Kebabı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Bursa İskender Kebabı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- İnegöl Köfte / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İnegöl Köfte';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'İnegöl Köfte'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'İnegöl Köfte'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DANA KIYMA' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DANA KIYMA', 'İnegöl Köfte'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'İnegöl Köfte'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'EKMEKLİK UN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / EKMEKLİK UN', 'İnegöl Köfte'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'İnegöl Köfte'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'İnegöl Köfte'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KİMYON' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KİMYON', 'İnegöl Köfte'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Bursa Kestaneli Kaz Dolması / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bursa Kestaneli Kaz Dolması';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Bursa Kestaneli Kaz Dolması'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Bursa Kestaneli Kaz Dolması'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KAZ ETİ (BÜTÜN, DERİLİ)' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KAZ ETİ (BÜTÜN, DERİLİ)', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'PİRİNÇ (HAM)' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / PİRİNÇ (HAM)', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KESTANE' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KESTANE', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KUŞ ÜZÜMÜ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KUŞ ÜZÜMÜ', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'YENİBAHAR' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / YENİBAHAR', 'Bursa Kestaneli Kaz Dolması'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- İstanbul Usulü Karnıyarık / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İstanbul Usulü Karnıyarık';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'İstanbul Usulü Karnıyarık'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'İstanbul Usulü Karnıyarık'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'PATLICAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / PATLICAN', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ZEYTİNYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ZEYTİNYAĞI', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- İstanbul Usulü Karnıyarık / asama 3
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İstanbul Usulü Karnıyarık';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'İstanbul Usulü Karnıyarık'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 3;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 3', 'İstanbul Usulü Karnıyarık'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DANA KIYMA' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DANA KIYMA', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DOMATES' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DOMATES', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'YEŞİL BİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / YEŞİL BİBER', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SARIMSAK' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SARIMSAK', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SU', 'İstanbul Usulü Karnıyarık'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Bandırma Mantısı / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Bandırma Mantısı';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Bandırma Mantısı'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Bandırma Mantısı'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'EKMEKLİK UN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / EKMEKLİK UN', 'Bandırma Mantısı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DANA KIYMA' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DANA KIYMA', 'Bandırma Mantısı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'Bandırma Mantısı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Bandırma Mantısı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SU', 'Bandırma Mantısı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TEREYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TEREYAĞI', 'Bandırma Mantısı'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Marmara Usulü Midye Tava / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Marmara Usulü Midye Tava';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Marmara Usulü Midye Tava'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Marmara Usulü Midye Tava'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'MİDYE' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / MİDYE', 'Marmara Usulü Midye Tava'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'EKMEKLİK UN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / EKMEKLİK UN', 'Marmara Usulü Midye Tava'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARBONAT (YEM. SODA)' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARBONAT (YEM. SODA)', 'Marmara Usulü Midye Tava'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'MISIR YAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / MISIR YAĞI', 'Marmara Usulü Midye Tava'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Marmara Usulü Midye Tava'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Marmara Kestaneli Muhallebi / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Marmara Kestaneli Muhallebi';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Marmara Kestaneli Muhallebi'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Marmara Kestaneli Muhallebi'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SÜT (TAM YAĞ)' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SÜT (TAM YAĞ)', 'Marmara Kestaneli Muhallebi'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KESTANE' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KESTANE', 'Marmara Kestaneli Muhallebi'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ŞEKER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ŞEKER', 'Marmara Kestaneli Muhallebi'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'MISIR NİŞASTASI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / MISIR NİŞASTASI', 'Marmara Kestaneli Muhallebi'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- İzmir Köfte (Fırında) / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'İzmir Köfte (Fırında)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'İzmir Köfte (Fırında)'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'İzmir Köfte (Fırında)'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DANA KIYMA' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DANA KIYMA', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'PATATES' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / PATATES', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DOMATES' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DOMATES', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'EKMEKLİK UN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / EKMEKLİK UN', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ZEYTİNYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ZEYTİNYAĞI', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SU', 'İzmir Köfte (Fırında)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Çeşme Usulü Ahtapot Güveç / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Çeşme Usulü Ahtapot Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Çeşme Usulü Ahtapot Güveç'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Çeşme Usulü Ahtapot Güveç'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'AHTAPOT' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / AHTAPOT', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SU', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Çeşme Usulü Ahtapot Güveç / asama 3
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Çeşme Usulü Ahtapot Güveç';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Çeşme Usulü Ahtapot Güveç'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 3;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 3', 'Çeşme Usulü Ahtapot Güveç'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'YEŞİL BİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / YEŞİL BİBER', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'DOMATES' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / DOMATES', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ZEYTİNYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ZEYTİNYAĞI', 'Çeşme Usulü Ahtapot Güveç'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Ege Otlu Peynirli Gözleme / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ege Otlu Peynirli Gözleme';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Ege Otlu Peynirli Gözleme'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Ege Otlu Peynirli Gözleme'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'YUFKA' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / YUFKA', 'Ege Otlu Peynirli Gözleme'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'OTLU PEYNİR' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / OTLU PEYNİR', 'Ege Otlu Peynirli Gözleme'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ISPANAK' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ISPANAK', 'Ege Otlu Peynirli Gözleme'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TEREYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TEREYAĞI', 'Ege Otlu Peynirli Gözleme'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Ege Otlu Peynirli Gözleme'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Ege Usulü Isırgan Kavurması (Etli) / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ege Usulü Isırgan Kavurması (Etli)';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KUZU ETİ (KOL)' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KUZU ETİ (KOL)', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ISIRGAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ISIRGAN', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ZEYTİNYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ZEYTİNYAĞI', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'Ege Usulü Isırgan Kavurması (Etli)'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Ege Yaylası Kuzu Tandır / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ege Yaylası Kuzu Tandır';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Ege Yaylası Kuzu Tandır'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Ege Yaylası Kuzu Tandır'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KUZU TANDIR' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KUZU TANDIR', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU SOĞAN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU SOĞAN', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ZEYTİNYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ZEYTİNYAĞI', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TUZ' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TUZ', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KEKİK' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KEKİK', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KARABİBER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KARABİBER', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SU', 'Ege Yaylası Kuzu Tandır'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Ege Portakallı Zeytinyağlı Kek / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ege Portakallı Zeytinyağlı Kek';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'EKMEKLİK UN' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / EKMEKLİK UN', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ŞEKER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ŞEKER', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ZEYTİNYAĞI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ZEYTİNYAĞI', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'PORTAKAL' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / PORTAKAL', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'TAVUK YUMURTASI' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / TAVUK YUMURTASI', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KABARTMA TOZU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KABARTMA TOZU', 'Ege Portakallı Zeytinyağlı Kek'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

    -- Ege İnciri ile Komposto / asama 2
    select id into v_recete_id from receteler where isletme_id is null and ad = 'Ege İnciri ile Komposto';
    if v_recete_id is null then raise exception 'Tarif bulunamadi: %', 'Ege İnciri ile Komposto'; end if;
    select id into v_asama_id from recete_asamalari where recete_id = v_recete_id and sira = 2;
    if v_asama_id is null then raise exception 'Asama bulunamadi: % / sira 2', 'Ege İnciri ile Komposto'; end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'KURU İNCİR' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / KURU İNCİR', 'Ege İnciri ile Komposto'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'ŞEKER' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / ŞEKER', 'Ege İnciri ile Komposto'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;
    select id into v_rm_id from recete_malzemeleri where recete_id = v_recete_id
      and malzeme_id = (select id from malzemeler where ad = 'SU' and isletme_id is null);
    if v_rm_id is null then raise exception 'Malzeme tarifte yok: % / SU', 'Ege İnciri ile Komposto'; end if;
    if not exists (select 1 from asama_malzemeleri where asama_id = v_asama_id and recete_malzeme_id = v_rm_id) then
        insert into asama_malzemeleri (asama_id, recete_malzeme_id) values (v_asama_id, v_rm_id);
    end if;

end $$;

-- Dogrulama: her ISIL asamada ARTIK BIRDEN FAZLA malzeme baglantisi
-- olmali (sadece su degil). Su-yok tariflerde de en az esas
-- malzemeler baglanmis olmali.
select r.ad, a.sira, a.ad as asama_adi, a.isil_islem_mi,
       count(am.id) as baglı_malzeme_sayisi
from receteler r
join recete_asamalari a on a.recete_id = r.id
left join asama_malzemeleri am on am.asama_id = a.id
where r.isletme_id is null
  and r.ad in ('Bursa İskender Kebabı', 'İnegöl Köfte', 'Bursa Kestaneli Kaz Dolması', 'İstanbul Usulü Karnıyarık', 'Bandırma Mantısı', 'Marmara Usulü Midye Tava', 'Kırklareli Rokalı Beyaz Peynir Salatası', 'Marmara Kestaneli Muhallebi', 'İzmir Köfte (Fırında)', 'Çeşme Usulü Ahtapot Güveç', 'Ege Otlu Peynirli Gözleme', 'Ege Usulü Isırgan Kavurması (Etli)', 'Ege Yaylası Kuzu Tandır', 'Ege Portakallı Zeytinyağlı Kek', 'Datça Bademli Yeşil Salata', 'Ege İnciri ile Komposto')
group by r.ad, a.sira, a.ad, a.isil_islem_mi
order by r.ad, a.sira;
