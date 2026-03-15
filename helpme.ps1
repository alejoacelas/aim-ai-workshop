# helpme.ps1 — wrap any command, get plain-English help if it fails
# Usage: helpme -- <command> [args...]

# Accept all remaining arguments as a flat array (avoids "--" being parsed as a parameter)
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AllArgs
)

$WorkerUrl = "https://helpme-worker.alejoacelas.workers.dev"
$LogDir = Join-Path $env:USERPROFILE ".helpme"
$LogFile = Join-Path $LogDir "log.jsonl"
$SessionId = "$([int](Get-Date -UFormat %s))-$PID"

# Strip leading "--" if present
if ($AllArgs.Count -gt 0 -and $AllArgs[0] -eq "--") {
    $AllArgs = $AllArgs[1..($AllArgs.Count - 1)]
}

if ($AllArgs.Count -eq 0) {
    Write-Host "Usage: helpme -- <command> [args...]"
    Write-Host "Example: helpme -- winget install Git.Git"
    exit 1
}

$Command = $AllArgs -join " "

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Run the command, capturing output while streaming to terminal
# Use cmd /c on Windows (streams + captures via temp files)
# Invoke-Expression as fallback (e.g. on macOS pwsh for testing)
$StdoutFile = [System.IO.Path]::GetTempFileName()
$StderrFile = [System.IO.Path]::GetTempFileName()

if ($env:OS -eq "Windows_NT") {
    # On Windows: use cmd /c which streams to terminal, capture via process redirection
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "cmd.exe"
    $pinfo.Arguments = "/c $Command"
    $pinfo.UseShellExecute = $false
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $proc = [System.Diagnostics.Process]::Start($pinfo)

    # Read output and stream to terminal + capture
    $stdoutTask = $proc.StandardOutput.ReadToEndAsync()
    $stderrTask = $proc.StandardError.ReadToEndAsync()
    $proc.WaitForExit()

    $Stdout = $stdoutTask.Result
    $Stderr = $stderrTask.Result
    $ExitCode = $proc.ExitCode

    if ($Stdout) { Write-Host $Stdout }
    if ($Stderr) { Write-Host $Stderr -ForegroundColor Red }
} else {
    # Non-Windows (testing with pwsh on Mac/Linux): use Invoke-Expression
    try {
        $output = Invoke-Expression $Command 2>$StderrFile
        $ExitCode = $LASTEXITCODE
        if ($null -eq $ExitCode) { $ExitCode = 0 }
        $Stdout = ($output | Out-String)
        # Stream to terminal
        if ($Stdout) { Write-Host $Stdout }
    } catch {
        $ExitCode = 1
        Write-Host $_.Exception.Message -ForegroundColor Red
        $Stderr = $_.Exception.Message
        $Stdout = ""
    }
    if (-not $Stderr) {
        $Stderr = if (Test-Path $StderrFile) { Get-Content $StderrFile -Raw -ErrorAction SilentlyContinue } else { "" }
    }
}

# Clean up temp files
Remove-Item $StdoutFile, $StderrFile -ErrorAction SilentlyContinue

# Detect OS info
$Os = "windows"
$Shell = "powershell"

# Build log entry
$LogEntry = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    command   = $Command
    stdout    = if ($Stdout -and $Stdout.Length -gt 2000) { $Stdout.Substring(0, 2000) } else { if ($Stdout) { $Stdout } else { "" } }
    stderr    = if ($Stderr -and $Stderr.Length -gt 2000) { $Stderr.Substring(0, 2000) } else { if ($Stderr) { $Stderr } else { "" } }
    exit_code = $ExitCode
    os        = $Os
    shell     = $Shell
} | ConvertTo-Json -Compress

Add-Content -Path $LogFile -Value $LogEntry -ErrorAction SilentlyContinue

# Read recent log history
$LogHistory = @()
if (Test-Path $LogFile) {
    $lines = Get-Content $LogFile -Tail 6 -ErrorAction SilentlyContinue
    if ($lines.Count -gt 1) {
        $LogHistory = $lines[0..($lines.Count - 2)] | ForEach-Object {
            try { $_ | ConvertFrom-Json } catch { $null }
        } | Where-Object { $null -ne $_ }
    }
}

# Build request payload
$Payload = @{
    command     = $Command
    stdout      = if ($Stdout -and $Stdout.Length -gt 3000) { $Stdout.Substring(0, 3000) } else { if ($Stdout) { $Stdout } else { "" } }
    stderr      = if ($Stderr -and $Stderr.Length -gt 3000) { $Stderr.Substring(0, 3000) } else { if ($Stderr) { $Stderr } else { "" } }
    exit_code   = $ExitCode
    os          = $Os
    shell       = $Shell
    session_id  = $SessionId
    log_history = @($LogHistory)
} | ConvertTo-Json -Depth 3

# POST to worker
try {
    $Response = Invoke-RestMethod -Uri "$WorkerUrl/analyze" -Method Post `
        -ContentType "application/json" -Body $Payload -TimeoutSec 15
} catch {
    if ($ExitCode -ne 0) {
        Write-Host ""
        Write-Host "The command failed (exit code $ExitCode) but couldn't reach the help service." -ForegroundColor Yellow
        Write-Host "Check your internet connection and try again." -ForegroundColor DarkGray
    }
    exit $ExitCode
}

# Handle response
if ($Response.ok -eq $true -and $Response.explanation) {
    Write-Host ""
    Write-Host "* $($Response.explanation)" -ForegroundColor Green
} elseif ($Response.ok -eq $false -and $Response.explanation) {
    Write-Host ""
    Write-Host ("=" * 55) -ForegroundColor Red
    Write-Host $Response.explanation -ForegroundColor Yellow

    if ($Response.fix_commands -and $Response.fix_commands.Count -gt 0) {
        Write-Host ""
        Write-Host "Suggested fix:" -ForegroundColor DarkGray
        foreach ($cmd in $Response.fix_commands) {
            Write-Host "  `$ $cmd" -ForegroundColor Cyan
        }

        Write-Host ""
        $confirm = Read-Host "Run these commands? [Y/n]"
        if (-not $confirm -or $confirm -match "^[Yy]$") {
            foreach ($cmd in $Response.fix_commands) {
                Write-Host "`$ $cmd" -ForegroundColor DarkGray
                Invoke-Expression $cmd
            }
        }
    }
    Write-Host ("=" * 55) -ForegroundColor Red
}

exit $ExitCode
