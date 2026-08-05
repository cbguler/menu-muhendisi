# MENÜ MÜHENDİSİ — PROJE NOTLARI

## Proje Özeti
- **Ad:** Menü Mühendisi
- **Domain:** menumuhendisi.com (satın alınıyor; .com.tr için karar kesinleşmedi)
- **Amaç:** İki iç içe geçmiş hedef:
  1. **Yıllık menü üretim motoru** (asıl motivasyon): mevsimsel, dengeli,
     anayasaya (aşağıda) uygun bir yıllık öğle/akşam yemek matrisi üretmek.
  2. **Restoran/cafe menü mühendisliği SaaS'ı**: reçete maliyeti, kâr marjı
     ve Boston Matrisi analizi sunan çoklu-kiracı ticari ürün.
  İkisi de aynı temel veriyi (malzeme kataloğu, beslenme değerleri,
  alerjenler, mevsimsellik) paylaşıyor.
- **Model:** Abonelik (deneme → temel → pro → kurumsal). Lansman ücretsiz
  denemeyle yapılacak; ödeme altyapısı hazır ama başlangıçta devre dışı.

## Kalıcı Proje Kuralları
1. Yapılan HER değişiklik/karar bu dosyaya kaydedilir — TrendSurf Optima ile
   aynı disiplin. Yeni bir sohbette devam ederken önce bu dosya okunmalı.
2. Streamlit **çoklu-sayfa** yapısı kullanılır (`pages/` klasörü) —
   TrendSurf'ün tek-dosya (`app.py`) kuralından bilinçli bir sapma; auth +
   abonelik kilitleme için çoklu-sayfa daha uygun.
3. Tüm SQL tablo/alan adları Türkçe.
4. Şema, ödeme sağlayıcısından bağımsız tasarlandı (`odeme_saglayici` serbest
   metin alanı) — sağlayıcı değişse şema değişmiyor.
5. Kullanıcılar `abonelikler` / `odeme_gecmisi` tablolarına DOĞRUDAN YAZAMAZ —
   yazma yalnızca Supabase Edge Function'ın `service_role` anahtarıyla yapılır.
6. Ticari/vergi kaydı (şirket kurma, PayTR üye işyeri hesabı, vergi dairesi)
   **en sona bırakıldı** — önce ürün + deneme kullanıcılarıyla doğrulama
   yapılacak.
7. Yeni/değişen dosya olduğunda Claude, kullanıcının çalıştırması için tam
   `git add / commit / push` komutlarını HER ZAMAN otomatik verir —
   kullanıcı ayrıca istemek zorunda kalmaz.
8. **UI'da emoji ve widget kullanımı KESİNLİKLE YASAK** (3 Ağustos 2026,
   Bahri'nin açık talebiyle — TrendSurf Optima'daki aynı kalıcı kuralın
   buraya da uygulanması). Buton etiketleri, başlıklar, caption'lar,
   hiçbir görünür metinde emoji ya da gereksiz widget olmayacak.

