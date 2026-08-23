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
import time
from datetime import datetime, timedelta, timezone

import extra_streamlit_components as stx
import streamlit as st
from cryptography.fernet import Fernet, InvalidToken

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, supabase_ile_dene

st.set_page_config(
    page_title="Menü Mühendisliği", page_icon="assets/favicon.png", layout="wide"
)
# NOT (12 Agustos 2026 guncellendi): logo artik burada da,
# kontrol_paneli_sayfasi() icinde de AYRICA cagrilmiyor -- ozel menu
# satirinin icine tasindi (asagida, sayfa gezinmesi bolumu), ve o satir
# HER sayfa gecisinde app.py'nin basinda (pg.run()'dan once) zaten bir
# kez calisiyor. sidebar_logo_goster() artik SADECE nav satirinin henuz
# olmadigi bagimsiz ekranlarda (giris, abonelik suresi dolmus) kullaniliyor.

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


def _navigasyon_sidebar_gizle():
    # ON DOKUZUNCU DUZELTME (13 Agustos 2026, Oturum 11 -- kullanici
    # giris ekraninda Streamlit'in cIplak varsayilan pages/ klasoru
    # kenar cubugunu gordu, daha once bu bilinen ama ertelenmis bir
    # sorundu): kimlik dogrulanmamis/engellenmis ekranlarda (cerez
    # bekleme, giris formu, abonelik bloke) st.navigation() HIC
    # cagrilmiyordu -- bu yuzden Streamlit kendi varsayilan sidebar'ina
    # dusuyordu. Bu yardimci, bu ekranlarin HER BIRININ kendi
    # st.stop()'undan hemen once cagrilarak sidebar'i bastiriyor --
    # .run() cagirmiyoruz (zaten hemen ardindan st.stop() var), sadece
    # "bu uygulama kendi navigasyonunu yonetiyor" sinyalini Streamlit'e
    # veriyoruz.
    # NOT: kimlik dogrulanmis (asil nav) yolunda BU FONKSIYON
    # cagrilmiyor -- orada zaten kendi st.navigation() cagrisi var,
    # ayni script calismasinda st.navigation()'i IKI KEZ cagirmanin
    # guvenilir olup olmadigi resmi olarak test edilmedi, bu riski
    # almamak icin path'ler birbirini DISLIYOR (mutually exclusive).
    st.navigation([st.Page(lambda: None, title="Giriş")], position="hidden")


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
#
# TEKNIK NOT (6 Agustos 2026, ALTINCI DUZELTME -- gorsel flas sorunu):
# extra_streamlit_components.CookieManager arka planda gercek bir
# Streamlit ozel bileseni -- tarayicidaki cerezleri Python'a JS uzerinden
# ASENKRON bir round-trip ile bildiriyor, script'in ILK CALISTIGI ANDA bu
# deger COGU ZAMAN BOS doner. time.sleep() ve zorla st.rerun() (tek
# seferlik ya da dongulu) denendi, ikisi de FONKSIYONEL OLARAK daha kotu
# sonuc verdi -- zorla rerun, bilesenin kendi DOGAL cozunme donguSunu
# tamamlanmadan kesintiye ugratip cerezi hic okutmuyordu.
#
# BESINCI DUZELTME (sadece ILK calistirmada "Yukleniyor" goster, sonra
# dogrudan gercek login/restore mantigina gec) FONKSIYONEL OLARAK
# CALISTI (sifre tekrar istemiyor) ama GORSEL OLARAK hala birden fazla
# ekran art arda flasliyordu -- cunku bilesenin gercek veriyi bildirmesi
# genelde 1 DEGIL, BIRKAC dogal yeniden-calistirma surebiliyor; ilk
# calistirmadan sonrakilerde kod dogrudan (henuz cozulmemis olabilecek)
# gercek login formunu render ediyordu.
#
# ALTINCI DUZELTME: kendi st.rerun()'umuzu YINE eklemeden (bu hala
# yasak -- dogal donguyu bozuyor), "Yukleniyor" gosterme suresini TEK
# calistirmadan SINIRLI SAYIDA (5) dogal calistirmaya genisletiyoruz --
# yani pes etmeden once bilesene birden fazla dogal firsat taniyoruz,
# ama HICBIRINI kendimiz zorlamiyoruz, sadece HAZIR OLANA KADAR gercek
# formu render etmeyi erteliyoruz.
# MOBIL DUZELTMESI (6 Agustos 2026): mobil tarayicilarda "beni hatirla"
# guvenilir calismadigi bildirildi -- muhtemel neden, mobil cihaz/aglarin
# genelde daha yavas olmasi, bilesenin gercek veriyi bildirmesi icin
# yeterli zaman/dogal rerun sayisi olmamasi. Deneme sayisi ve son care
# bekleme suresi arttirildi (masaustunde zaten calisan mekanizmayi
# bozmadan, sadece daha CIMRI davranmayi biraktik).
#
# YEDINCI DUZELTME (12 Agustos 2026 -- Oturum 11, hala TEST EDILMEDI):
# Onceki surumde butce "8 DOGAL RERUN" olarak sayiliyordu -- sure olarak
# degil. Mobilde Streamlit'in websocket baglantisi ekran kilitlenmesi/
# uygulama arka plana atilmasi/ag degisimi gibi nedenlerle sik sik kopup
# yeniden baglanabiliyor, ve bu yeniden baglanmalar da genelde bir rerun
# tetikliyor -- ama bu rerun'lar cerez bileseninin GERCEK VERI tasidigi
# rerun'lar DEGIL, sadece baglanti olaylari. Sonuc: mobilde 8'lik rerun
# butcesi, hicbiri gercek veri getirmeyen "bosa" rerun'larla erkenden
# tukenebiliyor, kod erkenden son careye dusuyor, orada da SADECE BIR
# KEZ 4 saniye bekleyip zorla rerun deniyor -- bu da yetmezse (mobil agda
# round-trip 4 saniyeden uzun surerse) hicbir yedek kalmiyor ve kod
# cerezi "yok" sayip giris ekranini gosteriyor ("her seferinde login
# soruyor" belirtisiyle ortusuyor).
#
# Duzeltme: rerun SAYISI yerine GECEN GERCEK SURE'ye dayali bir butce --
# spurious/baglanti-kaynakli rerun'lar sureyi tuketmiyor, sadece gercek
# zaman tuketiyor, bu yuzden mobildeki fazladan rerun'lardan etkilenmiyor.
# Ayrica son care tek seferden IKI DENEMEYE cikarildi.
CEREZ_BEKLEME_ESIK_SANIYE = 6  # dogal cozunme icin gercek zaman butcesi
CEREZ_SON_CARE_MAX_DENEME = 2  # tek seferlik son care mobilde yetersiz kalabiliyordu

