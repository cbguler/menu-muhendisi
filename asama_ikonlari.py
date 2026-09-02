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
    "dinlendirme": ["dinlen"],
    "demleme": ["demle"],
    "baharatlama": ["baharatla", "tuzla", "tatlandır", "tatlandir"],
}


def _ikon_yolu(ikon_adi):
    yol = f"assets/{ikon_adi}.png"
    return yol if os.path.exists(yol) else None


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
                yol = _ikon_yolu(ikon_adi)
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
                yol = _ikon_yolu(ikon_adi)
                if yol and yol not in bulunanlar:
                    bulunanlar.append(yol)
                break
    return bulunanlar
