# pages/6_Abonelik.py
#
# Abonelik/hesap sayfasi (6 Agustos 2026 eklendi). Once "Cikis yap"
# butonunu her sayfada CSS ile ust menuye zorla sikistirmayi denedik --
# Streamlit'in native ust navigasyonu ozel eleman eklemeye acik olmadigi
# icin bu hep kirilgan/guvenilmez cikti. Kullanicinin onerdigi cok daha
# temiz cozum: abonelik/hesap bilgisinin (ve Cikis yap'in) kendi DOGAL
# sayfasi olsun -- CSS hilesi degil, gercek bir sayfa.

import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula, cerez_yoneticisi

st.set_page_config(page_title="Abonelik", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Abonelik")

plan_kodu = st.session_state.get("plan_kodu", "-")
st.write(f"Mevcut plan: **{plan_kodu}**")
st.caption(
    "Premium plan / yükseltme akışı henüz kurulmadı (bkz. PROJE_NOTLARI.md "
    "\"Premium Plan / Erişim Stratejisi\" nihai hedefi) -- şimdilik sadece "
    "mevcut plan bilgisi gösteriliyor."
)

st.divider()

cerezler = cerez_yoneticisi()
if st.button("Çıkış yap", type="primary"):
    supabase.auth.sign_out()
    st.session_state.oturum = None
    cerezler.delete("refresh_token", key="refresh_token_cikis_abonelik_sayfasi")
    st.rerun()
