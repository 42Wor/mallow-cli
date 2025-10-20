@echo off
REM This script is a launcher for the more powerful PowerShell installer.

REM Finds the directory where this .bat file is located and calls the .ps1 script from there.
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"

pause