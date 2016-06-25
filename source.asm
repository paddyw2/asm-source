;---------------------------;
; Assignment 4              ; 
; Author: Patrick Withams   ;
; Date: 20/6/2015           ;
;---------------------------;

include irvine32.inc

.data 
    accountNumbers      DWORD   10021331, 12322244, 44499922, 10222334              ; an array for account numbers stored in system 
    PINS                WORD    2341, 3345, 1923, 3456                              ; an array for PINS corresponding to each account 
    Balances            DWORD   1000, 0, 80000, 4521                                ; an array for balances corresponding to each account
    maxWithdrawalVal    DWORD   1000                                                ; maximum withdrawal amount
    maxWithdrawalMsg    BYTE    "Max withdrawal is $1000 - withdrawal cancelled",0  ; max withdrawal message
    welcomeMsg          BYTE    "#############################", 0dh,0ah            ; atm welcome message
                        BYTE    "# Welcome to your local ATM #", 0dh,0ah 
                        BYTE    "#############################", 0
    pinPrompt           BYTE    "Enter your pin: ", 0                               ; pin prompt
    accountPrompt       BYTE    "Enter your account number: ", 0                    ; account number prompt 
    sessionId           BYTE    ?                                                   ; session id - corresponds to index position of account number etc.
    validDetails        BYTE    0                                                   ; 0 if details are invalid, 1 if details are valid
    invalidAccountMsg   BYTE    "That account does not exist", 0                    ; invalid accoutn no message
    exitMsg             BYTE    "Thank you for using this ATM", 0                   ; message shown on program exit
    menuMsg             BYTE        "############# ATM MENU #############", 0dh,0ah ; menu display message with input options
                        BYTE        0dh,0ah,"Please choose an option:", 0dh,0ah
                        BYTE        "1 - Display balance", 0dh,0ah
                        BYTE        "2 - Withdraw", 0dh,0ah
                        BYTE        "3 - Deposit", 0dh,0ah
                        BYTE        "4 - Print Receipt", 0dh,0ah
                        BYTE        "5 - Exit", 0dh,0ah,0dh,0ah
                        BYTE        "############# ATM MENU #############", 0
    depositMenuMsg      BYTE    "Choose a deposit option:", 0dh, 0ah                ; deposit option menu
                        BYTE    "1 - Cash", 0dh, 0ah
                        BYTE    "2 - Check", 0
    cashDepositMsg      BYTE    "Cash deposit - please enter multiples of $10", 0   ; cash message 
    checkDepositMsg     BYTE    "Check deposit - please enter check value", 0       ; check message
    invalidDepChoice    BYTE    "Invalid selection option", 0                       ; invalid deposit menu choice message
    depositPrompt       BYTE    "Enter deposit amount: ", 0                         ; prompt for when entering a deposit value
    withdrawalPrompt    BYTE    "Enter withdrawal amount: ", 0                      ; prompt for when entering a withdrawal value
    insufficientFunds   BYTE    "Insufficient funds - withdrawal cancelled", 0      ; insufficient funds error message
    withdrawSuccessMsg  BYTE    "Withdrawal completed", 0                           ; withdrawal success message
    balMsg              BYTE    "Balance: $", 0                                     ; message used when balance is displayed 
    accountNumberMsg    BYTE    "Account number: ", 0                               ; account number display message
    validDetailsMsg     BYTE    "Details match - user validated", 0                 ; successful login message
    wrongPinMsg         BYTE    "Incorrect pin - exiting", 0                        ; incorrect pin message
    invalidMenuInput    BYTE    "Invalid menu selection", 0                         ; invalid menu selection message
    totalWithdrawMsg    BYTE    "Total withdrawn: $", 0                             ; total withdrawn message
    totalDepositMsg     BYTE    "Total deposited: $", 0                             ; total deposited message
    totalWithdrawn      DWORD   0                                                   ; total withdrawn
    totalDeposited      DWORD   0                                                   ; total deposited
    transactionCounter  BYTE    0                                                   ; transaction counter
    transLimitMsg       BYTE    "Transaction limit reached for this session", 0     ; trans limited exceeded error message
    TRANSLIMIT = 3                                                                  ; transaction limit
    LOGINLIMIT = 3
    loginCounter        BYTE    0
    loginExceedMsg      BYTE    "Incorrect login attempt limit reached", 0
    cashCheckDep        BYTE    ?
    invalidDenomMsg     BYTE    "Not a denomination of $10 - deposit cancelled",0   ; invalid denomination message
    enteredDeposit      DWORD   ?

