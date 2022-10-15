;; Env config
	#NoEnv
	#WinActivateForce
	#SingleInstance, Force
	#Include C:\Program Files\AutoHotkey\Lib\tf.ahk
	#Include C:\Program Files\AutoHotkey\Lib\Gdip_All.ahk
	#Include C:\Program Files\AutoHotkey\Lib\Gdip_ImageSearch.ahk
	#Include %A_ScriptDir%\ahks\_VD.ahk
	#NoTrayIcon
	#InstallKeybdHook
	#KeyHistory, 0
	#MaxHotkeysPerInterval, 120

;; code config	
	ListLines, Off
	DetectHiddenText, On
	SetTitleMatchMode, 2
	SetWinDelay, -1
	SetBatchLines, -1
	SetControlDelay -1
	SendMode Input
	CoordMode, Mouse, Client
	CoordMode, Pixel, Client
	SetWorkingDir %A_ScriptDir%
	SysGet, wFrame, 7
	SysGet, wCaption, 4
	; DetectHiddenWindows, On	

;; Global VARs 
	Global wFrame, wCaption
	Global wCaption
	Global BreakPoint := true
	Global WinList := []
	Global AIMP_POS := []
	Global delayT = 200
	Global delayTR = 300
	Global delayTL = 70
	Global CCTVscanTimer_Interval := 1000*10*3
	Global last_b_down := A_TickCount
	Global last_b_up := A_TickCount
	Global CCTVscanTimer := A_TickCount - CCTVscanTimer_Interval
	Global robloxUpdateCheck := false
	Global KakaoTime = 0
	Global KTCallManagerTime = 0
	Global logMsg := ""
	Global adjVolume = 3

;; Prep Codes
	PIDS := DllCall("GetCurrentProcessId")
	Gdip_Startup()
	VD.init()
	VarSetCapacity(APPBARDATA, A_PtrSize=4 ? 36:48) ; for SystemCursor autohide
	; Run, "D:\Archive\_Ref Tools\Instant applications\jwShiftSpaceKey.exe",, hide
	SystemCursor("Off")	
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 , "Ptr", &APPBARDATA, "Int") ? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40), DllCall("Shell32\SHAppBarMessage", "UInt", 10, "Ptr", &APPBARDATA)
	Sleep, 50
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 , "Ptr", &APPBARDATA, "Int") ? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40), DllCall("Shell32\SHAppBarMessage", "UInt", 10, "Ptr", &APPBARDATA)
	SystemCursor("On")
	WinClose, Remote for Windows
	SetTimer, CleanWindows, 200
	SetTimer, EmptyFolderRemove, 600
	SetTimer, SyncToyCmd, 3600000
	gosub EmptyFolderRemove
	gosub SyncToyCmd
	;runStartApps()	

