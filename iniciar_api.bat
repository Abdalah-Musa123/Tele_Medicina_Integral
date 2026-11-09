@echo off
cd /d "%~dp0api"
if not exist node_modules call npm install
call npm start
pause
