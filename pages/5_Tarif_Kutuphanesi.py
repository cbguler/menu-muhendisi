# pages/5_Tarif_Kutuphanesi.py
#
# Tarif Kutuphanesi: 241 tariflik genel Turk mutfagi kutuphanesini
# gozden gecirme, bolge/gruba gore filtreleme, bir tarif secip istenen
# porsiyon sayisina gore malzeme miktarlarini ve besin/maliyet
# degerlerini olceklenmis olarak gorme, ve (doldurulduysa) adim adim
# hazirlik talimatini okuma.
#
# NOT: Malzeme miktarlari (recete_malzemeleri.miktar_gram) 1 porsiyon
# baz alinarak tasarlandi -- porsiyon olcekleme sadece bu miktarlari ve
# besin/maliyet toplamlarini carpar. Glisemik indeks bir oran oldugu
# icin olceklenmez (porsiyon sayisindan bagimsizdir).

import streamlit as st

# NOT (12 Agustos 2026, Oturum 11): logo artik burada AYRICA gosterilmiyor -- app.py'deki ozel menu satirinin icine tasindi, orada zaten her sayfa gecisinde render ediliyor. Burada tekrar cagirmak cift logoya yol acardi.

from asama_ikonlari import tum_ikonlari_bul
from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Tarif Kütüphanesi", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Tarif Kütüphanesi")
st.caption(
    "241 tariflik genel Türk mutfağı kütüphanesindeki tarifleri gözden "
    "geçir, bir tarif seçip istediğin porsiyon sayısına göre malzeme "
    "miktarlarını ve besin/maliyet değerlerini gör. Hazırlık talimatları "
    "kademeli olarak ekleniyor -- henüz eklenmemiş tarifler için bunu "
    "ekranda göreceksin."
)


def _sayfalayarak_getir(sorgu_uret, sayfa_boyutu=1000):
    """Supabase/PostgREST, .range() belirtilmese bile sorgu basina
    varsayilan olarak en fazla 1000 satir donduruyor -- sinirin uzerindeki
    satirlar HATA VERMEDEN sessizce kesiliyor. Bu fonksiyon .range() ile
    sayfa sayfa cekip TUM satirlari birlestirir. `sorgu_uret`, her
    cagrildiginda henuz .range()/.execute() uygulanmamis YENI bir sorgu
    builder'i donduren bir fonksiyon olmali (ayni builder tekrar
    kullanilamiyor)."""
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
def _tarif_kutuphanesi_detayli_getir():
    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", "turk").single().execute()
    ).data
    mutfak_id = mutfak["id"]

    kategoriler = (
        supabase.table("mutfak_kategorileri")
        .select("id, sira")
        .eq("mutfak_id", mutfak_id)
        .execute()
    ).data
    grup_by_kategori = {k["id"]: k["sira"] for k in kategoriler}

    receteler = _sayfalayarak_getir(lambda: supabase.table("receteler")
        .select("id, ad, mutfak_kategori_id, mevsim_etiketi, ozel_etiketler, bolge, hazirlik_talimati")
        .is_("isletme_id", "null")
    )

    malzeme_kalemleri = _sayfalayarak_getir(lambda: supabase.table("recete_malzemeleri")
        .select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(ad, kalori, protein, yag, karbonhidrat, glisemik_indeks)"
        )
    )

    alerjen_kayitlari = _sayfalayarak_getir(
        lambda: supabase.table("malzeme_alerjen").select("malzeme_id, alerjenler(ad)")
    )
    alerjen_by_malzeme = {}
    for kayit in alerjen_kayitlari:
        ad = (kayit.get("alerjenler") or {}).get("ad")
        if ad:
            alerjen_by_malzeme.setdefault(kayit["malzeme_id"], set()).add(ad)

    isletme_id = st.session_state.isletme_id
    fiyat_kayitlari = _sayfalayarak_getir(lambda: supabase.table("malzeme_guncel_fiyat")
        .select("malzeme_id, fiyat_eur")
        .eq("isletme_id", isletme_id)
    )
    fiyat_by_malzeme = {f["malzeme_id"]: f["fiyat_eur"] for f in fiyat_kayitlari}
    fiyat_verisi_var = len(fiyat_by_malzeme) > 0

    malzemeler_by_recete = {}
    for kalem in malzeme_kalemleri:
        malzemeler_by_recete.setdefault(kalem["recete_id"], []).append(kalem)

    tarifler = []
    for r in receteler:
        grup = grup_by_kategori.get(r["mutfak_kategori_id"])
        if grup is None:
            continue

        kalori = protein = yag = karbonhidrat = maliyet_eur = 0.0
        gi_agirlikli = gi_karb_toplam = 0.0
        tam_fiyatli = True
        eksik_malzemeler = set()
        alerjenler = set()
        malzeme_listesi = []

        for kalem in malzemeler_by_recete.get(r["id"], []):
            m = kalem.get("malzemeler") or {}
            oran = kalem["miktar_gram"] / 100.0
            kalori += (m.get("kalori") or 0) * oran
            protein += (m.get("protein") or 0) * oran
            yag += (m.get("yag") or 0) * oran
            karb = (m.get("karbonhidrat") or 0) * oran
            karbonhidrat += karb
            gi = m.get("glisemik_indeks")
            if gi is not None and karb > 0:
                gi_agirlikli += gi * karb
                gi_karb_toplam += karb

            malzeme_id = kalem["malzeme_id"]
            fiyat = fiyat_by_malzeme.get(malzeme_id)
            if fiyat is None:
                tam_fiyatli = False
                if m.get("ad"):
                    eksik_malzemeler.add(m["ad"])
            else:
                maliyet_eur += (kalem["miktar_gram"] / 1000.0) * fiyat
            alerjenler |= alerjen_by_malzeme.get(malzeme_id, set())

            malzeme_listesi.append({"ad": m.get("ad") or "?", "miktar_gram": kalem["miktar_gram"]})

        gi = (gi_agirlikli / gi_karb_toplam) if gi_karb_toplam > 0 else None

        tarifler.append({
            "id": r["id"],
            "ad": r["ad"],
            "grup": grup,
            "bolge": r["bolge"] or "Genel",
            "mevsim_etiketi": r["mevsim_etiketi"] or "yil_boyunca",
            "hazirlik_talimati": r["hazirlik_talimati"],
            "malzemeler": sorted(malzeme_listesi, key=lambda x: -x["miktar_gram"]),
            "kalori": kalori, "protein": protein, "yag": yag, "karbonhidrat": karbonhidrat,
            "gi": gi, "maliyet_eur": maliyet_eur, "tam_fiyatli": tam_fiyatli,
            "eksik_malzemeler": eksik_malzemeler, "alerjenler": alerjenler,
        })

    return tarifler, fiyat_verisi_var


