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
    JSR         INPUT
    
LOOP    
    *Print the initial address
    JSR         PRINTADDRESS
    
    *Copy the opcode part to D0
    MOVE.W      (A0), D0
    
    *Copy the opcode to D1 for changes
    MOVE.W      (A0), D1
    
    *Increase the address by 2, since that part has been read
    ADDA.W       #$2, A0
    
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
    
    JSR     DECODEEA
    
    JSR         PRINTSIZES  *Print the sizes
    
    *JSR         PRINTSOURCE *Print source EA
    
    CMP.L       A4, A0      *Check if the starting address is same as ending
    BGE         OUTPUTEND   *If yes, then stop
    
    JSR         CLEARALL
    
    BRA         LOOP        *If not, then loop back            
    
    SIMHALT   
*------------------------------------main----------------------------------------
    

CLEARALL        CLR         D0
                CLR         D1
                CLR         D2
                CLR         D3
                CLR         D4
                CLR         D5
                CLR         D6
                CLR         D7
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
                
                RTS
                
PRINTBYTE       LEA         BYTEMESSAGE, A1
                MOVE.B      #13, D0
                TRAP        #15
                
                RTS
                *JSR         PRINTSPACE
                *JSR         EMPTYLINE
                
PRINTWORD       LEA         WORDMESSAGE, A1
                MOVE.B      #13, D0
                TRAP        #15
                
                RTS
                *JSR         PRINTSPACE
                *JSR         EMPTYLINE
                
PRINTLONG       LEA         LONGMESSAGE, A1
                MOVE.B      #13, D0
                TRAP        #15
                
                RTS
                *JSR         PRINTSPACE
                *JSR         EMPTYLINE
                
*-----------------------------------PRINTEAS-------------------------------------
*Description: This branch prints the EAs
*--------------------------------------------------------------------------------

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
                
XXXWEA          MOVE.B      #$4, D5             *Put actual size in D5
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
                
XXXLEA          MOVE.B      #$8, D5             *Put actual size in D5
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
                
DATAEA          ROL.L       #$4, D2             *Shift left to right position
                MOVE.L      D2, D0              *Move to D0 for backup
                AND.L       #$F, D2             *Isolate first byte
                MOVE.B      D2, D1              *Move byte to D1
                MOVE.L      D0, D2              *Move original back to D2
                AND.L       #$FFFFFFF0, D2      *Remove first 4 bits
                SUB.B       #$1, D7
                
                JSR         COMPAREADDRESS
                
                CMP.B       #$0, D7
                BNE         DATAEA
                
                RTS

*-----------------------------------Input----------------------------------------
*Description: This branch handles the input part of the disassmbler
*--------------------------------------------------------------------------------

INPUT           LEA         INPUTMESSAGE, A1    *Show the first line
                MOVE.B      #13, D0
                TRAP        #15      

INPUTLOOP       MOVE.B      #5, D0              *Wait for user input (character)
                TRAP        #15
                
CHECKIFCOMMA    CMP.B       #$2C, D1            *If not, check if it's a comma
                BEQ         COMMAINPUT          *If yes, it's a comma
                
CHECKIFPERIOD   CMP.B       #$2E, D1            *If not, check if it's a period
                BEQ         PERIODINPUT         *If yes, it's a period
        
CHECKMOREA      CMP.B       #$41, D1            *Check if letter better than A
                BGE         CHECKLESSF          *If yes, check if less than F
                
                BRA         CHECKMORE0          *If not, check if number
                
CHECKLESSF      CMP.B       #$46, D1            *Check if less than F
                BLE         LETTERINPUT         *If yes, then it's an acceptable letter input
        
CHECKMORE0      CMP.B       #$30, D1            *If not, then check if number better than 0
                BGE         CHECKIFLESS9        *If yes, check if less than 9
                
CHECKIFLESS9    CMP.B       #$39, D1            *Check if less than 9
                BLE         NUMBERINPUT         *If yes, then it's a number input
                
                BRA         INPUTLOOP           *If not, then it's an unacceptable characher
        
