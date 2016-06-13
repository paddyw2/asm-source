;---------------------------;
; Assignment 3              ;
; Problem 1                 ;
; Author: Patrick Withams   ;
; Date: 9/6/2015            ;
;---------------------------;

include irvine32.inc

.data
    ;-----------------------------------------------
    ; initialBal stores the users pre deposits/
    ; withdrawal balance
    ; deposits stores a list of user deposits
    ; withdrawals stores a list of user withdrawals
    ; finalBal stores the users updated balance
    ;
    msgTitle            BYTE        "Welcome to Balance Checker!", 0
    origBalTitle        BYTE        "Your original balance: ", 0
    depTitle            BYTE        "Deposits: ", 0
    withTitle           BYTE        "Withdrawals: ", 0
    balanceTitle        BYTE        "Your new balance is: ", 0
    initialBal          WORD        1000
    deposits            WORD        20, 20, 10, 5
    withdrawals         WORD        20, 10, 20
    finalBal            WORD        0

.code
main proc
    ;------------------------
    ; print welcome message
    ;
    mov EDX, OFFSET msgTitle                                ; move msgTitle address to EDX
    call WriteString                                        ; print message to screen
    call Crlf                                               ; print new line
    ;-------------------------
    ; print original balance
    ;
    mov EDX, OFFSET origBalTitle                            ; move origBalTitle address to EDX
    call WriteString                                        ; print message to screen
    movzx EAX, initialBal                                   ; set EAX to initialBal value
    call WriteDec                                           ; write EAX value to screen in decimal format
    call Crlf
    ;-----------------
    ; print deposits
    ;
DepositTitle:   
    mov EDX, OFFSET depTitle 
    call WriteString
    mov ECX, LENGTHOF deposits                              ; set ECX (loop counter) to array length
    mov ESI, OFFSET deposits                                ; set ESI to first address of array
PrintDepositsLoop:
    mov AX, [ESI]                                           ; each loop, move array element into AX register
    call WriteDec                                           ; write EAX register to screen in decimal
    cmp ECX, 1                                              ; if last loop, skip printing commas    
    je WithdrawalsTitle
    cmp AX, 0                                               ; if array value is zero, end of deposits so jump to GetWithdrawals
    je WithdrawalsTitle
    mov AL, ','                                             ; move comma char to AL register
    call WriteChar                                          ; print to screen
    mov AL, ' '                                             ; move space char to AL register
    call WriteChar                                          ; print to screen
    add ESI, TYPE deposits                                  ; increment ESI address to next element 
    loop PrintDepositsLoop  
    ;----------------------
    ; print withdrawals
    ;
WithdrawalsTitle:
    call Crlf
    mov EDX, OFFSET withTitle                               ; move withTitle message to EDX
    call WriteString                                        ; write message to screen
    mov ECX, LENGTHOF withdrawals                           ; set ECX (loop counter) value to withdrawals length
    mov ESI, OFFSET withdrawals                             ; set ESI to first address of withdrawals array
PrintWithdrawalsLoop:
    mov AX, [ESI]                                           ; each loop, move element value into AX
    call WriteDec                                           ; write value to screen
    cmp ECX, 1                                              ; if loop counter is 1, jump to AddDeposits
    je AddDeposits
    mov AL, ','                                             ; move comma char to AL register
    call WriteChar                                          ; write char to screen
    mov AL, ' '                                             ; move space char to AL register
    call WriteChar                                          ; write char to screen
    add ESI, TYPE withdrawals                               ; increment ESI address
    loop PrintWithdrawalsLoop
    ;--------------------------
    ; all deposits to initial
    ; balance value
    ;
AddDeposits:
    movzx EAX, initialBal                                   ; move initialBal into EAX
    mov ECX, LENGTHOF deposits                              ; set ECX (loop counter) to length of array
    mov ESI, OFFSET deposits                                ; set ESI to first address of deposits
AddDepositsLoop:
    add AX, [ESI]                                           ; each loop, add deposit value to account balance
    add ESI, TYPE WORD                                      ; increment ESI to next element
    loop AddDepositsLoop
    ;--------------------------
    ; subtract withdrawals from
    ; updated balance value
    ;
AddWithdrawals:
    mov ECX, LENGTHOF withdrawals                           ; set ECX (loop counter) to length of array
    mov ESI, OFFSET withdrawals                             ; set ESI to first address of withdrawals
AddWithdrawalsLoop:
    sub AX, [ESI]                                           ; each loop, subtract withdrawal value from account balance
    add ESI, TYPE WORD                                      ; increment ESI to next element
    loop AddWithdrawalsLoop
    ;-----------------------
    ; update final balance
    ; variable and print
    ; details to screen
    ;
    mov finalBal, AX                                        ; update finalBal value
    call Crlf
    mov EDX, OFFSET balanceTitle                            ; move balanceTitle message to EDX
    call WriteString                                        ; write message to screen
    call WriteDec                                           ; write final balance to screen
    call Crlf
    ;---------------------------------------------
    ; wait for user input before exiting program
    ;
    call WaitMsg
    exit
main endp
end main
