; Working source file

include irvine32.inc

.data
    msgTitle            BYTE        "Welcome to Balance Checker!", 0
	origBalTitle		BYTE		"Your original balance: ", 0
	depTitle			BYTE		"Deposits: ", 0
	withTitle			BYTE		"Withdrawals: ", 0
    balanceTitle        BYTE        "Your new balance is: ", 0
    initialBal          WORD        1000
    deposits            WORD        150, 100, 450, 100, 100, 50, 50
    withdrawals         WORD        100, 50
    finalBal            WORD        0

.code
main proc
    mov EDX, OFFSET msgTitle
    call WriteString
    call Crlf
	; print original balance
	mov EDX, OFFSET origBalTitle
	call WriteString
	movzx EAX, initialBal
	call WriteDec
    ; print deposits
	DepositTitle:	
		call Crlf
		mov EDX, OFFSET depTitle 
		call WriteString
		mov ECX, LENGTHOF deposits
		mov ESI, OFFSET deposits
	PrintDepositsLoop:
		mov AX, [ESI]
		call WriteDec
		cmp ECX, 1
		je WithdrawalsTitle
		mov AL, ','
		call WriteChar
		mov AL, ' '
		call WriteChar
		add ESI, TYPE WORD
		dec ECX
		jmp PrintDepositsLoop	

	WithdrawalsTitle:
		call Crlf
		mov EDX, OFFSET withTitle
		call WriteString
		mov ECX, LENGTHOF withdrawals
		mov ESI, OFFSET withdrawals
	PrintWithdrawalsLoop:
		mov AX, [ESI]
		call WriteDec
		cmp ECX, 1
		je AddDeposits
		mov AL, ','
		call WriteChar
		mov AL, ' '
		call WriteChar
		add ESI, TYPE WORD
		dec ECX
		jmp PrintWithdrawalsLoop

    AddDeposits:
		movzx EAX, initialBal
		mov ECX, LENGTHOF deposits
		mov ESI, OFFSET deposits
	AddDepositsLoop:
        add AX, [ESI]
        add ESI, TYPE WORD
        loop AddDepositsLoop

	AddWithdrawals:
		mov ECX, LENGTHOF withdrawals
		mov ESI, OFFSET withdrawals
	AddWithdrawalsLoop:
		sub AX, [ESI]
		add ESI, TYPE WORD
		loop AddWithdrawalsLoop
    mov finalBal, AX
	call Crlf
    mov EDX, OFFSET balanceTitle
    call WriteString
    call WriteDec
    call Crlf
    call WaitMsg
    
    exit
    main endp
end main
