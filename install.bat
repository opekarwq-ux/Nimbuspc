@echo off
copy /Y "C:\OEM\wallpaper.jpg" "C:\Windows\Web\Wallpaper\nimbus.jpg"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /t REG_SZ /d "C:\Windows\Web\Wallpaper\nimbus.jpg" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v WallpaperStyle /t REG_SZ /d 10 /f
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\OEM\setup.ps1"
