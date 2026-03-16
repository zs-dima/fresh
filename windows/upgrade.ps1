$commands = @(
    @{ Name = "Winget";    Cmd = "winget upgrade --all --include-unknown" }
    @{ Name = "Choco";     Cmd = "choco upgrade all -y" }
    @{ Name = "Rust";      Cmd = "rustup update" }
    @{ Name = "FVM";       Cmd = "dart pub global activate fvm" }
    @{ Name = "GCloud";    Cmd = "gcloud components update --quiet" }
    @{ Name = "WSL";       Cmd = "wsl --update" }
    @{ Name = "Python";    Cmd = "py install --update" }
)

foreach ($c in $commands) {
    Write-Host "`n=== $($c.Name) ===" -ForegroundColor Cyan
    try {
        Invoke-Expression $c.Cmd
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "exit code $LASTEXITCODE" }
        Write-Host "$($c.Name): OK" -ForegroundColor Green
    } catch {
        Write-Host "$($c.Name): FAILED - $_" -ForegroundColor Red
    }
}

Write-Host "`nAll done. Press any key to close." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit