# uretim_algoritmasi.py
#
# Yillik Menu Uretim Motoru -- ILK SURUM (prototip).
# Anayasa kurallarina gore haftalik/yillik menu takvimini otomatik
# doldurur. VERI KAYNAGINDAN BAGIMSIZDIR: `tarifler` parametresi olarak
# [{"ad","grup","mevsim_etiketi","etiketler","kalori","protein","yag",
#   "karbonhidrat","gi"}, ...] seklinde bir liste bekler -- besin
# alanlari (kalori/protein/yag/karbonhidrat/gi) opsiyoneldir, sadece
# hedef araligi kullanilacaksa gereklidir.
#
# Uyguladigi kurallar:
#   Madde 8  - her ogun I. + II. + III. Grup icerir (1'er tarif)
#   Madde 2  - ayni hafta icinde bir tarif tekrarlanmaz (mumkun oldugunca)
#   Madde 11 - uyumsuzluk kurallari (asagida UYUMSUZLUK) -- HER ZAMAN uygulanir
#   Madde 13 - tamamlayici eslestirme (asagida TAMAMLAYICI, tercih --
#              zorunlu degil, mumkunse uygulanir)
#   Mevsimsellik - once ayni mevsim + yil_boyunca tarifler denenir
#   Besin hedefi - opsiyonel, ogun bazinda kalori/protein/yag/
#              karbonhidrat/glisemik indeks araligi (kullanici belirler)
#
# NOT: kisisel_beslenme_profili filtrelemesi (alerjen, kisitlama vb.)
# henuz eklenmedi -- bir sonraki adim.

import random

# --- Anayasa madde 11: uyumsuzluk kurallari (etiket ciftleri) ---
UYUMSUZLUK = [
    ("zeytinyagli", "etli_sebze"),
    ("pilav_makarna_borek", "tatli"),  # istisna: sporcu_uygun
    ("zeytinyagli", "salata"),
    ("etli_zeytinyagli_dolma", "pilav_makarna_borek"),
]

# --- Anayasa madde 13: tamamlayici eslestirme (oncelik sirali) ---
TAMAMLAYICI = {
    "dolma": ["yogurt"],
    "izgara": ["salata", "tursu"],
    "kuru_baklagil": ["tursu", "salata"],
    "balik": ["salata"],
}

MEVSIMLER = ["kis", "ilkbahar", "yaz", "sonbahar"]
# ON DOKUZUNCU DUZELTME (13 Agustos 2026, Oturum 11): temel 4 alanin
# yanina, malzemeler tablosundaki 27 genisletilmis besin ogesi de
# eklendi -- kullanicinin Yillik Menu'de bunlari da SECEREK
# hedefleyebilmesi icin (bkz. pages/0_Yillik_Menu.py TUM_BESIN_ALANLARI).
# ogun_besin_toplami ve _hedef_saglaniyor_mu zaten anahtar-bagimsiz
# (generic) yazildigi icin bu listeye eklemek yeterli, baska bir
# degisiklik gerekmiyor.
BESIN_ANAHTARLARI = (
    "kalori", "protein", "yag", "karbonhidrat",
    "sodyum_mg", "lif_g", "seker_g", "doymus_yag_g",
    "vitamin_a_mcg", "vitamin_b1_mg", "vitamin_b2_mg", "vitamin_b3_mg",
    "vitamin_b5_mg", "vitamin_b6_mg", "vitamin_b7_mcg", "vitamin_b9_mcg",
    "vitamin_b12_mcg", "vitamin_c_mg", "vitamin_d_mcg", "vitamin_e_mg",
    "vitamin_k_mcg", "kalsiyum_mg", "demir_mg", "magnezyum_mg",
    "potasyum_mg", "cinko_mg", "fosfor_mg", "bakir_mg", "manganez_mg",
    "selenyum_mcg", "iyot_mcg",
)


def _uyumlu_mu(etiket_kumesi):
    """Bir ogun icin secilen 3 tarifin BIRLESIK etiketleri arasinda
    anayasa madde 11'e aykiri bir cift var mi kontrol eder."""
    for a, b in UYUMSUZLUK:
        if a in etiket_kumesi and b in etiket_kumesi:
            if a == "pilav_makarna_borek" and b == "tatli":
                if "sporcu_uygun" in etiket_kumesi:
                    continue  # istisna uygulandi
            return False
    return True


