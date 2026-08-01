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
1. **[TAMAMLANDI — bkz. IV. Oturum]** ~~Yıllık menü üretim motoru: şema
   genişletmesi + tarif kütüphanesi veri girişi~~ → 74 tariflik set
   hazırlandı, `12_tarif_kutuphanesi_global_receteler.sql` +
   `yukle_tarifler.py` teslim edildi. **Sıradaki alt-adım:** SQL'i
   Supabase'de çalıştır, `yukle_tarifler.py`'yi çalıştır, sonra menü
   **üretim algoritmasının** (haftalık/yıllık takvim doldurma mantığı)
   tasarımına geç.
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
