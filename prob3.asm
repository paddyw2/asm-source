;---------------------------;
; Assignment 3              ;
; Problem 3                 ;
; Author: Patrick Withams   ;
; Date: 9/6/2015            ;
;---------------------------;

include irvine32.inc

.data
    ;-----------------------------------------------------
    ; the constant COUNT defines how many iterations of
    ; the sequence are needed
    ; fibArray stores the sequence, the length must
    ; match COUNT
    ; startVal is used for the 0, 1 positions of the
    ; sequence, before the loop takes place 
    ; titleMsg and fibMsg are used to print info to
    ; screen
    ;
    COUNT = 7               ; max value is 24 due to 16bit WORD capacity
    fibArray    WORD        COUNT DUP(?)
    startVal    WORD        1   
    titleMsg    BYTE        "Welcome to the Fibonacci Sequence generator!", 0
    fibMsg      BYTE        "Fibonacci Sequence:", 0

.code
main proc
    ;------------------------
    ; print welcome message
    ;
    mov EDX, OFFSET titleMsg                                    ; move titleMsg address to EDX
    call WriteString                                            ; print "Welcome to the..." message to screen
    call Crlf                                                   ; print new line to screen
    ;----------------------------------
    ; print start of sequence message
    ;
    mov EDX, OFFSET fibMsg                                      ; move fibMsg address to EDX
    call WriteString                                            ; print "Fibonacci Sequence:" message to screen
    call Crlf                                                   ; print new line to screen
    ;------------------------------------
    ; move fibArray address to ESI, and
    ; push the first of two values of the
    ; sequence to the stack, and update
    ; the fibArray variable
    ;
    mov ESI, OFFSET fibArray                                    ; move fibArray address to ESI
    mov EAX, 0                                                  ; set EAX to 0 to clear garbage value
    mov AX, startVal                                            ; move startVal (1) into 16bit register
    mov [ESI], EAX                                              ; set first element of fibArray to 1
    add ESI, TYPE fibArray                                      ; move address to next array element
    mov [ESI], AX                                               ; set second element of fibArray to 1
    mov ECX, 0                                                  ; set ECX to 0 to clear garbage value
    mov CX, COUNT                                               ; set ECX (loop counter) to COUNT value
    sub ECX, 2                                                  ; subtract 2 from counter value to account for first two elements
    add ESI, TYPE fibArray                                      ; move address to next array element
    push EAX                                                    ; push the two starting values to the stack
    push EAX                                                    ; push value the second time
    ;-------------------------------
    ; start loop to calculate main
    ; sequence and update fibArray
    ;
FibLoop:
    pop EAX                                                     ; pop n-1 value into EAX
    pop EBX                                                     ; pop n-2 value into EBX
    push EAX                                                    ; push n-1 value back onto stack, to become n-2 for next loop
    add EAX, EBX                                                ; sum n-1 and n-2 to get n in EAX
    mov [ESI], AX                                               ; move n into fibArray current element position
    add ESI, TYPE fibArray                                      ; increment fibArray address
    push EAX                                                    ; push n value onto stack, to become n-1 for next loop
    loop FibLoop                                                ; decrement ECX and loop again if != 0
    ;-----------------------------------
    ; move fibArray address to ESI and
    ; set ECX to array length
    ;
    mov ESI, OFFSET fibArray                                    ; move first address of fibArray into ESI
    mov ECX, LENGTHOF fibArray                                  ; set ECX (loop counter) value to length of fibArray
    ;-----------------------------------
    ; loop over fibArray and print each
    ; array element
    ;
PrintLoop:
    mov AX, [ESI]                                               ; move current fibArray element value into AX
    call WriteDec                                               ; write value to screen
    call Crlf                                                   ; print new line
    add ESI, TYPE fibArray                                      ; increment fibArray address    
    loop PrintLoop                                              ; decrement ECX and loop again if != 0
    ;---------------------------------------------
    ; wait for user input before exiting program
    ;
    call WaitMsg                                                ; print wait message and wait for user input
    exit
main endp
end main
