#Requires AutoHotkey v2.0
#Warn
#SingleInstance Force
#DllLoad Rpcrt4

KeyHistory(0)
InstallKeybdHook()
ProcessSetPriority("High")
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 200
A_MenuMaskKey := "vkE8"
SendMode("Input")
SetKeyDelay(0, 0)

; ── Window Groups ──────────────────────────────────────────────

GroupAdd("Browsers", "ahk_exe chrome.exe")
GroupAdd("Browsers", "ahk_exe msedge.exe")
GroupAdd("Browsers", "ahk_exe firefox.exe")
GroupAdd("Browsers", "ahk_exe brave.exe")
GroupAdd("Browsers", "ahk_exe vivaldi.exe")
GroupAdd("Browsers", "ahk_exe opera.exe")
GroupAdd("Browsers", "ahk_exe arc.exe")

GroupAdd("ElectronIDEs", "ahk_exe Code.exe")
GroupAdd("ElectronIDEs", "ahk_exe Code - Insiders.exe")
GroupAdd("ElectronIDEs", "ahk_exe Cursor.exe")
GroupAdd("ElectronIDEs", "ahk_exe Windsurf.exe")
GroupAdd("ElectronIDEs", "ahk_exe Antigravity.exe")

GroupAdd("JetBrainsIDEs", "ahk_exe rider64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe studio64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe webstorm64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe pycharm64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe goland64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe clion64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe phpstorm64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe rubymine64.exe")
GroupAdd("JetBrainsIDEs", "ahk_exe datagrip64.exe")

; ── Action Functions ───────────────────────────────────────────

NavigateBack() {
    if WinActive("ahk_group Browsers")
        Send('^{PgUp}')
    else if WinActive("ahk_group ElectronIDEs") || WinActive("ahk_exe zed.exe")
        Send('!{Left}')
    else if WinActive("ahk_exe devenv.exe") || WinActive("ahk_exe idea64.exe")
        Send('^{-}')
    else if WinActive("ahk_group JetBrainsIDEs")
        Send('^!{Left}')
}

NavigateForward() {
    if WinActive("ahk_group Browsers")
        Send('^{PgDn}')
    else if WinActive("ahk_group ElectronIDEs") || WinActive("ahk_exe zed.exe")
        Send('!{Right}')
    else if WinActive("ahk_exe devenv.exe") || WinActive("ahk_exe idea64.exe")
        Send('^+{-}')
    else if WinActive("ahk_group JetBrainsIDEs")
        Send('^!{Right}')
}

OpenNew() {
    if WinActive("ahk_group Browsers")
        Send('^{sc014}')  ; Ctrl+T
    else if WinActive("ahk_group ElectronIDEs") || WinActive("ahk_exe zed.exe")
        Send('^{sc031}')  ; Ctrl+N
    else if WinActive("ahk_group JetBrainsIDEs")
        Send('^+{sc015}')  ; Ctrl+Shift+Y
}

CloseTab() {
    if WinActive("ahk_group Browsers") || WinActive("ahk_group ElectronIDEs") || WinActive("ahk_exe zed.exe")
        Send('^{sc011}')  ; Ctrl+W
    else if WinActive("ahk_exe devenv.exe") || WinActive("ahk_group JetBrainsIDEs")
        Send('^{F4}')
}

; ── Global Hotkeys ─────────────────────────────────────────────

#c::Send('!n')
#`::Send('^+{F8}')
#z::WinSetAlwaysOnTop(-1, "A")

XButton1::Send('^{sc02E}')  ; Ctrl+C
XButton2::Send('+{Ins}')

CapsLock:: {
    SendEvent('{LWin Down}{Space Down}{Space Up}{LWin Up}')
    SetTimer(KeyboardLanguageColor, -50)
}

~XButton2 & WheelUp::AltTab
~XButton2 & WheelDown::ShiftAltTab

~LButton & ~RButton::Send("{Enter}")
~RButton & ~LButton::Send("{Delete}")

