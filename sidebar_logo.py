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
    # kazandiriyoruz.
    #
    # LOGO BOYUTU -- IKINCI DENEME (6 Agustos 2026): ilk denemede
    # [data-testid='stLogo'] secicisi ISE YARAMADI (buyumedi) -- st.logo()
    # dokumantasyonu "hem uygulamanin hem sidebar'inin sol ustune" render
    # ettigini soyluyor, yani muhtemelen IKI AYRI kopya olusturuyor (biri
    # sidebar icin, biri "sidebar kapaliyken/yokken" gorunen ust kose
    # icin) ve bu ikisinin FARKLI testid'leri olabilir -- ben yanlislikla
    # (artik gizli olan) sidebar kopyasini buyutmus, gercekte gorunen
    # kopyaya hic dokunmamis olabilirim. Bunun yerine, Streamlit'in ic
    # isimlendirmesinden BAGIMSIZ, gorselin KAYNAGINA (src) gore hedefleyen
    # daha saglam bir secici kullaniyoruz -- hangi testid'e sahip olursa
    # olsun, "logo.png" iceren HER img etiketini buyutur.
    st.markdown(
        "<style>"
        "[data-testid='stSidebar'] { display: none !important; }"
        "img[src*='logo.png'] { height: 64px !important; width: auto !important; }"
        "</style>",
        unsafe_allow_html=True,
    )
    st.logo("assets/logo.png", size="large")


def cikis_butonu_goster(supabase):
    """Her sayfada tutarli sekilde "Cikis yap" butonu gosterir (6
    Agustos 2026 eklendi -- daha once sadece Kontrol Paneli'nde vardi),
    ust menunun EN SAGINA (Share/yildiz/kalem/GitHub ikonlarinin yanina)
    gorsel olarak yerlestirilmis sekilde.

    ONEMLI KISIT: Streamlit'in native ust navigasyon cubuguna (st.navigation
    position="top") GERCEKTEN eleman eklemek MUMKUN DEGIL -- o cubuk sadece
    sayfa linklerini gosteriyor, ozel/harici bir ogeye acik degil. Bu
    yuzden burada bir HILE kullaniliyor: buton normal sekilde sayfa
    icerigine (st.button ile) basiliyor, ama CSS ile `position: fixed`
    kullanilarak GORSEL OLARAK ust menunun sag tarafina, native
    Share/yildiz/kalem ikonlarinin SOLUNA sabitleniyor. Bu tam anlamiyla
    menunun bir parcasi DEGIL, sadece oyle GORUNUYOR -- ekran genisligi
    cok degisirse ya da Streamlit kendi ust cubugunun duzenini
    degistirirse (surum guncellemesi), bu konumlandirma bozulabilir.

    Kendi cerez yoneticisini (db.py'deki cerez_yoneticisi(), app.py'nin
    kendi "beni hatirla" mantigindan AYRI ama ayni kutuphane/desen)
    olusturup cikista refresh_token cerezini de temizler. Bu fonksiyonu
    cagiran sayfa, `supabase = get_supabase(); oturumu_uygula(supabase)`
    adimlarindan SONRA cagirmali."""
    st.markdown(
        "<style>"
        ".st-key-cikis_yap_ortak { position: fixed; top: 10px; right: 220px; "
        "z-index: 999; }"
        "</style>",
        unsafe_allow_html=True,
    )
    cerezler = cerez_yoneticisi()
    if st.button("Çıkış yap", key="cikis_yap_ortak"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        cerezler.delete("refresh_token", key="refresh_token_cikis_ortak")
        st.rerun()
