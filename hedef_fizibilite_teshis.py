# hedef_fizibilite_teshis.py
#
# AMAC: Aralik ayinda "32 besin ogesi AYNI ANDA hedefte" sartinin
# GERCEKTEN mumkun mu, yoksa MEVCUT tarif havuzuyla matematiksel olarak
# (neredeyse) imkansiz mi oldugunu KANITLAMAK. Uretim algoritmasini
# degistirmeden ONCE bu sorunun cevabini bilmemiz lazim -- degilse,
# algoritma ne kadar iyilestirilirse iyilestirilsin sonuc degismez.
#
# YONTEM: TEK bir ogun icin (varsayilan: kis mevsimi, Ogle), mevsim +
# uyumsuzluk (madde 11) + ayni-ogunde-taban-tekrari kurallarina uyan
# TUM (grup1 x grup2 x grup3) ucluleri TAM (exhaustive) tarar --
# gercek uretim algoritmasindaki gibi bir deneme sayisi SINIRI YOK.
# Hafta ici tekrar / gunler-arasi kisitlar burada YOK -- yani bu, "en
# iyimser tek ogunluk senaryo". Bu en iyimser senaryoda bile tam
# eslesme yoksa, gercek aylik uretimde hic bulunmamasi hic sasirtici
# degildir -- ve hicbir arama algoritmasi bunu degistiremez.
#
# _hedefte_mi/_besin_hedefte_mi ile AYNI mantik kullanilir: bir tarifte
# o besin ogesi icin veri yoksa (None) o oge o ucluye ozel olarak
# kontrol DISI birakilir (0 sayilmaz) -- bkz. ON DOKUZUNCU DUZELTME.
#
# CALISTIRMA:
#   1) Bu dosyayi proje kok dizinine koy (besin_sabitleri.py ve
#      uretim_algoritmasi.py'nin yaninda).
#   2) SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY ortam degiskenlerinin
#      tanimli oldugundan emin ol (ikon_siniflandirma_calistir.py icin
#      zaten "setx" ile kaydetmistin -- ayni terminal/oturumdaysa hazir).
#   3) Once MUTFAK_KODU = None ile bir kez calistir -- mevcut mutfak
#      kodlarini listeler.
#   4) MUTFAK_KODU'nu doldur, HEDEF'i (varsayilan araliklari
#      kullanmiyorsan) kendi degerlerinle guncelle, tekrar calistir:
#         python hedef_fizibilite_teshis.py
#
# SURE: Havuz buyuklugune gore degisir -- birkac saniyeden birkac
# dakikaya kadar surebilir, ilerleme t1 bazinda ekrana yazilir.

import os
import time

from supabase import create_client
from besin_sabitleri import TUM_BESIN_ALANLARI, BESIN_ARALIK
from uretim_algoritmasi import ogun_besin_toplami, _taban_kelime, _uyumlu_mu, _besin_mesafesi

# YETMIS BIRINCI DUZELTME'deki ikon_siniflandirma_calistir.py ile AYNI
# neden: bu script db.py/oturumu_uygula() (Streamlit oturum) UZERINDEN
# GECMIYOR, yani "anon" rolunde baglanir -- ve anon rolunden
# auth_isletme_id() EXECUTE yetkisi kaldirilmis durumda (93-101
# numarali migration'lar). Bu yuzden SERVICE_ROLE anahtariyla, RLS'i
# atlayarak baglaniyoruz (SADECE bu tur tek seferlik/lokal teshis
# scriptleri icin uygun -- ASLA istemci tarafinda/uretimde kullanma).
supabase_url = os.environ.get("SUPABASE_URL")
supabase_service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
if not supabase_url or not supabase_service_key:
    print("HATA: SUPABASE_URL ve/veya SUPABASE_SERVICE_ROLE_KEY bulunamadi.")
    print("Bunlari ikon_siniflandirma_calistir.py icin zaten 'setx' ile")
    print("kaydetmistin -- ayni terminalde calistiriyorsan zaten mevcut")
    print("olmalilar. Degilse: Supabase projenin Settings -> API")
    print("sayfasindan 'Project URL' ve 'service_role' anahtarini al.")
    raise SystemExit(1)

supabase = create_client(supabase_url, supabase_service_key)

