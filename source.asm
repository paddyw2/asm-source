;---------------------------;
; Assignment 3				;
; Problem 5					;
; Author: Patrick Withams	;
; Date: 9/6/2015			;
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
	origBalTitle		BYTE		"Your original balance: ", 0
	balPrompt			BYTE		"Enter original balance (max 65535): ", 0
	depPrompt			BYTE		"Enter deposits (max 24, enter 0 to finish): ", 0
	withPrompt			BYTE		"Enter withdrawals (max 24, enter 0 to finish): ", 0
	depTitle			BYTE		"Deposits: ", 0
	withTitle			BYTE		"Withdrawals: ", 0
    balanceTitle        BYTE        "Your new balance is: ", 0
    initialBal          WORD        0
    deposits            WORD        25 DUP(0)
    withdrawals         WORD        25 DUP(0)
    finalBal            WORD        0

.code
main proc
	;------------------------
	; print welcome message
	;
    mov EDX, OFFSET msgTitle
    call WriteString
    call Crlf
	;-----------------------
	; get original balance
	;
	mov EDX, OFFSET balPrompt
	call WriteString
	call ReadInt
	mov initialBal, AX
	;-------------------------
	; print original balance
	;
	mov EDX, OFFSET origBalTitle
	call WriteString
	movzx EAX, initialBal
	call WriteDec
	call Crlf
	;---------------
	; get deposits
	;
	mov EDX, OFFSET depPrompt
	call WriteString
	call Crlf
	mov EBX, LENGTHOF deposits
	sub EBX, 1
	mov ESI, OFFSET deposits
	mov ECX, EBX
EnterDeposits:
	call ReadInt
	cmp EAX, 0
	je DepositTitle
	mov [ESI], AX
	add ESI, TYPE deposits
	loop EnterDeposits
	;-----------------
    ; print deposits
	;
DepositTitle:	
	mov EDX, OFFSET depTitle 
	call WriteString
	mov ECX, LENGTHOF deposits
	mov ESI, OFFSET deposits
	mov EAX, 0
PrintDepositsLoop:
	mov AX, [ESI]	
	call WriteDec
	cmp ECX, 1
	je GetWithdrawals	
	cmp AX, 0
	je GetWithdrawals
	mov AL, ','
	call WriteChar
	mov AL, ' '
	call WriteChar
	add ESI, TYPE WORD
	dec ECX
	jmp PrintDepositsLoop	
	;------------------
	; get withdrawals
	;
GetWithdrawals:
	call Crlf
	mov EDX, OFFSET withPrompt
	call WriteString
	call Crlf
	mov EBX, LENGTHOF withdrawals
	sub EBX, 1
	mov ESI, OFFSET withdrawals
	mov ECX, EBX
EnterWithdrawals:
	call ReadInt
	cmp EAX, 0
	je WithdrawalsTitle
	mov [ESI], AX
	add ESI, TYPE withdrawals
	loop EnterWithdrawals
	;----------------------
	; print withdrawals
	;
WithdrawalsTitle:
	mov EDX, OFFSET withTitle
	call WriteString
	mov ECX, LENGTHOF withdrawals
	mov ESI, OFFSET withdrawals
PrintWithdrawalsLoop:
	mov AX, [ESI]
	call WriteDec
	cmp ECX, 1
	je AddDeposits
	cmp EAX, 0
	je AddDeposits
	mov AL, ','
	call WriteChar
	mov AL, ' '
	call WriteChar
	add ESI, TYPE WORD
	dec ECX
	jmp PrintWithdrawalsLoop
	;--------------------------
	; all deposits to initial
	; balance value
	;
AddDeposits:
	movzx EAX, initialBal
	mov ECX, LENGTHOF deposits
	mov ESI, OFFSET deposits
AddDepositsLoop:
	add AX, [ESI]
	add ESI, TYPE WORD
	loop AddDepositsLoop
	;--------------------------
	; subtract withdrawals from
	; updated balance value
	;
AddWithdrawals:
	mov ECX, LENGTHOF withdrawals
	mov ESI, OFFSET withdrawals
AddWithdrawalsLoop:
	sub AX, [ESI]
	add ESI, TYPE WORD
	loop AddWithdrawalsLoop
	;-----------------------
	; update final balance
	; variable and print
	; details to screen
	;
    mov finalBal, AX
	call Crlf
    mov EDX, OFFSET balanceTitle
    call WriteString
    call WriteDec
    call Crlf
	;---------------------------------------------
    ; wait for user input before exiting program
    ;
    call WaitMsg
    exit
main endp
end main