LETTERINPUT     SUB.B       #$37, D1            *Subtract 37 from D1 (since it's in ASCII)
                BRA         DOREST
        
NUMBERINPUT     SUB.B       #$30, D1            *Subtract 30 from D1 (since it's in ASCII)
                BRA         DOREST
                
COMMAINPUT      ADD.B       #$1, D4             *Add 1 to D4 to show that the ending address
                BRA         INPUTLOOP 
                
PERIODINPUT     MOVEA.L     D2, A0              *Move the starting address to A0
                MOVEA.L     D3, A4              *Move the ending address to A4
                BRA         EMPTYLINE
        
DOREST          CMP.B       #$0, D4             *Check if it's starting or ending
                BEQ         STARTINGADDRESS     *If yes, it's part of starting address
                
                BRA         ENDINGADDRESS       *If not, it's part of ending address
                
STARTINGADDRESS ASL.L       #$4, D2             *Shift to left
                ADD.L       D1, D2              *Add the number to D2
                ADD.L       #$1, D5             *Add count in D5
                ADDA.L      #$1, A5             *Add to A5 as well
        
                BRA         INPUTLOOP           *Go back to the input loop
                
ENDINGADDRESS   ASL.L       #$4, D3             *Shift to left
                ADD.L       D1, D3              *Add the number to D3
                ADD.L       #$1, D6             *Add count in D6
        
                BRA         INPUTLOOP           *Go back to the input loop
            
EMPTYLINE       LEA         EMPTYLINEMESSAGE, A1  *Empty line
                MOVE.B      #13, D0
                TRAP        #15
                
                RTS

*----------------------------------------------------------------------------------------------------
*                                           Subroutine: OUTPUTEND
*Description: Handles what happens when the dissassembler is done
*----------------------------------------------------------------------------------------------------

OUTPUTEND       SIMHALT

*----------------------------------------------------------------------------------------------------
*                                           Subroutine: PRINTADDRESS
*Description: Prints the current address the disassembler is on
*----------------------------------------------------------------------------------------------------

PRINTADDRESS    MOVE.L      A0, D2              *Move current address to D2
                MOVE.L      A5, D5              *Move address size
                ADD.B       #$1, D5             *Add 1 to size
                CMP.L       #$5, D5             *Check if the length is >4
                BGT         PRINTLONGADDRESS    *If yes, it's a long address

                CMP.L       #$3, D5             *Check if the length is >2
                BGT         PRINTWORDADDRESS    *If yes, it's a word address
                
                BRA         PRINTBYTEADDRESS    *If not, it's a byte address
                
PRINTLONGADDRESS    ROL.L   #$4, D2             *Shift by 4 bits
                    MOVE.L  D2, D7              *Move to D7 for backup
                    AND.L   #$F, D2             *Isolate first byte
                    MOVE.B  D2, D1              *Move byte to D1
                    MOVE.L  D7, D2              *Move original back to D2
                    AND.L   #$FFFFFFF0, D2      *Remove first 4 bits
                    SUB.B   #$1, D5             *Subtract 1 from length of address
                    
                    JSR     COMPAREADDRESS        *Print the address
                    
                    CMP.L   #$0, D5             *Check if the address length is 0
                    BNE     PRINTLONGADDRESS    *If not, then loop again
                    
                    BRA     PRINTSPACE          *If yes, then stop and print empty line
                    
PRINTWORDADDRESS    ROL.W   #$4, D2             *Shift by 4 bits
                    MOVE.L  D2, D7              *Move to D7 for backup
                    AND.L   #$F, D2             *Isolate first byte
                    MOVE.B  D2, D1              *Move byte to D1
                    MOVE.L  D7, D2              *Move original back to D2
                    AND.L   #$FFFFFFF0, D2      *Remove first 4 bits
                    SUB.B   #$1, D5             *Subtract 1 from length of address
                    
                    JSR     COMPAREADDRESS        *Print the address
                    
                    CMP.W   #$0, D5             *Check if the address length is 0
                    BNE     PRINTWORDADDRESS    *If not, then loop again
                    
                    BRA     PRINTSPACE          *If yes, then stop and print empty line
                    
