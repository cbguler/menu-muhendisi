# pages/4_Uretim_Asamalari.py
#
# Reçete üretim aşamaları: ısıl işlem + işçilik maliyeti, paralel iş
# desteği (kritik yol hesabı uretim_hesap.py'de yapılır) ve genel gider
# payı dahil tam maliyet dökümü.

import streamlit as st

from db import get_supabase, oturumu_uygula
from uretim_hesap import kritik_yolu_hesapla

st.set_page_config(
    page_title="Üretim Aşamaları", page_icon="assets/favicon.png", layout="wide"
)
st.logo("assets/logo.png", icon_image="assets/logo_icon.png")
st.sidebar.markdown("### Menü Mühendisi")

supabase = get_supabase()
oturumu_uygula(supabase)

isletme_id = st.session_state.isletme_id

st.title("Üretim Aşamaları ve Gerçek Maliyet")
st.caption(
    "Her aşamanın ısıl işlem (enerji) ve işçilik maliyetini hesaplar, "
    "paralel yapılabilen işleri dikkate alarak toplam süreyi bulur, "
    "genel gider payını porsiyona yansıtır."
)

# ---------------------------------------------------------------------
# İşletme maliyet ayarları (yoksa varsayılanlarla oluştur)
# ---------------------------------------------------------------------
ayar_sonuc = (
    supabase.table("isletme_maliyet_ayarlari")
    .select("*")
    .eq("isletme_id", isletme_id)
    .execute()
)
ayarlar = ayar_sonuc.data[0] if ayar_sonuc.data else None

if ayarlar is None:
    yeni_ayar = (
        supabase.table("isletme_maliyet_ayarlari")
        .insert({"isletme_id": isletme_id})
        .execute()
    )
    ayarlar = yeni_ayar.data[0]

with st.expander("İşletme maliyet ayarları"):
    with st.form("maliyet_ayarlari_formu"):
        c1, c2, c3, c4 = st.columns(4)
        elektrik = c1.number_input(
            "Elektrik (€/kWh)", value=float(ayarlar["elektrik_birim_fiyat_eur_kwh"]), step=0.01
        )
        dogalgaz = c2.number_input(
            "Doğalgaz (€/kWh)", value=float(ayarlar["dogalgaz_birim_fiyat_eur_kwh"]), step=0.01
        )
        saat_ucreti = c3.number_input(
            "Personel saat ücreti (€)", value=float(ayarlar["personel_saat_ucreti_eur"]), step=0.5
        )
        genel_gider = c4.number_input(
            "Genel gider payı (%)", value=float(ayarlar["genel_gider_yuzdesi"]), step=1.0
        )
        if st.form_submit_button("Kaydet"):
            supabase.table("isletme_maliyet_ayarlari").update(
                {
                    "elektrik_birim_fiyat_eur_kwh": elektrik,
                    "dogalgaz_birim_fiyat_eur_kwh": dogalgaz,
                    "personel_saat_ucreti_eur": saat_ucreti,
                    "genel_gider_yuzdesi": genel_gider,
                }
            ).eq("isletme_id", isletme_id).execute()
            st.success("Kaydedildi.")
            st.rerun()

st.divider()

# ---------------------------------------------------------------------
# Reçete seçimi
# ---------------------------------------------------------------------
receteler = (
    supabase.table("receteler")
    .select("id, ad")
    .eq("isletme_id", isletme_id)
    .order("ad")
    .execute()
).data or []

if not receteler:
    st.info("Önce Reçeteler sayfasından bir reçete oluşturmalısın.")
    st.stop()

recete_id_by_ad = {r["ad"]: r["id"] for r in receteler}
secilen_ad = st.selectbox("Reçete seç", options=list(recete_id_by_ad.keys()))
recete_id = recete_id_by_ad[secilen_ad]

recete_malzemeleri = (
    supabase.table("recete_malzemeleri")
    .select("id, malzeme_id, miktar_gram, malzemeler(ad)")
    .eq("recete_id", recete_id)
    .execute()
).data or []

