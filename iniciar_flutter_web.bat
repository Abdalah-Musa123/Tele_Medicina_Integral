@echo off
cd /d "%~dp0"
if not exist web flutter create . --platforms=web,android
call flutter pub get
call flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
pause
