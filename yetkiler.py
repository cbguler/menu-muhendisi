# yetkiler.py
#
# YUZ ... DUZELTME (28 Eylul 2026, Menu Muhendisi 9): Isletme / Sube / Personel
# yetki katalogu. Veritabani tarafi: sql/182 (personel_sube_yetkileri.yetkiler
# jsonb, anahtar -> seviye kodu; auth_yetki_seviye() ile RLS'te zorlanir).
#
# Seviye kodlari ve siralari (182'deki auth_yetki_seviye ile AYNI):
#   "yok"     -> 0  (gizli / erisim yok)
#   "gor"     -> 1  (gorur; satin alma listesi icin gorur ve indirir)
#   "indir"   -> 1  (PDF raporlari)
#   "duzenle" -> 2
#
# Patron (isletme sahibi) her yetkinin en ust seviyesine sahiptir; bu kisitlanamaz.
# Abonelik, odeme, sube acma ve personel yonetimi SADECE patrona aittir ve
# katalogda yer almaz (devredilemez).

import streamlit as st

SEVIYE_SIRASI = {"yok": 0, "gor": 1, "indir": 1, "duzenle": 2}

# (anahtar, etiket, aciklama, [(seviye kodu, etiket), ...])  -- ilk seviye en dusuk
YETKI_KATALOGU = [
    ("maliyetler", "Maliyetler ve fiyatlar",
     "Reçete maliyeti, kâr marjı, malzeme fiyatları",
     [("yok", "Gizli"), ("gor", "Görür")]),
    ("satin_alma", "Satın alma listeleri",
     "Aylık Sarf Listesi",
     [("yok", "Yok"), ("gor", "Görür ve indirir")]),
    ("uygulama_tarifleri", "Uygulama tarifleri",
     "Tarif Kütüphanesi (uygulamanın ortak tarifleri)",
     [("yok", "Yok"), ("gor", "Görür")]),
    ("ozel_tarifler", "İşletmenin özel tarifleri",
     "Ana işletmenin ve şubenin kendi tarifleri",
     [("yok", "Yok"), ("gor", "Görür"), ("duzenle", "Düzenler")]),
    ("recete_uretimi", "Reçete üretimi",
     "Yeni reçete oluşturma, satışa açma",
     [("yok", "Yok"), ("gor", "Görür"), ("duzenle", "Düzenler")]),
    ("aylik_menu", "Aylık menü üretimi",
     "Aylık Menü sayfası",
     [("yok", "Yok"), ("gor", "Görür"), ("duzenle", "Düzenler")]),
    ("pdf_raporlar", "PDF raporları",
     "Aylık menü PDF'i",
     [("yok", "Yok"), ("indir", "İndirir")]),
    ("fiyat_guncelleme", "Malzeme fiyatlarını güncelleme",
     "Fiyatları görmekten ayrı bir yetki",
     [("yok", "Yok"), ("duzenle", "Düzenler")]),
    ("maliyet_ayarlari", "İşletme maliyet ayarları",
     "Elektrik, doğalgaz, personel ücreti, genel gider",
     [("yok", "Yok"), ("gor", "Görür"), ("duzenle", "Düzenler")]),
    ("porsiyon_profilleri", "Porsiyon profilleri",
     "Porsiyon profili ve besin hedefi düzenleme",
     [("yok", "Yok"), ("duzenle", "Düzenler")]),
]

YETKI_ANAHTARLARI = [k[0] for k in YETKI_KATALOGU]

# Hazir roller -- baslangic seti; patron her subede satir satir degistirebilir.
# ONERI (28 Eylul 2026, Bahri itiraz etmedi); Emre ile gozden gecirilecek.
HAZIR_ROLLER = {
    "asci": ("Aşçı", {
        "maliyetler": "yok", "satin_alma": "gor", "uygulama_tarifleri": "gor",
        "ozel_tarifler": "gor", "recete_uretimi": "gor", "aylik_menu": "gor",
        "pdf_raporlar": "indir", "fiyat_guncelleme": "yok", "maliyet_ayarlari": "yok",
        "porsiyon_profilleri": "yok",
    }),
    "yonetici": ("Yönetici", {
        "maliyetler": "gor", "satin_alma": "gor", "uygulama_tarifleri": "gor",
        "ozel_tarifler": "duzenle", "recete_uretimi": "duzenle", "aylik_menu": "duzenle",
        "pdf_raporlar": "indir", "fiyat_guncelleme": "duzenle", "maliyet_ayarlari": "duzenle",
        "porsiyon_profilleri": "duzenle",
    }),
    "muhasebe": ("Muhasebe", {
        "maliyetler": "gor", "satin_alma": "gor", "uygulama_tarifleri": "gor",
        "ozel_tarifler": "yok", "recete_uretimi": "yok", "aylik_menu": "gor",
        "pdf_raporlar": "indir", "fiyat_guncelleme": "duzenle", "maliyet_ayarlari": "gor",
        "porsiyon_profilleri": "yok",
    }),
}
OZEL_ROL = ("ozel", "Özel (aşağıdaki ayarlar)")


def tam_yetkiler():
    """Patron icin: her yetkinin en ust seviyesi."""
    return {anahtar: seviyeler[-1][0] for anahtar, _, _, seviyeler in YETKI_KATALOGU}


def yetki(anahtar):
    """Aktif subedeki seviye (0/1/2). app.py st.session_state.yetkiler'i doldurur."""
    yetkiler = st.session_state.get("yetkiler") or {}
    return SEVIYE_SIRASI.get(yetkiler.get(anahtar, "yok"), 0)