PRINTBYTEADDRESS    ROL.L   #$4, D2             *Shift by 4 bits
                    MOVE.L  D2, D7              *Move to D7 for backup
                    AND.L   #$F, D2             *Isolate first byte
                    MOVE.B  D2, D1              *Move byte to D1
                    MOVE.L  D7, D2              *Move original back to D2
                    AND.L   #$FFFFFFF0, D2      *Remove first 4 bits
                    SUB.B   #$1, D5             *Subtract 1 from length of address
                    
                    JSR     COMPAREADDRESS        *Print the address
                    
                    CMP.B   #$0, D5             *Check if the address length is 0
                    BNE     PRINTBYTEADDRESS    *If not, then loop again
                    
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
                BEQ OPBCC
                RTS
                
OPBCC           LEA BCCMESSAGE, A1
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
              
                ******check for MOVEM*****
                MOVE.W D0,D1 *RESTORE OPCODE
                AND.W #$100,D1  *mask every bit but the 8th
                CMP.W #$100, D1 *check if bit 8 is 1 
                BEQ OPMOVEM
    
                MOVE.W D0,D1 *restore opcode
                AND.W #$200,D1 *check if th 9 is 1 and 8 is 1
                CMP.W #$200,D1
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
                MOVE.B  #$22, D4
                RTS
OPLEA  
                LEA LEAMESSAGE,A1
                MOVE.B  #$11, D4
                
                BRA     SIZEL           *It's always long
                
OPMOVEM         LEA OPMOVEMMESSAGE,A1
                MOVE.B  #$3, D4
*                
                MOVE.W  D0, D1
                AND.W   #$40, D1       *Isolate SIZE part
                CMP.W   #$0, D1         *If SIZE 0
                BEQ     SIZEW           *If yes, it's byte 
                
                CMP.W   #$40, D1       *If SIZE 1
                BEQ     SIZEL           *If yes, it's byte
                
                RTS
                
OPRTS           LEA RTSMESSAGE,A1
                MOVE.B  #$23, D4
                RTS
                
OPCLR           LEA CLRMESSAGE,A1
                MOVE.B  #$12, D4
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

EMPTYLINEMESSAGE DC.B   '', 0
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

BYTEMESSAGE     DC.B    '.B', 0
WORDMESSAGE     DC.B    '.W', 0
LONGMESSAGE     DC.B    '.L', 0

INPUTMESSAGE    DC.B    'Welcome to JAN disassembler. Please type your addresses in this format: "starting address", "ending address". (period included)', 0
INPUTMESSAGE2   DC.B    'Now please type your ending address in hex format. Write a . (period) when done.', 0

SPACEMESSAGE    DC.B    '           ', 0

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
ANMINUSOPENMESSAGE DC.B '-(', 0


*==========================================================
*                                                         *
*                            Decode EA                    *
*                                                         *
*==========================================================

DECODEEA
    CMP.B #$0, D4
    BEQ DECODENOP                       
    
    CMP.B #$1, D4
    BEQ DECODEMOVE      
    
    CMP.B #$2, D4
    BEQ DECODEMOVEQ                     

    CMP.B #$3, D4
    BEQ DECODEMOVEM                  
    
    CMP.B #$4, D4
    BEQ DECODEADD                                       
    
    CMP.B #$5, D4
    BEQ DECODEADDA                       
    
    CMP.B #$6, D4
    BEQ DECODEADDI     
    
    CMP.B #$7, D4
    BEQ DECODESUB       
    
    CMP.B #$8, D4
    BEQ DECODESUBA       
    
    CMP.B #$0, D4
    BEQ DECODEMULS                              
    
    CMP.B #$10, D4
    BEQ DECODEDIVS      
    
    CMP.B #$11, D4
    BEQ DECODELEA           
    
    CMP.B #$12, D4
    BEQ DECODECLR       
    
    CMP.B #$13, D4
    BEQ DECODEAND      
    
    CMP.B #$14, D4
    BEQ DECODEANDI      
    
    CMP.B #$15, D4
    BEQ DECODELSLREG    
    
    CMP.B #$16, D4
    BEQ DECODEASRREG   
    
    CMP.B #$17, D4
    BEQ DECODEROLREG  

    CMP.B #$19, D4
    BEQ DECODECMP    
      
    CMP.B #$20, D4
    BEQ DECODECMPI      
    
    CMP.B #$21, D4
    BEQ DECODEBCC       
    
    CMP.B #$22, D4
    BEQ DECODEJSR      
    
    CMP.B #$23, D4
    BEQ DECODERTS                                              
    
    CMP.B #$25, D4
    BEQ DECODELSLMEMORY     
    
    CMP.B #$26, D4
    BEQ DECODEASXMEMORY    
   
    CMP.B #$27, D4
    BRA DECODEROXMEMORY                  







































