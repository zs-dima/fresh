#Requires AutoHotkey v2.0
#Warn
#SingleInstance

InstallKeybdHook
InstallKeybdHook
ProcessSetPriority "R"
A_HotkeyInterval := 2000 ; This is the default value (milliseconds).
A_MaxHotkeysPerInterval := 200

SetTitleMatchMode 2

chrome := " - Chrom"
gchrome := " - Google Chrome"
opera := "ahk_class OperaWindowClass"
vs := " - Microsoft Visual Studio"
vs1 := " - Microsoft Visual Studio (Administrator)"
vsCode := " - Visual Studio Code - Insiders"
androidStudio := " - Android Studio"
ampView := "ahkfoobar_class TAmpViewMainForm"
foobar := "foobar2000 ahk_class {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1}"
mpc := "ahk_class MediaPlayerClassicW"
firefox := "ahk_class MozillaWindowClass"
ie := "Internet Explorer ahk_class IEFrame"
idea1 := "IntelliJ IDEA"
idea := "ahk_exe idea64.exe"
rider := " JetBrains Rider"

; Win+c > Ctrl+F8
#c:: Send '!n'
#`:: Send '^+{F8}'

; Pin Window !SPACE
#z:: WinSetAlwaysOnTop -1, "A"

XButton1::Send '^{sc02E}' ; '^{Ins}'
XButton2::Send '+{Ins}'
;XButton1::{ ; Ctrl+C
;    Send '^{sc02E}'
;    Sleep 30
;    Send '{Ctrl up}'
;}
;XButton2::{ ; Ctrl+V
;    Send '^{sc02F}'
;    Sleep 30
;    Send '{Ctrl up}'
;}

CapsLock:: {
    Send '{LWin Down}{Space Down}{Space Up}{LWin Up}'
    KeyboardLanguageColor()
}

KeyboardLanguageColor() {
    if !LangID := GetKeyboardLanguage(WinActive("A"))
    {
        MsgBox "GetKeyboardLayout function failed"
        return
    }
    if (LangID = 0x0409) {
        SetLngColor(false)
    }
    else if (LangID = 0x419) {
        SetLngColor(true)
    }
    return
}

SetLngColor(en) {
    if (en) {
        SetKeyColor(44, 0, 0, 0)
    }
    else {
        SetKeyColor(44, 0, 255, 255)
    }
}

SetKeyColor(key, red, green, blue) {
    url := "http://localhost:5137/api/steelseries/key_color"

    body := ' { "key": ' . key . ', "red": ' . red . ', "green": ' . green . ', "blue": ' . blue . ' } '

    xhr := ComObject("WinHttp.WinHttpRequest.5.1")
    xhr.Open("POST", url, false)

    xhr.SetRequestHeader("Content-Type", "application/json")
    xhr.Send(body)

    if (xhr.Status != 200) {
        MsgBox("Error: " . xhr.StatusText)
    }
}

GetKeyboardLanguage(_hWnd := 0)
{
    if !_hWnd
        ThreadId:=0
    else
        if !ThreadId := DllCall("user32.dll\GetWindowThreadProcessId", "Ptr", _hWnd, "UInt", 0, "UInt")
            return false

    if !KBLayout := DllCall("user32.dll\GetKeyboardLayout", "UInt", ThreadId, "UInt")
        return false

    return KBLayout & 0xFFFF
}

Browser_Back:: ; Tab ->
    XButton1 & LButton:: {
        if WinActive(opera)
        {
            Send '^+{F6}'
        }
        else if (WinActive(firefox) or WinActive(chrome) or WinActive(gchrome))
        {
            Send '^{sc149}'
        }
        else if WinActive(vsCode)
        {
            SendInput '!{sc14B}' ; Alt+Left
        }
        else if (WinActive(rider) or WinActive(androidStudio))
        {
            Send '^!{sc14B}' ; Ctrl+Alt+Left
        }
        else if (WinActive(idea) or WinActive(vs) or WinActive(vs1))
        {
            Send '^{-}'
        }
        else if (WinExist(foobar))
        {
            WinActivate
            Send '{F1}'
        }
        return
    }

