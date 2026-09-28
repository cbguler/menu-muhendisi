# MENU MUHENDISI -- DEVIR NOTU (Menu Muhendisi 8 -> 9)
Tarih: 28 Eylul 2026. Ayrintili gecmis: PROJE_NOTLARI.md (en sondaki "OTURUM 28 EYLUL 2026" bolumu) ve
transcript: /mnt/transcripts/2026-09-27-18-55-49-menu-muhendisi-kalite-iscilik-enerji-2026.txt (onceki
kismi), bu oturumun tamami icin journal.txt'e bakilabilir.

## 1. Guncel durum (kisa)
- Kutuphane: 1000 tarif (515 yeni + onceki), hepsinde hazirlik_talimati ve uretim asamalari var.
- Eksik malzeme fiyati: tarifte kullanilan hicbir malzemenin fiyati eksik degil (migration 167).
- Giresun/Rize mantik hatasi cozuldu (migration 170, 170a dogrulandi).
- Maliyet ayarlari (Abonelik sayfasi): elektrik 0,13 EUR/kWh, dogalgaz 0,08, personel 11,03 EUR/saat
  (Bahri girdi). Dogalgaz 0,08 zayif kaynakli: ticarethane rakami bulunamadi.
- Ana sayfa: dinamik tarif/malzeme sayisi, 32 besin ogesi (5 temel + 13 vitamin + 10 mineral + 4 diger makro).
- Aylik Menu sayfasi: Excel KALDIRILDI. "Aylik Menuyu PDF'e indir" (dialog: Sade/Detayli, A4/B3,
  Dikey/Yatay) + "Aylik Sarf Listesi" PDF (malzeme + haftalik enerji kWh + iscilik saat + gereken personel).
- Bahri son Sade/Detayli PDF ciktilarini onayladi ("Super oldu").

## 2. Bu oturumda dokunulan dosyalar (repoda oldugunu teyit et)
pages/0_Yillik_Menu.py, app.py, pages/5_Tarif_Kutuphanesi.py, pages/6_Abonelik.py, requirements.txt
(reportlab>=4.0), assets/fonts/DejaVuSans.ttf + DejaVuSans-Bold.ttf, assets/logo.png (mevcut),
sql/165-170a, PROJE_NOTLARI.md. Hangilerinin commit/push edildigi TEYIT EDILMEDI.

## 3. ACIK ISLER (oncelik sirasiyla)
1. "Beni hatirla" sorunu DEVAM EDIYOR. Belirti henuz alinmadi; once sor: giris ekrani mi geliyor, bir
   sure sonra mi atiyor, hangi cihaz/tarayici. Bilinen gecmis: extra-streamlit-components CookieManager
   asenkron; masaustunde "Yukleniyor..." + st.stop() + 8 dogal rerun + 4 sn son-care rerun ile calisti,
   MOBIL HIC TEYIT EDILMEDI. Supabase refresh token tek kullanimlik: her yenilemede cerez yeniden
   yazilmali (kodda var, dogrula). Kod: app.py (BENI_HATIRLA_GUN=30, Fernet, COOKIE_SIFRESI).
2. Aylik Sarf Listesi PDF: son duzeltme (ozet satirlari tabloya birlesik + NOSPLIT) gercek ay verisiyle
   HENUZ teyit edilmedi (Kasim Sarf Listesi'nde 6. hafta sorunu sonrasi yapildi).
3. Yatay PDF modu: gercek ay verisiyle teyit yok (dialog'da "Sayfa yonu (deneme)" secimi zaten var).
4. Dogalgaz ticarethane birim fiyati kesinlestirilmedi.
5. Sade dikey/yatay tek sayfa testleri sahte veriyle; gercek 6 haftalik ay (Kasim) ile bir kez daha bak.
6. "Isil islem yok" taramasi sadece bir kalibi yakaladi; baska malzeme/talimat tutarsizliklari icin
   ayri tarama yapilmadi.
7. kaynak_duzeltilmis_v37.xlsx guncelleme kurali belirsiz; 10-15 tarifin bir asciya gozden gecirtilmesi.
8. Hafta sonu vurgusu istegi "daha once istenmisti" dendi; eski notlarda kaynagi bulunamadi.
9. Projects'e gecis (Operation & Maintenance asamasinda); PROJE_NOTLARI.md 12.000 satiri asti, Projects'e
   yuklemeden once kisa bir "guncel durum" ozeti cikarilmali (bu dosya onun taslagi).

## 4. Kalici kurallar (Bahri'nin acik talepleri)
- HER dosya teslimiyle git add/commit/push komutlari verilir (istenmeden). Windows cmd.exe: satir devami
  (\) CALISMAZ; tek satirda "git add ." veya dosya adlarini tek satirda yaz.
- Her degisiklik PROJE_NOTLARI.md'ye islenir.
- Emoji yok (sohbet ve UI). Uydurma/tahmin yok; belirsizlikte "TAHMIN" diye isaretle, Bahri'nin kararini bekle.
- "Kaldigin yerden devam et" denince aciklama yapmadan devam.
- Bir seyin eksik/yok oldugunu soylemeden once PROJE_NOTLARI.md veya gercek dosyayi kontrol et.
- Hesaplarda birden fazla gecerli referans varsa EN YUKSEK/muhafazakar olani kullan.
- Malzeme fiyati kaynagi: market zinciri (Migros/CarrefourSA) + Metro toptan esas; borsa/hal sadece emtia.
- Uretim asamasi: hazir/onceden pisirilmis malzeme varsayma; su kullanan her tarifte SU satiri + isil asamaya bagla.
- Supabase SERVICE_ROLE_KEY veya baska kimlik bilgisi ASLA Claude ortamina girilmez.
- Indirmeler: dosyalar dogrudan C:\Users\bahri\Desktop\menu-muhendisi, .sql dosyalari sql alt klasorune iner.
- Sablon: her duzeltme "YUZ ... DUZELTME" adlandirmasi ve kod icinde aciklayici yorumla belgelenir.

## 5. Teknik tuzaklar (bu oturumdan)
- Supabase SQL editoru coklu sorguda SADECE SON sorgunun sonucunu gosterir: teshis sorgularini ayri ayri calistir.
- Postgres ILIKE, DB collation'ina bagli olarak Turkce I/i katlamasi yapmayabilir; 'slem' gibi I/i icermeyen govde ara.
- reportlab: registerFontFamily olmadan Latin-1 disi Turkce harfler tablo hucrelerinde bozulur; Table satiri
  bolunmesini KeepTogether/NOSPLIT ile engelle; Sade PDF tek sayfa icin olcek dongusu kullanir.
- dict.get(key, "") NULL degeri None dondurur -> .get(key) or "" kullan.
- PostgREST sorgu basina 1000 satir keser: sayim/liste icin .range() ile sayfala.
- Streamlit Cloud: yeni bagimlilik (reportlab) ilk deploy'da yavas olabilir.

## 6. Yeni sohbet icin onerilen acilis
"Menu Muhendisi 9: DEVIR_NOTU_MM9.md ve PROJE_NOTLARI.md yuklendi. Once 'Beni hatirla' sorununu ele alalim;
belirti: [buraya yaz]."
