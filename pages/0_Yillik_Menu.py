# pages/5_Yillik_Menu.py
#
# Yillik Menu Uretim Motoru (ilk surum): global tarif kutuphanesinden
# (receteler, isletme_id NULL) anayasa kurallarina uygun ornek haftalik
# menu uretir. Henuz eklenmeyenler: kisisel_beslenme_profili filtrelemesi,
# menu_takvimi/menu_takvimi_ogeleri'ne yazma (sadece ekranda gosteriyor).

import io
import random

import streamlit as st
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

# NOT (12 Agustos 2026, Oturum 11): logo artik burada AYRICA gosterilmiyor -- app.py'deki ozel menu satirinin icine tasindi, orada zaten her sayfa gecisinde render ediliyor. Burada tekrar cagirmak cift logoya yol acardi.

from db import get_supabase, oturumu_uygula
from uretim_algoritmasi import MEVSIMLER, hafta_olustur

MEVSIM_AYLARI = {
    "kis": ["Aralık", "Ocak", "Şubat"],
    "ilkbahar": ["Mart", "Nisan", "Mayıs"],
    "yaz": ["Haziran", "Temmuz", "Ağustos"],
    "sonbahar": ["Eylül", "Ekim", "Kasım"],
}
AYLAR_SIRALI = [
    "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
    "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
]

# ON DOKUZUNCU DUZELTME (13 Agustos 2026, Oturum 11): malzemeler tablosu
# artik 27 ek besin ogesi iceriyor (45_genisletilmis_besin_degerleri.sql).
# Kullanicinin istegi: bunlarin da kalori ornegindeki gibi SECILEBILIR ve
# hedef araligiyla KISITLANABILIR olmasi -- ama hepsini otomatik gostermek
# DEGIL (31 satir birden cok kalabalik olurdu). Bu yuzden asagida TUM
# alanlarin (mevcut 5 + yeni 27) tek bir katalogu var; kullanici bunlardan
# HANGILERINI hedeflemek istedigini bir multiselect ile seciyor, sadece
# secilenler icin min/max girisi gosteriliyor (bkz. asagidaki
# "besin_hedefi_kullan" bolumu).
# Aralik/varsayilan degerleri kabaca "gunluk RDA'nin uc oguune bolunmus
# hali" mantigiyla, TEK BIR OGUN icin makul bir baslangic noktasi olarak
# secildi -- kesin bilimsel bir tavsiye degil, kullanici kendi mutfagina
# gore ayarlayabilir.
TUM_BESIN_ALANLARI = [
    # NOT: Streamlit'in number_input'u min/maks/varsayilan degerlerin
    # HEPSININ AYNI TIPTE (ya hep int ya hep float) olmasini zorunlu
    # kilar -- aksi halde StreamlitMixedNumericTypesError firlatir.
    # Bu yuzden HER satirda tum 4 deger (min, maks, def_alt, def_ust)
    # BILINCLI OLARAK float yaziliyor, tam sayi gibi gorunse bile.
    ("kalori", "Kalori (kcal)", 0.0, 3000.0, 900.0, 1200.0),
    ("protein", "Protein (g)", 0.0, 150.0, 20.0, 60.0),
    ("yag", "Yağ (g)", 0.0, 120.0, 10.0, 40.0),
    ("karbonhidrat", "Karbonhidrat (g)", 0.0, 300.0, 40.0, 120.0),
    ("gi", "Glisemik İndeks", 0.0, 100.0, 0.0, 70.0),
    ("sodyum_mg", "Sodyum (mg)", 0.0, 3000.0, 200.0, 800.0),
    ("lif_g", "Lif (g)", 0.0, 30.0, 3.0, 10.0),
    ("seker_g", "Şeker (g)", 0.0, 80.0, 0.0, 25.0),
    ("doymus_yag_g", "Doymuş Yağ (g)", 0.0, 50.0, 0.0, 15.0),
    ("vitamin_a_mcg", "Vitamin A (mcg)", 0.0, 1000.0, 100.0, 300.0),
    ("vitamin_b1_mg", "Vitamin B1 — Tiamin (mg)", 0.0, 3.0, 0.2, 0.6),
    ("vitamin_b2_mg", "Vitamin B2 — Riboflavin (mg)", 0.0, 3.0, 0.2, 0.6),
    ("vitamin_b3_mg", "Vitamin B3 — Niasin (mg)", 0.0, 25.0, 2.0, 8.0),
    ("vitamin_b5_mg", "Vitamin B5 — Pantotenik Asit (mg)", 0.0, 12.0, 0.5, 3.0),
    ("vitamin_b6_mg", "Vitamin B6 (mg)", 0.0, 4.0, 0.2, 0.6),
    ("vitamin_b7_mcg", "Vitamin B7 — Biyotin (mcg)", 0.0, 60.0, 5.0, 15.0),
    ("vitamin_b9_mcg", "Vitamin B9 — Folat (mcg)", 0.0, 600.0, 50.0, 150.0),
    ("vitamin_b12_mcg", "Vitamin B12 (mcg)", 0.0, 12.0, 0.3, 1.0),
    ("vitamin_c_mg", "Vitamin C (mg)", 0.0, 250.0, 15.0, 50.0),
    ("vitamin_d_mcg", "Vitamin D (mcg)", 0.0, 50.0, 2.0, 6.0),
    ("vitamin_e_mg", "Vitamin E (mg)", 0.0, 35.0, 2.0, 6.0),
    ("vitamin_k_mcg", "Vitamin K (mcg)", 0.0, 250.0, 20.0, 60.0),
    ("kalsiyum_mg", "Kalsiyum (mg)", 0.0, 1500.0, 150.0, 450.0),
    ("demir_mg", "Demir (mg)", 0.0, 35.0, 2.0, 8.0),
    ("magnezyum_mg", "Magnezyum (mg)", 0.0, 700.0, 50.0, 150.0),
    ("potasyum_mg", "Potasyum (mg)", 0.0, 4500.0, 400.0, 1200.0),
    ("cinko_mg", "Çinko (mg)", 0.0, 25.0, 1.0, 4.0),
    ("fosfor_mg", "Fosfor (mg)", 0.0, 1200.0, 100.0, 300.0),
    ("bakir_mg", "Bakır (mg)", 0.0, 4.0, 0.1, 0.4),
    ("manganez_mg", "Manganez (mg)", 0.0, 6.0, 0.3, 1.0),
    ("selenyum_mcg", "Selenyum (mcg)", 0.0, 180.0, 10.0, 30.0),
    ("iyot_mcg", "İyot (mcg)", 0.0, 350.0, 20.0, 60.0),
]
_BESIN_ETIKET = {anahtar: etiket for anahtar, etiket, *_ in TUM_BESIN_ALANLARI}
_BESIN_ARALIK = {anahtar: (minv, maxv, def_alt, def_ust) for anahtar, _, minv, maxv, def_alt, def_ust in TUM_BESIN_ALANLARI}
# malzemeler tablosundaki kolon adlari (5 temel alan disindakiler icin
# ayni isim, kolon adiyla anahtar birebir ayni secildi)
_GENISLETILMIS_KOLONLAR = [a for a, *_ in TUM_BESIN_ALANLARI if a not in ("kalori", "protein", "yag", "karbonhidrat", "gi")]

