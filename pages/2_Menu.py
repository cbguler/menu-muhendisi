# pages/2_Menu.py
#
# Menü ögesi (satışa sunulan ürün) yönetimi: bir reçeteyi menüye ekler,
# satış fiyatı atar, canlı kâr marjını gösterir (menu_ogesi_karlilik view'i).

import streamlit as st

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Menü", page_icon="assets/favicon.png", layout="wide")
st.sidebar.image("assets/logo.png", width=140)
st.sidebar.markdown(
    "<div style='font-weight:700; color:#2C6B3C; font-size:1.4rem; "
    "font-family: Arial, Helvetica, sans-serif; margin-top:-6px;'>"
    "Menü Mühendisi</div>",
    unsafe_allow_html=True,
)

supabase = get_supabase()
oturumu_uygula(supabase)

isletme_id = st.session_state.isletme_id

st.title("Menü Yönetimi")

receteler = (
    supabase.table("receteler")
    .select("id, ad, porsiyon_sayisi")
    .eq("isletme_id", isletme_id)
    .order("ad")
    .execute()
).data or []

if not receteler:
    st.info("Önce Reçeteler sayfasından en az bir reçete oluşturmalısın.")
    st.stop()

recete_id_by_ad = {r["ad"]: r["id"] for r in receteler}

with st.expander("Menüye yeni ürün ekle"):
    with st.form("yeni_menu_ogesi", clear_on_submit=True):
        c1, c2, c3 = st.columns(3)
        secilen_recete_adi = c1.selectbox("Reçete", options=list(recete_id_by_ad.keys()))
        menu_adi = c2.text_input("Menüde görünecek ad")
        satis_fiyati = c3.number_input("Satış fiyatı (€)", min_value=0.0, step=0.5)
        aciklama = st.text_area("Açıklama (opsiyonel)")
        ekle = st.form_submit_button("Menüye ekle", type="primary")

        if ekle:
            if not menu_adi.strip():
                st.error("Menü adı boş olamaz.")
            else:
                supabase.table("menu_ogeleri").insert(
                    {
                        "isletme_id": isletme_id,
                        "recete_id": recete_id_by_ad[secilen_recete_adi],
                        "menu_adi": menu_adi.strip(),
                        "aciklama": aciklama.strip() or None,
                        "satis_fiyati": satis_fiyati,
                    }
                ).execute()
                st.success(f"'{menu_adi}' menüye eklendi.")
                st.rerun()

st.divider()

menu_ogeleri = (
    supabase.table("menu_ogeleri")
    .select("*")
    .eq("isletme_id", isletme_id)
    .order("created_at", desc=True)
    .execute()
).data or []

if not menu_ogeleri:
    st.info("Menüde henüz ürün yok.")
    st.stop()

karlilik_listesi = (
    supabase.table("menu_ogesi_karlilik")
    .select("*")
    .eq("isletme_id", isletme_id)
    .execute()
).data or []
karlilik_sozluk = {k["menu_ogesi_id"]: k for k in karlilik_listesi}

for oge in menu_ogeleri:
    karlilik = karlilik_sozluk.get(oge["id"])
    with st.container(border=True):
        ust1, ust2 = st.columns([4, 1])
        with ust1:
            st.subheader(oge["menu_adi"])
            if oge.get("aciklama"):
                st.caption(oge["aciklama"])
        with ust2:
            aktif = st.toggle("Aktif", value=oge["aktif_mi"], key=f"aktif_{oge['id']}")
            if aktif != oge["aktif_mi"]:
                supabase.table("menu_ogeleri").update({"aktif_mi": aktif}).eq("id", oge["id"]).execute()
                st.rerun()

        m1, m2, m3 = st.columns(3)
        m1.metric("Satış fiyatı", f"{oge['satis_fiyati']:.2f} €")
        if karlilik and karlilik.get("porsiyon_maliyeti_eur") is not None:
            m2.metric("Porsiyon maliyeti", f"{karlilik['porsiyon_maliyeti_eur']:.2f} €")
            yuzde = karlilik.get("kar_marji_yuzde")
            m3.metric("Kâr marjı", f"{karlilik['kar_marji_eur']:.2f} € ({yuzde:.0f}%)" if yuzde is not None else f"{karlilik['kar_marji_eur']:.2f} €")
        else:
            m2.caption("Maliyet hesaplanamadı — reçetede malzeme eksik olabilir.")

        if st.button("Menüden sil", key=f"menu_sil_{oge['id']}"):
            supabase.table("menu_ogeleri").delete().eq("id", oge["id"]).execute()
            st.rerun()
