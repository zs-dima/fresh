function hosts { notepad c:\windows\system32\drivers\etc\hosts }

# Alias
Set-Alias tt tree
Set-Alias ll ls
Set-Alias g git
#Set alias vim nvim
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias ip ipconfig
Set-Alias code 'C:\dev\vscode\Code - Insiders.exe'


# https://medium.com/jacklee26/setup-fancy-terminal-using-ohmyposh-9f0ce00948bf
# $omp_config = Join-Path $PSScriptRoot ".\theme.omp.json"
# oh-my-posh init pwsh --config $omp_config | Invoke-Expression

$global:FirstCommand = $true
function Invoke-Starship-PreCommand {
    # Window Title
    $host.ui.RawUI.WindowTitle = "$env:USERNAME@$env:COMPUTERNAME $((Split-Path -Leaf $pwd))"
    # Add a blank line between commands
    if (-not $global:FirstCommand) { Write-Host "" } 
    $global:FirstCommand = $false
}
$ENV:STARSHIP_CONFIG = Join-Path $PSScriptRoot ".\starship.toml"
function Invoke-Starship-TransientFunction {
  &starship module character
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt