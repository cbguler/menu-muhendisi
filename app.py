# app.py
#
# Ana giris noktasi: Supabase Auth ile giris/kayit, ardindan isletmenin
# aktif abonelik durumunu kontrol eder. pages/ altindaki diger sayfalar
# bu dosyanin urettigi st.session_state degerlerini (isletme_id, plan,
# ozellikler) okuyarak kendi erisim kontrolunu yapar.
#
# Kurulum:
#   pip install streamlit supabase
#   .streamlit/secrets.toml icine:
#     SUPABASE_URL = "https://xxxx.supabase.co"
#     SUPABASE_ANON_KEY = "xxxx"

from datetime import date, timedelta

import streamlit as st

from db import get_supabase

st.set_page_config(page_title="Menü Mühendisliği", layout="wide")

supabase = get_supabase()


def giris_yap(email: str, sifre: str):
    return supabase.auth.sign_in_with_password({"email": email, "password": sifre})


def hesap_olustur(email: str, sifre: str, isletme_adi: str):
    kayit = supabase.auth.sign_up({"email": email, "password": sifre})
    if not kayit.user or not kayit.session:
        return kayit

    supabase.auth.set_session(kayit.session.access_token, kayit.session.refresh_token)

    yeni_isletme = supabase.table("isletmeler").insert({"ad": isletme_adi}).execute()
    isletme_id = yeni_isletme.data[0]["id"]

    supabase.table("kullanicilar").insert(
        {"id": kayit.user.id, "isletme_id": isletme_id, "rol": "sahip", "ad_soyad": None}
    ).execute()

    deneme_plan = (
        supabase.table("abonelik_planlari").select("id").eq("kod", "deneme").single().execute()
    )
    supabase.table("abonelikler").insert(
        {
            "isletme_id": isletme_id,
            "plan_id": deneme_plan.data["id"],
            "durum": "deneme",
            "deneme_bitis_tarihi": (date.today() + timedelta(days=14)).isoformat(),
        }
    ).execute()

    return kayit


# ---------------------------------------------------------------------
# 1) Oturum yoksa: giris / kayit ekrani goster, geri kalanini render etme
# ---------------------------------------------------------------------

if "oturum" not in st.session_state:
    st.session_state.oturum = None

if st.session_state.oturum is None:
    st.title("Menü Mühendisliği")
    st.caption("Reçete maliyeti, kâr marjı ve Boston Matrisi analizini tek yerden yönet.")

    sekme_giris, sekme_kayit = st.tabs(["Giriş yap", "Hesap oluştur"])

    with sekme_giris:
        email = st.text_input("E-posta", key="giris_email")
        sifre = st.text_input("Şifre", type="password", key="giris_sifre")
        if st.button("Giriş yap", type="primary"):
            try:
                sonuc = giris_yap(email, sifre)
                st.session_state.oturum = sonuc.session
                st.rerun()
            except Exception:
                st.error("Giriş başarısız: e-posta veya şifre hatalı.")

    with sekme_kayit:
        yeni_email = st.text_input("E-posta", key="kayit_email")
        yeni_sifre = st.text_input("Şifre (en az 8 karakter)", type="password", key="kayit_sifre")
        isletme_adi = st.text_input("İşletme adı", key="kayit_isletme")
        if st.button("14 günlük denemeyi başlat", type="primary"):
            if not (yeni_email and yeni_sifre and isletme_adi):
                st.warning("Lütfen tüm alanları doldur.")
            else:
                try:
                    hesap_olustur(yeni_email, yeni_sifre, isletme_adi)
                    st.success("Hesabın oluşturuldu. E-postana gelen bağlantıyla doğrulayıp giriş yap.")
                except Exception as e:
                    st.error(f"Kayıt başarısız: {e}")

    st.stop()

# ---------------------------------------------------------------------
# 2) Oturum var: kullaniciyi isletmeye baglayip abonelik durumunu kontrol et
# ---------------------------------------------------------------------

supabase.auth.set_session(
    st.session_state.oturum.access_token, st.session_state.oturum.refresh_token
)
kullanici = supabase.auth.get_user()

kullanici_kaydi = (
    supabase.table("kullanicilar")
    .select("isletme_id, rol")
    .eq("id", kullanici.user.id)
    .single()
    .execute()
)
isletme_id = kullanici_kaydi.data["isletme_id"]

abonelik = (
    supabase.table("isletme_aktif_abonelik")
    .select("*")
    .eq("isletme_id", isletme_id)
    .maybe_single()
    .execute()
)

if abonelik.data is None or abonelik.data["durum"] in ("suresi_doldu", "iptal_edildi"):
    st.warning("Aboneliğin bulunmuyor ya da sona ermiş.")
    st.link_button("Plan seç ve devam et", url="https://ORNEK-ODEME-SAYFASI-LINKI")
    if st.button("Çıkış yap"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        st.rerun()
    st.stop()

if abonelik.data["durum"] == "odeme_gecikti":
    st.warning("Son ödemen alınamadı. Kesintisiz erişim için ödeme yöntemini güncelle.")

# Diger sayfalarin okuyacagi ortak oturum bilgisi
st.session_state.isletme_id = isletme_id
st.session_state.rol = kullanici_kaydi.data["rol"]
st.session_state.plan_kodu = abonelik.data["plan_kodu"]
st.session_state.ozellikler = abonelik.data["ozellikler"] or {}
st.session_state.recete_limiti = abonelik.data["recete_limiti"]
st.session_state.sube_limiti = abonelik.data["sube_limiti"]

with st.sidebar:
    st.success(f"Plan: {abonelik.data['plan_adi']}")
    if abonelik.data["durum"] == "deneme":
        st.info(f"Deneme bitiş: {abonelik.data['deneme_bitis_tarihi']}")
    if st.button("Çıkış yap"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        st.rerun()

st.title("Kontrol paneli")
st.write(
    "Sol menüden reçete maliyeti, menü yönetimi ve (plana göre) "
    "Boston Matrisi satış analizine erişebilirsin."
)
