;-------------------------------------
; Variables
;-------------------------------------

Global $AInput, $XInput, $YInput, $CPUPointerInput, $StackInput, $BreakInput
Global $StepButton, $RunButton, $RAMButton
Global $CarryBox, $ZeroBox, $InterruptBox, $DecimalBox, $BRKBox, $OverflowBox, $NegativeBox
Global $CyclesLabel, $InstructionLabel

;-------------------------------------
; Includes
;-------------------------------------

#include <GUIConstantsEx.au3>

;-------------------------------------
; Initalize Debugger
;-------------------------------------

DebuggerGUI()
DebuggerUpdate()

;-------------------------------------
; Create Debugger GUI
;-------------------------------------

Func DebuggerGUI()
   $Running = False
   GUICreate("6502 Debugger", 400, 200)
   GUICtrlCreateLabel("A:", 10, 10)
   $AInput = GUICtrlCreateInput("", 20, 7)
   GUICtrlCreateLabel("X:", 10, 40)
   $XInput = GUICtrlCreateInput("", 20, 37)
   GUICtrlCreateLabel("Y:", 10, 70)
   $YInput = GUICtrlCreateInput("", 20, 67)
   GUICtrlCreateLabel("CPU Pointer:", 10, 100)
   $CPUPointerInput = GUICtrlCreateInput("", 80, 97, 40)
   GUICtrlCreateLabel("Stack Pointer:", 10, 130)
   $StackInput = GUICtrlCreateInput("", 80, 127, 40)
   GUICtrlCreateLabel("Breakpoint:", 10, 160)
   $BreakInput = GUICtrlCreateInput("", 80, 157, 40)
   GUICtrlCreateLabel("CPU Cycles:", 130, 100)
   $CyclesLabel = GUICtrlCreateLabel("0", 190, 100, 100)
   GUICtrlCreateLabel("Instructions:", 130, 130)
   $InstructionLabel = GUICtrlCreateLabel("0", 190, 130, 100)
   $StepButton = GUICtrlCreateButton("Step", 350, 150)
   $RunButton = GUICtrlCreateButton("Run", 350, 120)
   $RAMButton = GUICtrlCreateButton("RAM", 350, 90)
   $CarryBox = GUICtrlCreateCheckbox("Carry", 50, 7)
   $ZeroBox = GUICtrlCreateCheckbox("Zero", 50, 27)
   $BRKBox = GUICtrlCreateCheckbox("BRK", 50, 47)
   $DecimalBox = GUICtrlCreateCheckbox("Decimal", 50, 67)
   $InterruptBox = GUICtrlCreateCheckbox("Interrupt", 100, 7)
   $OverflowBox = GUICtrlCreateCheckbox("Overflow", 100, 27)
   $NegativeBox = GUICtrlCreateCheckbox("Negative", 100, 47)
   GUISetState(@SW_SHOW)
EndFunc

;-------------------------------------
; Writes in console the RAM
;-------------------------------------

Func DebuggerDrawRAM()
   $Line = 0
   $CurLine = ""
   For $i = 0 To UBound($RAM) - 1
	  if Mod($i, 16) == 0 Then
		 $HexCount = 0
		 ConsoleWrite(@LF & Hex($Line,4) & ": ")
		 $Line += 16
		 $CurLine = ""
	  EndIf
	  ConsoleWrite(Hex($RAM[$i],2) & " ")
   Next
EndFunc

;-------------------------------------
; Gets Debugger GUI Messages
;-------------------------------------

Func DebuggerGetMessages()

   $GGM = GUIGetMsg()

   if $GGM == $GUI_EVENT_CLOSE then
	  Return False
   elseif $GGM == $StepButton Then
	  CPUCycle()
	  UpdateIO()
	  DebuggerUpdate()
   elseif $GGM == $NegativeBox Then
	  $NegativeFlag = 1 - $NegativeFlag
   elseif $GGM == $ZeroBox Then
	  $ZeroFlag = 1 - $ZeroFlag
   elseif $GGM == $RAMButton Then
	  DebuggerDrawRAM()
   elseif $GGM == $RunButton Then
	  if $Running == True Then
		 UpdateGUI()
		 $Running = False
	  Else
		 $Running = True
	  EndIf
   Endif

   Return True

EndFunc

;------------------------------------
; Update Debugger GUI
;------------------------------------

Func DebuggerUpdate()
   GUICtrlSetData($AInput, Hex($A,2))
   GUICtrlSetData($XInput, Hex($X,2))
   GUICtrlSetData($YInput, Hex($Y,2))
   GUICtrlSetData($CPUPointerInput, Hex($CPUPointer,4))
   GUICtrlSetData($StackInput, Hex($StackPointer,4))
   GUICtrlSetData($CyclesLabel, $CPUCycles)
   GUICtrlSetData($InstructionLabel, $CPUInstructions)

   if $CarryFlag == 1 Then
	  GUICtrlSetState($CarryBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($CarryBox, $GUI_UNCHECKED)
   EndIf

   if $ZeroFlag == 1 Then
	  GUICtrlSetState($ZeroBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($ZeroBox, $GUI_UNCHECKED)
   EndIf

   if $OverflowFlag == 1 Then
	  GUICtrlSetState($OverflowBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($OverflowBox, $GUI_UNCHECKED)
   EndIf

   if $DecimalFlag == 1 Then
	  GUICtrlSetState($DecimalBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($DecimalBox, $GUI_UNCHECKED)
   EndIf

   if $BRKFlag == 1 Then
	  GUICtrlSetState($BRKBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($BRKBox, $GUI_UNCHECKED)
   EndIf

   if $NegativeFlag == 1 Then
	  GUICtrlSetState($NegativeBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($NegativeBox, $GUI_UNCHECKED)
   EndIf

   if $InterruptFlag == 1 Then
	  GUICtrlSetState($InterruptBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($InterruptBox, $GUI_UNCHECKED)
   EndIf

EndFunc