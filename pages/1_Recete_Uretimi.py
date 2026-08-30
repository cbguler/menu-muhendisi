# pages/1_Recete_Uretimi.py
#
# Recete olusturma + malzeme yonetimi + uretim asamalari (isil islem/
# iscilik) + gercek maliyet -- TEK sayfada. ONCEDEN IKI AYRI SAYFAYDI
# (1_Receteler.py + 4_Uretim_Asamalari.py) -- kullanici bunu "iki sayfada
# yapmak sacma" diye tanimlayip birlestirilmesini istedi (6 Agustos 2026).
# Akis: recete olustur -> malzeme ekle -> (ayni sayfada, asagida) uretim
# asamasi ekle -> kritik yol + gercek maliyet gorunur.

import streamlit as st

# NOT (12 Agustos 2026, Oturum 11): logo artik burada AYRICA gosterilmiyor -- app.py'deki ozel menu satirinin icine tasindi, orada zaten her sayfa gecisinde render ediliyor. Burada tekrar cagirmak cift logoya yol acardi.

from db import get_supabase, oturumu_uygula
from uretim_hesap import kritik_yolu_hesapla

st.set_page_config(page_title="Reçete Üretimi", page_icon="assets/favicon.png", layout="wide")

supabase = get_supabase()
oturumu_uygula(supabase)

isletme_id = st.session_state.isletme_id
recete_limiti = st.session_state.get("recete_limiti")  # None = sınırsız

# AYLAR_SIRALI: pages/0_Yillik_Menu.py'deki AYNI liste -- iki sayfa
# arasinda tutarlilik icin burada da ayni sirayla tekrarlaniyor.
AYLAR_SIRALI = [
    "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
    "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
]

# EK BESIN DEGERLERI (24 Agustos 2026) -- 73 numarali migration'la
# malzemeler tablosuna eklenen 24 vitamin/mineral sutunu (kolon adi,
# gorunen etiket, birim). Ana 4 deger (kalori/protein/yag/karbonhidrat)
# zaten ayri metric olarak gosteriliyor, bunlar EKLERDE (kucuk fontla,
# tek satira sigacak sekilde) gosteriliyor.
EK_BESIN_ALANLARI = [
    ("sodyum_mg", "Sodyum", "mg"),
    ("lif_g", "Lif", "g"),
    ("seker_g", "Şeker", "g"),
    ("doymus_yag_g", "Doymuş Yağ", "g"),
    ("vitamin_a_mcg", "A Vit.", "mcg"),
    ("vitamin_b1_mg", "B1", "mg"),
    ("vitamin_b2_mg", "B2", "mg"),
    ("vitamin_b3_mg", "B3", "mg"),
    ("vitamin_b5_mg", "B5", "mg"),
    ("vitamin_b6_mg", "B6", "mg"),
    ("vitamin_b9_mcg", "B9", "mcg"),
    ("vitamin_b12_mcg", "B12", "mcg"),
    ("vitamin_c_mg", "C Vit.", "mg"),
    ("vitamin_d_mcg", "D Vit.", "mcg"),
    ("vitamin_e_mg", "E Vit.", "mg"),
    ("vitamin_k_mcg", "K Vit.", "mcg"),
    ("kalsiyum_mg", "Kalsiyum", "mg"),
    ("demir_mg", "Demir", "mg"),
    ("magnezyum_mg", "Magnezyum", "mg"),
    ("potasyum_mg", "Potasyum", "mg"),
    ("cinko_mg", "Çinko", "mg"),
    ("fosfor_mg", "Fosfor", "mg"),
    ("bakir_mg", "Bakır", "mg"),
    ("manganez_mg", "Manganez", "mg"),
    ("selenyum_mcg", "Selenyum", "mcg"),
]


def _kompakt_sayi(deger):
    """Kucuk besin degerlerini gereksiz ondalik basamak olmadan, ama
    kucuk sayilarda (ör. 0.063 mg) anlamsiz "0" gorunmeyecek sekilde
    bicimlendirir."""
    if deger is None:
        return "0"
    if deger >= 10:
        return f"{deger:.0f}"
    if deger >= 1:
        return f"{deger:.1f}"
    if deger == 0:
        return "0"
    return f"{deger:.2f}"


