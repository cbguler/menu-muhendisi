# asama_ikonlari.py
#
# Hazirlik asamasi ikonlarini (dograma/kavurma/haslama vb.) asama
# adi/metninden bulmaya yarayan PAYLASIMLI mantik -- hem Recete
# Uretimi'nde (yapisal "asama" listesi -- her asamanin kisa bir "ad"i
# var, TEK ikon eslestirilir) hem Tarif Kutuphanesi'nde (241 kutuphane
# tarifi icin TEK PARCA "hazirlik_talimati" metni -- metin icinde GECEN
# TUM teknikler toplu bulunur) kullanilir. Boylece iki sayfa arasinda
# 20 satirlik esleme sozlugu TEKRAR YAZILMAZ.
#
# Eslesme KELIME BASI ile yapilir (alt dize DEGIL) -- ör. "ez" koku
# "bezeler" kelimesinin ICINDE var ama BASINDA degil, bu yuzden
# yanlislikla eslesmez (30 Agustos 2026, 20 gercekci ornek cumleyle
# test edildi).

import os

ASAMA_IKON_KOKLERI = {
    "dograma": ["doğra", "dogra"],
    "dilimleme": ["dilim"],
    "rendeleme": ["rende"],
    "soyma": ["soy"],
    "kavurma": ["kavur"],
    "kizartma": ["kızart", "kizart"],
    "haslama": ["haşla", "hasla", "kaynat"],
    "izgara": ["ızgara", "izgara"],
    "firinlama": ["fırın", "firin"],
    "buharda_pisirme": ["buhar"],
    "kozleme": ["közle", "kozle"],
    "karistirma": ["karıştır", "karistir"],
    "cirpma": ["çırp", "cirp"],
    "yogurma": ["yoğur", "yogur"],
    "ezme": ["ez"],
    "suzme": ["süz", "suz"],
    "marine_etme": ["marine"],
    "dinlendirme": ["dinlen", "demle"],
    "baharatlama": ["baharatla", "tatlandır", "tatlandir"],
}


def _ikon_yolu(ikon_adi):
    yol = f"assets/{ikon_adi}.png"
    return yol if os.path.exists(yol) else None


# ELLI YEDINCI DUZELTME (30 Agustos 2026): kullanici gercek bir ornek
# fark etti -- "şeftalileri ... dilimleyin" yazan bir tarifte, dilimleme
# ikonu bir SALATALIK gosteriyordu (ikonun icine gomulu sabit malzeme
# ile tarifteki gercek malzeme uyusmuyordu). Malzeme-turune EN COK
# duyarli 4 hazirlik islemi (dograma/dilimleme/rendeleme/soyma) icin
# oncelik sirali, GENISLETILEBILIR bir malzeme-varyanti sistemi
# kuruldu.
#
# ELLI DOKUZUNCU DUZELTME (30 Agustos 2026): kullanici gercek veriyle
# (241 tariflik kutuphanede SQL sorgusuyla) dogruladi -- SOGAN, doğrama/
# dilim/rende/soy adimlarinda EN BASKIN malzeme (78 farkli tarifte
# geciyor -- 2. siradaki domatesten 7 KAT fazla). Bu yuzden "soğan"
# genel meyve/sebze ayriminin ONUNE gecen, EN YUKSEK ONCELIKLI ozel
# bir varyant olarak eklendi.
#
# _SPESIFIK_MALZEME_VARYANTLARI: (kok listesi, dosya soneki) ciftlerinin
# ONCELIK SIRALI listesi -- yeni bir malzeme icin ikon eklendiginde
# buraya sadece bir satir eklemek yeterli, baska hicbir yer
# degismiyor. Bir eslesme bulunur ama karsilik gelen dosya HENUZ YOKSA
# bir sonraki (daha genel) secene sessizce gecilir.
_SPESIFIK_MALZEME_VARYANTLARI = [
    (["soğan", "sogan"], "sogan"),
    # ALTMISINCI DUZELTME (30 Agustos 2026): veri analizinde sogandan
    # sonra en sik gecen 2. tur malzemeler -- limon (10 tarif) ve biber
    # (10 tarif), patlican/havuctan (7 tarif) belirgin sekilde onde.
    (["limon"], "limon"),
    (["biber"], "biber"),
]

