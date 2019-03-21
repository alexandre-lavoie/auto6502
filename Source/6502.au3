;-------------------------------------
; Variables
;-------------------------------------

Const $RAMSIZE = Dec("FFF")
Global $RAM[$RAMSIZE]
for $i = 0 To $RAMSIZE - 1
   $RAM[$i] = 0
Next
Global $CPUPointer = 0, $StackPointer = Dec("06FF")
Global $CarryFlag = 0, $ZeroFlag = 0, $InterruptFlag = 0, $DecimalFlag = 0, $BRKFlag = 0, $OverflowFlag = 0, $NegativeFlag = 0
Global $A = 0, $X = 0, $Y = 0, $ProcessorFlag = 0
Global $Running = True
Global $CPUCycles = 0, $CPUInstructions = 0

;-------------------------------------
; Addressing
;-------------------------------------

Func Immediate()
   $Address = $CPUPointer+1
   $CPUPointer += 1
   Return $Address
EndFunc

Func ZeroPage()
   $Address = $RAM[$CPUPointer+1]
   $CPUPointer += 1
   Return $Address
EndFunc

Func ZeroPageX()
   $Address = Dec(Hex($RAM[$CPUPointer+1]+$X,2))
   $CPUPointer += 1
   Return $Address
EndFunc

Func ZeroPageY()
   $Address = Dec(Hex($RAM[$CPUPointer+1]+$Y,2))
   $CPUPointer += 1
   Return $Address
EndFunc

Func Relative()
   $Offset = $RAM[$CPUPointer+1]
   $Coord = $CPUPointer + 2
   if $Offset > 127 Then
	  $Coord -= (256 - $Offset)
   Else
	  $Coord += $Offset
   EndIf
   $CPUPointer += 1
   Return $Coord
EndFunc

Func Absolute()
   $Address = Dec(Hex($RAM[$CPUPointer+2],2) & Hex($RAM[$CPUPointer+1],2))
   $CPUPointer += 2
   Return $Address
EndFunc

Func AbsoluteX()
   $Address = Dec(Hex($RAM[$CPUPointer+2],2) & Hex($RAM[$CPUPointer+1],2)) + $X
   $CPUPointer += 2
   Return $Address
EndFunc

Func AbsoluteY()
   $Address = Dec(Hex($RAM[$CPUPointer+2],2) & Hex($RAM[$CPUPointer+1],2)) + $Y
   $CPUPointer += 2
   Return $Address
EndFunc

Func Indirect()
   $Point = Dec(Hex($RAM[$CPUPointer+2],2) & Hex($RAM[$CPUPointer+1],2))
   $Address = Dec(Hex($RAM[$Point+1],2) & Hex($RAM[$Point],2))
   $CPUPointer += 2
   Return $Address
EndFunc

Func IndirectX()
   $Address = $RAM[Dec(Hex($RAM[$CPUPointer+1] + $X,2))]
   $CPUPointer += 1
   Return $Address
EndFunc

Func IndirectY()
   $Address = Dec(Hex($RAM[$RAM[$CPUPointer+1]+1],2) & Hex($RAM[$RAM[$CPUPointer+1]],2)) + $Y
   $CPUPointer += 1
   Return $Address
EndFunc

;-------------------------------------
; Flags
;-------------------------------------

Func TestZero(ByRef $Register)
   if Dec(Hex($Register,2)) == 0 Then
	  $ZeroFlag = 1
   Else
	  $ZeroFlag = 0
   EndIf
EndFunc

Func TestCarry(ByRef $Register)
   If $Register > Dec("FF") then
	  $Register -= 256
	  $CarryFlag = 1
   Else
	  $CarryFlag = 0
   EndIf
EndFunc

Func TestNegative(ByRef $Register)
   If $Register < 0 Then
	  $Register += 256
	  $NegativeFlag  = 1
   Else
	  $NegativeFlag  = 0
   EndIf

   $NegativeFlag = BitShift($Register, 7)
EndFunc

Func TestOverflow(ByRef $Register)

EndFunc

Func TestGreater(ByRef $Register)
   If $Register > Dec("FF") then
	  $Register -= 256
   EndIf
EndFunc

;-------------------------------------
; Functions
;-------------------------------------