## Teknoloji Yığını
| Katman | Seçim |
|---|---|
| UI | Streamlit (başlangıçta Community Cloud, ücretsiz) |
| Backend | Supabase (Postgres + Auth + Edge Functions) |
| Ödeme (ileride) | PayTR (birincil) + LemonSqueezy (yedek/global) |
| Landing page | WordPress — WP Small hosting (musenstyle.com'dan taşınıyor) |
| Barındırma | hosting.com.tr paneli (mevcut hesap) |

## Yıllık Menü Anayasası — Türk Mutfağı (v3)
**Not (30 Temmuz 2026):** Bu anayasa özellikle **Türk Mutfağı** için
geçerlidir (`mutfaklar` tablosunda `kod='turk'`). İleride eklenecek her
mutfak (Fransız, fast-food vb.) kendi kategori şemasını ve kendi
uyumsuzluk/tamamlayıcı kurallarını tanımlayacak — bu 13 madde otomatik
olarak diğer mutfaklara uygulanmaz.
1. Günde iki öğün: öğle ve akşam yemeği menüleri olmalıdır.
2. Aynı hafta içinde bir yemek çeşidi tekrarlanmaz; ardışık günlerde aynı
   ana malzeme tekrar etmez.
3. Mevsimsel ürün/malzeme kullanılır (sebze-meyve takvimi, balık mevsim
   skoru, yasal av yasağı türleri otomatik dışlanır).
4. Kalori hesabı yapılır; günlük toplam hedef aralıkta, öğle/akşam
   arasındaki fark dengeli olmalı.
5. Kişiselleştirme: Kalori/Protein/Yağ/KH/Glisemik İndeks kısıtlamaları +
   malzeme bazlı istisna (alerji/sevmeme). Ayarlanmazsa yaş/cinsiyete göre
   otomatik hesap.
6. Malzemelerdeki alerjenler belirtilir.
7. Öğle daha enerji verici, akşam tok tutan ama hafif olmalı.
8. Haftalık dengeli dağılım: sebze/kırmızı et/beyaz et/balık; her öğün
   I. Grup (et/tavuk/balık/etli sebze/kuru baklagil/yumurta) + II. Grup
   (çorba/pilav/zeytinyağlı/makarna/börek) + III. Grup (salata/tatlı/
   komposto/yoğurt/cacık/turşu) içerir.
9. Mevsim meyveleri kalori/besin değeri hesaba katılarak dahil edilir.
10. Kalori uygun olduğunda meyve yerine uygun tatlı konulabilir.
11. Uyumsuzluk kuralları: zeytinyağlı sebze + etli sebze/dolma yasak;
    pilav/makarna/börek + tatlı yasak (sporcu istisna); zeytinyağlı +
    salata yasak; etli/zeytinyağlı dolma + pilav/makarna yasak; aynı öğünde
    hepsi sert/yumuşak veya hepsi sıvı/katı olmaz; renk/tat çeşitliliği.
12. Standart porsiyon gramajları referans alınır (kırmızı et 50-120g,
    tavuk 100-250g, sebze/meyve 200g, pilav/makarna çiğ 50g, yoğurt 200g vb).
13. **Tamamlayıcı Eşleştirme** (30 Temmuz 2026 eklendi): Ana yemek/II. grup
    seçimi, niteliğine göre bir III. grup tamamlayıcıyla desteklenir:
    - Dolma/sarma (etli veya zeytinyağlı) → **yoğurt**
    - Etli/köfte ızgara → **salata veya turşu**
    - Kuru baklagil (nohut, kuru fasulye vb.) → **turşu veya salata**
    - Balık → **salata**
    - Zeytinyağlı sebze → madde 11 gereği salata almaz, ekmek yeterli.
    Bu eşleştirme madde 11'deki uyumsuzluk kurallarıyla çelişmez;
    uyumsuzluk kuralı her zaman önceliklidir.

## Dosya Envanteri
| Dosya | İçerik |
|---|---|
| `kaynak_duzeltilmis_v2.xlsx` | Malzeme kataloğu (337 kalem) |
| `sql/01_menu_muhendisligi_schema.sql` | Ana veritabanı şeması |
| `sql/02_abonelik_ve_odeme_altyapisi.sql` | Abonelik/ödeme tabloları |
| `sql/03_view_guvenlik_duzeltmesi.sql` | View RLS bypass düzeltmesi |
| `sql/04_auth_isletme_id_duzeltmesi.sql` | RLS sonsuz döngü düzeltmesi |
| `sql/05_kullanici_kayit_tetikleyicisi.sql` | Kayıt trigger'ı |
| `sql/06_eksik_kullanicilari_tamamla.sql` | Geriye dönük kullanıcı tamamlama |
| `sql/07_varsayilan_fiyat.sql` | Varsayılan fiyat sütunu + trigger güncelleme |
| `sql/08_fiyat_gecmisini_geriye_donuk_doldur.sql` | Geriye dönük fiyat doldurma |
| `sql/migration_paytr_ekle.sql` | PayTR'yi `odeme_saglayici`'ye ekleyen migration |
| `supabase/functions/odeme-webhook/index.ts` | Webhook alıcı (PayTR + LemonSqueezy) |
| `app.py` | Streamlit ana giriş (auth + abonelik + "beni hatırla") |
| `db.py` | Ortak Supabase istemcisi |
| `pages/1_Receteler.py` | Reçete CRUD + canlı maliyet |
| `pages/2_Menu.py` | Menü ögesi CRUD + canlı kâr marjı |
| `pages/3_Boston_Matrisi.py` | Özellik kilitleme örneği |
| `yukle_malzemeler.py` | Malzeme kataloğu ETL scripti |
| `requirements.txt` | `streamlit`, `supabase`, `streamlit-cookies-manager` |
| `sql/12_tarif_kutuphanesi_global_receteler.sql` | `receteler` global tarif desteği + eksik SALATALIK kalemi |
| `tarif_verisi.py` | 74 tariflik Türk mutfağı başlangıç kütüphanesi (veri) |
| `yukle_tarifler.py` | Tarif kütüphanesi ETL scripti (global `receteler` + `recete_malzemeleri`) |
| `uretim_algoritmasi.py` | Yıllık menü üretim motoru — anayasa madde 8/11/13 kural motoru (veri kaynağından bağımsız) |
| `pages/5_Yillik_Menu.py` | Yıllık menü motoru UI (ilk sürüm) — Supabase'ten global tarifleri okuyup örnek haftalık menü üretir |
| `wake_app.py` | Streamlit uyku sorunu için Playwright tabanlı uyandırma scripti (TrendSurf Optima'dan uyarlandı) |
| `.github/workflows/uygulamayi_uyandir.yml` | `wake_app.py`'yi 3 saatte bir çalıştıran GitHub Actions workflow'u |
| `assets/favicon.png`, `logo.png`, `logo_icon.png`, `favicon.ico`, `apple-touch-icon.png` | Logo/favicon varlıkları (kaynak: kullanıcının `logo.png`'si, siyah arka plan şeffaflaştırıldı) |

## Oturum Geçmişi

### 30 Temmuz 2026 — I. Oturum: Veri Temeli + Mimari
- **kaynak_duzeltilmis_v2.xlsx** (337 malzeme): önceki oturumdan gelen
  dosyada ISI İLETKENLİĞİ/YÜZEY ALANI/NOT sütunları birbirine kaymıştı;
  `cafe_business_plan.xlsx`'teki orijinal veriyle çapraz kontrol edilerek
  220 kalem ground-truth'tan, 84 kalem ters-kaydırma mantığıyla düzeltildi.
  24 yeni malzeme eklendi. 14 AB alerjeni için sütun eklendi. ALIM FİYATI
  sütunu web araştırmasıyla (Temmuz 2026, EUR/TRY≈54) tamamen yeniden
  belirlendi.
- **menu_muhendisligi_schema.sql**: Çoklu-kiracı Postgres şeması —
  `isletmeler`, `malzemeler`, `alerjenler`, `malzeme_fiyat_gecmisi`,
  `receteler`, `recete_malzemeleri`, `menu_ogeleri`, `satislar`,
  `menu_analiz` + canlı maliyet/kârlılık view'ları. RLS her tabloda aktif.
- **abonelik_ve_odeme_altyapisi.sql**: `abonelik_planlari`, `abonelikler`,
  `odeme_gecmisi`, `webhook_olaylari` (idempotent webhook işleme).
- **supabase/functions/odeme-webhook/index.ts**: PayTR (hash doğrulama
  çalışır durumda) + LemonSqueezy (imza doğrulama çalışır durumda).
  TODO: PayTR abonelik-özel event alanları teyit edilmeli.
- **app.py + pages/3_Boston_Matrisi.py**: Supabase Auth giriş/kayıt, 14
  günlük deneme aboneliği, plan bazlı özellik kilitleme.
- **db.py + pages/1_Receteler.py + pages/2_Menu.py** (yeni): Reçete/menü
  CRUD ekranları, canlı maliyet/kâr marjı view'lardan okunuyor. `app.py`'ye
  `recete_limiti`/`sube_limiti` session state eklendi.
- **Kararlar:** Ödeme sağlayıcı PayTR (iyzico'dan değişti). Şirket kaydı
  yerine başlangıçta Mustafa'nın **Odora Kozmetik** şirketi düşünülüyor
  (henüz konuşulmadı). Domain **menumuhendisi.com**; musenstyle.com'un WP
  Small hosting'i landing page'e çevrilecek. Abonelik/ödeme/şirket kaydı
  en sona bırakıldı.

### 30 Temmuz 2026 — II. Oturum: Canlı Kurulum (GitHub + Supabase)
- GitHub deposu: `cbguler/menu-muhendisi` (**private** — TrendSurf'ten
  farklı olarak, burada henüz Actions kullanılmadığı ve ticari ürün
  olacağı için kod gizli tutuldu).
- Supabase projesi: `menu-muhendisi`, Personal org, Free plan, Frankfurt
  (eu-central-1), "Enable automatic RLS" işaretlendi.
- `01` ve `02` SQL dosyaları çalıştırıldı, 17 tablo + 4 view doğrulandı.
- **KRİTİK GÜVENLİK BULGUSU:** 4 view "UNRESTRICTED" işaretliydi — Postgres'te
  view'ler OLUŞTURAN rolün (superuser) yetkisiyle çalışır, RLS'yi atlar.
  **`03_view_guvenlik_duzeltmesi.sql`**: `security_invoker = on` ile düzeltildi.
- **KRİTİK BUG:** `stack depth limit exceeded` — `auth_isletme_id()`
  fonksiyonu `kullanicilar`'ı sorguluyor, `kullanicilar`'ın RLS'i de bu
  fonksiyonu çağırıyor, sonsuz döngü. **`04_auth_isletme_id_duzeltmesi.sql`**:
  fonksiyon `SECURITY DEFINER` yapıldı.
- **KRİTİK BUG:** `PGRST116: 0 rows` — kayıt mantığı `sign_up()` sonrası
  oturum varlığına güveniyordu, e-posta doğrulaması zorunluyken oturum
  dönmüyor. **Mimari düzeltme:** `05_kullanici_kayit_tetikleyicisi.sql` —
  `auth.users` trigger'ı ile işletme/kullanıcı/abonelik otomatik oluşuyor,
  client'tan bağımsız. `app.py`'deki `hesap_olustur()` sadeleşti.
- **`06_eksik_kullanicilari_tamamla.sql`**: trigger'dan önce oluşmuş/yarım
  kalmış hesapları geriye dönük tamamlayan script.
- **"Beni Hatırla"**: `streamlit-cookies-manager` eklendi, `EncryptedCookieManager`
  ile refresh_token şifreli çerezde saklanıyor, `COOKIE_SIFRESI` secret'ı
  eklendi. Çıkışta çerez temizleniyor.
- **Eksik adım:** `malzemeler` tablosu boştu, 337 kalem hiç yüklenmemişti.
  **`07_varsayilan_fiyat.sql`**: `varsayilan_fiyat_eur` sütunu + trigger
  güncellemesi (yeni işletme kayıt olunca varsayılan fiyatlar otomatik
  kopyalanır). **`yukle_malzemeler.py`**: ETL scripti, 337 malzeme + 141
  alerjen ilişkisi başarıyla yüklendi.
- **İlk uçtan uca test:** Kayıt → giriş → reçete oluşturma → malzeme ekleme
  çalıştı (kalori doğru: 3858 kcal). **KRİTİK BUG:** `.maybe_single()`
  0 satırda `None` dönüp `AttributeError` verdi (`pages/1_Receteler.py` VE
  `app.py`'deki abonelik sorgusu — bu ikincisi çok daha kritikti, tüm giriş
  akışını kilitleyebilirdi). Düzeltme: düz `.execute()` + `data[0] if data
  else None` deseni.
- **Maliyet 0,00 € sorunu:** Test hesabı `06` ile geriye dönük oluşturulduğu
  için hiç fiyat almamıştı (fiyat kopyalama sadece trigger üzerinden,
  yeni kayıtlarda çalışıyor). **`08_fiyat_gecmisini_geriye_donuk_doldur.sql`**:
  fiyat geçmişi boş olan her işletmeyi geriye dönük doldurur.
- Deploy adımına geçilirken (Streamlit Community Cloud) öncelik değişikliği
  yaşandı — bkz. aşağıdaki not.

## ÖNCELİK DEĞİŞİKLİĞİ (30 Temmuz 2026)
Ticari SaaS altyapısı bir kenara bırakılmadı ama öncelik **yıllık menü
üretim motoruna** kaydı — bu, projenin en başındaki asıl motivasyondu ve
henüz hiç yazılmadı. Mevcut `receteler`/`menu_ogeleri` şeması restoran
maliyet/kâr analizi için kurulmuştu; yıllık menü üretimi ayrı bir veri
modeli genişlemesi gerektiriyor (yemek grubu I/II/III, uyumsuzluk/
tamamlayıcı etiketleri, kişisel beslenme profili, menü takvimi tablosu).

## Sıradaki Adımlar (Kuyruk)
1. **[TAMAMLANDI — bkz. VI. Oturum]** ~~Üretim algoritması ilk sürümü~~ →
   `uretim_algoritmasi.py` + `pages/5_Yillik_Menu.py` teslim edildi,
   gerçek Supabase verisiyle çalışıyor. **Sıradaki alt-adım:** kişisel
   beslenme profili filtrelemesi (`kisisel_beslenme_profilleri` tablosu
   — alerjen/kısıtlama), üretilen menüyü `menu_takvimi`/
   `menu_takvimi_ogeleri`'ne kaydetme, ve `4_Uretim_Asamalari.py` ile
   isim karışıklığını önlemek için sayfa başlıklarının netliğini gözden
   geçirmek.
2. Streamlit uygulamasını Community Cloud'a deploy et — deploy tamamlandı
   (menu-muhendisi.streamlit.app canlı); **açık soru:** sol menüde
   "Uretim Asamalari" sayfası görünüyor mu, görünmüyorsa önce
   `10_uretim_maliyet_semasi.sql`/`4_Uretim_Asamalari.py`'nin GitHub'a
   push edilip edilmediği kontrol edilmeli (reboot bunu çözmeyebilir).
3. WordPress landing page içeriği (menumuhendisi.com).
4. Domain'i WP Small hosting'e bağlama (musenstyle.com'dan ayırma).
5. **[ERTELENDİ]** Mustafa ile Odora Kozmetik görüşmesi, PayTR üye işyeri
   hesabı, vergi dairesi kaydı.

### 30 Temmuz 2026 — III. Oturum: Üretim Maliyeti (Isıl İşlem + İşçilik + Genel Gider)
- `cafe_business_plan.xlsx`'teki "8-blok ısıl işlem" mantığı reçete modülüne
  taşındı. Kullanıcının dört gereksinimi:
  1. **Isıl işlem maliyeti**: `asama_enerji_maliyeti` view'i, duyulur ısı
     formülüyle (Q = m·c·ΔT, malzemelerin `ozgul_isi` alanı kullanılarak)
     enerji (kWh) ve maliyet hesaplıyor. `verimlilik_orani` ısı kaybını
     modelliyor.
  2. **İşçilik maliyeti**: `asama_iscilik_maliyeti` view'i, aşama süresi ×
     saat ücreti.
  3. **Paralel işler**: `asama_bagimliliklari` tablosuyla DAG kuruluyor.
     Genel bir DAG'de (özellikle "elmas" bağımlılık durumunda) doğru kritik
     yol hesabı SQL'de kırılgan olduğu için **`uretim_hesap.py`**'de Python
     tarafında (Kahn topolojik sıralama + dinamik programlama) yapılıyor —
     iki senaryoyla (elmas bağımlılık, paralel dal) test edildi, ikisi de
     doğru sonuç verdi.
  4. **Genel gider payı**: `isletme_maliyet_ayarlari` (elektrik/doğalgaz
     birim fiyatı, personel saat ücreti, genel gider yüzdesi) +
     `recete_uretim_maliyeti` view'i tüm bileşenleri (malzeme+enerji+
     işçilik) toplayıp genel gider yüzdesini ekleyerek porsiyon başı
     gerçek maliyeti veriyor.
- **`sql/10_uretim_maliyet_semasi.sql`**: `isletme_maliyet_ayarlari`,
  `recete_asamalari`, `asama_malzemeleri`, `asama_bagimliliklari` tabloları
  + 3 view. Yeni view'lara da `security_invoker=on` uygulandı (03'teki
  gerekçeyle aynı).
- **`pages/4_Uretim_Asamalari.py`** (yeni): Aşama ekleme/silme (malzeme +
  bağımlılık seçimiyle), kritik yol gösterimi, tam maliyet dökümü.
- Ayrıca bu oturumda **öncelik değişikliği** yaşandı: deploy adımı
  yarım bırakılıp yıllık menü üretim motoruna (anayasa madde 13 eklendi)
  ve tarif kütüphanesi planlamasına dönüldü — bkz. yukarıdaki "ÖNCELİK
  DEĞİŞİKLİĞİ" notu. 74 tariflik başlangıç seti (I/II/III grup dengeli,
  mevsimsel dağılım) önerildi, onay bekleniyor; onaylanınca veri girişi
  + yükleme scripti hazırlanacak.

### 30 Temmuz 2026 — III. Oturum (devam): Çoklu Mutfak Mimarisi
- **İleriye dönük gereksinim:** Uygulama sadece Türk mutfağıyla kalmayacak
  — kullanıcı ileride Fransız mutfağı, fast-food vb. seçebilmeli, menü
  yapısı ve tüm sistem seçilen mutfağa göre yeniden şekillenmeli, malzeme
  listeleri mutfağa göre genişleyebilmeli.
- **`sql/11_coklu_mutfak_capraz_kesim.sql`** eklendi:
  - `mutfaklar` (kod/ad) ve `mutfak_kategorileri` (her mutfağın kendi
    yemek sınıflandırması — Türk için I/II/III Grup, ileride Fransız için
    Entrée/Plat/Dessert vb.) tabloları.
  - `receteler.yemek_grubu` (sabit 1/2/3) → `receteler.mutfak_kategori_id`
    (esnek, mutfağa göre değişir) — 09 daha önce çalıştırılmışsa mevcut
    veriyi Türk mutfağı varsayımıyla otomatik taşıyıp eski sütunu kaldırır.
  - `uyumsuzluk_kurallari` ve `tamamlayici_eslestirme` artık `mutfak_id`
    ile kapsamlandırılıyor (Türk mutfağına özel kurallar başka mutfaklara
    sızmaz).
  - `menu_takvimi`'ye `mutfak_id` eklendi (takvim hangi mutfak için
    üretildi).
  - `mutfak_malzeme`: malzeme-mutfak ilişkisi **kısıtlayıcı değil,
    bilgilendirici** (bir malzeme birden fazla mutfakta ortak kullanılabilir).
    Mevcut 337 malzemenin tamamı başlangıçta Türk mutfağına bağlandı.
  - Anayasa dokümanına not eklendi: 13 madde özellikle Türk Mutfağı için
    geçerli, yeni mutfaklar kendi kural setini tanımlayacak.

### 1 Ağustos 2026 — IV. Oturum: 74 Tariflik Türk Mutfağı Kütüphanesi
- **Mimari karar:** `receteler` tablosu şimdiye kadar sadece isletme'ye
  özel (isletme_id NOT NULL) tasarlanmıştı; yıllık menü motorunun ortak
  tarif kütüphanesi için bu yeterli değildi. `malzemeler` tablosundaki
  "isletme_id NULL = global katalog" deseni `receteler`'a da uygulandı
  (`12_tarif_kutuphanesi_global_receteler.sql`): `isletme_id` nullable
  yapıldı, global/özel için ayrı unique index'ler eklendi, RLS
  `for all` politikası SELECT (global+kendi) / INSERT-UPDATE-DELETE
  (sadece kendi) olarak ayrıştırıldı — aynı ayrıştırma
  `recete_malzemeleri` için de yapıldı. **Etkisi yok:**
  `pages/1_Receteler.py` zaten `.eq("isletme_id", isletme_id)` ile
  sorguluyor, yani mevcut restoran maliyet ekranına global tarifler
  karışmıyor.
- **`receteler.mevsim_etiketi`** (yeni sütun) eklendi — gerçek
  mevsimsellik malzeme bazında zaten var, ama yıllık menü motorunun
  ağır join yapmadan tarif filtreleyebilmesi için kürasyonla belirlenen
  tek bir baskın mevsim etiketi de tutuluyor.
- **Eksik katalog kalemi bulundu:** `kaynak_duzeltilmis_v2.xlsx`'te
  **SALATALIK** (salatalık/cacık ve salatalarda temel malzeme) hiç
  yoktu. Standart referans besin değerleriyle `malzemeler` tablosuna
  eklendi (aynı migration dosyasında, kategori_id=2 SEBZELER).
- **74 tariflik başlangıç seti** tasarlandı ve doğrulandı (`tarif_verisi.py`):
  I. Grup 30 (kırmızı et 6, tavuk 6, balık/deniz ürünü 6, etli sebze/dolma 5,
  kuru baklagil 5, yumurta 2), II. Grup 24 (çorba 6, pilav 5, zeytinyağlı 6,
  makarna 3, börek 4), III. Grup 20 (salata 5, cacık/yoğurt 2, turşu 2,
  komposto 3, tatlı 8). Tüm malzeme adları `kaynak_duzeltilmis_v2.xlsx`
  kataloğuyla programatik olarak çapraz kontrol edildi (SALATALIK hariç
  hepsi zaten katalogda vardı). `porsiyon_sayisi` kütüphane genelinde 1
  (kişi başı günlük plan birimi) sabitlendi.
- **Etiket ayrımı netleştirildi:** `ozel_etiketler` içinde iki tür etiket
  var — kural motorunun kullandığı sabit etiketler (zeytinyagli,
  etli_sebze, etli_zeytinyagli_dolma, dolma, izgara, tursu, kuru_baklagil,
  salata, balik, pilav_makarna_borek, tatli, sporcu_uygun) ve sadece
  sınıflandırma/haftalık denge amaçlı serbest etiketler (kirmizi_et,
  beyaz_et, vejetaryen, corba, pilav, borek, komposto, cacik, yumurta).
  **Önemli detay:** `etli_zeytinyagli_dolma` etiketi hem etli hem
  zeytinyağlı dolma/sarma çeşitlerine birlikte uygulanır (uyumsuzluk
  kuralındaki `etiket_a` adı ikisini birden temsil eder) — sadece
  zeytinyağlı varyanta değil.
- **`yukle_tarifler.py`** (yeni ETL): `mutfaklar`/`mutfak_kategorileri`
  üzerinden Türk mutfağı I/II/III grup id'lerini, `malzemeler` üzerinden
  (isletme_id NULL) malzeme id'lerini çözüp `receteler` + 
  `recete_malzemeleri`'ne global (isletme_id=NULL) olarak yükler. Yükleme
  öncesi tüm malzeme adlarını doğrular, eksik varsa hiçbir satır
  yazmadan durur.
- **Sıradaki alt-adım:** `12_...sql` Supabase'de çalıştırılıp
  `yukle_tarifler.py` çalıştırılınca 74 tarif veritabanında olacak;
  bir sonraki oturumda **üretim algoritması** (haftalık/yıllık takvimi
  anayasa kurallarına göre otomatik dolduran mantık — madde 2, 4, 8, 11,
  13) tasarlanacak.
- **DOĞRULANDI (1 Ağustos 2026):** `12_...sql` çalıştırıldı,
  `yukle_tarifler.py` başarıyla tamamlandı ("74 tarif + malzeme
  ilişkileri yüklendi"), Supabase Table Editor'da teyit edildi. Kod
  GitHub'a push edildi. **Karşılaşılan ve çözülen ortam sorunları**
  (ileride benzer ETL scriptleri için hatırlatma): (1) bu makinede
  `python` komutu bazen gercek kurulum yerine Windows Store'un sahte
  kısayoluna gidiyor — gerçek yol `C:\Users\bahri\AppData\Local\Programs\
  Python\Python312\python.exe` kullanılmalı; (2) konsol varsayılan kod
  sayfası (cp1252) Türkçe karakterleri yazdıramıyor —
  `chcp 65001` + `PYTHONUTF8=1` + `PYTHONIOENCODING=utf-8` gerekli;
  (3) `SUPABASE_URL` ortam değişkenine yanlışlıkla Streamlit uygulama
  adresi (`...streamlit.app`) değil, Supabase **Project URL**'i
  (`...supabase.co`) girilmeli — karışınca `.data` beklenmeyen tipte
  dönüp `TypeError` veriyor.

### 1 Ağustos 2026 — V. Oturum: Favicon + Uygulama Logosu
- Kullanıcı `logo.ai` (Illustrator/PDF, 512×512pt) ve `logo.png` (aslında
  JPEG, 8000×7950, düz siyah arka plan) dosyalarını paylaştı.
- **`logo.ai` render edilemedi:** Poppler/pdftocairo ile açılınca sadece
  düz siyah bir kare geldi, asıl çizim görünmedi — muhtemelen dosya
  "PDF uyumluluğu" (Create PDF Compatible File) işaretlenmeden
  kaydedilmiş, yani PDF katmanında sadece bir arka plan var, gerçek
  vektör verisi Illustrator'a özel kısımda. **Sonuç:** `logo.png`
  (raster) kaynak olarak kullanıldı.
- **Arka plan kaldırma:** `logo.png`'nin arka planı saf siyahtı (0,0,0),
  çizim öğeleri (koyu yeşil çatal/bıçak dahil) belirgin şekilde daha
  açık renkte olduğundan güvenle chroma-key yapılabildi. Parlaklık eşiğine
  göre alfa hesaplanıp siyah arka plan üzerinden "unmultiply" ile gerçek
  renkler geri çıkarıldı (kenarlarda siyah halo kalmadı).
- **Üretilen dosyalar** (`assets/`): `favicon.png` (128px, Streamlit
  `page_icon` için), `logo.png` (512px, `st.logo()` ana görsel),
  `logo_icon.png` (96px, `st.logo()` daraltılmış sidebar ikonu),
  `favicon.ico` (16/32/48/64/128/256 çoklu boyut, ileride WordPress
  landing page için hazır), `apple-touch-icon.png` (180px, beyaz
  arka planlı — iOS şeffaflığı desteklemiyor).
- **Kod değişikliği:** `app.py` + `pages/` altındaki 4 sayfanın hepsine
  `st.set_page_config(..., page_icon="assets/favicon.png")` ve
  `st.logo("assets/logo.png", icon_image="assets/logo_icon.png")`
  eklendi (her sayfa kendi `set_page_config`'ini çağırdığı için hepsine
  ayrı ayrı eklenmesi gerekti — bkz. mimari not: çoklu-sayfa yapısı).

#### V. Oturum (devam): Sidebar Logo İterasyonu
Kullanıcı geri bildirimiyle birkaç turda son hâline ulaşıldı:
- **`st.logo()`'nun sabit boyut kısıtı keşfedildi:** Streamlit bu alanı
  hangi görsel verilirse verilsin sabit (küçük) yükseklikte gösteriyor —
  kaynak dosyanın çözünürlüğü fark etmiyor. Bu yüzden gerçekten büyük bir
  logo için `st.logo()` yerine normal bir sidebar elemanı
  (`st.sidebar.image`) kullanılmasına karar verildi.
- İlk denemede amblem+yazı tek bir görselde birleştirildi (yatay
  "wordmark", sonra dikey düzen) — kullanıcı görsele gömülü metni
  **istemedi**: metin ayrı, gerçek Streamlit metni olarak kalmalı
  (`st.sidebar.markdown`, tema/boyut esnekliği için).
- Yazı tipi/rengi logonun çatal-bıçağıyla eşleşen koyu yeşile
  (`#2C6B3C`, Arial/Helvetica kalın) `unsafe_allow_html=True` ile
  stillendirildi.
- Küçük `st.logo()` ikonu kullanıcı isteğiyle tamamen kaldırıldı (sadece
  favicon/`page_icon` kaldı) — sidebar'da artık tek, büyük bir logo var.
  **Bilinen ödün:** sidebar tamamen daraltıldığında artık hiç ikon
  görünmüyor (st.logo'nun collapsed-state faydası kayboldu).
  Logo+yazı `st.sidebar.columns([1, 5, 1])` ile ortalandı — **ilk
  denemede `[1, 2, 1]` kullanılmıştı, bu orta sütunu görsel genişliğinden
  (`width=190`) daha dar bıraktığı için büyütme hiç etkili olmamıştı**;
  oranı `[1, 5, 1]`'e çıkarıp `width=220` yapınca çözüldü. Bu, ileride
  sidebar'da ortalanmış herhangi bir görsel eklerken akılda tutulacak bir
  tuzak: `st.image(width=N)` istegi, içinde bulunduğu sütun/konteynerden
  geniş olamaz.
- Ayrıca bu oturumda: giriş/kayıt ekranı (`app.py`) `layout="wide"`
  yüzünden tam genişlikte açılan metin kutularına sahipti —
  `st.columns([1, 1.3, 1])` ile ortalanmış dar bir sütuna alındı. Plan/
  deneme bitiş bilgisi iki ayrı renkli kutudan (`st.success`/`st.info`)
  tek satırlık gri `st.caption`'a sadeleştirildi.

### 2 Ağustos 2026 — VI. Oturum: Üretim Algoritması İlk Sürümü + Animasyon Denemesi
- **Animasyonlu logo denemesi:** Kullanıcı TrendSurf'teki animasyonlu
  logo videosunu (`animated_logo.mp4`, beyaz zeminli) sidebar'da denemek
  istedi. `sidebar_logo.py`'ye `animasyonlu` parametresi eklendi (True =
  `mix-blend-mode:multiply` ile base64 gömülü `<video autoplay muted
  loop playsinline>`, False = statik `logo.png`) — kolay geri dönüş için
  bilerek bu şekilde tasarlandı. Kullanıcı beğenmedi, `animasyonlu=False`
  yapılıp `assets/logo_animated.mp4` repodan silindi. `sidebar_logo.py`
  altyapısı (iki seçenek) kalıcı olarak duruyor — ileride başka bir
  animasyonla tekrar denenebilir.
- **Üretim algoritması ilk sürümü** (`uretim_algoritmasi.py`): anayasa
  madde 8 (her öğün I+II+III grup), madde 11 (uyumsuzluk kuralları —
  **hiçbir koşulda gevşetilmez**), madde 13 (tamamlayıcı eşleştirme,
  tercih), mevsimsellik (önce aynı mevsim + yıl_boyunca) kurallarını
  uygulayan haftalık menü üretici. Veri kaynağından bağımsız tasarlandı
  (`tarifler` parametresi alır) — hem yerel test (`tarif_verisi.py`) hem
  gerçek uygulama (Supabase) için aynı modül kullanılabiliyor.
  **Kendi QA kontrolümde bulunan ve düzeltilen hata:** ilk sürümde
  haftalık havuz tükenince (74 tarif sınırlı olduğu için hafta sonlarına
  doğru olabiliyor) devreye giren yedek plan, uyumsuzluk kontrolünü de
  atlıyordu — düzeltildi, artık SADECE haftalık-tekrar kısıtı gevşetiliyor,
  madde 11 asla ihlal edilmiyor (74 tariflik örneklemde 0 ihlal
  doğrulandı; hafta-içi tekrar hâlâ olabiliyor, kütüphane büyüdükçe
  azalacak — bilinen sınırlama).
- **`pages/5_Yillik_Menu.py`** (yeni sayfa — `4_Uretim_Asamalari.py` ile
  KARIŞTIRILMAMALI, o sayfa reçete üretim MALİYETİ/işçilik hesaplıyor,
  bambaşka bir özellik): global tarif kütüphanesini (`receteler` where
  `isletme_id is null`, `mutfak_kategorileri.sira` üzerinden grup)
  Supabase'ten okuyup `uretim_algoritmasi.hafta_olustur`'u çağırıyor,
  mevsim seçimi + üret butonuyla ekranda gösteriyor.
  **Henüz eklenmedi:** kişisel beslenme profili filtrelemesi
  (`kisisel_beslenme_profilleri`), `menu_takvimi`/
  `menu_takvimi_ogeleri`'ne kaydetme — bunlar sıradaki adım.

### 2 Ağustos 2026 — VI. Oturum (devam): Uyku Sorunu + Soğuk Başlangıç Hatası
- **Streamlit uyku sorunu:** Community Cloud, trafiksiz uygulamaları
  **12 saat** sonra uykuya yatırıyor (resmi dokümantasyon). Kullanıcı
  TrendSurf Optima'nın PROJE_NOTLARI.md'sini paylaştı — orada bu sorun
  için iki aşamalı bir geçmiş vardı: (1) v2.0.5.2'de basit bir curl
  keep-alive denenmiş, (2) Temmuz 2026'da bunun ARTIK İŞE YARAMADIĞI
  anlaşılmış çünkü Streamlit artık gerçek bir tarayıcı (JS +
  `/_stcore/stream` WebSocket bağlantısı) olmadan hiç uyanmıyor; curl
  sadece statik HTML kabuğu alıyor. Çözüm: Playwright ile gerçek headless
  Chromium açıp "Yes, get this app back up!" butonunu arayıp tıklayan
  `wake_app.py` + GitHub Actions. **Aynı yaklaşım burada da uygulandı:**
  `wake_app.py` + `.github/workflows/uygulamayi_uyandir.yml` (3 saatte
  bir — TrendSurf'ün "aşırı sık çalıştırma üst üste binme riski
  yaratıyor" tecrübesiyle aynı frekans). **TrendSurf'teki gibi aynı
  sınırlama geçerli: bu resmi/garantili bir çözüm değil, topluluk
  workaround'u; sandbox'ın internet erişimi olmadığı için canlı
  `menu-muhendisi.streamlit.app`'e karşı uçtan uca test EDİLEMEDİ.**
  Bahri'nin push sonrası birkaç gün gözlemlemesi gerekiyor.
- **Ayrı bulunan hata (uyku ile ilgisiz değil ama farklı sorun):**
  Uygulama uykudan uyanırken `app.py`'de `httpx.ReadError` ile çöktü
  (`isletme_aktif_abonelik` sorgusunda) — soğuk başlangıçta geçici bir
  ağ kesintisi. `db.py`'ye `supabase_ile_dene()` (kısa beklemeli, 3
  denemeli yeniden-deneme yardımcısı) eklendi, `app.py`'deki 3 kritik
  başlangıç sorgusu (`auth.get_user`, `kullanicilar`,
  `isletme_aktif_abonelik`) bununla sarmalandı.

### 3 Ağustos 2026 — VI. Oturum (devam): Kart Görünümü Düzeltmeleri
- **HTML render hatası bulundu ve düzeltildi:** Gün kartları çok satırlı/
  girintili f-string olarak oluşturulup yan yana birleştirilince, araya
  yanlışlıkla boş satır giriyordu — Streamlit'in markdown ayırıcısı bunu
  "HTML bloğu bitti" sanıp sonraki kartları kaçışlı düz metin olarak
  gösteriyordu (sadece ilk kart doğru render oluyordu). Çözüm: her kart
  HTML'i tek satıra sıkıştırılıyor (`" ".join(html.split())`).
- **Kullanıcı talebiyle düzen değişti:** 7 gün artık kare şeklini bozarak
  tek satırda yan yana (`grid-template-columns:repeat(7,1fr)`), her
  öğündeki yemekler yan yana değil alt alta listeleniyor.
- **Kalıcı kural eklendi (madde 8, Kalıcı Proje Kuralları):** UI'da emoji
  ve widget kesinlikle yasak — TrendSurf Optima'daki aynı kural buraya da
  uygulandı. Claude'un hafızasına da (memory_user_edits) aynı kural ayrı
  bir proje-özel not olarak eklendi.
- **"Rastgelelik tohumu" kaldırıldı, mevsim→ay→4 hafta akışına geçildi:**
  Kullanıcı manuel tohum girmenin faydasız olduğunu belirtti. Artık:
  mevsim seçilince o mevsimin 3 ayı (`MEVSIM_AYLARI`) açılıyor, ay
  seçilince o ayın 4 haftası art arda (deterministik tohum =
  `ay_index*10+hafta_no`, kullanıcıya görünmüyor) üretilip alt alta
  gösteriliyor. Kart içinde alerjen bilgisi maliyetin üstüne alındı.
- **Kullanıcının bulduğu gerçek hata (madde 2 ihlali) — düzeltildi:**
  Aynı haftada "Mercimek Çorbası" ve "Sezar Usulü Tavuklu Salata" 3 kez
  tekrar etmiş. Kök neden: mevsime göre filtrelenmiş III. Grup havuzu
  bazı mevsimlerde çok küçük (ör. "yaz" için sadece 12 tarif); hafta
  ilerleyip bu küçük havuz tükenince (ya da kalanlar uyumsuzluk kuralına
  takılınca), algoritma **mevsim kısıtını gevşetmeden doğrudan tekrara
  izin verme**ye düşüyordu — oysa kütüphanenin geneli (mevsim dışı dahil)
  hâlâ kullanılmamış uygun tarif içeriyordu. `ogun_olustur`'a eksik olan
  ara kademe eklendi: (1) mevsime uygun + tekrarsız → (2) **mevsim
  kısıtı gevşetilmiş + hâlâ tekrarsız** [YENİ] → (3) son çare tekrara
  izin ver. UYUMSUZLUK kuralı (madde 11) hiçbir kademede gevşetilmiyor.
  16 haftalık (4 mevsim × 4 hafta) regresyon testinde doğrulandı: 0
  hafta-içi tekrar, 0 uyumsuzluk ihlali.
- **"Eksik fiyat var" artık hangi malzeme olduğunu söylüyor:** Önceden
  sadece genel bir uyarıydı, kullanıcı hangi malzemenin fiyatı eksik
  bilmiyordu. `malzemeler(ad, ...)` embed'ine `ad` eklendi, fiyatı
  olmayan her malzeme adı toplanıp maliyet metnine ekleniyor
  (ör. "≈3.67 € (eksik fiyat: Karides, Makarna)").

### 3 Ağustos 2026 — VI. Oturum (devam 2): Beni Hatırla Hatası + Sidebar Sırası
- **"Beni hatırla" hatası bulundu ve düzeltildi (gerçek bug, TrendSurf'te
  belgelenmemiş bir konu — oradan kopyalanmadı, doğrudan koddan
  teşhis edildi):** Supabase refresh token'ları tek kullanımlık
  (rotation) — her başarılı yenilemede yeni bir refresh_token dönüyor,
  eskisi geçersiz oluyor. Kod, oturumu yenilerken çerezi
  GÜNCELLEMİYORDU — sonuç: "beni hatırla" tam olarak bir kere işe
  yarayıp (2. ziyarette yenileme başarılı ama çerez eski token'da
  kalıyor), 3. ziyarette (artık geçersiz eski token'la yenileme
  denenince) başarısız oluyordu. `app.py`'de düzeltildi: her başarılı
  `refresh_session` sonrası çerez yeni `refresh_token` ile güncelleniyor.
- **Sidebar sırası:** Kullanıcı "Yıllık Menü"nün en üstte olmasını istedi.
  `pages/5_Yillik_Menu.py` → `pages/0_Yillik_Menu.py` olarak yeniden
  adlandırıldı (Streamlit sayfa sırası dosya adı başındaki sayıya göre).

### 3 Ağustos 2026 — VI. Oturum (devam 3): SALATALIK Fiyatı, "app" Sayfası, Mutfak Ölçeği
- **SALATALIK'in tüm işletmelerde fiyatı eksikti (bug değil, zamanlama
  sorunu):** `08_fiyat_gecmisini_geriye_donuk_doldur.sql` (Temmuz 2026)
  sadece "işletmenin HİÇ fiyatı var mı" kontrolü yapıyordu, malzeme
  bazında değil. SALATALIK bu backfill'den SONRA (12_...sql'de) eklendiği
  için, o tarihte zaten var olan hiçbir işletme SALATALIK için varsayılan
  fiyat almadı. `13_salatalik_fiyat_geriye_donuk_doldur.sql` eklendi —
  malzeme bazında kontrol ederek SADECE SALATALIK'i, henüz fiyatı
  olmayan her işletmeye geriye dönük ekliyor (idempotent).
