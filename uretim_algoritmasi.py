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
import time

import numpy as np

# YUZ ... DUZELTME (12 Ekim 2026, Menu Muhendisi 9): 11 Ekim'deki "ogun basina
# 3 sn zaman butcesi" duzeltmesi GERI ALINDI -- aramayi rastgele bir alt
# kumeye indirdigi icin 32 hedefin hepsi seciliyken Aralik'ta 70 ogunun
# 70'i "hedef disi" cikti (Bahri: "her zaman uydugu hedefleri asiyor").
# Yeni cozum: arama yine TAM (exhaustive, 9 Eylul'deki YUZ YIRMI ALTINCI
# DUZELTME'nin istedigi gibi), ama en ic iki dongu (t2 x t3) numpy ile tek
# seferde hesaplaniyor (bkz. _ogun_dene). Kurallar, kademe sirasi, tercih
# (madde 13) mantigi ve hedef/mesafe formulleri AYNEN korundu; eski Python
# surumuyle esdegerlik testle dogrulandi (PROJE_NOTLARI, 12 Ekim).
# Tam eslesme aramasinda zaman siniri YOK. Hicbir tam eslesme yoksa "en
# yakin" arama OGUN_MESAFE_SINIRI_SN ile sinirli (bkz. ogun_olustur).
OGUN_MESAFE_SINIRI_SN = 5.0
_TEMEL_4 = ("kalori", "protein", "yag", "karbonhidrat")

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
    return _besin_hedefte_mi(besin, hedef)


def _besin_hedefte_mi(besin, hedef):
    if not hedef:
        return True
    for anahtar, (alt, ust) in hedef.items():
        deger = besin.get(anahtar)
        if deger is None:
            continue
        if not (alt <= deger <= ust):
            return False
    return True


def _hedef_mesafesi(t1, t2, t3, hedef):
    """SEKSEN YEDINCI DUZELTME (4 Eylul 2026): hedef TAM saglanmadiginda
    NE KADAR uzakta oldugunu olcer -- 0.0 ise tam hedefte demektir,
    buyudukce o kadar uzak demektir. Her anahtar icin araligin disinda
    kalinan miktar, o anahtarin ARALIK GENISLIGINE bolunerek normalize
    edilir -- boylece kalori (yuzlerce birim) gibi buyuk olcekli bir
    anahtar, gram cinsinden kucuk anahtarlari otomatik olarak golgede
    birakmaz. hedef bos/None ise her zaman 0.0 (hicbir sey aranmiyor)."""
    if not hedef:
        return 0.0
    besin = ogun_besin_toplami(t1, t2, t3)
    return _besin_mesafesi(besin, hedef)


def _besin_mesafesi(besin, hedef):
    if not hedef:
        return 0.0
    toplam_mesafe = 0.0
    for anahtar, (alt, ust) in hedef.items():
        deger = besin.get(anahtar)
        if deger is None:
            continue
        genislik = (ust - alt) or 1.0
        if deger < alt:
            toplam_mesafe += (alt - deger) / genislik
        elif deger > ust:
            toplam_mesafe += (deger - ust) / genislik
    return toplam_mesafe


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


def _etiket_maskesi(etiketler, bit_haritasi):
    m = 0
    for e in etiketler:
        bit = bit_haritasi.get(e)
        if bit is not None:
            m |= bit
    return m


def _besin_matrisi(tarifler, hedef_anahtarlari):
    """tarifler icin (deger, var_mi) matrisleri ve GI yardimci vektorleri.
    ogun_besin_toplami ile AYNI kurallar: TEMEL_4 eksikse 0; genisletilmis
    oge eksikse 'yok' (ucunde de yoksa toplam None -> kontrol atlanir)."""
    n = len(tarifler)
    deger = np.zeros((n, len(hedef_anahtarlari)), dtype=np.float64)
    var = np.ones((n, len(hedef_anahtarlari)), dtype=bool)
    gk = np.zeros(n, dtype=np.float64)
    kk = np.zeros(n, dtype=np.float64)
    for i, t in enumerate(tarifler):
        for j, k in enumerate(hedef_anahtarlari):
            if k == "gi":
                continue
            v = t.get(k)
            if k in _TEMEL_4:
                deger[i, j] = v or 0
            elif v is None:
                var[i, j] = False
            else:
                deger[i, j] = v
        gi = t.get("gi")
        karb = t.get("karbonhidrat") or 0
        if gi is not None and karb > 0:
            gk[i] = gi * karb
            kk[i] = karb
    return deger, var, gk, kk


