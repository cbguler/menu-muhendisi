-- 93_guvenlik_uyarilarini_duzelt.sql
--
-- Supabase Security Advisor'in bildirdigi 1 hata + 7 uyarinin (bkz.
-- teshis_guvenlik_uyarilari*.sql sonuclari) analiz edilmis duzeltmesi.
-- Her degisiklik, ilgili gorunum/fonksiyonun GERCEK tanimini
-- inceledikten SONRA yapildi -- kor bir "hepsini kapat" yaklasimi
-- DEGIL.

-- =========================================================================
-- 1) recete_guncel_maliyet GORUNUMU: security_invoker=true yapiliyor
-- =========================================================================
-- Bu gorunum receteler+recete_malzemeleri+malzemeler+malzeme_guncel_fiyat
-- tablolarini isletme_id'ye gore birlestirip maliyet hesapliyor. SECURITY
-- DEFINER (varsayilan eski davranis) oldugu icin, ALTINDAKI tablolarin
-- RLS kurallarini atlayarak calisabiliyor -- yani TEORIK olarak bir
-- isletme, BASKA bir isletmenin tarif maliyet/fiyat verisini gorebilir.
-- security_invoker=true, gorunumun SORGUYU YAPAN kullanicinin KENDI RLS
-- kisitlamalariyla calismasini saglar -- yani "isletme A, sadece kendi
-- isletme_id'sine ait satirlari gorur" kurali GORUNUM ICIN DE gecerli
-- olur. Uygulama zaten sorgularinda isletme_id ile filtreledigi icin
-- (ve alttaki tablolarin RLS'i onceki oturumlarda zaten duzeltilmisti),
-- bu degisiklik GUVENLI olmali.
alter view public.recete_guncel_maliyet set (security_invoker = true);

-- =========================================================================
-- 2) rls_auto_enable(): sadece OLAY TETIKLEYICISI olarak calismali,
--    ELLE cagrilmaya ACIK OLMAMALI
-- =========================================================================
-- Bu fonksiyon "event trigger" (yeni tablo olusturulunca otomatik RLS
-- acan) -- normal kullanicilarin/anonim cagrilarin BUNU DOGRUDAN
-- cagirmasi icin HICBIR MESRU SEBEP yok. Tetikleyiciler kendi ic
-- mekanizmasiyla calisir, EXECUTE izni GEREKMEZ -- bu yuzden izinleri
-- kaldirmak uygulamanin islevini ETKILEMEZ.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

-- =========================================================================
-- 3) yeni_kullanici_isle(): sadece auth.users INSERT TETIKLEYICISI
--    olarak calismali, ELLE cagrilmaya ACIK OLMAMALI
-- =========================================================================
-- Bu fonksiyon yeni kullanici kaydolunca otomatik isletme+kullanici+
-- abonelik kaydi olusturuyor -- bir TETIKLEYICI, RPC endpoint'i degil.
-- Elle cagirmanin (NEW kaydi olmadan) zaten calismasi beklenmez, ama
-- gereksiz yuzey alanini kapatmak icin izinler kaldiriliyor.
revoke execute on function public.yeni_kullanici_isle() from public, anon, authenticated;

-- =========================================================================
-- 4) auth_isletme_id(): RLS kurallari ICINDE kullanilan standart bir
--    yardimci fonksiyon -- SECURITY DEFINER olmasi muhtemelen KASITLI
--    (RLS politikalarinda "sonsuz dongu" onlemek icin yaygin bir
--    Supabase deseni). SADECE anonim (giris yapmamis) erisimi kaldirildi
--    -- authenticated icin dokunulmadi (uygulama dogrudan cagiriyor
--    olabilir, bunu KESIN bilmeden kaldirmak riskli olurdu).
-- =========================================================================
revoke execute on function public.auth_isletme_id() from anon;

-- DOGRULAMA: yeni izin durumunu goster
select routine_name, grantee, privilege_type
from information_schema.role_routine_grants
where routine_name in ('auth_isletme_id', 'rls_auto_enable', 'yeni_kullanici_isle')
and routine_schema = 'public'
order by routine_name, grantee;
