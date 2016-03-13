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
    JSR         CLEARALL
    MOVEA.L     #$0, A1
    MOVEA.L     #$0, A2
    MOVEA.L     #$0, A3
    MOVEA.L     #$0, A4
    MOVEA.L     #$0, A5
    MOVEA.L     #$0, A6
    MOVEA.L     #$0, A7
    JSR         INPUT
    
LOOP    

    ADDA.L      #$1, A3 *Counter
    *Print the initial address
    JSR         PRINTADDRESS
    
    *Copy the opcode part to D0
    MOVE.W      (A0), D0
    
    *Copy the opcode to D1 for changes
    MOVE.W      (A0), D1
    
    MOVEA.W      A0, A6    *Keep original address in case there is an error
    
    *Increase the address by 2, since that part has been read
    ADDA.W       #$2, A0
    
    MOVE.B      #-1, D4     *Start at invalid
    
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
   
    MOVE.L      D0, D2          *Backup opcode
   
    CMP.B       #-1, D4
    BEQ         INVALIDOPCODE
    
    MOVE.L      D2, D0      *restore opcode
    CLR         D2
    
    JSR         CHECKEAS    *Checks the EAs
    
    *Would go below only if there are no errors
    MOVE.B  #14, D0         *Print opcode
    TRAP    #15
    
    JSR         PRINTSIZES  *Print the sizes
    
    CMP.B   #-1, D5
    BNE     SOURCE
    BRA     CONTINUE
    
SOURCE    JSR         PRINTSOURCE *Print source EA

    CMP.B   #-1, D6
    BEQ     DESTINATION
    
    JSR     PRINTCOMMA
    
DESTINATION     CMP.B   #-1, D6
    BNE     DEST
    BRA     CONTINUE
DEST    JSR         PRINTDESTINATION    *Print destination
CONTINUE    JSR         EMPTYLINE   
    
    CMP.L       A4, A0      *Check if the starting address is same as ending
    BGE         OUTPUTEND   *If yes, then stop
    
    JSR         CLEARALL
    
    CMP.L       #$18, A3
    BEQ         ASKFORCONTINUE
    
    BRA         LOOP        *If not, then loop back            
    
    SIMHALT   
*------------------------------------main----------------------------------------
    
ASKFORCONTINUE  LEA         CONTINUEMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      #5, D0  *Read y/n
ASKLOOP         TRAP        #15
                
                CMP.B       #$D, D1    *n
                BEQ         YESCONTINUE
                BRA ASKLOOP
             
                
YESCONTINUE     JSR         EMPTYLINE
                MOVEA.L     #$0, A3
                BRA         LOOP
                


INVALIDOPCODE   LEA         INVALIDMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                LEA         SPACEMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      #$4, D6             *Put actual size in D6
                MOVE.W      (A6), D3            *Move opcode in D3
INVALIDLOOP     ROL.W       #$4, D3             *Shift left to right position
                MOVE.W      D3, D0              *Move to D0 for backup
                AND.W       #$F, D3             *Isolate first byte
                MOVE.B      D3, D1              *Move byte to D1
                MOVE.W      D0, D3              *Move original back to D2
                AND.W       #$FFF0, D3          *Remove first 4 bits
                SUB.B       #$1, D6
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D6
                BNE         INVALIDLOOP
                
                BRA         CONTINUE

CLEARALL        CLR         D0
                CLR         D1
                CLR         D2
                CLR         D3
                CLR         D4
                CLR         D5
                CLR         D6
                CLR         D7
                
                *MOVEA.L     #$0, A1
                *MOVEA.L     #$0, A2
                *MOVEA.L     #$0, A6
                RTS
                
PRINTCOMMA      LEA         COMMAMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                RTS
                
*-----------------------------------PRINTSIZES-----------------------------------
*Description: This branch print the sizes (.b, .w, .l)
*--------------------------------------------------------------------------------
                
PRINTSIZES      CMP.B       #$1, D7         *Check if byte
                BEQ         PRINTBYTE
                
                CMP.B       #$2, D7         *Check if word
                BEQ         PRINTWORD   
                
                CMP.B       #$3, D7         *Check if long
                BEQ         PRINTLONG
                
                JSR         PRINTSPACE
                
                RTS
                
PRINTBYTE       LEA         BYTEMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                JSR         PRINTSPACE
                RTS
                
PRINTWORD       LEA         WORDMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                JSR         PRINTSPACE
                RTS
                
PRINTLONG       LEA         LONGMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                JSR         PRINTSPACE
                RTS
                
*-----------------------------------PRINTEAS-------------------------------------
*Description: This branch prints the EAs
*--------------------------------------------------------------------------------

PRINTDESTINATION     ADD.B       #$1, D6             *Add 1 to size

                CMP.B       #$1, D6             *Check if Dn
                BEQ         DNEAD                *It's DN
                
                CMP.B       #$2, D6             *Check if An
                BEQ         ANEAD
                
                CMP.B       #$4, D6             *Check if (An)
                BEQ         ANIEAD
                
                CMP.B       #$5, D6             *Check if (An)+
                BEQ         ANPLUSEAD       
                
                CMP.B       #$6, D6             *Check if -(An)
                BEQ         ANMINUSEAD      
                
                CMP.B       #$7, D6             *Check if xxx.w
                BEQ         XXXWEAD          
                
                CMP.B       #$8, D6             *Check if xxx.l
                BEQ         XXXLEAD
                
                CMP.B       #$9, D6             *Check if data
                BEQ         DATAEAD
                
                CMP.B       #$11, D6            *Check if list
                BEQ         ADLISTEAD
                
ADLISTEAD       CLR         D3
                CLR         D1
                CLR         D6
ADLISTEALOOPD   MOVE.B      (A2, D3), D1      *retrive element
                CMP.B       #$0, D6
                BNE         ADLISTSLASHD
                
ADLISTEALOOP2D  CMP.B       #7, D3              *Check if index less than 7
                BLE         DLISTD
                
                BRA         ALISTD
                
DLISTD          CMP.B       #$1, D1         *Check if element 1
                BNE         CHECKADLISTD
                
                LEA         DNMESSAGE, A1       *Show D
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D1, D6              *Conserve num
                MOVE.B      D3, D1              *Move counter to D1
                MOVE.B      #3, D0              *Show n
                TRAP        #15
                
                BRA         CHECKADLISTD
                
ALISTD          CMP.B       #$1, D1         *Check if element 1
                BNE         CHECKADLISTD
                
                LEA         ANMESSAGE, A1       *Show A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D1, D6              *Conserve num
                MOVE.B      D3, D1              *Move counter to D1
                SUB.B       #8, D1              *Subtract 8
                MOVE.B      #3, D0              *Show n
                TRAP        #15
                
                BRA         CHECKADLISTD
                
CHECKADLISTD    ADD.B       #1, D3              *add counter
                CMP.B       #16, D3
                BNE         ADLISTEALOOPD
                
                RTS        
                
ADLISTSLASHD    CMP.B       #$0, D1
                BEQ         ADLISTEALOOP2D
                
                LEA         SLASHMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                BRA         ADLISTEALOOP2D
                
DNEAD           LEA         DNMESSAGE, A1       *Show D
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D3, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                RTS
                
ANEAD           LEA         ANMESSAGE, A1       *Show A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D3, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                RTS
                
ANIEAD          LEA         ANIOPENMESSAGE, A1  *Show (A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D3, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                LEA         ANICLOSEMESSAGE, A1 *Show )  
                MOVE.B      #14, D0
                TRAP        #15   
                
                RTS
                
ANPLUSEAD       LEA         ANIOPENMESSAGE, A1  *Show (A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D3, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                LEA         ANPLUSCLOSEMESSAGE, A1 *Show )+  
                MOVE.B      #14, D0
                TRAP        #15  
                
                RTS
                
ANMINUSEAD      LEA         ANMINUSOPENMESSAGE, A1  *Show -(A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D3, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                LEA         ANICLOSEMESSAGE, A1 *Show )  
                MOVE.B      #14, D0
                TRAP        #15 
                
                RTS
                
XXXWEAD         LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15

                MOVE.B      #$4, D6             *Put actual size in D5
XXXWEALOOPD     ROL.W       #$4, D3             *Shift left to right position
                MOVE.W      D3, D0              *Move to D0 for backup
                AND.W       #$F, D3             *Isolate first byte
                MOVE.B      D3, D1              *Move byte to D1
                MOVE.W      D0, D3              *Move original back to D2
                AND.W       #$FFF0, D3          *Remove first 4 bits
                SUB.B       #$1, D6
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D6
                BNE         XXXWEALOOPD
                
                RTS
                
XXXLEAD         LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15

                MOVE.B      #$8, D6             *Put actual size in D5
XXXLEALOOPD     ROL.L       #$4, D3             *Shift left to right position
                MOVE.L      D3, D0              *Move to D0 for backup
                AND.L       #$F, D3             *Isolate first byte
                MOVE.B      D3, D1              *Move byte to D1
                MOVE.L      D0, D3              *Move original back to D2
                AND.L       #$FFFFFFF0, D3      *Remove first 4 bits
                SUB.B       #$1, D6
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D6
                BNE         XXXLEALOOPD
                
                RTS
     
DATAEAD         LEA         POUNDMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15

                CMP.L       #$1, D7
                BEQ         ADDBYTE
                
                CMP.L       #$2, D7
                BEQ         ADDWORD
                
                CMP.L       #$3, D7
                BEQ         ADDLONG
                
ADDBYTE         MOVE.L      #$2, D7
                BRA         DATAEALOOPD
                
ADDWORD         MOVE.L      #$4, D7
                BRA         DATAEALOOPD
              
ADDLONG         MOVE.L      #$8, D7
                BRA         DATAEALOOPD

