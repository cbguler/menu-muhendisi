# pages/6_Abonelik.py
#
# Abonelik/hesap sayfasi (6 Agustos 2026 eklendi). Once "Cikis yap"
# butonunu her sayfada CSS ile ust menuye zorla sikistirmayi denedik --
# Streamlit'in native ust navigasyonu ozel eleman eklemeye acik olmadigi
# icin bu hep kirilgan/guvenilmez cikti. Kullanicinin onerdigi cok daha
# temiz cozum: abonelik/hesap bilgisinin (ve Cikis yap'in) kendi DOGAL
# sayfasi olsun -- CSS hilesi degil, gercek bir sayfa.
#
# 12 Agustos 2026 (Oturum 11, kullanicinin acik talebi): sayfa "daha
# fazla bilgi toplayan bir tablo duzeni"ne genisletildi -- isletme
# adresi + fatura adresi (bkz. 47_isletme_adres_fatura_ekle.sql) ve
# hesap e-posta/sifre degistirme bolumu eklendi. Vergi no/vergi dairesi/
# yetkili kisi/telefon gibi diger "kurumsal abonelik" alanlari BILEREK
# eklenmedi -- kullanicidan hangi spesifik alanlari istedigi netlesince
# eklenecek.

import streamlit as st
import pandas as pd

from besin_sabitleri import TUM_BESIN_ALANLARI, BESIN_ETIKET, BESIN_ARALIK, kanonik_sirala, STANDART_PROFILLER

# NOT (12 Agustos 2026, Oturum 11): logo artik burada AYRICA gosterilmiyor -- app.py'deki ozel menu satirinin icine tasindi, orada zaten her sayfa gecisinde render ediliyor. Burada tekrar cagirmak cift logoya yol acardi.

from db import get_supabase, oturumu_uygula, cerez_yoneticisi