st.set_page_config(page_title="Yıllık Menü", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Yıllık Menü Üretim Motoru")
st.caption(
    "Türk mutfağı tarif kütüphanesinden, anayasa kurallarına uygun "
    "(madde 8, 11, 13) örnek haftalık menü üretir. İlk sürüm — kişisel "
    "beslenme profili filtrelemesi ve takvime kaydetme henüz eklenmedi."
)


@st.cache_data(ttl=3600)
def _mutfaklari_getir():
    return (supabase.table("mutfaklar").select("kod, ad").execute()).data


mutfaklar_listesi = _mutfaklari_getir()
sol_mutfak, _bos_mutfak = st.columns([1, 3])
with sol_mutfak:
    mutfak_secimi = st.selectbox(
        "Mutfak", mutfaklar_listesi, format_func=lambda m: m["ad"],
    )
# Su an sadece Turk Mutfagi var, ama tarif sorgusu asagida mutfak_secimi["kod"]'a
# gore calisiyor -- ileride yeni bir mutfak (ör. Fransiz Mutfagi) eklenip
# kendi mutfak_kategorileri/receteler'i girildiginde, bolge butonlari ve
# tum akis otomatik olarak o mutfaga gore calisacak, ek kod degisikligi gerekmez.


@st.cache_data(ttl=3600)
def _tarif_kutuphanesini_getir(mutfak_kodu):
    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", mutfak_kodu).single().execute()
    ).data
    kategoriler = (
        supabase.table("mutfak_kategorileri")
        .select("id, sira")
        .eq("mutfak_id", mutfak["id"])
        .execute()
    ).data
    grup_by_kategori = {k["id"]: k["sira"] for k in kategoriler}

    receteler = (
        supabase.table("receteler")
        .select("ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge")
        .is_("isletme_id", "null")
        .execute()
    ).data

    tarifler = []
    for r in receteler:
        grup = grup_by_kategori.get(r["mutfak_kategori_id"])
        if grup is None:
            continue
        tarifler.append(
            {
                "ad": r["ad"],
                "grup": grup,
                "mevsim_etiketi": r["mevsim_etiketi"] or "yil_boyunca",
                "etiketler": r["ozel_etiketler"] or [],
                "bolge": r["bolge"] or "Genel",
            }
        )
    return tarifler


@st.cache_data(ttl=3600)
def _tarif_detaylarini_getir(isletme_id):
    """Global tariflerin porsiyon basi besin degeri, alerjen listesi ve
    (bu isletmenin kendi malzeme fiyatlariyla) maliyetini hesaplar.
    Maliyet isletmeye ozeldir cunku fiyatlar isletme_id'ye gore tutuluyor
    (malzeme_guncel_fiyat) -- global tariflerin kendi fiyati yok."""
    receteler = (
        supabase.table("receteler").select("id, ad").is_("isletme_id", "null").execute()
    ).data
    id_to_ad = {r["id"]: r["ad"] for r in receteler}

    malzeme_kalemleri = (
        supabase.table("recete_malzemeleri")
        .select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(ad, kalori, protein, yag, karbonhidrat, glisemik_indeks, "
            + ", ".join(_GENISLETILMIS_KOLONLAR) + ")"
        )
        .execute()
    ).data

    alerjen_kayitlari = (
        supabase.table("malzeme_alerjen").select("malzeme_id, alerjenler(ad)").execute()
    ).data
    alerjen_by_malzeme = {}
    for kayit in alerjen_kayitlari:
        ad = (kayit.get("alerjenler") or {}).get("ad")
        if ad:
            alerjen_by_malzeme.setdefault(kayit["malzeme_id"], set()).add(ad)

    fiyat_kayitlari = (
        supabase.table("malzeme_guncel_fiyat")
        .select("malzeme_id, fiyat_eur")
        .eq("isletme_id", isletme_id)
        .execute()
    ).data
    fiyat_by_malzeme = {f["malzeme_id"]: f["fiyat_eur"] for f in fiyat_kayitlari}
    fiyat_verisi_var = len(fiyat_by_malzeme) > 0

    ham = {}
    for kalem in malzeme_kalemleri:
        ad = id_to_ad.get(kalem["recete_id"])
        if ad is None:
            continue  # baska bir isletmeye ait ozel tarif olabilir, atla
        m = kalem.get("malzemeler") or {}
        oran = kalem["miktar_gram"] / 100.0
        girdi = ham.setdefault(
            ad, {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
                 "gi_agirlikli": 0.0, "gi_karb_toplam": 0.0, "maliyet_eur": 0.0,
                 "tam_fiyatli": True, "eksik_malzemeler": set(), "alerjenler": set(),
                 **{k: 0.0 for k in _GENISLETILMIS_KOLONLAR},
                 # ON DOKUZUNCU DUZELTME (13 Agustos 2026): bir tarifte
                 # HICBIR malzeme belirli bir besin ogesi icin veri
                 # icermiyorsa (ör. Vitamin B7 -- kataloğumuzda birçok
                 # malzemede hala eksik), toplamin "0" degil "bilinmiyor"
                 # (None) olmasi gerekiyor -- yoksa hedef kontrolu
                 # yanlislikla "0 < min" diyerek TUM ogunleri hedef disi
                 # isaretliyordu (kullanici 32 besin ogesinin hepsini
                 # secince bu hata ortaya cikti). Her genisletilmis kolon
                 # icin ayri bir "en az bir malzeme veri verdi mi" bayragi
                 # tutuyoruz.
                 **{f"{k}_var_mi": False for k in _GENISLETILMIS_KOLONLAR}}
        )
        girdi["kalori"] += (m.get("kalori") or 0) * oran
        girdi["protein"] += (m.get("protein") or 0) * oran
        girdi["yag"] += (m.get("yag") or 0) * oran
        karb = (m.get("karbonhidrat") or 0) * oran
        girdi["karbonhidrat"] += karb
        gi = m.get("glisemik_indeks")
        if gi is not None and karb > 0:
            girdi["gi_agirlikli"] += gi * karb
            girdi["gi_karb_toplam"] += karb
        for kolon in _GENISLETILMIS_KOLONLAR:
            deger = m.get(kolon)
            if deger is not None:
                girdi[kolon] += deger * oran
                girdi[f"{kolon}_var_mi"] = True

        malzeme_id = kalem["malzeme_id"]
        fiyat = fiyat_by_malzeme.get(malzeme_id)
        if fiyat is None:
            girdi["tam_fiyatli"] = False
            malzeme_adi = m.get("ad")
            if malzeme_adi:
                girdi["eksik_malzemeler"].add(malzeme_adi)
        else:
            girdi["maliyet_eur"] += (kalem["miktar_gram"] / 1000.0) * fiyat
        girdi["alerjenler"] |= alerjen_by_malzeme.get(malzeme_id, set())

    sonuc = {}
    for ad, v in ham.items():
        gi = (v["gi_agirlikli"] / v["gi_karb_toplam"]) if v["gi_karb_toplam"] > 0 else None
        sonuc[ad] = {
            "kalori": v["kalori"], "protein": v["protein"],
            "yag": v["yag"], "karbonhidrat": v["karbonhidrat"], "gi": gi,
            "maliyet_eur": v["maliyet_eur"], "tam_fiyatli": v["tam_fiyatli"],
            "eksik_malzemeler": v["eksik_malzemeler"], "alerjenler": v["alerjenler"],
            **{k: (v[k] if v[f"{k}_var_mi"] else None) for k in _GENISLETILMIS_KOLONLAR},
        }
    return sonuc, fiyat_verisi_var


