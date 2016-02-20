*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    *Ask for input
    MOVE.B      #4, D0
    TRAP        #15
    
    *Move what has been typed in D1 to A0 (it's the address)
    MOVEA.L      D1, A0
    
    *Copy the opcode part to D0
    MOVE.W      (A0), D0
    
    *Copy the opcode to D1 for changes
    MOVE.W      (A0), D1
    
    *Increase the address by 2, since that part has been read
    ADDA.W       #$2, A0
    
    *Do check for 1100 initial
    JSR         CHECK1100
    JSR         CHECK0000   *Check for 0000 (or 00 for MOVE) initial
    JSR         CHECK1011  * Check for the CMP opcode
    JSR         CHECK0110 *Check for BCC opcode
    JSR         CHECK0111 *Check for MOVEQ opcode
    JSR         CHECK1101 *Check for ADD or ADDA
    JSR         CHECK1001 *Check for sub or suba
    JSR         CHECK1000 *Check for DIVS word
    JSR         CHECK0100 *Check for JSR,RTS,NOP,MOVEM,LEA,CLR

*-------------------IGNORE THIS PART FOR NOW------------------------------------
    *Now move the number of bytes that are needed for source and destination to D1 and D2 (let's say 1 for source and 2 for destination)
    MOVE.L      #$2, D1
    MOVE.L      #$2, D2
    
    *Now copy the source to D3 and destination to D4
    MOVE.W      (A3), D3
    ADDA.W       D1, A3
    
    MOVE.W      (A3), D4
    ADDA.W       D2, A3
    
    *Now check what source and destination are and move them to A2 and A3
    MOVE.B      #14, D0
    TRAP        #15 
    
    MOVE.B      #6, D0
    
    MOVE.L      D3, D1
    
    TRAP        #15 *Print the source
    
    MOVE.L      D4, D1
    
    TRAP        #15 *Print the destination
  *------------------------------------------------------------  
    SIMHALT             ; halt simulator

*----------------------------------------------------------------------------------------------------
CHECK1100       AND.W   #$F000, D1      *Isolates the first 4 spaces
                CMP.W   #$C000, D1      *Checks if the first 4 spaces are 1100
                
                BEQ     CHECKANDMULS    *If equal, then go check if it's AND or MULS
                
                RTS
            
CHECKANDMULS    MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$1C0, D1       *Isolate spaces 8 to 6
                CMP.W   #$1C0, D1       *Check if spaces 8 to 6 are 111
                
                BEQ     OPMULS          *If yes, then it's AND
                
                BRA     OPAND           *If not, then it's MULS

OPAND           LEA     ANDMESSAGE, A1  *Store the AND message
                MOVE.B  #14, D0
                TRAP    #15
OPMULS          LEA     MULSMESSAGE, A1 *Store the MULS message

*-----------------------------------------------------------------------------------------------------

CHECK0000       AND.W   #$F000, D1      *Isolates the first 4 spaces
                CMP.W   #$0000, D1      *Checks if the first 4 spaces are 0000
                
                BEQ     CHECKAABC       *If equal, then go check if it's ANDI, ADDI, BCHG and CMPI
                
                AND.W   #$C000, D1      *Isolate the first 2 spaces
                CMP.W   #$0000, D1      *Check if the first 2 spaces are 00
                
                BEQ     OPMOVE          *If true, it's MOVE
                
                RTS
            
CHECKAABC       MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPBCHG          *If yes, then it's BCHG
                
                MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$800, D1       *Isolate space 11
                CMP.W   #$800, D1       *Check if space 11 is 1
                
                BEQ     OPCMPI          *If yes, then it's CMPI
                
                MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$400, D1       *Isolate space 10
                CMP.W   #$400, D1       *Check if space 10 is 1
                
                BEQ     OPADDI          *If true, then it's ADDI
                
                BRA     OPANDI          *If not, then it's ANDI

OPMOVE          LEA     MOVEMESSAGE, A1 *Store the MOVE message
OPBCHG          LEA     BCHGMESSAGE, A1 *Store the BCHG message
OPCMPI          LEA     CMPIMESSAGE, A1 *Store the CMPI message
OPADDI          LEA     ADDIMESSAGE, A1 *Store the ADDI message
OPANDI          LEA     ANDIMESSAGE, A1 *Store the ANDI message

*-----------------------------------------------------------------------------------------------------


*-----------------------------------------------------------------------------------------------------
CHECK1011       MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$C000,D1
                BEQ OPCMP
                RTS
OPCMP           LEA CMPMESSAGE, A1
                RTS
*-----------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
CHECK0111       *Check for MOVEQ opcode
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$7000,D1
                BEQ OPMOVEQ
                RTS
OPMOVEQ         LEA MOVEQMESSAGE, A1
                RTS

*-----------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
CHECK0110       *Check for BCC opcode
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$6000,D1
                BEQ OPBCC
                RTS
OPBCC           LEA BCCMESSAGE, A1
                RTS
*-----------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
CHECK1101       *Check for ADD or ADDA
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$D000, D1
                BEQ CHECKADDADDA
                RTS
CHECKADDADDA    AND.W #$1C0, D1
                CMP.W #$1C0, D1
                BEQ OPADDA
            
                MOVE.W D0,D1 *restore the opcode to d1          
                AND.W #$C0,D1  *check for 011 in 8-6.
                CMP.W #$C0,D1 
                BEQ OPADDA
                BRA OPADD
OPADDA          LEA ADDAMESSAGE,A1
                RTS
OPADD           LEA ADDMESSAGE,A1
                RTS
*-----------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
CHECK1001       *Check for sub or suba

                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$9000, D1
                BEQ CHECKSUBSUBA
                RTS
CHECKSUBSUBA    AND.W #$1C0, D1
                CMP.W #$1C0, D1
                BEQ OPSUBA
            
                MOVE.W D0,D1 *restore the opcode to d1          
                AND.W #$C0,D1  *check for 011 in 8-6.
                CMP.W #$C0,D1 
                BEQ OPSUBA
                BRA OPSUB
OPSUBA          LEA SUBAMESSAGE,A1
                RTS
OPSUB           LEA SUBMESSAGE,A1
                RTS
*-----------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
CHECK1000       *Check for DIVS word
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$6000,D1
                BEQ OPBCC
                RTS
OPDIVS          LEA DIVSMESSAGE,A1
                RTS
*-----------------------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
CHECK0100   * check for JSR, RTS, NOP, MOVEM, LEA, CLEAR
                MOVE.W D0,D1 *RESTORE OPCODE
                AND.W #$F000,D1
                CMP.W #$4000,D1
                BEQ CHECKOPS *check all posible ops in the 0100 category
                RTS

CHECKOPS        MOVE.W D0,D1 * restore opcode
                *******Check for lea*******
                MOVE.W D0,D1 *RESTORE OPCODE
                AND.W #$100,D1  *mask every bit but the 8th
                CMP.W #$100, D1 *check if bit 8 is 1 
                BEQ OPLEA
                ******check for CLR********
       
                ******check for MOVEM*****
                MOVE.W D0,D1 *RESTORE OPCODE
                AND.W #$200,D1  *mask every bit but the 8th
                CMP.W #$200, D1 *check if bit 8 is 1 
                BEQ OPMOVEM
    
                MOVE.W D0,D1 *restore opcode
                AND.W #$300,D1 *check if th 9 is 1 and 8 is 1
                CMP.W #$300,D1
                BEQ CHECKRTSNOPJSR *check the remaing op codes
                RTS
CHECKRTSNOPJSR  MOVE.W D0,D1 *restore opcode
                AND.W #$30,D1 *check if 5,4,3 is 011 
                CMP.W #$30,D1
                BEQ CHECKRTSNOP
                BRA OPJSR
CHECKRTSNOP
                MOVE.W D0,D1 *restore opcode
                AND.W #$4,D1 *check if 2 bit is 1
                CMP.W #$4,D1 *if eqal then it is rts
                BEQ OPRTS
                BRA OPNOP *We know at this point it is 110 and not 1 so it has to be 1100
OPNOP           LEA NOPMESSAGE,A1
                RTS    
OPJSR
                LEA RTSMESSAGE,A1
                RTS
OPLEA  
                LEA LEAMESSAGE,A1
                RTS
OPMOVEM         LEA OPMOVEMMESSAGE,A1
OPRTS           LEA RTSMESSAGE,A1
                RTS
*-----------------------------------------------------------------------------------------------------
DIVSMESSAGE     DC.B    'DIVS', 0
CMPMESSAGE      DC.B     'CMP', 0
BCCMESSAGE      DC.B     'BCC', 0
MOVEQMESSAGE    DC.B   'MOVEQ', 0
ADDAMESSAGE     DC.B    'ADDA', 0
ADDMESSAGE      DC.B     'ADD', 0
SUBAMESSAGE     DC.B    'SUBA', 0
SUBMESSAGE      DC.B     'SUB', 0
ANDMESSAGE      DC.B     'AND', 0
MULSMESSAGE     DC.B    'MULS', 0
MOVEMESSAGE     DC.B    'MOVE', 0
BCHGMESSAGE     DC.B    'BCHG', 0
CMPIMESSAGE     DC.B    'CMPI', 0
ADDIMESSAGE     DC.B    'ADDI', 0
ANDIMESSAGE     DC.B    'ANDI', 0
LEAMESSAGE      DC.B    'LEA',0
OPMOVEMMESSAGE  DC.B    'MOVEM',0
RTSMESSAGE      DC.B    'RTS',0
NOPMESSAGE      DC.B    'NOP',0
    END    START        ; last line of source
    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
