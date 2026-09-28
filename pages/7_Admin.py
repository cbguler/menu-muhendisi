# pages/7_Admin.py
#
# Sadece admin'e acik sayfa -- st.navigation() listesine sadece admin
# oturumunda ekleniyor, bu yuzden baskasi URL'yi bilse bile ulasamiyor.
# Savunma amacli burada da ayrica kontrol ediliyor.
#
# YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9, Bahri'nin acik talebi:
# "admin olarak aboneler uzerinde neler yapabiliyorsam burada tumunu
# gormeliyim"): sayfa uc bolume genisletildi.
#   (1) Bekleyen Onaylar -- eskisiyle ayni ("Onayla" -> durum='aktif').
#   (2) Aboneler -- TUM abonelikler, duruma gore filtrelenebilir. Her abone
#       icin plan, durum, donem baslangic/bitis (bos = suresiz) degistirilir;
#       isletmenin kullanicilari ve personeli gorulur. Eski "Aktif
#       Abonelikler / Iptal Et" bolumu bunun icine alindi: iptal, durum
#       listesinden 'iptal_edildi' secilip onay kutusu isaretlenerek yapilir;
#       iptal edilmis bir hesap ayni yoldan tekrar 'aktif' yapilabilir.
#   (3) Planlar -- Temel/Pro/Kurumsal'in adi, fiyatlari, limitleri (bos =
#       sinirsiz) ve aktifligi duzenlenir. YUZ ... DUZELTME (28 Eylul 2026):
#       "Ozellikler" kutulari (boston_matrisi, satis_analitik, ozel_destek)
#       Bahri'nin karariyla KALDIRILDI -- uygulama satis verisi toplayan bir
#       satis destek uygulamasi degil; planlar SADECE sube ve recete limitiyle
#       ayrilir. Veritabanindaki ozellikler kolonuna dokunulmuyor (kodda hicbir
#       yerde kullanilmiyordu), guncelleme de o kolonu artik yazmiyor.
#   (4) Admin Yetkileri -- SADECE ana admin (Bahri) gorur. Aday listesindeki
#       kisilerin (Emre; ileride Gizem) admin hakki acilip kapatilir. Aday
#       listesi sql/178'de sabit; buradan yeni aday eklenemez.
#
# Yetki: sql/177_admin_yetkisi_ve_plan_yonetimi.sql'deki auth_admin_mi()
# fonksiyonuna bagli RLS politikalari. 177 calistirilmadan (2) icindeki
# kullanici/personel listesi bos, (3) kaydetme reddedilir.
# Admin listesi SADECE o fonksiyonda (Bahri; ileride yalnizca Emre/Gizem).

from datetime import date, datetime, timezone

import streamlit as st

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Admin", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

if not st.session_state.get("admin_mi"):
    st.error("Bu sayfaya erişimin yok.")
    st.stop()

st.title("Admin")

DURUM_ETIKETLERI = {
    "aktif": "Aktif",
    "odeme_alindi_onay_bekliyor": "Ödeme alındı, onay bekliyor",
    "odeme_bekleniyor": "Ödeme bekleniyor",
    "odeme_gecikti": "Ödeme gecikti",
    "iptal_edildi": "İptal edildi",
    "suresi_doldu": "Süresi doldu",
    "deneme": "Deneme",
}
# Erisimi kesen durumlar -- secilirse ayrica onay istenir
ERISIMI_KESEN = {"iptal_edildi", "suresi_doldu"}



def _tarih(deger):
    """Supabase'ten gelen 'YYYY-MM-DD' metnini date'e cevirir (bos -> None)."""
    if not deger:
        return None
    return date.fromisoformat(str(deger)[:10])


def _durum_etiketi(kod):
    return DURUM_ETIKETLERI.get(kod, kod or "-")


def _plan_adi(abonelik):
    # YUZ ... DUZELTME: .get("ad", "?") plan NULL iken "?" gosteriyordu
    return (abonelik.get("abonelik_planlari") or {}).get("ad") or "Plan atanmamış"


planlar = (
    supabase.table("abonelik_planlari")
    .select("*")
    .order("created_at")
    .execute()
).data or []
# Kodlarin sabit sirasi: temel, pro, kurumsal; digerleri sonda
_sira = {"temel": 0, "pro": 1, "kurumsal": 2}
planlar.sort(key=lambda p: _sira.get(p.get("kod"), 99))
plan_adlari = {p["id"]: p["ad"] for p in planlar}

# -----------------------------------------------------------------------
# 1) BEKLEYEN ONAYLAR
# -----------------------------------------------------------------------
st.subheader("Bekleyen Onaylar")
st.caption(
    "Ödemesi alınmış ama henüz onaylanmamış abonelikler burada listelenir. "
    "Onaylayınca hesap tam erişime geçer."
)

bekleyenler = (
    supabase.table("abonelikler")
    .select("id, isletme_id, plan_id, durum, isletmeler(ad), abonelik_planlari(kod, ad)")
    .eq("durum", "odeme_alindi_onay_bekliyor")
    .execute()
).data or []

if not bekleyenler:
    st.info("Onay bekleyen abonelik yok.")
else:
    for abonelik in bekleyenler:
        isletme_adi = (abonelik.get("isletmeler") or {}).get("ad") or "?"
        with st.container(border=True):
            c1, c2 = st.columns([4, 1])
            with c1:
                st.write(f"**{isletme_adi}** — {_plan_adi(abonelik)}")
            with c2:
                if st.button("Onayla", key=f"onayla_{abonelik['id']}", type="primary"):
                    # RLS UPDATE'i sessizce reddedebilir (hata firlatmaz, 0 satir
                    # etkilenir) -- bu yuzden sonuc.data kontrol ediliyor.
                    sonuc = (
                        supabase.table("abonelikler")
                        .update({"durum": "aktif"})
                        .eq("id", abonelik["id"])
                        .execute()
                    )
                    if sonuc.data:
                        st.success(f"'{isletme_adi}' onaylandı.")
                        st.rerun()
                    else:
                        st.error(
                            "Onaylama veritabanı tarafından reddedildi "
                            "(muhtemelen bir RLS/izin politikası engelliyor)."
                        )

st.divider()

# -----------------------------------------------------------------------
# 2) ABONELER
# -----------------------------------------------------------------------
st.subheader("Aboneler")
st.caption(
    "Plan, durum ve dönem tarihlerini buradan değiştirebilirsin. "
    "'İptal edildi' veya 'Süresi doldu' hesabın erişimini keser; aynı yoldan tekrar 'Aktif' yapılabilir."
)

kendi_isletme_id = st.session_state.get("isletme_id")

tum_abonelikler = (
    supabase.table("abonelikler")
    .select(
        "id, isletme_id, plan_id, durum, donem_baslangic, donem_bitis, "
        "created_at, isletmeler(ad), abonelik_planlari(kod, ad)"
    )
    .order("created_at", desc=True)
    .execute()
).data or []
# Admin'in KENDI isletmesi listede degistirilebilir gorunmesin
tum_abonelikler = [a for a in tum_abonelikler if a.get("isletme_id") != kendi_isletme_id]

# Isletme basina kullanicilar ve personel (177'deki admin okuma politikalari)
kullanicilar = (
    supabase.table("kullanicilar").select("id, isletme_id, rol, ad_soyad").execute()
).data or []
try:
    personel = (
        # YUZ ... DUZELTME (28 Eylul 2026, sql/182): personel_yetkileri yerine
        # personel tablosu (ana_isletme_id); abonelik ana isletmeye bagli.
        supabase.table("personel")
        .select("ana_isletme_id, email, ad_soyad, aktif, kullanici_id")
        .execute()
    ).data or []
except Exception:
    personel = []

filtre_secenekleri = ["Tümü"] + list(DURUM_ETIKETLERI.keys())
filtre = st.selectbox(
    "Duruma göre filtrele",
    filtre_secenekleri,
    format_func=lambda k: "Tümü" if k == "Tümü" else _durum_etiketi(k),
)
gosterilecek = [a for a in tum_abonelikler if filtre == "Tümü" or a.get("durum") == filtre]

if not gosterilecek:
    st.info("Bu filtreye uyan abone yok (kendi hesabın hariç).")

plan_secenekleri = [None] + [p["id"] for p in planlar]

