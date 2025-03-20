@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Esegui questo programma come amministratore.
    pause
    exit /b
)

dism /online /Cleanup-Image /RestoreHealth
sfc /scannow
del /s /q %temp%\*
del /s /q C:\Windows\Temp\*
cleanmgr /sagerun:1
ipconfig /flushdns
netsh int ip reset
netsh winsock reset
rd /s /q %systemdrive%\$Recycle.Bin
fsutil behavior set DisableDeleteNotify 0
cls
echo Controllo della tipologia del disco
wmic diskdrive get model, mediatype | find "HDD" >nul
if %errorlevel%==0 (
    echo HDD rilevato, avvio deframmentazione...
    defrag C: /O
) else (
    echo Nessun HDD rilevato, ottimizzazione SSD in corso...
    defrag C: /L
)
pause
del /s /q C:\Windows\Prefetch\*
bcdedit /timeout 5
chkdsk /f /r
cls
echo ===========================================================================
echo  PER COMPLETARE LA PULIZIA E VELOCIZZAZIONE DEL PC BISOGNA RIAVVIARE IL PC
echo ===========================================================================
pause
shutdown -r now