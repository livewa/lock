	#NoEnv
	#WinActivateForce
	#SingleInstance, Force
	#Include C:\Program Files\AutoHotkey\Lib\tf.ahk
	#include C:\Program Files\AutoHotkey\Lib\Gdip_All.ahk
	#include C:\Program Files\AutoHotkey\Lib\Gdip_ImageSearch.ahk
	#NoTrayIcon
	#InstallKeybdHook
	DetectHiddenWindows, On
	DetectHiddenWindows, On
	DetectHiddenText, On
	SetTitleMatchMode, 2
	SetBatchLines, -1
	SetControlDelay -1
	SendMode Input
	SetWorkingDir %A_ScriptDir%
	SysGet, wFrame, 7
	SysGet, wCaption, 4
	Global wFrame
	Global wCaption
	Global BreakPoint := true
	Global WinList := []
	Global AIMP_POS := []
	Global CurrentWin 
	Global delayT = 200
	Global last_b_down := A_TickCount
	Global last_b_up := A_TickCount
	Global kakaoRun := false
	x = 1920
	y = 0
	VarSetCapacity(APPBARDATA, A_PtrSize=4 ? 36:48) ; for autohide
	; Run, "D:\Archive\_Ref Tools\Instant applications\jwShiftSpaceKey.exe",, hide
	gosub SyncToyCmd
	SetTimer, SyncToyCmd, 3600000
	SetTimer, CloseWindows, 200
	WinClose, Remote for Windows	
	logMsg := ""

	loop {		
		Process, Exist, MinAll.exe
		If ErrorLevel {
			logMsg := ""
			TimeIdle := A_TimeIdleKeyboard
			BreakPoint := false
			ClickIndex = 0
			WinList := []
			MinimizeAll()
			SystemCursor("Off")
			MouseGetPos, xpos, ypos
			if (ypos > 1000) {
				MouseMove, xpos, 999
			}
			WinHide, ahk_class Shell_TrayWnd
			WinHide, Start ahk_class Button
			Loop {
				if (TimeIdle > A_TimeIdleKeyboard) {
					BreakPoint := true
					logMsg := logMsg "`nTimeIdle:" TimeIdle
				}
				if (BreakPoint != false) {
					WinShow, ahk_class Shell_TrayWnd
					WinShow, Start ahk_class Button
					SystemCursor("On")
					RestoreAll()
					break
				} else {
					ClickIndex++
					Sleep, 100
					if (A_Index == 10 or A_Index == 30 or A_Index == 60 or ClickIndex > 300){
						MouseClick, left
						ClickIndex := 0
					}
				}
			}
		}
		deskTopClean()
		Sleep, 100		
	}
return

deskTopClean() {
	if FileExist("C:\Users\livew\Desktop\Roblox Studio.lnk") {
		FileDelete, C:\Users\livew\Desktop\Roblox Studio.lnk
	}
}

GoogleDriveNoticeClose() {
	WinGet, id, list, , , Program Manager
	Loop, %id%
	{
		this_ID := id%A_Index%
		WinGetTitle, title, ahk_id %this_ID%
		If InStr(title, "백업 및 동기화") {
			WinGetText, OutputVar , ahk_id %this_ID%
			if Instr(OutputVar, "데스크톱용 Google Drive 출시 예정") and not Instr(OutputVar, "업데이트됨")
				WinClose, ahk_id %this_ID%
		}
	}
}

*XButton1::
if (A_TickCount - last_b_down >= delayT && A_TickCount - last_b_up >= delayT) {
	Send {Blind}{XButton1 Down}
  last_b_down := A_TickCount
} else
	writeLog("XButton1 Down Chatter " A_TickCount - last_b_down ", " A_TickCount - last_b_up)
	
return

*XButton1 up::
if (A_TickCount - last_b_up >= delayT) {
  Send {Blind}{XButton1 Up}
	Sleep, 10
  last_b_up := A_TickCount
} else
	writeLog("XButton1 UP Chatter " A_TickCount - last_b_up)
return

Global Xbutton2Down = false
~XButton2::
return

~LButton::
	BreakPoint := true
return

~RButton::
	BreakPoint := true
return

#!PgDn::
	kakaoRun := !kakaoRun
	kakaoStat := % kakaoRun ? "True" : "False"
	msgBox, , , % kakaoStat , 1
return

#!Space::
	if not WinExist("다음 국어사전")
		RunWait, "C:\Program Files\Vivaldi\Application\vivaldi.exe" "--app=https://small.dic.daum.net/index.do?dic=kor",, hide
	WinRestore, 다음 국어사전
	WinMove, 다음 국어사전,, 1528, 512, 395, 533
	WinActivate, 다음 국어사전
	

return

ScrollLock::
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 ; ABM_GETSTATE
					, "Ptr", &APPBARDATA
					, "Int")
				    ? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40) ; 2 - ABS_ALWAYSONTOP, 1 - ABS_AUTOHIDE
	, DllCall("Shell32\SHAppBarMessage", "UInt", 10 ; ABM_SETSTATE
				, "Ptr", &APPBARDATA)
	KeyWait, % A_ThisHotkey
return

RemoveToolTip:
	ToolTip
return

SyncToyCmd:
	Run, "C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" -R,, hide
	if FileExist("E:\Temp\Torrents\*.torrent") {		
		FileDelete, E:\Temp\Torrents\*.torrent
	}
	gosub EmptyFolderRemove
