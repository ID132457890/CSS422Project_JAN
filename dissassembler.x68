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

ANDMESSAGE DC.B     'AND', 0
MULSMESSAGE DC.B    'MULS', 0

MOVEMESSAGE DC.B    'MOVE', 0
BCHGMESSAGE DC.B    'BCHG', 0
CMPIMESSAGE DC.B    'CMPI', 0
ADDIMESSAGE DC.B    'ADDI', 0
ANDIMESSAGE DC.B    'ANDI', 0

    END    START        ; last line of source