def _ogun_dene(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, deneme_sayisi, tekrara_izin_ver, mevsim_zorunlu=True, hedef=None, kullanilan_gun_taban=None, bitis_zamani=None, mesafe_hesapla=True, sadece_mesafe=False, onceki_en_iyi=None):
    """Verilen esneklik seviyesinde ogun kombinasyonu arar.
    sadece_mesafe=True: tam eslesme ARANMAZ (cagiran, olmadigini zaten
    biliyor), sadece en yakin uclu -- ogun_olustur'un 2. asamasi, daha hizli.
    mesafe_hesapla=False: sadece TAM eslesme aranir (en yakin hesaplanmaz,
    budama cok daha erken devreye girer) -- ogun_olustur'un 1. asamasi.
    UYUMSUZLUK (madde 11) HER ZAMAN uygulanir; haftalik tekrar ve mevsim
    kisiti kademeli gevsetilir (bkz. ogun_olustur). Donus:
    (tam_sonuc, en_iyi_yakin): hedefi tam saglayan uclu (yoksa None) ve
    uyumlu ucluler icinde hedefe EN YAKIN olan.

    Tarihce: SEKSEN YEDINCI DUZELTME (4 Eylul: sistemli tarama + en yakin
    sonuc), DOKSAN DOKUZUNCU DUZELTME (haftalik-farkinda denemeler geri
    alindi), YUZ YIRMI ALTINCI DUZELTME (9 Eylul: tam/exhaustive arama).

    YUZ ... DUZELTME (12 Ekim 2026): ayni mantik numpy ile. t1 adaylari
    karistirilmis sirada tek tek dolasilir; her t1 icin BUTUN (t2, t3)
    ciftleri bir matriste ayni anda degerlendirilir:
      - t2: t1 ile ayni temel yemek turu degil + t1 ile uyumlu,
      - t3: t1/t2 ile ayni temel tur degil + uclu uyumlu,
      - madde 13 tercihi: t1'in tamamlayici etiket sirasindaki ILK etiket
        icin o satirda uygun t3 varsa SADECE o etikettekiler, yoksa tum
        uyumlu t3'ler (eski "tercih_edilenler, yoksa aday3_uyumlu").
    Hedefi saglayan ucluler arasindan secim rastgele (eski surumde
    karistirilmis siradaki ilk isabet -- ayni olasilik dagilimi).
    deneme_sayisi artik kullanilmiyor (her zaman tam arama); geriye
    donuk uyumluluk icin parametre olarak duruyor."""
    import time as _time

    aday1_ham = _aday_havuzu(grup1_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu, kullanilan_gun_taban)
    aday2_ham = _aday_havuzu(grup2_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu, kullanilan_gun_taban)
    aday3_ham = _aday_havuzu(grup3_havuz, mevsim, kullanilan_hafta, tekrara_izin_ver, mevsim_zorunlu, kullanilan_gun_taban)
    if not (aday1_ham and aday2_ham and aday3_ham):
        return None, None

    # --- Etiket bitleri: uyumsuzluk + istisna + tamamlayici etiketler ---
    ilgili = set()
    for a_, b_ in UYUMSUZLUK:
        ilgili.update((a_, b_))
    ilgili.add("sporcu_uygun")
    for tercihler in TAMAMLAYICI.values():
        ilgili.update(tercihler)
    bit = {e: 1 << i for i, e in enumerate(sorted(ilgili))}
    istisna_bit = bit["sporcu_uygun"]
    kurallar = []
    for a_, b_ in UYUMSUZLUK:
        kurallar.append((bit[a_], bit[b_], (a_ == "pilav_makarna_borek" and b_ == "tatli")))

    def _uyumsuz(m):
        """m: birlesik etiket maskesi (numpy int64 dizi) -> uyumsuz mu (bool dizi)"""
        kotu = np.zeros(m.shape, dtype=bool)
        for ba, bb, istisnali in kurallar:
            ikisi = ((m & ba) != 0) & ((m & bb) != 0)
            if istisnali:
                ikisi &= (m & istisna_bit) == 0
            kotu |= ikisi
        return kotu

    taban_id = {}

    def _tid(ad):
        tb = _taban_kelime(ad)
        if tb not in taban_id:
            taban_id[tb] = len(taban_id)
        return taban_id[tb]

    hedef = hedef or {}
    anahtarlar = list(hedef.keys())
    alt = np.array([hedef[k][0] for k in anahtarlar], dtype=np.float64)
    ust = np.array([hedef[k][1] for k in anahtarlar], dtype=np.float64)
    genislik = np.where((ust - alt) == 0, 1.0, ust - alt)
    gi_sutunu = anahtarlar.index("gi") if "gi" in anahtarlar else None

    # BUDAMA SIRASI: hedefi en sik ihlal edilen besin ogeleri once hesaplansin
    # ki mesafe hizla buyusun ve kaybeden t1'ler erken elensin. Sira, rastgele
    # ornek uclulerden olculur; SONUCU degistirmez, sadece hizi etkiler.
    if anahtarlar:
        _orn = random.Random(len(aday1_ham) * 7919 + len(aday3_ham))
        _ihlal = [0.0] * len(anahtarlar)
        for _ in range(min(400, len(aday1_ham) * len(aday2_ham) * len(aday3_ham))):
            _b = ogun_besin_toplami(_orn.choice(aday1_ham), _orn.choice(aday2_ham), _orn.choice(aday3_ham))
            for _j, _k in enumerate(anahtarlar):
                _d = _b.get(_k)
                if _d is not None:
                    _a, _u = hedef[_k]
                    _g = (_u - _a) or 1.0
                    _ihlal[_j] += max(_a - _d, 0.0, _d - _u) / _g
        _sira = sorted(range(len(anahtarlar)), key=lambda _j: -_ihlal[_j])
        anahtarlar = [anahtarlar[_j] for _j in _sira]
        alt = alt[_sira]
        ust = ust[_sira]
        genislik = genislik[_sira]
        gi_sutunu = anahtarlar.index("gi") if "gi" in anahtarlar else None

    D2, V2, GK2, KK2 = _besin_matrisi(aday2_ham, anahtarlar)
    D3, V3, GK3, KK3 = _besin_matrisi(aday3_ham, anahtarlar)
    orta = (alt + ust) / 2.0
    yarim = (ust - alt) / 2.0
    ters_genislik = 1.0 / genislik
    tumu_var = (V2.all(axis=0) & V3.all(axis=0)) if len(anahtarlar) else np.zeros(0, dtype=bool)
    if gi_sutunu is not None:
        tumu_var[gi_sutunu] = False
    M2 = np.array([_etiket_maskesi(t["etiketler"], bit) for t in aday2_ham], dtype=np.int64)
    M3 = np.array([_etiket_maskesi(t["etiketler"], bit) for t in aday3_ham], dtype=np.int64)
    T2 = np.array([_tid(t["ad"]) for t in aday2_ham], dtype=np.int64)
    T3 = np.array([_tid(t["ad"]) for t in aday3_ham], dtype=np.int64)

    aday1_karisik = list(aday1_ham)
    rastgele.shuffle(aday1_karisik)

    en_iyi_mesafe = None
    en_iyi_uclu = None
    if onceki_en_iyi is not None:
        # onceki kademelerin en iyisi: bu kademede ancak ondan KESIN daha
        # iyisi kabul edilir (eski "mesafe < en_iyi_genel_mesafe" ile ayni)
        en_iyi_mesafe, en_iyi_uclu = onceki_en_iyi

    if sadece_mesafe and hedef:
        # BASLANGIC SINIRI: kurallara uyan rastgele ucluler arasindan en iyisi,
        # budamanin ilk t1'den itibaren etkili olmasi icin. Sadece tamamlayici
        # tercihi (madde 13) OLMAYAN t1'ler orneklenir -- o t1'lerde her uyumlu
        # t3 gecerli aday oldugu icin secilen uclu kesinlikle KURALA UYGUN; yani
        # bu sadece bir baslangic noktasi, nihai sonucun en iyi olma garantisini
        # bozmaz (daha iyisi varsa asagidaki tam tarama onu bulur).
        _t1_tercihsiz = [t for t in aday1_ham if not _grup3_tercih_sirasi(t["etiketler"])]
        if _t1_tercihsiz:
            _orn = random.Random(len(aday1_ham) * 104729 + len(aday2_ham))
            for _ in range(3000):
                a1 = _orn.choice(_t1_tercihsiz)
                a2 = _orn.choice(aday2_ham)
                a3 = _orn.choice(aday3_ham)
                if len({_taban_kelime(a1["ad"]), _taban_kelime(a2["ad"]), _taban_kelime(a3["ad"])}) < 3:
                    continue
                # eski kuralla ayni: once t1+t2 ikilisi, sonra uclu uyumlu olmali
                if not _uyumlu_mu(set(a1["etiketler"]) | set(a2["etiketler"])):
                    continue
                if not _uyumlu_mu(set(a1["etiketler"]) | set(a2["etiketler"]) | set(a3["etiketler"])):
                    continue
                m = _besin_mesafesi(ogun_besin_toplami(a1, a2, a3), hedef)
                if en_iyi_mesafe is None or m < en_iyi_mesafe:
                    en_iyi_mesafe, en_iyi_uclu = m, (a1, a2, a3)

    for t1 in aday1_karisik:
        if bitis_zamani is not None and _time.monotonic() >= bitis_zamani:
            break
        tb1 = _tid(t1["ad"])
        m1 = _etiket_maskesi(t1["etiketler"], bit)
        # t2 adaylari
        s2 = (T2 != tb1) & ~_uyumsuz(M2 | m1)
        if not s2.any():
            continue
        i2 = np.nonzero(s2)[0]
        # 1) BESIN KONTROLU (anahtar anahtar, bellek dostu). BUDAMA: mesafe her
        #    anahtarda sadece artar; hicbir hucre hem hedefte olamiyor hem de
        #    simdiye kadarki en iyi mesafenin altinda kalamiyorsa bu t1 atlanir
        #    (kural/tercih matrisi hic kurulmadan). Sonuc degismez: atlanan
        #    hucreler zaten kazanamayacak hucrelerdir.
        d1, v1, gk1, kk1 = _besin_matrisi([t1], anahtarlar)
        hedefte = np.ones((len(i2), len(aday3_ham)), dtype=bool)
        mesafe = np.zeros(hedefte.shape, dtype=np.float64) if mesafe_hesapla else None
        sinir = np.inf if en_iyi_mesafe is None else en_iyi_mesafe
        budandi = False
        for j in range(len(anahtarlar)):
            if j == gi_sutunu:
                pay = gk1[0] + GK2[i2][:, None] + GK3[None, :]
                payda = kk1[0] + KK2[i2][:, None] + KK3[None, :]
                var_mi = payda > 0
                with np.errstate(divide="ignore", invalid="ignore"):
                    toplam = np.where(var_mi, pay / np.where(var_mi, payda, 1.0), 0.0)
            else:
                toplam = d1[0, j] + D2[i2, j][:, None] + D3[None, :, j]
                var_mi = v1[0, j] | V2[i2, j][:, None] | V3[None, :, j]
            if sadece_mesafe:
                # |toplam - orta| - yarim_genislik, sifirin altindaysa 0
                ihlal = np.abs(toplam - orta[j])
                ihlal -= yarim[j]
                np.maximum(ihlal, 0.0, out=ihlal)
                ihlal *= ters_genislik[j]
                if not tumu_var[j]:
                    ihlal *= var_mi
                mesafe += ihlal
                if not (mesafe < sinir).any():
                    budandi = True
                    break
                continue
            alti = toplam < alt[j]
            ustu = toplam > ust[j]
            hedefte &= ~(var_mi & (alti | ustu))
            if mesafe_hesapla:
                mesafe += np.where(var_mi & alti, (alt[j] - toplam) / genislik[j], 0.0)
                mesafe += np.where(var_mi & ustu, (toplam - ust[j]) / genislik[j], 0.0)
            if not hedefte.any() and (not mesafe_hesapla or not (mesafe < sinir).any()):
                budandi = True
                break
        if budandi:
            continue
        if sadece_mesafe:
            hedefte[:] = False

        # 2) KURAL MATRISI: (t2, t3) gecerliligi (temel tur + madde 11)
        gecerli = (
            (T3[None, :] != tb1)
            & (T3[None, :] != T2[i2][:, None])
            & ~_uyumsuz((M2[i2] | m1)[:, None] | M3[None, :])
        )
        if not gecerli.any():
            continue
        # madde 13: satir basina tercih edilen t3 kumesi
        aday = gecerli
        tercih_sirasi = _grup3_tercih_sirasi(t1["etiketler"])
        if tercih_sirasi:
            secildi = np.zeros(gecerli.shape[0], dtype=bool)
            aday = np.zeros_like(gecerli)
            for etiket in tercih_sirasi:
                etiketli = gecerli & ((M3 & bit[etiket]) != 0)[None, :]
                satir_var = etiketli.any(axis=1) & ~secildi
                aday[satir_var] = etiketli[satir_var]
                secildi |= satir_var
            aday[~secildi] = gecerli[~secildi]
        hedefte &= aday

        if hedefte.any():
            satirlar, sutunlar = np.nonzero(hedefte)
            k = rastgele.randrange(len(satirlar))
            uclu = (t1, aday2_ham[i2[satirlar[k]]], aday3_ham[sutunlar[k]])
            return uclu, uclu

        if not mesafe_hesapla:
            continue
        mesafe_aday = np.where(aday, mesafe, np.inf)
        konum = int(np.argmin(mesafe_aday))
        en_kucuk = float(mesafe_aday.flat[konum])
        if np.isfinite(en_kucuk) and (en_iyi_mesafe is None or en_kucuk < en_iyi_mesafe):
            r, c = divmod(konum, mesafe_aday.shape[1])
            en_iyi_mesafe = en_kucuk
            en_iyi_uclu = (t1, aday2_ham[i2[r]], aday3_ham[c])

    return None, en_iyi_uclu