- **`app.py` → `Kontrol_Paneli.py` olarak yeniden adlandırıldı:**
  Kullanıcı sidebar'daki "app" etiketinin ne işe yaradığını anlamadı.
  Araştırınca gerçek bir işlevi olduğu ortaya çıktı — "Çıkış yap" butonu
  SADECE bu sayfada tanımlı, kaldırılamaz. Ama etiket (dosya adından
  türetiliyor) anlamsızdı. Streamlit'in klasik `pages/` modelinde ana
  giriş dosyasının sidebar etiketi sadece dosya adı değiştirilerek
  düzeltilebiliyor (kodda ayarlanamıyor). **Kullanıcının Streamlit Cloud
  panelinde de Settings → Main file path'i `Kontrol_Paneli.py` olarak
  güncellemesi gerekiyor** (kod tarafı tek başına yetmez).
- **Türk mutfağının gerçek ölçeği (kullanıcıdan bağlam):** 74 tarif
  sadece başlangıç seti olarak tasarlanmıştı zaten; kullanıcı Türk
  mutfağının gerçekte 15.000-20.000+ yemek, 81 il/7 bölgeye yayılı
  bölgesel çeşitlilik içerdiğini belirtti (UNESCO tescilli ürünler,
  Çin/Fransız mutfaklarıyla birlikte dünyanın en zengin 3 mutfağından
  biri sayılıyor). Genişleme yöntemi (kategori bazlı mı, bölge bazlı mı)
  henüz kararlaştırılmadı — kullanıcıdan yön bekleniyor.

