; Working source file

include irvine32.inc

.data
   myArray		DWORD		0Fh, 1, 2, 10h, 5, 14h	
   origMsg		BYTE		"Original Array: ", 0
   revMsg		BYTE		"Reversed Array: ", 0
   copyMsg		BYTE		"The original array, now copied from reversed array: ", 0

.code
main proc
    ;----------------------;
    ; print original array ;
    ;----------------------;
	mov EDX, OFFSET origMsg
	call WriteString
	call Crlf
	mov ECX, LENGTHOF myArray
	mov ESI, OFFSET myArray
PrintOrigArray:
    mov EAX, [ESI]
    add ESI, TYPE myArray
    call WriteDec
    call Crlf
    loop PrintOrigArray
    ;----------------------------------;
    ; push each element onto the stack ; 
    ;----------------------------------;
	mov ESI, OFFSET myArray 
	mov ECX, LENGTHOF myArray
PushArray:
    push [ESI]
    add ESI, TYPE myArray
    sub EBX, TYPE myArray
    loop ReverseArray
    ;--------------------------------;
    ; pop each element off the stack ; 
    ;--------------------------------;
    mov ESI, OFFSET myArray
    mov ECX, LENGTHOF myArray
PopArray:
    pop EAX
    mov [ESI], EAX
    add ESI, TYPE myArray
    loop PopArray
    ;-----------------------------------------------;
    ; print myArray to show that it is now reversed ; 
    ;-----------------------------------------------;
	mov EDX, OFFSET copyMsg
	call WriteString
	call Crlf	
	mov ECX, LENGTHOF myArray
	mov ESI, OFFSET myArray
PrintCopyArray:
    mov EAX, [ESI]
    add ESI, TYPE myArray
    call WriteDec
    call Crlf
    loop PrintCopyArray
    ;--------------------------------------------;
    ; wait for user input before exiting program ;
    ;--------------------------------------------;
    call WaitMsg
	exit
main endp
end main