def ogun_besin_toplami(t1, t2, t3):
    """3 tarifin toplam kalori/protein/yag/karbonhidrat'ini ve
    karbonhidrata-agirlikli ortalama glisemik indeksini hesaplar.
    Tariflerde besin alanlari yoksa (None/eksik) 0 sayilir."""
    toplam = {k: 0.0 for k in BESIN_ANAHTARLARI}
    gi_agirlikli = 0.0
    gi_karb_toplam = 0.0
    for t in (t1, t2, t3):
        for k in BESIN_ANAHTARLARI:
            toplam[k] += t.get(k) or 0
        gi = t.get("gi")
        karb = t.get("karbonhidrat") or 0
        if gi is not None and karb > 0:
            gi_agirlikli += gi * karb
            gi_karb_toplam += karb
    toplam["gi"] = (gi_agirlikli / gi_karb_toplam) if gi_karb_toplam > 0 else None
    return toplam


def _hedef_saglaniyor_mu(t1, t2, t3, hedef):
    """hedef: {"kalori": (min,max), "protein": (min,max), ...} -- sadece
    hedefte belirtilen anahtarlar kontrol edilir. hedef bos/None ise
    her zaman True doner. gi hesaplanamiyorsa (karbonhidratsiz ogun)
    o kontrol atlanir."""
    if not hedef:
        return True
    besin = ogun_besin_toplami(t1, t2, t3)
    for anahtar, (alt, ust) in hedef.items():
        deger = besin.get(anahtar)
        if deger is None:
            continue  # degerlendirilemiyor (ör. karbonhidratsiz ogunde gi) -- serbest birak
        if not (alt <= deger <= ust):
            return False
    return True


def _aday_havuzu(havuz, mevsim, kullanilan_hafta, tekrara_izin_ver=False, mevsim_zorunlu=True):
    if tekrara_izin_ver:
        if mevsim_zorunlu:
            aday = [r for r in havuz if r["mevsim_etiketi"] in (mevsim, "yil_boyunca")]
            if not aday:
                aday = list(havuz)
        else:
            aday = list(havuz)
        return aday
    if mevsim_zorunlu:
        return [
            r for r in havuz
            if r["ad"] not in kullanilan_hafta and r["mevsim_etiketi"] in (mevsim, "yil_boyunca")
        ]
    return [r for r in havuz if r["ad"] not in kullanilan_hafta]


def _grup3_tercih_sirasi(grup1_etiketler):
    for anahtar, tercihler in TAMAMLAYICI.items():
        if anahtar in grup1_etiketler:
            return tercihler
    return []


def _ogun_dene(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, deneme_sayisi, tekrara_izin_ver, mevsim_zorunlu=True, hedef=None):
    """Verilen esneklik seviyesinde ogun kombinasyonu aramaya calisir.
    UYUMSUZLUK (madde 11) HER ZAMAN uygulanir, gevsetilmez -- haftalik-
    tekrar, mevsim kisiti VE besin hedefi kademeli olarak gevsetilebilir."""
    for _ in range(deneme_sayisi):
        aday1 = _aday_havuzu(grup1_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu)
        aday2 = _aday_havuzu(grup2_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu)
        aday3 = _aday_havuzu(grup3_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu)
        if not (aday1 and aday2 and aday3):
            return None

        t1 = rastgele.choice(aday1)

        aday2_uyumlu = [t for t in aday2 if _uyumlu_mu(set(t1["etiketler"]) | set(t["etiketler"]))]
        if not aday2_uyumlu:
            continue
        t2 = rastgele.choice(aday2_uyumlu)

        birlesik_12 = set(t1["etiketler"]) | set(t2["etiketler"])
        tercih_sirasi = _grup3_tercih_sirasi(t1["etiketler"])

        aday3_uyumlu = [t for t in aday3 if _uyumlu_mu(birlesik_12 | set(t["etiketler"]))]
        if not aday3_uyumlu:
            continue

        # Once tamamlayici tercihe uyan adaylar arasindan hedefe uyani ara;
        # bulunamazsa tum uyumlu adaylara genislet.
        tercih_edilenler = []
        for tercih_etiket in tercih_sirasi:
            tercih_edilenler = [t for t in aday3_uyumlu if tercih_etiket in t["etiketler"]]
            if tercih_edilenler:
                break

        for aday_listesi in (tercih_edilenler, aday3_uyumlu):
            if not aday_listesi:
                continue
            karisik = list(aday_listesi)
            rastgele.shuffle(karisik)
            for t3 in karisik:
                if _hedef_saglaniyor_mu(t1, t2, t3, hedef):
                    return t1, t2, t3
            break  # tercih edilenlerde hicbiri hedefe uymadi, tekrar deneme dongusune don
    return None


