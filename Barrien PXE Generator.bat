call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

@echo off

echo ██████╗  █████╗ ██████╗ ██████╗ ██╗███████╗███╗   ██╗
echo ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║██╔════╝████╗  ██║
echo ██████╔╝███████║██████╔╝██████╔╝██║█████╗  ██╔██╗ ██║
echo ██╔══██╗██╔══██║██╔══██╗██╔══██╗██║██╔══╝  ██║╚██╗██║
echo ██████╔╝██║  ██║██║  ██║██║  ██║██║███████╗██║ ╚████║
echo ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═══╝

@echo on

ping 127.0.0.1

mkdir C:\SCRIPT
mkdir C:\SCRIPT\ISO


cd "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"

echo creation de l'environnement de creation du WinPE

if exist C:\winpe64 (
    echo Le dossier C:\winpe64 existe, suppression...
    rmdir /s /q C:\winpe64
)
copype.cmd amd64 C:\winpe64


echo Resoudre l’erreur 0xc1420127
dism /get-mountedwiminfo
dism /cleanup-wim
dism /unmount-wim
dism /cleanup-wim

echo Monter le boot.wim
dism /mount-image /imagefile:C:\winpe64\media\sources\boot.wim /index:1 /mountdir:C:\winpe64\mount


echo Copier startnet.cmd
copy /y C:\SCRIPT\startnet.cmd C:\winpe64\mount\Windows\System32\

echo Copier install.cmd
copy /y C:\SCRIPT\install.cmd C:\winpe64\mount\Windows\System32\

echo Copier diskpart.cmd
copy /y C:\SCRIPT\diskpart.cmd C:\winpe64\mount\Windows\System32\

echo Ajout du pack de langue FR
Dism /image:C:\winpe64\mount /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\fr-fr\lp.cab"
Dism /image:C:\winpe64\mount /Add-Package /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\fr-fr\WinPE-FontSupport-FR-FR.cab"

echo Commit et demontage
dism /unmount-wim /mountdir:C:\winpe64\mount /commit

echo Resoudre l’erreur 0xc1420127
dism /get-mountedwiminfo
dism /cleanup-wim
dism /unmount-wim
dism /cleanup-wim

echo Creation de l'ISO WinPE
MakeWinPEMedia /ISO C:\winpe64 C:\winpe64\WinPE.iso

pause

