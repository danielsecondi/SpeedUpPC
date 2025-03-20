@echo off
title Ottimizzazione e Pulizia del Sistema
chcp 65001 >nul
cls

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Esegui questo programma come amministratore.
    pause
    exit /b
)

echo ============================================
echo  INIZIO PROCEDURA DI PULIZIA E OTTIMIZZAZIONE
echo ============================================
timeout /t 2 >nul

:: Controllo e riparazione componenti di Windows
echo [1/10] Controllo e riparazione componenti di Windows...
dism /online /Cleanup-Image /RestoreHealth
sfc /scannow

:: Pulizia file temporanei
echo [2/10] Eliminazione file temporanei...
taskkill /IM explorer.exe /F >nul 2>&1
del /s /q %temp%\* >nul 2>&1
del /s /q C:\Windows\Temp\* >nul 2>&1
del /s /q C:\Windows\Prefetch\* >nul 2>&1
rd /s /q %systemdrive%\$Recycle.Bin >nul 2>&1
start explorer.exe

:: Pulizia disco
echo [3/10] Avvio pulizia disco...
cleanmgr /verylowdisk

:: Pulizia cache DNS e reset rete
echo [4/10] Pulizia cache DNS e reset rete...
ipconfig /flushdns
netsh int ip reset >nul
netsh winsock reset >nul

cls
echo [5/10] Controllo del tipo di disco...
PowerShell -Command "$diskType = (Get-PhysicalDisk | Where-Object { $_.DeviceID -eq 0 }).MediaType; if ($diskType -eq 'HDD') { exit 1 } else { exit 0 }"
if %errorlevel%==1 (
    echo HDD rilevato, avvio deframmentazione...
    defrag C: /O
) else (
    echo SSD rilevato, avvio ottimizzazione...
    PowerShell -Command "Optimize-Volume -DriveLetter C -ReTrim"
)

:: Verifica ed abilitazione TRIM
echo [6/10] Verifica ed abilitazione TRIM...
PowerShell -Command "if ((fsutil behavior query DisableDeleteNotify) -match '0') { echo TRIM gia\' attivato. } else { fsutil behavior set DisableDeleteNotify 0; echo TRIM abilitato! }"

:: Riduzione tempo di avvio
echo [7/10] Riduzione tempo di avvio...
bcdedit /timeout 3 >nul 2>&1

:: Verifica del disco
echo [8/10] Verifica del disco...
chkdsk /scan

cls
echo ========================================================
echo  LA PULIZIA E OTTIMIZZAZIONE È COMPLETATA
echo  RIAVVIA IL SISTEMA PER APPLICARE LE MODIFICHE
echo ========================================================
pause
exit
