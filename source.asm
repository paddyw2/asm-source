; Program template
; Author:
; Date:
; Program Description: 

include Irvine32.inc

.data
    msgTitle        BYTE    "Welcome to Bank Account checker!", 0
    msgDeposits     BYTE    "Enter deposits (max 24 - enter -1 to finish)", 0
    depositPrompt   BYTE    "Deposit: ", 0
    msgWithdraws    BYTE    "Enter withdrawals (max 24 - enter -1 to finish)", 0
    withdrawPrompt  BYTE    "Withdrawal: ", 0 
    msgBalance      BYTE    "Your balance is: ", 0
    initialBal      WORD    0
    dailyDeposits   WORD    24 DUP[?]
    dailyWithdraws  WORD    24 DUP[?]
    finalBal        WORD    0

.code
main proc
    mov edx, OFFSET msgTitle
    call WriteString 
    call Crlf
   
    ; deposits 
    Deposit: 
        mov edx, OFFSET msgDeposits
        call WriteString
        call Crlf
        
        mov ecx, 24
    DepositLoop:
        mov edx, OFFSET depositPrompt 
        call WriteString
        call ReadInt
        cmp eax, -1
        je Withdraw
        mov ebx, ecx
        sub ebx, 24
        mov [dailyWithdraws + ebx], ax
        loop DepositLoop
    
    ; withdrawals
    Withdraw:
        mov edx, OFFSET msgWithdraws
        call WriteString
        call Crlf
        
        mov ecx, 24
    WithdrawLoop:
        mov edx, OFFSET withdrawPrompt
        call WriteString
        call ReadInt
        cmp eax, -1
        je DisplayBalance
        mov ebx, ecx
        sub ebx, 24
        mov [dailyWithdraws + ebx], ax
        loop WithdrawLoop
               
    mov ecx, 24
        
    AddDeposits:
        mov eax, 0        
        mov ax, initialBal
        mov ebx, ecx
        sub ebx, 24
        cmp ebx, 0
        je DisplayBalance
        add ax, [dailyDeposits + ebx]
        loop AddDeposits
   
    DisplayBalance:
        mov finalBal, ax
        mov edx, OFFSET msgBalance
        call WriteString
        call WriteDec
        call Crlf 
        
        

    exit
main endp					; ends main process
end main
