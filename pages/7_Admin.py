# pages/7_Admin.py
#
# Sadece admin'e (app.py'de hardcode edilmis e-posta ile tespit edilen
# tek hesap) acik sayfa -- st.navigation() listesine sadece admin
# oturumunda ekleniyor, bu yuzden baskasi URL'yi bilse bile
# ulasamiyor. Ama savunma amacli, burada da ayrica kontrol ediliyor.
#
# Odemesi alinmis ama admin onayi bekleyen abonelikleri listeler,
# "Onayla" butonuyla durum='aktif' yapar.

import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Admin", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

if not st.session_state.get("admin_mi"):
    st.error("Bu sayfaya erişimin yok.")
    st.stop()

st.title("Admin — Bekleyen Abonelikler")
st.caption(
    "Ödemesi alınmış ama henüz onaylanmamış abonelikler burada listelenir. "
    "Onaylayınca hesap tam erişime geçer."
)

bekleyenler = (
    supabase.table("abonelikler")
    .select("id, isletme_id, plan_id, durum, isletmeler(ad), abonelik_planlari(kod, ad)")
    .eq("durum", "odeme_alindi_onay_bekliyor")
    .execute()
).data or []

if not bekleyenler:
    st.info("Onay bekleyen abonelik yok.")
    st.stop()

for abonelik in bekleyenler:
    isletme_adi = (abonelik.get("isletmeler") or {}).get("ad", "?")
    plan_adi = (abonelik.get("abonelik_planlari") or {}).get("ad", "?")
    with st.container(border=True):
        c1, c2 = st.columns([4, 1])
        with c1:
            st.write(f"**{isletme_adi}** — {plan_adi} planı")
        with c2:
            if st.button("Onayla", key=f"onayla_{abonelik['id']}", type="primary"):
                supabase.table("abonelikler").update({"durum": "aktif"}).eq(
                    "id", abonelik["id"]
                ).execute()
                st.success(f"'{isletme_adi}' onaylandı.")
                st.rerun()
