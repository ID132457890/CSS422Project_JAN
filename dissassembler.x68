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
    
    JSR         CHECK0110 *Check for BCC opcode
   
    MOVE.B  #14, D0
    TRAP    #15
    SIMHALT   
*------------------------------------main----------------------------------------











*-----------------------------------------------------------------------------------------------------
*                                        Subroutine: CHECK0110
*Description: Checks if opcode word starts with the binary 0110. If true it identifies if it is BCC
*----------------------------------------------------------------------------------------------------

CHECK0110       *Check for BCC opcode
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F000,D1
                CMP.W #$6000,D1
                BEQ OPBXX
                RTS                  
                
               
                  
OPBXX          * check bit 11,10,9,8 for what bcc codition code                 
             
                
                                 
                *check if 11,10,9,8 is 1111
                MOVE.W D0,D1 *restore the opcode to d1
                AND.W #$F00,D1 *isolate bit 11-8
                CMP.W #$F00,D1                
                BEQ OPBLE 1111
            
                MOVE.W D0,D1
                AND.W #$E00,D1
                CMP.W #$E00,D1
                BEQ OPBGT
                
            
                MOVE.W D0,D1
                AND.W #$400,D1
                CMP.W #$400,D1
                BEQ OPBCC
                     RTS
                
OPBCC    LEA BCCMESSAGE, A1   
         RTS
         
OPBGT    LEA BGTMESSAGE, A1   
         RTS

OPBLE    LEA BLEMESSAGE, A1   
         RTS
*------------------------------------------CHECK0110-------------------------------------------------------

BCCMESSAGE      DC.B     'BCC', 0
BGTMESSAGE      DC.B     'BGT', 0
BLEMESSAGE      DC.B     'BLE',0

    END    START        ; last line of source
   













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
