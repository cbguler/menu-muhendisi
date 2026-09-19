import sys

DOSYA = "pages/0_Yillik_Menu.py"

ESKI = '''def _hedefte_mi(ogun_adi, t, hedefler, hafta=None, detay=None):
    """TEMEL_5 (kalori/protein/yag/karbonhidrat/gi) HALA TEK OGUN (gun)
    bazinda sikica kontrol ediliyor -- bunlar ana/hemen-belirgin
    degerler, gun gun sapma onemli. TEMEL_5 DISINDAKI ogeler ise (hafta
    ve detay parametreleri verilmisse) HAFTALIK ORTALAMA uzerinden
    kontrol ediliyor (bkz. _haftalik_ortalama). hafta/detay verilmezse
    (ör. eski cagri yerleri, ya da haftalik baglam mevcut degilse) TUM
    anahtarlar eskisi gibi TEK OGUN bazinda kontrol edilir -- geriye
    donuk uyumluluk.

    SEKSEN DOKUZUNCU DUZELTME (4 Eylul 2026): donus degeri artik
    (True/False/None, basarisiz_olan_anahtar_listesi) ikilisi --
    Bahri'nin talebi: "Hedef dışı" yazisinin yaninda HANGI besin
    ogesinin hedef disi oldugu da gosterilsin."""
    if not hedefler or ogun_adi not in hedefler:
        return None, []
    basarisiz = []
    for anahtar, (alt, ust) in hedefler[ogun_adi].items():
        if anahtar in TEMEL_5 or hafta is None or detay is None:
            deger = t.get(anahtar)
        else:
            deger = _haftalik_ortalama(ogun_adi, anahtar, hafta, detay)
        if deger is None:
            continue
        if not (alt <= deger <= ust):
            basarisiz.append(anahtar)
    if basarisiz:
        return False, basarisiz
    return True, []'''

YENI = '''def _hedefte_mi(ogun_adi, t, hedefler, hafta=None, detay=None):
    """TUM besin ogeleri (TEMEL_5 + genisletilmis 22 oge) GUNLUK --
    yani o TEK OGUNUN kendi degeri -- bazinda kontrol edilir.

    SEKSEN DOKUZUNCU DUZELTME (4 Eylul 2026): donus degeri
    (True/False/None, basarisiz_olan_anahtar_listesi) ikilisi --
    Bahri'nin talebi: "Hedef dışı" yazisinin yaninda HANGI besin
    ogesinin hedef disi oldugu da gosterilsin.

    YUZ YIRMI BESINCI DUZELTME (6 Eylul 2026): SEKSEN DOKUZUNCU
    DUZELTME'de TEMEL_5 disindaki ogeler icin eklenen HAFTALIK
    ORTALAMA kontrolu GERI ALINDI -- Bahri, ekranda araligin ICINDE
    gorunen bir degerin (haftalik ortalama araligin disinda kaldigi
    icin) "Hedef dışı" cikmasinin kafa karistirici oldugunu bildirdi,
    ve GUNLUK kontrole donup sonucu gormeyi tercih etti. hafta/detay
    parametreleri GERIYE DONUK UYUMLULUK icin hala kabul ediliyor
    (cagiran kod degismedi) ama artik KULLANILMIYOR."""
    if not hedefler or ogun_adi not in hedefler:
        return None, []
    basarisiz = []
    for anahtar, (alt, ust) in hedefler[ogun_adi].items():
        deger = t.get(anahtar)
        if deger is None:
            continue
        if not (alt <= deger <= ust):
            basarisiz.append(anahtar)
    if basarisiz:
        return False, basarisiz
    return True, []'''

with open(DOSYA, encoding="utf-8") as f:
    icerik = f.read()

sayisi = icerik.count(ESKI)
if sayisi == 0:
    print("HATA: Eski metin dosyada BULUNAMADI -- dosya beklenenden farkli olabilir.")
    print("Hicbir degisiklik yapilmadi. Bana haber ver.")
    sys.exit(1)
elif sayisi > 1:
    print(f"HATA: Eski metin dosyada {sayisi} KEZ bulundu (1 bekleniyordu) -- guvenlik icin durduruldu.")
    print("Hicbir degisiklik yapilmadi. Bana haber ver.")
    sys.exit(1)

yeni_icerik = icerik.replace(ESKI, YENI)
with open(DOSYA, "w", encoding="utf-8") as f:
    f.write(yeni_icerik)

print("BASARILI: _hedefte_mi fonksiyonu guncellendi (gunluk kontrole donuldu).")
