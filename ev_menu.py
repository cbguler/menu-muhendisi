# ev_menu.py
#
# "Evdekilerle Menu" (13 Ekim 2026; oneri: Efe Turkoglu, tasarim:
# ev_stok_menu_tasarim_v3.md). Streamlit'ten BAGIMSIZ hesap modulu: stok,
# ceza, haftalik menu kurma, alisveris listesi ve stok raporu. Sayfa:
# pages/2_Evdekilerle_Menu.py.
#
# Kurallar (Bahri'nin kararlari):
#   - Esnek mod: menu her durumda tam cikar; stok bir TERCIH, zorunluluk degil.
#   - Oncelik: anayasa kurallari > besin hedefi > stok. Stok, motorun
#     (uretim_algoritmasi.ogun_olustur) hedefi TAM saglayan secenekleri
#     arasinda karar verir (ceza parametresi). Hicbir secenek hedefi tam
#     saglamiyorsa motor hedefe en yakin olani secer; stok o ogunde etkisizdir.
#   - Stok gun gun duser: her ogun secildikten sonra kullanilan miktar
#     stoktan dusulur, sonraki ogun kalan stokla degerlendirilir.
#   - Temel malzemeler (su, tuz, baharat, yag, seker) "evde var" kabul edilir;
#     stok hesabina ve alisveris listesine girmez.
#
# Ceza (bir tarif icin, o anki kalan stoga gore, porsiyon sayisiyla carpilmis):
#   ceza = eksik_g - karsilanan_g     (temel malzemeler haric)
#   eksik_g     = toplam max(0, ihtiyac - stok)
#   karsilanan_g = toplam min(ihtiyac, stok)
# Kucuk ceza iyi: stogu cok kullanan ve az eksik birakan tarif one cikar;
# stokla hic ilgisi olmayan kucuk bir tarif (ör. salata) stok kullanan bir ana
# yemegin onune gecmez.
# BILINEN SINIR: ayni ogundeki iki tarif ayni stok kalemini isterse ceza her
# tarif icin ayri hesaplandigindan o kalem iki kez "karsilanmis" sayilabilir.
# Gercek dusum (stoktan_dus) sirayla ve dogru yapilir; sadece secim sirasindaki
# tahmin yaklasiktir.

import math

from uretim_algoritmasi import ogun_olustur, _taban_kelime

# Varsayilan "evde var" kabul edilen malzemeler (katalogdaki tam adlar).
# Katalogda olmayan ad sessizce atlanir; kullanici listeden cikarabilir.
TEMEL_MALZEMELER = [
    "SU", "TUZ", "KARABİBER", "PUL BİBER", "TATLIKA KIRMIZI BİBER", "KİMYON",
    "KURU NANE", "AYÇİÇEK YAĞI", "ZEYTİNYAĞI", "TOZ ŞEKER", "ŞEKER",
]

# Adet -> gram (TAHMIN: USDA ortalamalari, kopya donusumlerinde de kullanilan
# degerler). Kullanici ekranda gram karsiligini gorur ve isterse gram girer.
ADET_GRAM = {
    "TAVUK YUMURTASI": 50.0,
    "KURU SOĞAN": 110.0,
    "PATATES": 213.0,
    "DOMATES": 110.0,
}

# 2 tarifli ogun (I. grup ana yemek + II. grup yan yemek): motor uclu bekledigi
# icin III. grup yerine bu bos "tarif" verilir. Besin degeri 0, etiketi yok,
# hicbir kurala takilmaz ve kullanilan tarif listelerine eklenmez.
BOS_TARIF_ADI = "__bos_ucuncu_tarif__"
BOS_TARIF = {
    "ad": BOS_TARIF_ADI, "grup": 3, "mevsim_etiketi": "yil_boyunca", "etiketler": [],
    "kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0, "gi": None,
}

OGUN_SECENEKLERI = {
    "iki": ("Öğle", "Akşam"),
    "ogle": ("Öğle",),
    "aksam": ("Akşam",),
}

AYLAR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
         "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]

_MEVSIM_BY_AY = {12: "kis", 1: "kis", 2: "kis", 3: "ilkbahar", 4: "ilkbahar", 5: "ilkbahar",
                 6: "yaz", 7: "yaz", 8: "yaz", 9: "sonbahar", 10: "sonbahar", 11: "sonbahar"}


_MEVSIM_SIRASI = ["ilkbahar", "yaz", "sonbahar", "kis"]


