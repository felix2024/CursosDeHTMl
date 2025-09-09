@echo off
cd /d %~dp0
git add .
set /p commitmsg=Mensaje del commit:
git commit -m "%commitmsg%"
git push origin master
pause   