# sidebar_logo.py
#
# Uygulama logosunu SOL UST KOSEYE (st.logo ile) yerlestirmek icin ortak
# modul. 6 Agustos 2026: navigasyon sidebar'dan ust menuye tasindi,
# kullanici sidebar'in TAMAMEN kaldirilip o alanin ana icerige
# kazandirilmasini istedi -- bu fonksiyon ona gore yeniden yazildi.
#
# ONEMLI KISIT: st.logo() sadece statik gorsel (PNG/JPG/SVG) kabul
# ediyor, VIDEO DESTEKLEMIYOR -- bu yuzden animasyonlu logo (assets/
# logo_animated.mp4) artik bu konumda kullanilamiyor, sadece statik
# logo.png kullaniliyor. animasyonlu/genislik parametreleri geriye
# donuk uyumluluk icin (eski cagrilar hata vermesin diye) duruyor ama
# artik etkisiz.

import streamlit as st

from db import cerez_yoneticisi


def sidebar_logo_goster(animasyonlu: bool = True, genislik: int = 220):
    """Uygulamanin sol ust kosesine logoyu basar (st.logo ile) ve
    sidebar'i tamamen gizleyip o alani ana icerige kazandirir.

    NOT: animasyonlu ve genislik parametreleri artik ETKISIZ (video
    destegi yok, st.logo kendi boyutlandirmasini kullaniyor) -- sadece
    eski cagrilarin (sidebar_logo_goster(animasyonlu=False) gibi)
    hata vermemesi icin imzada duruyorlar.
    """
    # Navigasyon ust menuye tasindigi ve sidebar'da baska bir icerik
    # kalmadigi icin sidebar'i tamamen gizleyip alanini ana icerige
    # kazandiriyoruz. Logo icin de st.logo()'nun native "large" (32px)
    # tavanini CSS ile asiyoruz -- kullanici eski sidebar boyutuna
    # (~220px genislik) yakin bir gorunum istedi. NOT: bu CSS secicisi
    # ([data-testid='stLogo']) Streamlit'in guncel surumunde dogru --
    # ileride bir surum guncellemesinde degisebilir, o zaman burayi
    # tekrar kontrol etmek gerekir.
    st.markdown(
        "<style>"
        "[data-testid='stSidebar'] { display: none !important; }"
        "[data-testid='stLogo'] { height: 64px !important; }"
        "</style>",
        unsafe_allow_html=True,
    )
    st.logo("assets/logo.png", size="large")


def cikis_butonu_goster(supabase):
    """Her sayfada tutarli sekilde "Cikis yap" butonu gosterir (6
    Agustos 2026 eklendi -- daha once sadece Kontrol Paneli'nde vardi).

    Kendi cerez yoneticisini (db.py'deki cerez_yoneticisi(), app.py'nin
    kendi "beni hatirla" mantigindan AYRI ama ayni kutuphane/desen)
    olusturup cikista refresh_token cerezini de temizler. Bu fonksiyonu
    cagiran sayfa, `supabase = get_supabase(); oturumu_uygula(supabase)`
    adimlarindan SONRA cagirmali."""
    cerezler = cerez_yoneticisi()
    if st.button("Çıkış yap", key="cikis_yap_ortak"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        cerezler.delete("refresh_token", key="refresh_token_cikis_ortak")
        st.rerun()
