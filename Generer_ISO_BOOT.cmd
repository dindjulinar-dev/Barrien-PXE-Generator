@echo off
set SERVER=C:\Barrien_APPs\
REM set /p SERVER="Entrez le chemin du serveur : "
REM echo Vous avez choisi d'installer le server a : %SERVER%
REM timeout /t 10

:: Création du dossier destination si besoin
mkdir "%SERVER%\Barrien\SCRIPT" 2>nul
mkdir "%SERVER%\Barrien\SCRIPT\ISO" 2>nul
mkdir "%server%\Barrien\UNATTEND_response_file"
:: Copie du fichier


copy "%~dp0SCRIPT\INSTALL.cmd" "%SERVER%\Barrien\SCRIPT\INSTALL.cmd" /Y
copy "%~dp0SCRIPT\Windows_UPGRADE.CMD" "%SERVER%\Barrien\SCRIPT\Windows_UPGRADE.CMD" /Y
copy "%~dp0SCRIPT\diskpart.txt" "%SERVER%\Barrien\SCRIPT\diskpart.txt" /Y
copy "%~dp0SCRIPT\cscript.exe" "%SERVER%\Barrien\SCRIPT\cscript.exe" /Y
copy "%~dp0UNATTEND_response_file\unattend.xml" "%SERVER%\Barrien\UNATTEND_response_file\unattend.xml" /Y
copy "%~dp0SCRIPT\diskpart.cmd" "%SERVER%\Barrien\SCRIPT\diskpart.cmd" /Y
copy "%~dp0SCRIPT\INSTALL_PXE.cmd" "%SERVER%\Barrien\SCRIPT\INSTALL_PXE.cmd" /Y
copy "%~dp0SCRIPT\startnet.cmd" "%SERVER%\Barrien\SCRIPT\startnet.cmd" /Y
copy "%~dp0SCRIPT\Diskpart.txt" "%SERVER%\Barrien\SCRIPT\Diskpart.txt" /Y
copy "%~dp0IMPORT_ISO.bat" "%SERVER%\Barrien\IMPORT_ISO.bat" /Y
copy "%~dp0Generer_ISO_BOOT.cmd" "%SERVER%\Barrien\Generer_ISO_BOOT.cmd" /Y
copy "%~dp0SCRIPT\winpe.jpg" "%SERVER%\Barrien\SCRIPT\winpe.jpg" /Y


net share Barrien_PXE="C:\Barrien_APPs\Barrien" /grant:"Tout le monde",FULL



echo Chemin : "%SERVER%\Barrien"
if not exist "%SERVER%\Barrien" echo --> Le dossier n'existe pas !







dism /Unmount-Image /MountDir:C:\winpe64\mount /Discard

title Barrien ISO Generator
echo.
echo ==========================================
echo 	Barrien PXE GENERATOR (v2.1) SETUP
echo ==========================================
echo.
timeout /t 5

:: Verification admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Executer en tant qu'administrateur.
    pause
    exit /b 1
)

set ADK=C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit
set DTOOLS=%ADK%\Deployment Tools
set COPYPE="%ADK%\Windows Preinstallation Environment\copype.cmd"
set MAKEMEDIA="%ADK%\Windows Preinstallation Environment\MakeWinPEMedia.cmd"

:: [1] Nettoyage DISM
echo [1/7] Nettoyage DISM...
dism /cleanup-wim >nul 2>&1
echo  OK

:: [2] Suppression ancienne session
echo [2/7] Preparation C:\winpe64...
if exist C:\winpe64 (
    echo  Suppression ancien C:\winpe64...
    rmdir /s /q C:\winpe64
)
echo  OK

:: [3] copype avec chemin complet + PATH ADK
echo [3/7] Creation environnement WinPE...
call "%DTOOLS%\DandISetEnv.bat" >nul 2>&1
call %COPYPE% amd64 C:\winpe64
if not exist C:\winpe64\media\sources\boot.wim (
    echo [ERREUR] copype a echoue - boot.wim introuvable
    pause
    exit /b 1
)
echo  OK - C:\winpe64 cree

:: [4] Montage boot.wim
echo [4/7] Montage boot.wim...
dism /mount-image /imagefile:C:\winpe64\media\sources\boot.wim /index:1 /mountdir:C:\winpe64\mount
if %errorlevel% neq 0 (
    echo [ERREUR] Montage DISM echoue
    dism /cleanup-wim
    pause
    exit /b 1
)
echo  OK - monte
:: [5] Copie scripts
echo [5/7] Copie scripts et bypass du fond d'écran...

:: On force d'abord l'attribution des droits sur TOUT le dossier System32 du montage pour les administrateurs locaux
icacls "C:\winpe64\mount\Windows\System32" /grant administrators:(OI)(CI)F /T /C >nul 2>&1

if exist "C:\Barrien_APPs\Barrien\SCRIPT\startnet.cmd" copy /y "C:\Barrien_APPs\Barrien\SCRIPT\startnet.cmd" "C:\winpe64\mount\Windows\System32\" >nul
if exist "C:\Barrien_APPs\Barrien\SCRIPT\cscript.exe" copy /y "C:\Barrien_APPs\Barrien\SCRIPT\cscript.exe" "C:\winpe64\mount\Windows\System32\" >nul
if exist "C:\Barrien_APPs\Barrien\SCRIPT\INSTALL_PXE.cmd" copy /y "C:\Barrien_APPs\Barrien\SCRIPT\INSTALL_PXE.cmd" "C:\winpe64\mount\Windows\System32\" >nul
if exist "C:\Barrien_APPs\Barrien\SCRIPT\diskpart.cmd" copy /y "C:\Barrien_APPs\Barrien\SCRIPT\diskpart.cmd" "C:\winpe64\mount\Windows\System32\" >nul