*-----------NOP--------------------------------
*Description: Decode NOP Checks for other various information about the opcode 
DECODENOP       
                

*-----------MOVE--------------------------------
*Description: Decode MOVE Checks for other various information about the opcode 
DECODEMOVE      
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     MOVESIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     MOVESIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     MOVESIZEL 

*-----------MOVEQ--------------------------------
*Description: Decode MOVE Checks for other various information about the opcode 
DECODEMOVEQ     BEQ     MOVEQSIZEL
                
*-----------MOVEM--------------------------------
*Description: Decode MOVEM Checks for other various information about the opcode 
DECODEMOVEM     MOVE #$3,D4 
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     MOVEMSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     MOVEMSIZEL 
             
*-----------ADD--------------------------------
*Description: Decode ADD Checks for other various information about the opcode 
DECODEADD       
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     ADDSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     ADDSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     ADDSIZEL 
                
*-----------ADDA--------------------------------
*Description: Decode ADDA Checks for other various information about the opcode 
DECODEADDA      
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     ADDASIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     ADDASIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     ADDASIZEL 

*-----------ADDI--------------------------------
*Description: Decode ADDI Checks for other various information about the opcode 

DECODEADDI     
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     ADDISIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     ADDISIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     ADDISIZEL
                

*-----------SUB--------------------------------
*Description: Decode SUB Checks for other various information about the opcode 
DECODESUB       
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     SUBSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     SUBSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     SUBSIZEL

*-----------SUBA--------------------------------
*Description: Decode SUBA Checks for other various information about the opcode 
DECODESUBA      
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     SUBASIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     SUBASIZEL

*-----------MULS--------------------------------
*Description: Decode MULS Checks for other various information about the opcode 
DECODEMULS      
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     SIXBITSRCONLYSIZEW          
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     SIXBITSRCONLYSIZEL          

*-----------DIVS--------------------------------
*Description: Decode DIVS Checks for other various information about the opcode 
DECODEDIVS      
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     SIXBITSRCONLYSIZEW          
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     SIXBITSRCONLYSIZEL   

*-----------LEA--------------------------------
*Description: Decode LEA Checks for other various information about the opcode 
DECODELEA       
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     LEASIZEL          

*-----------CLR--------------------------------
*Description: Decode CLR Checks for other various information about the opcode 
DECODECLR       

                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     CLRSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     CLRSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     CLRSIZEL

*-----------AND--------------------------------
*Description: Decode AND Checks for other various information about the opcode 
DECODEAND       
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     ANDSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     ANDSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     ANDSIZEL

*-----------ANDI--------------------------------
*Description: Decode AND Checks for other various information about the opcode 
DECODEANDI      
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     EIGHTBITDESTONLYSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     EIGHTBITDESTONLYSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     EIGHTBITDESTONLYSIZEL

*-----------LSL Register--------------------------------
*Description: Decode LSx Register Checks for other various information about the opcode 
DECODELSLREG    
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     LSLREGSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     LSLREGSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     LSLREGSIZEL
*-----------ASR Regiser--------------------------------
*Description: Decode ASR Register Checks for other various information about the opcode 
DECODEASRREG    CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     ASRREGSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     ASRREGSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     ASRREGSIZEL

*-----------ROL Regiser--------------------------------
*Description: Decode ROL Register Checks for other various information about the opcode 
DECODEROLREG    CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     ROLREGSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     ROLREGSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     ROLREGSIZEL

