# helpme.ps1 — wrap any command, get plain-English help if it fails

# Accept all remaining arguments as a flat array (avoids "--" being parsed as a parameter)
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AllArgs
)

# TLS 1.2 — PowerShell 5.1 defaults to TLS 1.0, which many endpoints reject
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Version = "0.2.0"
$WorkerUrl = if ($env:HELPME_WORKER_URL) { $env:HELPME_WORKER_URL } else { "https://helpme-worker.alejoacelas.workers.dev" }
$HomeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$LogDir = if ($env:HELPME_LOG_DIR) { $env:HELPME_LOG_DIR } else { Join-Path $HomeDir ".helpme" }
$LogFile = Join-Path $LogDir "log.jsonl"
$SessionId = "$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())-$PID"

# --- Subcommands ---

function Show-HelpmeHelp {
    Write-Host @"
helpme v$Version — wrap any command, get plain-English help if it fails

Usage:
  helpme -- <command>       Run a command with automatic error analysis
  helpme run -- <command>   Same as above (explicit)
  helpme --help             Show this help
  helpme --version          Show version

Examples:
  helpme -- brew install git
  helpme -- npm start
  helpme -- pip install requests
"@
}

function Show-HelpmeVersion {
    Write-Host "helpme $Version"
}

function Invoke-HelpmeRun {
    param([string[]]$RunArgs)

    # Strip leading "--" if present
    if ($RunArgs.Count -gt 0 -and $RunArgs[0] -eq "--") {
        $RunArgs = if ($RunArgs.Count -gt 1) { $RunArgs[1..($RunArgs.Count - 1)] } else { @() }
    }

    if ($RunArgs.Count -eq 0) {
        Show-HelpmeHelp
        exit 0
    }

    $Command = $RunArgs -join " "

    # Ensure log directory exists
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }

    # Run the command, capturing output while streaming to terminal in real time
    $StderrFile = [System.IO.Path]::GetTempFileName()
    $StartTime = Get-Date

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

    $Duration = ((Get-Date) - $StartTime).TotalSeconds
    $Duration = [math]::Round($Duration, 0)

    # Clean up temp files
    Remove-Item $StderrFile -ErrorAction SilentlyContinue

    # Detect OS and shell at runtime
    $Os = if ($env:OS -eq "Windows_NT") { "windows" } elseif ($IsMacOS) { "darwin" } else { "linux" }
    $Shell = if ($PSVersionTable.PSEdition -eq "Core") { "pwsh" } else { "powershell" }

    # Read recent log history
    $LogHistory = @()
    if (Test-Path $LogFile) {
        $lines = Get-Content $LogFile -Tail 5 -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($lines) {
            $LogHistory = $lines | ForEach-Object {
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

    # Helper: build and write log entry
    function Write-LogEntry($WorkerOk, $WorkerExplanation, $WorkerFixCommands) {
        $entry = @{
            timestamp    = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
            command      = $Command
            stdout       = if ($Stdout -and $Stdout.Length -gt 2000) { $Stdout.Substring(0, 2000) } else { if ($Stdout) { $Stdout } else { "" } }
            stderr       = if ($Stderr -and $Stderr.Length -gt 2000) { $Stderr.Substring(0, 2000) } else { if ($Stderr) { $Stderr } else { "" } }
            exit_code    = $ExitCode
            os           = $Os
            shell        = $Shell
            ok           = $WorkerOk
            explanation  = if ($WorkerExplanation) { $WorkerExplanation } else { "" }
            fix_commands = if ($WorkerFixCommands) { @($WorkerFixCommands) } else { @() }
            duration     = $Duration
        } | ConvertTo-Json -Compress
        Add-Content -Path $LogFile -Value $entry -Encoding UTF8 -ErrorAction SilentlyContinue
    }

    # POST to worker
    $Response = $null
    try {
        $Response = Invoke-RestMethod -Uri "$WorkerUrl/analyze" -Method Post `
            -ContentType "application/json" -Body $Payload -TimeoutSec 15 -ErrorAction Stop
    } catch {
        Write-LogEntry $null "" @()
        if ($ExitCode -ne 0) {
            Write-Host ""
            Write-Host "The command failed (exit code $ExitCode) but couldn't reach the help service." -ForegroundColor Yellow
            Write-Host "Check your internet connection and try again." -ForegroundColor DarkGray
        }
        exit $ExitCode
    }

    # Extract worker response fields
    $Ok = if ($null -ne $Response.ok) { $Response.ok } else { $null }
    $Explanation = if ($Response.explanation) { $Response.explanation } else { "" }
    $FixCommands = if ($Response.fix_commands) { @($Response.fix_commands) } else { @() }

    Write-LogEntry $Ok $Explanation $FixCommands

    if ($Ok -eq $true -and $Explanation) {
        Write-Host ""
        Write-Host "* $Explanation" -ForegroundColor Green
    } elseif ($Ok -eq $false -and $Explanation) {
        Write-Host ""
        Write-Host ("=" * 55) -ForegroundColor Red
        Write-Host $Explanation -ForegroundColor Yellow

        if ($FixCommands.Count -gt 0) {
            Write-Host ""
            Write-Host "Suggested fix:" -ForegroundColor DarkGray
            foreach ($cmd in $FixCommands) {
                Write-Host "  `$ $cmd" -ForegroundColor Cyan
            }

            Write-Host ""
            $confirm = Read-Host "Run these commands? [Y/n]"
            if (-not $confirm -or $confirm -match "^[Yy]$") {
                foreach ($cmd in $FixCommands) {
                    Write-Host "`$ $cmd" -ForegroundColor DarkGray
                    Invoke-Expression $cmd
                }
            }
        }
        Write-Host ("=" * 55) -ForegroundColor Red
    }

    exit $ExitCode
}

# --- Dispatcher ---

# Strip leading "--" from $AllArgs for the dispatcher (so "helpme -- echo hello" works)
if ($AllArgs.Count -gt 0 -and $AllArgs[0] -eq "--") {
    # "helpme -- <cmd>" → treat as run with remaining args (keep the --)
    Invoke-HelpmeRun $AllArgs
    exit
}

$FirstArg = if ($AllArgs.Count -gt 0) { $AllArgs[0] } else { "" }
switch ($FirstArg) {
    { $_ -in "--help", "-h", "help" } { Show-HelpmeHelp; exit 0 }
    { $_ -in "--version", "-v" }      { Show-HelpmeVersion; exit 0 }
    "run"                              { Invoke-HelpmeRun ($AllArgs[1..($AllArgs.Count - 1)]); break }
    ""                                 { Show-HelpmeHelp; exit 0 }
    default                            { Invoke-HelpmeRun $AllArgs; break }
}
