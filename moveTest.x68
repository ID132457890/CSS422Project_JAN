*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
START:  ORG $1000
                        
        MOVE.W D2,D3 Move machine code to memory address D3
        MOVE.B D3, D5 Move LS 2 byte to memory address D5
        ASR #8,D3 Shift machine code by a byte to get most significant byte
        MOVE.B D3,D4 move most significant byte to d4
        ASR #4,D4   shift by one char to get leftmost char
        CMP.B #1, D4    compare the leftmost char to 1 the hex num leading all move.b machine codes
        BEQ MOVEB   branch to the moveB operation
        BRA BAD     else halt
MOVEB   LEA MOVEBSTRING,A1  load the move.b string
        MOVE.B #14,D0       move 4 into d0
        TRAP #15            execute process 4 of trap 15
        
        
   
BAD
        SIMHALT
MOVEBSTRING DC.B 'MOVE.B',0
        END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
