# db.py
#
# Streamlit sayfaları arasında paylaşılan Supabase istemcisi ve ortak
# oturum yardımcıları. app.py ve pages/ altındaki her dosya bunu kullanır:
#
#   from db import get_supabase, oturumu_uygula
#   supabase = get_supabase()
#   oturumu_uygula(supabase)

import time

import extra_streamlit_components as stx
import streamlit as st
from supabase import create_client, Client


def get_supabase() -> Client:
    """Her TARAYICI OTURUMUNA ayri bir Supabase istemcisi dondurur.

    YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): bu fonksiyon onceden
    @st.cache_resource ile onbellekleniyordu. cache_resource, sunucudaki
    BUTUN kullanicilar arasinda TEK bir nesne paylastirir; her sayfa da bu
    ortak istemciye set_session() ile kendi token'ini yaziyordu. Iki kisi ayni
    anda uygulamayi kullandiginda birinin sorgusu digerinin token'iyla
    calisabilir (baska isletmenin verisini gorme/yazma riski) ve refresh
    token'lar birbirinin uzerine yazilabilir ("Beni hatirla" sorunlarinin
    olasi sebeplerinden biri -- TAHMIN, teyit edilmedi). Personel/sube modeline
    gecmeden once kapatilmasi SART. Artik istemci st.session_state'te, yani
    oturum basina tutuluyor.
    """
    if "_supabase_istemcisi" not in st.session_state:
        st.session_state["_supabase_istemcisi"] = create_client(
            st.secrets["SUPABASE_URL"], st.secrets["SUPABASE_ANON_KEY"]
        )
    return st.session_state["_supabase_istemcisi"]


@st.cache_resource
def get_supabase_admin():
    """Service role istemcisi -- SADECE patronun personel hesabi acmasi icin
    (auth.admin.create_user). RLS'i ATLAR: baska hicbir sorguda kullanilmaz,
    set_session() asla cagrilmaz (kullanici oturumu tasimadigi icin
    onbelleklenmesi guvenli). Anahtar Streamlit Cloud "Secrets" ekraninda
    SUPABASE_SERVICE_ROLE_KEY adiyla durur; repoya ve Claude ortamina ASLA
    girmez. Anahtar tanimli degilse None doner, arayuz bunu kontrol eder.
    """
    anahtar = st.secrets.get("SUPABASE_SERVICE_ROLE_KEY")
    if not anahtar:
        return None
    return create_client(st.secrets["SUPABASE_URL"], anahtar)


def supabase_ile_dene(fonksiyon, deneme_sayisi=3, bekleme_saniye=1.0):
    """Gecici ag hatalarina (ozellikle uygulama uykudan yeni uyanirken
    gorulen httpx.ReadError/ConnectError) karsi kisa bir bekleyle tekrar
    dener. `fonksiyon` parametresiz bir lambda/callable olmali, ornek:
        sonuc = supabase_ile_dene(lambda: supabase.table("x").select("*").execute())
    """
    son_hata = None
    for deneme in range(deneme_sayisi):
        try:
            return fonksiyon()
        except Exception as e:
            son_hata = e
            if deneme < deneme_sayisi - 1:
                time.sleep(bekleme_saniye * (deneme + 1))
    raise son_hata


def oturumu_uygula(supabase: Client):
    """Aktif Streamlit oturumundaki Supabase erisim token'ini istemciye uygular.
    app.py disindaki her sayfanin basinda cagrilmali; oturum yoksa sayfayi durdurur."""
    oturum = st.session_state.get("oturum")
    if oturum is None or "isletme_id" not in st.session_state:
        st.warning("Lütfen önce giriş yap.")
        st.stop()
    supabase.auth.set_session(oturum.access_token, oturum.refresh_token)


def cerez_yoneticisi():
    """Sayfalar arasinda paylasilan cerez yoneticisi (6 Agustos 2026
    eklendi) -- app.py'deki "beni hatirla" cerez mantiginin kullandigi
    AYNI kutuphane (extra_streamlit_components). Bunu app.py'nin kendi
    _cerez_yoneticisi()'ndan AYRI tutuyoruz -- app.py'deki mantik zaten
    uzun bir sure ugrasip duzelttigimiz, calisan bir kod, ona dokunma
    riski almiyoruz. Bu fonksiyon sadece SAYFALARIN (Cikis yap butonu
    icin) cerez temizleyebilmesi icin var."""
    return stx.CookieManager(key="sayfa_cerez_yoneticisi")


def olay_kaydet(supabase: Client, olay: str, sayfa=None, detay=None):
    """Kullanim istatistigi olayi yazar (sql/183, kullanim_olaylari).

    YUZ ... DUZELTME (29 Eylul 2026): admin sayfasindaki Kullanim Istatistikleri
    icin. Olay yazilamazsa (ag hatasi, 183 calismamis) uygulama ETKILENMEZ --
    hata sessizce yutulur, kullanicinin isi asla bu yuzden kesilmez.
    olay: 'giris' | 'cikis' | 'sayfa'
    """
    try:
        if "_oturum_kimligi" not in st.session_state:
            import uuid
            st.session_state["_oturum_kimligi"] = str(uuid.uuid4())
        supabase.table("kullanim_olaylari").insert({
            "email": st.session_state.get("_kullanici_eposta"),
            "isletme_id": st.session_state.get("isletme_id"),
            "ana_isletme_id": st.session_state.get("ana_isletme_id"),
            "oturum_kimligi": st.session_state["_oturum_kimligi"],
            "olay": olay,
            "sayfa": sayfa,
            "detay": detay,
        }).execute()
    except Exception:
        pass
