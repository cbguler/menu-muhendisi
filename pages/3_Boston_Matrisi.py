# pages/3_Boston_Matrisi.py
#
# Menu ogelerini karlilik ve populerlige gore Yildiz/Bulmaca/Atli/Kopek
# olarak siniflandirir. 6 Agustos 2026: plan kilidi kaldirildi, gercek
# analiz eklendi -- satislar tablosunun semasi (isletme_id, menu_ogesi_id,
# tarih, adet) Supabase Table Editor'den dogrulandiktan sonra yazildi.
#
# Yontem: secilen donemde her menu ogesinin toplam satis adedi (populerlik)
# ile menu_ogesi_karlilik view'indeki kar_marji_yuzde (karlilik) medyan
# deger uzerinden 2x2'ye ayriliyor -- klasik BCG matrisi mantigi.

from datetime import date, timedelta

import pandas as pd
import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Boston Matrisi", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Boston Matrisi")
st.caption("Menü ögelerini kârlılık ve popülerliğe göre Yıldız / Bulmaca / Atlı / Köpek olarak sınıflandırır.")

isletme_id = st.session_state.isletme_id

donem = st.selectbox("Dönem", ["Son 30 gün", "Son 90 gün", "Tüm zamanlar"], index=0)
if donem == "Son 30 gün":
    baslangic = date.today() - timedelta(days=30)
elif donem == "Son 90 gün":
    baslangic = date.today() - timedelta(days=90)
else:
    baslangic = None

satis_sorgu = supabase.table("satislar").select("menu_ogesi_id, adet").eq("isletme_id", isletme_id)
if baslangic:
    satis_sorgu = satis_sorgu.gte("tarih", baslangic.isoformat())
satislar = satis_sorgu.execute().data or []

if not satislar:
    st.info(
        "Seçili dönemde hiç satış kaydı yok — Boston Matrisi analizi için "
        "\"satislar\" tablosuna en az birkaç menü ögesi için satış verisi "
        "girilmesi gerekiyor. (Bu tabloya nasıl veri gireceğin henüz "
        "uygulama içinden değil, doğrudan Supabase'den mümkün — istersen "
        "buraya da bir \"satış kaydet\" formu ekleyebiliriz.)"
    )
    st.stop()

satis_toplam = {}
for s in satislar:
    satis_toplam[s["menu_ogesi_id"]] = satis_toplam.get(s["menu_ogesi_id"], 0) + s["adet"]

karlilik_listesi = (
    supabase.table("menu_ogesi_karlilik").select("*").eq("isletme_id", isletme_id).execute()
).data or []
karlilik_by_id = {k["menu_ogesi_id"]: k for k in karlilik_listesi}

menu_ogeleri = (
    supabase.table("menu_ogeleri").select("id, menu_adi").eq("isletme_id", isletme_id).execute()
).data or []
ad_by_id = {m["id"]: m["menu_adi"] for m in menu_ogeleri}

satirlar = []
for oge_id, adet in satis_toplam.items():
    karlilik = karlilik_by_id.get(oge_id)
    if not karlilik or karlilik.get("kar_marji_yuzde") is None:
        continue
    satirlar.append({
        "ad": ad_by_id.get(oge_id, "?"),
        "adet": adet,
        "kar_marji_yuzde": karlilik["kar_marji_yuzde"],
    })

if not satirlar:
    st.info(
        "Satış kaydı olan ürünler için kâr marjı hesaplanamadı — "
        "reçetelerinde malzeme eksik olabilir."
    )
    st.stop()

df = pd.DataFrame(satirlar)
medyan_adet = df["adet"].median()
medyan_kar = df["kar_marji_yuzde"].median()


def _grup_belirle(satir):
    populer = satir["adet"] >= medyan_adet
    karli = satir["kar_marji_yuzde"] >= medyan_kar
    if populer and karli:
        return "Yıldız"
    if not populer and karli:
        return "Bulmaca"
    if populer and not karli:
        return "Atlı"
    return "Köpek"


df["grup"] = df.apply(_grup_belirle, axis=1)

st.divider()
st.scatter_chart(df, x="adet", y="kar_marji_yuzde", color="grup", size=80)
st.caption(
    f"Yatay kesişim: medyan satış adedi ({medyan_adet:.0f}). "
    f"Dikey kesişim: medyan kâr marjı (%{medyan_kar:.0f})."
)

st.divider()

GRUP_ACIKLAMA = {
    "Yıldız": "Çok satan + kârlı. Koru, öne çıkar.",
    "Bulmaca": "Kârlı ama az satan. Menüde daha görünür yap, tanıtımını güçlendir.",
    "Atlı": "Çok satan ama düşük kârlı. Fiyatı gözden geçir ya da maliyeti düşür.",
    "Köpek": "Az satan + düşük kârlı. Menüden çıkarmayı ya da yeniden tasarlamayı düşün.",
}

kolonlar = st.columns(4)
for kolon, grup_adi in zip(kolonlar, ["Yıldız", "Bulmaca", "Atlı", "Köpek"]):
    with kolon:
        st.markdown(f"**{grup_adi}**")
        st.caption(GRUP_ACIKLAMA[grup_adi])
        grup_df = df[df["grup"] == grup_adi][["ad", "adet", "kar_marji_yuzde"]]
        if grup_df.empty:
            st.caption("(bu grupta ürün yok)")
        else:
            st.dataframe(grup_df, hide_index=True, use_container_width=True)
