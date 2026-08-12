# pages/7_Admin.py
#
# Sadece admin'e (app.py'de hardcode edilmis e-posta ile tespit edilen
# tek hesap) acik sayfa -- st.navigation() listesine sadece admin
# oturumunda ekleniyor, bu yuzden baskasi URL'yi bilse bile
# ulasamiyor. Ama savunma amacli, burada da ayrica kontrol ediliyor.
#
# Iki bolum: (1) odemesi alinmis ama admin onayi bekleyen abonelikler --
# "Onayla" butonuyla durum='aktif' yapar. (2) 12 Agustos 2026 (Oturum 11,
# kullanicinin acik talebi) EKLENEN: aktif abonelikleri listeleyip
# "Iptal Et" ile durum='iptal_edildi' yapabilme -- boylece admin sadece
# onaylama degil, abonelikten cikartma yetkisine de sahip.
#
# Ikisi de sql/46_admin_abonelik_rls.sql'deki admin'e ozel SELECT/UPDATE
# politikalarina dayaniyor -- o migration calistirilmadan bu sayfa hicbir
# satir goremez/guncelleyemez (RLS sessizce engeller).

import streamlit as st

# NOT (12 Agustos 2026, Oturum 11): logo artik burada AYRICA gosterilmiyor -- app.py'deki ozel menu satirinin icine tasindi, orada zaten her sayfa gecisinde render ediliyor. Burada tekrar cagirmak cift logoya yol acardi.

from db import get_supabase, oturumu_uygula

st.set_page_config(page_title="Admin", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

if not st.session_state.get("admin_mi"):
    st.error("Bu sayfaya erişimin yok.")
    st.stop()

st.title("Admin")

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
        isletme_adi = (abonelik.get("isletmeler") or {}).get("ad", "?")
        plan_adi = (abonelik.get("abonelik_planlari") or {}).get("ad", "?")
        with st.container(border=True):
            c1, c2 = st.columns([4, 1])
            with c1:
                st.write(f"**{isletme_adi}** — {plan_adi} planı")
            with c2:
                if st.button("Onayla", key=f"onayla_{abonelik['id']}", type="primary"):
                    # NOT (12 Agustos 2026, Oturum 11): sonuc.data kontrol
                    # EDILMEDEN "onaylandi" gosterilmesi, 44_isletmeler_
                    # update_politikasi.sql'de bulunanla AYNI sinif hataya
                    # acikti -- RLS UPDATE'i sessizce reddedebilir (hata
                    # firlatmaz, sadece 0 satir etkilenir). 46_admin_
                    # abonelik_rls.sql ile UPDATE politikasi eklendi ama
                    # yine de savunma amacli kontrol ediyoruz.
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
                            "Onaylama işlemi veritabanı tarafından reddedildi "
                            "(muhtemelen bir RLS/izin politikası engelliyor) -- "
                            "hiçbir hata mesajı dönmedi ama satır güncellenmedi."
                        )

st.divider()

# -----------------------------------------------------------------------
# 2) AKTIF ABONELIKLER -- iptal etme (12 Agustos 2026, Oturum 11 eklendi)
# -----------------------------------------------------------------------
st.subheader("Aktif Abonelikler")
st.caption("Bir aboneliği iptal etmek hesabı bloke eder (durum='iptal_edildi').")

kendi_isletme_id = st.session_state.get("isletme_id")

aktifler = (
    supabase.table("abonelikler")
    .select("id, isletme_id, plan_id, durum, isletmeler(ad), abonelik_planlari(kod, ad)")
    .eq("durum", "aktif")
    .execute()
).data or []
# Admin'in KENDI aboneligi (her zaman aktif, kurumsal) bu listede
# yanlislikla "iptal edilebilir" gorunmesin diye disaridan filtreleniyor.
aktifler = [a for a in aktifler if a.get("isletme_id") != kendi_isletme_id]

if not aktifler:
    st.info("Aktif abonelik yok (kendi hesabın hariç).")
else:
    for abonelik in aktifler:
        isletme_adi = (abonelik.get("isletmeler") or {}).get("ad", "?")
        plan_adi = (abonelik.get("abonelik_planlari") or {}).get("ad", "?")
        onay_anahtari = f"iptal_onay_{abonelik['id']}"
        with st.container(border=True):
            c1, c2 = st.columns([4, 1])
            with c1:
                st.write(f"**{isletme_adi}** — {plan_adi} planı")
            with c2:
                if not st.session_state.get(onay_anahtari):
                    if st.button("İptal Et", key=f"iptal_{abonelik['id']}"):
                        st.session_state[onay_anahtari] = True
                        st.rerun()
                else:
                    # IKI ADIMLI ONAY -- iptal, onaylamadan farkli olarak
                    # geri donusu (musterinin erisimini kesmek) daha
                    # agir bir islem, bu yuzden tek tikla degil.
                    st.warning("Emin misin?")
                    cc1, cc2 = st.columns(2)
                    with cc1:
                        if st.button("Evet, iptal et", key=f"iptal_evet_{abonelik['id']}", type="primary"):
                            sonuc = (
                                supabase.table("abonelikler")
                                .update({"durum": "iptal_edildi"})
                                .eq("id", abonelik["id"])
                                .execute()
                            )
                            st.session_state[onay_anahtari] = False
                            if sonuc.data:
                                st.success(f"'{isletme_adi}' iptal edildi.")
                                st.rerun()
                            else:
                                st.error(
                                    "İptal işlemi veritabanı tarafından reddedildi "
                                    "(muhtemelen bir RLS/izin politikası engelliyor)."
                                )
                    with cc2:
                        if st.button("Vazgeç", key=f"iptal_vazgec_{abonelik['id']}"):
                            st.session_state[onay_anahtari] = False
                            st.rerun()
