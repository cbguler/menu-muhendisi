# pages/5_Yillik_Menu.py
#
# Yillik Menu Uretim Motoru (ilk surum): global tarif kutuphanesinden
# (receteler, isletme_id NULL) anayasa kurallarina uygun ornek haftalik
# menu uretir. Henuz eklenmeyenler: kisisel_beslenme_profili filtrelemesi,
# menu_takvimi/menu_takvimi_ogeleri'ne yazma (sadece ekranda gosteriyor).

import io
import random
import urllib.parse

import streamlit as st
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

from sidebar_logo import sidebar_logo_goster

from db import get_supabase, oturumu_uygula
from uretim_algoritmasi import MEVSIMLER, hafta_olustur

MEVSIM_AYLARI = {
    "kis": ["Aralık", "Ocak", "Şubat"],
    "ilkbahar": ["Mart", "Nisan", "Mayıs"],
    "yaz": ["Haziran", "Temmuz", "Ağustos"],
    "sonbahar": ["Eylül", "Ekim", "Kasım"],
}
AYLAR_SIRALI = [
    "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
    "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
]

st.set_page_config(page_title="Yıllık Menü", page_icon="assets/favicon.png", layout="wide")
sidebar_logo_goster(animasyonlu=False)

supabase = get_supabase()
oturumu_uygula(supabase)

st.title("Yıllık Menü Üretim Motoru")
st.caption(
    "Türk mutfağı tarif kütüphanesinden, anayasa kurallarına uygun "
    "(madde 8, 11, 13) örnek haftalık menü üretir. İlk sürüm — kişisel "
    "beslenme profili filtrelemesi ve takvime kaydetme henüz eklenmedi."
)


@st.cache_data(ttl=3600)
def _mutfaklari_getir():
    return (supabase.table("mutfaklar").select("kod, ad").execute()).data


mutfaklar_listesi = _mutfaklari_getir()
sol_mutfak, _bos_mutfak = st.columns([1, 3])
with sol_mutfak:
    mutfak_secimi = st.selectbox(
        "Mutfak", mutfaklar_listesi, format_func=lambda m: m["ad"],
    )
# Su an sadece Turk Mutfagi var, ama tarif sorgusu asagida mutfak_secimi["kod"]'a
# gore calisiyor -- ileride yeni bir mutfak (ör. Fransiz Mutfagi) eklenip
# kendi mutfak_kategorileri/receteler'i girildiginde, bolge butonlari ve
# tum akis otomatik olarak o mutfaga gore calisacak, ek kod degisikligi gerekmez.


@st.cache_data(ttl=3600)
def _tarif_kutuphanesini_getir(mutfak_kodu):
    mutfak = (
        supabase.table("mutfaklar").select("id").eq("kod", mutfak_kodu).single().execute()
    ).data
    kategoriler = (
        supabase.table("mutfak_kategorileri")
        .select("id, sira")
        .eq("mutfak_id", mutfak["id"])
        .execute()
    ).data
    grup_by_kategori = {k["id"]: k["sira"] for k in kategoriler}

    receteler = (
        supabase.table("receteler")
        .select("ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi, bolge")
        .is_("isletme_id", "null")
        .execute()
    ).data

    tarifler = []
    for r in receteler:
        grup = grup_by_kategori.get(r["mutfak_kategori_id"])
        if grup is None:
            continue
        tarifler.append(
            {
                "ad": r["ad"],
                "grup": grup,
                "mevsim_etiketi": r["mevsim_etiketi"] or "yil_boyunca",
                "etiketler": r["ozel_etiketler"] or [],
                "bolge": r["bolge"] or "Genel",
            }
        )
    return tarifler


@st.cache_data(ttl=3600)
def _tarif_detaylarini_getir(isletme_id):
    """Global tariflerin porsiyon basi besin degeri, alerjen listesi ve
    (bu isletmenin kendi malzeme fiyatlariyla) maliyetini hesaplar.
    Maliyet isletmeye ozeldir cunku fiyatlar isletme_id'ye gore tutuluyor
    (malzeme_guncel_fiyat) -- global tariflerin kendi fiyati yok."""
    receteler = (
        supabase.table("receteler").select("id, ad").is_("isletme_id", "null").execute()
    ).data
    id_to_ad = {r["id"]: r["ad"] for r in receteler}

    malzeme_kalemleri = (
        supabase.table("recete_malzemeleri")
        .select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(ad, kalori, protein, yag, karbonhidrat, glisemik_indeks)"
        )
        .execute()
    ).data

    alerjen_kayitlari = (
        supabase.table("malzeme_alerjen").select("malzeme_id, alerjenler(ad)").execute()
    ).data
    alerjen_by_malzeme = {}
    for kayit in alerjen_kayitlari:
        ad = (kayit.get("alerjenler") or {}).get("ad")
        if ad:
            alerjen_by_malzeme.setdefault(kayit["malzeme_id"], set()).add(ad)

    fiyat_kayitlari = (
        supabase.table("malzeme_guncel_fiyat")
        .select("malzeme_id, fiyat_eur")
        .eq("isletme_id", isletme_id)
        .execute()
    ).data
    fiyat_by_malzeme = {f["malzeme_id"]: f["fiyat_eur"] for f in fiyat_kayitlari}
    fiyat_verisi_var = len(fiyat_by_malzeme) > 0

    ham = {}
    for kalem in malzeme_kalemleri:
        ad = id_to_ad.get(kalem["recete_id"])
        if ad is None:
            continue  # baska bir isletmeye ait ozel tarif olabilir, atla
        m = kalem.get("malzemeler") or {}
        oran = kalem["miktar_gram"] / 100.0
        girdi = ham.setdefault(
            ad, {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
                 "gi_agirlikli": 0.0, "gi_karb_toplam": 0.0, "maliyet_eur": 0.0,
                 "tam_fiyatli": True, "eksik_malzemeler": set(), "alerjenler": set()}
        )
        girdi["kalori"] += (m.get("kalori") or 0) * oran
        girdi["protein"] += (m.get("protein") or 0) * oran
        girdi["yag"] += (m.get("yag") or 0) * oran
        karb = (m.get("karbonhidrat") or 0) * oran
        girdi["karbonhidrat"] += karb
        gi = m.get("glisemik_indeks")
        if gi is not None and karb > 0:
            girdi["gi_agirlikli"] += gi * karb
            girdi["gi_karb_toplam"] += karb

        malzeme_id = kalem["malzeme_id"]
        fiyat = fiyat_by_malzeme.get(malzeme_id)
        if fiyat is None:
            girdi["tam_fiyatli"] = False
            malzeme_adi = m.get("ad")
            if malzeme_adi:
                girdi["eksik_malzemeler"].add(malzeme_adi)
        else:
            girdi["maliyet_eur"] += (kalem["miktar_gram"] / 1000.0) * fiyat
        girdi["alerjenler"] |= alerjen_by_malzeme.get(malzeme_id, set())

    sonuc = {}
    for ad, v in ham.items():
        gi = (v["gi_agirlikli"] / v["gi_karb_toplam"]) if v["gi_karb_toplam"] > 0 else None
        sonuc[ad] = {
            "kalori": v["kalori"], "protein": v["protein"],
            "yag": v["yag"], "karbonhidrat": v["karbonhidrat"], "gi": gi,
            "maliyet_eur": v["maliyet_eur"], "tam_fiyatli": v["tam_fiyatli"],
            "eksik_malzemeler": v["eksik_malzemeler"], "alerjenler": v["alerjenler"],
        }
    return sonuc, fiyat_verisi_var