def _ogun_toplami(tarif_adlari, detay):
    toplam = {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0, "maliyet_eur": 0.0,
              **{k: 0.0 for k in _GENISLETILMIS_KOLONLAR}}
    # Ayni "veri var mi" ayrimi burada da gerekli -- meal'deki HICBIR
    # tarif belirli bir besin ogesi icin veri tasimiyorsa, o ogenin
    # ogun toplami "0" degil None olmali (bkz. yukaridaki not).
    genisletilmis_var_mi = {k: False for k in _GENISLETILMIS_KOLONLAR}
    gi_agirlikli = 0.0
    gi_karb_toplam = 0.0
    tam_fiyatli = True
    eksik_malzemeler = set()
    alerjenler = set()
    for ad in tarif_adlari:
        b = detay.get(ad)
        if not b:
            continue
        toplam["kalori"] += b["kalori"]
        toplam["protein"] += b["protein"]
        toplam["yag"] += b["yag"]
        toplam["karbonhidrat"] += b["karbonhidrat"]
        toplam["maliyet_eur"] += b["maliyet_eur"]
        tam_fiyatli = tam_fiyatli and b["tam_fiyatli"]
        eksik_malzemeler |= b["eksik_malzemeler"]
        alerjenler |= b["alerjenler"]
        if b["gi"] is not None and b["karbonhidrat"] > 0:
            gi_agirlikli += b["gi"] * b["karbonhidrat"]
            gi_karb_toplam += b["karbonhidrat"]
        for kolon in _GENISLETILMIS_KOLONLAR:
            deger = b.get(kolon)
            if deger is not None:
                toplam[kolon] += deger
                genisletilmis_var_mi[kolon] = True
    for kolon in _GENISLETILMIS_KOLONLAR:
        if not genisletilmis_var_mi[kolon]:
            toplam[kolon] = None
    toplam["gi"] = round(gi_agirlikli / gi_karb_toplam) if gi_karb_toplam > 0 else None
    toplam["tam_fiyatli"] = tam_fiyatli
    toplam["eksik_malzemeler"] = eksik_malzemeler
    toplam["alerjenler"] = alerjenler
    return toplam