KATEGORILER = ["corba", "ana_yemek", "salata", "tatli", "icecek", "baslangic", "pizza", "burger"]
KATEGORI_ETIKET = {
    "corba": "Çorba",
    "ana_yemek": "Ana Yemek",
    "salata": "Salata",
    "tatli": "Tatlı",
    "icecek": "İçecek",
    "baslangic": "Başlangıç",
    "pizza": "Pizza",
    "burger": "Burger",
}

st.title("Reçete Üretimi")
st.caption(
    "Burada oluşturduğun her reçete tamamen kendi işletmene özeldir -- "
    "başka hiçbir işletme, hiçbir şekilde senin reçetelerini göremez. "
    "Reçeteni oluştur, malzemelerini ekle, sonra aynı sayfada pişirme "
    "sürecini aşama aşama tarif et -- sistem malzeme, enerji ve işçilik "
    "dahil gerçek porsiyon maliyetini hesaplar; hazır olduğunda aynı "
    "sayfanın altından reçeteni doğrudan satışa açabilirsin. Enerji/"
    "işçilik maliyet ayarlarını Abonelik sayfasından yönetebilirsin."
)
st.caption(
    "Yeni bir reçete oluşturduğunda, işletme kısaltman (Abonelik "
    "sayfasında ayarlarsan) reçete adının sonuna otomatik eklenir -- "
    "ör. \"Tavuk Sote (ACM)\"."
)
if st.session_state.get("salt_okunur"):
    st.info("Önizleme modundasın — admin onayı gelene kadar işlem yapamazsın.")

isletme_bilgi = (
    supabase.table("isletmeler").select("kisaltma").eq("id", isletme_id).single().execute()
).data or {}
isletme_kisaltma = (isletme_bilgi.get("kisaltma") or "").strip()

st.divider()

# ---------------------------------------------------------------------
# Mevcut reçeteleri çek — hem listelemek hem plan limitini kontrol
# etmek için lazım.
# ---------------------------------------------------------------------
receteler = (
    supabase.table("receteler")
    .select("*")
    .eq("isletme_id", isletme_id)
    .order("created_at", desc=True)
    .execute()
).data or []

mevcut_sayi = len(receteler)
limit_doldu = recete_limiti is not None and mevcut_sayi >= recete_limiti

if limit_doldu:
    st.warning(
        f"Planın {recete_limiti} reçete ile sınırlı, şu an {mevcut_sayi} reçeten var. "
        "Daha fazla eklemek için planını yükselt."
    )
    st.link_button("Planı yükselt", url="https://ORNEK-ODEME-SAYFASI-LINKI")
else:
    with st.expander("Yeni reçete ekle", expanded=(mevcut_sayi == 0)):
        st.caption(
            "Her reçete SABİT 10 porsiyon olarak üretilmelidir -- bu, "
            "işletmeler arası maliyet/fiyat karşılaştırmasının ve Yıllık "
            "Menü'deki hesaplamaların tutarlı kalması için gerekli. "
            "Porsiyon sayısı bu yüzden artık sorulmuyor, otomatik 10 "
            "olarak kaydediliyor."
        )
        with st.form("yeni_recete_formu", clear_on_submit=True):
            col1, col2 = st.columns(2)
            with col1:
                ad = st.text_input("Reçete adı")
            with col2:
                kategori = st.selectbox(
                    "Kategori", KATEGORILER, format_func=lambda k: KATEGORI_ETIKET[k]
                )
            hazirlik = st.number_input("Hazırlık süresi (dakika)", min_value=0, value=15, step=5)
            uygun_aylar = st.multiselect(
                "Bu reçete yılın hangi aylarında müşteriye sunulabilir?",
                AYLAR_SIRALI,
                help="Boş bırakırsan kısıtlama olmaz, reçete yılın her "
                "ayında sunulabilir kabul edilir (ör. mevsimlik bir "
                "malzemeye dayanmayan reçeteler için).",
            )
            kaydet = st.form_submit_button("Reçeteyi oluştur", type="primary", disabled=st.session_state.get("salt_okunur", False))

            if kaydet:
                if not ad.strip():
                    st.error("Reçete adı boş olamaz.")
                else:
                    kaydedilecek_ad = (
                        f"{ad.strip()} ({isletme_kisaltma})" if isletme_kisaltma else ad.strip()
                    )
                    supabase.table("receteler").insert(
                        {
                            "isletme_id": isletme_id,
                            "ad": kaydedilecek_ad,
                            "kategori": kategori,
                            "porsiyon_sayisi": 10,
                            "hazirlik_dakika": int(hazirlik),
                            "uygun_aylar": uygun_aylar,
                        }
                    ).execute()
                    st.success(f"'{kaydedilecek_ad}' reçetesi oluşturuldu.")
                    st.rerun()

