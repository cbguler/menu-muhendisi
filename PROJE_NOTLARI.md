# MENÜ MÜHENDİSİ — PROJE NOTLARI

## Proje Özeti
- **Ad:** Menü Mühendisi
- **Domain:** menumuhendisi.com (satın alınıyor; .com.tr için karar kesinleşmedi)
- **Amaç:** Restoran/cafe işletmeleri için reçete maliyeti, kâr marjı ve Boston Matrisi
  (Yıldız / Bulmaca / Atlı / Köpek) analizi sunan çoklu-kiracı SaaS.
- **Model:** Abonelik (deneme → temel → pro → kurumsal). Lansman ücretsiz denemeyle
  yapılacak; ödeme altyapısı hazır ama başlangıçta devre dışı.

## Kalıcı Proje Kuralları
1. Yapılan HER değişiklik/karar bu dosyaya kaydedilir — TrendSurf Optima ile aynı disiplin.
   Yeni bir sohbette devam ederken önce bu dosya okunmalı.
2. Streamlit **çoklu-sayfa** yapısı kullanılır (`pages/` klasörü) — TrendSurf'ün
   tek-dosya (`app.py`) kuralından bilinçli bir sapma; auth + abonelik kilitleme
   için çoklu-sayfa daha uygun.
3. Tüm SQL tablo/alan adları Türkçe.
4. Şema, ödeme sağlayıcısından bağımsız tasarlandı (`odeme_saglayici` serbest metin
   alanı) — sağlayıcı değişse şema değişmiyor. Nitekim iyzico → PayTR geçişinde
   şemaya dokunulmadı, sadece constraint'e yeni değer eklendi.
5. Kullanıcılar `abonelikler` / `odeme_gecmisi` tablolarına DOĞRUDAN YAZAMAZ —
   yazma yalnızca Supabase Edge Function'ın `service_role` anahtarıyla yapılır.
6. Ticari/vergi kaydı (şirket kurma, PayTR üye işyeri hesabı, vergi dairesi) **en sona
   bırakıldı** — önce ürün + deneme kullanıcılarıyla doğrulama yapılacak.

## Teknoloji Yığını
| Katman | Seçim |
|---|---|
| UI | Streamlit (başlangıçta Community Cloud, ücretsiz) |
| Backend | Supabase (Postgres + Auth + Edge Functions) |
| Ödeme (ileride) | PayTR (birincil) + LemonSqueezy (yedek/global) |
| Landing page | WordPress — WP Small hosting (musenstyle.com'dan taşınıyor) |
| Barındırma | hosting.com.tr paneli (mevcut hesap) |

## Oturum Geçmişi

### 30 Temmuz 2026 — I. Oturum: Veri Temeli + Mimari
- **kaynak_duzeltilmis_v2.xlsx** (337 malzeme):
  - Önceki oturumdan gelen dosyada ISI İLETKENLİĞİ / YÜZEY ALANI / NOT sütunları
    birbirine kaymıştı. `cafe_business_plan.xlsx`'teki orijinal veriyle çapraz
    kontrol edilerek 220 kalem ground-truth'tan, 84 kalem ters-kaydırma mantığıyla
    düzeltildi.
  - 24 yeni malzeme eklendi (menüde geçip kaynakta olmayanlar: Mezgit, Rokfor,
    Trüf yağı, Ketçap, Mayonez, Sezar sos, Basmati/Siyah pirinç, Edamame, vb.).
  - 14 AB alerjeni için sütun eklendi, 337 malzemenin tamamı işaretlendi.
  - ALIM FİYATI sütunu tamamen yeniden araştırıldı (web araması, Temmuz 2026
    Türkiye piyasa fiyatları, EUR/TRY≈54) — önceki değerler ısı iletkenliği
    kayması yüzünden anlamsızdı (ör. zeytinyağı 0,17€/lt → 4,49€/lt düzeltildi).
- **menu_muhendisligi_schema.sql**: Çoklu-kiracı Postgres şeması —
  `isletmeler`, `malzemeler` (global + işletmeye özel katalog), `alerjenler`,
  `malzeme_fiyat_gecmisi` (işletme+zaman bazlı fiyat geçmişi), `receteler`,
  `recete_malzemeleri`, `menu_ogeleri`, `satislar`, `menu_analiz` (Boston
  Matrisi) + canlı maliyet/kârlılık view'ları (`recete_guncel_maliyet`,
  `menu_ogesi_karlilik`). RLS her tabloda aktif, `auth_isletme_id()` helper
  fonksiyonuyla izole.
- **abonelik_ve_odeme_altyapisi.sql**: `abonelik_planlari` (deneme/temel/pro/
  kurumsal), `abonelikler`, `odeme_gecmisi`, `webhook_olaylari` (idempotent
  webhook işleme).