tarifler, fiyat_verisi_var = _tarif_kutuphanesi_detayli_getir()

GRUP_ADI = {1: "Ana Yemek", 2: "Yardımcı Yemek", 3: "Tamamlayıcı"}
KISA_BOLGE_ADI = {"Genel": "Klasik", "Doğu Anadolu": "Doğu", "Güneydoğu Anadolu": "Güneydoğu"}

sol, sag = st.columns(2)
with sol:
    bolgeler_mevcut = ["Tümü"] + sorted({t["bolge"] for t in tarifler})
    bolge_secimi = st.selectbox(
        "Bölge", bolgeler_mevcut, format_func=lambda b: KISA_BOLGE_ADI.get(b, b),
    )
with sag:
    grup_secimi = st.selectbox(
        "Grup", ["Tümü", 1, 2, 3], format_func=lambda g: "Tümü" if g == "Tümü" else GRUP_ADI[g],
    )

filtrelenmis = tarifler
if bolge_secimi != "Tümü":
    filtrelenmis = [t for t in filtrelenmis if t["bolge"] == bolge_secimi]
if grup_secimi != "Tümü":
    filtrelenmis = [t for t in filtrelenmis if t["grup"] == grup_secimi]

st.caption(f"{len(filtrelenmis)} tarif listeleniyor.")

if not filtrelenmis:
    st.warning("Bu filtrelerde tarif bulunamadı.")
    st.stop()

isimler_sirali = sorted(t["ad"] for t in filtrelenmis)
query_tarif = st.query_params.get("tarif")
varsayilan_index = isimler_sirali.index(query_tarif) if query_tarif in isimler_sirali else 0
secilen_ad = st.selectbox("Tarif", isimler_sirali, index=varsayilan_index)
tarif = next(t for t in filtrelenmis if t["ad"] == secilen_ad)

porsiyon = st.number_input("Porsiyon sayısı", min_value=1, max_value=200, value=10, step=1)

st.subheader(tarif["ad"])
st.caption(
    f"{GRUP_ADI[tarif['grup']]} · {KISA_BOLGE_ADI.get(tarif['bolge'], tarif['bolge'])} · "
    f"Mevsim: {tarif['mevsim_etiketi'].replace('_', ' ').capitalize()}"
)

sutun_malzeme, sutun_bilgi = st.columns([1, 1])

with sutun_malzeme:
    st.write(f"**Malzemeler ({porsiyon} porsiyon için)**")
    for m in tarif["malzemeler"]:
        st.write(f"- {m['ad']}: {round(m['miktar_gram'] * porsiyon)} g")