*-----------CMP --------------------------------
*Description: Decode CMP Checks for other various information about the opcode 
DECODECMP       CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     EIGHTBITDESTONLYSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     EIGHTBITDESTONLYSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     EIGHTBITDESTONLYSIZEL

*-----------CMPI--------------------------------
*Description: Decode CMPI Checks for other various information about the opcode 
DECODECMPI      
                CMP.B   #$0,D7     *Compare if the size is a byte  
                BEQ     EIGHTBITDESTONLYSIZEB
    
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     EIGHTBITDESTONLYSIZEW
    
                CMP.B   #$2,D7     *Compare if the size is a long 
                BEQ     EIGHTBITDESTONLYSIZEL


*-----------BCC--------------------------------
*Description: Decode BCC Checks for other various information about the opcode 
DECODEBCC       
                

*-----------JSR--------------------------------
*Description: Decode JSR Checks for other various information about the opcode 
DECODEJSR      
                BRA JSR

*-----------RTS--------------------------------
*Description: Decode RTS Checks for other various information about the opcode 
DECODERTS       
                
                                        
*-----------LSL Memory--------------------------------
*Description: Decode LSL MEMORY Checks for other various information about the opcode 
DECODELSLMEMORY       
                CMP.B   #$1,D7     *Compare if the size is a word 
                BEQ     LSLMEMSIZEW

*-----------ASx Memory--------------------------------
*Description: Decode ASx MEMORY Checks for other various information about the opcode 
DECODEASXMEMORY    

*-----------ROx Memory--------------------------------
*Description: Decode ROx MEMORY Checks for other various information about the opcode 
DECODEROXMEMORY                  
              
 
*---------Determine Size-------------- 

TWELVEBITSRCONLYSIZEB       MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     TWELVEBITSRCONLY *Branches to destination

TWELVEBITSRCONLYSIZEW       MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     TWELVEBITSRCONLY *Branches to destination

TWELVEBITSRCONLYSIZEL       MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     SIXBITSRCONLY *Branches to destination
                            
EIGHTBITDESTONLYSIZEB       MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     EIGHTBITDESTONLY *Branches to destination
                            
EIGHTBITDESTONLYSIZEW       MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$4, A0 
        
                            BRA     EIGHTBITDESTONLY *Branches to destination

EIGHTBITDESTONLYSIZEL       MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$8, A0 
                            
                            BRA     EIGHTBITDESTONLY *Branches to destination
                            
SIXBITSRCONLYSIZEB          MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     SIXBITSRCONLY *Branches to destination
                            
SIXBITSRCONLYSIZEW          MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     SIXBITSRCONLY *Branches to destination

SIXBITSRCONLYSIZEL          MOVE.B  (A0),D2 
                            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                            ADDA.W  #$2, A0 
        
                            BRA     SIXBITSRCONLY *Branches to destination

MOVESIZEB   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$2, A0 
        
            BRA     MOVEDEST    *Branches to destination

MOVESIZEW   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     MOVEDEST    *Branches to destination

MOVESIZEL   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
        
            BRA     MOVEDEST    *Branches to destination

MOVEQSIZEL  MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
        
            BRA     MOVEDEST    *Branches to destination
        
MOVEMSIZEW  MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     MOVEMDEST    *Branches to destination

MOVEMSIZEL  MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 , BUT WHAT IF SOURCE CAN BE EA TOO!
            ADDA.W  #$8, A0 
        
            BRA     MOVEMDEST    *Branches to destination

ADDSIZEB    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
        
            BRA     ADDDEST    *Branches to destination
        
ADDSIZEW    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     ADDDEST    *Branches to destination

ADDSIZEL    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 , BUT WHAT IF SOURCE CAN BE EA TOO!
            ADDA.W  #$8, A0 
        
            BRA     ADDDEST    *Branches to destination


ADDASIZEB   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
        
            BRA     ADDASRC

ADDASIZEW   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     ADDASRC

ADDASIZEL   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 , BUT WHAT IF SOURCE CAN BE EA TOO!
            ADDA.W  #$8, A0 
        
            BRA     ADDASRC
