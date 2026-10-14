# ev_menu_pdf.py
#
# Evdekilerle Menu PDF'i (15 Ekim 2026, Bahri: "Menü, alışveriş listesi, stok raporu ve
# tariflerin PDF olarak indirilmesi olması gereken bir özellik"). Streamlit'ten bagimsiz:
# sayfa (pages/2_Evdekilerle_Menu.py) veriyi hazirlayip ev_menu_pdf_olustur'u cagirir.
# Bolumler: 1) Menu (gun gun), 2) Alman gerekenler, 3) Stok raporu, 4) Tarifler (kisi
# sayisina gore olceklenmis malzemeler + hazirlanis).
# Gorunum 0_Yillik_Menu.py PDF'leriyle ayni: DejaVu Sans (Turkce karakterler), her sayfada
# logo + "Menü Mühendisi" + isletme adi + alt baslik.

import html
import io
import os
import re

import ev_menu as E

_FONT_KLASORU = "assets/fonts"
_FONT_HAZIR = None
_GUNLER = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
_YESIL = "#0F6E56"
_ACIK_YESIL = "#E1F5EE"


def _fontlar():
    """(normal, kalin) font adlari. DejaVu yoksa Helvetica (Turkce karakterler bozuk ama PDF uretilir)."""
    global _FONT_HAZIR
    if _FONT_HAZIR is None:
        from reportlab.pdfbase import pdfmetrics
        from reportlab.pdfbase.ttfonts import TTFont
        normal = os.path.join(_FONT_KLASORU, "DejaVuSans.ttf")
        kalin = os.path.join(_FONT_KLASORU, "DejaVuSans-Bold.ttf")
        if os.path.exists(normal) and os.path.exists(kalin):
            pdfmetrics.registerFont(TTFont("Turkce", normal))
            pdfmetrics.registerFont(TTFont("Turkce-Kalin", kalin))
            # registerFontFamily olmadan Paragraph bazi Turkce harfleri yanlis basiyor (0_Yillik_Menu.py notu)
            pdfmetrics.registerFontFamily("Turkce", normal="Turkce", bold="Turkce-Kalin",
                                          italic="Turkce", boldItalic="Turkce-Kalin")
            _FONT_HAZIR = True
        else:
            _FONT_HAZIR = False
    return ("Turkce", "Turkce-Kalin") if _FONT_HAZIR else ("Helvetica", "Helvetica-Bold")


def _metin(s):
    """Duz metni Paragraph icin guvenli hale getirir; **kalin** -> <b>kalin</b>."""
    s = html.escape(str(s or ""), quote=False)
    return re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", s)


