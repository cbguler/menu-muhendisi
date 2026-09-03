# ÖZET — Menü Mühendisi, XI. Oturum Sonu (Hazırlık Aşaması İkonları + AI Sınıflandırma)

Bu dosya, bir önceki sohbetin görsel limiti dolduğu için yeni bir
sohbete geçerken bağlamın kaybolmaması için hazırlandı. Yeni sohbette
bu dosyayı Claude'a verirsen kaldığımız yerden devam edebiliriz.

---

## 1. Bu Oturumda Ne Yapıldı (Genel Akış)

1. **Yıllık Menü'de "aynı gün benzer yemek tekrarı" düzeltildi**
   (`uretim_algoritmasi.py`) — kelime-kökü tabanlı bir sezgisel
   yöntemle (ör. "Cacık" ile "Sumaklı Cacık" aynı sayılır).
2. **Tarif sayısını artırma ve tarif görselleri** konuları araştırıldı.
3. **Hazırlık aşaması ikonları** fikri doğdu: doğrama, kavurma, haşlama
   gibi 20 temel mutfak işlemi için Gemini ile üretilen çizgi
   resimler, hem **Reçete Üretimi** hem **Tarif Kütüphanesi**
   sayfalarında ilgili adımın altında otomatik gösteriliyor.
4. **Malzeme-özel ikon varyantları** eklendi: gerçek SQL analiziyle
   soğanın (78 tarif) en baskın malzeme olduğu bulunup öncelik
   sırasına konuldu (soğan > limon/biber > meyve > temel).
5. Kelime-kökü eşleştirmesinde **tekrar tekrar gerçek hatalar** bulundu
   ve düzeltildi (yoğur/yoğurt es-sesliliği, "SÜRE ÖZETİ" satırında
   yanlış eşleşme, "salatalık"→"salatalığı" ünsüz yumuşaması SQL
   analizini kör bırakmıştı, vb.) — bu, yöntemin temelden güvenilmez
   olduğunu gösterdi.
6. **Kritik karar:** Kelime-kökü eşleştirmesi bırakılıp, **AI tabanlı
   BİR KEZ (ve artımlı) sınıflandırma** mimarisine geçildi.
7. **Sağlayıcı seçimi çok sancılı oldu** (bkz. bölüm 4) — sonunda
   Groq'ta küçük bir modelde karar kılındı.

---

## 2. Mevcut Kod Mimarisi (ÇALIŞIR DURUMDA, test bekliyor)

### `asama_ikonlari.py` (paylaşımlı modül)
- `ASAMA_IKON_KOKLERI`: 19 eylem → kelime kökü listesi (artık sadece
  AI script'inin GEÇERLİ EYLEM listesini oluşturmak için referans
  olarak kullanılıyor; asıl eşleştirmeyi AI yapıyor).
- `_SPESIFIK_MALZEME_VARYANTLARI`: öncelik sıralı liste — şu an
  `soğan`, `limon`, `biber` var. Yeni malzeme eklemek için tek satır
  yeterli.
- `ikon_yolu_for_eylem(eylem_adi, satir)`: **YENİ, ÖNEMLİ fonksiyon** —
  AI'nin bulduğu bir eylem adı + satır metni verildiğinde, mevcut
  malzeme-önceliği mantığını (soğan > limon > biber > meyve > temel)
  kullanarak doğru ikon dosya yolunu döndürür. AI SADECE eylemi
  buluyor, malzeme-varyant seçimini hâlâ bu KANITLANMIŞ kod yapıyor.
- `tek_ikon_bul()` / `tum_ikonlari_bul()`: ESKİ kelime-kökü yöntemi,
  artık sadece **fallback** olarak duruyor (AI henüz sınıflandırmadığı
  tarifler için).

### `pages/5_Tarif_Kutuphanesi.py`
- `receteler.hazirlik_ikonlari` (yeni JSONB sütun) içinde
  `{"hash": ..., "ikonlar_by_satir": [[...], [...], ...]}` var mı VE
  hash güncel mi kontrol ediyor. Varsa AI sonucunu kullanıyor, yoksa
  (veya bayatsa) eski kelime-kökü yöntemine sessizce düşüyor.
- Her satırın ikonu, o satırın HEMEN ÜSTÜNDE gösteriliyor (220px,
  `st.columns(..., gap="medium", vertical_alignment="bottom")` ile
  hizalı, `width=260`).

