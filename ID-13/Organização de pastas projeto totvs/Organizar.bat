@echo off
REM Wrapper ASCII puro - apenas invoca o PowerShell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Organizar.ps1"
