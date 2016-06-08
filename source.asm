include irvine32.inc

.data
    msgTitle            BYTE        "Welcome to Balance Checker!", 0
    balanceTitle        BYTE        "Your balance is: ", 0
    initialBal          WORD        100
    deposits            WORD        150, 100, 450
    withdrawals         WORD        100, 50
    finalBal            WORD        0

.code
main proc
    mov EDX, OFFSET msgTitle
    call WriteString
    call Crlf
    
    mov ECX, LENGTHOF deposits
    mov EAX, 0
    mov ESI, OFFSET deposits
    AddDeposits:
        add EAX, [ESI]
        add ESI, TYPE WORD
        loop AddDeposits

    mov finalBal, AX
    mov EDX, OFFSET balanceTitle
    call WriteString
    call Write Dec
    call Crlf
    call WaitMsg
    
    exit
    end mainp
main end
