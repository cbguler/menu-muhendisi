# pages/3_Boston_Matrisi.py
#
# Ozellik kilitleme ornegi: bu sayfa sadece "boston_matrisi" ozelligi
# acik olan planlarda (Pro ve Kurumsal) calisir. app.py'de dolan
# st.session_state uzerinden kontrol eder.

import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Boston Matrisi", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=True)

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