@st.cache_data(ttl=3600)
def _isletme_receteler_ve_detay_getir(isletme_id):
    """Isletmenin kendi ozel receteleri (1_Receteler.py'de olusturulan)
    -- Yillik Menu'ye ISTEGE BAGLI olarak eklenebilir (bkz. asagidaki
    'kendi menu' butonu). Kutuphane tarifleriyle AYNI sekle
    (ad/grup/mevsim_etiketi/etiketler/bolge + besin/maliyet detayi)
    donusturulur ki uretim_algoritmasi.py'ye hic dokunmadan ayni
    fonksiyona (hafta_olustur) verilebilsin.

    Kategori -> anayasa grubu eslesmesi (6 Agustos 2026, kullaniciyla
    netlestirildi):
      ana_yemek -> 1 (Ana Yemek), corba -> 2 (Yardimci Yemek),
      salata/tatli -> 3 (Tamamlayici),
      icecek/baslangic/pizza/burger -> 4 (ISTEGE BAGLI Fast Food yuvasi
      -- anayasa madde 8'in ZORUNLU 3'lusune DAHIL DEGIL, bkz.
      uretim_algoritmasi.py._fast_food_sec).

    Bolge: ozel receteler bolge bilgisi TASIMAZ ve bolge filtresinden
    MUAF tutulur (kullanicinin acik talebi, 6 Agustos 2026) -- "bolge"
    alani sentinel bir deger (__isletme__) tasir ama cagiran kod bunlari
    zaten bolge filtresi UYGULANDIKTAN SONRA havuza ekler, o yuzden bu
    deger hicbir filtrede kullanilmaz.

    Maliyet hesabi kutuphane fonksiyonuyla (_tarif_detaylarini_getir)
    AYNI dogrudan malzeme_guncel_fiyat yontemini kullanir (1_Receteler.py
    'deki recete_guncel_maliyet VIEW'inden FARKLI bir yol -- iki ayri
    yontemin sonucu ayni olmali ama bagimsiz olarak hesaplaniyor)."""
    KATEGORI_GRUP = {
        "ana_yemek": 1, "corba": 2, "salata": 3, "tatli": 3,
        "icecek": 4, "baslangic": 4, "pizza": 4, "burger": 4,
    }

    receteler = (
        supabase.table("receteler")
        .select("id, ad, kategori, porsiyon_sayisi")
        .eq("isletme_id", isletme_id)
        .execute()
    ).data or []
    if not receteler:
        return [], {}, False

    id_to_ad = {r["id"]: r["ad"] for r in receteler}
    porsiyon_by_id = {r["id"]: (r["porsiyon_sayisi"] or 1) for r in receteler}

    malzeme_kalemleri = (
        supabase.table("recete_malzemeleri")
        .select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(ad, kalori, protein, yag, karbonhidrat, glisemik_indeks, "
            + ", ".join(_GENISLETILMIS_KOLONLAR) + ")"
        )
        .in_("recete_id", list(id_to_ad.keys()))
        .execute()
    ).data or []

    alerjen_kayitlari = (
        supabase.table("malzeme_alerjen").select("malzeme_id, alerjenler(ad)").execute()
    ).data or []
    alerjen_by_malzeme = {}
    for kayit in alerjen_kayitlari:
        ad = (kayit.get("alerjenler") or {}).get("ad")
        if ad:
            alerjen_by_malzeme.setdefault(kayit["malzeme_id"], set()).add(ad)

    fiyat_kayitlari = (
        supabase.table("malzeme_guncel_fiyat")
        .select("malzeme_id, fiyat_eur")
        .eq("isletme_id", isletme_id)
        .execute()
    ).data or []
    fiyat_by_malzeme = {f["malzeme_id"]: f["fiyat_eur"] for f in fiyat_kayitlari}
    fiyat_verisi_var = len(fiyat_by_malzeme) > 0

    ham = {}
    for kalem in malzeme_kalemleri:
        recete_id = kalem["recete_id"]
        if recete_id not in id_to_ad:
            continue
        m = kalem.get("malzemeler") or {}
        oran = kalem["miktar_gram"] / 100.0
        girdi = ham.setdefault(
            recete_id, {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
                        "gi_agirlikli": 0.0, "gi_karb_toplam": 0.0, "maliyet_eur": 0.0,
                        "tam_fiyatli": True, "eksik_malzemeler": set(), "alerjenler": set(),
                        **{k: 0.0 for k in _GENISLETILMIS_KOLONLAR},
                        **{f"{k}_var_mi": False for k in _GENISLETILMIS_KOLONLAR}}
        )
        girdi["kalori"] += (m.get("kalori") or 0) * oran
        girdi["protein"] += (m.get("protein") or 0) * oran
        girdi["yag"] += (m.get("yag") or 0) * oran
        karb = (m.get("karbonhidrat") or 0) * oran
        girdi["karbonhidrat"] += karb
        gi = m.get("glisemik_indeks")
        if gi is not None and karb > 0:
            girdi["gi_agirlikli"] += gi * karb
            girdi["gi_karb_toplam"] += karb
        for kolon in _GENISLETILMIS_KOLONLAR:
            deger = m.get(kolon)
            if deger is not None:
                girdi[kolon] += deger * oran
                girdi[f"{kolon}_var_mi"] = True

        malzeme_id = kalem["malzeme_id"]
        fiyat = fiyat_by_malzeme.get(malzeme_id)
        if fiyat is None:
            girdi["tam_fiyatli"] = False
            malzeme_adi = m.get("ad")
            if malzeme_adi:
                girdi["eksik_malzemeler"].add(malzeme_adi)
        else:
            girdi["maliyet_eur"] += (kalem["miktar_gram"] / 1000.0) * fiyat
        girdi["alerjenler"] |= alerjen_by_malzeme.get(malzeme_id, set())

    tarif_listesi = []
    detay = {}
    for r in receteler:
        grup = KATEGORI_GRUP.get(r["kategori"])
        if grup is None:
            continue  # bilinmeyen/yeni bir kategori -- sessizce atla
        tarif_listesi.append({
            "ad": r["ad"], "grup": grup, "mevsim_etiketi": "yil_boyunca",
            "etiketler": [], "bolge": "__isletme__",
        })

        v = ham.get(r["id"])
        porsiyon = porsiyon_by_id[r["id"]]
        if v is None:
            detay[r["ad"]] = {
                "kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0, "gi": None,
                "maliyet_eur": 0.0, "tam_fiyatli": True, "eksik_malzemeler": set(), "alerjenler": set(),
                **{k: None for k in _GENISLETILMIS_KOLONLAR},
            }
            continue
        gi = (v["gi_agirlikli"] / v["gi_karb_toplam"]) if v["gi_karb_toplam"] > 0 else None
        detay[r["ad"]] = {
            "kalori": v["kalori"] / porsiyon, "protein": v["protein"] / porsiyon,
            "yag": v["yag"] / porsiyon, "karbonhidrat": v["karbonhidrat"] / porsiyon, "gi": gi,
            "maliyet_eur": v["maliyet_eur"] / porsiyon, "tam_fiyatli": v["tam_fiyatli"],
            "eksik_malzemeler": v["eksik_malzemeler"], "alerjenler": v["alerjenler"],
            **{k: (v[k] / porsiyon if v[f"{k}_var_mi"] else None) for k in _GENISLETILMIS_KOLONLAR},
        }

    return tarif_listesi, detay, fiyat_verisi_var


tarifler = _tarif_kutuphanesini_getir(mutfak_secimi["kod"])

if not tarifler:
    st.warning(
        "Global tarif kütüphanesi boş görünüyor. Önce `yukle_tarifler.py` "
        "ile 74 tarifin Supabase'e yüklendiğinden emin ol."
    )
    st.stop()