st.divider()

if not receteler:
    st.info("Henüz reçete eklenmedi. Yukarıdan ilk reçeteni oluşturabilirsin.")
    st.stop()

# ---------------------------------------------------------------------
# Malzeme kataloğu (global + işletmeye özel), besin alanlarıyla birlikte
# ---------------------------------------------------------------------
_ek_alan_kolonlari = ", ".join(alan for alan, _, _ in EK_BESIN_ALANLARI)
malzemeler = (
    supabase.table("malzemeler")
    .select(f"id, ad, kalori, protein, yag, karbonhidrat, glisemik_indeks, {_ek_alan_kolonlari}")
    .or_(f"isletme_id.is.null,isletme_id.eq.{isletme_id}")
    .order("ad")
    .execute()
).data or []

malzeme_adi = {m["id"]: m["ad"] for m in malzemeler}
malzeme_id_by_ad = {m["ad"]: m["id"] for m in malzemeler}
malzeme_bilgi = {m["id"]: m for m in malzemeler}

# ---------------------------------------------------------------------
# Reçete seçimi -- bundan sonraki HER ŞEY (malzeme, üretim aşamaları,
# maliyet) seçilen bu TEK reçete üzerinden işler. Eskiden Reçeteler
# sayfasında her reçete kendi acordiyonunda ayrı ayrı gösteriliyordu;
# şimdi üretim aşamaları da aynı ekranda olduğu için (çok daha fazla
# içerik var) "birini seç, üstünde çalış" akışına geçildi.
# ---------------------------------------------------------------------
recete_id_by_ad = {r["ad"]: r["id"] for r in receteler}
recete_by_id = {r["id"]: r for r in receteler}
secilen_ad = st.selectbox("Reçete seç", options=list(recete_id_by_ad.keys()))
recete = recete_by_id[recete_id_by_ad[secilen_ad]]
recete_id = recete["id"]

ust1, ust2 = st.columns([4, 1])
with ust1:
    st.subheader(
        f"{recete['ad']} ({KATEGORI_ETIKET.get(recete['kategori'], recete['kategori'])}) "
        f"— {recete['porsiyon_sayisi']} porsiyon"
    )
    _uygun_aylar = recete.get("uygun_aylar") or []
    st.caption(
        f"Sunulabilir aylar: {', '.join(_uygun_aylar)}" if _uygun_aylar
        else "Sunulabilir aylar: kısıtlama yok (yılın her ayı)"
    )
with ust2:
    if st.button("Reçeteyi sil", key=f"sil_{recete_id}", disabled=st.session_state.get("salt_okunur", False)):
        supabase.table("receteler").delete().eq("id", recete_id).execute()
        st.rerun()

# ---------------------------------------------------------------------
# Malzemeler
# ---------------------------------------------------------------------
st.markdown("#### Malzemeler")

recete_malzemeleri = (
    supabase.table("recete_malzemeleri")
    .select("*")
    .eq("recete_id", recete_id)
    .execute()
).data or []

if recete_malzemeleri:
    for rm in recete_malzemeleri:
        mc1, mc2, mc3 = st.columns([3, 2, 1])
        mc1.write(malzeme_adi.get(rm["malzeme_id"], "(silinmiş malzeme)"))
        mc2.write(f"{rm['miktar_gram']:.0f} g")
        if mc3.button("Çıkar", key=f"cikar_{rm['id']}", disabled=st.session_state.get("salt_okunur", False)):
            supabase.table("recete_malzemeleri").delete().eq("id", rm["id"]).execute()
            st.rerun()
else:
    st.caption("Henüz malzeme eklenmedi.")

