wpeinit
wpeutil InitializeKeyboard
wpeutil SetKeyboardLayout 040c:0000040c
wpeutil InitializeNetwork
ipconfig /renew
timeout /t 5
:: --- OPTIMISATION DE LA PILE RESEAU SMB ---
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxCmds" /t REG_DWORD /d 100 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "MaxThreads" /t REG_DWORD /d 100 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "KeepConn" /t REG_DWORD /d 86400 /f >nul

:: --- OPTIMISATION DES FLUX TCP (SI LE MATERIEL LE SUPPORTE) ---
netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global heuristics=disabled >nul


@echo off
cls
echo ==========================================
echo    CONNEXION RESEAU - BARRIEN PXE
echo ==========================================
echo.

:: Demande le nom d'utilisateur dans la console noire
set /p "winuser=Entrez le nom d'utilisateur : "
set /P "domainuser=Entrer le Domaine de l'utilisateur : "
@echo on
echo.
REM echo Veuillez entrer le mot de passe pour %domainuser%\%winuser% :
:: Le '*' force Windows à demander le mot de passe de manière sécurisée (masquée)
net use z: \\192.168.100.46\Barrien_PXE * /user:%domainuser%\%winuser% /persistent:no


start Z:\SCRIPT\INSTALL_PXE.cmd