DATAEALOOPD     ROL.L       #$4, D3             *Shift left to right position
                MOVE.L      D3, D0              *Move to D0 for backup
                AND.L       #$F, D3             *Isolate first byte
                CLR         D1
                MOVE.B      D3, D1              *Move byte to D1
                MOVE.L      D0, D3              *Move original back to D2
                AND.L       #$FFFFFFF0, D3      *Remove first 4 bits
                SUB.B       #$1, D7
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D7
                BNE         DATAEALOOPD
                
                RTS
                

PRINTSOURCE     ADD.B       #$1, D5             *Add 1 to size

                CMP.B       #$1, D5             *Check if Dn
                BEQ         DNEA                *It's DN
                
                CMP.B       #$2, D5             *Check if An
                BEQ         ANEA
                
                CMP.B       #$4, D5             *Check if (An)
                BEQ         ANIEA
                
                CMP.B       #$5, D5             *Check if (An)+
                BEQ         ANPLUSEA       
                
                CMP.B       #$6, D5             *Check if -(An)
                BEQ         ANMINUSEA      
                
                CMP.B       #$7, D5             *Check if xxx.w
                BEQ         XXXWEA          
                
                CMP.B       #$8, D5             *Check if xxx.l
                BEQ         XXXLEA
                
                CMP.B       #$9, D5             *Check if data
                BEQ         DATAEA
                
                CMP.B       #$11, D5            *Check if list
                BEQ         ADLISTEA
                
                CMP.B       #$12, D5            *Check if list
                BEQ         DALISTEA
                
ADLISTEA        CLR         D2
                CLR         D1
                CLR         D5
ADLISTEALOOP    MOVE.B      (A2, D2), D1      *retrive element
                CMP.B       #$0, D5
                BNE         ADLISTSLASH
                
ADLISTEALOOP2   CMP.B       #7, D2              *Check if index less than 7
                BLE         DLIST
                
                BRA         ALIST
                
DLIST           CMP.B       #$1, D1         *Check if element 1
                BNE         CHECKADLIST
                
                LEA         DNMESSAGE, A1       *Show D
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D1, D5              *Conserve num
                MOVE.B      D2, D1              *Move counter to D1
                MOVE.B      #3, D0              *Show n
                TRAP        #15
                
                BRA         CHECKADLIST
                
ALIST           CMP.B       #$1, D1         *Check if element 1
                BNE         CHECKADLIST
                
                LEA         ANMESSAGE, A1       *Show A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D1, D5              *Conserve num
                MOVE.B      D2, D1              *Move counter to D1
                SUB.B       #8, D1              *Subtract 8
                MOVE.B      #3, D0              *Show n
                TRAP        #15
                
                BRA         CHECKADLIST
                
CHECKADLIST     ADD.B       #1, D2              *add counter
                CMP.B       #16, D2
                BNE         ADLISTEALOOP
                
                RTS        
                
ADLISTSLASH     CMP.B       #$0, D1
                BEQ         ADLISTEALOOP2
                
                LEA         SLASHMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                BRA         ADLISTEALOOP2
               
                
DALISTEA        CLR         D2
                CLR         D1
                CLR         D5
DALISTEALOOP    MOVE.B      (A2, D2), D1      *retrive element
                CMP.B       #$0, D5
                BNE         DALISTSLASH
                
DALISTEALOOP2   CMP.B       #7, D2              *Check if index less than 7
                BLE         ALIST2
                
                BRA         DLIST2
                
DLIST2          CMP.B       #$1, D1         *Check if element 1
                BNE         CHECKDALIST
                
                LEA         DNMESSAGE, A1       *Show D
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D1, D5              *Conserve num
                MOVE.B      D2, D1              *Move counter to D1
                SUB.B       #8, D1              *Subtract 8
                MOVE.B      D1, D0              *Move counter to d0
                MOVE.B      #7, D1              *Move 7 to d1
                SUB.B       D0, D1              *Do 7 - counter
                MOVE.B      #3, D0              *Show n
                TRAP        #15
                
                BRA         CHECKDALIST
                
ALIST2          CMP.B       #$1, D1         *Check if element 1
                BNE         CHECKDALIST
                
                LEA         ANMESSAGE, A1       *Show A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D1, D5              *Conserve num
                MOVE.B      D2, D1              *Move counter to D1
                MOVE.B      D1, D0              *Move counter to d0
                MOVE.B      #7, D1              *Move 7 to d1
                SUB.B       D0, D1              *Do 7 - counter
                MOVE.B      #3, D0              *Show n
                TRAP        #15
                
                BRA         CHECKDALIST
                
CHECKDALIST     ADD.B       #1, D2              *add counter
                CMP.B       #16, D2
                BNE         DALISTEALOOP
                
                RTS        
                
DALISTSLASH     CMP.B       #$0, D1
                BEQ         DALISTEALOOP2
                
                LEA         SLASHMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                BRA         DALISTEALOOP2

                                
DNEA            LEA         DNMESSAGE, A1       *Show D
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D2, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                RTS
                
ANEA            LEA         ANMESSAGE, A1       *Show A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D2, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                RTS
                
ANIEA           LEA         ANIOPENMESSAGE, A1  *Show (A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D2, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                LEA         ANICLOSEMESSAGE, A1 *Show )  
                MOVE.B      #14, D0
                TRAP        #15   
                
                RTS
                
ANPLUSEA        LEA         ANIOPENMESSAGE, A1  *Show (A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D2, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                LEA         ANPLUSCLOSEMESSAGE, A1 *Show )+  
                MOVE.B      #14, D0
                TRAP        #15  
                
                RTS
                
ANMINUSEA       LEA         ANMINUSOPENMESSAGE, A1  *Show -(A
                MOVE.B      #14, D0
                TRAP        #15
                
                MOVE.B      D2, D1              *Show n
                MOVE.B      #3, D0
                TRAP        #15
                
                LEA         ANICLOSEMESSAGE, A1 *Show )  
                MOVE.B      #14, D0
                TRAP        #15 
                
                RTS
                
XXXWEA          LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15

                MOVE.B      #$4, D5             *Put actual size in D5
XXXWEALOOP      ROL.W       #$4, D2             *Shift left to right position
                MOVE.W      D2, D0              *Move to D0 for backup
                AND.W       #$F, D2             *Isolate first byte
                MOVE.B      D2, D1              *Move byte to D1
                MOVE.W      D0, D2              *Move original back to D2
                AND.W       #$FFF0, D2          *Remove first 4 bits
                SUB.B       #$1, D5
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D5
                BNE         XXXWEALOOP
                
                RTS
                
XXXLEA          LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15

                MOVE.B      #$8, D5             *Put actual size in D5
XXXLEALOOP      ROL.L       #$4, D2             *Shift left to right position
                MOVE.L      D2, D0              *Move to D0 for backup
                AND.L       #$F, D2             *Isolate first byte
                MOVE.B      D2, D1              *Move byte to D1
                MOVE.L      D0, D2              *Move original back to D2
                AND.L       #$FFFFFFF0, D2      *Remove first 4 bits
                SUB.B       #$1, D5
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D5
                BNE         XXXLEALOOP
                
                RTS
                
DATAEA          LEA         POUNDMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15
                
                LEA         DOLLARMESSAGE, A1
                MOVE.B      #14, D0
                TRAP        #15

                CMP.L       #$1, D7
                BEQ         ADDBYTES
                
                CMP.L       #$2, D7
                BEQ         ADDWORDS
                
                CMP.L       #$3, D7
                BEQ         ADDLONGS
                
ADDBYTES        MOVE.L      #$2, D7
                MOVE.L      #$1, D5
                BRA         DATAEALOOP
                
ADDWORDS        MOVE.L      #$4, D7
                MOVE.L      #$2, D5
                BRA         DATAEALOOP
              
ADDLONGS        MOVE.L      #$8, D7
                MOVE.L      #$3, D5
                BRA         DATAEALOOP
                
DATAEALOOP      CMP.W       #$1, D5
                BEQ         BYTEDATA
                
                CMP.W       #$2, D5
                BEQ         WORDDATA
                
                CMP.W       #$3, D5
                BEQ         LONGDATA
                
BYTEDATA        ROL.B       #$4, D2             *Shift left to right position
                BRA         DATAEALOOP2
                
WORDDATA        ROL.W       #$4, D2             *Shift left to right position
                BRA         DATAEALOOP2
                
LONGDATA        ROL.L       #$4, D2             *Shift left to right position
                BRA         DATAEALOOP2
               
DATAEALOOP2     MOVE.L      D2, D0              *Move to D0 for backup
                AND.L       #$F, D2             *Isolate first byte
                CLR         D1
                MOVE.B      D2, D1              *Move byte to D1
                MOVE.L      D0, D2              *Move original back to D2
                AND.L       #$FFFFFFF0, D2      *Remove first 4 bits
                SUB.B       #$1, D7
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D7
                BNE         DATAEALOOP
                
                RTS

*-----------------------------------Input----------------------------------------
*Description: This branch handles the input part of the disassmbler
*--------------------------------------------------------------------------------

INPUT           LEA         INPUTMESSAGE, A1    *Show the first line
                MOVE.B      #13, D0
                TRAP        #15    
                LEA         INPUTMESSAGE1, A1
                MOVE.B      #13, D0
                TRAP        #15  

INPUTLOOP       MOVE.B      #5, D0              *Wait for user input (character)
                TRAP        #15
                
CHECKIFCOMMA    CMP.B       #$2C, D1            *If not, check if it's a comma
                BEQ         COMMAINPUT          *If yes, it's a comma
                
CHECKIFPERIOD   CMP.B       #$2E, D1            *If not, check if it's a period
                BEQ         PERIODINPUT         *If yes, it's a period
                
