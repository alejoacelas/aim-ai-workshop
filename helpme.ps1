# helpme.ps1 — wrap any command, get plain-English help if it fails
# Usage: helpme -- <command> [args...]

param(
    [Parameter(Position = 0)]
    [string]$Separator,
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$CommandArgs
)

$WorkerUrl = "https://helpme-worker.alejoacelas.workers.dev"
$LogDir = Join-Path $env:USERPROFILE ".helpme"
$LogFile = Join-Path $LogDir "log.jsonl"
$SessionId = "$([int](Get-Date -UFormat %s))-$PID"

# Strip leading "--" if present
if ($Separator -eq "--" -and $CommandArgs.Count -gt 0) {
    $Command = $CommandArgs -join " "
} elseif ($Separator -and $Separator -ne "--") {
    $Command = (@($Separator) + $CommandArgs) -join " "
} else {
    Write-Host "Usage: helpme -- <command> [args...]"
    Write-Host "Example: helpme -- winget install Git.Git"
    exit 1
}

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Run the command, capturing output
$StdoutFile = [System.IO.Path]::GetTempFileName()
$StderrFile = [System.IO.Path]::GetTempFileName()

try {
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $Command -NoNewWindow -Wait -PassThru `
        -RedirectStandardOutput $StdoutFile -RedirectStandardError $StderrFile
    $ExitCode = $process.ExitCode
} catch {
    # Fallback: try running directly via PowerShell
    try {
        $output = Invoke-Expression $Command 2>&1
        $ExitCode = $LASTEXITCODE
        if ($null -eq $ExitCode) { $ExitCode = 0 }
        $output | Out-File -FilePath $StdoutFile -Encoding utf8
    } catch {
        $ExitCode = 1
        $_.Exception.Message | Out-File -FilePath $StderrFile -Encoding utf8
    }
}

$Stdout = if (Test-Path $StdoutFile) { Get-Content $StdoutFile -Raw -ErrorAction SilentlyContinue } else { "" }
$Stderr = if (Test-Path $StderrFile) { Get-Content $StderrFile -Raw -ErrorAction SilentlyContinue } else { "" }

# Print captured output to terminal
if ($Stdout) { Write-Host $Stdout }
if ($Stderr) { Write-Host $Stderr -ForegroundColor Red }

# Clean up temp files
Remove-Item $StdoutFile, $StderrFile -ErrorAction SilentlyContinue

# Detect OS info
$Os = "windows"
$Shell = "powershell"

# Build log entry
$LogEntry = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    command   = $Command
    stdout    = if ($Stdout.Length -gt 2000) { $Stdout.Substring(0, 2000) } else { $Stdout }
    stderr    = if ($Stderr -and $Stderr.Length -gt 2000) { $Stderr.Substring(0, 2000) } else { $Stderr }
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
    stdout      = if ($Stdout.Length -gt 3000) { $Stdout.Substring(0, 3000) } else { $Stdout }
    stderr      = if ($Stderr -and $Stderr.Length -gt 3000) { $Stderr.Substring(0, 3000) } else { $Stderr }
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