*---------If the size is a byte , then go to this branch---
ADDISIZEB   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$2, A0 
        
            BRA     ADDIDEST    *Branches to destination 
        
ADDISIZEW   MOVE.W  (A0),D2 
            MOVE.W  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 *
        
            BRA     ADDIDEST    *Branches to destination 

ADDISIZEL   MOVE.L  (A0),D2 
            MOVE.L  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.L  #$8, A0 *
        
            BRA     ADDIDEST    *Branches to destination 
            
SUBSIZEB    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
        
            BRA     ADDASRC

SUBSIZEW    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     ADDASRC

SUBSIZEL    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 , BUT WHAT IF SOURCE CAN BE EA TOO!
            ADDA.W  #$8, A0 
        
            BRA     ADDASRC

SUBASIZEW   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     TWELVEBITSRCONLY

SUBASIZEL   MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 , BUT WHAT IF SOURCE CAN BE EA TOO!
            ADDA.W  #$8, A0 
        
            BRA     TWELVEBITSRCONLY
            
LEASIZEL    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 , BUT WHAT IF SOURCE CAN BE EA TOO!
            ADDA.W  #$8, A0 
        
            BRA     LEASRC     

CLRSIZEB    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$2, A0 
        
            BRA     CLR

CLRSIZEW    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            BRA     CLR
            
CLRSIZEL    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
        
            BRA     CLR
            
ANDSIZEB    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$2, A0 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$0, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$40, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$80, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$100, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$140, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$180, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
  
ASRREGSIZEB   

ASRREGSIZEW           

ASRREGSIZEL                   

ANDSIZEW    MOVE.B  (A0),D2 
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$4, A0 
        
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$0, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$40, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$80, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$100, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$140, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$180, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST

ANDSIZEL    MOVE.B  (A0),D2  
            MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
            ADDA.W  #$8, A0 
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$0, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$40, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$80, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDSRC
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$100, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$140, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
            AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 000111000000
            CMP.W   #$180, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     ANDDEST
            
LSLREGSIZEB     MOVE.B  (A0),D2  
                MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                ADDA.W  #$8, A0   
                
                BRA LSLREG
                
LSLREGSIZEW     MOVE.B  (A0),D2  
                MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                ADDA.W  #$8, A0   
                
                BRA LSLREG
               
LSLREGSIZEL     MOVE.B  (A0),D2  
                MOVE.B  #$8, D5 *Stores the type of source as Data into D5 
                ADDA.W  #$8, A0   
                
                BRA LSLREG
            
LSLMEMSIZEW
            
            
ROLREGSIZEB

ROLREGSIZEW

ROLREGSIZEL

MOVEDEST    AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 00000111000000
            CMP.W   #$0, D1   *Checks to see if the size is Dn(Data Register) 
            BEQ     MOVEDATAREG  *Goes to Dn Process 
        
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$1C0, D1 
            CMP.W   #$80, D1   *Checks (An)
            BEQ     MOVEINDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$C0, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     MOVEPOSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$1C0, D1
            CMP.W   #$100, D1 *Checks -(An)
            BEQ     MOVEPREADDR
        
            MOVE.W  D0, D1
            AND.W   #$1C0, D1
            CMP.W   #$1C0, D1 *Checks Addressing Mode
            BEQ     MOVEADDRESSVALUE
            
            BRA     ERRORDEST       *Gives error if it's none of the them
            
MOVESRC     AND.W   #$1C0, D1 *Moves hex value to D1 for Comparison 00000111000000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     MOVEDATAREGSRC  *Goes to Dn Process 
        
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$1C0, D1 
            CMP.W   #$40, D1   *Checks An
            BEQ     MOVEDIRECTADDRSRC
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$1C0, D1 
            CMP.W   #$80, D1   *Checks (An)
            BEQ     MOVEINDIRECTADDRSRC
        
            MOVE.W  D0, D1
            AND.W   #$C0, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     MOVEPOSTADDRSRC
        
            MOVE.W  D0, D1
            AND.W   #$1C0, D1
            CMP.W   #$100, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$1C0, D1
            CMP.W   #$1C0, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUE  
            
