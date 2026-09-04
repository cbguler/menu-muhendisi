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
    ad_sutunu, kisaltma_sutunu = st.columns([2, 1])
    yeni_ad = ad_sutunu.text_input("İşletme adı", value=isletme_bilgi.get("ad", ""))
    yeni_kisaltma = kisaltma_sutunu.text_input(
        "İşletme kısaltılmış adı", value=isletme_bilgi.get("kisaltma", ""),
        max_chars=12,
        help="Reçete Üretimi'nde oluşturduğun her yeni reçetenin adının "
        "sonuna otomatik olarak eklenir (ör. \"Tavuk Sote (ACM)\") -- "
        "boş bırakırsan hiçbir şey eklenmez.",
    )
    st.caption(
        "İşletme adı, Yıllık Menü sayfasındaki işletmenin kendi özel "
        "menüsünü dahil etme butonunun üzerinde görünür."
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

# ---------------------------------------------------------------------
# Isletme maliyet ayarlari (24 Agustos 2026: Recete Uretimi sayfasindan
# BURAYA tasindi -- kullanicinin gerekcesi: bu ayarlar tek bir receteye
# ozgu degil, isletmenin TUM receteleri (kendi ozel receteleri + Yillik
# Menu'deki 241 kutuphane tarifi DAHIL) icin gecerli, o yuzden dogal
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
st.caption(
    "Bu ayarlar Reçete Üretimi sayfasında değil buradadır, çünkü tek "
    "bir reçeteye değil işletmenin TÜM reçetelerine birden uygulanır -- "
    "hem kendi oluşturduğun özel reçetelere, hem de Yıllık Menü "
    "sayfasındaki hazır 241 tariflik kütüphaneden ürettiğin menülere. "
    "Malzeme maliyetleri (fiyatlar) zaten sistemde ayrı olarak "
    "tutuluyor, burada SADECE enerji ve işçilik birim fiyatları var. "
    "Aşağıdaki rakamlar başlangıç için makul TAHMİNİ değerlerdir -- "
    "işletmenin gerçek elektrik, doğalgaz ve saatlik personel maliyeti "
    "bu değerlerden farklıysa burada değiştirebilirsin; yaptığın "
    "değişiklik hesaplanan TÜM porsiyon maliyetlerine (default gelen "
    "241 reçete dahil) anında yansır."
)

ayar_sonuc = (
    supabase.table("isletme_maliyet_ayarlari")
    .select("*")
    .eq("isletme_id", isletme_id)
    .execute()
)
maliyet_ayarlari = ayar_sonuc.data[0] if ayar_sonuc.data else None

if maliyet_ayarlari is None:
    yeni_ayar = (
        supabase.table("isletme_maliyet_ayarlari")
        .insert({"isletme_id": isletme_id})
        .execute()
    )
    maliyet_ayarlari = yeni_ayar.data[0]

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
    if st.form_submit_button("Kaydet"):
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
    "Yıllık Menü sayfasındaki maliyet hesabı bu porsiyon sayılarını "
    "kullanır. Tek bir müşterin/tipik üretim miktarın varsa tek satır "
    "yeterli. Birden fazla müşteriye farklı porsiyon sayılarıyla "
    "üretim yapıyorsan (ör. bir yemek fabrikası), her müşteri için "
    "ayrı bir satır ekleyebilirsin -- Yıllık Menü'de hangisini "
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