MEYVE_KOKLERI = [
    "elma", "armut", "şeftali", "seftali", "kayısı", "kayisi", "erik",
    "çilek", "cilek", "muz", "portakal", "mandalina", "greyfurt",
    "üzüm", "uzum", "kiraz", "vişne", "visne", "karpuz", "kavun", "incir",
    "nar", "ananas", "kivi", "ayva", "dut", "böğürtlen", "bogurtlen",
    "ahududu", "mersin",
]

_MALZEME_DUYARLI_ISLEMLER = {"dograma", "dilimleme", "rendeleme", "soyma"}


def _kelimelerde_kok_var_mi(kelimeler, kokler):
    return any(any(kelime.startswith(kok) for kok in kokler) for kelime in kelimeler)


def _ikon_adini_coz(ikon_adi, kelimeler):
    """dograma/dilimleme/rendeleme/soyma icin, AYNI metinde ozel bir
    malzeme (ör. soğan) geciyorsa o varyanti (dosyasi varsa) tercih
    eder; yoksa genel meyve varyantina, o da yoksa temel (sebze)
    versiyona duser."""
    if ikon_adi in _MALZEME_DUYARLI_ISLEMLER:
        for kokler, sonek in _SPESIFIK_MALZEME_VARYANTLARI:
            if _kelimelerde_kok_var_mi(kelimeler, kokler):
                yol = _ikon_yolu(f"{ikon_adi}_{sonek}")
                if yol:
                    return yol
        if _kelimelerde_kok_var_mi(kelimeler, MEYVE_KOKLERI):
            meyve_yolu = _ikon_yolu(f"{ikon_adi}_meyve")
            if meyve_yolu:
                return meyve_yolu
    return _ikon_yolu(ikon_adi)


_OLUMSUZLUK_KELIMELERI = {"değil", "degil", "yerine"}


def _kelime_eslesiyor_mu(kelimeler, indeks, kokler):
    """Bir kelimenin bir kok listesiyle eslesip eslesmedigini kontrol
    eder -- ama HEMEN ARDINDAN "degil"/"yerine" geliyorsa eslesmeyi
    IPTAL eder (30 Agustos 2026: test sirasinda yakalandi -- "soğan
    doğranmış DEĞİL, rendelenmiş kullanılır" cumlesinde "doğranmış"
    eslesiyordu ama cumle asil DOGRAMAYI REDDEDIYOR, yanlis ikon
    gosterirdi). Bu TAM bir dilbilgisi cozumu degil (ör. "degil" iki
    kelime sonra gelirse yakalanmaz), ama en sik gorulen "X degil, Y"
    kalibini kapsiyor."""
    kelime = kelimeler[indeks]
    if not any(kelime.startswith(kok) for kok in kokler):
        return False
    sonraki = kelimeler[indeks + 1].strip(",.;:") if indeks + 1 < len(kelimeler) else ""
    if sonraki in _OLUMSUZLUK_KELIMELERI:
        return False
    return True


def tek_ikon_bul(metin):
    """Kisa bir metinde (ör. Recete Uretimi'ndeki tek bir asama adi)
    ILK eslesen ikonun dosya yolunu dondurur, yoksa None."""
    kelimeler = metin.strip().lower().split()
    for ikon_adi, kokler in ASAMA_IKON_KOKLERI.items():
        for i in range(len(kelimeler)):
            if _kelime_eslesiyor_mu(kelimeler, i, kokler):
                yol = _ikon_adini_coz(ikon_adi, kelimeler)
                if yol:
                    return yol
    return None


def tum_ikonlari_bul(metin):
    """Uzun bir metinde (ör. Tarif Kutuphanesi'ndeki tum
    hazirlik_talimati) GECEN TUM benzersiz ikonlarin dosya yollarini
    (sirali, tekrarsiz liste olarak) bulur. Metin bos/None ise bos
    liste doner."""
    if not metin:
        return []
    kelimeler = metin.strip().lower().split()
    bulunanlar = []
    for ikon_adi, kokler in ASAMA_IKON_KOKLERI.items():
        for i in range(len(kelimeler)):
            if _kelime_eslesiyor_mu(kelimeler, i, kokler):
                yol = _ikon_adini_coz(ikon_adi, kelimeler)
                if yol and yol not in bulunanlar:
                    bulunanlar.append(yol)
                break
    return bulunanlar
