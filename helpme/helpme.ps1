# helpme.ps1 — wrap any command, get plain-English help if it fails
# Usage: helpme -- <command> [args...]

# Accept all remaining arguments as a flat array (avoids "--" being parsed as a parameter)
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AllArgs
)

# TLS 1.2 — PowerShell 5.1 defaults to TLS 1.0, which many endpoints reject
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$WorkerUrl = "https://helpme-worker.alejoacelas.workers.dev"
$HomeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$LogDir = Join-Path $HomeDir ".helpme"
$LogFile = Join-Path $LogDir "log.jsonl"
$SessionId = "$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())-$PID"

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

# Run the command, capturing output while streaming to terminal in real time
$StderrFile = [System.IO.Path]::GetTempFileName()

if ($env:OS -eq "Windows_NT") {
    # Windows: use cmd /c with event-based async output for real-time streaming
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "cmd.exe"
    $pinfo.Arguments = "/c $Command"
    $pinfo.UseShellExecute = $false
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $pinfo

    # Collect output in StringBuilders while streaming each line to the terminal
    $stdoutBuilder = New-Object System.Text.StringBuilder
    $stderrBuilder = New-Object System.Text.StringBuilder

    $stdoutEvent = Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action {
        if ($null -ne $EventArgs.Data) {
            $Event.MessageData.AppendLine($EventArgs.Data) | Out-Null
            [Console]::WriteLine($EventArgs.Data)
        }
    } -MessageData $stdoutBuilder

    $stderrEvent = Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived -Action {
        if ($null -ne $EventArgs.Data) {
            $Event.MessageData.AppendLine($EventArgs.Data) | Out-Null
            [Console]::Error.WriteLine($EventArgs.Data)
        }
    } -MessageData $stderrBuilder

    $proc.Start() | Out-Null
    $proc.BeginOutputReadLine()
    $proc.BeginErrorReadLine()
    $proc.WaitForExit()

    # Let async event handlers flush (PS 5.1 doesn't guarantee delivery before WaitForExit returns)
    Start-Sleep -Milliseconds 100

    Unregister-Event -SourceIdentifier $stdoutEvent.Name
    Unregister-Event -SourceIdentifier $stderrEvent.Name

    $Stdout = $stdoutBuilder.ToString()
    $Stderr = $stderrBuilder.ToString()
    $ExitCode = $proc.ExitCode
} else {
    # Non-Windows (testing with pwsh on Mac/Linux): use Invoke-Expression
    try {
        $output = Invoke-Expression $Command 2>$StderrFile
        $ExitCode = $LASTEXITCODE
        if ($null -eq $ExitCode) { $ExitCode = 0 }
        $Stdout = ($output | Out-String)
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
Remove-Item $StderrFile -ErrorAction SilentlyContinue

# Detect OS and shell at runtime
$Os = if ($env:OS -eq "Windows_NT") { "windows" } elseif ($IsMacOS) { "darwin" } else { "linux" }
$Shell = if ($PSVersionTable.PSEdition -eq "Core") { "pwsh" } else { "powershell" }

# Build log entry
$LogEntry = @{
    timestamp = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    command   = $Command
    stdout    = if ($Stdout -and $Stdout.Length -gt 2000) { $Stdout.Substring(0, 2000) } else { if ($Stdout) { $Stdout } else { "" } }
    stderr    = if ($Stderr -and $Stderr.Length -gt 2000) { $Stderr.Substring(0, 2000) } else { if ($Stderr) { $Stderr } else { "" } }
    exit_code = $ExitCode
    os        = $Os
    shell     = $Shell
} | ConvertTo-Json -Compress

Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8 -ErrorAction SilentlyContinue

# Read recent log history
$LogHistory = @()
if (Test-Path $LogFile) {
    $lines = Get-Content $LogFile -Tail 6 -Encoding UTF8 -ErrorAction SilentlyContinue
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
