# ai_okuma.py
#
# Evdekilerle Menu (14 Ekim 2026): market fisi ve tarif okuma (Groq).
#   - fis_oku: fis fotografi -> urun satirlari (katalog adi + gram tahmini)
#   - tarif_oku: yapistirilan metin ve/veya ekran goruntuleri (sosyal medya
#     tarifi) -> tarif adi, kategori, porsiyon, malzemeler (katalog adi + gram),
#     hazirlik talimati
# Yabanci dildeki urun/malzeme adlari Turkceye cevrilir ve katalogdaki
# (malzemeler tablosu) karsiligina eslenir; boylece besin degerleri katalogdan gelir.
# Model ciktisi KESIN kabul edilmez: sayfa her satiri kullaniciya bir tabloda
# gosterir, kullanici duzeltip onaylamadan hicbir sey kaydedilmez.
#
# IKI ADIM (15 Ekim 2026): Groq ucretsiz katmaninda bu model icin dakikada 7.000 girdi
# token siniri var (Bahri'nin ekraninda: "Limit 7000, Requested 7226"). Ilk surum her
# istege ~600 kalemlik katalogun tamamini ekliyordu (~5.000 token) + gorsel basina 2.048.
# Artik:
#   1) Okuma: model sadece metni/gorseli okur, KATALOGSUZ (kucuk istek).
#   2) Esleme: adlar once yerelde (tam ad / diger_adlar) eslenir; eslenemeyenler icin her
#      malzemeye en fazla 8 aday ad iceren kucuk ikinci bir istek gider. Bu istek de sinira
#      takilirsa okuma bozulmaz: o malzemeler tabloda bos (ya da en yakin aday) gelir.
#
# Anahtar: Streamlit Secrets'ta GROQ_API_KEY_IKON. Model: Groq belgelerinde (14 Ekim 2026)
# goruntu destekleyen tek model "qwen/qwen3.8-27b"; Secrets'ta GROQ_GORSEL_MODEL ile degisir.

import base64
import difflib
import io
import json

VARSAYILAN_MODEL = "qwen/qwen3.8-27b"
EN_FAZLA_GORSEL = 2          # gorsel basina 2.048 token sayiliyor; 2 gorsel + metin sinirin altinda kalir
GORSEL_UZUN_KENAR = 1600     # piksel; yazi okunur kalir (token sayisini degistirmez, istek boyutunu kucultur)
ADAY_SAYISI = 10
TPM_SINIRI = 7000            # Groq ucretsiz katman, bu model: dakikada girdi token (15 Ekim 2026 hata mesajindan)
GORSEL_TOKEN = 2048          # Groq: gorsel basina sayilan token

KATEGORILER = {"ana_yemek": "Ana Yemek", "corba": "Çorba", "salata": "Salata", "tatli": "Tatlı"}


class OkumaHatasi(Exception):
    pass


class SinirHatasi(OkumaHatasi):
    """Groq dakikalik token/istek siniri."""


def _istemci(api_anahtari):
    from groq import Groq  # sayfa yuklenirken degil, ihtiyac aninda
    return Groq(api_key=api_anahtari)


def gorseli_hazirla(veri):
    """Yuklenen fotografi (bayt) en fazla GORSEL_UZUN_KENAR px JPEG'e cevirip
    data URL dondurur. Telefon fotograflarinin yonunu (EXIF) duzeltir."""
    from PIL import Image, ImageOps
    try:
        img = Image.open(io.BytesIO(veri))
        img = ImageOps.exif_transpose(img).convert("RGB")
    except Exception as e:
        raise OkumaHatasi(f"Görsel açılamadı: {e}")
    img.thumbnail((GORSEL_UZUN_KENAR, GORSEL_UZUN_KENAR))
    tampon = io.BytesIO()
    img.save(tampon, format="JPEG", quality=85)
    return "data:image/jpeg;base64," + base64.b64encode(tampon.getvalue()).decode("ascii")


