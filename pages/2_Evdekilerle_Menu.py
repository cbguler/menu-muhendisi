# pages/2_Evdekilerle_Menu.py
#
# "Evdekilerle Menu" (13 Ekim 2026; oneri: Efe Turkoglu; tasarim:
# ev_stok_menu_tasarim_v3.md; altyapi: sql/194). Kullanici evdeki
# malzemeleri ve miktarlarini girer; sistem bunlari ONCE kullanan bir
# haftalik menu kurar, eksikleri "Alman gerekenler" listesi olarak verir.
# Hesap mantigi ev_menu.py'de (Streamlit'ten bagimsiz).
#
# Erisim: sadece isletme sahibi ve sadece hizmet acikken (isletmeler.
# ev_menu_hizmeti = true). Navigasyona app.py ekler; burada da ayrica kontrol.

import datetime
import random

import pandas as pd
import streamlit as st

from besin_sabitleri import TUM_BESIN_ALANLARI
from db import get_supabase, oturumu_uygula
import ev_menu as E

st.set_page_config(page_title="Evdekilerle Menü", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

if not st.session_state.get("patron_mu"):
    st.error("Bu sayfa sadece işletme sahibine açık.")
    st.stop()
if not st.session_state.get("ev_menu_hizmeti"):
    st.info("Evdekilerle Menü hizmeti kapalı. Abonelik sayfasından açabilirsin.")
    st.stop()

_IMZA = st.session_state.get("onbellek_imzasi", "")
_ISLETME_ID = st.session_state.isletme_id
_SALT_OKUNUR = st.session_state.get("salt_okunur", False)
_GENISLETILMIS = [a for a, *_ in TUM_BESIN_ALANLARI if a not in ("kalori", "protein", "yag", "karbonhidrat", "gi")]


def _sayfalayarak_getir(sorgu_uret, sayfa_boyutu=1000):
    """PostgREST sorgu basina en fazla 1000 satir doner; sayfalayarak hepsini al."""
    tumu = []
    offset = 0
    while True:
        sayfa = sorgu_uret().range(offset, offset + sayfa_boyutu - 1).execute().data
        tumu.extend(sayfa)
        if len(sayfa) < sayfa_boyutu:
            break
        offset += sayfa_boyutu
    return tumu


@st.cache_data(ttl=3600)
def _kutuphane_getir(imza=""):
    """Kutuphane (isletme_id NULL) tarifleri: motorun bekledigi sekil + porsiyon
    basi malzeme listesi. miktar_gram tarifin KENDI porsiyon_sayisi icindir
    (bkz. 5_Tarif_Kutuphanesi.py notu) -- porsiyon basina bolunur."""
    mutfak = supabase.table("mutfaklar").select("id").eq("kod", "turk").single().execute().data
    kategoriler = (
        supabase.table("mutfak_kategorileri").select("id, sira").eq("mutfak_id", mutfak["id"]).execute()
    ).data
    grup_by_kategori = {k["id"]: k["sira"] for k in kategoriler}
    receteler = _sayfalayarak_getir(
        lambda: supabase.table("receteler")
        .select("id, ad, mutfak_kategori_id, mevsim_etiketi, ozel_etiketler, porsiyon_sayisi")
        .is_("isletme_id", "null")
    )
    kalemler = _sayfalayarak_getir(
        lambda: supabase.table("recete_malzemeleri").select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(kalori, protein, yag, karbonhidrat, glisemik_indeks, " + ", ".join(_GENISLETILMIS) + ")"
        )
    )
    by_id = {}
    for r in receteler:
        grup = grup_by_kategori.get(r["mutfak_kategori_id"])
        if grup not in (1, 2, 3):
            continue
        by_id[r["id"]] = {
            "ad": r["ad"], "grup": grup,
            "mevsim_etiketi": r["mevsim_etiketi"] or "yil_boyunca",
            "etiketler": r["ozel_etiketler"] or [],
            "_porsiyon": r["porsiyon_sayisi"] or 1,
            "_malz": [], "_gk": 0.0, "_kk": 0.0,
            "kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
            **{k: None for k in _GENISLETILMIS},
        }
    for k in kalemler:
        t = by_id.get(k["recete_id"])
        if t is None:
            continue
        g = (k["miktar_gram"] or 0) / t["_porsiyon"]
        t["_malz"].append((k["malzeme_id"], g))
        m = k.get("malzemeler") or {}
        oran = g / 100.0
        for a in ("kalori", "protein", "yag"):
            t[a] += (m.get(a) or 0) * oran
        karb = (m.get("karbonhidrat") or 0) * oran
        t["karbonhidrat"] += karb
        if m.get("glisemik_indeks") is not None and karb > 0:
            t["_gk"] += m["glisemik_indeks"] * karb
            t["_kk"] += karb
        for a in _GENISLETILMIS:
            if m.get(a) is not None:
                t[a] = (t[a] or 0.0) + m[a] * oran
    tarifler, tarif_malzemeleri = [], {}
    for t in by_id.values():
        if not t["_malz"]:
            continue
        t["gi"] = (t["_gk"] / t["_kk"]) if t["_kk"] > 0 else None
        tarif_malzemeleri[t["ad"]] = t["_malz"]
        tarifler.append({k: v for k, v in t.items() if not k.startswith("_")})
    return tarifler, tarif_malzemeleri