ANDSRC      AND.W   #$38, D1 *Moves hex value to D1 for Comparison 00000111000000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$80, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUEWITHDATA 
            
ANDDEST     AND.W   #$38, D1 
            CMP.W   #$80, D1        *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1        *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1       *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1       *Checks Addressing Mode
            BEQ     ADDRESSVALUEWITHDATA
            
            

ADDDEST     AND.W   #$38, D1 *Moves hex value to D1 for Comparison 000000111000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
        
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$8, D1   *Checks An
            BEQ     DIRECTADDR
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUEWITHDATA 

ADDASRC     AND.W   #$38, D1 *Moves hex value to D1 for Comparison 000000111000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
        
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$8, D1   *Checks An
            BEQ     DIRECTADDR
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUEWITHDATA  

TWELVEBITSRCONLY *000000 111 000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
        
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$8, D1   *Checks An
            BEQ     DIRECTADDR
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUEWITHDATA  
            
EIGHTBITDESTONLY *00 111 000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUE

SIXBITSRCONLY *111 000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUEWITHDATA  
            
JSR    
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUE  
            RTS       
             
LEASRC      MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUE
            

CLR         CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
            
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 
            CMP.W   #$10, D1   *Checks (An)
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1 *Checks (An)+
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1 *Checks -(An)
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1 *Checks Addressing Mode
            BEQ     ADDRESSVALUE

ADDIDEST    AND.W   #$38, D1 *Moves hex value to D1 for Comparison 00111000
            CMP.W   #$0, D1  *Checks to see if the size is Dn(Data Register) 
            BEQ     DATAREG  *Goes to Dn Process 
        
            MOVE.W  D0, D1   *Store temp of D1 into D0 
            AND.W   #$38, D1 *Checks to see if the size is (An)
            CMP.W   #$10, D1    
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$18, D1
            BEQ     POSTADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$20, D1
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1
            BEQ     ADDRESSVALUE
        
            BRA     ERRORDEST       *Gives error if it's none of the them
        
MOVEMDEST   MOVE.W  D0, D1   *Store temp of D1 into D0 0010000          
            AND.W   #$38, D1 *Checks to see if the size is (An)
            CMP.W   #$10, D1    
            BEQ     INDIRECTADDR
        
            MOVE.W  D0, D1  
            AND.W   #$38, D1
            CMP.W   #$20, D1
            BEQ     PREADDR
        
            MOVE.W  D0, D1
            AND.W   #$38, D1
            CMP.W   #$38, D1
            BEQ     ADDRESSVALUE
        
            BRA     ERRORDEST       *Gives error if it's none of the them   
            
LSLREG          AND.W   #$20,D1       *000 dr 00 1 00000
                CMP.W   #$0,D1
                BEQ     DATADN
               
                MOVE.W  D0, D1
                AND.W   #$20,D1 
                CMP.W   #$20,D1 
                BEQ     DNDN
        
MOVEDATAREG     MOVE.W  D0, D1      *Moves value to D1 just incase. 
                AND.W   #$7,D1      *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$0, D6
                RTS          
DATADN          

DNDN      
            
MOVEINDIRECTADDR    MOVE.W D0,D1 
                    AND.W   #$7,D1  *Isolates the MODE 
                    MOVE.W  D1, D3
                    MOVE.B  #$3, D6
                    RTS                

MOVEPOSTADDR    MOVE.W D0,D1 
                AND.W   #$7,D1  *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$4, D6
                RTS
                
MOVEPREADDR     MOVE.W D0,D1 
                AND.W   #$7,D1  *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$5, D6
                RTS
        
MOVEADDRESSVALUE    MOVE.W  D0, D1
                    AND.W   #$7, D1
                
                    CMP.W   #$0, D1
                    BEQ     MOVEADDRW
                
                    CMP.W   #$1, D1
                    BEQ     MOVEADDRL
                
                    BRA     ERRORADDRESS
                    
MOVEDATAREGSRC  MOVE.W  D0, D1      *Moves value to D1 just incase. 
                AND.W   #$7,D1      *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$0, D6
                RTS
                
