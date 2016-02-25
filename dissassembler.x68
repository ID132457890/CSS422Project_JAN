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
                MOVE.B  #$13, D4
                RTS
                
OPMULS          LEA     MULSMESSAGE, A1 *Store the MULS message
                MOVE.B  #$9, D4
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
                MOVE.B  #$1, D4
                RTS

OPBCHG          LEA     BCHGMESSAGE, A1 *Store the BCHG message
                MOVE.B  #$18, D4
                RTS
                
OPCMPI          LEA     CMPIMESSAGE, A1 *Store the CMPI message
                MOVE.B  #$20, D4
                RTS
                
OPADDI          LEA     ADDIMESSAGE, A1 *Store the ADDI message
                MOVE.B  #$6, D4
                RTS
                
OPANDI          LEA     ANDIMESSAGE, A1 *Store the ANDI message
                MOVE.B  #$14, D4
                RTS

*---------------------------------------END_CHECK0000--------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
*                                            Subroutine: CHECK1110
*Description: Checks if opcode word starts with the binary 1110. If true it identifies if it is LSR/LSL,ASR/ASL,ROR/ROL
*----------------------------------------------------------------------------------------------------
CHECK1110       AND.W   #$F000, D1      *Isolates the first 4 spaces
                CMP.W   #$E000, D1      *Checks if the first 4 spaces are 1110
                
                BEQ     CHECKLAR        *If true, then it's LSR, ASR or ROR (and left versions)
                
                RTS
                
CHECKLAR        MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$C0, D1        *Isolate spaces 7-6
                CMP.W   #$C0, D1        *Check if spaces 7-6 are 11
                
                BEQ     CHECKLARM       *If true, then it's LSR, ASR or ROR (memory shift)
                
                BRA     CHECKLARR       *If not, then it's LRS, ASR or ROR (register shift)
                
CHECKLARM       MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$600, D1       *Isolate spaces 10-9
                CMP.W   #$200, D1       *Check if spaces 10-9 are 01
                
                BEQ     CHECKLSM        *If true, it's LS (memory)
                
                CMP.W   #$0000, D1      *Check if spaces 10-9 are 00
                
                BEQ     CHECKASM        *If true, it's AS (memory)
                
                CMP.W   #$600, D1       *Check if spaces 10-9 are 11
                
                BEQ     CHECKROM        *If true, it's RO (memory)
                
CHECKLARR       MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$18, D1        *Isolate spaces 4-3
                CMP.W   #$8, D1         *Check if spaces 4-3 are 01
                
                BEQ     CHECKLSRE       *If true, it's LS (register)
                
                CMP.W   #$0000, D1      *Check if spaces 4-3 are 00
                
                BEQ     CHECKASRE       *If true, it's AS (register)
                
                CMP.W   #$18, D1        *Check if spaces 4-3 are 11
                
                BEQ     CHECKRORE       *If true, it's RO (register)
                
CHECKLSM        MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8 
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPLSLM          *If true, it's LSL (memory)
                
                BRA     OPLSRM          *If not, it's LSR (memory)
                
CHECKASM        MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8 
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPASLM          *If true, it's ASL (memory)
                
                BRA     OPASRM          *If not, it's ASR (memory)
                
CHECKROM        MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8 
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPROLM          *If true, it's ROL (memory)
                
                BRA     OPRORM          *If not, it's ROR (memory)
                
CHECKLSRE       MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8 
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPLSLR          *If true, it's LSL (register)
                
                BRA     OPLSRR          *If not, it's LSR (register)
                
CHECKASRE       MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8 
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPASLR          *If true, it's ASL (register)
                
                BRA     OPASRR          *If not, it's ASR (register)
                
CHECKRORE       MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$100, D1       *Isolate space 8 
                CMP.W   #$100, D1       *Check if space 8 is 1
                
                BEQ     OPROLR          *If true, it's ROL (register)
                
                BRA     OPRORR          *If not, it's ROR (register)
                
OPLSLM          LEA     LSLMESSAGE, A1 *Store the LSL (memory) message
                MOVE.B  #$15, D4
                RTS
                
OPLSLR          LEA     LSLMESSAGE, A1 *Store the LSL (register) message
                MOVE.B  #$15, D4
                RTS
                
OPLSRM          LEA     LSRMESSAGE, A1 *Store the LSR (memory) message
                MOVE.B  #$15, D4
                RTS
                
OPLSRR          LEA     LSRMESSAGE, A1 *Store the LSR (register) message
                MOVE.B  #$15, D4
                RTS

OPASLM          LEA     ASLMESSAGE, A1 *Store the ASL (memory) message
                MOVE.B  #$16, D4
                RTS

OPASLR          LEA     ASLMESSAGE, A1 *Store the ASL (register) message
                MOVE.B  #$16, D4
                RTS

OPASRM          LEA     ASRMESSAGE, A1 *Store the ASR (memory) message
                MOVE.B  #$16, D4
                RTS

OPASRR          LEA     ASRMESSAGE, A1 *Store the ASR (register) message
                MOVE.B  #$16, D4
                RTS

OPROLM          LEA     ROLMESSAGE, A1 *Store the ROL (memory) message
                MOVE.B  #$17, D4
                RTS

OPROLR          LEA     ROLMESSAGE, A1 *Store the ROL (register) message
                RTS

OPRORM          LEA     RORMESSAGE, A1 *Store the ROR (memory) message
                RTS

OPRORR          LEA     RORMESSAGE, A1 *Store the ROR (register) message
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
                MOVE.B  #$0, D4
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
