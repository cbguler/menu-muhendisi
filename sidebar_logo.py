# sidebar_logo.py
#
# Uygulama logosunu gostermek icin ortak modul. 6 Agustos 2026: navigasyon
# sidebar'dan ust menuye tasindi. 12 Agustos 2026 (Oturum 11, ON BIRINCI
# DUZELTME): kullanici "menuyu logo ile ayni satira alalim" istedi -- bunu
# Streamlit'in kendi basligina (st.logo()) enjeksiyon yaparak DEGIL, logoyu
# TAMAMEN kendi ozel menu satirimizin icine tasiyarak yaptik (bkz. app.py,
# OZEL NAVIGASYON bolumu). Bu yuzden st.logo() ve onun ozel basligi
# buyutme CSS'i (stHeader/stHeaderLogo) burada ARTIK KULLANILMIYOR.
#
# BU FONKSIYON ARTIK SADECE "nav satirinin henuz olmadigi" baglamlarda
# kullaniliyor -- giris ekrani (app.py, oturum yokken) ve abonelik
# suresi dolmus/iptal ekrani gibi nav satirinin render edilmedigi erken
# donus (early return) durumlari. Kimlik dogrulanmis TUM sayfalarda logo
# artik app.py'deki ozel menu satirinin icinde render ediliyor -- oralarda
# (pages/*.py, kontrol_paneli_sayfasi) bu fonksiyonu TEKRAR CAGIRMAYIN,
# cift logo gorunur.

import streamlit as st


def sidebar_logo_goster(animasyonlu: bool = True, genislik: int = 220):
    """Nav satirinin henuz kurulmadigi bagimsiz ekranlarda (giris ekrani,
    abonelik suresi dolmus ekrani vb.) logoyu gosterir.

    NOT: animasyonlu ve genislik parametreleri ETKISIZ (video destegi yok) --
    sadece eski cagrilarin hata vermemesi icin imzada duruyorlar.
    """
    st.image("assets/logo.png", width=90)