@st.cache_data(ttl=3600)
def _katalog_getir(imza=""):
    return _sayfalayarak_getir(
        lambda: supabase.table("malzemeler").select("id, ad, diger_adlar, yogunluk").order("ad")
    )


def _stok_getir():
    satirlar = supabase.table("ev_stogu").select("malzeme_id, miktar_gram").eq("isletme_id", _ISLETME_ID).execute().data
    return {s["malzeme_id"]: float(s["miktar_gram"]) for s in satirlar}


def _ayarlar_getir():
    satir = supabase.table("isletmeler").select("ev_menu_ayarlari").eq("id", _ISLETME_ID).single().execute().data
    return (satir or {}).get("ev_menu_ayarlari") or {}


def _profiller_getir():
    return (
        supabase.table("isletme_porsiyon_profilleri").select("id, ad, hedefler")
        .eq("isletme_id", _ISLETME_ID).order("sira").execute()
    ).data or []


katalog = _katalog_getir(imza=_IMZA)
malzeme_by_id = {m["id"]: m for m in katalog}
id_by_ad = {}
for m in katalog:
    id_by_ad.setdefault(m["ad"], m["id"])

st.title("Evdekilerle Menü")
st.caption(
    "Evdeki malzemeleri ve miktarlarını gir; sistem bunları önce kullanan bir menü kursun. "
    "Stok yetmeyen yerler için sonunda kısa bir alışveriş listesi çıkar."
)
if _SALT_OKUNUR:
    st.info("Hesabın admin onayı bekliyor; onaylanana kadar bu sayfada değişiklik yapamazsın.")

# ---------------------------------------------------------------------
# 1) Stok
# ---------------------------------------------------------------------
st.subheader("1. Evdeki malzemeler")
stok = _stok_getir()


def _malzeme_etiketi(mid):
    m = malzeme_by_id.get(mid) or {}
    diger = [d for d in (m.get("diger_adlar") or []) if d]
    return f"{m.get('ad', '?')} ({', '.join(diger)})" if diger else m.get("ad", "?")