CHECKBACKSPACE  CMP.B       #$8, D1             *If not, check if backspace
                BEQ         BACKSPACEINPUT
                
CHECKLCA        CMP.B       #$61, D1
                BGE         CHECKLCZ
                
                BRA         CHECKMOREA
                
CHECKLCZ        CMP.B       #$7A, D1
                BLE         DECREASELC
                
                BRA         CHECKMOREA
                
DECREASELC      SUB.W       #$20, D1
                BRA         CHECKMOREA
        
CHECKMOREA      CMP.B       #$41, D1            *Check if letter better than A
                BGE         CHECKLESSF          *If yes, check if less than F
                
                BRA         CHECKMORE0          *If not, check if number
                
CHECKLESSF      CMP.B       #$46, D1            *Check if less than F
                BLE         LETTERINPUT         *If yes, then it's an acceptable letter input
        
CHECKMORE0      CMP.B       #$30, D1            *If not, then check if number better than 0
                BGE         CHECKIFLESS9        *If yes, check if less than 9
                
                BRA         INPUTLOOP
                
CHECKIFLESS9    CMP.B       #$39, D1            *Check if less than 9
                BLE         NUMBERINPUT         *If yes, then it's a number input
                
                BRA         INPUTLOOP           *If not, then it's an unacceptable characher
        
LETTERINPUT     SUB.B       #$37, D1            *Subtract 37 from D1 (since it's in ASCII)
                BRA         DOREST
        
NUMBERINPUT     SUB.B       #$30, D1            *Subtract 30 from D1 (since it's in ASCII)
                BRA         DOREST
                
COMMAINPUT      ADD.B       #$1, D4             *Add 1 to D4 to show that the ending address
                BRA         INPUTLOOP 
                
PERIODINPUT     CMP.L       D2, D3
                BLT         SWITCHINPUT
                
                MOVEA.L     D2, A0              *Move the starting address to A0
                MOVEA.L     D3, A4              *Move the ending address to A4
                MOVEA.L     D6, A5

                BRA         EMPTYLINE
                
SWITCHINPUT     MOVEA.L     D2, A4              *Move the starting address to A0
                MOVEA.L     D3, A0              *Move the ending address to A0
                MOVEA.L     D5, A5


                BRA         EMPTYLINE
                
BACKSPACEINPUT  CMP.B       #$0, D4             *Check if starting address or not
                BEQ         BACKSTART
                
                BEQ         BACKEND
                
BACKSTART       ASR.L       #$4, D2             *Shift to right
                SUB.L       #$1, D5             *Subtract size
                *SUBA.L       #$1, A5

                SUBA.L       #$1, A5
                
                BRA         INPUTLOOP
                
BACKEND         CMP.B       #$0, D6
                BEQ         BACKCOMMA
                
                ASR.L       #$4, D3             *Shift to right
                SUB.L       #$1, D6             *Subtract size
                
                BRA         INPUTLOOP
                
BACKCOMMA       MOVE.L      #$0, D4
                BRA         INPUTLOOP
        
DOREST          CMP.B       #$0, D4             *Check if it's starting or ending
                BEQ         STARTINGADDRESS     *If yes, it's part of starting address
                
                BRA         ENDINGADDRESS       *If not, it's part of ending address
                
STARTINGADDRESS ASL.L       #$4, D2             *Shift to left
                ADD.L       D1, D2              *Add the number to D2
                ADD.L       #$1, D5             *Add count in D5

                *ADDA.L      #$1, A5             *Add to A5 as well

                ADDA.L      #$1, A5             *Add to A5 as well
    
                BRA         INPUTLOOP           *Go back to the input loop
                
ENDINGADDRESS   ASL.L       #$4, D3             *Shift to left
                ADD.L       D1, D3              *Add the number to D3
                ADD.L       #$1, D6             *Add count in D6

                ADDA.L      #$1, A5

        
                BRA         INPUTLOOP           *Go back to the input loop
            
EMPTYLINE       LEA         EMPTYLINEMESSAGE, A1  *Empty line
                MOVE.B      #13, D0
                TRAP        #15
                
                RTS

*----------------------------------------------------------------------------------------------------
*                                           Subroutine: OUTPUTEND
*Description: Handles what happens when the dissassembler is done
*----------------------------------------------------------------------------------------------------

OUTPUTEND       LEA         ENDMESSAGE, A1
                MOVE.B      #13, D0
                TRAP        #15

                
   
        

ENDLOOP    
                MOVE.B #5, D0
                TRAP #15
                CMP.B #$6E,D1
                
                BEQ DONE
                
                CMP.B #$79,D1                
                BEQ TESTNEWRANGE                
                BRA ENDLOOP
TESTNEWRANGE    
                *start next line on a new line
                MOVE.B #14,D0   
                LEA NEWLINE,A1
                TRAP #15          
                
                *zero out memory 
                JSR CLEARALL      
                
                *start program over          
                BRA START

DONE SIMHALT   


*----------------------------------------------------------------------------------------------------*                                           
*Subroutine: PRINTADDRESS
*Description: Prints the current address the disassembler is on
*----------------------------------------------------------------------------------------------------

PRINTADDRESS    MOVE.L      A0, D2              *Move current address to D2
                MOVE.L      A5, D5              *Move address size
                *ADD.L       #$1, D5             *Add 1 to size
                CMP.L       #$4, D5             *Check if the length is >4
                BGT         PRINTLONGADDRESS    *If yes, it's a long address

                CMP.L       #$2, D5             *Check if the length is >2
                BGT         PRINTWORDADDRESS    *If yes, it's a word address
                
                BRA         PRINTBYTEADDRESS    *If not, it's a byte address
                
PRINTLONGADDRESS    MOVE.L  #$8, D7
                    SUB.L   D5, D7
                    MULS.W  #$4, D7
                    ROL.L   D7, D2
PLAL                ROL.L   #$4, D2             *Shift by 4 bits
                    MOVE.L  D2, D7              *Move to D7 for backup
                    AND.L   #$F, D2             *Isolate first byte
                    MOVE.B  D2, D1              *Move byte to D1
                    MOVE.L  D7, D2              *Move original back to D2
                    AND.L   #$FFFFFFF0, D2      *Remove first 4 bits
                    SUB.B   #$1, D5             *Subtract 1 from length of address
                    
                    JSR     COMPAREADDRESS        *Print the address
                    
                    CMP.L   #$0, D5             *Check if the address length is 0
                    BNE     PLAL                *If not, then loop again
                    
                    BRA     PRINTSPACE          *If yes, then stop and print empty line
                    
PRINTWORDADDRESS    MOVE.L  #$4, D7
                    SUB.W   D5, D7
                    MULS.W  #$4, D7
                    ROL.W   D7, D2
PWAL                ROL.W   #$4, D2             *Shift by 4 bits
                    MOVE.L  D2, D7              *Move to D7 for backup
                    AND.L   #$F, D2             *Isolate first byte
                    MOVE.B  D2, D1              *Move byte to D1
                    MOVE.L  D7, D2              *Move original back to D2
                    AND.L   #$FFFFFFF0, D2      *Remove first 4 bits
                    SUB.B   #$1, D5             *Subtract 1 from length of address
                    
                    JSR     COMPAREADDRESS        *Print the address
                    
                    CMP.W   #$0, D5             *Check if the address length is 0
                    BNE     PWAL                *If not, then loop again
                    
                    BRA     PRINTSPACE          *If yes, then stop and print empty line
                    
PRINTBYTEADDRESS    MOVE.L  #$2, D7
                    SUB.W   D5, D7
                    MULS.W  #$4, D7
                    ROL.B   D7, D2
PBAL                ROL.B   #$4, D2             *Shift by 4 bits
                    MOVE.L  D2, D7              *Move to D7 for backup
                    AND.L   #$F, D2             *Isolate first byte
                    MOVE.B  D2, D1              *Move byte to D1
                    MOVE.L  D7, D2              *Move original back to D2
                    AND.L   #$FFFFFFF0, D2      *Remove first 4 bits
                    SUB.B   #$1, D5             *Subtract 1 from length of address
                    
                    JSR     COMPAREADDRESS        *Print the address
                    
                    CMP.B   #$0, D5             *Check if the address length is 0
                    BNE     PBAL                *If not, then loop again
                    
                    BRA     PRINTSPACE          *If yes, then stop and print empty line
                    
PRINTSPACE          LEA     SPACEMESSAGE, A1    *Display space
                    MOVE.B  #14, D0
                    TRAP    #15
                    
                    RTS
                    
COMPAREADDRESS      CMP.B   #$0, D1             *Check if 0
                    BEQ     NUMBERZERO
                    
                    CMP.B   #$1, D1             *etc
                    BEQ     NUMBERONE
                    
                    CMP.B   #$2, D1
                    BEQ     NUMBERTWO
                    
                    CMP.B   #$3, D1
                    BEQ     NUMBERTHREE
                    
                    CMP.B   #$4, D1
                    BEQ     NUMBERFOUR
                    
                    CMP.B   #$5, D1
                    BEQ     NUMBERFIVE
                    
                    CMP.B   #$6, D1
                    BEQ     NUMBERSIX
                    
                    CMP.B   #$7, D1
                    BEQ     NUMBERSEVEN
                    
                    CMP.B   #$8, D1
                    BEQ     NUMBEREIGHT
                    
                    CMP.B   #$9, D1
                    BEQ     NUMBERNINE
                    
                    CMP.B   #$A, D1
                    BEQ     NUMBERA
                    
                    CMP.B   #$B, D1
                    BEQ     NUMBERB
                    
                    CMP.B   #$C, D1
                    BEQ     NUMBERC
                    
                    CMP.B   #$D, D1
                    BEQ     NUMBERD
                    
                    CMP.B   #$E, D1
                    BEQ     NUMBERE
                    
                    CMP.B   #$F, D1
                    BEQ     NUMBERF

