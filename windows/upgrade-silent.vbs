Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
sh.Run "pwsh.exe -NoLogo -ExecutionPolicy Bypass -File """ & dir & "\upgrade.ps1"" -Silent", 0, True