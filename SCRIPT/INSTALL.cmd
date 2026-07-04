echo === Lancement de l'installation locale ===
Z:\sources\%I_INS%\setup.exe /unattend:z:\Sources\%I_INS%\autounattend.xml  /installfrom:Z:\Sources\%I_INS%\sources\install.wim




REM Liste des argument pouvant être utiliser :
REM > /installfrom:z:\Sources\%I_INS%\sources\install.wim
REM > /product server 
REM > /unattend:z:\Sources\%I_INS%\autounattend.xml 

REM rd /s /q "Z:\$WINDOWS.~BT"
REM rd /s /q "Z:\ProgramData"


exit