def _sade(metin):
    """Turkce harfleri sadelestirip kucuk harfe cevirir ('Kış' -> 'kis')."""
    m = metin.strip().replace("İ", "i").replace("I", "ı").lower()
    return m.replace("ı", "i").replace("ş", "s").replace("ç", "c").replace("ğ", "g").replace("ö", "o").replace("ü", "u")


def malzeme_mevsimleri(metin):
    """malzemeler.mevsim metnini mevsim kumesine cevirir. Katalogdaki bicimler:
    'Yıl boyunca', 'Yaz', 'Yaz-Sonbahar', 'İlkbahar-Sonbahar', 'Kış-İlkbahar',
    'Sonbahar - Kış'. Iki mevsimli yazim bir ARALIKTIR (ilkbahar -> yaz ->
    sonbahar -> kis dongusunde baslangictan bitise, ikisi dahil): 'İlkbahar-Sonbahar'
    = ilkbahar + yaz + sonbahar. Bos/taninmayan -> None (bilinmiyor: kisitlama yok)."""
    if not metin or not metin.strip():
        return None
    m = _sade(metin)
    if "yil boyunca" in m:
        return set(_MEVSIM_SIRASI)
    parcalar = [p.strip() for p in m.split("-")]
    if not parcalar or any(p not in _MEVSIM_SIRASI for p in parcalar):
        return None
    if len(parcalar) == 1:
        return {parcalar[0]}
    bas, son = _MEVSIM_SIRASI.index(parcalar[0]), _MEVSIM_SIRASI.index(parcalar[-1])
    kume = set()
    i = bas
    while True:
        kume.add(_MEVSIM_SIRASI[i])
        if i == son:
            break
        i = (i + 1) % 4
    return kume


# Katalogdaki "mevsim" alani HASAT mevsimidir; nohut, pirinc, bulgur, ceviz, sarimsak,
# tarcin gibi dayanikli urunler de mevsimli isaretli ama yil boyu bulunur. Bu yuzden
# mevsim kontrolu sadece TAZE urunlere uygulanir: bozulma_suresi bu esigin altinda
# olanlar (katalogda mevsimli 167 malzemenin 97'si 1-30 gun, kalanlari 90 gun ve uzeri).
TAZE_URUN_BOZULMA_GUN = 30


def malzeme_mevsim_haritasi(katalog):
    """katalog: [{"id", "mevsim", "bozulma_suresi"}, ...] -> {id: mevsim kumesi ya da None}.
    Dayanikli (bozulma_suresi > esik ya da bilinmiyor) malzemeler None: kisitlanmaz."""
    harita = {}
    for m in katalog:
        b = m.get("bozulma_suresi")
        taze = b is not None and b <= TAZE_URUN_BOZULMA_GUN
        harita[m["id"]] = malzeme_mevsimleri(m.get("mevsim")) if taze else None
    return harita


def mevsimde_mi(kalemler, mevsim, malzeme_mevsim, muaf_idler):
    """Tarifin temel olmayan ve evde olmayan butun malzemeleri bu mevsimde mi?
    Mevsimi bilinmeyen malzeme engel sayilmaz."""
    for mid, _g in kalemler:
        if mid in muaf_idler:
            continue
        kume = malzeme_mevsim.get(mid)
        if kume is not None and mevsim not in kume:
            return False
    return True


def tarih_mevsimi(tarih):
    """0_Yillik_Menu.py'deki MEVSIM_AYLARI ile ayni esleme."""
    return _MEVSIM_BY_AY[tarih.month]


def miktari_grama_cevir(miktar, birim, malzeme):
    """birim: 'g' | 'kg' | 'adet' | 'ml' | 'l'. malzeme: {'ad', 'yogunluk'}.
    Cevrilemiyorsa ValueError."""
    if miktar is None or miktar <= 0:
        raise ValueError("Miktar sıfırdan büyük olmalı.")
    if birim == "g":
        return float(miktar)
    if birim == "kg":
        return float(miktar) * 1000.0
    if birim == "adet":
        g = ADET_GRAM.get(malzeme.get("ad"))
        if g is None:
            raise ValueError("Bu malzeme için adet karşılığı tanımlı değil; gram ya da kg gir.")
        return float(miktar) * g
    if birim in ("ml", "l"):
        yogunluk = malzeme.get("yogunluk")
        if not yogunluk:
            raise ValueError("Bu malzemenin yoğunluk bilgisi yok; gram ya da kg gir.")
        ml = float(miktar) * (1000.0 if birim == "l" else 1.0)
        return ml * float(yogunluk)
    raise ValueError(f"Bilinmeyen birim: {birim}")


