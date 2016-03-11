*****************************
*
* demo_test.X68
*
* Created 3/06/2016
*
* Test program for CSS 422 Disassembler Project Demo
*
*****************************

start		EQU	$00007000	* ORG and END address

* ORG the program so that it straddles the address boundary $00007FFF to $00008000

		ORG	start

* NOP and similar instructions. Should clearly differentiate NOP and RTS from others.

		NOP			*Required
		RTS			*Required


* This is a group of ADD instructions

add_start	ADDI.W	#$4E71,D1
		ADDQ.L	#07,D7		
		ADDA.L	-(SP),A2
		ADDA.W	(A6)+,A3
		ADDA.L	#$3000AAAA,A6
		ADDI.L	#$D50000AA,D5
		ADDI.W	#$5555,D6
		ADDI.B	#$FE,D0
		
* Group is random data

data1		DC.B		$FF,$AA,$45,$0A
data2		DC.B		$00,00,01,00,00,00
data3		DC.W		$AAAA,$5555,0000,$FFFF

* This is an illegal instruction, MOVE.B    #$0F,A6

* illegal		DC.W		$1C7C,$000F

* Move instructions

moves		MOVE.B	D0,D1
		MOVE.W	A6,$F30045BB
		MOVE.L	D0,D0
		MOVE.L	D7,(A6)+
		MOVE.W	#$FFD0,(A3)
		MOVE.L	$C00022AA,$3000A0F8
		MOVE.L	A0,-(A5)
		MOVEA.W	(A6),A0
		MOVEM.W	A0/A1/A2/D5/D6/D7,$3A(A6,D4.L)
		MOVEM.L	(A0)+,D0/D1/D2/A4/A3/A0/A1
*		MOVEA.L	#$AAAA00AA,A2
		
* Divide and multiple optional instructions

ands		AND.B	#$01,$4568
		AND.L	$8000A000,D3
shifts		LSL.B	D0,D0
		LSL.W	#4,D0
		LSL.W	(A2)+
		ASR.B	D6,D7
rolls		ROL.L	D2,D3
		ROR.L	#4,D6

clear		CLR.B	D4
load_addr	LEA	$DC00FF00,A2
		LEA	(A5),A4
		LEA	(ands,PC),A3
		LEA	-$20(A2,D7),A2

* random data	
		DC.W	2949,0411,2848,7869

compares	CMP.B	(A3),D5
		CMP.L	$ABC0FF00,D2
		CMPA.W	D2,A4
* Branches	


* Jump and branch instructions

jmplabel	BSR	compares	* BSR long test
		BSR	rolls	        * BSR short test	
		JSR	(A3)		* Address register indirect
		BSR	multiply
		BSR	$2000
		BCC	clear		
		BGT	compares		
		BLE	multiply	

		
		
		
*These are not required instructions
multiply	MULS	D0,D3		*Optional instruction
		MULS	(A6),D0		*Optional instruction
		MULS	#$4567,D1	*Optional instruction
		DIVU	(A3)+,D5	*Optional instruction
		NOP
		NOP
		SUB.L	#$00000055,D4
		SUB.L	#$FFFFFFEE,D7
	

		END	start







