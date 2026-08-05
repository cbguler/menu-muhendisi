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

import base64
import hashlib
from datetime import datetime, timedelta, timezone

import extra_streamlit_components as stx
import streamlit as st
from cryptography.fernet import Fernet, InvalidToken

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, supabase_ile_dene

st.set_page_config(
    page_title="Menü Mühendisliği", page_icon="assets/favicon.png", layout="wide"
)
# NOT: sidebar_logo_goster() burada DEGIL, kontrol_paneli_sayfasi()
# fonksiyonunun icinde cagriliyor. st.navigation() kullandigimizdan beri
# HER sayfa gecisinde app.py'nin TAMAMI yeniden calisiyor -- burada
# cagrilsaydi, diger sayfalarin (Tarif Kutuphanesi, Yillik Menu vb.)
# kendi ustlerindeki sidebar_logo_goster() cagrisiyla birlikte logo IKI
# KEZ render oluyordu.

supabase = get_supabase()

BENI_HATIRLA_GUN = 30  # profesyonel sitelerde yaygin standart (Streamlit'in kendi
                       # native auth ozelligi de varsayilan olarak 30 gun kullaniyor)


def _fernet_anahtari() -> bytes:
    # COOKIE_SIFRESI herhangi bir uzunlukta bir metin olabilir; Fernet tam
    # olarak 32 bayt url-safe base64 bir anahtar bekliyor -- SHA-256 ile
    # deterministik olarak turetiyoruz, boylece yeni bir secret eklemeye
    # gerek kalmiyor, ayni COOKIE_SIFRESI ayni anahtari uretiyor.
    ozet = hashlib.sha256(st.secrets["COOKIE_SIFRESI"].encode()).digest()
    return base64.urlsafe_b64encode(ozet)


_fernet = Fernet(_fernet_anahtari())


def _sifrele(metin: str) -> str:
    return _fernet.encrypt(metin.encode()).decode()


def _coz(sifreli_metin: str):
    try:
        return _fernet.decrypt(sifreli_metin.encode()).decode()
    except InvalidToken:
        return None


def _cerez_yoneticisi():
    # ONEMLI: burayi @st.cache_resource ile onbelleklemeye CALISMA --
    # stx.CookieManager()'in kendisi bir Streamlit bileseni (widget)
    # render ediyor, ve Streamlit onbelleklenmis bir fonksiyon icinde
    # widget kullanimini kesinlikle yasakliyor (CachedWidgetWarning,
    # bu Streamlit surumunde sert bir hataya donusuyor). Onbellek
    # olmadan her calismada yeniden olusturmak fonksiyonel olarak
    # sorun degil, kutuphanenin resmi ornekleri de bunu boyle kullaniyor.
    return stx.CookieManager()


# "Beni hatırla" için tarayıcıda (kendi şifrelediğimiz) bir çerez tutuyoruz --
# refresh_token burada saklanır, bir sonraki ziyarette oturumu otomatik
# tazelemek için kullanılır. Onceki surumde kullandigimiz kutuphane
# (streamlit-cookies-manager) cerez suresini ayarlamaya izin vermiyordu --
# bu yuzden "beni hatirla" gercekte cok kisa surede (muhtemelen 1 gun ya da
# tarayici kapanana kadar) unutuluyordu. extra-streamlit-components ile
# artik acikca BENI_HATIRLA_GUN kadar bir sure ayarlayabiliyoruz.
cerezler = _cerez_yoneticisi()


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
    saklanan_sifreli = cerezler.get("refresh_token")
    saklanan_refresh = _coz(saklanan_sifreli) if saklanan_sifreli else None
    if saklanan_refresh:
        try:
            yenilenen = supabase.auth.refresh_session(saklanan_refresh)
            st.session_state.oturum = yenilenen.session
            # ONEMLI: Supabase refresh token'lari TEK KULLANIMLIK (rotation) --
            # her basarili yenilemede yeni bir refresh_token doner, eskisi
            # gecersiz olur. Cerezi burada guncellemezsek "beni hatirla"
            # tam olarak BIR KERE calisir, bir sonraki ziyarette eski
            # (artik gecersiz) token cerezde kalir ve yenileme basarisiz olur.
            cerezler.set(
                "refresh_token", _sifrele(yenilenen.session.refresh_token),
                expires_at=datetime.now(timezone.utc) + timedelta(days=BENI_HATIRLA_GUN),
                key="refresh_token_yenile",
            )
        except Exception:
            # refresh token geçersiz/süresi dolmuş -- sessizce temizleyip
            # normal giriş ekranına düş
            cerezler.delete("refresh_token", key="refresh_token_sil_gecersiz")

