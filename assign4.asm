include irvine32.inc

.data
; an array for account numbers stored in system.
accountNumbers DWORD 10021331, 12322244, 44499922, 10222334
;an array for PINS corresponding to each account
PINS WORD 2341, 3345, 1923, 3456
; an array for balances corresponding to each account
Balances DWORD 1000, 0, 80000, 4521
; atm welcome message
welcomeMsg  BYTE    "Welcome to this ATM", 0
; pin prompt
pinPrompt   BYTE    "Enter your pin: ", 0
; account number prompt
accountPrompt   BYTE    "Enter your account number: ", 0
; index
index   BYTE    ?
validDetails    BYTE    0
; invalud accoutn no
invalidAccountMsg   BYTE    "That account does not exist", 0
exitMsg     BYTE        "Thank you for using this ATM", 0
menuMsg     BYTE        "Please choose an option:", 0dh,0ah
            BYTE        "1 - Display balance", 0dh,0ah
            BYTE        "2 - Withdraw", 0dh,0ah
            BYTE        "3 - Deposit", 0dh,0ah
            BYTE        "4 - Print Receipt", 0dh,0ah
            BYTE        "5 - Exit", 0

depositPrompt   BYTE    "Enter deposit amount: ", 0
withdrawalPrompt    BYTE    "Enter withdrawal amount: ", 0
balMsg          BYTE        "Balance: ", 0
validDetailsMsg BYTE        "Details match - user validated", 0
wrongPinMsg     BYTE        "Incorrect pin - exiting", 0
invalidMenuInput    BYTE    "Invalid menu selection", 0


.code
main proc
    mov EDX, OFFSET welcomeMsg
    call WriteString
    call Crlf
    mov EDX, OFFSET accountPrompt
    call WriteString
    call ReadInt
    mov EBX, EAX
    mov EDX, OFFSET pinPrompt
    call WriteString
    call ReadInt
    
    call ValidateDetails
    cmp validDetails, 1
    jne Quit
PrintMenu:
    call Clrscr ; clear screen
    
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
    je Option5
    mov EDX, OFFSET invalidMenuInput
    call WriteString
    call Crlf
    jmp Quit

Option1:
    call DisplayBalance
    jmp Quit
Option2:
    call Withdraw
    jmp Quit
Option3:
    call Deposit
    jmp Quit 
Option4:
    call PrintReceipt
    jmp Quit
Option5:
    jmp Quit 
     

Quit:
    mov EDX, OFFSET exitMsg
    call WriteString
    call Crlf
    exit
    main endp

;----
; processes
;----
ValidateDetails PROC
    ; takes EAX, EBX as pin and account no
    PUSHAD              ; push values to stack
    mov ECX, LENGTHOF accountNumbers 
    mov ESI, OFFSET accountNumbers
    mov index, 0
AccountNoChecker:
    cmp EBX, DWORD PTR [ESI]
    je Success
    inc index
    add ESI, TYPE accountNumbers
    loop AccountNoChecker
    ; if loop fails
    mov EDX, OFFSET invalidAccountMsg
    call WriteString
    call Crlf
    jmp End
Success:
    ; check pin
    mov ESI, OFFSET PINS
    mov ECX, index
GetPin:
    add ESI, TYPE PINS 
    loop GetPin
    cmp EAX, WORD PTR [ESI]
    je Valid
    mov EDX, OFFSET wrongPinMsg
    call WriteString
    call Crlf
    jmp End
Valid:
    mov EDX, OFFSET validDetailsMsg
    call WriteString
    call Crlf
    mov validDetails, 1
End:
    POPAD           ; restore values
    ret
ValidateDetails ENDP

GetBalance PROC
    mov ECX, index
    mov ESI, OFFSET Balances
FindBalance:
    add ESI, TYPE Balances
    loop FindBalance
    mov EAX, DWORD PTR [ESI]
    ret
GetBalance ENDP


DisplayBalance PROC
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

Withdraw PROC
    PUSHAD
    mov EDX, OFFSET withdrawalPrompt
    call WriteString
    call ReadInt
    mov EBX, EAX
    call GetBalance    
    ; bal value is in EAX, and address in ESI
    sub EAX, EBX
    ; mov new EAX value into array position
    mov DWORD PTR [ESI], EAX    
    POPAD
    ret
Withdraw ENDP

Deposit PROC
    PUSHAD
    mov EDX, OFFSET depositPrompt
    call WriteString
    call ReadInt
    mov EBX, EAX
    call GetBalance    
    ; bal value is in EAX, and address in ESI
    add EAX, EBX
    ; mov new EAX value into array position
    mov DWORD PTR [ESI], EAX    
    POPAD
    ret
Deposit ENDP

PrintReceipt PROC
    PUSHAD


    POPAD
    ret
PrintReceipt ENDP

end main