with st.form("stok_ekle", clear_on_submit=True):
    c1, c2, c3, c4 = st.columns([3, 1, 1, 1])
    secilen_mid = c1.selectbox(
        "Malzeme (yazarak ara)", [m["id"] for m in katalog], index=None,
        format_func=_malzeme_etiketi, placeholder="ör. kıyma, soğan, nohut",
    )
    miktar = c2.number_input("Miktar", min_value=0.0, value=0.0, step=1.0)
    birim = c3.selectbox("Birim", ["g", "kg", "adet", "ml", "l"])
    c4.write("")
    c4.write("")
    ekle = c4.form_submit_button("Ekle", disabled=_SALT_OKUNUR, use_container_width=True)
    st.caption(
        "Adet karşılıkları (TAHMİN, ortalama): "
        + ", ".join(f"{a.lower()} {g:.0f} g" for a, g in E.ADET_GRAM.items())
        + ". Bunların dışındaki malzemeleri gram ya da kg ile gir. ml/l sadece yoğunluğu bilinen malzemelerde çalışır."
    )
    if ekle:
        if not secilen_mid:
            st.error("Bir malzeme seç.")
        else:
            try:
                gram = E.miktari_grama_cevir(miktar, birim, malzeme_by_id[secilen_mid])
                yeni = stok.get(secilen_mid, 0.0) + gram
                supabase.table("ev_stogu").upsert(
                    {"isletme_id": _ISLETME_ID, "malzeme_id": secilen_mid, "miktar_gram": round(yeni, 1),
                     "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()},
                    on_conflict="isletme_id,malzeme_id",
                ).execute()
                st.success(f"{malzeme_by_id[secilen_mid]['ad']}: {E.gram_yazisi(gram)} eklendi (toplam {E.gram_yazisi(yeni)}).")
                st.rerun()
            except ValueError as e:
                st.error(str(e))
            except Exception as e:
                st.error(f"Kaydedilemedi: {e}")

if stok:
    satirlar = sorted(
        ({"malzeme_id": mid, "Malzeme": (malzeme_by_id.get(mid) or {}).get("ad", "?"),
          "Miktar (g)": round(g, 1), "Sil": False} for mid, g in stok.items()),
        key=lambda r: r["Malzeme"],
    )
    duzenlenen = st.data_editor(
        pd.DataFrame(satirlar), hide_index=True, use_container_width=True, disabled=["Malzeme"] if not _SALT_OKUNUR else True,
        column_order=["Malzeme", "Miktar (g)", "Sil"], key="stok_tablosu",
        column_config={"Miktar (g)": st.column_config.NumberColumn(min_value=0.0, step=10.0, format="%.0f")},
    )
    s1, s2 = st.columns([1, 3])
    if s1.button("Değişiklikleri kaydet", disabled=_SALT_OKUNUR):
        try:
            for eski, yeni in zip(satirlar, duzenlenen.to_dict("records")):
                mid = eski["malzeme_id"]
                if yeni["Sil"] or not yeni["Miktar (g)"]:
                    supabase.table("ev_stogu").delete().eq("isletme_id", _ISLETME_ID).eq("malzeme_id", mid).execute()
                elif abs(float(yeni["Miktar (g)"]) - eski["Miktar (g)"]) > 1e-6:
                    supabase.table("ev_stogu").update(
                        {"miktar_gram": float(yeni["Miktar (g)"]),
                         "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()}
                    ).eq("isletme_id", _ISLETME_ID).eq("malzeme_id", mid).execute()
            st.success("Kaydedildi.")
            st.rerun()
        except Exception as e:
            st.error(f"Kaydedilemedi: {e}")
    s2.caption(f"Toplam {len(stok)} kalem, {E.gram_yazisi(sum(stok.values()))}.")
else:
    st.info("Henüz malzeme girmedin. Yukarıdan ekleyebilirsin; boş stokla da menü kurulur, o zaman her şey alışveriş listesine düşer.")

# ---------------------------------------------------------------------
# 2) Ayarlar
# ---------------------------------------------------------------------
st.subheader("2. Menü ayarları")
ayar = _ayarlar_getir()
profiller = [p for p in _profiller_getir() if p.get("hedefler")]
_HEDEF_YOK = "__hedef_yok__"
profil_secenekleri = [p["id"] for p in profiller] + [_HEDEF_YOK]
varsayilan_profil = ayar.get("hedef_profil_id")
if varsayilan_profil not in profil_secenekleri:
    ev_profili = next((p["id"] for p in profiller if p["ad"].strip().upper() == "EV"), None)
    varsayilan_profil = ev_profili or _HEDEF_YOK
_profil_adi = {p["id"]: p["ad"] for p in profiller}
_profil_adi[_HEDEF_YOK] = "Besin hedefi kullanma"

a1, a2, a3 = st.columns(3)
porsiyon = a1.number_input("Kişi (porsiyon) sayısı", min_value=1, max_value=10, value=int(ayar.get("porsiyon", 3)))
ogun_kodu = a2.selectbox(
    "Öğün", list(E.OGUN_SECENEKLERI.keys()),
    index=list(E.OGUN_SECENEKLERI.keys()).index(ayar.get("ogun", "iki")) if ayar.get("ogun", "iki") in E.OGUN_SECENEKLERI else 0,
    format_func=lambda k: {"iki": "2 öğün (Öğle + Akşam)", "ogle": "Sadece Öğle", "aksam": "Sadece Akşam"}[k],
)
gun_sayisi = a3.number_input("Gün sayısı", min_value=1, max_value=7, value=int(ayar.get("gun", 7)))
b1, b2, b3 = st.columns(3)
baslangic = b1.date_input("Başlangıç günü", value=datetime.date.today(), format="DD.MM.YYYY")
hedef_profil = b2.selectbox(
    "Besin hedefi", profil_secenekleri, index=profil_secenekleri.index(varsayilan_profil),
    format_func=lambda k: _profil_adi[k],
    help="Porsiyon profillerine kaydettiğin besin hedefleri (Abonelik sayfası). Öncelik besin hedefindedir; "
    "stok, hedefi tutturan seçenekler arasında karar verir.",
)
b3.write("")
iki_tarif = b3.checkbox(
    "Öğünde 2 tarif (ana yemek + yan yemek)", value=bool(ayar.get("iki_tarif", False)),
    help="İşaretsizse her öğün 3 tariften oluşur (ana yemek, yan yemek, tamamlayıcı).",
)
if iki_tarif and hedef_profil != _HEDEF_YOK:
    st.caption(
        "Not: besin hedefleri 3 tariflik öğüne göre girildiyse 2 tarifte tutmayabilir; o öğünlerde "
        "hedefe en yakın seçenek alınır ve stok o öğünde dikkate alınmaz."
    )

temel_adlar_katalog = [a for a in E.TEMEL_MALZEMELER if a in id_by_ad]
haric = set(ayar.get("temel_haric") or [])
temel_secili = st.multiselect(
    "Evde var kabul edilen temel malzemeler (alışveriş listesine girmez)",
    temel_adlar_katalog, default=[a for a in temel_adlar_katalog if a not in haric],
)
temel_idler = {id_by_ad[a] for a in temel_secili}

# ---------------------------------------------------------------------
# 3) Menu kur
# ---------------------------------------------------------------------
if st.button("Menüyü oluştur", type="primary", disabled=_SALT_OKUNUR):
    yeni_ayar = {
        "porsiyon": int(porsiyon), "ogun": ogun_kodu, "gun": int(gun_sayisi), "iki_tarif": bool(iki_tarif),
        "hedef_profil_id": hedef_profil if hedef_profil != _HEDEF_YOK else None,
        "temel_haric": [a for a in temel_adlar_katalog if a not in temel_secili],
    }
    try:
        supabase.table("isletmeler").update({"ev_menu_ayarlari": yeni_ayar}).eq("id", _ISLETME_ID).execute()
    except Exception:
        pass  # ayar kaydi basarisiz olsa da menu kurulur
    tarifler, tarif_malzemeleri = _kutuphane_getir(imza=_IMZA)
    hedefler = None
    if hedef_profil != _HEDEF_YOK:
        hedefler = next(p["hedefler"] for p in profiller if p["id"] == hedef_profil)
    ogunler = E.OGUN_SECENEKLERI[ogun_kodu]
    tarihler = [baslangic + datetime.timedelta(days=i) for i in range(int(gun_sayisi))]
    cubuk = st.progress(0.0, text="Menü kuruluyor...")
    _toplam_adim = len(tarihler) * len(ogunler)
    _sayac = [0]

    def _ilerle():
        _sayac[0] += 1
        cubuk.progress(min(_sayac[0] / _toplam_adim, 1.0), text=f"Menü kuruluyor... {_sayac[0]}/{_toplam_adim} öğün")

    sonuc = E.menu_olustur(
        tarifler, tarif_malzemeleri, stok, int(porsiyon), ogunler,
        [E.tarih_mevsimi(t) for t in tarihler], bool(iki_tarif), hedefler,
        random.Random(), temel_idler, ilerleme=_ilerle,
    )
    cubuk.empty()
    st.session_state["ev_menu_sonuc"] = {
        "sonuc": sonuc, "tarihler": tarihler, "baslangic_stok": dict(stok), "porsiyon": int(porsiyon),
    }

# ---------------------------------------------------------------------
# 4) Sonuc
# ---------------------------------------------------------------------
kayit = st.session_state.get("ev_menu_sonuc")
if kayit:
    sonuc = kayit["sonuc"]
    _GUNLER = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    st.divider()
    st.subheader(f"Menü ({kayit['porsiyon']} kişilik)")
    for gun, tarih in zip(sonuc["gunler"], kayit["tarihler"]):
        with st.container(border=True):
            st.markdown(f"**{tarih.strftime('%d.%m.%Y')} {_GUNLER[tarih.weekday()]}**")
            sutunlar = st.columns(len(gun["ogunler"]))
            for sutun, (ogun_adi, o) in zip(sutunlar, gun["ogunler"].items()):
                with sutun:
                    st.markdown(f"*{ogun_adi}*")
                    for ad in o["tarifler"]:
                        st.markdown(f"- {ad}")
                    if o["stoktan_yuzde"] is not None:
                        st.caption(f"Evdeki malzemeden karşılanan: %{o['stoktan_yuzde']:.0f}")

    st.subheader("Alman gerekenler")
    if sonuc["eksik"]:
        liste = sorted(
            ({"Malzeme": (malzeme_by_id.get(mid) or {}).get("ad", "?"),
              "Gereken": E.gram_yazisi(g),
              "Önerilen alım": E.gram_yazisi(E.pratik_miktar(g))} for mid, g in sonuc["eksik"].items()),
            key=lambda r: r["Malzeme"],
        )
        st.dataframe(liste, hide_index=True, use_container_width=True)
        st.caption(
            "Temel malzemeler (yukarıda seçtiklerin) listeye girmez. Miktarlar tarif gramlarıdır; "
            "soyma/ayıklama firesi henüz eklenmedi, kabuklu ya da kemikli ürünlerde biraz fazla almak gerekebilir."
        )
    else:
        st.success("Evdeki malzemeler bu menü için yetiyor; alman gereken bir şey yok.")

    st.subheader("Stok raporu")
    bas = kayit["baslangic_stok"]
    if bas:
        rapor = sorted(
            ({"Malzeme": (malzeme_by_id.get(mid) or {}).get("ad", "?"),
              "Evde olan": E.gram_yazisi(g),
              "Kullanılan": E.gram_yazisi(sonuc["kullanilan"].get(mid, 0.0)),
              "Kalan": E.gram_yazisi(sonuc["kalan"].get(mid, 0.0))} for mid, g in bas.items()),
            key=lambda r: r["Malzeme"],
        )
        st.dataframe(rapor, hide_index=True, use_container_width=True)
        kullanilmayan = sorted(
            (malzeme_by_id.get(mid) or {}).get("ad", "?") for mid in bas if sonuc["kullanilan"].get(mid, 0.0) <= 0
        )
        if kullanilmayan:
            st.caption("Bu menüde değerlendirilemeyenler: " + ", ".join(kullanilmayan))
        st.caption("Stok kaydın değişmedi; bu rapor sadece bu menüye göre bir hesaptır.")
    else:
        st.caption("Stok boş olduğu için rapor yok.")
