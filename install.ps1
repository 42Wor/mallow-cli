# install.ps1 (Final Robust Version - No Git Required)

# --- Configuration ---
$ErrorActionPreference = "Stop" 
$OutputEncoding = [System.Text.Encoding]::UTF8
$MALLOW_ENV_DIR = Join-Path $env:LOCALAPPDATA "Mallow"
# The GitHub repository URL now points to the ZIP archive
$REPO_URL = "https://github.com/42Wor/mallow-cli/archive/refs/heads/main.zip"
$LOG_FILE = "mallow-install.log"
# --- End Configuration ---

# --- ASCII Progress Bar Function ---
function Show-AsciiProgressBar {
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.Job]
        $Job
    )

    $duration = 90 
    $width = 40
    $startTime = Get-Date

    while ($Job.State -eq 'Running') {
        $elapsed = (Get-Date) - $startTime
        $percent = [Math]::Min(100, [int](($elapsed.TotalSeconds / $duration) * 100))
        $filledWidth = [int](($width * $percent) / 100)

        $bar = "["
        $bar += "#" * $filledWidth
        if ($filledWidth -lt $width) { $bar += ">" }
        $bar += "-" * ($width - $filledWidth - 1)
        $bar += "]"

        Write-Host "`r$bar $($percent)%" -NoNewline
        Start-Sleep -Milliseconds 200
    }

    $finalBar = "[$(('#' * $width))]"
    Write-Host "`r$finalBar 100% "
}


# --- Main Script ---
Write-Host "Starting Mallow installation via HTTPS..." -ForegroundColor Yellow

# 1. Create virtual environment
if (-not (Test-Path $MALLOW_ENV_DIR)) {
    python -m venv $MALLOW_ENV_DIR > $null
}

# 2. Install the project in a background job from the ZIP URL
$scriptsDir = Join-Path -Path $MALLOW_ENV_DIR -ChildPath "Scripts"
$pip_executable = Join-Path -Path $scriptsDir -ChildPath "pip.exe"

$scriptBlock = {
    param($pip, $url, $log)
    & $pip install --no-input $url > $log 2>&1
}
$installJob = Start-Job -ScriptBlock $scriptBlock -ArgumentList $pip_executable, $REPO_URL, $LOG_FILE

Write-Host "Installing packages..."
Show-AsciiProgressBar -Job $installJob

# 3. Improved Error Checking
Wait-Job $installJob | Out-Null
if ($installJob.State -eq 'Failed') {
    Write-Host "`n[ERROR] Installation failed." -ForegroundColor Red
    Write-Host "Please check the log file for details: '$LOG_FILE'" -ForegroundColor Yellow
    Get-Content $LOG_FILE -Tail 10
    exit 1
} else {
    Write-Host "Packages installed successfully." -ForegroundColor Green
}

# 4. Add to PATH
Write-Host "Adding 'mallow' command to your system PATH..."
try {
    $currentUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (-not ($currentUserPath -like "*$scriptsDir*")) {
        $newPath = "$scriptsDir;$currentUserPath"
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    }
} catch {
    Write-Host "Failed to update PATH automatically. Please add '$scriptsDir' to your PATH environment variable manually." -ForegroundColor Yellow
}

# 5. Final Instructions
Write-Host "`nMallow has been successfully installed!" -ForegroundColor Green
Write-Host "IMPORTANT: You must open a NEW terminal for the 'mallow' command to be available." -ForegroundColor Yellow
Write-Host "This is because the PATH environment variable is only loaded when a new terminal starts."
Write-Host "Once in a new terminal, you can run commands like: mallow list"