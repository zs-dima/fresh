Option Explicit

Dim backupfile
Dim record
Dim myshell
Dim appmyshell
Dim myresult
Dim myline
Dim makeactive
Dim makepassive
Dim reboot
record=""
Set myshell = WScript.CreateObject("WScript.Shell")

If WScript.Arguments.Length = 0 Then
    Set appmyshell  = CreateObject("Shell.Application")
    appmyshell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ RunAsAdministrator", , "runas", 1
    WScript.Quit
End if




Set backupfile = CreateObject("Scripting.FileSystemObject")
If Not (backupfile.FileExists("C:\bcdedit.bak")) Then
    Set myresult = myshell.Exec("cmd /c bcdedit /export C:\bcdedit.bak")
End If

Set myresult = myshell.Exec("cmd /c bcdedit")
Do While Not myresult.StdOut.AtEndOfStream
    myline = myresult.StdOut.ReadLine()

    If myline="The boot configuration data store could not be opened." Then
        record=""
        exit do
    End If
    If Instr(myline, "identifier") > 0 Then
        record=""
        If Instr(myline, "{current}") > 0 Then
            record="current"
        End If
    End If
    If Instr(myline, "hypervisorlaunchtype") > 0 And record = "current" Then
        If Instr(myline, "Auto") > 0 Then
            record="1"
            Exit Do
        End If
        If Instr(myline, "On") > 0 Then
            record="1"
            Exit Do
        End If
        If Instr(myline, "Off") > 0 Then
            record="0"
            Exit Do
        End If
    End If
Loop

If record="1" Then
    makepassive = MsgBox ("Hypervisor status is active, do you want set to passive? ", vbYesNo, "Hypervisor")
    Select Case makepassive
    Case vbYes
        myshell.run "cmd.exe /C  bcdedit /set hypervisorlaunchtype off"
        reboot = MsgBox ("Hypervisor changed to passive; Computer must reboot. Reboot now? ", vbYesNo, "Hypervisor")
        Select Case reboot
            Case vbYes
                myshell.run "cmd.exe /C  shutdown /r /t 0"
        End Select
    Case vbNo
        MsgBox("Not Changed")
    End Select
End If

If record="0" Then
    makeactive = MsgBox ("Hypervisor status is passive, do you want set active? ", vbYesNo, "Hypervisor")
    Select Case makeactive
    Case vbYes
        myshell.run "cmd.exe /C  bcdedit /set hypervisorlaunchtype auto"
        reboot = MsgBox ("Hypervisor changed to active;  Computer must reboot. Reboot now?", vbYesNo, "Hypervisor")
        Select Case reboot
            Case vbYes
                myshell.run "cmd.exe /C  shutdown /r /t 0"
        End Select
    Case vbNo
        MsgBox("Not Changed")
    End Select
End If

If record="" Then
        MsgBox("Error: record can't find")
End If