if st.session_state.oturum is None:
    sidebar_logo_goster(animasyonlu=False)
    _, giris_sutunu, _ = st.columns([1, 1.3, 1])
    with giris_sutunu:
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
                        cerezler.set(
                            "refresh_token", _sifrele(sonuc.session.refresh_token),
                            expires_at=datetime.now(timezone.utc) + timedelta(days=BENI_HATIRLA_GUN),
                            key="refresh_token_yeni_giris",
                        )
                    st.rerun()
                except Exception:
                    st.error("Giriş başarısız: e-posta veya şifre hatalı.")

        with sekme_kayit:
            yeni_email = st.text_input("E-posta", key="kayit_email")
            yeni_sifre = st.text_input(
                "Şifre (en az 8 karakter)", type="password", key="kayit_sifre"
            )
            isletme_adi = st.text_input("İşletme adı", key="kayit_isletme")
            if st.button("14 günlük denemeyi başlat", type="primary"):
                if not (yeni_email and yeni_sifre and isletme_adi):
                    st.warning("Lütfen tüm alanları doldur.")
                else:
                    try:
                        hesap_olustur(yeni_email, yeni_sifre, isletme_adi)
                        st.success(
                            "Hesabın oluşturuldu. E-postana gelen bağlantıyla doğrulayıp giriş yap."
                        )
                    except Exception as e:
                        st.error(f"Kayıt başarısız: {e}")

    st.stop()

# ---------------------------------------------------------------------
# 2) Oturum var: kullaniciyi isletmeye baglayip abonelik durumunu kontrol et
# ---------------------------------------------------------------------

supabase.auth.set_session(
    st.session_state.oturum.access_token, st.session_state.oturum.refresh_token
)
kullanici = supabase_ile_dene(lambda: supabase.auth.get_user())

kullanici_kaydi = supabase_ile_dene(
    lambda: (
        supabase.table("kullanicilar")
        .select("isletme_id, rol")
        .eq("id", kullanici.user.id)
        .single()
        .execute()
    )
)
isletme_id = kullanici_kaydi.data["isletme_id"]

abonelik_sonuc = supabase_ile_dene(
    lambda: (
        supabase.table("isletme_aktif_abonelik")
        .select("*")
        .eq("isletme_id", isletme_id)
        .execute()
    )
)
abonelik_verisi = abonelik_sonuc.data[0] if abonelik_sonuc.data else None

if abonelik_verisi is None or abonelik_verisi["durum"] in ("suresi_doldu", "iptal_edildi"):
    sidebar_logo_goster(animasyonlu=False)
    st.warning("Aboneliğin bulunmuyor ya da sona ermiş.")
    st.link_button("Plan seç ve devam et", url="https://ORNEK-ODEME-SAYFASI-LINKI")
    if st.button("Çıkış yap"):
        supabase.auth.sign_out()
        st.session_state.oturum = None
        cerezler.delete("refresh_token", key="refresh_token_cikis_abonelik")
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

