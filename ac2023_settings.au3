#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ #AutoIt3Wrapper_Icon=icons\vpn4_on.ico
;~ #AutoIt3Wrapper_Outfile=bin\vpn_connect.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=AutoCAD 2023 Settings Backup/Restore
#AutoIt3Wrapper_Res_Fileversion=1.0.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=AutoCAD 2023 Settings Backup
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0
#AutoIt3Wrapper_Res_CompanyName=V@no
#AutoIt3Wrapper_Res_LegalCopyright=©V@no 2023
#AutoIt3Wrapper_Res_Language=1033
;~ #AutoIt3Wrapper_Res_Icon_Add=icons\vpn4_on.ico
;~ #AutoIt3Wrapper_Res_Icon_Add=icons\vpn4_off.ico
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#NoTrayIcon
#RequireAdmin

AutoItSetOption("MustDeclareVars", 1)

#include <_debug.au3>
#include <file.au3>
#include <GUIConstantsEx.au3>
#include <GuiListBox.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>

Global $ini
initIni()
Global $registry[3][2] = [ _
        ["HKEY_LOCAL_MACHINE\SOFTWARE\Autodesk\AutoCAD\R24.2", "LM"], _
        ["HKEY_CURRENT_USER\SOFTWARE\Autodesk\AutoCAD\R24.2", "CU"], _
        ["HKEY_CURRENT_USER\SOFTWARE\AppDataLow\Software\Autodesk\AutoCAD\R24.2", "CUL"]]