# ---- AYARLANMASI GEREKENLER ----
MUTFAK_KODU = None   # None birakirsan mevcut mutfaklar listelenir.
OGUN_ADI_ETIKETI = "Öğle (Aralık / kış varsayımıyla)"
MEVSIM = "kis"        # Aralik = kis

# Aralik'ta VARSAYILAN aralik degerlerini degil, KENDI girdigin ozel
# sayilari kullandiysan HEDEF'i ELLE doldur -- aksi halde script
# besin_sabitleri.py'deki varsayilan (def_alt/def_ust) araliklari
# kullanir (bu, "boş hedef profili + tüm ögeler" secimiyle AYNI
# olmali, cunku o durumda number_input'lar varsayilan degerle dolar).
HEDEF = None
# Ornek ozel hedef (sadece birkac oge icin):
# HEDEF = {"kalori": (900.0, 1200.0), "protein": (20.0, 60.0)}

if HEDEF is None:
    HEDEF = {anahtar: (def_alt, def_ust) for anahtar, (minv, maxv, def_alt, def_ust) in BESIN_ARALIK.items()}

_GENISLETILMIS_KOLONLAR = [a for a, *_ in TUM_BESIN_ALANLARI if a not in ("kalori", "protein", "yag", "karbonhidrat", "gi")]

print(f"Kontrol edilen besin ogesi sayisi: {len(HEDEF)}")
print(f"({OGUN_ADI_ETIKETI})\n")


# ---- MUTFAK SECIMI ----
if MUTFAK_KODU is None:
    mutfaklar = supabase.table("mutfaklar").select("kod, ad").execute().data
    print("MUTFAK_KODU belirtilmedi. Mevcut mutfaklar:")
    for m in mutfaklar:
        print(f"  kod={m['kod']!r}  ad={m['ad']}")
    print("\nYukaridaki kod degerlerinden birini MUTFAK_KODU degiskenine yazip tekrar calistir.")
    raise SystemExit(0)


# ---- TARIF KUTUPHANESI (0_Yillik_Menu.py:_tarif_kutuphanesini_getir ile AYNI mantik) ----
def tarif_kutuphanesini_getir(mutfak_kodu):
    mutfak = supabase.table("mutfaklar").select("id").eq("kod", mutfak_kodu).single().execute().data
    kategoriler = (
        supabase.table("mutfak_kategorileri")
        .select("id, sira")
        .eq("mutfak_id", mutfak["id"])
        .execute()
    ).data
    grup_by_kategori = {k["id"]: k["sira"] for k in kategoriler}
    receteler = (
        supabase.table("receteler")
        .select("id, ad, mutfak_kategori_id, ozel_etiketler, mevsim_etiketi")
        .is_("isletme_id", "null")
        .execute()
    ).data
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


# ---- BESIN DETAYI (0_Yillik_Menu.py:_tarif_detaylarini_getir ile AYNI hesaplama,
#      fiyat/alerjen kismi CIKARILDI -- bu script icin gereksiz) ----
def besin_detaylarini_getir():
    receteler = supabase.table("receteler").select("id, ad").is_("isletme_id", "null").execute().data
    id_to_ad = {r["id"]: r["ad"] for r in receteler}
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
        gi = (v["gi_agirlikli"] / v["gi_karb_toplam"]) if v["gi_karb_toplam"] > 0 else None
        sonuc[ad] = {
            "kalori": v["kalori"], "protein": v["protein"], "yag": v["yag"],
            "karbonhidrat": v["karbonhidrat"], "gi": gi,
            **{k: (v[k] if v[f"{k}_var_mi"] else None) for k in _GENISLETILMIS_KOLONLAR},
        }
    return sonuc


def basarisiz_ogeler(besin, hedef):
    """_hedefte_mi / _besin_hedefte_mi ile AYNI mantik: None -> atla (kontrol disi)."""
    sonuc = []
    for anahtar, (alt, ust) in hedef.items():
        deger = besin.get(anahtar)
        if deger is None:
            continue
        if not (alt <= deger <= ust):
            sonuc.append(anahtar)
    return sonuc


# ---- VERIYI CEK VE ZENGINLESTIR ----
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

havuz = [t for t in zengin if t["mevsim_etiketi"] in (MEVSIM, "yil_boyunca")]
g1 = [t for t in havuz if t["grup"] == 1]
g2 = [t for t in havuz if t["grup"] == 2]
g3 = [t for t in havuz if t["grup"] == 3]

print(f"Havuz buyuklugu (mevsim={MEVSIM} + yil_boyunca): grup1={len(g1)}, grup2={len(g2)}, grup3={len(g3)}")
print(f"Filtresiz ust sinir (grup1 x grup2 x grup3): {len(g1) * len(g2) * len(g3):,}\n")

if not (g1 and g2 and g3):
    print("HATA: bir veya daha fazla grup bos -- MUTFAK_KODU/MEVSIM dogru mu kontrol et.")
    raise SystemExit(1)


# ---- TAM TARAMA ----
basarisizlik_sayaci = {k: 0 for k in HEDEF}
degerlendirilen = 0
tam_eslesenler = []
en_iyi_mesafe = None
en_iyi_uclu = None
en_iyi_basarisiz = None

baslangic = time.time()
for i, t1 in enumerate(g1, 1):
    t1_taban = _taban_kelime(t1["ad"])
    for t2 in g2:
        t2_taban = _taban_kelime(t2["ad"])
        if t2_taban == t1_taban:
            continue
        birlesik_12 = set(t1["etiketler"]) | set(t2["etiketler"])
        for t3 in g3:
            t3_taban = _taban_kelime(t3["ad"])
            if t3_taban in (t1_taban, t2_taban):
                continue
            if not _uyumlu_mu(birlesik_12 | set(t3["etiketler"])):
                continue

            degerlendirilen += 1
            besin = ogun_besin_toplami(t1, t2, t3)
            basarisiz = basarisiz_ogeler(besin, HEDEF)

            if not basarisiz:
                if len(tam_eslesenler) < 5:
                    tam_eslesenler.append((t1["ad"], t2["ad"], t3["ad"]))
            else:
                for k in basarisiz:
                    basarisizlik_sayaci[k] += 1

            mesafe = _besin_mesafesi(besin, HEDEF)
            if en_iyi_mesafe is None or mesafe < en_iyi_mesafe:
                en_iyi_mesafe = mesafe
                en_iyi_uclu = (t1["ad"], t2["ad"], t3["ad"])
                en_iyi_basarisiz = basarisiz

    print(f"  [{i}/{len(g1)}] t1={t1['ad']!r} tamamlandi -- su ana kadar degerlendirilen uyumlu uclu: {degerlendirilen:,}, gecen sure: {time.time() - baslangic:.1f}s")

print(f"\n{'=' * 60}")
print(f"TOPLAM degerlendirilen (uyumlu) uclu: {degerlendirilen:,}")
print(f"TAM eslesen (TUM {len(HEDEF)} oge hedefte) uclu sayisi: {len(tam_eslesenler)}{' (ilk 5 gosteriliyor)' if len(tam_eslesenler) == 5 else ''}")

if tam_eslesenler:
    print("\nOrnek tam eslesenler:")
    for e in tam_eslesenler:
        print(f"  {e}")
    print("\nSONUC: Havuzda tam eslesme VAR ama nadir -- bu bir ARAMA/KAPSAMA")
    print("sorunu, algoritmayi (arama butcesi/stratejisi) iyilestirmek anlamli.")
else:
    print(f"\nEn yakin (hedefe en yakin) uclu:\n  {en_iyi_uclu}")
    print(f"Bu uclude basarisiz olan {len(en_iyi_basarisiz)}/{len(HEDEF)} oge: {en_iyi_basarisiz}")
    print("\nSONUC: Bu en iyimser (hafta/gun kisitlari olmadan tek ogunluk)")
    print("senaryoda bile TAM eslesme YOK -- yani mevcut tarif havuzuyla 32")
    print("ogeyi ayni anda tutturmak MATEMATIKSEL OLARAK IMKANSIZ (ya da ona")
    print("çok yakin). Algoritma degisikligi bunu COZEMEZ.")

print(f"\n{'=' * 60}")
print("En sik basarisiz olan besin ogeleri (degerlendirilen TUM ucrlularda\nkac kez araligin disinda kaldi -- yuksek oran = 'kronik engelleyici'):")
for k, sayi in sorted(basarisizlik_sayaci.items(), key=lambda x: -x[1]):
    if degerlendirilen:
        oran = 100 * sayi / degerlendirilen
        if sayi > 0:
            print(f"  {k}: {sayi:,} / {degerlendirilen:,}  (%{oran:.1f})")
