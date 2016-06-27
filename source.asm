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
    enteredDeposit      DWORD   ?                                                   ; memory location for deposit value

.code
main proc
    mov EDX, OFFSET welcomeMsg                                                      ; move welcome message offset into EDX 
    call WriteString                                                                ; write welcome message to screen
    call Crlf                                                                       ; print new line
UserLogin:
    call Crlf                                                                       ; print new line
    call GetLoginDetails                                                            ; call login prompt procedure
    call ValidateDetails                                                            ; call validation procedure, if details invalid validDetails set to 0
    cmp validDetails, 1                                                             ; check details were valid
    je PrintMenu                                                                    ; if valid, jump to PrintMenu
    call WaitMsg                                                                    ; print wait message, wait for user input
    cmp loginCounter, LOGINLIMIT                                                    ; compare login attempts to limit
    jnb LoginExceeded                                                               ; if greater than three, jump to LoginExceeded
    jmp UserLogin                                                                   ; else, jump back to the start of UserLogin

LoginExceeded:
    call Crlf                                                                       ; print new line
    mov EDX, OFFSET loginExceedMsg                                                  ; move login exceeded message into EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    jmp Quit                                                                        ; jump to quit label

PrintMenu:
    call MainMenu                                                                   ; call MainMenu procedure

Quit:
    call QuitMessage                                                                ; call QuitMessage procedure
    
    exit
main endp

;----
; processes
;----

;--------------------------------------------
GetLoginDetails PROC
; Prompt user for account and pin number
;
; Receives:
; Returns: EAX, EBX as pin and account number
;
    mov EDX, OFFSET accountPrompt                                                   ; move enter account number message to EDX
    call WriteString                                                                ; print message to screen
    call ReadInt                                                                    ; read user input as integer
    mov EBX, EAX                                                                    ; move input into EBX to store for later
    mov EDX, OFFSET pinPrompt                                                       ; move enter pin message to EDX
    call WriteString                                                                ; print message to screen
    call ReadInt                                                                    ; read user input as integer
    inc loginCounter                                                                ; increment login counter at each attempt
    ret                                                                             ; return to after call location
GetLoginDetails ENDP

;---------------------------------
ValidateDetails PROC
; Takes EAX as pin, and EBX as account
; number and verify that they have
; the same index position in PINS and
; accountNumbers respectively
; if valid, validDetails is set to 1
; 
; Receives: EAX, EBX as pin and account number
; Returns: validDetails
;
    PUSHAD                                                                          ; push values to stack
    mov ECX, LENGTHOF accountNumbers                                                ; move length of accountNumbers to ECX
    mov ESI, OFFSET accountNumbers                                                  ; move starting address of accountNumbers to ESI
    mov sessionId, 0                                                                ; set sessionId (index identifier) to zero
AccountNoChecker:
    cmp EBX, DWORD PTR [ESI]                                                        ; each loop, compare user input to each account number
    je Success                                                                      ; if equal, jump to success
    inc sessionId                                                                   ; if not, increment sessionId value
    add ESI, TYPE accountNumbers                                                    ; increment address value by type
    loop AccountNoChecker                                                           ; loop for length of accountNumbers
    mov EDX, OFFSET invalidAccountMsg                                               ; if end of loop is reached, move invalid account message to EDX
    call WriteString                                                                ; write message to screen
    call Crlf                                                                       ; print new line
    jmp Finish                                                                      ; jump to Finish label
Success:
    mov ESI, OFFSET PINS                                                            ; if account number valid, check pin matches, so move PINS address into ESI
    movzx ECX, sessionId                                                            ; move sessionId (index) into ECX loop counter
GetPin:
    add ESI, TYPE PINS                                                              ; increment address value on each loop
    loop GetPin                                                                     ; loop until sessionId index value is reached
    cmp AX, WORD PTR [ESI]                                                          ; check if this pin number matches the one entered by user
    je Valid                                                                        ; if equal, jump to Valid label
    mov EDX, OFFSET wrongPinMsg                                                     ; if not, move wrong pin message to EDX
    call WriteString                                                                ; write message to screen
    call Crlf                                                                       ; print new line
    jmp Finish                                                                      ; jump to Finish label
Valid:
    mov EDX, OFFSET validDetailsMsg                                                 ; move valid details message into EDX
    call WriteString                                                                ; write message to screen
    call Crlf                                                                       ; print new line
    mov validDetails, 1                                                             ; move 1 into validDetails to signify successful login
Finish:
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
ValidateDetails ENDP

