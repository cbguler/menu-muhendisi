# besin_kalibrasyon.py
#
# AMAC: besin_sabitleri.py'deki def_alt/def_ust varsayilan hedef
# araliklari OTUZ IKINCI DUZELTME'de (13 Agustos 2026) "3 x TEK TARIFIN
# medyani" formuluyle hesaplanmisti -- bu, GERCEK 3'lu OGUN
# kombinasyonlarinin dagilimini yansitmiyormus: hedef_fizibilite_teshis.py
# ile yapilan test, ornegin kalorinin GERCEK ucrlularin sadece %8.9'unda
# (900-1200 araliginda) kaldigini gosterdi -- yani varsayilan aralik cok
# DAR ve/veya YANLIS merkezde.
#
# BU SCRIPT: her mevsim icin GERCEK (t1,t2,t3) uclulerinden BUYUK
# RASTGELE bir ornek (varsayilan 100.000/mevsim) ceker -- tam/exhaustive
# degil, sadece dagilimi/percentile'lari OLCMEK icin yeterli buyuklukte
# bir ornek. Her 32 besin ogesi icin p5/p10/p25/p50(medyan)/p75/p90/p95
# yuzdelik dilimlerini raporlar -- hem mevsim BAZINDA hem TUM MEVSIMLER
# BIRLESIK (uygulamanin tek, mevsimden bagimsiz varsayilan araligi
# icin). Sonunda besin_sabitleri.py'ye YAPISTIRILMAYA HAZIR, p10/p90
# tabanli ONERI satirlari yazdirir (nihai karari Bahri ile birlikte
# verecegiz -- bu SADECE veri, otomatik uygulanmiyor).
#
# CALISTIRMA:
#   python besin_kalibrasyon.py

import os
import random
import time
from statistics import median

from supabase import create_client
from besin_sabitleri import TUM_BESIN_ALANLARI
from uretim_algoritmasi import ogun_besin_toplami, _taban_kelime, _uyumlu_mu, MEVSIMLER

ORNEK_BUYUKLUGU_MEVSIM_BASINA = 100_000
YUZDELIKLER = (5, 10, 25, 50, 75, 90, 95)

_GENISLETILMIS_KOLONLAR = [a for a, *_ in TUM_BESIN_ALANLARI if a not in ("kalori", "protein", "yag", "karbonhidrat", "gi")]
_TUM_ANAHTARLAR = [a for a, *_ in TUM_BESIN_ALANLARI]

supabase_url = os.environ.get("SUPABASE_URL")
supabase_service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
if not supabase_url or not supabase_service_key:
    print("HATA: SUPABASE_URL ve/veya SUPABASE_SERVICE_ROLE_KEY bulunamadi.")
    raise SystemExit(1)

supabase = create_client(supabase_url, supabase_service_key)

MUTFAK_KODU = "turk"  # hedef_fizibilite_teshis.py'deki gibi -- farkliysa degistir.


def tarif_kutuphanesini_getir(mutfak_kodu):
    mutfak = supabase.table("mutfaklar").select("id").eq("kod", mutfak_kodu).single().execute().data
    kategoriler = supabase.table("mutfak_kategorileri").select("id, sira").eq("mutfak_id", mutfak["id"]).execute().data
    grup_by_kategori = {k["id"]: k["sira"] for k in kategoriler}
    receteler = supabase.table("receteler").select("id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi").is_("isletme_id", "null").execute().data
    tarifler = []
    for r in receteler:
        grup = grup_by_kategori.get(r["mutfak_kategori_id"])
        if grup is None:
            continue
        tarifler.append({
            "ad": r["ad"], "grup": grup,
            "mevsim_etiketi": r["mevsim_etiketi"] or "yil_boyunca",
            "etiketler": r["ozel_etiketler"] or [],
        })
    return tarifler


def sayfalayarak_getir(sorgu_fn, sayfa_boyu=1000):
    tumu = []
    offset = 0
    while True:
        sonuc = sorgu_fn().range(offset, offset + sayfa_boyu - 1).execute().data
        if not sonuc:
            break
        tumu.extend(sonuc)
        if len(sonuc) < sayfa_boyu:
            break
        offset += sayfa_boyu
    return tumu


