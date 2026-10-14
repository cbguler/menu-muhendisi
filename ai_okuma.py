# ai_okuma.py
#
# Evdekilerle Menu (14 Ekim 2026): market fisi ve tarif okuma (Groq).
#   - fis_oku: fis fotografi -> urun satirlari (katalog adi + gram tahmini)
#   - tarif_oku: yapistirilan metin ve/veya ekran goruntuleri (sosyal medya
#     tarifi) -> tarif adi, kategori, porsiyon, malzemeler (katalog adi + gram),
#     hazirlik talimati
# Yabanci dildeki urun/malzeme adlari Turkceye cevrilip katalogdaki (malzemeler
# tablosu) EN YAKIN ada eslenir; boylece besin degerleri katalogdan gelir.
# Model ciktisi KESIN kabul edilmez: sayfa her satiri kullaniciya bir tabloda
# gosterir, kullanici duzeltip onaylamadan hicbir sey kaydedilmez. Modelin
# uydurdugu (katalogda olmayan) adlar burada yakin eslesmeyle duzeltilir ya da
# bos birakilir.
#
# Anahtar: Streamlit Secrets'ta GROQ_API_KEY_IKON (Menu Muhendisi'nin ayri Groq
# hesabi; TrendSurf'un anahtariyla limit paylasmasin diye -- PROJE_NOTLARI 30
# Agustos). Model: Groq belgelerinde (console.groq.com/docs/vision, 14 Ekim 2026)
# goruntu destekleyen tek model "qwen/qwen3.8-27b". Groq modelleri degisebildigi
# icin Secrets'ta GROQ_GORSEL_MODEL ile degistirilebilir.

import base64
import difflib
import io
import json

VARSAYILAN_MODEL = "qwen/qwen3.8-27b"
EN_FAZLA_GORSEL = 3          # Groq: istek basina en fazla 3 goruntu
GORSEL_UZUN_KENAR = 1600     # piksel; fis yazisi okunur kalir, istek kucuk olur

KATEGORILER = {"ana_yemek": "Ana Yemek", "corba": "Çorba", "salata": "Salata", "tatli": "Tatlı"}


class OkumaHatasi(Exception):
    pass


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
        raise OkumaHatasi(f"Okuma servisine ulaşılamadı: {e}")
    try:
        return json.loads(yanit.choices[0].message.content)
    except Exception:
        raise OkumaHatasi("Okuma servisi anlaşılır bir sonuç döndürmedi; daha net bir fotoğrafla tekrar dene.")


def tr_buyuk(metin):
    """Turkce buyuk harf: 'i' -> 'İ', 'ı' -> 'I' (Python'un upper()'i 'i'yi 'I' yapar)."""
    return str(metin).strip().replace("i", "İ").replace("ı", "I").upper()


def katalog_eslestirici(katalog):
    """katalog: [{"ad", "diger_adlar"}] -> (ad listesi, esle(ad) fonksiyonu).
    esle: modelin verdigi adi katalogdaki gercek ada cevirir; bulamazsa None."""
    adlar = [m["ad"] for m in katalog]
    ad_kumesi = set(adlar)
    takma = {}
    for m in katalog:
        for d in (m.get("diger_adlar") or []):
            if d:
                takma[tr_buyuk(d)] = m["ad"]

    def esle(aday):
        if not aday:
            return None
        a = tr_buyuk(aday)
        if a in ad_kumesi:
            return a
        if a in takma:
            return takma[a]
        yakin = difflib.get_close_matches(a, adlar + list(takma), n=1, cutoff=0.82)
        if yakin:
            return takma.get(yakin[0], yakin[0])
        return None

    return adlar, esle


_FIS_SISTEM = (
    "Bir market fişini okuyan yardımcısın. Fişteki GIDA ürünlerini çıkar; poşet, deterjan, temizlik, "
    "kozmetik, indirim, KDV, toplam, ödeme satırlarını ATLA. Ürün adı başka bir dildeyse Türkçeye çevir. "
    "Her ürün için verilen KATALOG listesinden anlamca en uygun adı AYNEN (büyük harf, katalogda yazdığı "
    "gibi) seç; uygun ad yoksa null yaz, ad uydurma. Miktarı gram olarak tahmin et: tartılı ürünlerde "
    "fişteki kg değeri (1,250 KG -> 1250), paketli ürünlerde ürün adındaki paket boyutu x adet "
    "(SÜT 1 LT x 2 -> 2060; sıvılarda 1 litre yaklaşık 1000-1030 g). Boyut yazmıyorsa yaygın paket "
    "boyutunu tahmin et ve tahmin=true işaretle. Yalnızca JSON döndür: "
    '{"urunler":[{"fis_satiri":"...","urun":"Türkçe ürün adı","katalog_adi":"... ya da null",'
    '"gram":sayı,"tahmin":true/false}]}'
)