NUMBERZERO          LEA     ZEROMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERONE           LEA     ONEMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERTWO           LEA     TWOMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERTHREE         LEA     THREEMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERFOUR          LEA     FOURMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERFIVE          LEA     FIVEMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERSIX           LEA     SIXMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERSEVEN         LEA     SEVENMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBEREIGHT         LEA     EIGHTMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERNINE          LEA     NINEMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERA             LEA     AMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERB             LEA     BMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERC             LEA     CMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERD             LEA     DMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERE             LEA     EMESSAGE, A1
                    BRA     SHOWADDRESS
                    
NUMBERF             LEA     FMESSAGE, A1
                    BRA     SHOWADDRESS
                    
                    
SHOWADDRESS         MOVE.B  #14, D0             *Show number
                    TRAP    #15
                    
                    RTS                         *Go back
                    
                    
                                   

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
                
                BEQ     OPMULS          *If yes, then it's MULS
                    
                BRA     OPAND          *If not, then it's AND
OPAND           LEA     ANDMESSAGE, A1  *Store the AND message
                MOVE.B  #$13, D4
                
                MOVE.W  D0, D1
                AND.W   #$1C0, D1       *Isolate OPMODE part
                CMP.W   #$0, D1         *If OPMODE 000
                BEQ     SIZEB           *If yes, it's byte 
                
                CMP.W   #$100, D1       *If OPMODE 100
                BEQ     SIZEB           *If yes, it's byte
                
                CMP.W   #$40, D1        *If OPMODE 001
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$140, D1       *If OPMODE 101
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$80, D1        *If OPMODE 010
                BEQ     SIZEL           *If yes, it's long
                
                CMP.W   #$180, D1       *If OPMODE 110
                BEQ     SIZEL           *If yes, it's long
                
                RTS   
                
OPMULS          LEA     MULSMESSAGE, A1 *Store the MULS message
                MOVE.B  #$9, D4
                
                BRA     SIZEW           *It's always a word
                
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
                
                BEQ     OPBCHGR         *If yes, then it's BCHG (register)
                
                MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$800, D1       *Isolate space 11
                CMP.W   #$800, D1       *Check if space 11 is 1
                
                BEQ     CHECKCBD        *If yes, then check if CMPI or BCHG (data)
                
                MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$400, D1       *Isolate space 10
                CMP.W   #$400, D1       *Check if space 10 is 1
                
                BEQ     OPADDI          *If true, then it's ADDI
                
                BRA     OPANDI          *If not, then it's ANDI
                
CHECKCBD        MOVE.W  D0, D1          *Move the original opcode to D1 since we need original
                AND.W   #$400, D1       *Isolate space 10
                CMP.W   #$400, D1       *Check if space 10 is 1

                BEQ     OPCMPI          *If yes, then it's CMPI

                BRA     OPBCHGD         *If not, then it's BCHG (data)

OPMOVE          LEA     MOVEMESSAGE, A1 *Store the MOVE message
                MOVE.B  #$1, D4
                MOVE.B  #$1, D7
                
                MOVE.W  D0, D1
                AND.W   #$3000, D1      *Isolate SIZE
                
                CMP.W   #$1000, D1      *Check if size is 01
                BEQ     SIZEB           *If yes, it's a byte
                
                CMP.W   #$3000, D1      *Check if size is 11
                BEQ     SIZEW           *If yes, it's a word
                
                CMP.W   #$2000, D1      *Check if size is 10
                BEQ     SIZEL           *If yes, it's a long
                
                RTS

OPBCHGR         LEA     BCHGMESSAGE, A1 *Store the BCHG message
                MOVE.B  #$18, D4
                
                BRA     SIZEB           *When it's register, it's always byte
                
                RTS
                
OPBCHGD         LEA     BCHGMESSAGE, A1 *Store the BCHG message
                MOVE.B  #$24, D4
                
                BRA     SIZEL           *When data, it's always long
                
                RTS
                
OPCMPI          LEA     CMPIMESSAGE, A1 *Store the CMPI message
                MOVE.B  #$20, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS
                
OPADDI          LEA     ADDIMESSAGE, A1 *Store the ADDI message
                MOVE.B  #$6, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS
                
OPANDI          LEA     ANDIMESSAGE, A1 *Store the ANDI message
                MOVE.B  #$14, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS

*---------------------------------------END_CHECK0000--------------------------------------------------------

*-----------------------------------------------------------------------------------------------------
*                                            Subroutine: CHECK1110
*Description: Checks if opcode word starts with the binary 1110. If true it identifies if it is LSR/LSL,ASR/ASL,ROR/ROL
*----------------------------------------------------------------------------------------------------
CHECK1110       MOVE.W  D0, D1
                AND.W   #$F000, D1      *Isolates the first 4 spaces
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
                MOVE.B  #$25, D4
                
                BRA     SIZEW           *It's always a word when memory
                
                RTS
                
OPLSLR          LEA     LSLMESSAGE, A1 *Store the LSL (register) message
                MOVE.B  #$15, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS
                
OPLSRM          LEA     LSRMESSAGE, A1 *Store the LSR (memory) message
                MOVE.B  #$25, D4
                
                BRA     SIZEW           *It's always a word when memory
                
                RTS
                
OPLSRR          LEA     LSRMESSAGE, A1 *Store the LSR (register) message
                MOVE.B  #$15, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS

OPASLM          LEA     ASLMESSAGE, A1 *Store the ASL (memory) message
                MOVE.B  #$26, D4
                
                BRA     SIZEW           *It's always a word when memory
                
                RTS

OPASLR          LEA     ASLMESSAGE, A1 *Store the ASL (register) message
                MOVE.B  #$16, D4
                RTS

OPASRM          LEA     ASRMESSAGE, A1 *Store the ASR (memory) message
                MOVE.B  #$26, D4
                
                BRA     SIZEW           *It's always a word when memory
                
                RTS

OPASRR          LEA     ASRMESSAGE, A1 *Store the ASR (register) message
                MOVE.B  #$16, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS

OPROLM          LEA     ROLMESSAGE, A1 *Store the ROL (memory) message
                MOVE.B  #$27, D4
                
                BRA     SIZEW           *It's always a word when memory
                
                RTS

OPROLR          LEA     ROLMESSAGE, A1 *Store the ROL (register) message
                MOVE.B  #$17, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
                RTS

OPRORM          LEA     RORMESSAGE, A1 *Store the ROR (memory) message
                MOVE.B  #$27, D4
                
                BRA     SIZEW           *It's always a word when memory
                
                RTS

OPRORR          LEA     RORMESSAGE, A1 *Store the ROR (register) message
                MOVE.B  #$17, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1      *Isolate SIZE
                
                CMP.W   #$0, D1         *Check if size is 00
                BEQ     SIZEB        *If yes, it's a byte
                
                CMP.W   #$40, D1      *Check if size is 01
                BEQ     SIZEW         *If yes, it's a word
                
                CMP.W   #$80, D1      *Check if size is 10
                BEQ     SIZEL         *If yes, it's a long
                
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
                MOVE.B  #$19, D4
                
                MOVE.W  D0, D1
                AND.W   #$1C0, D1       *Isolate OPMODE part
                
                CMP.W   #$0, D1         *If OPMODE 000
                BEQ     SIZEB           *If yes, it's byte 
                
                CMP.W   #$40, D1        *If OPMODE 001
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$80, D1        *If OPMODE 010
                BEQ     SIZEL           *If yes, it's long
                
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
                MOVE.B  #$2, D4
                
                BRA     SIZEL           *It's always a long operation
                
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
         MOVE.B  #$21, D4
         RTS
         
OPBGT    LEA BGTMESSAGE, A1 
         MOVE.B  #$21, D4  
         RTS

OPBLE    LEA BLEMESSAGE, A1   
         MOVE.B  #$21, D4
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
                MOVE.B  #$5, D4
                
                MOVE.W  D0, D1
                AND.W   #$1C0, D1       *Isolate OPMODE part
                CMP.W   #$C0, D1         *If OPMODE 011
                BEQ     SIZEW           *If yes, it's word 
                
                CMP.W   #$1C0, D1       *If OPMODE 111
                BEQ     SIZEL           *If yes, it's long
                
                RTS
                
OPADD           LEA ADDMESSAGE,A1
                MOVE.B  #$4, D4
                
                MOVE.W  D0, D1
                AND.W   #$1C0, D1       *Isolate OPMODE part
                CMP.W   #$0, D1         *If OPMODE 000
                BEQ     SIZEB           *If yes, it's byte 
                
                CMP.W   #$100, D1       *If OPMODE 100
                BEQ     SIZEB           *If yes, it's byte
                
                CMP.W   #$40, D1        *If OPMODE 001
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$140, D1       *If OPMODE 101
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$80, D1        *If OPMODE 010
                BEQ     SIZEL           *If yes, it's long
                
                CMP.W   #$180, D1       *If OPMODE 110
                BEQ     SIZEL           *If yes, it's long
                
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
                MOVE.B  #$8, D4
                
                MOVE.W  D0, D1
                AND.W   #$1C0, D1       *Isolate OPMODE part
                CMP.W   #$C0, D1         *If OPMODE 011
                BEQ     SIZEW           *If yes, it's word 
                
                CMP.W   #$1C0, D1       *If OPMODE 111
                BEQ     SIZEL           *If yes, it's long
                
                RTS
                
