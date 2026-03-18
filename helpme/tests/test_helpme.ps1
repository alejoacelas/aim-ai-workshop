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
$env:HELPME_WORKER_URL = "http://localhost:0"  # unreachable - tests don't need the worker

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
        Write-Host "  PASS: $Desc"
        $script:Pass++
    } else {
        Write-Host "  FAIL: $Desc (expected exit $Expected, got $got)"
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
        Write-Host "  PASS: $Desc"
        $script:Pass++
    } else {
        Write-Host "  FAIL: $Desc (output did not contain '$Pattern')"
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
    Write-Host "  FAIL: log file not created"
    $script:Fail++
}
if ($logExists) {
    Write-Host "  PASS: log file created after run"
    $script:Pass++
}

$lastLine = ""
if ($logExists) {
    $lastLine = Get-Content $logPath -Tail 1
}

if ($logExists) {
    if ($lastLine -match '"timestamp"') {
        Write-Host "  PASS: log entry contains 'timestamp'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'timestamp'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"command"') {
        Write-Host "  PASS: log entry contains 'command'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'command'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"exit_code"') {
        Write-Host "  PASS: log entry contains 'exit_code'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'exit_code'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"os"') {
        Write-Host "  PASS: log entry contains 'os'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'os'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"shell"') {
        Write-Host "  PASS: log entry contains 'shell'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'shell'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"ok"') {
        Write-Host "  PASS: log entry contains 'ok'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'ok'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"explanation"') {
        Write-Host "  PASS: log entry contains 'explanation'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'explanation'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"fix_commands"') {
        Write-Host "  PASS: log entry contains 'fix_commands'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'fix_commands'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }

    if ($lastLine -match '"duration"') {
        Write-Host "  PASS: log entry contains 'duration'"
        $script:Pass++
    } else {
        Write-Host "  FAIL: log entry missing 'duration'"
        Write-Host "    entry: $lastLine"
        $script:Fail++
    }
}

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
