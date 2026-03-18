#!/usr/bin/env pwsh
# Test suite for install.ps1

$ErrorActionPreference = "Continue"
$InstallScript = Join-Path (Split-Path $PSScriptRoot) "install.ps1"
$LocalHelpme = Join-Path (Split-Path $PSScriptRoot) "helpme.ps1"
$Pass = 0
$Fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) {
        $script:Pass++
        Write-Host "  PASS: $Message" -ForegroundColor Green
    } else {
        $script:Fail++
        Write-Host "  FAIL: $Message" -ForegroundColor Red
    }
}

function New-TempTestDir {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) "helpme_test_$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    return $dir
}

function Run-InstallTest {
    param(
        [string]$FakeHome,
        [string]$FakeProfile,
        [string]$ExtraSetup = ""
    )

    # Escape single quotes for embedding in the command string
    $escapedInstall = $InstallScript -replace "'", "''"
    $escapedHelpme = $LocalHelpme -replace "'", "''"
    $escapedHome = $FakeHome -replace "'", "''"
    $escapedProfile = $FakeProfile -replace "'", "''"

    $cmd = @"
`$ErrorActionPreference = 'Stop'
`$env:USERPROFILE = '$escapedHome'
`$global:PROFILE = '$escapedProfile'

# Mock Invoke-WebRequest to copy local file instead of downloading
function global:Invoke-WebRequest {
    param([string]`$Uri, [string]`$OutFile, [switch]`$UseBasicParsing)
    `$dir = Split-Path `$OutFile -Parent
    if (-not (Test-Path `$dir)) { New-Item -ItemType Directory -Path `$dir -Force | Out-Null }
    Copy-Item '$escapedHelpme' -Destination `$OutFile -Force
}

$ExtraSetup

. '$escapedInstall'
"@

    $result = pwsh -Command $cmd 2>&1
    return $result
}

# ============================================================
Write-Host ""
Write-Host "=== install.ps1 test suite ===" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------
# Test 1: Profile doesn't exist -> profile is created with function helpme
# --------------------------------------------------
Write-Host "Test 1: Profile doesn't exist -> creates profile with helpme function"
$tmpDir = New-TempTestDir
$fakeProfile = Join-Path $tmpDir "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
try {
    Run-InstallTest -FakeHome $tmpDir -FakeProfile $fakeProfile | Out-Null
    Assert-True (Test-Path $fakeProfile) "Profile file was created"
    $content = Get-Content $fakeProfile -Raw
    Assert-True ($content -match "function helpme") "Profile contains 'function helpme'"
} finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# Test 2: Profile exists without helpme -> function is appended
# --------------------------------------------------
Write-Host "Test 2: Profile exists without helpme -> function block appended"
$tmpDir = New-TempTestDir
$fakeProfile = Join-Path $tmpDir "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
try {
    $profileDir = Split-Path $fakeProfile -Parent
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Set-Content -Path $fakeProfile -Value "# existing profile content`nSet-Alias ll Get-ChildItem" -Encoding UTF8

    Run-InstallTest -FakeHome $tmpDir -FakeProfile $fakeProfile | Out-Null
    $content = Get-Content $fakeProfile -Raw
    Assert-True ($content -match "existing profile content") "Original profile content preserved"
    Assert-True ($content -match "Set-Alias ll") "Original alias preserved"
    Assert-True ($content -match "function helpme") "helpme function was appended"
} finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# Test 3: Idempotency -> run twice, function helpme appears only once
# --------------------------------------------------
Write-Host "Test 3: Idempotency -> helpme function appears only once after two installs"
$tmpDir = New-TempTestDir
$fakeProfile = Join-Path $tmpDir "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
try {
    Run-InstallTest -FakeHome $tmpDir -FakeProfile $fakeProfile | Out-Null
    Run-InstallTest -FakeHome $tmpDir -FakeProfile $fakeProfile | Out-Null
    $content = Get-Content $fakeProfile -Raw
    $matches_found = [regex]::Matches($content, "function helpme")
    Assert-True ($matches_found.Count -eq 1) "function helpme appears exactly once (found $($matches_found.Count))"
} finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# Test 4: Old .cmd wrapper exists -> it gets removed
# --------------------------------------------------
Write-Host "Test 4: Old .cmd wrapper is removed"
$tmpDir = New-TempTestDir
$fakeProfile = Join-Path $tmpDir "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
try {
    $binDir = Join-Path $tmpDir ".local" "bin"
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    $cmdWrapper = Join-Path $binDir "helpme.cmd"
    Set-Content -Path $cmdWrapper -Value "@echo off`npowershell -File helpme.ps1 %*" -Encoding UTF8
    Assert-True (Test-Path $cmdWrapper) ".cmd wrapper exists before install"

    Run-InstallTest -FakeHome $tmpDir -FakeProfile $fakeProfile | Out-Null
    Assert-True (-not (Test-Path $cmdWrapper)) ".cmd wrapper was removed after install"
} finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

# --------------------------------------------------
# Test 5: Script downloaded to correct location
# --------------------------------------------------
Write-Host "Test 5: helpme.ps1 is placed in .local/bin"
$tmpDir = New-TempTestDir
$fakeProfile = Join-Path $tmpDir "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
try {
    Run-InstallTest -FakeHome $tmpDir -FakeProfile $fakeProfile | Out-Null
    $scriptPath = Join-Path $tmpDir ".local" "bin" "helpme.ps1"
    Assert-True (Test-Path $scriptPath) "helpme.ps1 exists at .local/bin/helpme.ps1"

    # Verify it's the real file (check first line matches)
    $installed = Get-Content $scriptPath -TotalCount 1
    $original = Get-Content $LocalHelpme -TotalCount 1
    Assert-True ($installed -eq $original) "Installed file matches source (first line)"
} finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}

# ============================================================
Write-Host ""
Write-Host "=== Results: $Pass passed, $Fail failed ===" -ForegroundColor $(if ($Fail -eq 0) { "Green" } else { "Red" })
Write-Host ""

exit $Fail
