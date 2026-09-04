# Malzeme Satınalma Listesi — Tasarım Taslağı

## Genel Akış

1. Kullanıcı bir tarih aralığı seçer (Yıllık Menü'nün mevcut ISO takvim
   entegrasyonu üzerinden — belirli bir gün ya da hafta).
2. Sistem o aralıktaki tüm menü satırlarını (hangi tarif, hangi öğün,
   kaç porsiyon) çeker.
3. Her tarifin malzeme listesi, o günkü porsiyon sayısına göre ölçeklenir
   (Tarif Kütüphanesi'ndeki mevcut porsiyon-ölçekleme mantığı aynen
   kullanılır — yeniden icat etmeye gerek yok).
4. Aynı malzeme (ör. "soğan") birden fazla tarifte geçiyorsa, **malzeme
   ID'sine göre** toplanır — isme göre DEĞİL. (Not: isim bazlı eşleştirme
   geçmişte `_taban_kelime()` sürecinde defalarca hataya yol açmıştı —
   "salatalık/salatalığı" gibi ünsüz yumuşaması sorunları. ID bazlı
   toplama bu riski baştan eler.)
5. Her malzeme için üç değer gösterilir:
   - **Ham toplam** (ör. 847 g)
   - **Yuvarlanmış pratik miktar** (ör. 1 kg)
   - **Önerilen alım sıklığı** (Günlük / Haftalık)
6. Streamlit tablo olarak sunulur; üstte filtre: "Sadece Günlük" /
   "Sadece Haftalık" / "Hepsi".

## Karara Bağlanan Noktalar

- Günlük/haftalık ayrımı: **otomatik**, mevcut malzeme kategori alanına
  göre (564 malzeme için zaten dolu).
- Miktar gösterimi: **hem ham hem yuvarlanmış** birlikte gösterilecek.
- Çıktı: **sadece uygulama içi** Streamlit sayfası (PDF/yazdırma yok).
- İsraf azaltma: **üç yöntem birden, baştan** —
  1. Bozulabilirliğe göre farklı yuvarlama inceliği
  2. Devreden stok defteri (SADECE dayanıklı malzemelerde)
  3. Yüksek-israf-oranlı kalemleri işaretleme

## İsraf Azaltma — Detaylı Mantık

### 1. Yuvarlama İnceliği (bozulabilirliğe göre)

| Birim tipi | Bozulabilir (Günlük) | Dayanıklı (Haftalık) |
|---|---|---|
| kg | 100 g'a yukarı yuvarla | 500 g'a yukarı yuvarla |
| lt | 100 ml'ye yukarı yuvarla | 500 ml'ye yukarı yuvarla |
| adet | 1 adete yuvarla (zaten tam sayı) | 1 adete yuvarla |
| g (baharat, küçük miktar) | 10 g'a yukarı yuvarla | 50 g'a yukarı yuvarla |

Mantık: bozulabilir malzemenin fazlası bir sonraki alıma taşınamaz
(çürür/bayatlar), o yüzden ince adımlarla yuvarlanıp israf en aza
indirilir. Dayanıklı malzemede fazlalık zaten devreden stok defteriyle
telafi edildiği için daha kaba yuvarlama kabul edilebilir.

### 2. Devreden Stok Defteri (SADECE dayanıklı/haftalık malzemeler)

**ÖNEMLİ GÜVENLİK KARARI:** Bu mekanizma bozulabilir malzemelere
UYGULANMAZ. Kurumsal müşteriler arasında hastane ve huzurevi de
olduğu için "geçen haftaki taze sebze fazlasını bu haftaya say"
mantığı gıda güvenliği riski taşır. Bozulabilir malzemede her dönem
ihtiyaç sıfırdan hesaplanır, sadece ince yuvarlama uygulanır.

Dayanıklı malzemeler için akış:
1. Yeni tablo: `satinalma_devreden_stok` (malzeme_id, miktar, birim,
   son_guncelleme)
2. Her hesaplamada: `net_ihtiyac = max(0, ham_ihtiyac - mevcut_fazla)`
3. `net_ihtiyac` pratik birime yukarı yuvarlanır → `satin_alinacak`
4. Yeni fazla hesaplanır: `(mevcut_fazla + satin_alinacak) - ham_ihtiyac`
5. `satinalma_devreden_stok` bu yeni değerle güncellenir

Bu sayede tekrarlayan yuvarlama fazlalıkları birikip zamanla
"harcanır", uzun vadede toplam israf ciddi ölçüde azalır.

### 3. Yüksek-İsraf-Oranlı Kalem İşaretleme

Kural: `(yuvarlanmış_miktar - net_ihtiyaç) / yuvarlanmış_miktar > %30`
ise kalem listede "⚠ Yüksek fazlalık — stoğunu kontrol et" etiketiyle
işaretlenir. Bu, sistemin körü körüne yuvarlamak yerine, oran çok
yüksek olduğunda kararı insana bırakmasını sağlar (ör. ihtiyaç 80g ama
en küçük pratik birim 500g ise, %84 fazlalık — muhtemelen zaten evde/
depoda vardır, tekrar almaya gerek olmayabilir).

## Açık Kalan Tek Nokta (uygulama aşamasında netleşecek)

Malzeme tablosundaki mevcut kategori alanının gerçek değerlerini
(hangi kategori adları var, kaç tanesi bozulabilir/dayanıklı sayılmalı)
göremediğim için, günlük/haftalık eşlemesini uygulamaya geçerken
senden gerçek kategori listesini isteyeceğim ve eşlemeyi birlikte
teyit edeceğiz. Bu, tahmine dayalı yanlış sınıflandırma riskini
ortadan kaldırır.

## Sıradaki Adım

1. Malzeme tablosundaki kategori alanının adını ve gerçek değerlerini
   paylaşman (ör. bir SQL sorgusu çıktısı veya Excel'deki sütun).
2. Kategori → Günlük/Haftalık eşlemesini birlikte teyit etmek.
3. `satinalma_devreden_stok` tablosu için migration yazılması.
4. Yıllık Menü sayfasına "Satınalma Listesi" sekmesi eklenmesi.
5. Toplama + yuvarlama + devreden stok mantığının yazılıp, birkaç
   gerçek hafta üzerinde test edilmesi (özellikle çok tarifte geçen
   malzemelerin -- soğan, domates -- doğru toplandığından emin olmak).
