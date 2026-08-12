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
