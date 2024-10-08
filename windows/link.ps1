
# PowerShell
$profilePath = $PROFILE
$profileFolder = Split-Path -Path $profilePath

$configWinDir = Join-Path $PSScriptRoot '.config'
$gitProfilePath = Join-Path $configWinDir 'Microsoft.PowerShell_profile.ps1'

$configRootDir = Join-Path (Split-Path -Path $PSScriptRoot -Parent) '.config'
$gitStarshipPath = Join-Path -Path $configRootDir -ChildPath 'starship.toml'
$starshipPath = Join-Path -Path $profileFolder -ChildPath 'starship.toml'

$terminalSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$gitTerminalSettingsPath = Join-Path -Path $configWinDir -ChildPath 'terminal_settings.json'
$terminalSettingsPath = Join-Path -Path $terminalSettingsDir -ChildPath 'settings.json'

$ahkDir = Join-Path $env:ProgramFiles 'AutoHotkey\v2'
$gitAhkPath = Join-Path -Path $configWinDir -ChildPath 'AutoHotkey.ahk'
$ahkPath = Join-Path -Path $ahkDir -ChildPath 'AutoHotkey.ahk'

# Function to check if a file is a symbolic link
function Test-IsSymbolicLink {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        return $false
    }

    return $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
}

function CheckSymlink {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProfilePath,

        [Parameter(Mandatory = $true)]
        [string]$GitProfilePath
    )

    try {
        # Determine if the existing profile is a symbolic link
        $isSymlink = Test-IsSymbolicLink -Path $ProfilePath

        if ($isSymlink) {
            # If it's a symlink, check if it points to the desired local profile
            $currentTarget = (Get-Item -Path $ProfilePath).Target

            # Resolve full paths for comparison
            $resolvedCurrentTarget = [System.IO.Path]::GetFullPath($currentTarget)
            $resolvedLocalProfile = [System.IO.Path]::GetFullPath($GitProfilePath)

            if ($resolvedCurrentTarget -ieq $resolvedLocalProfile) {
                Write-Verbose "The PowerShell profile is already a symbolic link to '$GitProfilePath'. No action needed."
                return $true
            }
            else {
                Write-Verbose "The PowerShell profile is a symbolic link to '$currentTarget'. Updating to point to '$GitProfilePath'."

                try {
                    # Remove the existing symlink
                    Remove-Item -Path $ProfilePath -Force -ErrorAction Stop
                    Write-Verbose "Removed existing symbolic link at '$ProfilePath'."
                    return $false
                }
                catch {
                    Write-Error "Failed to remove existing symbolic link. Error: $_"
                    return $false # exit 1
                }
            }
        }
        else {
            Write-Verbose "The PowerShell profile is a regular file. Deleting it to create a symbolic link."

            #  Remove the existing regular file
            Remove-Item -Path $ProfilePath -Force -ErrorAction Ignore
            Write-Verbose "Deleted existing profile file at '$ProfilePath'."
            return $false
        }
    }
    catch {
        Write-Error "An unexpected error occurred: $_"
        return $false # exit 1
    }
}

function CreateSymlink {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProfilePath,

        [Parameter(Mandatory = $true)]
        [string]$GitProfilePath
    )

    # Create the Symbolic Link
    try {
        New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $GitProfilePath -Force | Out-Null
        Write-Host "Successfully created a symbolic link from '$ProfilePath' to '$GitProfilePath'."
    }
    catch {
        Write-Error "Failed to create symbolic link. Ensure you have the necessary permissions. Error: $_"
        exit 1
    }

    # Verification
    try {
        $link = Get-Item -Path $ProfilePath
        if ($link.LinkType -eq "SymbolicLink") {
            Write-Host "Verification successful: '$ProfilePath' is a symbolic link to '$($link.Target)'."
        }
        else {
            Write-Warning "Verification failed: '$ProfilePath' is not a symbolic link."
        }
    }
    catch {
        Write-Warning "Unable to verify the symbolic link. Error: $_"
    }
}

# If PS profile directory exists check if symlink is needed
if (Test-Path -Path $profileFolder) {
    $symlinkOk = CheckSymlink -ProfilePath $profilePath -GitProfilePath $gitProfilePath
    if (-not $symlinkOk) {
        CreateSymlink -ProfilePath $profilePath -GitProfilePath $gitProfilePath
    }

    $symlinkOk = CheckSymlink -ProfilePath $starshipPath -GitProfilePath $gitStarshipPath
    if (-not $symlinkOk) {
        CreateSymlink -ProfilePath $starshipPath -GitProfilePath $gitStarshipPath
    }
}
else {
    New-Item -ItemType Directory -Path $profileFolder -Force | Out-Null
    Write-Host "Created directory '$profileFolder'."
    CreateSymlink -ProfilePath $profilePath -GitProfilePath $gitProfilePath
    CreateSymlink -ProfilePath $starshipPath -GitProfilePath $gitStarshipPath    
}

if (Test-Path -Path $terminalSettingsDir) {
    $symlinkOk = CheckSymlink -ProfilePath $terminalSettingsPath -GitProfilePath $gitTerminalSettingsPath
    if (-not $symlinkOk) {
        CreateSymlink -ProfilePath $terminalSettingsPath -GitProfilePath $gitTerminalSettingsPath
    }
}
else {
    New-Item -ItemType Directory -Path $terminalSettingsDir -Force | Out-Null
    Write-Host "Created directory '$terminalSettingsDir'."
    CreateSymlink -ProfilePath $terminalSettingsPath -GitProfilePath $gitTerminalSettingsPath
}


if (Test-Path -Path $ahkDir) {
    $symlinkOk = CheckSymlink -ProfilePath $ahkPath -GitProfilePath $gitAhkPath
    if (-not $symlinkOk) {
        CreateSymlink -ProfilePath $ahkPath -GitProfilePath $gitAhkPath
    }
}
else {
    New-Item -ItemType Directory -Path $ahkDir -Force | Out-Null
    Write-Host "Created directory '$ahkDir'."
    CreateSymlink -ProfilePath $ahkPath -GitProfilePath $gitAhkPath
}

