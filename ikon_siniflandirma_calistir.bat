@echo off
echo Gemini ve Supabase paketleri kontrol ediliyor / kuruluyor...
pip install google-genai --quiet
pip install supabase --quiet

if "%GEMINI_API_KEY%"=="" (
    echo.
    echo HATA: GEMINI_API_KEY bulunamadi.
    echo aistudio.google.com'dan ucretsiz bir anahtar al, sonra
    echo "setx GEMINI_API_KEY <anahtarin>" komutunu BIR KEZ calistirip,
    echo terminali kapatip yeniden acman gerekiyor.
    pause
    exit /b 1
)

if "%SUPABASE_URL%"=="" (
    echo.
    echo HATA: SUPABASE_URL bulunamadi.
    echo Supabase projenin Settings -^> API sayfasindan "Project URL"
    echo degerini al, "setx SUPABASE_URL <url>" ile BIR KEZ kaydet,
    echo terminali kapatip yeniden ac.
    pause
    exit /b 1
)

if "%SUPABASE_SERVICE_ROLE_KEY%"=="" (
    echo.
    echo HATA: SUPABASE_SERVICE_ROLE_KEY bulunamadi.
    echo Supabase projenin Settings -^> API sayfasindan "service_role"
    echo anahtarini al ^(ANON anahtari DEGIL^), "setx SUPABASE_SERVICE_ROLE_KEY <anahtar>"
    echo ile BIR KEZ kaydet, terminali kapatip yeniden ac.
    echo BU ANAHTAR COK GIZLI -- kimseyle paylasma, hicbir dosyaya yazma.
    pause
    exit /b 1
)

echo.
echo Siniflandirma basliyor -- Gemini'nin ucretsiz katmani cok daha
echo yuksek limitli oldugu icin muhtemelen tek calistirmada bitecek...
echo.

python ikon_siniflandirma_calistir.py

echo.
echo ============================================
echo Islem tamamlandi. Yukaridaki sonuclara bak.
echo ============================================
pause