if "cerez_ilk_deneme_zamani" not in st.session_state:
    st.session_state.cerez_ilk_deneme_zamani = None
if "cerez_son_care_sayisi" not in st.session_state:
    st.session_state.cerez_son_care_sayisi = 0

_tum_cerezler = cerezler.get_all() if st.session_state.oturum is None else {}

if st.session_state.oturum is None and not _tum_cerezler:
    if st.session_state.cerez_ilk_deneme_zamani is None:
        st.session_state.cerez_ilk_deneme_zamani = time.time()

    _gecen_sure = time.time() - st.session_state.cerez_ilk_deneme_zamani

    if _gecen_sure < CEREZ_BEKLEME_ESIK_SANIYE:
        st.info("Yükleniyor...")
        _navigasyon_sidebar_gizle()
        st.stop()
    elif st.session_state.cerez_son_care_sayisi < CEREZ_SON_CARE_MAX_DENEME:
        # GUVENLIK AGI: esik sure gecmesine ragmen cerez hala gelmediyse
        # (ör. gercekten hic cerezi olmayan yeni bir kullanici -- ya da
        # mobilde yavas bir round-trip) UZUN bir bekleme sonrasi zorla
        # kontrol ediyoruz. Mobilde tek deneme yetmeyebildigi icin bu
        # artik EN FAZLA IKI KEZ deneniyor.
        st.session_state.cerez_son_care_sayisi += 1
        st.info("Yükleniyor...")
        time.sleep(4)
        st.rerun()

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
        st.caption("Reçete maliyeti ve kâr marjını tek yerden yönet.")

        sekme_giris, sekme_kayit, sekme_sifre_sifirla = st.tabs(
            ["Giriş yap", "Hesap oluştur", "Şifremi unuttum"]
        )

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
                        # DOKUZUNCU DUZELTME (12 Agustos 2026 -- Oturum 11,
                        # kullanici hem masaustunde hem mobilde "beni hatirla"
                        # hala calismiyor dedi -- bu ONCEKI (okuma tarafi)
                        # duzeltmemin ISE YARAMADIGINI gosteriyor, yani sorun
                        # muhtemelen okumada degil, cerezin HIC YAZILMAMASINDA.
                        # .set() cagrisindan hemen sonra KENDI st.rerun()'umuzu
                        # tetiklemek, tipki okuma tarafinda daha once ogrendigimiz
                        # gibi, bilesenin cerezi tarayicida GERCEKTEN yazma isini
                        # bitirmeden kesintiye ugratabilir -- yani cerez hic
                        # yazilmamis olabilir. Zorla rerun'dan once kisa bir
                        # bekleme ekleyip bilesene bu isi bitirmesi icin firsat
                        # taniyoruz (henuz TEST EDILMEDI, bir sonraki adim gercek
                        # tarayicida dogrulama).
                        time.sleep(1.5)
                    st.rerun()
                except Exception as e:
                    # ON ALTINCI DUZELTME (12 Agustos 2026, Oturum 11):
                    # bu blok her turlu exception'i (yanlis sifre, ag
                    # hatasi, Supabase API hatasi, RATE LIMIT, vb.) AYNI
                    # "e-posta veya sifre hatali" mesajiyla gosteriyordu --
                    # bu, Bahri'nin KENDI hesabinda basarisiz giris
                    # denemesinde GERCEK nedeni gizleyebilir. Simdi asagida
                    # gercek exception detayi da gosteriliyor (destek icin).
                    st.error("Giriş başarısız: e-posta veya şifre hatalı.")
                    with st.expander("Teknik detay (destek için)"):
                        st.code(f"{type(e).__name__}: {e}")

        with sekme_kayit:
            yeni_email = st.text_input("E-posta", key="kayit_email")
            yeni_sifre = st.text_input(
                "Şifre (en az 8 karakter)", type="password", key="kayit_sifre"
            )
            isletme_adi = st.text_input("İşletme adı", key="kayit_isletme")
            if st.button("Hesap oluştur", type="primary"):
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

        # ON YEDINCI DUZELTME (13 Agustos 2026, Oturum 11 -- Bahri'nin
        # kendi hesabinda yasadigi kilitlenme sonrasi acilen eklendi):
        # "Sifremi unuttum" akisi HIC YOKTU -- tek cikis yolu Supabase
        # Dashboard'a girip SQL ile sifreyi elle degistirmekti. Ayrica
        # Supabase'in varsayilan "sifirlama BAGLANTISI" akisi bu proje
        # icin İKİ SEBEPTEN kirilgan: (1) Site URL ayari su an localhost'a
        # ayarli, baglanti kirik cikar (Bahri'nin yasadigi durum); (2)
        # baglanti tarayicida acildiginda Supabase, token'i URL'nin
        # FRAGMENT kismina (#access_token=...) koyar -- bu kisim
        # TARAYICIDAN SUNUCUYA HIC GONDERILMEZ, yani Streamlit (sunucu
        # tarafinda calisan bir uygulama) bunu OKUYAMAZ bile, ozel bir
        # JS koprusu gerekir.
        #
        # Bunun yerine, Supabase'in AYNI E-POSTADA gonderdigi 6 haneli
        # KODU (email sablonundaki {{ .Token }}) kullaniciya elle
        # girdirip dogrudan supabase.auth.verify_otp(type="recovery")
        # ile dogruluyoruz -- bu, link/redirect/fragment sorunlarinin
        # HICBIRINE takilmiyor (resmi, dokumante edilmis bir Supabase
        # akisi -- bkz. supabase.com/docs/guides/auth/auth-email-passwordless
        # ve Python referansindaki verify_otp). Site URL duzeltilmemis
        # olsa BILE bu akis calisir.
        with sekme_sifre_sifirla:
            if not st.session_state.get("sifirlama_asama"):
                st.session_state.sifirlama_asama = "eposta_gir"

            if st.session_state.sifirlama_asama == "eposta_gir":
                st.caption(
                    "E-postana 6 haneli bir kod göndereceğiz -- o kodu bir "
                    "sonraki adımda gireceksin."
                )
                sifirlama_eposta = st.text_input("E-posta", key="sifirlama_eposta_girisi")
                if st.button("Kod gönder"):
                    if not sifirlama_eposta.strip():
                        st.warning("E-posta gir.")
                    else:
                        try:
                            supabase.auth.reset_password_for_email(sifirlama_eposta.strip())
                        except Exception:
                            # NOT: hata olsa bile ayni genel mesaji gosteriyoruz --
                            # Supabase'in kendisi de "bu e-posta kayitli mi"
                            # bilgisini disari sizdirmiyor (user enumeration
                            # koruması), biz de ayni prensibi koruyoruz.
                            pass
                        st.session_state.sifirlama_eposta = sifirlama_eposta.strip()
                        st.session_state.sifirlama_asama = "kod_gir"
                        st.rerun()

            elif st.session_state.sifirlama_asama == "kod_gir":
                st.success(
                    f"{st.session_state.sifirlama_eposta} adresine bir kod "
                    "gönderildi (gelen kutunu ve spam klasörünü kontrol et)."
                )
                kod = st.text_input("6 haneli kod", key="sifirlama_kod")
                sifirlama_yeni_sifre = st.text_input(
                    "Yeni şifre (en az 8 karakter)", type="password", key="sifirlama_yeni_sifre"
                )
                sifirlama_yeni_sifre_tekrar = st.text_input(
                    "Yeni şifre (tekrar)", type="password", key="sifirlama_yeni_sifre_tekrar"
                )
                c1, c2 = st.columns(2)
                with c1:
                    if st.button("Şifreyi sıfırla", type="primary"):
                        if not kod.strip():
                            st.warning("Kodu gir.")
                        elif len(sifirlama_yeni_sifre) < 8:
                            st.warning("Şifre en az 8 karakter olmalı.")
                        elif sifirlama_yeni_sifre != sifirlama_yeni_sifre_tekrar:
                            st.warning("Şifreler eşleşmiyor.")
                        else:
                            try:
                                supabase.auth.verify_otp({
                                    "email": st.session_state.sifirlama_eposta,
                                    "token": kod.strip(),
                                    "type": "recovery",
                                })
                                supabase.auth.update_user({"password": sifirlama_yeni_sifre})
                                supabase.auth.sign_out()
                                st.session_state.sifirlama_asama = None
                                st.session_state.sifirlama_eposta = None
                                st.success(
                                    "Şifren değiştirildi. Şimdi \"Giriş yap\" "
                                    "sekmesinden yeni şifrenle giriş yapabilirsin."
                                )
                            except Exception as e:
                                st.error(f"Kod doğrulanamadı: {e}")
                with c2:
                    if st.button("Farklı e-posta ile tekrar dene"):
                        st.session_state.sifirlama_asama = "eposta_gir"
                        st.rerun()

    _navigasyon_sidebar_gizle()
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
    _navigasyon_sidebar_gizle()
    st.stop()

