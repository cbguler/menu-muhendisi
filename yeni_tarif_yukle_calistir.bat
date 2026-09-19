@echo off
REM Bu dosyayi calistirmadan once asagidaki iki satiri kendi Supabase
REM bilgilerinle DOLDUR (Settings > API sayfasindan al):
REM   - SUPABASE_URL: Project URL (....supabase.co ile biter, streamlit.app DEGIL)
REM   - SUPABASE_SERVICE_ROLE_KEY: "service_role" anahtari (anon degil!)

set SUPABASE_URL=https://jdjzjtoprgvkanozpkey.supabase.co/
set SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpkanpqdG9wcmd2a2Fub3pwa2V5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NTQxMDYzMiwiZXhwIjoyMTAwOTg2NjMyfQ.m4I4Gul081I_aV2E6yQaKXlNSBVxXE9zN2wdWaq3S3o

set PY="C:\Users\bahri\AppData\Local\Programs\Python\Python312\python.exe"
chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

cd /d "%~dp0"
set LOGFILE=%TEMP%\yukle_yeni_tarifler_log.txt
taskkill /f /im notepad.exe >nul 2>&1
del /f /q "%LOGFILE%" 2>nul
echo ===== yukle_yeni_tarifler.py calistiriliyor ===== > "%LOGFILE%"
%PY% yukle_yeni_tarifler.py >> "%LOGFILE%" 2>&1
echo ===== BITTI (cikis kodu: %errorlevel%) ===== >> "%LOGFILE%"

notepad "%LOGFILE%"
