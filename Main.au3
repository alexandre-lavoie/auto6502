;-------------------------------------
; Variables
;-------------------------------------

Global $ROMPath = "./ROMs/Draw.rom"
Const $RUNCYCLES = 100000
Const $COMPUTE = Dec("FF")

;-------------------------------------
; Includes
;-------------------------------------

#include "./Source/6502.au3"
#include "./Basic/ROM.au3"
#include "./Basic/Debugger.au3"
#include "./Basic/IO.au3"

;-------------------------------------
; Main Loop
;-------------------------------------

While 1

if $Running Then

   For $i = 0 To $RUNCYCLES

	  If $CPUPointer == Dec(GUICtrlRead($BreakInput)) Or $Running == False Then ; Breaks when program is shutdown or when hits a breakpoint.
		 ExitLoop
	  EndIf

	  If Mod($i, $COMPUTE) == 0 Then ; Loads computation heavy functions once every $COMPUTE
		 CheckKeys()
		 UpdateOutput()
		 DebuggerUpdate()
	  EndIf

	  UpdateInput()
	  CPUCycle()
   Next

   UpdateIO()
   DebuggerUpdate()

   $Running = False

Else

   If DebuggerGetMessages() == False Then
	  ExitLoop
   EndIf

EndIf

WEnd