def _cagir(api_anahtari, model, sistem, metin, gorseller=()):
    icerik = [{"type": "text", "text": metin}]
    for url in list(gorseller)[:EN_FAZLA_GORSEL]:
        icerik.append({"type": "image_url", "image_url": {"url": url}})
    try:
        yanit = _istemci(api_anahtari).chat.completions.create(
            model=model,
            messages=[{"role": "system", "content": sistem}, {"role": "user", "content": icerik}],
            response_format={"type": "json_object"},
            temperature=0,
        )
    except Exception as e:
        metin_hata = str(e)
        if "rate_limit" in metin_hata or "Error code: 429" in metin_hata or "Error code: 413" in metin_hata:
            raise SinirHatasi(
                "Okuma servisinin (Groq, ücretsiz katman) dakikalık sınırı doldu. Bir dakika bekleyip tekrar dene; "
                "sorun sürerse daha az görselle (ya da sadece metinle) dene."
            )
        raise OkumaHatasi(f"Okuma servisine ulaşılamadı: {metin_hata}")
    try:
        return json.loads(yanit.choices[0].message.content)
    except Exception:
        raise OkumaHatasi("Okuma servisi anlaşılır bir sonuç döndürmedi; daha net bir görselle tekrar dene.")


# ---------------------------------------------------------------------
# Katalog esleme
# ---------------------------------------------------------------------
def tr_buyuk(metin):
    """Turkce buyuk harf: 'i' -> 'İ', 'ı' -> 'I' (Python'un upper()'i 'i'yi 'I' yapar)."""
    return str(metin).strip().replace("i", "İ").replace("ı", "I").upper()


def _sade(metin):
    """Karsilastirma icin: Turkce harfleri sadelestir, buyuk harf, noktalama yerine bosluk."""
    m = tr_buyuk(metin)
    for a, b in (("İ", "I"), ("Ş", "S"), ("Ç", "C"), ("Ğ", "G"), ("Ö", "O"), ("Ü", "U"), ("Â", "A")):
        m = m.replace(a, b)
    return "".join(c if c.isalnum() else " " for c in m).split()


class KatalogEslestirici:
    def __init__(self, katalog):
        self.adlar = [m["ad"] for m in katalog]
        self.ad_kumesi = set(self.adlar)
        self.takma = {}
        for m in katalog:
            for d in (m.get("diger_adlar") or []):
                if d:
                    self.takma[tr_buyuk(d)] = m["ad"]
        self._kelimeler = {ad: _sade(ad) for ad in self.adlar}

    def kesin(self, aday):
        """Tam ad ya da diger_adlar eslesmesi; yoksa None."""
        if not aday:
            return None
        a = tr_buyuk(aday)
        if a in self.ad_kumesi:
            return a
        return self.takma.get(a)

    def adaylar(self, aday, n=ADAY_SAYISI):
        """Kelime ortakligi + benzerlik puanina gore en olasi katalog adlari."""
        if not aday:
            return []
        k = _sade(aday)
        if not k:
            return []
        birlesik = " ".join(k)
        puanlar = []
        for ad, kel in self._kelimeler.items():
            ortak = 0
            for w in k:
                for c in kel:
                    # tam ayni; ya da biri digerinin basi (Turkce ek: UN -> UNU, SUT -> SUTU)
                    if w == c or (c.startswith(w) and len(c) - len(w) <= 2) or (
                            len(w) >= 3 and len(c) >= 3 and (c.startswith(w) or w.startswith(c))):
                        ortak += 1
                        break
            oran = difflib.SequenceMatcher(None, birlesik, " ".join(kel)).ratio()
            puan = 2.0 * ortak + oran
            if ortak or oran >= 0.6:
                puanlar.append((puan, ad))
        puanlar.sort(key=lambda x: -x[0])
        return [ad for _, ad in puanlar[:n]]


