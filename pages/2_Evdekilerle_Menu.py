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
#
# 14 Ekim 2026 (Bahri): (1) market fisi okutarak stok girisi, (2) kendi
# tarifini ekleme -- elle, metin yapistirarak ya da sosyal medya ekran
# goruntusuyle; kendi tarifleri menu havuzuna girer, (3) kurulan menude tarif
# degistirme. Fis ve tarif okuma ai_okuma.py (Groq) ile; okunan her sey
# kullaniciya tabloda gosterilir, onaylanmadan kaydedilmez.

import datetime
import random

import pandas as pd
import streamlit as st

from besin_sabitleri import TUM_BESIN_ALANLARI, BESIN_ETIKET, BESIN_ARALIK, kanonik_sirala
from db import get_supabase, oturumu_uygula
import ai_okuma as A
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
    return _tarifleri_tamamla(by_id, kalemler)


def _tarifleri_tamamla(by_id, kalemler):
    """by_id: {recete_id: tarif taslagi (_porsiyon, _malz, _gk, _kk ve besin alanlari)}.
    Malzeme kalemlerinden porsiyon basi malzeme listesi ve besin degerlerini doldurur."""
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


# Kendi tarif kategorisi -> anayasa grubu (0_Yillik_Menu.py ile ayni esleme;
# icecek/baslangic/pizza/burger bu sayfada kullanilmaz).
_KATEGORI_GRUP = {"ana_yemek": 1, "corba": 2, "salata": 3, "tatli": 3}


def _kendi_isletme_idleri():
    ana = st.session_state.get("ana_isletme_id")
    return [_ISLETME_ID] if not ana or ana == _ISLETME_ID else [_ISLETME_ID, ana]


@st.cache_data(ttl=3600)
def _kendi_tarifler_getir(isletme_idleri, surum=0, imza=""):
    """Isletmenin (ve subede ana isletmenin) kendi tarifleri, kutuphane tarifleriyle ayni sekilde.
    Donus: (tarifler, tarif_malzemeleri, tarif_aylari, tum_kayitlar)."""
    receteler = (
        supabase.table("receteler").select("id, ad, kategori, porsiyon_sayisi, uygun_aylar")
        .in_("isletme_id", list(isletme_idleri)).execute()
    ).data or []
    by_id = {}
    aylar = {}
    for r in receteler:
        grup = _KATEGORI_GRUP.get(r.get("kategori"))
        if grup is None:
            continue
        by_id[r["id"]] = {
            "ad": r["ad"], "grup": grup, "mevsim_etiketi": "yil_boyunca", "etiketler": [],
            "_porsiyon": r["porsiyon_sayisi"] or 1, "_malz": [], "_gk": 0.0, "_kk": 0.0,
            "kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
            **{k: None for k in _GENISLETILMIS},
        }
        aylar[r["ad"]] = set(r.get("uygun_aylar") or [])
    if not by_id:
        return [], {}, {}, receteler
    kalemler = _sayfalayarak_getir(
        lambda: supabase.table("recete_malzemeleri").select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(kalori, protein, yag, karbonhidrat, glisemik_indeks, " + ", ".join(_GENISLETILMIS) + ")"
        ).in_("recete_id", list(by_id.keys()))
    )
    tarifler, tarif_malzemeleri = _tarifleri_tamamla(by_id, kalemler)
    return tarifler, tarif_malzemeleri, {a: aylar[a] for a in tarif_malzemeleri}, receteler


def _groq_ayarlari():
    """(anahtar, model). Anahtar Streamlit Secrets'ta GROQ_API_KEY_IKON; yoksa None."""
    try:
        return st.secrets.get("GROQ_API_KEY_IKON"), st.secrets.get("GROQ_GORSEL_MODEL", A.VARSAYILAN_MODEL)
    except Exception:
        return None, A.VARSAYILAN_MODEL


