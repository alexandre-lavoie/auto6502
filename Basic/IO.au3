;-------------------------------------
; Note - IO system inspired by Easy 6502 : https://skilldrick.github.io/easy6502/
;-------------------------------------

;-------------------------------------
; Includes
;-------------------------------------
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <Misc.au3>

;-------------------------------------
; Variables
;-------------------------------------
Const $SCREEN = 32
Const $SCALE = 8
Const $SCREENPOINTER = Dec("200")
Local $LastKey = Asc("s")

;-------------------------------------
; Setup GUI
;-------------------------------------
$GUI = GUICreate("6502 Output", $SCREEN * $SCALE, $SCREEN * $SCALE)
GUISetState(@SW_SHOW)
_GDIPlus_Startup()

;-------------------------------------
; Listens for key presses.
;-------------------------------------
Func CheckKeys()
   For $i = 0 to 255
	  If _isPressed($i) Then
		 $LastKey = Hex($i,2)
	  EndIf
   Next
EndFunc

;-------------------------------------
; Slow function that updates all the IO.
;-------------------------------------
Func UpdateIO()
   CheckKeys()
   UpdateInput()
   UpdateOutput()
EndFunc

;-------------------------------------
; Updates the random and key in RAM.
;-------------------------------------
Func UpdateInput()
   $RAM[Dec("FE")] = Hex(Random(0, Dec("FF"), 1),2)
   $RAM[Dec("FF")] = $LastKey
EndFunc

Func UpdateOutput()
   UpdateScreen()
EndFunc

;-------------------------------------
; Draws $SCREEN * $SCREEN from memory $SCREENPOINTER
;-------------------------------------
Func UpdateScreen()
   $Bitmap = _GDIPlus_BitmapCreateFromScan0($SCREEN,$SCREEN)
   For $i = 0 to $SCREEN*$SCREEN
	  $Color = GetColor($RAM[$i+$SCREENPOINTER])
	  _GDIPlus_BitmapSetPixel($Bitmap, Mod($i, $SCREEN)+1, Floor($i/($SCREEN))+1, $Color)
   Next
   $Bitmap = _GDIPlus_ImageResize($Bitmap, $SCREEN * $SCALE, $SCREEN * $SCALE, 5)
   $Graphic = _GDIPlus_GraphicsCreateFromHWND($GUI)
   _GDIPlus_GraphicsDrawImage($Graphic, $Bitmap, 0, 0)

   _GDIPlus_GraphicsDispose($Graphic)
   _GDIPlus_ImageDispose($Bitmap)
EndFunc

;-------------------------------------
; Gets the color of a byte.
;-------------------------------------
Func GetColor($Hex)
   Switch(StringRight(Hex(Dec($Hex),2),1))
	  Case "0"
		 Return "0xFF000000"
	  Case "1"
		 Return "0xFFFFFFFF"
	  Case "2"
		 Return "0xFFFF0000"
	  Case "3"
		 Return "0xFF00FFFF"
	  Case "4"
		 Return "0xFFFF00FF"
	  Case "5"
		 Return "0xFF00FF00"
	  Case "6"
		 Return "0xFF0000FF"
	  Case "7"
		 Return "0xFFFFFF00"
	  Case "8"
		 Return "0xFFFFa500"
	  Case "9"
		 Return "0xFFA52A2A"
	  Case "A"
		 Return "0xFFFF8080"
	  Case "B"
		 Return "0xFF008000"
	  Case "C"
		 Return "0xFF808080"
	  Case "D"
		 Return "0xFF80FF80"
	  Case "E"
		 Return "0xFF8080FF"
	  Case "F"
		 Return "0xFFCCCCCC"
	  Case Else
		 Return "0xFF000000"
   EndSwitch
EndFunc