;------------------------------
MainMenu PROC
; Prints main menu and processes user selection
; by calling appropriate procedures
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack
PrintMenu:
    call WaitMsg                                                                    ; print wait message - allow user to control when to continue
    call Clrscr                                                                     ; clear screen before printing menu each time
    
    mov EDX, OFFSET menuMsg                                                         ; move menu options into EDX
    call WriteString                                                                ; print menu options to screen
    call Crlf                                                                       ; print new line
    call ReadInt                                                                    ; read user input as integer
    cmp EAX, 1                                                                      ; compare user input in EAX to 1
    je Option1                                                                      ; if equal, jump to Option1 label
    cmp EAX, 2                                                                      ; compare input to 2
    je Option2                                                                      ; if equal jump to Option2
    cmp EAX, 3                                                                      ; compare to 3
    je Option3                                                                      ; if equal jump to Option3
    cmp EAX, 4                                                                      ; compare to 4
    je Option4                                                                      ; if equal jump to Option4
    cmp EAX, 5                                                                      ; compare to 5
    je Quit                                                                         ; if equal jump to Quit
    mov EDX, OFFSET invalidMenuInput                                                ; if some other input, move invalid input message to EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    jmp PrintMenu                                                                   ; jump back to PrintMenu to clear screen and print options

Option1:
    call DisplayBalance                                                             ; if input is 1, call DisplayBalance
    jmp PrintMenu                                                                   ; return to menu
Option2:
    call Withdraw                                                                   ; if input is 2, call Withdraw
    jmp PrintMenu                                                                   ; return to menu
Option3:
    call Deposit                                                                    ; if input is 3, call Deposit
    jmp PrintMenu                                                                   ; return to menu
Option4:
    call PrintReceipt                                                               ; if input is 4, call PrintReceipt
    jmp PrintMenu                                                                   ; return to menu
Quit:
                                                                                    ; if input is 5, do not return to menu
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
MainMenu ENDP

;-----------------------------
QuitMessage PROC
; Prints quit message to screen
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack
    mov EDX, OFFSET exitMsg                                                         ; move exit message to EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    call WaitMsg                                                                    ; print wait message and wait for user input
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
QuitMessage ENDP

;-----------------------------
GetBalance PROC
; Takes no parameters, but after
; running, sets EAX to the users
; account balance, and sets ESI
; to their account value address
;
; Receives:
; Returns: EAX, ESI as account balance, and account address
;
    movzx ECX, sessionId                                                            ; move sessionId into ECX with zero extension
    mov ESI, OFFSET Balances                                                        ; move starting address of Balances into ESI
FindBalance:
    add ESI, TYPE Balances                                                          ; each loop, add to address of Balances until desired index is reached
    loop FindBalance                                                                ; loop back to FindBalances while ECX != 0
    mov EAX, DWORD PTR [ESI]                                                        ; when index reached, move value into EAX
    ret                                                                             ; return
GetBalance ENDP

;-------------------------------
DisplayBalance PROC
; Gets users balance and prints
; it to screen, with message
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack 
    call GetBalance                                                                 ; call GetBalance procedure to get bal val in EAX and address in ESI
    mov EDX, OFFSET balMsg                                                          ; move balance message into EDX
    call WriteString                                                                ; print message to screen
    call WriteDec                                                                   ; write EAX decimal value to screen
    call Crlf                                                                       ; print new line
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
DisplayBalance ENDP

;------------------------
Withdraw PROC
; Prints withdrawal prompt
; gets users withdrawal value
; subs that value from current
; balance, then updates user
; balance with new value
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack
    cmp transactionCounter, TRANSLIMIT                                              ; compare transactions so far with limit
    jnb TransactionLimit                                                            ; if not below, jump to error TransactionLimit label
    mov EDX, OFFSET withdrawalPrompt                                                ; move withdrawalPrompt message address to EDX
    call WriteString                                                                ; print message to screen
    call ReadInt                                                                    ; read user input as integer
    mov EBX, EAX                                                                    ; save EAX by moving into EBX
    call GetBalance                                                                 ; call GetBalance to get value into EAX and address into ESI
    cmp EBX, EAX                                                                    ; compare balance with amount to withdraw
    ja Error                                                                        ; if withdrawal is greater than balance, generate error
    cmp EBX, maxWithdrawalVal                                                       ; if withdrawal greater than max withdrawal limit, generate error  
    ja ErrorMax                                                                     ; jump to error label ErrorMax
    sub EAX, EBX                                                                    ; if valid, subtract value from current balance
    add totalWithdrawn, EBX                                                         ; sum totalWithdrawn value
    mov DWORD PTR [ESI], EAX                                                        ; update balance with new total
    inc transactionCounter                                                          ; increment transaction counter
    call DisplayBalance                                                             ; call DisplayBalance
    jmp Finish                                                                      ; jump to Finish label
TransactionLimit:
    call TransactionLimitExceeded                                                   ; call error label
    jmp Finish                                                                      ; jump to Finish label
ErrorMax:
    mov EDX, OFFSET maxWithdrawalMsg                                                ; move error message into EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    jmp Finish                                                                      ; jump to Finish label
Error:
    mov EDX, OFFSET insufficientFunds                                               ; move error message into EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
Finish:
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
Withdraw ENDP

