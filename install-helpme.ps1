# install-helpme.ps1 — one-line installer for the helpme CLI (Windows)
# Usage: irm https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/install-helpme.ps1 | iex

$ErrorActionPreference = "Stop"

$BinDir = "$env:USERPROFILE\.local\bin"
$ScriptUrl = "https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme.ps1"
$ScriptPath = "$BinDir\helpme.ps1"
$CmdWrapper = "$BinDir\helpme.cmd"

Write-Host ""
Write-Host "Installing helpme..."

# 1. Create bin directory
if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
}

# 2. Download helpme.ps1
try {
    Invoke-WebRequest -Uri $ScriptUrl -OutFile $ScriptPath -UseBasicParsing
} catch {
    Write-Host ""
    Write-Host "Download failed." -ForegroundColor Yellow
    Write-Host "  If you're on a corporate network, the download URL might be blocked."
    Write-Host "  Ask a workshop organizer for the file directly."
    exit 1
}

# 3. Create a .cmd wrapper so "helpme" works from any shell without execution policy issues
@"
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0helpme.ps1" %*
"@ | Set-Content -Path $CmdWrapper -Encoding ASCII

# 4. Add to PATH if not already there
$CurrentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentUserPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$CurrentUserPath", "User")
    # Also update current session
    $env:Path = "$BinDir;$env:Path"
    $PathAdded = $true
} else {
    $PathAdded = $false
    # Make sure current session has it too
    if ($env:Path -notlike "*$BinDir*") {
        $env:Path = "$BinDir;$env:Path"
    }
}

# 5. Success message
Write-Host ""
Write-Host "helpme installed successfully!" -ForegroundColor Green
Write-Host ""

if ($PathAdded) {
    Write-Host "~\.local\bin was added to your PATH." -ForegroundColor DarkGray
    Write-Host "Open a new PowerShell window for the change to take effect." -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "Try it: " -ForegroundColor DarkGray -NoNewline
Write-Host "helpme -- echo 'hello world'"
Write-Host ""