def ogun_olustur(grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele, hedef=None, kullanilan_gun_taban=None):
    """Tek bir ogun (Ogle veya Aksam) icin I+II+III grup tarifi secer.
    Kademeli esneme sirasi (UYUMSUZLUK/madde 11 hicbirinde gevsetilmez):
      1) mevsime uygun + hafta icinde tekrarsiz + besin hedefi icinde
      2) mevsim kisitini gevset + hala tekrarsiz + besin hedefi icinde
      3) tekrara da izin ver (mevsim gevsek) + besin hedefi icinde
    Bu 3 kademenin HICBIRINDE "ayni gun icinde ayni temel yemek turu"
    (kullanilan_gun_taban) gevsetilmez -- sadece havuz TAMAMEN
    tukenirse (bkz. _aday_havuzu/_ogun_dene ici fallback) devreye girer.

    SEKSEN YEDINCI DUZELTME (4 Eylul 2026): "Hedef Dışı" ARTIK hicbir
    kademede kabul edilmiyor -- hedef hicbir kademede birakilmiyor; 3
    kademe de deneme sayisi ciddi olcude ARTIRILDI (200 -> 1500/1500/
    2500) VE her kademe, tam eslesme bulunamazsa kendi EN YAKIN uyumlu
    secenegini bildiriyor (bkz. _ogun_dene).

    YUZ YIRMI ALTINCI DUZELTME (9 Eylul 2026): Aralik ayinda 31 gunden
    SADECE 1'inin hedefte ciktigi bildirildi. `hedef_fizibilite_teshis.py`
    ile YAPILAN GERCEK VERI TESTI (kis mevsimi, 32 besin ogesi ayni anda,
    hafta/gun kisitlari OLMADAN en iyimser senaryo) sunu kanitladi: tam
    eslesme VAR ama COK NADIR -- 518.698 uyumlu uclunun SADECE 5'i (yani
    ~1/103.740) TUM 32 ogeyi tutturuyor. Sorun sonuc degil, KAPSAMA: tek
    bir t1 (ana yemek) adayinin butun kombinasyonlarini denemek bile
    ORTALAMA ~6.000 deneme gerektiriyor (89 t1 adayi icin), yani eski
    1500-2500 butcesiyle algoritma TEK BIR t1 adayini bile bitiremeden
    tukeniyor -- kazanan kombinasyonlarin kumelendigi "sansli" t1'e
    (ornekte: "Etli Yeşil Mercimek Yemeği") hic ulasamiyordu.
    Olcum: bu tarama 518.698 denemeyi 14.5 saniyede tamamladi (~35.800
    deneme/sn) -- yani butceyi ciddi olcude buyutmek HESAPSAL OLARAK
    UCUZ. Bahri'nin acik talimatiyla ("ne kadar surerse sursun en iyi
    sonucu istiyorum") 3 kademe de SINIRSIZ (tam/exhaustive) yapildi --
    artik bir kademe, o kademenin butun uyumlu havuzunu tuketmeden
    vazgecmiyor. Bu, EGER bir tam eslesme o kademenin kisitlari altinda
    VARSA, MUTLAKA bulunacagi anlamina gelir (aksi halde en yakin
    sonuca duser, eskisi gibi). Maliyet: buyuk/gevsek havuzlarda
    (ozellikle 3. kademe, tekrara_izin_ver=True) bir ogun icin BIRKAC
    ON SANIYEYE kadar surebilir -- aylik (~60 ogunluk) bir uretimde bu,
    kotu durumda onlarca dakikaya cikabilir; Bahri bu tradeoff'u
    BILINCLI olarak kabul etti."""
    en_iyi_genel_uclu = None
    en_iyi_genel_mesafe = None

    # YUZ ... DUZELTME (12 Ekim 2026): iki asamali arama.
    # 1. ASAMA -- TAM ESLESME: 3 kademe sirayla, her biri TAM taranir
    #    (exhaustive, vektorize). Bir kademede eslesme varsa MUTLAKA bulunur
    #    (9 Eylul'deki "ne kadar surerse sursun en iyi sonuc" kurali korunur).
    # 2. ASAMA -- EN YAKIN: hicbir kademede tam eslesme yoksa en yakin uclu
    #    3 kademede sirayla aranir (eskisi gibi en kucugu secilir); bir
    #    kademenin en iyisi sonrakinin baslangic siniri olur, boylece sonraki
    #    kademeler cok daha hizli budanir. Toplam sure OGUN_MESAFE_SINIRI_SN
    #    ile sinirli (sinira ulasilirsa o ana kadarki en iyi kullanilir).
    for tekrara_izin_ver, mevsim_zorunlu in ((False, True), (False, False), (True, False)):
        tam_sonuc, _ = _ogun_dene(
            grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele,
            float("inf"), tekrara_izin_ver, mevsim_zorunlu, hedef, kullanilan_gun_taban,
            mesafe_hesapla=False,
        )
        if tam_sonuc is not None:
            return tam_sonuc
    _bitis = time.monotonic() + OGUN_MESAFE_SINIRI_SN
    en_iyi = None
    for tekrara_izin_ver, mevsim_zorunlu in ((False, True), (False, False), (True, False)):
        if time.monotonic() >= _bitis:
            break
        _, uclu = _ogun_dene(
            grup1_havuz, grup2_havuz, grup3_havuz, mevsim, kullanilan_hafta, rastgele,
            float("inf"), tekrara_izin_ver, mevsim_zorunlu, hedef, kullanilan_gun_taban,
            bitis_zamani=_bitis, mesafe_hesapla=True, sadece_mesafe=True, onceki_en_iyi=en_iyi,
        )
        if uclu is not None and (en_iyi is None or uclu is not en_iyi[1]):
            en_iyi = (_hedef_mesafesi(*uclu, hedef), uclu)
    en_iyi_genel_uclu = en_iyi[1] if en_iyi else None

    if en_iyi_genel_uclu is not None:
        return en_iyi_genel_uclu

    # Buraya kadar gelinmesi COK OLASI DEGIL (uyumsuzluk kurallarini
    # saglayan TEK BIR uclu bile bulunamadi demektir). Programin
    # cokmemesi icin en gevsek secim yapiliyor.
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


