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
    # SIDEBAR GIZLEME -- ALTINCI DUZELTME (6 Agustos 2026, mobil sorunu):
    # [data-testid='stSidebar'] { display: none } TUM ekran boyutlarinda
    # uygulaniyordu -- masaustunde iyi calisiyordu ama MOBILDE, dar
    # ekranda ust menu sigmayinca Streamlit'in kendi "daralt/genislet"
    # (>>) davranisi TAM DA bu sidebar alanini kullaniyor gibi gorunuyor
    # -- kullanici ">>" ikonuna tiklayinca menu hic acilmiyordu, cunku
    # acilmasi gereken yer zaten gizliydi. Cozum: sidebar'i SADECE genis
    # (masaustu) ekranlarda gizle, mobilde (dar ekran) dokunma -- boylece
    # Streamlit'in kendi mobil-uyumlu davranisi bozulmuyor.
    st.markdown(
        "<style>"
        "@media (min-width: 768px) {"
        "  [data-testid='stSidebar'] { display: none !important; }"
        "}"
        "[data-testid='stHeader'] { min-height: 90px !important; height: auto !important; }"
        "[data-testid='stHeaderLogo'] { height: 100px !important; width: auto !important; max-width: none !important; }"
        "</style>",
        unsafe_allow_html=True,
    )
    st.logo("assets/logo.png", size="large")