st.caption(f"Kütüphanede {len(tarifler)} tarif bulundu.")

KISA_BOLGE_ADI = {
    "Genel": "Klasik",
    "Doğu Anadolu": "Doğu",
    "Güneydoğu Anadolu": "Güneydoğu",
}

BOLGE_SIRASI = ["Marmara", "Ege", "Akdeniz", "Karadeniz", "İç Anadolu", "Doğu Anadolu", "Güneydoğu Anadolu"]
mevcut_diger_bolgeler = {t["bolge"] for t in tarifler} - {"Genel"}
diger_bolgeler = [b for b in BOLGE_SIRASI if b in mevcut_diger_bolgeler]
diger_bolgeler += sorted(mevcut_diger_bolgeler - set(BOLGE_SIRASI))  # BOLGE_SIRASI'nda olmayan yeni bolgeler sona eklenir
bolgeler_mevcut = (["Genel"] if any(t["bolge"] == "Genel" for t in tarifler) else []) + diger_bolgeler

if "secili_bolgeler_set" not in st.session_state:
    st.session_state.secili_bolgeler_set = set()  # bos = hicbir kisit yok, tumu kullanilir
if "kendi_menu_dahil" not in st.session_state:
    st.session_state.kendi_menu_dahil = False

isletme_bilgi = (
    supabase.table("isletmeler").select("ad").eq("id", st.session_state.isletme_id).single().execute()
).data
isletme_adi = (isletme_bilgi or {}).get("ad") or "Kendi Menüm"

st.markdown("**Bölge (mutfak)**")
st.caption(
    "Hiçbiri seçili değilken tüm bölgeler kullanılır. Bir bölgeye tıklamak "
    f"SADECE onu etkinleştirir. \"{isletme_adi}\" butonu, işletmenin kendi "
    "özel reçetelerini (bölge seçiminden bağımsız, her zaman) menüye dahil eder."
)
kolonlar = st.columns(len(bolgeler_mevcut) + 1)
for kolon, bolge in zip(kolonlar[:-1], bolgeler_mevcut):
    secili = bolge in st.session_state.secili_bolgeler_set
    etiket = KISA_BOLGE_ADI.get(bolge, bolge)
    if kolon.button(
        etiket, key=f"bolge_buton_{bolge}", use_container_width=True,
        type="primary" if secili else "secondary",
    ):
        if secili:
            st.session_state.secili_bolgeler_set.discard(bolge)
        else:
            st.session_state.secili_bolgeler_set.add(bolge)
        st.rerun()

with kolonlar[-1]:
    if st.button(
        isletme_adi, key="kendi_menu_buton", use_container_width=True,
        type="primary" if st.session_state.kendi_menu_dahil else "secondary",
    ):
        st.session_state.kendi_menu_dahil = not st.session_state.kendi_menu_dahil
        st.rerun()

secili_bolgeler = st.session_state.secili_bolgeler_set

if secili_bolgeler:
    tarifler = [t for t in tarifler if t["bolge"] in secili_bolgeler]
# secili_bolgeler bossa (hicbir buton tiklanmamissa) hicbir filtre uygulanmaz, tum bolgeler kullanilir

# "Kendi menum" -- BOLGE FILTRESI UYGULANDIKTAN SONRA, filtreden MUAF
# olarak havuza ekleniyor (kullanicinin acik talebi).
detay_ozel = {}
fiyat_ozel_var = False
if st.session_state.kendi_menu_dahil:
    ozel_tarifler, detay_ozel, fiyat_ozel_var = _isletme_receteler_ve_detay_getir(
        st.session_state.isletme_id
    )
    if not ozel_tarifler:
        st.caption(
            f"\"{isletme_adi}\" için henüz Ana Yemek/Çorba/Salata/Tatlı/"
            "İçecek/Başlangıç/Pizza/Burger kategorisinde bir reçete yok."
        )
    tarifler = tarifler + ozel_tarifler

if not tarifler:
    st.warning("Seçtiğin bölge(ler)de hiç tarif bulunamadı.")
    st.stop()

if secili_bolgeler:
    st.caption(f"Seçili bölge(ler)de {len(tarifler)} tarif kullanılacak.")
else:
    st.caption(f"Hiçbir bölge seçilmedi, tüm {len(tarifler)} tarif kullanılacak.")


detay, fiyat_verisi_var = _tarif_detaylarini_getir(st.session_state.isletme_id)
if detay_ozel:
    detay = {**detay, **detay_ozel}
    fiyat_verisi_var = fiyat_verisi_var or fiyat_ozel_var
if not fiyat_verisi_var:
    st.caption(
        "Bu işletme için henüz malzeme fiyatı girilmemiş — maliyet "
        "sütunu bu yüzden hesaplanamıyor (\"-\" gösterilecek)."
    )

# Uretim algoritmasi besin hedefi kontrolu icin HER alani (kalori/protein/
# yag/karbonhidrat/gi + 27 genisletilmis besin ogesi) tarife ekliyoruz
# (detay'dan -- zaten hesaplanmisti). Hangilerinin GERCEKTEN hedeflenecegi
# asagidaki multiselect ile secilir, ama _hedefte_mi kontrolunun her alana
# erisebilmesi icin hepsi burada tasiniyor.
tarifler_zengin = []
for t in tarifler:
    b = detay.get(t["ad"], {})
    t2 = dict(t)
    t2["kalori"] = b.get("kalori")
    t2["protein"] = b.get("protein")
    t2["yag"] = b.get("yag")
    t2["karbonhidrat"] = b.get("karbonhidrat")
    t2["gi"] = b.get("gi")
    for kolon in _GENISLETILMIS_KOLONLAR:
        t2[kolon] = b.get(kolon)
    tarifler_zengin.append(t2)

sol, sag, _bos = st.columns([1, 1, 3])
with sol:
    mevsim_secimi = st.selectbox("Mevsim", MEVSIMLER, format_func=lambda m: m.capitalize())
with sag:
    ay_secimi = st.selectbox("Ay", MEVSIM_AYLARI[mevsim_secimi])