OPSUB           LEA SUBMESSAGE,A1
                MOVE.B  #$7, D4
                
                MOVE.W  D0, D1
                AND.W   #$1C0, D1       *Isolate OPMODE part
                CMP.W   #$0, D1         *If OPMODE 000
                BEQ     SIZEB           *If yes, it's byte 
                
                CMP.W   #$100, D1       *If OPMODE 100
                BEQ     SIZEB           *If yes, it's byte
                
                CMP.W   #$40, D1        *If OPMODE 001
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$140, D1       *If OPMODE 101
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$80, D1        *If OPMODE 010
                BEQ     SIZEL           *If yes, it's long
                
                CMP.W   #$180, D1       *If OPMODE 110
                BEQ     SIZEL           *If yes, it's long
                
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
                MOVE.B  #$10, D4
                
                BRA     SIZEW           *It's always a word
                
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
                
                MOVE.W  D0, D1
                AND.W   #$800, D1   *Isolate 11 bit
                CMP.W   #$0, D1
                BEQ     OPCLR
                
                MOVE.W  D0, D1
                AND.W   #$200, D1   *Isolate 9 bit
                CMP.W   #$0, D1
                BEQ     OPMOVEM
                
                MOVE.W  D0, D1
                AND.W   #$38, D1   *Isolate 5, 4 and 3 bits
                CMP.W   #$110, D1
                BNE     OPJSR
              
                BRA     INVALIDOPCODE
                
 
OPNOP           LEA NOPMESSAGE,A1
                MOVE.B  #$0, D4
                MOVE.B  #$0, D7
                RTS    
OPJSR
                LEA JSRMESSAGE,A1
                MOVE.B  #$22, D4
                MOVE.B  #$0, D7
                RTS
OPLEA  
                LEA LEAMESSAGE,A1
                MOVE.B  #$11, D4
                
                MOVE.B  #$0, D7
                RTS
                *BRA     SIZEL           *It's always long
                
OPMOVEM         LEA OPMOVEMMESSAGE,A1
                MOVE.B  #$3, D4
                
                MOVE.W  D0, D1
                AND.W   #$40, D1       *Isolate SIZE part
                CMP.W   #$0, D1         *If SIZE 0
                BEQ     SIZEW           *If yes, it's word 
                
                CMP.W   #$40, D1       *If SIZE 1
                BEQ     SIZEL           *If yes, it's long
                
                RTS
                
OPRTS           LEA RTSMESSAGE,A1
                MOVE.B  #$23, D4
                MOVE.B  #$0, D7
                RTS
                
OPCLR           LEA CLRMESSAGE,A1
                MOVE.B  #$12, D4
                
                MOVE.W  D0, D1
                AND.W   #$C0, D1       *Isolate SIZE part
                
                CMP.W   #$0, D1         *If SIZE 0
                BEQ     SIZEB           *If yes, it's byte 
                
                CMP.W   #$40, D1       *If SIZE 1
                BEQ     SIZEW           *If yes, it's word
                
                CMP.W   #$80, D1       *If SIZE 1
                BEQ     SIZEL           *If yes, it's byte
                
                RTS
*----------------------------------------CHECK0100-------------------------------------------------------


*--------------------------------------------------------------------------------------------------------
*                                Subroutines for size of OPCode
* Description: Display following in D7: $0 if it's a byte opration, $1 if it's a word operation and $2 if
*              it's a long operation.
*--------------------------------------------------------------------------------------------------------
SIZEB           MOVE.B  #$1, D7
                RTS
                
SIZEW           MOVE.B  #$2, D7
                RTS
                
SIZEL           MOVE.B  #$3, D7
                RTS
*-------------------------------------OPCode sizes end---------------------------------------------------








*-------------------------------------EA Code begins-----------------------------------------------------
CHECKEAS        CMP.B   #$0, D4
                BEQ     NOPEA

                CMP.B   #$1, D4
                BEQ     MOVEEA
                
                CMP.B   #$2, D4
                BEQ     MOVEQEA
                
                CMP.B   #$3, D4
                BEQ     MOVEMEA
                
                CMP.B   #$4, D4
                BEQ     ADDEA
                
                CMP.B   #$5, D4
                BEQ     ADDAEA
                
                CMP.B   #$6, D4
                BEQ     ADDIEA

                CMP.B   #$7, D4
                BEQ     SUBEA
                
                CMP.B   #$9, D4
                BEQ     MULSEA
                
                CMP.B   #$10, D4
                BEQ     DIVUEA
                
                CMP.B   #$11, D4
                BEQ     LEAEA
                
                CMP.B   #$12, D4
                BEQ     CLREA
                
                CMP.B   #$13, D4
                BEQ     ANDEA
                
                CMP.B   #$15, D4
                BEQ     LSREA
                
                CMP.B   #$16, D4
                BEQ     ASREA
                
                CMP.B   #$17, D4
                BEQ     ROREA
                
                CMP.B   #$19, D4
                BEQ     CMPEA
                
                CMP.B   #$21, D4
                BEQ     BCCEA
                
                CMP.B   #$22, D4
                BEQ     JSREA
                
                CMP.B   #$23, D4
                BEQ     RTSEA
                
                CMP.B   #$25, D4
                BEQ     LSMEA
                
                CMP.B   #$26, D4
                BEQ     ASMEA
                
                CMP.B   #$27, D4
                BEQ     ROMEA
                


NOPEA       MOVE.B  #-1, D5
            RTS
            
RTSEA       MOVE.B  #-1, D5
            RTS

MOVEEA      MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     MOVEDATAREG
            
            CMP.L   #$8, D1     *Check if 001
            BEQ     MOVEADDRREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     MOVEINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     MOVEPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     MOVEMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     MOVEADDRESSDATA
            
            BRA     INVALIDOPCODE
            
MOVEDATAREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     MOVEDEST
            
MOVEADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of An
            MOVE.B  #$1, D5     *Move type of source
            
            BRA     MOVEDEST
            
MOVEINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     MOVEDEST
            
MOVEPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     MOVEDEST
            
MOVEMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     MOVEDEST
            
MOVEADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     MOVEADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     MOVEADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     MOVEDATA
            
            BRA     INVALIDOPCODE
            
MOVEADDRW   MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     MOVEDEST

MOVEADDRL   MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     MOVEDEST
            
MOVEDATA    CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     MOVESIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     MOVESIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     MOVESIZEL 

MOVESIZEB   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     MOVEDEST    *Branches to destination

MOVESIZEW   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     MOVEDEST    *Branches to destination

MOVESIZEL   MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     MOVEDEST    *Branches to destination

MOVEDEST    MOVE.W  D0, D1
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 00000111000000
            CMP.W   #$0, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     MOVEDATAREGD  *Goes to Dn Process 
        
            CMP.W   #$80, D1   *Checks (An)
            BEQ     MOVEINADDRD
        
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     MOVEPOSTADDRD
        
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     MOVEPREADDRD
        
            CMP.W   #$1C0, D1 *Checks Addressing Mode
            BEQ     MOVEADDRD
            
            BRA     INVALIDOPCODE
            
MOVEDATAREGD    MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D3
                MOVE.B  #$0, D6
                
                RTS
                
MOVEINADDRD     MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D3
                MOVE.B  #$1, D6
                
                RTS
                
MOVEPOSTADDRD   MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D3
                MOVE.B  #$3, D6
                
                RTS
                
MOVEPREADDRD    MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D3
                MOVE.B  #$4, D6
                
                RTS
                
MOVEADDRD       MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                
                CMP.W   #$0, D1     *Check if 000
                BEQ     MOVEADDRWD  
                
                CMP.W   #$200, D1     *Check if 001
                BEQ     MOVEADDRLD  
                
                BRA     INVALIDOPCODE
                
MOVEADDRWD      MOVE.W  (A0), D3
                MOVE.B  #$6, D6
                ADDA.L  #$2, A0
                
                RTS
                
MOVEADDRLD      MOVE.L  (A0), D3
                MOVE.B  #$7, D6
                ADDA.L  #$4, A0
                
                RTS







MOVEQEA         MOVE.L  D0, D1
                AND.W   #$FF, D1    *Isolate data
                MOVE.W  D1, D2
                MOVE.B  #$8, D5
                
                MOVE.L  D0, D1
                AND.W   #$E00, D1    *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D3
                MOVE.B  #$0, D6
                
                RTS
                
                
                
registers       DS.L    16
                
MOVEMEA         MOVE.L  D0, D1
                AND.W   #$400, D1       *Isolate dr field 
                
                CMP.W   #$400, D1       *Check if it's 1
                BEQ     MOVEMMR
                
                BRA     MOVEMRM
                
MOVEMRM         MOVE.W  (A0), D2
                ADDA.L  #$2, A0
                LEA     registers, A2   *Store array
                MOVE.L  #$10, D5
                MOVE.L  #$0, D6     *Counter
MOVEMRLOOP      MOVE.W  D2, D1      *For editing
                AND.W   #$1, D1
                
                CMP.W   #$1, D1
                BNE     MOVEMNOONES
                
                MOVE.B  #$1, (A2, D6)   *Insert 1 to array
                ADD.W   #1, D6
                ASR.W   #$1, D2     *Shift to right
                
                CMP.W   #16, D6
                BNE     MOVEMRLOOP
                
                BRA     MOVEMMDEST
                
MOVEMNOONES     MOVE.B  #$0, (A2, D6)
                ADD.W  #1, D6     *Add counter
                ASR.W   #$1, D2     *Shift to right
                
                CMP.W   #16, D6
                BNE     MOVEMRLOOP
                
                BRA     MOVEMMDEST
                
MOVEMMDEST      CLR     D6
                MOVE.L  D0, D1
                AND.L   #$38, D1    *Isolate source mode
            
                CMP.L   #$10, D1    *Check if 010
                BEQ     MOVEMINADDRREGD
                
                CMP.W   #$20, D1 *Checks -(An)
                BEQ     MOVEMPREADDRD
            
                CMP.L   #$38, D1     *Check if 111
                BEQ     MOVEMADDRESSD
                
                BRA     INVALIDOPCODE
                
