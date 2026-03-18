#!/usr/bin/env pwsh
# Test suite for helpme.ps1
#
# Uses "pwsh -Command" (not "pwsh -File") to invoke the script because
# -File mode has a known limitation where ValueFromRemainingArguments
# only binds the first argument when multiple positional args follow --.

$ErrorActionPreference = "Continue"
# Use whichever PowerShell is running this test (pwsh 7+ or powershell 5.1)
$PwshExe = (Get-Process -Id $PID).Path
$Helpme = Join-Path (Split-Path $PSScriptRoot) "helpme.ps1"
$Pass = 0
$Fail = 0
$TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "helpme-test-$PID"

# Isolated test environment
New-Item -ItemType Directory -Path $TestDir -Force | Out-Null
$env:HELPME_LOG_DIR = $TestDir
$env:HELPME_WORKER_URL = "http://localhost:0"  # unreachable — tests don't need the worker

# --- Assertions ---

function Assert-ExitCode($Desc, $Expected, [scriptblock]$ScriptBlock) {
    try {
        & $ScriptBlock 2>&1 | Out-Null
        $got = $LASTEXITCODE
        if ($null -eq $got) { $got = 0 }
    } catch {
        $got = 1
    }
    if ($got -eq $Expected) {
        Write-Host "  ✓ $Desc"
        $script:Pass++
    } else {
        Write-Host "  ✗ $Desc (expected exit $Expected, got $got)"
        $script:Fail++
    }
}

function Assert-OutputContains($Desc, $Pattern, [scriptblock]$ScriptBlock) {
    try {
        $output = & $ScriptBlock 2>&1 | Out-String
    } catch {
        $output = $_.Exception.Message
    }
    if ($output -match [regex]::Escape($Pattern)) {
        Write-Host "  ✓ $Desc"
        $script:Pass++
    } else {
        Write-Host "  ✗ $Desc (output did not contain '$Pattern')"
        $lines = ($output -split "`n" | Select-Object -First 3) -join "`n"
        Write-Host "    got: $lines"
        $script:Fail++
    }
}

# --- Tests ---

Write-Host "=== helpme.ps1 test suite ==="
Write-Host ""

Write-Host "-- help and version --"
Assert-ExitCode      "--help exits 0"                    0 { & $PwshExe -Command "& '$Helpme' --help" }
Assert-ExitCode      "-h exits 0"                        0 { & $PwshExe -Command "& '$Helpme' -h" }
Assert-ExitCode      "help subcommand exits 0"           0 { & $PwshExe -Command "& '$Helpme' help" }
Assert-ExitCode      "no args exits 0 (shows help)"      0 { & $PwshExe -Command "& '$Helpme'" }
Assert-OutputContains "--help shows Usage:"              "Usage:" { & $PwshExe -Command "& '$Helpme' --help" }
Assert-OutputContains "--help shows examples"            "Examples:" { & $PwshExe -Command "& '$Helpme' --help" }
Assert-OutputContains "--help shows version"             "v0.2.0" { & $PwshExe -Command "& '$Helpme' --help" }

Assert-ExitCode      "--version exits 0"                 0 { & $PwshExe -Command "& '$Helpme' --version" }
Assert-ExitCode      "-v exits 0"                        0 { & $PwshExe -Command "& '$Helpme' -v" }
Assert-OutputContains "--version prints version"         "helpme 0.2.0" { & $PwshExe -Command "& '$Helpme' --version" }

Write-Host ""
Write-Host "-- command execution --"
Assert-ExitCode      "-- echo hello exits 0"             0 { & $PwshExe -Command "& '$Helpme' -- echo hello" }
Assert-OutputContains "-- echo hello outputs hello"      "hello" { & $PwshExe -Command "& '$Helpme' -- echo hello" }
Assert-ExitCode      "run -- echo hello exits 0"         0 { & $PwshExe -Command "& '$Helpme' run -- echo hello" }

Write-Host ""
Write-Host "-- log file --"
# Clear log and run a command so we can inspect the entry
$logPath = Join-Path $TestDir "log.jsonl"
Remove-Item $logPath -ErrorAction SilentlyContinue
& $PwshExe -Command "& '$Helpme' -- echo logtest" 2>&1 | Out-Null

$logExists = Test-Path $logPath
if (-not $logExists) {
    Write-Host "  ✗ log file not created"
    $script:Fail++
}
if ($logExists) {
    Write-Host "  ✓ log file created after run"
    $script:Pass++

    $lastLine = Get-Content $logPath -Tail 1
    $fields = @("timestamp", "command", "exit_code", "os", "shell", "ok", "explanation", "fix_commands", "duration")
    foreach ($field in $fields) {
        if ($lastLine -match "`"$field`"") { Write-Host "  ✓ log entry contains '$field'"; $script:Pass++ }
        else { Write-Host "  ✗ log entry missing '$field'"; Write-Host "    entry: $lastLine"; $script:Fail++ }
    } }

Write-Host ""
Write-Host "-- dispatcher routing --"
Assert-OutputContains "bare command falls through to run" "hello" { & $PwshExe -Command "& '$Helpme' echo hello" }

# --- Cleanup ---

Remove-Item $TestDir -Recurse -Force -ErrorAction SilentlyContinue
$env:HELPME_LOG_DIR = $null
$env:HELPME_WORKER_URL = $null

Write-Host ""
Write-Host "=== Results: $Pass passed, $Fail failed ==="
if ($Fail -gt 0) { exit 1 } else { exit 0 }