;; Loop Core
	loop {
		if !(FollowMouse()[1] = "iVMS-4200") {
			Process, Exist, MinAll.exe
			If ErrorLevel {
				logMsg := ""
				TimeIdle := A_TimeIdleKeyboard
				BreakPoint := false
				ClickIndex = 0
				MinimizeAll()
				SystemCursor("Off")
				WallpaperEngine()
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
						Sleep, 10
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
		}
		Sleep, 100				
	}
return

;; Mouse Double click prevent
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

*XButton2::
	if (A_TickCount - last_b_down >= delayT && A_TickCount - last_b_up >= delayT) {
		Send {Blind}{XButton2 Down}
		last_b_down := A_TickCount
	} else
	writeLog("XButton2 Down Chatter " A_TickCount - last_b_down ", " A_TickCount - last_b_up)
return

*XButton2 up::
	if (A_TickCount - last_b_up >= delayT) {
		Send {Blind}{XButton2 Up}
		Sleep, 10
		last_b_up := A_TickCount
	} else 
	writeLog("XButton2 UP Chatter " A_TickCount - last_b_up) 
return

*RButton::
	if (A_TickCount - last_b_down >= delayTR && A_TickCount - last_b_up >= delayTR) {
		Send {Blind}{RButton Down}
		last_b_down := A_TickCount
	} else
	writeLog("RButton Down Chatter " A_TickCount - last_b_down ", " A_TickCount - last_b_up)
return

*RButton up::
	if (A_TickCount - last_b_up >= delayTR) {
		Send {Blind}{RButton Up}
		Sleep, 50
		last_b_up := A_TickCount
	} else
	writeLog("RButton UP Chatter " A_TickCount - last_b_up)
return

~LButton::
	BreakPoint := true
return

~RButton::
	BreakPoint := true
return

~MButton::
	if ProcessExist("iVMS-4200.Framework.C.exe"){
		UnderMouse := FollowMouse()
		Title := UnderMouse[1]
		WinGetTitle, TitleA, A
		If (Title = "iVMS-4200") or ((Title = "") and (TitleA = ""))  {
			desktopNumber_Now := VD.getCurrentDesktopNum()
			targetDeskTop := (desktopNumber_Now = 1) ? 2 : 1
			VD.goToDesktopNum(targetDeskTop)
			; CloseCCTV(true)
		}
	}
return

;; Move to other vertual desktop 
#1::
	VD.goToDesktopNum(1) 
return

#2::
	VD.goToDesktopNum(2) 
return

#3::
	VD.goToDesktopNum(3) 
return

;; Open Dictionary 
#!Space::
	runDic("다음 국어사전", " --app=https://small.dic.daum.net/index.do?dic=kor")	
return

;; Open Translator 
^#!Space::
	runDic("Papago", " --app=https://papago.naver.com")
return

;; Window Callender Show/Hide
#C::
	Send #n
return

;; Chrome backward & Mouse Cursor default
*F1::
	SetKeyDelay -1
	If WinActive("ahk_exe chrome.exe") {
		Send, {XButton1 Down}
		SetSystemCursor()
	} else if (FollowMouse()[1] = "iVMS-4200") {
		CloseCCTV(true)
	} else {
		Send {Blind}{F1 Down}
	}
return

*F1 up::
	SetKeyDelay -1
	If WinActive("ahk_exe chrome.exe") {
		Send, {XButton1 Up}
	} else if WinActive("ahk_exe iVMS-4200.Framework.C.exe") {
		
	} else {
		Send {Blind}{F1 Up}
	}
	RestoreCursors()
return

;; AHK exit & open fodler
#F10::	
	winExist := false
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%
		WinGet, ahk_exe, ProcessName, ahk_id %this_ID%
		WinGetTitle, title, ahk_id %this_ID%
		WinGetClass, this_class, ahk_id %this_ID% 
		If  (ahk_exe = "explorer.exe") and (title = "_Ref Tools") {
			winExist := true
		}
	}
	if (winExist=false) {
		explorerpath:= "explorer /e, " "D:\Archive\_Ref Tools"
		Run, %explorerpath%
	}
	ExitApp
return

;; Current window size adjust
#F11::
	WinGetTitle, OutputVar, A
	WinGetPos, X, Y, Width, Height, %OutputVar%
	WinMove, %OutputVar%, , 0, 200, 2040, 1440
return

;; Current window size adjust
^#F11::
	WinGetTitle, OutputVar, A
	WinGetPos, X, Y, Width, Height, %OutputVar%
	WinMove, %OutputVar%, , 2026, 378, 1814, 1415
return

;; Autohide taskbar Show/Hide Toggle
#F12::
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 , "Ptr", &APPBARDATA, "Int") ? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40), DllCall("Shell32\SHAppBarMessage", "UInt", 10, "Ptr", &APPBARDATA)
	KeyWait, % A_ThisHotkey
return

;; Volume adjust amount control
$Volume_Up::
	SoundGet, volume
	Send {Volume_Up}
	SoundSet, volume + adjVolume
Return

$Volume_Down::
	SoundGet, volume
	Send {Volume_Up}
	SoundSet, volume - adjVolume
Return

RemoveToolTip:
	ToolTip
return

SyncToyCmd:
	Run, "C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" -R,, hide
	if FileExist("E:\Temp\Torrents\*.torrent") {		
		FileDelete, E:\Temp\Torrents\*.torrent
	}
return

CleanWindows:
	CloseWindow()
	CloseCCTV()
	KT_CallCheck()
	GoogleDriveNoticeClose()
	PipMove()
	KakaoCheck()
	deskTopClean()
	HIGHDPIAWARE()
	CloseAdobeTrash()
