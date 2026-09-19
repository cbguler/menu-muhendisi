# Menü Mühendisliği — Devam Özeti (Oturum 10 sonrası)

## Proje
Streamlit + Supabase restoran menü mühendisliği SaaS'ı. Repo: github.com/cbguler/menu-muhendisi (artık PUBLIC), deploy: menu-muhendisi.streamlit.app. Kalıcı kurallar: emoji yasak, PROJE_NOTLARI.md'ye her değişiklik işlenir, git komutları her dosya değişikliğinde verilir, asla uydurma/tahmin — kaynak belirsizse sor.

## Bu oturumda tamamlananlar

### 1) "Beni hatırla" çerez sorunu (masaüstü ÇÖZÜLDÜ, mobil KISMEN)
- Kök neden: extra_streamlit_components.CookieManager'ın tarayıcı↔Python round-trip'i asenkron, script ilk çalıştığında çoğu zaman boş dönüyor.
- Çözüm: kendi st.rerun() ZORLAMAK yerine Streamlit'in doğal component-rerun döngüsüne bırakmak — "Yükleniyor..." gösterip st.stop(). 5→8 doğal tur + son çare 4sn bekleme+tek rerun.
- Masaüstünde (Edge/Chrome) çalışıyor, doğrulandı. Mobilde HALA güvenilir değil ("her seferinde login soruyor") — bekleme süresi arttırıldı ama sonuç doğrulanmadı, TEST EDİLMESİ GEREKİYOR.

### 2) Streamlit Cloud erişim ayarları (ÇÖZÜLDÜ)
- GitHub deposu private'tı → Public yapıldı (secrets.toml.example'da gerçek anahtar olmadığı doğrulandı, güvenli).
- Streamlit Cloud'un AYRI "Who can view this app" ayarı ("Only specific people") da "Anyone" yapıldı — Manage app → ⋮ → Settings → Sharing.

### 3) Navigasyon: sidebar → üst menü → özel menü (ÇÖZÜLDÜ, karmaşık yolculuk)
- Sidebar tamamen kaldırıldı, `st.logo()` ile sol üstte logo (CSS ile `[data-testid='stHeaderLogo']` 100px'e büyütüldü, SADECE masaüstünde media query ile — mobilde native boyut).
- `st.navigation(position="top")` denendi → Streamlit'in kendi GitHub deposunda onaylanmış hatalar var (çift görünme, mobilde açılmama) → TERK EDİLDİ.
- Final çözüm: `position="hidden"` + kendi özel navigasyon — masaüstünde yatay `st.page_link` satırı, mobilde `st.popover("Menü")` açılır liste, ikisi de aynı sayfa listesinden besleniyor, CSS media query ile hangisi görünür seçiliyor. **Bu son hali TEST EDİLMEDİ.**
- "Page not found" kısa flaşı (reboot sonrası) — kendiliğinden düzeliyor, sorun değil.

### 4) Üç kademeli abonelik + admin onay sistemi (KOD TAMAM, UÇTAN UCA TEST EDİLMEDİ)
- "Deneme" planı kavramı TAMAMEN kaldırıldı (SQL: 41, 42, 43, 44 numaralı migration'lar — hepsi Supabase'de ÇALIŞTIRILDI ve doğrulandı).
- Yeni model: **Ücretsiz** (sadece Kontrol Paneli+Abonelik görünür) → **Ödedi, onay bekliyor** (`odeme_alindi_onay_bekliyor` — 4 sayfa GÖRÜNÜR ama tüm yazma-butonları `disabled=True`) → **Aktif** (`aktif` — tam erişim).
- Admin SADECE `bahriguler@gmail.com`'a hardcode edilmiş (kullanicilar.rol='sahip' genel bir alan, platform admin'i için KULLANILMADI, kasıtlı ayrım).
- Yeni "Admin" sayfası (pages/7_Admin.py) — bekleyen abonelikleri listeler, "Onayla" butonu var, navigasyonda SADECE admin'e görünür.
- Kayıt tetikleyicisi (05_kullanici_kayit_tetikleyicisi.sql) güncellendi — yeni kayıtlar artık `odeme_bekleniyor` durumuyla başlıyor, plan_id NULL (nullable yapıldı).
- **KRİTİK RİSK BULUNDU VE DÜZELTİLDİ:** `isletme_aktif_abonelik` view'i INNER JOIN kullanıyordu → plan_id=NULL olan yeni kullanıcılar view'den kayboluyordu → LEFT JOIN'e çevrildi (43 no'lu migration).
- **UÇTAN UCA TEST EDİLMEDİ:** yeni kayıt → ödeme bekliyor durumu → admin onayı akışının tamamı gerçek bir hesapla hiç denenmedi.

