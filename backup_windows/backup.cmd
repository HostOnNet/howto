# Backup runes daily at 10 AM

robocopy.exe D:\os\firefox_profile\ I:\backup_drive_d\os\firefox_profile\ /R:1 /MIR
robocopy.exe D:\ I:\backup_drive_d /R:2 /XD "D:\System Volume Information" d:\os d:\RECYCLER D:\$RECYCLE.BIN /MIR
robocopy.exe C:\Windows\System32\drivers\etc\ I:\backup_others\etc\ /R:2 /MIR
REGEDIT.EXE /E D:\programs\putty_backup.reg "HKEY_CURRENT_USER\Software\SimonTatham"
echo %date% - %time% - Backup Complete >> D:\backup_log.txt