ScrollLock:: {
    static lastPress := 0
    now := A_TickCount
    if now - lastPress > 1000 {
        lastPress := now
        ToolTip("Press ScrollLock again to clock out and hibernate")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    lastPress := 0
    try {
        xhr := ComObject("WinHttp.WinHttpRequest.5.1")
        xhr.SetTimeouts(2000, 5000, 2000, 5000)
        xhr.Open("GET", "https://n8n.dmitrii.app/webhook/c542578f-d1e9-4ef5-90ce-b96e142a1526?action=off&source=home&checkin=meckano&notify=telegram", false)
        xhr.SetRequestHeader("User-Agent", "AutoHotkey")
        xhr.Send()
    } catch as err {
        MsgBox("Clock-out request failed: " . err.Message . "`nHibernate aborted.")
        return
    }
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 1)
}

SC068::Run("calc.exe")

!g:: {
    uuid := UUIDCreate()
    if !uuid
        return
    prevClip := ClipboardAll()
    A_Clipboard := StrLower(uuid)
    Send('+{Ins}')
    Sleep(50)
    A_Clipboard := prevClip
}

Pause::SwitchKeysLocale()

; ── Mouse Navigation ───────────────────────────────────────────

Browser_Back::
XButton1 & LButton::NavigateBack()

Browser_Forward::
XButton1 & RButton::NavigateForward()

LButton & XButton1::OpenNew()

XButton1 & MButton::CloseTab()

; ── Keyboard Language ──────────────────────────────────────────

KeyboardLanguageColor() {
    if !LangID := GetKeyboardLanguage(WinActive("A"))
        return
    if (LangID = 0x0409)
        SetLngColor(false)
    else if (LangID = 0x419)
        SetLngColor(true)
}

SetLngColor(ru) {
    if (ru)
        SetKeyColor(44, 0, 255, 255)
    else
        SetKeyColor(44, 0, 0, 0)
}

SetKeyColor(key, red, green, blue) {
    static prev := ""
    try {
        prev := ComObject("WinHttp.WinHttpRequest.5.1")
        prev.Open("POST", "http://localhost:5137/api/steelseries/key_color", true)
        prev.SetRequestHeader("Content-Type", "application/json")
        prev.Send('{"key":' . key . ',"red":' . red . ',"green":' . green . ',"blue":' . blue . '}')
    }
}

GetKeyboardLanguage(_hWnd := 0) {
    if !_hWnd
        ThreadId := 0
    else if !ThreadId := DllCall("user32.dll\GetWindowThreadProcessId", "Ptr", _hWnd, "UInt", 0, "UInt")
        return false
    if !KBLayout := DllCall("user32.dll\GetKeyboardLayout", "UInt", ThreadId, "Ptr")
        return false
    return KBLayout & 0xFFFF
}

SwitchKeysLocale() {
    TempClipboard := ""
    SelText := GetWord(&TempClipboard)
    if !SelText {
        A_Clipboard := TempClipboard
        return
    }
    Layout := ""
    A_Clipboard := ConvertText(SelText, &Layout)
    Send('+{Ins}')
    Sleep(50)
    SwitchLocale(Layout)
    Sleep(50)
    A_Clipboard := TempClipboard
    SetLngColor(Layout = "Lat")
}

GetWord(&TempClipboard) {
    TempClipboard := ClipboardAll()
    A_Clipboard := ""
    Send("^{vk43}")
    if ClipWait(0.15)
        return A_Clipboard

    Loop 9 {
        Send("^+{Left}^{vk43}")
        if !ClipWait(0.2)
            return

        if RegExMatch(A_Clipboard, "([ \t])", &Found) && A_Index != 1 {
            Send("^+{Right}")
            return SubStr(A_Clipboard, (Found.Pos[1] + 1) < 1 ? (Found.Pos[1] + 1) - 1 : (Found.Pos[1] + 1))
        }

        PrevClipboard := A_Clipboard
        A_Clipboard := ""
        Send("+{Left}^{vk43}")
        if !ClipWait(0.2)
            return

        if (StrLen(A_Clipboard) = StrLen(PrevClipboard)) {
            A_Clipboard := ""
            Send("+{Left}^{vk43}")
            if !ClipWait(0.2)
                return
            if (StrLen(A_Clipboard) = StrLen(PrevClipboard))
                return A_Clipboard
            else {
                Send("+{Right 2}")
                return PrevClipboard
            }
        }

        Send("+{Right}")
        s := SubStr(A_Clipboard, 1, 1)
        if RegExMatch(s, "^\s$") {
            A_Clipboard := ""
            Send("+{Left}^{vk43}")
            if !ClipWait(0.2)
                return
            return A_Clipboard
        }
        A_Clipboard := ""
    }
}