### 3 Ağustos 2026 — VI. Oturum (devam 4): app.py İsim Değişikliği Geri Alındı
- **`Kontrol_Paneli.py` → `app.py` geri alındı.** Streamlit Cloud'un
  "App settings" panelinde "Main file path" diye düzenlenebilir bir alan
  YOK (sadece App URL ve Python sürümü var) — yani deploy sonrası ana
  dosya adı değiştirilemiyor, sadece uygulamayı silip yeniden oluşturarak
  (secrets'ları tekrar girerek, muhtemelen URL riskiyle) yapılabilir.
  Bu riske değmeyeceği için sidebar'daki "app" etiketi kozmetik bir
  sorun olarak kabul edildi, kalıcı olarak `app.py` ismiyle devam
  ediliyor. İleride gerçekten istenirse st.navigation()/st.Page()
  API'sine geçiş (daha önce bu oturumda tartışılmıştı) bu sorunu kod
  içinden çözebilir, dosya adı değiştirmeden.

### 3 Ağustos 2026 — VI. Oturum (devam 5): SALATALIK Kaynak Dosyaya İşlendi + Eşanlamlı Desteği
- Kullanıcı SALATALIK'i (HIYAR) `kaynak_duzeltilmis_v2.xlsx`'e de ekledi
  (satır 47, SEBZELER bloğu). Eksik değerler için tam liste verildi:
  yoğunluk 0,95; özgül ısı 4,0; bozulma süresi 7 gün; fire %0,1; saklama
  10°C; kalori 15; protein 0,7; yağ 0,1; karbonhidrat 3,6; Gİ 15; mevsim
  Yaz; ısı iletkenliği 0,55; yüzey alanı 150cm²; alerjen: yok.
- **Alım fiyatı web araştırmasıyla düzeltildi:** Hal fiyatı ortalaması
  ~21,28 TL/kg (26 Temmuz 2026) → 0,39 €/kg (EUR/TRY~54) — migration
  12'deki geçici 0,30 değerinden daha isabetli.
  `14_malzeme_diger_adlar_ve_fiyat_duzeltme.sql`: hem
  `malzemeler.varsayilan_fiyat_eur`'u hem (eğer migration 13 zaten
  çalıştırılmışsa) mevcut `malzeme_fiyat_gecmisi` satırlarını 0,39'a
  güncelliyor.
- **Eşanlamlı malzeme adı desteği eklendi:** Bazı tariflerde SALATALIK
  yerine HIYAR geçebileceği belirtildi. `malzemeler.diger_adlar` (text[])
  sütunu eklendi, SALATALIK için `{HIYAR}` set edildi.
  `yukle_tarifler.py`'deki malzeme adı→id eşleme sözlüğü artık
  `diger_adlar` içindeki tüm eşanlamlıları da otomatik indeksliyor —
  ileride bir tarif "HIYAR" yazsa da doğru malzemeye bağlanacak. Kanonik
  ad hâlâ `malzemeler.ad` (SALATALIK); bu sadece esneklik katmanı.

### 3 Ağustos 2026 — VII. Oturum: Kütüphane 74 -> 250 Tarif
- Kullanıcı Türk mutfağının gerçek ölçeğini (15-20 bin+ yemek, 81 il/7
  bölge) hatırlattıktan sonra kütüphaneyi genişletme kararı alındı:
  **250'ye çıkar, hem mevcut kategorilerin çeşidini artır hem bölgesel
  yemek ekle (dengeli)**.
- **`tarif_verisi_ek1.py`** (yeni dosya, 176 tarif): I. Grup +70 (30->100,
  kırmızı et/tavuk/balık/etli sebze/kuru baklagil/yumurta çeşitlendirildi
  + Güneydoğu kebapları, Karadeniz balık/kavurma, Doğu Anadolu, İç
  Anadolu mantı/pastırma), II. Grup +56 (24->80, çorba/pilav/zeytinyağlı/
  makarna/börek), III. Grup +50 (20->70, salata/meze/cacık/turşu/
  komposto/tatlı — baklava, künefe, mantı, kısır, muhammara, çiğ köfte
  (vejetaryen) gibi ikonik bölgesel isimler dahil).
- **Bölgesel sınıflandırma:** `ozel_etiketler`e kural motorunu
  ETKİLEMEYEN yeni sınıflandırma etiketleri eklendi: `ege`, `karadeniz`,
  `guneydogu`, `akdeniz`, `ic_anadolu`, `marmara`, `dogu_anadolu` (aynı
  `kirmizi_et`/`vejetaryen` gibi bilgi amaçlı, madde 11/13'ü etkilemiyor).
- **Doğrulama:** 250 tarif, 0 tekrar eden isim (EK1 içinde ve orijinal
  74 ile karşılaştırmalı), 0 katalogda bulunamayan malzeme (154 farklı
  malzeme kullanıldı, ilk denemede 2 tanesi Türkçe İ/I yazım farkından
  ötürü — ÇILEK REÇELİ, INSTANT MAYA — kataloğun kendi yazımına göre
  düzeltildi).
- **`yukle_tarifler.py` idempotent hale getirildi:** Artık `TARIFLER` +
  `TARIFLER_EK1`'i birleştirip, Supabase'de **zaten var olan** tarif
  adlarını atlıyor — script'i her yeni parti eklendiğinde tekrar tekrar
  çalıştırmak güvenli (74'ü yeniden yüklemeye çalışıp unique constraint
  hatası vermiyor).
- **YUFKA kataloğu yok, adaptasyon notu:** Baklava/künefe gibi tarifler
  gerçek yufka/tel kadayıf yerine mevcut `BUĞDAY UNU`/`KADAYIF` ile
  yaklaşık olarak modellendi (aynı önceki börek tariflerindeki yaklaşım).
  Adana/Urfa kebap gibi geleneksel kuzu kıymalı tarifler, katalogda
  "kuzu kıyma" olmadığı için `DANA KIYMA` ile uyarlandı.
- **Sıradaki adım:** `yukle_tarifler.py`'yi tekrar çalıştırıp 176 yeni
  tarifi Supabase'e yüklemek (74'ü otomatik atlayacak).