def besin_detaylarini_getir():
    receteler = supabase.table("receteler").select("id, ad, porsiyon_sayisi").is_("isletme_id", "null").execute().data
    id_to_ad = {r["id"]: r["ad"] for r in receteler}
    porsiyon_by_id = {r["id"]: (r["porsiyon_sayisi"] or 1) for r in receteler}
    malzeme_kalemleri = sayfalayarak_getir(
        lambda: supabase.table("recete_malzemeleri").select(
            "recete_id, malzeme_id, miktar_gram, "
            "malzemeler(kalori, protein, yag, karbonhidrat, glisemik_indeks, "
            + ", ".join(_GENISLETILMIS_KOLONLAR) + ")"
        )
    )
    ham = {}
    for kalem in malzeme_kalemleri:
        ad = id_to_ad.get(kalem["recete_id"])
        if ad is None:
            continue
        m = kalem.get("malzemeler") or {}
        oran = kalem["miktar_gram"] / 100.0
        girdi = ham.setdefault(ad, {
            "recete_id": kalem["recete_id"],
            "kalori": 0.0, "protein": 0.0, "yag": 0.0, "karbonhidrat": 0.0,
            "gi_agirlikli": 0.0, "gi_karb_toplam": 0.0,
            **{k: 0.0 for k in _GENISLETILMIS_KOLONLAR},
            **{f"{k}_var_mi": False for k in _GENISLETILMIS_KOLONLAR},
        })
        girdi["kalori"] += (m.get("kalori") or 0) * oran
        girdi["protein"] += (m.get("protein") or 0) * oran
        girdi["yag"] += (m.get("yag") or 0) * oran
        karb = (m.get("karbonhidrat") or 0) * oran
        girdi["karbonhidrat"] += karb
        gi = m.get("glisemik_indeks")
        if gi is not None and karb > 0:
            girdi["gi_agirlikli"] += gi * karb
            girdi["gi_karb_toplam"] += karb
        for kolon in _GENISLETILMIS_KOLONLAR:
            deger = m.get(kolon)
            if deger is not None:
                girdi[kolon] += deger * oran
                girdi[f"{kolon}_var_mi"] = True
    sonuc = {}
    for ad, v in ham.items():
        # KRITIK DUZELTME: tarifler PARTI (batch) toplami olarak
        # saklaniyor -- 0_Yillik_Menu.py:_tarif_detaylarini_getir ile
        # AYNI sekilde porsiyon_sayisi'na BOLUNMEDEN kullanmak, tum
        # besin degerlerini porsiyon sayisi kadar (tipik olarak birkac
        # kat) SISIRIR. Bu satir, YUZ YIRMI YEDINCI DUZELTME (9 Eylul
        # 2026) ile eklendi -- eklenmeden once hedef_fizibilite_teshis.py
        # VE besin_kalibrasyon.py bu bolmeyi ATLIYORDU, tum olcumler
        # (1/103.740 nadirlik bulgusu DAHIL) guvenilmezdi.
        porsiyon = porsiyon_by_id.get(v["recete_id"], 1)
        gi = (v["gi_agirlikli"] / v["gi_karb_toplam"]) if v["gi_karb_toplam"] > 0 else None
        sonuc[ad] = {
            "kalori": v["kalori"] / porsiyon, "protein": v["protein"] / porsiyon,
            "yag": v["yag"] / porsiyon, "karbonhidrat": v["karbonhidrat"] / porsiyon, "gi": gi,
            **{k: (v[k] / porsiyon if v[f"{k}_var_mi"] else None) for k in _GENISLETILMIS_KOLONLAR},
        }
    return sonuc


def yuzdelik(sirali_liste, y):
    if not sirali_liste:
        return None
    n = len(sirali_liste)
    idx = max(0, min(n - 1, round((y / 100.0) * (n - 1))))
    return sirali_liste[idx]


print("Tarif kutuphanesi ve besin detaylari cekiliyor (biraz surebilir)...")
tarifler = tarif_kutuphanesini_getir(MUTFAK_KODU)
detay = besin_detaylarini_getir()

zengin = []
for t in tarifler:
    b = detay.get(t["ad"], {})
    t2 = dict(t)
    t2["kalori"] = b.get("kalori")
    t2["protein"] = b.get("protein")
    t2["yag"] = b.get("yag")
    t2["karbonhidrat"] = b.get("karbonhidrat")
    t2["gi"] = b.get("gi")
    for kolon in _GENISLETILMIS_KOLONLAR:
        t2[kolon] = b.get(kolon)
    zengin.append(t2)