return

EmptyFolderRemove:
	targetList := ["C:\Logs"
		, "C:\Temp"
		, "C:\MSI"]
	for k, v in targetList {
		ClearInsideFolder(v)
		FileRemoveDir, %v%, 1
	}

	targetList := ["D:\AppData"
		, "D:\Work\VideoProc"
		, "D:\Creative Cloud Files"
		, "D:\Work\사용자 지정 Office 서식 파일"
		, "E:\Mp3\VideoProc"]
	
	for k, v in targetList {
		if FileExist(v) {
			emptyFolderCleaning(v)
			FileRemoveDir, % v
		}
	}
	;emptyFolderCleaning("C:\")
return

ClearInsideFolder( folderpath ) {
    FileDelete, %folderpath%\*.*
    Loop, %folderpath%\*.*, 2, 1
        FileRemoveDir, %A_LoopFileFullPath%, 1
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

MinimizeAll() {
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
		WinList.Push(this_ID)
		; WinList[A_Index] := this_ID
		; writeLog(WinList[A_Index])
		WinMinimize, ahk_id %this_ID%
	}
}

RestoreAll() {	
	DetectHiddenWindows Off
	WinList := RevArr(WinList)
	WinGet, id, list	
	for Index, saveID in WinList {
		Loop, %id%
		{
			this_ID := id%A_Index%
			if (saveID = this_ID) {
				If NOT IsWindow(WinExist("ahk_id" . this_ID))
					continue
				WinGet, WinState, MinMax, ahk_id %this_ID%
				If (WinState != -1)
					continue
				WinGetTitle, title, ahk_id %this_ID%
				If (title = "")
					continue				
				WinRestore, ahk_id %this_ID%				
				;writeLog(title Index)
			}
		}
	}
	WinShow, AIMP
	WinList := []
}

KakaoCheck() {
	DetectHiddenWindows Off
	kakaoExist := false
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%
		WinGetClass, this_class, ahk_id %this_ID% 
		if (this_class = "EVA_Window_Dblclk") {
			WinGetTitle, title, ahk_id %this_ID%
			If (title = "카카오톡") {
				kakaoExist := true
				WinGet, WinState, MinMax, ahk_id %this_ID%
				If (WinState != -1) {
					if (KakaoTime = 0) {
						KakaoTime := A_Now
						KakaoTime += 60, Seconds	
					} else if (KakaoTime < A_Now and GetKeyState("Capslock", "T") != 1) {
						WinHide, ahk_id %this_ID%
						KakaoTime := 0
					}
				} else {
					KakaoTime := 0
				}
			}
		}
	}
	kakaoTime := kakaoExist ? KakaoTime : 0
}

KT_CallCheck() {	
	DetectHiddenWindows Off
	KT_CallExist := false
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%		
		WinGetClass, this_class, ahk_id %this_ID%
		WinGetTitle, title, ahk_id %this_ID%
		if (this_class = "#32770") {
			WinGetTitle, title, ahk_id %this_ID%
			If (title = "통화매니저") {
				KT_CallExist := true
				WinGet, WinState, MinMax, ahk_id %this_ID%
				If (WinState != -1) {
					if (KTCallManagerTime = 0) {
						KTCallManagerTime := A_Now
						KTCallManagerTime += 60, Seconds	
					} else if (KTCallManagerTime < A_Now and GetKeyState("Capslock", "T") != 1) {
						WinHide, ahk_id %this_ID%
						KTCallManagerTime := 0
					}
				} else {
					KTCallManagerTime := 0
				}
			}
		}
		if InStr(title, "통화매니저") {
			if (InStr(this_class, "EDialogWnd") and InStr(this_class, "BYTO")) {
				WinGet, hwndList, ControlListHwnd, ahk_id %this_ID%
				loop, Parse, hwndList, `n
				{
					WinGet, styleID, Style, ahk_id %a_LoopField%
					WinGetTitle, subTitle, ahk_id %a_LoopField%
					if InStr(subTitle, "예") {
						GetClientSize(a_LoopField, w, h)
						ClickPos(2/2, h/2, a_LoopField)
						break
					}
				}
			} else if InStr(this_class, "#32770") {				
				screenSize = 3840
				WinGetPos, X, Y, Width, Height, ahk_id %this_ID%
				yPos := 1300
				if ((screenSize != X + Width - 2)  or (Y != yPos)) {
					xPos := screenSize - Width + 2
					WinMove, ahk_id %this_ID%,, %xPos%, %yPos%
				}
			}
		}
		if InStr(title, "안내") {
			WinGetText, text, ahk_id %this_ID%
			if (InStr(text, "닫기")) {				
				WinGet, hwndList, ControlListHwnd, ahk_id %this_ID%
				loop, Parse, hwndList, `n
				{
					WinGetClass, this_class2, ahk_id %a_LoopField%
					if Instr(this_class2, "Internet Explorer_Server") {
						ClickPos(320, 155, a_LoopField)
						WinHide, "통화매니저"
						break
					}
				}
			}
		}
	}
	KTCallManagerTime := KT_CallExist ? KTCallManagerTime : 0
}

