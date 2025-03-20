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

echo [1/10] Controllo e riparazione componenti di Windows...
dism /online /Cleanup-Image /RestoreHealth
sfc /scannow

echo [2/10] Eliminazione file temporanei...
del /s /q %temp%\* >nul 2>&1
del /s /q C:\Windows\Temp\* >nul 2>&1
del /s /q C:\Windows\Prefetch\* >nul 2>&1
rd /s /q %systemdrive%\$Recycle.Bin >nul 2>&1

echo [3/10] Avvio pulizia disco...
cleanmgr /sagerun:1

echo [4/10] Pulizia cache DNS e reset rete...
ipconfig /flushdns
netsh int ip reset >nul
netsh winsock reset >nul

cls
echo [5/10] Controllo del tipo di disco...
wmic diskdrive get model, mediatype | find "HDD" >nul
if %errorlevel%==0 (
    echo HDD rilevato, avvio deframmentazione...
    defrag C: /O
) else (
    echo SSD rilevato, avvio ottimizzazione...
    defrag C: /L
)

echo [6/10] Verifica ed abilitazione TRIM...
fsutil behavior query DisableDeleteNotify | find "0" >nul
if %errorlevel% neq 0 (
    fsutil behavior set DisableDeleteNotify 0
    echo TRIM abilitato!
) else (
    echo TRIM gia' attivato.
)

echo [7/10] Riduzione tempo di avvio...
bcdedit /timeout 3 >nul 2>&1

echo [8/10] Verifica del disco...
chkdsk /f /r

cls
echo ========================================================
echo  LA PULIZIA E OTTIMIZZAZIONE È COMPLETATA
echo  PER APPLICARE TUTTE LE MODIFICHE È NECESSARIO RIAVVIARE
echo ========================================================
pause
shutdown -r -t 10
exit
