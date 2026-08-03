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
    RENKLER = {1: "#D85A30", 2: "#639922", 3: "#1D9E75"}
    st.markdown(
        "<div style='font-size:13px; color:gray; margin:0.5rem 0 1rem;'>"
        "<span style='color:#D85A30;'>●</span> I. Grup&nbsp;&nbsp;&nbsp;"
        "<span style='color:#639922;'>●</span> II. Grup&nbsp;&nbsp;&nbsp;"
        "<span style='color:#1D9E75;'>●</span> III. Grup</div>",
        unsafe_allow_html=True,
    )
    for gun in hafta:
        with st.container(border=True):
            st.markdown(f"**Gün {gun['gun']}**")
            for ogun_adi, tarif_adlari in gun["ogunler"].items():
                renkli = "&nbsp;&nbsp;&nbsp;".join(
                    f"<span style='color:{RENKLER[i + 1]};'>●</span> {ad}"
                    for i, ad in enumerate(tarif_adlari)
                )
                st.markdown(
                    f"<div style='font-size:14px; margin:2px 0;'><b>{ogun_adi}:</b> {renkli}</div>",
                    unsafe_allow_html=True,
                )