# Sabit es anlamlilar (15 Ekim 2026, Bahri). Veritabanindaki diger_adlar'dan bagimsiz, once bunlara bakilir.
# Anahtar: tr_buyuk(ad). TARIF_ESANLAM sadece tarif okumada (ev yemegi baglami) kullanilir.
ORTAK_ESANLAM = {
    "REYHAN": "TAZE FESLEĞEN", "MOR REYHAN": "TAZE FESLEĞEN", "FESLEĞEN": "TAZE FESLEĞEN",
    "DEREOTU": "TAZE DEREOTU", "DERE OTU": "TAZE DEREOTU",
    "SALÇA": "KONSERVE DOMATES SALÇASI", "DOMATES SALÇASI": "KONSERVE DOMATES SALÇASI",
    "BİBER SALÇASI": "KONSERVE BİBER SALÇASI", "ACI BİBER SALÇASI": "KONSERVE BİBER SALÇASI",
    "TATLI BİBER SALÇASI": "KONSERVE BİBER SALÇASI",
    # Tarifte turu yazilmadiginda yaygin varsayilanlar (Not sutununda gosterilir, kullanici degistirebilir)
    "PİRİNÇ": "PİRİNÇ (HAM)", "UN": "BUĞDAY UNU", "SÜT": "SÜT (TAM YAĞ)", "YOĞURT": "YOĞURT (TAM)",
    "YUMURTA": "TAVUK YUMURTASI", "SOĞAN": "KURU SOĞAN", "ŞEKER": "TOZ ŞEKER", "KIYMA": "DANA KIYMA",
}
# Bahri: "Sivi yag tariflerde genelde aycicek yagi diye gecse de ev yemeklerinde daha cok zeytinyagi kullanilir."
TARIF_ESANLAM = {"SIVI YAĞ": "ZEYTİNYAĞI", "SIVIYAĞ": "ZEYTİNYAĞI", "YAĞ": "ZEYTİNYAĞI"}

_ESLEME_SISTEM = (
    "Malzeme adlarını bir gıda kataloğuyla eşleştiriyorsun. Her malzeme için verilen ADAYLAR arasından anlamca "
    "en uygun olanı AYNEN yaz. Yöresel ve eş anlamlı adları dikkate al (ör. reyhan = fesleğen). Bir malzemeyi "
    "boş bırakma: tam karşılık yoksa en yakın olanı seç. Aday dışında ad yazma. "
    "Sadece JSON: {\"eslesmeler\":[{\"no\":1,\"katalog_adi\":\"...\"}]}"
)


def eslestir(api_anahtari, model, adlar, katalog, esanlam=None):
    """adlar: ['kıyma', 'soğan', ...] -> [(katalog adi ya da None, kaynak), ...]
    kaynak: 'kesin' (tam ad / diger_adlar), 'esanlam' (sabit es anlamli), 'secim' (model adaylardan secti),
    'yakin' (model secemedi ya da istek yapilamadi: en olasi aday -- kullanici kontrol etmeli), None (aday yok).
    Bahri (15 Ekim): malzemeler bos gecilmesin -- aday varsa her zaman bir ad konur."""
    es = KatalogEslestirici(katalog)
    sozluk = dict(ORTAK_ESANLAM)
    sozluk.update(esanlam or {})
    sonuc = []
    for a in adlar:
        k = es.kesin(a)
        if k:
            sonuc.append((k, "kesin"))
            continue
        e = sozluk.get(tr_buyuk(a)) if a else None
        sonuc.append((e, "esanlam") if e and e in es.ad_kumesi else (None, None))
    bekleyen = [(i, a, es.adaylar(a)) for i, a in enumerate(adlar) if sonuc[i][0] is None and a]
    bekleyen = [(i, a, ad) for i, a, ad in bekleyen if ad]
    if not bekleyen:
        return sonuc
    metin = "\n".join(
        f"{no}. {a} -> ADAYLAR: {' | '.join(ad)}" for no, (_i, a, ad) in enumerate(bekleyen, 1)
    )
    try:
        veri = _cagir(api_anahtari, model, _ESLEME_SISTEM, metin)
        secimler = {int(e.get("no")): e.get("katalog_adi") for e in (veri.get("eslesmeler") or [])
                    if isinstance(e, dict) and str(e.get("no", "")).isdigit()}
    except OkumaHatasi:
        secimler = {}
    for no, (i, a, ad) in enumerate(bekleyen, 1):
        secim = secimler.get(no)
        sonuc[i] = (secim, "secim") if secim in ad else (ad[0], "yakin")
    return sonuc


# ---------------------------------------------------------------------
# 1. adim: okuma (katalogsuz)
# ---------------------------------------------------------------------
_FIS_SISTEM = (
    "Bir market fişini okuyorsun. Sadece GIDA ürünlerini çıkar; poşet, deterjan, temizlik, kozmetik, indirim, "
    "KDV, toplam ve ödeme satırlarını atla. Ürün adını sade Türkçe genel adıyla yaz (marka yazma; başka dildeyse "
    "çevir; ör. 'ONIONS' -> 'kuru soğan', 'DANA KIYMA %20' -> 'dana kıyma'). Miktarı gram olarak ver: tartılı "
    "ürünlerde fişteki kg (1,250 KG -> 1250); paketli ürünlerde paket boyutu x adet (SÜT 1 LT x 2 -> 2060; "
    "1 litre ~1000-1030 g). Boyut yazmıyorsa yaygın paket boyutunu tahmin et ve tahmin=true yaz. Sadece JSON: "
    '{"urunler":[{"fis_satiri":"...","urun":"...","gram":sayı,"tahmin":true/false}]}'
)