Global $title = "AutoCAD 2023 Settings Backup"
Global $version = "1.0.0"
Global $minWidth = 350
Global $minHeight = 180
Global $width = _iniRead("w", $minWidth - 14)
Global $height = _iniRead("h", $minHeight - 14)
Global $left = _iniRead("x", -1)
Global $top = _iniRead("y", -1)
Global $aWin[5] = [$width, $height, $left, $top]
Global $filePrefix = 'acad2023_settings'
Global $sDir = @ScriptDir & '\settings\'
Global $sAppData = StringReplace(_PathFull(@ScriptDir & "..\C\"), "\", "\\")
Global $UserProfileDir = StringReplace(@UserProfileDir, "\", "\\")
Global $UserProfileDirDouble = StringReplace($UserProfileDir, "\", "\\")
Global $sAppDataDouble = StringReplace($sAppData, "\", "\\")
Global $mList[]
Global $aList
Global $gDeleteContext
Global $gFocusedControl

startup()

#Region ### START Koda GUI section ### Form=E:\dev\Apps\Autocad Backup\ac2023_settings.kxf
Global $hGUI = GUICreate($title & " v" & $version, $width, $height, $left, $top, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $DS_MODALFRAME))
GUISetFont(10, 400, 0, "Segoe UI")
Global $gList = GUICtrlCreateList("", 6, 0, $width - 14, $height - 62, BitOR($WS_BORDER, $WS_VSCROLL, $LBS_EXTENDEDSEL), 0)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM)
Global $hList = GUICtrlGetHandle($gList)
Global $gBackup = GUICtrlCreateButton("&Backup", 6, $height - 56, 75, 25, $BS_NOTIFY)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
Global $gRestore = GUICtrlCreateButton("&Restore", 86, $height - 56, 75, 25, $BS_NOTIFY)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
Global $gDelete = GUICtrlCreateButton("&Delete", 166, $height - 56, 75, 25, $BS_NOTIFY)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
Global $gStatus = GUICtrlCreateLabel("", 246, $height - 52, $width - 87 - 246, 18, $DT_PATH_ELLIPSIS)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKRIGHT + $GUI_DOCKHEIGHT)
Global $gExit = GUICtrlCreateButton("&Exit", $width - 82, $height - 56, 75, 25, $BS_NOTIFY)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)

Global $gListContext = GUICtrlCreateContextMenu($gList)
contextDeleteToggle()

Global $hDelKey = GUICtrlCreateDummy()
Local $AccelKeys[1][2] = [["{DELETE}", $hDelKey]]
GUISetAccelerators($AccelKeys)

showList()
toggleButtons()

GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")
GUIRegisterMsg($WM_CONTEXTMENU, "_WM_CONTEXTMENU") ;registering context menu event handler
GUIRegisterMsg($WM_GETMINMAXINFO, "_WM_GETMINMAXINFO")
GUIRegisterMsg($WM_MOVING, "_WM_MOVING")

_GUICtrlListBox_SetSel($gList, 0, True)
GUISetState(@SW_SHOW)

#EndRegion ### END Koda GUI section ###

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            _exit()

        Case $GUI_EVENT_MAXIMIZE
            $aWin[4] = 1
        Case $GUI_EVENT_RESTORE
            $aWin[4] = 0
        Case $GUI_EVENT_RESIZED
            _Resized()

    EndSwitch
WEnd

Func _exit()
    _iniWrite("w", $aWin[0])
    _iniWrite("h", $aWin[1])
    _iniWrite("x", $aWin[2])
    _iniWrite("y", $aWin[3])
    Exit
EndFunc   ;==>_exit

Func _iniRead($key, $def)
    Local $val = IniRead($ini, "General", $key, $def)
    If $val == "" Then $val = $def
    Return $val
EndFunc   ;==>_iniRead

Func _iniWrite($key, $val)
    Return IniWrite($ini, "General", $key, $val)
EndFunc   ;==>_iniWrite

Func _Resized() ; срабатывает один раз при изменении размера окна, но не при "Развернуть на весь экран", "Восстановить"
    Local $aClientSize = WinGetClientSize($hGUI) ; сохраняется размер клиентской области
    $aWin[0] = $aClientSize[0] + 2
    $aWin[1] = $aClientSize[1] + 25
;~ Local $aWinPos = WinGetPos($hGUI)
;~ $aWin[2] = $aWinPos[0]
;~ $aWin[3] = $aWinPos[1]
;~ debug("_Resized", $aWin)
EndFunc   ;==>_Resized

Func _WM_COMMAND($hWnd, $Msg, $wParam, $lParam)

    Local $nCode = BitShift($wParam, 16)        ; HiWord
    Local $nIDFrom = BitAND($wParam, 0xFFFF)    ; LoWord
    Local $sType = _WinAPI_GetClassName($nIDFrom)
    debug("WM_COMMAND", $nIDFrom, $nCode, $sType)

    If ($sType == "Button" And ($nCode == $BN_SETFOCUS Or $nCode == $BN_KILLFOCUS)) Or _
            ($sType == "ListBox" And ($nCode == $LBN_SETFOCUS Or $nCode == $LBN_KILLFOCUS)) Then
        $gFocusedControl = ControlGetFocus($hGUI)
        debug("$gFocusedControl", $gFocusedControl)
    Else
        Switch $nIDFrom
            Case $gExit
                _exit()

            Case $gRestore
                toggleButtons(False, False, False)
                settingsRestore($mList[GUICtrlRead($gList)])
                toggleButtons()
                ControlFocus($hGUI, "", $gFocusedControl)

            Case $gBackup
                toggleButtons(False, False, False)
                settingsBackup()
                showList()
                _GUICtrlListBox_SetSel($gList, 0, True)
                toggleButtons()
                ControlFocus($hGUI, "", $gFocusedControl)

            Case $gDelete, $gDeleteContext, $hDelKey
                Local $items = _GUICtrlListBox_GetSelItemsText($gList)
                If $gDelete Or $gDeleteContext Or (_WinAPI_GetFocus() = $hList) And $items[0] Then
                    settingsDelete($items)
                EndIf

            Case $gList
                Local $items = _GUICtrlListBox_GetSelItems($gList)

                toggleButtons(True, $items[0] == 1)
                Switch $nCode
                    Case $LBN_DBLCLK
                        settingsRestore($mList[GUICtrlRead($gList)])
                EndSwitch
        EndSwitch
    EndIf

    Return $GUI_RUNDEFMSG

EndFunc   ;==>_WM_COMMAND

Func _WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $wParam, $lParam
    If $wParam <> $hList Then Return $GUI_RUNDEFMSG ;we only going to handle context menu on list, all others carry on as is.

    Local $tPoint = _WinAPI_GetMousePos(True, $hList)
    Local $iY = DllStructGetData($tPoint, "Y")
    Local $index = -1
    For $i = 0 To $aList[0]
        Local $aRect = _GUICtrlListBox_GetItemRect($gList, $i)
        If ($iY >= $aRect[1]) And ($iY <= $aRect[3]) Then
            $index = $i
            Local $count = _GUICtrlListBox_GetCount($gList)
            If Not _GUICtrlListBox_GetSel($gList, $index) Then
                For $j = 0 To $count
                    _GUICtrlListBox_SetSel($gList, $j, $j == $index)
                Next
            EndIf
;~ _GUICtrlListBox_SetSel($gList, $index, true) ;set as current item
            ExitLoop
        EndIf
    Next
    If $index <> -1 Then
        If Not $gDeleteContext Then
            contextDeleteToggle()
        EndIf
    Else
        contextDeleteToggle(False)
    EndIf
    Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_CONTEXTMENU

Func _WM_GETMINMAXINFO($hWnd, $Msg, $wParam, $lParam)
    Local $minmaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
    DllStructSetData($minmaxinfo, 7, $minWidth) ; min X
    DllStructSetData($minmaxinfo, 8, $minHeight) ; min Y
;~ DllStructSetData($minmaxinfo,9,600) ; max X
;~ DllStructSetData($minmaxinfo,10,700) ; max Y
    Return 0
EndFunc   ;==>_WM_GETMINMAXINFO

Func _WM_MOVING($hWnd, $Msg, $wParam, $lParam)
    ; получаем координаты окна. Это нужно при закрытии свёрнутого скрипта
    Local $sRect = DllStructCreate("Int[4]", $lParam)
    $aWin[2] = DllStructGetData($sRect, 1, 1)
    $aWin[3] = DllStructGetData($sRect, 1, 2)
;~ debug("_WM_MOVING", $aWin)
    Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_MOVING

Func contextDeleteToggle($create = True)
    If $create Then
        $gDeleteContext = GUICtrlCreateMenuItem("&Delete", $gListContext) ; add "delete" option
    Else
        GUICtrlDelete($gDeleteContext) ;remove "delete" option
        $gDeleteContext = Null
    EndIf
EndFunc   ;==>contextDeleteToggle

Func fixPath($sPath)
    $sPath = StringRegExpReplace($sPath, "(?i)(\w:\\\\Users\\\\[^\\]+|%userprofile%)\\\\(AppData\\\\(Local|Roaming))", $sAppDataDouble & "$2")
    $sPath = StringRegExpReplace($sPath, "(?i)(\w:\\Users\\[^\\]+|%userprofile%)\\(AppData\\(Local|Roaming))", $sAppData & "$3")
    $sPath = StringRegExpReplace($sPath, "(?i)\w:\\\\Users\\\\[^\\]+", $UserProfileDirDouble)
    $sPath = StringRegExpReplace($sPath, "(?i)\w:\\Users\\[^\\]+", $UserProfileDir)
;~ debug("fixPath", $sPath)
    Return $sPath
EndFunc   ;==>fixPath

Func getList()
    Local $sList = ""
    Local $PID = Run(@ComSpec & ' /c DIR "' & $sDir & '" /B /A-D /O-D | findstr /m /i "^' & $filePrefix & '_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].*\.reg$" ', "", @SW_HIDE, 2) ; /O-D = newest first, 2 = $STDOUT_CHILD
    While Not @error
        $sList &= StdoutRead($PID)
    WEnd
    $sList = StringStripWS($sList, 7)
    debug($sList)
    Return $sList
;~ $sList = StringReplace(StringStripWS($sList, 7), @CR, "|")
;~ return StringSplit(StringStripWS($sList, 7), @cr, 2)
;~ return $sList
EndFunc   ;==>getList

Func initIni()
    Local $sName = StringLeft(@ScriptName, StringInStr(@ScriptName, ".", 2, -1) - 1)
    Local $sName2 = StringRegExpReplace($sName, "[\s_-]+v[0-9]+.*", "")
    $ini = @ScriptDir & "\" & $sName & ".ini"
    Local $ini2 = @ScriptDir & "\" & $sName2 & ".ini"
    Local $bIniExists = BitOR(FileExists($ini) ? 1 : 0, FileExists($ini2) ? 2 : 0)
    If $bIniExists = 2 Or Not $bIniExists Then $ini = $ini2

    If Not $bIniExists Then
        Local $f = FileOpen($ini, $FO_OVERWRITE + $FO_UNICODE)
        If $f <> -1 Then FileWrite($f, "")
        FileClose($f)
    EndIf
EndFunc   ;==>initIni

Func settingsBackup($file = Null)
;~ Func settingsBackup($file = $filePrefix & '.reg')
    If Not $file Then $file = 'acad2023_settings_' & @YEAR & @MON & @MDAY & '_' & @HOUR & @MIN & @SEC & '.reg'
    If Not FileExists($sDir) Then DirCreate($sDir)
    $file = $sDir & $file
    Local $return = ""
    For $i = 0 To UBound($registry) - 1
        ;~ ShellExecuteWait('REG', 'EXPORT "' & $registry[$i][0] & '" "' & $file & '" /y', "", "", @SW_HIDE)
        runCmd('REG EXPORT "' & $registry[$i][0] & '" "' & $file & '" /y')
        Local $text = FileRead($file)
        If Not $return Then
            $return = StringLeft($text, StringInStr($text, @CRLF, 0, 1) + 2)
        EndIf
        $text = StringRight($text, StringLen($text) - StringInStr($text, @CRLF, 0, 1))
;~ $text = StringRegExpReplace($text, "(?i)(\w:\\\\Users\\\\)[^\\]+(\\\\AppData\\\\(?:Local|Roaming)\\\\(?!temp).*)", "\1$_USERNAME_$\2")
        $return &= @CRLF & @CRLF & @CRLF & ";------------- [ " & $registry[$i][1] & " ] -------------" & @CRLF & @CRLF & @CRLF
        $return &= $text
    Next
    Local $fh = FileOpen($file, 2)
    FileWrite($file, $return)
    debug("backup")
    debug($file)
    FileClose($fh)
EndFunc   ;==>settingsBackup

Func settingsDelete($aFiles)
    Local $title = _ArrayToString($aFiles, @CRLF, 1)
    Local $res = MsgBox($MB_ICONWARNING + $MB_OKCANCEL + $MB_DEFBUTTON2 + $MB_SYSTEMMODAL + $MB_TASKMODAL, "Are you sure?", "Delete" & @CRLF & $title, 0, $hGUI)
    debug("settingsDelete", "$res", $res)
    If $res == $IDYES Or $res == $IDOK Then
        toggleButtons(True, False, False)
        Local $items = _GUICtrlListBox_GetSelItems($gList)
        debug($items)
        For $i = 1 To $aFiles[0]
            Local $sFile = $mList[$aFiles[$i]]
            Local $res = FileRecycle($sDir & $sFile)
            debug("settingsDelete()", $sFile, $res, @error)
        Next
        showList()
        Local $last = $items[$items[0]] - $items[0] + 1
        debug($last, $items[$items[0]])
        If $last < 0 Then $last = 0
        _GUICtrlListBox_SetSel($gList, $last, True)
        toggleButtons()
        ControlFocus($hGUI, "", $gFocusedControl)
    EndIf
EndFunc   ;==>settingsDelete

Func settingsRestore($sFile = Null)
    debug("restore", $sFile)
    If Not $sFile Then
        Local $hSearch = FileFindFirstFile($sDir & $filePrefix & "*.reg")
        Local $sFileName = ""
        Local $iFileMtime
        While 1
            $sFileName = FileFindNextFile($hSearch, 1)
            If @error Then ExitLoop
            Local $iMtime = FileGetTime($sDir & $sFileName, 0, 1)
            If $iMtime > $iFileMtime Then
                $iFileMtime = $iMtime
                $sFile = $sFileName
            EndIf
        WEnd
    EndIf
;~ debug($sFile)
    If Not $sFile Then
        Return Null
    EndIf
    Local $sData = FileRead($sDir & $sFile)
    Local $iStart = 1
    Local $iEnd = 1
    Local $iLen = 0
    Local $sValue
    Local $sHex
    Local $sString
;~ local $i = 100
    debug($sFile)
    $sData = fixPath($sData)
    While $iStart
        $iStart = StringInStr($sData, '"=hex(2):', 1, 1, $iStart)
        If Not $iStart Then ExitLoop
        $iStart += 9
        $iEnd = $iStart
        $sValue = ""
        $sHex = ""
        Do
            Local $iLine = StringInStr($sData, @LF, 0, 1, $iEnd)
            $sHex = StringMid($sData, $iStart, $iLine - $iStart)
            $iEnd = $iStart + StringLen($sHex) + 2
            $sValue = StringStripWS($sHex, 8)
;~ debug("Hex", $iBin, stringreplace($sHex, @crlf, "\r\n"))
            If StringRight($sValue, 1) <> "\" Then ExitLoop
        Until Not $iLine
        $sValue = StringReplace($sValue, "\", "")
        $sValue = StringReplace($sValue, ",", "")
        $sValue = StringRegExpReplace($sValue, "0000$", "")
        $sString = BinaryToString(Binary("0x" & $sValue), 2)
        debug("$sValue", Hex($iStart), Hex($iEnd), $sValue)
        debug($sString)
        Local $_sData = StringLeft($sData, $iStart - 1)
        $sString = fixPath($sString)
        $sString = StringRegExpReplace(StringMid(StringToBinary($sString, 2), 3), "..\K(?!$)", ",") & ",00,00"
        $_sData &= $sString
        $_sData &= StringRight($sData, StringLen($sData) - $iStart - StringLen($sHex))
        $sData = $_sData
;~ debug("$sData", $sData)
        $iStart += StringLen($sString)
        debug("----------------------------------------------------------------")
;~ If Not $i Then Return
;~ $i -= 1
    WEnd
    local $sFilePath = @TempDir & "\~" & stringleft($sfile, StringLen($sfile) - 4)
    local $sTempName = "_"
    While StringLen($sTempName) < 4
        $sTempName &= StringRegExpReplace(Chr(Random(48, 122, 1)), "[^0-9a-zA-Z]", "")
    WEnd
    $sFilePath &= $sTempName & stringright($sfile, 4)
    local $hFile = FileOpen($sFilePath, 2)
    FileWrite($sFilePath, $sData)
    FileClose($hFile)
    runCmd('REG IMPORT "' & $sFilePath & '"', true)
    FileDelete($sFilePath)
    debug($sFilePath)
EndFunc   ;==>settingsRestore

Func showList($sList = null, $sSelect = Null)
    if $sList == null then $sList = getList()
    $aList = StringSplit($sList, @CR, 1)
    Global $mList[]
    Local $sListDisplay = ""
    For $i = 1 To $aList[0]
        Local $name = StringRegExpReplace($aList[$i], "^" & $filePrefix & "_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})(.*)\.reg", "$1-$2-$3 $4:$5:$6$7")
        $sListDisplay &= @CR & $name
        $mList[$name] = $aList[$i]
    Next
    debug($sListDisplay)
    GUICtrlSetData($gList, StringReplace($sListDisplay, @CR, "|"))
    _GUICtrlListBox_SelectString($gList, $sSelect)
EndFunc   ;==>showList

;~ settingsRestore()
;~ settingsBackup()

func runCMD($cmd, $isAdmin = false)
    local $iPID
    if $isAdmin Then
        $iPID = Run($cmd, "", @SW_HIDE, $STDERR_MERGED)
    else
        $iPID = Run($cmd, "", @SW_HIDE, $STDERR_MERGED)
    EndIf
    Local $sOutput = ""
    While 1
            $sOutput &= StdoutRead($iPID)
            If @error Then ; Exit the loop if the process closes or StdoutRead returns an error.
                    ExitLoop
            EndIf
    WEnd
    debug("$sOutput", StringStripWS($sOutput, 3))
    statusShow($sOutput)
    return $sOutput
Endfunc

func statusShow($txt)
    GUICtrlSetData($gStatus, $txt)
    GUICtrlSetTip($gStatus, $txt)
EndFunc

Func startup()
    debug("startup", $cmdLine)
    Local $i, $command, $data, $len
    Local $cmd[1][2] = [[0, 0]]
    For $i = 1 To $CmdLine[0]
        $command = StringRegExpReplace($CmdLine[$i], "^[\\-]", "")
        If $command <> $CmdLine[$i] Then
            $cmd[0][0] += 1
            ReDim $cmd[$cmd[0][0] + 1][2]
            $cmd[$cmd[0][0]][0] = $command
            Local $data[0]
            $cmd[$cmd[0][0]][1] = $data
        Else
            $data = $cmd[$cmd[0][0]][1]
            $len = UBound($data)
            ReDim $data[$len + 1]
            $data[$len] = $command
            $cmd[$cmd[0][0]][1] = $data
        EndIf
    Next
    Local $isCMD = False
    For $i = 1 To $cmd[0][0]
        $command = $cmd[$i][0]
        $data = $cmd[$i][1]
        debug($command, $data)
        Switch $command
            Case "backup"
                settingsBackup(UBound($data) ? $data[0] : Null)
                $isCMD = True
            Case "restore"
                settingsRestore(UBound($data) ? $data[0] : Null)
                $isCMD = True
        EndSwitch
    Next
    If $isCMD Then _exit()
EndFunc   ;==>startup

Func toggleButtons($bBackup = True, $bRestore = True, $bDelete = True)
    GUICtrlSetState($gBackup, $bBackup ? $GUI_ENABLE : $GUI_DISABLE)
    GUICtrlSetState($gRestore, $bRestore ? $GUI_ENABLE : $GUI_DISABLE)
    GUICtrlSetState($gDelete, $bDelete ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc   ;==>toggleButtons