def kontrol_paneli_sayfasi():
    sidebar_logo_goster(animasyonlu=False)

    with st.sidebar:
        plan_metni = f"Plan: {abonelik_verisi['plan_adi']}"
        if abonelik_verisi["durum"] == "deneme":
            plan_metni += f"  ·  Deneme bitiş: {abonelik_verisi['deneme_bitis_tarihi']}"
        st.caption(plan_metni)
        if st.button("Çıkış yap"):
            supabase.auth.sign_out()
            st.session_state.oturum = None
            cerezler.delete("refresh_token", key="refresh_token_cikis_sidebar")
            st.rerun()

    st.title("Kontrol paneli")
    st.write(
        "Bu sayfa uygulamanın giriş ekranı ve ana kontrol noktasıdır — oturum "
        "açma/kapama ve abonelik durumu burada yönetilir. Aşağıda her bölümün "
        "ne işe yaradığının ayrıntılı açıklamasını bulabilirsin."
    )

    with st.expander("Reçeteler — kendi yemeklerini oluştur ve maliyetlendir"):
        st.write(
            "İşletmenin kendi yemek reçetelerini burada oluşturursun (Çorba, Ana "
            "Yemek, Salata, Tatlı, İçecek, Başlangıç, Pizza, Burger kategorileri). "
            "Bir reçeteye malzeme ekleyip çıkardıkça, o malzemelerin güncel "
            "fiyatlarına göre porsiyon maliyeti anlık olarak hesaplanır. Plan "
            "türüne göre kaç reçete oluşturabileceğin sınırlı olabilir. Bu "
            "reçeteler, aşağıdaki \"Yıllık Menü\" bölümündeki 241 tariflik genel "
            "Türk mutfağı kütüphanesinden AYRIDIR — burada kendi işletmene özel "
            "yemeklerini tutarsın."
        )

    with st.expander("Menü — reçeteleri satışa sun, kâr marjını gör"):
        st.write(
            "Reçeteler bölümünde oluşturduğun bir yemeği buradan menüye "
            "eklersin ve bir satış fiyatı belirlersin. Sistem, o yemeğin "
            "maliyetiyle satış fiyatını karşılaştırıp kâr marjını anlık olarak "
            "gösterir."
        )

    with st.expander("Boston Matrisi — hangi ürün ne kadar kazandırıyor"):
        st.write(
            "Menündeki ürünleri kârlılık ve popülerliğe göre dört gruba ayırır: "
            "Yıldız (çok satan + kârlı), Bulmaca (kârlı ama az satan), Atlı "
            "(çok satan ama düşük kârlı) ve Köpek (az satan + düşük kârlı). Bu "
            "klasik menü mühendisliği yöntemi, menüde neyi öne çıkarman ya da "
            "menüden çıkarman gerektiğine karar vermene yardımcı olur. Plana "
            "göre erişilebilir olabilir."
        )

    with st.expander("Üretim Aşamaları — gerçek porsiyon maliyeti"):
        st.write(
            "Bir yemeğin sadece malzeme maliyetini değil, üretim aşamalarının "
            "(ısıl işlem/enerji ve işçilik) maliyetini de hesaba katar. Paralel "
            "yapılabilen işleri dikkate alarak gerçek toplam üretim süresini "
            "bulur, genel giderleri de porsiyona yansıtarak \"gerçek maliyeti\" "
            "ortaya çıkarır — sadece malzeme fiyatına bakmaktan çok daha "
            "gerçekçi bir sonuç verir."
        )

    with st.expander("Yıllık Menü — otomatik aylık menü üretimi"):
        st.write(
            "241 tariflik genel bir Türk mutfağı kütüphanesinden (7 coğrafi "
            "bölge + genel/klasik tarifler) anayasa kurallarına uygun aylık "
            "menü üretir:\n"
            "- **Mutfak / Bölge seçimi:** İstersen tüm kütüphaneyi, istersen "
            "sadece belirli bölge(ler)i (Ege, Akdeniz, Karadeniz vb.) "
            "kullanabilirsin. Bir bölgeye tıklamak sadece o bölgeyi devreye "
            "sokar; hiçbiri seçili değilken tüm kütüphane kullanılır.\n"
            "- **Mevsim / Ay seçimi:** Seçtiğin ay için 4 haftalık bir menü "
            "üretilir, mevsime uygun tarifler önceliklendirilir.\n"
            "- **Anayasa kuralları:** Her öğün üç gruptan (ana yemek, yardımcı "
            "yemek, tamamlayıcı) birer tarif içerir; aynı hafta içinde bir "
            "tarif mümkün olduğunca tekrar etmez; birbiriyle uyuşmayan yemek "
            "kombinasyonları (ör. zeytinyağlı + etli sebze) hiçbir zaman bir "
            "arada çıkmaz.\n"
            "- **Besin hedefi (opsiyonel):** Öğle ve akşam için ayrı ayrı "
            "kalori/protein/yağ/karbonhidrat/glisemik indeks aralığı "
            "belirleyebilirsin; algoritma bu aralığa uyan kombinasyonları "
            "önceliklendirir.\n"
            "- **Excel'e indir:** Üretilen menüyü, ekrandaki kart görünümüyle "
            "birebir aynı biçimde (gün sütunları, renkli yemek grupları, "
            "besin/alerjen/maliyet bilgisi) tek tıkla indirebilirsin."
        )


# ---------------------------------------------------------------------
# 3) Sayfa gezinmesi -- st.Page ile HER sayfaya istedigimiz ismi
# veriyoruz, dosya adindan bagimsiz olarak. Bu, Streamlit Cloud'un
# deploy-sonrasi degistirilemeyen "main file path" kisitini asan tek
# kod-ici cozum: giris dosyasi hala app.py (Cloud ayari degismiyor),
# ama artik sidebar'da "app" degil "Kontrol Paneli" gorunuyor.
# ---------------------------------------------------------------------

kontrol_sayfasi = st.Page(kontrol_paneli_sayfasi, title="Kontrol Paneli", default=True)
yillik_menu_sayfasi = st.Page("pages/0_Yillik_Menu.py", title="Yıllık Menü")
receteler_sayfasi = st.Page("pages/1_Receteler.py", title="Reçeteler")
menu_sayfasi = st.Page("pages/2_Menu.py", title="Menü")
boston_sayfasi = st.Page("pages/3_Boston_Matrisi.py", title="Boston Matrisi")
uretim_sayfasi = st.Page("pages/4_Uretim_Asamalari.py", title="Üretim Aşamaları")
tarif_kutuphanesi_sayfasi = st.Page(
    "pages/5_Tarif_Kutuphanesi.py", title="Tarif Kütüphanesi", url_path="tarif-kutuphanesi",
)

pg = st.navigation([
    kontrol_sayfasi, yillik_menu_sayfasi, receteler_sayfasi,
    menu_sayfasi, boston_sayfasi, uretim_sayfasi, tarif_kutuphanesi_sayfasi,
])
pg.run()
