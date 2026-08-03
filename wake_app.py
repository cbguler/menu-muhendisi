# wake_app.py
#
# Streamlit Community Cloud, 12 saat trafiksizlik sonrasi uygulamayi
# uykuya yatiriyor. Duz bir HTTP GET/curl ISE YARAMAZ -- Streamlit
# artik gercek bir tarayici (JavaScript + WebSocket, /_stcore/stream)
# olmadan uygulamayi hic baslatmiyor, curl sadece statik bir HTML
# kabugu aliyor.
#
# Bu yuzden TrendSurf Optima'da uyguladigimiz cozumle ayni yontem:
# gercek (headless) bir Chromium tarayicisiyla sayfayi ziyaret edip,
# "Yes, get this app back up!" butonu varsa tikliyoruz.
#
# ONEMLI SINIRLAMA: Bu resmi/garantili bir cozum DEGIL -- topluluk
# kaynakli bir workaround, Streamlit altyapisi degisirse bozulabilir.
# TrendSurf'teki gibi push sonrasi birkac gun canli ortamda uygulamanin
# gercekten uyku ekranina dusup dusmedigi gozlemlenmeli.

import os
import sys

from playwright.sync_api import sync_playwright

APP_URL = os.environ.get("STREAMLIT_APP_URL", "https://menu-muhendisi.streamlit.app")
UYANDIRMA_BUTONU_METNI = "Yes, get this app back up!"


def main():
    with sync_playwright() as p:
        tarayici = p.chromium.launch(headless=True)
        sayfa = tarayici.new_page()
        try:
            sayfa.goto(APP_URL, wait_until="networkidle", timeout=30000)
        except Exception as e:
            print(f"UYARI: sayfa yuklenirken zaman asimi/hata: {e}")

        try:
            buton = sayfa.get_by_text(UYANDIRMA_BUTONU_METNI, exact=False)
            buton.wait_for(state="visible", timeout=5000)
            buton.click()
            print("Uyku ekrani bulundu, uyandirma butonuna tiklandi.")
            sayfa.wait_for_timeout(8000)  # uygulamanin ayilmasi icin kisa bekleme
        except Exception:
            print("Uyku ekrani gorulmedi -- uygulama zaten uyanik olabilir.")

        tarayici.close()

    print(f"Tamamlandi: {APP_URL} ziyaret edildi.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"HATA: {e}")
        sys.exit(1)