if abonelik_verisi["durum"] == "odeme_gecikti":
    st.warning("Son ödemen alınamadı. Kesintisiz erişim için ödeme yöntemini güncelle.")

# ADMIN TESPITI -- 6 Agustos 2026, kullanicinin acik talebi: admin
# SADECE Bahri'nin kendi hesabina ozgu, HARDCODE edilmis bir e-posta
# kontrolu -- kullanicilar.rol gibi genel bir alan KULLANILMIYOR, cunku
# 'rol' zaten 'sahip' degerini tasiyor ve bu "BU ISLETMENIN sahibi"
# anlamina geliyor -- ileride HER musteri kendi isletmesinde 'sahip'
# rolune sahip olacak. Platform genelinde TEK admin olmasi icin bu
# ayrimin rol alanindan tamamen BAGIMSIZ tutulmasi sart.
ADMIN_EPOSTA = "bahriguler@gmail.com"
st.session_state.admin_mi = (kullanici.user.email == ADMIN_EPOSTA)

# YENI ABONELIK DURUMU -- 6 Agustos 2026: "deneme" kavrami tamamen
# kaldirildi (bkz. 41_deneme_plani_kaldir.sql). Yeni akis: kullanici
# parayi oder -> durum='odeme_alindi_onay_bekliyor' olur -> admin
# onaylayinca durum='aktif' olur. Admin bu bekleme durumundan MUAF --
# her zaman tam erisimi var. Herkes icin: sayfaya girebilir (tamamen
# engellenmiyor, suresi_doldu/iptal_edildi'den FARKLI olarak), ama
# Yillik Menu/Recete Uretimi/Ozel Menu Uretimi/Tarif Kutuphanesi
# sayfalarinda SADECE ONIZLEME yapabilir -- o 4 sayfadaki HER etkilesimli
# widget'a disabled=st.session_state.salt_okunur veriliyor.
st.session_state.salt_okunur = (
    abonelik_verisi["durum"] == "odeme_alindi_onay_bekliyor" and not st.session_state.admin_mi
)
if st.session_state.salt_okunur:
    st.info(
        "Ödemen alındı, teşekkürler! Hesabın admin onayı bekliyor — onaylanana "
        "kadar sayfaları görüntüleyebilirsin ama işlem yapamazsın."
    )

# UCUNCU KADEME -- 6 Agustos 2026: hic odeme yapmamis (yeni kayit olmus)
# kullanici. Bu durumda Yillik Menu/Recete Uretimi/Ozel Menu Uretimi/
# Tarif Kutuphanesi sayfalari NAVIGASYONDA BILE GORUNMUYOR (salt_okunur'dan
# FARKLI -- o sayfalar gorunur ama etkilesimsiz; burada sayfalarin
# kendisi navigasyon listesine hic eklenmiyor, asagida st.navigation
# olusturulurken kullaniliyor).
st.session_state.odeme_bekleniyor = (
    abonelik_verisi["durum"] == "odeme_bekleniyor" and not st.session_state.admin_mi
)

# Diger sayfalarin okuyacagi ortak oturum bilgisi
st.session_state.isletme_id = isletme_id
st.session_state.rol = kullanici_kaydi.data["rol"]
st.session_state.plan_kodu = abonelik_verisi["plan_kodu"]
st.session_state.ozellikler = abonelik_verisi["ozellikler"] or {}
st.session_state.recete_limiti = abonelik_verisi["recete_limiti"]
st.session_state.sube_limiti = abonelik_verisi["sube_limiti"]

