# eposta.py
#
# 16 Ekim 2026 (acik is #8): uygulamadan e-posta gonderimi (SMTP).
# Simdilik Bahri'nin Gmail hesabindan gonderilir (Bahri: "daha sonra baska e-posta alirim").
# Ayarlar SADECE Streamlit Cloud Secrets'ta durur, kodda ve depoda sifre yoktur:
#   SMTP_KULLANICI   gonderen hesap (ör. Gmail adresi)
#   SMTP_SIFRE       Gmail "uygulama sifresi" (16 harf; normal Gmail sifresi CALISMAZ)
#   SMTP_GONDEREN_AD (istege bagli) gorunen ad, varsayilan "Menü Mühendisi"
#   SMTP_SUNUCU      (istege bagli) varsayilan smtp.gmail.com
#   SMTP_PORT        (istege bagli) varsayilan 465 (SSL)
# Ileride baska bir adrese gecilirse sadece Secrets degisir, kod degismez.
#
# Kotuye kullanim onlemi: uygulama e-postayi SADECE giris yapan kullanicinin kendi hesap adresine gonderir
# (sayfa alici adresini kullanicidan almaz).

import html
import smtplib
import ssl
from email.message import EmailMessage
from email.utils import formataddr

import streamlit as st


class EpostaHatasi(Exception):
    pass


def _secret(ad, varsayilan=None):
    try:
        return st.secrets.get(ad, varsayilan)
    except Exception:
        return varsayilan


def hazir_mi():
    """SMTP kullanici adi ve sifresi Secrets'ta tanimli mi."""
    return bool(_secret("SMTP_KULLANICI") and _secret("SMTP_SIFRE"))


def gonder(alici, konu, html_govde, duz_metin):
    if not hazir_mi():
        raise EpostaHatasi(
            "E-posta gönderimi henüz kurulmadı (SMTP_KULLANICI ve SMTP_SIFRE Streamlit Cloud Secrets'ta yok)."
        )
    kullanici = str(_secret("SMTP_KULLANICI")).strip()
    sifre = str(_secret("SMTP_SIFRE")).replace(" ", "")  # Gmail uygulama sifresi bosluklu gosterilir
    sunucu = str(_secret("SMTP_SUNUCU", "smtp.gmail.com"))
    port = int(_secret("SMTP_PORT", 465))
    ad = str(_secret("SMTP_GONDEREN_AD", "Menü Mühendisi"))

    mesaj = EmailMessage()
    mesaj["Subject"] = konu
    mesaj["From"] = formataddr((ad, kullanici))
    mesaj["To"] = alici
    mesaj.set_content(duz_metin)
    mesaj.add_alternative(html_govde, subtype="html")

    try:
        if port == 465:
            with smtplib.SMTP_SSL(sunucu, port, context=ssl.create_default_context(), timeout=20) as s:
                s.login(kullanici, sifre)
                s.send_message(mesaj)
        else:
            with smtplib.SMTP(sunucu, port, timeout=20) as s:
                s.starttls(context=ssl.create_default_context())
                s.login(kullanici, sifre)
                s.send_message(mesaj)
    except smtplib.SMTPAuthenticationError:
        raise EpostaHatasi(
            "E-posta hesabına giriş yapılamadı. Secrets'taki SMTP_SIFRE bir Gmail uygulama şifresi olmalı "
            "(normal Gmail şifresi çalışmaz)."
        )
    except smtplib.SMTPRecipientsRefused:
        raise EpostaHatasi(f"Alıcı adres kabul edilmedi: {alici}")
    except (smtplib.SMTPException, OSError) as e:
        raise EpostaHatasi(f"E-posta gönderilemedi: {e}")


# ---------------------------------------------------------------------
# Evdekilerle Menu: menu + alinmasi gerekenler
# ---------------------------------------------------------------------
_GUNLER = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
_YESIL = "#0F6E56"


