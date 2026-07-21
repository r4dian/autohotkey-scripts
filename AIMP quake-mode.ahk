#Requires AutoHotkey v2.0

CoordMode("Mouse", "Screen")

; Win+Alt+A -> expand AIMP from its floating/compact mode ( win-alt- is a bit awkward, but matches OneCommander's Win-Alt-E...) )
#!a:: {
    ; Save current mouse position
    MouseGetPos(&origX, &origY)

    ; Move to top-centre of primary monitor to trigger the arrow to appear
    triggerX := A_ScreenWidth // 2
    triggerY := 2
    MouseMove(triggerX, triggerY, 0)  ; instant move (speed 0)

    ; Wait up to 1.5s for the floating arrow window to appear
    hWnd := 0
    loop 30 {
        hWnd := WinExist("ahk_class TASEFloatArrow ahk_exe AIMP.exe")
        if hWnd
            break
        Sleep(50)
    }

    if !hWnd {
        MouseMove(origX, origY, 0)
        MsgBox("AIMP floating arrow did not appear.")
        return
    }

    ; Get the arrow window's position and click its centre
    WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hWnd)
    clickX := wx + ww // 2
    clickY := wy + wh // 2
    Click(clickX, clickY)

    Sleep(100)
    MouseMove(origX, origY, 0)
}