def kontrol_paneli_sayfasi():
    # NOT (12 Agustos 2026, Oturum 11): logo artik burada cagrilmiyor --
    # ozel menu satirinin icine tasindi (asagida, sayfa gezinmesi bolumu).

    # -------------------------------------------------------------
    # Bu fonksiyon artik bir "kontrol paneli" degil, gercekte bir
    # TANITIM/ONBOARDING sayfasi -- 5 Agustos 2026'da acilir menuler
    # (st.expander) kaldirilip asagi-kaydirmali, gorsel destekli bir
    # duzene cevrildi. Her bolumdeki st.image() cagrisi assets/
    # klasorunde bir dosya bekliyor -- o dosyalar HENUZ orada degil,
    # gercek uygulama ekran goruntuleriyle doldurulmasi gerekiyor (bkz.
    # PROJE_NOTLARI.md'deki liste: hangi sayfanin ekran goruntusunun
    # hangi dosya adiyla kaydedilmesi gerektigi). Dosya yoksa
    # st.image() hata FIRLATIR -- bu yuzden asagida once dosyanin var
    # olup olmadigini kontrol eden kucuk bir yardimci kullaniliyor;
    # dosya henuz yoksa gorsel yerine sessizce bos birakiyor (sayfa
    # kirilmiyor, sadece o gorsel eksik kaliyor).
    # -------------------------------------------------------------
    import os

    def _gorsel_varsa_goster(dosya_adi, *args, **kwargs):
        yol = f"assets/{dosya_adi}"
        if os.path.exists(yol):
            st.image(yol, *args, **kwargs)
        else:
            st.caption(f"(Görsel henüz eklenmedi: assets/{dosya_adi})")

    def _video_varsa_goster(dosya_adi):
        # IKINCI DUZELTME (6 Agustos 2026, mobil sorunu): base64 data-URI
        # hilesi masaustunde calisiyordu ama MOBILDE video hic
        # gorunmuyordu -- muhtemelen mobil tarayicilarin gomulu (data-URI)
        # video kaynaklarina koydugu boyut/uyumluluk kisitlarina takiliyordu
        # (bu video base64'te ~3.6 MB). st.video()'nun artik NATIVE
        # autoplay/loop/muted parametreleri var (eskiden yoktu, sonradan
        # eklenmis) -- Streamlit'in kendi (st.logo() ile ayni turden)
        # duzgun medya sunum mekanizmasini kullaniyor, data-URI degil.
        # BEDEL: native versiyon bazi tarayicilarda kontrol cubugunu
        # gosterebilir (eski hackte hic yoktu) -- islevsellik icin bu
        # kabul edildi.
        yol = f"assets/{dosya_adi}"
        if not os.path.exists(yol):
            st.caption(f"(Video henüz eklenmedi: assets/{dosya_adi})")
            return
        with open(yol, "rb") as f:
            st.video(f.read(), format="video/mp4", autoplay=True, loop=True, muted=True)

    st.title("Menü Mühendisi'ne Hoş Geldin")
    st.write(
        "Bu sayfa, uygulamanın tüm bölümlerini kısaca tanıtır. İstediğin "
        "an üst menüden doğrudan çalışmaya başlayabilirsin — aşağısı "
        "sadece neyin nerede olduğunu görmen için. Çıkış yapmak için "
        "üst menüdeki **Abonelik** sayfasına bak."
    )

    _video_varsa_goster("tanitim_video.mp4")

    st.divider()

    # ---- 0) Bu Uygulamanın Amacı ----
    st.header("Bu Uygulamanın Amacı")
    st.write(
        "Menü Mühendisi; ticari işletmelerin, okul kantinlerinin, hastane "
        "mutfaklarının, kurumsal yemekhanelerin ve benzeri kurum/kuruluşların "
        "**bölgesel tarifleri ve mevsimlik ürünleri gözeterek** haftalık, "
        "aylık, mevsimlik ve yıllık menülerini hazırlaması için kuruldu."
    )

    st.markdown(
        """
<svg width="100%" viewBox="0 0 680 116" role="img">
<title>Bölgesel ve mevsimlik tariflerden doğru kitleye ulaşan menü üretim süreci</title>
<defs><marker id="ok1" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="#888780" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></marker></defs>
<rect x="48" y="40" width="101" height="56" rx="8" fill="#FAECE7" stroke="#993C1D" stroke-width="0.5"/>
<text x="98" y="58" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#712B13">7 bölge</text>
<text x="98" y="78" text-anchor="middle" dominant-baseline="central" font-size="12" fill="#993C1D">+ mevsimlik</text>
<rect x="179" y="40" width="122" height="56" rx="8" fill="#F1EFE8" stroke="#5F5E5A" stroke-width="0.5"/>
<text x="240" y="58" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#444441">Menü üretimi</text>
<text x="240" y="78" text-anchor="middle" dominant-baseline="central" font-size="12" fill="#5F5E5A">Anayasa kuralı</text>
<rect x="331" y="40" width="144" height="56" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="403" y="58" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">Besin &amp; alerjen</text>
<text x="403" y="78" text-anchor="middle" dominant-baseline="central" font-size="12" fill="#0F6E56">6 veri noktası</text>
<rect x="505" y="40" width="128" height="56" rx="8" fill="#FAEEDA" stroke="#854F0B" stroke-width="0.5"/>
<text x="569" y="58" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#633806">Doğru kitleye</text>
<text x="569" y="78" text-anchor="middle" dominant-baseline="central" font-size="12" fill="#854F0B">Sağlık + kurum</text>
<line x1="149" y1="68" x2="179" y2="68" stroke="#888780" stroke-width="1.5" marker-end="url(#ok1)"/>
<line x1="301" y1="68" x2="331" y2="68" stroke="#888780" stroke-width="1.5" marker-end="url(#ok1)"/>
<line x1="475" y1="68" x2="505" y2="68" stroke="#888780" stroke-width="1.5" marker-end="url(#ok1)"/>
</svg>
""",
        unsafe_allow_html=True,
    )

    st.markdown(
        "- **Bölge / mevsim gözeten üretim:** 7 coğrafi bölgenin 241 "
        "tariflik kütüphanesinden, mevsime uygun ürünleri önceliklendirerek "
        "haftalık/aylık/mevsimlik/yıllık menü üretir — anayasa kuralları "
        "(grup dengesi, tekrar etmeme, uyumsuz kombinasyonların engellenmesi) "
        "her menünün tutarlı ve dengeli olmasını garanti eder.\n"
        "- **Sadece maliyet değil, sağlık bilgisi de:** Her yemek için "
        "hesaplanan kalori, protein, yağ, karbonhidrat, glisemik indeks ve "
        "alerjen bilgisi sadece bir maliyet aracı değil — amaçlarımızdan "
        "biri de bu bilgiyi gerçekten ihtiyacı olan insanlara ulaştırmak."
    )

    st.markdown(
        """
<svg width="100%" viewBox="0 0 680 164" role="img">
<title>Menüde takip edilen altı besin ve alerjen veri noktası</title>
<rect x="120" y="40" width="130" height="44" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="185" y="62" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">Kalori</text>
<rect x="274" y="40" width="130" height="44" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="339" y="62" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">Protein</text>
<rect x="428" y="40" width="130" height="44" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="493" y="62" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">Yağ</text>
<rect x="120" y="100" width="130" height="44" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="185" y="122" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">Karbonhidrat</text>
<rect x="274" y="100" width="130" height="44" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="339" y="122" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">GI</text>
<rect x="428" y="100" width="130" height="44" rx="8" fill="#E1F5EE" stroke="#0F6E56" stroke-width="0.5"/>
<text x="493" y="122" text-anchor="middle" dominant-baseline="central" font-size="14" font-weight="500" fill="#085041">Alerjen</text>
</svg>
""",
        unsafe_allow_html=True,
    )
    st.caption("GI: Glisemik İndeks")

    st.write("**Bu verilerin şeffaf sunulması, aşağıdaki gibi pek çok kişi ve kuruma gerçek bir fark yaratabilir:**")
    sutun1, sutun2, sutun3 = st.columns(3)
    with sutun1:
        st.markdown(
            "**Beslenme ve sağlık takibi**\n"
            "- Diyetisyenler\n"
            "- Diyet yapanlar ve kilo vermek isteyenler\n"
            "- Sporcular\n"
            "- Gelişme çağındaki çocuklar\n"
            "- Hamile ve emziren anneler"
        )
    with sutun2:
        st.markdown(
            "**Kronik durumlar**\n"
            "- Şeker hastaları (glisemik indeks)\n"
            "- Endokrin sistem hastalıkları olanlar\n"
            "- Kalp-damar / hipertansiyon hastaları\n"
            "- Böbrek ve karaciğer hastaları\n"
            "- Bariatrik cerrahi sonrası hastalar"
        )
    with sutun3:
        st.markdown(
            "**Alerjen ve kurumsal ihtiyaçlar**\n"
            "- Alerjik bünyeye sahip olanlar\n"
            "- Çölyak hastaları (gluten takibi)\n"
            "- Kanser tedavisinde beslenme desteği alanlar\n"
            "- Okul kantinleri, hastane mutfakları, kurumsal yemekhaneler"
        )

    st.divider()

    # ---- 1) Reçete Üretimi (eskiden "Reçeteler" + "Üretim Aşamaları"
    # diye iki ayrı sayfaydı, kullanıcı talebiyle 6 Ağustos 2026'da
    # birleştirildi) ----
    sutun_metin, sutun_gorsel = st.columns([1.1, 1])
    with sutun_metin:
        st.header("Reçete Üretimi")
        st.write(
            "İşletmene özel kendi yemek reçetelerini burada oluşturursun "
            "(Çorba, Ana Yemek, Salata, Tatlı, İçecek, Başlangıç, Pizza, "
            "Burger kategorileri) — malzemelerini ve miktarlarını "
            "girersin, sistem güncel malzeme fiyatlarına göre porsiyon "
            "maliyetini ve porsiyon başı kaloriyi anlık olarak hesaplar."
        )
        st.write(
            "Aynı sayfada, hemen altında pişirme sürecini aşama aşama "
            "tarif edersin: her aşamada malzemeyi nerede, kaç dereceye "
            "kadar ısıttığını seçeneklerden seçersin; aşamalar arasında "
            "hangisinin hangisinden önce bitmesi gerektiğini (ya da hangi "
            "aşamaların aynı anda/paralel yapılabildiğini) belirlersin. "
            "Bağımlı olmayan aşamalar otomatik olarak paralel sayılır, "
            "sistem gerçek toplam üretim süresini (kritik yol) buna göre "
            "hesaplar. Bu veriyle malzeme + enerji + işçilik + genel "
            "gider dahil **gerçek porsiyon maliyetini** çıkarır. "
            "Elektrik/doğalgaz birim fiyatını, personel saat ücretini ve "
            "genel gider payını kendi işletme ayarlarından belirlersin."
        )
        st.caption(
            "Özel reçetelerini sadece sen görürsün, başka işletmeler "
            "erişemez. Bu reçeteler, aşağıdaki \"Yıllık Menü\" bölümündeki "
            "241 tariflik genel Türk mutfağı kütüphanesinden AYRIDIR — "
            "hazır olduğunda Özel Menü Üretimi sayfasından satışa sunabilirsin."
        )
    with sutun_gorsel:
        _gorsel_varsa_goster("tanitim_uretim_asamalari.png", use_container_width=True)

    st.divider()

    # ---- 2) Menü ----
    sutun_gorsel, sutun_metin = st.columns([1, 1.1])
    with sutun_gorsel:
        _gorsel_varsa_goster("tanitim_menu.png", use_container_width=True)
    with sutun_metin:
        st.header("Özel Menü Üretimi")
        st.write(
            "Reçete Üretimi bölümünde oluşturduğun bir yemeği buradan menüye "
            "eklersin ve bir satış fiyatı belirlersin. Sistem, o yemeğin "
            "maliyetiyle satış fiyatını karşılaştırıp kâr marjını anlık "
            "olarak gösterir — malzeme fiyatı değiştiğinde kâr marjı da "
            "otomatik olarak yeniden hesaplanır, elle güncelleme "
            "gerekmez."
        )
        st.markdown(
            "- **Kategori bazlı organizasyon:** Çorba, Ana Yemek, Salata, "
            "Tatlı, İçecek, Başlangıç, Pizza, Burger — menünü mutfağının "
            "gerçek yapısına göre düzenlersin.\n"
            "- **Anlık kâr marjı:** Her ürünün yanında maliyet, satış "
            "fiyatı ve aradaki farkın yüzdesi tek bakışta görünür — "
            "hangi ürünün gerçekte ne kazandırdığını tahmin etmek "
            "yerine kesin olarak bilirsin.\n"
            "- **Fiyatlandırma denemeleri:** Bir ürünün satış fiyatını "
            "değiştirip kâr marjının nasıl değişeceğini, menüyü fiilen "
            "değiştirmeden önce görebilirsin."
        )

    st.divider()

    # ---- 4) Yıllık Menü ----
    st.header("Yıllık Menü")
    _gorsel_varsa_goster("tanitim_yillik_menu.png", use_container_width=True)
    st.write(
        "241 tariflik genel bir Türk mutfağı kütüphanesinden (7 coğrafi "
        "bölge + genel/klasik tarifler) anayasa kurallarına uygun aylık "
        "menü üretir:"
    )
    st.markdown(
        "- **Mutfak / Bölge seçimi:** İstersen tüm kütüphaneyi, istersen "
        "sadece belirli bölge(ler)i (Ege, Akdeniz, Karadeniz vb.) "
        "kullanabilirsin. Bir bölgeye tıklamak sadece o bölgeyi devreye "
        "sokar; hiçbiri seçili değilken tüm kütüphane kullanılır.\n"
        "- **Mevsim / Ay seçimi:** Seçtiğin ay için 4 haftalık bir menü "
        "üretilir, mevsime uygun tarifler önceliklendirilir.\n"
        "- **Anayasa kuralları:** Her öğün üç gruptan (ana yemek, "
        "yardımcı yemek, tamamlayıcı) birer tarif içerir; aynı hafta "
        "içinde bir tarif mümkün olduğunca tekrar etmez; birbiriyle "
        "uyuşmayan yemek kombinasyonları (ör. zeytinyağlı + etli sebze) "
        "hiçbir zaman bir arada çıkmaz.\n"
        "- **Besin hedefi (opsiyonel):** Öğle ve akşam için ayrı ayrı "
        "kalori/protein/yağ/karbonhidrat/glisemik indeks aralığı "
        "belirleyebilirsin; algoritma bu aralığa uyan kombinasyonları "
        "önceliklendirir.\n"
        "- **Excel'e indir:** Üretilen menüyü, ekrandaki kart "
        "görünümüyle birebir aynı biçimde tek tıkla indirebilirsin."
    )

    st.divider()
    st.caption("Üst menüden istediğin bölüme geçip çalışmaya başlayabilirsin.")