with sutun_bilgi:
    st.write("**Besin değerleri (toplam)**")
    st.write(f"{round(tarif['kalori'] * porsiyon)} kcal")
    st.write(
        f"Protein {round(tarif['protein'] * porsiyon)}g · "
        f"Yağ {round(tarif['yag'] * porsiyon)}g · "
        f"Karbonhidrat {round(tarif['karbonhidrat'] * porsiyon)}g"
    )
    gi_metin = f"{round(tarif['gi'])}" if tarif["gi"] is not None else "-"
    st.write(f"Glisemik İndeks: {gi_metin} (porsiyon sayısından bağımsız, bir orandır)")
    alerjen_metin = ", ".join(sorted(tarif["alerjenler"])) if tarif["alerjenler"] else "Yok"
    st.write(f"Alerjen: {alerjen_metin}")

    if fiyat_verisi_var and not tarif["tam_fiyatli"]:
        eksik_liste = ", ".join(sorted(tarif["eksik_malzemeler"]))
        st.caption(f"Eksik fiyat: {eksik_liste}")

@st.cache_data(ttl=3600)
def _uretim_asamalarini_getir(recete_id):
    asamalar = (
        supabase.table("recete_asamalari")
        .select("id, ad, sira, sure_dakika, aktif_dakika, isil_islem_mi, enerji_kaynagi, baslangic_sicaklik, hedef_sicaklik, verimlilik_orani")
        .eq("recete_id", recete_id)
        .order("sira")
        .execute()
    ).data
    if not asamalar:
        return []

    asama_malzeme_kayitlari = (
        supabase.table("asama_malzemeleri")
        .select("asama_id, recete_malzemeleri(miktar_gram, malzemeler(ozgul_isi))")
        .in_("asama_id", [a["id"] for a in asamalar])
        .execute()
    ).data

    for a in asamalar:
        a["isitilan_kutle_gram"] = sum(
            (k["recete_malzemeleri"] or {}).get("miktar_gram", 0)
            for k in asama_malzeme_kayitlari
            if k["asama_id"] == a["id"]
        )
        a["agirlikli_ozgul_isi"] = None
        kayitlar_bu_asama = [
            k for k in asama_malzeme_kayitlari
            if k["asama_id"] == a["id"] and k.get("recete_malzemeleri")
        ]
        if kayitlar_bu_asama and a["isitilan_kutle_gram"] > 0:
            toplam_ozgul_isi_agirlikli = sum(
                k["recete_malzemeleri"]["miktar_gram"]
                * ((k["recete_malzemeleri"].get("malzemeler") or {}).get("ozgul_isi") or 0)
                for k in kayitlar_bu_asama
            )
            a["agirlikli_ozgul_isi"] = toplam_ozgul_isi_agirlikli / a["isitilan_kutle_gram"]

    return asamalar


@st.cache_data(ttl=3600)
def _maliyet_ayarlarini_getir(isletme_id):
    sonuc = (
        supabase.table("isletme_maliyet_ayarlari")
        .select("*")
        .eq("isletme_id", isletme_id)
        .execute()
    ).data
    if sonuc:
        return sonuc[0]
    # Kayit yoksa varsayilan degerlerle (tabloya hic yazmadan, sadece
    # hesap icin) don -- kullanici Uretim Asamalari sayfasinda kendi
    # oranlarini girdiginde bu degerler otomatik guncel gelir.
    return {
        "elektrik_birim_fiyat_eur_kwh": 0.12,
        "dogalgaz_birim_fiyat_eur_kwh": 0.08,
        "personel_saat_ucreti_eur": 5.0,
        "genel_gider_yuzdesi": 15.0,
    }


def _gercek_maliyet_hesapla(asamalar, ayarlar, porsiyon):
    enerji_eur = 0.0
    iscilik_dk = 0.0
    for a in asamalar:
        iscilik_dk += a["aktif_dakika"] if a["aktif_dakika"] is not None else a["sure_dakika"]
        if a["isil_islem_mi"] and a["agirlikli_ozgul_isi"] and a["isitilan_kutle_gram"]:
            kutle = a["isitilan_kutle_gram"] * porsiyon  # 1 porsiyon baz -> istenen porsiyona olcekle
            delta_t = a["hedef_sicaklik"] - a["baslangic_sicaklik"]
            joule = kutle * a["agirlikli_ozgul_isi"] * delta_t
            kwh = joule / 3_600_000.0 / a["verimlilik_orani"]
            birim_fiyat = (
                ayarlar["elektrik_birim_fiyat_eur_kwh"] if a["enerji_kaynagi"] == "elektrik"
                else ayarlar["dogalgaz_birim_fiyat_eur_kwh"]
            )
            enerji_eur += kwh * birim_fiyat

    iscilik_eur = (iscilik_dk / 60.0) * ayarlar["personel_saat_ucreti_eur"]
    return enerji_eur, iscilik_eur


