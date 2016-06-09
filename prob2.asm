; Working source file

include irvine32.inc

.data
   myArray		DWORD		0Fh, 1, 2, 10h, 5, 14h	
   revArray		DWORD		LENGTHOF myArray DUP(?)
   origMsg		BYTE		"Original Array: ", 0
   revMsg		BYTE		"Reversed Array: ", 0
   copyMsg		BYTE		"The original array, now copied from reversed array: ", 0

.code
main proc
	; print original array
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
	; reverse original array into revArray variable	
	mov ESI, OFFSET revArray
	mov ECX, LENGTHOF myArray
	mov EBX, ESI
	sub EBX, TYPE myArray
	ReverseArray:
		mov EAX, [EBX]
		mov [ESI], EAX
		add ESI, TYPE myArray
		sub EBX, TYPE myArray
		loop ReverseArray
	; print revArray to show reversed result
	mov EDX, OFFSET revMsg
	call WriteString
	call Crlf		
	mov ECX, LENGTHOF revArray
	mov ESI, OFFSET revArray
	PrintRevArray:
		mov EAX, [ESI]
		add ESI, TYPE revArray
		call WriteDec
		call Crlf
		loop PrintRevArray
	; if required, copy reversed array into original array memory so that myArray is now reversed
	mov ECX, LENGTHOF revArray
	mov ESI, OFFSET revArray
	mov EBX, OFFSET myArray
	UpdateOriginal:
		mov EAX, [ESI]
		mov [EBX], EAX
		add ESI, TYPE revArray
		add EBX, TYPE revArray
		loop UpdateOriginal
	; print myArray to show that original variable is now reversed	
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
	; wait for user input before exiting program
	call WaitMsg
	exit
main endp
end main