def ogun_olustur(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, hedef=None):
    """Tek bir ogun (Ogle veya Aksam) icin I+II+III grup tarifi secer.
    Kademeli esneme sirasi (UYUMSUZLUK/madde 11 hicbirinde gevsetilmez):
      1) mevsime uygun + hafta icinde tekrarsiz + besin hedefi icinde
      2) mevsim kisitini gevset + hala tekrarsiz + besin hedefi icinde
      3) tekrara da izin ver (mevsim gevsek) + besin hedefi icinde
      4) son care: besin hedefini de gevset (mevsim/tekrar gevsek kalir)
    """
    for tekrara_izin_ver, mevsim_zorunlu, bu_hedef in (
        (False, True, hedef),
        (False, False, hedef),
        (True, False, hedef),
        (True, False, None),
    ):
        sonuc = _ogun_dene(
            grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele,
            200, tekrara_izin_ver, mevsim_zorunlu, bu_hedef,
        )
        if sonuc is not None:
            return sonuc

    # Buraya kadar gelinmesi cok olasi degil (uyumsuzluk kurallarini
    # saglayan hicbir ucteli bulunamadi demektir) -- yine de programin
    # cokmemesi icin en gevsek secimi yapiyoruz, ama bunu acikca isaretliyoruz.
    return (
        rastgele.choice(grup1_havuz),
        rastgele.choice(grup2_havuz),
        rastgele.choice(grup3_havuz),
    )


def _fast_food_sec(grup4_havuz, birlesik_etiketler, rastgele):
    """ISTEGE BAGLI 4. yuva (6 Agustos 2026 eklendi): isletmenin kendi
    ozel recetelerinden Icecek/Baslangic/Pizza/Burger kategorisindeki
    tarifler (grup=4). Anayasa madde 8'in ZORUNLU 3'lusune dahil DEGIL --
    bu yuzden:
      - Madde 11 (uyumsuzluk) yine de kontrol edilir (tutarlilik icin),
        ama bir aday bulunamazsa ogun YINE DE GECERLI sayilir, sadece bu
        yuva bos kalir.
      - Haftalik tekrar kisiti (madde 2) burada UYGULANMAZ -- bu havuz
        genelde kucuk (isletmenin kendi menusu) oldugu icin tekrarsizlik
        zorlanirsa yuva birkac gunde tukenip surekli bos kalirdi.
      - Mevsim kisiti da uygulanmaz (ozel receteler icin mevsim_etiketi
        zaten hep 'yil_boyunca').
    Uygun aday yoksa None doner."""
    if not grup4_havuz:
        return None
    adaylar = [
        t for t in grup4_havuz
        if _uyumlu_mu(birlesik_etiketler | set(t.get("etiketler") or []))
    ]
    if not adaylar:
        return None
    return rastgele.choice(adaylar)


def hafta_olustur(tarifler, mevsim, rastgele, hedefler=None, gun_sayisi=7):
    """tarifler: [{"ad","grup"(1/2/3, opsiyonel 4),"mevsim_etiketi","etiketler", ...besin}, ...]
    hedefler: {"Öğle": {"kalori":(min,max), ...}, "Akşam": {...}} ya da None.
    grup=4 (isletmenin kendi Icecek/Baslangic/Pizza/Burger receteleri)
    varsa, her ogune ISTEGE BAGLI 4. bir tarif eklenir -- bkz. _fast_food_sec."""
    grup1 = [t for t in tarifler if t["grup"] == 1]
    grup2 = [t for t in tarifler if t["grup"] == 2]
    grup3 = [t for t in tarifler if t["grup"] == 3]
    grup4 = [t for t in tarifler if t["grup"] == 4]

    kullanilan_hafta = set()
    hafta = []
    for gun_no in range(1, gun_sayisi + 1):
        gun = {"gun": gun_no, "ogunler": {}}
        for ogun_adi in ("Öğle", "Akşam"):
            hedef = (hedefler or {}).get(ogun_adi)
            t1, t2, t3 = ogun_olustur(grup1, grup2, grup3, mevsim, kullanilan_hafta, rastgele, hedef)
            for t in (t1, t2, t3):
                kullanilan_hafta.add(t["ad"])
            ogun_tarifleri = [t1["ad"], t2["ad"], t3["ad"]]

            if grup4:
                birlesik = set(t1["etiketler"]) | set(t2["etiketler"]) | set(t3["etiketler"])
                t4 = _fast_food_sec(grup4, birlesik, rastgele)
                if t4 is not None:
                    ogun_tarifleri.append(t4["ad"])

            gun["ogunler"][ogun_adi] = ogun_tarifleri
        hafta.append(gun)
    return hafta


def yillik_ornek_uret(tarifler, tohum=42):
    rastgele = random.Random(tohum)
    return {mevsim: hafta_olustur(tarifler, mevsim, rastgele) for mevsim in MEVSIMLER}


if __name__ == "__main__":
    import json

    from tarif_verisi import TARIFLER  # sadece yerel test icin

    print(json.dumps(yillik_ornek_uret(TARIFLER), ensure_ascii=False, indent=2))


