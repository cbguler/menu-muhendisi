# app.py
#
# Ana giris noktasi: Supabase Auth ile giris/kayit, ardindan isletmenin
# aktif abonelik durumunu kontrol eder. pages/ altindaki diger sayfalar
# bu dosyanin urettigi st.session_state degerlerini (isletme_id, plan,
# ozellikler) okuyarak kendi erisim kontrolunu yapar.
#
# Kurulum:
#   pip install -r requirements.txt
#   .streamlit/secrets.toml icine:
#     SUPABASE_URL = "https://xxxx.supabase.co"
#     SUPABASE_ANON_KEY = "xxxx"
#     COOKIE_SIFRESI = "uzun-rastgele-bir-metin"   # "Beni hatirla" cerezini sifrelemek icin

import streamlit as st
from streamlit_cookies_manager import EncryptedCookieManager

from db import get_supabase

st.set_page_config(
    page_title="Menü Mühendisliği", page_icon="assets/favicon.png", layout="wide"
)
_sol, _orta, _sag = st.sidebar.columns([1, 2, 1])
_orta.image("assets/logo.png", width=140)
st.sidebar.markdown(
    "<div style='text-align:center; font-weight:700; color:#2C6B3C; font-size:1.4rem; "
    "font-family: Arial, Helvetica, sans-serif; margin-top:-6px;'>"
    "Menü Mühendisi</div>",
    unsafe_allow_html=True,
)

supabase = get_supabase()

# "Beni hatırla" için tarayıcıda şifreli çerez tutuyoruz -- refresh_token
# burada saklanır, bir sonraki ziyarette oturumu otomatik tazelemek için
# kullanılır. cookies.ready() ilk yüklemede bir çerçeve gecikmesi ister;
# bu normaldir.
cookies = EncryptedCookieManager(prefix="menumuhendisi_", password=st.secrets["COOKIE_SIFRESI"])
if not cookies.ready():
    st.stop()


def giris_yap(email: str, sifre: str):
    return supabase.auth.sign_in_with_password({"email": email, "password": sifre})


def hesap_olustur(email: str, sifre: str, isletme_adi: str):
    # isletme/kullanici/abonelik satirlari artik veritabani tetikleyicisiyle
    # (05_kullanici_kayit_tetikleyicisi.sql) otomatik olusuyor -- e-posta
    # dogrulamasi bekleniyor olsa bile calisir. Burada sadece isletme adini
    # kullanici metadata'si olarak gonderiyoruz, tetikleyici onu okuyor.
    return supabase.auth.sign_up(
        {
            "email": email,
            "password": sifre,
            "options": {"data": {"isletme_adi": isletme_adi}},
        }
    )


# ---------------------------------------------------------------------
# 1) Oturum yoksa: giris / kayit ekrani goster, geri kalanini render etme
# ---------------------------------------------------------------------

if "oturum" not in st.session_state:
    st.session_state.oturum = None

# --- "Beni hatırla" çerezinden oturumu geri yüklemeyi dene ---
if st.session_state.oturum is None:
    saklanan_refresh = cookies.get("refresh_token")
    if saklanan_refresh:
        try:
            yenilenen = supabase.auth.refresh_session(saklanan_refresh)
            st.session_state.oturum = yenilenen.session
        except Exception:
            # refresh token geçersiz/süresi dolmuş -- sessizce temizleyip
            # normal giriş ekranına düş
            del cookies["refresh_token"]
            cookies.save()

if st.session_state.oturum is None:
    st.title("Menü Mühendisliği")
    st.caption("Reçete maliyeti, kâr marjı ve Boston Matrisi analizini tek yerden yönet.")

    sekme_giris, sekme_kayit = st.tabs(["Giriş yap", "Hesap oluştur"])

    with sekme_giris:
        email = st.text_input("E-posta", key="giris_email")
        sifre = st.text_input("Şifre", type="password", key="giris_sifre")
        beni_hatirla = st.checkbox("Beni hatırla", value=True, key="beni_hatirla")
        if st.button("Giriş yap", type="primary"):
            try:
                sonuc = giris_yap(email, sifre)
                st.session_state.oturum = sonuc.session
                if beni_hatirla:
                    cookies["refresh_token"] = sonuc.session.refresh_token
                    cookies.save()
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

abonelik_sonuc = (
    supabase.table("isletme_aktif_abonelik")
    .select("*")
    .eq("isletme_id", isletme_id)
    .execute()
)
abonelik_verisi = abonelik_sonuc.data[0] if abonelik_sonuc.data else None

if abonelik_verisi is None or abonelik_verisi["durum"] in ("suresi_doldu", "iptal_edildi"):
    st.warning("Aboneliğin bulunmuyor ya da sona ermiş.")
    st.link_button("Plan seç ve devam et", url="https://ORNEK-ODEME-SAYFASI-LINKI")
    if st.button("Çıkış yap"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        if "refresh_token" in cookies:
            del cookies["refresh_token"]
            cookies.save()
        st.rerun()
    st.stop()

if abonelik_verisi["durum"] == "odeme_gecikti":
    st.warning("Son ödemen alınamadı. Kesintisiz erişim için ödeme yöntemini güncelle.")

# Diger sayfalarin okuyacagi ortak oturum bilgisi
st.session_state.isletme_id = isletme_id
st.session_state.rol = kullanici_kaydi.data["rol"]
st.session_state.plan_kodu = abonelik_verisi["plan_kodu"]
st.session_state.ozellikler = abonelik_verisi["ozellikler"] or {}
st.session_state.recete_limiti = abonelik_verisi["recete_limiti"]
st.session_state.sube_limiti = abonelik_verisi["sube_limiti"]

with st.sidebar:
    st.success(f"Plan: {abonelik_verisi['plan_adi']}")
    if abonelik_verisi["durum"] == "deneme":
        st.info(f"Deneme bitiş: {abonelik_verisi['deneme_bitis_tarihi']}")
    if st.button("Çıkış yap"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        if "refresh_token" in cookies:
            del cookies["refresh_token"]
            cookies.save()
        st.rerun()

st.title("Kontrol paneli")
st.write(
    "Sol menüden reçete maliyeti, menü yönetimi ve (plana göre) "
    "Boston Matrisi satış analizine erişebilirsin."
)