with st.form(f"malzeme_ekle_{recete_id}", clear_on_submit=True):
    # OTUZ BESINCI DUZELTME (24 Agustos 2026): "Ekle" butonu, ustunde
    # etiketi olan diger iki alanla (Malzeme/Miktar) hizasiz duruyordu --
    # ayni sinif sorun app.py'deki nav satirinda vertical_alignment=
    # "bottom" ile cozulmustu, ayni cozum burada da uygulandi.
    ec1, ec2, ec3 = st.columns([3, 2, 1], vertical_alignment="bottom")
    secilen_malzeme_ad = ec1.selectbox(
        "Malzeme", options=list(malzeme_id_by_ad.keys()), key=f"secim_{recete_id}"
    )
    miktar = ec2.number_input(
        "Miktar (gram)", min_value=1.0, value=100.0, step=10.0, key=f"miktar_{recete_id}"
    )
    ekle = ec3.form_submit_button("Ekle", disabled=st.session_state.get("salt_okunur", False))
    if ekle:
        supabase.table("recete_malzemeleri").insert(
            {
                "recete_id": recete_id,
                "malzeme_id": malzeme_id_by_ad[secilen_malzeme_ad],
                "miktar_gram": miktar,
            }
        ).execute()
        st.rerun()

if not recete_malzemeleri:
    st.info("Üretim aşaması eklemeden önce en az bir malzeme eklemelisin.")
    st.stop()

# ---------------------------------------------------------------------
# Malzeme maliyeti + besin değerleri (canlı)
# ---------------------------------------------------------------------
maliyet_sonuc = (
    supabase.table("recete_guncel_maliyet")
    .select("*")
    .eq("recete_id", recete_id)
    .execute()
)
maliyet = maliyet_sonuc.data[0] if maliyet_sonuc.data else None

porsiyon_sayisi = recete.get("porsiyon_sayisi") or 1

if maliyet:
    st.write(f"**Malzeme maliyeti ({porsiyon_sayisi} porsiyon için)**")
    mc1, mc2, mc3 = st.columns(3)
    mc1.metric(f"Toplam malzeme maliyeti ({porsiyon_sayisi} porsiyon)", f"{maliyet['toplam_maliyet_eur']:.2f} €")
    mc2.metric("Porsiyon başı maliyet", f"{maliyet['porsiyon_maliyeti_eur']:.2f} €")
    if maliyet.get("porsiyon_kalori") is not None:
        mc3.metric("Porsiyon başı kalori", f"{maliyet['porsiyon_kalori']:.0f} kcal")

# Besin degerleri (protein/yag/karbonhidrat/GI + 24 ek vitamin/mineral) --
# kalorinin aksine recete_guncel_maliyet view'inden gelmiyor, Tarif
# Kutuphanesi'ndeki ile AYNI yontemle burada hesaplaniyor: miktar_gram/100
# orani kadar katki toplanir, GI karbonhidrat agirlikli ortalama olarak
# hesaplanir (porsiyon sayisindan bagimsiz bir orandir, olceklenmez).
toplam_protein = toplam_yag = toplam_karbonhidrat = 0.0
gi_agirlikli = gi_karb_toplam = 0.0
ek_toplamlar = {alan: 0.0 for alan, _, _ in EK_BESIN_ALANLARI}
for rm in recete_malzemeleri:
    bilgi = malzeme_bilgi.get(rm["malzeme_id"], {})
    oran = rm["miktar_gram"] / 100.0
    toplam_protein += (bilgi.get("protein") or 0) * oran
    toplam_yag += (bilgi.get("yag") or 0) * oran
    karb = (bilgi.get("karbonhidrat") or 0) * oran
    toplam_karbonhidrat += karb
    gi = bilgi.get("glisemik_indeks")
    if gi is not None and karb > 0:
        gi_agirlikli += gi * karb
        gi_karb_toplam += karb
    for alan, _, _ in EK_BESIN_ALANLARI:
        ek_toplamlar[alan] += (bilgi.get(alan) or 0) * oran

gi_deger = (gi_agirlikli / gi_karb_toplam) if gi_karb_toplam > 0 else None

st.write("**Besin değerleri (porsiyon başı)**")
bd1, bd2, bd3, bd4 = st.columns(4)
bd1.metric("Protein", f"{toplam_protein / porsiyon_sayisi:.0f} g")
bd2.metric("Yağ", f"{toplam_yag / porsiyon_sayisi:.0f} g")
bd3.metric("Karbonhidrat", f"{toplam_karbonhidrat / porsiyon_sayisi:.0f} g")
bd4.metric("Glisemik İndeks", f"{gi_deger:.0f}" if gi_deger is not None else "-")