:: Bypass TrustedInstaller sur winpe.jpg par suppression brute des permissions héritées
if exist "C:\Barrien_APPs\Barrien\SCRIPT\winpe.jpg" (
    icacls "C:\winpe64\mount\Windows\System32\winpe.jpg" /reset >nul 2>&1
    icacls "C:\winpe64\mount\Windows\System32\winpe.jpg" /grant administrators:F >nul 2>&1
    del /f /q /a "C:\winpe64\mount\Windows\System32\winpe.jpg" >nul 2>&1
    copy /y "C:\Barrien_APPs\Barrien\SCRIPT\winpe.jpg" "C:\winpe64\mount\Windows\System32\winpe.jpg" >nul
)
echo  OK

set WINPEOCS=C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs
Dism /Image:"C:\winpe64\mount" /Add-Package /PackagePath:"%WINPEOCS%\fr-fr\lp.cab"
Dism /Image:"C:\winpe64\mount" /Add-Package /PackagePath:"%WINPEOCS%\WinPE-FontSupport-FR-FR.cab"
Dism /Image:"C:\winpe64\mount" /Add-Package /PackagePath:"%WINPEOCS%\WinPE-Setup-FR-FR.cab"
Dism /Image:"C:\winpe64\mount" /Add-Package /PackagePath:"%WINPEOCS%\WinPE-Setup-Client-FR-FR.cab"
Dism /Image:"C:\winpe64\mount" /Add-Package /PackagePath:"%WINPEOCS%\WinPE-Setup-Server-FR-FR.cab"
Dism /Image:"C:\winpe64\mount" /Set-AllIntl:fr-FR
Dism /Image:"mount" /Add-Package /PackagePath:"WinPE-WMI.cab"
Dism /Image:"mount" /Add-Package /PackagePath:"WinPE-Scripting.cab"
Dism /Image:"mount" /Add-Package /PackagePath:"WinPE-HTA.cab"
Dism /Image:"mount" /Add-Package /PackagePath:"WinPE-Legacy.cab"
Dism /Image:"mount" /Add-Package /PackagePath:"WinPE-XML.cab"
Dism /Add-Package /Image:"C:\WinPE_mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
Dism /Image:"mount" /Add-Driver /Driver:"Drivers\NIC" /Recurse
Dism /Image:"mount" /Add-Driver /Driver:"Drivers\NVMe" /Recurse

:: Ajout de la prise en change de GUI
dism /Image:"C:\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"

dism /Image:"C:\mount" /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"

:: [5b] Copie ISO Windows
echo [5b/7] Copie ISO depuis C:\SCRIPT\ISO...
if exist C:\SCRIPT\ISO\ (
    if not exist C:\winpe64\media\Windows\ mkdir C:\winpe64\media\Windows\
    xcopy C:\SCRIPT\ISO\* C:\winpe64\media\Windows\ /E /H /K /Y /Q
    echo  OK
) else (
    echo  AVERTISSEMENT : C:\SCRIPT\ISO\ vide ou absent
)

:: [5d] Remplacement forcé du fond d'écran (Bypass TrustedInstaller)
echo [5d/7] Remplacement du fond d'écran winpe.jpg...
if exist "C:\Barrien_APPs\Barrien\SCRIPT\winpe.jpg" (
    :: 1. Prendre la propriété du fichier (équivalent de l'étape 1.c de ta doc)
    takeown /f "C:\winpe64\mount\Windows\System32\winpe.jpg" /a >nul 2>&1
    
    :: 2. Accorder l'accès complet au groupe Administrateurs (étape 1.f de ta doc)
    icacls "C:\winpe64\mount\Windows\System32\winpe.jpg" /grant:r *S-1-5-32-544:F >nul 2>&1
    
    :: 3. Supprimer l'attribut lecture seule au cas où
    attrib -r -s -h "C:\winpe64\mount\Windows\System32\winpe.jpg" >nul 2>&1
    
    :: 4. Remplacer le fichier (étape 2 de ta doc)
    copy /y "C:\Barrien_APPs\Barrien\SCRIPT\winpe.jpg" "C:\winpe64\mount\Windows\System32\winpe.jpg" /Y
)
echo  OK

:: [6] Commit et demontage
echo [6/7] Commit et demontage...
dism /unmount-wim /mountdir:C:\winpe64\mount /commit
if %errorlevel% neq 0 (
    echo [ERREUR] Commit echoue
    dism /cleanup-wim
    pause
    exit /b 1
)
dism /cleanup-wim >nul 2>&1
echo  OK

:: [7] Creation ISO
echo [7/7] Creation ISO finale...
call %MAKEMEDIA% /ISO C:\winpe64 C:\winpe64\WinPE.iso
if %errorlevel% neq 0 (
    echo [ERREUR] MakeWinPEMedia a echoue
    pause
    exit /b 1
)

echo.
echo ========================================
echo  ISO creee : C:\winpe64\WinPE.iso
echo ========================================
echo.
copy C:\winpe64\media\sources\boot.wim C:\Barrien_APPs\Barrien\boot.wim
copy C:\winpe64\WinPE.iso C:\Barrien_APPs\Barrien\WinPE.iso

echo ========================================
echo  ISO creee : C:\%SERVER%\WinPE.iso
echo ========================================
echo.
timeout /t 10
exit
