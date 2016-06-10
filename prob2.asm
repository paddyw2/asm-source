;---------------------------;
; Assignment 3				;
; Problem 2					;
; Author: Patrick Withams	;
; Date: 9/6/2015			;
;---------------------------;

include irvine32.inc

.data
	;-----------------------------------------------------
	; myArray is the variable that will be reversed
	; origMsg and revMsg are strings that are displayed
	; before and after the array is reversed
	;
	myArray		DWORD		0Fh, 1, 2, 10h, 5, 14h	
	origMsg		BYTE		"Original Array: ", 0
	revMsg		BYTE		"Original Array, now reversed: ", 0

.code
main proc
    ;-----------------------
    ; print original array
	;
	mov EDX, OFFSET origMsg						; move "Original Array: " message address to EDX 
	call WriteString							; print to screen
	call Crlf
	mov ECX, LENGTHOF myArray					; set ECX register (decremented each loop) to length of array
	mov ESI, OFFSET myArray						; set ESI to the first memory address of array
PrintOrigArray:
    mov EAX, [ESI]								; move element value into EAX
    add ESI, TYPE myArray						; move ESI address to next element by adding array type (1 or 2 etc)
    call WriteDec								; write EAX to screen
    call Crlf
    loop PrintOrigArray
    ;-----------------------------------
    ; push each element onto the stack 
    ;
	mov ESI, OFFSET myArray						; set ESI to the first memory address of array
	mov ECX, LENGTHOF myArray					; set ECX (loop counter) to length of array
PushArray:
    push [ESI]									; for each element address, push the value onto the stack
    add ESI, TYPE myArray
    loop PushArray
    ;---------------------------------
    ; pop each element off the stack 
    ;
    mov ESI, OFFSET myArray						; set ESI to the first memory address of array
	mov ECX, LENGTHOF myArray					; set ECX (loop counter) to length of array
PopArray:
    pop EAX										; for each loop, pop stack value into EAX
    mov [ESI], EAX								; then move EAX value into each array element 
    add ESI, TYPE myArray						; increment array element address
    loop PopArray
    ;---------------------------------------
    ; print myArray to show it is reversed 
    ;
	mov EDX, OFFSET revMsg						; move "Original Array, now reversed: " message to EDX
	call WriteString							; print message to screen
	call Crlf	
	mov ECX, LENGTHOF myArray					; set ECX (loop counter) to length of array
	mov ESI, OFFSET myArray						; set ESI to first memory address of array
PrintCopyArray:
    mov EAX, [ESI]								; for each loop, move element value into EAX
    add ESI, TYPE myArray						; increment address value to next element
    call WriteDec								; write EAX value to screen
    call Crlf
    loop PrintCopyArray
    ;---------------------------------------------
    ; wait for user input before exiting program
    ;
    call WaitMsg
	exit
main endp
end main
