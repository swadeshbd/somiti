@echo off
echo ====================================================
echo Starting Microcredit Mobile App on Chrome / Web...
echo ====================================================
cd mobile_app
call flutter pub get
echo.
echo Launching App in Chrome Browser...
call flutter run -d chrome
pause
