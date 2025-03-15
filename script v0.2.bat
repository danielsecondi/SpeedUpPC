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
fsutil behavior set DisableDeleteNotify 0
bcdedit /timeout 5
chkdsk /f /r
cls
echo ===========================================================================
echo  PER COMPLETARE LA PULIZIA E VELOCIZZAZIONE DEL PC BISOGNA RIAVVIARE IL PC
echo ===========================================================================
pause
shutdown -r now