- **supabase/functions/odeme-webhook/index.ts**: PayTR (hash doğrulama gerçek
  ve çalışır durumda: `base64(HMAC-SHA256(merchant_oid+salt+status+tutar))`)
  + LemonSqueezy (HMAC-SHA256 imza doğrulama çalışır durumda) webhook alıcısı.
  **TODO:** PayTR'nin abonelik-özel event alan adları (`paytrNormallestir`
  içinde) canlıya geçmeden önce güncel PayTR dokümantasyonuyla teyit edilmeli.
- **app.py + pages/3_Boston_Matrisi.py**: Supabase Auth ile giriş/kayıt, kayıt
  olunca otomatik 14 günlük deneme aboneliği, plan bazlı özellik kilitleme
  örneği.
- **Karar:** Ödeme sağlayıcı iyzico'dan **PayTR**'ye değiştirildi (kullanıcı
  tercihi).
- **Karar:** Şirket kaydı yerine başlangıçta Mustafa'nın şirketi **Odora
  Kozmetik** kullanılması düşünülüyor — Mustafa ile henüz konuşulmadı,
  netleşmedi. Netleştiğinde: (a) Odora Kozmetik'e yazılım/SaaS faaliyet kodu
  eklenmesi gerekebilir, (b) gelir paylaşımı için yazılı anlaşma önerildi.
- **Karar:** Domain **menumuhendisi.com** alınıyor. musenstyle.com'un WP Small
  hosting'i bu domain için serbest bırakılıp landing page'e çevrilecek.
- **Karar:** Abonelik/ödeme/şirket kaydı işleri **en sona bırakıldı** — önce
  deneme sürümüyle ürün doğrulaması yapılacak. Mevcut şema buna zaten uygun
  (`deneme` durumu `odeme_saglayici` alanını boş bırakabiliyor).

## Dosya Envanteri
| Dosya | İçerik |
|---|---|
| `kaynak_duzeltilmis_v2.xlsx` | Malzeme kataloğu (337 kalem) |
| `menu_muhendisligi_schema.sql` | Ana veritabanı şeması |
| `abonelik_ve_odeme_altyapisi.sql` | Abonelik/ödeme tabloları |
| `migration_paytr_ekle.sql` | PayTR'yi `odeme_saglayici` constraint'ine ekleyen migration |
| `supabase/functions/odeme-webhook/index.ts` | Webhook alıcı (PayTR + LemonSqueezy) |
| `app.py` | Streamlit ana giriş (auth + abonelik kontrolü) |
| `pages/3_Boston_Matrisi.py` | Özellik kilitleme örneği |