_TARIF_SISTEM = (
    "Sosyal medyadan ya da bir metinden alınmış bir yemek tarifini okuyan yardımcısın. Metin ve/veya "
    "görsellerdeki TEK bir tarifi çıkar. Başka dildeyse Türkçeye çevir. Her malzeme için verilen KATALOG "
    "listesinden anlamca en uygun adı AYNEN seç; uygun ad yoksa null yaz, ad uydurma. Ölçüleri grama çevir "
    "(1 su bardağı un ~120 g, 1 su bardağı pirinç ~180 g, 1 su bardağı su/süt ~200 g, 1 yemek kaşığı yağ "
    "~13 g, 1 yemek kaşığı salça ~17 g, 1 tatlı kaşığı ~5 g, 1 çay kaşığı tuz ~5 g, 1 orta soğan ~110 g, "
    "1 yumurta ~50 g, 1 diş sarımsak ~4 g); ölçü yoksa ya da çevirmen gerekiyorsa tahmin=true işaretle. "
    "Kategori şunlardan biri olsun: ana_yemek, corba, salata, tatli. Porsiyon (kaç kişilik) yazmıyorsa "
    "tahmin et ve porsiyon_tahmin=true yaz. Hazırlık adımlarını numaralı, sade Türkçe yaz. Yalnızca JSON döndür: "
    '{"ad":"...","kategori":"...","porsiyon":sayı,"porsiyon_tahmin":true/false,'
    '"malzemeler":[{"metin":"tarifte yazan","katalog_adi":"... ya da null","gram":sayı,"tahmin":true/false}],'
    '"talimat":"1. ...\\n2. ..."}'
)


def _katalog_metni(adlar):
    return "KATALOG:\n" + "\n".join(adlar)


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
    adlar, esle = katalog_eslestirici(katalog)
    veri = _cagir(api_anahtari, model, _FIS_SISTEM, _katalog_metni(adlar) + "\n\nFişi oku.", gorsel_urlleri)
    satirlar = []
    for u in (veri.get("urunler") or []):
        if not isinstance(u, dict):
            continue
        satirlar.append({
            "fis_satiri": str(u.get("fis_satiri") or "")[:120],
            "urun": str(u.get("urun") or "")[:80],
            "katalog_adi": esle(u.get("katalog_adi")) or esle(u.get("urun")),
            "gram": _sayi(u.get("gram")),
            "tahmin": bool(u.get("tahmin")),
        })
    return satirlar


def tarif_oku(api_anahtari, metin, gorsel_urlleri, katalog, model=VARSAYILAN_MODEL):
    """Donus: {"ad", "kategori", "porsiyon", "porsiyon_tahmin", "malzemeler": [{"metin",
    "katalog_adi", "gram", "tahmin"}], "talimat"}"""
    if not (metin or "").strip() and not gorsel_urlleri:
        raise OkumaHatasi("Tarif metni ya da ekran görüntüsü yok.")
    adlar, esle = katalog_eslestirici(katalog)
    istek = _katalog_metni(adlar) + "\n\nTARİF:\n" + ((metin or "").strip()[:8000] or "(görsellerde)")
    veri = _cagir(api_anahtari, model, _TARIF_SISTEM, istek, gorsel_urlleri)
    kategori = veri.get("kategori") if veri.get("kategori") in KATEGORILER else "ana_yemek"
    porsiyon = _sayi(veri.get("porsiyon"))
    malzemeler = []
    for m in (veri.get("malzemeler") or []):
        if not isinstance(m, dict):
            continue
        malzemeler.append({
            "metin": str(m.get("metin") or "")[:120],
            "katalog_adi": esle(m.get("katalog_adi")) or esle(m.get("metin")),
            "gram": _sayi(m.get("gram")),
            "tahmin": bool(m.get("tahmin")),
        })
    return {
        "ad": str(veri.get("ad") or "").strip()[:100],
        "kategori": kategori,
        "porsiyon": int(round(porsiyon)) if porsiyon else 4,
        "porsiyon_tahmin": bool(veri.get("porsiyon_tahmin")) or not porsiyon,
        "malzemeler": malzemeler,
        "talimat": str(veri.get("talimat") or "").strip()[:6000],
    }
