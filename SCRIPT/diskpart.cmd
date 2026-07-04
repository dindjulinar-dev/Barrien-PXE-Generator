diskpart /s Z:\SCRIPT\diskpart.txt

timeout /t 1

diskpart
select disk 0
clean
convert gpt
create partition efi size=100
format fs=fat32 quick label="EFI"
assign letter=S
create partition msr size=16
create partition primary
format fs=ntfs quick label="Windows"
assign letter=C
create partition primary size=1024
format fs=ntfs quick label="Recovery"
assign letter=R



exit