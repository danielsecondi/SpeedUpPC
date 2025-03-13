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
fsutil behavior set DisableDeleteNotify 1
bcdedit /timeout 3
chkdsk /f /r