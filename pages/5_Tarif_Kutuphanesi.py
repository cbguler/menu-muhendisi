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

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Tarif Kütüphanesi", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

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

    receteler = (
        supabase.table("receteler")
        .select("id, ad, mutfak_kategori_id, mevsim_etiketi, ozel_etiketler, bolge, hazirlik_talimati")
        .is_("isletme_id", "null")
        .execute()
    ).data

    malzeme_kalemleri = (
        supabase.table("recete_malzemeleri")
        .select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(ad, kalori, protein, yag, karbonhidrat, glisemik_indeks)"
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

    isletme_id = st.session_state.isletme_id
    fiyat_kayitlari = (
        supabase.table("malzeme_guncel_fiyat")
        .select("malzeme_id, fiyat_eur")
        .eq("isletme_id", isletme_id)
        .execute()
    ).data
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
secilen_ad = st.selectbox("Tarif", isimler_sirali)
tarif = next(t for t in filtrelenmis if t["ad"] == secilen_ad)

porsiyon = st.number_input("Porsiyon sayısı", min_value=1, max_value=200, value=1, step=1)

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

    if not fiyat_verisi_var:
        st.write("Maliyet: -")
    elif tarif["tam_fiyatli"]:
        st.write(f"Maliyet: {tarif['maliyet_eur'] * porsiyon:.2f} €")
    else:
        eksik_liste = ", ".join(sorted(tarif["eksik_malzemeler"]))
        st.write(f"Maliyet: ≈{tarif['maliyet_eur'] * porsiyon:.2f} € (eksik fiyat: {eksik_liste})")

st.write("**Hazırlık talimatı**")
if tarif["hazirlik_talimati"]:
    st.write(tarif["hazirlik_talimati"])
else:
    st.info(
        "Bu tarif için adım adım hazırlık talimatı henüz eklenmedi. "
        "Talimatlar kademeli olarak ekleniyor."
    )