.code
main proc
    ; print welcome message
    mov EDX, OFFSET welcomeMsg
    call WriteString
    call Crlf
UserLogin:
    call Crlf
    call GetLoginDetails
    ; check details are valid, if invalud validDetails set to 0
    call ValidateDetails
    cmp validDetails, 1
    je PrintMenu
    call WaitMsg
    cmp loginCounter, LOGINLIMIT
    jnb LoginExceeded
    jmp UserLogin

LoginExceeded:
    call Crlf
    mov EDX, OFFSET loginExceedMsg
    call WriteString
    call Crlf
    jmp Quit
;-----------
; print menu message and
; process user input
;
PrintMenu:
    call MainMenu

Quit:
    call QuitMessage
    
    exit
main endp

;----
; processes
;----
GetLoginDetails PROC
    ; prompt user for account number
    mov EDX, OFFSET accountPrompt
    call WriteString
    call ReadInt
    mov EBX, EAX
    ; prompt user for pin number
    mov EDX, OFFSET pinPrompt
    call WriteString
    call ReadInt
    inc loginCounter
    ret
GetLoginDetails ENDP
;---------------------------------
ValidateDetails PROC
; takes EAX as pin, and EBX as account
; number and verify that they have
; the same index position in PINS and
; accountNumbers respectively
; if valid, validDetails is set to 1
;
    PUSHAD              ; push values to stack
    mov ECX, LENGTHOF accountNumbers 
    mov ESI, OFFSET accountNumbers
    mov sessionId, 0
AccountNoChecker:
    cmp EBX, DWORD PTR [ESI]
    je Success
    inc sessionId
    add ESI, TYPE accountNumbers
    loop AccountNoChecker
    ; if loop fails
    mov EDX, OFFSET invalidAccountMsg
    call WriteString
    call Crlf
    jmp Finish
Success:
    ; check pin
    mov ESI, OFFSET PINS
    movzx ECX, sessionId
GetPin:
    add ESI, TYPE PINS 
    loop GetPin
    cmp AX, WORD PTR [ESI]
    je Valid
    mov EDX, OFFSET wrongPinMsg
    call WriteString
    call Crlf
    jmp Finish
Valid:
    mov EDX, OFFSET validDetailsMsg
    call WriteString
    call Crlf
    mov validDetails, 1
Finish:
    POPAD           ; restore values
    ret
ValidateDetails ENDP

;------------------------------
MainMenu PROC
    PUSHAD

PrintMenu:
    call WaitMsg                            ; allow user to control when to continue
    call Clrscr                             ; clear screen before printing menu each time
    
    mov EDX, OFFSET menuMsg
    call WriteString
    call Crlf
    call ReadInt
    cmp EAX, 1
    je Option1
    cmp EAX, 2
    je Option2
    cmp EAX, 3
    je Option3
    cmp EAX, 4
    je Option4
    cmp EAX, 5
    je Quit
    mov EDX, OFFSET invalidMenuInput
    call WriteString
    call Crlf
    jmp PrintMenu

Option1:
    call DisplayBalance
    jmp PrintMenu
Option2:
    call Withdraw
    jmp PrintMenu
Option3:
    call Deposit
    jmp PrintMenu
Option4:
    call PrintReceipt
    jmp PrintMenu
Quit:

    POPAD
    ret
MainMenu ENDP

;----------------------h
QuitMessage PROC
    PUSHAD
    mov EDX, OFFSET exitMsg
    call WriteString
    call Crlf
    call WaitMsg
    POPAD
    ret
QuitMessage ENDP

;-----------------------------
GetBalance PROC
; takes no parameters, but after
; running, sets EAX to the users
; account balance, and sets ESI
; to their account value address
;
    movzx ECX, sessionId
    mov ESI, OFFSET Balances
FindBalance:
    add ESI, TYPE Balances
    loop FindBalance
    mov EAX, DWORD PTR [ESI]
    ret
GetBalance ENDP

;-------------------------------
DisplayBalance PROC
; gets users balance and prints
; it to screen, with message
;
    PUSHAD    
    ; put balance value in EAX
    ; and put value address in ESI
    call GetBalance
    mov EDX, OFFSET balMsg
    call WriteString
    call WriteDec
    call Crlf
    POPAD
    ret
DisplayBalance ENDP

