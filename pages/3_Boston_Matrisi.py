# pages/3_Boston_Matrisi.py
#
# Ozellik kilitleme ornegi: bu sayfa sadece "boston_matrisi" ozelligi
# acik olan planlarda (Pro ve Kurumsal) calisir. app.py'de dolan
# st.session_state uzerinden kontrol eder.

import streamlit as st

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Boston Matrisi", page_icon="assets/favicon.png", layout="wide")
_sol, _orta, _sag = st.sidebar.columns([1, 2, 1])
_orta.image("assets/logo.png", width=190)
st.sidebar.markdown(
    "<div style='text-align:center; font-weight:700; color:#2C6B3C; font-size:1.4rem; "
    "font-family: Arial, Helvetica, sans-serif; margin-top:-6px;'>"
    "Menü Mühendisi</div>",
    unsafe_allow_html=True,
)

supabase = get_supabase()
oturumu_uygula(supabase)

if not st.session_state.ozellikler.get("boston_matrisi", False):
    st.info("Boston Matrisi analizi Pro plana özeldir.")
    st.link_button("Pro plana yükselt", url="https://ORNEK-ODEME-SAYFASI-LINKI")
    st.stop()

st.title("Boston Matrisi")
st.caption("Menü ögelerini kârlılık ve popülerliğe göre Yıldız / Bulmaca / Atlı / Köpek olarak sınıflandırır.")

# Buradan sonrasi: menu_ogesi_karlilik view'i + satislar tablosundan
# donemsel toplam satis adedi cekilip 2x2 matris olarak gorsellestirilir.
# (recete_guncel_maliyet ve menu_ogesi_karlilik view'lari zaten SQL
# tarafinda hazir; burada sadece sorgulayip grafiğe dokmek kaliyor.)
