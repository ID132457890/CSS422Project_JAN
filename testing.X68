*-----------------------------------------------------------
* Title      : Testing file
* Written by : JAN
* Date       : 02/11/2016
* Description: Testing file for disassembler
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

    MOVE.B      #$32, $1000
 
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