Browser_Forward:: ; Tab <-
    XButton1 & RButton:: {
        if WinActive(opera)
        {
            Send '^{F6}'
        }
        else if WinActive(firefox) or WinActive(chrome) or WinActive(gchrome)
        {
            Send '^{sc151}'
        }
        else if WinActive(vsCode)
        {
            SendInput '!{sc14D}'
        }
        else if WinActive(rider) or WinActive(androidStudio)
        {
            Send '^!{sc14D}'
        }
        else if WinActive(idea) or WinActive(vs) or WinActive(vs1)
        {
            Send '^+{-}'
        }
        else if WinExist(foobar)
        {
            WinActivate
            Send '{F2}'
        }
        return
    }

    LButton & XButton1:: { ; New Tab
        if WinActive(firefox) or WinActive(chrome) or WinActive(gchrome) or WinActive(ie) or WinActive(opera)
        {
            Send '^{sc014}'
        }
        else if WinActive(vsCode)
        {
            SendInput '^{sc031}'
        }
        else if WinActive(idea) or WinActive(rider) or WinActive(androidStudio)
        {
            Send '^+{sc015}'
        }
        return
    }

    XButton1 & MButton:: { ; Close Tab
        if WinActive(vs) or WinActive(vs1)
        {
            Send '^{F4}'
        }
        else if WinActive(vsCode) or WinActive(chrome) or WinActive(gchrome) or WinActive(ie) or WinActive(firefox) or WinActive(opera)
        {
            Send '^{sc011}'
        }
        else if WinActive(idea) or WinActive(rider) or WinActive(androidStudio)
        {
            Send '^{sc03E}'
        }
        return
    }

    ; ##############################

    ; LWin & LButton:: {
    ;    Style := WinGetStyle("A")
    ;    if(Style & 0xC00000) {
    ;        ;WinSetStyle "-0x400000" ; hides the dialog frame
    ;        ;WinSetStyle "-0x40000" ; hides the sizebox/thickframe
    ;        ;WinSetStyle "-0x800000" ; hides the thin-line border
    ;        WinSetStyle "-0xc40000", "A" ; hides the title bar
    ;    } else {
    ;        ;WinSetStyle "+0x400000" ; hides the dialog frame
    ;        ;WinSetStyle "+0x40000" ; hides the sizebox/thickframe
    ;        ;WinSetStyle "+0x800000" ; hides the thin-line border
    ;        WinSetStyle "+0xc40000", "A" ; hides the title bar
    ;    }
    ;    WinRedraw
    ;    WinSetAlwaysOnTop -1, "A"
    ;    return
    ;}

    iScrollUp := 0
    iScrollDwn := 0

    ;XButton1 & WheelDown:: {
    ;    iScrollUp := 0
    ;    if iScrollDwn > 3
    ;    {
    ;        iScrollDwn := 0
    ;        if WinActive(vs) or WinActive(vs1)
    ;        {
    ;            Send "^{-}"
    ;            iScrollDwn := 0
    ;        }
    ;    } else iScrollDwn := iScrollDwn + 1
    ;        return
    ;}

    ;XButton1 & WheelUp:: {
    ;    iScrollDwn := 0
    ;    if iScrollUp > 3
    ;    {
    ;        iScrollUp := 0
    ;        if WinActive(vs) or WinActive(vs1)
    ;        {
    ;            Send "^+{-}"
    ;            iScrollUp := 0
    ;        }
    ;    } else iScrollUp := iScrollUp + 1
    ;        return
    ;}

    ~XButton2 & WheelUp::AltTab
    ~XButton2 & WheelDown::ShiftAltTab

    ~LButton & ~RButton::Send "{Enter}"
    ~RButton & ~LButton::Send "{Delete}"

    SC122:: { ;Media_Play_Pause
        DllCall("PowrProf\SetSuspendState", "int", 1, "int", 1, "int", 1)
        return
    }

    SC068:: Run "calc.exe"

    !g:: { ; Alt+G Generate GUID
        gid := UUIDCreate()
        gid := StrLower(gid) ; StrUpper(gid)
        A_Clipboard := gid
        Send '+{Ins}' ; Send '^{sc02F}' ; Ctrl + V
        return
    }

    ; https://github.com/cocobelgica/AutoHotkey-Util/blob/master/UUIDCreate.ahk
    UUIDCreate(mode:=1, format:="", &UUID:="")
    {
        #DllLoad Rpcrt4
        uidCreate := "Rpcrt4\UuidCreate"
        if InStr("02", mode)
            uidCreate .= mode? "Sequential" : "Nil"
        UUID := Buffer(16) ;// long(UInt) + 2*UShort + 8*UChar
        if (DllCall(uidCreate, "Ptr", UUID) == 0)
            && (DllCall("Rpcrt4\UuidToString", "Ptr", UUID, "UInt*", &pString := 0) == 0)
        {
            str := StrGet(pString)
            DllCall("Rpcrt4\RpcStringFree", "UInt*", pString)
            if InStr(format, "U")
                DllCall("CharUpper", "Ptr", StrPtr(str))
            return InStr(format, "{") ? "{" . str . "}" : str
        }
    }

    Pause::SwitchKeysLocale() ; Break

    SwitchKeysLocale()
    {
        Layout := ""
        TempClipboard := ""
        SelText := GetWord(&TempClipboard)
        A_Clipboard := ConvertText(SelText, &Layout)
        Send '+{Ins}' ; ("^{vk56}") ; Ctrl + V
        Sleep(50)
        SwitchLocale(Layout)
        Sleep(50)
        ;Send '{Ctrl up}'
        A_Clipboard := TempClipboard

        SetLngColor(Layout = "Lat")
    }

    ;SwitchRegistr()
    ;{
    ;    SelText := GetWord(TempClipboard)
    ;    A_Clipboard := ConvertRegistr(SelText)
    ;    SendInput("^{vk56}") ; Ctrl + V
    ;    Sleep(200)
    ;    A_Clipboard := TempClipboard
    ;}

    GetWord(&TempClipboard)
    {
        ; REMOVED:    SetBatchLines, -1
        SetKeyDelay(0)

        TempClipboard := ClipboardAll()
        A_Clipboard := ""
        SendInput("^{vk43}")
        Sleep(100)
        if (A_Clipboard != "")
            Return A_Clipboard

        While A_Index < 10
        {
            SendInput("^+{Left}^{vk43}")
            Errorlevel := !ClipWait(1)
            if ErrorLevel
                Return

            if RegExMatch(A_Clipboard, "([ \t])", &Found) && A_Index != 1
            {
                SendInput("^+{Right}")
                Return SubStr(A_Clipboard, (Found.Pos[1] + 1)<1 ? (Found.Pos[1] + 1)-1 : (Found.Pos[1] + 1))
            }

            PrevClipboard := A_Clipboard
            A_Clipboard := ""
            SendInput("+{Left}^{vk43}")
            Errorlevel := !ClipWait(1)
            if ErrorLevel
                Return

            if (StrLen(A_Clipboard) = StrLen(PrevClipboard))
            {
                A_Clipboard := ""
                SendInput("+{Left}^{vk43}")
                Errorlevel := !ClipWait(1)
                if ErrorLevel
                    Return

                if (StrLen(A_Clipboard) = StrLen(PrevClipboard))
                    Return A_Clipboard
                Else
                {
                    SendInput("+{Right 2}")
                    Return PrevClipboard
                }
            }

            SendInput("+{Right}")

            s := SubStr(A_Clipboard, 1, 1)
            if (s ~= "^(?i:" RegExReplace(RegExReplace(A_Space "," A_Tab ",`n,`r","[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\s*,\s*","|") ")$")
            {
                A_Clipboard := ""
                SendInput("+{Left}^{vk43}")
                Errorlevel := !ClipWait(1)
                if ErrorLevel
                    Return

                Return A_Clipboard
            }
            A_Clipboard := ""
        }
    }

    ConvertText(Text, &OppositeLayout)
    {
        Static Cyr := "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ/ёйцукенгшщзхъфывапролджэячсмитьбю,.`"№;?"
        Static Lat := "~QWERTYUIOP{}ASDFGHJKL:`"ZXCVBNM<>|``qwertyuiop[]asdfghjkl;'zxcvbnm,.?/@#$&"

        RegExReplace(Text, "i)[A-Z@#\$\^&\[\]'`\{}]", "", &LatCount)
        RegExReplace(Text, "i)[А-ЯЁ№]", "", &CyrCount)

        if (LatCount != CyrCount) {
            CurrentLayout := LatCount > CyrCount ? "Lat" : "Cyr"
            OppositeLayout := LatCount > CyrCount ? "Cyr" : "Lat"
        }
        else {
            threadId := DllCall("GetWindowThreadProcessId", "Ptr", WinExist("A"), "UInt", 0, "Ptr")
            landId := DllCall("GetKeyboardLayout", "Ptr", threadId, "Ptr") & 0xFFFF
            if (landId = 0x409)
                CurrentLayout := "Lat", OppositeLayout := "Cyr"
            else
                CurrentLayout := "Cyr", OppositeLayout := "Lat"
        }
        Loop Parse, Text
            NewText .= (found := InStr(%CurrentLayout%, A_LoopField, 1))
                ? SubStr(%OppositeLayout%, found, 1) : A_LoopField
        Return NewText
    }

    SwitchLocale(Layout)
    {
        ;CtrlFocus := ControlGetClassNN(ControlGetFocus("A"))
        PostMessage(WM_INPUTLANGCHANGEREQUEST := 0x0050, 0, Layout = "Lat" ? 0x4090409 : 0x4190419, , "A") ; %CtrlFocus%
    }

    ConvertRegistr(Text)
    {
        static Chars := "ёйцукенгшщзхъфывапролджэячсмитьбюqwertyuiopasdfghjklzxcvbnm" . "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮQWERTYUIOPASDFGHJKLZXCVBNM"

        Loop Parse, Text
            NewText .= (found := InStr(Chars, A_LoopField, 1))
                ? SubStr(Chars, (Found.Len - 59)<1 ? (Found.Len - 59)-1 : (Found.Len - 59), 1) : A_LoopField
        Return NewText
    }