# OTUZ ALTINCI DUZELTME (24 Agustos 2026): kullanici talebi -- kalan 24
# vitamin/mineral degeri de gosterilsin ama st.metric() gibi buyuk yer
# kaplayan bir bicimde DEGIL, kucuk fontla 1-2 satira sigacak sekilde.
# NOT (DURUSTCE BELIRTILMELI): 24 kalemin GERCEKTEN 1-2 satira sigmasi
# ekran genisligine bagli -- genis masaustunde sigar, dar/mobil ekranda
# CSS flex-wrap ile alt alta kayar (bu tasarim geregi, engellenemez).
_ek_satir_parcalari = []
for alan, etiket, birim in EK_BESIN_ALANLARI:
    deger_porsiyon = ek_toplamlar[alan] / porsiyon_sayisi
    _ek_satir_parcalari.append(
        f"<span style='white-space:nowrap;'>{etiket}: "
        f"<b>{_kompakt_sayi(deger_porsiyon)}{birim}</b></span>"
    )
st.markdown(
    "<div style='display:flex; flex-wrap:wrap; gap:4px 14px; "
    "font-size:12px; color:#444; margin-top:-4px;'>"
    + " ".join(_ek_satir_parcalari) + "</div>",
    unsafe_allow_html=True,
)

st.divider()

# ---------------------------------------------------------------------
# Üretim aşamaları (aynı sayfa, aynı reçete üzerinde)
# ---------------------------------------------------------------------
st.markdown("#### Üretim aşamaları")

malzeme_etiket = {
    rm["id"]: f"{malzeme_adi.get(rm['malzeme_id'], '?')} ({rm['miktar_gram']:.0f} g)"
    for rm in recete_malzemeleri
}

asamalar = (
    supabase.table("recete_asamalari")
    .select("*")
    .eq("recete_id", recete_id)
    .order("sira")
    .execute()
).data or []

asama_ad_by_id = {a["id"]: a["ad"] for a in asamalar}

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
            f"{a['baslangic_sicaklik']}°C → {a['hedef_sicaklik']}°C ({a['enerji_kaynagi']})"
            if a["isil_islem_mi"]
            else "—"
        )
        sure_metni = f"{a['sure_dakika']:.0f} dk"
        if a.get("aktif_dakika") is not None and a["aktif_dakika"] != a["sure_dakika"]:
            sure_metni += f" (aktif işçilik: {a['aktif_dakika']:.0f} dk)"
        st.markdown(
            f"**{a['sira']}. {a['ad']}** ({sure_metni}) — "
            f"Malzeme: {kullanilan} — Isıl işlem: {isil} — Bağımlı olduğu: {bagimlilik_metni}"
        )
        if st.button("Sil", key=f"asama_sil_{a['id']}", disabled=st.session_state.get("salt_okunur", False)):
            supabase.table("recete_asamalari").delete().eq("id", a["id"]).execute()
            st.rerun()