### 5) Boston Matrisi TAMAMEN KALDIRILDI
Kullanıcının amacına uygun değildi (satış takibi istemiyor). Sayfa, navigasyon, tüm referanslar silindi.

### 6) Abonelik sayfasına işletme bilgisi düzenleme eklendi
- İşletme adı düzenlenebiliyor (Yıllık Menü'deki "kendi menüm" butonunun etiketini besliyor).
- **RLS hatası bulundu ve düzeltildi:** `isletmeler` tablosunda UPDATE politikası hiç yoktu (sadece SELECT vardı) → eklendi (44 no'lu migration). Şu an ÇALIŞIYOR, doğrulandı.
- Başka işletme bilgisi alanı (adres/telefon vb.) eklenmedi — şema bilinmiyor, istenirse eklenir.

### 7) Video native st.video()'ya geçirildi (mobil uyumluluk için)
Eski base64 data-URI hilesi mobilde hiç görünmüyordu. `st.video(bytes, autoplay=True, loop=True, muted=True)` kullanılıyor — kontrol çubuğu görünebilir (kabul edildi).

### 8) BÜYÜK İŞ: 27 yeni besin değeri sütunu (kod + Excel, KISMEN TAMAMLANDI)
Kullanıcı talebi: kalori/protein/yağ/karbonhidrat/GI dışında sağlık açısından önemli değerler (sodyum, lif, şeker, doymuş yağ + TÜM vitamin/mineraller — 27 sütun).
- **Veritabanı şeması kuruldu** (SQL: 45_genisletilmis_besin_degerleri.sql, malzemeler tablosuna 27 nullable sütun eklendi, Supabase'de ÇALIŞTIRILDI).
- **Excel dosyasına (kaynak_duzeltilmis_v2.xlsx) 27 sütun eklendi** (Glisemik İndeks'ten sonra, Mevsimi'nden önce, mevcut başlık biçimiyle birebir).
- **358 malzemenin 349'u USDA FoodData Central'dan (Foundation+SR Legacy veri setleri, ikisi birleştirilerek) dolduruldu** — %90 doluluk, mavi yazıyla işaretli. Bulk JSON indirilip yerel eşleştirme yapıldı (DEMO_KEY rate limit'e çok hızlı takıldığı için API değil, toplu indirilen dosyalar kullanıldı).
- **Kullanıcının haklı uyarısı üzerine:** Türk mutfağına özgü ürünler için TürKomp (turkomp.gov.tr — TÜBİTAK/Tarım Bakanlığı/Sağlık Bakanlığı'nın resmi, laboratuvar analizli ulusal veri tabanı) da tarandı. 18 üründe (KAVURMA, PASTIRMA, SUCUK, TARHANA, YUFKA, KAYMAK, NAR EKŞİSİ, JAMBON, SALAM, BAZLAMA, EZİNE/KAŞAR/TULUM/OTLU PEYNİR, ÇÖREKOTU, KESTANE ŞEKERİ, TÜRK KAHVESİ, İRMİK) gerçek TürKomp verisi bulunup YEŞİL yazıyla USDA'nın üzerine yazıldı (daha güvenilir).
- **9 malzeme hâlâ boş:** SUMAK, MAHLEP, DAMLA SAKIZI (TürKomp'ta da yok, niş baharatlar), GUACAMOLE, VANİLİN (hazır ürün/bileşik, hiçbir kaynakta net karşılığı yok).
- **YARIM KALAN İŞ:** TürKomp'ta muhtemelen DAHA FAZLA malzeme için iyi eşleşme bulunabilir (644 ürünlük TürKomp indeksi zaten `turkomp_index.json` olarak elimde, sadece öncelikli ~40 kalemi test ettim — geri kalan ~300+ malzeme için de TürKomp'ta arama yapılıp USDA'nın üzerine yazılabilir, henüz yapılmadı). Ayrıca "yaklaşık eşleşme" olarak işaretlediğim ama TürKomp'ta aranmamış diğer kalemler (HELLİM, MASCARPONE, PİDE, KADAYIF, ÜzÜM PEKMEZİ, KONSERVE BİBER SALÇASI, ŞEHRİYE, İTALYAN SUCUĞU vb.) da tekrar TürKomp'ta aranabilir.
- **Veritabanına henüz YÜKLENMEDİ** — sadece Excel dosyasında. Excel'den Supabase'e (malzemeler tablosuna) aktaracak bir yükleme script'i henüz yazılmadı.

## Bekleyen / Açık İşler (öncelik sırasıyla)

1. **Mobil "beni hatırla" testi** — yeni bekleme süresiyle gerçekten çalışıyor mu, hâlâ belirsiz.
2. **Yeni özel navigasyon (masaüstü satır + mobil popover) testi** — hiç test edilmedi.
3. **Üç kademeli abonelik/admin sisteminin uçtan uca testi** — yeni kayıt, ödeme bekleme, admin onayı akışı hiç denenmedi.
4. **TürKomp taramasının geri kalan ~300+ malzemeye genişletilmesi** — mevcut altyapı (turkomp_index.json, eşleştirme scripti) hazır, sadece çalıştırılıp Excel güncellenmesi gerekiyor.
5. **Excel'deki 27 yeni sütunun Supabase'e (malzemeler tablosu) yüklenmesi** — henüz script yazılmadı.
6. **Kayıt tetikleyicisinin (05 no'lu SQL) test edilmesi** — yeni bir kullanıcı gerçekten kayıt olup `odeme_bekleniyor` durumuyla başlıyor mu doğrulanmadı.
7. Abonelik sayfasına ek işletme bilgisi alanları (adres/telefon vb.) — şema bilinmiyor, istenirse eklenir.
8. `use_container_width` parametresinin deprecated olması (Streamlit uyarısı) — tüm kodda `width=` ile değiştirilmesi gerekiyor, acil değil.

## Önemli teknik notlar / öğrenilen dersler

- **st.button()'da `key=` parametresi CSS class ÜRETMİYOR** (ama `st.container(key=...)` üretiyor — `.st-key-{key}` deseni SADECE container'lar için güvenilir, DevTools ile doğrulanmadan CSS seçicisi tahmin edilmemeli).
- **`st.logo()` gerçek testid'i `stHeaderLogo`**, `stLogo` değil; `src` alanı Streamlit'in kendi hash'lediği medya adresi, dosya adını içermiyor.
- **`isletme_aktif_abonelik` view'i gibi INNER JOIN kullanan view'lar, plan_id=NULL gibi yeni durumlarla sessizce satır kaybedebilir** — her yeni durum eklendiğinde ilgili view'ların JOIN tipi kontrol edilmeli.
- **RLS politikaları sessizce (hatasız) UPDATE'i engelleyebilir** — "Kaydedildi" mesajı göstermeden önce `.data` dolu mu diye kontrol etmek gerekiyor.
- **USDA FoodData Central DEMO_KEY çok düşük rate limit'e sahip** — büyük ölçekli iş için bulk JSON indirmeleri (fdc.nal.usda.gov/fdc-datasets/*.zip) API'den çok daha pratik.
- **TürKomp (turkomp.gov.tr) Türk mutfağına özgü ürünler için USDA'dan kıyaslanamayacak kadar daha doğru** — arama kutusu yok ama harf bazlı gezinme (`database?type=foods&harf=X`) ile tüm 644 ürün indekslenebiliyor, detay sayfaları (`food-{slug}-{id}`) düzenli HTML tablo formatında.

## Dosya durumu (bu oturumda değişen/oluşturulan)
app.py, sidebar_logo.py, db.py, pages/6_Abonelik.py (yeni), pages/7_Admin.py (yeni), pages/0_Yillik_Menu.py, pages/1_Recete_Uretimi.py, pages/2_Menu.py, pages/5_Tarif_Kutuphanesi.py, pages/3_Boston_Matrisi.py (SİLİNDİ), sql/41-45 (yeni migration'lar, hepsi Supabase'de çalıştırıldı), kaynak_duzeltilmis_v2.xlsx (27 yeni sütun + kısmen dolu veri).
