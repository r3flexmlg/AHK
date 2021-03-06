﻿#Include lib/iniMaker.ahk
#Include lib/JSON.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance off
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetControlDelay -1

WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WinHttp.Open("GET", "http://worldtimeapi.org/api/ip", false)
WinHttp.Send()
obj := JSON.Load(WinHttp.ResponseText)
TimeNow := obj.unixtime

TimeExpire := "2021/04/12/10:00:59"
TimeExpire := StrReplace(TimeExpire, "/")
TimeExpire := StrReplace(TimeExpire, ":")
FormatTime, TimeString, %TimeExpire%, yyyyMMddHHmmss
; Convert string to number.
TimeExpire := TimeString*1
EnvSub, TimeExpire, 19700101000000, Seconds

if (TimeNow > TimeExpire) {
	MsgBox, Expired!
	ExitApp
}

Global IniSections := []
Global IniSections ["Singular"] 
:= { posx: "0"
	,	posy: "0"
	,	color: "0x00FF00"
	,	htk: "f3"}
Global IniSections ["UhaczkaHotkeys"] := {}

cachePth = %A_ScriptFullPath%:Stream:$DATA
Global cachePath := cachePth
Global ini := ReadINI(cachePath)

if (!ini.Singular.count()) {
	ini.Singular := IniSections.Singular.Clone()
	ini.Singular.posx := IniSections.Singular.posx
	ini.Singular.posy := IniSections.Singular.posy
	ini.Singular.color := IniSections.Singular.color
	ini.Singular.htk := IniSections.Singular.htk
}

Gui, Show, X200 Y200 W300 H300
Gui, Add, Button, w133 gSelectCoords, Select target position
Gui, Add, Text, vtargetPosX, 0
Gui, Add, Text, vtargetPosY, 0
Gui, Add, Text, vtargetColor, 0x000000
Gui, Add, Hotkey, vHtk, F2
Gui, Add, Button, w100 gStartMain, Start
Gui, Add, Button, w100 gStopMain, Stop

; Load values from store
GuiControl, Text, targetPosX, % ini["Singular"].posx
GuiControl, Move, targetPosX, W300
GuiControl, Text, targetPosY, % ini["Singular"].posy
GuiControl, Move, targetPosY, W300
GuiControl, Text, targetColor, % ini["Singular"].color
GuiControl, Move, targetColor, W300
GuiControl, Text, Htk, % ini["Singular"].htk

OnExit("SaveCache")
return

GuiClose:
	ExitApp
return

SelectCoords:
	;WinActivate, Tibia -
	SetTimer, WatchCursor, 35
	return
return

WatchCursor:
	CoordMode, Mouse, Relative 
	MouseGetPos, MouseX, MouseY
  PixelGetColor, clr, %MouseX%, %MouseY%
	ToolTip, `Select Position and Color`n`x: %MouseX% y: %MouseY% color: %clr%`
	
	if (GetKeyState("LButton")) {
		MsgBox, , , %MouseX% %MouseY%, 0.3
		BlockInput, Mouse
		GuiControl, Text, targetPosX, %MouseX%
		GuiControl, Move, targetPosX, W300
		GuiControl, Text, targetPosY, %MouseY%
		GuiControl, Move, targetPosY, W300
    GuiControl, Text, targetColor, %clr%
		GuiControl, Move, targetColor, W300
		SetTimer, WatchCursor, Off
		ToolTip
	}
return

StartMain:
	WinActivate, Tibia -
	;Gui, Font, c098c00
	;GuiControl, Font, ScrStatus
	;GuiControl, Text, ScrStatus, Status: Running
	;GuiControl, Move, ScrStatus, W300
	;Gosub, Amulet
	SetTimer, Amulet, 80
return

StopMain:
	SetTimer, Amulet, Off
	return
return

Amulet:
	GuiControlGet, tPosX ,, targetPosX
	GuiControlGet, tPosY ,, targetPosY
	GuiControlGet, tColor ,, targetColor
	GuiControlGet, hotkey ,, Htk
	PixelGetColor, color, %tPosX%, %tPosY%
	if (tColor = color) {
		ControlSend,, {%hotkey% down}, Tibia -
		sleep 200
		ControlSend,, {%hotkey% up}, Tibia -
	}
return

SaveCache(ExitReason, ExitCode)
{
	GuiControlGet, posx ,, targetPosX
	IniSections["Singular"].posx := posx
	GuiControlGet, posy ,, targetPosY
	IniSections["Singular"].posy := posy
	GuiControlGet, color ,, targetColor
	IniSections["Singular"].color := color
	GuiControlGet, htk ,, Htk
	IniSections["Singular"].htk := htk

	WriteINI(IniSections, cachePath)
}