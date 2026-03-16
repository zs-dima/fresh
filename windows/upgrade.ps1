param([switch]$Silent)

$commands = @(
    @{ Name = "Winget";    Cmd = "winget upgrade --all --include-unknown" }
    @{ Name = "Choco";     Cmd = "choco upgrade all -y" }
    @{ Name = "Rust";      Cmd = "rustup update" }
    @{ Name = "FVM";       Cmd = "dart pub global activate fvm" }
    @{ Name = "GCloud";    Cmd = "gcloud components update --quiet" }
    @{ Name = "WSL";       Cmd = "wsl --update" }
    @{ Name = "Python";    Cmd = "py install --update" }
)

$total = [System.Diagnostics.Stopwatch]::StartNew()
$results = @()
$failed = 0

foreach ($c in $commands) {
    Write-Host "`n=== $($c.Name) ===" -ForegroundColor Cyan
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $LASTEXITCODE = 0

    try {
        Invoke-Expression $c.Cmd
        if ($LASTEXITCODE -ne 0) { throw "exit code $LASTEXITCODE" }
        $status = "OK     $($sw.Elapsed.ToString('mm\:ss'))"
        Write-Host "$($c.Name): OK" -ForegroundColor Green
    } catch {
        $status = "FAILED $($sw.Elapsed.ToString('mm\:ss'))  $_"
        Write-Host "$($c.Name): FAILED - $_" -ForegroundColor Red
        $failed++
    }

    $results += "$($c.Name): $status"
}

$total.Stop()
$summary = if ($failed -eq 0) { "All OK" } else { "$failed failed" }
$header = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm')]  $summary  $($total.Elapsed.ToString('mm\:ss')) total"

$log = Join-Path $PSScriptRoot "upgrade.log"
@($header) + $results | Set-Content $log

Write-Host "`n$header" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if (-not $Silent) {
    Write-Host "Press any key to close."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