def hafta_olustur(tarifler, mevsim, rastgele, hedefler=None, gun_sayisi=7, gun_mevsimleri=None, ilerleme=None):
    """tarifler: [{"ad","grup"(1/2/3, opsiyonel 4),"mevsim_etiketi","etiketler", ...besin}, ...]
    hedefler: {"Öğle": {"kalori":(min,max), ...}, "Akşam": {...}} ya da None.
    grup=4 (isletmenin kendi Icecek/Baslangic/Pizza/Burger receteleri)
    varsa, her ogune ISTEGE BAGLI 4. bir tarif eklenir -- bkz. _fast_food_sec.

    gun_mevsimleri: kullanicinin "her gun kendi gercek tarihinin ait
    oldugu mevsimden beslensin" karari uzerine eklendi. Bu listeye
    [gun1_mevsim, gun2_mevsim, ...] seklinde (gun_sayisi uzunlugunda)
    o haftanin HER GUNUNUN GERCEK mevsimi verilirse, o gunun
    ogun_olustur cagrisinda mevsim yerine bu kullanilir. Hafta ici
    tekrarsizlik (kullanilan_hafta) mevsim karisik olsa bile HALA TUM
    HAFTA icin gecerli."""
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
        # SIFIRLANAN ayri bir kume.
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
            if ilerleme is not None:
                ilerleme()  # YUZ ... DUZELTME (11 Ekim 2026): ekrandaki ilerleme cubugu
        hafta.append(gun)
    return hafta


def yillik_ornek_uret(tarifler, tohum=42):
    rastgele = random.Random(tohum)
    return {mevsim: hafta_olustur(tarifler, mevsim, rastgele) for mevsim in MEVSIMLER}


if __name__ == "__main__":
    import json

    from tarif_verisi import TARIFLER  # sadece yerel test icin

    print(json.dumps(yillik_ornek_uret(TARIFLER), ensure_ascii=False, indent=2))