def _ogun_toplami(tarif_adlari, detay):
    toplam = {"kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0, "maliyet_eur": 0.0}
    gi_agirlikli = 0.0
    gi_karb_toplam = 0.0
    tam_fiyatli = True
    eksik_malzemeler = set()
    alerjenler = set()
    for ad in tarif_adlari:
        b = detay.get(ad)
        if not b:
            continue
        toplam["kalori"] += b["kalori"]
        toplam["protein"] += b["protein"]
        toplam["yag"] += b["yag"]
        toplam["karbonhidrat"] += b["karbonhidrat"]
        toplam["maliyet_eur"] += b["maliyet_eur"]
        tam_fiyatli = tam_fiyatli and b["tam_fiyatli"]
        eksik_malzemeler |= b["eksik_malzemeler"]
        alerjenler |= b["alerjenler"]
        if b["gi"] is not None and b["karbonhidrat"] > 0:
            gi_agirlikli += b["gi"] * b["karbonhidrat"]
            gi_karb_toplam += b["karbonhidrat"]
    toplam["gi"] = round(gi_agirlikli / gi_karb_toplam) if gi_karb_toplam > 0 else None
    toplam["tam_fiyatli"] = tam_fiyatli
    toplam["eksik_malzemeler"] = eksik_malzemeler
    toplam["alerjenler"] = alerjenler
    return toplam


tarifler = _tarif_kutuphanesini_getir(mutfak_secimi["kod"])

if not tarifler:
    st.warning(
        "Global tarif kütüphanesi boş görünüyor. Önce `yukle_tarifler.py` "
        "ile 74 tarifin Supabase'e yüklendiğinden emin ol."
    )
    st.stop()

st.caption(f"Kütüphanede {len(tarifler)} tarif bulundu.")

KISA_BOLGE_ADI = {
    "Genel": "Klasik",
    "Doğu Anadolu": "Doğu",
    "Güneydoğu Anadolu": "Güneydoğu",
}

BOLGE_SIRASI = ["Marmara", "Ege", "Akdeniz", "Karadeniz", "İç Anadolu", "Doğu Anadolu", "Güneydoğu Anadolu"]
mevcut_diger_bolgeler = {t["bolge"] for t in tarifler} - {"Genel"}
diger_bolgeler = [b for b in BOLGE_SIRASI if b in mevcut_diger_bolgeler]
diger_bolgeler += sorted(mevcut_diger_bolgeler - set(BOLGE_SIRASI))  # BOLGE_SIRASI'nda olmayan yeni bolgeler sona eklenir
bolgeler_mevcut = (["Genel"] if any(t["bolge"] == "Genel" for t in tarifler) else []) + diger_bolgeler

if "secili_bolgeler_set" not in st.session_state:
    st.session_state.secili_bolgeler_set = set()  # bos = hicbir kisit yok, tumu kullanilir

st.markdown("**Bölge (mutfak)**")
st.caption("Hiçbiri seçili değilken tüm bölgeler kullanılır. Bir bölgeye tıklamak SADECE onu etkinleştirir.")
kolonlar = st.columns(len(bolgeler_mevcut))
for kolon, bolge in zip(kolonlar, bolgeler_mevcut):
    secili = bolge in st.session_state.secili_bolgeler_set
    etiket = KISA_BOLGE_ADI.get(bolge, bolge)
    if kolon.button(
        etiket, key=f"bolge_buton_{bolge}", use_container_width=True,
        type="primary" if secili else "secondary",
    ):
        if secili:
            st.session_state.secili_bolgeler_set.discard(bolge)
        else:
            st.session_state.secili_bolgeler_set.add(bolge)
        st.rerun()

secili_bolgeler = st.session_state.secili_bolgeler_set

if secili_bolgeler:
    tarifler = [t for t in tarifler if t["bolge"] in secili_bolgeler]
# secili_bolgeler bossa (hicbir buton tiklanmamissa) hicbir filtre uygulanmaz, tum bolgeler kullanilir

if not tarifler:
    st.warning("Seçtiğin bölge(ler)de hiç tarif bulunamadı.")
    st.stop()

if secili_bolgeler:
    st.caption(f"Seçili bölge(ler)de {len(tarifler)} tarif kullanılacak.")
else:
    st.caption(f"Hiçbir bölge seçilmedi, tüm {len(tarifler)} tarif kullanılacak.")


detay, fiyat_verisi_var = _tarif_detaylarini_getir(st.session_state.isletme_id)
if not fiyat_verisi_var:
    st.caption(
        "Bu işletme için henüz malzeme fiyatı girilmemiş — maliyet "
        "sütunu bu yüzden hesaplanamıyor (\"-\" gösterilecek)."
    )

# Uretim algoritmasi besin hedefi kontrolu icin her tarife kalori/protein/
# yag/karbonhidrat/gi ekliyoruz (detay'dan -- zaten hesaplanmisti).
tarifler_zengin = []
for t in tarifler:
    b = detay.get(t["ad"], {})
    t2 = dict(t)
    t2["kalori"] = b.get("kalori")
    t2["protein"] = b.get("protein")
    t2["yag"] = b.get("yag")
    t2["karbonhidrat"] = b.get("karbonhidrat")
    t2["gi"] = b.get("gi")
    tarifler_zengin.append(t2)

sol, sag, _bos = st.columns([1, 1, 3])
with sol:
    mevsim_secimi = st.selectbox("Mevsim", MEVSIMLER, format_func=lambda m: m.capitalize())
with sag:
    ay_secimi = st.selectbox("Ay", MEVSIM_AYLARI[mevsim_secimi])

besin_hedefi_kullan = st.checkbox("Öğün başına besin hedefi uygula (opsiyonel)")

BESIN_SATIRLARI = [
    ("kalori", "Kalori (kcal)", 0, 3000, 900, 1200),
    ("protein", "Protein (g)", 0, 150, 20, 60),
    ("yag", "Yağ (g)", 0, 120, 10, 40),
    ("karbonhidrat", "Karbonhidrat (g)", 0, 300, 40, 120),
    ("gi", "Glisemik İndeks", 0, 100, 0, 70),
]

hedefler = None
if besin_hedefi_kullan:
    hedefler = {}
    for ogun_adi in ("Öğle", "Akşam"):
        with st.expander(f"{ogun_adi} hedefleri", expanded=False):
            hedefler[ogun_adi] = {}
            for anahtar, etiket, minv, maxv, def_alt, def_ust in BESIN_SATIRLARI:
                c1, c2 = st.columns(2)
                with c1:
                    alt = st.number_input(
                        f"{etiket} — min", min_value=minv, max_value=maxv,
                        value=def_alt, key=f"{ogun_adi}_{anahtar}_alt",
                    )
                with c2:
                    ust = st.number_input(
                        f"{etiket} — maks", min_value=minv, max_value=maxv,
                        value=def_ust, key=f"{ogun_adi}_{anahtar}_ust",
                    )
                hedefler[ogun_adi][anahtar] = (alt, ust)

if hedefler and secili_bolgeler and len(tarifler) < 60:
    st.caption(
        "Dikkat: dar bir bölge seçiliyken besin hedefi de uygularsan, küçük "
        "havuzda hedefe uyan tarif sayısı çok azalabilir ve menü tek bir "
        "yemeğe kilitlenebilir. Çeşitlilik azsa hedef aralığını genişletmeyi "
        "veya daha fazla bölge seçmeyi dene."
    )

if st.button("Ay için menü üret", type="primary"):
    ay_index = AYLAR_SIRALI.index(ay_secimi)
    haftalar = []
    for hafta_no in range(1, 5):
        tohum = ay_index * 10 + hafta_no  # deterministik: ayni ay+hafta = ayni sonuc
        rastgele = random.Random(tohum)
        haftalar.append(
            hafta_olustur(tarifler_zengin, mevsim_secimi, rastgele, hedefler=hedefler)
        )
    st.session_state["yillik_menu_aylik"] = {"ay": ay_secimi, "haftalar": haftalar}
    st.session_state["yillik_menu_hedefler"] = hedefler

RENKLER = {1: "#D85A30", 2: "#639922", 3: "#1D9E75"}


def _hedefte_mi(ogun_adi, t, hedefler):
    if not hedefler or ogun_adi not in hedefler:
        return None
    for anahtar, (alt, ust) in hedefler[ogun_adi].items():
        deger = t.get(anahtar)
        if deger is None:
            continue
        if not (alt <= deger <= ust):
            return False
    return True


def _hafta_kart_izgarasi_html(hafta, detay, fiyat_verisi_var, hedefler):
    kartlar = []
    for gun in hafta:
        ogun_html = ""
        for ogun_adi, tarif_adlari in gun["ogunler"].items():
            satirlar = "".join(
                f"<div style='margin-left:6px;'>"
                f"<span style='color:{RENKLER[i + 1]};'>●</span> "
                f"<a href='tarif-kutuphanesi?tarif={urllib.parse.quote(ad)}' "
                f"target='_self' style='color:inherit; text-decoration:underline;'>{ad}</a></div>"
                for i, ad in enumerate(tarif_adlari)
            )

            t = _ogun_toplami(tarif_adlari, detay)
            gi_metin = f"{t['gi']}" if t["gi"] is not None else "-"

            if not fiyat_verisi_var:
                maliyet_metin = "-"
            elif t["tam_fiyatli"]:
                maliyet_metin = f"{t['maliyet_eur']:.2f} €"
            else:
                eksik_liste = ", ".join(sorted(t["eksik_malzemeler"]))
                maliyet_metin = f"≈{t['maliyet_eur']:.2f} € (eksik fiyat: {eksik_liste})"

            alerjen_metin = ", ".join(sorted(t["alerjenler"])) if t["alerjenler"] else "Yok"

            hedef_metin = ""
            hedefte = _hedefte_mi(ogun_adi, t, hedefler)
            if hedefte is True:
                hedef_metin = "<div style='color:#1D9E75;'>Hedefte</div>"
            elif hedefte is False:
                hedef_metin = "<div style='color:#D85A30;'>Hedef dışı</div>"

            ogun_html += (
                f"<div style='margin:6px 0;'><b>{ogun_adi}</b>{satirlar}"
                f"<div style='color:#666; margin-top:3px;'>{round(t['kalori'])} kcal · "
                f"P {round(t['protein'])}g · Y {round(t['yag'])}g · "
                f"K {round(t['karbonhidrat'])}g · Gİ {gi_metin}</div>"
                f"<div style='color:#666;'>Alerjen: {alerjen_metin}</div>"
                f"<div style='color:#666;'>Maliyet: {maliyet_metin}</div>"
                f"{hedef_metin}"
                f"</div>"
            )

        kart_html = f"""
            <div style="border:0.5px solid var(--border, #ddd); border-radius:10px;
                        padding:10px 12px; font-size:11.5px; line-height:1.5;">
              <div style="font-weight:600; margin-bottom:4px; font-size:13px;">Gün {gun['gun']}</div>
              {ogun_html}
            </div>
            """
        # Tek satira sikistir: coklu-satirli/girintili HTML parcalari yan
        # yana birlestirilince araya yanlislikla bos satir girip Streamlit'in
        # markdown ayiricisinin "HTML blogu bitti" sanmasina (ve sonraki
        # kartlari duz metin olarak kacis'lamasina) yol aciyordu.
        kartlar.append(" ".join(kart_html.split()))

    return (
        f"<div style='display:grid; grid-template-columns:repeat({len(hafta)}, 1fr); "
        "gap:8px;'>" + "".join(kartlar) + "</div>"
    )


def _aylik_menu_excel_olustur(aylik, detay, fiyat_verisi_var, hedefler):
    """Aylık menüyü ekrandaki kart görünümüyle AYNI düzende Excel'e döker:
    her gün bir sütun, altında Öğle/Akşam blokları (yemekler + besin +
    alerjen + maliyet) aynı sırayla. Bir finansal model degil -- formul
    gerekmiyor, sadece ekrandakiyle bire bir eslesen bir gorunum."""
    wb = Workbook()
    ws = wb.active
    ws.title = "Yıllık Menü"

    yazi_tipi = "Arial"
    baslik_yazi = Font(name=yazi_tipi, bold=True, color="FFFFFF")
    baslik_dolgu = PatternFill(start_color="2C6B3C", end_color="2C6B3C", fill_type="solid")
    hafta_baslik_yazi = Font(name=yazi_tipi, bold=True, size=13)
    alan_yazi = Font(name=yazi_tipi, bold=True)
    normal_yazi = Font(name=yazi_tipi)
    RENK_ANA, RENK_YARDIMCI, RENK_TAMAMLAYICI = "D85A30", "639922", "1D9E75"

    ALAN_SATIRLARI = [
        ("Ana Yemek", RENK_ANA), ("Yardımcı Yemek", RENK_YARDIMCI), ("Tamamlayıcı", RENK_TAMAMLAYICI),
        ("Besin (kcal/P/Y/K/Gİ)", None), ("Alerjen", None), ("Maliyet", None),
    ]

    def oyun_bloguna_yaz(satir, ogun_adi, tarif_adlari, t, gun_kolonu):
        ws.cell(row=satir, column=1, value=ogun_adi).font = alan_yazi
        satir += 1
        alan_satirlari = list(ALAN_SATIRLARI)
        if hedefler:
            alan_satirlari.append(("Hedef Durumu", None))
        for i, (etiket, renk) in enumerate(alan_satirlari):
            hucre_etiket = ws.cell(row=satir, column=1, value=etiket)
            hucre_etiket.font = Font(name=yazi_tipi, color=renk) if renk else normal_yazi
            if i < 3:
                deger = tarif_adlari[i]
            elif etiket.startswith("Besin"):
                gi_deger = f"{round(t['gi'])}" if t["gi"] is not None else "-"
                deger = (
                    f"{round(t['kalori'])} kcal · P{round(t['protein'])}g · "
                    f"Y{round(t['yag'])}g · K{round(t['karbonhidrat'])}g · Gİ{gi_deger}"
                )
            elif etiket == "Alerjen":
                deger = ", ".join(sorted(t["alerjenler"])) if t["alerjenler"] else "Yok"
            elif etiket == "Hedef Durumu":
                hedefte = _hedefte_mi(ogun_adi, t, hedefler)
                deger = {True: "Hedefte", False: "Hedef dışı", None: "-"}[hedefte]
            else:  # Maliyet
                if not fiyat_verisi_var:
                    deger = "-"
                elif t["tam_fiyatli"]:
                    deger = f"{t['maliyet_eur']:.2f} €"
                else:
                    eksik_liste = ", ".join(sorted(t["eksik_malzemeler"]))
                    deger = f"≈{t['maliyet_eur']:.2f} € (eksik: {eksik_liste})"
            hucre = ws.cell(row=satir, column=gun_kolonu, value=deger)
            hucre.font = normal_yazi
            hucre.alignment = Alignment(wrap_text=True, vertical="top")
            satir += 1
        return satir

    satir = 1
    for hafta_no, hafta in enumerate(aylik["haftalar"], start=1):
        gun_sayisi = len(hafta)

        ws.cell(row=satir, column=1, value=f"{aylik['ay']} — {hafta_no}. Hafta").font = hafta_baslik_yazi
        satir += 1

        baslik_satiri = satir
        ws.cell(row=baslik_satiri, column=1, value="")
        for g in range(gun_sayisi):
            hucre = ws.cell(row=baslik_satiri, column=g + 2, value=f"Gün {g + 1}")
            hucre.font = baslik_yazi
            hucre.fill = baslik_dolgu
            hucre.alignment = Alignment(horizontal="center")
        satir += 1

        blok_baslangic = satir
        for g, gun in enumerate(hafta):
            gun_kolonu = g + 2
            s = blok_baslangic
            for ogun_adi, tarif_adlari in gun["ogunler"].items():
                t = _ogun_toplami(tarif_adlari, detay)
                s = oyun_bloguna_yaz(s, ogun_adi, tarif_adlari, t, gun_kolonu)
        satir = s + 1  # bir sonraki hafta bloğundan önce bos satir

    genislikler = [24] + [24] * 7
    for i, genislik in enumerate(genislikler, start=1):
        ws.column_dimensions[get_column_letter(i)].width = genislik

    tampon = io.BytesIO()
    wb.save(tampon)
    return tampon.getvalue()


aylik = st.session_state.get("yillik_menu_aylik")
if aylik:
    kayitli_hedefler = st.session_state.get("yillik_menu_hedefler")

    excel_verisi = _aylik_menu_excel_olustur(aylik, detay, fiyat_verisi_var, kayitli_hedefler)
    st.download_button(
        "Excel'e indir",
        data=excel_verisi,
        file_name=f"yillik_menu_{aylik['ay']}.xlsx",
        mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    )

    st.markdown(
        "<div style='font-size:13px; color:gray; margin:0.5rem 0 1rem;'>"
        "<span style='color:#D85A30;'>●</span> Ana Yemek&nbsp;&nbsp;&nbsp;"
        "<span style='color:#639922;'>●</span> Yardımcı Yemek&nbsp;&nbsp;&nbsp;"
        "<span style='color:#1D9E75;'>●</span> Tamamlayıcılar</div>",
        unsafe_allow_html=True,
    )

    for i, hafta in enumerate(aylik["haftalar"], start=1):
        st.markdown(f"**{aylik['ay']} — {i}. Hafta**")
        st.markdown(
            _hafta_kart_izgarasi_html(hafta, detay, fiyat_verisi_var, kayitli_hedefler),
            unsafe_allow_html=True,
        )