### 3 Ağustos 2026 — VII. Oturum: Kütüphane Genişletme Yol Haritası + I. Parti (Karadeniz)
- **Karar (kullanıcıyla):** 74 tariflik kütüphane ~500'e çıkarılacak,
  hem bölgesel (Türkiye'nin 7 coğrafi bölgesi) hem kategorik çeşitlilik
  dengeli şekilde ele alınacak. Tek seferde değil, **bölge bölge partiler**
  hâlinde ilerlenecek (~60 tarif/bölge × 7 ≈ 420 + mevcut 74 ≈ 494).
- **I. Parti: Karadeniz Bölgesi — 20 tarif teslim edildi**
  (`karadeniz_tarifleri.py`, `KARADENIZ_TARIFLERI` listesi — I. Grup 8,
  II. Grup 6, III. Grup 6). Örnek tarifler: Akçaabat Köfte, Karalahana
  Sarması, Hamsili Pilav, Kuymak, Karalahana Çorbası, Laz Böreği,
  Fındıklı Kurabiye. Tüm malzemeler kataloğa karşı doğrulandı (0 eksik),
  74'lük kütüphaneyle isim çakışması yok.
- **Eksik malzemeler bulundu ve eklendi** (`17_karadeniz_malzemeleri_ekle.sql`):
  KARALAHANE (normal lahanadan farklı, Karadeniz'e özgü) ve FINDIK
  (Sert Kabuklu Yemiş alerjeni bağlandı). Fındık fiyatı TMO 2025-2026
  kabuklu fındık alım fiyatı (Giresun kalite, %50 randıman, 200 TL/kg
  kabuklu) referans alınarak iç fındık eşdeğeri ~5,56 €/kg olarak
  hesaplandı.
- **Yeni araç: `yukle_yeni_tarifler.py`** — `yukle_tarifler.py`'den
  farklı olarak mevcut tarifleri isme göre ATLAR, bu yüzden güvenle
  tekrar tekrar farklı partilerle (Ege, Güneydoğu, İç Anadolu, Akdeniz,
  Marmara, Doğu Anadolu partileri dahil) çalıştırılabilir. Her yeni
  parti için sadece dosyanın başındaki import satırı değiştirilecek.
- **Sıradaki bölge partileri (öncelik sırası belirlenmedi, kullanıcı
  yönlendirecek):** Ege, Akdeniz, Güneydoğu Anadolu, İç Anadolu,
  Marmara, Doğu Anadolu — her biri için önce eksik malzeme taraması,
  sonra tarif tasarımı, sonra doğrulama (isim çakışması + malzeme
  eksikliği) aynı yöntemle tekrarlanacak.

### 3 Ağustos 2026 — VII. Oturum (devam): Besin Hedefi Kısıtları
- **Yeni özellik: öğün bazında besin hedefi.** `uretim_algoritmasi.py`'ye
  `hedef` parametresi eklendi (kalori/protein/yağ/karbonhidrat/glisemik
  indeks için ayrı ayrı min-maks aralığı, Öğle ve Akşam için bağımsız).
  Kademeli esneme sırasına yeni bir aşama eklendi (UYUMSUZLUK/madde 11
  hâlâ hiçbir aşamada gevşetilmiyor):
  1) mevsime uygun + tekrarsız + hedef içinde
  2) mevsim gevşek + tekrarsız + hedef içinde
  3) tekrar izinli + hedef içinde
  4) son çare: hedef de gevşetilir
  **Test sonucu** (74 tarifle, sentetik besin verisiyle): hedef
  belirtilince 14/14 öğün hedefe uydu; 16 haftalık regresyon testinde
  hâlâ 0 uyumsuzluk ihlali, hafta-içi tekrar 42'den 54'e çıktı (kütüphane
  küçük + artık bir kısıt daha var — beklenen, Karadeniz partisi ve
  sonraki partiler bunu azaltacak).
- `pages/0_Yillik_Menu.py`: "Öğün başına besin hedefi uygula" onay kutusu
  + Öğle/Akşam için ayrı genişletilebilir bölümler (5 besin değeri ×
  min/maks). Kart görünümünde her öğünün altına "Hedefte" / "Hedef dışı"
  notu ekleniyor (hedef aktifse).

### 3 Ağustos 2026 — VII. Oturum (devam): Uyandırma Workflow'u Düzeltildi
- **Benim hatam, kullanıcının değil:** `.github/workflows/uygulamayi_uyandir.yml`
  ilk yazıldığında `actions/checkout` adımı unutulmuştu — bu adım olmadan
  GitHub Actions sanal makinesi repoyu hiç klonlamıyor, bu yüzden
  `wake_app.py` GitHub'da doğru şekilde dursa bile "No such file or
  directory" hatası veriyordu. `git status`/`git push` çıktıları dosyanın
  gerçekten commit'lendiğini doğruluyordu — sorun hep workflow'un kendi
  eksikliğindeydi. Düzeltildi (`Kodu indir` adımı eklendi, ilk sıraya
  alındı). Manuel "Run workflow" ile test edildi, başarılı: uygulama
  ziyaret edildi, log "uyku ekranı görülmedi" dedi (zaten uyanıktı).

