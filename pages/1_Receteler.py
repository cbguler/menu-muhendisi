# pages/1_Receteler.py
#
# Reçete (yemek) yönetimi: oluştur, malzeme ekle/çıkar, canlı maliyet gör.
# Maliyet hesabı recete_guncel_maliyet view'inden gelir (SQL tarafında hazır);
# burada sadece sorgulayıp gösteriyoruz.

import streamlit as st

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Reçeteler", page_icon="assets/favicon.png", layout="wide")
_sol, _orta, _sag = st.sidebar.columns([1, 5, 1])
_orta.image("assets/logo.png", width=220)
st.sidebar.markdown(
    "<div style='text-align:center; font-weight:700; color:#2C6B3C; font-size:1.4rem; "
    "font-family: Arial, Helvetica, sans-serif; margin-top:-6px;'>"
    "Menü Mühendisi</div>",
    unsafe_allow_html=True,
)

supabase = get_supabase()
oturumu_uygula(supabase)

isletme_id = st.session_state.isletme_id
recete_limiti = st.session_state.get("recete_limiti")  # None = sınırsız

KATEGORILER = ["corba", "ana_yemek", "salata", "tatli", "icecek", "baslangic", "pizza", "burger"]
KATEGORI_ETIKET = {
    "corba": "Çorba",
    "ana_yemek": "Ana Yemek",
    "salata": "Salata",
    "tatli": "Tatlı",
    "icecek": "İçecek",
    "baslangic": "Başlangıç",
    "pizza": "Pizza",
    "burger": "Burger",
}

st.title("Reçeteler")

# ---------------------------------------------------------------------
# Mevcut reçeteleri önce çek — hem listelemek hem plan limitini
# kontrol etmek için lazım.
# ---------------------------------------------------------------------
receteler = (
    supabase.table("receteler")
    .select("*")
    .eq("isletme_id", isletme_id)
    .order("created_at", desc=True)
    .execute()
).data or []

mevcut_sayi = len(receteler)
limit_doldu = recete_limiti is not None and mevcut_sayi >= recete_limiti

# ---------------------------------------------------------------------
# Yeni reçete ekleme formu (limit dolmuşsa yükseltme mesajı gösterilir)
# ---------------------------------------------------------------------
if limit_doldu:
    st.warning(
        f"Planın {recete_limiti} reçete ile sınırlı, şu an {mevcut_sayi} reçeten var. "
        "Daha fazla eklemek için planını yükselt."
    )
    st.link_button("Planı yükselt", url="https://ORNEK-ODEME-SAYFASI-LINKI")
else:
    with st.expander("Yeni reçete ekle", expanded=(mevcut_sayi == 0)):
        with st.form("yeni_recete_formu", clear_on_submit=True):
            col1, col2, col3 = st.columns(3)
            with col1:
                ad = st.text_input("Reçete adı")
            with col2:
                kategori = st.selectbox(
                    "Kategori", KATEGORILER, format_func=lambda k: KATEGORI_ETIKET[k]
                )
            with col3:
                porsiyon = st.number_input("Porsiyon sayısı", min_value=1, value=1, step=1)
            hazirlik = st.number_input("Hazırlık süresi (dakika)", min_value=0, value=15, step=5)
            kaydet = st.form_submit_button("Reçeteyi oluştur", type="primary")

            if kaydet:
                if not ad.strip():
                    st.error("Reçete adı boş olamaz.")
                else:
                    supabase.table("receteler").insert(
                        {
                            "isletme_id": isletme_id,
                            "ad": ad.strip(),
                            "kategori": kategori,
                            "porsiyon_sayisi": int(porsiyon),
                            "hazirlik_dakika": int(hazirlik),
                        }
                    ).execute()
                    st.success(f"'{ad}' reçetesi oluşturuldu.")
                    st.rerun()

st.divider()

if not receteler:
    st.info("Henüz reçete eklenmedi. Yukarıdan ilk reçeteni oluşturabilirsin.")
    st.stop()

# ---------------------------------------------------------------------
# Malzeme kataloğu (global + işletmeye özel) — tüm reçetelerde ortak kullanılır
# ---------------------------------------------------------------------
malzemeler = (
    supabase.table("malzemeler")
    .select("id, ad")
    .or_(f"isletme_id.is.null,isletme_id.eq.{isletme_id}")
    .order("ad")
    .execute()
).data or []

malzeme_adi = {m["id"]: m["ad"] for m in malzemeler}
malzeme_id_by_ad = {m["ad"]: m["id"] for m in malzemeler}

# ---------------------------------------------------------------------
# Reçete listesi — her biri kendi malzeme + maliyet paneliyle
# ---------------------------------------------------------------------
for recete in receteler:
    baslik = f"{recete['ad']} ({KATEGORI_ETIKET.get(recete['kategori'], recete['kategori'])}) — {recete['porsiyon_sayisi']} porsiyon"
    with st.expander(baslik):
        ust1, ust2 = st.columns([4, 1])
        with ust2:
            if st.button("Reçeteyi sil", key=f"sil_{recete['id']}"):
                supabase.table("receteler").delete().eq("id", recete["id"]).execute()
                st.rerun()

        recete_malzemeleri = (
            supabase.table("recete_malzemeleri")
            .select("*")
            .eq("recete_id", recete["id"])
            .execute()
        ).data or []

        if recete_malzemeleri:
            st.write("**Malzemeler**")
            for rm in recete_malzemeleri:
                mc1, mc2, mc3 = st.columns([3, 2, 1])
                mc1.write(malzeme_adi.get(rm["malzeme_id"], "(silinmiş malzeme)"))
                mc2.write(f"{rm['miktar_gram']:.0f} g")
                if mc3.button("Çıkar", key=f"cikar_{rm['id']}"):
                    supabase.table("recete_malzemeleri").delete().eq("id", rm["id"]).execute()
                    st.rerun()
        else:
            st.caption("Henüz malzeme eklenmedi.")

        with st.form(f"malzeme_ekle_{recete['id']}", clear_on_submit=True):
            ec1, ec2, ec3 = st.columns([3, 2, 1])
            secilen_ad = ec1.selectbox(
                "Malzeme", options=list(malzeme_id_by_ad.keys()), key=f"secim_{recete['id']}"
            )
            miktar = ec2.number_input(
                "Miktar (gram)", min_value=1.0, value=100.0, step=10.0, key=f"miktar_{recete['id']}"
            )
            ekle = ec3.form_submit_button("Ekle")
            if ekle:
                supabase.table("recete_malzemeleri").insert(
                    {
                        "recete_id": recete["id"],
                        "malzeme_id": malzeme_id_by_ad[secilen_ad],
                        "miktar_gram": miktar,
                    }
                ).execute()
                st.rerun()

        maliyet_sonuc = (
            supabase.table("recete_guncel_maliyet")
            .select("*")
            .eq("recete_id", recete["id"])
            .execute()
        )
        maliyet = maliyet_sonuc.data[0] if maliyet_sonuc.data else None

        if maliyet:
            st.write("**Canlı maliyet**")
            mc1, mc2, mc3 = st.columns(3)
            mc1.metric("Toplam malzeme maliyeti", f"{maliyet['toplam_maliyet_eur']:.2f} €")
            mc2.metric("Porsiyon başı maliyet", f"{maliyet['porsiyon_maliyeti_eur']:.2f} €")
            if maliyet.get("porsiyon_kalori") is not None:
                mc3.metric("Porsiyon başı kalori", f"{maliyet['porsiyon_kalori']:.0f} kcal")
