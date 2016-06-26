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
; Prints main menu and processes user selection
; by calling appropriate procedures
;
; Receives:
; Returns:
;
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

;-----------------------------
QuitMessage PROC
; Prints quit message to screen
;
; Receives:
; Returns:
;
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
; Takes no parameters, but after
; running, sets EAX to the users
; account balance, and sets ESI
; to their account value address
;
; Receives:
; Returns: EAX, ESI as account balance, and account address
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
; Gets users balance and prints
; it to screen, with message
;
; Receives:
; Returns:
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
; Prints withdrawal prompt
; gets users withdrawal value
; subs that value from current
; balance, then updates user
; balance with new value
;
; Receives:
; Returns:
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
; Receives:
; Returns:
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

;---------------------------------
TransactionLimitExceeded PROC
; Prints transaction limit reached error
; message to screen
;
; Receives:
; Returns:
;
    PUSHAD
    mov EDX, OFFSET transLimitMsg
    call WriteString
    call Crlf
    POPAD
    ret
TransactionLimitExceeded ENDP
end main
