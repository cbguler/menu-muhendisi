# db.py
#
# Streamlit sayfaları arasında paylaşılan Supabase istemcisi ve ortak
# oturum yardımcıları. app.py ve pages/ altındaki her dosya bunu kullanır:
#
#   from db import get_supabase, oturumu_uygula
#   supabase = get_supabase()
#   oturumu_uygula(supabase)

import streamlit as st
from supabase import create_client, Client


@st.cache_resource
def get_supabase() -> Client:
    return create_client(st.secrets["SUPABASE_URL"], st.secrets["SUPABASE_ANON_KEY"])


def oturumu_uygula(supabase: Client):
    """Aktif Streamlit oturumundaki Supabase erisim token'ini istemciye uygular.
    app.py disindaki her sayfanin basinda cagrilmali; oturum yoksa sayfayi durdurur."""
    oturum = st.session_state.get("oturum")
    if oturum is None or "isletme_id" not in st.session_state:
        st.warning("Lütfen önce giriş yap.")
        st.stop()
    supabase.auth.set_session(oturum.access_token, oturum.refresh_token)
