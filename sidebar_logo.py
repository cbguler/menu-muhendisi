# sidebar_logo.py
#
# Sidebar'daki logo+başlık bloğunu tek yerden yönetmek için ortak modül.
# Amaç: deneme amaçlı değişiklikleri (ör. statik <-> animasyonlu logo)
# tek fonksiyonu değiştirerek tüm sayfalara yansıtabilmek.

import base64
from pathlib import Path

import streamlit as st

_BASLIK_HTML = (
    "<div style='text-align:center; font-weight:700; color:#2C6B3C; "
    "font-size:1.4rem; font-family: Arial, Helvetica, sans-serif; "
    "margin-top:-6px;'>Menü Mühendisi</div>"
)


@st.cache_data
def _video_base64(path: str) -> str:
    return base64.b64encode(Path(path).read_bytes()).decode()


def sidebar_logo_goster(animasyonlu: bool = True, genislik: int = 220):
    """Sidebar'ın en üstüne logo + 'Menü Mühendisi' başlığını basar.

    animasyonlu=True  -> assets/logo_animated.mp4 (DENEME, beğenilmezse
                          animasyonlu=False yapılıp geri dönülebilir)
    animasyonlu=False -> assets/logo.png (önceki, statik sürüm)
    """
    # Sidebar'ı daralt + ana icerik alaninin sag/sol bosluklarini azalt --
    # kullanicinin "bosluklari kullanalim" istegi. NOT: bu secicilerin
    # (stSidebar, stMainBlockContainer) Streamlit surumler arasi kararlilik
    # garantisi yok ama otomatik-uretilen (st-emotion-cache-...) siniflara
    # gore cok daha stabil, yaygin kullanilan sabit isimler.
    st.markdown(
        "<style>"
        "[data-testid='stSidebar'] { min-width: 260px !important; max-width: 260px !important; }"
        ".stMainBlockContainer { padding-left: 1.5rem !important; padding-right: 1.5rem !important; "
        "max-width: 100% !important; }"
        "</style>",
        unsafe_allow_html=True,
    )

    if animasyonlu:
        video_b64 = _video_base64("assets/logo_animated.mp4")
        st.sidebar.markdown(
            f"""
            <div style="text-align:center; margin-bottom:4px;">
                <video autoplay muted loop playsinline
                       style="width:{genislik}px; mix-blend-mode:multiply;">
                    <source src="data:video/mp4;base64,{video_b64}" type="video/mp4">
                </video>
            </div>
            """,
            unsafe_allow_html=True,
        )
    else:
        _sol, _orta, _sag = st.sidebar.columns([1, 5, 1])
        _orta.image("assets/logo.png", width=genislik)

    st.sidebar.markdown(_BASLIK_HTML, unsafe_allow_html=True)