# ---------------------------------------------------------------------
# 3) Sayfa gezinmesi -- st.Page ile HER sayfaya istedigimiz ismi
# veriyoruz, dosya adindan bagimsiz olarak. Bu, Streamlit Cloud'un
# deploy-sonrasi degistirilemeyen "main file path" kisitini asan tek
# kod-ici cozum: giris dosyasi hala app.py (Cloud ayari degismiyor),
# ama artik sidebar'da "app" degil "Kontrol Paneli" gorunuyor.
# ---------------------------------------------------------------------

kontrol_sayfasi = st.Page(kontrol_paneli_sayfasi, title="Kontrol Paneli", default=True)
yillik_menu_sayfasi = st.Page("pages/0_Yillik_Menu.py", title="Yıllık Menü")
recete_uretimi_sayfasi = st.Page("pages/1_Recete_Uretimi.py", title="Reçete Üretimi")
menu_sayfasi = st.Page("pages/2_Menu.py", title="Özel Menü Üretimi")
tarif_kutuphanesi_sayfasi = st.Page(
    "pages/5_Tarif_Kutuphanesi.py", title="Tarif Kütüphanesi", url_path="tarif-kutuphanesi",
)
abonelik_sayfasi = st.Page("pages/6_Abonelik.py", title="Abonelik")

