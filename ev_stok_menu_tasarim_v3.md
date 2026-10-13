# Evdekilerle Menü (EV Profili) — Tasarım Taslağı v3

13 Ekim 2026. Öneri: Efe Türkoğlu. Kararlar: Bahri.

v2 değişiklikleri (Bahri'nin 13 Ekim kararları): ayrı sayfa; öğünde 2 tarif seçeneği; gün sayısı
seçilebilir; hizmet aboneye sorulur, açıp kapatabilir; besin hedefi stoktan önce gelir;
alışveriş listesi ve stok raporu istenirse abonenin e-postasına gönderilir.

v3 değişiklikleri (13 Ekim): sayfa adı "Evdekilerle Menü"; e-posta gönderimi ertelendi (Faz 2).
Altyapı: sql/194_evdekilerle_menu_altyapi.sql (isletmeler.ev_menu_hizmeti, isletmeler.ev_menu_ayarlari, ev_stogu).

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
| Gün sayısı | 7 | 1–7 |
| Öğünde 2 tarif | işaretsiz (3 tarif: I + II + III grup) | İşaretlenirse 2 tarif: I. grup ana yemek + II. grup yan yemek |
| Besin hedefi | EV profilinin kayıtlı hedefleri | Mevcut "Öğün başına besin hedefi" alanlarıyla aynı |
| Stok listesi | boş | Katalogdan malzeme + miktar + birim |
| Temel malzemeler | aşağıdaki liste "evde var" kabul edilir | Kullanıcı listeden çıkarabilir |

Not: Motor şu an yalnızca Öğle ve Akşam öğünlerini tanıyor; kahvaltı kütüphanede yok.
"Öğün sayısı" bu yüzden 1 ya da 2 olabilir.

Not (2 tarif): EV profilinin besin hedefleri 3 tariflik öğüne göre girilmiş olabilir. 2 tarifte
kalori alt sınırı tutmayabilir; bu durumda mevcut "hedef tutturulamıyor" uyarısı gösterilir.
Hangi iki grubun seçileceği (I + II) öneridir; Emre/Gizem'e de sorulabilir.

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
   önüne geçmez; sadece eşit derecede uygun seçenekler arasında karar verir (Bahri onayladı).
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
4. **E-postama gönder (isteğe bağlı, ERTELENDİ — Faz 2):** sonuç ekranında bir düğme. Alman gerekenler listesi ve
   stok raporu, giriş yapılan hesabın e-posta adresine gönderilir (başka adres yazılamaz; kötüye
   kullanımı ve yanlış adrese veri gitmesini önler). İçerik e-postanın gövdesinde iki tablo olarak
   yer alır; PDF eki Faz 2'de (reportlab zaten kurulu).

## Hizmeti Açma / Kapatma

- Ayar işletme düzeyindedir (`isletmeler` tablosuna yeni sütun: `ev_menu_hizmeti`; boş = henüz
  sorulmadı, true = açık, false = kapalı). Kararı işletme sahibi verir.
- Abonelik aktif olan sahibe, Kontrol Paneli'nde bir kez sorulur: "Evdeki malzemelerle haftalık
  menü kuran hizmeti kullanmak ister misin?" Evet / Hayır. Cevap kaydedilir, bir daha sorulmaz.
- Abonelik sayfasında aç/kapat anahtarı bulunur; istediği zaman değiştirebilir.
- Kapalıysa sayfa navigasyonda görünmez. Personelin erişimi Faz 2'de yetki kataloğuna eklenir;
  ilk sürümde sayfayı yalnızca sahip görür.

## E-posta Gönderimi (ERTELENDİ — Bahri, 13 Ekim; altyapı seçimi o zaman yapılacak)

Uygulamada şu an e-posta gönderen bir altyapı yok (Supabase yalnızca kendi doğrulama ve şifre
sıfırlama e-postalarını gönderiyor). İki seçenek:

| | A) Gmail SMTP (uygulama şifresi) | B) E-posta servisi (ör. Resend, Brevo) + kendi alan adı |
|---|---|---|
| Kurulum | Kısa: Google hesabında 2 adımlı doğrulama + uygulama şifresi, Streamlit Secrets'a eklenir | Uzun: servis hesabı + alan adına DNS kayıtları (SPF/DKIM) |
| Gönderen | Bahri'nin Gmail adresi | ornek@menumuhendisi.com gibi kurumsal adres |
| Limit | Gmail günlük gönderim sınırı (küçük ölçek için yeterli) | Servisin planına göre |
| Spam riski | Orta | Düşük (alan adı doğrulanmış) |

Her iki durumda da şifre/anahtar yalnızca Streamlit Cloud Secrets'a girer, depoya ve sohbete gelmez.
Aynı SMTP bilgisi Supabase'in kendi doğrulama e-postaları için de tanımlanabilir (Supabase'in
yerleşik e-posta servisinin saatlik gönderim sınırı düşüktür; kayıt sorunlarında olası bir etken).

## Veri Kalitesi Bağımlılıkları (doğruluğu doğrudan etkiler)

- **Porsiyon gramajı kararı (Emre/Gizem):** 41 genel tarifin çiğ porsiyonu düşük
  (örnek: Kavurmalı Yumurta 74,6 g). Bu düzelmeden stok tüketimi olduğundan az hesaplanır.
- **Fire:** tarif gramları ile dükkândan alınan (kabuklu, kemikli) ağırlık arasındaki fark.
  `fire_orani` çoğu malzemede boş (185 teşhisi). Tarif gramlarının net mi brüt mü olduğu
  netleşmeden stok hesabı fire düşmeden yapılır; bu durum ekranda not olarak yazılır.
- **Adet ağırlıkları:** TAHMİN; kullanıcı düzeltebilir.

## Fazlar

- **Faz 1 (ilk sürüm):** hizmet aç/kapat sorusu ve anahtarı, stok girişi + kalıcılık, temel
  malzeme listesi, porsiyon/öğün/gün ve 2 tarif seçimi, stok tercihli menü, alışveriş listesi,
  stok raporu.
- **Faz 2:** bozulabilirlik — `malzemeler.bozulma_suresi` kısa olan kalemler haftanın
  başına çekilir (önce taze et/sebze, sonra kuru bakliyat).
- **Faz 2:** "Menüyü onayla → stoktan düş" (kalan stok kalıcı tabloya yazılır).
- **Faz 2:** "E-postama gönder" (altyapı seçimiyle birlikte) ve PDF eki; personel erişimi için yetki kataloğu kalemi.

## Kararlaştırılanlar (13 Ekim 2026)

- Esnek mod; varsayılan 3 porsiyon, 2 öğün; ikisi de seçilebilir.
- Ayrı sayfa.
- Öğünde 2 tarif seçeneği işaretlenebilir.
- Gün sayısı 1–7 seçilebilir.
- Hizmet aboneye sorulur; açık/kapalı abonenin elinde.
- Öncelik: besin hedefi > stok.
- Alman gerekenler listesi ve stok raporu, istenirse abonenin e-postasına gönderilir (ertelendi, Faz 2).
- Sayfa adı: "Evdekilerle Menü".
