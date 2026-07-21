#Requires AutoHotkey v2.0
; Editor Anywhere - Emacs flavour
; Hotkey: Win+# in any text field
;   1. Copies current selection (or whole field) to a temp file
;   2. Opens it in a new emacsclient frame, blocks until the frame is closed
;   3. Pastes the edited text back into the original control

; --- config -------------------------------------------------------------
EMACSCLIENT := 'C:\Program Files\Emacs\emacs-30.2\bin\emacsclientw.exe'
TEMPDIR     := A_Temp
FILEEXT     := ".org"              ; or ".md"
; ------------------------------------------------------------------------

#SC02B::EditAnywhere()

EditAnywhere() {
    ; remember where we came from
    srcHwnd := WinGetID('A')

    ; stash and clear clipboard
    savedClip := ClipboardAll()
    A_Clipboard := ''

    ; try to grab a selection; if none, select all then copy
    Send '^c'
    if !ClipWait(0.4) {
        Send '^a'
        Sleep 30
        Send '^c'
        if !ClipWait(1.0) {
            TrayTip 'Editor Anywhere', 'Could not read text from focused control.', 3
            A_Clipboard := savedClip
            return
        }
    }

    original := A_Clipboard

    ; write to a temp .md file (change extension if you prefer .txt/.org)
    tmp := TEMPDIR '\editor-anywhere-' A_TickCount FILEEXT
    f := FileOpen(tmp, 'w', 'UTF-8')
    f.Write(original)
    f.Close()

    ; launch emacsclient: add -c for new frame, -a "" auto-start daemon if needed,
    ; the eval makes closing the frame (C-x #) return control to us.
    cmd := Format('"{1}" -a "" "{2}"', EMACSCLIENT, tmp)
    RunWait cmd, , 'Hide'

    ; read it back
    edited := FileRead(tmp, 'UTF-8')
    try FileDelete tmp

    ; nothing changed? bail without disturbing the field
    if (edited = original) {
        A_Clipboard := savedClip
        TrayTip 'Editor Anywhere', 'No changes.', 2
        return
    }

    ; push edited text via clipboard
    A_Clipboard := edited
    if !ClipWait(1.0) {
        TrayTip 'Editor Anywhere', 'Clipboard never populated.', 3
        return
    }

    ; refocus the source window and replace contents
    if WinExist('ahk_id ' srcHwnd) {
        WinActivate
        WinWaitActive 'ahk_id ' srcHwnd, , 1
    }
    Send '^a'
    Sleep 30
    Send '^v'
    Sleep 80

    ; restore original clipboard
    A_Clipboard := savedClip
}
#Requires AutoHotkey v2.0

