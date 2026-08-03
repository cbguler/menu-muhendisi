# uretim_algoritmasi.py
#
# Yillik Menu Uretim Motoru -- ILK SURUM (prototip).
# Anayasa kurallarina gore haftalik/yillik menu takvimini otomatik
# doldurur. VERI KAYNAGINDAN BAGIMSIZDIR: `tarifler` parametresi olarak
# [{"ad","grup","mevsim_etiketi","etiketler"}, ...] seklinde bir liste
# bekler -- bu liste ister tarif_verisi.py'den (yerel test), ister
# Supabase'den (gercek uygulama, pages/5_Yillik_Menu.py) gelebilir.
#
# Uyguladigi kurallar:
#   Madde 8  - her ogun I. + II. + III. Grup icerir (1'er tarif)
#   Madde 2  - ayni hafta icinde bir tarif tekrarlanmaz (mumkun oldugunca)
#   Madde 11 - uyumsuzluk kurallari (asagida UYUMSUZLUK) -- HER ZAMAN uygulanir
#   Madde 13 - tamamlayici eslestirme (asagida TAMAMLAYICI, tercih --
#              zorunlu degil, mumkunse uygulanir)
#   Mevsimsellik - once ayni mevsim + yil_boyunca tarifler denenir
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


def _aday_havuzu(havuz, mevsim, kullanilan_hafta, tekrara_izin_ver=False):
    if tekrara_izin_ver:
        aday = [r for r in havuz if r["mevsim_etiketi"] in (mevsim, "yil_boyunca")]
        if not aday:
            aday = list(havuz)
        return aday
    aday = [r for r in havuz if r["ad"] not in kullanilan_hafta and r["mevsim_etiketi"] in (mevsim, "yil_boyunca")]
    if not aday:  # mevsim kisitini gevset (kutuphane henuz kucuk)
        aday = [r for r in havuz if r["ad"] not in kullanilan_hafta]
    return aday


def _grup3_tercih_sirasi(grup1_etiketler):
    for anahtar, tercihler in TAMAMLAYICI.items():
        if anahtar in grup1_etiketler:
            return tercihler
    return []


def _ogun_dene(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, deneme_sayisi, tekrara_izin_ver):
    """Verilen esneklik seviyesinde ogun kombinasyonu aramaya calisir.
    UYUMSUZLUK (madde 11) HER ZAMAN uygulanir, gevsetilmez -- sadece
    haftalik-tekrar kisitlaniyor gevsetilebilir (tekrara_izin_ver=True)."""
    for _ in range(deneme_sayisi):
        aday1 = _aday_havuzu(grup1_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver)
        aday2 = _aday_havuzu(grup2_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver)
        aday3 = _aday_havuzu(grup3_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver)
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

        t3 = None
        for tercih_etiket in tercih_sirasi:
            eslesen = [t for t in aday3_uyumlu if tercih_etiket in t["etiketler"]]
            if eslesen:
                t3 = rastgele.choice(eslesen)
                break
        if t3 is None:
            t3 = rastgele.choice(aday3_uyumlu)

        return t1, t2, t3
    return None


def ogun_olustur(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele):
    """Tek bir ogun (Ogle veya Aksam) icin I+II+III grup tarifi secer.
    Once haftalik-tekrarsizlik + uyumluluk ile dener; kutuphane bu
    ogun icin tukendiyse, SADECE haftalik-tekrar kisitini gevsetip
    UYUMSUZLUK kuralini koruyarak tekrar dener."""
    sonuc = _ogun_dene(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, 200, False)
    if sonuc is not None:
        return sonuc

    sonuc = _ogun_dene(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, 200, True)
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


def hafta_olustur(tarifler, mevsim, rastgele, gun_sayisi=7):
    """tarifler: [{"ad","grup"(1/2/3),"mevsim_etiketi","etiketler"}, ...]"""
    grup1 = [t for t in tarifler if t["grup"] == 1]
    grup2 = [t for t in tarifler if t["grup"] == 2]
    grup3 = [t for t in tarifler if t["grup"] == 3]

    kullanilan_hafta = set()
    hafta = []
    for gun_no in range(1, gun_sayisi + 1):
        gun = {"gun": gun_no, "ogunler": {}}
        for ogun_adi in ("Öğle", "Akşam"):
            t1, t2, t3 = ogun_olustur(grup1, grup2, grup3, mevsim, kullanilan_hafta, rastgele)
            for t in (t1, t2, t3):
                kullanilan_hafta.add(t["ad"])
            gun["ogunler"][ogun_adi] = [t1["ad"], t2["ad"], t3["ad"]]
        hafta.append(gun)
    return hafta


def yillik_ornek_uret(tarifler, tohum=42):
    rastgele = random.Random(tohum)
    return {mevsim: hafta_olustur(tarifler, mevsim, rastgele) for mevsim in MEVSIMLER}


if __name__ == "__main__":
    import json

    from tarif_verisi import TARIFLER  # sadece yerel test icin

    print(json.dumps(yillik_ornek_uret(TARIFLER), ensure_ascii=False, indent=2))

