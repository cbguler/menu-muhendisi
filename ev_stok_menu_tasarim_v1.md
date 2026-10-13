# Elimdekilerle Menü (EV Profili) — Tasarım Taslağı v1

13 Ekim 2026. Öneri: Efe Türkoğlu. Karar: Bahri (esnek mod; varsayılan 3 porsiyon, 2 öğün; ikisi de seçilebilir).

## Amaç

Ev kullanıcısı elindeki malzemeleri ve miktarlarını girer. Sistem bu malzemeleri
**önce kullanan** bir haftalık menü kurar, eksik kalanları kısa bir
"Alman gerekenler" listesi olarak verir. Stok bir zorunluluk değil, önceliktir
(esnek mod): menü her durumda tam çıkar, stok yetmediği yerde alışveriş listesi uzar.

## Kullanıcı Girdileri

| Girdi | Varsayılan | Seçenekler |
|---|---|---|
| Porsiyon (kişi sayısı) | 3 | 1–10 |
| Öğün | 2 (Öğle + Akşam) | 1 öğün (Öğle ya da Akşam) / 2 öğün |
| Gün sayısı | 7 | 1–7 (öneri, onay bekliyor) |
| Besin hedefi | EV profilinin kayıtlı hedefleri | Mevcut "Öğün başına besin hedefi" alanlarıyla aynı |
| Stok listesi | boş | Katalogdan malzeme + miktar + birim |
| Temel malzemeler | aşağıdaki liste "evde var" kabul edilir | Kullanıcı listeden çıkarabilir |

Not: Motor şu an yalnızca Öğle ve Akşam öğünlerini tanıyor; kahvaltı kütüphanede yok.
"Öğün sayısı" bu yüzden 1 ya da 2 olabilir.

## Stok Girişi

- **Serbest metin yok, katalogdan seçim.** Arama `malzemeler.ad` ve `malzemeler.diger_adlar`
  üzerinden yapılır ("kıyma" yazınca "DANA KIYMA" çıkar). Eşleşme ID ile yapılır, isimle değil
  (satınalma tasarımındaki gerekçeyle aynı: `_taban_kelime` tipi isim hataları baştan elenir).
- **Birim:** g, kg, adet; sıvılar için ml/l (`malzemeler.yogunluk` ile grama çevrilir).
- **Adet → gram:** yumurta, soğan, patates, domates gibi kalemler için tablo
  (mevcut adet ağırlıkları: yumurta 50 g, soğan 110 g, patates 213 g, domates 110 g — TAHMİN, USDA ortalaması).
  Kullanıcı ekranda gram karşılığını görür ve düzeltebilir.
- **Kalıcılık:** stok, işletmeye bağlı yeni bir tabloda tutulur (`ev_stogu`: isletme_id,
  malzeme_id, miktar_gram, guncelleme), RLS `auth_isletme_id()` ile. Kullanıcı her seferinde
  baştan girmez.

## Temel Malzemeler (evde var kabul edilir)

Su, tuz, karabiber, kırmızı toz/pul biber, kimyon, kuru nane, sıvı yağ, zeytinyağı, toz şeker.
Bunlar stok hesabına ve alışveriş listesine girmez. Katalogdaki tam adlar uygulama sırasında
eşlenecek. Kullanıcı istediğini listeden çıkarabilir (örneğin zeytinyağı yoksa).

## Menü Kurma Mantığı

Mevcut motor (`uretim_algoritmasi.hafta_olustur` / `ogun_olustur`) aynen kullanılır;
kurallar değişmez:

1. **Zorunlu:** Anayasa kuralları (madde 11 uyumsuzluklar, aynı gün aynı temel yemek türü yok).
2. **Mevcut sıra korunur:** mevsim, hafta içi tekrarsızlık, besin hedefi kademeleri.
3. **Yeni katman — stok tercihi:** bir öğün için kurallara ve hedefe uyan adaylar arasından
   **stoğu en çok kullanan, eksiği en az olan** birleşim seçilir. Stok, besin hedefinin
   önüne geçmez; sadece eşit derecede uygun seçenekler arasında karar verir (öneri, onay bekliyor).