;------------------------
Withdraw PROC
; prints withdrawal prompt
; gets users withdrawal value
; subs that value from current
; balance, then updates user
; balance with new value
;
    PUSHAD
    cmp transactionCounter, TRANSLIMIT
    jnb TransactionLimit
    mov EDX, OFFSET withdrawalPrompt
    call WriteString
    call ReadInt
    mov EBX, EAX
    call GetBalance    
    cmp EBX, EAX
    ja Error                                                    ; if withdrawal is greater than balance, generate error
    cmp EBX, maxWithdrawalVal                                   ; if withdrawal greater than max withdrawal limit, generate error  
    ja ErrorMax
    ; bal value is in EAX, and address in ESI
    sub EAX, EBX
    add totalWithdrawn, EBX
    ; mov new EAX value into array position
    mov DWORD PTR [ESI], EAX    
    inc transactionCounter
    call DisplayBalance
    jmp Finish
TransactionLimit:
    call TransactionLimitExceeded
    jmp Finish
ErrorMax:
    mov EDX, OFFSET maxWithdrawalMsg
    call WriteString
    call Crlf
    jmp Finish
Error:
    mov EDX, OFFSET insufficientFunds
    call WriteString
    call Crlf
Finish:
    POPAD
    ret
Withdraw ENDP

;------------------------
Deposit PROC
; prints deposit prompt
; gets users deposit value
; adds that value from current
; balance, then updates user
; balance with new value
;
    PUSHAD
    cmp transactionCounter, TRANSLIMIT
    jnb TransactionLimit
    mov EDX, OFFSET depositMenuMsg
    call WriteString
    call Crlf
    call ReadInt
    cmp EAX, 1
    je Cash
    cmp EAX, 2
    je Check
    mov EDX, OFFSET invalidDepChoice
    call WriteString
    call Crlf
    jmp Finish

TransactionLimit:
    call TransactionLimitExceeded
    jmp Finish
Cash:
    mov cashCheckDep, 1
    mov EDX, OFFSET cashDepositMsg
    call WriteString
    call Crlf
    jmp EnterValue
Check:
    mov cashCheckDep, 0
    mov EDX, OFFSET checkDepositMsg
    call WriteString
    call Crlf
EnterValue:
    mov EDX, OFFSET depositPrompt
    call WriteString
    call ReadInt

    cmp cashCheckDep, 1
    jne BalanceCalc                                                         ; jump to next step if not cash
    mov enteredDeposit, EAX                                                 ; move entered amount into memory to accessed via pointers
    PUSHAD                                                                  ; push eax register to stack to save value
    mov DX, WORD PTR [enteredDeposit + 2]                                   ; move first part of EAX value into DX
    mov AX, WORD PTR enteredDeposit                                         ; move seconds part into AX (note little endian)
    mov BX, 10                                                              ; 10 is our divisor, so move into BX
    div BX                                                                  ; perform division
    cmp DX, 0                                                               ; if 10|EAX then remainder should be 0
    POPAD                                                                   ; restore register values before any jumps occur
    jne InvalidDenom                                                        ; if there is remainder, trigger error
BalanceCalc:
    mov EBX, EAX
    call GetBalance    
    ; bal value is in EAX, and address in ESI
    add EAX, EBX
    add totalDeposited, EBX
    ; mov new EAX value into array position
    mov DWORD PTR [ESI], EAX
    inc transactionCounter
    call DisplayBalance
    jmp Finish
InvalidDenom:
    mov EDX, OFFSET invalidDenomMsg
    call WriteString
    call Crlf
Finish:    
    POPAD
    ret
Deposit ENDP

PrintReceipt PROC
    PUSHAD
    mov EDX, OFFSET accountNumberMsg
    call WriteString
    movzx ECX, sessionId
    mov ESI, OFFSET accountNumbers
GetAccountNumber:
    add ESI, TYPE accountNumbers
    loop GetAccountNumber
    mov EAX, DWORD PTR [ESI]
    call WriteDec
    call Crlf
    mov EDX, OFFSET totalWithdrawMsg
    call WriteString
    mov EAX, totalWithdrawn
    call WriteDec
    call Crlf
    mov EDX, OFFSET totalDepositMsg
    call WriteString
    mov EAX, totalDeposited
    call WriteDec
    call Crlf
    call DisplayBalance


    POPAD
    ret
PrintReceipt ENDP

;-----------------------
TransactionLimitExceeded PROC
    PUSHAD
    mov EDX, OFFSET transLimitMsg
    call WriteString
    call Crlf
    POPAD
    ret
TransactionLimitExceeded ENDP
end main
