@echo off
echo Starting Mallow system installation...

REM Define the hidden system directory for the virtual environment
set "MALLOW_ENV_DIR=%LOCALAPPDATA%\Mallow"

REM 1. Create the virtual environment in the AppData directory
echo Setting up virtual environment in %MALLOW_ENV_DIR%...
if exist "%MALLOW_ENV_DIR%" (
    echo Environment directory already exists. Skipping creation.
) else (
    python -m venv "%MALLOW_ENV_DIR%" >nul
)
echo [OK] Virtual environment ready.

REM 2. Install the project into the new environment
echo Installing Mallow and its dependencies... (This may take a few minutes)

REM Run pip install from the new environment, hiding verbose output
"%MALLOW_ENV_DIR%\Scripts\pip.exe" install -e . >nul 2>nul

if %errorlevel% neq 0 (
    echo [ERROR] Installation failed.
    echo Please run the following command manually to see the error:
    echo "%MALLOW_ENV_DIR%\Scripts\pip.exe" install -e .
    exit /b 1
)
echo [OK] Packages installed successfully.

REM 3. Add the Scripts directory to the user's PATH permanently
echo Adding 'mallow' command to your system PATH...
set "MALLOW_SCRIPTS_DIR=%MALLOW_ENV_DIR%\Scripts"

REM Use setx to permanently modify the user's PATH.
setx PATH "%MALLOW_SCRIPTS_DIR%;%PATH%" >nul

echo [OK] PATH updated.

echo.
echo ^> Mallow has been successfully installed!
echo.
echo IMPORTANT: You must open a NEW terminal window for the 'mallow'
echo command to be available everywhere.
echo.
echo Once in a new terminal, you can run commands like:
echo mallow list
echo.