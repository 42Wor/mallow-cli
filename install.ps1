# Mallow Installer Script for Windows (PowerShell)
# ------------------------------------------------

# --- Configuration ---
$RepoUrl = "https://github.com/42Wor/mallow-cli.git"
$InstallDir = "$env:USERPROFILE\.mallow\app"

# --- Pacman Animation Function ---
function Show-PacmanAnimation {
    param(
        [string]$Message
    )
    $frames = @("( o< )", "(  < )", "( <  )", "(<   )", "(   <)", "(  < )")
    $duration = 3 # seconds
    
    Write-Host ""
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    while ($stopwatch.Elapsed.TotalSeconds -lt $duration) {
        foreach ($frame in $frames) {
            Write-Host -NoNewline "`r$frame $Message"
            Start-Sleep -Milliseconds 100
        }
    }
    Write-Host "`r" # Clear the line
    Write-Host "✔ Done!" -ForegroundColor Green
}

# --- Header Function ---
function Show-Header {
    Clear-Host
    $art = @"
  __  __       _          _ _ 
 |  \/  | __ _(_)_ __    | | |
 | |\/| |/ _` | | '_ \   | | |
 | |  | | (_| | | | | |  |_|_|
 |_|  |_|\__,_|_|_| |_|  (_|_)

"@
    Write-Host $art -ForegroundColor Green
    Write-Host "Welcome to the Mallow Installer! 🍬" -ForegroundColor Yellow
    Write-Host ""
}

# --- Main Script ---
Show-Header
Write-Host "This script will download and install Mallow on your system."

# 2. Check Dependencies
Write-Host "[INFO] Checking for required tools (git, python, pip)..."
$gitExists = Get-Command git -ErrorAction SilentlyContinue
$pythonExists = Get-Command python -ErrorAction SilentlyContinue

if (-not $gitExists) {
    Write-Host "[ERROR] Git is not installed or not in your PATH. Please install it first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
if (-not $pythonExists) {
    Write-Host "[ERROR] Python is not installed or not in your PATH. Please install it first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[INFO] All dependencies found."

# 3. Clone Repository
Show-PacmanAnimation "Downloading Mallow from GitHub..."
if (Test-Path $InstallDir) {
    Write-Host "[INFO] Removing existing installation..."
    Remove-Item -Recurse -Force -Path $InstallDir
}
git clone --depth 1 $RepoUrl $InstallDir

# 4. Install Python Dependencies
Write-Host "[INFO] Installing required Python packages..."
Set-Location $InstallDir
pip install -r requirements.txt

# 5. Create the Launcher and Add to PATH
Write-Host "[INFO] Creating the 'mallow' command..."
$launcherContent = "@echo off`r`npython `"%~dp0mallow.py`" %*"
Set-Content -Path (Join-Path $InstallDir "mallow.bat") -Value $launcherContent

Write-Host "[INFO] Adding Mallow to your user PATH..."
$currentUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($currentUserPath -like "*$InstallDir*")) {
    $newPath = $currentUserPath + ";" + $InstallDir
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
}

# 6. Success Message
Show-Header
Write-Host "-------------------------------------------" -ForegroundColor Green
Write-Host "  Mallow has been successfully installed!  " -ForegroundColor Green
Write-Host "-------------------------------------------" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: You must CLOSE this terminal and OPEN a NEW one" -ForegroundColor Yellow
Write-Host "for the 'mallow' command to be available." -ForegroundColor Yellow
Write-Host ""
Write-Host "In your new terminal, you can run:"
Write-Host ""
Write-Host "  mallow list" -ForegroundColor Cyan
Write-Host ""
Write-Host "Enjoy your soft-serve AI! ✨"
Read-Host "Press Enter to exit"