def tarif_ihtiyaci(tarif_malzemeleri, porsiyon, temel_idler):
    """tarif_malzemeleri: [(malzeme_id, porsiyon_basi_gram), ...]
    Donus: {malzeme_id: gram} -- temel malzemeler haric, porsiyonla carpilmis."""
    ihtiyac = {}
    for mid, g in tarif_malzemeleri:
        if mid in temel_idler or not g:
            continue
        ihtiyac[mid] = ihtiyac.get(mid, 0.0) + g * porsiyon
    return ihtiyac


def tarif_cezasi(ihtiyac, stok):
    eksik = 0.0
    karsilanan = 0.0
    for mid, g in ihtiyac.items():
        var = stok.get(mid, 0.0)
        karsilanan += min(g, var)
        eksik += max(0.0, g - var)
    return eksik - karsilanan


def stoktan_dus(ihtiyac, stok):
    """stok'u yerinde gunceller. Donus: (karsilanan_g, eksik: {malzeme_id: g},
    kullanilan: {malzeme_id: g})."""
    karsilanan = 0.0
    eksik = {}
    kullanilan = {}
    for mid, g in ihtiyac.items():
        var = stok.get(mid, 0.0)
        al = min(g, var)
        if al > 0:
            stok[mid] = var - al
            kullanilan[mid] = kullanilan.get(mid, 0.0) + al
            karsilanan += al
        if g - al > 1e-9:
            eksik[mid] = eksik.get(mid, 0.0) + (g - al)
    return karsilanan, eksik, kullanilan


def _ogun_stoktan_dus(adlar, ihtiyaclar, kalan, toplam_eksik, toplam_kullanilan):
    """Bir ogunun tariflerini sirayla stoktan duser; toplamlari yerinde gunceller.
    Donus: evdeki malzemeden karsilanan yuzde (ihtiyac yoksa None)."""
    ihtiyac_toplam = 0.0
    karsilanan_toplam = 0.0
    for ad in adlar:
        ih = ihtiyaclar.get(ad, {})
        ihtiyac_toplam += sum(ih.values())
        k, e, u = stoktan_dus(ih, kalan)
        karsilanan_toplam += k
        for mid, g in e.items():
            toplam_eksik[mid] = toplam_eksik.get(mid, 0.0) + g
        for mid, g in u.items():
            toplam_kullanilan[mid] = toplam_kullanilan.get(mid, 0.0) + g
    return (100.0 * karsilanan_toplam / ihtiyac_toplam) if ihtiyac_toplam > 0 else None


def menuyu_yeniden_hesapla(gun_tarifleri, tarif_malzemeleri, stok, porsiyon, temel_idler):
    """Elle duzenlenmis menunun stok hesabi. gun_tarifleri: [{"Öğle": [ad, ...], "Akşam": [...]}, ...]
    Donus: menu_olustur ile ayni sekil (gunler, eksik, kullanilan, kalan)."""
    ihtiyaclar = {ad: tarif_ihtiyaci(k, porsiyon, temel_idler) for ad, k in tarif_malzemeleri.items()}
    kalan = dict(stok)
    toplam_eksik, toplam_kullanilan = {}, {}
    gunler = []
    for gun_no, ogunler in enumerate(gun_tarifleri, 1):
        gun = {"gun": gun_no, "ogunler": {}}
        for ogun_adi, adlar in ogunler.items():
            gun["ogunler"][ogun_adi] = {
                "tarifler": list(adlar),
                "stoktan_yuzde": _ogun_stoktan_dus(adlar, ihtiyaclar, kalan, toplam_eksik, toplam_kullanilan),
            }
        gunler.append(gun)
    return {"gunler": gunler, "eksik": toplam_eksik, "kullanilan": toplam_kullanilan, "kalan": kalan}


