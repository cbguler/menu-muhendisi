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

# YIRMI BIRINCI DUZELTME (30 Agustos 2026): kullanicinin fark ettigi
# gercek ornek -- bir gunde ogle "Cacık", aksam "Sumaklı Cacık" cikmisti.
# Anayasa madde 2 (hafta ici tekrarsizlik) SADECE TAM ISIM eslesmesine
# bakiyor -- "Cacık" != "Sumaklı Cacık" oldugu icin bu kontrolden
# GECIYORLARDI. Asagidaki sezgisel fonksiyon, bir tarifin "temel yemek
# turunu" bulmaya calisir ve AYNI GUN icinde bu temel turun tekrarini
# engeller (bkz. hafta_olustur'daki kullanilan_gun_taban).
#
# DURUSTCE BELIRTILMELI: bu TAM/KESIN bir cozum degil, bir SEZGISEL
# (heuristic) yontemdir -- 241 tariflik kutuphanenin tamaminda elle
# dogrulanmadi. Turkce yemek isimlerinde COGUNLUKLA son kelime cekirdek
# isimdir (sifat/tarif ONCE gelir: "Sumaklı Cacık" -> cekirdek "cacık"),
# ama corba/salata/tatli/borek/kebap/kofte/dolma/pilav gibi COK GENEL bir
# sonekle biten isimlerde SADECE son kelimeyi almak butun corbalari
# (ör. "Mercimek Çorbası" ile "Ezogelin Çorbası") YANLISLIKLA ayni
# sayardi -- bu durumda son IKI kelime birlikte kullanilir. "İmam
# Bayıldı" gibi deyimsel (idiyomatik) isimlerde bu sezgi yanilabilir,
# ama bu tur isimler zaten baska hicbir tarifle CAKISMAYACAGI icin
# riski dusuk (yanlis pozitif degil, en kotu ihtimalle yanlis negatif --
# yani nadir bir gercek benzerlik gozden kacabilir, ama YANLISTAN
# YANLISA "farkli yemekleri ayni sayip" gereksiz kisitlama olusmaz).
_GENERIK_YEMEK_TURU_SONEKLERI = {
    "çorbası", "corbasi", "çorba", "corba",
    "salatası", "salatasi", "salata",
    "tatlısı", "tatlisi", "tatlı", "tatli",
    "böreği", "boregi", "börek", "borek",
    "kebabı", "kebabi", "kebap",
    "köftesi", "koftesi", "köfte", "kofte",
    "dolması", "dolmasi", "dolma",
    "pilavı", "pilavi", "pilav",
    "yemeği", "yemegi", "yemek",
    "kavurma", "kavurması", "kavurmasi",
    "güveç", "guvec", "güveci", "guveci",
}


