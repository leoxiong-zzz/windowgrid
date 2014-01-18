#SingleInstance, Force
#NoTrayIcon
#NoEnv
SetBatchLines, -1

Gui, -Caption +E0x80000 +E0x20 +Hwndhwnd +LastFound +ToolWindow +AlwaysOnTop
Gui, Show, Hide

screenWidth := A_ScreenWidth
screenHeight := A_ScreenHeight

OnExit, exit

x := 0
y := 0
w := screenWidth
h := screenHeight

pToken := Gdip_Startup()
hbm := CreateDIBSection(screenWidth, screenHeight)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
pGraphics := Gdip_GraphicsFromHDC(hdc)

Gdip_SetSmoothingMode(pGraphics, 4)

pBrush := Gdip_BrushCreateSolid("0x330000ff")

UpdateLayeredWindow(hwnd, hdc, 0, 0, screenWidth, screenHeight)

return
#m::
Hotkey, Left, key, On
Hotkey, Right, key, On
Hotkey, Up, key, On
Hotkey, Down, key, On
Hotkey, Enter, move, On
Hotkey, ^Left, key, On
Hotkey, ^Right, key, On
Hotkey, ^Up, key, On
Hotkey, ^Down, key, On

x := 0
y := 0
w := screenWidth / 2
h := screenHeight / 2

Gui, Show, NoActivate

gosub, key

return
key:
/*
x := (x := (A_ThisHotkey = "^Left" ? x - w : (A_ThisHotkey = "^Right" ? x + w : x))) < 0 ? 0 : (x > screenWidth - w ? screenWidth - w := y: x)
y := (y := (A_ThisHotkey = "^Up" ? y - h : (A_ThisHotkey = "^Down" ? y + h : y))) < 0 ? 0 : (y > screenHeight - h ? screenHeight - h : y)
w := (w := Round((A_ThisHotkey = "Left" ? w / 2 : (A_ThisHotkey = "Right" ? w * 2 : w)))) > screenWidth ? screenWidth : w
h := (h := Round((A_ThisHotkey = "Up" ? h / 2  : (A_ThisHotkey = "Down" ? h * 2 : h)))) > screenHeight ? screenHeight : h
*/

x := (x := (A_ThisHotkey = "Left" ? x - w : (A_ThisHotkey = "Right" ? x + w : x)))
if (x < 0) {
    x := 0
    w := w / 2
}
y := (y := (A_ThisHotkey = "Up" ? y - h : (A_ThisHotkey = "Down" ? y + h : y)))
if (y < 0) {
    y := 0
    h := h / 2
}
w := (w := Round((A_ThisHotkey = "^Left" ? w / 2 : (A_ThisHotkey = "^Right" ? w * 2 : w))))
if (w + x > screenWidth) {
    w := w / 2
    x := screenWidth - w
}
h := (h := Round((A_ThisHotkey = "^Up" ? h / 2 : (A_ThisHotkey = "^Down" ? h * 2 : h))))
if (h + y > screenHeight) {
    h := h / 2
    y := screenHeight - h
}

Gdip_GraphicsClear(pGraphics)
Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
UpdateLayeredWindow(hwnd, hdc)

return
move:
win := WinExist("A")
WinMove, ahk_id %win%,, %x%, %y%, %w%, %h%
if (A_TimeSincePriorHotkey < 500 and A_PriorHotkey = A_ThisHotkey){
    Hotkey, Left,, Off
    Hotkey, Right,, Off
    Hotkey, Up,, Off
    Hotkey, Down,, Off
    Hotkey, Enter,, Off
    Hotkey, ^Left,, Off
    Hotkey, ^Right,, Off
    Hotkey, ^Up,, Off
    Hotkey, ^Down,, Off
    Gui, Show, Hide
}

return
Esc::
Exit:
GuiClose:
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
ExitApp

;#Include Gdip.ahk