BIRIMLER = ["g", "kg", "ml", "l", "adet", "su bardağı", "çay bardağı", "yemek kaşığı",
            "tatlı kaşığı", "çay kaşığı", "diş", "demet", "tutam"]

_TARIF_SISTEM = (
    "Bir yemek tarifini (metin ve/veya ekran görüntüsü) okuyorsun. Tek tarifi çıkar, başka dildeyse Türkçeye "
    "çevir. Tarifin ADINI malzeme olarak yazma. HER malzemeyi ayrı yaz: bir satırda birden fazla malzeme varsa "
    "(ör. 'maydanoz, dereotu', 'tuz ve karabiber') her birini ayrı satır yap; 'domates biber karışık salça' gibi "
    "karışık salçayı da domates salçası ve biber salçası olarak iki satıra böl, miktarı eşit paylaştır. İsteğe "
    "bağlı ve süsleme malzemelerini atlama. Her malzeme için: tarifte yazan metin, sade Türkçe genel ad "
    "(ör. 'ground beef' -> 'dana kıyma'), tarifteki miktar (sayı) ve birim. Birim şunlardan biri olsun: "
    + ", ".join(BIRIMLER) + ". Mutlaka toplam GRAM ver (1 su bardağı un ~120 g, pirinç ~180 g, bulgur ~170 g, "
    "şeker ~190 g, su/süt ~200 g; 1 çay bardağı yağ ~90 g; 1 yemek kaşığı yağ ~13 g, salça ~17 g, un ~10 g; "
    "1 tatlı kaşığı ~5 g; 1 çay kaşığı tuz/baharat ~3-5 g; 1 tutam taze yeşillik (maydanoz, dereotu, nane) ~5 g; "
    "1 tutam baharat/tuz ~1 g; 1 demet maydanoz/dereotu ~50 g; 1 orta soğan ~110 g, büyük ~150 g; 1 orta lahana "
    "~1000 g; 1 yumurta ~50 g; 1 diş sarımsak ~4 g). Miktar yazmıyorsa (ör. 'tuz', 'isteğe göre') makul bir "
    "miktar tahmin et ve tahmin=true yaz. Kategori: ana_yemek, corba, salata ya da tatli. Kişi sayısı "
    "yazmıyorsa tahmin et, porsiyon_tahmin=true. Hazırlanışı numaralı, sade Türkçe yaz. Sadece JSON: "
    '{"ad":"...","kategori":"...","porsiyon":sayı,"porsiyon_tahmin":true/false,'
    '"malzemeler":[{"metin":"tarifte yazan","malzeme":"Türkçe genel ad","miktar":sayı,"birim":"...",'
    '"gram":sayı,"tahmin":true/false}],"talimat":"1. ...\\n2. ..."}'
)


def _sayi(x):
    try:
        v = float(str(x).replace(",", "."))
        return v if v > 0 else None
    except Exception:
        return None


def fis_oku(api_anahtari, gorsel_urlleri, katalog, model=VARSAYILAN_MODEL):
    """Donus: [{"fis_satiri", "urun", "katalog_adi" (gercek ad ya da None), "gram", "tahmin"}]"""
    if not gorsel_urlleri:
        raise OkumaHatasi("Fiş fotoğrafı yok.")
    veri = _cagir(api_anahtari, model, _FIS_SISTEM, "Fişi oku.", gorsel_urlleri)
    urunler = [u for u in (veri.get("urunler") or []) if isinstance(u, dict)]
    eslesme = eslestir(api_anahtari, model, [str(u.get("urun") or "") for u in urunler], katalog)
    return [{
        "fis_satiri": str(u.get("fis_satiri") or "")[:120],
        "urun": str(u.get("urun") or "")[:80],
        "katalog_adi": k,
        "eslesme": kaynak,
        "gram": _sayi(u.get("gram")),
        "tahmin": bool(u.get("tahmin")),
    } for u, (k, kaynak) in zip(urunler, eslesme)]


