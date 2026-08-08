# pages/3_Boston_Matrisi.py
#
# Menu ogelerini karlilik ve populerlige gore Yildiz/Bulmaca/Atli/Kopek
# olarak siniflandirir. 6 Agustos 2026: plan kilidi (Pro'ya ozel) kaldirildi
# -- Premium plan/erisim stratejisi henuz kurulmadi (bkz. PROJE_NOTLARI.md),
# bu yuzden sayfa simdilik herkese acik.

import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Boston Matrisi", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Boston Matrisi")
st.caption("Menü ögelerini kârlılık ve popülerliğe göre Yıldız / Bulmaca / Atlı / Köpek olarak sınıflandırır.")

# Buradan sonrasi: menu_ogesi_karlilik view'i + satislar tablosundan
# donemsel toplam satis adedi cekilip 2x2 matris olarak gorsellestirilir.
# (recete_guncel_maliyet ve menu_ogesi_karlilik view'lari zaten SQL
# tarafinda hazir; burada sadece sorgulayip grafiğe dokmek kaliyor.)
# NOT (6 Agustos 2026): satislar tablosunun semasi (hangi kolonlar var,
# tarih araligi nasil tutuluyor) hen henuz gorulmedi -- gercek analiz
# kodu, o sema bilinmeden GUVENLE yazilamiyor. Kullanicidan bekleniyor.
st.info(
    "Gerçek analiz (Yıldız/Bulmaca/Atlı/Köpek hesaplaması) henüz "
    "eklenmedi -- \"satislar\" tablosunun şemasını görmeden güvenle "
    "yazılamıyor, bu bilgi bekleniyor."
)