rastgele = random.Random(42)


def rastgele_gecerli_uclu(havuz1, havuz2, havuz3, max_deneme=200):
    for _ in range(max_deneme):
        t1 = rastgele.choice(havuz1)
        t2 = rastgele.choice(havuz2)
        t3 = rastgele.choice(havuz3)
        t1_taban, t2_taban, t3_taban = _taban_kelime(t1["ad"]), _taban_kelime(t2["ad"]), _taban_kelime(t3["ad"])
        if len({t1_taban, t2_taban, t3_taban}) < 3:
            continue
        etiketler = set(t1["etiketler"]) | set(t2["etiketler"]) | set(t3["etiketler"])
        if not _uyumlu_mu(etiketler):
            continue
        return (t1, t2, t3)
    return None


tum_mevsimler_degerleri = {k: [] for k in _TUM_ANAHTARLAR}
mevsim_degerleri = {}

for mevsim in MEVSIMLER:
    havuz = [t for t in zengin if t["mevsim_etiketi"] in (mevsim, "yil_boyunca")]
    g1 = [t for t in havuz if t["grup"] == 1]
    g2 = [t for t in havuz if t["grup"] == 2]
    g3 = [t for t in havuz if t["grup"] == 3]
    print(f"\n{mevsim}: havuz grup1={len(g1)}, grup2={len(g2)}, grup3={len(g3)} -- {ORNEK_BUYUKLUGU_MEVSIM_BASINA:,} rastgele ornek cekiliyor...")

    degerler = {k: [] for k in _TUM_ANAHTARLAR}
    baslangic = time.time()
    toplanan = 0
    while toplanan < ORNEK_BUYUKLUGU_MEVSIM_BASINA:
        uclu = rastgele_gecerli_uclu(g1, g2, g3)
        if uclu is None:
            continue
        besin = ogun_besin_toplami(*uclu)
        for k in _TUM_ANAHTARLAR:
            deger = besin.get(k)
            if deger is not None:
                degerler[k].append(deger)
                tum_mevsimler_degerleri[k].append(deger)
        toplanan += 1
    mevsim_degerleri[mevsim] = degerler
    print(f"  tamamlandi -- {time.time() - baslangic:.1f} sn")


def rapor_yazdir(baslik, degerler_dict):
    print(f"\n{'=' * 70}\n{baslik}\n{'=' * 70}")
    print(f"{'Oge':<20}" + "".join(f"p{y:<6}" for y in YUZDELIKLER))
    for anahtar in _TUM_ANAHTARLAR:
        liste = sorted(degerler_dict[anahtar])
        if not liste:
            print(f"{anahtar:<20} (veri yok)")
            continue
        degerler = [yuzdelik(liste, y) for y in YUZDELIKLER]
        print(f"{anahtar:<20}" + "".join(f"{d:<7.1f}" for d in degerler))


for mevsim in MEVSIMLER:
    rapor_yazdir(f"MEVSIM: {mevsim}", mevsim_degerleri[mevsim])

rapor_yazdir("TUM MEVSIMLER BIRLESIK", tum_mevsimler_degerleri)

print(f"\n{'=' * 70}")
print("besin_sabitleri.py ICIN ONERI (p10 / p90 tabanli, TUM MEVSIMLER BIRLESIK)")
print("(Bu sadece bir ONERI -- nihai karari birlikte verecegiz.)")
print(f"{'=' * 70}")
etiket_by_anahtar = {a: e for a, e, *_ in TUM_BESIN_ALANLARI}
minmax_by_anahtar = {a: (minv, maxv) for a, _, minv, maxv, *_ in TUM_BESIN_ALANLARI}
for anahtar in _TUM_ANAHTARLAR:
    liste = sorted(tum_mevsimler_degerleri[anahtar])
    if not liste:
        continue
    p10 = yuzdelik(liste, 10)
    p90 = yuzdelik(liste, 90)
    minv, maxv = minmax_by_anahtar[anahtar]
    etiket = etiket_by_anahtar[anahtar]
    print(f'    ("{anahtar}", "{etiket}", {minv}, {maxv}, {round(p10, 1)}, {round(p90, 1)}),')
