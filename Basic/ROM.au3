;-------------------------------------
; Variables
;-------------------------------------

Global $ROM = ROMLoad($ROMPath)
Global $RomAddress = Dec("600")

;-------------------------------------
; Includes
;-------------------------------------

#include <String.au3>

;-------------------------------------
; Initialize Machine
;-------------------------------------

ROMtoRAM()

;-------------------------------------
; Reads ROM
;-------------------------------------

Func ROMLoad($Path)
   $FO = FileOpen($Path,16)
   $R = StringSplit(Hex(FileRead($FO),2),"")
   FileClose($FO)
   Dim $RHex[UBound($R)/2]

   $Address = 0

   For $i = 1 To UBound($R) - 1 Step 2
	  $RHex[$Address] = Dec($R[$i] & $R[$i+1])
	  $Address += 1
   Next

   Return $RHex
EndFunc

;-------------------------------------
; Loads ROM into RAM
;-------------------------------------

Func ROMtoRAM()

   $CPUPointer = $RomAddress

   $Address = $CPUPointer

   For $i = 0 To UBound($ROM) - 1
	  $RAM[$Address] = $ROM[$i]
	  $Address += 1
   Next

EndFunc