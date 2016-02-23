*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*----------------------------------main--------------------------
    *Ask for input
    MOVE.B      #4, D0
    TRAP        #15
    
    *Move what has been typed in D1 to A0 (it's the address)
    MOVEA.L      D1, A0
LOOP    
    *Copy the opcode part to D0
    MOVE.W      (A0), D0
    
    *Copy the opcode to D1 for changes
    MOVE.W      (A0), D1
    
    *Increase the address by 2, since that part has been read
    ADDA.W       #$2, A0
    
    *Do check for 1100 initial
    JSR         CHECK1100    *Check for AND or MULS
    JSR         CHECK0000   *Check for ANDI, ADDI, BCHG, CMPI or MOVE  initial
    JSR         CHECK1110 *Check for LSx,ASx,ROx
    JSR         CHECK1010  * Check for the CMP opcode
    JSR         CHECK0110 *Check for BCC opcode
    JSR         CHECK0111 *Check for MOVEQ opcode
    JSR         CHECK1101 *Check for ADD or ADDA
    JSR         CHECK1001 *Check for SUB or SUBA
    JSR         CHECK1000 *Check for DIVS 
    JSR         CHECK0100 *Check for JSR,RTS,NOP,MOVEM,LEA,CLR
   
    MOVE.B  #14, D0
    TRAP    #15
    SIMHALT   
*------------------------------------main----------------------------------------




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

    LEA NEWLINE,A1
    TRAP #15

     SIMHALT             ; halt simulator
  *--------------------IGNORRE THIS PART FOR NOW----------------------------------------  
    
   


*----------------------------------------------------------------------------------------------------
*                                           Subroutine: CHECK1100
*Description: Checks if opcode word starts with the binary 1100. If true it checks if it is AND or MULS
*----------------------------------------------------------------------------------------------------
CHECK1100       AND.W   #$F000, D1      *Isolates the first 4 spaces
                CMP.W   #$C000, D1      *Checks if the first 4 spaces are 1100
                
                BEQ     CHECKANDMULS    *If equal, then go check if it's AND or MULS
                
                RTS
            
CHECKANDMULS    MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$1C0, D1       *Isolate spaces 8 to 6
                CMP.W   #$1C0, D1       *Check if spaces 8 to 6 are 111
                
                BEQ     OPMULS *If yes, then it's MULS
                    
                BRA     OPAND          *If not, then it's AND
OPAND           LEA     ANDMESSAGE, A1  *Store the AND message
                
                RTS
OPMULS          LEA     MULSMESSAGE, A1 *Store the MULS message
                RTS
*---------------------------------------------END_CHECK1100-----------------------------------------------------




*----------------------------------------------------------------------------------------------------
*                                                Subroutine: CHECK0000
*Description: Checks if opcode word starts with the binary 0000. If true it idendifies if it is ANDI, ADDI, BCHG,CMPI or MOVE
*----------------------------------------------------------------------------------------------------
CHECK0000       MOVE.W D0,D1      
                AND.W   #$F000, D1      *Isolates the first 4 spaces
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

                RTS

OPBCHG          LEA     BCHGMESSAGE, A1 *Store the BCHG message
                RTS
OPCMPI          LEA     CMPIMESSAGE, A1 *Store the CMPI message
                RTS
OPADDI          LEA     ADDIMESSAGE, A1 *Store the ADDI message
                RTS
OPANDI          LEA     ANDIMESSAGE, A1 *Store the ANDI message
                RTS

*---------------------------------------END_CHECK0000--------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
*                                            Subroutine: CHECK1110
*Description: Checks if opcode word starts with the binary 1110. If true it identifies if it is LSR/LSL,ASR/ASL,ROR/ROL
*----------------------------------------------------------------------------------------------------
CHECK1110        MOVE.W D0,D1    *restore opcode
                 AND.W #$F000,D1
                 CMP.W #$E000,D1
                 BEQ CHECKSHIFTOPS
                 RTS
CHECKSHIFTOPS      *check if the opcode is LSx,ASx,ROx
                JSR ROTATION
                MOVE.W D0,D1 *restore opcode   
                AND.W #$C0,D1
                CMP.W #$C0,D1
                BEQ MEMSHIFT *if 1 in 7 and 1 in 6 this is a memory shift
                BRA REGSHIFT
MEMSHIFT        MOVE.W D0,D1 *restore opcode   
                AND.W #$200,D1 *check if opcode is lsr or lsl
                CMP.W #$200,D1
                BEQ CHECKLSX
                
                MOVE.W D0,D1 *restore opcode
                AND.W #$18,D1
                CMP.W #$18, D1
                BEQ CHECKROX *Opcode is ROR or ROL if 
                BRA CHECKASX

          
REGSHIFT        
                MOVE.W D0,D1 *restore opcode   
                AND.W #$8,D1 *check if opcode is lsr or lsl
                CMP.W #$8,D1
                BEQ CHECKLSX
                
                
                MOVE.W D0,D1 *restore opcode
                AND.W #$18,D1
                CMP.W #$18, D1
                BEQ CHECKROX *Opcode is ROR or ROL if 
                BRA CHECKASX




CHECKLSX
            CMP.B #01,D7
            BEQ    OPLSL
            BRA OPLSR
            
        
CHECKASX
            CMP.B #01,D7
            BEQ OPASL
            BRA OPASR
            
        
CHECKROX
            CMP.B #01,D7
            BEQ  OPROL
            BRA OPROR
           
        
ROTATION    MOVE.W D0,D1
            AND.W #$100,D1
            CMP.W #$100,D1
            BEQ LEFT
            BRA RIGHT
LEFT 
            MOVEQ #1, D7
            RTS
RIGHT       
            MOVEQ #0, D7
            RTS

OPLSR  
        LEA LSRMESSAGE,A1
        RTS
        
OPLSL   LEA LSLMESSAGE,A1
        RTS

OPASL   LEA ASLMESSAGE,A1
        RTS


OPASR   LEA ASRMESSAGE,A1
        RTS
        
OPROR   LEA RORMESSAGE,A1
        RTS
        
OPROL   LEA ROLMESSAGE,A1
        RTS
*---------------------------------------END_CHECK1110--------------------------------------------------------


*-----------------------------------------------------------------------------------------------------
*                                            Subroutine: CHECK1010
*Description: Checks if opcode word starts with the binary 1010. If true it identifies if it is CMP
*----------------------------------------------------------------------------------------------------
CHECK1010       MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$B000,D1
                BEQ OPCMP
                RTS
OPCMP           LEA CMPMESSAGE, A1
                RTS
*---------------------------------------------- CHECK1011-----------------------------------------------


*-----------------------------------------------------------------------------------------------------
*                                        Subroutine: CHECK0111
*Description: Checks if opcode word starts with the binary 0111. If true it identifies if it is MOVEQ
*----------------------------------------------------------------------------------------------------

CHECK0111       *Check for MOVEQ opcode
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$7000,D1
                BEQ OPMOVEQ
                RTS
OPMOVEQ         LEA MOVEQMESSAGE, A1
                RTS

*------------------------------------------------CHECK0111----------------------------------------------


*-----------------------------------------------------------------------------------------------------
*                                        Subroutine: CHECK0110
*Description: Checks if opcode word starts with the binary 0110. If true it identifies if it is BCC
*----------------------------------------------------------------------------------------------------

CHECK0110       *Check for BCC opcode
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$6000,D1
                BEQ OPBCC
                RTS
OPBCC           LEA BCCMESSAGE, A1
                RTS
*------------------------------------------CHECK0110-------------------------------------------------------



*-----------------------------------------------------------------------------------------------------
*                                    Subroutine: CHECK1101
*Description: Checks if opcode word starts with the binary 1101. If true it identifies if it is ADD or ADDA
*----------------------------------------------------------------------------------------------------
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
*--------------------------------------------CHECK1101--------------------------------------------------


*-----------------------------------------------------------------------------------------------------
*                                        Subroutine: CHECK1001
*Description: Checks if opcode word starts with the binary 1001. If true it identifies if it is SUB or SUBA
*----------------------------------------------------------------------------------------------------

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
*--------------------------------------------------------CHECK1001----------------------------------------


*-----------------------------------------------------------------------------------------------------
*                                    Subroutine: CHECK1000
*Description: Checks if opcode word starts with the binary 1000. If true it identifies if it is DIVS
*----------------------------------------------------------------------------------------------------
CHECK1000       *Check for DIVS word
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$8000,D1
                BEQ OPDIVS
                RTS
OPDIVS          LEA DIVSMESSAGE,A1
                RTS
*--------------------------------------CHECK1000-----------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
*                                    Subroutine: CHECK0100
*Description: Checks if opcode word starts with the binary 0100. If true it identifies if it is JSR, RTS, NOP, MOVEM, LEA or CLR
*----------------------------------------------------------------------------------------------------

CHECK0100   * check for JSR, RTS, NOP, MOVEM, LEA, CLR
                MOVE.W D0,D1 *RESTORE OPCODE
                AND.W #$F000,D1
                CMP.W #$4000,D1
                BEQ CHECKOPS *check all posible ops in the 0100 category
                RTS

CHECKOPS        *******Check for NOP and RTS since they are constant
                 MOVE.W D0,D1 *RESTORE OPCODE
                 CMP #$4E75,D1
                 BEQ OPRTS
                 CMP #$4E71,D1
                 BEQ OPNOP

              
                
                *******Check for lea*******                
                AND.W #$100,D1  *mask every bit but the 8th
                CMP.W #$100, D1 *check if bit 8 is 1 
                BEQ OPLEA
              
                ******check for MOVEM*****
                MOVE.W D0,D1 *RESTORE OPCODE
                AND.W #$30,D1  *mask every bit but the 8th
                CMP.W #$30, D1 *check if bit 8 is 1 
                BEQ OPMOVEM
    
                MOVE.W D0,D1 *restore opcode
                AND.W #$300,D1 *check if th 9 is 1 and 8 is 1
                CMP.W #$300,D1
                BEQ OPJSR *check the remaing op codes
                  ******check for CLR********
                MOVE.W D0,D1 *RESTORE OPCODE         
                AND.W #$FF00,D1  *mask every bit but the 8th
                CMP.W #$4200, D1 *check if bit 8 and 11 is 1
                BEQ   OPCLR
                RTS
                
 
OPNOP           LEA NOPMESSAGE,A1
                RTS    
OPJSR
                LEA JSRMESSAGE,A1
                RTS
OPLEA  
                LEA LEAMESSAGE,A1
                RTS
OPMOVEM         LEA OPMOVEMMESSAGE,A1
                RTS
OPRTS           LEA RTSMESSAGE,A1
                RTS
OPCLR           LEA CLRMESSAGE,A1
                RTS
*----------------------------------------CHECK0100-------------------------------------------------------

NEWLINE         DC.B    $0D,$0A,0
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
JSRMESSAGE      DC.B    'JSR',0
CLRMESSAGE      DC.B    'CLR',0
ASRMESSAGE      DC.B    'ASR',0
ASLMESSAGE      DC.B    'ASL',0
LSLMESSAGE      DC.B    'LSL',0
LSRMESSAGE      DC.B    'LSR',0
RORMESSAGE      DC.B    'ROR',0
ROLMESSAGE      DC.B    'ROL',0

    END    START        ; last line of source
   












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