besin_hedefi_kullan = st.checkbox("Öğün başına besin hedefi uygula (opsiyonel)")

hedefler = None
if besin_hedefi_kullan:
    st.caption(
        "Önce hangi besin değerlerini hedeflemek istediğini seç (kalori "
        "gibi temel değerler varsayılan olarak seçili) — sadece seçtiklerin "
        "için aşağıda min/maks aralığı gösterilecek."
    )
    secili_besin_anahtarlari = st.multiselect(
        "Hedeflenecek besin değerleri",
        options=[anahtar for anahtar, *_ in TUM_BESIN_ALANLARI],
        default=["kalori", "protein", "yag", "karbonhidrat", "gi"],
        format_func=lambda a: _BESIN_ETIKET[a],
        key="yillik_menu_secili_besin_anahtarlari",
    )
    hedefler = {}
    for ogun_adi in ("Öğle", "Akşam"):
        with st.expander(f"{ogun_adi} hedefleri", expanded=False):
            hedefler[ogun_adi] = {}
            if not secili_besin_anahtarlari:
                st.caption("Yukarıdan en az bir besin değeri seçmelisin.")
            for anahtar in secili_besin_anahtarlari:
                etiket = _BESIN_ETIKET[anahtar]
                # (float(...) burada bilinçli bir guvenlik agi: TUM_BESIN_ALANLARI'na
                # ileride eklenecek bir satirda min/maks/varsayilan turleri
                # yanlislikla karisik (int+float) yazilirsa bile, number_input
                # yine de tek tip float alacak -- StreamlitMixedNumericTypesError
                # bir daha tekrarlanmasin diye.)
                minv, maxv, def_alt, def_ust = (float(x) for x in _BESIN_ARALIK[anahtar])
                c1, c2 = st.columns(2)
                with c1:
                    alt = st.number_input(
                        f"{etiket} — min", min_value=minv, max_value=maxv,
                        value=def_alt, key=f"{ogun_adi}_{anahtar}_alt",
                    )
                with c2:
                    ust = st.number_input(
                        f"{etiket} — maks", min_value=minv, max_value=maxv,
                        value=def_ust, key=f"{ogun_adi}_{anahtar}_ust",
                    )
                hedefler[ogun_adi][anahtar] = (alt, ust)

if hedefler and secili_bolgeler and len(tarifler) < 60:
    st.caption(
        "Dikkat: dar bir bölge seçiliyken besin hedefi de uygularsan, küçük "
        "havuzda hedefe uyan tarif sayısı çok azalabilir ve menü tek bir "
        "yemeğe kilitlenebilir. Çeşitlilik azsa hedef aralığını genişletmeyi "
        "veya daha fazla bölge seçmeyi dene."
    )

if st.button("Ay için menü üret", type="primary"):
    ay_index = AYLAR_SIRALI.index(ay_secimi)
    haftalar = []
    for hafta_no in range(1, 5):
        tohum = ay_index * 10 + hafta_no  # deterministik: ayni ay+hafta = ayni sonuc
        rastgele = random.Random(tohum)
        haftalar.append(
            hafta_olustur(tarifler_zengin, mevsim_secimi, rastgele, hedefler=hedefler)
        )
    st.session_state["yillik_menu_aylik"] = {"ay": ay_secimi, "haftalar": haftalar}
    st.session_state["yillik_menu_hedefler"] = hedefler

RENKLER = {1: "#D85A30", 2: "#639922", 3: "#1D9E75"}


def _hedefte_mi(ogun_adi, t, hedefler):
    if not hedefler or ogun_adi not in hedefler:
        return None
    for anahtar, (alt, ust) in hedefler[ogun_adi].items():
        deger = t.get(anahtar)
        if deger is None:
            continue
        if not (alt <= deger <= ust):
            return False
    return True


BILGI_KUTU_YUKSEKLIK = 120  # tipik 3-4 kisa satir icin sikilastirilmis sabit