return

CloseWindows:
	CloseWindow()
	GoogleDriveNoticeClose()
return

EmptyFolderRemove:
	targetList := []
	targetList.push("C:\MSI")
	targetList.push("D:\Work\VideoProc")
	targetList.push("D:\Creative Cloud Files")
	targetList.push("E:\Mp3\VideoProc")
	
	for k, v in targetList {
		if FileExist(v) {
			emptyFolderCleaning(v)
			FileRemoveDir, % v
		}
	}
return

MinimizeAll() {
	WinGet, CurrentWin ,, A
	DetectHiddenWindows Off	
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%
		If NOT IsWindow(WinExist("ahk_id" . this_ID))
			continue
		WinGet, WinState, MinMax, ahk_id %this_ID%
		If (WinState = -1)
			continue
		WinGetTitle, title, ahk_id %this_ID%		
		If (title = "AIMP") {
			WinHide, AIMP
		} else If (title = "")
			continue
		WinMinimize, ahk_id %this_ID%
		WinList.Insert(this_ID)
	}
	
}

RestoreAll() {	
	DetectHiddenWindows Off	
	WinGet, id, list	
	Loop, %id%
	{
		this_ID := id%A_Index%
		If NOT IsWindow(WinExist("ahk_id" . this_ID))
			continue
		WinGet, WinState, MinMax, ahk_id %this_ID%
		If (WinState != -1)
			continue
		WinGetTitle, title, ahk_id %this_ID%
		If (title = "")
			continue
		for Index, saveID in WinList {
			if (saveID = this_ID){
				WinRestore, ahk_id %this_ID%
			}
		}
	}
	WinShow, AIMP	
	WinActivate ahk_id %CurrentWin%
}

IsWindow(hWnd) {
    WinGet, dwStyle, Style, ahk_id %hWnd%
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
			return false
    }
    WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
    if (dwExStyle & 0x00000080) {
			return false
    }
    WinGetClass, szClass, ahk_id %hWnd%
    if (szClass = "TApplication") {
			return false
    }
    return true
}

writeLog(string="", fileName="Log") {
	; DirectoryName = %A_DeskTop%\LogTemp
	; IfNotExist, %DirectoryName%
		; FileCreateDir, %DirectoryName%	
	; FileGetSize, logSize, %A_Desktop%\%fileName%.txt, K
	FormatTime, DateNow, YYYYMMDDHH24MISS,MM/dd HH:mm.ss
	WriteLogTemp := string
	x := DateNow " " string "`n"
	; FileAppend, %x%, %A_Desktop%\%fileName%.txt
	FileAppend, %x%, %A_ScriptDir%\%fileName%.txt
}

CloseWindow() {
	Winclose, Steam - 뉴스
	Winclose, Steam - News
	Winclose, CrashReporter	
	close_targetList := ["CrashReporter"
						,"Explorer.EXE"
						,"nProtect Online Security V1.0 설치"
						,"TouchEn nxKey"
						,"Delfino G3 (x86) 제거"
						,"CrossEX Service UnInstall"
						,"Veraport-x64 제거"
						,"I3GSvcManager"
						,"악성 웹 사이트 탐지 서비스(APS Engine) 1.8.0 제거"
						,"VestCert"
						,"WIZVERA Process Manager 제거"]
	WinGet, id, list
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%
		WinGetTitle, title, ahk_id %this_ID%
		for k, v in close_targetList {
			if InStr(title, v) and InStr(v, title) {
				WinActivate, %title%
				IfWinActive, %title% 
				{
					Send, {y}
					Send, {Enter}
					Sleep, 1200
				}
			}	
		}
	}
}

SystemCursor(OnOff=1) {   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
	static AndMask, XorMask, $, h_cursor
			,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
			, b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
			, h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
	if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
	{
		$ = h                                          ; active default cursors
		VarSetCapacity( h_cursor,4444, 1 )
		VarSetCapacity( AndMask, 32*4, 0xFF )
		VarSetCapacity( XorMask, 32*4, 0 )
		system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
		StringSplit c, system_cursors, `,
		Loop %c0%
		{
			h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
			h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
			b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0, "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
		}
	}
	if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
			$ = b  ; use blank cursors
	else
			$ = h  ; use the saved cursors

	Loop %c0%
	{
		h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
		DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
	}
}

emptyFolderCleaning(Folder) {
	; FileSelectFolder, Folder, , % (Del:=0), Purge Empty Folders
	If ( ErrorLevel Or Folder="" )
		Return
	Loop, %Folder%\*, 2, 1
		FL .= ((FL<>"") ? "`n" : "" ) A_LoopFileFullPath
	Sort, FL, R D`n ; Arrange folder-paths inside-out
	Loop, Parse, FL, `n
	{
		; msgbox, %A_LoopField%
		FileRemoveDir, %A_LoopField% ; Do not remove the folder unless is  empty
		If ! ErrorLevel
				 Del := Del+1,  RFL .= ((RFL<>"") ? "`n" : "" ) A_LoopField
	}
	; MsgBox, 64, Empty Folders Purged : %Del%, %RFL%
}

/* MinAll.ahk source
	#NoEnv
	#WinActivateForce
	#SingleInstance, Force
	#NoTrayIcon
	SetWorkingDir %A_ScriptDir%
	Sleep, 6000
	ExitApp
	exit 
	return
*/