### `pages/1_Recete_Uretimi.py`
- Kullanıcının kendi özel reçetelerindeki "üretim aşamaları" için
  AYNI ikon sistemini (eski kelime-kökü yöntemiyle, `tek_ikon_bul`)
  kullanıyor — bu sayfa henüz AI sınıflandırmasına taşınmadı (gerek de
  yok, çünkü orada aşama adları zaten kısa/temiz, "SÜRE ÖZETİ" gibi
  sorunlu satırlar yok).

### `sql/76_hazirlik_ikonlari_ekle.sql`
- `receteler.hazirlik_ikonlari` JSONB sütununu ekleyen migration.
  **Kullanıcı tarafından çalıştırıldı, sorun yok.**

### `ikon_siniflandirma_calistir.py` + `.bat`
- **Amaç:** 241 kütüphane tarifinin `hazirlik_talimati` metnini AI ile
  (satır satır, hangi mutfak işlemi geçiyor) sınıflandırıp
  `hazirlik_ikonlari`'na yazan BAKIM script'i.
- **Artımlı:** sadece `hazirlik_ikonlari` boş olan veya
  `hazirlik_talimati` hash'i değişmiş tarifleri işler.
- **Gruplu:** 12 tarif tek istekte gönderiliyor (token israfını
  azaltmak için).
- **ŞU AN Groq + `llama-3.1-8b-instant` kullanıyor** (bkz. bölüm 4 —
  bu son karar, henüz test edilmedi).
- Supabase'e **`service_role` anahtarıyla DOĞRUDAN** bağlanıyor
  (`db.py` KULLANILMIYOR) — çünkü `db.py`'nin RLS'e tabi anahtarı
  güncellemeleri SESSİZCE 0 satırla sonuçlandırıyordu (hata
  vermeden). Her güncellemeden sonra dönen veri gerçekten boş mu diye
  kontrol ediliyor.

