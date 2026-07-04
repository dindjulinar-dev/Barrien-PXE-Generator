@echo off
set ISO_FILE=C:\Barrien_APPs\Barrien\Sources

set /p ISO_NAME="Nom de l'OS / ISO (Sans espaces): "
set /p ISO_PATCH="Chemin complet du dossier ISO extrait: "

echo Le nom de l'ISO sélectionné est : %ISO_NAME%
timeout /t 3

echo === Création du dossier de destination ===
mkdir "%ISO_FILE%\%ISO_NAME%"

echo === Copie de l'ISO extrait dans le serveur ===
robocopy "%ISO_PATCH%" "%ISO_FILE%\%ISO_NAME%" /MIR

REM echo === Vérification du WIM ===
REM if exist "%ISO_FILE%\%ISO_NAME%\sources\install.swm" (
    REM echo Les fichiers SWM existent déjà, pas de split nécessaire.
REM ) else (
    REM echo Split du WIM en cours...
    REM dism /split-image /imagefile:"%ISO_FILE%\%ISO_NAME%\sources\install.wim" ^
         REM /swmfile:"%ISO_FILE%\%ISO_NAME%\sources\install.swm" /filesize:512
REM )

echo === Importation de l'autounattend.xml ===
copy "%~dp0UNATTEND\autounattend.xml" "%ISO_FILE%\%ISO_NAME%\autounattend.xml" /Y

echo === Importation du script INSTALL.cmd ===
copy "%~dp0SCRIPT\INSTALL.cmd" "%ISO_FILE%\%ISO_NAME%\INSTALL.cmd" /Y

echo === Importation du script PRE-SPLIT.CMD ===
copy "%~dp0SCRIPT\PRE-SPLIT.CMD" "%ISO_FILE%\%ISO_NAME%\PRE-SPLIT.CMD" /Y

echo === Importation terminée ===
timeout /t 3
