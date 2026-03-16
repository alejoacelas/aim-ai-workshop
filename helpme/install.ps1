# install-helpme.ps1 — one-line installer for the helpme CLI (Windows/PowerShell)
# Usage: irm https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/install.ps1 | iex

$ErrorActionPreference = "Stop"

# TLS 1.2 — PowerShell 5.1 defaults to TLS 1.0, which many endpoints reject
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$BinDir = "$env:USERPROFILE\.local\bin"
$ScriptUrl = "https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/helpme.ps1"
$ScriptPath = "$BinDir\helpme.ps1"
$OldCmdWrapper = "$BinDir\helpme.cmd"

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

# 3. Remove old .cmd wrapper if it exists (replaced by profile function)
if (Test-Path $OldCmdWrapper) {
    Remove-Item $OldCmdWrapper -Force
}

# 4. Add helpme function to PowerShell profile
# This avoids the cmd.exe .cmd wrapper which mangles special characters in arguments
$ProfileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Force -Path $PROFILE | Out-Null
}

$FunctionBlock = @"

# helpme CLI — workshop troubleshooting tool
function helpme { & "$ScriptPath" @args }
"@

$ProfileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if (-not $ProfileContent -or $ProfileContent -notmatch "function helpme") {
    Add-Content -Path $PROFILE -Value $FunctionBlock -Encoding UTF8
    $ProfileUpdated = $true
} else {
    $ProfileUpdated = $false
}

# Define in current session so it works immediately
Invoke-Expression "function helpme { & `"$ScriptPath`" @args }"

# 5. Add bin dir to PATH (useful for other tools, not strictly needed for helpme)
$CurrentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$PathEntries = $CurrentUserPath -split ";"
if ($PathEntries -notcontains $BinDir) {
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$CurrentUserPath", "User")
    $env:Path = "$BinDir;$env:Path"
    $PathAdded = $true
} else {
    $PathAdded = $false
    if (($env:Path -split ";") -notcontains $BinDir) {
        $env:Path = "$BinDir;$env:Path"
    }
}

# 6. Success message
Write-Host ""
Write-Host "helpme installed successfully!" -ForegroundColor Green
Write-Host ""

if ($ProfileUpdated) {
    Write-Host "Added helpme to your PowerShell profile." -ForegroundColor DarkGray
    Write-Host "It works now. Future PowerShell windows will load it automatically." -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "Try it: " -ForegroundColor DarkGray -NoNewline
Write-Host "helpme -- echo 'hello world'"
Write-Host ""
