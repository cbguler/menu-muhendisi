# pages/5_Yillik_Menu.py
#
# Yillik Menu Uretim Motoru (ilk surum): global tarif kutuphanesinden
# (receteler, isletme_id NULL) anayasa kurallarina uygun ornek haftalik
# menu uretir. Henuz eklenmeyenler: kisisel_beslenme_profili filtrelemesi,
# menu_takvimi/menu_takvimi_ogeleri'ne yazma (sadece ekranda gosteriyor).

import random

import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula
from uretim_algoritmasi import MEVSIMLER, hafta_olustur

st.set_page_config(page_title="Yıllık Menü", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Yıllık Menü Üretim Motoru")
st.caption(
    "Türk mutfağı tarif kütüphanesinden, anayasa kurallarına uygun "
    "(madde 8, 11, 13) örnek haftalık menü üretir. İlk sürüm — kişisel "
    "beslenme profili filtrelemesi ve takvime kaydetme henüz eklenmedi."
)


@st.cache_data(ttl=3600)
def _tarif_kutuphanesini_getir():
    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", "turk").single().execute()
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
        .select("ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi")
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
            }
        )
    return tarifler


@st.cache_data(ttl=3600)
def _besin_degerlerini_getir():
    """Global tariflerin porsiyon basi toplam besin degerlerini hesaplar
    (recete_malzemeleri + malzemeler uzerinden). Glisemik indeks,
    karbonhidrat katkisina gore agirlikli ortalama olarak hesaplanir."""
    receteler = (
        supabase.table("receteler").select("id, ad").is_("isletme_id", "null").execute()
    ).data
    id_to_ad = {r["id"]: r["ad"] for r in receteler}

    malzeme_kalemleri = (
        supabase.table("recete_malzemeleri")
        .select(
            "recete_id, miktar_gram, "
            "malzemeler(kalori, protein, yag, karbonhidrat, glisemik_indeks)"
        )
        .execute()
    ).data

    ham = {}
    for kalem in malzeme_kalemleri:
        ad = id_to_ad.get(kalem["recete_id"])
        if ad is None:
            continue  # baska bir isletmeye ait ozel tarif olabilir, atla
        m = kalem.get("malzemeler") or {}
        oran = kalem["miktar_gram"] / 100.0
        girdi = ham.setdefault(
            ad, {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
                 "gi_agirlikli": 0.0, "gi_karb_toplam": 0.0}
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

    sonuc = {}
    for ad, v in ham.items():
        gi = (v["gi_agirlikli"] / v["gi_karb_toplam"]) if v["gi_karb_toplam"] > 0 else None
        sonuc[ad] = {
            "kalori": v["kalori"], "protein": v["protein"],
            "yag": v["yag"], "karbonhidrat": v["karbonhidrat"], "gi": gi,
        }
    return sonuc


def _gun_toplami(gun, besin):
    toplam = {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0}
    gi_agirlikli = 0.0
    gi_karb_toplam = 0.0
    for tarif_adlari in gun["ogunler"].values():
        for ad in tarif_adlari:
            b = besin.get(ad)
            if not b:
                continue
            toplam["kalori"] += b["kalori"]
            toplam["protein"] += b["protein"]
            toplam["yag"] += b["yag"]
            toplam["karbonhidrat"] += b["karbonhidrat"]
            if b["gi"] is not None and b["karbonhidrat"] > 0:
                gi_agirlikli += b["gi"] * b["karbonhidrat"]
                gi_karb_toplam += b["karbonhidrat"]
    toplam["gi"] = round(gi_agirlikli / gi_karb_toplam) if gi_karb_toplam > 0 else None
    return toplam


tarifler = _tarif_kutuphanesini_getir()

if not tarifler:
    st.warning(
        "Global tarif kütüphanesi boş görünüyor. Önce `yukle_tarifler.py` "
        "ile 74 tarifin Supabase'e yüklendiğinden emin ol."
    )
    st.stop()

st.caption(f"Kütüphanede {len(tarifler)} tarif bulundu.")

sol, sag = st.columns([1, 1])
with sol:
    mevsim_secimi = st.selectbox("Mevsim", MEVSIMLER, format_func=lambda m: m.capitalize())
with sag:
    tohum = st.number_input("Rastgelelik tohumu (aynı sayı = aynı sonuç)", value=42, step=1)

if st.button("Örnek hafta üret", type="primary"):
    rastgele = random.Random(int(tohum))
    st.session_state["yillik_menu_hafta"] = hafta_olustur(tarifler, mevsim_secimi, rastgele)

hafta = st.session_state.get("yillik_menu_hafta")
if hafta:
    besin = _besin_degerlerini_getir()
    RENKLER = {1: "#D85A30", 2: "#639922", 3: "#1D9E75"}

    kartlar = []
    for gun in hafta:
        ogun_html = ""
        for ogun_adi, tarif_adlari in gun["ogunler"].items():
            renkli = "&nbsp;".join(
                f"<span style='color:{RENKLER[i + 1]};'>●</span> {ad}"
                for i, ad in enumerate(tarif_adlari)
            )
            ogun_html += (
                f"<div style='margin:2px 0;'><b>{ogun_adi}:</b> {renkli}</div>"
            )

        t = _gun_toplami(gun, besin)
        gi_metin = f"{t['gi']}" if t["gi"] is not None else "-"
        kartlar.append(
            f"""
            <div style="border:0.5px solid var(--border, #ddd); border-radius:10px;
                        padding:10px 12px; font-size:12.5px; line-height:1.5;">
              <div style="font-weight:600; margin-bottom:4px; font-size:13.5px;">Gün {gun['gun']}</div>
              {ogun_html}
              <hr style="margin:6px 0; border:none; border-top:0.5px solid #e2e2e2;">
              <div style="color:#666;">
                {round(t['kalori'])} kcal &nbsp;·&nbsp; P {round(t['protein'])}g
                &nbsp;·&nbsp; Y {round(t['yag'])}g &nbsp;·&nbsp;
                K {round(t['karbonhidrat'])}g &nbsp;·&nbsp; Gİ {gi_metin}
              </div>
            </div>
            """
        )

    st.markdown(
        "<div style='font-size:13px; color:gray; margin:0.5rem 0 1rem;'>"
        "<span style='color:#D85A30;'>●</span> I. Grup&nbsp;&nbsp;&nbsp;"
        "<span style='color:#639922;'>●</span> II. Grup&nbsp;&nbsp;&nbsp;"
        "<span style='color:#1D9E75;'>●</span> III. Grup</div>"
        "<div style='display:grid; grid-template-columns:repeat(auto-fill,minmax(240px,1fr)); "
        "gap:12px;'>" + "".join(kartlar) + "</div>",
        unsafe_allow_html=True,
    )