tarif_asamalari = _uretim_asamalarini_getir(tarif["id"])

st.write("**Gerçek üretim maliyeti (malzeme + enerji + işçilik)**")
if not tarif_asamalari:
    st.info(
        "Bu tarif için üretim aşaması (ısıl işlem/işçilik) verisi henüz "
        "eklenmedi — sadece malzeme maliyeti yukarıda gösteriliyor. "
        "Aşama verisi kademeli olarak ekleniyor."
    )
elif not fiyat_verisi_var or not tarif["tam_fiyatli"]:
    st.caption(
        "Malzeme fiyatı eksik olduğu için gerçek maliyet hesaplanamıyor "
        "(yukarıdaki eksik fiyat uyarısına bakın)."
    )
else:
    ayarlar = _maliyet_ayarlarini_getir(st.session_state.isletme_id)
    enerji_eur, iscilik_eur = _gercek_maliyet_hesapla(tarif_asamalari, ayarlar, porsiyon)
    malzeme_eur = tarif["maliyet_eur"] * porsiyon
    toplam_eur = malzeme_eur + enerji_eur + iscilik_eur

    m1, m2, m3, m4 = st.columns(4)
    for kolon, baslik, deger in (
        (m1, "Malzeme", malzeme_eur), (m2, "Enerji", enerji_eur),
        (m3, "İşçilik", iscilik_eur), (m4, f"Toplam ({porsiyon} p.)", toplam_eur),
    ):
        kolon.markdown(
            f"<div style='font-size:12px; color:gray;'>{baslik}</div>"
            f"<div style='font-size:20px; font-weight:600;'>{deger:.2f} €</div>",
            unsafe_allow_html=True,
        )
    st.caption(
        "Genel gider payı bu hesaba dahil değildir. İşçilik, her aşamanın "
        "\"aktif dakika\" değerini kullanır (girilmemişse aşamanın toplam "
        "süresiyle aynı sayılır) — uzun pasif süreçlerde (fırın, bekletme) "
        "bu ikisi kasıtlı olarak farklıdır. Enerji hesabı Q=m·c·ΔT (duyulur "
        "ısı) formülüne dayanır ve ekipmanın kendi ısınma/ısı kaybını "
        "hesaba katmaz — özellikle uzun ısıl işlemlerde gerçek değerin "
        "altında kalabilir."
    )

st.write("**Hazırlık talimatı**")
if tarif["hazirlik_talimati"]:
    # ELLI ALTINCI DUZELTME (30 Agustos 2026): kullanici "her madde
    # kendi ikonunun ustunde/altinda olsun, hepsi bastan toplu degil"
    # dedi -- hakliydi, oncekinde tum ikonlar metnin USTUNDE tek sirada
    # topluydu. Simdi metin SATIR SATIR isleniyor, her satirin (ör.
    # "1. Soğanı rendeleyin...") HEMEN ALTINA sadece O SATIRDA gecen
    # ikon(lar) ekleniyor -- bir satirda birden fazla teknik geciyorsa
    # ALTMIS IKINCI DUZELTME (30 Agustos 2026): kullanici birden fazla
    # ikon yan yana geldiginde aralarinin dar oldugunu ve alt kenarlarinin
    # hizasiz durdugunu belirtti (kaynagi: farkli gorsellerin dogal
    # en-boy oranlari farkli, ayni genislikte bile farkli yukseklikte
    # cikiyorlar). st.image()'in LISTE modu yerine, Streamlit'in
    # BELGELENMIS `gap` ve `vertical_alignment="bottom"` destegine sahip
    # st.columns() kullanildi -- CSS hack DEGIL, resmi API. Bir satirda
    # gercekci olarak en fazla birkac (2-4) ikon cikiyor (tum_ikonlari_bul
    # artik SATIR bazinda calisiyor, tum metin degil) -- bu yuzden
    # "Admin butonu" hatasindaki gibi asiri sikisma riski yok.
    for _satir in tarif["hazirlik_talimati"].splitlines():
        if _satir.strip():
            _satir_ikonlari = tum_ikonlari_bul(_satir)
            if _satir_ikonlari:
                _ikon_kolonlari = st.columns(
                    len(_satir_ikonlari), gap="medium", vertical_alignment="bottom"
                )
                for _kolon, _ikon_yolu in zip(_ikon_kolonlari, _satir_ikonlari):
                    with _kolon:
                        st.image(_ikon_yolu, width=260)
            st.write(_satir)
        else:
            st.write("")
else:
    st.info(
        "Bu tarif için adım adım hazırlık talimatı henüz eklenmedi. "
        "Talimatlar kademeli olarak ekleniyor."
    )