### 3 Ağustos 2026 — VII. Oturum (devam): Excel'e İndir Butonu
- **Yeni özellik:** Üretilen aylık menü artık "Excel'e indir" butonuyla
  tek dosya (.xlsx) olarak indirilebiliyor — tüm haftalar/günler/öğünler
  tek bir düz veri tablosu (Hafta, Gün, Öğün, Ana/Yardımcı/Tamamlayıcı
  Yemek, Kalori, Protein, Yağ, Karbonhidrat, Gİ, Alerjen, Maliyet,
  Hedefte mi). `openpyxl` ile `st.download_button` kullanılarak bellekte
  (dosyaya yazmadan) üretiliyor. `openpyxl` `requirements.txt`'e eklendi
  (önceden tanımlı değildi). Profesyonel biçimlendirme: Arial font, koyu
  yeşil (#2C6B3C) marka renkli kalın başlık satırı, dondurulmuş başlık,
  sütun genişlikleri. Yerel testte 4 hafta × 7 gün × 2 öğün = 56 satır +
  başlık doğrulandı.

### 3 Ağustos 2026 — VII. Oturum (devam): Ege Bölgesi (II. Parti)
- **74 (başlangıç) + 20 (Karadeniz) = 94 doğrulandı** — kullanıcı Yıllık
  Menü sayfasında hâlâ "74" görüyordu, sebebi `_tarif_kutuphanesini_getir()`
  üzerindeki `@st.cache_data(ttl=3600)` (1 saatlik önbellek) idi — reboot
  sonrası 94 olarak doğru göründü. Bug değil, beklenen önbellek davranışı.
- **II. Parti: Ege Bölgesi — 26 tarif teslim edildi** (`ege_tarifleri.py`,
  `EGE_TARIFLERI` — I. Grup 10, II. Grup 8, III. Grup 8). Örnekler:
  Zeytinyağlı Bakla, Ahtapot Izgara, İzmir Köfte, Etli Enginar Dolması,
  Zeytinyağlı Radika, Bademli Kurabiye. Toplam kütüphane artık 94+26=120
  hedefleniyor.
- **Eksik malzemeler eklendi** (`18_ege_malzemeleri_ekle.sql`): BAKLA,
  PAZI, RADİKA (yabani ot), BADEM (Sert Kabuklu Yemiş alerjeni bağlandı).
  Badem fiyatı için perakende marka fiyatları (~600-900 TL/kg) yerine
  toptan/işletme alımına daha yakın bir referans (~450-500 TL/kg → 9€/kg)
  kullanıldı.
- **`yukle_yeni_tarifler.py`'nin import satırı Ege partisine güncellendi**
  (artık `ege_tarifleri.py`'den okuyor) — bir sonraki bölge için tekrar
  değiştirilecek. **Kendi kontrolümde bir hata yakaladım ve düzelttim:**
  ilk str_replace denemem import satırını yanlışlıkla bir sonraki satırla
  birleştirip syntax hatası yaratmıştı — `py_compile` ile fark edilip
  teslim öncesi düzeltildi.
- **Kalan 5 bölge partisi:** Akdeniz, Güneydoğu Anadolu, İç Anadolu,
  Marmara, Doğu Anadolu — sıradaki adım kullanıcının yönlendirmesiyle
  belirlenecek.

### 3 Ağustos 2026 — VII. Oturum (devam): Bölgesel Mutfak Seçimi
- **Yeni özellik: Yıllık Menü sayfasına bölge (mutfak) seçim kutusu
  eklendi.** `receteler` tablosuna `bolge` sütunu eklendi
  (`19_recete_bolge_ekle.sql`) — mevcut 120 tarif isimlerine göre geriye
  dönük etiketlendi: 74 tarif "Genel", 20 tarif "Karadeniz", 26 tarif
  "Ege". Sayfada artık bir çoklu-seçim kutusu var; varsayılan olarak tüm
  bölgeler seçili (davranış değişmiyor), kullanıcı isterse örn. sadece
  "Ege" ya da "Karadeniz + Ege" seçip üretim havuzunu daraltabiliyor.
- **Gelecekteki partiler için otomatikleştirildi:** `karadeniz_tarifleri.py`
  ve `ege_tarifleri.py`'ye `BOLGE_ADI` sabiti eklendi,
  `yukle_yeni_tarifler.py` artık bunu okuyup her tarife otomatik
  yazıyor — bundan sonraki bölge partileri (Akdeniz, Güneydoğu, İç
  Anadolu, Marmara, Doğu Anadolu) için geriye dönük SQL güncellemesi
  gerekmeyecek, sadece `BOLGE_ADI` doğru ayarlanacak.
- **Bilinen sınırlama (küçük ölçek):** Bölge filtresi sadece tarif
  HAVUZUNU daraltıyor — tek bir öğündeki 3 tarif (ana/yardımcı/tamamlayıcı)
  farklı bölgelerden gelebilir (ör. Karadeniz ana yemek + Ege salata).
  "Bir öğünün 3 tarifi de aynı bölgeden olsun" gibi daha katı bir kural
  istenirse ayrı bir geliştirme olarak ele alınmalı.

### 3 Ağustos 2026 — VII. Oturum (devam): Akdeniz Bölgesi (III. Parti)
- **III. Parti: Akdeniz Bölgesi — 24 tarif teslim edildi**
  (`akdeniz_tarifleri.py`, `AKDENIZ_TARIFLERI` — I. Grup 9, II. Grup 7,
  III. Grup 8). Örnekler: Adana Kebap, Muhammara Soslu Tavuk, Humus,
  Künefe, Kısır, Nar Ekşili Köfte. **Yeni malzeme eklemeye gerek
  kalmadı** — NAR, NAR EKŞİSİ, SUMAK, TAHİN, HUMUS zaten katalogda
  mevcuttu (74 kütüphanesi hazırlanırken geniş bir SEBZELER/BAHARATLAR
  kataloğu kurulmuştu). Toplam kütüphane hedefi: 120+24=144.
  `yukle_yeni_tarifler.py`'nin import satırı Akdeniz partisine
  güncellendi.
- **Kalan 4 bölge partisi:** Güneydoğu Anadolu, İç Anadolu, Marmara,
  Doğu Anadolu.

### 3 Ağustos 2026 — VII. Oturum (devam): Güneydoğu Anadolu (IV. Parti)
- **IV. Parti: Güneydoğu Anadolu — 24 tarif teslim edildi**
  (`guneydogu_tarifleri.py` — I. Grup 9, II. Grup 7, III. Grup 8).
  Örnekler: Çiğ Köfte, Alinazik Kebap, İçli Köfte, Antep Usulü Baklava,
  Antep Fıstıklı Künefe, Sumaklı Cacık. Toplam hedef: 144+24=168.
- **Eksik malzeme:** sadece İSOT (Urfa biberi) eklendi
  (`20_guneydogu_malzemeleri_ekle.sql`). NANE yerine katalogda zaten
  `TAZE NANE`/`KURU NANE` ayrımı vardı, kullanıldı.
- **Kendi kontrolümde yakalanan hata:** migration'da yanlışlıkla "ISOT"
  (düz I) yazmışım, tariflerde "İSOT" (noktalı İ) kullanmışım —
  doğrulama scripti eksik malzeme olarak yakaladı, migration düzeltildi.
- **Kalan 3 bölge partisi:** İç Anadolu, Marmara, Doğu Anadolu.

### 3 Ağustos 2026 — VII. Oturum (devam): İç Anadolu (V. Parti)
- **V. Parti: İç Anadolu Bölgesi — 24 tarif teslim edildi**
  (`ic_anadolu_tarifleri.py` — I. Grup 9, II. Grup 7, III. Grup 8).
  Örnekler: Keşkek, Etli Ekmek (Konya), Kayseri Mantısı, Testi Kebabı,
  Tarhana Çorbası, Höşmerim, Kuru Üzümlü İrmik Helvası. Toplam hedef:
  168+24=192.
- **Eksik malzemeler eklendi** (`21_ic_anadolu_malzemeleri_ekle.sql`):
  BUĞDAY (TAM TANE) (keşkek icin), TARHANA, BAMYA. PASTIRMA ve SUCUK
  zaten katalogda mevcuttu.
- **Kalan 2 bölge partisi:** Marmara, Doğu Anadolu.

### 3 Ağustos 2026 — VII. Oturum (devam): Marmara (VI. Parti)
- **VI. Parti: Marmara Bölgesi — 24 tarif teslim edildi**
  (`marmara_tarifleri.py` — I. Grup 9, II. Grup 7, III. Grup 8).
  Örnekler: İskender Kebap, Hünkar Beğendi, Midye Tava, Bursa Usulü
  İnegöl Köfte, Kestane Şekeri, Kaymaklı Ekmek Kadayıfı. Toplam hedef:
  192+24=216.
- **Eksik malzemeler eklendi** (`23_marmara_malzemeleri_ekle.sql`):
  KESTANE, EKMEK KADAYIFI (Gluten alerjeni bağlandı). KAYMAK zaten
  katalogda mevcuttu.
- **Kalan 1 bölge partisi: Doğu Anadolu** — tamamlanınca 7 bölgenin
  tamamı bitmiş olacak (~240 tarif hedefine yakın).

### 3 Ağustos 2026 — VII. Oturum (devam): Doğu Anadolu (VII. ve SON Parti) — 7 Bölge Tamamlandı
- **VII. Parti: Doğu Anadolu Bölgesi — 24 tarif teslim edildi**
  (`dogu_anadolu_tarifleri.py` — I. Grup 9, II. Grup 7, III. Grup 8).
  Örnekler: Cağ Kebabı, Van Usulü Kahvaltı Tabağı, Bal Kaymak, Otlu
  Peynirli Gözleme, Kayısı Tatlısı (Ballı).
- **Eksik malzeme:** sadece OTLU PEYNİR eklendi
  (`24_dogu_anadolu_malzemeleri_ekle.sql`, Süt alerjeni bağlandı).
  TULUM PEYNİRİ ve BAL zaten katalogda mevcuttu.
- **7 COĞRAFİ BÖLGENİN TAMAMI TAMAMLANDI:** Genel (74) + Karadeniz (20)
  + Ege (26) + Akdeniz (24) + Güneydoğu Anadolu (24) + İç Anadolu (24)
  + Marmara (24) + Doğu Anadolu (24) = **TOPLAM 240 TARİF**.
- **Dürüst durum değerlendirmesi:** Kullanıcının hedefi ~500'dü, 240'a
  ulaşıldı (7 bölgenin "ilk turu" tamamlandı, hedefin ~%48'i). 500'e
  ulaşmak için ya (a) her bölgeye ikinci bir tur eklenebilir (bölge
  başına +25-30 daha), ya da (b) kategori bazlı bir genişleme yapılabilir
  (çorba/tatlı/et yemekleri gibi kategorilerin genel havuzda çeşidini
  artırmak). Kullanıcıya sorulacak.

### 3 Ağustos 2026 — VII. Oturum (devam): "Genel" Butonu Düzeltmesi
- Kullanıcı "Genel" seçilince tüm 240 tarifin görünmesini bekliyordu
  (sadece 74'lük genel havuzu değil) — "Genel"i "hepsi" anlamında
  kullanıyor. Davranış değiştirildi: **"Genel" seçiliyken (diğer
  bölgeler seçili olsun olmasın) TÜM bölgeler kullanılır.** Sadece
  belirli bir bölgeye daraltmak icin once "Genel" kaldırılıp sonra
  istenen bölge(ler) seçilmeli. Yardım metni buna göre güncellendi.

### 3 Ağustos 2026 — VII. Oturum (devam): Arayüz Düzeltmeleri (5 Madde)
- **Bölge butonları artık `st.pills` değil, `st.columns` + `st.button`.**
  İki kez `st.pills` üzerinde CSS ile eşit genişlik denendi, ikisi de
  tutmadı (Streamlit bu bileşenin iç HTML yapısını belgelemiyor).
  Güvenilir/belgeli bir API'ye geçildi: `st.columns(N)` doğası gereği
  eşit genişlikte sütunlar üretir, her birine `use_container_width=True`
  ile buton konularak genişlik garantili hale getirildi (CSS tahminine
  gerek kalmadı). Seçim durumu `st.session_state.secili_bolgeler_set`
  içinde tutuluyor, buton rengi `type="primary"/"secondary"` ile
  (Streamlit'in resmi/belgeli parametresi) ayırt ediliyor.
- **Kısa bölge adları:** "Doğu Anadolu"→"Doğu", "Güneydoğu Anadolu"→
  "Güneydoğu" (sadece görünen etiket; veritabanındaki `bolge` değeri ve
  filtreleme mantığı değişmedi, `KISA_BOLGE_ADI` sözlüğü sadece
  görüntüleme içindir).
- **"Genel" = hepsi davranışı** korunuyor (bir önceki oturumda eklendi);
  seçili bölge(ler)deki tarif sayısı butonların hemen altında gösteriliyor.
- **Mevsim/Ay** artık `st.columns([1,1,3])` ile dar ve yan yana (üçüncü
  boş sütun kalan alanı yutuyor, ikisi tam genişlik kaplamıyor).
- **Yeni: Mutfak seçimi (en üstte, dar).** `mutfaklar` tablosundan
  (zaten çoklu-mutfak için hazırlanmıştı, `11_coklu_mutfak_capraz_kesim.sql`)
  okunuyor; şu an sadece "Türk Mutfağı" var, ileride başka mutfak
  eklenince aynı seçim kutusu otomatik büyüyecek. Şu an için filtreleme
  mantığına henüz bağlanmadı (tek mutfak olduğu için gerek yok) — yorum
  satırıyla işaretlendi.

### 3 Ağustos 2026 — VII. Oturum (devam): Bölge Sayım Mantığı Düzeltmesi + Çoklu Mutfak Altyapısı
- **"Genel" mantığı yanlış anlaşılmıştı, düzeltildi:** Önceki kural
  "Genel her seçiliyken hepsi" idi — kullanıcı bunu istemiyor. Doğru
  kural: **SADECE Genel tek başına seçiliyse hepsi (240)**; Genel başka
  bölgelerle BİRLİKTE seçiliyse kendi 74'ü ile normal toplama katılır
  (ör. Genel + 6 bölge, Akdeniz hariç = 216). Bu, hem ekrandaki sayıyı
  hem de **üretim motorunun fiilen kullandığı tarif havuzunu** aynı anda
  düzeltti (aynı `tarifler` listesi ikisi için de kullanılıyordu).
  16 test senaryosuyla doğrulandı (Akdeniz hariç hepsi→216, sadece
  Genel→240, sadece Akdeniz→24, Genel+Akdeniz→98, hepsi doğru).
- **Çoklu mutfak altyapısı tamamlandı:** `_tarif_kutuphanesini_getir()`
  artık `mutfak_kodu` parametresi alıyor (önceden "turk" sabit
  kodlanmıştı). İleride yeni bir mutfak (ör. Fransız Mutfağı) eklenip
  kendi `mutfak_kategorileri`/`receteler` verisi girildiğinde, en
  üstteki mutfak seçim kutusu + bölge butonları + tüm üretim akışı
  otomatik olarak o mutfağa göre çalışacak, ekstra kod değişikliği
  gerekmeyecek (mevcut `grup_by_kategori` eşleştirme mantığı zaten
  mutfağa özgü çalışıyordu, sadece sabit kodlanmış "turk" değeri
  parametreleştirildi).

### 3 Ağustos 2026 — VII. Oturum (devam): Bölge Sıralaması
- Bölge butonları alfabetik yerine kullanıcının istediği sırayla:
  Genel, Marmara, Ege, Akdeniz, Karadeniz, İç Anadolu, Doğu, Güneydoğu.
  `BOLGE_SIRASI` listesiyle sabit sıra uygulandı; ileride bu listede
  olmayan yeni bir bölge eklenirse otomatik olarak sona (alfabetik)
  eklenir, koddan bir şey unutulmaz.

### 3 Ağustos 2026 — VII. Oturum (devam): Bölge Seçim Modeli Kökten Basitleştirildi
- **Kullanıcının bulduğu gerçek karışıklık:** "sadece Marmara seçiliyken
  216 tarif" gibi ters sonuçlar bildirdi. Kök neden: butonlar varsayılan
  olarak HEPSİ SEÇİLİ başlıyordu, bir butona tıklamak o bölgeyi
  AÇMIYOR, KAPATIYORDU (diğer 7'si açık kalıyordu) — yani "sadece X'e
  tıkladım" aslında "X hariç hepsi" anlamına geliyordu (240-X). Sayılar
  matematiksel olarak doğruydu ama etkileşim modeli sezgiye aykırıydı.
- **Kökten basitleştirme:** Varsayılan artık BOŞ seçim (hiçbir buton
  seçili değil). Hiçbir buton seçili değilken kısıt yok, tüm bölgeler
  kullanılır (240). Bir butona tıklamak SADECE o bölgeyi ekler/çıkarır
  (normal, sezgisel "toggle" davranışı). "Genel" artık özel bir durum
  değil, sadece bir bölge değeri gibi davranıyor — ayrı bir
  `if secili_bolgeler == {"Genel"}` özel durumuna gerek kalmadı, kod da
  basitleşti. Buton altına açıklayıcı bir not eklendi.

### 3 Ağustos 2026 — VII. Oturum (devam): "Genel" → "Klasik" Görünen Etiket
- Kullanıcı "Genel" kelimesinin kafa karıştırdığını belirtti (sanki
  "hepsini birleştiren/kapsayan" anlamına geliyormuş gibi algılanıyordu,
  oysa 74'lük bağımsız/ayrık bir grup). Sadece GÖRÜNEN etiket "Klasik"
  olarak değiştirildi (`KISA_BOLGE_ADI` sözlüğüne eklendi) — veritabanındaki
  gerçek `bolge` değeri hâlâ "Genel" (hiçbir migration/veri değişikliği
  gerekmedi, "Doğu Anadolu"→"Doğu" ile aynı yöntem).

### 3 Ağustos 2026 — VII. Oturum (devam): "Aynı Yemek Her Gün" Teşhisi
- Kullanıcı tek bölgeye (Güneydoğu) daralttığında ve besin hedefi
  açıkken, "Antep Usulü Mercimekli Köfte"nin 14/14 öğünde çıktığını
  bildirdi. Sentetik veriyle test edilince algoritmanın kendisinde
  yapısal bir sorun olmadığı doğrulandı (makul çeşitlilik üretti).
  Kullanıcı hedefi kapatıp tekrar üretince çeşitlilik gerçekten düzeldi
  — **teşhis doğrulandı: dar bölge (küçük havuz, grup başına 7-9 tarif)
  + sıkı kalori hedefi birleşince, gerçek verilerde o aralığa uyan
  neredeyse tek yemek varmış, algoritma da ona kilitleniyormuş.** Kod
  hatası değil, matematiksel bir sınırlama (küçük kütüphane + sıkı
  kısıt kombinasyonu).
- **Önlem eklendi:** dar bölge seçiliyken (< 60 tarif) VE besin hedefi
  aktifken, üret butonunun üstünde uyarı metni çıkıyor ("hedef aralığını
  genişlet veya daha fazla bölge seç" tavsiyesi).

### 3 Ağustos 2026 — VII. Oturum (devam): Excel Formatı Ekrandaki Kartlarla Eşleştirildi
- Kullanıcı önceki Excel formatını (düz "1 satır = 1 öğün" veri tablosu)
  beğenmedi, ekrandaki kart görünümüyle birebir aynı olmasını istedi.
  `_aylik_menu_excel_olustur` tamamen yeniden yazıldı: artık her GÜN bir
  SÜTUN (Gün 1..7), her hafta kendi bloğu (başlık + gün başlıkları +
  Öğle bloğu + Akşam bloğu). Her öğün bloğunda ekrandaki sırayla: Ana
  Yemek (kırmızı), Yardımcı Yemek (yeşil), Tamamlayıcı (teal), Besin
  özeti (kcal/P/Y/K/Gİ tek satırda), Alerjen, Maliyet, (besin hedefi
  aktifse) Hedef Durumu. Renkler ekrandaki legend ile aynı (#D85A30,
  #639922, #1D9E75), başlık dolgusu marka yeşili (#2C6B3C).

### 3 Ağustos 2026 — VII. Oturum (devam): Yeni Malzemelerin Fiyat Eksikliği Toplu Düzeltmesi
- **Sistematik bir gözden kaçırma bulundu:** SALATALIK için yaptığım
  "geriye dönük fiyat doldurma" adımını (madde bazında,
  `malzeme_fiyat_gecmisi`'ne varsayılan fiyatı kopyalama), bölgesel
  genişletme sırasında eklenen 13 yeni malzeme için (YUFKA, KARALAHANE,
  FINDIK, BAKLA, PAZI, RADİKA, BADEM, İSOT, BUĞDAY (TAM TANE), TARHANA,
  BAMYA, KESTANE, EKMEK KADAYIFI, OTLU PEYNİR) unutmuşum — her biri
  sadece `malzemeler.varsayilan_fiyat_eur` aldı, mevcut işletmelerin
  kendi fiyat geçmişine hiç kopyalanmadı. `25_yeni_malzemeler_fiyat_geriye_donuk_doldur.sql`
  ile hepsi tek seferde, malzeme bazında kontrol ederek düzeltildi
  (idempotent). Tüm 13 isim, ilgili migration dosyalarından programatik
  olarak doğrulandı (Türkçe karakter hatası riski yaşanmadı bu sefer).

### 3 Ağustos 2026 — VII. Oturum (devam): KARALAHANE → KARALAHANA Yazım Düzeltmesi
- Kullanıcı "KARALAHANE" yazımının yanlış olduğunu belirtti, doğrusu
  "KARALAHANA". `26_karalahane_isim_duzeltme.sql` ile canlı veritabanında
  düzeltildi (sadece isim güncelleniyor, tarifler/fiyat geçmişi malzeme
  ID'sine bağlı olduğu için hiçbir bağlantı bozulmadı). Yerel dosyalarda
  da (`karadeniz_tarifleri.py`, `17_karadeniz_malzemeleri_ekle.sql`,
  `25_yeni_malzemeler_fiyat_geriye_donuk_doldur.sql`) düzeltildi.

### 3 Ağustos 2026 — VII. Oturum (devam): "Beni Hatırla" Kökten Düzeltildi (Kütüphane Değişikliği)
- **Gerçek kök neden bulundu:** Streamlit'in resmi çerez sistemi
  (`st.context.cookies`) sadece OKUMA yapabiliyor, yazma imkanı yok
  (Streamlit'in kendi GitHub'ında hâlâ açık bir istek). Önceden
  kullandığımız `streamlit-cookies-manager` kütüphanesi çerez SÜRESİNİ
  hiç ayarlamaya izin vermiyordu (dokümantasyonunda `expires_at`/`max_age`
  parametresi yok) — benzer topluluk kütüphanelerinin çoğu (streamlitextras,
  extra-streamlit-components) açıkça ayarlanmazsa varsayılan olarak
  SADECE 1 GÜN süreli çerez oluşturduğunu belgeliyor. Bu güçlü örüntü,
  "beni hatırla"nın neden kısa sürede unuttuğunu açıklıyor.
- **Çözüm: `extra-streamlit-components` kütüphanesine geçildi**
  (`expires_at` parametresini açıkça destekliyor). Artık
  `BENI_HATIRLA_GUN = 30` ile net bir süre ayarlanıyor (Streamlit'in
  kendi yeni native auth özelliğinin de varsayılan olarak kullandığı
  süreyle aynı). Bu kütüphane şifreleme yapmadığı için (eski
  `EncryptedCookieManager`'ın aksine), `cryptography.fernet` ile KENDI
  şifrelememizi ekledik — anahtar mevcut `COOKIE_SIFRESI` secret'ından
  SHA-256 ile türetiliyor (yeni bir secret gerekmedi). Round-trip
  şifreleme/çözme yerel olarak test edildi ve doğrulandı.
- `requirements.txt`: `streamlit-cookies-manager` kaldırıldı,
  `extra-streamlit-components` + `cryptography` eklendi.
- **Not:** Bu, canlıda test edilememiş bir kütüphane değişikliği —
  ilk birkaç günlük gözlem önemli. Sorun çıkarsa geri dönüş noktası bu
  commit'ten önceki sürüm.

### 3 Ağustos 2026 — VII. Oturum (devam): Beni Hatırla Değişikliği Sonrası Çökme Düzeltildi
- Kütüphane değişikliğinden hemen sonra `CachedWidgetWarning` ile sert
  bir hata alındı: `stx.CookieManager()`'ı `@st.cache_resource` ile
  önbelleklemeye çalışmıştım, ama bu sınıfın kendisi bir Streamlit
  bileşeni (widget) render ediyor — Streamlit, önbelleklenmiş fonksiyon
  içinde widget kullanımını kesinlikle yasaklıyor. `@st.cache_resource`
  kaldırıldı, her çalıştırmada yeniden oluşturuluyor (fonksiyonel olarak
  sorun değil, kütüphanenin resmi örnekleri de böyle kullanıyor).

### 3 Ağustos 2026 — VII. Oturum (devam): Çam Fıstığı/Kuş Üzümü/Kuru İncir Eksikliği
- **Kullanıcının bulduğu gerçek eksiklik, sadece malzeme değil tarif
  düzeyinde de:** ÇAM FISTIĞI (dolmalık fıstık) ve KUŞ ÜZÜMÜ hiç
  katalogda yoktu, KURU İNCİR de eksikti (KURU KAYISI/KURU ÜZÜM zaten
  vardı). Daha da önemlisi: **"Zeytinyağlı Yaprak Sarma" bu malzemeler
  eksik olduğu için onlarsız yazılmıştı** — geleneksel tarifte
  vazgeçilmez oldukları hâlde. "Aşure" de KURU İNCİR içermiyordu.
- **Düzeltmeler** (`27_cam_fistigi_kus_uzumu_kuru_incir_ekle.sql` +
  `28_mevcut_tarifleri_duzelt_ve_fiyat_doldur.sql`):
  1. 3 yeni malzeme eklendi (Çam fıstığı fiyatı güncel piyasa
     araştırmasına dayanıyor: ~3700 TL/kg perakende → ~61 €/kg toptan
     referansı).
  2. Mevcut "Zeytinyağlı Yaprak Sarma" (74) tarifine ÇAM FISTIĞI +
     KUŞ ÜZÜMÜ eklendi; "Aşure"ye KURU İNCİR eklendi (recete_malzemeleri
     tablosuna doğrudan, malzeme bazında kontrol ederek).
  3. Mevcut işletmelere geriye dönük fiyat dolduruldu (13/25 ile aynı
     yöntem).
  4. `tarif_verisi.py` da güncellendi (gelecekteki sıfırdan kurulumlar
     için tutarlılık).
- **Yeni tarif: "İç Pilav"** eklendi (`ek_tarifler.py` + `tarif_verisi.py`,
  bölge: Genel) — pirinç, çam fıstığı, kuş üzümü, kuru soğan, tereyağı,
  yenibahar. Kütüphane artık 75 (genel) + 166 (7 bölge) = 241 tarif
  hedefliyor. `yukle_yeni_tarifler.py`'nin import satırı bu tekil tarif
  partisine güncellendi.

### 3 Ağustos 2026 — VII. Oturum (devam): "app" İsim Sorunu KALICI Çözüldü (st.navigation)
- Kullanıcı defalarca "app" etiketinin neden değiştirilemediğini sordu.
  Daha önce (Streamlit Cloud'un deploy-sonrası "main file path"
  değiştirilemediği için) bu kozmetik bir sınırlama olarak kabul
  edilmişti. Bu sefer **gerçek bir kod-içi çözüm bulundu ve uygulandı:**
  Streamlit'in yeni `st.navigation()` + `st.Page()` API'si (resmi
  dokümantasyondan doğrulandı), dosya adından tamamen bağımsız olarak
  her sayfaya istenilen ismi verebiliyor.
- **Uygulama:** `app.py`'nin sonu yeniden yapılandırıldı — dashboard
  içeriği (sidebar plan/çıkış + kullanım kılavuzu) `kontrol_paneli_sayfasi()`
  fonksiyonuna sarıldı, ardından:
  ```python
  kontrol_sayfasi = st.Page(kontrol_paneli_sayfasi, title="Kontrol Paneli", default=True)
  yillik_menu_sayfasi = st.Page("pages/0_Yillik_Menu.py", title="Yıllık Menü")
  ... (digerleri de ayni sekilde, dosya yolu ile) ...
  pg = st.navigation([...])
  pg.run()
  ```
  Diğer sayfa dosyalarının (`pages/*.py`) İÇİNE HİÇ DOKUNULMADI — sadece
  dosya yolu üzerinden referans veriliyor, kendi `st.set_page_config()`
  çağrıları da (resmi dokümantasyona göre) sorunsuz çalışıyor
  ("entrypoint'te varsayılan, sayfa içinde onu geçersiz kılma" deseni
  resmi olarak destekleniyor).
- **Streamlit Cloud ayarına HİÇ dokunulmadı** — giriş dosyası hâlâ
  `app.py`, deploy ayarı değişmedi. Sidebar'da artık "Kontrol Paneli"
  görünecek, "app" değil.
- **Bilinen davranış (değişmedi):** Çıkış/plan bilgisi hâlâ sadece
  Kontrol Paneli sayfasında görünüyor (diğer sayfalarda değil) — bu
  refactor'un kapsamı dışında tutuldu, ayrı bir iyileştirme olarak ele
  alınabilir.

### 3 Ağustos 2026 — VII. Oturum (devam): Hamsili Pilav de İç Pilav Tekniğine Düzeltildi
- Kullanıcı "Hamsili Pilav"ın (Karadeniz) geleneksel olarak İç Pilav
  tekniğiyle (çam fıstığı + kuş üzümü ile) pişirildiğini belirtti;
  kontrol edilince gerçekten sade pirinçle yazıldığı doğrulandı.
  `karadeniz_tarifleri.py` güncellendi, canlı veritabanı için
  `29_hamsili_pilav_ic_pilav_duzeltme.sql` ile düzeltildi.

### 3 Ağustos 2026 — VII. Oturum (devam): Pişirme Talimatları Altyapısı Kuruldu
- **Yeni özellik altyapısı (kullanıcının onayıyla): "Tarif Kütüphanesi"
  sayfası eklendi** (`pages/5_Tarif_Kutuphanesi.py`). 241 tariflik genel
  kütüphaneyi bölge/gruba göre filtreleyip tek bir tarif seçmeyi,
  istenen porsiyon sayısına göre malzeme miktarlarının, besin
  değerlerinin ve maliyetin ÖLÇEKLENMİŞ hâlini görmeyi sağlıyor.
  Glisemik indeks bir oran olduğu için porsiyon sayısından bağımsız
  tutuldu (ölçeklenmiyor).
- **Şema:** `receteler.hazirlik_talimati` (metin, NULL=henüz girilmedi)
  eklendi (`30_hazirlik_talimati_ekle.sql`). Malzeme miktarları zaten
  1 porsiyon baz alınarak tasarlandığı için ayrı bir ölçekleme alanına
  gerek kalmadı — arayüz miktar_gram × porsiyon_sayısı işlemini
  doğrudan yapıyor.
- **st.navigation() listesine eklendi** — yeni sayfa unutulmadan
  `app.py`'deki sayfa listesine dahil edildi (aksi halde hiç görünmez
  olurdu, çünkü artık pages/ klasörü otomatik keşfedilmiyor).
- **Sıradaki adım:** Talimatları kademeli doldurmak — kullanıcı hangi
  tariflerden/hangi sırayla başlanmasını istediğini belirtecek.

### 3 Ağustos 2026 — VII. Oturum (devam): Pişirme Talimatları I. Parti (30 Ana Yemek)
- **ÇAM FISTIĞI'na eksik kalan sert kabuklu yemiş alerjeni**
  `31_cam_fistigi_alerjen_duzeltme.sql` ile düzeltildi (27_...sql'de
  unutulmuştu).
- **Pişirme talimatları I. Parti:** orijinal 75 "Klasik" kütüphanenin
  I. Grup (ana yemek) tariflerinin **tamamı (30/30)** için adım adım
  talimat yazıldı (`talimatlar_parti1.py`). Yeniden kullanılabilir bir
  yükleme scripti (`talimat_yukle.py` + `talimat_yukle_calistir.bat`)
  oluşturuldu — `receteler.hazirlik_talimati` alanını isme göre UPDATE
  ediyor, idempotent. Gelecekteki partiler için sadece import satırı
  değiştirilecek (yeni bir `talimatlar_partiN.py` yazılıp import
  güncellenecek).
- **Sıradaki adım:** II. Grup (yardımcı yemek, çorba/pilav/börek) ve
  III. Grup (tamamlayıcı) tarifleri, sonra bölgesel tarifler (166 adet).

### 3 Ağustos 2026 — VII. Oturum (devam): Pişirme Talimatları — Detay Seviyesi Yükseltildi
- Kullanıcı ilk 30 talimatın çok yüzeysel kaldığını belirtti — malzeme
  hazırlama teknikleri, ısıl işlem sıcaklık/süre detayları, PARALEL
  yapılabilecek işlemler ve işçilik zamanlaması bekliyordu (Üretim
  Aşamaları sayfasının metodolojisiyle uyumlu bir derinlik).
- **`talimatlar_parti1.py` tamamen yeniden yazıldı (v2).** Yeni format,
  her tarif için: Hazırlık/Mise en Place → Isıl İşlem aşama(lar)ı (tam
  sıcaklık °C + süre + teknik detay) → açık "PARALEL YAPILABİLİRLİK"
  notları (hangi aşamalar eş zamanlı yürütülebilir, kaç dakika
  kazandırır) → "SÜRE ÖZETİ" (aktif işçilik dk vs pasif bekleme dk ayrı
  ayrı). Örnek: Karnıyarık'ta patlıcan kızartma ile kıyma harcı
  hazırlamanın ayrı ocak gözlerinde paralel yapılabileceği, bunun
  ardışık 18 dk'yı ~10 dk'ya indirdiği açıkça belirtildi.
- Aynı `talimat_yukle.py`/`.bat` ile tekrar yüklenebilir (UPDATE
  olduğu için eski kısa metnin üzerine yeni detaylı metin yazılır,
  idempotent).

### 3 Ağustos 2026 — VII. Oturum (devam): Çift Logo Düzeltmesi + Gerçek Maliyet Motoru Kütüphaneye Bağlandı
- **Çift logo hatası düzeltildi:** `st.navigation()`'a geçtiğimizden beri
  app.py'nin TAMAMI her sayfa geçişinde yeniden çalışıyor. `sidebar_logo_goster()`
  eskiden en üst seviyede (fonksiyon dışında) çağrılıyordu — bu da her
  sayfanın kendi üstündeki çağrıyla birleşip logoyu ÇİFT gösteriyordu.
  Çözüm: üst seviye çağrı kaldırıldı, sadece login ekranı / abonelik-yok
  ekranı / Kontrol Paneli fonksiyonu içinde (üç ayrı, birbirini
  dışlayan dal) çağrılıyor — her zaman tam olarak BİR kez render olur.
- **Gerçek üretim maliyeti (enerji+işçilik+genel gider) kütüphaneye
  bağlandı.** Kritik bulgu: mevcut `recete_uretim_maliyeti` view'i
  `isletme_maliyet_ayarlari` ile SIKI (`r.isletme_id = ima.isletme_id`)
  join yapıyor — global (isletme_id NULL) tarifler için bu hiç eşleşmez,
  çünkü enerji/işçilik/genel gider oranları oturum açan İŞLETMEYE özel
  (herkes için tek bir "doğru" enerji fiyatı yok). Var olan şemayı
  (`recete_asamalari`/`asama_malzemeleri`/`asama_bagimliliklari` — zaten
  herhangi bir recete_id için çalışıyor, isletmeye özel değil) DEĞİŞTİRMEDEN,
  Tarif Kütüphanesi sayfasına AYRI bir Python hesaplaması eklendi: aşama
  verisini (global tarif) + oturum açan işletmenin KENDİ maliyet
  ayarlarını ayrı ayrı çekip aynı Q=m·c·ΔT formülüyle birleştiriyor.
  Mevcut çalışan sistem (`4_Uretim_Asamalari.py`, kullanıcının kendi
  reçeteleri) hiç değiştirilmedi, sıfır risk.
- **I. Parti (kanıt-kavram): 3 tarif için aşama verisi eklendi**
  (`asamalar_parti1.py` + `asama_yukle.py` + `.bat`) — Menemen (basit
  sıralı), Karnıyarık (paralel işlem örneği), Kuzu Tandır (uzun pasif
  fırın). `asama_yukle.py` idempotent (aynı tarif için tekrar
  çalıştırılırsa eski aşamaları silip yeniden ekler).
- **Dürüst sınırlama notu:** Enerji formülü (Q=mcΔT) sadece yemeğin
  kütlesini ısıtma enerjisini hesaplıyor, fırın/ocak ekipmanının kendi
  ısınma/ısı kaybı enerjisini içermiyor — bu, `10_uretim_maliyet_semasi.sql`'in
  kendi yorumunda da açıkça kabul edilen bir v1 sınırlaması, bu oturumda
  değiştirilmedi.
- **Sıradaki adım:** Kalan 27 ana yemek + II./III. Grup + bölgesel
  tarifler için aşama verisi kademeli eklenecek.

### 3 Ağustos 2026 — VII. Oturum (devam): Aşama RLS Düzeltmesi + Yıllık Menü'den Tarif Kütüphanesi'ne Tıklanabilir Link
- **Gerçek maliyet neden görünmüyordu:** `recete_asamalari`/`asama_malzemeleri`/
  `asama_bagimliliklari` muhtemelen sadece "kendi işletmesi" için RLS
  izni taşıyordu — global (bölgesiz) tariflere ait aşamalar hiçbir
  kullanıcıya görünmüyordu (`asama_yukle.py` service_role ile yazdığı
  için RLS'i atlamıştı, ama normal oturum okurken engelleniyordu — bu
  projede daha önce de defalarca karşılaşılan bir kalıp: mutfaklar,
  malzeme_alerjen vb.). `32_recete_asamalari_global_rls_duzeltme.sql`
  ile üç tabloya da EKLEME nitelikli (mevcut politikaları değiştirmeyen)
  "global tarifler için herkese açık okuma" politikası eklendi.
- **Yıllık Menü'deki yemek isimleri artık tıklanabilir link.** Her yemek
  adı, Tarif Kütüphanesi'ne `?tarif=<isim>` sorgu parametresiyle giden
  bir bağlantıya dönüştürüldü (`urllib.parse.quote` ile Türkçe
  karakter/boşluk güvenli kodlanıyor). `app.py`'de Tarif Kütüphanesi
  sayfasına sabit bir URL yolu (`url_path="tarif-kutuphanesi"`) verildi.
  Tarif Kütüphanesi sayfası açılışta `st.query_params`'tan "tarif"
  değerini okuyup, varsa o tarifi otomatik seçili getiriyor (yoksa
  normal ilk sıradaki tarife düşüyor, hata vermiyor).

### 3 Ağustos 2026 — VII. Oturum (devam): Aktif/Pasif İşçilik Ayrımı + Genel Gider Geçici Kaldırma
- Kullanıcı Kuzu Tandır'da işçilik 15,83€ (aşırı yüksek), enerji 0,00€
  (Q=mcΔT formülünün uzun ısıl işlemlerde ekipman ısı kaybını
  hesaba katmaması yüzünden) ve genel gider bulgularını doğru tespit
  etti — üçü de gerçek sorun.
- **Genel gider payı Tarif Kütüphanesi'nden ŞİMDİLİK tamamen çıkarıldı**
  (kullanıcı kararı) — sadece malzeme+enerji+işçilik gösteriliyor.
- **Aktif/pasif işçilik ayrımı eklendi** (kullanıcı kararı, küçük şema
  değişikliği): `recete_asamalari`'ye `aktif_dakika` sütunu eklendi
  (`33_aktif_dakika_ekle.sql`). NULL = eski davranış (sure_dakika ile
  aynı, GERİYE UYUMLU — mevcut kullanıcı reçeteleri bozulmadan çalışmaya
  devam eder). `asama_iscilik_maliyeti` view'i `coalesce(aktif_dakika,
  sure_dakika)` kullanacak şekilde güncellendi (hem kendi reçeteler hem
  kütüphane tarifleri için ortak).
- **`4_Uretim_Asamalari.py`'ye de aynı özellik eklendi** (kullanıcının
  kendi tarifleri için de kullanılabilir): "Bu aşamanın büyük kısmı
  pasif" onay kutusu + "gerçek aktif işçilik süresi" girişi. Ayrıca bu
  dosyada fark edilen bir emoji (🔥, ısıl işlem satırında) kalıcı kurala
  aykırı olduğu için temizlendi.
- **Pilot 3 tarifte düzeltme:** Kuzu Tandır'ın "Ağır Ateş Fırınlama"
  aşaması (165 dk toplam) artık sadece 6 dk aktif işçilik sayıyor;
  Karnıyarık'ın "Montaj ve Fırınlama" aşaması (22 dk toplam) 4 dk aktif
  sayıyor. Yeni işçilik: Kuzu Tandır için ~31 dk (önceden 190 dk).

### 3 Ağustos 2026 — VII. Oturum (devam): Tarif Linkleri Düzeltildi (Göreli → Mutlak Yol)
- Kullanıcı Yıllık Menü'deki yemek linklerinin "saçma sapan yerlere"
  yönlendirdiğini bildirdi. Kök neden: link göreli (relative) yazılmıştı
  (`tarif-kutuphanesi?tarif=...`) — tarayıcı bunu şu anki sayfanın
  ALTINDA bir alt yol gibi yorumluyordu, site kökünden bağımsız değil.
  Başına `/` eklenerek mutlak yola (`/tarif-kutuphanesi?tarif=...`)
  çevrildi — artık hangi sayfadan tıklanırsa tıklansın doğru,
  kök-göreli adrese gidiyor.

### 3 Ağustos 2026 — VII. Oturum (devam): Üretim Aşamaları II. Parti — 27 Ana Yemek Daha
- **Kullanıcı isteği: "maliyet hesabını tüm tariflere uygula".** 241'in
  tamamı tek seferde gerçekçi değil, ama zaten detaylı pişirme talimatı
  yazılmış olan 30 ana yemeğin (74'lük Klasik kütüphane, I. Grup)
  TAMAMI için yapılandırılmış aşama verisi tamamlandı (`asamalar_parti2.py`
  — kalan 27 tarif; ilk 3'ü zaten `asamalar_parti1.py`'de vardı).
- **Basitleştirme kararı:** Ardışık aynı-kap ısıl işlemler (ör.
  "kaynatma" + "ağır kaynama") TEK bir aşamada birleştirildi — ayrı
  tutulsaydı ikinci aşama zaten hedef sıcaklıkta başlayacağından
  Q=mcΔT formülünde ΔT=0 çıkıp enerji maliyetini yanlış sıfırlardı.
  Çoğu tarif 2-3 aşamaya indirgendi (Hazırlık + birleşik Isıl İşlem,
  bazılarında ek Dinlendirme/Montaj).
- **Doğrulama:** Tüm 30 tarifin (a) bağımlılık referansları geçerli,
  (b) ısıl işlem alanları eksiksiz, (c) her aşamaya atanan malzemenin
  GERÇEKTEN o tarifin kendi malzeme listesinde var olduğu programatik
  olarak teyit edildi (0 hata).
- `asama_yukle.py` artık `asamalar_parti1.py` + `asamalar_parti2.py`'yi
  birleştirip tek seferde işliyor (30 tarif, aynı `.bat` ile).
- **Sıradaki adım:** II./III. Grup (çorba/pilav/börek/tatlı, ~45 tarif)
  ve ardından 166 bölgesel tarif için hem pişirme talimatı hem aşama
  verisi kademeli olarak eklenecek.

### 3 Ağustos 2026 — VII. Oturum (devam): Tarif Linki Kökten Düzeltildi (st.page_link)
- **Gerçek kök neden bulundu:** Streamlit'in resmi forum/GitHub kayıtları,
  ham HTML (`<a href>`) linkleriyle alt sayfaya gitmenin BİRDEN FAZLA
  sürümde bilinen, kırılgan bir yöntem olduğunu gösteriyor (Streamlit'i
  "takılı döngüye" sokabiliyor) — benim iki denemem (göreli/mutlak yol)
  de bu yüzden işe yaramadı, sorun yol formatı değil, YÖNTEMİN KENDİSİYDİ.
  Resmi/desteklenen mekanizma `st.page_link()` ve onun `query_params`
  parametresi.
- **Çözüm:** Kart içine gömülü ham HTML linkleri tamamen kaldırıldı
  (`st.page_link` gerçek bir widget olduğu için tek bir HTML string
  bloğu içine gömülemiyor, kart tasarımını bozmadan içine koyulamaz).
  Bunun yerine, üretilen ayın altına AYRI, güvenilir bir "Bir tarifin
  detayına git" bölümü eklendi: o ayda geçen tüm tariflerin listelendiği
  bir seçim kutusu + `st.page_link("pages/5_Tarif_Kutuphanesi.py",
  query_params={"tarif": secilen_tarif})` ile Tarif Kütüphanesi'ne
  doğru tarifle giden resmi bir link butonu.

### 3 Ağustos 2026 — VII. Oturum (devam): Tarif Linki NİHAİ Çözüm — Kart Gerçek Widget'lara Çevrildi
- Kullanıcı kendi hatasını buldu: URL'ler aslında doğru değişiyormuş
  (Tarif Kütüphanesi gerçekten `/tarif-kutuphanesi` adresine gidiyor,
  önceki "hiç değişmiyor" gözlemi bir test hatasıymış). Bu, `st.page_link`
  yönteminin doğru olduğunu kesinleştirdi.
- **Kullanıcı "Bir tarifin detayına git" ayrı seçicisini istemedi**,
  doğrudan yemek isimlerine tıklama deneyimini istedi. Bunun için kart
  görünümü (`_hafta_kart_izgarasi_html`, tek dev HTML string döndüren
  fonksiyon) TAMAMEN kaldırıldı, yerine `_hafta_kartlarini_goster` —
  gerçek Streamlit widget'larıyla (st.columns + st.container(border=True)
  + st.page_link) doğrudan ekrana çizen bir fonksiyon geldi. Artık her
  yemek adı gerçek bir `st.page_link(..., query_params={"tarif": ad})`
  çağrısı, kart görünümü korundu (border=True container).
- **Bilinen görsel ödün:** Eski HTML sürümünde her yemeğin önünde
  grup rengine göre bir nokta (●) vardı (kırmızı/yeşil/teal). `st.page_link`
  kendi görünümünü kullandığı için bu renkli nokta artık yok — üstteki
  "Ana Yemek/Yardımcı Yemek/Tamamlayıcılar" renk lejantı hâlâ duruyor,
  ama satır satır renk eşleşmesi kayboldu. Kullanıcı bunu fark ederse
  ayrıca ele alınabilir (ör. st.page_link'in icon parametresiyle emoji
  DIŞI bir işaretleme denenebilir).
- Önceki geçici "Bir tarifin detayına git" bölümü kaldırıldı (artık
  gereksiz).