ConvertText(Text, &OppositeLayout) {
    static Layouts := Map(
        "Cyr", "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ/ёйцукенгшщзхъфывапролджэячсмитьбю,.`"№;?",
        "Lat", "~QWERTYUIOP{}ASDFGHJKL:`"ZXCVBNM<>|``qwertyuiop[]asdfghjkl;'zxcvbnm,.?/@#$&"
    )

    RegExReplace(Text, "i)[A-Z@#\$\^&\[\]'`\{}]", "", &LatCount)
    RegExReplace(Text, "i)[А-ЯЁ№]", "", &CyrCount)

    if (LatCount != CyrCount) {
        CurrentLayout := LatCount > CyrCount ? "Lat" : "Cyr"
        OppositeLayout := LatCount > CyrCount ? "Cyr" : "Lat"
    } else {
        threadId := DllCall("GetWindowThreadProcessId", "Ptr", WinExist("A"), "UInt", 0, "Ptr")
        landId := DllCall("GetKeyboardLayout", "Ptr", threadId, "Ptr") & 0xFFFF
        if (landId = 0x409)
            CurrentLayout := "Lat", OppositeLayout := "Cyr"
        else
            CurrentLayout := "Cyr", OppositeLayout := "Lat"
    }
    NewText := ""
    Loop Parse, Text
        NewText .= (found := InStr(Layouts[CurrentLayout], A_LoopField, 1))
            ? SubStr(Layouts[OppositeLayout], found, 1) : A_LoopField
    return NewText
}

SwitchLocale(Layout) {
    PostMessage(0x0050, 0, Layout = "Lat" ? 0x4090409 : 0x4190419, , "A")  ; WM_INPUTLANGCHANGEREQUEST
}

; ── Utilities ──────────────────────────────────────────────────

; https://github.com/cocobelgica/AutoHotkey-Util/blob/master/UUIDCreate.ahk
UUIDCreate(mode := 1, format := "") {
    uidCreate := "Rpcrt4\UuidCreate"
    if InStr("02", mode)
        uidCreate .= mode ? "Sequential" : "Nil"
    uuid := Buffer(16)
    if (DllCall(uidCreate, "Ptr", uuid) == 0)
        && (DllCall("Rpcrt4\UuidToString", "Ptr", uuid, "UInt*", &pString := 0) == 0) {
        str := StrGet(pString)
        DllCall("Rpcrt4\RpcStringFree", "UInt*", pString)
        if InStr(format, "U")
            DllCall("CharUpper", "Ptr", StrPtr(str))
        return InStr(format, "{") ? "{" . str . "}" : str
    }
}

; ── AppUserModelID: Separate/Rejoin Electron IDE Windows ───────

PSV := "c:\Tool\Win\PropertySystemView.exe"
SeparateId := "ElectronIDE.Separate"

DefaultAppIds := Map(
    "Code.exe",            "Microsoft.VisualStudioCode",
    "Code - Insiders.exe", "Microsoft.VisualStudioCode.Insiders",
    "Cursor.exe",          "Cursor.Cursor",
    "Windsurf.exe",        "Windsurf.Windsurf",
    "Antigravity.exe",     "Google.Antigravity",
)

#HotIf WinActive("ahk_group ElectronIDEs")

^!F12:: {
    hwnd := WinActive("A")
    if !hwnd || !FileExist(PSV) {
        MsgBox("Check PSV path or focus an Electron IDE window.")
        return
    }
    RunWait(Format('"{1}" /SetPropertyWindow {2:08X} "System.AppUserModel.ID" "{3}"', PSV, hwnd, SeparateId),, "Hide")
}

^!F11:: {
    hwnd := WinActive("A")
    if !hwnd || !FileExist(PSV) {
        MsgBox("Check PSV path or focus an Electron IDE window.")
        return
    }
    exeName := ProcessGetName(WinGetPID(hwnd))
    if !DefaultAppIds.Has(exeName) {
        MsgBox("Unknown AppUserModelID for " . exeName)
        return
    }
    RunWait(Format('"{1}" /SetPropertyWindow {2:08X} "System.AppUserModel.ID" "{3}"', PSV, hwnd, DefaultAppIds[exeName]),, "Hide")
}

#HotIf