## Sıradaki Adımlar (Kuyruk)
1. Streamlit uygulamasını Community Cloud'a deploy et, gerçek URL al (kod hazır, deploy birlikte yapılıyor).
2. WordPress landing page içeriği (menumuhendisi.com).
3. Domain'i WP Small hosting'e bağlama (musenstyle.com'dan ayırma).
4. **[ERTELENDİ]** Mustafa ile Odora Kozmetik görüşmesi, PayTR üye işyeri
   hesabı, vergi dairesi kaydı.

### 30 Temmuz 2026 — II. Oturum: Canlı Kurulum (GitHub + Supabase)
- GitHub deposu oluşturuldu: `cbguler/menu-muhendisi` (**private** — TrendSurf'ten
  farklı olarak, orada public seçimi ücretsiz sınırsız Actions içindi, burada
  henüz Actions kullanılmıyor ve ticari ürün olacağı için kod gizli tutuldu).
  İlk push'ta remote URL placeholder ("KULLANICI_ADIN") olarak kalmıştı,
  `git remote set-url` ile düzeltildi.
- Supabase projesi oluşturuldu: `menu-muhendisi`, Personal org, Free plan,
  Frankfurt (eu-central-1) bölgesi, "Enable automatic RLS" işaretlendi.
- `01_menu_muhendisligi_schema.sql` ve `02_abonelik_ve_odeme_altyapisi.sql`
  SQL Editor'de başarıyla çalıştırıldı. Table Editor'de 17 tablo + 4 view
  doğrulandı.
- **KRİTİK GÜVENLİK BULGUSU:** Table Editor'de 4 view (`malzeme_guncel_fiyat`,
  `recete_guncel_maliyet`, `menu_ogesi_karlilik`, `isletme_aktif_abonelik`)
  "UNRESTRICTED" etiketiyle işaretliydi. Sebep: Postgres'te view'ler
  varsayılan olarak OLUŞTURAN rolün (Supabase'de `postgres` superuser)
  yetkileriyle çalışır, sorguyu yapanın değil — superuser RLS'yi atladığı
  için bu 4 view düzeltilmeden herhangi bir işletmenin maliyet/kâr
  marjı/abonelik verisini TÜM işletmeler için ifşa edebilirdi.
  **`sql/03_view_guvenlik_duzeltmesi.sql`** eklendi: her 4 view'e
  `security_invoker = on` ayarı verildi, RLS artık sorguyu yapan kullanıcının
  rolü üzerinden doğru şekilde uygulanıyor. Bu dosya da SQL Editor'de
  çalıştırılmalı (01/02'den sonra, tek seferlik).
- **KRİTİK BUG:** İlk giriş denemesinde `postgrest.exceptions.APIError: stack
  depth limit exceeded` hatası alındı. Sebep: `auth_isletme_id()` fonksiyonu
  `kullanicilar` tablosunu sorguluyor, ama `kullanicilar`'ın RLS politikası da
  bu fonksiyonu çağırıyor — SECURITY INVOKER (varsayılan) olduğu için iç
  sorgu da RLS'e tabi oluyor ve sonsuz döngüye giriyordu.
  **`sql/04_auth_isletme_id_duzeltmesi.sql`** eklendi: fonksiyon `SECURITY
  DEFINER` + sabit `search_path` ile yeniden tanımlandı, böylece iç sorgu
  RLS'i atlıyor ve döngü kırılıyor. Bu dosya da SQL Editor'de çalıştırılmalı.
- **KRİTİK BUG:** Döngü düzeltildikten sonra girişte `PGRST116: Cannot
  coerce... The result contains 0 rows` hatası alındı. Sebep: `app.py`'deki
  kayıt mantığı, `isletmeler`/`kullanicilar`/`abonelikler` satırlarını
  oluşturmak için `sign_up()` sonrası bir oturum (session) varlığına
  güveniyordu — e-posta doğrulaması zorunlu olduğunda Supabase doğrulama
  tamamlanana kadar oturum döndürmüyor, bu yüzden kayıt satırları hiç
  oluşmuyordu.
  **Mimari düzeltme (daha sağlam):** İş, client'tan veritabanı
  tetikleyicisine taşındı. **`sql/05_kullanici_kayit_tetikleyicisi.sql`**
  eklendi: `auth.users` tablosuna her yeni kayıt girdiğinde (oturum olsun
  olmasın) `isletmeler`+`kullanicilar`+`abonelikler` (deneme) satırları
  otomatik oluşuyor. `app.py`'deki `hesap_olustur()` sadeleşti — artık
  sadece işletme adını kullanıcı metadata'sı olarak gönderiyor, tetikleyici
  gerisini hallediyor.
  **Not:** Bu düzeltmeden önce oluşturulan test hesabı (`bahriguler@gmail.com`,
  "ev" işletmesi) yarım kalmış durumda — Authentication → Users'tan silinip
  yeniden kayıt olunmalı.

### 30 Temmuz 2026 — I. Oturum (devam): Reçete/Menü CRUD Ekranları
- **db.py** (yeni, ortak modül): `get_supabase()` ve `oturumu_uygula()` buraya
  taşındı — her sayfa artık `from db import get_supabase, oturumu_uygula`
  ile aynı istemciyi paylaşıyor (önceden app.py içinde tanımlıydı, tekrar
  eden/tutarsız cache riski vardı).
- **app.py güncellendi**: `get_supabase` içe aktarımı `db.py`'den yapılacak
  şekilde değişti. Ayrıca `st.session_state.recete_limiti` ve `.sube_limiti`
  eklendi (önceden sadece `ozellikler` jsonb'si taşınıyordu, plan limitleri
  ayrı sütun olduğu için sayfalarda erişilemiyordu).
- **pages/1_Receteler.py** (yeni): Reçete oluşturma/silme, reçeteye malzeme
  ekleme/çıkarma (global + işletmeye özel `malzemeler` kataloğundan seçim),
  `recete_guncel_maliyet` view'inden canlı porsiyon maliyeti + kalori
  gösterimi. Plan `recete_limiti`'ne ulaşılınca ekleme formu kapanıp
  yükseltme linki gösteriliyor.
- **pages/2_Menu.py** (yeni): Reçeteyi menüye ürün olarak ekleme, satış
  fiyatı atama, `menu_ogesi_karlilik` view'inden canlı kâr marjı (€ ve %)
  gösterimi, aktif/pasif toggle, silme.
- **pages/3_Boston_Matrisi.py güncellendi**: Diğer sayfalarla tutarlı olsun
  diye `db.py` kullanacak şekilde küçük bir refactor yapıldı (davranış
  değişmedi).
- **requirements.txt** (yeni): `streamlit>=1.38`, `supabase>=2.6`.
- Sıradaki adımlara "Reçete/menü CRUD" maddesi bu oturumda tamamlandığı için
  kuyruktan çıkarıldı.