st.write("**Yeni aşama ekle**")
with st.form("yeni_asama_formu", clear_on_submit=True):
    c1, c2, c3 = st.columns(3)
    asama_adi_girdi = c1.text_input("Aşama adı (ör. 'Sebzeleri haşla')")
    sira = c2.number_input("Sıra", min_value=1, value=len(asamalar) + 1, step=1)
    sure_dakika = c3.number_input(
        "Toplam süre (dakika)", min_value=0.0, value=10.0, step=1.0,
        help="Bu aşamanın başlangıcından bitişine geçen GERÇEK süre "
        "(kritik yol/toplam üretim süresi hesabında kullanılır).",
    )

    pasif_asama_mi = st.checkbox(
        "Bu aşamanın büyük kısmı pasif (fırın/haşlama/bekletme gibi, personel "
        "sürekli meşgul değil)",
    )
    aktif_dakika = None
    if pasif_asama_mi:
        aktif_dakika = st.number_input(
            "Bu aşamada personelin GERÇEKTEN meşgul olduğu süre (dakika)",
            min_value=0.0, value=min(5.0, sure_dakika), step=1.0,
            help="Sadece işçilik maliyeti hesabında kullanılır (ör. periyodik "
            "kontrol). Toplam süre yukarıdaki değeri kullanmaya devam eder.",
        )

    isil_islem_mi = st.checkbox("Isıl işlem içerir (pişirme/haşlama/kızartma vb.)")
    enerji_kaynagi = baslangic_sicaklik = hedef_sicaklik = verimlilik = None
    if isil_islem_mi:
        ic1, ic2, ic3, ic4 = st.columns(4)
        enerji_kaynagi = ic1.selectbox("Enerji kaynağı", ["elektrik", "dogalgaz"])
        baslangic_sicaklik = ic2.number_input("Başlangıç sıcaklığı (°C)", value=20.0, step=5.0)
        hedef_sicaklik = ic3.number_input("Hedef sıcaklığı (°C)", value=100.0, step=5.0)
        verimlilik = ic4.slider("Verimlilik oranı", min_value=0.1, max_value=1.0, value=0.65, step=0.05)

    secilen_malzemeler = st.multiselect(
        "Bu aşamada işlenen malzemeler", options=list(malzeme_etiket.keys()),
        format_func=lambda k: malzeme_etiket[k],
    )
    onceki_asamalar = st.multiselect(
        "Hangi aşama(lar) bitmeden bu başlayamaz? (boş = baştan başlayabilir)",
        options=list(asama_ad_by_id.keys()), format_func=lambda k: asama_ad_by_id[k],
    )

    if st.form_submit_button("Aşamayı ekle", type="primary", disabled=st.session_state.get("salt_okunur", False)):
        if not asama_adi_girdi.strip():
            st.error("Aşama adı boş olamaz.")
        else:
            yeni_asama = (
                supabase.table("recete_asamalari")
                .insert(
                    {
                        "recete_id": recete_id,
                        "ad": asama_adi_girdi.strip(),
                        "sira": int(sira),
                        "sure_dakika": sure_dakika,
                        "aktif_dakika": aktif_dakika,
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

            st.success(f"'{asama_adi_girdi}' aşaması eklendi.")
            st.rerun()

if not asamalar:
    st.caption("Kritik yol ve gerçek üretim maliyeti için en az bir üretim aşaması eklemelisin.")
    st.stop()

st.divider()

# ---------------------------------------------------------------------
# Kritik yol (paralel işler dahil toplam süre)
# ---------------------------------------------------------------------
st.markdown("#### Toplam üretim süresi (paralel işler dahil)")
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
# Tam maliyet dökümü (malzeme + enerji + işçilik + genel gider)
# ---------------------------------------------------------------------
st.markdown("#### Gerçek porsiyon maliyeti")
uretim_maliyeti_sonuc = (
    supabase.table("recete_uretim_maliyeti")
    .select("*")
    .eq("recete_id", recete_id)
    .execute()
)
uretim_maliyeti = uretim_maliyeti_sonuc.data[0] if uretim_maliyeti_sonuc.data else None

if uretim_maliyeti:
    # OTUZ YEDINCI DUZELTME (24 Agustos 2026): "Genel gider payı" diger
    # hesaplamalardan (kullanicinin daha once bahsettigi bir onceki
    # duzeltmede) zaten cikarilmisti, tutarlilik icin BURADAN da
    # kaldirildi. recete_uretim_maliyeti VIEW'inin SQL tanimina
    # dokunmadik (gormedigimiz bir sey uzerinde tahmin yurutup risk
    # almamak icin) -- onun yerine, view'in dondurdugu toplami Python
    # tarafinda genel_gider_payi_eur kadar geri cikariyoruz. View'deki
    # sutun kaldirilmadigi icin ileride gerekirse sorunsuz geri
    # eklenebilir.
    m1, m2, m3 = st.columns(3)
    m1.metric("Malzeme", f"{uretim_maliyeti['malzeme_maliyeti_eur']:.2f} €")
    m2.metric("Enerji (ısıl işlem)", f"{uretim_maliyeti['enerji_maliyeti_eur']:.2f} €")
    m3.metric("İşçilik", f"{uretim_maliyeti['iscilik_maliyeti_eur']:.2f} €")
    _gercek_maliyet_gg_haric = (
        uretim_maliyeti["porsiyon_gercek_maliyet_eur"]
        - (uretim_maliyeti.get("genel_gider_payi_eur") or 0)
    )
    st.metric("**Porsiyon başı gerçek maliyet**", f"{_gercek_maliyet_gg_haric:.2f} €")
else:
    st.caption("Maliyet hesaplanamadı.")

st.divider()

# ---------------------------------------------------------------------
# Satisa acma (24 Agustos 2026: eskiden ayri bir sayfaydi -- pages/
# 2_Menu.py, "Ozel Menu Uretimi"). Kullanici talebiyle BURAYA, secili
# receteye ozel bir devam bolumu olarak tasindi ("Ozel Menu Uretimi,
# Recete Uretimi'nin devami niteligiginde olsun"). pages/2_Menu.py
# navigasyondan kaldirildi (bkz. app.py), dosyanin kendisi repodan
# silinmeli (git rm pages/2_Menu.py).
# ---------------------------------------------------------------------
st.markdown("#### Satışa Açma")

recete_menu_ogeleri = (
    supabase.table("menu_ogeleri")
    .select("*")
    .eq("recete_id", recete_id)
    .order("created_at", desc=True)
    .execute()
).data or []

if recete_menu_ogeleri:
    _menu_ogesi_idleri = [oge["id"] for oge in recete_menu_ogeleri]
    karlilik_listesi = (
        supabase.table("menu_ogesi_karlilik")
        .select("*")
        .in_("menu_ogesi_id", _menu_ogesi_idleri)
        .execute()
    ).data or []
    karlilik_sozluk = {k["menu_ogesi_id"]: k for k in karlilik_listesi}

    for oge in recete_menu_ogeleri:
        karlilik = karlilik_sozluk.get(oge["id"])
        with st.container(border=True):
            must1, must2 = st.columns([4, 1])
            with must1:
                st.write(f"**{oge['menu_adi']}**")
                if oge.get("aciklama"):
                    st.caption(oge["aciklama"])
            with must2:
                aktif = st.toggle(
                    "Aktif", value=oge["aktif_mi"], key=f"aktif_{oge['id']}",
                    disabled=st.session_state.get("salt_okunur", False),
                )
                if aktif != oge["aktif_mi"]:
                    supabase.table("menu_ogeleri").update({"aktif_mi": aktif}).eq("id", oge["id"]).execute()
                    st.rerun()

            mn1, mn2, mn3 = st.columns(3)
            mn1.metric("Satış fiyatı", f"{oge['satis_fiyati']:.2f} €")
            if karlilik and karlilik.get("porsiyon_maliyeti_eur") is not None:
                mn2.metric("Porsiyon maliyeti", f"{karlilik['porsiyon_maliyeti_eur']:.2f} €")
                yuzde = karlilik.get("kar_marji_yuzde")
                mn3.metric(
                    "Kâr marjı",
                    f"{karlilik['kar_marji_eur']:.2f} € ({yuzde:.0f}%)" if yuzde is not None
                    else f"{karlilik['kar_marji_eur']:.2f} €",
                )
            else:
                mn2.caption("Maliyet hesaplanamadı — reçetede malzeme eksik olabilir.")

            if st.button("Menüden sil", key=f"menu_sil_{oge['id']}", disabled=st.session_state.get("salt_okunur", False)):
                supabase.table("menu_ogeleri").delete().eq("id", oge["id"]).execute()
                st.rerun()
else:
    st.caption("Bu reçete henüz satışa açılmadı.")

with st.expander(
    "Bu reçeteyi menüye ekle" if not recete_menu_ogeleri else "Menüye başka bir isimle daha ekle"
):
    with st.form(f"menu_ekle_{recete_id}", clear_on_submit=True):
        menu_adi = st.text_input("Menüde görünecek ad", value=recete["ad"])
        satis_fiyati = st.number_input("Satış fiyatı (€)", min_value=0.0, step=0.5)
        aciklama = st.text_area("Açıklama (opsiyonel)")
        ekle = st.form_submit_button(
            "Menüye ekle", type="primary", disabled=st.session_state.get("salt_okunur", False)
        )
        if ekle:
            if not menu_adi.strip():
                st.error("Menü adı boş olamaz.")
            else:
                supabase.table("menu_ogeleri").insert(
                    {
                        "isletme_id": isletme_id,
                        "recete_id": recete_id,
                        "menu_adi": menu_adi.strip(),
                        "aciklama": aciklama.strip() or None,
                        "satis_fiyati": satis_fiyati,
                    }
                ).execute()
                st.success(f"'{menu_adi}' menüye eklendi.")
                st.rerun()