4. **Stok gün gün düşer:** her öğün seçildikten sonra kullanılan miktar stoktan düşülür,
   sonraki öğün kalan stokla değerlendirilir. Pazartesi kullanılan kıyma salıya kalmaz.

Öğün skoru (her tarif için, porsiyon sayısıyla çarpılmış ihtiyaçla):

- `karsilanan_g` = Σ min(ihtiyaç, kalan stok) — temel malzemeler hariç
- `eksik_g` = Σ max(0, ihtiyaç − kalan stok) — temel malzemeler hariç
- Öncelik: önce `eksik_g` en az, eşitse `karsilanan_g` en çok.

Bu, gün gün ilerleyen açgözlü (greedy) bir yöntem; haftanın tamamında matematiksel olarak
en iyi çözümü garanti etmez, ama mevcut motora en az müdahaleyle oturur. İlk sürüm için yeterli.

## Çıktı

1. **Haftalık menü:** Yıllık Menü'deki hafta kartları yeniden kullanılır. Her öğünün altında
   "stoktan karşılanan: %X".
2. **Alman gerekenler:** eksikler malzeme ID'sine göre toplanır, satınalma tasarımındaki
   yuvarlama kuralıyla gösterilir (ham toplam + pratik miktar).
3. **Stok raporu:** her stok kalemi için kullanılan / kalan. Hiç kullanılamayan kalemler ayrıca
   listelenir ("bu hafta değerlendirilemedi").

## Veri Kalitesi Bağımlılıkları (doğruluğu doğrudan etkiler)

- **Porsiyon gramajı kararı (Emre/Gizem):** 41 genel tarifin çiğ porsiyonu düşük
  (örnek: Kavurmalı Yumurta 74,6 g). Bu düzelmeden stok tüketimi olduğundan az hesaplanır.
- **Fire:** tarif gramları ile dükkândan alınan (kabuklu, kemikli) ağırlık arasındaki fark.
  `fire_orani` çoğu malzemede boş (185 teşhisi). Tarif gramlarının net mi brüt mü olduğu
  netleşmeden stok hesabı fire düşmeden yapılır; bu durum ekranda not olarak yazılır.
- **Adet ağırlıkları:** TAHMİN; kullanıcı düzeltebilir.

## Fazlar

- **Faz 1 (ilk sürüm):** stok girişi + kalıcılık, temel malzeme listesi, porsiyon/öğün/gün
  seçimi, stok tercihli menü, alışveriş listesi, stok raporu.
- **Faz 2:** bozulabilirlik — `malzemeler.bozulma_suresi` kısa olan kalemler haftanın
  başına çekilir (önce taze et/sebze, sonra kuru bakliyat).
- **Faz 2:** "Menüyü onayla → stoktan düş" (kalan stok kalıcı tabloya yazılır).

## Bahri'nin Kararını Bekleyen Noktalar

1. **Yeri:** ayrı sayfa ("Elimdekilerle Menü") mı, Yıllık Menü içinde bir mod mu?
   Öneri: ayrı sayfa — Yıllık Menü zaten çok kalabalık ve ay/yıl takvimine bağlı.
2. **Öğün başına tarif sayısı:** anayasa madde 8 her öğüne I + II + III grup (3 tarif) koyuyor.
   Ev için 3 tarif kalsın mı, yoksa "2 tarif (ana yemek + yan)" seçeneği de olsun mu?
3. **Gün sayısı seçilebilsin mi** (1–7), yoksa sabit 7 mi?
4. **Erişim:** hangi planlar/profiller bu sayfayı görsün?
5. **Öncelik sırası:** besin hedefi > stok (öneri) mi, yoksa stok > besin hedefi mi?