def ev_menu_pdf_olustur(isletme_adi, tarihler, sonuc, porsiyon, malzeme_adlari, tarif_malzemeleri,
                        tarif_talimatlari, baslangic_stok, temel_idler=()):
    """
    isletme_adi: sayfa basligi (isletmenin tam adi)
    tarihler: [datetime.date, ...] menunun gunleri
    sonuc: ev_menu.menu_olustur / menuyu_yeniden_hesapla ciktisi (gunler, eksik, kullanilan, kalan)
    porsiyon: kisi sayisi
    malzeme_adlari: {malzeme_id: ad}
    tarif_malzemeleri: {tarif_adi: [(malzeme_id, porsiyon_basi_gram), ...]}
    tarif_talimatlari: {tarif_adi: hazirlanis metni ya da None}
    baslangic_stok: {malzeme_id: gram}
    temel_idler: "evde var" kabul edilen temel malzemeler (tarifte "(evde var)" notu icin)
    Donus: PDF bayt.
    """
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
    from reportlab.lib.units import cm
    from reportlab.platypus import (KeepTogether, PageBreak, Paragraph, SimpleDocTemplate, Spacer,
                                    Table, TableStyle)

    fn, fk = _fontlar()
    if tarihler:
        aralik = f"{tarihler[0].strftime('%d.%m.%Y')} - {tarihler[-1].strftime('%d.%m.%Y')}"
    else:
        aralik = ""
    alt_baslik = f"Evdekilerle Menü ({porsiyon} kişilik) — {aralik}"

    tampon = io.BytesIO()
    belge = SimpleDocTemplate(tampon, pagesize=A4, leftMargin=1.8 * cm, rightMargin=1.8 * cm,
                              topMargin=2.8 * cm, bottomMargin=1.8 * cm, title=f"Evdekilerle Menü {aralik}")
    ss = getSampleStyleSheet()
    s_bolum = ParagraphStyle("bolum", parent=ss["Heading2"], fontName=fk, fontSize=14, spaceBefore=6, spaceAfter=8,
                             textColor=colors.HexColor(_YESIL))
    s_tarif = ParagraphStyle("tarif", parent=ss["Heading3"], fontName=fk, fontSize=12, spaceBefore=10, spaceAfter=4)
    s_normal = ParagraphStyle("n", parent=ss["Normal"], fontName=fn, fontSize=9.5, leading=12.5)
    s_kucuk = ParagraphStyle("k", parent=s_normal, fontSize=8.5, leading=11)
    s_gri = ParagraphStyle("g", parent=s_kucuk, textColor=colors.grey)
    s_hucre = ParagraphStyle("h", parent=s_normal, fontSize=9, leading=11.5)
    s_baslik_hucre = ParagraphStyle("hb", parent=s_hucre, fontName=fk, textColor=colors.white)

    def tablo(satirlar, genislikler, baslik_var=True):
        t = Table(satirlar, colWidths=genislikler, repeatRows=1 if baslik_var else 0)
        stil = [
            ("FONTNAME", (0, 0), (-1, -1), fn),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#B8D8CC")),
            ("TOPPADDING", (0, 0), (-1, -1), 3), ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
        ]
        if baslik_var:
            stil.append(("BACKGROUND", (0, 0), (-1, 0), colors.HexColor(_YESIL)))
            for i in range(1, len(satirlar)):
                if i % 2 == 0:
                    stil.append(("BACKGROUND", (0, i), (-1, i), colors.HexColor(_ACIK_YESIL)))
        t.setStyle(TableStyle(stil))
        return t

    def P(x, stil=s_hucre):
        return Paragraph(_metin(x), stil)

    def H(x):
        return Paragraph(_metin(x), s_baslik_hucre)

    genislik = A4[0] - belge.leftMargin - belge.rightMargin
    akis = []

    # 1) Menu
    akis.append(Paragraph("Menü", s_bolum))
    ogun_adlari = list(sonuc["gunler"][0]["ogunler"].keys()) if sonuc["gunler"] else []
    satirlar = [[H("Gün")] + [H(o) for o in ogun_adlari]]
    for gun, tarih in zip(sonuc["gunler"], tarihler):
        hucreler = [Paragraph(f"<b>{tarih.strftime('%d.%m.%Y')}</b><br/>{_GUNLER[tarih.weekday()]}", s_hucre)]
        for o in ogun_adlari:
            og = gun["ogunler"].get(o) or {}
            satir_metni = "<br/>".join(_metin(t) for t in og.get("tarifler", []))
            if og.get("stoktan_yuzde") is not None:
                satir_metni += f"<br/><font size=7.5 color='grey'>Evdeki malzemeden: %{og['stoktan_yuzde']:.0f}</font>"
            hucreler.append(Paragraph(satir_metni, s_hucre))
        satirlar.append(hucreler)
    gun_g = 3.0 * cm
    akis.append(tablo(satirlar, [gun_g] + [(genislik - gun_g) / max(1, len(ogun_adlari))] * len(ogun_adlari)))

    # 2) Alman gerekenler
    akis.append(Spacer(1, 10))
    akis.append(Paragraph("Alman gerekenler", s_bolum))
    if sonuc["eksik"]:
        satirlar = [[H("Malzeme"), H("Gereken"), H("Önerilen alım"), H("Alındı")]]
        for mid, g in sorted(sonuc["eksik"].items(), key=lambda x: E.tr_sirala_anahtari(malzeme_adlari.get(x[0], "?"))):
            satirlar.append([P(malzeme_adlari.get(mid, "?")), P(E.gram_yazisi(g)),
                             P(E.gram_yazisi(E.pratik_miktar(g))), P("[  ]")])
        akis.append(tablo(satirlar, [genislik * 0.46, genislik * 0.18, genislik * 0.2, genislik * 0.16]))
        akis.append(Spacer(1, 4))
        akis.append(Paragraph(
            "Temel malzemeler (evde var kabul edilenler) listede yok. Miktarlar tarif gramlarıdır; soyma/ayıklama "
            "firesi eklenmedi, kabuklu ya da kemikli ürünlerde biraz fazla almak gerekebilir.", s_gri))
    else:
        akis.append(Paragraph("Evdeki malzemeler bu menü için yetiyor; alınacak bir şey yok.", s_normal))

    # 3) Stok raporu
    akis.append(Spacer(1, 10))
    akis.append(Paragraph("Stok raporu", s_bolum))
    if baslangic_stok:
        satirlar = [[H("Malzeme"), H("Evde olan"), H("Kullanılan"), H("Kalan")]]
        for mid, g in sorted(baslangic_stok.items(), key=lambda x: E.tr_sirala_anahtari(malzeme_adlari.get(x[0], "?"))):
            satirlar.append([P(malzeme_adlari.get(mid, "?")), P(E.gram_yazisi(g)),
                             P(E.gram_yazisi(sonuc["kullanilan"].get(mid, 0.0))),
                             P(E.gram_yazisi(sonuc["kalan"].get(mid, 0.0)))])
        akis.append(tablo(satirlar, [genislik * 0.46, genislik * 0.18, genislik * 0.18, genislik * 0.18]))
        kullanilmayan = sorted((malzeme_adlari.get(mid, "?") for mid in baslangic_stok
                                if sonuc["kullanilan"].get(mid, 0.0) <= 0), key=E.tr_sirala_anahtari)
        if kullanilmayan:
            akis.append(Spacer(1, 4))
            akis.append(Paragraph("Bu menüde değerlendirilemeyenler: " + _metin(", ".join(kullanilmayan)), s_gri))
    else:
        akis.append(Paragraph("Stok girilmediği için rapor yok.", s_normal))

    # 4) Tarifler (menudeki siraya gore, her tarif bir kez)
    sirali = []
    for gun in sonuc["gunler"]:
        for og in gun["ogunler"].values():
            for t in og.get("tarifler", []):
                if t not in sirali:
                    sirali.append(t)
    if sirali:
        akis.append(PageBreak())
        akis.append(Paragraph("Tarifler", s_bolum))
        akis.append(Paragraph(f"Malzeme miktarları {porsiyon} kişi içindir.", s_gri))
    for ad in sirali:
        parca = [Paragraph(_metin(ad), s_tarif)]
        kalemler = tarif_malzemeleri.get(ad) or []
        if kalemler:
            satirlar = [[H("Malzeme"), H("Miktar")]]
            for mid, g in kalemler:
                not_ = " (evde var)" if mid in temel_idler else ""
                satirlar.append([P(malzeme_adlari.get(mid, "?") + not_), P(E.gram_yazisi(g * porsiyon))])
            parca.append(tablo(satirlar, [genislik * 0.7, genislik * 0.3]))
        talimat = (tarif_talimatlari or {}).get(ad)
        parca.append(Spacer(1, 4))
        if talimat:
            for satir in str(talimat).splitlines():
                if satir.strip():
                    parca.append(Paragraph(_metin(satir.strip()), s_kucuk))
        else:
            parca.append(Paragraph("Bu tarif için hazırlanış metni girilmemiş.", s_gri))
        # Tarif basligi ve malzeme tablosu sayfa sonunda ayrilmasin
        akis.append(KeepTogether(parca[:2]))
        akis.extend(parca[2:])

    def sayfa(canvas, doc):
        canvas.saveState()
        en, boy = doc.pagesize
        sol, sag = doc.leftMargin, en - doc.rightMargin
        if os.path.exists("assets/logo.png"):
            try:
                canvas.drawImage("assets/logo.png", sol, boy - 2.2 * cm, width=1.2 * cm, height=1.2 * cm,
                                 mask="auto", preserveAspectRatio=True)
            except Exception:
                pass
        canvas.setFont(fn, 8)
        canvas.setFillColor(colors.grey)
        canvas.drawString(sol, boy - 2.4 * cm, "Menü Mühendisi")
        canvas.setFont(fk, 14)
        canvas.setFillColor(colors.black)
        canvas.drawCentredString((sol + sag) / 2, boy - 1.55 * cm, isletme_adi or "")
        canvas.setFont(fn, 9)
        canvas.setFillColor(colors.grey)
        canvas.drawCentredString((sol + sag) / 2, boy - 2.1 * cm, alt_baslik)
        canvas.setStrokeColor(colors.grey)
        canvas.line(sol, boy - 2.5 * cm, sag, boy - 2.5 * cm)
        canvas.setFont(fn, 8)
        canvas.drawRightString(sag, 1.1 * cm, f"Sayfa {doc.page}")
        canvas.restoreState()

    belge.build(akis, onFirstPage=sayfa, onLaterPages=sayfa)
    return tampon.getvalue()