for abonelik in gosterilecek:
    aid = abonelik["id"]
    isletme_adi = (abonelik.get("isletmeler") or {}).get("ad") or "?"
    baslik = f"{isletme_adi} — {_plan_adi(abonelik)} — {_durum_etiketi(abonelik.get('durum'))}"
    with st.expander(baslik):
        with st.form(f"abonelik_form_{aid}"):
            c1, c2 = st.columns(2)
            with c1:
                mevcut_plan = abonelik.get("plan_id")
                yeni_plan = st.selectbox(
                    "Plan",
                    plan_secenekleri,
                    index=plan_secenekleri.index(mevcut_plan) if mevcut_plan in plan_secenekleri else 0,
                    format_func=lambda pid: "Plan atanmamış" if pid is None else plan_adlari.get(pid, "?"),
                    key=f"plan_{aid}",
                )
                durum_listesi = list(DURUM_ETIKETLERI.keys())
                mevcut_durum = abonelik.get("durum")
                yeni_durum = st.selectbox(
                    "Durum",
                    durum_listesi,
                    index=durum_listesi.index(mevcut_durum) if mevcut_durum in durum_listesi else 0,
                    format_func=_durum_etiketi,
                    key=f"durum_{aid}",
                )
            with c2:
                yeni_baslangic = st.date_input(
                    "Dönem başlangıcı",
                    value=_tarih(abonelik.get("donem_baslangic")) or date.today(),
                    format="DD.MM.YYYY",
                    key=f"baslangic_{aid}",
                )
                mevcut_bitis = _tarih(abonelik.get("donem_bitis"))
                suresiz = st.checkbox(
                    "Süresiz (bitiş tarihi yok)", value=mevcut_bitis is None, key=f"suresiz_{aid}"
                )
                secilen_bitis = st.date_input(
                    "Dönem bitişi (süresiz işaretliyse dikkate alınmaz)",
                    value=mevcut_bitis or date.today(),
                    format="DD.MM.YYYY",
                    key=f"bitis_{aid}",
                )

            erisim_kesiliyor = yeni_durum in ERISIMI_KESEN and yeni_durum != mevcut_durum
            onay = st.checkbox(
                "Bu hesabın erişimini kesmek istediğimi onaylıyorum "
                "(sadece 'İptal edildi' veya 'Süresi doldu' seçildiğinde gerekir)",
                key=f"onay_{aid}",
            )
            kaydet = st.form_submit_button("Kaydet", type="primary")

        if kaydet:
            yeni_bitis = None if suresiz else secilen_bitis
            if erisim_kesiliyor and not onay:
                st.error("Erişimi kesen bir durum seçtin; kaydetmek için onay kutusunu işaretle.")
            elif yeni_bitis is not None and yeni_bitis < yeni_baslangic:
                st.error("Dönem bitişi, başlangıçtan önce olamaz.")
            else:
                sonuc = (
                    supabase.table("abonelikler")
                    .update({
                        "plan_id": yeni_plan,
                        "durum": yeni_durum,
                        "donem_baslangic": yeni_baslangic.isoformat(),
                        "donem_bitis": yeni_bitis.isoformat() if yeni_bitis else None,
                    })
                    .eq("id", aid)
                    .execute()
                )
                if sonuc.data:
                    st.success(f"'{isletme_adi}' güncellendi.")
                    st.rerun()
                else:
                    st.error(
                        "Güncelleme veritabanı tarafından reddedildi "
                        "(muhtemelen bir RLS/izin politikası engelliyor)."
                    )

        # Kullanicilar ve personel (salt okunur)
        isletme_kullanicilari = [k for k in kullanicilar if k.get("isletme_id") == abonelik.get("isletme_id")]
        isletme_personeli = [p for p in personel if p.get("ana_isletme_id") == abonelik.get("isletme_id")]
        st.markdown("**Kullanıcılar**")
        if not isletme_kullanicilari:
            st.caption("Kullanıcı bilgisi okunamadı (177 çalıştırıldı mı?).")
        else:
            satirlar = []
            for k in isletme_kullanicilari:
                p = next((x for x in isletme_personeli if x.get("kullanici_id") == k["id"]), None)
                satirlar.append({
                    "Rol": k.get("rol") or "-",
                    "Ad soyad": k.get("ad_soyad") or "-",
                    "E-posta": (p or {}).get("email") or ("(işletme sahibi)" if k.get("rol") == "sahip" else "-"),
                    "Durum": "-" if p is None else ("Aktif" if p.get("aktif") else "Durduruldu"),
                })
            st.dataframe(satirlar, hide_index=True, use_container_width=True)
        bekleyen_personel = [p for p in isletme_personeli if not p.get("kullanici_id")]
        if bekleyen_personel:
            st.caption(
                "Hesabı henüz açılmamış personel: "
                + ", ".join(p.get("email") or "?" for p in bekleyen_personel)
            )

