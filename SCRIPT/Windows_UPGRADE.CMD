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



echo ==========================================
echo 	Barrien PXE GENERATOR (v2.1) WinPE
echo ==========================================
echo.
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo
echo ==========================================
echo             QUEL OS CHOISIR :
echo ==========================================
echo.

echo Liste des isos disponible :
Dir /B Z:\Sources
echo 															_
set /p I_INS=Choisisser l'iso d'installation (Nom complet) : 
echo off l'iso sélectionner est %i_ins% ?

start Z:\sources\%I_INS%\setup.exe /unattend:z:\Sources\%I_INS%\autounattend.xml /auto upgrade /eula accept