# db.py
#
# Streamlit sayfaları arasında paylaşılan Supabase istemcisi ve ortak
# oturum yardımcıları. app.py ve pages/ altındaki her dosya bunu kullanır:
#
#   from db import get_supabase, oturumu_uygula
#   supabase = get_supabase()
#   oturumu_uygula(supabase)

import time

import extra_streamlit_components as stx
import streamlit as st
from supabase import create_client, Client


@st.cache_resource
def get_supabase() -> Client:
    return create_client(st.secrets["SUPABASE_URL"], st.secrets["SUPABASE_ANON_KEY"])


def supabase_ile_dene(fonksiyon, deneme_sayisi=3, bekleme_saniye=1.0):
    """Gecici ag hatalarina (ozellikle uygulama uykudan yeni uyanirken
    gorulen httpx.ReadError/ConnectError) karsi kisa bir bekleyle tekrar
    dener. `fonksiyon` parametresiz bir lambda/callable olmali, ornek:
        sonuc = supabase_ile_dene(lambda: supabase.table("x").select("*").execute())
    """
    son_hata = None
    for deneme in range(deneme_sayisi):
        try:
            return fonksiyon()
        except Exception as e:
            son_hata = e
            if deneme < deneme_sayisi - 1:
                time.sleep(bekleme_saniye * (deneme + 1))
    raise son_hata


def oturumu_uygula(supabase: Client):
    """Aktif Streamlit oturumundaki Supabase erisim token'ini istemciye uygular.
    app.py disindaki her sayfanin basinda cagrilmali; oturum yoksa sayfayi durdurur."""
    oturum = st.session_state.get("oturum")
    if oturum is None or "isletme_id" not in st.session_state:
        st.warning("Lütfen önce giriş yap.")
        st.stop()
    supabase.auth.set_session(oturum.access_token, oturum.refresh_token)


def cerez_yoneticisi():
    """Sayfalar arasinda paylasilan cerez yoneticisi (6 Agustos 2026
    eklendi) -- app.py'deki "beni hatirla" cerez mantiginin kullandigi
    AYNI kutuphane (extra_streamlit_components). Bunu app.py'nin kendi
    _cerez_yoneticisi()'ndan AYRI tutuyoruz -- app.py'deki mantik zaten
    uzun bir sure ugrasip duzelttigimiz, calisan bir kod, ona dokunma
    riski almiyoruz. Bu fonksiyon sadece SAYFALARIN (Cikis yap butonu
    icin) cerez temizleyebilmesi icin var."""
    return stx.CookieManager(key="sayfa_cerez_yoneticisi")