def _tablo(basliklar, satirlar):
    h = "".join(
        f"<th style='text-align:left;padding:6px 10px;border-bottom:2px solid {_YESIL};'>{html.escape(b)}</th>"
        for b in basliklar
    )
    govde = "".join(
        "<tr>" + "".join(
            f"<td style='padding:6px 10px;border-bottom:1px solid #ddd;vertical-align:top;'>{hucre}</td>"
            for hucre in satir
        ) + "</tr>"
        for satir in satirlar
    )
    return f"<table style='border-collapse:collapse;width:100%;font-size:14px;'><tr>{h}</tr>{govde}</table>"


def ev_menu_epostasi(isletme_adi, tarihler, gunler, porsiyon, alinacaklar):
    """gunler: E.menu_olustur sonucundaki 'gunler' listesi ({'ogunler': {ad: {'tarifler': [...]}}}).
    alinacaklar: [(malzeme adi, gereken yazisi, onerilen alim yazisi)], Turkce alfabe sirasinda.
    Donus: (konu, html, duz metin)."""
    bas, son = tarihler[0], tarihler[-1]
    aralik = bas.strftime("%d.%m.%Y") + ("" if bas == son else " - " + son.strftime("%d.%m.%Y"))
    konu = f"Evdekilerle Menü: {aralik} ({porsiyon} kişilik)"

    menu_satirlari, duz = [], [konu, ""]
    for gun, tarih in zip(gunler, tarihler):
        gun_yazisi = f"{tarih.strftime('%d.%m.%Y')} {_GUNLER[tarih.weekday()]}"
        duz.append(gun_yazisi)
        for i, (ogun, o) in enumerate(gun["ogunler"].items()):
            tarifler = list(o.get("tarifler") or [])
            menu_satirlari.append([
                f"<b>{html.escape(gun_yazisi)}</b>" if i == 0 else "",
                html.escape(ogun),
                "<br>".join(html.escape(t) for t in tarifler),
            ])
            duz.append(f"  {ogun}: " + ", ".join(tarifler))
    duz.append("")

    duz.append("ALINMASI GEREKENLER")
    if alinacaklar:
        liste_html = _tablo(
            ["Malzeme", "Gereken", "Önerilen alım"],
            [[html.escape(a), html.escape(g), html.escape(o)] for a, g, o in alinacaklar],
        )
        duz += [f"- {a}: {g} (önerilen alım {o})" for a, g, o in alinacaklar]
    else:
        liste_html = "<p>Evdeki malzemeler bu menü için yetiyor; alman gereken bir şey yok.</p>"
        duz.append("Evdeki malzemeler bu menü için yetiyor; alman gereken bir şey yok.")
    not_metni = ("Temel malzemeler (tuz, baharat, yağ gibi evde var saydıkların) listeye girmez. Miktarlar tarif "
                 "gramlarıdır; kabuklu ya da kemikli ürünlerde biraz fazla almak gerekebilir.")
    duz += ["", not_metni, "", "Bu e-posta Menü Mühendisi'nden senin isteğinle gönderildi."]

    baslik = html.escape(isletme_adi) + " - " if isletme_adi else ""
    html_govde = f"""<!doctype html><html><body style="font-family:Arial,Helvetica,sans-serif;color:#222;max-width:720px;margin:auto;">
<h2 style="color:{_YESIL};margin-bottom:4px;">Evdekilerle Menü</h2>
<p style="margin-top:0;color:#555;">{baslik}{html.escape(aralik)} &middot; {porsiyon} kişilik</p>
<h3 style="color:{_YESIL};">Menü</h3>
{_tablo(["Gün", "Öğün", "Tarifler"], menu_satirlari)}
<h3 style="color:{_YESIL};margin-top:24px;">Alınması gerekenler</h3>
{liste_html}
<p style="color:#666;font-size:12px;margin-top:12px;">{html.escape(not_metni)}</p>
<p style="color:#999;font-size:12px;margin-top:24px;">Bu e-posta Menü Mühendisi'nden senin isteğinle gönderildi.</p>
</body></html>"""
    return konu, html_govde, "\n".join(duz)