def menu_olustur(tarifler, tarif_malzemeleri, stok, porsiyon, ogunler, gun_mevsimleri,
                 iki_tarif, hedefler, rastgele, temel_idler, ilerleme=None, malzeme_mevsim=None,
                 gun_aylari=None, tarif_aylari=None):
    """tarifler: motorun bekledigi liste ({"ad","grup","mevsim_etiketi","etiketler", besin...}).
    tarif_malzemeleri: {tarif_adi: [(malzeme_id, porsiyon_basi_gram), ...]}
    stok: {malzeme_id: gram} (DEGISTIRILMEZ; kopyasi uzerinde calisilir)
    ogunler: ("Öğle", "Akşam") gibi; gun_mevsimleri: her gunun mevsimi (gun sayisi = uzunluk)
    hedefler: {"Öğle": {...}, "Akşam": {...}} ya da None.
    malzeme_mevsim: {malzeme_id: mevsim kumesi ya da None} -- verilirse (Bahri,
      13 Ekim: "malzemenin mevsimi de dikkate alinsin") o gunun mevsiminde
      bulunmayan bir malzemeyi isteyen tarif o gun ONERILMEZ. Muaf: temel
      malzemeler ve baslangicta evde olan malzemeler (evde varsa mevsimi
      onemsiz). Bir grupta hic tarif kalmazsa o grup o gun filtresiz kullanilir.
    gun_aylari / tarif_aylari: her gunun ay adi ("Ocak"...) ve {tarif_adi: ay adlari kumesi}.
      Kullanicinin kendi tariflerinde "sunulabilir aylar" (receteler.uygun_aylar) secildiyse
      tarif sadece o aylarda onerilir; bos kume = kisitlama yok.

    Donus sozlugu:
      gunler: [{"gun": 1, "ogunler": {"Öğle": {"tarifler": [...], "stoktan_yuzde": x}}}, ...]
      eksik: {malzeme_id: g}          -- alisveris listesi (ham)
      kullanilan: {malzeme_id: g}
      kalan: {malzeme_id: g}
    """
    kalan = dict(stok)
    muaf_idler = set(temel_idler) | {mid for mid, g in stok.items() if g > 0}
    mevsim_disi_gun = {}
    ihtiyaclar = {
        ad: tarif_ihtiyaci(kalemler, porsiyon, temel_idler)
        for ad, kalemler in tarif_malzemeleri.items()
    }
    toplam_eksik = {}
    toplam_kullanilan = {}
    kullanilan_hafta = set()
    gunler = []
    for gun_no, mevsim in enumerate(gun_mevsimleri, 1):
        gun = {"gun": gun_no, "ogunler": {}}
        kullanilan_gun_taban = set()
        gun_tarifleri = tarifler
        if tarif_aylari and gun_aylari:
            _ay = gun_aylari[gun_no - 1]
            gun_tarifleri = [t for t in gun_tarifleri if not tarif_aylari.get(t["ad"]) or _ay in tarif_aylari[t["ad"]]]
        if malzeme_mevsim:
            uygun = [t for t in gun_tarifleri
                     if mevsimde_mi(tarif_malzemeleri.get(t["ad"], ()), mevsim, malzeme_mevsim, muaf_idler)]
            mevsim_disi_gun[gun_no] = len(gun_tarifleri) - len(uygun)
            gun_tarifleri = uygun
        grup1 = [t for t in gun_tarifleri if t["grup"] == 1] or [t for t in tarifler if t["grup"] == 1]
        grup2 = [t for t in gun_tarifleri if t["grup"] == 2] or [t for t in tarifler if t["grup"] == 2]
        grup3 = [BOS_TARIF] if iki_tarif else (
            [t for t in gun_tarifleri if t["grup"] == 3] or [t for t in tarifler if t["grup"] == 3])
        for ogun_adi in ogunler:
            ceza = {ad: tarif_cezasi(ih, kalan) for ad, ih in ihtiyaclar.items()}
            secilen = ogun_olustur(
                grup1, grup2, grup3, mevsim, kullanilan_hafta, rastgele,
                (hedefler or {}).get(ogun_adi), kullanilan_gun_taban, ceza=ceza,
            )
            secilen = [t for t in secilen if t["ad"] != BOS_TARIF_ADI]
            for t in secilen:
                kullanilan_hafta.add(t["ad"])
                kullanilan_gun_taban.add(_taban_kelime(t["ad"]))
            adlar = [t["ad"] for t in secilen]
            gun["ogunler"][ogun_adi] = {
                "tarifler": adlar,
                "stoktan_yuzde": _ogun_stoktan_dus(adlar, ihtiyaclar, kalan, toplam_eksik, toplam_kullanilan),
            }
            if ilerleme is not None:
                ilerleme()
        gunler.append(gun)
    return {"gunler": gunler, "eksik": toplam_eksik, "kullanilan": toplam_kullanilan, "kalan": kalan,
            "mevsim_disi_gun": mevsim_disi_gun}


def pratik_miktar(gram):
    """Alisveris listesi icin yukari yuvarlanmis pratik miktar (gram).
    100 g altina 10 g, 1 kg altina 50 g, ustune 100 g adim."""
    if gram <= 0:
        return 0
    adim = 10 if gram < 100 else (50 if gram < 1000 else 100)
    return int(math.ceil(gram / adim) * adim)


def gram_yazisi(gram):
    if gram >= 1000:
        return f"{gram / 1000:.2f}".rstrip("0").rstrip(".").replace(".", ",") + " kg"
    return f"{gram:.0f} g"