Func ADC($Address)
   $A += $RAM[$Address] + $CarryFlag

   TestCarry($A)
   TestZero($A)
   TestNegative($A)
   TestOverflow($A)
EndFunc

Func cAND($Address)
   $A = BitAND($A, $RAM[$Address])

   TestZero($A)
   TestNegative($A)
EndFunc

Func ASL(ByRef $Address, $IsRegister)
   If $IsRegister Then
	  $CarryFlag = BitShift(BitAND($Address, 128),7)
	  $Address = BitShift($Address, -1)

	  TestZero($Address)
	  TestNegative($Address)
   Else
	  $CarryFlag = BitShift(BitAND($RAM[$Address], 128),7)
	  $RAM[$Address] = BitShift($RAM[$Address], -1)

	  TestZero($RAM[$Address])
	  TestNegative($RAM[$Address])
   Endif
EndFunc

Func BIT($Address)
   $Ans = BitAND($A, $RAM[$Address])

   TestZero($Ans)

   $NegativeFlag = BitShift($Ans, 7)

   $OverflowFlag = BitAND(BitNOT($NegativeFlag) * 2 + 1, BitShift($Ans, 6))
EndFunc

Func BNC($Flag, $Set, $Address)

   If $Flag == $Set then
	  $CPUPointer = $Address - 1
	  $CPUCycles += 1
   endif

EndFunc

Func BRK()
   Push(Hex($CPUPointer,4))
   Push(Hex($ProcessorFlag,2))

   $Pointer = Dec(Hex($RAM[Dec("0317")],2) & Hex($RAM[Dec("0316")],2))-1

   $BRKFlag = 1
EndFunc

Func CMP($Address)
   $Sub = $A - $RAM[$Address]

   If $Sub >= 0 Then
	  $CarryFlag = 1
   Else
	  $CarryFlag = 0
   EndIf

   If $Sub == 0 Then
	  $ZeroFlag = 1
   Else
	  $ZeroFlag = 0
   EndIf

   $NegativeFlag = BitShift($Sub, 7)
EndFunc

Func CPX($Address)
   $Sub = $X - $RAM[$Address]

   If $Sub >= 0 Then
	  $CarryFlag = 1
   Else
	  $CarryFlag = 0
   EndIf

   If $Sub == 0 Then
	  $ZeroFlag = 1
   Else
	  $ZeroFlag = 0
   EndIf

   $NegativeFlag = BitShift($Sub, 7)
EndFunc

Func CPY($Address)
   $Sub = $Y - $RAM[$Address]

   If $Sub >= 0 Then
	  $CarryFlag = 1
   Else
	  $CarryFlag = 0
   EndIf

   If $Sub == 0 Then
	  $ZeroFlag = 1
   Else
	  $ZeroFlag = 0
   EndIf

   $NegativeFlag = BitShift($Sub, 7)
EndFunc

Func cDEC($Address)
   $RAM[$Address] -= 1

   TestZero($RAM[$Address])
   TestNegative($RAM[$Address])
EndFunc

Func EOR($Address)
   $A = BITXOR($A, $RAM[$Address])

   TestZero($A)
   TestNegative($A)
EndFunc

Func CLC()
   $CarryFlag = 0
EndFunc

Func SEC()
   $CarryFlag = 1
EndFunc

Func CLI()
   $InterruptFlag = 0
EndFunc

Func SEI()
   $InterruptFlag = 1
EndFunc

Func CLV()
   $OverflowFlag = 0
EndFunc

Func CLD()
   $DecimalFlag = 0
EndFunc

Func SED()
   $DecimalFlag = 1
EndFunc

Func INC($Address)
   $RAM[$Address] += 1

   TestZero($RAM[$Address])
   TestNegative($RAM[$Address])
EndFunc

Func JMP($Address)
   $CPUPointer = $Address - 1
EndFunc

Func JSR($Address)
   Push(Hex($CPUPointer,4))
   $CPUPointer = $Address - 1
EndFunc

Func LDA($Address)
   $A = $RAM[$Address]
   TestZero($A)
   TestNegative($A)
EndFunc

Func LDX($Address)
   $X = $RAM[$Address]
   TestZero($X)
   TestNegative($X)
EndFunc

Func LDY($Address)
   $Y = $RAM[$Address]
   TestZero($Y)
   TestNegative($Y)
EndFunc