sayfa_listesi = [kontrol_sayfasi]
# UCUNCU KADEME: hic odeme yapmamis kullanici icin bu 4 sayfa navigasyona
# HIC EKLENMIYOR (yukarida tanimlanan odeme_bekleniyor bayragi) -- sadece
# Kontrol Paneli + Abonelik goruyor. Odeme sonrasi (onaylansa da
# onaylanmasa da) bu sayfalar navigasyonda goruniyor; onay bekleyen
# durumdaki kisitlama (islem yapamama) salt_okunur ile ayri saglaniyor.
if not st.session_state.odeme_bekleniyor:
    sayfa_listesi += [
        yillik_menu_sayfasi, recete_uretimi_sayfasi, menu_sayfasi, tarif_kutuphanesi_sayfasi,
    ]
sayfa_listesi.append(abonelik_sayfasi)
# Admin sayfasi SADECE admin oturumunda navigasyon listesine ekleniyor --
# st.navigation() sadece kendisine verilen sayfalari taniyor, listede
# olmayan bir sayfaya dogrudan URL ile gidilmeye calisilirsa "page not
# found" olur -- yani bu sadece gorsel bir gizleme degil, gercek bir
# erisim kisitlamasi.
if st.session_state.admin_mi:
    admin_sayfasi = st.Page("pages/7_Admin.py", title="Admin")
    sayfa_listesi.append(admin_sayfasi)