;------------------------
Deposit PROC
; prints deposit prompt
; gets users deposit value
; adds that value from current
; balance, then updates user
; balance with new value
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack
    cmp transactionCounter, TRANSLIMIT                                              ; check transaction limit is not reached
    jnb TransactionLimit                                                            ; if it is, jump to error label
    mov EDX, OFFSET depositMenuMsg                                                  ; move deposit menu message to EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    call ReadInt                                                                    ; read user input as integer
    cmp EAX, 1                                                                      ; compare to 1
    je Cash                                                                         ; if equal, jump to Cash option
    cmp EAX, 2                                                                      ; compare to 2
    je Check                                                                        ; if equal, jump to Check option
    mov EDX, OFFSET invalidDepChoice                                                ; move error message to EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    jmp Finish                                                                      ; jump to Finish label

TransactionLimit:
    call TransactionLimitExceeded                                                   ; call error procedure
    jmp Finish                                                                      ; jump to finish label
Cash:
    mov cashCheckDep, 1                                                             ; set user choice to 1
    mov EDX, OFFSET cashDepositMsg                                                  ; move message into EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    jmp EnterValue                                                                  ; jump to EnterValue label
Check:
    mov cashCheckDep, 0                                                             ; set user choice to 2
    mov EDX, OFFSET checkDepositMsg                                                 ; move message to EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
EnterValue:
    mov EDX, OFFSET depositPrompt                                                   ; move message to EDX
    call WriteString                                                                ; print message to screen
    call ReadInt                                                                    ; read user input as integer

    cmp cashCheckDep, 1
    jne BalanceCalc                                                                 ; jump to next step if not cash
    mov enteredDeposit, EAX                                                         ; move entered amount into memory to accessed via pointers
    PUSHAD                                                                          ; push eax register to stack to save value
    mov DX, WORD PTR [enteredDeposit + 2]                                           ; move first part of EAX value into DX
    mov AX, WORD PTR enteredDeposit                                                 ; move seconds part into AX (note little endian)
    mov BX, 10                                                                      ; 10 is our divisor, so move into BX
    div BX                                                                          ; perform division
    cmp DX, 0                                                                       ; if 10|EAX then remainder should be 0
    POPAD                                                                           ; restore register values before any jumps occur
    jne InvalidDenom                                                                ; if there is remainder, trigger error
BalanceCalc:
    mov EBX, EAX                                                                    ; store EAX value in EBX
    call GetBalance                                                                 ; call GetBalance - bal value is in EAX, and address in ESI
    add EAX, EBX                                                                    ; add balance and deposit
    add totalDeposited, EBX                                                         ; sum total deposits
    mov DWORD PTR [ESI], EAX                                                        ; update balance value 
    inc transactionCounter                                                          ; increment transactions
    call DisplayBalance                                                             ; print user balance
    jmp Finish                                                                      ; jump to finish
InvalidDenom:
    mov EDX, OFFSET invalidDenomMsg                                                 ; move message to EDX        
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
Finish:    
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
Deposit ENDP

;------------------------------
PrintReceipt PROC
; Prints users receipt details
; to screen
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack
    mov EDX, OFFSET accountNumberMsg                                                ; move message to EDX register
    call WriteString                                                                ; print message to screen
    movzx ECX, sessionId                                                            ; move sessionId to ECX with zero extension
    mov ESI, OFFSET accountNumbers                                                  ; move start of accountNumbers address to ESI
GetAccountNumber:
    add ESI, TYPE accountNumbers                                                    ; each loop, increment address to get to desired index
    loop GetAccountNumber                                                           ; loop GetAccountNumber
    mov EAX, DWORD PTR [ESI]                                                        ; move balance value into EAX
    call WriteDec                                                                   ; print value to screen
    call Crlf                                                                       ; print new line
    mov EDX, OFFSET totalWithdrawMsg                                                ; move message to EDX
    call WriteString                                                                ; print message to screen
    mov EAX, totalWithdrawn                                                         ; move total withdrawn value to EAX
    call WriteDec                                                                   ; print value to screen
    call Crlf                                                                       ; print new line
    mov EDX, OFFSET totalDepositMsg                                                 ; move message address to EDX
    call WriteString                                                                ; print message to screen
    mov EAX, totalDeposited                                                         ; move total deposited value to EAX
    call WriteDec                                                                   ; print value to screen
    call Crlf                                                                       ; print new line
    call DisplayBalance                                                             ; call DisplayBalance procedure

    POPAD                                                                           ; restore register values
    ret                                                                             ; return
PrintReceipt ENDP

;---------------------------------
TransactionLimitExceeded PROC
; Prints transaction limit reached error
; message to screen
;
; Receives:
; Returns:
;
    PUSHAD                                                                          ; push register values to stack
    mov EDX, OFFSET transLimitMsg                                                   ; move message address to EDX
    call WriteString                                                                ; print message to screen
    call Crlf                                                                       ; print new line
    POPAD                                                                           ; restore register values
    ret                                                                             ; return
TransactionLimitExceeded ENDP
end main
