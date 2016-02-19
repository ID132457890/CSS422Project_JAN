*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $200
stack EQU    $7000    *sp initial
START LEA stack,SP
    
    *Ask for input
    MOVE.B      #4, D0
    TRAP        #15
    
    *Move what has been typed in D1 to A3 (it's the address)
    MOVEA.L      D1, A3
    
    *Move the opcode part to D0
LOOP    MOVE.W      (A3), D0
    *Increase the address by 2, since that part has been read
    ADDA.W       #$2, A3
     
    
    JSR decode_opcode
   
    JSR decode_ea
    
    JSR print_assembly
    BRA END
    
    


*******************************************************************   
*Subroturine decode_opcode()                                      *
*Description Decodes opcode word into unique id representing      *
*            opcode and puts it into D4                           *
*******************************************************************
decode_opcode  
         MOVE.W D0, D1 *Make a backup of the opcode word so it can be restored when more than one test is done on it
         ANDI.W  #$F000,D0 *make last two chars 0
         CMP.W #$1000, D0
         BEQ MOVEB
        
         CMP.W #$3000, D0
         BEQ MOVEW
       
         CMP.W #$2000, D0
         BEQ MOVEL
       
         BRA BAD
        
MOVEB     MOVEQ #1, D4
          LEA MOVEBMESSAGE, A1 
          RTS       
MOVEW    MOVEQ #1,D4
         LEA MOVEWMESSAGE, A1

         RTS      
              
MOVEL   MOVEQ #1,D4 
        LEA MOVELMESSAGE, A1
           RTS    

BAD        RTS
*******************************************************************
*End of decode_opcode()                                           *
*******************************************************************
        
               
*******************************************************************
*Subroturine decode_ea                                            *
*Description: uses id in D4 to decode the number of words to read *
* puts the number of words to read for source and destination     *
*               into D1 and D2                                    *
*******************************************************************
decode_ea  
    
    MOVE.W      D1,D0 *Make a copy of the OpCode Word and placing it into D0.
    ANDI.W      #$0FFF,D1 *This masks D1 so that you turn the left most 1 into the 0.       
 *Now move the number of bytes that are needed for source and destination to D1 and D2 (let's say 1 for source and 2 for destination)
    MOVE.L      #$2, D1
    MOVE.L      #$2, D2
    
   * THESE TWO LINES ARE PULLING FFFFF
    *Now copy the source to D3 and destination to D4
    MOVE.W      (A3), D3
    ADDA.W       D1, A3
    
    MOVE.W      (A3), D4
    ADDA.W       D2, A3
        RTS       
*******************************************************************
*  End of decode_ea                                               *
*******************************************************************  

    
*******************************************************************
*Subroturine print_assembly                                       *
*Description:                                                     *
*                                                                 *
*                                                                 *
*******************************************************************
print_assembly 
    MOVE.B  #14,D0    
    TRAP #15      
    *Now check what source and destination are and move them to A1 and A2
    MOVE.B      #15, D0
    
    MOVE.L      D3, D1
    MOVE.B      #16, D2 *For trap 15 task 15, it's a base 16 number
    
    TRAP        #15 *Print the source
    
    MOVE.L      D4, D1
    MOVE.B      #16, D2 *For trap 15 task 15, it's a base 16 number
    
    TRAP        #15 *Print the destination  
        RTS       
*******************************************************************
*  End of print_assembly                                          *
*******************************************************************  
    
    
    
   
  

MOVEBMESSAGE DC.B 'MOVE.B',0


MOVEWMESSAGE DC.B 'MOVE.W',0    
MOVELMESSAGE DC.B 'MOVE.L',0
END    SIMHALT    
    END    START       last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
