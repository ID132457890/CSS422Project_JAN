*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
START:  ORG $1000

        MOVE.B #14,D0  Move 14 in D0 for Trap 15          
        MOVE.W D2,D3 Move machine code to memory address D3
        MOVE.B D3, D5 Move LS 2 byte to memory address D5
        ASR #8,D3 Shift machine code by a byte to get most significant byte
        MOVE.B D3,D4 move most significant byte to d4
        ASR #$4,D4   shift by one char to get leftmost char
        
        CMP.B #$1, D4    compare the leftmost char to 1 the hex num leading all move.b machine codes
        BEQ MOVEB   branch to the moveB operation
        
        CMP.B  #$3, D4 Compare 3 to value in d4
        BEQ MOVEW   Branch to MOVEW if equal
        
        CMP.B   #$2, D4 
        BEQ MOVEL
        
        CMP.B #$5,  D4
        BEQ ADDQ   
        BRA BAD     else halt
MOVEB   LEA MOVEBSTRING,A1  load the move.b string
      
        TRAP #15 execute process 4 of trap 15
        SIMHALT
MOVEW   LEA MOVEWSTRING,A1
        
        TRAP #15
        SIMHALT        
MOVEL   LEA MOVELSTRING,A1
        TRAP #15
        SIMHALT 
    
BAD
        SIMHALT
        
MOVEBEA      SIMHALT 

MOVEWEA
MOVELEA
MOVEBSTRING DC.B 'MOVE.B',0

MOVEWSTRING DC.B 'MOVE.W',0
MOVELSTRING DC.B 'MOVE.L',0



        END START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