def tarif_oku(api_anahtari, metin, gorsel_urlleri, katalog, model=VARSAYILAN_MODEL):
    """Donus: {"ad", "kategori", "porsiyon", "porsiyon_tahmin", "malzemeler": [{"metin",
    "katalog_adi", "gram", "tahmin"}], "talimat"}"""
    if not (metin or "").strip() and not gorsel_urlleri:
        raise OkumaHatasi("Tarif metni ya da ekran görüntüsü yok.")
    # Dakikalik token siniri: gorsel sayisina gore metin kisaltilir (Turkce metinde ~1,8 karakter/token
    # olarak hesaplandi; 15 Ekim'deki gercek istekte katalog listesi beklenenin ~1,8 kati token tuttu).
    n = len(list(gorsel_urlleri or [])[:EN_FAZLA_GORSEL])
    metin_siniri = max(1000, int((TPM_SINIRI - 1000 - GORSEL_TOKEN * n - 600) * 1.8))
    istek = "TARİF:\n" + ((metin or "").strip()[:metin_siniri] or "(görsellerde)")
    veri = _cagir(api_anahtari, model, _TARIF_SISTEM, istek, gorsel_urlleri)
    tarif_adi = str(veri.get("ad") or "").strip()[:100]
    ham = _malzemeleri_temizle([m for m in (veri.get("malzemeler") or []) if isinstance(m, dict)], tarif_adi)
    eslesme = eslestir(api_anahtari, model, [str(m.get("malzeme") or m.get("metin") or "") for m in ham],
                       katalog, esanlam=TARIF_ESANLAM)
    kategori = veri.get("kategori") if veri.get("kategori") in KATEGORILER else "ana_yemek"
    porsiyon = _sayi(veri.get("porsiyon"))
    return {
        "ad": tarif_adi,
        "kategori": kategori,
        "porsiyon": int(round(porsiyon)) if porsiyon else 4,
        "porsiyon_tahmin": bool(veri.get("porsiyon_tahmin")) or not porsiyon,
        "malzemeler": [{
            "metin": str(m.get("metin") or m.get("malzeme") or "")[:120],
            "ad": str(m.get("malzeme") or "")[:60],
            "katalog_adi": k,
            "eslesme": kaynak,
            "miktar": _sayi(m.get("miktar")),
            "birim": m.get("birim") if m.get("birim") in BIRIMLER else ("g" if _sayi(m.get("gram")) else "adet"),
            "gram": _sayi(m.get("gram")),
            "tahmin": bool(m.get("tahmin")),
            "not": m.get("_not", ""),
        } for m, (k, kaynak) in zip(ham, eslesme)],
        "talimat": str(veri.get("talimat") or "").strip()[:6000],
    }


def _malzemeleri_temizle(ham, tarif_adi):
    """(1) Tarifin adi malzeme satiri olarak gelmisse atilir (15 Ekim: 'Etli Lahana Sarmasi' 200 g kiyma olarak
    gelmisti). (2) 'domates biber karisik' salca model bolmediyse burada iki satira bolunur (miktar yari yariya)."""
    ad_sade = _sade(tarif_adi)
    temiz = []
    for m in ham:
        metin_sade = _sade(m.get("metin") or "")
        if ad_sade and (metin_sade == ad_sade or _sade(m.get("malzeme") or "") == ad_sade):
            continue
        malz = " ".join(_sade(m.get("malzeme") or ""))
        birlesik = malz + " " + " ".join(_sade(m.get("metin") or ""))
        # Model zaten bolduyse malzeme adi tek tur icerir (DOMATES ya da BIBER); o zaman bolunmez.
        tek_tur = ("DOMATES" in malz) != ("BIBER" in malz)
        if "SALCA" in birlesik and "DOMATES" in birlesik and "BIBER" in birlesik and not tek_tur:
            yari = {k: (_sayi(m.get(k)) / 2 if _sayi(m.get(k)) else m.get(k)) for k in ("miktar", "gram")}
            for ad in ("domates salçası", "biber salçası"):
                temiz.append(dict(m, malzeme=ad, miktar=yari["miktar"], gram=yari["gram"],
                                  _not="karışık salça ikiye bölündü"))
            continue
        temiz.append(m)
    return temiz
