@echo off
echo Groq ve Supabase paketleri kontrol ediliyor / kuruluyor...
pip install groq --quiet
pip install supabase --quiet

if "%GROQ_API_KEY_IKON%"=="" (
    echo.
    echo HATA: GROQ_API_KEY_IKON bulunamadi.
    echo Once "setx GROQ_API_KEY_IKON <anahtarin>" komutunu BIR KEZ
    echo calistirip, terminali kapatip yeniden acman gerekiyor.
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
echo Siniflandirma basliyor -- ilk calistirmada 241 tarifin hepsini
echo isleyecegi icin birkac dakika surebilir, sabirli ol...
echo.

python ikon_siniflandirma_calistir.py

echo.
echo ============================================
echo Islem tamamlandi. Yukaridaki sonuclara bak.
echo ============================================
pause