MOVEDIRECTADDRSRC      MOVE.W D0,D1 
                       AND.W   #$7,D1  *Isolates the MODE 
                       MOVE.W  D1, D3
                       MOVE.B  #$1, D6
                        RTS
      
                    
MOVEINDIRECTADDRSRC    MOVE.W D0,D1 
                       AND.W   #$7,D1  *Isolates the MODE 
                       MOVE.W  D1, D3
                       MOVE.B  #$3, D6
                    RTS
                

MOVEPOSTADDRSRC     MOVE.W D0,D1 
                    AND.W   #$7,D1  *Isolates the MODE 
                    MOVE.W  D1, D3
                    MOVE.B  #$4, D6
                RTS
                
MOVEPREADDRSRC     MOVE.W D0,D1 
                   AND.W   #$7,D1  *Isolates the MODE 
                   MOVE.W  D1, D3
                   MOVE.B  #$5, D6
               RTS
        
MOVEADDRESSVALUESRC MOVE.W  D0, D1
                    AND.W   #$7, D1
                
                    CMP.W   #$0, D1
                    BEQ     MOVEADDRWSRC
                
                    CMP.W   #$1, D1
                    BEQ     MOVEADDRLSRC
                
                    BRA     ERRORADDRESS
                    
                
DATAREG         MOVE.W  D0, D1      *Moves value to D1 just incase. 
                AND.W   #$7,D1      *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$0, D6
                RTS     LOOP    *goes back to loop 
            
DIRECTADDR      MOVE.W D0,D1 
                AND.W   #$7,D1  *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$1, D6
                RTS





INDIRECTADDR    MOVE.W D0,D1 
                AND.W   #$7,D1  *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$3, D6
                RTS

POSTADDR        MOVE.W D0,D1 
                AND.W   #$7,D1  *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$4, D6
                RTS
PREADDR         MOVE.W D0,D1 
                AND.W   #$7,D1  *Isolates the MODE 
                MOVE.W  D1, D3
                MOVE.B  #$5, D6
                RTS
ADDRESSVALUE    MOVE.W  D0, D1
                AND.W   #$7, D1
                
                CMP.W   #$0, D1
                BEQ     ADDRW
                
                CMP.W   #$1, D1
                BEQ     ADDRL
                
                BRA     ERRORADDRESS
         
ADDRESSVALUEWITHDATA
                MOVE.W  D0, D1
                AND.W   #$7, D1
                
                CMP.W   #$0, D1
                BEQ     ADDRW
                
                CMP.W   #$1, D1
                BEQ     ADDRL
                
                CMP.W   #$8, D1
                BEQ     ADDRD
                
                BRA     ERRORADDRESS

ADDRW           MOVE.W  (A0),D3
                MOVE.B  #$6, D6
                ADDA.W  #$4, A0
                RTS




                
ADDRL           MOVE.W  (A0),D3
                MOVE.B  #$7, D6
                ADDA.W  #$8, A0
                RTS
                
ADDRD           MOVE.W  (A0),D3
                MOVE.B  #$8, D6
                ADDA.W  #$8, A0
                 RTS
                
MOVEADDRW       MOVE.W  (A0),D3
                MOVE.B  #$6, D6
                ADDA.W  #$4, A0
                BRA MOVESRC
                
MOVEADDRL       MOVE.W  (A0),D3
                MOVE.B  #$7, D6
                ADDA.W  #$8, A0
                BRA MOVESRC
                
MOVEADDRWSRC    MOVE.W  (A0),D3
                MOVE.B  #$6, D6
                ADDA.W  #$4, A0
                RTS
                
MOVEADDRLSRC    MOVE.W  (A0),D3
                MOVE.B  #$7, D6
                ADDA.W  #$8, A0
                RTS
                

                
ERRORDEST
                *This will be responsible for printing out the error of the destination

ERRORADDRESS
                *This will be responsible for printing out the error

    SIMHALT             ; halt simulator

* Put variables and constants here
INVALIDERRORMESSAGE     DC.B 'Not valid', 0


    END    START        ; last line of source
   







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