MOVEMINADDRREGD MOVE.L  D0, D1
                AND.L   #$7, D1     *Isolate register
                MOVE.L  D1, D3      *Move value of an
                MOVE.B  #$3, D6     *Move type of dest
            
                RTS
                
MOVEMPREADDRD   MOVE.L  D0, D1
                AND.L   #$7, D1     *Isolate register
                MOVE.L  D1, D3      *Move value of an
                MOVE.B  #$5, D6     *Move type of dest
                MOVE.L  #$11, D5    *flip mask
            
                RTS
            
MOVEMADDRESSD   MOVE.L  D0, D1
                AND.L   #$7, D1     *Isolate register
            
                CMP.L   #$0, D1     *Check if 000
                BEQ     MOVEMADDRWD
            
                CMP.L   #$1, D1     *Check if 001
                BEQ     MOVEMADDRLD
                
                BRA     INVALIDOPCODE
            
MOVEMADDRWD     MOVE.W  (A0),D3     *Move addr
                MOVE.B  #$6, D6     *Store type
                ADDA.L  #$2, A0 
            
                RTS

MOVEMADDRLD     MOVE.L  (A0),D3     *Move addr
                MOVE.B  #$7, D6     *Store type
                ADDA.L  #$4, A0
            
                RTS
                
                
                
     
MOVEMMR         MOVE.W  (A0), D3
                ADDA.L  #$2, A0
                LEA     registers, A2   *Store array
                MOVE.L  #$10, D6
                MOVE.L  #$0, D5     *Counter
MOVEMRLOOPD     MOVE.W  D3, D1      *For editing
                AND.W   #$1, D1
                
                CMP.W   #$1, D1
                BNE     MOVEMNOONE
                
                MOVE.B  #$1, (A2, D5)   *Insert 1 to array
                ADD.W   #1, D5
                ASR.W   #$1, D3     *Shift to right
                
                CMP.W   #16, D5
                BNE     MOVEMRLOOPD
                
                BRA     MOVEMRDEST
                
MOVEMNOONE      MOVE.B  #$0, (A2, D5)
                ADD.W  #1, D5     *Add counter
                ASR.W   #$1, D3     *Shift to right
                
                CMP.W   #16, D5
                BNE     MOVEMRLOOPD
                
                BRA     MOVEMRDEST
                
MOVEMRDEST      MOVE.L  D0, D1
                AND.L   #$38, D1    *Isolate source mode
            
                CMP.L   #$10, D1    *Check if 010
                BEQ     MOVEMINADDRREG
                
                CMP.L   #$18, D1    *Check if 011
                BEQ     MOVEMPLUSADDRREG
            
                CMP.L   #$38, D1     *Check if 111
                BEQ     MOVEMADDRESS
                
                BRA     INVALIDOPCODE
            
MOVEMINADDRREG  MOVE.L  D0, D1
                AND.L   #$7, D1     *Isolate register
                MOVE.L  D1, D2      *Move value of an
                MOVE.B  #$3, D5     *Move type of source
            
                RTS 
                
MOVEMPLUSADDRREG MOVE.L  D0, D1
                AND.L   #$7, D1     *Isolate register
                MOVE.L  D1, D2      *Move value of an
                MOVE.B  #$4, D5     *Move type of source
            
                RTS
            
MOVEMADDRESS    MOVE.L  D0, D1
                AND.L   #$7, D1     *Isolate register
            
                CMP.L   #$0, D1     *Check if 000
                BEQ     MOVEMADDRW
            
                CMP.L   #$1, D1     *Check if 001
                BEQ     MOVEMADDRL
                
                RTS
            
MOVEMADDRW      MOVE.W  (A0),D2     *Move addr
                MOVE.B  #$6, D5     *Store type
                ADDA.L  #$2, A0 
            
                RTS

MOVEMADDRL      MOVE.L  (A0),D2     *Move addr
                MOVE.B  #$7, D5     *Store type
                ADDA.L  #$4, A0
            
                RTS

                
                
                
                
                

               
                
                
                
                
                
ADDEA           MOVE.W  D0, D1
                AND.W   #$1C0, D1     *Isolate opmode
                
                CMP.W   #$100, D1     *Check if < 100
                BLT     ADDEADN
                
                BRA     ADDDNEA
                
ADDDNEA         MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D2      *Move register to d2
                MOVE.B  #$0, D5
                
                BRA     ADDDNEADEST
                
ADDDNEADEST     MOVE.L  D0, D1
                AND.L   #$38, D1    *Isolate mode
            
                CMP.L   #$10, D1    *Check if 010
                BEQ     ADDINADDRREGD
            
                CMP.L   #$18, D1    *Check if 011
                BEQ     ADDPLUSADDRREGD
            
                CMP.L   #$20, D1    *Check if 100
                BEQ     ADDMINUSADDRREGD
            
                CMP.L   #$38, D1     *Check if 111
                BEQ     ADDADDRESSD
                
                BRA     INVALIDOPCODE
                
            
ADDINADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$3, D6     *Move type of source
            
            RTS
            
ADDPLUSADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$4, D6     *Move type of source
            
            RTS
            
ADDMINUSADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$5, D6     *Move type of source
            
            RTS
            
ADDADDRESSD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDADDRWD
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ADDADDRLD
            
            BRA     INVALIDOPCODE
            
ADDADDRWD   MOVE.W  (A0),D3     *Move addr
            MOVE.B  #$6, D6     *Store type
            ADDA.L  #$2, A0 
            
            RTS

ADDADDRLD   MOVE.L  (A0),D3     *Move addr
            MOVE.B  #$7, D6     *Store type
            ADDA.L  #$4, A0
            
            RTS
                
ADDEADN     MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDDATAREG
            
            CMP.L   #$8, D1     *Check if 001
            BEQ     ADDADDRREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     ADDINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     ADDPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     ADDMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     ADDADDRESSDATA
            
            BRA     INVALIDOPCODE
                
ADDDATAREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     ADDDNDEST
            
ADDADDRREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of An
            MOVE.B  #$1, D5     *Move type of source
            
            BRA     ADDDNDEST
            
ADDINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     ADDDNDEST
            
ADDPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     ADDDNDEST
            
ADDMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     ADDDNDEST
            
ADDADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ADDADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     ADDDATA
            
            BRA     INVALIDOPCODE
            
ADDADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     ADDDNDEST

ADDADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     ADDDNDEST
            
ADDDATA     CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     ADDSIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     ADDSIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     ADDSIZEL 

ADDSIZEB    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ADDDNDEST *Branches to destination

ADDSIZEW    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ADDDNDEST *Branches to destination

ADDSIZEL    MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     ADDDNDEST *Branches to destination
            
ADDDNDEST   MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$0, D6
            
            RTS
            *Check add size
            
            
            
            
ADDAEA      MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDADATAREG
            
            CMP.L   #$8, D1     *Check if 001
            BEQ     ADDAADDRREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     ADDAINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     ADDAPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     ADDAMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     ADDAADDRESSDATA
            
            BRA     INVALIDOPCODE
            
ADDADATAREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     ADDADEST 
            
ADDAADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of An
            MOVE.B  #$1, D5     *Move type of source
            
            BRA     ADDADEST 
            
ADDAINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     ADDADEST 
            
ADDAPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     ADDADEST 
            
ADDAMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     ADDADEST 
            
ADDAADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDAADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ADDAADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     ADDADATA
            
            BRA     INVALIDOPCODE
            
ADDAADDRW   MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     ADDADEST 

ADDAADDRL   MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     ADDADEST 
            
ADDADATA    CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     ADDASIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     ADDASIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     ADDASIZEL 

ADDASIZEB   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ADDADEST *Branches to destination

ADDASIZEW   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ADDADEST *Branches to destination

ADDASIZEL   MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     ADDADEST 

ADDADEST    MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3
            MOVE.B  #$1, D6
            
            RTS
            
            
ADDIEA      CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     ADDISIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     ADDISIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     ADDISIZEL 

ADDISIZEB   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ADDIDEST *Branches to destination

ADDISIZEW   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ADDIDEST *Branches to destination

ADDISIZEL   MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0
            
            BRA     ADDIDEST
            
ADDIDEST    MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDIDATAREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     ADDIINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     ADDIPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     ADDIMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     ADDIADDRESS
            
            BRA     INVALIDOPCODE
            
ADDIDATAREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            RTS
            
ADDIINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            RTS
            
ADDIPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            RTS
            
ADDIMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            RTS
            
ADDIADDRESS MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ADDIADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ADDIADDRL
            
            BRA     INVALIDOPCODE
            
ADDIADDRW   MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            RTS

ADDIADDRL   MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            RTS



            
            
SUBEA           MOVE.W  D0, D1
                AND.W   #$1C0, D1     *Isolate opmode
                
                CMP.W   #$100, D1     *Check if < 100
                BLT     SUBEADN
                
                BRA     SUBDNEA
                
SUBDNEA         MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D2      *Move register to d2
                MOVE.B  #$0, D5
                
                BRA     SUBEADEST
                
SUBEADEST       MOVE.L  D0, D1
                AND.L   #$38, D1    *Isolate mode
            
                CMP.L   #$10, D1    *Check if 010
                BEQ     SUBINADDRREGD
            
                CMP.L   #$18, D1    *Check if 011
                BEQ     SUBPLUSADDRREGD
            
                CMP.L   #$20, D1    *Check if 100
                BEQ     SUBMINUSADDRREGD
            
                CMP.L   #$38, D1     *Check if 111
                BEQ     SUBADDRESSD
                
                BRA     INVALIDOPCODE
                
            
SUBINADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$3, D6     *Move type of source
            
            RTS
            
SUBPLUSADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$4, D6     *Move type of source
            
            RTS
            
SUBMINUSADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$5, D6     *Move type of source
            
            RTS
            
SUBADDRESSD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     SUBADDRWD
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     SUBADDRLD
            
            BRA     INVALIDOPCODE
            
SUBADDRWD   MOVE.W  (A0),D3     *Move addr
            MOVE.B  #$6, D6     *Store type
            ADDA.L  #$2, A0 
            
            RTS

SUBADDRLD   MOVE.L  (A0),D3     *Move addr
            MOVE.B  #$7, D6     *Store type
            ADDA.L  #$4, A0
            
            RTS
                
SUBEADN     MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     SUBDATAREG
            
            CMP.L   #$8, D1     *Check if 001
            BEQ     SUBADDRREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     SUBINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     SUBPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     SUBMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     SUBADDRESSDATA
            
            BRA     INVALIDOPCODE
                
SUBDATAREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     SUBDNDEST
            
SUBADDRREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of An
            MOVE.B  #$1, D5     *Move type of source
            
            BRA     SUBDNDEST
            
SUBINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     SUBDNDEST
            
SUBPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     SUBDNDEST
            
SUBMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     SUBDNDEST
            
SUBADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     SUBADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     SUBADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     SUBDATA
            
            BRA     INVALIDOPCODE
            
SUBADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     SUBDNDEST

SUBADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     SUBDNDEST
            
SUBDATA     CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     SUBSIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     SUBSIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     SUBSIZEL 

SUBSIZEB    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     SUBDNDEST *Branches to destination

SUBSIZEW    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     SUBDNDEST *Branches to destination

SUBSIZEL    MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     SUBDNDEST *Branches to destination
            
SUBDNDEST   MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$0, D6
            
            RTS



MULSEA      MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     MULSDATAREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     MULSINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     MULSPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     MULSMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     MULSADDRESSDATA
            
            BRA     INVALIDOPCODE
                
MULSDATAREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     MULSDEST
            
MULSINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     MULSDEST 
           
MULSPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     MULSDEST 
            
MULSMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     MULSDEST 
            
MULSADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     MULSADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     MULSADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     MULSDATA
            
            BRA     INVALIDOPCODE
            
MULSADDRW   MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     MULSDEST

MULSADDRL   MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     MULSDEST
            
MULSDATA    CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     MULSSIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     MULSSIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     MULSSIZEL 

MULSSIZEB   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     MULSDEST *Branches to destination

MULSSIZEW   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     MULSDEST *Branches to destination

MULSSIZEL   MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     MULSDEST *Branches to destination
            
MULSDEST    MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$0, D6
            
            RTS




DIVUEA      MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     DIVUDATAREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     DIVUINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     DIVUPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     DIVUMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     DIVUADDRESSDATA
            
            BRA     INVALIDOPCODE
                
DIVUDATAREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     DIVUDEST
            
DIVUINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     DIVUDEST 
           
DIVUPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     DIVUDEST 
            
DIVUMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     DIVUDEST 
            
DIVUADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     DIVUADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     DIVUADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     DIVUDATA
            
            BRA     INVALIDOPCODE
            
DIVUADDRW   MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     DIVUDEST

DIVUADDRL   MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     DIVUDEST
            
DIVUDATA    CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     DIVUSIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     DIVUSIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     DIVUSIZEL 

DIVUSIZEB   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     DIVUDEST *Branches to destination

DIVUSIZEW   MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     DIVUDEST *Branches to destination

DIVUSIZEL   MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     DIVUDEST *Branches to destination
            
DIVUDEST    MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$0, D6
            
            RTS



LEAEA       MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     LEAINADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     LEAADDRESS
            
            BRA     INVALIDOPCODE
            
LEAINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     LEADEST 
            
LEAADDRESS  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     LEAADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     LEAADDRL
            
LEAADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     LEADEST 

LEAADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0
            
            BRA     LEADEST 
            
LEADEST     MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$1, D6
            
            RTS
            
            
            
CLREA       MOVE.L  #-1, D6
            MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     CLRDATAREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     CLRINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     CLRPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     CLRMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     CLRADDRESS            
            
            BRA     INVALIDOPCODE

CLRDATAREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            RTS
            
CLRINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            RTS
           
CLRPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            RTS
            
CLRMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            RTS
            
CLRADDRESS  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     DIVUADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     DIVUADDRL
            
            BRA     INVALIDOPCODE
            
CLRADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            RTS

CLRADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0
            
            RTS




ANDEA           MOVE.W  D0, D1
                AND.W   #$1C0, D1     *Isolate opmode
                
                CMP.W   #$100, D1     *Check if < 100
                BLT     ANDEADN
                
                BRA     ANDDNEA
                
ANDDNEA         MOVE.W  D0, D1
                AND.W   #$E00, D1   *Isolate register
                ASR.L   #8, D1
                ASR.L   #1, D1
                MOVE.W  D1, D2      *Move register to d2
                MOVE.B  #$0, D5
                
                BRA     ANDEADEST
                
ANDEADEST       MOVE.L  D0, D1
                AND.L   #$38, D1    *Isolate mode
            
                CMP.L   #$10, D1    *Check if 010
                BEQ     ANDINADDRREGD
            
                CMP.L   #$18, D1    *Check if 011
                BEQ     ANDPLUSADDRREGD
            
                CMP.L   #$20, D1    *Check if 100
                BEQ     ANDMINUSADDRREGD
            
                CMP.L   #$38, D1     *Check if 111
                BEQ     ANDADDRESSD
                
                BRA     INVALIDOPCODE
                
            
ANDINADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$3, D6     *Move type of source
            
            RTS
            
ANDPLUSADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$4, D6     *Move type of source
            
            RTS
            
ANDMINUSADDRREGD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D3      *Move value of an
            MOVE.B  #$5, D6     *Move type of source
            
            RTS
            
ANDADDRESSD MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ANDADDRWD
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ANDADDRLD
            
            BRA     INVALIDOPCODE
            
ANDADDRWD   MOVE.W  (A0),D3     *Move addr
            MOVE.B  #$6, D6     *Store type
            ADDA.L  #$2, A0 
            
            RTS

ANDADDRLD   MOVE.L  (A0),D3     *Move addr
            MOVE.B  #$7, D6     *Store type
            ADDA.L  #$4, A0
            
            RTS
                
ANDEADN     MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ANDDATAREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     ANDINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     ANDPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     ANDMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     ANDADDRESSDATA
            
            BRA     INVALIDOPCODE
                
ANDDATAREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     ANDDNDEST
            
ANDINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     ANDDNDEST
            
ANDPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     ANDDNDEST
            
ANDMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     ANDDNDEST
            
ANDADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ANDADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ANDADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     ANDDATA
            
            BRA     INVALIDOPCODE
            
ANDADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     ANDDNDEST

ANDADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     ANDDNDEST
            
ANDDATA     CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     ANDSIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     ANDSIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     ANDSIZEL 

ANDSIZEB    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ANDDNDEST *Branches to destination

ANDSIZEW    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     ANDDNDEST *Branches to destination

ANDSIZEL    MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     ANDDNDEST *Branches to destination
            
ANDDNDEST   MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$0, D6
            
            RTS



LSREA       MOVE.W  D0, D1
            AND.W   #$20, D1    *Isolate ir
            
            CMP.W   #$20, D1    *Check if 1
            BEQ     LSRD
            
            BRA     LSRC

LSRD        MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate count/register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D2
            MOVE.B  #$0, D5
            
            BRA     LSRDEST
            
LSRC        MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate count/register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D2
            MOVE.B  #$8, D5
            
            BRA     LSRDEST 
            
LSRDEST     MOVE.W  D0, D1
            AND.W   #$7, D1     *Isolate register
            MOVE.W  D1, D3
            MOVE.B  #$0, D6
            
            RTS
            
LSMEA       MOVE.L  #-1, D6
            MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     LSMINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     LSMPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     LSMMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     LSMADDRESS
            
            BRA     INVALIDOPCODE
            
LSMINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            RTS
            
LSMPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            RTS
            
LSMMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            RTS
            
LSMADDRESS  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     LSMADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     LSMADDRL
            
            BRA     INVALIDOPCODE
            
LSMADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            RTS

LSMADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0
            
            RTS
            
            
            
ASREA       MOVE.W  D0, D1
            AND.W   #$20, D1    *Isolate ir
            
            CMP.W   #$20, D1    *Check if 1
            BEQ     ASRD
            
            BRA     ASRC

ASRD        MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate count/register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D2
            MOVE.B  #$0, D5
            
            BRA     ASRDEST
            
ASRC        MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate count/register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D2
            MOVE.B  #$8, D5
            
            BRA     ASRDEST 
            
ASRDEST     MOVE.W  D0, D1
            AND.W   #$7, D1     *Isolate register
            MOVE.W  D1, D3
            MOVE.B  #$0, D6
            
            RTS
            
ASMEA       MOVE.L  #-1, D6
            MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     ASMINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     ASMPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     ASMMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     ASMADDRESS
            
            BRA     INVALIDOPCODE
            
ASMINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            RTS
            
ASMPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            RTS
            
ASMMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            RTS
            
ASMADDRESS  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     LSMADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     LSMADDRL
            
            BRA     INVALIDOPCODE
            
ASMADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            RTS

ASMADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0
            
            RTS




ROREA       MOVE.W  D0, D1
            AND.W   #$20, D1    *Isolate ir
            
            CMP.W   #$20, D1    *Check if 1
            BEQ     RORD
            
            BRA     RORC