def _dish_kutu_yuksekligi_hesapla(tarif_adlari, karakter_basina_px=7, satir_yuksekligi=30, taban_px=12):
    """Bir gunun yemek adi listesi icin GERCEK metne dayali yukseklik tahmini
    -- global bir sabit (onceki 240px) yerine, o haftanin o ogunundeki EN
    UZUN gunun ihtiyacina gore hesaplaniyor. Boylece kisa listeli gunlerde
    bosluk kalmiyor, uzun listeli gunlerde de tasma olmuyor. Sutun genisligi
    ekrana gore degisebildigi icin bu yine de bir TAHMIN -- karakter_basina_px
    ve satir_yuksekligi degerleri tipik masaustu genisligi icin ayarlandi,
    cok dar/genis ekranlarda hafif sapma olabilir."""
    sutun_karakter_kapasitesi = 22  # tek satira sigan yaklasik karakter sayisi
    toplam = taban_px
    for ad in tarif_adlari:
        satir_sayisi = max(1, -(-len(ad) // sutun_karakter_kapasitesi))
        toplam += satir_yuksekligi * satir_sayisi
    return toplam


def _hafta_kartlarini_goster(hafta, detay, fiyat_verisi_var, hedefler, ay_adi, hafta_no):
    """Haftayi ekrana GERCEK Streamlit widget'lariyla render eder (ham HTML
    string DEGIL) -- boylece her yemek adi st.page_link ile Tarif
    Kutuphanesi'ne tiklanabilir olur (resmi/desteklenen navigasyon
    yontemi; ham <a href> linkleri Streamlit'te bilinen sekilde
    guvenilmezdir).

    NOT (5 Agustos 2026, besinci deneme): Sabit GLOBAL yukseklik (240px)
    her hafta/ogun icin ayni kaldigindan, kisa listeli gunlerde buyuk bir
    bosluk birakip yemek adiyla alt bilgi arasini gereksiz aciyordu.
    Bunun yerine her hafta+ogun SATIRI icin (ör. "1. Hafta - Ogle") o
    satirdaki 7 gunun GERCEK yemek adlarina bakip EN UZUN olana gore
    yukseklik hesaplaniyor (_dish_kutu_yuksekligi_hesapla) -- boylece kisa
    haftalarda kutu kucuk, uzun haftalarda buyuk oluyor, hep tam ihtiyaca
    gore. Kenarlik hala st.container(border=False) ile kapali."""
    # st.page_link varsayilan olarak metni tek satirda kirpiyor (uzun
    # tarif isimleri sigmayinca "..." ile kesiliyor) -- bunu alt satira
    # kaydiracak sekilde zorluyoruz.
    st.markdown(
        "<style>"
        "[data-testid='stPageLink'] p { white-space: normal !important; "
        "word-break: break-word !important; }"
        "</style>",
        unsafe_allow_html=True,
    )

    # Bu haftadaki her ogun (Ogle/Aksam) icin, 7 gunun en uzun yemek
    # listesine gore GEREKEN yukseklik -- render dongusunden ONCE, tek
    # seferde hesaplaniyor.
    ogun_adlari = list(hafta[0]["ogunler"].keys()) if hafta else []
    dish_yukseklikleri = {
        ogun_adi: max(
            _dish_kutu_yuksekligi_hesapla(gun["ogunler"][ogun_adi]) for gun in hafta
        )
        for ogun_adi in ogun_adlari
    }

    kolonlar = st.columns(len(hafta), gap="small")
    for kolon, gun in zip(kolonlar, hafta):
        with kolon:
            st.markdown(f"**Gün {gun['gun']}**")
            for i, (ogun_adi, tarif_adlari) in enumerate(gun["ogunler"].items()):
                if i > 0:
                    st.write("")
                    st.write("")
                st.markdown(f"**{ogun_adi.upper()}**")

                dish_key = f"dish-box-{ay_adi}-{hafta_no}-{gun['gun']}-{ogun_adi}"
                with st.container(height=dish_yukseklikleri[ogun_adi], border=False, key=dish_key):
                    for ad in tarif_adlari:
                        st.page_link(
                            "pages/5_Tarif_Kutuphanesi.py", label=ad,
                            query_params={"tarif": ad}, use_container_width=True,
                        )

                t = _ogun_toplami(tarif_adlari, detay)
                info_key = f"info-box-{ay_adi}-{hafta_no}-{gun['gun']}-{ogun_adi}"
                with st.container(height=BILGI_KUTU_YUKSEKLIK, border=False, key=info_key):
                    # ON SEKIZINCI DUZELTME (13 Agustos 2026, Oturum 11):
                    # kullanici besin/maliyet satirlarinin PASTEL degil
                    # BELIRGIN renklerle gosterilmesini istedi. Onceki hali
                    # st.caption(":blue[...]") kullaniyordu -- st.caption()
                    # Streamlit temasinda kucuk+SOLUK render edilen bir
                    # bilesen, ustune renk direktifi eklense bile hafif/
                    # pastel kaliyor. Simdi st.markdown + dogrudan HTML/CSS
                    # ile daha DOYGUN renkler ve YARI KALIN font kullanildi.
                    # Font-size bilerek caption'in yaklasik boyutuyla (0.8rem)
                    # AYNI tutuldu ve margin:0 verildi -- yoksa normal
                    # markdown paragraf boslugu, sabit 120px'lik kutuyu
                    # (BILGI_KUTU_YUKSEKLIK) tasirip ic kaydirma cubugu
                    # cikarabilirdi.
                    gi_metin = f"{round(t['gi'])}" if t["gi"] is not None else "-"
                    st.markdown(
                        "<div style='font-size:0.8rem; font-weight:600; "
                        "color:#0B5ED7; margin:0; line-height:1.35;'>"
                        f"{round(t['kalori'])} kcal · P{round(t['protein'])}g · "
                        f"Y{round(t['yag'])}g · K{round(t['karbonhidrat'])}g · "
                        f"Gİ{gi_metin}</div>",
                        unsafe_allow_html=True,
                    )
                    alerjen_metin = ", ".join(sorted(t["alerjenler"])) if t["alerjenler"] else "Yok"
                    st.markdown(
                        "<div style='font-size:0.8rem; font-weight:600; "
                        f"color:#0B5ED7; margin:0; line-height:1.35;'>Alerjen: {alerjen_metin}</div>",
                        unsafe_allow_html=True,
                    )

                    if not fiyat_verisi_var:
                        _maliyet_metin = "Maliyet: -"
                    elif t["tam_fiyatli"]:
                        _maliyet_metin = f"Maliyet: {t['maliyet_eur']:.2f} €"
                    else:
                        eksik_liste = ", ".join(sorted(t["eksik_malzemeler"]))
                        _maliyet_metin = f"Maliyet: ≈{t['maliyet_eur']:.2f} € (eksik fiyat: {eksik_liste})"
                    st.markdown(
                        "<div style='font-size:0.8rem; font-weight:600; "
                        f"color:#1B7A3D; margin:0; line-height:1.35;'>{_maliyet_metin}</div>",
                        unsafe_allow_html=True,
                    )

                    hedefte = _hedefte_mi(ogun_adi, t, hedefler)
                    if hedefte is True:
                        st.markdown(
                            "<div style='font-size:0.8rem; font-weight:600; "
                            "color:#1B7A3D; margin:0; line-height:1.35;'>Hedefte</div>",
                            unsafe_allow_html=True,
                        )
                    elif hedefte is False:
                        st.markdown(
                            "<div style='font-size:0.8rem; font-weight:600; "
                            "color:#D9720B; margin:0; line-height:1.35;'>Hedef dışı</div>",
                            unsafe_allow_html=True,
                        )


def _aylik_menu_excel_olustur(aylik, detay, fiyat_verisi_var, hedefler):
    """Aylık menüyü ekrandaki kart görünümüyle AYNI düzende Excel'e döker:
    her gün bir sütun, altında Öğle/Akşam blokları (yemekler + besin +
    alerjen + maliyet) aynı sırayla. Bir finansal model degil -- formul
    gerekmiyor, sadece ekrandakiyle bire bir eslesen bir gorunum."""
    wb = Workbook()
    ws = wb.active
    ws.title = "Yıllık Menü"

    yazi_tipi = "Arial"
    baslik_yazi = Font(name=yazi_tipi, bold=True, color="FFFFFF")
    baslik_dolgu = PatternFill(start_color="2C6B3C", end_color="2C6B3C", fill_type="solid")
    hafta_baslik_yazi = Font(name=yazi_tipi, bold=True, size=13)
    alan_yazi = Font(name=yazi_tipi, bold=True)
    normal_yazi = Font(name=yazi_tipi)
    RENK_ANA, RENK_YARDIMCI, RENK_TAMAMLAYICI, RENK_FAST_FOOD = "D85A30", "639922", "1D9E75", "BA7517"

    def oyun_bloguna_yaz(satir, ogun_adi, tarif_adlari, t, gun_kolonu):
        ws.cell(row=satir, column=1, value=ogun_adi).font = alan_yazi
        satir += 1
        # Yemek satirlari, o ogunde 4. (istege bagli Fast Food) tarif
        # var mi yok mu -- 6 Agustos 2026'da eklendi -- gore DINAMIK
        # olarak olusturuluyor. Sabit 3'lu bir liste kullanip
        # tarif_adlari[i] ile eslestirmek (eski kod), 4. tarif eklenince
        # onu sessizce Excel'den dusururdu.
        yemek_satirlari = [
            ("Ana Yemek", RENK_ANA), ("Yardımcı Yemek", RENK_YARDIMCI), ("Tamamlayıcı", RENK_TAMAMLAYICI),
        ]
        if len(tarif_adlari) >= 4:
            yemek_satirlari.append(("Fast Food", RENK_FAST_FOOD))
        yemek_sayisi = len(yemek_satirlari)

        alan_satirlari = yemek_satirlari + [
            ("Besin (kcal/P/Y/K/Gİ)", None), ("Alerjen", None), ("Maliyet", None),
        ]
        if hedefler:
            alan_satirlari.append(("Hedef Durumu", None))
        for i, (etiket, renk) in enumerate(alan_satirlari):
            hucre_etiket = ws.cell(row=satir, column=1, value=etiket)
            hucre_etiket.font = Font(name=yazi_tipi, color=renk) if renk else normal_yazi
            if i < yemek_sayisi:
                deger = tarif_adlari[i]
            elif etiket.startswith("Besin"):
                gi_deger = f"{round(t['gi'])}" if t["gi"] is not None else "-"
                deger = (
                    f"{round(t['kalori'])} kcal · P{round(t['protein'])}g · "
                    f"Y{round(t['yag'])}g · K{round(t['karbonhidrat'])}g · Gİ{gi_deger}"
                )
            elif etiket == "Alerjen":
                deger = ", ".join(sorted(t["alerjenler"])) if t["alerjenler"] else "Yok"
            elif etiket == "Hedef Durumu":
                hedefte = _hedefte_mi(ogun_adi, t, hedefler)
                deger = {True: "Hedefte", False: "Hedef dışı", None: "-"}[hedefte]
            else:  # Maliyet
                if not fiyat_verisi_var:
                    deger = "-"
                elif t["tam_fiyatli"]:
                    deger = f"{t['maliyet_eur']:.2f} €"
                else:
                    eksik_liste = ", ".join(sorted(t["eksik_malzemeler"]))
                    deger = f"≈{t['maliyet_eur']:.2f} € (eksik: {eksik_liste})"
            hucre = ws.cell(row=satir, column=gun_kolonu, value=deger)
            hucre.font = normal_yazi
            hucre.alignment = Alignment(wrap_text=True, vertical="top")
            satir += 1
        return satir

    satir = 1
    for hafta_no, hafta in enumerate(aylik["haftalar"], start=1):
        gun_sayisi = len(hafta)

        ws.cell(row=satir, column=1, value=f"{aylik['ay']} — {hafta_no}. Hafta").font = hafta_baslik_yazi
        satir += 1

        baslik_satiri = satir
        ws.cell(row=baslik_satiri, column=1, value="")
        for g in range(gun_sayisi):
            hucre = ws.cell(row=baslik_satiri, column=g + 2, value=f"Gün {g + 1}")
            hucre.font = baslik_yazi
            hucre.fill = baslik_dolgu
            hucre.alignment = Alignment(horizontal="center")
        satir += 1

        blok_baslangic = satir
        for g, gun in enumerate(hafta):
            gun_kolonu = g + 2
            s = blok_baslangic
            for ogun_adi, tarif_adlari in gun["ogunler"].items():
                t = _ogun_toplami(tarif_adlari, detay)
                s = oyun_bloguna_yaz(s, ogun_adi, tarif_adlari, t, gun_kolonu)
        satir = s + 1  # bir sonraki hafta bloğundan önce bos satir

    genislikler = [24] + [24] * 7
    for i, genislik in enumerate(genislikler, start=1):
        ws.column_dimensions[get_column_letter(i)].width = genislik

    tampon = io.BytesIO()
    wb.save(tampon)
    return tampon.getvalue()


aylik = st.session_state.get("yillik_menu_aylik")
if aylik:
    kayitli_hedefler = st.session_state.get("yillik_menu_hedefler")

    excel_verisi = _aylik_menu_excel_olustur(aylik, detay, fiyat_verisi_var, kayitli_hedefler)
    st.download_button(
        "Excel'e indir",
        data=excel_verisi,
        file_name=f"yillik_menu_{aylik['ay']}.xlsx",
        mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )

    fast_food_notasi = (
        "&nbsp;&nbsp;&nbsp;<span style='color:#BA7517;'>●</span> Fast Food"
        if st.session_state.get("kendi_menu_dahil") else ""
    )
    st.markdown(
        "<div style='font-size:13px; color:gray; margin:0.5rem 0 1rem;'>"
        "<span style='color:#D85A30;'>●</span> Ana Yemek&nbsp;&nbsp;&nbsp;"
        "<span style='color:#639922;'>●</span> Yardımcı Yemek&nbsp;&nbsp;&nbsp;"
        f"<span style='color:#1D9E75;'>●</span> Tamamlayıcılar{fast_food_notasi}</div>",
        unsafe_allow_html=True,
    )

    for i, hafta in enumerate(aylik["haftalar"], start=1):
        st.markdown(f"**{aylik['ay']} — {i}. Hafta**")
        _hafta_kartlarini_goster(hafta, detay, fiyat_verisi_var, kayitli_hedefler, aylik["ay"], i)
        st.divider()
