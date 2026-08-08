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


def sidebar_logo_goster(animasyonlu: bool = True, genislik: int = 220):
    """Uygulamanin sol ust kosesine logoyu basar (st.logo ile) ve
    sidebar'i tamamen gizleyip o alani ana icerige kazandirir.

    NOT: animasyonlu ve genislik parametreleri artik ETKISIZ (video
    destegi yok, st.logo kendi boyutlandirmasini kullaniyor) -- sadece
    eski cagrilarin (sidebar_logo_goster(animasyonlu=False) gibi)
    hata vermemesi icin imzada duruyorlar.
    """
    # LOGO BOYUTU -- BESINCI DUZELTME (6 Agustos 2026): 56px yeterince
    # buyuk degildi (kullanici 2x daha istedi -> ~112px), ama daha once
    # 120px'te USTTEN KIRPILMISTI -- kirpilmanin gercek nedeni logo degil,
    # basligin KENDI YUKSEKLIGI logo kadar buyumuyordu (header kutusu
    # sabit/kucuk, tasan kisim gizleniyordu). Bu sefer HEM logoyu HEM DE
    # basligin (stHeader) kendi min-height'ini birlikte buyutuyoruz --
    # kutu artik logoyu kirpmadan icine alacak kadar buyuk.
    st.markdown(
        "<style>"
        "[data-testid='stSidebar'] { display: none !important; }"
        "[data-testid='stHeader'] { min-height: 90px !important; height: auto !important; }"
        "[data-testid='stHeaderLogo'] { height: 100px !important; width: auto !important; max-width: none !important; }"
        "</style>",
        unsafe_allow_html=True,
    )
    st.logo("assets/logo.png", size="large")
