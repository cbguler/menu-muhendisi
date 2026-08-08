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
    # YEDINCI DUZELTME (6 Agustos 2026, mobil sorunu devam ediyor):
    # Sadece sidebar gizlemeyi media query'ye almak yetmedi -- kullanici
    # mobilde logo/menu ikonunun dokununca belirip tekrar dokununca
    # kaybolmasi gibi baska bir bozulma bildirdi. Muhtemel neden: baslik
    # yuksekligi (min-height:90px) ve logo boyutu (height:100px) CSS'i
    # HALA tum ekran boyutlarinda uygulaniyordu -- mobildeki farkli
    # baslik/menu yapisiyla cakismis olabilir. Guvenli tarafta kalmak
    # icin TUM ozel CSS'i (sidebar gizleme DAHIL, baslik/logo boyutu DA
    # DAHIL) SADECE genis (masaustu, >=768px) ekranlarda uygulanacak
    # sekilde sinirliyoruz -- mobilde Streamlit'in tamamen kendi
    # varsayilan (kucuk ama CALISAN) gorunumune donuyoruz.
    st.markdown(
        "<style>"
        "@media (min-width: 768px) {"
        "  [data-testid='stSidebar'] { display: none !important; }"
        "  [data-testid='stHeader'] { min-height: 90px !important; height: auto !important; }"
        "  [data-testid='stHeaderLogo'] { height: 100px !important; width: auto !important; max-width: none !important; }"
        "}"
        "</style>",
        unsafe_allow_html=True,
    )
    st.logo("assets/logo.png", size="large")
