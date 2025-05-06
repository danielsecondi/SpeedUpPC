@echo off
title SpeedUpPC
chcp 65001 >nul
cls

:: Verifica permessi amministrativi
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Esegui questo programma come amministratore.
    pause
    exit /b
)

:: Avvio script PowerShell
echo Avvio di SpeedUpPC...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0SpeedUpPC.ps1"