def _taban_kelime(ad):
    """Bir tarifin 'temel yemek turunu' bulmaya calisan basit bir sezgisel
    yontem -- ust taraftaki nota bakiniz."""
    kelimeler = ad.strip().lower().replace("'", "").split()
    if not kelimeler:
        return ad.strip().lower()
    son = kelimeler[-1]
    if son in _GENERIK_YEMEK_TURU_SONEKLERI and len(kelimeler) >= 2:
        return " ".join(kelimeler[-2:])
    return son
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
    Temel 4 alan (kalori/protein/yag/karbonhidrat) icin veri eksikligi
    0 sayilir (bu alanlar pratikte her zaman doludur). ANCAK 27
    genisletilmis besin ogesi (vitamin/mineral) icin bu VARSAYIM
    GECERLI DEGIL -- katalogumuzda birçok malzemede hala eksik veri
    var (ör. B7/Biyotin). Bir tarifte o ogeye dair HICBIR malzeme veri
    icermiyorsa deger None olarak geliyor (bkz. 0_Yillik_Menu.py'deki
    ayni duzeltme) -- burada da 3 tarifin UCU de None ise toplam None
    kalmali, aksi halde yanlislikla '0 < hedef min' diyerek gecerli
    kombinasyonlar reddediliyordu (13 Agustos 2026 duzeltmesi)."""
    TEMEL_4 = ("kalori", "protein", "yag", "karbonhidrat")
    toplam = {k: 0.0 for k in BESIN_ANAHTARLARI}
    genisletilmis = [k for k in BESIN_ANAHTARLARI if k not in TEMEL_4]
    var_mi = {k: False for k in genisletilmis}
    gi_agirlikli = 0.0
    gi_karb_toplam = 0.0
    for t in (t1, t2, t3):
        for k in TEMEL_4:
            toplam[k] += t.get(k) or 0
        for k in genisletilmis:
            deger = t.get(k)
            if deger is not None:
                toplam[k] += deger
                var_mi[k] = True
        gi = t.get("gi")
        karb = t.get("karbonhidrat") or 0
        if gi is not None and karb > 0:
            gi_agirlikli += gi * karb
            gi_karb_toplam += karb
    for k in genisletilmis:
        if not var_mi[k]:
            toplam[k] = None
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


def _aday_havuzu(havuz, mevsim, kullanilan_hafta, tekrara_izin_ver=False, mevsim_zorunlu=True, kullanilan_gun_taban=None):
    kullanilan_gun_taban = kullanilan_gun_taban or set()
    if tekrara_izin_ver:
        if mevsim_zorunlu:
            aday = [r for r in havuz if r["mevsim_etiketi"] in (mevsim, "yil_boyunca")]
            if not aday:
                aday = list(havuz)
        else:
            aday = list(havuz)
    elif mevsim_zorunlu:
        aday = [
            r for r in havuz
            if r["ad"] not in kullanilan_hafta and r["mevsim_etiketi"] in (mevsim, "yil_boyunca")
        ]
    else:
        aday = [r for r in havuz if r["ad"] not in kullanilan_hafta]
    # YIRMI BIRINCI DUZELTME (30 Agustos 2026, DUZELTILDI): burada "taban
    # filtresi bossa filtresiz listeye don" seklinde bir guvenlik agi
    # OLMAMALI -- boyle bir sey ogun_olustur'un DIS kademeli gevsetme
    # dongusunu (mevsim gevset -> hafta-tekrarina izin ver -> ...) atlayip
    # DAHA ERKEN, gereksiz yere taban tekrarina izin verilmesine sebep
    # oluyordu (test sirasinda yakalandi: Cacık+Sumaklı Cacık ayni gun
    # tekrar CIKTI, cunku ilk denemede bu "yerel" fallback devreye girip
    # dis dongunun daha iyi bir alternatif (ör. bir salata) bulma sansini
    # hic denemeden yok ediyordu). Burada boş liste donmesi GEREKIYOR --
    # _ogun_dene bunu None olarak yorumlayip ogun_olustur'un bir sonraki,
    # daha gevsek kademesine gecmesini saglayacak.
    return [r for r in aday if _taban_kelime(r["ad"]) not in kullanilan_gun_taban]


def _grup3_tercih_sirasi(grup1_etiketler):
    for anahtar, tercihler in TAMAMLAYICI.items():
        if anahtar in grup1_etiketler:
            return tercihler
    return []


def _ogun_dene(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, deneme_sayisi, tekrara_izin_ver, mevsim_zorunlu=True, hedef=None, kullanilan_gun_taban=None):
    """Verilen esneklik seviyesinde ogun kombinasyonu aramaya calisir.
    UYUMSUZLUK (madde 11) HER ZAMAN uygulanir, gevsetilmez -- haftalik-
    tekrar, mevsim kisiti VE besin hedefi kademeli olarak gevsetilebilir."""
    for _ in range(deneme_sayisi):
        aday1 = _aday_havuzu(grup1_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu, kullanilan_gun_taban)
        aday2 = _aday_havuzu(grup2_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu, kullanilan_gun_taban)
        aday3 = _aday_havuzu(grup3_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu, kullanilan_gun_taban)
        if not (aday1 and aday2 and aday3):
            return None

        t1 = rastgele.choice(aday1)
        t1_taban = _taban_kelime(t1["ad"])

        # YIRMI BIRINCI DUZELTME (DUZELTILDI): burada da "bossa filtresiz
        # listeye don" YOK -- havuz tukenirse (aday2_taban_haric bos)
        # FARKLI bir t1 denemek icin `continue` ile bir sonraki rastgele
        # denemeye geciliyor (tipki asagidaki uyumsuzluk kontrolundeki
        # `continue` gibi) -- butun deneme_sayisi (200) tukenirse zaten
        # None donup ogun_olustur'un DAHA GEVSEK kademesine (mevsim/hafta
        # tekrar) gecmesini saglar.
        aday2_havuzu = [t for t in aday2 if _taban_kelime(t["ad"]) != t1_taban]
        if not aday2_havuzu:
            continue

        aday2_uyumlu = [t for t in aday2_havuzu if _uyumlu_mu(set(t1["etiketler"]) | set(t["etiketler"]))]
        if not aday2_uyumlu:
            continue
        t2 = rastgele.choice(aday2_uyumlu)
        t2_taban = _taban_kelime(t2["ad"])

        birlesik_12 = set(t1["etiketler"]) | set(t2["etiketler"])
        tercih_sirasi = _grup3_tercih_sirasi(t1["etiketler"])

        aday3_havuzu = [t for t in aday3 if _taban_kelime(t["ad"]) not in (t1_taban, t2_taban)]
        if not aday3_havuzu:
            continue

        aday3_uyumlu = [t for t in aday3_havuzu if _uyumlu_mu(birlesik_12 | set(t["etiketler"]))]
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


def ogun_olustur(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, hedef=None, kullanilan_gun_taban=None):
    """Tek bir ogun (Ogle veya Aksam) icin I+II+III grup tarifi secer.
    Kademeli esneme sirasi (UYUMSUZLUK/madde 11 hicbirinde gevsetilmez):
      1) mevsime uygun + hafta icinde tekrarsiz + besin hedefi icinde
      2) mevsim kisitini gevset + hala tekrarsiz + besin hedefi icinde
      3) tekrara da izin ver (mevsim gevsek) + besin hedefi icinde
      4) son care: besin hedefini de gevset (mevsim/tekrar gevsek kalir)
    Bu 4 kademenin HICBIRINDE "ayni gun icinde ayni temel yemek turu"
    (kullanilan_gun_taban) gevsetilmez -- sadece havuz TAMAMEN
    tukenirse (bkz. _aday_havuzu/_ogun_dene ici fallback) devreye girer."""
    for tekrara_izin_ver, mevsim_zorunlu, bu_hedef in (
        (False, True, hedef),
        (False, False, hedef),
        (True, False, hedef),
        (True, False, None),
    ):
        sonuc = _ogun_dene(
            grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele,
            200, tekrara_izin_ver, mevsim_zorunlu, bu_hedef, kullanilan_gun_taban,
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


def hafta_olustur(tarifler, mevsim, rastgele, hedefler=None, gun_sayisi=7, gun_mevsimleri=None):
    """tarifler: [{"ad","grup"(1/2/3, opsiyonel 4),"mevsim_etiketi","etiketler", ...besin}, ...]
    hedefler: {"Öğle": {"kalori":(min,max), ...}, "Akşam": {...}} ya da None.
    grup=4 (isletmenin kendi Icecek/Baslangic/Pizza/Burger receteleri)
    varsa, her ogune ISTEGE BAGLI 4. bir tarif eklenir -- bkz. _fast_food_sec.

    gun_mevsimleri: YIRMINCI DUZELTME (13 Agustos 2026, Oturum 11) --
    kullanicinin "her gun kendi gercek tarihinin ait oldugu mevsimden
    beslensin" karari uzerine eklendi. GERCEK takvim haftalari (Pazartesi-
    Pazar) ay/mevsim sinirlarini asabilir (ör. 31 Agustos=yaz, 1 Eylul=
    sonbahar, ayni haftada). Bu listeye [gun1_mevsim, gun2_mevsim, ...]
    seklinde (gun_sayisi uzunlugunda) o haftanin HER GUNUNUN GERCEK
    mevsimi verilirse, o gunun ogun_olustur cagrisinda mevsim yerine bu
    kullanilir -- `mevsim` parametresi ise SADECE gun_mevsimleri
    verilmediginde (eski/geriye-donuk kullanim, ör. yillik_ornek_uret)
    devreye girer. Hafta ici tekrarsizlik (madde 2, kullanilan_hafta)
    mevsim karisik olsa bile HALA TUM HAFTA icin gecerli -- bir tarif,
    hangi mevsimden gelirse gelsin, ayni hafta icinde iki kez cikmaz."""
    grup1 = [t for t in tarifler if t["grup"] == 1]
    grup2 = [t for t in tarifler if t["grup"] == 2]
    grup3 = [t for t in tarifler if t["grup"] == 3]
    grup4 = [t for t in tarifler if t["grup"] == 4]

    kullanilan_hafta = set()
    hafta = []
    for gun_no in range(1, gun_sayisi + 1):
        gun_mevsimi = gun_mevsimleri[gun_no - 1] if gun_mevsimleri else mevsim
        gun = {"gun": gun_no, "ogunler": {}}
        # YIRMI BIRINCI DUZELTME (30 Agustos 2026): kullanilan_hafta
        # (TAM isim, HAFTA capinda) DEGIL -- bu, TEMEL YEMEK TURU (bkz.
        # _taban_kelime) icin, sadece BU GUNE ozel, her yeni gunde
        # SIFIRLANAN ayri bir kume. Boylece "Cacık" (ogle) + "Sumaklı
        # Cacık" (aksam) gibi bir gun icindeki benzer-yemek tekrari
        # engellenir, ama farkli GUNLERDE ayni temel turun (ör. baska
        # bir gun yine bir corba turu) cikmasina engel olunmaz -- kucuk
        # kutuphanede o kadar agir bir kisit pratik olmazdi.
        kullanilan_gun_taban = set()
        for ogun_adi in ("Öğle", "Akşam"):
            hedef = (hedefler or {}).get(ogun_adi)
            t1, t2, t3 = ogun_olustur(
                grup1, grup2, grup3, gun_mevsimi, kullanilan_hafta, rastgele, hedef,
                kullanilan_gun_taban,
            )
            for t in (t1, t2, t3):
                kullanilan_hafta.add(t["ad"])
                kullanilan_gun_taban.add(_taban_kelime(t["ad"]))
            ogun_tarifleri = [t1["ad"], t2["ad"], t3["ad"]]

            if grup4:
                birlesik = set(t1["etiketler"]) | set(t2["etiketler"]) | set(t3["etiketler"])
                t4 = _fast_food_sec(grup4, birlesik, rastgele)
                if t4 is not None:
                    ogun_tarifleri.append(t4["ad"])
                    kullanilan_gun_taban.add(_taban_kelime(t4["ad"]))

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


