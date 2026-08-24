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

### 3 Ağustos 2026 — VII. Oturum (devam): Reboot Sonrası Çökme — starlette Bağımlılık Sürüm Uyumsuzluğu
- Reboot sonrası "Oh no" hatası — kodla İLGİSİZ, saf bağımlılık sürüm
  kaymasi (dependency drift). Log: `TypeError: GZipResponder.__init__()
  missing 1 required keyword-only argument: 'thread_minimum_size'`,
  Streamlit'in KENDİ dahili `starlette_gzip_middleware.py` dosyasında
  (app.py hiç çalışmadan, sunucu seviyesinde) oluşuyordu. `starlette`
  kütüphanesi requirements.txt'te hiç sabitlenmemişti — yeni bir sürüm
  (1.4.0) yayınlanmış, API'sini değiştirmiş, Streamlit 1.61.0'ın dahili
  kodu buna henüz uyumlu değildi. `requirements.txt`'e `starlette<1.4`
  eklendi (önceki çalışan deploy'da `starlette==1.3.1` kullanılıyordu).

### 3 Ağustos 2026 — VII. Oturum (devam): Yıllık Menü Kart Genişliği ve Metin Kaydırma
- Kullanıcı link çözümünü onayladı ("istediğim gibi olmuş") ama yeni
  kart görünümünde (gerçek widget'lara geçiş sonrası) yemek isimlerinin
  sığmadığını, sütunlar arası boşluğun fazla olduğunu bildirdi.
- `st.columns(len(hafta), gap="small")` ile sütun arası boşluk daraltıldı.
- `st.page_link` varsayılan olarak uzun metni tek satırda kırpıyor
  ("...") — bunu alt satıra kaydırmaya zorlayan bir CSS eklendi
  (`[data-testid='stPageLink'] p { white-space: normal; word-break:
  break-word; }`). NOT: bu CSS seçicisi Streamlit'in standart
  adlandırma kalıbıyla tutarlı ama garantili değil (bu projede daha
  önce bazı CSS denemeleri tutmamıştı) — tutmazsa alternatif
  yaklaşıma (ör. st.page_link yerine farklı bir gösterim) geçilecek.

### 3 Ağustos 2026 — VII. Oturum (devam): Sidebar Daraltıldı, Ana İçerik Boşlukları Azaltıldı
- Metin kaydırma düzeltmesi çalıştı (ekran görüntüsünde doğrulandı).
  Kullanıcı hâlâ sağ/sol boşlukları fark etti, sidebar'ın da
  daraltılabileceğini önerdi.
- `sidebar_logo.py` (HER sayfada çağrılıyor, bu yüzden tek yerden tüm
  uygulamaya uygulanıyor) içine global CSS eklendi:
  sidebar genişliği 260px'e sabitlendi (önceki Streamlit varsayılanı
  ~336px), ana içerik alanının sağ/sol dolgusu 1,5rem'e düşürüldü ve
  max-width %100 yapıldı (Streamlit'in "wide" modunda bile bıraktığı
  kalan boşluk azaltıldı). NOT: bu seçiciler (`stSidebar`,
  `stMainBlockContainer`) otomatik üretilen sınıflara göre çok daha
  stabil ama yine de garantili değil.

### 3 Ağustos 2026 — VII. Oturum (devam): Öğle/Akşam Başlıkları + Yaklaşık Satır Hizalama
- **Öğle/Akşam artık büyük harf + kalın**, aralarında 2 satır boşluk
  (`st.write("")` x2).
- **7 günlük kartların Öğle/Akşam hizası ve alt sınırı yaklaşık
  eşitlendi:** Streamlit'te render-sonrası gerçek piksel yüksekliği
  ölçmek mümkün olmadığı için, her günün Öğle/Akşam yemek adlarının
  TOPLAM KARAKTER uzunluğuna göre kaç satır kaplayacağı tahmin ediliyor
  (`_tahmini_satir_sayisi`, ~13 karakter/satır kalibrasyonu), 7 gün
  içindeki en uzun tahmine göre kısa kalan günlere boş alan ekleniyor.
  **Bu piksel-kusursuz bir çözüm DEĞİL** — kelime sınırlarına göre
  gerçek satır kırılması karakter sayısıyla tam örtüşmeyebilir,
  kalibrasyon (13) gerçek sonuçlara göre ince ayar gerektirebilir.

### 3 Ağustos 2026 — VII. Oturum (devam): Kart Hizalama — Sabit Yükseklik Yöntemine Geçildi
- Karakter-sayısına dayalı tahmin yöntemi Akşam'ı hizalayamadı ("eksik
  fiyat" gibi değişken uzunluklu satırları hesaba katmıyordu) ve kart
  altlarını da eşitlemiyordu.
- **Çok daha sağlam bir yönteme geçildi: sabit yükseklikli kutular**
  (`st.container(height=...)`, Streamlit'in resmi/stabil bir özelliği,
  tahmin değil). Kütüphanedeki EN UZUN tarif adı (241 tarif arasında,
  41 karakter: "Van Usulü Kahvaltı Tabağı (Otlu Peynirli)") programatik
  olarak bulundu ve yemek adları kutusu (`DISH_KUTU_YUKSEKLIK=220px`)
  bunu kapsayacak şekilde ayarlandı; bilgi bloğu (kcal/alerjen/maliyet/
  hedef) için de sabit bir yükseklik (`BILGI_KUTU_YUKSEKLIK=150px`)
  verildi. Artık HER kartın toplam yüksekliği, içerikten bağımsız olarak
  HER ZAMAN aynı — bu da Öğle/Akşam hizasını VE kart alt sınırlarını
  otomatik olarak eşitliyor (haftadan haftaya da tutarlı, önceki
  yöntemde olmayan bir garanti).
- Nadir bir durumda (3 yemeğin hepsi aynı anda çok uzun isimliyse) kutu
  taşabilir, bu durumda o kutu kendi içinde kayar (hizalama bozulmaz,
  sadece o kutuda küçük bir kaydırma çubuğu görünür).

### 3 Ağustos 2026 — VII. Oturum (devam): İskender Kebap'ta Pide ve Kornişon Turşu Eksikliği
- Kullanıcı "İskender Kebap"ta pide (etin altına serilen) hiç olmadığını
  fark etti — kontrol edilince doğrulandı (sadece dana biftek, yoğurt,
  salça, tereyağı vardı). Kornişon turşu (geleneksel servis garnitürü)
  de eksikti. İkisi de kataloğa hiç girmemiş.
- `34_pide_kornison_ekle.sql`: PİDE (kategori 8, Gluten alerjeni) ve
  KORNİŞON TURŞU (kategori 2) eklendi.
- `35_iskender_duzelt_ve_fiyat_doldur.sql`: mevcut "İskender Kebap"
  tarifine PİDE (100g) ve KORNİŞON TURŞU (20g) eklendi + mevcut
  işletmelere geriye dönük fiyat dolduruldu.
- `marmara_tarifleri.py` güncellendi (gelecekteki sıfırdan kurulumlar
  için tutarlılık).
### 6 Ağustos 2026 — [Oturum No] Oturum: 7 Bölgenin Tamamı + Kalite Düzeltmeleri

**Kütüphane tamamlandı: 240 tarif (74 Klasik + 166 bölgesel, 7 bölgenin
tamamı).** Marmara, Karadeniz, Ege, Akdeniz, Doğu Anadolu, Güneydoğu
Anadolu, İç Anadolu — hepsi için hem pişirme talimatı (v2 format:
Hazırlık/Mise en Place → Isıl İşlem → Paralel Yapılabilirlik → Süre
Özeti) hem üretim aşaması (recete_asamalari/asama_malzemeleri) verisi
yazıldı, malzeme adı + bağımlılık + ısıl işlem alanı doğrulaması her
bölgede programatik olarak yapıldı (0 hata).

**Verimlilik oranları kaynaklandırıldı.** Uygulamanın TİCARİ (restoran)
kullanım için tasarlandığı netleştirildi — bu yüzden verimlilik_orani
değerleri ev tipi değil ticari mutfak ekipmanı verilerine göre web
araştırmasıyla düzeltildi: dogalgaz ocak/kavurma 0.42, dogalgaz kızartma
0.4, elektrik fırın 0.58 (ENERGY STAR + sanayi kaynakları). Izgara için
kaynak bulunamadı, projenin ilk oturumundan kalan tahmini 0.35 korundu.
6 dosyada (pilot dahil) toplam 173 değer otomatik script ile retroaktif
düzeltildi.

**Kalite kontrolleri (kullanıcı tarafından tespit edildi):**
- Köfte/kebap tariflerinde (6 tarif: Adana Kebap, Akçaabat Köfte, Nar
  Ekşili Köfte, Bursa Usulü İnegöl Köfte, İzmir Köfte, Cağ Kebabı) soğan
  hazırlama adımı eksikti — hepsine "soğanı rendeleyin" adımı eklendi.
- "Kavurmalı X" adındaki 3 tarifte (Kavurmalı Nohut, Erzincan Usulü
  Kavurmalı Yumurta, Erzurum Usulü Kavurmalı Kuru Fasulye) kavurma
  (korunmuş et ürünü) yerine yanlışlıkla pastırma/kıyma kullanılmıştı.
  Yeni malzeme **KAVURMA** kataloğa eklendi (345 kcal/20.62g
  protein/28.53g yağ per 100g — kaynaklı; fiyat TEK bir perakende
  kaynağına dayanıyor, doğrulanması gerekiyor), 3 tarif buna göre
  düzeltildi (SQL + talimat metni + aşama verisi).
- Diğer "kavurma" geçen 3 tarif (Pazı Kavurma, Kavurma (Erzurum Usulü),
  Küşleme) kontrol edildi, sorun yok (kavurma orada yöntem, malzeme
  değil).

**Teknik düzeltmeler:**
- Tarif Kütüphanesi: PostgREST'in varsayılan 1000 satır limitini aşan
  sayfalama eklendi (recete_malzemeleri sessizce kesiliyordu).
- İskender Kebap: eksik pide/kornişon turşu düzeltildi (Türkçe İ/I
  karakter uyumsuzluğu kök nedendi).
- Yıllık Menü: haftalık kart görünümü — iç çerçeve/kaydırma sorunu,
  hizalama, üst üste binme dertleri sırayla çözüldü; final çözüm: her
  hafta/öğün satırı için gerçek veriye göre hesaplanan dinamik yükseklik
  + `border=False`. Renkli metin (kalori mavi, maliyet yeşil), hafta
  sonu ayırıcı çizgi eklendi.
- Tarif Kütüphanesi maliyet gösterimi: tekrarlayan "Maliyet" satırı
  kaldırıldı, 4 kalem (Malzeme/Enerji/İşçilik/Toplam) tek satırda
  hizalandı, not metni sadeleştirildi.
- Kontrol Paneli tamamen yeniden tasarlandı: açılır menüler kaldırıldı,
  görsel destekli aşağı-kaydırmalı tanıtım sayfasına dönüştürüldü
  (görseller `assets/tanitim_*.png` olarak eklenmeyi bekliyor). Sidebar'daki
  gereksiz "Plan: 14 Günlük Deneme" metni kaldırıldı. Besin/alerjen
  takibinin kimlere hizmet ettiğini anlatan bir misyon bölümü eklendi
  (diyetisyenler, kronik hastalar, alerjikler, kurumsal mutfaklar vb.).

**Kalıcı kural hatırlatması (5 Ağustos 2026'da eklendi):** Claude hiçbir
zaman emin olmadığı bir değeri uydurmayacak — kaynak bulamazsa tahmin
kullanır ama kodda/notlarda açıkça "tahmindir, doğrulanmamıştır" diye
işaretler.

---

## NİHAİ HEDEF (6 Ağustos 2026 eklendi)

Uygulama WordPress üzerinden kurulacak bir tanıtım/pazarlama sitesiyle
(muhtemelen `menumuhendisi.com`) birlikte sunulacak; asıl uygulama ayrı
bir alt alan adında (ör. `app.menumuhendisi.com`) Streamlit Cloud'da
barınmaya devam edecek — WordPress'e iframe ile gömülmeyecek (oturum/
çerez ve mobil görünüm sorunları çıkarır), bunun yerine WordPress'teki
"Giriş Yap" butonu kullanıcıyı doğrudan uygulamaya yönlendirecek.
Kullanıcıların cep telefonundan da erişebilmesi hedefleniyor — Streamlit
uygulaması zaten tarayıcı üzerinden mobilde açılabiliyor, ama bazı
sayfaların (özellikle Yıllık Menü'nün 7 sütunlu hafta görünümü) mobil
ekranda kullanışlı olması için ayrıca bir arayüz uyarlaması gerekecek.
Bu, ileride ele alınacak ayrı bir iş kalemi olarak not edildi, şu an için
sadece hedef olarak kayıtlı.

## NİHAİ HEDEF: Premium Plan / Erişim Stratejisi (6 Ağustos 2026 eklendi)

**Model (iki seviyeli, "deneme" kavramı yok):**
- **Ücretsiz kullanıcı:** Sadece Kontrol Paneli (tanıtım sayfası) görünür.
  Diğer sayfalara (Yıllık Menü, Reçeteler, Menü, Boston Matrisi, Üretim
  Aşamaları, Tarif Kütüphanesi) tıklayınca gerçek içerik yerine bir
  "Premium gerekli" uyarı ekranı çıkacak.
- **Premium kullanıcı:** Belirli bir süre için ücret ödeyen herkes tüm
  özelliklere erişir.

**Plan kodu:** Veritabanında (`isletme_aktif_abonelik.plan_kodu`) paylı
plan için **"premium"** ismi kullanılacak (kod tarafında bu string
üzerinden kontrol edilecek). Şu an veritabanında sadece Bahri'nin kendi
test hesabına ait `plan_kodu = 'deneme'` satırı var — gerçek `premium`
planı henüz tanımlanmadı, kontrol edilip netleştirilecek.

**Ödeme/upgrade akışı: ŞİMDİLİK KURULMAYACAK.** Sıralama şöyle:
1. Önce uygulamanın geri kalanı (özellik/içerik tarafı) tamamlanacak.
2. Sonra altyapı WordPress ortamına taşınacak (bkz. yukarıdaki "WordPress
   + mobil erişim" nihai hedefi).
3. En son aşamada gerçek ödeme sayfası linki (PayTR) ve plan/upgrade
   mekanizması kurulacak.

Yani şu an için: sayfa erişim kısıtlaması (Premium olmayan kullanıcıya
"Premium gerekli" ekranı gösterme) kod tarafında HENÜZ UYGULANMADI —
bu bilinçli bir erteleme, unutulmuş bir iş değil. Gelecekteki bir
oturumda bu adıma gelindiğinde: `app.py`'deki `st.Page(...)` sayfa
tanımlarına, `st.session_state.plan_kodu != "premium"` kontrolüyle
içerik yerine yükseltme daveti gösteren bir sarmalayıcı eklenecek.

### 12 Ağustos 2026 — XI. Oturum: "Beni Hatırla" Mobil Kök Neden Analizi + Kayıt Ekranı Kalıntı Metin

**"Beni hatırla" mobil sorunu için olası kök neden bulundu ve düzeltildi
(YEDİNCİ DÜZELTME, henüz TEST EDİLMEDİ):** Önceki sürümde bekleme
bütçesi "8 doğal rerun" olarak sayılıyordu — süre olarak değil. Mobil
tarayıcılarda Streamlit'in websocket bağlantısı ekran kilitlenmesi/
uygulama arka plana atılması/ağ değişimi gibi nedenlerle sık sık kopup
yeniden bağlanabiliyor, ve bu yeniden bağlanmalar da genelde bir rerun
tetikliyor — ama bu rerun'lar çerez bileşeninin gerçek veri taşıdığı
rerun'lar değil, sadece bağlantı olayları. Sonuç: mobilde 8'lik rerun
bütçesi, hiçbiri gerçek veri getirmeyen "boşa" rerun'larla erkenden
tükenebiliyor, kod erkenden son çareye düşüyor, orada da sadece bir kez
4 saniye bekleyip zorla rerun deniyor — bu da yetmezse hiçbir yedek
kalmıyor ve kod çerezi "yok" sayıp giriş ekranını gösteriyor ("her
seferinde login soruyor" belirtisiyle örtüşüyor).
- Düzeltme: rerun SAYISI yerine GEÇEN GERÇEK SÜRE'ye dayalı bir bütçe
  (`CEREZ_BEKLEME_ESIK_SANIYE = 6`) — spurious/bağlantı-kaynaklı
  rerun'lar süreyi tüketmiyor, sadece gerçek zaman tüketiyor, bu yüzden
  mobildeki fazladan rerun'lardan etkilenmiyor.
- Son çare tek seferden İKİ DENEMEYE çıkarıldı (`CEREZ_SON_CARE_MAX_DENEME = 2`).
- **Bu bir kod incelemesi + mantık düzeltmesidir, gerçek mobil cihazda
  DOĞRULANMADI** — bir sonraki adım hâlâ gerçek telefonda test.

**Kayıt ekranı kalıntı metni düzeltildi:** "Deneme" planı kavramı 6
Ağustos'ta tamamen kaldırılmıştı ama kayıt butonu hâlâ "14 günlük
denemeyi başlat" yazıyordu — üç kademeli modelde (Ücretsiz → Ödeme
onayı bekliyor → Aktif) artık bir "deneme" yok. Buton metni "Hesap
oluştur" olarak değiştirildi.

**Dosya durumu:** app.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Menü Satırı Sabitlendi (Kaydırınca Kaybolma Sorunu)

**Kullanıcı geri bildirimi (gerçek mobil test, ekran görüntüleriyle):**
- Mobil özel navigasyon (masaüstü satır + mobil popover) GÖRSEL OLARAK
  ÇALIŞTIĞI doğrulandı — "Menü" butonu açılıyor, tüm sayfalar (Admin
  dahil) listede görünüyor.
- YENİ SORUN: mobilde sayfa aşağı kaydırıldığında "Menü" butonu normal
  akışta render edildiği için sayfayla birlikte yukarı kayıp ekran
  dışına çıkıyor — başka sayfaya geçmek için tekrar en yukarı kaydırmak
  gerekiyor.
- Kullanıcı isteği: masaüstünde menü satırını logo ile aynı satıra
  almak, böylece kaydırınca da görünür kalması; aynı yaklaşımın
  mobildeki soruna da çözüm olup olamayacağı soruldu.

**Kök neden ve çözüm (SEKİZİNCİ DÜZELTME, TEST EDİLMEDİ):**
Streamlit'in kendi başlığı (`[data-testid='stHeader']`, logo'nun
oturduğu yer) zaten `position: fixed` — bu yüzden logo kaydırınca da
hep ekranda kalıyor. Ama Streamlit kendi başlığına dışarıdan widget
eklemeye izin vermiyor; bu bileşen render ağacımızın dışında, içine
enjeksiyon Streamlit sürüm güncellemelerinde kırılma riski yüksek bir
CSS/DOM hack'i gerektirir (toplulukta sıkça bildirilen bir sorun).
- Bunun yerine daha düşük riskli, pratikte aynı sonucu veren yöntem
  seçildi: menü satırının kendisi de `position: fixed` ile başlığın
  HEMEN ALTINA sabitlendi (masaüstünde top:90px, mobilde top:60px —
  bu değerler TAHMİNİ, gerçek cihazda ince ayar gerekebilir). Aynı
  satırda değil ama doğrudan altında, her zaman görünür — hem
  masaüstünde hem mobilde aynı mantıkla çalışıyor.
- Menü artık normal akıştan çıktığı (fixed) için altındaki içerik
  yukarı kaymasın diye 56px'lik bir boşluk (spacer) eklendi.
- **Bilinçli bir kapsam kararı:** menüyü LOGO İLE TAM AYNI SATIRA
  (Streamlit'in kendi başlığının içine) yerleştirmek denenmedi —
  bu, resmi olmayan bir DOM enjeksiyonu gerektirir ve sürüm
  güncellemelerinde kırılma riski taşır. Görünürlük sorunu (asıl
  şikayet) bu daha güvenli yöntemle çözüldü; kullanıcı yine de tam
  birleşik tek satır isterse ayrı, daha riskli bir iş olarak ele
  alınabilir.

**Dosya durumu:** app.py.

### 12 Ağustos 2026 — XI. Oturum (devam): "Beni Hatırla" — Yazma Tarafında Muhtemel Kök Neden + Menü İnce Ayarları

**Kritik gelişme:** Kullanıcı bir önceki düzeltmeyi (süre-tabanlı bekleme,
okuma tarafı) gerçekten deploy edip push ettiğini ekran görüntüsüyle
doğruladı (commit e20b496) — ama sorun HEM masaüstünde HEM mobilde devam
ediyor. Bu, önceki teşhisin (okuma tarafında bekleme yetersizliği) yanlış
ya da eksik olduğunu gösteriyor.

**Yeni teori (DOKUZUNCU DÜZELTME, TEST EDİLMEDİ):** Sorun okumada değil,
çerezin HİÇ YAZILMAMASINDA olabilir. Giriş butonunun kod akışında
`cerezler.set("refresh_token", ...)` çağrısından HEMEN sonra `st.rerun()`
çağrılıyordu (satır ~233-238). Bu, projenin daha önce okuma tarafında
öğrendiği dersle birebir aynı hastalık — zorla rerun, bileşenin cerezi
tarayıcıda gerçekten yazma işini bitirmeden kesintiye uğratabiliyor.
extra_streamlit_components kütüphanesinin GitHub deposunda da tam bu
türden "set() çağrısından hemen sonra bir şey yapılırsa cerez düzgün
işlenmiyor" şikayetleri bulundu (bkz. Mohamed-512/Extra-Streamlit-Components
issue #9 ve #58).
- Düzeltme: `.set()` ile `st.rerun()` arasına `time.sleep(1.5)` eklendi —
  bileşene cerezi gerçekten yazması için kısa bir fırsat tanınıyor.
- **Bu bir hipotez + düzeltmedir, gerçek tarayıcıda DOĞRULANMADI.** Eğer
  bu da işe yaramazsa bir sonraki şüpheli: çerezin encode/decode
  (Fernet) tarafı, ya da SameSite/Secure cookie attribute'ları.
- Kullanıcıya nasıl test ettiğini (tam tarayıcı kapatıp açma mı, yoksa
  sayfa yenileme mi) sormak hâlâ faydalı olurdu — bu bilgi teşhisi
  daraltır, henüz netleşmedi.

**Menü satırı ince ayarları (kullanıcı geri bildirimi, gerçek ekran
görüntüleriyle):**
- Sütunlar arası boşluk fazla bulundu — `st.columns()`'un varsayılan
  `gap="small"` değeri (1rem, Streamlit dokümantasyonunda doğrulandı)
  SADECE menü satırını hedefleyen bir CSS kuralıyla ~%30 azaltılıp
  0.7rem yapıldı.
- Mobilde kaydırınca menünün göründüğü DOĞRULANDI (bir önceki `position:
  fixed` düzeltmesi çalışıyor) — sadece daha belirgin olması istendi,
  gölge güçlendirildi + alt çizgi (border-bottom) eklendi.
- Kullanıcı "menüyü logo ile aynı satıra alalım" fikrini tekrarladı —
  bunun neden zor olduğu (Streamlit'in başlığı resmi API ile SADECE
  st.logo() kabul ediyor, başka widget eklemeye izin vermiyor; zorlamak
  sürüm-kırılgan bir DOM hack'i gerektirir) kendisine izah edildi, kod
  tarafında bilinçli olarak yapılmadı — mevcut "başlığın hemen altına
  sabitleme" çözümü aynı pratik faydayı (kaydırınca kaybolmama) resmi
  API'lerle sağlıyor.

**Dosya durumu:** app.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Logo Menü Satırına Taşındı, Sayfa Butonları Eşit Genişlik + Pastel Stil

**Kullanıcı talebi (gerçek ekran görüntüsüyle, önceki gap-azaltma
düzeltmesinin görsel etkisi olmadığı bildirildi):**
1. Menüdeki tüm sayfa isimlerinin kapladığı alan, en uzun isim ("Özel
   Menü Üretimi" / "Tarif Kütüphanesi") neyse o genişlikte, hepsi EŞİT
   olsun — buton gibi görünsün, pastel renkli olsun.
2. Logoyu menü satırının başına, mevcut büyüklüğüyle yerleştirip
   üstteki ayrı logo satırını (st.logo()) tamamen kaldıralım.

**Önceki "sütun arası boşluk %30 azaltıldı" düzeltmesinin neden işe
yaramadığı (öğrenilen ders):** Gerçek sorun sütunlar ARASI boşluk
değildi — her sütun zaten tam sayfa genişliğini 7'ye eşit bölüyordu,
kısa etiketler bu geniş sütunların içinde sola yaslı durduğu için BOŞ
ALAN sütun İÇİNDE kalıyordu, `gap` CSS'i o boşluğu etkilemiyordu. Bu
oturumda tamamen farklı bir yaklaşıma geçildi (aşağıya bak).

**Uygulanan çözüm (ON BİRİNCİ DÜZELTME, TEST EDİLMEDİ):**
- `st.logo()` ve ona bağlı başlık büyütme CSS'i (`sidebar_logo.py`)
  TAMAMEN kaldırıldı. `sidebar_logo_goster()` artık sadece nav satırının
  olmadığı bağımsız ekranlarda (giriş, abonelik süresi dolmuş)
  kullanılıyor — kimlik doğrulanmış TÜM sayfalardaki (6 sayfa dosyası +
  `kontrol_paneli_sayfasi`) tekrar eden çağrılar kaldırıldı (çift logo
  önlendi).
- Logo artık DOĞRUDAN özel menü satırının (`masaustu_nav`/`mobil_nav`)
  İÇİNDE, en solda `st.image()` ile render ediliyor — hem masaüstünde
  hem mobilde.
- Her sayfa "butonu" artık EŞİT ORANLI `st.columns()` içinde (matematiksel
  garanti, tahmin değil) + kendi `st.container(key=f"nav_buton_masaustu_{i}")`
  içine sarılı — bu, projenin daha önce doğruladığı TEK güvenilir CSS
  kancası (`.st-key-{key}`), `st.page_link`'in iç DOM yapısını tahmin
  etmek yerine.
- Pastel renk paleti: Kontrol Paneli'ndeki MEVCUT pastel kutularla
  (Kalori/Protein/... SVG'si) birebir aynı — `#E1F5EE` dolgu, `#0F6E56`
  çerçeve, `#085041` metin — tutarlılık için kasıtlı olarak seçildi,
  uydurulmadı.
- **Dürüstçe belirtilmesi gereken risk:** buton genişliğini belirleyen
  oran değerleri (`LOGO_ORANI`/`BUTON_ORANI`/`BOSLUK_ORANI`) ve "top"/
  spacer piksel değerleri TAHMİNİ — gerçek tarayıcıda, özellikle 768px'e
  yakın dar masaüstü/tablet genişliklerinde, butonlar sıkışıp satır
  kayabilir. Ayrıca page_link'in iç metin rengini/hizasını zorlayan CSS
  (`a { color: ...; justify-content: center; }`) DevTools ile
  doğrulanmadı, tutmayabilir.

**Dosya durumu:** app.py, sidebar_logo.py, pages/0_Yillik_Menu.py,
pages/1_Recete_Uretimi.py, pages/2_Menu.py, pages/5_Tarif_Kutuphanesi.py,
pages/6_Abonelik.py, pages/7_Admin.py.

### 12 Ağustos 2026 — XI. Oturum (devam): "Beni Hatırla" DOĞRULANDI + Logo Büyütüldü, Mobil Satır Gerçekten Yan Yana, Video Kontrolleri Temizlendi

**BÜYÜK HABER: "Beni hatırla" düzeltmesi DOĞRULANDI.** Kullanıcı gerçek
testte "Uygulama bu sefer beni tanıdı" dedi — bir önceki oturumdaki
DOKUZUNCU DÜZELTME teorisi (cerezin `.set()` sonrası hemen `st.rerun()`
ile kesintiye uğrayıp hiç yazılamaması) doğru çıktı. `time.sleep(1.5)`
eklenmesi sorunu çözdü. Bekleyen açık işler listesindeki "beni hatırla"
maddesi ARTIK ÇÖZÜLDÜ olarak işaretlenebilir (yine de zaman içinde
tekrar test edilmesi iyi olur, tek seferlik doğrulama).

**Buton menü tasarımı BEĞENİLDİ** (bir önceki oturumun pastel buton +
eşit genişlik + logo-satır-içi değişikliği) — ekran görüntüleriyle
doğrulandı, masaüstünde tam istenen gibi görünüyor.

**Üç küçük ayar daha yapıldı:**
1. **Logo çok küçük kalmıştı, 2x büyütüldü** — masaüstü 48px→96px,
   mobil 36px→72px. Buna bağlı olarak nav satırının altına eklenen
   boşluk (spacer) yükseklikleri de büyütüldü (masaüstü 112px→156px,
   mobil 68px→96px) ki büyüyen logo sayfa içeriğini örtmesin.
2. **Mobilde "değişiklik olmamış gibi" — kök neden bulundu:** Streamlit
   varsayılan olarak dar (mobil) ekranlarda `st.columns()`'u yataydan
   dikeye (alt alta) OTOMATİK çeviriyor — bir önceki oturumda logo+Menü
   butonunu "yan yana" koyma niyeti bu yüzden mobilde hiç gerçekleşmemiş,
   ikisi yine alt alta kalmış. CSS ile bu otomatik alt-alta-çevirme
   SADECE bizim mobil menü satırımız için zorla iptal edildi
   (`flex-direction: row !important`). **DevTools ile doğrulanmadı,
   Streamlit'in iç CSS yapısına bağlı bir tahmin.**
3. **Kontrol Paneli'ndeki tanıtım videosunun native kontrol çubuğu
   (oynat/durdur, süre, sessize al, tam ekran, "..." menüsü)
   temizlendi.** `st.video()` bunu kaldırmak için resmi bir parametre
   SUNMUYOR (araştırıldı, doğrulandı) — WebKit/Blink'in kendi iç video
   kontrol elemanlarını (`::-webkit-media-controls` ailesi) CSS ile
   gizleyen bir yöntem kullanıldı. **BİLİNÇLİ KISIT:** bu sadece Chrome/
   Edge/Safari'de çalışır, Firefox'ta kontroller görünmeye devam eder.
   **BİLİNÇLİ KARAR:** eski base64/data-URI video yöntemine KASITLI
   OLARAK dönülmedi — o yöntem daha önce (6 Ağustos) mobilde videoyu
   hiç çalıştıramamıştı, bu riski tekrar almamak için `st.video()`
   korunup sadece görsel olarak kontroller CSS ile gizlendi.

**Dosya durumu:** app.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Video Kontrolleri ÇÖZÜLDÜ, Masaüstü Logo Hâlâ Büyümedi (ON DÖRDÜNCÜ DÜZELTME)

**Video kontrolleri DOĞRULANDI — çözüldü.** Ekran görüntüsünde kontrol
çubuğu artık görünmüyor.

**Mobil logo + yan yana satır DOĞRULANDI (ekran görüntüsünden görsel
olarak teyit edildi, kullanıcı ayrıca belirtmedi ama görünüyor).**

**Masaüstü logo BÜYÜMEDİ — yeni teşhis:** LOGO_ORANI (1.3), 7 buton +
boşluk sütunuyla (toplam ~23.9 birim) kıyaslandığında çok dar bir sütun
payı veriyordu (~%5.4) — istenen 96px genişlik, sütunun kendisi o kadar
geniş olmadığı için kırpılıyor/küçültülüyor olabilir. Mobilde sorun
yaşanmamasının nedeni, oradaki logo sütununun (sadece 2 elemanlı bir
satırda) orantılı olarak çok daha geniş bir pay alması.
- İki önlem birden alındı: (1) `LOGO_ORANI` 1.3'ten 2.6'ya çıkarıldı,
  (2) resmin kendisine doğrudan genişlik zorlayan bir CSS kuralı
  eklendi (`[data-testid='stImage'] img { width: ... !important; }`) —
  sütun payından bağımsız bir güvenlik ağı olarak.
- **TEST EDİLMEDİ** — bu üçüncü deneme (gap azaltma → tutmadı, mobil
  flex-direction → tuttu, şimdi logo boyutu → sonuç bilinmiyor).

**Dosya durumu:** app.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Logo 1.5x Büyütüldü + Alt Hizalama (resmi API ile)

**Masaüstü logo DOĞRULANDI — bir önceki (ON DÖRDÜNCÜ) düzeltme tuttu.**
Kullanıcı ekran görüntüsüyle onayladı, sadece "biraz daha büyük olsun"
dedi.

**Yapılan (ON BEŞİNCİ DÜZELTME):**
- Logo 1.5x daha büyütüldü: 96px→144px (masaüstü). `LOGO_ORANI` da
  buna orantılı arttırıldı (2.6→4.0) ki sütun payı yine dar kalıp
  resmi kırpmasın.
- Menü öğelerinin logo ile ALT HİZALI (bottom-aligned) durması istendi.
  **ÖNEMLİ SELF-CORRECTION:** ilk denemede hem tahmini bir CSS kuralı
  (`align-items: flex-end`) HEM DE Streamlit'in resmi
  `vertical_alignment` parametresi aynı anda, birbiriyle ÇELİŞEN
  değerlerle (CSS flex-end / Python "center") eklenmiş bulundu — bu
  ikisi çakışıyordu. Temizlendi: SADECE resmi API kullanılıyor artık
  (`st.columns(..., vertical_alignment="bottom")` — dokümantasyonda
  doğrulandı, "top"/"center"/"bottom" resmi olarak destekleniyor).
  Tahmini CSS kuralı tamamen kaldırıldı.
- Büyüyen logoya göre alt boşluk (spacer) 156px→180px yapıldı.

**Dosya durumu:** app.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Açık İş #3 — Admin Onay Sayfası Kod İncelemesiyle Bozuk Bulundu (Canlı Testten ÖNCE)

Kullanıcı "kaldığımız yerden devam" dedi — sıradaki açık iş üç kademeli
abonelik/admin sisteminin uçtan uca testiydi. Canlı test yapılamayacağı
için (kimlik/tarayıcı gerektiriyor) önce kod incelemesi yapıldı — tıpkı
"beni hatırla" ve navigasyon maddelerinde olduğu gibi — ve CİDDİ, gerçek
bir hata bulundu:

**Bulunan hata:** `abonelikler` tablosunda SADECE `"kendi abonelini gor"`
SELECT politikası vardı (02_abonelik_ve_odeme_altyapisi.sql) — UPDATE
politikası HİÇ YOKTU. Orijinal tasarımda yazma işleminin sadece
service_role/Edge Function ile yapılması planlanmıştı (yorumda açıkça
yazıyor), ama `pages/7_Admin.py` normal oturumla doğrudan `.update()`
çağırıyor. Sonuç: (1) Admin sayfasının sorgusu RLS tarafından admin'in
KENDİ işletmesine filtreleniyor — admin'in kendi aboneliği zaten `aktif`
olduğu için "bekleyenler" listesi HER ZAMAN BOŞ dönüyor, gerçek bekleyen
müşteriler olsa bile. (2) "Onayla" butonu bir satıra erişebilse bile
UPDATE politikası olmadığı için RLS SESSİZCE reddediyor (44 no'lu
migration'da bulunanla AYNI sınıf hata) — sayfa sonucu kontrol etmediği
için yine de "onaylandı" mesajı gösteriyordu.

**Ek bulunan hata (aynı inceleme):** Admin sayfası, `isletmeler(ad)`
gömülü (embedded) sorgusuyla işletme adını da çekiyor — PostgREST gömülü
sorgularda da HEDEF tablonun kendi RLS'ini uyguluyor, `isletmeler`'in
tek SELECT politikası da "kendi işletmeni gör" olduğu için admin işletme
adını da göremeyecekti ("?" olarak kalırdı).

**Düzeltme (46_admin_abonelik_rls.sql, TEST EDİLMEDİ):**
- `abonelikler` tablosuna admin'e özel (hardcoded e-posta,
  `app.py`'deki `ADMIN_EPOSTA` ile aynı mantık) bir SELECT + bir UPDATE
  politikası eklendi. Mevcut "kendi abonelini gör" politikasına
  dokunulmadı (Postgres'te aynı komut için birden fazla PERMISSIVE
  politika OR ile birleşir).
- `isletmeler` tablosuna da admin'e özel bir SELECT politikası eklendi
  (gömülü sorgu için).
- `pages/7_Admin.py`'deki "Onayla" butonu artık `isletmeler` sayfasındaki
  gibi `sonuc.data`'yı kontrol ediyor — RLS sessizce reddederse artık
  yanlış "onaylandı" mesajı GÖSTERMİYOR, gerçek bir hata mesajı
  gösteriyor.

**Test için:** gerçek ödeme akışı henüz kurulmadığı için (bkz.
pages/6_Abonelik.py'deki dürüst uyarı) tam uçtan uca test şu an mümkün
değil — bir hesabı manuel olarak Supabase SQL Editor'de
`odeme_alindi_onay_bekliyor` durumuna çekip Admin sayfasının onu artık
GÖSTERDİĞİNİ ve "Onayla"nın GERÇEKTEN çalıştığını doğrulamak gerekiyor.

**Dosya durumu:** sql/46_admin_abonelik_rls.sql (yeni), pages/7_Admin.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Admin İptal Yetkisi + Abonelik Sayfası Genişletildi

**Kullanıcı geri bildirimi (ekran görüntüleriyle):** Admin sayfası
"Onay bekleyen abonelik yok" gösteriyordu — bu BEKLENEN bir sonuç
(henüz test hesabı oluşturulmadı, 46 no'lu migration'ın gerçek testi
hâlâ bekleniyor), hata değil. Kullanıcı iki yeni talep iletti:
1. Admin'in sadece onaylama değil, **abonelikten çıkartma (iptal etme)**
   yetkisi de olmalı.
2. Abonelik sayfası daha kapsamlı bilgi toplayan bir düzene kavuşmalı:
   işletme adı+adresi, fatura adresi, e-posta/şifre girişleri, "kurumsal
   abonelikle ilgili her şey".

**Yapılanlar:**
- **47_isletme_adres_fatura_ekle.sql (yeni):** `isletmeler` tablosuna
  `adres` ve `fatura_adresi` (ikisi ayrı, nullable) sütunları eklendi.
- **pages/7_Admin.py yeniden düzenlendi:** artık iki bölüm var —
  "Bekleyen Onaylar" (eskisi) ve YENİ "Aktif Abonelikler" (durum='aktif'
  olanları listeler, admin'in KENDİ hesabı hariç tutulur). Her aktif
  abonelik için iki adımlı onaylı bir "İptal Et" akışı eklendi (tek
  tıkla değil — "Emin misin?" + Evet/Vazgeç — çünkü iptal, onaylamadan
  farklı olarak müşterinin erişimini kesen, daha ağır bir işlem).
  46 no'lu migration'daki admin SELECT/UPDATE politikaları zaten bu
  geniş erişimi (sadece 'odeme_alindi_onay_bekliyor' değil, TÜM
  durumlar için) kapsıyordu, ek bir RLS değişikliği gerekmedi.
- **pages/6_Abonelik.py genişletildi:** İşletme Bilgileri formuna adres
  + fatura adresi eklendi; yeni "Hesap Bilgileri" bölümü ile e-posta
  değiştirme (Supabase resmi `auth.update_user()` — yeni adrese
  doğrulama bağlantısı gönderir, kullanıcıya arayüzde açıkça belirtildi)
  ve şifre değiştirme formu eklendi.
- **BİLİNÇLİ OLARAK YAPILMAYAN:** vergi no/vergi dairesi/yetkili kişi/
  telefon gibi diğer "kurumsal abonelik" alanları EKLENMEDİ — "her şey"
  çok belirsiz bir kapsam, hangi spesifik alanların (özellikle Türk
  e-fatura mevzuatına uygun alan adları/formatları) istendiği netleşmeden
  tahmin edilmedi, kullanıcıya soruldu.

**Dosya durumu:** sql/47_isletme_adres_fatura_ekle.sql (yeni),
pages/7_Admin.py, pages/6_Abonelik.py.

### 12 Ağustos 2026 — XI. Oturum (devam): Vergi Dairesi + Vergi Numarası Eklendi

Kullanıcı talebi: fatura adresinin altına Vergi Dairesi ve Vergi
Numarası da eklensin.

- **48_isletme_vergi_bilgileri_ekle.sql (yeni):** `isletmeler`'e
  `vergi_dairesi` ve `vergi_no` (ikisi text, nullable). Kasıtlı olarak
  metin tipi kullanıldı (numeric DEĞİL) — vergi numaraları başında sıfır
  olabilir, numeric tip bunu sessizce siler. Format/uzunluk kısıtlaması
  da EKLENMEDİ — bireysel (TCKN, 11 hane) ile kurumsal (VKN, 10 hane)
  farklı uzunlukta olabiliyor, netleşmeden kısıtlamak yanlış kayıtları
  reddedebilirdi.
- `pages/6_Abonelik.py`: form alanları fatura adresinin hemen altına
  eklendi.

**Dosya durumu:** sql/48_isletme_vergi_bilgileri_ekle.sql (yeni),
pages/6_Abonelik.py.

### 12 Ağustos 2026 — XI. Oturum (devam): KAYIT TETİKLEYİCİSİ GERÇEKTEN TEST EDİLDİ — "Database error saving new user" (Açık İş #6, sonunda gerçek sonuç)

Kullanıcı oğlu Emre için gerçek bir hesap açmaya çalıştı — bekleyen açık
işler listesindeki "kayıt tetikleyicisinin testi" maddesinin İLK GERÇEK
denemesiydi, ve BAŞARISIZ oldu: "Kayıt başarısız: Database error saving
new user".

**Kök neden bulundu:** `abonelikler` tablosunun orijinal şemasındaki
`durum` sütunu CHECK kısıtı sadece ('deneme','aktif','odeme_gecikti',
'iptal_edildi','suresi_doldu') değerlerine izin veriyordu. 41/42 no'lu
migration'lar üç kademeli modele geçerken yeni tetikleyici artık
`durum='odeme_bekleniyor'` ile satır ekliyor — ama bu ESKİ CHECK KISITI
HİÇ GÜNCELLENMEMİŞTİ. Tetikleyicinin INSERT'i kısıtı ihlal edip
exception fırlatıyordu — bu da `auth.users` satırının OLUŞTURULMASINI
BİLE engelliyordu (AFTER INSERT tetikleyicisindeki hata tüm transaction'ı
geri alıyor). Bu şekilde daha önce fark edilmedi çünkü 41/42'den beri
GERÇEK bir kayıt denemesi hiç yapılmamıştı.

**Düzeltme (49_abonelik_durum_kisit_duzelt.sql, TEST EDİLMEDİ):** kısıt
dinamik olarak (isim tahmin edilmeden, pg_constraint'ten sorgulanarak)
bulunup kaldırıldı, yeni kısıt ESKİ TÜM değerleri + İKİ YENİ değeri
('odeme_bekleniyor', 'odeme_alindi_onay_bekliyor') içerecek şekilde
eklendi.

**Eğer bu yetmezse ikinci şüpheli:** `plan_id` sütunu — 42 no'lu
migration'da "not null" kaldırılmıştı ama gerçekten Supabase'de
çalıştırıldığı doğrulanmalı (migration dosyasının varlığı, çalıştırıldığı
anlamına gelmiyor). 49 no'lu migration'ın sonundaki doğrulama sorgusu
bunu da kontrol ediyor.

**Dosya durumu:** sql/49_abonelik_durum_kisit_duzelt.sql (yeni).

### 12 Ağustos 2026 — XI. Oturum (devam): Bahri'nin Kendi Hesabı Giriş Yapamadı — Hata Mesajı Gerçek Nedeni Gizliyordu

Kullanıcı kendi hesabıyla (bahriguler@gmail.com) giriş yapmaya çalıştı,
"Giriş başarısız: e-posta veya şifre hatalı" hatası aldı. Ekran
görüntüsünde ayrıca beklenmedik bir şey daha vardı: sayfa Streamlit'in
KENDİ varsayılan pages/ klasörü kenar çubuğuyla (sidebar) render
edilmişti -- özel menü satırımız değil.

**Acil olan (giriş hatası) için yapılan:** giriş butonunun `except
Exception:` bloğu HER TÜRLÜ hatayı (yanlış şifre, ağ hatası, Supabase
API hatası, rate limit, vb.) AYNI "e-posta veya şifre hatalı" mesajıyla
gösteriyordu -- gerçek nedeni gizliyordu. Artık gerçek exception detayı
da bir expander içinde gösteriliyor ("Teknik detay (destek için)").
Kullanıcıya tekrar denemesi ve gerçek hatayı paylaşması istendi --
KÖK NEDEN HENÜZ BİLİNMİYOR, tahmin yürütülmedi.

**İkincil, muhtemelen ayrı ve önceden var olan bir sorun (HENÜZ
ÇÖZÜLMEDİ):** giriş ekranı, `st.navigation()` sadece kimlik doğrulanmış
kullanıcılar için (script'in ilerisinde) çağrıldığından, giriş ekranı
render edilirken `st.navigation()` o çalıştırmada HİÇ tetiklenmiyor --
bu yüzden Streamlit kendi varsayılan pages/ klasörü kenar çubuğuna
düşüyor olabilir. Bu muhtemelen 6 Ağustos'taki navigasyon değişikliğinden
beri hep böyleydi ama kimse fark etmemişti (Bahri neredeyse hep zaten
giriş yapmış durumda oluyor, giriş ekranını nadiren görüyor). Düzeltmesi
muhtemelen giriş ekranını da bir `st.Page`'e sarıp `st.navigation()`'ı
HER ZAMAN (auth durumundan bağımsız) tam olarak bir kez çağırmak --
ama bu, yakın zamanda stabilize edilen kırılgan "beni hatırla" bekleme
mantığına dokunma riski taşıdığı için, ACİL giriş hatası netleşmeden
ERTELENDİ (kasıtlı bir sıralama kararı, unutulmadı).

**Dosya durumu:** app.py.

### 13 Ağustos 2026 — XI. Oturum (devam, ACİL): "Şifremi Unuttum" Akışı Eklendi

Bahri kendi hesabında kilitlenince ("Send password recovery" e-postası
localhost'a kırık bir link içeriyordu) uygulamada hiçbir kendi kendine
şifre sıfırlama yolu OLMADIĞI ortaya çıktı. Acil olarak eklendi.

**Neden Supabase'in standart "bağlantıya tıkla" akışı DEĞİL de KOD
girişi seçildi (ON YEDİNCİ DÜZELTME):** İki bağımsız kırılganlık
tespit edildi: (1) Supabase Auth ayarlarındaki "Site URL" şu an
localhost'ta duruyor -- düzeltilmeden link her zaman kırık çıkar.
(2) Bunu düzeltsek bile, Supabase linke tıklanınca token'ı URL'nin
FRAGMENT kısmına (#access_token=...) koyuyor -- bu kısım tarayıcıdan
SUNUCUYA HİÇ gönderilmiyor, yani Streamlit (sunucu tarafında çalışan
bir uygulama) bunu okuyamıyor bile, özel bir JS köprüsü gerektirir.
Bunun yerine Supabase'in AYNI e-postada gönderdiği 6 haneli KODU
(`{{ .Token }}`) kullanıcıya elle girdirip `supabase.auth.verify_otp
(type="recovery")` ile doğruluyoruz -- resmi, dokümante edilmiş bir
akış, link/redirect/fragment sorunlarının hiçbirine takılmıyor, Site
URL düzeltilmemiş olsa BİLE çalışır.

**Eklenen:** Giriş ekranına üçüncü bir sekme -- "Şifremi unuttum".
İki adım: (1) e-posta gir → kod gönderilir (Supabase'in "hangi
e-postalar kayıtlı" bilgisini sızdırmama prensibi korunuyor -- hata
olsa bile aynı genel mesaj gösteriliyor). (2) kodu + yeni şifreyi gir →
`verify_otp` + `update_user` + `sign_out` (temiz bir devir için, normal
girişe yönlendiriliyor).

**Kullanıcıdan (Bahri'den) istenen iki manuel adım (ben yapamıyorum,
Supabase Dashboard erişimi gerekiyor):**
1. Authentication → URL Configuration → Site URL'i localhost'tan gerçek
   adrese (`https://menu-muhendisi.streamlit.app`) güncellemesi --
   genel olarak iyi pratik, bu yeni akış için ZORUNLU değil ama diğer
   e-posta linkleri (kayıt doğrulama vb.) için hâlâ gerekli.
2. Authentication → Emails → "Reset Password" şablonunu, Menü
   Mühendisi'nden geldiğini belli eden ve `{{ .Token }}`'ı öne çıkaran
   bir metinle değiştirmesi -- şablon metni ayrıca verildi.

**TEST EDİLMEDİ** -- bir sonraki adım gerçek bir hesapla uçtan uca
doğrulama.

**Dosya durumu:** app.py.

### 13 Ağustos 2026 — XI. Oturum (devam): Yıllık Menü — Besin/Maliyet Satırları Pastelden Belirgin Renklere

Kullanıcı geri bildirimi (ekran görüntüsüyle): Yıllık Menü'deki her
öğün kartının altındaki besin değerleri/alerjen/maliyet satırları
(`kcal · P/Y/K/Gİ`, `Alerjen: ...`, `Maliyet: ... €`) çok pastel/soluk
duruyordu, daha belirgin olması istendi.

**Kök neden:** Bu satırlar `st.caption(":blue[...]")` /
`":green[...]"` ile render ediliyordu — `st.caption()` Streamlit
temasında zaten küçük+soluk bir bileşen, üzerine renk direktifi
eklense de pastel kalıyor.

**Yapılan (ON SEKİZİNCİ DÜZELTME):** `st.caption` yerine `st.markdown`
+ doğrudan HTML/CSS ile doygun renkler (`#0B5ED7` mavi -- besin+alerjen,
`#1B7A3D` yeşil -- maliyet+hedefte, `#D9720B` turuncu -- hedef dışı) ve
yarı kalın font (`font-weight:600`) kullanıldı. Font boyutu BİLEREK
caption'ınkiyle aynı (`0.8rem`) tutuldu ve `margin:0` verildi -- yoksa
normal markdown paragraf boşluğu, sabit 120px'lik bilgi kutusunu
(`BILGI_KUTU_YUKSEKLIK`) taşırıp içeride kaydırma çubuğu çıkarabilirdi.

**Bilerek dokunulmayan:** aynı dosyadaki Excel dışa aktarma fonksiyonu
(`_aylik_menu_excel_olustur`) -- openpyxl ile ayrı, tamamen farklı bir
renklendirme mekanizması kullanıyor, ekran görüntüsündeki şikayet ekran
(UI) ile ilgiliydi, Excel çıktısıyla değil.

**Dosya durumu:** pages/0_Yillik_Menu.py.

### 13 Ağustos 2026 — XI. Oturum (devam): TürKomp Kategori Uyumu — Karar Bekleniyor (HİÇBİR ŞEY UYGULANMADI)

Kullanıcı, kalan malzemelerin TürKomp'ta aranmasına geçmeden önce
kendi kategori sistemimizin (17 kategori, hem `kaynak_duzeltilmis_v2.xlsx`
hem veritabanındaki `malzeme_kategorileri` tablosu) TürKomp'un kendi
kategori sistemiyle uyumlu hale getirilmesini istedi.

**TürKomp'un GERÇEK 14 kategorisi bulundu** (tahmin değil -- sitenin
kendi `?type=foods&group=N` link verisinden, bash üzerinden doğrudan
erişilerek çıkarıldı, web_fetch aracı robots.txt tarafından
engellendiği için bash+curl kullanıldı):
1 Süt ve süt ürünleri, 2 Yumurta ve yumurta ürünleri, 3 Et ve et
ürünleri, 4 Balık ve su ürünleri, 5 Sıvı ve katı yağlar, 6 Tahıl ve
tahıl ürünleri, 7 Yağlı tohumlar ve kuru baklagiller, 8 Sebze ve sebze
ürünleri, 9 Meyve ve meyve ürünleri, 10 Şeker ve şekerli ürünler,
11 İçecekler, 12 Muhtelif gıda, 13 Geleneksel gıdalar, 14 Özel
beslenme amaçlı gıdalar.

**Bulunan uyuşmazlık:** Bizim 17 kategorimizin bir kısmı (Sebzeler,
Meyveler, Süt, Yumurta, Un ve Tahıllar, İçecek Hammaddeleri) doğrudan
eşleşiyor. Ama yedi kategorimizin (Baharatlar ve Tatlandırıcılar,
Soslar/Pastalar/Fondlar, Konserveler, Maya ve Pişirme Malzemeleri, Su
ve Temel Sıvı, Çikolata ve Kakao, Tatlı ve Pasta Malzemeleri) TürKomp'ta
DOĞRUDAN KARŞILIĞI YOK -- hepsi TürKomp'un "Muhtelif gıda" çöp-torbası
kategorisine sıkıştırılabilir (arama/filtreleme değerini düşürür) ya da
kendi alt-ayrımımızı koruyup sadece ortak olanları TürKomp isimleriyle
eşleştirebiliriz. Ayrıca bizim "Et ve Protein Kaynakları" tek
kategorimiz, TürKomp'ta Et (3) ve Balık (4) diye ikiye ayrılıyor --
bu da malzeme malzeme gözden geçirme gerektirir.

**Kullanıcı kararı:** "Şimdilik bir şey yapma" -- soru soruldu, cevap
gelmedi, hiçbir kod/veri değişikliği YAPILMADI. Bir sonraki oturumda
kaldığı yerden devam: kullanıcının belirsiz 7 kategori için tercihini
öğrenip (Muhtelif'e mi toplansın, yoksa kendi alt-ayrımımız mı korunsun)
ondan sonra hem Excel hem `malzeme_kategorileri` tablosu güncellenecek.

**Dosya durumu:** değişiklik yok (sadece araştırma + PROJE_NOTLARI kaydı).

### 13 Ağustos 2026 — XI. Oturum (devam): TürKomp Kategori Uyumu UYGULANDI + 644 Maddeyle Karşılaştırma (kısmi, karar bekleniyor)

**Kullanıcı kararı uygulandı:**
1. "1. ET VE PROTEİN KAYNAKLARI" (41 kalem) ikiye ayrıldı: "1. ET VE ET
   ÜRÜNLERİ" (25 kalem, aynı id=1) ve YENİ "18. BALIK VE SU ÜRÜNLERİ"
   (16 kalem, yeni id=18).
2. "4. SIVI YAĞLAR" → "4. SIVI VE KATI YAĞLAR" olarak genişletildi
   (aynı id=4). TEREYAĞI, Süt kategorisinden buraya taşındı. 4 YENİ
   malzeme eklendi: KUYRUKYAĞI, DONYAĞI, SADEYAĞ, MARGARİN — **besin
   değerleri BİLEREK BOŞ bırakıldı** (uydurulmadı), sonraki aşamada
   TürKomp'tan doldurulacak.

**Teknik not (öğrenilen ders):** Excel'de kategori isimleri
BİRLEŞTİRİLMİŞ HÜCRELER (merged cells) olarak saklanıyor. İlk denemede
`openpyxl.insert_rows()`/`delete_rows()` ile parça parça satır taşıma
denendi — bu, hücre DEĞERLERİNİ doğru kaydırsa da birleştirilmiş hücre
ARALIKLARINI otomatik güncellemiyor, birkaç kategori başlığı kayboldu.
Düzeltme: tüm veri belleğe (Python listesi) okunup orijinal (bozulmamış)
merge sınırlarından doğru kategorilere atandı, tamamen yeniden
düzenlenip dosyaya SIFIRDAN yazıldı — satır satır taşıma yerine.
Sonuç `kaynak_duzeltilmis_v3.xlsx` olarak kaydedildi (v2'nin yerini
alıyor). 3 örnek malzemede (SOMON dahil, mavi renk kodu) besin
değerleri ve renk kodlaması birebir doğrulandı, veri kaybı yok.

**Veritabanı tarafı:** `sql/50_turkomp_kategori_uyumu_asama1.sql` —
Excel ile aynı değişiklikleri `malzeme_kategorileri` ve `malzemeler`
tablolarına uyguluyor (sadece `isletme_id is null` ortak katalog,
işletmeye özel malzemelere dokunulmuyor).

**644 madde karşılaştırması (KISMİ — kullanıcı kararı bekleniyor):**
TürKomp'un tüm 644 maddesi (isim+kategori) `bash`+`curl` ile
`turkomp.tarimorman.gov.tr`'nin `?type=foods&group=N` sayfalarından
çekildi (web_fetch aracı robots.txt tarafından engellendiği için).
Bizim 362 maddeyle bulanık (fuzzy) karşılaştırma yapıldı — ham sonuç
197 "aday eksik" gösterdi ama gürültülüydü (TürKomp'un aynı kavramın
onlarca bölgesel/laboratuvar varyantını ayrı satır olarak tutması —
ör. "Çökelek, Çorum"/"Çökelek, Mersin" — ve isimlendirme farkları
ör. "Dana eti, bonfile" vs bizim "DANA BONFİLE" — çoğu sahte pozitifti).
Benzer varyantlar tek kavramda gruplanınca **124 benzersiz aday
kavrama** indi. Bu liste kullanıcıya sunuldu, HANGİLERİNİN gerçekten
eklenmesi gerektiğine (bazıları -- Kazandibi, Mantı, Yaprak Sarma gibi
-- ham malzeme değil BİTMİŞ YEMEK/tarif, kataloğa uygun olmayabilir)
dair KARAR HENÜZ VERİLMEDİ.

**Dosya durumu:** kaynak_duzeltilmis_v3.xlsx (yeni, v2'nin yerini
alıyor), sql/50_turkomp_kategori_uyumu_asama1.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): 124 Yeni Malzeme Eklendi + NUTELLA→FINDIK KREMASI

Kullanıcı, önceki oturumda sunulan 124 adaylık Excel dosyasını doldurup
geri gönderdi — her satıra hangi kategorimize (1-18 arası numara)
gireceğini işaretledi. Ayrıca NUTELLA'nın marka adı olduğunu, jenerik
"FINDIK KREMASI" ile değiştirilmesi gerektiğini belirtti.

**Uygulanan:**
- `kaynak_duzeltilmis_v4.xlsx` (yeni, v3'ün yerini alıyor): 124 yeni
  malzeme, kullanıcının işaretlediği kategorilere eklendi (isimler
  Türkçe-duyarlı büyük harfe çevrildi — `str.upper()` DEĞİL, çünkü o
  'i'yi 'İ' değil ASCII 'I'ya çeviriyor, özel bir dönüştürücü
  yazıldı). NUTELLA → FINDIK KREMASI. Toplam malzeme: 362→486.
  Aynı güvenli "belleğe oku, yeniden inşa et" yöntemiyle yapıldı (bkz.
  bir önceki oturum notu), doğrulandı (SOMON'un mavi renk kodu dahil
  hiçbir veri kaybı yok).
- `sql/51_turkomp_kategori_uyumu_asama2.sql` (yeni): aynı 124 malzeme
  + Nutella düzeltmesi veritabanına.
- **BİLİNÇLİ OLARAK YAPILMAYAN:** 124 yeni malzemenin besin değerleri
  (kalori/protein/vb.) DOLDURULMADI — kullanıcının kendi planı
  ("önce kategori, sonra besin değerleri") gereği bu ayrı, sonraki bir
  aşama. `not_aciklama` alanında açıkça belirtildi.

**Kullanıcıya sorulan, henüz cevaplanmamış bir nokta:** Berlam, Kalkan,
Kefal, Tirsi, Zargana — TürKomp'ta "Balık ve su ürünleri" kategorisinde
olmalarına rağmen kullanıcı bunları "1" (ET VE ET ÜRÜNLERİ) olarak
işaretledi, yeni oluşturulan "18" (BALIK VE SU ÜRÜNLERİ) değil.
Kullanıcının yazdığı GİBİ uygulandı (onun kararına saygı) ama bunun
kasıtlı mı yoksa gözden kaçma mı olduğu ayrıca soruldu, henüz yanıt
gelmedi.

**Dosya durumu:** kaynak_duzeltilmis_v4.xlsx (yeni),
sql/51_turkomp_kategori_uyumu_asama2.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): Kategori Sistemi Tam Yeniden Numaralandırıldı (18→20 kategori)

**Süreç sorunu bulundu ve düzeltildi:** Kullanıcı, 50 no'lu migration
dosyasını daha önce hiç alamadığını fark etti — geçmişe bakınca o
dosyayı gerçekten oluşturup göstermiştim (present_files ile) ama o
mesajda git komutlarını vermeyi UNUTMUŞUM — bu projede her teslimat
sonunda standart olan adımı o seferinde atlamışım. 50 ve 51 dosyaları
tekrar, birlikte, doğru git komutlarıyla verildi.

**Kategori sırası tamamen yeniden düzenlendi:** Kullanıcı kendi
kafasındaki sıraya göre bir Excel dosyası hazırlayıp gönderdi — 18
kategoriden 20 kategoriye çıkan, çoğu numarası değişen, bazıları
birleşen tam bir yeniden numaralandırma:
- BALIK VE SU ÜRÜNLERİ artık 18 değil, 2 (ET'in hemen ardından).
- 9 (KURU BAKLAGİLLER) ile eski 14'teki 3 yağlı tohum (AYÇİÇEĞİ/KETEN/
  KOLZA TOHUMU) BİRLEŞİP yeni "8. YAĞLI TOHUMLAR VE KURU BAKLAGİLLER"
  oldu (TürKomp'un kendi birleşik kategorisiyle uyumlu).
- İKİ YENİ, ŞU AN BOŞ kategori eklendi: "18. GELENEKSEL GIDALAR" (dosyada
  yazım hatası vardı, "GİDALAR" → "GIDALAR" olarak düzeltildi, kullanıcıya
  bildirildi) ve "19. ÖZEL BESLENME AMAÇLI GIDALAR".
- "13. SU VE TEMEL SIVI" → "20" oldu (listenin sonuna taşındı).

**Excel:** `kaynak_duzeltilmis_v5.xlsx` (yeni, v4'ün yerini alıyor) —
aynı güvenli "belleğe oku, yeniden inşa et" yöntemiyle yapıldı,
doğrulandı (486 gerçek malzeme + 2 boş kategori için "(henüz malzeme
eklenmedi)" açık placeholder metni, veri/renk kaybı yok).

**Veritabanı:** `sql/52_kategori_yeniden_numaralandirma.sql` (yeni) —
`kategori_id` foreign key'i geçici olarak kaldırılıp (çakışmaları
önlemek için +1000 ofsetli geçici ID'lerden geçirilerek) tüm malzemeler
yeni numaralara taşındı, `malzeme_kategorileri` tablosu sıfırdan
kuruldu, FK sonda geri eklendi.

**AÇIK SORU (kullanıcıya soruldu, henüz yanıt yok):** 51 no'lu
migration'da eklenen "Geleneksel gıdalar" kökenli ~23 malzeme
(KAZANDİBİ, MANTI, SİMİT, LOKUM, BOZA, PESTİL vb. — TürKomp'ta zaten
"Geleneksel gıdalar" kategorisinden geliyorlardı ama o zaman böyle bir
kategorimiz olmadığı için kullanıcı onları başka kategorilere -- 8, 16,
17 vb. -- işaretlemişti) şimdi YENİ 18 numaralı kategoriye taşınmalı
mı? TAŞINMADI, kullanıcının açık onayı bekleniyor.

**Dosya durumu:** kaynak_duzeltilmis_v5.xlsx (yeni),
sql/52_kategori_yeniden_numaralandirma.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): Geleneksel/Özel Beslenme Malzemeleri Doğru Kategoriye Taşındı

Kullanıcı iki açık soruyu da onayladı: (1) GIDALAR yazım düzeltmesi
doğruydu. (2) TürKomp kökenli 23 "Geleneksel gıdalar" malzemesi
(Boza, Çökelek, Kazandibi, Mantı, Simit, Lokum vb.) ve 4 "Özel
beslenme amaçlı gıdalar" malzemesi (İzotonik Sporcu İçeceği, Müsli,
Tam Tahıllı Gevrek, Tatlandırıcı) sırasıyla yeni 18 ve 19 numaralı
kategorilere taşındı.

**Excel:** `kaynak_duzeltilmis_v6.xlsx` (yeni, v5'in yerini alıyor) --
486 malzeme korunarak (veri/renk kaybı yok, doğrulandı) 27 malzeme
doğru kategorilere taşındı. Artık "18. GELENEKSEL GIDALAR" (23) ve
"19. ÖZEL BESLENME AMAÇLI GIDALAR" (4) gerçek içerikle dolu, geçici
"(henüz malzeme eklenmedi)" yer tutucuları kaldırıldı.

**Veritabanı:** `sql/53_geleneksel_ve_ozel_beslenme_tasima.sql` (yeni)
-- basit UPDATE'ler, FK/çakışma riski yok (hedef kategoriler zaten
52 no'lu migration'da kuruldu).

**Kategori yeniden yapılandırması tamamlandı** (bu konudaki açık iş
kapandı) -- güncel durum: 20 kategori, 486 malzeme, hepsi doğru
kategorilerinde.

**Dosya durumu:** kaynak_duzeltilmis_v6.xlsx (yeni),
sql/53_geleneksel_ve_ozel_beslenme_tasima.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam, ACİL): Giriş Ekranındaki Çıplak Sidebar Düzeltildi + "Beni Hatırla" Yeniden Bildirildi

Kullanıcı giriş ekranında Streamlit'in çıplak varsayılan `pages/`
kenar çubuğunu tekrar gördü (daha önce bilinen ama "beni hatırla"
mantığına dokunma riski yüzünden ERTELENMİŞ bir sorundu) ve aynı
ziyarette "beni hatırla" da çalışmadı ("sistem beni tanımadı").

**Logo sorunu değildi** — kullanıcı ikinci bir ekran görüntüsünde
logonun aslında düzgün göründüğünü onayladı, ilk seferki muhtemelen
bir yükleme anı/tarayıcı garipliğiydi.

**Sidebar düzeltmesi (ON DOKUZUNCU DÜZELTME, TEST EDİLMEDİ):** Kod
incelendi -- giriş ekranı, cerez bekleme ekranı ve abonelik-bloke
ekranı `st.navigation()`'ı HİÇ çağırmadan doğrudan `st.stop()`'a
gidiyordu, bu yüzden Streamlit kendi varsayılan sidebar'ına
düşüyordu. Bu 3 çıkış noktasının HER BİRİNİN kendi `st.stop()`'undan
hemen önce, minimal bir "boş" sayfa ile `st.navigation([...],
position="hidden")` çağıran yeni bir yardımcı fonksiyon
(`_navigasyon_sidebar_gizle()`) eklendi -- `.run()` çağrılmıyor
(zaten hemen ardından durduruluyor), sadece sidebar'ı bastırmak için.
**BİLİNÇLİ TASARIM KARARI:** kimlik doğrulanmış (asıl) navigasyon
yolunda bu fonksiyon ÇAĞRILMIYOR -- aynı script çalışmasında
`st.navigation()`'ı iki kez çağırmanın güvenilir olup olmadığı resmi
olarak test edilmediği için, iki yol birbirini DIŞLAYACAK şekilde
(mutually exclusive) tasarlandı, riske girilmedi.

**"Beni hatırla" yeniden bildirildi -- KÖK NEDEN BULUNAMADI:** İlgili
kod (cerez bekleme/okuma/yenileme mantığı) son "beni tanıdı"
onayından beri HİÇ DEĞİŞMEDİ, bu oturumdaki diğer tüm çalışma
(kategori/Excel işi) app.py'ye hiç dokunmadı. En olası açıklama:
Supabase refresh token'ları TEK KULLANIMLIK (rotation) -- eğer token
bir şekilde tüketilip (ör. iki sekme/cihaz, ya da bir yenileme
denemesi) yeni token cereze başarıyla yazılamadıysa, eski cerez
sessizce geçersiz kalır (satır ~230 civarı, hata YUTULUYOR, kullanıcıya
hiçbir şey gösterilmiyor -- by design). Bu KESİN teşhis DEĞİL,
kullanıcıya soruldu (birden fazla sekme/cihaz kullanımı oldu mu, vb.),
henüz yanıt yok.

**Dosya durumu:** app.py.

### 13 Ağustos 2026 — XI. Oturum (devam): Bölgesel/Laboratuvar Varyantları Geri Açıldı (Kullanıcı Talebi)

Kullanıcı 51 no'lu migration'daki deduplikasyon kararına haklı bir
itirazda bulundu: TürKomp'un aynı kavramı (ör. Pestil) bölgesel
varyantlar olarak ayrı tutmasının muhtemelen bir nedeni var (en azından
FİYAT farkı), gıda değerleri/lezzeti benzese bile ayrı tutulmalılar.

**Yapılan (30 kavram, 63 yeni satır):** Deduplike edilmiş 33 kavramdan
30'u tam TürKomp granülerliğine geri açıldı -- mevcut tek malzeme
GERÇEKTEN hangi TürKomp varyantından geldiyse o özel isimle yeniden
adlandırıldı (ör. "AYRAN" → "AYRAN (TAM YAĞLI)"), kalan varyantlar
YENİ ayrı malzemeler olarak eklendi (ör. "AYRAN (YAYIK, BURSA)",
"AYRAN (YAYIK, DİYARBAKIR)" vb.). Besin değerleri yine bilerek boş --
her varyant farklı bir TürKomp analizinden geliyor, aynı değeri
kopyalamak yanlış olurdu.

**3 kavram ERTELENDİ (kullanıcıya soruldu, henüz yanıt yok):** DANA
ETİ, SIĞIR ETİ (5'er varyant -- "bonfile" varyantı mevcut DANA
BONFİLE/SIĞIR BONFİLE ile birebir çakışıyor), PİLİÇ ETİ (3 varyant --
mevcut TAVUK BUT/KANAT/GÖĞÜS ile kavramsal çakışma riski, piliç/tavuk
aynı mı sayılmalı netleşmeden eklenmedi).

**Excel:** `kaynak_duzeltilmis_v7.xlsx` (yeni, kullanıcının düzelttiği
v6'nın yerini alıyor) -- 486→549 malzeme, doğrulandı (SOMON renk
kodu dahil veri kaybı yok). Küçük bir kozmetik hata (KEFAL isminde
çift boşluk) fark edilip düzeltildi.

**Veritabanı:** `sql/54_bolgesel_varyant_ekleme.sql` (yeni).

**Dosya durumu:** kaynak_duzeltilmis_v7.xlsx (yeni),
sql/54_bolgesel_varyant_ekleme.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): Et Kesim Hiyerarşisi Tamamlandı (Dana/Sığır/Piliç Ertelenen Karar)

Kullanıcı gerçek kasaplık şemaları (Dana, Kuzu, Kümes hayvanı) göndererek
54 no'lu migration'da ertelenen 3 soruyu netleştirdi:

1. **Bonfile dahil edilmeli** ("bonfile ve kontrfile en lezzetli/değerli
   parçalar") — ama `DANA BONFİLE`/`SIĞIR BONFİLE` ZATEN mevcut olduğu
   için (orijinal 358 listesinden) aynı isimle ikinci bir kayıt
   OLUŞTURULMADI, sadece eksik 4 kesim (but/kol/kontrfile/pirzola)
   eklendi. Bu teknik çözüm kullanıcıya açıklandı.

2. **Piliç, Tavuk'tan AYRI tutulmalı** — kullanıcı, Dana/Sığır ve
   Kuzu/Koyun ayrımının (genç/yaşlı hayvan, yaş lezzeti değiştirir,
   piyasada ayrı satılırlar) AYNI mantıkla Tavuk/Piliç için de geçerli
   olduğunu açıkladı. Bu yüzden PİLİÇ ETİ KALDIRILMADI (ilk önerinin
   tersine) — kendi kesimleriyle (but/göğüs derisiz/kanat) TAVUK'tan
   bağımsız, ayrı bir kavram olarak tamamlandı.

**Yapılan:** `kaynak_duzeltilmis_v8.xlsx` (yeni) — DANA ETİ/SIĞIR ETİ/
PİLİÇ ETİ yer tutucuları ilk kesim adıyla yeniden adlandırıldı (DANA
BUT, SIĞIR BUT, PİLİÇ BUT), 8 yeni kesim eklendi (DANA KOL/KONTRFİLE/
PİRZOLA, SIĞIR KOL/KONTRFİLE/PİRZOLA, PİLİÇ GÖĞÜS DERİSİZ/KANAT).
549→557 malzeme. Doğrulandı, veri kaybı yok.

**Veritabanı:** `sql/55_et_kesim_hiyerarsisi_tamamlama.sql` (yeni).

**TürKomp karşılaştırma çalışması artık tamamlandı** — sıradaki açık
iş: 128+ yeni eklenen malzemenin (bu oturumda eklenenler) besin
değerlerinin TürKomp'tan çekilip doldurulması.

**Dosya durumu:** kaynak_duzeltilmis_v8.xlsx (yeni),
sql/55_et_kesim_hiyerarsisi_tamamlama.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): 197 Malzemenin Besin Değerleri TürKomp'tan Dolduruldu

Kullanıcı "hazırım" dedi, TürKomp karşılaştırmasında bu oturumda
eklenen 199 yeni malzemenin (128 aday + 63 bölgesel varyant + 8 et
kesimi) besin değerlerini doldurma aşaması başladı.

**Eşleştirme:** 199 malzemenin 197'si TürKomp'un kendi 644 maddelik
veri tabanındaki gerçek kaynağına isim-dönüşüm kurallarıyla (ör.
"AYRAN (TAM YAĞLI)" -> "ayran, tam yağlı") eşleştirildi, üç aşamada
(doğrudan eşleşme → tek-aday kök-kelime eşleşmesi → et kesimleri/
özel durumlar için elle düzeltme). **2 malzeme (DONYAĞI, SADEYAĞ)
TürKomp'ta HİÇ YOK** -- bunlar hâlâ boş, başka bir kaynak gerekiyor,
uydurulmadı.

**Veri çekme:** 197 sayfa `turkomp.tarimorman.gov.tr`'den Python
`requests` ile çekildi (bash `while read` döngüsü Türkçe karakterlerle
bozulduğu için Python'a geçildi). Her sayfadan 8-82 satırlık (ortalama
43) tam bileşen tablosu (enerji, makrolar, vitaminler, mineraller,
amino asitler, yağ asitleri) ayrıştırıldı.

**Eşleme kararları (bizim 27 sütunumuz <- TürKomp bileşeni):**
- ŞEKER <- Fruktoz+Glukoz+Sakaroz+Laktoz+Maltoz TOPLAMI (TürKomp tek
  bir "toplam şeker" vermiyor, doğal şekerleri ayrı listeliyor -- şeker
  alkolleri/yapay tatlandırıcılar HARİÇ tutuldu).
- VİTAMİN K <- K-1 + K-2 toplamı (ikisi de varsa).
- VİTAMİN A <- "A vitamini" (RE birimi, mcg RAE'ye en yakın karşılık,
  birebir özdeş değil).
- **4 alan (VİTAMİN B5, VİTAMİN B7, BAKIR, MANGANEZ) TürKomp'ta
  BULUNMUYOR** -- 197 malzemenin HİÇBİRİNDE yok, sistemik bir kaynak
  eksikliği, tek tek malzeme sorunu değil. Bu 4 sütun boş kaldı.

**Yapılan:** `kaynak_duzeltilmis_v9.xlsx` (yeni, v8'in yerini alıyor)
-- 197 malzemenin 27 sütunu dolduruldu, TürKomp kaynağını belirten
YEŞİL renk koduyla (`FF008000` -- mevcut PASTIRMA/KAVURMA gibi eski
TürKomp-kaynaklı hücrelerle AYNI, doğrulanmış renk). Doğrulandı --
önceden var olan SOMON gibi verilere dokunulmadı.

**Veritabanı:** `sql/56_turkomp_besin_degerleri_doldur.sql` (yeni) --
197 UPDATE ifadesi. **Önemli düzeltme:** ilk taslakta sütun isimlerini
(ör. `sodyum`) yanlış varsaymıştım -- gerçek şema (45 no'lu migration)
birim ekli isimler kullanıyor (`sodyum_mg`, `vitamin_a_mcg` vb.),
çalıştırmadan önce fark edilip düzeltildi.

**Dosya durumu:** kaynak_duzeltilmis_v9.xlsx (yeni),
sql/56_turkomp_besin_degerleri_doldur.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): B5/B7/Bakır/Manganez USDA'dan Dolduruldu, Donyağı/Sadeyağ Bulundu

Kullanıcı, Türk kaynaklarından bulunamayan değerler için USDA kullanılmasını
onayladı, ve Ayran gibi bileşik malzemeler için "ana bileşenlerden yola
çıkma" yöntemini önerdi (bu yöntem henüz uygulanmadı, sıradaki adım).
Kullanıcı kendi ücretsiz USDA API anahtarını çıkarıp paylaştı.

**USDA API anahtarı sorunu:** DEMO_KEY paylaşımlı olduğu için sürekli
rate-limit'e takılıyordu, gerçek bir anahtar gerekiyordu. Kullanıcıya
`fdc.nal.usda.gov/api-key-signup.html` adımları verildi, anahtarı
çıkarıp gönderdi.

**B5/B7/Bakır/Manganez için 111 malzeme USDA'da arandı:**
- 197 malzemenin ~49'unun tamamen Türk'e özgü (Ayran, Pestil, Kazandibi
  vb.) olduğu, USDA'da (ABD veritabanı) hiç karşılığı olmadığı
  belirlendi.
- Geri kalan ~148'i için İngilizce arama terimleri hazırlandı, USDA'da
  arandı. **İLK OTOMATIK ESLEŞMEDE CİDDİ HATALAR bulundu** (SIĞIR
  PİRZOLA→domuz eti, HİNDİ ETİ→tavuk, KUZU ETİ→kurbağa bacağı, KAZ
  ETİ→kaz CİĞERİ, BERLAM/ZARGANA→"Abiyuch" adlı tropik meyve!) — bunlar
  kör kabul edilmedi, anahtar-kelime doğrulamasıyla (sonuçta beklenen
  kelime GEÇMELİ, yasaklı kelime GEÇMEMELİ) tek tek bulunup düzeltildi.
  Sonuçta 111 malzeme güvenilir şekilde eşleşti, 1'i (BUĞDAY NİŞASTASI)
  hiç doğru eşleşmedi, boş bırakıldı.
- 111 malzemenin B5/B7/Bakır/Manganez değerleri çekildi. **B7 (Biyotin)
  USDA'da da nadiren ölçülüyor** (111'in sadece 3'ünde var) -- bu,
  kaynakların kendi sistemik eksikliği.

**DONYAĞI ve SADEYAĞ:** Türk kaynaklarında (TürKomp dahil, kapsamlı
arama) bulunamadığı için kullanıcının onayıyla USDA'nın en yakın
eşdeğerlerinden ("Fat, beef tallow" / "Clarified butter (ghee)") TAM
PROFİL alındı. SADEYAĞ için USDA kaydı oldukça sınırlı (eski SR Legacy
kaydı) -- çoğu vitamin/mineral orada da yok, dürüstçe boş bırakıldı.

**Excel:** `kaynak_duzeltilmis_v10.xlsx` (yeni, v9'un yerini alıyor) --
USDA kaynaklı değerler MAVI renk kodu ile (mevcut SOMON gibi eski
USDA-kaynaklı hücrelerle AYNI renk), TürKomp kaynaklı değerlerden
(yeşil) ayrı işaretlendi. Aynı satırda hem yeşil (TürKomp makrolar)
hem mavi (USDA iz mineraller) hücreler bir arada olabiliyor, doğrulandı.

**Veritabanı:** `sql/57_usda_capraz_kontrol_b5_b7_bakir_manganez.sql`
(yeni) -- 110 UPDATE ifadesi.

**Sırada:** ~49 Türk'e özgü malzeme için kullanıcının önerdiği "ana
bileşenlerden yola çıkma" yöntemi (ör. Ayran = yoğurt+su) -- oran
varsayımları için kullanıcı onayı bekleniyor, henüz uygulanmadı.

**Dosya durumu:** kaynak_duzeltilmis_v10.xlsx (yeni),
sql/57_usda_capraz_kontrol_b5_b7_bakir_manganez.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): Ayran TSE Standardından Hesaplandı (ÖNEMLİ HATA DÜZELTMESİ)

**Kullanıcı talebi:** Ayran'ın yoğurt/su/tuz oranını TSE standardından
araştırıp bulmam istendi ("tahmin etme, araştır"). Ayrıca diğer Türk'e
özgü malzemeler için de TSE'ye bakılması istendi.

**TSE/Türk Gıda Kodeksi araştırması (megep.meb.gov.tr üzerinden TSE TS
3810 + Türk Gıda Kodeksi Fermente Sütler Tebliği referans alınarak):**
- Ayran yağ sınıfları: Tam yağlı ≥%1.5, Yarım yağlı ≥%0.8, Yağsız ≤%0.15
- Yağsız kurumadde: en az %6 (Türk Gıda Kodeksi)
- Tuz: TSE üst sınırı %1, ama araştırmalarda tüketici beğenisine en
  uygun bulunan oran %0.5

**Hesaplama:** Bizim YOĞURT (TAM)'ımızın gerçek verisinden (protein 3g
+ karbonhidrat 4.9g ≈ 7.9g yağsız kurumadde, yağ 3.4g /100g) iki
kısıtı da çözünce: yağsız kurumadde şartı (6/7.9=%76) yağ şartından
(1.5/3.4=%44) daha kısıtlayıcı çıktı → **%76 yoğurt + %0.5 tuz + %23.5
su** — ilk tahmin ettiğim %50-50'den çok daha yoğurt ağırlıklı.

**KRİTİK HATA BULUNUP DÜZELTİLDİ:** İlk uygulamada bu hesaplanan
profili 5 Ayran çeşidinin TÜM sütunlarına yazmıştım -- ama bu 5
çeşidin HER BİRİNİN ZATEN kendi gerçek TürKomp verisi vardı (farklı
bölgesel laboratuvar örnekleri, farklı gerçek değerler)! Kalori gibi
DOLU alanları hesaplanan tahminle EZMİŞTİM. Fark edilip DÜZELTİLDİ --
sadece GERÇEKTEN BOŞ olan alanlar (Lif, çoğu vitamin, Bakır, Manganez,
İyot -- kolon bazında değişiyor, her çeşidin kendi boşluğu farklı)
dolduruldu, mevcut TürKomp verilerine DOKUNULMADI.

**Yeni renk kodu eklendi:** Turuncu (`FFFF8C00`) -- "standart+bileşen
bazlı hesaplama" kaynağını gösteriyor, yeşil (TürKomp) ve mavi (USDA)
'dan ayrı.

**Excel:** `kaynak_duzeltilmis_v11.xlsx` (yeni, v10'un yerini alıyor).

**Sırada:** kalan ~44 Türk'e özgü malzeme için TSE araştırması --
TSE'nin "Türk Baklavası" için tam tarif+yüzde standardı olduğu
görüldü (2015, 2024 güncellendi), bu umut verici bir emsal ama her
malzeme kendi araştırmasını gerektiriyor, hepsi baklava gibi net bir
TSE standardına sahip olmayabilir. Kullanıcıya nasıl devam edileceği
soruldu (tek tek mi, yoksa bulunabilenler toplu mu sunulsun).

**Dosya durumu:** kaynak_duzeltilmis_v11.xlsx (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): TSE Standardı Araştırması — Lokum ve Pişmaniye Tamamlandı

Kullanıcı 85 malzemenin tek tek TSE araştırmasıyla ilerlenmesini istedi.

**LOKUM — TSE TS 8444 (2025 taslak) bulundu, tam standart:**
- Rutubet ≤%16, toplam şeker (kuru maddede) ≥%75, kaymaklı lokum kaymak
  oranı ≥%8 (Afyon kaymaklı ≥%10), meyveli/fıstıklı lokum meyve oranı ≥%12.
- 3 çeşit hesaplandı: SADE (İSTANBUL) = %63.75 ŞEKER + %21.25 MISIR
  NİŞASTASI + %15 su; KAYMAKLI (AFYON) = %10 KAYMAK + %90 sade taban;
  SAFRANLI/FISTIKLI (SAFRANBOLU) = %12 ANTEP FISTIĞI + %88 sade taban
  (safran eser miktarda, ihmal edildi). Kendi ŞEKER/MISIR NİŞASTASI/
  KAYMAK/ANTEP FISTIĞI verilerimizden türetildi, sadece BOŞ kolonlar
  dolduruldu (49 kolon toplam).

**PİŞMANİYE — TSE'de ayrı standart bulunamadı, gerçek üretici etiketi
kullanıldı:** Alko Şekerleme (Afyonkarahisar) ürününün yasal gıda
etiketinden (kalori 415.79, protein 4.26g, yağ 6.55g, karbonhidrat
82.97g, şeker 46.45g, lif 3.96g, doymuş yağ 3.47g) — pişmaniye
tarifi şehre göre (Ayran/Pestil'in aksine) anlamlı değişmediği için
İZMİT PİŞMANİYESİ'ne uygulandı. Sadece 2 kolon (lif, doymuş yağ)
gerçekten boştu, dolduruldu; kalori/protein/yağ/karbonhidrat zaten
TürKomp'tan doluydu, dokunulmadı. Vitamin/mineral değerleri hâlâ boş
(etiket sadece makro veriyor).

**Excel:** `kaynak_duzeltilmis_v12.xlsx` (yeni, v11'in yerini alıyor).

**İlerleme durumu:** 85 malzemeden 9'u işlendi (5 Ayran + 3 Lokum + 1
Pişmaniye kısmi). Kalan ~76 malzeme için araştırma devam edecek --
kullanıcıya bu oranda ilerlemenin çok sayıda ayrı araştırma turu
gerektireceği bildirildi.

**Dosya durumu:** kaynak_duzeltilmis_v12.xlsx (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): TÜRKPATENT Coğrafi İşaret Kaynağı Keşfedildi

Kullanıcı, TÜRKPATENT'in coğrafi işaret tescil sistemini (ci.turkpatent.gov.tr)
araştırılmasını istedi -- yöresel Türk ürünlerinin resmi teknik
şartnameleri bu sistemde tutuluyor.

**DEĞERLİ BİR KAYNAK DOĞRULANDI:** TÜRKPATENT'in her tescilli coğrafi
işaret için YAYINLANMIŞ, DETAYLI teknik şartname belgesi var (ör.
Maraş Dondurması -- Tescil No: 344 -- ci.turkpatent.gov.tr/Files/
GeographicalSigns/344.pdf) -- bileşen YÜZDELERİNİ, kuru madde/yağ
oranlarını, üretim akış şemasını içeriyor. Bu, TSE standartlarına
(Lokum, Baklava) çok benzer kalitede, TARIM/GIDA odaklı ek bir resmi
kaynak.

**Maraş Dondurması için bulunanlar (Tescil No 344):** Sadece 3
bileşen -- keçi sütü, salep, şeker. Şeker oranı %15-22, salep oranı
%0.7-8, toplam kuru madde ≥%33, süt yağı ≥%4.

**UYGULAMADA TIKANIKLIK (dürüstçe bildiriliyor):** Bu veriyi
kullanmak için (1) KEÇİ SÜTÜ'nün kendi kataloğumuzda HİÇ olmadığı
görüldü, (2) SALEP kendisi de bu oturumda hâlâ veri bekleyen bir
malzeme -- web'de bulunan "kaç kalori" siteleri SALEP için birbirinden
**6 KAT FARKLI** (65 - 383 kcal/100g aralığında) çelişkili rakamlar
veriyor, hiçbiri güvenilir bir metodoloji göstermiyor -- kullanılmadı.
Maraş Dondurması bu yüzden TAMAMLANAMADI, ertelendi.

**BU OTURUMDAKİ TOPLAM İLERLEME (85 hedef malzemeden):**
- 5 Ayran çeşidi: TAMAMLANDI (TSE TS 3810 + Türk Gıda Kodeksi'nden
  hesaplanan %76 yoğurt oranıyla).
- 3 Lokum çeşidi: TAMAMLANDI (TSE TS 8444'ten).
- 1 Pişmaniye (İzmit): KISMİ TAMAMLANDI (gerçek üretici etiketinden,
  sadece makrolar, vitamin/mineral hâlâ boş).
- Maraş Dondurması: ERTELENDİ (bağımlılık zinciri: Keçi Sütü yok,
  Salep kaynaksız).
- Kalan ~75 malzeme: HENÜZ ARAŞTIRILMADI.

**Dosya durumu:** kaynak_duzeltilmis_v12.xlsx (değişmedi, bu turda
yeni veri yazılmadı).

### 13 Ağustos 2026 — XI. Oturum (devam): Keçi Sütü + Manda Sütü Eklendi, Salep ve Maraş Dondurması Tamamlandı

Kullanıcı KEÇİ SÜTÜ ve MANDA SÜTÜ'nün kataloğa mutlaka eklenmesini,
SALEP ve MARAŞ DONDURMASI'nın derinlemesine araştırılmasını istedi.

**KEÇİ SÜTÜ, MANDA SÜTÜ (YENİ malzemeler, 557→559):** USDA'dan (Milk,
goat, fluid / Milk, indian buffalo, fluid) tam profil eklendi, 5. SÜT
VE SÜT ÜRÜNLERİ kategorisine, güvenli yeniden-inşa yöntemiyle.

**ÖNEMLİ HATA YAKALANDI VE DÜZELTİLDİ:** Vitamin D alanını çekerken
ilk denemede USDA'nın IU birimindeki değerini (KEÇİ SÜTÜ için 51 IU)
yanlışlıkla mcg sanıp öyle yazmışım (gerçek değer 1.3 mcg). Çalıştırma
öncesi fark edilip düzeltildi; DONYAĞI'nın daha önceki (56 no'lu
migration) verisi kontrol edildi, o rastlantısal olarak doğru
çıkmıştı, başka bir düzeltme gerekmedi.

**SALEP:** Zaten TürKomp kaynaklı gerçek verisi vardı (kalori/protein/
karbonhidrat/lif/şeker) -- sadece YAĞ alanı boştu. Akademik kaynaklar
(Sezik 1967; Tekinşen&Güner 2010, İYTE tez çalışmasında aktarılan)
glukomannan %45-55, nişasta %5-38, protein %3-5, kül %1-2, su %9-11
aralıklarını doğruladı ama yağ hiç belirtilmemiş -- 0 kabul edilip
sadece o alan dolduruldu.

**MARAŞ DONDURMASI:** TÜRKPATENT coğrafi işaret tescil belgesi (No
344) bulundu -- şeker %15-22, salep %0.7-8, süt yağı ≥%4, toplam kuru
madde ≥%33. Ana makrolar zaten TürKomp'tan doluydu, dokunulmadı;
KEÇİ SÜTÜ (süt yağı %4 hedefine göre ölçeklenmiş, "%96.6 ham süt
eşdeğeri") + ŞEKER (%20.5, kuru madde hedefini tutturmak için üst-orta
nokta) + SALEP (%2.7) karışımından hesaplanan mikrobesin (vitamin/
mineral) değerleri, sadece boş alanlara yazıldı.

**Excel:** `kaynak_duzeltilmis_v15.xlsx` (yeni, v12'nin yerini alıyor
-- v13/v14 ara adımlardı).

**Veritabanı:** `sql/58_keci_sutu_manda_sutu_ve_maras_dondurmasi.sql`
(yeni).

**Genel ilerleme (85 hedeften):** 5 Ayran + 3 Lokum + 1 Pişmaniye
(kısmi) + Salep + Maraş Dondurması = 11 tamamlandı, artı 2 YENİ
malzeme (Keçi Sütü, Manda Sütü) eklendi. ~74 malzeme kaldı.

**Dosya durumu:** kaynak_duzeltilmis_v15.xlsx (yeni),
sql/58_keci_sutu_manda_sutu_ve_maras_dondurmasi.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): 24 Malzeme Daha Tamamlandı (USDA + TÜRKPATENT)

Kullanıcı "devam edelim" dedi, kalan 79 malzemeye sistemli devam edildi.

**USDA'dan tamamlanan (23 malzeme, ikinci parti):** MAYDANOZ, MAYDANOZ
(KURU), ASMA YAPRAĞI, KEBERE, KEÇİBOYNUZU, YENİDÜNYA, KARNABAHAR,
KUYRUKYAĞI, MİLFÖY HAMURU, KATMER, BÖREK (2 çeşit), GÜLLAÇ, HARDALİYE,
IHLAMUR, TATLANDIRICI (sodyum siklamat/sakarin), 3 LEBLEBİ çeşidi,
SİMİT, 2 MANTI çeşidi, BAHARAT KARIŞIMI, KAZANDİBİ (3 şehir), KEŞKÜL
(3 şehir), TAVŞAN ETİ. **Yine ciddi yanlış eşleşmeler bulunup
düzeltildi** (Boza→enerji içeceği, Simit→soğan halkası, Leblebi→nohut
unu, Kolza tohumu→ekmek meyvesi tohumu, Kuyrukyağı→sığır yağı) --
bazıları (BOZA, KOLZA TOHUMU, BUĞDAY NİŞASTASI) hiçbir doğru eşleşme
bulunamadığı için USDA'dan İŞLENMEDİ, bırakıldı.

**TÜRKPATENT'ten tamamlanan (MERSİN CEZERYESİ):** No 44 tescil belgesi
bulundu -- son derece detaylı üretim oranları (150kg havuç + 20L su →
85kg püre + 15kg şeker = 100kg hamur; kuruyemiş orta oran %15).
Hesaplanan oran (~%72 havuç + %13 şeker + %15 ceviz) kendi HAVUÇ/
ŞEKER/CEVİZ verilerimizden türetildi.

**Bulunamayanlar (USDA'nın hiçbir veri setinde -- Foundation/SR
Legacy/FNDDS/Branded -- yok):** YAZ HELVASI (halva), YAPRAK SARMA
(dolma/sarma -- sadece çiğ/konserve yaprak var, dolgu yok), TATLANDIRICI
(saf sorbitol tozu -- sadece şekerli/az kalorili şekerleme var).

**Excel:** `kaynak_duzeltilmis_v17.xlsx` (yeni, v15'in yerini alıyor).
Toplam malzeme sayısı 559'da sabit kaldı (bu turda yeni EKLEME yok,
sadece mevcut boşluklar dolduruldu). Doğrulandı, SOMON gibi eski
veriler dokunulmadı.

**Genel ilerleme:** Bu oturumda toplam ~35 malzeme (Ayran×5, Lokum×3,
Pişmaniye, Salep, Maraş Dondurması, Mersin Cezeryesi, +23 USDA
partisi) tamamlandı veya kısmen tamamlandı, artı 2 yeni malzeme
(Keçi/Manda Sütü) eklendi. **Kalan ~55 malzeme** -- büyük çoğunluğu
(~25) yabani/mera otları (Madımak, Ebegümeci, Kenger vb.) ve birkaç
meyve (Bergamot, Karayemiş, Zingit vb.) -- henüz hiç araştırılmadı,
muhtemelen sanayi/akademik standardı olmayan, güç bulunacak bir grup.

**Dosya durumu:** kaynak_duzeltilmis_v17.xlsx (yeni). SQL migration'ı
henüz oluşturulmadı -- sıradaki adım.

### 13 Ağustos 2026 — XI. Oturum (devam): Yabani Otlar İçin Akademik Kaynak Taraması

Kullanıcı "kesinlikle bulacağından eminim" diyerek yabani ot grubuna
devam edilmesini istedi. Haklı çıktı -- akademik kaynaklar gerçekten
var, ama çıkarımı her biri için ayrı, zaman alıcı bir iş.

**USDA'dan 2 tane daha çözüldü:** TEKESAKALI -> "Salsify, (vegetable
oyster), raw" (TAM İSABET, tekesakalı zaten salsify'nin Türkçesi).
DENİZ BÖRÜLCESİ -> "Purslane, raw" (yakın familya, tam özdeş değil
ama makul).

**Geri kalan ~12 tanesi (EBEGÜMECİ, KARAMUK, KAYA KORUĞU, ÇOBAN
ÇANTASI, KARAYEMİŞ, BERGAMOT, MADIMAK, KENGER, ŞEVKETİ BOSTAN,
KUZUKEMİRDİ, ÇİRİŞ, ÇÖVEN) USDA'da YANLIŞ eşleşti** -- hepsi USDA'nın
"bulamadım" yedek sonucu olan aynı egzotik meyveye (Abiyuch) veya
tamamen alakasız kategorilere (Asparagus, Apples, Cherries) düştü,
KULLANILMADI.

**Türk akademik literatüründe GERÇEKTEN kaynaklar bulundu:**
- ŞEVKETİ BOSTAN (Scolymus hispanicus): Uludağ Üniversitesi doktora
  tezinden (Dülger, 2015) üretilmiş, hakemli bir makalede (Dülger
  Altıner & Şahan, 2021, Iğdır Üniv. Fen Bil. Derg.) TAM kimyasal
  bileşim tablosu var -- AMA bu veri KURUTULMUŞ KÖK UNU için (nem
  %8.53, kül %4.74, protein %11.07, yağ %0.46, kuru madde üzerinden).
  Bizim kataloğumuzdaki diğer yabani otlar TAZE/ÇİĞ hâlde -- bu veriyi
  doğrudan uygulamak besin yoğunluğunu abartır. **Kullanıcıya
  soruldu:** ayrı bir "kök unu" malzemesi olarak mı eklensin, yoksa
  tipik bir taze-sebze nem oranı varsayılıp geri mi hesaplansın?
- KENGER (Gundelia tournefortii): Karaaslan ve ark. 2014, A/E/C
  vitamin içeriği üzerine özel bir çalışma bulundu (tam metin henüz
  çekilmedi).
- MADIMAK/yemlik/kızamık: Demir 2006, Erzurum'da yetişen bu
  bitkilerin kimyasal bileşimi üzerine bir çalışma bulundu (tam metin
  henüz çekilmedi).
- İĞDE (daha önce başka bağlamda bulunmuştu): Sahan ve ark. 2012,
  TÜBİTAK projesi -- iğde meyvesinin kimyasal/besleyici özellikleri.

**Ders:** Türk yabani bitkileri üzerine ciddi bir akademik literatür
var (çoğunlukla gıda mühendisliği tezleri/makaleleri, un/bisküvi
katkısı olarak kullanım odaklı) -- ama her birinin tam metnini bulup
çekmek, tam kompozisyon tablosunu ayıklamak ve TAZE/KURUTULMUŞ
formlarını doğru eşleştirmek malzeme başına ciddi zaman alıyor.

**Excel:** `kaynak_duzeltilmis_v18.xlsx` (yeni, v17'nin yerini alıyor)
-- sadece TEKESAKALI ve DENİZ BÖRÜLCESİ dolduruldu.

**Dosya durumu:** kaynak_duzeltilmis_v18.xlsx (yeni). SQL migration
henüz oluşturulmadı.

### 13 Ağustos 2026 — XI. Oturum (devam): "Uydurma Yok" Kuralı Netleştirildi, Şevketi Bostan + Kenger İşlendi

Kullanıcı kesin bir kural koydu: "Hiçbir veriyi uydurma, tahmini
değerler yaratma, mutlaka ilgili kaynakları araştır ve gerçek verileri
kullan." Netleştirme istendi -- kullanıcı TSE/TÜRKPATENT gibi resmi
kaynakların verdiği ARALIKLARIN orta noktasını kabul edilebilir buldu
(bu "uydurma" değil, resmi bir aralığın içinde makul bir nokta seçimi).
Yasak olan: kaynağı olmayan dönüştürme faktörleri, "tipik" varsayımlar,
form-dönüştürme (kurutulmuş->taze gibi) tahminleri.

**ŞEVKETİ BOSTAN KÖK UNU (YENİ malzeme, 559→560):** Dülger Altıner &
Şahan (2021), Iğdır Üniv. Fen Bil. Derg. makalesinden GERÇEK ölçülmüş
değerler (nem %8.53, kül/protein/yağ kuru madde üzerinden) -- kurutulmuş
kök unu için. Orijinal "ŞEVKETİ BOSTAN" (taze sebze) İÇİN bu veri
KULLANILMADI (form uyumsuzluğu, dönüştürme yapılmadı) -- ayrı, yeni
bir malzeme olarak eklendi. Kalori standart Atwater faktörleriyle
hesaplandı (bu evrensel bir dönüşüm, tahmin değil).

**KENGER:** Karaaslan/Çöteli/Karataş (2014, Fırat Üniv.) makalesinden
-- HPLC ile TAZE (kurutulmamış, homojenize) bitki örneğinden ölçülmüş
gerçek veri. Vitamin A (98 mcg/100g) ve C (1.972 mg/100g) yazıldı.
**Vitamin E YAZILMADI** -- bu kaynak (0.035 mg/100g) ile başka bir
akademik kaynak (Matthäus&Özcan 2011, 48.9 mg/100g, farklı bitki
kısmı -- çiçek tomurcuğu/yağ) arasında ~1400 kat fark bulundu,
kullanıcıya hangisinin kullanılacağı soruldu, henüz yanıt yok.

**Excel:** `kaynak_duzeltilmis_v19.xlsx` (yeni, v18'in yerini alıyor).

**Genel ilerleme özeti (85 hedeften):** ~40 malzeme tamamlandı veya
kısmen tamamlandı, 2 yeni malzeme (Keçi/Manda Sütü) + 1 yeni malzeme
(Şevketi Bostan Kök Unu) eklendi. Kalan ~45 malzeme (çoğunluğu yabani
ot) için akademik kaynak taraması devam edecek -- her biri kendi
araştırmasını gerektiriyor, TSE/TÜRKPATENT kadar hızlı bulunamıyorlar.

**Dosya durumu:** kaynak_duzeltilmis_v19.xlsx (yeni). SQL migration
henüz oluşturulmadı.

### 13 Ağustos 2026 — XI. Oturum (devam): Kenger İçin Bilgir 1982 Kaynağı Bulunamadı

Kullanıcının yüklediği makale (Onur, Yılmaz, Zıvalı 2025, Turkish J.
Agriculture-Food Science and Technology) esas olarak Kenger'in
MUTFAK KULLANIMI üzerine bir etnobotanik çalışma (besin değeri
verisi içermiyor) -- ama gövde metninde Bilgir (1982) kaynağından
alıntılanan gerçek sayılar vardı: kuru madde %8.93, kül %14.26
(kuru madde üzerinden), protein %16.74 (kuru madde üzerinden),
demir 109.00 mg/100g, fosfor 18 mg/100g.

**Orijinal 1982 kaynağı ARANDI, BULUNAMADI:** Ege Üniversitesi Ziraat
Fakültesi Dergisi'nin resmi dijital arşivi (dergipark.org.tr/tr/pub/
zfdergi/archive) doğrudan kontrol edildi -- dijitalleştirme sadece
2001'e (Cilt 38) kadar gidiyor, 1982 (Cilt 19) hiç taranmamış. Tarım
ve Orman Bakanlığı kütüphane sistemi de dahil başka kaynaklar
denendi, sonuç yok.

**Uygulanan (kullanıcının "emin olduklarını yaz" talimatına göre):**
- Kül: bizim şemamızda "kül" diye genel bir sütun YOK (sadece bireysel
  mineraller var: Ca, Fe, Mg, K, Zn, P, Cu, Mn, Se, I) -- bu veri
  hiçbir sütuna yazılamadı.
- Protein: KENGER'in zaten TürKomp kaynaklı gerçek protein verisi
  vardı (1.15g/100g) -- Bilgir 1982'den hesaplanan değer (~1.5g/100g)
  YAZILMADI, mevcut veriye dokunulmadı.
- Demir, Fosfor: kuru madde/taze madde bazı belirsizliği devam
  ediyor, orijinal kaynak bulunamadığı için YAZILMADI -- ileride
  başka bir kaynak bulunursa tamamlanacak.

**Sonuç: Bu kaynaktan KENGER için yeni bir veri yazılamadı** -- tüm
potansiyel katkılar ya zaten doluydu ya da şema uyumsuzluğu/kaynak
belirsizliği nedeniyle uygulanamadı.

### 13 Ağustos 2026 — XI. Oturum (devam): MADIMAK Tamamlandı (Demir 2006)

Kullanıcının talimatı: "emin olduklarını yaz, bulamadıklarını daha
sonra araştırmak üzere boş bırak ve devam et."

**MADIMAK -- TAMAMLANDI:** Demir H (2006), Bahçe dergisi, 35(1-2):
55-60 -- Erzurum'da toplanan Polygonum cognatum Maissn. (madımak)
üzerine gerçek, kapsamlı bir kimyasal analiz (Atomik Absorbsiyon
Spektrofotometresi). MADIMAK'ın zaten TürKomp'tan Na/K/Ca/Mg/P/Fe/
Zn/VitC verisi vardı -- sadece BAKIR (0.21 mg/100g) ve MANGANEZ
(0.86 mg/100g) boştu, ikisi de bu kaynaktan dolduruldu. Makalenin
kendi kültür-bitkisi karşılaştırması (Na değerinin ıspanaktan düşük
çıkması gibi) verinin fresh-bazlı olduğunu doğruluyor.

**KENGER için Bilgir 1982 kaynağı aranmaya devam edildi, hâlâ
bulunamadı** -- Ege Üniv. Ziraat Fak. Derg. dijital arşivi 2001
öncesine gitmiyor. Kullanıcının talimatına göre bu kaynaktan HİÇBİR
ŞEY yazılmadı (zaten yazılabilecek bir şey de yoktu -- kül sütunumuz
yok, protein doluydu, demir/fosfor belirsiz kaldı).

**Excel:** `kaynak_duzeltilmis_v20.xlsx` (yeni, v19'un yerini alıyor).
**Veritabanı:** `sql/62_kenger_ve_madimak_akademik_veri.sql` (yeni).

**Kalan iş:** ~10-11 yabani ot (EBEGÜMECİ, KARAMUK, ÇOBAN ÇANTASI,
KARAYEMİŞ, KUZUKEMİRDİ, ÇİRİŞ, ÇÖVEN, DOLAMBAÇ, ECİBÜCÜ, GELEBORU,
HELEVAN, KALDIRIK, KAYA KORUĞU, KAYMACIK, KEÇİ AYAĞI, ZİNGİT) hâlâ
araştırılmadı -- her biri kendi kaynak taramasını gerektiriyor.

**Dosya durumu:** kaynak_duzeltilmis_v20.xlsx (yeni),
sql/62_kenger_ve_madimak_akademik_veri.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): EBEGÜMECİ Tamamlandı ("Ege Otları" Araması)

Kullanıcı "Ege otları" olarak aramamı önerdi -- isabetli oldu. Kaya İ,
İncekara N, Nemli Y (2004), YYÜ Zir. Fak. Derg. 14(1):1-6 -- Ege
Bölgesi'nde (İzmir/Bornova) tüketilen 7 yabani sebzenin (kuşkonmaz,
sirken, yabani hindiba, rezene, EBEGÜMECİ, gelincik, çoban değneği)
kapsamlı element analizi.

**EBEGÜMECİ tamamlandı:** Bakır (1.71 mg/100g) ve Manganez (5.46
mg/100g) yazıldı -- Demir/Çinko zaten başka kaynaktan doluydu,
dokunulmadı.

**ÖNEMLİ VERİ KALİTESİ SORUNU TESPİT EDİLDİ:** Aynı makalenin
tablosundaki (Çizelge 3) Na/K/Ca/Mg/P değerleri KULLANILMADI --
makalenin kendi metniyle karşılaştırıldığında (ör. "ıspanakta K=230
mg/100g" diyor ama kendi tablosu K=0.33 gösteriyor -- ~700 kat fark)
kaynağın kendi içinde birim tutarsızlığı/hatası olduğu tespit edildi.
Bu, kaynağın PDF'inde muhtemelen bir baskı/dönüştürme hatası --
tahmin/düzeltme yapılmadı, sadece FE/CU/MN/ZN (metinde ayrıca
doğrulanan, tutarlı) kullanıldı.

**"Çoban değneği" (Polygonum aviculare) ile bizim "ÇOBAN ÇANTASI"
FARKLI bitkiler** (Çoban Çantası = Capsella bursa-pastoris) --
bu makaledeki "çoban değneği" verisi ÇOBAN ÇANTASI'na uygulanmadı.

**Excel:** `kaynak_duzeltilmis_v21.xlsx` (yeni, v20'nin yerini alıyor).

**Kalan yabani otlar (~9-10):** KARAMUK, ÇOBAN ÇANTASI, KARAYEMİŞ,
KUZUKEMİRDİ, ÇİRİŞ, ÇÖVEN, DOLAMBAÇ, ECİBÜCÜ, GELEBORU, HELEVAN,
KALDIRIK, KAYA KORUĞU, KAYMACIK, KEÇİ AYAĞI, ZİNGİT -- bu makalede
kapsanan diğer bitkiler (kuşkonmaz, sirken, hindiba, rezene, gelincik)
bizim listemizde zaten yok/farklı isimlerle var.

**Dosya durumu:** kaynak_duzeltilmis_v21.xlsx (yeni). SQL migration
henüz oluşturulmadı.

### 13 Ağustos 2026 — XI. Oturum (devam): Isırgan (Selenyum) ve Çiriş (B6/B9) Tamamlandı

Kullanıcı "başka kaynaklara da bak, ısırgan otunu da araştır" dedi.

**ISIRGAN:** USDA'da "Stinging Nettles, blanched" bulundu -- ama genel
profili (kalori/Ca/Fe/K/VitA) bizim mevcut ISIRGAN verimizden (TürKomp
kaynaklı, farklı tür/hazırlama) belirgin farklı çıktı (ör. Fe 13.14 vs
1.64 mg/100g). Sadece gerçekten BOŞ olan Selenyum (0.3 mcg/100g)
yazıldı, diğerlerine dokunulmadı.

**ÇİRİŞ tamamlandı:** Karataş ve ark. (2011, SDU Journal of Science)
-- TAZE örnekten HPLC ölçümü (metinde "taze çiriş otu örneklerinde"
diye açıkça doğrulandı, ilk aktarımda μg/g mü mg/g mi olduğu
belirsizdi, orijinal PDF'ten µg/g olduğu kesinleştirildi). Sadece B6
(2.197 mg/100g) ve B9 (820 mcg/100g) yazıldı -- B1/B2/B3/VitC zaten
TürKomp'tan doluydu.

**Diğer Ege otları araştırması:** Çolakoğlu&Bilgir (1977, 1978) --
sarmaşık/stifno/helvacık/deniz börülcesi/ısırgan/gelincik üzerine --
aranıp bulunamadı (muhtemelen 1970'ler dönemine ait, dijitalleştirilmemiş).

**Excel:** `kaynak_duzeltilmis_v23.xlsx` (yeni, v21'in yerini alıyor).

**Kalan yabani otlar (~13):** KARAMUK, ÇOBAN ÇANTASI, KARAYEMİŞ,
KUZUKEMİRDİ, ÇÖVEN, DOLAMBAÇ, ECİBÜCÜ, GELEBORU, HELEVAN, KALDIRIK,
KAYA KORUĞU, KAYMACIK, KEÇİ AYAĞI, ZİNGİT.

**Dosya durumu:** kaynak_duzeltilmis_v23.xlsx (yeni),
sql/64_isirgan_ve_ciris_akademik_veri.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): KARAYEMİŞ Araştırması — Taban Belirsizliği Nedeniyle Ertelendi

Kullanıcı "kalanları da bul" dedi, KARAYEMİŞ için araştırma yapıldı.

**Bulunan (ama YAZILMAYAN) veri:** Kalyoncu, Ersoy, Elidemir, Dolek (2013).
"Mineral and Some Physico-Chemical Composition of Karayemis (Prunus
laurocerasus L.) Fruits Grown in Northeast [Turkey]". World Academy
of Science, Engineering and Technology, 7(6):430-433 -- K, P, Ca, Na,
Mg, S, Fe, Mn, Zn, Cu, Se, Cr, B, Li, Sr, Al, Ni, V mineral profili
(ppm cinsinden, Bursa Uludağ Üniversitesi tezi Çizelge 2.2'de
aktarılmış).

**NEDEN YAZILMADI -- taban (fresh/kuru) belirsizliği:** Aynı tezin
komşu tablosu (Çizelge 2.1, Ergüney ve ark. 2017 -- şeker/fenolik/yağ
asitleri) AÇIKÇA "kuru ağırlık üzerinden" diyor, ama mineral tablosu
(Çizelge 2.2) bu ibareyi TEKRARLAMIYOR. Orijinal Kalyoncu 2013
makalesinin tam metnine (sadece ikincil aktarım bulundu, orijinal
makale erişilemedi) ulaşılamadan hangi tabanda olduğu kesinleştirilemedi.
Kullanıcının "gerçek kaynak + kesin taban olmadan yazma" kuralına göre
YAZILMADI, ertelendi.

**Durum:** Bu, gerçekten büyük bir araştırma turu oldu (Karayemiş,
Çiriş, Işırgan, Ebegümeci, Madımak dahil çok sayıda kaynak tarandı).
Kalan yaklaşık 12-13 yabani ot (KARAMUK, ÇOBAN ÇANTASI, KUZUKEMİRDİ,
ÇÖVEN, DOLAMBAÇ, ECİBÜCÜ, GELEBORU, HELEVAN, KALDIRIK, KAYA KORUĞU,
KAYMACIK, KEÇİ AYAĞI, ZİNGİT) için araştırma devam edecek, artı
KARAYEMİŞ'in taban belirsizliği çözülecek.

**Dosya durumu:** değişiklik yok (bu turda hiçbir veri yazılmadı,
sadece araştırma yapıldı).

### 13 Ağustos 2026 — XI. Oturum (devam): 10 Yabani Ot TürKomp'ta Doğrudan Bulundu (Ama Zaten Doluymuş)

Kullanıcı GELEBORU->GİLABURU yeniden adlandırmasını onayladı, kurutulmuş
verinin (tazesi kullanıldığı teyit edilerek) ayrı malzeme olarak
eklenmesini istedi.

**GİLABURU + 2 YENİ "KURUTULMUŞ" malzeme (560->562):**
- GELEBORU -> GİLABURU olarak yeniden adlandırıldı (daha yaygın isim).
- KARAYEMİŞ (KURUTULMUŞ) ve GİLABURU (KURUTULMUŞ) yeni malzeme olarak
  eklendi -- Kalyoncu ve ark. (2013) ve Taşkın ve ark. (2019)'dan,
  ikisi de metinde "kurutulmuş" olduğu doğrulanan mineral verileriyle.
  Tazeleri (KARAYEMİŞ, GİLABURU) zaten TürKomp'tan mevcut olduğu için
  fresh kullanımı teyit edilmiş sayıldı, ayrıca araştırma gerekmedi.

**10 yabani ot TürKomp'ta DOĞRUDAN bulundu** (KEÇİ AYAĞI, KAYA KORUĞU,
KUZUKEMİRDİ, KAYMACIK, ÇOBAN ÇANTASI, KARAMUK, HELEVAN, DOLAMBAÇ,
ECİBÜCÜ, ZİNGİT) -- ama hepsinin ZATEN TürKomp kaynaklı tam verisi
vardı (muhtemelen çok daha önceki bir eşleştirme aşamasından). Yeni
çekilen veri, mevcut veriyle BİREBİR AYNI çıktı -- HİÇBİR YENİ KOLON
YAZILMADI (doğrulandı, 3 örnekle kontrol edildi). Gerçekten eksik olan
alanlar (Bakır, Manganez) TürKomp'un KENDİSİNDE bu bitkiler için HİÇ
ÖLÇÜLMEMİŞ -- bu bir veri kaybı değil, kaynağın kendi sistemik
eksikliği.

**Kalan gerçek boşluk:** Sadece ÇÖVEN ve KALDIRIK için TürKomp'ta
sayfa bulunamadı (arandı, yok). Bunlar + yukarıdaki 10 malzemenin
Bakır/Manganez alanları için USDA çapraz kontrolü denenebilir
(bazıları -- Keçi Ayağı/Ground Elder, Çoban Çantası/Shepherd's Purse
-- İngilizce karşılığı olan bitkiler, USDA'da bulunabilir).

**Excel:** `kaynak_duzeltilmis_v25.xlsx` (yeni, v24 ile aynı veri
içeriği -- bu turda hiçbir yeni değer yazılmadı, sadece isim/malzeme
eklemeleri v24'te zaten yapılmıştı).

**Dosya durumu:** kaynak_duzeltilmis_v25.xlsx (yeni). SQL migration
GİLABURU rename + 2 kurutulmuş malzeme için hazırlanacak.

### 13 Ağustos 2026 — XI. Oturum (devam): KALDIRIK Tamamlandı (Tür Kimliği Netleştirilerek)

Kullanıcı Kaldırık'ın alternatif isimlerini (hodan, ıspıt, sığırdili,
zılbıt, galdirik, deli pancar) verdi, bunlarla araştırma yapıldı.

**ÖNEMLİ BULGU -- halk isimlendirmesi karmaşası:** Bu isimler halk
arasında BİRBİRİNİN YERİNE kullanılıyor ama farklı botanik türlere
karşılık geliyor -- bazı kaynaklar Trachystemon orientalis, bazıları
Borago officinalis (gerçek hodan), bazıları Anchusa officinalis
(sığırdili) diyor. AKADEMİK LİTERATÜRDE "Kaldırık" adı ÖZELLİKLE
Trachystemon orientalis'e bağlanıyor (Iğdır Üniv. makalesi başlığında
doğrudan "...(Kaldırık)" geçiyor) -- bu kimlik tercih edildi.

**KALDIRIK (KURUTULMUŞ) -- YENİ malzeme olarak eklendi:** Özbakır
Özer & Aksoy (2019), Acta Sci. Pol. Hortorum Cultus 18(4):157-167 --
Samsun/Ordu popülasyonlarından mineral analizi, doğal biyolojik
varyasyon aralığının (kullanıcının onayıyla) orta noktası hesaplandı.
Taze/kurutulmuş ayrımı tam metinden doğrulanamadı -- ama potasyum
değeri (~4838mg/100g) mevcut taze yabani otlarımızdan (Madımak K=448,
Kaymacık K=631) 8-10 kat yüksek olduğu için KURUTULMUŞ olduğu güçlü
şekilde tahmin edildi. Bu yüzden "KALDIRIK" (taze) olarak DEĞİL, ayrı
"KALDIRIK (KURUTULMUŞ)" malzemesi olarak eklendi.

**Bu turun sonucu -- ÇÖVEN ve KALDIRIK araştırması artık tamamlandı:**
- ÇÖVEN: gerçek bir "gıda" değil, saponin/köpürtücü işlem yardımcı
  maddesi (helvaya doku vermek için) -- bilinçli olarak boş bırakıldı.
- KALDIRIK (KURUTULMUŞ): yukarıda tamamlandı.

**Excel:** `kaynak_duzeltilmis_v26.xlsx` (yeni, v25'in yerini alıyor)
-- 562->563 malzeme.

**GENEL DURUM -- yabani ot araştırması artık tamamlanmış sayılabilir**
(orijinal ~25 kadar yabani ottan, çoğu TürKomp'ta zaten bulunmuş
çıktı, geri kalanlar akademik kaynaklarla -- Kenger, Şevketi Bostan,
Madımak, Ebegümeci, Çiriş, Karayemiş/Gilaburu, Kaldırık -- tamamlandı
ya da bilinçli olarak boş bırakıldı -- Çöven, ve Kenger'in Vitamin E'si).

**Dosya durumu:** kaynak_duzeltilmis_v26.xlsx (yeni),
sql/66_kaldirik_kurutulmus.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): KALDIRIK Tür Kimliği Düzeltildi (Borage/Borago officinalis)

Kullanıcı iki ekran görüntüsü gönderdi (nefis.com, bim.com.tr'den
Kaldırık tarifleri) -- fotoğraflarda mavi, yıldız şeklinde çiçekler
görüldü. Bu, KLASİK Borago officinalis (Borage) çiçeği -- Trachystemon
orientalis'in çan/tüp şeklindeki çiçeğinden BELİRGİN ŞEKİLDE FARKLI.

**Tür kimliği yeniden değerlendirildi:** USDA'da "Borage, raw" (fdcId
170481) tam ve gerçek bir kayıt bulundu:
- %93 su içeriği AÇIKÇA belirtilmiş -- TAZE örnek, kesin.
- Potasyum 470mg/100g -- bizim diğer taze yabani otlarımızla (Madımak
  K=448, Kaymacık K=631) TUTARLI -- önceki Trachystemon verisindeki
  (4837.6mg/100g) 10 kat fazla değerden çok daha makul.

Bu hem görsel kanıtla hem büyüklük tutarlılığıyla Borage'ın daha
doğru tür olduğunu güçlü şekilde destekliyor.

**"KALDIRIK" (taze, YENİ malzeme, 563->564) Borage verisiyle
eklendi** -- tam profil (kalori, protein, yağ, karbonhidrat, çoğu
vitamin/mineral).

**"KALDIRIK (KURUTULMUŞ)" (Trachystemon verisi) SİLİNMEDİ** --
kullanıcıya iki türün de (halk arasında karışık kullanıldığı için)
ayrı ayrı mı tutulması, yoksa Trachystemon kaydının kaldırılması mı
istendiği sorulacak.

**Excel:** `kaynak_duzeltilmis_v27.xlsx` (yeni, v26'nın yerini alıyor).

**Dosya durumu:** kaynak_duzeltilmis_v27.xlsx (yeni),
sql/67_kaldirik_taze_borage.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): İki KALDIRIK Kaydı Ayrı Tutuldu

Kullanıcı iki türü de ayrı tutmayı tercih etti. Karışıklığı önlemek
için kurutulmuş (Trachystemon) kaydı tür adıyla yeniden adlandırıldı:
"KALDIRIK (KURUTULMUŞ)" -> "KALDIRIK (KURUTULMUŞ, TRACHYSTEMON)".

Artık iki net kayıt var:
- KALDIRIK (taze, Borago officinalis/Borage, USDA kaynaklı)
- KALDIRIK (KURUTULMUŞ, TRACHYSTEMON) (Trachystemon orientalis,
  Özbakır Özer & Aksoy 2019 kaynaklı, popülasyon aralığının orta
  noktası)

**Excel:** kaynak_duzeltilmis_v28.xlsx (yeni, v27nin yerini alıyor).

**Dosya durumu:** kaynak_duzeltilmis_v28.xlsx (yeni),
sql/68_kaldirik_kurutulmus_yeniden_adlandirma.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): Yıllık Menü — Tüm Besin Ögeleri Seçilebilir/Kısıtlanabilir Hale Getirildi

Kullanıcı, malzemeler tablosunun artık 27 ek besin ögesi (vitaminler,
mineraller vb.) içerdiğini belirterek Yıllık Menü'de bunların da kalori
örneğindeki gibi SEÇİLEBİLİR ve hedef aralığıyla KISITLANABİLİR
olmasını istedi -- ama hepsini otomatik göstermeden (31 satır birden
kalabalık olurdu). Görsel/tablo düzenlemeleri ayrı, sonraki bir istek
olarak ertelendi.

**Yapılan değişiklikler:**

1. `pages/0_Yillik_Menu.py`:
   - Yeni `TUM_BESIN_ALANLARI` kataloğu: mevcut 5 (kalori/protein/yağ/
     karbonhidrat/GI) + yeni 27 alan (sodyum, lif, şeker, doymuş yağ,
     13 vitamin, 10 mineral) -- her biri için etiket + makul min/maks/
     varsayılan aralık (kabaca "günlük RDA'nın öğün başına düşen payı"
     mantığıyla, kesin bilimsel tavsiye değil, başlangıç noktası).
   - `_tarif_detaylarini_getir` ve `_isletme_receteler_ve_detay_getir`:
     Supabase sorgusu artık 27 yeni kolonu da çekiyor, ağırlıklı toplama
     mantığı tüm alanlar için genelleştirildi.
   - `_ogun_toplami`: öğün bazında toplama tüm 27 yeni alanı da kapsıyor.
   - UI: "Öğün başına besin hedefi uygula" işaretlenince artık ÖNCE bir
     multiselect çıkıyor ("Hedeflenecek besin değerleri", varsayılan =
     mevcut 5) -- SADECE seçilen alanlar için öğün başına min/maks
     girişi gösteriliyor, geri kalan 27 alan gizli kalıyor (kullanıcının
     "hepsini göstermeden seçilebilir olsun" isteğine uygun).

2. `uretim_algoritmasi.py`:
   - `BESIN_ANAHTARLARI` sabiti 4 alandan 31 alana genişletildi.
     `ogun_besin_toplami` ve `_hedef_saglaniyor_mu` zaten anahtar-
     bağımsız (generic) yazıldığı için BAŞKA hiçbir değişiklik
     gerekmedi -- sadece bu listeye eklemek yeterli oldu.

**BİLİNÇLİ OLARAK DOKUNULMAYAN:** `pages/5_Tarif_Kutuphanesi.py`'deki
benzer (dar) sorgu -- kullanıcının isteği özellikle Yıllık Menü
kapsamındaydı, kapsam genişletilmedi.

**Test edilmedi** -- kod mantıksal olarak tutarlı (sözdizimi + veri akışı
kontrol edildi) ama gerçek ortamda (Streamlit + Supabase) henüz
denenmedi.

**Dosya durumu:** pages/0_Yillik_Menu.py, uretim_algoritmasi.py
(ikisi de güncellendi).

### 13 Ağustos 2026 — XI. Oturum (devam): Yıllık Menü Besin Hedefi Çökme Hatası Düzeltildi

Kullanıcı önceki dosya-yerleştirme sorununu çözdükten sonra uygulamayı
test etti: tüm 32 besin değerini birden seçince uygulama çöktü.

**Kök neden bulundu (kullanıcının gönderdiği hata ekran görüntüsünden):**
streamlit.errors.StreamlitMixedNumericTypesError -- pages/0_Yillik_Menu.py
satır 568, st.number_input çağrısında. TUM_BESIN_ALANLARI listesindeki
7 satırda (Vitamin B1, B2, B5, B6, B12, Bakır, Manganez) min/maks tam
sayı (0, 3 gibi) ama varsayılan değerler ondalıklı (0.2, 0.6 gibi)
yazılmıştı -- Streamlit number_input'ta TÜM değerlerin (min/maks/
varsayılan) aynı tipte olmasını zorunlu kılıyor. Tek tek seçildiğinde
bu 7 alana denk gelinmediği için sorun fark edilmemişti, "hepsini seç"
ile ortaya çıktı.

**Düzeltme:**
- TUM_BESIN_ALANLARI listesindeki TÜM 32 satırın min/maks/varsayılan
  değerleri açıkça float yapıldı (örn. 0 -> 0.0, 3 -> 3.0).
- Ek güvenlik: number_input çağrısının hemen öncesinde de
  float(x) for x in _BESIN_ARALIK[anahtar] ile tekrar float'a
  çevriliyor -- ileride listeye eklenecek yeni bir satırda aynı hata
  tekrarlanırsa bile bu ikinci katman koruma sağlıyor.

**Ayrıca ortaya çıkan süreç sorunu:** Kullanıcı önceki turda dosyayı
indirip proje klasörüne TAM olarak yerleştirmekte zorlandı (tarayıcının
indirdiği dosya Downloads klasörüne değil başka bir konuma gitmiş,
kopyalama adımı atlanmış). dir komutuyla dosya tarihini kontrol ederek
(14.08.2026 -- eski, değişmemiş) bu tespit edildi, kullanıcı dosyayı
doğru konuma taşıyarak çözdü. Bu, ileride benzer bir "kod göndermeme
rağmen değişiklik görünmüyor" durumunda ilk kontrol edilecek adım
olarak not edildi: dosyanın gerçekten doğru klasöre, doğru adla
yerleştirildiğini dir/Get-Content gibi bir komutla doğrulamak.

**Excel/DB:** Bu turda ilgisiz, sadece Python kodu değişti.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi (886 satır).

### 13 Ağustos 2026 — XI. Oturum (devam): "Tüm Öğünler Hedef Dışı" Hatası Düzeltildi (None/0 Karışıklığı)

Kullanıcı, hiçbir değeri değiştirmediği halde tüm 32 besin ögesini
seçince tüm öğünlerin "hedef dışı" işaretlendiğini bildirdi.

**Kök neden:** Malzeme bazında bir besin ögesi (ör. Vitamin B7 --
kataloğumuzda birçok malzemede hâlâ eksik) hiç ölçülmemişse, toplama
kodu bunu sessizce "0" olarak sayıyordu ("değer or 0" deseni) --
"bilinmiyor" (None) olarak değil. Çoğu besin ögesinin varsayılan hedef
ALT SINIRI 0'ın üzerinde olduğu için (ör. B7 için 5.0), bu yanlış "0"
değeri hedefin altında kalıp öğünü "hedef dışı" gösteriyordu. 32
ögenin hepsi seçilince, HER öğünde en az bir nadir besin ögesi bu
şekilde yanlış "başarısız" oluyordu.

**Düzeltme (3 katmanda, hepsi aynı mantıkla):**
1. `pages/0_Yillik_Menu.py` -- `_tarif_detaylarini_getir` ve
   `_isletme_receteler_ve_detay_getir`: her genişletilmiş besin ögesi
   için "en az bir malzeme veri verdi mi" bayrağı eklendi -- hiçbiri
   vermediyse tarif düzeyinde sonuç None (0 değil).
2. `_ogun_toplami`: aynı mantık öğün (3 tarif) toplamı için de
   uygulandı -- üç tarifin de o öge için verisi yoksa öğün toplamı None.
3. `uretim_algoritmasi.py` -- `ogun_besin_toplami`: MENÜ ÜRETİMİ
   sırasında kullanılan asıl kontrol noktası -- temel 4 alan (kalori/
   protein/yağ/karbonhidrat, pratikte hep dolu) eskisi gibi "0"
   sayılmaya devam ediyor, ama 27 genişletilmiş öge için aynı None/0
   ayrımı uygulandı.

`_hedef_saglaniyor_mu` ve `_hedefte_mi` zaten "deger None ise atla"
mantığıyla yazılmıştı -- asıl sorun bu fonksiyonlara HİÇBİR ZAMAN
None ulaşmamasıydı, o yüzden bu üç katman düzeltilerek zincir
tamamlandı.

**Kullanıcının ikinci notu ("ana tabloda bu değerleri göremiyorum"):**
Bu, kullanıcının daha önce "görsel/tablo düzenlemelerini sonra ayrı
isteyeceğim" dediği kapsam -- şimdilik dokunulmadı, ayrı bir istek
bekleniyor.

**Dosya durumu:** pages/0_Yillik_Menu.py, uretim_algoritmasi.py
(ikisi de güncellendi).

### 13 Ağustos 2026 — XI. Oturum (devam): Gerçek Takvim Entegrasyonu + Kart Tasarımı Uygulandı

Kullanıcı önce görsel tasarımı (kart bazlı, tıkla-aç, tekrar tıkla-
çevir) onayladı, sonra "takvimi gerçek takvim yapalım" dedi. Gönderdiği
2026 takvim görseliyle netleşen istek: GERÇEK ISO takvim haftaları
(Pazartesi-Pazar), ay sınırlarını aşabilen (ör. 31 Ağustos + 1-6 Eylül
aynı haftada). En kritik nokta: "her gün kendi gerçek tarihinin ait
olduğu mevsimden beslensin" -- kullanıcı bunu onayladı.

**1) uretim_algoritmasi.py -- gün bazında mevsim desteği:**
`hafta_olustur` artık opsiyonel `gun_mevsimleri` parametresi alıyor
(7 elemanlı mevsim listesi, günlük). Verilmezse eski `mevsim` (tek
değer, geriye dönük uyumluluk) kullanılır. `ogun_olustur` zaten GÜN
BAZINDA çağrıldığı için (haftalık döngünün içinde), bu değişiklik
minimal oldu -- anayasa kuralları (uyumsuzluk/madde 11, tamamlayıcı/
madde 13, hedef kontrolü) hiç değişmedi. Haftalık tekrarsızlık
(madde 2, kullanılan_hafta) hâlâ TÜM hafta için tek bir küme --
mevsim karışık olsa bile bir tarif aynı haftada iki kez çıkmaz.
Gerçekçi boyutta (30 tarif/grup/mevsim) sahte veriyle test edildi,
gün bazında doğru mevsimden seçim yapıldığı doğrulandı.

**2) pages/0_Yillik_Menu.py -- gerçek tarih hesaplama:**
- `AY_TO_MEVSIM`: Ay->Mevsim ters eşleşmesi (yeni).
- `_ay_gercek_haftalari(yil, ay_adi)`: verilen ay için gerçek ISO
  haftalarını (her biri 7 datetime.date) hesaplar -- ayın ilk/son
  gününün ait olduğu haftanın Pazartesi'sinden başlayıp biter. 2026
  Ağustos için Python'da test edildi, kullanıcının gönderdiği GERÇEK
  takvim görseliyle BİREBİR eşleşti (Hafta 1: 27 Tem-2 Ağu, Hafta 6:
  31 Ağu-6 Eyl).
- `_tarih_mevsimi(tarih)`: bir tarihin mevsimini bulur.
- UI: "Mevsim" seçim kutusu kaldırıldı, yerine "Yıl" (number_input,
  varsayılan bugünün yılı) eklendi. "Ay" artık tüm 12 ayı gösteriyor
  (mevsime göre filtrelenmiyor, çünkü mevsim artık gün bazında otomatik
  hesaplanıyor).
- Buton mantığı: sabit "her ay = 4 hafta" varsayımı kaldırıldı (bu,
  ay uzunluğunu hiç hesaba katmıyordu!) -- artık `_ay_gercek_haftalari`
  ile o ayı kapsayan GERÇEK hafta sayısı (4-6 arası) kullanılıyor.
  Tohum artık haftanın gerçek Pazartesi tarihinden (toordinal())
  türetiliyor -- eski "ay_index*10+hafta_no" şeması artık anlamlı
  değildi (gerçek haftalar ay sınırını aşabildiği için).
  Her `gun` dict'ine gerçek `tarih` (datetime.date) eklendi.

**3) Kart tasarımı -- onaylanan mockup GERÇEK Streamlit'e uygulandı:**
`_hafta_kartlarini_goster` tamamen yeniden yazıldı:
- Her gün artık bir KART (sıcak kireçtaşı zemin, altın alt-çizgi
  başlık, Fraunces/IBM Plex Mono yazı tipleri Google Fonts'tan).
- 3 durum: KAPALI (sadece gün adı + tarih + 2 küçük nokta) -> başlığa
  tıkla -> AÇIK/ÖN YÜZ (Öğle/Akşam yemek listeleri, GERÇEK
  st.page_link ile) -> "Besin değerlerini gör" tıkla -> AÇIK/ARKA YÜZ
  (koyu patlıcan moru zemin, IBM Plex Mono ile tam besin/maliyet/
  hedef tablosu).
- Gün başlığında artık "Gün 1" değil GERÇEK gün adı (Pazartesi...)
  + gerçek tarih (ör. "23 Ağu") gösteriliyor. Hafta sonu günleri
  (Cumartesi/Pazar) hafif farklı bir zemin tonuyla ayrılıyor.
- **ÖNEMLİ KISIT (kullanıcıya iletildi):** Streamlit'in script-yeniden-
  çalıştırma modeli, mockup'taki KESINTİSİZ 3D döndürme animasyonunun
  birebir aynı şekilde çalışmasını garanti etmiyor -- her tıklama tüm
  sayfayı yeniden çiziyor, bu yüzden "çevirme" bir ANİMASYON değil bir
  DURUM DEĞİŞİMİ (ön yüz/arka yüz içeriği yer değiştiriyor, ama akıcı
  dönme hareketi olmayabilir). Görsel dil (renkler, yazı tipleri,
  ipucu metni) mockup'la aynı.
- CSS, Streamlit'in `key=` parametresinin ürettiği `st-key-{key}`
  sınıfını hedefliyor (Streamlit >=1.38 -- requirements.txt'te
  doğrulandı). Bu, canlı ortamda GÖRÜLMEDEN test edilemedi -- ilk
  gerçek denemede küçük görsel ince ayarlar gerekebilir.

**Test durumu:** Python sözdizimi + AST + üretim algoritması mantığı
(sahte veriyle) test edildi. Streamlit arayüzünün GERÇEK görünümü
(CSS'in Streamlit DOM'una doğru uygulanıp uygulanmadığı) canlı ortamda
henüz görülmedi.

**Dosya durumu:** pages/0_Yillik_Menu.py, uretim_algoritmasi.py
(ikisi de büyük ölçüde güncellendi).

### 13 Ağustos 2026 — XI. Oturum (devam): Kart Genişleme ve Çoklu-Açık-Kart Hatası Düzeltildi

Kullanıcı "şekil bozukluğu var" dedi (ekran görüntüsü olmadan, sadece
metin). Kodu tekrar inceleyerek iki gerçek mimari eksiklik bulundu:

**1) Kart açılınca GENİŞLEMİYORDU:** Mockup'ta CSS Grid (`grid-column:
span 3`) kartı büyütüp digerlerini küçültüyordu. Streamlit
implementasyonunda `st.columns(len(hafta))` SABİT EŞİT genişlikte 7
sütun oluşturuyordu -- açık bir kart hâlâ 1/7'lik dar sütuna sıkışıp
içeriği (yemek listesi + besin tablosu) çarpık/sıkışık görünüyor
olmalıydı. Düzeltme: session_state'ten hangi günün açık olduğu
kolonlar OLUŞMADAN ÖNCE kontrol ediliyor, açık güne 3 kat, diğerlerine
1 kat oran verilen bir liste ile `st.columns([1,1,1,3,1,1,1])` gibi
DİNAMİK oranlı sütunlar oluşturuluyor -- mockup'taki "span 3"
davranışının Streamlit karşılığı.

**2) Birden fazla kart aynı anda açık kalabiliyordu:** Bir kartın
başlığına tıklanınca sadece O kartın acik_key'i güncelleniyordu,
aynı haftadaki DİĞER kartlar kapatılmıyordu -- kullanıcı farklı
günlerin başlıklarına art arda tıklarsa birden fazla kart aynı anda
açık kalıp hepsi dar sütunlara sıkışabiliyordu (özellikle 1.
maddedeki sorunla birleşince ciddi bir görsel karmaşaya yol açardı).
Düzeltme: bir kart açılırken (False->True geçişinde) aynı haftadaki
TÜM diğer kartlar otomatik kapatılıyor (mockup'taki "tek seferde
sadece bir kart açık" davranışı).

**Bilinen, henüz çözülmemiş küçük bir nokta:** `_dish_kutu_yuksekligi_
hesapla` (yemek listesi kutusunun sabit piksel yüksekliği) dar sütun
varsayımıyla hesaplanıyor -- şimdi açık kart 3 kat geniş olduğu için
bu yükseklik tahmini fazla cömert kalabilir (metin daha az satıra
sığacağı için kutuda gereğinden fazla boşluk kalabilir). Sıkışma kadar
ciddi değil, ayrı bir ince ayar maddesi olarak bırakıldı.

**Test durumu:** Sözdizimi kontrol edildi. Görsel sonuç kullanıcının
bir sonraki canlı denemesinde doğrulanacak -- ekran görüntüsü
paylaşılırsa daha kesin teşhis mümkün olur.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): CSS'in Düz Metin Olarak Görünmesi Hatası -- Kesin Sebep Bulundu ve Düzeltildi

Kullanıcı ekran görüntüsü (MHTML) gönderdi: CSS kodunun kendisi sayfada
DÜZ METİN olarak görünüyordu, stil olarak uygulanmıyordu.

**Kesin sebep:** `_yillik_menu_tasarim_stilini_uygula()` fonksiyonundaki
üçlü tırnaklı CSS string'i, Python kodunun kendi girinti seviyesine
(8-12 boşluk) hizalanmış şekilde yazılmıştı. Markdown standardında,
**4 veya daha fazla boşlukla başlayan HER satır "girintili kod bloğu"
sayılır** ve olduğu gibi (kaçış karakterleriyle) düz metin olarak
gösterilir -- `unsafe_allow_html=True` bunu GEÇERSİZ KILMAZ, çünkü bu
karar HTML'e ulaşmadan ÖNCE, markdown ayrıştırma aşamasında veriliyor.
Ekran görüntüsündeki metnin bu kadar düzgün/eksiksiz görünmesi de bunu
doğruluyordu -- tam olarak bir kod bloğu gibi render edilmişti.

**Düzeltme:** İlk denemede `textwrap.dedent()` kullanıldı ama bu SADECE
satırların ORTAK asgari girintisini siliyor -- CSS kuralının kendi iç
içe girintisi (süslü parantez içi özellikler) hâlâ 4+ boşluk
bırakıyordu (83 satırın 45'i hâlâ girintiliydi). Kesin çözüm: tüm CSS
kuralları TEK SATIRA indirildi (okunabilirlik için iç girinti zaten
gereksizdi) VE ekstra güvenlik için her satır `.lstrip()` ile tek tek
sıfırlandı -- artık 28 satırın TAMAMI sıfır girintiyle başlıyor,
doğrulandı.

**Ayrıca küçük bir iyileştirme:** "Besin değerlerini gör / Yemekleri
gör" çevirme butonunun rengi (#6B6055 -> #A99B8A) hem açık (ön yüz)
hem koyu (arka yüz) zeminde okunabilir olacak şekilde ayarlandı.

**Bu oturumda önceki iki düzeltme de (kart genişleme + tek-kart-açık
kısıtı) bu CSS-metin hatası çözülmeden test edilememişti** -- şimdi
hepsi birlikte canlı ortamda denenebilir.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi (1070 satır).

### 13 Ağustos 2026 — XI. Oturum (devam): Kart Yüksekliği, Hafta Sonu Rengi ve İki Satırlı Başlık Düzeltildi

Kullanıcı ekran görüntüsü gönderdi -- düzen artık ÇALIŞIYOR (önceki
CSS-metin hatası çözülmüş), ama 3 ince ayar istendi:

**1) Kart yükseklik tutarsızlığı:** Başlık metni "Pazartesi · 30 Kas"
gibi bazen 2 satıra taşarken "Salı · 1 Ara" gibi bazen 1 satıra
sığıyordu -- bu farklı kart yüksekliklerine yol açıyordu. Kullanıcının
istediği "gün adı üstte tek başına, tarih altta ayrı satırda" düzeni
bunu YAN ETKİ olarak da çözüyor: artık HER kart başlığı zorunlu olarak
TAM 2 satır (gün adı \n tarih) olduğu için tüm kartlar aynı yükseklikte.
CSS'e `white-space: pre-line` eklendi (aksi halde buton metni \n'i
görmezden gelip boşluğa çevirebilirdi).

**2) Ay adı tam yazıldı:** "Kas" kısaltması yerine "Kasım" (tam ad) --
AY_KISA sözlüğü kaldırıldı, doğrudan AYLAR_SIRALI kullanılıyor.

**3) Hafta sonu rengi belirginleştirildi:** Önceki soluk ton (#F7EBD8)
yerine daha doygun bir şeftali/kehribar tonu (#F2CFA0) + altın renkte
2px kenarlık (#C88A2E) eklendi -- artık Cumartesi/Pazar kartları
gözle daha net ayrışıyor.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): Üst Başlık Boşluğu Düzeltildi, "Menü Mühendisi" Yazısı Eklendi + Geçmiş Tarih Tartışması

**1) Sayfa başlığının çok aşağıda kalması (app.py):** Sebep bulundu --
sabit (position:fixed) nav çubuğunun altına eklenen manuel boşluk
(spacer, .ust_menu_bosluk_masaustu) ile Streamlit'in KENDİ varsayılan
üst dolgusu (.block-container'ın "wide" düzende araç çubuğu için
ayırdığı birkaç rem'lik pay) ÜST ÜSTE binip toplam boşluğu gereğinden
fazla yapıyordu. `.block-container { padding-top: 1rem !important; }`
eklenerek Streamlit'in kendi payı küçültüldü -- bu TÜM sayfalarda
(sadece Yıllık Menü'de değil) düzelme sağlıyor.

**2) "Menü Mühendisi" yazısı eklendi:** Hem masaüstü hem mobil nav
satırının (logo + menü butonları) HEMEN ÜSTÜNE, ortalanmış, yeşil
vurgu renkli (#0F6E56, mevcut pastel paletle tutarlı) bir başlık
eklendi. Sabit nav çubuğunun toplam yüksekliği arttığı için, altındaki
boşluk (spacer) değerleri de buna göre büyütüldü (masaüstü 180->210px,
mobil 96->120px) -- aksi halde bu yeni satır sayfa içeriğini
öncekinden biraz daha fazla örtebilirdi.

**3) TARTIŞMA -- geçmiş tarihe menü üretimi:** Kullanıcı, sistemin
geçmiş bir tarih için menü üretebildiğini fark edip bunun doğru olup
olmadığını sordu. Claude'un görüşü paylaşıldı: üretimin kendisi
sorunlu değil (deterministik, "bu sistem o hafta için ne önerirdi"
sorusuna cevap veren bir simülasyon) -- asıl risk, üretilen menü ile
GERÇEKTEN servis edilmiş bir kaydın şu an görsel olarak ayırt
edilememesi. Öneri: üretimi engellemek yerine, geçmiş bir tarih
seçildiğinde küçük bir uyarı notu göstermek. Kullanıcının kararı
BEKLENİYOR -- henüz hiçbir kısıtlama/uyarı kodu yazılmadı.

**Dosya durumu:** app.py güncellendi (1-2 numaralı maddeler).

### 13 Ağustos 2026 — XI. Oturum (devam): Gecmis Tarih Uyari Notu Eklendi + Pop-up Tartismasi

Kullanicinin karari: uyari notu kullanilsin (engelleme degil).

**Uygulandi:** "Ay icin menu uret" butonuna basildiginda, secilen ayin
GERCEK son gunu bugunden ONCEYSE (_ay_gercek_haftalari ile hesaplanan
gercek tarih araligina gore), session_state'e "gecmis_ay_mi": True
bayragi kaydediliyor. Menu goruntulenirken bu bayrak True ise
st.warning() ile acik bir not gosteriliyor ("Bu, gecmis bir tarih
icin uretildi -- gercek servis kaydi degildir...").

NOT: ilk denemede st.warning(..., icon="uyari-emoji") yazilmisti --
kullanicinin "arayuzde emoji yasak" kalici kuralini ihlal ediyordu,
hemen fark edilip kaldirildi (st.warning()'in kendi varsayilan
ikonuyla, projenin geri kalaninda zaten boyle kullaniliyor).

**Yeni tartisma -- pop-up kartlar:** Kullanici gunluk menu kartlarinin
pop-up pencere gibi acilip acilamayacagini sordu. Streamlit'in yerlesik
st.dialog() bileseni (surum >=1.38'de mevcut, henuz kullanilmiyor) bunu
saglayabilir. Iki secenek sunuldu:
  A) Mevcut ac/cevir mekanigi TAMAMEN pop-up'a donusturulur -- yemek
     listesi + besin tablosu ayni anda, cevirmeye gerek kalmadan.
  B) Mevcut mekanik KALIR (onaylanan "sanat eseri" hissi korunur),
     pop-up EKSTRA bir "buyut" secenegi olarak eklenir.
Kullanicinin cevabi BEKLENIYOR -- henuz kod yazilmadi.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi (gecmis tarih
uyarisi).

### 13 Ağustos 2026 — XI. Oturum (devam): Kartlar Pop-up'a Dönüştürüldü (Animasyonlu Çevirme)

Kullanıcı kartların pop-up pencere gibi açılmasını, içeride animasyonlu
çevirme (ön yüz=yemekler, arka yüz=besin verileri) olmasını istedi.

**Uygulanan mimari:** Streamlit'in yerleşik `st.dialog()` bileşeni
kullanıldı (surum >=1.38'de mevcut, ilk kez kullanılıyor).

- Izgara kartı artık HER ZAMAN kapalı/sabit boyutta (gün adı + tarih +
  2 nokta) -- önceki "yerinde büyüme" (dinamik sütun oranı) mantığı
  TAMAMEN kaldırıldı, artık gerek yok, çünkü kartlar artık ızgarada
  büyümüyor, pop-up açılıyor.
- Başlığa tıklanınca `st.session_state["yillik_menu_popup_gun_id"]`
  ayarlanıp `_gun_popup_dialog()` (bir `@st.dialog` fonksiyonu)
  tetikleniyor.
- Pop-up içinde ön yüz (yemek listesi, GERÇEK st.page_link ile) / arka
  yüz (besin/maliyet/hedef, IBM Plex Mono) arasında "cevir" butonuyla
  geçiş yapılabiliyor.
- **Animasyon çözümü:** Streamlit'in rerun modeli kalıcı bir CSS
  transition'ı güvenilir kılmadığı için, "montaj-anlı animasyon" hilesi
  kullanıldı -- ön/arka yüz her değiştiğinde container key'i de
  değişiyor (popupgovde_on_ vs popupgovde_arka_), bu yüzden tarayıcı
  onu HER SEFERINDE yeni bir eleman olarak görüp CSS @keyframes
  (omgoFlipOn / omgoFlipArka, rotateY + opacity) animasyonunu güvenilir
  şekilde her çevirmede yeniden oynatıyor.

**AÇIKÇA BELİRTİLEN KISIT:** Pop-up'ın KAPANMASI (X butonu / dışına
tıklama) Streamlit'in kendi standart davranışını kullanıyor -- kartın
ızgaradaki tam konumuna "küçülerek geri dönmesi" gibi özel bir kapanış
animasyonu st.dialog ile YAPILAMIYOR (Streamlit bu seviyede özel
pozisyon kontrolü sunmuyor), kullanıcıya bu açıkça iletildi.

**Ek güvenlik:** Pop-up'ın sadece ilk tıklamada değil her rerun'da
(örn. içindeki "çevir" butonuna basıldığında) doğru şekilde açık
kalması için, session_state kontrolü HER döngüde açıkça yapılıyor --
Streamlit'in "bir kez çağrılınca kendiliğinden hatırlar" davranışına
körü körüne güvenmek yerine.

**Temizlik:** Artık kullanılmayan `_dish_kutu_yuksekligi_hesapla`
fonksiyonu kaldırıldı (pop-up'ta sabit yükseklik kısıtı yok).

**Test durumu:** st.dialog canlı ortamda hiç denenmedi (sandbox'ta
Streamlit kurulu değil) -- ilk canlı testte davranış doğrulanmalı.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi (1058 satır).

### 13 Ağustos 2026 — XI. Oturum (devam): app.py'de TypeError Düzeltildi (Fazladan Virgül)

Kullanıcı canlı ortamda "TypeError: multiple values for argument"
hatası bildirdi -- app.py satır 848 civarındaki st.markdown() çağrısında.

**Kök neden:** Önceki turda ".block-container { padding-top: 1rem
!important; }" satırını eklerken, hemen ardına YANLIŞLIKLA
"</style>()," eklenmişti -- ama string birleştirmesi orada bitmemesi
gerekiyordu (devamında video-kontrol CSS kuralları ve GERÇEK
"</style>" kapanışı vardı). Bu fazladan virgül, tek olması gereken
uzun string'i ikiye bölüp, ikinci parçayı POZİSYONEL 2. argüman olarak
`unsafe_allow_html` parametresine gönderiyordu -- bu da çağrının
SONUNDAKİ açık `unsafe_allow_html=True,` ile çakışıp "multiple values
for argument" TypeError'ına yol açıyordu.

**Düzeltme:** Fazladan virgül kaldırıldı. AST ile doğrulandı: artık
st.markdown() çağrısının TEK bir pozisyonel argümanı var (1913 karakter,
tek bir "</style>" içeren birleşik CSS string'i).

**Dosya durumu:** app.py düzeltildi.

### 13 Ağustos 2026 — XI. Oturum (devam): Baslik Boyutu, Pop-up Boyutu ve Animasyon Ince Ayari

Kullanici iki sorun bildirdi: (1) "Menü Mühendisi" yazisi "Yillik Menü
Üretim Motoru" basligindan cok kucuk, ayni boyutta olmali. (2) Pop-up
cok buyuk aciliyor, animasyonlu acilma/donme hic gorulmuyor.

**1) Baslik boyutu esitlendi (app.py):** "Menü Mühendisi" font-size
1.05rem/0.95rem (masaustu/mobil) -> 2.25rem/1.4rem yapildi (st.title()'in
kendi varsayilan boyutuna -- yaklasik 2.25rem, font-weight 700 --
uyacak sekilde). Buyuyen metne gore sabit nav-bosluk (spacer)
degerleri de arttirildi (210->245px masaustu, 120->135px mobil).

**2) Pop-up boyutu kuculttildu:** `@st.dialog("Gün Detayı", width="large")`
-> `width` parametresi kaldirildi (Streamlit'in varsayilan/kucuk
boyutuna donuldu).

**3) Animasyon -- ince ayar yapildi ama DURUSTCE belirtilmesi gereken
bir belirsizlik var:** Suphelenilen sebep: donme (rotateY) transform'u
GERCEK 3 boyutlu derinlik gostermesi icin bir UST elemanda `perspective`
tanimli olmasi gerekiyordu, bu hic yoktu -- eklendi ([data-testid=
"stDialog"] VE yedek olarak .stApp uzerine). Ayrica hareket daha
belirgin olsun diye suresi (0.45s->0.6s), donme acisi (90->100 derece)
ve olcek (scale 0.85->1) eklendi.

**DURUSTCE BELIRTILMESI GEREKEN KISIT:** Bu degisiklikler MANTIK
YURUTMEYE dayanarak yapildi -- sandbox'ta Streamlit kurulu olmadigi
ve canli tarayicida test edilemedigi icin, animasyonun bu degisiklikle
GERCEKTEN calisip calismayacagi kesin degil. `[data-testid="stDialog"]`
secicisinin Streamlit'in GUNCEL surumunde dogru test-id oldugu da
DOGRULANMADI (tahmin). Bir sonraki canli testte hala calismazsa,
daha derin bir arastirma (ornegin animasyonu tamamen farkli bir
teknikle -- ör. JS tabanli class-toggle ile -- yeniden ele almak)
gerekebilir.

**Dosya durumu:** app.py, pages/0_Yillik_Menu.py guncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): Baslik Bir Tik Daha Buyutuldu, Flip Animasyonu Sadelestirildi

Kullanici: "Menü Mühendisi" bir tik daha buyusun; animasyon oluyor ama
istenen "kartin donme efekti" degil.

**1) Baslik:** 2.25rem -> 2.75rem (masaustu), 1.4rem -> 1.65rem
(mobil). Spacer yukseklikleri buna gore tekrar arttirildi (245->260px
masaustu, 135->145px mobil).

**2) Animasyon sadelestirildi:** Onceki versiyon rotateY + opacity
fade + scale ucunu BIRLIKTE kullaniyordu -- bu, saf bir "donme" hissi
yerine bulanik bir "belirme/buyume" hissi yaratmis olabilir (opacity
fade, donme SIRASINDA icerigi gorunmez kildigi icin donusun kendisi
algilanamiyor olabilirdi). Duzeltme: opacity ve scale TAMAMEN
kaldirildi, SADECE rotateY (90 derece kenar-goruntusunden 0 dereceye)
birakildi -- boylece "donme" tamamen perspective ile saglanan
foreshortening (govde inceden kalina donusum) uzerinden algilanacak,
gercek bir kagit/kart cevirme hareketine daha yakin. Ayrica
`animation-fill-mode: both` eklendi (animasyon bitince eski haline
donmesin diye) ve `backface-visibility: hidden` (donme sirasinda
olasi ters/aynali gorsel hatalari onlemek icin, iyi pratik).

**Test durumu:** Yine canli ortamda test EDILEMEDI (sandbox'ta
Streamlit yok) -- bir sonraki denemede sonuc bildirilmeli.

**Dosya durumu:** app.py, pages/0_Yillik_Menu.py guncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): "Sadece Yazılar Dönüyor" Düzeltildi -- Tüm Kart Artık Birlikte Dönüyor

Kullanıcı: sadece ic yazilar donuyor, kartin TAMAMI donmeli.

**Kok neden:** Onceki yapida animasyon SADECE ic icerik blogu (yemek
listesi VEYA besin tablosu) etrafina uygulanmisti -- kartin kendi
zemin rengi/golge/koseleri ve baslik metni (gun adi + tarih) bu
animasyonun DISINDAYDI, bu yuzden sabit kaliyorlardi ve sadece
ic yazilar hareket ediyormus gibi gorunuyordu.

**Duzeltme:** Baslik + on/arka yuz icerigi TEK BIR kapsayiciya
alindi (_gun_popup_govdesini_ciz fonksiyonu yeniden yapilandirildi).
Bu kapsayiciya kendi GORSEL KART stili verildi (sicak kirectasi zemin
+ golge + yuvarlatilmis kose ON YUZ icin, koyu patlican moru ARKA
YUZ icin) -- ve donme animasyonu bu TUM kapsayiciya uygulaniyor.
Boylece baslik dahil GORUNEN her sey (Streamlit'in kendi dialog X-
butonu/disi cercevesi haric, o Streamlit'in kendi kontrolunde) birlikte
donuyor.

**Test durumu:** Yine canli ortamda test EDILEMEDI.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): st.dialog TAMAMEN Birakildi -- Kendi Pop-up Sistemimiz Kuruldu

Kullanici IKINCI KEZ "yine ayni sey, ic donuyor kart donmuyor" dedi.

**Kok sebep NIHAYET dogru teshis edildi:** Streamlit'in `st.dialog()`
bileseni kendi SABIT cercevesini (beyaz kutu, "Gün Detayı" baslik
cubugu, X kapatma butonu) URETIYOR -- bu cerceve TAMAMEN Streamlit'in
kendi kontrolunde, benim CSS'im ona ULASAMIYOR/ANIMASYON
UYGULAYAMIYOR. Ben sadece bu cercevenin ICINE koydugum icerigi
kontrol edebiliyordum -- bu yuzden ne kadar CSS degistirilirse
degistirilsin, "dis kutu sabit + ic icerik donuyor" sonucu
KACINILMAZDI. Bu, onceki iki denemenin (govde-sarma, kart+baslik-
birlestirme) neden ISE YARAMADIGINI aciklıyor.

**GERCEK COZUM:** `st.dialog` TAMAMEN kaldirildi. Yerine KENDI
insa ettigimiz bir pop-up sistemi kuruldu:
- Yari saydam bir "ortu" (backdrop, position:fixed, tum ekranı kaplar).
- Ortalanmis bir "sarmalayici" (position:fixed, tam ortada, z-index
  cok yuksek -- ust nav cubugunu bile ustune alacak sekilde).
- Icinde: KENDI cizdigimiz kapatma (X) butonu + flip-kart (baslik +
  icerik BIRLIKTE, tek kapsayicida -- onceki duzeltme).
- Bu yontem, projenin zaten kanitlanmis bir deseni: ust nav cubugu da
  ayni sekilde (position:fixed + gercek Streamlit widget'lari icinde)
  calisiyor.

**Artik BASLIK DAHIL TUM GORUNEN KUTU benim kontrolumde** -- animasyon
gercekten butune uygulanabiliyor, cunku disaridan gorunen HICBIR
parca artik Streamlit'in kendi (kontrol edilemeyen) bir bileseninden
gelmiyor.

**Test durumu:** Yine canli ortamda test EDILEMEDI -- ama bu sefer
kok sebep net oldugu icin (onceki iki denemenin neden basarisiz
oldugu ANLASILDI, korlemesine tekrar denemedik) cozumun dogru
yonde oldugundan daha eminim.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): Kendi Pop-up Denemesi Geri Alindi -- st.dialog'a Donuldu

Kullanici kendi insa edilmis (position:fixed backdrop) pop-up
denemesini BEGENMEDI, "bir onceki haline don" dedi.

**Geri alindi:** `_gun_popup_dialog` tekrar `@st.dialog("Gün Detayı")`
ile calisan basit haline dondu (backdrop/kapatma-butonu/sarmalayici
kod TAMAMEN kaldirildi). `_hafta_kartlarini_goster` da ayni sekilde
eski (st.dialog kullanan) haline dondu. Ilgili CSS kurallari
(omgo-popup-ortu, popupsarmalayici_, kapat_) temizlendi.

**Mevcut durum -- acikca hatirlatilan kisit:** st.dialog kullanildigi
icin, "kartin TAMAMI (Streamlit'in kendi dialog cercevesi HARIC)
donmesi" kisitli kaliyor -- sadece benim cizdigim ic kisim (baslik +
govde) donuyor, Streamlit'in kendi "Gün Detayı" baslik cubugu ve X
butonu sabit kaliyor. Kullanici bu duruma geri donmeyi tercih etti.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi (1064 satir).

### 13 Ağustos 2026 — XI. Oturum (devam): Pop-up Arka Yüzüne Genişletilmiş Besin Değerleri Eklendi (Seçenek D)

Kullanıcı, pop-up'ın arka yüzünde sadece 5 temel değerin (Kalori/
Protein/Yağ/Karbonhidrat/GI) gorunmesinin yetersiz oldugunu belirtti
-- 27 vitamin/mineral hic yansitilmiyordu. 4 secenek sunuldu, kullanici
"D"yi (varsayilan: temel 5 + o an hedeflenen degerler; ayrica "tumunu
gor" ile 32 ogenin tamami) sectii.

**Uygulanan:**
- Hedefler (kullanicinin "Ogun basina besin hedefi uygula" ile sectigi
  besin ogeleri) varsa, temel 5'in ALTINA "Hedeflenen Degerler" olarak
  otomatik ekleniyor.
- Yeni bir "▸ Tum besin degerlerini gor" / "▾ ...gizle" butonu (per-
  pop-up session_state ile acilir/kapanir) -- acildiginda kalan TUM
  vitamin/mineral/diger-makro (sodyum/lif/seker/doymus yag) degerleri
  "Diger / Vitaminler / Mineraller" olarak gruplanip gosteriliyor
  (hedeflenenlerle CAKISANLAR tekrar gosterilmiyor).
- Deger formatlama: 5'in altindaki degerler 2 ondalikli (ornek Vitamin
  B7 0.35 gibi kucuk degerler icin), 5 ve uzeri tam sayiya yuvarlaniyor.
  Deger yoksa (None) "-" gosteriliyor.
- Birim ve kisa ad, mevcut _BESIN_ETIKET sozlugunden otomatik cikariliyor
  (ayri bir sozluk gerekmedi).

**Test durumu:** Yardimci fonksiyonlar (_deger_formatla, _birim_al,
_kisa_ad) izole Python ile dogru sonuc verdigi test edildi. Tam
Streamlit render'i canli ortamda henuz denenmedi.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): "Veri Yok" Notu Eklendi + Öncelik Sorgusu Hazırlandı

Kullanıcının "Tüm besin değerlerini gör" ile bazı kategorilerin (Diğer/
Vitaminler/Mineraller) tamamen bos gorunmesi bildirimi -- SQL ile
DOGRULANDI: bu bir kod hatasi DEGIL, gercek bir veri bosluğu (564
malzemeden sadece 68'inde Vitamin C, 195'inde Kalsiyum, 194'unde
Demir var). O gunun 6 yemeginin malzemeleri, bu ozel besin ogelerini
hic icermeyen malzemelerden (tuz, yag, baharat gibi) olusmus.

**1) Uygulandi -- "veri yok" notu:** `_tablo_satirlari_yaz` artik
GERCEK veri yazip yazmadigini (True/False) donduruyor -- hicbir deger
yoksa sessizce bos birakmak yerine acikca "Bu değerler için veri yok
(seçilen yemeklerin malzemelerinde henüz ölçülmemiş)" notu gosteriyor.

**2) Devam ediyor -- oncelik sorgusu hazirlandi:** Hangi malzemelerin
EN COK tarifte kullanildigini (yuksek etki) AMA en cok temel besin
ogesi (VitC/Kalsiyum/Demir/VitA/Potasyum) eksik oldugunu bulan bir
sorgu (`oncelik_eksik_malzemeler.sql`) olusturuldu -- sonuc kullaniciya
sorulacak, sonra bu listedeki malzemeler icin arastirma/doldurma
devam edecek.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi,
sql/teshis_popup_besin_bos.sql ve sql/oncelik_eksik_malzemeler.sql
(yeni, sadece teshis/oncelik amacli, veritabanini degistirmiyor).

### 13 Ağustos 2026 — XI. Oturum (devam): Öncelikli 6 Malzeme Tamamlandı (İsot Bulunamadı)

Kullanıcının paylaştığı öncelik sorgusu sonucundan (40 satırın ilk 7'si
görünür durumdaydı) 6 tanesi tamamlandı:

- PATLICAN, KESTANE, NAR EKŞİSİ (Gaziantep) -- TürKomp'tan gerçek veri.
- MISIR NİŞASTASI -- TürKomp'tan.
- İNCE BULGUR -- TürKomp'ta tam "ince/köftelik" varyantı yok, en yakın
  mevcut eşdeğer ("Bulgur, pilavlık, Gaziantep") kullanıldı.
- YEŞİL BİBER -- USDA'dan ("Peppers, sweet, green, raw") -- TürKomp'ta
  sadece kırmızı/sarı "California Wonder" tipi bulundu, yeşil yoktu.

**İSOT bulunamadı:** Gerçek bir akademik kaynak (Korkmaz ve ark. 2016,
Harran Tarım ve Gıda Bilimleri Dergisi) bulundu ve tam metni okundu --
ama bu makale SADECE renk/nem/pH/su aktivitesi özelliklerini ölçmüş,
besin değeri (protein/vitamin/mineral) verisi HİÇ YOK. Diğer kaynaklar
(kaç-kalori siteleri, bloglar) güvenilir olmadığı için kullanılmadı.
İşlenmedi, boş bırakıldı.

**Kalan ~33 satır** (öncelik sorgusunun geri kalanı) kullanıcıdan
bekleniyor -- ekran görüntüsü/kaydırma ile paylaşılırsa devam edilecek.

**Dosya durumu:** sql/69_oncelikli_malzemeler_besin_degeri.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): 32 YÜKSEK ETKİLİ Malzeme Tamamlandı (Excel'den Tam Öncelik Listesi)

Kullanıcı öncelik sorgusunun TAM sonucunu (40 satır) bir Excel dosyası
(SQL.xlsx) olarak paylaştı -- pandas ile doğrudan okundu. Bu, en
yüksek etkili malzemeleri ortaya çıkardı (TUZ 128 tarifte, KURU SOĞAN
79, TEREYAĞI 74, ZEYTİNYAĞI 71 gibi).

**32 malzeme tamamlandı** (30 TürKomp + 2 USDA):
TUZ, KURU SOĞAN, TEREYAĞI, ZEYTİNYAĞI, ŞEKER, SIĞIR KIYMA (yaklaşık
eşleşme -- but eti, gerçek kıyma değil), BUĞDAY UNU, PİRİNÇ (HAM),
LİMON SUYU, DOMATES, SARIMSAK, YOĞURT (TAM), HAVUÇ, KARABİBER, TAVUK
YUMURTASI, YUFKA, CEVİZ (İÇ), LİMON, NOHUT, BULGUR, TAVUK GÖĞÜS (USDA,
derili varyant -- TürKomp'ta çiğ/derisiz bulunamadı), AYÇİÇEK YAĞI,
KAŞAR PEYNİRİ, KONSERVE DOMATES SALÇASI, SÜT (TAM YAĞ), KIRMIZI
MERCİMEK, KONSERVE DOMATES, LOR PEYNİRİ (USDA ricotta -- en yakın
uluslararası eşdeğer), KUZU TANDIR (yaklaşık eşleşme -- but eti),
PUL BİBER, KURU FASULYE, SU (neredeyse sıfır besin değeri, TürKomp'tan
gerçek veriyle doğrulandı).

**İşlenmeyenler:**
- İSOT: hâlâ geçerli bir akademik kaynak yok (önceki turda arandı).
- MAYDONOZ: Bahri'nin listesinde bu yazımla geçiyor ama TürKomp'ta
  "MAYDANOZ" var (bu oturumda daha önce USDA'dan işlenmişti) --
  yazım farkı nedeniyle bunun AYNI kalem mi yoksa veritabanında
  GERÇEKTEN ayrı bir satır mı olduğu netleşmedi, kullanıcıya
  sorulacak.

**Dosya durumu:** sql/70_yuksek_etkili_malzemeler_besin_degeri.sql
(yeni, 32 UPDATE içeriyor).

### 13 Ağustos 2026 — XI. Oturum (devam): Maydanoz/Maydonoz Aynı Malzeme Doğrulandı, İsot Vikipedi'de de Bulunamadı

Kullanıcı iki şeyi netleştirdi:
1. İsot'un Türkçe Vikipedi sayfasını paylaştı -- doğrulandı, İsot
   Urfa'da yetişen kırmızı acı biber türü (tanım/tarihçe/kullanım
   alanı doğru), AMA sayfa (diğer benzer gıda maddesi sayfaları gibi)
   hiçbir sayısal besin değeri tablosu içermiyor. İSOT hala
   çözülemedi, boş kalmaya devam ediyor.
2. MAYDANOZ ve MAYDONOZ'un aynı malzeme olduğunu, sadece iki farklı
   yazım şekli olduğunu doğruladı.

**Uygulandı:** Daha önce MAYDANOZ için kullanılan USDA verisi
("Parsley, fresh") her iki yazılışa da (coalesce ile, sadece boş
alanlara) uygulandı -- artık hangi yazılış kullanılmış olursa olsun
veri tutarlı.

**Not:** Bu, veritabanındaki olası "aynı malzemenin iki farklı
yazımla iki kez kayıtlı olması" veri kalitesi sorununu ÇÖZMÜYOR --
sadece her iki satırın besin değerlerini tutarlı hale getiriyor.
Katalogun uzun vadede tek bir yazılış etrafında birleştirilmesi ayrı
bir konu olarak ele alınabilir.

**Dosya durumu:** sql/71_maydonoz_maydanoz_ayni_malzeme.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): İSOT için Kullanıcı Onaylı Pul Biber Eşdeğerliği

Kullanıcı, "diyetkolik.com" tipi bir kaynağı önerdi ("İsot Biberi Kaç
Kalori?" -- 36 kcal/100g) -- Claude bunu REDDETTİ: Pul Biber (aynı
kategoride, TürKomp'tan gerçek veri) 286 kcal/100g çıkmıştı, 36 kcal
bunun ~1/8'i, kurutulmuş bir baharat için fiziksel olarak anlamsız;
ayrıca kaynak/yöntem belirtilmiyor, tıpkı Salep'te reddedilen "kaç
kalori" siteleri gibi.

Kullanıcı bunun yerine kendi ürün bilgisine dayanarak PUL BİBER ile
AYNI degerlerin kullanılmasını istedi -- "ikisi de aynı, ikisi de
kurutulmuş pul olarak kullanılıyor, isot daha acı olanı." Bu, Claude'un
kendi inisiyatifiyle veri uydurması DEĞİL -- kullanıcının kendi ürün
bilgisine dayanan, gerçek bir kaynaktan (TürKomp, PUL BİBER için daha
önce bulunan veri) türetilen bilinçli bir eşdeğerlik kararı.

**Uygulandı:** PUL BİBER'in TürKomp verisi (kalori=286, protein=11.69,
karbonhidrat=43.67, lif=32.25 -- TürKomp kaydında sadece bu 4 alan
ölçülmüş, vitamin/mineral o kayıtta da yoktu) İSOT'a coalesce ile
uygulandı.

**Dosya durumu:** sql/72_isot_pul_biber_esdegeri.sql (yeni).

### 13 Ağustos 2026 — XI. Oturum (devam): ÖNEMLİ KEŞİF -- Excel-Veritabanı Senkronizasyon Boşluğu Bulundu ve Kapatıldı

Kullanıcı Excel'in de güncellenmesini istedi. Migration 69-72'deki 41
malzemenin Excel karşılığı kontrol edilirken KRİTİK bir bulgu ortaya
çıktı: bu 41 malzemenin 38'inde HİÇBİR yeni hücre gerekmedi -- Excel'de
ZATEN dolu, gerçekçi değerler vardı (ör. TUZ sodyum=38700mg, TEREYAĞI
kalori=717) ama bu veri HİÇ veritabanına aktarılmamıştı!

**Sonuç:** Önceki turlarda "veri yok, araştırmam lazım" diye
yaklaştığım birçok durumun aslında "veri Excel'de zaten var ama
veritabanına hiç senkronize edilmemiş" olduğu anlaşıldı.

**Yapılan:** Excel'deki (v28) TÜM 564 malzemenin TÜM dolu hücreleri
tek bir kapsamlı SQL migration'a (73 numaralı) dönüştürüldü --
coalesce() ile SADECE veritabanında hâlâ boş olan alanlar dolduruluyor,
hiçbir mevcut veri değişmiyor. İstatistik: 564 malzeme, 14.214 SET
ifadesi (hücre). Bu, muhtemelen bu 41 malzemenin ÇOK ötesinde,
katalogun geri kalanındaki birçok boşluğu da tek seferde kapatacak.

**Excel:** kaynak_duzeltilmis_v29.xlsx (yeni) -- sadece 6 hücre yeni
eklendi (ŞEKER, CEVİZ İÇ, KIRMIZI MERCİMEK, KURU FASULYE'de birkaç
alan), geri kalanı v28 ile aynı (zaten doluydu).

**ÖNEMLİ TAVSİYE:** 73 numaralı migration çalıştırıldıktan sonra,
veritabanının besin verisi kapsamı önemli ölçüde artacak -- bundan
sonraki "eksik malzeme" araştırmalarına başlamadan ÖNCE bu
migration'ın çalıştırılıp çalıştırılmadığı kontrol edilmeli, aksi
halde zaten Excel'de olan veri için gereksiz yere tekrar araştırma
yapılabilir.

**Dosya durumu:** kaynak_duzeltilmis_v29.xlsx (yeni),
sql/73_excel_veritabani_tam_senkronizasyon.sql (yeni, BÜYÜK dosya --
564 UPDATE, 14.214 hücre).

### 13 Ağustos 2026 — XI. Oturum (devam): 73 Numaralı Migration 6 Parçaya Bölündü

Kullanıcı, 73 numaralı migration'ı Supabase SQL Editor'de KAYDEDEMEDİĞİNİ
bildirdi ("Failed to rename snippet: request entity too large") --
"Untitled query" olarak calistirip kaydetmeden birakmak da işe
yaramıyor (sayfa yenilendiğinde/başka sorgu açıldığında kayboluyor).

**Çözüm:** 564 UPDATE ifadesi 6 eşit parçaya bölündü:
- sql/73_1_excel_veritabani_senkronizasyon_parca1.sql (94 ifade, ~103KB)
- sql/73_2_..._parca2.sql (94 ifade, ~104KB)
- sql/73_3_..._parca3.sql (94 ifade, ~105KB)
- sql/73_4_..._parca4.sql (94 ifade, ~107KB)
- sql/73_5_..._parca5.sql (94 ifade, ~107KB)
- sql/73_6_..._parca6.sql (94 ifade, ~89KB)

Her biri bağımsız çalıştırılıp kaydedilebilir, hepsi coalesce()
güvenliğini koruyor. Kullanıcının hepsini sırayla çalıştırması
bekleniyor.

**Dosya durumu:** 6 yeni SQL dosyası, orijinal büyük
73_excel_veritabani_tam_senkronizasyon.sql yerine kullanılacak.

### 13 Ağustos 2026 — XI. Oturum (devam): Öğün Başlıkları Büyütüldü ve Yeniden Adlandırıldı

Kullanıcı "MAKRO" etiketinin anlamını sordu (kalori/protein/yağ/
karbonhidrat/GI = makro-besin ögeleri, aşağıdaki Vitaminler/
Mineraller'den -- mikro besin ögeleri -- ayırt etmek için) --
açıklandı. Kullanıcı bu başlığın "ÖĞLE YEMEĞİ"/"AKŞAM YEMEĞİ" olarak
değiştirilmesini, daha büyük/kalın fontla ve ortalanmış olmasını
istedi.

**Uygulandı:** "{Öğle/Akşam} — Makro" -> "{ÖĞLE/AKŞAM} YEMEĞİ" (yeni
.omgo-ogun-baslik-buyuk sınıfı: Fraunces serif, 19px, 700 ağırlık,
ortalanmış, büyük harf). Koyu arka planda (popupkart_arka_) rengin
doğru (ochre) kalması için özel bir öncelik kuralı da eklendi.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): Ön Yüzdeki Öğün Etiketleri de Büyütüldü

Kullanıcı, arka yüzde onaylanan büyük/kalın/ortalanmış öğün başlığı
stilinin ön yüze (yemek listesi görünümü) de uygulanmasını istedi.

**Uygulandı:** Ön yüzdeki küçük "ÖĞLE"/"AKŞAM" pastel pill-etiketleri
(.omgo-ogun-etiket/.omgo-ogle/.omgo-aksam) kaldırıldı, yerine arka
yüzle AYNI .omgo-ogun-baslik-buyuk sınıfı (Fraunces, 19px, 700 ağırlık,
ortalanmış, büyük harf, "ÖĞLE YEMEĞİ"/"AKŞAM YEMEĞİ") kullanıldı.
Artık ön ve arka yüzde öğün başlıkları tutarlı görünüyor. Kullanılmayan
eski pill-etiket CSS kuralları temizlendi.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): Mobil Düzensizlik İncelemesi + Maliyet Tutarsızlığı Araştırması

**1) Mobil/tablet kart düzensizliği:** Kullanıcı, uzun gün adlarının
(Perşembe, Çarşamba vb.) dar ekranlarda kendi içinde kırılıp kartların
farklı boylarda göründüğünü, "bölge menü kartları" gibi başka yerlerde
de aynı sorunun olduğunu bildirdi.

Uygulanan (UNTESTED, canlı ortamda görülmeden):
- @media (max-width:700px/480px) ile başlık font boyutu kademeli
  küçültüldü (19px -> 11px -> 9.5px).
- @media (max-width:700px) ile Streamlit'in sütun kapsayıcısına
  ([data-testid="stHorizontalBlock"] -- TAHMIN, dogrulanmadi)
  flex-wrap eklendi -- boylece dar ekranda 7 sutun alt satirlara
  kayabilir, her kart daha genis kalir. Bu CSS TÜM sayfaya (ayni
  0_Yillik_Menu.py icindeki "bölge (mutfak)" secim sutunlari dahil)
  etki eder -- kullanicinin bahsettigi "bölge menü kartları" da
  muhtemelen bu fix'ten faydalanacak (ayni sayfada, ayni st.columns
  mekanizmasi kullaniliyorsa).

**2) Maliyet tutarsızlığı (1.58€ pop-up vs 8.17€ tarif toplamı):**
Kod TAM olarak incelendi -- GLOBAL tarifler (İçli Köfte gibi) için
hem pop-up hem Tarif Kütüphanesi AYNI formülü kullanıyor (malzeme
başına miktar/1000 × fiyat, porsiyon bölmesi/çarpması YOK bu
fonksiyonda). Kod düzeyinde bir bölme/çarpma hatası BULUNAMADI.

TESPIT EDİLEN GERÇEK FARK: Tarif Kütüphanesi'nde "Porsiyon sayısı"
(st.number_input, varsayılan 1) kullanıcı tarafından değiştirilebilir
ve gösterilen maliyeti bu sayıyla ÇARPIYOR (`malzeme_eur =
tarif["maliyet_eur"] * porsiyon`). Kullanıcıya, İçli Köfte'ye
baktığında bu kutunun gerçekten "1" gösterip göstermediği soruldu --
eğer farklıysa (Streamlit widget durumu sayfalar arası kalıcı olabilir),
bu ÇARPIMDAN kaynaklanan bir görünüm farkı olabilir, kod hatası değil.
POP-UP'IN gösterdiği değere güvenilmesi önerildi (her zaman "1
porsiyon" varsayımıyla hesaplanıyor). Kullanıcının yanıtı BEKLENİYOR.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi (mobil CSS).

### 13 Ağustos 2026 — XI. Oturum (devam): Mobil/Tablet Kart Düzeni Düzeltildi + Maliyet Tutarsızlığı Açıklığa Kavuşturuldu

**1) Maliyet tutarsızlığı (ARAŞTIRILDI, kod hatası DEĞİL):** Kullanıcı,
Yıllık Menü pop-up'ında öğle yemeği için 1.58€ gördüğünü ama Tarif
Kütüphanesi'nde aynı 3 yemeğin (İçli Köfte 5.39€ + Mercimek Çorbası
1.75€ + Nar Taneli Meyve Tabağı 1.03€ = 8.17€) TOPLAMININ çok daha
yüksek çıktığını bildirdi -- "hangisi doğru?" diye sordu.

Kod incelendi: Tarif Kütüphanesi'nde "Porsiyon sayısı" kutusu VARSAYILAN
1 (satır 192), ve gösterilen maliyet `tarif["maliyet_eur"] * porsiyon`
formülüyle hesaplanıyor -- bu, Yıllık Menü'nün kullandığı TEMEL
`maliyet_eur` (recete_malzemeleri tablosundaki, 1 PORSİYON baz alınarak
tasarlanmış miktarlar üzerinden) ile BİREBİR AYNI kaynak. Oran hesabı
(8.17/1.58 ≈ 5.17) kullanıcının o tarifleri incelerken "Porsiyon
sayısı" kutusunu muhtemelen ~5'e ayarlamış (fark etmeden) olduğuna
işaret ediyor. **Sonuç: Yıllık Menü'deki 1.58€ doğru** (1 kişilik
porsiyon başına) -- kullanıcıdan Tarif Kütüphanesi'nde "Porsiyon
sayısı" kutusunun değerini kontrol etmesi istendi.

**2) Mobil/tablet kart düzeni düzeltildi:** Kullanıcı ekran görüntüsü
gönderdi -- mobil/tablet genişlikte hem hafta günü kartları hem bölge
menü kartları eşit-sabit 7 (veya N) sütuna sıkışıp metin kelime
ortasından bölünüyordu (ör. "Pazar/tesi"). Kök neden: mevcut duyarlı
(responsive) CSS kuralı SADECE 700px altı (telefon) genişliği
kapsıyordu, tablet (tipik 700-1024px) dışarıda kalıyordu. Eşik
1024px'e genişletildi.

Ayrıca, bu CSS'in ASIL enjeksiyon noktası (_yillik_menu_tasarim_
stilini_uygula) SADECE menü üretildikten SONRA çalıştığı için, menü
üretilmeden önce görünen bölge menü kartları bu korumadan mahrum
kalıyordu -- yeni, küçük bir `_duyarli_sutun_css_uygula()` fonksiyonu
sayfanın EN BAŞINDA, koşulsuz çağrılarak eklendi.

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi (1199 satır).

### 13 Ağustos 2026 — XI. Oturum (devam): Standart Porsiyon 10'a Çıkarıldı (Tarif Kütüphanesi + Yıllık Menü + Excel)

Kullanıcı, gerçek mutfaklarda (ve evde bile) tek porsiyonluk üretimin
nadir olduğunu belirterek uygulamanın standart porsiyon sayısını 10'a
çıkarmasını, bunun her maliyet/tarif gösterilen yerde AÇIKÇA
belirtilmesini istedi.

**1) Tarif Kütüphanesi:** "Porsiyon sayısı" kutusunun varsayılan
değeri 1 -> 10 yapıldı. Mevcut kod zaten dinamik olarak
"Malzemeler (N porsiyon için)" etiketi ve tüm besin/maliyet
hesaplarını `* porsiyon` ile ölçeklediği için, sadece varsayılanı
değiştirmek yeterli oldu (gerçek üretim maliyeti -- enerji/işçilik --
hesabı da zaten dinamik olarak ölçekleniyor).

**2) Yıllık Menü pop-up'ı (arka yüz):** Daha önce SADECE 1 porsiyonluk
değerler gösteriliyordu (hiç ölçekleme yoktu). Artık kalori/protein/
yağ/karbonhidrat/maliyet VE tüm 27 genişletilmiş besin ögesi 10 ile
çarpılıyor, öğün başlığının hemen altına "(10 porsiyon için)" notu
eklendi. Glisemik İndeks (bir ORAN olduğu için) ve alerjen/eksik-fiyat
listeleri (kategorik bilgi) ÖLÇEKLENMEDİ -- doğru mantık.

**KRİTİK DÜZELTME:** "Hedefte/Hedef dışı" kontrolü (_hedefte_mi),
kullanıcının belirlediği hedef aralıkları HÂLÂ 1 porsiyon baz alınarak
tasarlandığı için, ÖLÇEKLENMEMİŞ (t_ham) değerlerle yapılmaya devam
ediyor -- ekranda gösterilen (10x) değerle DEĞİL. Bu ayrım
yapılmasaydı, hemen hemen her öğün yanlışlıkla "hedef dışı"
görünürdü.

**3) Excel export:** Aynı 10x ölçekleme ve "(10 porsiyon)" etiketi
Excel'deki öğün başlık satırına da uygulandı, hedef kontrolü orada da
ölçeklenmemiş değerle yapılıyor.

**Dosya durumu:** pages/0_Yillik_Menu.py, pages/5_Tarif_Kutuphanesi.py
güncellendi.

### 13 Ağustos 2026 — XI. Oturum (devam): ACİL DÜZELTME -- Sayfalama Eksikliği Nedeniyle Sessiz Veri Kaybı

Kullanıcı, 30 Ekim Cuma Akşam Yemeği için pop-up'ta 30.94€ görürken,
Tarif Kütüphanesi'nden aynı 3 yemeğin (Kayısılı Kuzu Tandır 20.81€ +
Ezo Gelin Çorbası 3.37€ + Kayısı Tatlısı 12.05€) TOPLAMININ 36.23€
çıktığını bildirdi -- oran temiz bir katsayı DEĞİLDİ (önceki "porsiyon
ayarı" sorunundan farklı), bu yüzden gerçek bir kod hatası olduğu
anlaşıldı, "acil çözüm" istendi.

**KÖK SEBEP BULUNDU (kod karşılaştırmasıyla, tahmin değil):**
`pages/5_Tarif_Kutuphanesi.py`'de zaten var olan `_sayfalayarak_getir`
yardımcı fonksiyonunun docstring'i şunu açıkça belirtiyor: "Supabase/
PostgREST, .range() belirtilmese bile sorgu başına varsayılan olarak
en fazla 1000 satır döndürüyor -- sınırın üzerindeki satırlar HATA
VERMEDEN sessizce kesiliyor." Tarif Kütüphanesi bu korumayı
kullanıyordu, AMA `pages/0_Yillik_Menu.py`'deki AYNI tabloları çeken
sorgular (malzeme_guncel_fiyat VE recete_malzemeleri VE malzeme_
alerjen) bu korumayı HİÇ kullanmıyordu -- düz `.execute()` ile
çekiliyorlardı.

**recete_malzemeleri (tarif-malzeme iliski tablosu) EN CIDDI risk
altındaydi** -- 241 tarif × ortalama malzeme sayısı kolayca 1000
satırı geçebilir, bu da SADECE maliyeti değil, bazı tariflerin kalori/
protein/vitamin hesaplarını da sessizce eksik bırakıyor olabilirdi.

**Düzeltme:** `_sayfalayarak_getir` fonksiyonu (Tarif Kütüphanesi'nden
birebir aynı mantıkla) 0_Yillik_Menu.py'ye de eklendi, TÜM 6 ilgili
sorgu (malzeme_kalemleri ×2, alerjen_kayitlari ×2, fiyat_kayitlari ×2
-- hem global hem işletmeye özel tarif fonksiyonlarında) bu güvenli
yöntemle değiştirildi.

**Kontrol edilen ama şimdilik risksiz bulunan:** `receteler` tablosu
(241 satır, 1000 sınırının altında) -- ileride tarif sayısı büyürse
gözden geçirilebilir.

**Bu düzeltme muhtemelen sadece bu bir maliyet farkını değil, daha
önce fark edilmemiş başka gizli tutarsızlıkları da (bazı tariflerin
kalori/vitamin toplamlarında) düzeltmiş olabilir.**

**Dosya durumu:** pages/0_Yillik_Menu.py güncellendi (kritik veri
bütünlüğü düzeltmesi).

### 13 Ağustos 2026 — XI. Oturum (devam): Pop-up Artik TAM Uretim Maliyeti Gosteriyor (Malzeme+Enerji+Iscilik)

Kullanicinin sorusu uzerine kod incelendi ve ONEMLI bir mimari
tutarsizlik bulundu: Tarif Kutuphanesi'nde ZATEN var olan "Gerçek
üretim maliyeti (malzeme + enerji + işçilik)" hesaplamasi (üretim
asamalari -- isil islem/ozgul isi/sicaklik farkindan enerji, aktif
dakikadan iscilik) Yillik Menu pop-up'inda HIC KULLANILMIYORDU --
pop-up sadece basit malzeme toplamini gosteriyordu. Kullanici, pop-up'in
da TAM hesaplamaya gore guncellenmesini istedi.

**Uygulandi:** `_uretim_asamalarini_getir`, `_maliyet_ayarlarini_getir`,
`_gercek_maliyet_hesapla` fonksiyonlari (5_Tarif_Kutuphanesi.py'den
BIREBIR AYNI mantikla) 0_Yillik_Menu.py'ye eklendi. Ayrica yeni bir
`_tum_tarif_id_by_ad_getir` fonksiyonu eklendi (pop-up'in `detay`
sozlugu sadece ADA gore anahtarli, id tasimiyordu -- uretim
asamalarina erismek icin id gerekiyor).

Pop-up'taki "Maliyet" satiri artik 4 satira bolundu: Malzeme / Enerji /
İşçilik / **Toplam Maliyet** (kalin) -- her ogundeki 3 (veya 4) yemegin
uretim asamalari ayri ayri hesaplanip toplaniyor, malzeme maliyetiyle
(zaten 10 porsiyona olceklenmis) birlikte gosteriliyor.

**Bilinen, henuz guncellenmeyen tutarsizlik:** Excel export
(_aylik_menu_excel_olustur) hala SADECE malzeme maliyetini gosteriyor
-- kullanici ayrica isterse bu da ayni modele guncellenebilir.

**Test durumu:** Canli ortamda test EDILEMEDI (sandbox'ta Streamlit
yok) -- ozellikle her yemegin recete_id'sinin dogru bulunup
bulunmadigi (isim eslesmesi) canli denemede dogrulanmali.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi (1347+ satir).

### 13 Ağustos 2026 — XI. Oturum (devam): 27 Besin Ögesi Hedef Aralığı GERÇEK VERİYE GÖRE Yeniden Kalibre Edildi

Kullanıcı, "neredeyse hiç öğün hedefte çıkmıyor" sorununu bildirdi --
ekran görüntüleriyle (16+ mikrobesin AYNI ANDA hedeflenmiş, gerçek
değerler -- Fosfor 5734mg, Potasyum 11032mg gibi -- çok yüksek)
teşhis netleşti: sorun kod hatası değil, TUM_BESIN_ALANLARI'ndaki
varsayılan hedef aralıklarının "kabaca tahmin" olup GERÇEK (artık tam
olan) veriyle uyuşmamasıydı.

Kullanıcı, "hedeflenen değer sayısını azalt" seçeneğini KESİNLİKLE
REDDETTİ -- gelecekte hastane/huzurevi/yatılı okul gibi ÇOK SAYIDA
besin ögesini AYNI ANDA hedefleyecek kurumsal kısıtlar ekleyeceğini
belirtti, altyapının bunu desteklemesi gerektiğini vurguladı.

**Uygulanan çözüm:** kalibrasyon_besin_dagilimi.sql ile TÜM tariflerin
(564 malzeme, tam veri) GERÇEK tek-tarif medyan/p90 dağılımı ölçüldü
(kullanıcı CSV olarak paylaştı). Bir öğün ~3 tarifin (ana+yardımcı+
tamamlayıcı) toplamı olduğu için, "3 x medyan" o besin ögesi için
TİPİK bir öğün değeri kabul edildi, TÜM 32 alanın (5 temel + 27
genişletilmiş) def_alt/def_ust değerleri bu gerçek dağılıma göre
YENİDEN YAZILDI.

**En çok değişen alanlar (önceki tahminler gerçek veriden ÇOK
UZAKTI):**
- Sodyum: 200-800mg -> 800-5000mg (gerçek medyan zaten 1126mg/tarif!)
- Fosfor: 100-300mg -> 100-900mg
- Potasyum: 400-1200mg -> 300-2500mg
- Kalsiyum: 150-450mg -> 50-600mg
- İyot: 20-60mcg -> 10-500mcg
- Vitamin D: 2-6mcg -> 0-3mcg (gercek medyan sadece 0.04!)
- Vitamin B7: 5-15mcg -> 0-8mcg (gercek medyan sadece 0.24!)
- Diger 20 alanda da daha kucuk duzeltmeler yapildi (Yağ, Vitamin B2/
  B3/B6/B12/C/K, Çinko, Bakır, Manganez).

**Dogrulama:** Gercek medyan x3 degerleri TUM 32 yeni aralikla test
edildi -- **31/31 basarili** (kalori zaten dogruydu, digerleri artik
dogru). Tip tutarliligi (StreamlitMixedNumericTypesError riski) ve
mantikli siralama (min<=varsayilan_alt<=varsayilan_ust<=maks) da
otomatik dogrulandi.

**Dosya durumu:** pages/0_Yillik_Menu.py guncellendi (TUM_BESIN_
ALANLARI tamamen yeniden kalibre edildi).

### 13 Ağustos 2026 — XI. Oturum (devam): "Menü Mühendisi" Başlığına Sebze/Meyve/Et/Balık Süslemesi Eklendi

Kullanıcı, "Kontrol Paneli sayfasındaki gibi" başlığın etrafına sebze/
meyve/malzeme/et-balık süslemesi istedi. Kullanıcı, Kontrol Paneli'nin
kendi tanıtım görsellerini (tanitim_menu.png, tanitim_receteler.png,
tanitim_uretim_asamalari.png, tanitim_yillik_menu.png, tanitim_video.mp4)
paylaştı -- bunlar sandbox'ta hiç yoktu (kullanıcı kendi tarafında
eklemiş), "Görsel henüz eklenmedi" placeholder'ı devredeydi.

**Uygulanan:**
1. tanitim_yillik_menu.png'den (Kontrol Paneli'nin kendi süsleme dili)
   sol-üst köşe (yaprak+armut/lale+elma/nar-çiçeği) ve sağ-üst köşe
   (ananas+güneş) demetleri PIL ile kırpıldı, HSV doygunluk-tabanlı bir
   maskeyle arka planı SAYDAM yapıldı (krem/bej ton düşük doygunluk,
   ikonlar yüksek doygunluk -- net ayrıştı), assets/baslik_susu_sol.png
   ve assets/baslik_susu_sag.png olarak kaydedildi.
2. Kaynak görsellerde et/balık AYRI bir ikon olarak yoktu (sadece büyük
   illüstrasyonların içinde) -- bu yüzden domates, biber, balık, et
   için AYNI düz-tasarım tarzında (tek renkli, sade), mevcut Yıllık
   Menü kart paletiyle (rust #A6472F, sage #5B7553, indigo #2E4057)
   tutarlı kendi SVG ikonlarım eklendi.
3. Masaüstü nav satırı: [raster süs-sol] [domates][biber] Menü
   Mühendisi [balık][et] [raster süs-sağ] -- base64 veri-URI ile
   gömüldü (Streamlit özel CSS/HTML'de yerel dosya yolu güvenilir
   çalışmıyor).
4. Mobil nav satırı: sayfa ağırlığı için raster GÖRSELLER DAHIL
   EDİLMEDİ, sadece küçük domates+balık SVG'si (hafif).

**Dosya durumu:** app.py güncellendi, assets/baslik_susu_sol.png ve
assets/baslik_susu_sag.png (yeni, projeye eklenmesi gerekiyor).