# OZEL NAVIGASYON (6 Agustos 2026): Streamlit'in native st.navigation(
# position="top") menusu, kendi GitHub deposunda birden fazla ONAYLANMIS
# hata iceriyor (ornegin ust menu+sidebar'da CIFT gorunmesi, tek sayfali
# gruplarin gizlenmesi) -- kullanicinin mobilde menuyu hic acamamasi da
# muhtemelen bu olgunlasmamisligin bir sonucu (kesin dogrulanmis bir hata
# raporuyla birebir eslesmedi ama cok yakin/iliskili sorunlar bulundu).
#
# COZUM: native menuyu TAMAMEN GIZLEYIP (position="hidden" -- bu SADECE
# GORSEL kismini kapatiyor, st.navigation/pg.run() yine de sayfa
# yonlendirmesini/routing'i yapmaya devam ediyor), KENDI ozel menumuzu
# kuruyoruz: masaustunde yatay bir satir (st.page_link), mobilde
# st.popover ile acilir bir menu -- ikisi de AYNI sayfa listesinden
# besleniyor, hangisinin gorunecegi CSS media query ile (ekran
# genisligine gore) seciliyor. st.popover, Streamlit'in kendi native,
# mobil-uyumlu bir bileseni oldugu icin position="top" menusunun
# yasadigi turden hatalara girme riski cok daha dusuk.
# SEKIZINCI DUZELTME (12 Agustos 2026 -- Oturum 11, kullanici geri
# bildirimi): mobilde sayfa asagi kaydirildiginda "Menü" butonu (normal
# akista render edildigi icin) sayfayla birlikte yukari kayip ekran
# disina cikiyordu. Cozum: menu satiri basligin HEMEN ALTINA
# `position: fixed` ile sabitlendi (asagida).
#
# ON BIRINCI DUZELTME (12 Agustos 2026, ayni oturum -- kullanicinin acik
# talebi): logo artik Streamlit'in kendi basligina (st.logo()) DEGIL,
# DOGRUDAN bu ozel menu satirinin icine, en basa yerlestiriliyor -- ve
# st.logo() TAMAMEN KALDIRILDI (bkz. sidebar_logo.py, artik sadece nav
# satirinin olmadigi bagimsiz ekranlarda -- giris/abonelik suresi dolmus --
# kullaniliyor). Bunun sonucu olarak Streamlit'in native basligi artik
# HICBIR OZEL CSS ile buyutulmuyor/degistirilmiyor -- sadece kendi
# varsayilan (kucuk, Streamlit Cloud'un Share/Fork/GitHub simgelerini
# tasiyan) haliyle kaliyor, "top" ofseti buna gore asagida guncellendi.
#
# Ayrica kullanicinin ikinci talebi: her sayfa "butonu" ayni genislikte
# olsun (en uzun isim -- "Özel Menü Üretimi"/"Tarif Kütüphanesi" -- neyse
# ona gore) ve pastel renkli, gercek bir buton gibi gorunsun. Esit oranli
# st.columns() zaten butun butonlari OTOMATIK OLARAK ayni genislikte
# yapiyor (matematiksel garanti, tahmin degil); pastel stil icin HER
# page_link kendi st.container(key=...) icine sarildi -- bu, projenin
# daha once dogruladigi TEK guvenilir CSS kancasi (.st-key-{key}), page_
# link'in kendi ic DOM yapisini tahmin etmek yerine. Renk paleti (#E1F5EE
# dolgu / #0F6E56 cerceve / #085041 metin) Kontrol Paneli'ndeki mevcut
# pastel kutularla (Kalori/Protein/... SVG'si) BIREBIR AYNI, tutarlilik
# icin.
#
# NOT (DEZAVANTAJ, DURUSTCE BELIRTILMELI): asagidaki oran degerleri
# (LOGO_ORANI/BUTON_ORANI/BOSLUK_ORANI) ve "top"/spacer piksel degerleri
# TAHMINI -- gercek tarayicida (ozellikle 768px'e yakin dar masaustu/
# tablet genisliklerinde) butonlar sikisip satir kayabilir, bu durumda
# oranlarin ince ayara ihtiyaci olur.
#
# ON DORDUNCU DUZELTME (12 Agustos 2026): kullanici masaustunde logonun
# 2x buyutulmedigini bildirdi (mobilde buyudu, doğrulandı). Olasi neden:
# LOGO_ORANI (1.3), 7 buton + bosluk sutunuyla (toplam ~23.9 birim)
# kiyaslandiginda COK DAR bir sutun payi veriyordu (~%5.4) -- istenen
# 96px genislik, sutunun kendisi o kadar genis olmadigi icin Streamlit'in
# varsayilan "resim kendi kabini tasmasin" davranisiyla kirpiliyor/
# kucultuluyor olabilir. Mobilde sorun yasanmamasinin nedeni, oradaki
# logo sutununun (toplam sadece 2 elemanli bir satirda) orantili olarak
# COK DAHA GENIS bir pay almasi. Iki onlem birden alindi: (1) LOGO_ORANI
# belirgin sekilde arttirildi, (2) resmin kendisine dogrudan genislik
# zorlayan bir CSS kurali eklendi (asagida) -- sutun payindan bagimsiz
# bir guvenlik agi olarak.
LOGO_ORANI = 4.0
BUTON_ORANI = 2.8
BOSLUK_ORANI = 2.2

