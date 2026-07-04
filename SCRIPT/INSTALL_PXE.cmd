@echo off

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


wpeutil InitializeKeyboard
wpeutil SetKeyboardLayout 040c:0000040c
wpeutil InitializeNetwork
wpeutil UpdateBootInfo
wpeutil IsUEFI
ping 127.0.0.1
ipconfig


echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_
echo 															_


echo
echo ==========================================
echo 		Installation de %i_ins% :
echo ==========================================
echo.

@echo on

diskpart /s Z:\SCRIPT\diskpart.txt

echo start z:\Sources\%I_INS%\INSTALL.CMD
start z:\Sources\%I_INS%\INSTALL.CMD