Func LSR(ByRef $Address, $IsRegister)
   If $IsRegister Then
	  $CarryFlag = BitAND($Address, 1)
	  $Address = BitShift($Address, -1)

	  TestZero($Address)
	  TestNegative($Address)
   Else
	  $CarryFlag = BitAND($RAM[$Address], 1)
	  $RAM[$Address] = BitShift($RAM[$Address], -1)

	  TestZero($RAM[$Address])
	  TestNegative($RAM[$Address])
   Endif
EndFunc

Func NOP()

EndFunc

Func ORA($Address)
   $A = BitOR($A, $RAM[$Address])

   TestZero($A)
   TestNegative($A)
EndFunc

Func TAX()
   $X = $A
EndFunc

Func TXA()
   $A = $X
EndFunc

Func DEX()
   $X -= 1

   TestZero($X)
   TestNegative($X)
EndFunc

Func INX()
   $X += 1

   TestGreater($X)
   TestZero($X)
   TestNegative($X)
EndFunc

Func TAY()
   $Y = $A
EndFunc

Func TYA()
   $A = $Y
EndFunc

Func DEY()
   $Y -= 1

   TestZero($Y)
   TestNegative($Y)
EndFunc

Func INY()
   $Y += 1

   TestZero($Y)
   TestGreater($Y)
   TestNegative($Y)
EndFunc

Func ROL(ByRef $Address, $IsRegister)
   If $IsRegister Then
	  $CN = BitShift($Address, 7)
	  $Address = BitShift($Address, -1) + $CarryFlag
	  $CarryFlag = $CN

	  TestZero($Address)
	  TestNegative($Address)
   Else
	  $CN = BitShift($RAM[$Address], 7)
	  $RAM[$Address] = BitShift($RAM[$Address], -1) + $CarryFlag
	  $CarryFlag = $CN

	  TestZero($RAM[$Address])
	  TestNegative($RAM[$Address])
   Endif
EndFunc

Func ROR(ByRef $Address, $IsRegister)
   If $IsRegister Then
	  $CN = BitAND($Address,1)
	  $Address = BitShift($Address, 1) + $CarryFlag * 128
	  $CarryFlag = $CN

	  TestZero($Address)
	  TestNegative($Address)
   Else
	  $CN = BitAND($RAM[$Address],1)
	  $RAM[$Address] = BitShift($RAM[$Address], 1) + $CarryFlag * 128
	  $CarryFlag = $CN

	  TestZero($RAM[$Address])
	  TestNegative($RAM[$Address])
   Endif
EndFunc

Func RTI()
   Pull(1)
   $CPUPointer = Pull(2)
EndFunc

Func RTS()
   $CPUPointer = Pull(2)
EndFunc

Func SBC($Address)
   $A -= $RAM[$Address] - (1-$CarryFlag)

   TestZero($A)
   TestNegative($A)
   TestOverflow($A)
EndFunc

Func STA($Address)
   $RAM[$Address] = $A
EndFunc

Func TXS()
   $StackPointer = $X + 256
EndFunc

Func TSX()
   $X = $StackPointer
EndFunc

Func PHA()
   Push(Hex($A,2))
EndFunc

Func PLA()
   $A = Pull(1)
EndFunc

Func PHP()
   Push(Hex($ProcessorFlag,2))
EndFunc

Func PLP()
   $ProcessorFlag = Pull(1)
EndFunc

Func STX($Address)
   $RAM[$Address] = $X
EndFunc

Func STY($Address)
   $RAM[$Address] = $Y
EndFunc

;-------------------------------------
; Push Stack
;-------------------------------------

Func Push($Hex)
   $HexSplit = StringRegExp($Hex, "(?s).{1,2}", 3)
   for $i = 0 to UBound($HexSplit) - 1
	  $StackPointer -= 1
	  $RAM[$StackPointer] = Dec($HexSplit[$i])
   Next
EndFunc

;-------------------------------------
; Pop Stack
;-------------------------------------

Func Pull($Size)

   $SP = $StackPointer
   $StackPointer += $Size
   $FinalHex = ""
   for $i = $Size - 1 To 0 Step -1
	  $FinalHex &= Hex($RAM[$SP+$i],2)
   Next

   return Dec($FinalHex)
EndFunc