st.markdown(
    "<style>"
    "@media (min-width: 768px) { .st-key-mobil_nav { display: none !important; } }"
    "@media (max-width: 767px) { .st-key-masaustu_nav { display: none !important; } }"
    ".st-key-masaustu_nav, .st-key-mobil_nav {"
    "  position: fixed; left: 0; right: 0; z-index: 999999;"
    "  background-color: var(--background-color, #ffffff);"
    "  padding: 0.4rem 1rem;"
    "  box-shadow: 0 2px 6px rgba(0,0,0,0.15);"
    "  border-bottom: 1px solid rgba(0,0,0,0.08);"
    "}"
    ".st-key-masaustu_nav div[data-testid='stHorizontalBlock'] { gap: 0.7rem !important; }"
    # ON IKINCI DUZELTME (12 Agustos 2026): kullanici "mobilde degisiklik
    # olmamis gibi" dedi -- hakliydi. Streamlit varsayilan olarak dar
    # (mobil) ekranlarda st.columns()'u YATAYDAN DIKEYE (alt alta) otomatik
    # ceviriyor -- benim logo+Menu butonunu "yan yana" koyma niyetim bu
    # yuzden mobilde hic gerceklesmemis, eskisi gibi alt alta kalmislar.
    # Asagidaki kural SADECE bizim mobil menu satirimizi hedefleyip bu
    # otomatik alt-alta-cevirmeyi zorla iptal ediyor (DevTools ile
    # dogrulanmadi, Streamlit'in ic CSS yapisina bagli bir tahmin).
    ".st-key-mobil_nav div[data-testid='stHorizontalBlock'] {"
    "  flex-direction: row !important; flex-wrap: nowrap !important;"
    "  align-items: center !important; gap: 0.5rem !important;"
    "}"
    ".st-key-mobil_nav div[data-testid='stColumn'] { width: auto !important; min-width: 0 !important; }"
    # Guvenlik agi: resmin kendi genisligini sutun payindan BAGIMSIZ
    # olarak zorluyoruz -- yukaridaki LOGO_ORANI artisiyla birlikte
    # calisir, tek basina LOGO_ORANI yetmezse bu devreye girer.
    ".st-key-masaustu_nav [data-testid='stImage'] img { width: 144px !important; height: auto !important; }"
    ".st-key-mobil_nav [data-testid='stImage'] img { width: 72px !important; height: auto !important; }"
    # Pastel "buton" gorunumu -- Kontrol Paneli'ndeki mevcut renk paletiyle
    # birebir ayni (bkz. yukaridaki SVG: fill #E1F5EE, stroke #0F6E56,
    # metin #085041).
    "[class*='st-key-nav_buton_'] {"
    "  background-color: #E1F5EE; border: 1px solid #0F6E56;"
    "  border-radius: 8px; padding: 0.25rem 0.3rem; text-align: center;"
    "}"
    "[class*='st-key-nav_buton_'] a {"
    "  color: #085041 !important; text-decoration: none !important;"
    "  font-weight: 500; justify-content: center !important;"
    "}"
    "@media (min-width: 768px) { .st-key-masaustu_nav { top: 60px; } }"
    "@media (max-width: 767px) { .st-key-mobil_nav { top: 60px; } }"
    # Logo buyudugu icin (simdi 144px masaustu, 72px mobil) altindaki
    # icerigin ortulmemesi icin bosluklar da buyutuldu. "Menü Mühendisi"
    # basligi eklendigi icin (13 Agustos 2026) bosluklar bir miktar daha
    # arttirildi (bu yeni satirin kapladigi yuksekligi de karsilasin diye).
    ".ust_menu_bosluk_masaustu { height: 210px; }"
    ".ust_menu_bosluk_mobil { height: 120px; }"
    "@media (min-width: 768px) { .ust_menu_bosluk_mobil { display: none !important; } }"
    "@media (max-width: 767px) { .ust_menu_bosluk_masaustu { display: none !important; } }"
    # YIRMI BIRINCI DUZELTME (13 Agustos 2026, Oturum 11): kullanici
    # sayfa basliklarinin (ör. "Yıllık Menü Üretim Motoru") gereksiz
    # asagida kaldigini bildirdi. Sebep: Streamlit'in KENDI varsayilan
    # ust-bosluğu (.block-container'in varsayilan padding-top'u, "wide"
    # duzende arac cubugu icin ayrilan pay -- genelde birkac rem) bizim
    # zaten eklediğimiz sabit menu-bosluğu (yukarida) ile ÜST ÜSTE
    # bindigi icin toplam bosluk gereğinden fazla oluyordu. Kendi
    # bosluğumuz zaten sabit menunun tam yuksekliğini karsiladigindan,
    # Streamlit'in kendi varsayilan payini kucultuyoruz.
    ".block-container { padding-top: 1rem !important; }"
    # ON UCUNCU DUZELTME (12 Agustos 2026): Kontrol Paneli'ndeki tanitim
    # videosunun native tarayici kontrol cubugu (oynat/durdur, sure,
    # sessize al, tam ekran, "..." menusu) temizlensin istendi. st.video()
    # bunu kaldirmak icin resmi bir parametre SUNMUYOR (dogrulandi) --
    # tek yol tarayicinin kendi ic (WebKit/Blink) video kontrol
    # elemanlarini CSS ile gizlemek. BILINCLI KISIT: bu SADECE Chrome/
    # Edge/Safari (WebKit/Blink tabanli) tarayicilarda calisir, Firefox
    # bu ozel secicileri desteklemiyor -- orada kontroller GORUNMEYE DEVAM
    # EDER. Eski base64/data-URI video hilesine KASITLI OLARAK donulmedi
    # -- o yontem mobilde videoyu tamamen calistiramiyordu (bkz. yukaridaki
    # IKINCI DUZELTME notu), bu riski tekrar almiyoruz.
    "video::-webkit-media-controls { display: none !important; }"
    "video::-webkit-media-controls-enclosure { display: none !important; }"
    "video::-webkit-media-controls-panel { display: none !important; }"
    "</style>",
    unsafe_allow_html=True,
)

with st.container(key="masaustu_nav"):
    st.markdown(
        "<div style='text-align:center; font-size:1.05rem; font-weight:600; "
        "color:#0F6E56; letter-spacing:0.02em; margin-bottom:0.3rem;'>Menü Mühendisi</div>",
        unsafe_allow_html=True,
    )
    # ON BESINCI DUZELTME (12 Agustos 2026): logo 1.5x daha buyutuldu
    # (96px->144px). Kullanici ayrica menu ogelerinin logo ile ALT
    # HIZALI (bottom-aligned) durmasini istedi. Bunun icin CSS hack'i
    # DEGIL, Streamlit'in resmi `vertical_alignment="bottom"` parametresi
    # kullanildi (dokumante edilmis API -- "top" varsayilan, "center"/
    # "bottom" da destekleniyor, dogrulandi).
    _tum_kolonlar = st.columns(
        [LOGO_ORANI] + [BUTON_ORANI] * len(sayfa_listesi) + [BOSLUK_ORANI],
        vertical_alignment="bottom",
    )
    with _tum_kolonlar[0]:
        st.image("assets/logo.png", width=144)
    for _i, (_kolon, _sayfa) in enumerate(zip(_tum_kolonlar[1:-1], sayfa_listesi)):
        with _kolon:
            with st.container(key=f"nav_buton_masaustu_{_i}"):
                st.page_link(_sayfa, use_container_width=True)

with st.container(key="mobil_nav"):
    st.markdown(
        "<div style='text-align:center; font-size:0.95rem; font-weight:600; "
        "color:#0F6E56; letter-spacing:0.02em; margin-bottom:0.2rem;'>Menü Mühendisi</div>",
        unsafe_allow_html=True,
    )
    _logo_kolonu, _menu_kolonu = st.columns([1, 3], vertical_alignment="center")
    with _logo_kolonu:
        st.image("assets/logo.png", width=72)
    with _menu_kolonu:
        with st.popover("Menü"):
            for _sayfa in sayfa_listesi:
                st.page_link(_sayfa, use_container_width=True)

# Menu satiri artik `position: fixed` oldugu icin normal akistan cikti --
# altindaki sayfa icerigi menu tarafindan ortulmesin diye bosluk birakiyoruz.
st.markdown(
    "<div class='ust_menu_bosluk_masaustu'></div>"
    "<div class='ust_menu_bosluk_mobil'></div>",
    unsafe_allow_html=True,
)

pg = st.navigation(sayfa_listesi, position="hidden")
pg.run()
