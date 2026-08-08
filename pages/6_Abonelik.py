# pages/6_Abonelik.py
#
# Abonelik/hesap sayfasi (6 Agustos 2026 eklendi). Once "Cikis yap"
# butonunu her sayfada CSS ile ust menuye zorla sikistirmayi denedik --
# Streamlit'in native ust navigasyonu ozel eleman eklemeye acik olmadigi
# icin bu hep kirilgan/guvenilmez cikti. Kullanicinin onerdigi cok daha
# temiz cozum: abonelik/hesap bilgisinin (ve Cikis yap'in) kendi DOGAL
# sayfasi olsun -- CSS hilesi degil, gercek bir sayfa.

import streamlit as st

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula, cerez_yoneticisi

st.set_page_config(page_title="Abonelik", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Abonelik")

plan_kodu = st.session_state.get("plan_kodu", "-")
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
else:
    st.write(f"Mevcut plan: **{plan_kodu}**")
st.caption(
    "Gerçek ödeme akışı (PayTR vb.) henüz kurulmadı (bkz. PROJE_NOTLARI.md "
    "\"Premium Plan / Erişim Stratejisi\" nihai hedefi)."
)

st.divider()

# ---------------------------------------------------------------------
# Isletme bilgileri (6 Agustos 2026 eklendi). NOT: isletmeler tablosunda
# kesin olarak bildigim tek alan "ad" (Yillik Menu'deki "kendi menum"
# butonunun etiketini buradan okuyor). Baska alanlar (adres/telefon/
# vergi no vb.) olup olmadigini bilmiyorum -- kullanici isterse
# soyleyip ekletebilir.
# ---------------------------------------------------------------------
st.subheader("İşletme Bilgileri")

isletme_id = st.session_state.isletme_id
isletme_bilgi = (
    supabase.table("isletmeler").select("*").eq("id", isletme_id).single().execute()
).data or {}

with st.form("isletme_bilgi_formu"):
    yeni_ad = st.text_input("İşletme adı", value=isletme_bilgi.get("ad", ""))
    st.caption(
        "Bu ad, Yıllık Menü sayfasındaki işletmenin kendi özel menüsünü "
        "dahil etme butonunun üzerinde görünür."
    )
    if st.form_submit_button("Kaydet"):
        if not yeni_ad.strip():
            st.error("İşletme adı boş olamaz.")
        else:
            sonuc = (
                supabase.table("isletmeler")
                .update({"ad": yeni_ad.strip()})
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

cerezler = cerez_yoneticisi()
if st.button("Çıkış yap", type="primary"):
    supabase.auth.sign_out()
    st.session_state.oturum = None
    cerezler.delete("refresh_token", key="refresh_token_cikis_abonelik_sayfasi")
    st.rerun()