RORD        MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate count/register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D2
            MOVE.B  #$0, D5
            
            BRA     RORDEST
            
RORC        MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate count/register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D2
            MOVE.B  #$8, D5
            
            BRA     RORDEST 
            
RORDEST     MOVE.W  D0, D1
            AND.W   #$7, D1     *Isolate register
            MOVE.W  D1, D3
            MOVE.B  #$0, D6
            
            RTS
            
ROMEA       MOVE.L  #-1, D6
            MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     ROMINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     ROMPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     ROMMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     ROMADDRESS
            
            BRA     INVALIDOPCODE
            
ROMINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            RTS
            
ROMPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            RTS
            
ROMMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            RTS
            
ROMADDRESS  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     ROMADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     ROMADDRL
            
            BRA     INVALIDOPCODE
            
ROMADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            RTS

ROMADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0
            
            RTS
            
            
            
            
CMPEA       MOVE.L  D0, D1
            AND.L   #$38, D1    *Isolate source mode
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     CMPDATAREG
            
            CMP.L   #$8, D1     *Check if 001
            BEQ     CMPADDRREG
            
            CMP.L   #$10, D1    *Check if 010
            BEQ     CMPINADDRREG
            
            CMP.L   #$18, D1    *Check if 011
            BEQ     CMPPLUSADDRREG
            
            CMP.L   #$20, D1    *Check if 100
            BEQ     CMPMINUSADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     CMPADDRESSDATA
            
            BRA     INVALIDOPCODE
                
CMPDATAREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of Dn
            MOVE.B  #$0, D5     *Move type of source
            
            BRA     CMPDNDEST
            
CMPADDRREG  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of An
            MOVE.B  #$1, D5     *Move type of source
            
            BRA     CMPDNDEST
            
CMPINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            BRA     CMPDNDEST
            
CMPPLUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$4, D5     *Move type of source
            
            BRA     CMPDNDEST
            
CMPMINUSADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$5, D5     *Move type of source
            
            BRA     CMPDNDEST
            
CMPADDRESSDATA MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     CMPADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     CMPADDRL
            
            CMP.L   #$4, D1     *Check if 100
            BEQ     CMPDATA
            
            BRA     INVALIDOPCODE
            
CMPADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            BRA     CMPDNDEST

CMPADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0 
            
            BRA     CMPDNDEST
            
CMPDATA     CMP.B   #$1,D7     *Compare if the size is a byte  
            BEQ     CMPSIZEB
    
            CMP.B   #$2,D7     *Compare if the size is a word 
            BEQ     CMPSIZEW
    
            CMP.B   #$3,D7     *Compare if the size is a long 
            BEQ     CMPSIZEL 

CMPSIZEB    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     CMPDNDEST *Branches to destination

CMPSIZEW    MOVE.W  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$2, A0 
        
            BRA     CMPDNDEST *Branches to destination

CMPSIZEL    MOVE.L  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$4, A0 
        
            BRA     CMPDNDEST *Branches to destination
            
CMPDNDEST   MOVE.W  D0, D1
            AND.W   #$E00, D1   *Isolate register
            ASR.L   #8, D1
            ASR.L   #1, D1
            MOVE.W  D1, D3      *Move register to d3
            MOVE.B  #$0, D6
            
            RTS
            
            
            
            
BCCEA       MOVE.L  #-1, D6
            MOVE.W  D0, D1
            AND.W   #$FF, D1    *Isolate first byte
            
            CMP.W   #$0, D1
            BEQ     BCCW
            
            CMP.W   #$FF, D1
            BEQ     BCCL
            
            AND.W   #$80, D1    *Isolate first bit
            CMP.W   #$80, D1
            BEQ     BCCBS       *If negative, need further manipulation
            
            MOVE.W  D0, D1
            AND.W   #$FF, D1
            SUB.B   #$2, D1     *Subtract 2
            MOVE.W  A6, D5      *Move address
            SUB.W   D1, D5      *Add from address
            MOVE.W  D5, D1
            MOVE.W  D1, D2
            MOVE.L  #$6, D5  
            
            RTS
            
BCCBS       MOVE.W  D0, D1
            AND.W   #$FF, D1
            SUB.B   #$1, D1     *Subtract 1
            NOT.B   D1          *Flip all bits
            SUB.B   #$2, D1     *Subtract 2
            MOVE.W  A6, D5      *Move address
            SUB.W   D1, D5      *Add from address
            MOVE.W  D5, D1
            MOVE.W  D1, D2
            MOVE.L  #$6, D5  
            
            RTS
            
BCCWS       SUB.W   #$1, D1     *Subtract 1
            NOT.W   D1          *Flip all bits
            SUB.W   #$2, D1     *Subtract 2
            MOVE.W  A6, D5      *Move address
            SUB.W   D1, D5      *Add from address
            MOVE.W  D5, D1
            MOVE.W  D1, D2
            MOVE.L  #$6, D5  
            
            RTS
            
BCCW        MOVE.W  (A0), D1
            ADDA.L  #$2, A0
            CMP.W   #0, D1
            BLT     BCCWS       *If negative, need further manipulation
            
            ADD.B   #$2, D1     *Subtract 2
            MOVE.W  A6, D5      *Move address
            ADD.W   D5, D1      *Add from address
            MOVE.W  D1, D2
            MOVE.L  #$6, D5 
            
            RTS
   
BCCL        MOVE.L  (A0), D2
            ADDA.L  #$4, A0
            CMP.L   #0, D1
            BLT     BCCLS       *If negative, need further manipulation
            
            MOVE.L  D1, D2
            ADD.L   #$2, D2
            MOVE.B  #$8, D5
            
            RTS
                 
BCCLS       SUB.L   #$1, D1     *Subtract 1
            NOT.L   D1          *Flip all bits
            ADD.L   #$2, D1     *Add 2
            MOVE.L  D1, D2
            MOVE.B  #$8, D5  
            
            RTS
            
            
JSREA       MOVE.L  D0, D1
            MOVE.B  #-1, D6
            AND.L   #$38, D1    *Isolate source mode

            CMP.L   #$10, D1    *Check if 010
            BEQ     JSRINADDRREG
            
            CMP.L   #$38, D1     *Check if 111
            BEQ     JSRADDRESS
            
            BRA     INVALIDOPCODE
            
JSRINADDRREG MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            MOVE.L  D1, D2      *Move value of an
            MOVE.B  #$3, D5     *Move type of source
            
            RTS
            
JSRADDRESS  MOVE.L  D0, D1
            AND.L   #$7, D1     *Isolate register
            
            CMP.L   #$0, D1     *Check if 000
            BEQ     JSRADDRW
            
            CMP.L   #$1, D1     *Check if 001
            BEQ     JSRADDRL
            
            BRA     INVALIDOPCODE
            
JSRADDRW    MOVE.W  (A0),D2     *Move addr
            MOVE.B  #$6, D5     *Store type
            ADDA.L  #$2, A0 
            
            RTS

JSRADDRL    MOVE.L  (A0),D2     *Move addr
            MOVE.B  #$7, D5     *Store type
            ADDA.L  #$4, A0
            
            RTS

                

EMPTYLINEMESSAGE DC.B   '', 0
NEWLINE         DC.B    $0D,$0A,0
DIVSMESSAGE     DC.B    'DIVU', 0
CMPMESSAGE      DC.B     'CMP', 0
BCCMESSAGE      DC.B     'BCC', 0
BGTMESSAGE      DC.B     'BGT', 0
BLEMESSAGE      DC.B     'BLE', 0
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

BYTEMESSAGE     DC.B    '.B', 0
WORDMESSAGE     DC.B    '.W', 0
LONGMESSAGE     DC.B    '.L', 0

INPUTMESSAGE    DC.B    'Welcome to JAN disassembler. Please type your addresses in this format:', $0D,$0A,0
INPUTMESSAGE1   DC.B    '"starting address","ending address". (period included)', 0

CONTINUEMESSAGE DC.B    'Section ended. Press ENTER to continue?', 0
ENDMESSAGE      DC.B    'All done!! Thank you for using JAN disassembler. Continue? (y/n)'

SPACEMESSAGE    DC.B    '           ', 0
COMMAMESSAGE    DC.B    ', ', 0
SLASHMESSAGE    DC.B    '/', 0

INVALIDMESSAGE  DC.B    'DATA', 0
DOLLARMESSAGE   DC.B    '$', 0
POUNDMESSAGE    DC.B    '#', 0

ZEROMESSAGE     DC.B    '0', 0
ONEMESSAGE      DC.B    '1', 0
TWOMESSAGE      DC.B    '2', 0
THREEMESSAGE    DC.B    '3', 0
FOURMESSAGE     DC.B    '4', 0
FIVEMESSAGE     DC.B    '5', 0
SIXMESSAGE      DC.B    '6', 0
SEVENMESSAGE    DC.B    '7', 0
EIGHTMESSAGE    DC.B    '8', 0
NINEMESSAGE     DC.B    '9', 0
AMESSAGE        DC.B    'A', 0
BMESSAGE        DC.B    'B', 0
CMESSAGE        DC.B    'C', 0
DMESSAGE        DC.B    'D', 0
EMESSAGE        DC.B    'E', 0
FMESSAGE        DC.B    'F', 0    

DNMESSAGE       DC.B    'D', 0
ANMESSAGE       DC.B    'A', 0 
ANIOPENMESSAGE  DC.B    '(A', 0
ANICLOSEMESSAGE DC.B    ')', 0
ANPLUSCLOSEMESSAGE DC.B ')+', 0
ANMINUSOPENMESSAGE DC.B '-(A', 0

    END    START        ; last line of source
   












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~20~






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
