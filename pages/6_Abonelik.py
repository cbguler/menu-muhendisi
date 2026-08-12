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

# NOT (12 Agustos 2026, Oturum 11): logo artik burada AYRICA gosterilmiyor -- app.py'deki ozel menu satirinin icine tasindi, orada zaten her sayfa gecisinde render ediliyor. Burada tekrar cagirmak cift logoya yol acardi.

from db import get_supabase, oturumu_uygula, cerez_yoneticisi

st.set_page_config(page_title="Abonelik", page_icon="assets/favicon.png", layout="wide")

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
# Isletme bilgileri (6 Agustos 2026 eklendi, 12 Agustos 2026 genisletildi:
# adres + fatura adresi -- bkz. 47_isletme_adres_fatura_ekle.sql).
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
    yeni_adres = st.text_area(
        "İşletme adresi", value=isletme_bilgi.get("adres", ""), height=80,
    )
    yeni_fatura_adresi = st.text_area(
        "Fatura adresi",
        value=isletme_bilgi.get("fatura_adresi", ""),
        height=80,
        help="İşletme adresinden farklıysa buraya ayrı gir; aynıysa boş bırakabilirsin.",
    )
    yeni_vergi_dairesi = st.text_input(
        "Vergi dairesi", value=isletme_bilgi.get("vergi_dairesi", ""),
    )
    yeni_vergi_no = st.text_input(
        "Vergi numarası", value=isletme_bilgi.get("vergi_no", ""),
    )
    if st.form_submit_button("Kaydet"):
        if not yeni_ad.strip():
            st.error("İşletme adı boş olamaz.")
        else:
            sonuc = (
                supabase.table("isletmeler")
                .update({
                    "ad": yeni_ad.strip(),
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