if not recete_malzemeleri:
    st.warning("Bu reçetede henüz malzeme yok — önce Reçeteler sayfasından ekle.")
    st.stop()

malzeme_etiket = {
    rm["id"]: f"{rm['malzemeler']['ad']} ({rm['miktar_gram']:.0f} g)" for rm in recete_malzemeleri
}

# ---------------------------------------------------------------------
# Mevcut aşamalar
# ---------------------------------------------------------------------
asamalar = (
    supabase.table("recete_asamalari")
    .select("*")
    .eq("recete_id", recete_id)
    .order("sira")
    .execute()
).data or []

asama_ad_by_id = {a["id"]: a["ad"] for a in asamalar}

st.subheader("Aşamalar")
if not asamalar:
    st.caption("Henüz aşama eklenmedi.")
else:
    for a in asamalar:
        am_kayitlari = (
            supabase.table("asama_malzemeleri")
            .select("recete_malzeme_id")
            .eq("asama_id", a["id"])
            .execute()
        ).data or []
        kullanilan = ", ".join(
            malzeme_etiket.get(k["recete_malzeme_id"], "?") for k in am_kayitlari
        ) or "(malzeme atanmadı)"

        bagimlilik_kayitlari = (
            supabase.table("asama_bagimliliklari")
            .select("onceki_asama_id")
            .eq("asama_id", a["id"])
            .execute()
        ).data or []
        bagimlilik_metni = ", ".join(
            asama_ad_by_id.get(b["onceki_asama_id"], "?") for b in bagimlilik_kayitlari
        ) or "yok (baştan başlayabilir)"

        isil = (
            f"🔥 {a['baslangic_sicaklik']}°C → {a['hedef_sicaklik']}°C ({a['enerji_kaynagi']})"
            if a["isil_islem_mi"]
            else "—"
        )
        st.markdown(
            f"**{a['sira']}. {a['ad']}** ({a['sure_dakika']:.0f} dk) — "
            f"Malzeme: {kullanilan} — Isıl işlem: {isil} — Bağımlı olduğu: {bagimlilik_metni}"
        )
        if st.button("Sil", key=f"asama_sil_{a['id']}"):
            supabase.table("recete_asamalari").delete().eq("id", a["id"]).execute()
            st.rerun()

st.divider()

# ---------------------------------------------------------------------
# Yeni aşama ekleme
# ---------------------------------------------------------------------
st.subheader("Yeni aşama ekle")
with st.form("yeni_asama_formu", clear_on_submit=True):
    c1, c2, c3 = st.columns(3)
    ad = c1.text_input("Aşama adı (ör. 'Sebzeleri haşla')")
    sira = c2.number_input("Sıra", min_value=1, value=len(asamalar) + 1, step=1)
    sure_dakika = c3.number_input("Süre (dakika)", min_value=0.0, value=10.0, step=1.0)

    isil_islem_mi = st.checkbox("Isıl işlem içerir (pişirme/haşlama/kızartma vb.)")
    enerji_kaynagi = baslangic_sicaklik = hedef_sicaklik = verimlilik = None
    if isil_islem_mi:
        ic1, ic2, ic3, ic4 = st.columns(4)
        enerji_kaynagi = ic1.selectbox("Enerji kaynağı", ["elektrik", "dogalgaz"])
        baslangic_sicaklik = ic2.number_input("Başlangıç sıcaklığı (°C)", value=20.0, step=5.0)
        hedef_sicaklik = ic3.number_input("Hedef sıcaklık (°C)", value=100.0, step=5.0)
        verimlilik = ic4.slider("Verimlilik oranı", min_value=0.1, max_value=1.0, value=0.65, step=0.05)

    secilen_malzemeler = st.multiselect(
        "Bu aşamada işlenen malzemeler", options=list(malzeme_etiket.keys()),
        format_func=lambda k: malzeme_etiket[k],
    )
    onceki_asamalar = st.multiselect(
        "Hangi aşama(lar) bitmeden bu başlayamaz? (boş = baştan başlayabilir)",
        options=list(asama_ad_by_id.keys()), format_func=lambda k: asama_ad_by_id[k],
    )

    if st.form_submit_button("Aşamayı ekle", type="primary"):
        if not ad.strip():
            st.error("Aşama adı boş olamaz.")
        else:
            yeni_asama = (
                supabase.table("recete_asamalari")
                .insert(
                    {
                        "recete_id": recete_id,
                        "ad": ad.strip(),
                        "sira": int(sira),
                        "sure_dakika": sure_dakika,
                        "isil_islem_mi": isil_islem_mi,
                        "enerji_kaynagi": enerji_kaynagi,
                        "baslangic_sicaklik": baslangic_sicaklik,
                        "hedef_sicaklik": hedef_sicaklik,
                        "verimlilik_orani": verimlilik or 0.65,
                    }
                )
                .execute()
            )
            yeni_asama_id = yeni_asama.data[0]["id"]

            if secilen_malzemeler:
                supabase.table("asama_malzemeleri").insert(
                    [{"asama_id": yeni_asama_id, "recete_malzeme_id": rm} for rm in secilen_malzemeler]
                ).execute()

            if onceki_asamalar:
                supabase.table("asama_bagimliliklari").insert(
                    [{"asama_id": yeni_asama_id, "onceki_asama_id": oa} for oa in onceki_asamalar]
                ).execute()

            st.success(f"'{ad}' aşaması eklendi.")
            st.rerun()