CloseCCTV(force=false) {
	if (GetKeyState("Capslock", "T") != 1) {
		WinGet, id, list
		Loop, %id%
		{
			this_ID := id%A_Index%
			WinGetTitle, title, ahk_id %this_ID%
			WinGetClass, class1, ahk_id %this_ID%
			WinGet, ahk_exe, ProcessName, ahk_id %this_ID%			
			if (InStr(title, "Form") and InStr(class1, "Qt5QWindow") and InStr(ahk_exe, "iVMS-4200.Framework.C.exe")) {
				ClickPos(500, 430, this_ID)
			} 
			WinGetTitle, TitleA, A
			if (FollowMouse()[1] = "iVMS-4200" and A_TickCount - CCTVscanTimer_Interval >= CCTVscanTimer) or force {
				loop {
					allClear := CloseCCTV_Replay()
					if (allClear = true)
						break
				}
				; msgBox, done
				CCTVscanTimer := allClear ? A_TickCount:(A_TickCount - CCTVscanTimer_Interval + 10000)
			}
		}
	}
}

CloseCCTV_Replay() {
	allClear := true
	needleFile = %A_ScriptDir%\ahks\play_button.png
	needle := Gdip_CreateBitmapFromFile(NeedleFile)
	countNumber := 0
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%
		WinGetTitle, title, ahk_id %this_ID%
		WinGetClass, class1, ahk_id %this_ID%
		WinGet, ahk_exe, ProcessName, ahk_id %this_ID%	
		if InStr(title, "iVMS-4200") and InStr(class1, "Qt5QWindowIcon") and InStr(ahk_exe, "iVMS-4200.Framework.C.exe") {
			countNumber += 1					
			WinGet, hwndList, ControlListHwnd, ahk_id %this_ID%
			loop, Parse, hwndList, `n
			{
				GetClientSize(a_LoopField, w, h)
				if (w > 480 and h > 320 and h < 1226 ) {							
					WinGet, styleID, Style, ahk_id %a_LoopField%
					if (styleID = 0x56000000) {
						checkChild := Parent(a_LoopField, ChildExist, ChildClass, Child_Hwid)
						if (checkChild) {
							bitMap := Gdip_BitmapFromHWND(a_LoopField)							
							; Gdip_GetImageDimensions(bitMap, width, height)
							; logText := a_LoopField ": " w ", " h ". " width ", " height
							; writeLog(logText)
							; SaveFileName = %A_ScriptDir%\%a_LoopField%.png
							; Gdip_SaveBitmapToFile(bitMap, SaveFileName)
							if (GetPosLibForClick(needle, posX, posY, 1,  (w/2-34), (h/2-34), 68, 68, bitMap) = 0) {
								ClickPos(w/2, h/2, a_LoopField)
								allClear := False
							}
							Gdip_DisposeImage(bitMap)
						}
					}
				}
			}
		}
	}
	Gdip_DisposeImage(needle)
	return allClear
}

CloseWindow() {
	Winclose, Steam - 뉴스
	Winclose, Steam - News
	Winclose, CrashReporter	
	close_targetList := ["CrashReporter"
						,"AnySign4PC 1.1.3.3 제거"
						,"Papyrus-PlugIn-web 제거"
						,"Papyrus-PlugIn-agent 제거"
						,"MaPrtDistEFILE Uninstall"
						,"악성 웹 사이트 탐지 서비스(APS Engine) 1.8.0 제거"
						,"INISAFE SmartManagerEX 1.0.0.277 제거"
						,"nProtect Online Security V1.0 설치"
						,"CROSSCERT UniCRSV3 2.0.11.2 제거"
						,"WIZVERA Process Manager 제거"
						,"INISAFE CrossWeb EX V3 제거"
						,"CrossEX Service UnInstall"
						,"TouchEn Key All Cleaner"
						,"Delfino G3 (x86) 제거"
						,"Veraport-x64 제거"
						,"TouchEn nxKey"
						,"I3GSvcManager"
						,"Explorer.EXE"
						,"VestCert"]
		WinGet, id, list
		Loop, %id%
		{
			this_ID := id%A_Index%
			WinGetTitle, title, ahk_id %this_ID%
			for k, v in close_targetList {
				if InStr(title, v) { ;and InStr(v, title) {
					;WinGet, styleID, Style, ahk_id %this_ID%
					ClickHwndTarget(this_ID, "삭제")
					ClickHwndTarget(this_ID, "확인")
					ClickHwndTarget(this_ID, "예(Y)")
					ClickHwndTarget(this_ID, "예(&Y)")
					ClickHwndTarget(this_ID, "종료")
					ClickHwndTarget(this_ID, "닫음")
					; MsgBox, found %title%
					; WinActivate, ahk_id %this_ID%
					; Send, {y}
					; Send, {Enter}
					; Sleep, 100	94CF0044	94C80347			
				}
			}
			if Instr(title, "https://asp.firstpos.co.kr/common/popup/popIframe.do?mode=W&scroll=yes&url=/skioskrequest.do&params=&dialogWidth=800&dialogHeight=400") {
				Sleep, 50
				WinActivate, ahk_id %this_ID%
				Send +{TAB 2}
				Send, {Space}
			}
			if Instr(title, "Hoax Eliminator") and InStr("Hoax Eliminator", title) {
				WinGetText, OutputVar , ahk_id %this_ID%
				if Instr(OutputVar, "개의 구라와 추가적인 구라들에 대한 제거를 시도했습니다.") {
					ClickHwndTarget(this_ID, "OK")
					;WinActivate, ahk_id %this_ID%					
					;Send, {Enter}
				}
			}
		}
	;}
}

ClickHwndTarget(this_ID, subNeedle) {
	WinGet, hwndList, ControlListHwnd, ahk_id %this_ID%
	loop, Parse, hwndList, `n
	{
		WinGet, styleID, Style, ahk_id %a_LoopField%
		WinGetTitle, subTitle, ahk_id %a_LoopField%
		if InStr(subTitle, subNeedle) {
			GetClientSize(a_LoopField, w, h)
			ClickPos(2/2, h/2, a_LoopField)
			;MsgBox, Found %subNeedle%
			break
		}
	}

}

CloseAdobeTrash() {
	close_targetList := ["cclibrary.exe"
						,"ccxprocess.exe"
						,"adobeipcbroker.exe"]
	for k, v in close_targetList {
		;logText := ahk_exe2 ", " v
		;writeLog(logText)
		if ProcessExist(v) and !ProcessExist("Photoshop.exe") 
			Process, Close, %v%
	}
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
	FileAppend, %x%, %A_ScriptDir%\%fileName%.txt, UTF-8
}

PipMove() {
	v := "PIP 모드"
	screenSize = 3840
	WinGet, id, list
	Loop, %id%
	{
		this_ID := id%A_Index%
		WinGetTitle, title, ahk_id %this_ID%		
		if InStr(title, v) {			
			WinGetPos, X, Y, Width, Height, %v%
			yPos = -3
			if ((screenSize != X + Width - 2)  or (Y != yPos)) {
				xPos := screenSize - Width + 2
				WinMove, %v%,, %xPos%, %yPos%
			}			
		}
	}	
}

SendKey(value, title) {
	if (value = "y") {
		keycode := 0x59
		Keyss = Y
	} else if (value = "Enter") {
		keycode := 0x0D
		Keyss = {Enter}
	}
	msgBox, %keycode% %title%
	PostMessage, 0x100, %keycode%,,, ahk_pid %title%
	ControlSend, , %Keyss%, ahk_pid %title%
	Sleep, 50
	PostMessage, 0x101, %keycode%,,,ahk_pid %title%
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

WallpaperEngine() {
	; Process, Close, wallpaper64.exe
	; sleep, 100
	RunWait, "D:\Program Files\Steam\steamapps\common\wallpaper_engine\wallpaper64.exe" -control nextWallpaper, , hide
}

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

runDic(dicName, location){
	wX = 3200
	wY = 1205
	wW = 646
	wH = 966
	AppFullPath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe "
	;AppFullPath := "C:\Program Files\Vivaldi\Application\vivaldi.exe "
	If WinExist("ahk_exe chrome.exe") {
		if not WinExist(dicName)
			RunWait, %AppFullPath% %location%,, hide
		WinRestore, %dicName%
		WinMove, %dicName%,, 3200, 1205 , 646, 966
		WinActivate, %dicName%
		WinGetPos, X, Y, Width, Height, %dicName%
		if ((wX != X)  or (wY != Y) or (wW != Width) or (wH != Height)) {
			loop {
				WinMove, %dicName%,, 3200, 1205 , 646, 966
				WinGetPos, X, Y, Width, Height, %dicName%
				if (wX == X)
					break
			}		
		}
		KeyWait, % A_ThisHotkey
	} else {
		Run, %AppFullPath%, , hide
	}
}

runStartApps() {		
	if !ProcessExist("EarTrumpet.exe") {		
		Run, """C:\Program Files\WindowsApps\40459File-New-Project.EarTrumpet_2.2.0.0_x86__1sdd7yawvg6ne\EarTrumpet\EarTrumpet.exe""",, hide
	}		
}

HIGHDPIAWARE() {
	if robloxUpdateCheck 
		return
	Process, Exist, RobloxStudioBeta.exe
	If ErrorLevel {
		tFolder := "C:\Program Files (x86)\Roblox\Versions"
		tName := "RobloxStudioBeta.exe"
		rootKey := "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
		value := "~ HIGHDPIAWARE"
		Loop, %tFolder%\*.*, 1, 1
		{
			x := A_LoopFileFullPath
			SplitPath, x, name, dir, ext, name_no_ext, drive
			if (name = tName) {
				RegRead, OutputVar, %rootKey%, %A_LoopFileFullPath%
				if not InStr(OutputVar, value) {
					RegWrite, REG_SZ,  %rootKey%, %A_LoopFileFullPath%, %value%
				}
			}
		}
		robloxUpdateCheck := true
	}
}

ToogleWinBarHide() {
	NumPut(DllCall("Shell32\SHAppBarMessage", "UInt", 4 ; ABM_GETSTATE
					, "Ptr", &APPBARDATA
					, "Int")
				    ? 2:1, APPBARDATA, A_PtrSize=4 ? 32:40) ; 2 - ABS_ALWAYSONTOP, 1 - ABS_AUTOHIDE
	, DllCall("Shell32\SHAppBarMessage", "UInt", 10 ; ABM_SETSTATE
				, "Ptr", &APPBARDATA)	
}

RevArr(arr) {
    newarr := []
    for index, value in arr
        newarr.InsertAt(1, value)
    return newarr
}

RevArrByRef(ByRef arr) {
    loop % len := arr.MaxIndex()
        arr.Push(arr.RemoveAt(len - (A_Index - 1)))
    return
}

ProcessExist(Name){
    Process, Exist, %Name%
    return Errorlevel
}

SetSystemCursor() {
	IDC_SIZEALL := 32646
	CursorHandle := DllCall( "LoadCursor", Uint,0, Int,IDC_SIZEALL )
	Cursors = 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
	Loop, Parse, Cursors, `,
	{
		DllCall( "SetSystemCursor", Uint,CursorHandle, Int,A_Loopfield )
	}
}

RestoreCursors() {
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

ClickPos(posX, posY, this_ID) {
	; CoordMode, Mouse, Client
	;DrawCheckRound(posX, posY, 50, 50, 0xFF0000)
	posPM:= posX|posY<<16	
	PostMessage, 0x201,0x0001, % posPM, , ahk_id %this_ID%
	Sleep, 10
	PostMessage, 0X202, 0, % posPM, , ahk_id %this_ID%
	; Sleep, 100
	; CoordMode, Mouse, Screen
}

ClickPos2(posX, posY, this_ID) {
	MouseGetPos, XX, YY
	; CoordMode, Mouse, Client
	WinActivate, ahk_id %this_ID%
	MouseClick, Left, % posX, % posY
	; CoordMode, Mouse, Screen
	MouseMove, % XX, % YY, 0
}

FollowMouse() {
	MouseGetPos, msX, msY, msWin, msCtrl
	curWin := msWin
	curCtrl := msCtrl
	WinExist("ahk_id " curWin)
	WinGetTitle, t1
	WinGetClass, t2
	WinGet, t3, ProcessName
	WinGet, t4, PID
	return Array(t1, t2, t3, t4)
}

GetPosLibForClick(needle, byRef posX="", byRef posY="", Variation = "35", X="0", Y="0", hayWidth="0", hayHeight="0", Source="Null") {
	SearchDirection = 1
	Trans = 0xFF00FF
	Instances = 1
	;needle := Gdip_CreateBitmapFromFile(NeedleFile)
	haystack := (!(X="0") or !(Y="0") or !(hayWidth="0") or !(hayHeight="0")) ? Gdip_CropImage(Source, X, Y, hayWidth, hayHeight):Source
	found := Gdip_ImageSearch(haystack,needle,OutputList,0,0,0,0,Variation,Trans, SearchDirection, Instances,"`,","`,")
  if !( found < 1 ) {
		Gdip_GetImageDimensions(needle, Width, Height)
		out:=StrSplit(OutputList,"`,")		
		posX := Floor(out[1] + Width/2)   
		posY := Floor(out[2] + Height/2)  
	}
	; Gdip_DisposeImage(needle)
	return ( found < 1 ) ; will return 0 for SUCCESS, 1 for FAILURE
}

Gdip_CropImage(pBitmap, x, y, w, h) {
	pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
	Gdip_DeleteGraphics(G2)
	Gdip_DisposeImage(G2)
	return pBitmap2
}

DrawCheckRound(posX, posY, Width, Height, ColorValue) {
	CoordMode, Pixel, Screen
	x:= posX
	y:= posY
	w:= Width
	h:= Height
	Gui, 1:New
	Gui, 1:-Caption -Border +AlwaysOnTop
	Gui, 1:color, %ColorValue%
	Gui, 1:Show, % "x" x  " y" y "w" w "h" h ,Area
	WinSet, Transparent, 185, Area
	Sleep, 500
	Gui, 1:Destroy
	CoordMode, Pixel, Client
}

GetClientSize(hwnd, ByRef w, ByRef h)
{
    VarSetCapacity(rc, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
    w := NumGet(rc, 8, "int")
    h := NumGet(rc, 12, "int")
}

Parent(hwnd1, byRef child="", byRef cl="", byRef hwid="") {
	GW_HWNDFIRST:=0, GW_HWNDLAST:=1, GW_HWNDNEXT:=2, GW_HWNDPREV:=3, GW_OWNER:=4, GW_CHILD:=5, GW_ENABLEDPOPUP:=6
	child := DllCall("GetWindow", "ptr", hwnd1, "uint", GW_CHILD, "ptr")
	desktop := DllCall("GetDesktopWindow", "ptr")
	if (child != desktop){
		WinGetClass, cl ,  ahk_id %child%
		WinGetTitle title,  ahk_id %child%
		WinGetText text , ahk_id %child%
		WinGet, hwid, ID, ahk_id %child%
		;MsgBox Child parent : %child%`nClass : %cl%`nTitle : %title%`nText : %text%`nHW ID : %hwid%
	}else{
		;MsgBox Top-level window
	}
	return !(hwid="")
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