**Gerekli ortam değişkenleri (kullanıcının bilgisayarında `setx` ile
KALICI olarak ayarlı):**
- `GROQ_API_KEY_IKON` (TrendSurf'teki `GROQ_API_KEY`'den KASITLI
  olarak ayrı bir Groq hesabına ait — hotmail.com/outlook.com kabul
  etmediği için Gmail ile açıldı: bkz. bölüm 5)
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY` (RLS'i atlar, ÇOK GİZLİ)
- `GEMINI_API_KEY` de ayarlı ama artık KULLANILMIYOR (Gemini'den
  vazgeçildi, bkz. bölüm 4) — isterse silinebilir, zararı yok.

---

## 3. Teslim Edilmiş 20 Temel İkon + Varyantlar

`assets/` klasöründe (düz, alt klasörsüz):

**20 temel eylem:** dograma, dilimleme, rendeleme, soyma, kavurma,
kizartma, haslama, izgara, firinlama, buharda_pisirme, kozleme,
karistirma, cirpma, yogurma, ezme, suzme, marine_etme, dinlendirme,
demleme (artık kullanılmıyor, `dinlendirme`'ye yönlendiriliyor),
baharatlama.

**Malzeme varyantları (sadece dograma/dilimleme/rendeleme/soyma
için):**
- `_meyve` (elma ile): dograma_meyve, dilimleme_meyve,
  rendeleme_meyve, soyma_meyve — TESLİM EDİLDİ.
- `_sogan`: dograma_sogan, dilimleme_sogan, rendeleme_sogan,
  soyma_sogan — TESLİM EDİLDİ.
- `_limon`, `_biber`: promptlar verildi
  (`limon_biber_ikon_prompt_listesi.md`) ama kullanıcı HENÜZ
  ÜRETMEDİ/GÖNDERMEDİ — bekliyor.

**kavurma ve haslama** jenerik (malzemesiz) versiyonlarla
GÜNCELLENDİ — artık belirsiz/spesifik bir malzeme göstermiyorlar.

---

## 4. Sağlayıcı Serüveni (ÖNEMLİ — yeni sohbette tekrar yaşanmasın)

Kronolojik olarak denenenler ve neden vazgeçildiği:

1. **Groq + `openai/gpt-oss-120b`**: Çalıştı ama GÜNLÜK 200.000 TOKEN
   (TPD) limitine defalarca takıldı — 240 tarifi bitirmek günler
   sürecekti. Ayrıca bu model 16 Ağustos 2026'da bir ARA
   `llama-3.3-70b-versatile`'ın yerine geçmişti (o da kaldırılmıştı).
2. **Google Gemini denendi** (kullanıcı `menumuhendisi@gmail.com` ile
   yeni hesap açtı): Art arda 3 model adı denendi
   (`gemini-2.0-flash-lite` → 404 kaldırılmış;
   `gemini-3.5-flash-lite` → "prepayment credits depleted";
   `gemini-2.5-flash-lite` → "no longer available to new users").
   **KÖK SEBEP BULUNDU:** Google, 23 Mart 2026'dan itibaren YENİ
   hesaplar için Gemini API kullanmadan önce en az 10$'lık ZORUNLU bir
   "prepay" şartı getirmiş. Kullanıcı ücretli çözüm istemediği için
   Gemini'den TAMAMEN VAZGEÇİLDİ.
3. **Groq'a geri dönüldü, ama KÜÇÜK model:** `llama-3.1-8b-instant`.
   Araştırma (topluluk kaynaklı, resmi değil) küçük modellerde sert
   bir günlük TOKEN duvarı olmadığını, sadece dakikalık token + günlük
   İSTEK SAYISI sınırı olduğunu gösterdi. **BU SON HALİ HENÜZ TEST
   EDİLMEDİ** — yeni sohbette ilk iş bunu test etmek.

**Diğer önemli dersler:**
- Groq hotmail.com/outlook.com e-postalarını kabul etmiyor (Gmail
  kullanılmalı).
- Groq rate limit'leri HESAP bazında havuzlanıyor, anahtar bazında
  DEĞİL (yeni anahtar oluşturmak izolasyon sağlamıyor, tamamen ayrı
  hesap gerekiyor).
- Model adları Groq'ta VE Gemini'de çok hızlı değişiyor/kaldırılıyor
  — bir model adı çalışmazsa güncel adını ARAŞTIRMAK gerekiyor,
  tahmin etmemeli.

---

## 5. Yeni Sohbette İlk Yapılacaklar

1. **Kullanıcıya sor:** `.bat` dosyasını (güncel hali: Groq +
   `llama-3.1-8b-instant`) çalıştırdı mı, sonucu ne oldu?
   - Başarılıysa: kaç tarif işlendi, hata var mı bak.
   - `llama-3.1-8b-instant` da bir rate limit'e takılırsa: hata
     mesajını DİKKATLİCE oku (TPD mi TPM mi RPD mi?), ona göre karar
     ver -- gerekirse ARAŞTIRMA yap (model adları/limitler hızlı
     değişiyor, GÜNCEL bilgiye güven, bu özetteki bilgilere değil).
2. **Tüm 241 tarif sınıflandırılınca:** Tarif Kütüphanesi'nde birkaç
   farklı tarifte (özellikle önceden sorunlu çıkan "cacık/salatalık",
   "yoğurt/yoğurma" gibi örnekler) ikonların doğru göründüğünü
   doğrula.
3. **Bekleyen küçük iş:** `limon_biber_ikon_prompt_listesi.md`'deki 8
   promptu kullanıcı henüz Gemini'de üretmedi — hatırlatılabilir
   (düşük öncelik, sistem bunlar olmadan da sorunsuz çalışıyor,
   sadece limon/biber için temel/sebze ikonuna düşüyor).
4. **Kütüphane büyüdükçe** (241 → 1000): `ikon_siniflandirma_calistir.py`
   sadece YENİ/DEĞİŞEN tarifleri işleyecek şekilde zaten hazır --
   kullanıcının sadece `.bat`'ı tekrar çalıştırması yeterli.

---

## 6. Diğer Bekleyen/Arka Planda Konular (bu oturumdan ÖNCEKİ, hâlâ geçerli)

- Halka Arz Graham/Çarpan sütunlarının boş kalması (Tesseract OCR
  kalite sorunu) — çözülmedi, gelecek bir oturumda ele alınabilir.
- KAP tabanlı temettü hattı (yfinance yerine) — onaylandı ama
  BAŞLANMADI.
- Tarif kütüphanesini büyütme (bölge bazlı yeni "parti"ler) — konuşuldu
  ama bu oturumda ikon işine odaklanıldığı için ertelendi.