st.set_page_config(page_title="Abonelik", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

# YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9, sql/182): Isletme / Sube /
# Personel modeli. Patron (isletme sahibi) bu sayfada her seyi gorur; personel
# sadece Hesap Bilgileri'ni, cikisi ve yetkisi olan bolumleri (maliyet ayarlari,
# porsiyon profilleri) gorur. Isletme bilgileri, subeler ve personel yonetimi
# SADECE patrona aittir.
from yetkiler import YETKI_KATALOGU, HAZIR_ROLLER, OZEL_ROL, yetki
from db import get_supabase_admin

_patron = st.session_state.get("patron_mu", True)
_personel_mi = st.session_state.get("personel_mi", False)
isletme_id = st.session_state.isletme_id


@st.cache_data(ttl=3600)
def _varsayilan_kutuphane_tarif_sayisi():
    """Aylik Menu'nun hazir kutuphanesindeki (isletme_id NULL olan)
    tarif sayisi. Supabase/PostgREST sorgu basina varsayilan olarak
    en fazla 1000 satir donduruyor (sinirin uzerindekiler sessizce
    kesiliyor) -- kutuphane su an tam 1000 tarif oldugu icin .range()
    ile sayfalayarak sayiyoruz, boylece ileride kutuphane buyuyunce
    bu sayi sessizce yanlis (1000'de sabit) kalmaz."""
    toplam = 0
    offset = 0
    sayfa_boyutu = 1000
    while True:
        sayfa = (
            supabase.table("receteler")
            .select("id")
            .is_("isletme_id", "null")
            .range(offset, offset + sayfa_boyutu - 1)
            .execute()
        ).data
        toplam += len(sayfa)
        if len(sayfa) < sayfa_boyutu:
            break
        offset += sayfa_boyutu
    return toplam


st.title("Abonelik")

# YUZ ... DUZELTME (28 Eylul 2026): plan NULL iken "None" yaziyordu (.get(key, "-")
# anahtar varsa varsayilani kullanmaz) -> .get(key) or ...
plan_kodu = st.session_state.get("plan_adi") or st.session_state.get("plan_kodu") or "Plan atanmamış"
if st.session_state.get("odeme_bekleniyor"):
    st.warning(
        "Henüz bir ödeme yapmadın. Ödeme sonrası hesabın admin onayına "
        "geçecek, onaylanınca tüm sayfalara erişebileceksin."
    )
elif st.session_state.get("salt_okunur"):
    st.info(
        "Ödemen alındı, teşekkürler! Admin onayı bekleniyor -- onaylanana "
        "kadar sayfaları görüntüleyebilirsin ama işlem yapamazsın."
    )
elif _patron:
    st.write(f"Mevcut plan: **{plan_kodu}**")
st.caption(
    "Gerçek ödeme akışı (PayTR vb.) henüz kurulmadı (bkz. PROJE_NOTLARI.md "
    "\"Premium Plan / Erişim Stratejisi\" nihai hedefi)."
)

st.divider()

# ---------------------------------------------------------------------
# SUBELER ve PERSONEL VE YETKILER (28 Eylul 2026, sql/182) -- sadece patron
# ---------------------------------------------------------------------
_org = st.session_state.get("erisilebilir_isletmeler") or []
if _patron and _org:
    _ana_id = st.session_state.get("ana_isletme_id")
    _org_ad = {i["id"]: i["ad"] + (" (merkez)" if not i.get("ust_isletme_id") else "") for i in _org}
    _org_idleri = [i["id"] for i in _org]

    st.subheader("Şubeler")
    _limit = st.session_state.get("sube_limiti")
    st.caption(
        "Her şube ayrı bir işletmedir: kendi reçeteleri, maliyet ayarları, menüleri ve raporları vardır. "
        "Merkezin özel tarifleri bütün şubelerde ortaktır. Yeni şube açıldığında merkezin malzeme "
        "fiyatları, maliyet ayarları ve porsiyon profilleri şubeye kopyalanır; şube bunları sonra "
        "kendine göre değiştirebilir. Hangi işletmede çalıştığını sayfanın üstündeki seçiciden değiştirirsin. "
        f"Planındaki işletme sınırı (merkez dahil): {_limit if _limit else 'sınırsız'}. Şu an: {len(_org)}."
    )
    st.dataframe(
        [{"İşletme": i["ad"], "Tür": "Merkez" if not i.get("ust_isletme_id") else "Şube"} for i in _org],
        hide_index=True, use_container_width=True,
    )
    with st.form("yeni_sube_formu", clear_on_submit=True):
        _sc1, _sc2 = st.columns(2)
        _sube_adi = _sc1.text_input("Yeni şube adı")
        _sube_adres = _sc2.text_input("Adres (isteğe bağlı)")
        if st.form_submit_button("Şube aç"):
            if not _sube_adi.strip():
                st.error("Şube adı boş olamaz.")
            else:
                try:
                    supabase.rpc("sube_olustur", {"p_ad": _sube_adi.strip(), "p_adres": _sube_adres.strip() or None}).execute()
                    st.success(f"'{_sube_adi.strip()}' şubesi açıldı.")
                    st.rerun()
                except Exception as e:
                    st.error(f"Şube açılamadı: {e}")

    st.divider()

    st.subheader("Personel ve Yetkiler")
    st.caption(
        "Personeli sen eklersin: e-postasını ve şifresini belirlersin, hangi şubelerde çalışacağını ve "
        "her şubede neyi görüp neyi değiştirebileceğini seçersin. Hazır roller bir başlangıç setidir; "
        "'Özel' seçersen yetkileri tek tek belirlersin. Yetkiler veritabanında da zorlanır. "
        "Değişiklikler personelin bir sonraki sayfa yenilemesinde geçerli olur."
    )
    _admin = get_supabase_admin()
    if _admin is None:
        st.warning(
            "Personel hesabı açmak için Supabase service role anahtarının Streamlit Cloud "
            "Secrets ekranına SUPABASE_SERVICE_ROLE_KEY adıyla eklenmesi gerekiyor."
        )

    _rol_secenekleri = list(HAZIR_ROLLER.keys()) + [OZEL_ROL[0]]
    _rol_etiketi = {k: v[0] for k, v in HAZIR_ROLLER.items()}
    _rol_etiketi[OZEL_ROL[0]] = OZEL_ROL[1]

    with st.expander("Yeni personel ekle", expanded=False):
        with st.form("yeni_personel_formu", clear_on_submit=False):
            _pc1, _pc2 = st.columns(2)
            _p_ad = _pc1.text_input("Ad soyad")
            _p_eposta = _pc2.text_input("E-posta (giriş adı)")
            _pc3, _pc4 = st.columns(2)
            _p_sifre = _pc3.text_input("Şifre (en az 8 karakter)", type="password")
            _p_rol = _pc4.selectbox(
                "Rol", list(HAZIR_ROLLER.keys()), format_func=lambda k: _rol_etiketi[k],
                help="Yetkileri sonra şube şube değiştirebilirsin.",
            )
            _p_subeler = st.multiselect(
                "Çalışacağı işletmeler", _org_idleri, default=[isletme_id] if isletme_id in _org_idleri else [],
                format_func=lambda i: _org_ad.get(i, "?"),
            )
            if st.form_submit_button("Personeli ekle", type="primary", disabled=_admin is None):
                _eposta = _p_eposta.strip().lower()
                if not _eposta or "@" not in _eposta:
                    st.error("Geçerli bir e-posta gir.")
                elif len(_p_sifre) < 8:
                    st.error("Şifre en az 8 karakter olmalı.")
                elif not _p_subeler:
                    st.error("En az bir işletme seç.")
                else:
                    _personel_id = None
                    try:
                        _personel_id = supabase.table("personel").insert({
                            "ana_isletme_id": _ana_id, "email": _eposta, "ad_soyad": _p_ad.strip() or None,
                        }).execute().data[0]["id"]
                        supabase.table("personel_sube_yetkileri").insert([
                            {"personel_id": _personel_id, "isletme_id": _sid, "rol_sablonu": _p_rol,
                             "yetkiler": HAZIR_ROLLER[_p_rol][1]}
                            for _sid in _p_subeler
                        ]).execute()
                        # Hesap e-posta gondermeden, dogrulanmis olarak acilir; kayit
                        # tetikleyicisi (182) kisiyi yeni isletme acmadan bu isletmeye baglar.
                        _admin.auth.admin.create_user(
                            {"email": _eposta, "password": _p_sifre, "email_confirm": True}
                        )
                        st.success(f"{_eposta} eklendi. Bu e-posta ve şifreyle giriş yapabilir.")
                        st.rerun()
                    except Exception as e:
                        if _personel_id:
                            try:
                                supabase.table("personel").delete().eq("id", _personel_id).execute()
                            except Exception:
                                pass
                        st.error(
                            f"Personel eklenemedi: {e}. E-posta başka bir hesapta kayıtlı olabilir."
                        )

    try:
        _personeller = (
            supabase.table("personel")
            .select("id, email, ad_soyad, aktif, kullanici_id, personel_sube_yetkileri(isletme_id, rol_sablonu, yetkiler)")
            .order("created_at")
            .execute()
        ).data or []
    except Exception:
        _personeller = []

    if not _personeller:
        st.info("Henüz personel eklemedin.")

    for _p in _personeller:
        _pid = _p["id"]
        _mevcut = {y["isletme_id"]: y for y in (_p.get("personel_sube_yetkileri") or [])}
        _durum = "Aktif" if _p.get("aktif") else "Durduruldu"
        if not _p.get("kullanici_id"):
            _durum += ", hesabı açılmamış"
        with st.expander(f"{_p.get('ad_soyad') or _p['email']} — {_p['email']} — {_durum}"):
            with st.form(f"personel_formu_{_pid}"):
                _aktif = st.checkbox("Aktif (işaret kaldırılırsa hiçbir işletmeye erişemez)", value=bool(_p.get("aktif")), key=f"p_aktif_{_pid}")
                _secimler = {}
                for _iid in _org_idleri:
                    st.markdown(f"**{_org_ad[_iid]}**")
                    _var = _iid in _mevcut
                    _k1, _k2 = st.columns([1, 2])
                    _calisir = _k1.checkbox("Bu işletmede çalışır", value=_var, key=f"p_calisir_{_pid}_{_iid}")
                    _eski_rol = (_mevcut.get(_iid) or {}).get("rol_sablonu") or "asci"
                    _rol = _k2.selectbox(
                        "Rol", _rol_secenekleri,
                        index=_rol_secenekleri.index(_eski_rol) if _eski_rol in _rol_secenekleri else 0,
                        format_func=lambda k: _rol_etiketi[k], key=f"p_rol_{_pid}_{_iid}",
                    )
                    _eski_yetkiler = (_mevcut.get(_iid) or {}).get("yetkiler") or HAZIR_ROLLER.get(_eski_rol, HAZIR_ROLLER["asci"])[1]
                    st.caption("Aşağıdaki ayarlar sadece rol 'Özel' iken kullanılır; hazır rolde o rolün seti uygulanır.")
                    _ozel = {}
                    _sutunlar = st.columns(5)
                    for _n, (_anahtar, _etiket, _aciklama, _seviyeler) in enumerate(YETKI_KATALOGU):
                        _kodlar = [kod for kod, _ in _seviyeler]
                        _etiketler = dict(_seviyeler)
                        _eski = _eski_yetkiler.get(_anahtar, _kodlar[0])
                        with _sutunlar[_n % 5]:
                            _ozel[_anahtar] = st.selectbox(
                                _etiket, _kodlar,
                                index=_kodlar.index(_eski) if _eski in _kodlar else 0,
                                format_func=lambda k, e=_etiketler: e[k],
                                help=_aciklama, key=f"p_yetki_{_pid}_{_iid}_{_anahtar}",
                            )
                    _secimler[_iid] = (_calisir, _rol, _ozel)
                _yeni_sifre = st.text_input(
                    "Yeni şifre belirle (boş bırakırsan değişmez)", type="password", key=f"p_sifre_{_pid}"
                )
                _kaydet = st.form_submit_button("Kaydet", type="primary")

            if _kaydet:
                try:
                    supabase.table("personel").update({"aktif": _aktif}).eq("id", _pid).execute()
                    for _iid, (_calisir, _rol, _ozel) in _secimler.items():
                        if _calisir:
                            _yetkiler = _ozel if _rol == OZEL_ROL[0] else HAZIR_ROLLER[_rol][1]
                            supabase.table("personel_sube_yetkileri").upsert(
                                {"personel_id": _pid, "isletme_id": _iid, "rol_sablonu": _rol, "yetkiler": _yetkiler},
                                on_conflict="personel_id,isletme_id",
                            ).execute()
                        elif _iid in _mevcut:
                            supabase.table("personel_sube_yetkileri").delete().eq(
                                "personel_id", _pid
                            ).eq("isletme_id", _iid).execute()
                    if _yeni_sifre:
                        if len(_yeni_sifre) < 8:
                            st.error("Şifre en az 8 karakter olmalı; şifre değiştirilmedi.")
                        elif _admin is None:
                            st.error("Service role anahtarı tanımlı değil; şifre değiştirilemedi.")
                        elif _p.get("kullanici_id"):
                            _admin.auth.admin.update_user_by_id(_p["kullanici_id"], {"password": _yeni_sifre})
                        else:
                            # Hesap onceden acilamadiysa simdi ac
                            _admin.auth.admin.create_user(
                                {"email": _p["email"], "password": _yeni_sifre, "email_confirm": True}
                            )
                    st.success("Kaydedildi.")
                    st.rerun()
                except Exception as e:
                    st.error(f"Kaydedilemedi: {e}")

    st.divider()
if _patron:

    # ---------------------------------------------------------------------
    # Isletme bilgileri (6 Agustos 2026 eklendi, 12 Agustos 2026 genisletildi:
    # adres + fatura adresi -- bkz. 47_isletme_adres_fatura_ekle.sql).
    # ---------------------------------------------------------------------
    st.subheader("İşletme Bilgileri")

    isletme_id = st.session_state.isletme_id
    isletme_bilgi = (
        supabase.table("isletmeler").select("*").eq("id", isletme_id).single().execute()
    ).data or {}

    with st.form("isletme_bilgi_formu"):
        ad_sutunu, kisaltma_sutunu = st.columns([2, 1])
        yeni_ad = ad_sutunu.text_input("İşletme adı", value=isletme_bilgi.get("ad") or "")
        yeni_kisaltma = kisaltma_sutunu.text_input(
            "İşletme kısaltılmış adı", value=isletme_bilgi.get("kisaltma") or "",
            max_chars=12,
            help="Reçete Üretimi'nde oluşturduğun her yeni reçetenin adının "
            "sonuna otomatik olarak eklenir (ör. \"Tavuk Sote (ACM)\") -- "
            "boş bırakırsan hiçbir şey eklenmez.",
        )
        st.caption(
            "İşletme adı, Aylık Menü sayfasındaki işletmenin kendi özel "
            "menüsünü dahil etme butonunun üzerinde görünür."
        )
        yeni_adres = st.text_area(
            "İşletme adresi", value=isletme_bilgi.get("adres") or "", height=80,
        )
        yeni_fatura_adresi = st.text_area(
            "Fatura adresi",
            value=isletme_bilgi.get("fatura_adresi") or "",
            height=80,
            help="İşletme adresinden farklıysa buraya ayrı gir; aynıysa boş bırakabilirsin.",
        )
        yeni_vergi_dairesi = st.text_input(
            "Vergi dairesi", value=isletme_bilgi.get("vergi_dairesi") or "",
        )
        yeni_vergi_no = st.text_input(
            "Vergi numarası", value=isletme_bilgi.get("vergi_no") or "",
        )
        if st.form_submit_button("Kaydet"):
            if not yeni_ad.strip():
                st.error("İşletme adı boş olamaz.")
            else:
                sonuc = (
                    supabase.table("isletmeler")
                    .update({
                        "ad": yeni_ad.strip(),
                        "kisaltma": yeni_kisaltma.strip() or None,
                        "adres": yeni_adres.strip() or None,
                        "fatura_adresi": yeni_fatura_adresi.strip() or None,
                        "vergi_dairesi": yeni_vergi_dairesi.strip() or None,
                        "vergi_no": yeni_vergi_no.strip() or None,
                    })
                    .eq("id", isletme_id)
                    .execute()
                )
                # NOT (6 Agustos 2026): Daha once burada sonucu kontrol etmeden
                # "Kaydedildi" gosteriliyordu -- ama kullanici gercekte
                # kaydedilmedigini (bir sonraki ziyarette eski deger -- e-posta
                # -- geri geldigini) fark etti. Supabase, RLS politikasi
                # guncellemeyi SESSIZCE reddederse (hata FIRLATMAZ, sadece
                # bos bir sonuc doner) -- bu yuzden sonuc.data'nin GERCEKTEN
                # dolu olup olmadigini kontrol ediyoruz.
                if sonuc.data:
                    st.success("Kaydedildi.")
                    st.rerun()
                else:
                    st.error(
                        "Kaydetme işlemi veritabanı tarafından reddedildi (muhtemelen "
                        "bir RLS/izin politikası engelliyor) -- hiçbir hata mesajı "
                        "dönmedi ama satır güncellenmedi. Supabase'de "
                        "\"isletmeler\" tablosunun RLS politikalarını kontrol etmek "
                        "gerekiyor."
                    )

    st.divider()
if _patron or yetki("maliyet_ayarlari") >= 1:

    # ---------------------------------------------------------------------
    # Isletme maliyet ayarlari (24 Agustos 2026: Recete Uretimi sayfasindan
    # BURAYA tasindi -- kullanicinin gerekcesi: bu ayarlar tek bir receteye
    # ozgu degil, isletmenin TUM receteleri (kendi ozel receteleri + Yillik
    # Menu'deki hazir kutuphane tarifleri DAHIL) icin gecerli, o yuzden dogal
    # yeri "hesap/isletme genelinde" bir ayar sayfasidir, tek tek recete
    # calisilirken karsina cikan bir form degil.
    #
    # Genel gider payi alani (12 Agustos 2026'da hesaplamalardan cikarilmis
    # ama BU FORMDA hala soruluyordu) BURADAN DA KALDIRILDI -- artik hicbir
    # hesaplamada kullanilmiyor, formda birakmak kullaniciyi yanlis
    # yonlendirirdi ("bunu degistirsem maliyete yansir mi" sorusu). Alttaki
    # genel_gider_yuzdesi DB sutunu DOKUNULMADI (silinmedi) -- sadece
    # arayuzden kaldirildi, ileride geri getirilmek istenirse veri kaybi
    # olmaz.
    # ---------------------------------------------------------------------
    st.subheader("İşletme Maliyet Ayarları")
    _kutuphane_tarif_sayisi = _varsayilan_kutuphane_tarif_sayisi()
    st.caption(
        "Bu ayarlar Reçete Üretimi sayfasında değil buradadır, çünkü tek "
        "bir reçeteye değil işletmenin TÜM reçetelerine birden uygulanır -- "
        "hem kendi oluşturduğun özel reçetelere, hem de Aylık Menü "
        f"sayfasındaki hazır {_kutuphane_tarif_sayisi} tariflik kütüphaneden "
        "ürettiğin menülere. "
        "Malzeme maliyetleri (fiyatlar) zaten sistemde ayrı olarak "
        "tutuluyor, burada SADECE enerji ve işçilik birim fiyatları var. "
        "Aşağıdaki rakamlar başlangıç için makul TAHMİNİ değerlerdir -- "
        "işletmenin gerçek elektrik, doğalgaz ve saatlik personel maliyeti "
        "bu değerlerden farklıysa burada değiştirebilirsin; yaptığın "
        "değişiklik hesaplanan TÜM porsiyon maliyetlerine (default gelen "
        f"{_kutuphane_tarif_sayisi} reçete dahil) anında yansır."
    )

    ayar_sonuc = (
        supabase.table("isletme_maliyet_ayarlari")
        .select("*")
        .eq("isletme_id", isletme_id)
        .execute()
    )
    maliyet_ayarlari = ayar_sonuc.data[0] if ayar_sonuc.data else None

    if maliyet_ayarlari is None and yetki("maliyet_ayarlari") >= 2:
        yeni_ayar = (
            supabase.table("isletme_maliyet_ayarlari")
            .insert({"isletme_id": isletme_id})
            .execute()
        )
        maliyet_ayarlari = yeni_ayar.data[0]

    if maliyet_ayarlari is None:
        st.info("Bu işletme için maliyet ayarı henüz girilmemiş.")
    if maliyet_ayarlari is not None:
      with st.form("maliyet_ayarlari_formu"):
        mc1, mc2, mc3 = st.columns(3)
        elektrik = mc1.number_input(
            "Elektrik (€/kWh)",
            value=float(maliyet_ayarlari["elektrik_birim_fiyat_eur_kwh"]), step=0.01,
        )
        dogalgaz = mc2.number_input(
            "Doğalgaz (€/kWh)",
            value=float(maliyet_ayarlari["dogalgaz_birim_fiyat_eur_kwh"]), step=0.01,
        )
        saat_ucreti = mc3.number_input(
            "Personel saat ücreti (€)",
            value=float(maliyet_ayarlari["personel_saat_ucreti_eur"]), step=0.5,
        )
        if st.form_submit_button("Kaydet", disabled=yetki("maliyet_ayarlari") < 2):
            supabase.table("isletme_maliyet_ayarlari").update(
                {
                    "elektrik_birim_fiyat_eur_kwh": elektrik,
                    "dogalgaz_birim_fiyat_eur_kwh": dogalgaz,
                    "personel_saat_ucreti_eur": saat_ucreti,
                }
            ).eq("isletme_id", isletme_id).execute()
            st.success("Kaydedildi -- tüm reçetelerin maliyeti güncellendi.")
            st.rerun()

    st.divider()
if yetki("porsiyon_profilleri") >= 2:

    # ---------------------------------------------------------------------
    # PORSIYON PROFİLLERİ (3 Eylül 2026 eklendi, 79 numarali migration).
    # Yillik Menu pop-up'inin maliyet hesabi icin kullanilan porsiyon
    # sayilari BURADA yonetiliyor -- Bahri'nin belirttigi gercek durum:
    # bir isletme (ör. bir yemek fabrikasi) AYNI ANDA birden fazla
    # musteriye, HER BIRINE FARKLI porsiyon sayisiyla uretim yapabilir
    # (ör. Musteri A: 100, Musteri B: 30, Musteri C: 75). Tek bir sayi bu
    # durumu temsil edemezdi (bkz. 78 numarali migration'in supurulmesi).
    # Tek musterili isletmeler icin sistem otomatik TEK bir "Standart"
    # profil olusturur -- bu isletmeler hicbir ekstra karmasiklik gormez.
    # ---------------------------------------------------------------------
    st.subheader("Porsiyon Profilleri")
    st.caption(
        "Aylık Menü sayfasındaki maliyet hesabı bu porsiyon sayılarını "
        "kullanır. Tek bir müşterin/tipik üretim miktarın varsa tek satır "
        "yeterli. Birden fazla müşteriye farklı porsiyon sayılarıyla "
        "üretim yapıyorsan (ör. bir yemek fabrikası), her müşteri için "
        "ayrı bir satır ekleyebilirsin -- Aylık Menü'de hangisini "
        "görüntülemek istediğini seçebileceksin."
    )

    profil_sonuc = (
        supabase.table("isletme_porsiyon_profilleri")
        .select("*")
        .eq("isletme_id", isletme_id)
        .order("sira")
        .execute()
    )
    porsiyon_profilleri = profil_sonuc.data or []

    if not porsiyon_profilleri:
        # Guvenlik agi -- 79 numarali migration zaten her isletme icin bir
        # "Standart" profil olusturuyor, ama migration'dan SONRA olusan bir
        # isletme buraya bos gelebilir, o durumda burada olusturulur.
        yeni_profil = (
            supabase.table("isletme_porsiyon_profilleri")
            .insert({"isletme_id": isletme_id, "ad": "Standart", "porsiyon_sayisi": 10, "sira": 0})
            .execute()
        )
        porsiyon_profilleri = yeni_profil.data

    _profil_df = pd.DataFrame([
        {"id": p["id"], "Ad": p["ad"], "Porsiyon Sayısı": p["porsiyon_sayisi"]}
        for p in porsiyon_profilleri
    ])

    _duzenlenmis_df = st.data_editor(
        _profil_df,
        column_config={
            "id": None,
            "Ad": st.column_config.TextColumn(required=True),
            "Porsiyon Sayısı": st.column_config.NumberColumn(min_value=1, step=1, required=True),
        },
        num_rows="dynamic",
        hide_index=True,
        key="porsiyon_profil_editor",
        use_container_width=True,
    )

    if st.button("Porsiyon profillerini kaydet"):
        _gecerli_mi = True
        if len(_duzenlenmis_df) == 0:
            st.error("En az bir profil olmalı.")
            _gecerli_mi = False
        elif _duzenlenmis_df["Ad"].isna().any() or _duzenlenmis_df["Porsiyon Sayısı"].isna().any():
            st.error("Tüm satırlarda Ad ve Porsiyon Sayısı dolu olmalı.")
            _gecerli_mi = False

        if _gecerli_mi:
            _eski_idler = {p["id"] for p in porsiyon_profilleri}
            _yeni_idler = {i for i in _duzenlenmis_df["id"] if pd.notna(i)}
            for _silinecek_id in _eski_idler - _yeni_idler:
                supabase.table("isletme_porsiyon_profilleri").delete().eq("id", _silinecek_id).execute()

            for _sira, (_, _satir) in enumerate(_duzenlenmis_df.iterrows()):
                if pd.isna(_satir["id"]):
                    supabase.table("isletme_porsiyon_profilleri").insert({
                        "isletme_id": isletme_id,
                        "ad": _satir["Ad"],
                        "porsiyon_sayisi": int(_satir["Porsiyon Sayısı"]),
                        "sira": _sira,
                    }).execute()
                else:
                    supabase.table("isletme_porsiyon_profilleri").update({
                        "ad": _satir["Ad"],
                        "porsiyon_sayisi": int(_satir["Porsiyon Sayısı"]),
                        "sira": _sira,
                    }).eq("id", _satir["id"]).execute()

            st.success("Porsiyon profilleri kaydedildi.")
            st.rerun()

    # ---------------------------------------------------------------------
    # PROFİL BAŞINA BESİN HEDEFLERİ (4 Eylül 2026 eklendi, 80 numarali
    # migration). Bahri'nin senaryosu: bir isletmenin (yemek fabrikasi)
    # farkli musteri TIPLERI olabilir -- hastane, spor salonu, ilkokul,
    # huzur evi, tatil koyu -- her birinin besin hedefi KOKTEN farkli
    # olmali. Burada SECILEN profile hedef kaydedilir; Aylik Menu
    # sayfasinda o profil secildiginde bu hedefler OTOMATIK yuklenir.
    # ---------------------------------------------------------------------
    st.markdown("##### Profil Başına Besin Hedefleri")
    st.caption(
        "Yukarıdaki profillerden birini seç ve o profile özel besin hedefi "
        "aralıkları tanımla (ör. \"Huzur Evi\" için düşük sodyum, \"Spor "
        "Salonu\" için yüksek protein). Aylık Menü sayfasında bu profili "
        "seçtiğinde buradaki hedefler otomatik yüklenir -- ihtiyaç halinde "
        "o an için yine değiştirebilirsin."
    )

    # porsiyon_profilleri degiskeni yukarida (kaydetmeden ONCEKI liste)
    # zaten mevcut -- ama kullanici az once yeni bir profil eklediyse
    # rerun sonrasi taze veriyle calismak icin tekrar cekiyoruz.
    _hedef_profil_listesi = (
        supabase.table("isletme_porsiyon_profilleri")
        .select("*")
        .eq("isletme_id", isletme_id)
        .order("sira")
        .execute()
    ).data or []

    if _hedef_profil_listesi:
        _hedef_profil_etiketleri = [f"{p['ad']} ({p['porsiyon_sayisi']} porsiyon)" for p in _hedef_profil_listesi]
        _hedef_secili_index = st.selectbox(
            "Hangi profilin hedeflerini düzenliyorsun?",
            options=range(len(_hedef_profil_etiketleri)),
            format_func=lambda i: _hedef_profil_etiketleri[i],
            key="hedef_duzenleme_profil_secimi",
        )
        _secili_hedef_profili = _hedef_profil_listesi[_hedef_secili_index]
        _profil_id = _secili_hedef_profili["id"]
        _kayitli_hedefler = _secili_hedef_profili.get("hedefler") or {}

        # SEKSEN IKINCI DUZELTME (4 Eylul 2026): bu sayfadaki widget'lar,
        # Aylik Menu sayfasindaki ("Öğle_kalori_alt" gibi) ANAHTARLARLA
        # KESINLIKLE CAKISMAMALI -- Streamlit session_state SAYFALAR ARASI
        # PAYLASILIYOR, ayni key kullanilsaydi bir profilin hedefini
        # duzenlemek, Aylik Menu'deki O ANKI uretim hedefini SESSIZCE
        # degistirebilirdi. Bu yuzden HER key'e "abn_{profil_id}_" onekini
        # ekliyoruz -- hem sayfalar arasi hem PROFILLER ARASI carpismayi
        # onluyor.
        _anahtar_on_eki = f"abn_{_profil_id}_"

        # YUZ OTUZ DORDUNCU DUZELTME (9 Eylul 2026): "Şablondan başlat" --
        # STANDART_PROFILLER'daki arastirilmis kaliplardan birini secip
        # BASLANGIC noktasi olarak uygulama kolayligi. Bu bir KISIT DEGIL,
        # sadece bir kisayol -- uygulandiktan sonra asagidaki alanlar
        # (multiselect + sayi kutulari) ile GENE serbestce degistirilebilir,
        # kaydetmeden once. Profil sistemi zaten tamamen ozgur (herhangi bir
        # kullanici sinirsiz sayida ozel profil/grup olusturabilir) --
        # sablonlar bu ozgurlugu KISITLAMIYOR, sadece hizlandiriyor.
        _sablon_secimi = st.selectbox(
            "Hazır şablondan başlat (opsiyonel)",
            options=["(Boş — elle gir)"] + list(STANDART_PROFILLER.keys()),
            key=f"{_anahtar_on_eki}sablon_secimi",
            help="Bir şablon seçip uyguladıktan sonra aşağıdaki alanları yine istediğin gibi değiştirip kaydedebilirsin.",
        )
        if _sablon_secimi != "(Boş — elle gir)":
            if st.button(f"\"{_sablon_secimi}\" şablonunu uygula", key=f"{_anahtar_on_eki}sablon_uygula"):
                _sablon_hedef = {anahtar: list(aralik) for anahtar, aralik in STANDART_PROFILLER[_sablon_secimi].items()}
                supabase.table("isletme_porsiyon_profilleri").update(
                    {"hedefler": {"Öğle": _sablon_hedef, "Akşam": _sablon_hedef}}
                ).eq("id", _profil_id).execute()
                st.success(f"\"{_sablon_secimi}\" şablonu uygulandı — aşağıdan istersen düzenleyip tekrar kaydedebilirsin.")
                st.rerun()

        _profil_secili_anahtarlar = kanonik_sirala(
            {anahtar for ogun in _kayitli_hedefler.values() for anahtar in ogun}
        ) or ["kalori", "protein", "yag", "karbonhidrat", "gi"]

        _secili_besin_anahtarlari_abn = st.multiselect(
            "Hedeflenecek besin değerleri",
            options=[anahtar for anahtar, *_ in TUM_BESIN_ALANLARI],
            default=_profil_secili_anahtarlar,
            format_func=lambda a: BESIN_ETIKET[a],
            key=f"{_anahtar_on_eki}secili_besin_anahtarlari",
        )

        _yeni_hedefler = {}
        for _ogun_adi in ("Öğle", "Akşam"):
            with st.expander(f"{_ogun_adi} hedefleri", expanded=False):
                _yeni_hedefler[_ogun_adi] = {}
                if not _secili_besin_anahtarlari_abn:
                    st.caption("Yukarıdan en az bir besin değeri seçmelisin.")
                for _anahtar in _secili_besin_anahtarlari_abn:
                    _etiket = BESIN_ETIKET[_anahtar]
                    _minv, _maxv, _def_alt, _def_ust = (float(x) for x in BESIN_ARALIK[_anahtar])
                    _kayitli_aralik = _kayitli_hedefler.get(_ogun_adi, {}).get(_anahtar)
                    if _kayitli_aralik:
                        _def_alt, _def_ust = float(_kayitli_aralik[0]), float(_kayitli_aralik[1])
                    _c1, _c2 = st.columns(2)
                    with _c1:
                        _alt = st.number_input(
                            f"{_etiket} — min", min_value=_minv, max_value=_maxv,
                            value=_def_alt, key=f"{_anahtar_on_eki}{_ogun_adi}_{_anahtar}_alt",
                        )
                    with _c2:
                        _ust = st.number_input(
                            f"{_etiket} — maks", min_value=_minv, max_value=_maxv,
                            value=_def_ust, key=f"{_anahtar_on_eki}{_ogun_adi}_{_anahtar}_ust",
                        )
                    _yeni_hedefler[_ogun_adi][_anahtar] = [_alt, _ust]

        if st.button("Bu profilin besin hedeflerini kaydet", key=f"{_anahtar_on_eki}kaydet"):
            supabase.table("isletme_porsiyon_profilleri").update(
                {"hedefler": _yeni_hedefler if _secili_besin_anahtarlari_abn else None}
            ).eq("id", _profil_id).execute()
            st.success(f"\"{_secili_hedef_profili['ad']}\" profilinin besin hedefleri kaydedildi.")
            st.rerun()

    st.divider()

# ---------------------------------------------------------------------
# Hesap bilgileri: e-posta / sifre degistirme (12 Agustos 2026 eklendi).
# supabase.auth.update_user() -- Supabase'in resmi, dokumante edilmis
# yontemi, gecerli oturumun kendi e-posta/sifresini degistirir.
# E-POSTA DEGISIKLIGI ICIN ONEMLI NOT: Supabase varsayilan olarak YENI
# adrese bir dogrulama baglantisi gonderir -- degisiklik o baglantiya
# tiklanana kadar TAMAMLANMAZ. Bu, kodun bir eksigi degil, Supabase'in
# kendi guvenlik davranisi -- kullaniciya arayuzde acikca belirtiliyor.
# ---------------------------------------------------------------------
st.subheader("Hesap Bilgileri")

if not _personel_mi:  # personelin giris e-postasi patronun kaydiyla ayni kalmali
    with st.form("eposta_degistir_formu"):
        st.caption(
            "E-posta değiştirmek, yeni adrese bir doğrulama bağlantısı gönderir "
            "-- değişiklik o bağlantıya tıklanana kadar tamamlanmaz."
        )
        yeni_eposta = st.text_input("Yeni e-posta")
        if st.form_submit_button("E-postayı değiştir"):
            if not yeni_eposta.strip():
                st.error("E-posta boş olamaz.")
            else:
                try:
                    supabase.auth.update_user({"email": yeni_eposta.strip()})
                    st.success(
                        f"Doğrulama bağlantısı {yeni_eposta.strip()} adresine gönderildi. "
                        "Bağlantıya tıklayana kadar giriş e-postan değişmez."
                    )
                except Exception as e:
                    st.error(f"E-posta değiştirilemedi: {e}")

with st.form("sifre_degistir_formu"):
    yeni_sifre = st.text_input("Yeni şifre (en az 8 karakter)", type="password")
    yeni_sifre_tekrar = st.text_input("Yeni şifre (tekrar)", type="password")
    if st.form_submit_button("Şifreyi değiştir"):
        if not yeni_sifre or len(yeni_sifre) < 8:
            st.error("Şifre en az 8 karakter olmalı.")
        elif yeni_sifre != yeni_sifre_tekrar:
            st.error("Şifreler eşleşmiyor.")
        else:
            try:
                supabase.auth.update_user({"password": yeni_sifre})
                st.success("Şifren değiştirildi.")
            except Exception as e:
                st.error(f"Şifre değiştirilemedi: {e}")

st.divider()

cerezler = cerez_yoneticisi()
if st.button("Çıkış yap", type="primary"):
    supabase.auth.sign_out()
    st.session_state.oturum = None
    cerezler.delete("refresh_token", key="refresh_token_cikis_abonelik_sayfasi")
    st.rerun()
