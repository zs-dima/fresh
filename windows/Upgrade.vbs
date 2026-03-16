Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
CreateObject("Shell.Application").ShellExecute "wt.exe", _
    "pwsh.exe -NoLogo -ExecutionPolicy Bypass -File """ & dir & "\upgrade.ps1""", dir, "runas", 1