st.divider()

# -----------------------------------------------------------------------
# 3) PLANLAR
# -----------------------------------------------------------------------
st.subheader("Planlar")
st.caption(
    "Fiyat ve limit alanlarını boş bırakmak 'tanımsız / sınırsız' anlamına gelir. "
    "Değişiklik, o plandaki bütün abonelere bir sonraki girişlerinde yansır."
)

def _sayi_ya_da_none(deger, tam_sayi=False):
    if deger is None:
        return None
    return int(deger) if tam_sayi else float(deger)


for plan in planlar:
    pid = plan["id"]
    with st.expander(f"{plan['ad']} ({plan['kod']})" + ("" if plan.get("aktif_mi") else " — pasif")):
        with st.form(f"plan_form_{pid}"):
            c1, c2, c3 = st.columns(3)
            with c1:
                ad = st.text_input("Plan adı", value=plan.get("ad") or "", key=f"ad_{pid}")
                aktif_mi = st.checkbox("Aktif (yeni abonelere sunulur)", value=bool(plan.get("aktif_mi")), key=f"aktif_{pid}")
            with c2:
                aylik = st.number_input(
                    "Aylık fiyat (EUR)", min_value=0.0, step=1.0,
                    value=_sayi_ya_da_none(plan.get("aylik_fiyat_eur")), key=f"aylik_{pid}",
                )
                yillik = st.number_input(
                    "Yıllık fiyat (EUR)", min_value=0.0, step=1.0,
                    value=_sayi_ya_da_none(plan.get("yillik_fiyat_eur")), key=f"yillik_{pid}",
                )
            with c3:
                sube = st.number_input(
                    "Şube limiti (boş = sınırsız)", min_value=1, step=1,
                    value=_sayi_ya_da_none(plan.get("sube_limiti"), tam_sayi=True), key=f"sube_{pid}",
                )
                recete = st.number_input(
                    "Reçete limiti (boş = sınırsız)", min_value=1, step=1,
                    value=_sayi_ya_da_none(plan.get("recete_limiti"), tam_sayi=True), key=f"recete_{pid}",
                )
            plan_kaydet = st.form_submit_button("Planı kaydet", type="primary")

        if plan_kaydet:
            if not ad.strip():
                st.error("Plan adı boş olamaz.")
            else:
                sonuc = (
                    supabase.table("abonelik_planlari")
                    .update({
                        "ad": ad.strip(),
                        "aktif_mi": aktif_mi,
                        "aylik_fiyat_eur": aylik,
                        "yillik_fiyat_eur": yillik,
                        "sube_limiti": sube,
                        "recete_limiti": recete,
                    })
                    .eq("id", pid)
                    .execute()
                )
                if sonuc.data:
                    st.success(f"'{ad.strip()}' planı kaydedildi.")
                    st.rerun()
                else:
                    st.error(
                        "Kaydetme veritabanı tarafından reddedildi "
                        "(177 çalıştırılmadıysa plan güncelleme izni yoktur)."
                    )


# -----------------------------------------------------------------------
# KULLANIM ISTATISTIKLERI (29 Eylul 2026, sql/183 kullanim_olaylari)
# Bahri'nin istegi: abonelerin giris, cikis, hangi sayfada ne kadar kaldigi.
# SURE TAHMINDIR: Streamlit sekmenin kapandigini sunucuya bildirmez. Bir olaydan
# sonraki olaya kadar gecen sure o sayfaya yazilir; 30 dakikadan uzun ara oturum
# kopmasi sayilip 1 dakika olarak alinir; oturumun son olayina da 1 dakika eklenir.
# -----------------------------------------------------------------------
st.divider()
st.subheader("Kullanım İstatistikleri")
st.caption(
    "Giriş, çıkış ve sayfa görüntüleme kayıtları. Sayfada kalma süreleri tahminidir: tarayıcı "
    "kapatıldığında uygulamaya haber gelmez, bu yüzden bir işlemden bir sonrakine kadar geçen süre "
    "sayılır (30 dakikadan uzun aralar kesinti kabul edilir). Kayıtlar 29 Eylül 2026'dan itibaren tutulur."
)

import pandas as pd
from datetime import timedelta

_ist_c1, _ist_c2 = st.columns([1, 1])
_donem_gun = _ist_c1.selectbox(
    "Dönem", [1, 7, 30, 90], index=1,
    format_func=lambda g: "Son 24 saat" if g == 1 else f"Son {g} gün", key="ist_donem",
)
_kendi_haric = _ist_c2.checkbox("Kendi hesabımı hariç tut", value=True, key="ist_kendi_haric")

_baslangic = (datetime.now(timezone.utc) - timedelta(days=_donem_gun)).isoformat()
_olaylar = []
_ofset = 0
try:
    while True:
        _parti = (
            supabase.table("kullanim_olaylari")
            .select("kullanici_id, email, isletme_id, ana_isletme_id, oturum_kimligi, olay, sayfa, detay, created_at")
            .gte("created_at", _baslangic)
            .order("created_at")
            .range(_ofset, _ofset + 999)
            .execute()
        ).data or []
        _olaylar += _parti
        if len(_parti) < 1000:
            break
        _ofset += 1000
except Exception:
    _olaylar = []
    st.info("Kullanım kayıtları okunamadı (183 çalıştırıldı mı?).")

if _kendi_haric:
    _kendi_eposta = st.session_state.get("_kullanici_eposta")
    _olaylar = [o for o in _olaylar if o.get("email") != _kendi_eposta]

if not _olaylar:
    st.info("Bu dönemde kayıt yok.")
else:
    _df = pd.DataFrame(_olaylar)
    _df["zaman"] = pd.to_datetime(_df["created_at"], utc=True).dt.tz_convert("Europe/Istanbul")
    _df = _df.sort_values(["oturum_kimligi", "zaman"])
    # Tahmini sure: ayni oturumda bir sonraki olaya kadar
    _df["sonraki"] = _df.groupby("oturum_kimligi")["zaman"].shift(-1)
    _fark = (_df["sonraki"] - _df["zaman"]).dt.total_seconds()
    _df["sure_sn"] = _fark.where(_fark <= 1800, 60).fillna(60)
    _df.loc[_df["olay"] == "cikis", "sure_sn"] = 0

    # Isletme adlari (admin tum isletmeleri gorur)
    try:
        _isl = supabase.table("isletmeler").select("id, ad").execute().data or []
    except Exception:
        _isl = []
    _isl_ad = {i["id"]: i["ad"] for i in _isl}
    _df["abone"] = _df["ana_isletme_id"].map(_isl_ad).fillna("?")
    _df["calisilan"] = _df["isletme_id"].map(_isl_ad).fillna("?")

    def _sure_yaz(sn):
        sn = int(sn or 0)
        s_, d_ = divmod(sn // 60, 60)
        return f"{s_} sa {d_} dk" if s_ else f"{d_} dk"

    _sayfa_df = _df[_df["olay"] == "sayfa"]
    _giris_df = _df[_df["olay"] == "giris"]

    _m1, _m2, _m3, _m4 = st.columns(4)
    _m1.metric("Aktif kullanıcı", _df["email"].nunique())
    _m2.metric("Oturum", _df["oturum_kimligi"].nunique())
    _m3.metric("Giriş", len(_giris_df))
    _m4.metric("Toplam süre (tahmini)", _sure_yaz(_sayfa_df["sure_sn"].sum()))

    st.markdown("**Kullanıcı bazında**")
    _kullanici_ozet = []
    for (_eposta, _abone), _g in _df.groupby(["email", "abone"], dropna=False):
        _gs = _g[_g["olay"] == "sayfa"]
        _en_cok = _gs.groupby("sayfa")["sure_sn"].sum().sort_values(ascending=False)
        _kullanici_ozet.append({
            "Kullanıcı": _eposta or "?",
            "Abone işletme": _abone,
            "Giriş": int((_g["olay"] == "giris").sum()),
            "Çıkış (düğmeyle)": int((_g["olay"] == "cikis").sum()),
            "Son işlem": _g["zaman"].max().strftime("%d.%m.%Y %H:%M"),
            "Toplam süre": _sure_yaz(_gs["sure_sn"].sum()),
            "En çok kullandığı sayfa": _en_cok.index[0] if len(_en_cok) else "-",
        })
    st.dataframe(pd.DataFrame(_kullanici_ozet), hide_index=True, use_container_width=True)

    st.markdown("**Sayfa bazında**")
    _sayfa_ozet = (
        _sayfa_df.groupby("sayfa")
        .agg(goruntuleme=("sayfa", "size"), sure=("sure_sn", "sum"), kullanici=("email", "nunique"))
        .sort_values("sure", ascending=False)
        .reset_index()
    )
    st.dataframe(
        pd.DataFrame({
            "Sayfa": _sayfa_ozet["sayfa"],
            "Görüntüleme": _sayfa_ozet["goruntuleme"],
            "Kullanıcı": _sayfa_ozet["kullanici"],
            "Toplam süre": _sayfa_ozet["sure"].map(_sure_yaz),
        }),
        hide_index=True, use_container_width=True,
    )

    st.markdown("**Günlük aktif kullanıcı**")
    _gunluk = _df.assign(gun=_df["zaman"].dt.strftime("%Y-%m-%d")).groupby("gun")["email"].nunique()
    st.bar_chart(_gunluk)

    with st.expander("Son işlemler (en yeni 200)"):
        _son = _df.sort_values("zaman", ascending=False).head(200)
        _olay_etiket = {"giris": "Giriş", "cikis": "Çıkış", "sayfa": "Sayfa"}
        _detay_etiket = {"sifre": "şifreyle", "hatirla": "beni hatırla", "oturum": "açık oturum"}
        st.dataframe(
            pd.DataFrame({
                "Zaman": _son["zaman"].dt.strftime("%d.%m.%Y %H:%M:%S"),
                "Kullanıcı": _son["email"],
                "Abone": _son["abone"],
                "Çalışılan işletme": _son["calisilan"],
                "İşlem": _son["olay"].map(_olay_etiket),
                "Sayfa / ayrıntı": _son["sayfa"].fillna(_son["detay"].map(_detay_etiket)).fillna(""),
            }),
            hide_index=True, use_container_width=True,
        )

# -----------------------------------------------------------------------
# 4) ADMIN YETKILERI -- sadece ana admin (sql/178)
# -----------------------------------------------------------------------
try:
    ana_admin_mi = bool(supabase.rpc("auth_ana_admin_mi").execute().data)
except Exception:
    ana_admin_mi = False

if ana_admin_mi:
    st.divider()
    st.subheader("Admin Yetkileri")
    st.caption(
        "Sadece aday listesindeki kişilere admin hakkı verilebilir; liste veritabanında sabittir, "
        "buradan yeni kişi eklenemez. Değişiklik, kişinin bir sonraki sayfa yenilemesinde geçerli olur."
    )
    try:
        adaylar = (
            supabase.table("admin_yetkileri").select("email, aktif, updated_at").order("email").execute()
        ).data or []
    except Exception:
        adaylar = []

    if not adaylar:
        st.info("Aday bulunamadı (178 çalıştırıldı mı?).")
    else:
        with st.form("admin_yetkileri_form"):
            yeni_degerler = {}
            for aday in adaylar:
                yeni_degerler[aday["email"]] = st.checkbox(
                    f"{aday['email']} — admin hakkı",
                    value=bool(aday.get("aktif")),
                    key=f"adminhak_{aday['email']}",
                )
            yetki_kaydet = st.form_submit_button("Admin yetkilerini kaydet", type="primary")

        if yetki_kaydet:
            hata = False
            for aday in adaylar:
                yeni = yeni_degerler[aday["email"]]
                if yeni == bool(aday.get("aktif")):
                    continue
                sonuc = (
                    supabase.table("admin_yetkileri")
                    .update({"aktif": yeni, "updated_at": datetime.now(timezone.utc).isoformat()})
                    .eq("email", aday["email"])
                    .execute()
                )
                if not sonuc.data:
                    hata = True
                    st.error(f"'{aday['email']}' güncellenemedi (izin politikası engelledi).")
            if not hata:
                st.success("Admin yetkileri kaydedildi.")
                st.rerun()
