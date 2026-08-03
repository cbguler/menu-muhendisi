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