;-------------------------------------
; Runs a CPU Cycle
;-------------------------------------

Func CPUCycle()
   $CPUInstructions += 1

	  Switch(Hex($RAM[$CPUPointer],2))
		 Case "69"
			ADC(Immediate())
			$CPUCycles += 2
		 Case "65"
			ADC(ZeroPage())
			$CPUCycles += 3
		 Case "75"
			ADC(ZeroPageX())
			$CPUCycles += 4
		 Case "6D"
			ADC(Absolute())
			$CPUCycles += 4
		 Case "7D"
			ADC(AbsoluteX())
			$CPUCycles += 4
		 Case "79"
			ADC(AbsoluteY())
			$CPUCycles += 4
		 Case "61"
			ADC(IndirectX())
			$CPUCycles += 6
		 Case "71"
			ADC(IndirectY())
			$CPUCycles += 5
		 Case "29"
			cAND(Immediate())
			$CPUCycles += 2
		 Case "25"
			cAND(ZeroPage())
			$CPUCycles += 3
		 Case "35"
			cAND(ZeroPageX())
			$CPUCycles += 3
		 Case "2D"
			cAND(Absolute())
			$CPUCycles += 4
		 Case "3D"
			cAND(AbsoluteX())
			$CPUCycles += 4
		 Case "39"
			cAND(AbsoluteY())
			$CPUCycles += 4
		 Case "21"
			cAND(IndirectX())
			$CPUCycles += 6
		 Case "31"
			cAND(IndirectY())
			$CPUCycles += 5
		 Case "0A"
			ASL($A,True)
			$CPUCycles += 2
		 Case "06"
			ASL(ZeroPage(), False)
			$CPUCycles += 5
		 Case "16"
			ASL(ZeroPageX(), False)
			$CPUCycles += 6
		 Case "0E"
			ASL(Absolute(), False)
			$CPUCycles += 6
		 Case "1E"
			ASL(AbsoluteX(), False)
			$CPUCycles += 7
		 Case "24"
			BIT(ZeroPage())
			$CPUCycles += 3
		 Case "2C"
			BIT(Absolute())
			$CPUCycles += 4
		 Case "10"
			BNC($NegativeFlag, 0, Relative())
			$CPUCycles += 2
		 Case "30"
			BNC($NegativeFlag, 1, Relative())
			$CPUCycles += 2
		 Case "50"
			BNC($OverflowFlag, 0, Relative())
			$CPUCycles += 2
		 Case "70"
			BNC($OverflowFlag, 1, Relative())
			$CPUCycles += 2
		 Case "90"
			BNC($CarryFlag, 0, Relative())
			$CPUCycles += 2
		 Case "B0"
			BNC($CarryFlag, 1, Relative())
			$CPUCycles += 2
		 Case "D0"
			BNC($ZeroFlag, 0, Relative())
			$CPUCycles += 2
		 Case "F0"
			BNC($ZeroFlag, 1, Relative())
			$CPUCycles += 2
		 Case "00"
			BRK()
			$CPUCycles += 7
		 Case "C9"
			CMP(Immediate())
			$CPUCycles += 2
		 Case "C5"
			CMP(ZeroPage())
			$CPUCycles += 3
		 Case "D5"
			CMP(ZeroPageX())
			$CPUCycles += 4
		 Case "CD"
			CMP(Absolute())
			$CPUCycles += 4
		 Case "DD"
			CMP(AbsoluteX())
			$CPUCycles += 4
		 Case "D9"
			CMP(AbsoluteY())
			$CPUCycles += 4
		 Case "C1"
			CMP(IndirectX())
			$CPUCycles += 6
		 Case "D1"
			CMP(IndirectY())
			$CPUCycles += 5
		 Case "E0"
			CPX(Immediate())
			$CPUCycles += 2
		 Case "E4"
			CPX(ZeroPage())
			$CPUCycles += 3
		 Case "EC"
			CPX(Absolute())
			$CPUCycles += 4
		 Case "C0"
			CPY(Immediate())
			$CPUCycles += 2
		 Case "C4"
			CPY(ZeroPage())
			$CPUCycles += 3
		 Case "CC"
			CPY(Absolute())
			$CPUCycles += 4
		 Case "C6"
			cDEC(ZeroPage())
			$CPUCycles += 5
		 Case "D6"
			cDEC(ZeroPageX())
			$CPUCycles += 6
		 Case "CE"
			cDEC(Absolute())
			$CPUCycles += 6
		 Case "DE"
			cDEC(AbsoluteX())
			$CPUCycles += 7
		 Case "49"
			EOR(Immediate())
			$CPUCycles += 2
		 Case "45"
			EOR(ZeroPage())
			$CPUCycles += 3
		 Case "55"
			EOR(ZeroPageX())
			$CPUCycles += 4
		 Case "4D"
			EOR(Absolute())
			$CPUCycles += 4
		 Case "5D"
			EOR(AbsoluteX())
			$CPUCycles += 4
		 Case "59"
			EOR(AbsoluteY())
			$CPUCycles += 4
		 Case "41"
			EOR(IndirectX())
			$CPUCycles += 6
		 Case "51"
			EOR(IndirectY())
			$CPUCycles += 5
		 Case "18"
			CLC()
			$CPUCycles += 2
		 Case "38"
			SEC()
			$CPUCycles += 2
		 Case "58"
			CLI()
			$CPUCycles += 2
		 Case "78"
			SEI()
			$CPUCycles += 2
		 Case "B8"
			CLV()
			$CPUCycles += 2
		 Case "D8"
			CLD()
			$CPUCycles += 2
		 Case "F8"
			SED()
			$CPUCycles += 2
		 Case "E6"
			INC(ZeroPage())
			$CPUCycles += 5
		 Case "F6"
			INC(ZeroPageX())
			$CPUCycles += 6
		 Case "EE"
			INC(Absolute())
			$CPUCycles += 6
		 Case "FE"
			INC(AbsoluteX())
			$CPUCycles += 7
		 Case "4C"
			JMP(Absolute())
			$CPUCycles += 3
		 Case "6C"
			JMP(Indirect())
			$CPUCycles += 5
		 Case "20"
			JSR(Absolute())
			$CPUCycles += 6
		 Case "A9"
			LDA(Immediate())
			$CPUCycles += 2
		 Case "A5"
			LDA(ZeroPage())
			$CPUCycles += 3
		 Case "B5"
			LDA(ZeroPageX())
			$CPUCycles += 4
		 Case "AD"
			LDA(Absolute())
			$CPUCycles += 4
		 Case "BD"
			LDA(AbsoluteX())
			$CPUCycles += 4
		 Case "B9"
			LDA(AbsoluteY())
			$CPUCycles += 4
		 Case "A1"
			LDA(IndirectX())
			$CPUCycles += 6
		 Case "B1"
			LDA(IndirectY())
			$CPUCycles += 5
		 Case "A2"
			LDX(Immediate())
			$CPUCycles += 2
		 Case "A6"
			LDX(ZeroPage())
			$CPUCycles += 3
		 Case "B6"
			LDX(ZeroPageY())
			$CPUCycles += 4
		 Case "AE"
			LDX(Absolute())
			$CPUCycles += 4
		 Case "BE"
			LDX(AbsoluteY())
			$CPUCycles += 4
		 Case "A0"
			LDY(Immediate())
			$CPUCycles += 2
		 Case "A4"
			LDY(ZeroPage())
			$CPUCycles += 3
		 Case "B4"
			LDY(ZeroPageY())
			$CPUCycles += 4
		 Case "AC"
			LDY(Absolute())
			$CPUCycles += 4
		 Case "BC"
			LDY(AbsoluteY())
			$CPUCycles += 4
		 Case "4A"
			LSR($A,True)
			$CPUCycles += 2
		 Case "46"
			LSR(ZeroPage(), False)
			$CPUCycles += 5
		 Case "56"
			LSR(ZeroPageX(), False)
			$CPUCycles += 6
		 Case "4E"
			LSR(Absolute(), False)
			$CPUCycles += 6
		 Case "5E"
			LSR(AbsoluteX(), False)
			$CPUCycles += 7
		 Case "EA"
			NOP()
			$CPUCycles += 2
		 Case "09"
			ORA(Immediate())
			$CPUCycles += 2
		 Case "05"
			ORA(ZeroPage())
			$CPUCycles += 3
		 Case "15"
			ORA(ZeroPageX())
			$CPUCycles += 4
		 Case "0D"
			ORA(Absolute())
			$CPUCycles += 4
		 Case "1D"
			ORA(AbsoluteX())
			$CPUCycles += 4
		 Case "19"
			ORA(AbsoluteY())
			$CPUCycles += 4
		 Case "01"
			ORA(IndirectX())
			$CPUCycles += 6
		 Case "11"
			ORA(IndirectY())
			$CPUCycles += 5
		 Case "AA"
			TAX()
			$CPUCycles += 2
		 Case "8A"
			TXA()
			$CPUCycles += 2
		 Case "CA"
			DEX()
			$CPUCycles += 2
		 Case "E8"
			INX()
			$CPUCycles += 2
		 Case "A8"
			TAY()
			$CPUCycles += 2
		 Case "98"
			TYA()
			$CPUCycles += 2
		 Case "88"
			DEY()
			$CPUCycles += 2
		 Case "C8"
			INY()
			$CPUCycles += 2
		 Case "2A"
			ROL($A, True)
			$CPUCycles += 2
		 Case "26"
			ROL(ZeroPage(), False)
			$CPUCycles += 5
		 Case "36"
			ROL(ZeroPageX(), False)
			$CPUCycles += 6
		 Case "2E"
			ROL(Absolute(), False)
			$CPUCycles += 6
		 Case "3E"
			ROL(AbsoluteX(), False)
			$CPUCycles += 7
		 Case "6A"
			ROR($A,True)
			$CPUCycles += 2
		 Case "66"
			ROR(ZeroPage(), False)
			$CPUCycles += 5
		 Case "76"
			ROR(ZeroPageX(), False)
			$CPUCycles += 6
		 Case "6E"
			ROR(Absolute(), False)
			$CPUCycles += 6
		 Case "7E"
			ROR(AbsoluteX(), False)
			$CPUCycles += 7
		 Case "40"
			RTI()
			$CPUCycles += 6
		 Case "60"
			RTS()
			$CPUCycles += 6
		 Case "E9"
			SBC(Immediate())
			$CPUCycles += 2
		 Case "E5"
			SBC(ZeroPage())
			$CPUCycles += 3
		 Case "F5"
			SBC(ZeroPageX())
			$CPUCycles += 4
		 Case "ED"
			SBC(Absolute())
			$CPUCycles += 4
		 Case "FD"
			SBC(AbsoluteX())
			$CPUCycles += 4
		 Case "F9"
			SBC(AbsoluteY())
			$CPUCycles += 4
		 Case "E1"
			SBC(IndirectX())
			$CPUCycles += 6
		 Case "F1"
			SBC(IndirectY())
			$CPUCycles += 5
		 Case "85"
			STA(ZeroPage())
			$CPUCycles += 3
		 Case "95"
			STA(ZeroPageX())
			$CPUCycles += 4
		 Case "8D"
			STA(Absolute())
			$CPUCycles += 4
		 Case "9D"
			STA(AbsoluteX())
			$CPUCycles += 5
		 Case "99"
			STA(AbsoluteY())
			$CPUCycles += 5
		 Case "81"
			STA(IndirectX())
			$CPUCycles += 6
		 Case "91"
			STA(IndirectY())
			$CPUCycles += 6
		 Case "9A"
			TXS()
			$CPUCycles += 2
		 Case "BA"
			TSX()
			$CPUCycles += 2
		 Case "48"
			PHA()
			$CPUCycles += 3
		 Case "68"
			PLA()
			$CPUCycles += 4
		 Case "08"
			PHP()
			$CPUCycles += 3
		 Case "28"
			PLP()
			$CPUCycles += 4
		 Case "86"
			STX(ZeroPage())
			$CPUCycles += 2
		 Case "96"
			STX(ZeroPageY())
			$CPUCycles += 4
		 Case "8E"
			STX(Absolute())
			$CPUCycles += 4
		 Case "84"
			STY(ZeroPage())
			$CPUCycles += 2
		 Case "94"
			STY(ZeroPageX())
			$CPUCycles += 4
		 Case "8C"
			STY(Absolute())
			$CPUCycles += 4
		 Case Else
			ConsoleWrite(Hex($CPUPointer,4) & "-" & Hex($RAM[$CPUPointer],2))
			$Running = False
	  EndSwitch
	  $CPUPointer += 1
EndFunc