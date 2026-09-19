@echo off
REM Bu dosyayi calistirmadan once asagidaki iki satiri kendi Supabase
REM bilgilerinle DOLDUR (Settings > API Keys > Legacy anon, service_role
REM API keys sekmesinden service_role'u, Integrations > Data API'den
REM Project URL'i al).

set SUPABASE_URL=https://jdjzjtoprgvkanozpkey.supabase.co
set SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpkanpqdG9wcmd2a2Fub3pwa2V5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NTQxMDYzMiwiZXhwIjoyMTAwOTg2NjMyfQ.m4I4Gul081I_aV2E6yQaKXlNSBVxXE9zN2wdWaq3S3o

set PY="C:\Users\bahri\AppData\Local\Programs\Python\Python312\python.exe"
chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

cd /d "%~dp0"
set LOGFILE=%TEMP%\talimat_yukle_log.txt
taskkill /f /im notepad.exe >nul 2>&1
del /f /q "%LOGFILE%" 2>nul
echo ===== talimat_yukle.py calistiriliyor ===== > "%LOGFILE%"
%PY% talimat_yukle.py >> "%LOGFILE%" 2>&1
echo ===== BITTI (cikis kodu: %errorlevel%) ===== >> "%LOGFILE%"

notepad "%LOGFILE%"