def _stoga_ekle(mid, gram, mevcut):
    yeni = mevcut.get(mid, 0.0) + gram
    supabase.table("ev_stogu").upsert(
        {"isletme_id": _ISLETME_ID, "malzeme_id": mid, "miktar_gram": round(yeni, 1),
         "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()},
        on_conflict="isletme_id,malzeme_id",
    ).execute()
    mevcut[mid] = yeni
    return yeni


@st.cache_data(ttl=3600)
def _katalog_getir(imza=""):
    return _sayfalayarak_getir(
        lambda: supabase.table("malzemeler").select("id, ad, diger_adlar, yogunluk, mevsim, bozulma_suresi").order("ad")
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
# 1b) Market fisinden stok girisi (Groq goruntu okuma)
# ---------------------------------------------------------------------
_groq_anahtar, _groq_model = _groq_ayarlari()
katalog_adlari = [m["ad"] for m in katalog]

with st.expander("Market fişinden ekle", expanded=False):
    if not _groq_anahtar:
        st.info(
            "Fiş okuma için Groq anahtarının Streamlit Cloud Secrets ekranına GROQ_API_KEY_IKON adıyla "
            "eklenmesi gerekiyor."
        )
    st.caption(
        f"Fişin fotoğrafını yükle ya da yapıştır, veya kamerayla çek (en fazla {A.EN_FAZLA_GORSEL} fotoğraf; uzun fişi parça parça çekebilirsin). "
        "Fotoğraf okunmak için Groq'a gönderilir. Başka dildeki ürün adları Türkçeye çevrilip kataloğumuzdaki "
        "malzemeyle eşlenir. Gıda dışı ürünler atlanır. Okunan her satırı aşağıdaki tabloda kontrol et; "
        "sadece işaretlediklerin stoğa eklenir."
    )
    _fis_dosyalari = st.file_uploader(
        "Fiş fotoğrafı: \"Upload\" ile seç ya da kopyaladığın görseli yapıştırmak için bu alana tıklayıp Ctrl+V yap",
        type=["jpg", "jpeg", "png", "webp"], accept_multiple_files=True, key="fis_dosyalari",
    )
    _fis_kamera = st.camera_input("ya da kamerayla çek", key="fis_kamera") if st.toggle("Kamerayı aç", key="fis_kamera_ac") else None
    if st.button("Fişi oku", disabled=_SALT_OKUNUR or not _groq_anahtar):
        _veriler = [f.getvalue() for f in (_fis_dosyalari or [])][: A.EN_FAZLA_GORSEL]
        if _fis_kamera is not None and len(_veriler) < A.EN_FAZLA_GORSEL:
            _veriler.append(_fis_kamera.getvalue())
        if not _veriler:
            st.error("Önce bir fiş fotoğrafı yükle (ya da yapıştır) veya kamerayla çek.")
        else:
            try:
                with st.spinner("Fiş okunuyor..."):
                    _satirlar = A.fis_oku(_groq_anahtar, [A.gorseli_hazirla(v) for v in _veriler], katalog, _groq_model)
                st.session_state["fis_satirlari"] = _satirlar
                if not _satirlar:
                    st.warning("Fişte gıda ürünü bulunamadı. Daha net, düz ve iyi ışıklı bir fotoğrafla tekrar dene.")
            except A.OkumaHatasi as e:
                st.error(str(e))

    _fis = st.session_state.get("fis_satirlari")
    if _fis:
        _fis_df = pd.DataFrame([{
            "Ekle": bool(r["katalog_adi"] and r["gram"]),
            "Fişte yazan": r["fis_satiri"],
            "Ürün": r["urun"],
            "Malzeme": r["katalog_adi"],
            "Gram": r["gram"],
            "Tahmini": "evet" if r["tahmin"] else "",
        } for r in _fis])
        _fis_duzen = st.data_editor(
            _fis_df, hide_index=True, use_container_width=True, key="fis_tablosu",
            disabled=["Fişte yazan", "Ürün", "Tahmini"],
            column_config={
                "Malzeme": st.column_config.SelectboxColumn(options=katalog_adlari, help="Katalogdaki karşılığı"),
                "Gram": st.column_config.NumberColumn(min_value=0.0, step=10.0, format="%.0f"),
                "Tahmini": st.column_config.TextColumn(help="Miktar fişte yazmıyordu; paket boyutu tahmin edildi."),
            },
        )
        st.caption("\"Tahmini\" işaretli satırlarda miktar paket boyutundan tahmin edildi (TAHMİN); kontrol et.")
        f1, f2 = st.columns([1, 1])
        if f1.button("İşaretlileri stoğa ekle", type="primary", disabled=_SALT_OKUNUR):
            _eklenen, _atlanan = 0, 0
            try:
                for r in _fis_duzen.to_dict("records"):
                    if not r["Ekle"]:
                        continue
                    _mid = id_by_ad.get(r["Malzeme"])
                    if not _mid or not r["Gram"] or pd.isna(r["Gram"]) or r["Gram"] <= 0:
                        _atlanan += 1
                        continue
                    _stoga_ekle(_mid, float(r["Gram"]), stok)
                    _eklenen += 1
                st.session_state.pop("fis_satirlari", None)
                st.success(f"{_eklenen} ürün stoğa eklendi." + (f" {_atlanan} satır malzeme ya da miktar eksik olduğu için atlandı." if _atlanan else ""))
                st.rerun()
            except Exception as e:
                st.error(f"Kaydedilemedi: {e}")
        if f2.button("Okunanları temizle"):
            st.session_state.pop("fis_satirlari", None)
            st.rerun()

# ---------------------------------------------------------------------
# 2) Kendi tariflerin (elle / metin / sosyal medya ekran goruntusu)
# ---------------------------------------------------------------------
st.subheader("2. Kendi tariflerin")
_tarif_surum = st.session_state.get("ev_tarif_surum", 0)
kendi_tarifler, kendi_tarif_malzemeleri, kendi_tarif_aylari, _kendi_kayitlar = _kendi_tarifler_getir(
    tuple(_kendi_isletme_idleri()), surum=_tarif_surum, imza=_IMZA,
)
if kendi_tarifler:
    st.caption(
        f"Menüde kullanılabilecek {len(kendi_tarifler)} kendi tarifin var: "
        + ", ".join(sorted(t["ad"] for t in kendi_tarifler))
        + ". Düzenlemek ya da silmek için Reçete Üretimi sayfasını kullan."
    )
else:
    st.caption("Henüz kendi tarifin yok. Aşağıdan ekleyebilirsin; eklediğin tarifler menü kurulurken kullanılır.")

_recete_limiti = st.session_state.get("recete_limiti")
_tarif_limit_doldu = _recete_limiti is not None and len(_kendi_kayitlar) >= _recete_limiti

_BOS_TASLAK = {"ad": "", "kategori": "ana_yemek", "porsiyon": 4, "porsiyon_tahmin": False,
               "malzemeler": [], "talimat": ""}

with st.expander("Yeni tarif ekle", expanded=bool(st.session_state.get("ev_tarif_taslak"))):
    if _tarif_limit_doldu:
        st.warning(f"Planın {_recete_limiti} tarif ile sınırlı ve bu sınıra ulaştın.")
    st.caption(
        "Tarifi elle girebilir ya da bir metinden, sosyal medyada gördüğün bir paylaşımdan alabilirsin. "
        "Sosyal medya için paylaşımın açıklamasını kopyalayıp yapıştır ya da ekran görüntüsünü yükle "
        "(bağlantıdan okuma yapılmıyor: Instagram/TikTok sayfaları giriş istediği için güvenilir değil). "
        "Metin ve görseller okunmak için Groq'a gönderilir; başka dildeki tarifler Türkçeye çevrilir."
    )
    _okuma_metni = st.text_area("Tarif metni (isteğe bağlı)", key="tarif_metni", height=120)
    # Panodan yapistirma: Streamlit'in kendi yukleme alani yapistirmayi destekliyor (alana tiklayip
    # Ctrl+V). Panoyu bir DUGMEYLE okumak (Clipboard API) Streamlit Cloud'un ic ice cercevesinde
    # tarayici tarafindan engelleniyor -- 14 Ekim'de iki bilesen denendi, ikisi de olmadi.
    _tarif_gorselleri = st.file_uploader(
        f"Ekran görüntüsü (en fazla {A.EN_FAZLA_GORSEL}): \"Upload\" ile seç ya da kopyaladığın görseli yapıştırmak için "
        "bu alana tıklayıp Ctrl+V yap",
        type=["jpg", "jpeg", "png", "webp"], accept_multiple_files=True, key="tarif_gorselleri",
    )
    _tarif_gorsel_baytlari = [f.getvalue() for f in (_tarif_gorselleri or [])][: A.EN_FAZLA_GORSEL]
    o1, o2 = st.columns([1, 1])
    if o1.button("Metinden / görselden oku", disabled=_SALT_OKUNUR or not _groq_anahtar):
        if not (_okuma_metni or "").strip() and not _tarif_gorsel_baytlari:
            st.warning(
                "Okunacak bir şey yok. Önce yukarıdaki \"Tarif metni\" kutusuna tarifi yapıştır ya da "
                "\"Ekran görüntüsü\" alanına görseli yükle ya da alana tıklayıp Ctrl+V ile yapıştır, sonra bu düğmeye bas."
            )
        else:
            try:
                with st.spinner("Tarif okunuyor..."):
                    _okunan = A.tarif_oku(
                        _groq_anahtar, _okuma_metni,
                        [A.gorseli_hazirla(b) for b in _tarif_gorsel_baytlari],
                        katalog, _groq_model,
                    )
                st.session_state["ev_tarif_taslak"] = _okunan
                st.session_state["ev_tarif_taslak_surum"] = st.session_state.get("ev_tarif_taslak_surum", 0) + 1
                st.rerun()
            except A.OkumaHatasi as e:
                st.error(str(e))
    if o2.button("Elle boş tarif başlat"):
        st.session_state["ev_tarif_taslak"] = dict(_BOS_TASLAK)
        st.session_state["ev_tarif_taslak_surum"] = st.session_state.get("ev_tarif_taslak_surum", 0) + 1
        st.rerun()
    if not _groq_anahtar:
        st.caption("Metinden/görselden okuma için Groq anahtarı (GROQ_API_KEY_IKON) gerekiyor; elle giriş her zaman çalışır.")

    _taslak = st.session_state.get("ev_tarif_taslak")
    if _taslak:
        _ts = st.session_state.get("ev_tarif_taslak_surum", 0)
        st.divider()
        st.markdown("**Tarifi kontrol et ve kaydet**")
        d1, d2, d3, d4 = st.columns([3, 2, 1, 1])
        _t_ad = d1.text_input("Tarif adı", value=_taslak["ad"], key=f"tt_ad_{_ts}")
        _t_kat = d2.selectbox(
            "Kategori", list(A.KATEGORILER), index=list(A.KATEGORILER).index(_taslak["kategori"]),
            format_func=lambda k: A.KATEGORILER[k], key=f"tt_kat_{_ts}",
        )
        _t_porsiyon = d3.number_input("Kaç kişilik", min_value=1, max_value=50, value=int(_taslak["porsiyon"]), key=f"tt_por_{_ts}")
        _t_sure = d4.number_input("Süre (dk)", min_value=0, max_value=1440, value=30, step=5, key=f"tt_sure_{_ts}")
        if _taslak.get("porsiyon_tahmin"):
            st.caption("Kişi sayısı tarifte yazmıyordu; tahmin edildi (TAHMİN), kontrol et.")
        _t_aylar = st.multiselect(
            "Sunulabilir aylar (boş = her ay)", E.AYLAR, key=f"tt_ay_{_ts}",
        )
        _malz_df = pd.DataFrame(
            [{"Tarifte yazan": m.get("metin", ""), "Malzeme": m.get("katalog_adi"), "Gram (toplam)": m.get("gram"),
              "Tahmini": "evet" if m.get("tahmin") else ""} for m in _taslak["malzemeler"]]
            or [{"Tarifte yazan": "", "Malzeme": None, "Gram (toplam)": None, "Tahmini": ""}]
        )
        _malz_duzen = st.data_editor(
            _malz_df, hide_index=True, use_container_width=True, num_rows="dynamic", key=f"tt_malz_{_ts}",
            column_config={
                "Malzeme": st.column_config.SelectboxColumn(options=katalog_adlari, help="Katalogdaki karşılığı"),
                "Gram (toplam)": st.column_config.NumberColumn(
                    min_value=0.0, step=5.0, format="%.0f", help="Tarifin tamamı için (kişi sayısı kadar) gram"),
                "Tahmini": st.column_config.TextColumn(disabled=True),
            },
        )
        st.caption(
            "Malzemesi boş kalan satırlar (katalogda karşılığı bulunamayanlar) kaydedilmez; listeden seçebilirsin. "
            "\"Tahmini\" satırlarda ölçü grama tahminen çevrildi (TAHMİN)."
        )
        _t_talimat = st.text_area("Hazırlanışı", value=_taslak.get("talimat", ""), height=160, key=f"tt_tal_{_ts}")
        k1, k2 = st.columns([1, 1])
        if k1.button("Tarifi kaydet", type="primary", disabled=_SALT_OKUNUR or _tarif_limit_doldu):
            _kalemler = []
            for r in _malz_duzen.to_dict("records"):
                _mid = id_by_ad.get(r.get("Malzeme"))
                _g = r.get("Gram (toplam)")
                if _mid and _g is not None and not pd.isna(_g) and float(_g) > 0:
                    _kalemler.append((_mid, float(_g)))
            if not _t_ad.strip():
                st.error("Tarif adı boş olamaz.")
            elif not _kalemler:
                st.error("En az bir malzeme (katalogdan seçilmiş ve gramı girilmiş) gerekli.")
            else:
                try:
                    _kisaltma = ((supabase.table("isletmeler").select("kisaltma").eq("id", _ISLETME_ID)
                                  .single().execute().data or {}).get("kisaltma") or "").strip()
                    _kayit_adi = f"{_t_ad.strip()} ({_kisaltma})" if _kisaltma else _t_ad.strip()
                    # Recete Uretimi ile tutarli: kendi tarifler 10 porsiyon olarak saklanir
                    # (miktarlar 10 / kisi sayisi ile olceklenir).
                    _olcek = 10.0 / float(_t_porsiyon)
                    _birlesik = {}
                    for _mid, _g in _kalemler:
                        _birlesik[_mid] = _birlesik.get(_mid, 0.0) + _g * _olcek
                    _yeni = supabase.table("receteler").insert({
                        "isletme_id": _ISLETME_ID, "ad": _kayit_adi, "kategori": _t_kat,
                        "porsiyon_sayisi": 10, "hazirlik_dakika": int(_t_sure), "uygun_aylar": _t_aylar,
                        "hazirlik_talimati": _t_talimat.strip() or None,
                    }).execute().data[0]
                    try:
                        supabase.table("recete_malzemeleri").insert([
                            {"recete_id": _yeni["id"], "malzeme_id": _mid, "miktar_gram": round(_g, 2)}
                            for _mid, _g in _birlesik.items()
                        ]).execute()
                    except Exception:
                        supabase.table("receteler").delete().eq("id", _yeni["id"]).execute()
                        raise
                    st.session_state.pop("ev_tarif_taslak", None)
                    st.session_state["ev_tarif_surum"] = _tarif_surum + 1
                    st.success(f"'{_kayit_adi}' kaydedildi ({len(_birlesik)} malzeme). Menü kurulurken kullanılacak.")
                    st.rerun()
                except Exception as e:
                    st.error(f"Kaydedilemedi: {e}")
        if k2.button("Vazgeç"):
            st.session_state.pop("ev_tarif_taslak", None)
            st.rerun()

def _havuzu_kur(kendi_dahil):
    """Kutuphane + (istenirse) kendi tarifler. Ad cakisirsa kendi tarife " (kendi)" eklenir.
    Donus: (tarifler, tarif_malzemeleri, tarif_aylari)."""
    tarifler, tarif_malzemeleri = _kutuphane_getir(imza=_IMZA)
    tarifler, tarif_malzemeleri, aylar = list(tarifler), dict(tarif_malzemeleri), {}
    if kendi_dahil:
        for t in kendi_tarifler:
            ad = t["ad"] if t["ad"] not in tarif_malzemeleri else f"{t['ad']} (kendi)"
            tarifler.append(dict(t, ad=ad))
            tarif_malzemeleri[ad] = kendi_tarif_malzemeleri[t["ad"]]
            aylar[ad] = kendi_tarif_aylari.get(t["ad"], set())
    return tarifler, tarif_malzemeleri, aylar


# ---------------------------------------------------------------------
# 3) Ayarlar
# ---------------------------------------------------------------------
st.subheader("3. Menü ayarları")
ayar = _ayarlar_getir()

a1, a2, a3, a4 = st.columns(4)
porsiyon = a1.number_input("Kişi (porsiyon) sayısı", min_value=1, max_value=10, value=int(ayar.get("porsiyon", 3)))
_ogun_kodlari = list(E.OGUN_SECENEKLERI.keys())
ogun_kodu = a2.selectbox(
    "Öğün", _ogun_kodlari,
    index=_ogun_kodlari.index(ayar.get("ogun")) if ayar.get("ogun") in _ogun_kodlari else 0,
    format_func=lambda k: {"iki": "2 öğün (Öğle + Akşam)", "ogle": "Sadece Öğle", "aksam": "Sadece Akşam"}[k],
)
gun_sayisi = a3.number_input("Gün sayısı", min_value=1, max_value=7, value=int(ayar.get("gun", 7)))
baslangic = a4.date_input("Başlangıç günü", value=datetime.date.today(), format="DD.MM.YYYY")

t1, t2 = st.columns(2)
with t1:
    _TARIF_SAYISI = {
        2: "Öğünde 2 tarif (ana yemek + yan yemek)",
        3: "Öğünde 3 tarif (ana yemek + yan yemek + tamamlayıcı)",
    }
    tarif_sayisi = st.radio(
        "Öğündeki tarif sayısı", [2, 3], index=0 if ayar.get("iki_tarif") else 1,
        format_func=lambda k: _TARIF_SAYISI[k],
    )
    iki_tarif = tarif_sayisi == 2
with t2:
    kendi_kullan = st.checkbox(
        "Kendi tariflerimi de kullan", value=bool(ayar.get("kendi_tarifler", True)),
        help="Kendi eklediğin tarifler kütüphane tarifleriyle birlikte menüye girebilir.",
    )
    mevsim_kontrolu = st.checkbox(
        "Malzemenin mevsimini dikkate al", value=bool(ayar.get("mevsim_kontrolu", True)),
        help="Menünün o günkü mevsiminde bulunmayan TAZE bir malzemeyi (ör. kışın taze fasulye, yazın hamsi) "
        "isteyen tarif önerilmez. Kontrol sadece taze ürünlere (raf ömrü 30 gün ve altı) uygulanır; bakliyat, "
        "tahıl, baharat, kuruyemiş gibi yıl boyu bulunan ürünler kısıtlanmaz. Evdeki malzemeler, temel "
        "malzemeler ve katalogda mevsimi girilmemiş malzemeler de muaftır.",
    )

temel_adlar_katalog = [a for a in E.TEMEL_MALZEMELER if a in id_by_ad]
haric = set(ayar.get("temel_haric") or [])
temel_secili = st.multiselect(
    "Evde var kabul edilen temel malzemeler (alışveriş listesine girmez)",
    temel_adlar_katalog, default=[a for a in temel_adlar_katalog if a not in haric],
)
temel_idler = {id_by_ad[a] for a in temel_secili}

# ---------------------------------------------------------------------
# 2b) Besin Degerleri Hedefi (Aylik Menu'deki bolumle ayni alanlar)
# ---------------------------------------------------------------------
ogunler = E.OGUN_SECENEKLERI[ogun_kodu]
profiller = [p for p in _profiller_getir() if p.get("hedefler")]


def _hedefleri_yukle(hedef_sozlugu):
    """Bir hedef sozlugunu ({ogun: {anahtar: [alt, ust]}}) ekrandaki kutulara yazar."""
    anahtarlar = {a for o in (hedef_sozlugu or {}).values() for a in o}
    st.session_state["ev_hedef_anahtarlari"] = kanonik_sirala(anahtarlar) if anahtarlar else \
        ["kalori", "protein", "yag", "karbonhidrat", "gi"]
    for ogun_adi in ("Öğle", "Akşam"):
        for anahtar, *_ in TUM_BESIN_ALANLARI:
            st.session_state.pop(f"ev_{ogun_adi}_{anahtar}_alt", None)
            st.session_state.pop(f"ev_{ogun_adi}_{anahtar}_ust", None)
    for ogun_adi, degerler in (hedef_sozlugu or {}).items():
        for anahtar, aralik in degerler.items():
            if anahtar not in BESIN_ARALIK:
                continue
            _min, _max = float(BESIN_ARALIK[anahtar][0]), float(BESIN_ARALIK[anahtar][1])
            st.session_state[f"ev_{ogun_adi}_{anahtar}_alt"] = min(max(float(aralik[0]), _min), _max)
            st.session_state[f"ev_{ogun_adi}_{anahtar}_ust"] = min(max(float(aralik[1]), _min), _max)


# Ilk acilista: kayitli kendi hedefleri; yoksa "EV" profili; yoksa varsayilan araliklar.
# Not: Streamlit, sayfadan cikildiginda widget anahtarlarini siler; anahtar yoksa
# kayitli ayarlardan yeniden yuklenir.
if "ev_hedef_kullan" not in st.session_state:
    _ev_profili = next((p for p in profiller if p["ad"].strip().upper() == "EV"), None)
    _baslangic_hedef = ayar.get("hedefler") or (_ev_profili or {}).get("hedefler")
    st.session_state["ev_hedef_kullan"] = bool(ayar.get("hedef_kullan", _baslangic_hedef is not None))
    _hedefleri_yukle(_baslangic_hedef)

hedefler = None
with st.container(border=True):
    st.markdown("#### Besin Değerleri Hedefi")
    hedef_kullan = st.checkbox("**Öğün başına besin değerleri hedefi uygula (opsiyonel)**", key="ev_hedef_kullan")
    if hedef_kullan:
        if profiller:
            p1, p2 = st.columns([3, 1])
            _yuklenecek = p1.selectbox(
                "Porsiyon profilinden hedef yükle", [p["id"] for p in profiller],
                format_func=lambda i: next(p["ad"] for p in profiller if p["id"] == i),
                help="Abonelik sayfasındaki \"Profil Başına Besin Hedefleri\" bölümünde kaydettiğin hedefler.",
            )
            p2.write("")
            p2.write("")
            if p2.button("Yükle", use_container_width=True):
                _hedefleri_yukle(next(p["hedefler"] for p in profiller if p["id"] == _yuklenecek))
                st.rerun()
        st.caption(
            "Önce hangi besin değerlerini hedeflemek istediğini seç; sadece seçtiklerin için min/maks aralığı "
            "gösterilir. Öncelik besin hedefindedir: evdeki malzemeler, hedefi tutturan seçenekler arasında "
            "karar verir."
        )
        secili_anahtarlar = st.multiselect(
            "Hedeflenecek besin değerleri", options=[a for a, *_ in TUM_BESIN_ALANLARI],
            format_func=lambda a: BESIN_ETIKET[a], key="ev_hedef_anahtarlari",
        )
        hedefler = {}
        for ogun_adi in ogunler:
            with st.expander(f"{ogun_adi} hedefleri", expanded=False):
                hedefler[ogun_adi] = {}
                if not secili_anahtarlar:
                    st.caption("Yukarıdan en az bir besin değeri seçmelisin.")
                for anahtar in secili_anahtarlar:
                    etiket = BESIN_ETIKET[anahtar]
                    minv, maxv, def_alt, def_ust = (float(x) for x in BESIN_ARALIK[anahtar])
                    c1, c2 = st.columns(2)
                    _k_alt, _k_ust = f"ev_{ogun_adi}_{anahtar}_alt", f"ev_{ogun_adi}_{anahtar}_ust"
                    # Anahtar session_state'te varsa value verilmez (Streamlit uyarisini onler).
                    alt = c1.number_input(f"{etiket} — min", min_value=minv, max_value=maxv, key=_k_alt,
                                          **({} if _k_alt in st.session_state else {"value": def_alt}))
                    ust = c2.number_input(f"{etiket} — maks", min_value=minv, max_value=maxv, key=_k_ust,
                                          **({} if _k_ust in st.session_state else {"value": def_ust}))
                    hedefler[ogun_adi][anahtar] = (alt, ust)
        if iki_tarif:
            st.caption(
                "Not: 2 tarifli öğünde hedefleri 3 tarife göre girdiysen tutmayabilir; o öğünlerde hedefe en yakın "
                "seçenek alınır ve evdeki malzemeler o öğünde dikkate alınmaz."
            )

# ---------------------------------------------------------------------
# 3) Menu kur
# ---------------------------------------------------------------------
if st.button("Menüyü oluştur", type="primary", disabled=_SALT_OKUNUR):
    yeni_ayar = {
        "porsiyon": int(porsiyon), "ogun": ogun_kodu, "gun": int(gun_sayisi), "iki_tarif": bool(iki_tarif),
        "mevsim_kontrolu": bool(mevsim_kontrolu), "kendi_tarifler": bool(kendi_kullan),
        "hedef_kullan": bool(hedef_kullan),
        "hedefler": {o: {a: [float(v[0]), float(v[1])] for a, v in h.items()} for o, h in (hedefler or {}).items()}
        or ayar.get("hedefler"),
        "temel_haric": [a for a in temel_adlar_katalog if a not in temel_secili],
    }
    try:
        supabase.table("isletmeler").update({"ev_menu_ayarlari": yeni_ayar}).eq("id", _ISLETME_ID).execute()
    except Exception:
        pass  # ayar kaydi basarisiz olsa da menu kurulur
    tarifler, tarif_malzemeleri, tarif_aylari = _havuzu_kur(bool(kendi_kullan))
    tarihler = [baslangic + datetime.timedelta(days=i) for i in range(int(gun_sayisi))]
    cubuk = st.progress(0.0, text="Menü kuruluyor...")
    _toplam_adim = len(tarihler) * len(ogunler)
    _sayac = [0]

    def _ilerle():
        _sayac[0] += 1
        cubuk.progress(min(_sayac[0] / _toplam_adim, 1.0), text=f"Menü kuruluyor... {_sayac[0]}/{_toplam_adim} öğün")

    malzeme_mevsim = (
        E.malzeme_mevsim_haritasi(katalog) if mevsim_kontrolu else None
    )
    sonuc = E.menu_olustur(
        tarifler, tarif_malzemeleri, stok, int(porsiyon), ogunler,
        [E.tarih_mevsimi(t) for t in tarihler], bool(iki_tarif), hedefler,
        random.Random(), temel_idler, ilerleme=_ilerle, malzeme_mevsim=malzeme_mevsim,
        gun_aylari=[E.AYLAR[t.month - 1] for t in tarihler], tarif_aylari=tarif_aylari,
    )
    cubuk.empty()
    st.session_state["ev_menu_sonuc"] = {
        "sonuc": sonuc, "tarihler": tarihler, "baslangic_stok": dict(stok), "porsiyon": int(porsiyon),
        "tarif_sayisi": len(tarifler), "kendi_kullan": bool(kendi_kullan),
        "temel_idler": set(temel_idler), "iki_tarif": bool(iki_tarif),
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
    _mevsim_disi = sonuc.get("mevsim_disi_gun") or {}
    if _mevsim_disi:
        st.caption(
            f"Malzeme mevsimi kontrolü: günün mevsiminde bulunmayan malzeme istediği için "
            f"{min(_mevsim_disi.values())}-{max(_mevsim_disi.values())} tarif (toplam {kayit.get('tarif_sayisi', '?')} içinden) "
            "o günlerde önerilmedi."
        )
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

    # Elle duzenleme (14 Ekim 2026): bir gunun tariflerini kutuphaneden ya da kendi
    # tariflerinden degistir; stok, alisveris listesi ve rapor yeniden hesaplanir.
    with st.expander("Menüyü düzenle (tarif değiştir)", expanded=False):
        _havuz_t, _havuz_m, _ = _havuzu_kur(kayit.get("kendi_kullan", True))
        _grup_by_ad = {t["ad"]: t["grup"] for t in _havuz_t}
        _adlar_by_grup = {}
        for _t in _havuz_t:
            _adlar_by_grup.setdefault(_t["grup"], []).append(_t["ad"])
        for _l in _adlar_by_grup.values():
            _l.sort()
        _GRUP_ADI = {1: "Ana yemek", 2: "Yan yemek", 3: "Tamamlayıcı"}
        _surum = kayit.get("surum", 0)
        st.caption(
            "Değiştirmek istediğin günü seç, tarifleri listeden değiştir (yazarak arayabilirsin) ve uygula. "
            "Elle yapılan seçimde kural, mevsim ve besin hedefi kontrolü yapılmaz; evdeki malzeme hesabı ve "
            "alışveriş listesi yeniden hesaplanır."
        )
        _gun_idx = st.selectbox(
            "Gün", list(range(len(sonuc["gunler"]))), key=f"duz_gun_{_surum}",
            format_func=lambda i: f"{kayit['tarihler'][i].strftime('%d.%m.%Y')} {_GUNLER[kayit['tarihler'][i].weekday()]}",
        )
        _gun = sonuc["gunler"][_gun_idx]
        _yeni_gun = {}
        for _kolon, (_ogun_adi, _o) in zip(st.columns(len(_gun["ogunler"])), _gun["ogunler"].items()):
            with _kolon:
                st.markdown(f"*{_ogun_adi}*")
                _secimler = []
                for _j, _ad in enumerate(_o["tarifler"]):
                    _grup = _grup_by_ad.get(_ad, 1)
                    _secenek = _adlar_by_grup.get(_grup, [])
                    if _ad not in _secenek:
                        _secenek = [_ad] + _secenek
                    _secimler.append(st.selectbox(
                        _GRUP_ADI.get(_grup, "Tarif"), _secenek, index=_secenek.index(_ad),
                        key=f"duz_{_surum}_{_gun_idx}_{_ogun_adi}_{_j}",
                    ))
                _yeni_gun[_ogun_adi] = _secimler
        if st.button("Değişikliği uygula", disabled=_SALT_OKUNUR):
            _gt = [{o: v["tarifler"] for o, v in g["ogunler"].items()} for g in sonuc["gunler"]]
            _gt[_gun_idx] = _yeni_gun
            _r = E.menuyu_yeniden_hesapla(
                _gt, _havuz_m, kayit["baslangic_stok"], kayit["porsiyon"], kayit.get("temel_idler", set()),
            )
            _r["mevsim_disi_gun"] = sonuc.get("mevsim_disi_gun")
            kayit["sonuc"] = _r
            kayit["surum"] = _surum + 1
            st.rerun()

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
