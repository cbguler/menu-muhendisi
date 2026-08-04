@echo off
REM Bu dosyayi calistirmadan once asagidaki iki satiri kendi Supabase
REM bilgilerinle DOLDUR (Settings > API Keys > Legacy anon, service_role
REM API keys sekmesinden service_role'u, Integrations > Data API'den
REM Project URL'i al).

set SUPABASE_URL=BURAYA_PROJECT_URL_YAPISTIR
set SUPABASE_SERVICE_ROLE_KEY=BURAYA_SERVICE_ROLE_KEY_YAPISTIR

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
