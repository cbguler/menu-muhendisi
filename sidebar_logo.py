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
    # LOGO BOYUTU -- UCUNCU VE KESIN DUZELTME (6 Agustos 2026): DevTools
    # ile GERCEK HTML'e bakildi -- data-testid GERCEKTE "stHeaderLogo"
    # (benim tahmin ettigim "stLogo" DEGIL), ve src Streamlit'in kendi
    # hash'ledigi bir medya adresi (".../media/01ed5cf....png") -- "logo.png"
    # DEGIL. Iki onceki CSS denemem de bu yuzden hicbir seye denk
    # gelmemisti. Simdi DOGRU/DOGRULANMIS secici kullaniliyor.
    st.markdown(
        "<style>"
        "[data-testid='stSidebar'] { display: none !important; }"
        "[data-testid='stHeaderLogo'] { height: 120px !important; width: auto !important; max-width: none !important; }"
        "</style>",
        unsafe_allow_html=True,
    )
    st.logo("assets/logo.png", size="large")


def cikis_butonu_goster(supabase):
    """Her sayfada tutarli sekilde "Cikis yap" butonu gosterir (6
    Agustos 2026 eklendi -- daha once sadece Kontrol Paneli'nde vardi).

    KONUMLANDIRMA HAKKINDA (ucuncu deneme): DevTools ile bakildiginda
    st.button()'in KENDISI (key= parametresine ragmen) benzersiz/kararli
    bir CSS class ALMIYOR -- sadece HERKESE ORTAK "stButton"/
    "stBaseButton-secondary" class'lari ve DEGISKEN (surumden surume
    farkli olabilen) "st-emotion-cache-XXXXX" hash'leri var. Bu yuzden
    butonu DOGRUDAN CSS ile hedeflemek guvenilir degil.
    Cozum: butonu, benzersiz bir key verilen bir st.container() ICINE
    sarmaliyoruz -- container'lar (Yillik Menu sayfasinda daha once
    basariyla kullandigimiz ayni yontemle) GERCEKTEN "st-key-{key}"
    class'i aliyor, bu da guvenilir bir CSS hedefi saglıyor.

    Kendi cerez yoneticisini (db.py'deki cerez_yoneticisi(), app.py'nin
    kendi "beni hatirla" mantigindan AYRI ama ayni kutuphane/desen)
    olusturup cikista refresh_token cerezini de temizler. Bu fonksiyonu
    cagiran sayfa, `supabase = get_supabase(); oturumu_uygula(supabase)`
    adimlarindan SONRA cagirmali."""
    st.markdown(
        "<style>"
        ".st-key-cikis_yap_sarmalayici { position: fixed; top: 14px; "
        "right: 230px; z-index: 999; }"
        "</style>",
        unsafe_allow_html=True,
    )
    with st.container(key="cikis_yap_sarmalayici"):
        cerezler = cerez_yoneticisi()
        if st.button("Çıkış yap", key="cikis_yap_ortak"):
            supabase.auth.sign_out()
            st.session_state.oturum = None
            cerezler.delete("refresh_token", key="refresh_token_cikis_ortak")
            st.rerun()
