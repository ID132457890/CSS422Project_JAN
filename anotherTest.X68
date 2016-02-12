*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $100
START:                  ; first instruction of program

    *Ask for input
    MOVE.B      #4, D0
    TRAP        #15
    
    *Move written in D1 to D2
    MOVE.L      D1, D2

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