st.divider()

# ---------------------------------------------------------------------
# Kritik yol (paralel işler dahil toplam süre)
# ---------------------------------------------------------------------
if asamalar:
    st.subheader("Toplam üretim süresi (paralel işler dahil)")
    tum_bagimliliklar = (
        supabase.table("asama_bagimliliklari")
        .select("asama_id, onceki_asama_id")
        .in_("asama_id", [a["id"] for a in asamalar])
        .execute()
    ).data or []

    try:
        sonuc = kritik_yolu_hesapla(
            [{"id": a["id"], "sure_dakika": a["sure_dakika"]} for a in asamalar],
            tum_bagimliliklar,
        )
        toplam_dakika_seri = sum(a["sure_dakika"] for a in asamalar)
        k1, k2 = st.columns(2)
        k1.metric("Kritik yol süresi (gerçek geçen süre)", f"{sonuc['toplam_sure_dakika']:.0f} dk")
        k2.metric("Tüm aşamaların toplamı (paralel olmasaydı)", f"{toplam_dakika_seri:.0f} dk")
        kritik_isimler = " → ".join(asama_ad_by_id.get(a, "?") for a in sonuc["kritik_yol"])
        st.caption(f"Kritik yol: {kritik_isimler}")
    except ValueError as e:
        st.error(str(e))

st.divider()

# ---------------------------------------------------------------------
# Tam maliyet dökümü
# ---------------------------------------------------------------------
st.subheader("Gerçek porsiyon maliyeti")
maliyet_sonuc = (
    supabase.table("recete_uretim_maliyeti")
    .select("*")
    .eq("recete_id", recete_id)
    .execute()
)
maliyet = maliyet_sonuc.data[0] if maliyet_sonuc.data else None

if maliyet:
    m1, m2, m3, m4 = st.columns(4)
    m1.metric("Malzeme", f"{maliyet['malzeme_maliyeti_eur']:.2f} €")
    m2.metric("Enerji (ısıl işlem)", f"{maliyet['enerji_maliyeti_eur']:.2f} €")
    m3.metric("İşçilik", f"{maliyet['iscilik_maliyeti_eur']:.2f} €")
    m4.metric("Genel gider payı", f"{maliyet['genel_gider_payi_eur']:.2f} €")
    st.metric("**Porsiyon başı gerçek maliyet**", f"{maliyet['porsiyon_gercek_maliyet_eur']:.2f} €")
else:
    st.caption("Maliyet hesaplanamadı.")
