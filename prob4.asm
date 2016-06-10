;---------------------------;
; Assignment 3				;
; Problem 4					;
; Author: Patrick Withams	;
; Date: 9/6/2015			;
;---------------------------;

include irvine32.inc

.data
	;-----------------------------------------------------
	; bigEndian contains original storage format
	; littleEndian stores the same data, but reversed (little
	; endian format)
	; titleMsg, bigMsg, and littleMsg are used to display
	; text info on the screen
	;
	bigEndian		BYTE	12h, 34h, 56h, 78h
	littleEndian	DWORD	4 DUP(?)
	titleMsg		BYTE	"Welcome to Big Endian, Little Endian!", 0
	bigMsg			BYTE	"Big Endian Storage: ", 0
	littleMsg		BYTE	"Little Endian Storage: ", 0

.code
main proc
	;------------------------
	; print welcome message
	;
	mov EDX, OFFSET titleMsg									; move titleMsg address to EDX
	call WriteString											; print "Welcome to..." message to screen
	call Crlf													; print new line
	;------------------------
	; print big endian message
	;
	mov EDX, OFFSET bigMsg										; move titleMsg address to EDX
	call WriteString											; print "Welcome to..." message to screen
	call Crlf
	;--------------------------
	; print bigEndian array to
	; screen, and push values
	; to stack
	;
	mov ESI, OFFSET bigEndian									; move bigEndian starting address into ESI
	mov ECX, LENGTHOF bigEndian									; set ECX (loop counter) to length of bigEndian
	mov EAX, 0													; clear EAX by setting to 0
PrintBig:
	mov AL, [ESI]												; each loop, move current bigEndian element into AL
	call WriteHex												; print element to screen in hex format
	push EAX													; push array element to stack
	call Crlf													; print new line
	add ESI, TYPE bigEndian										; increment ESI address
	loop PrintBig
	;-----------------------------------
	; convert bigEndian format to
	; littleEndian from stack
	;
	mov ESI, OFFSET littleEndian
	mov ECX, LENGTHOF littleEndian
ConvertEndian:
	pop EAX														; each loop, pop top stack value into EAX
	mov [ESI], EAX												; move eax value into current address position	
	add ESI, TYPE littleEndian									; increment address value to next array element
	loop ConvertEndian
	;------------------------
	; print little endian message
	;
	mov EDX, OFFSET littleMsg									; move littleMsg address to EDX
	call WriteString											; print message to screen
	call Crlf
	;--------------------------
	; print littleEndian array
	;
	mov ESI, OFFSET littleEndian	
	mov ECX, LENGTHOF littleEndian
PrintLittle:
	mov EAX, [ESI]												; each loop, move current littleEndian element into AL
	call WriteHex												; print element to screen in hex format
	call Crlf													; print new line
	add ESI, TYPE littleEndian									; increment ESI address
	loop PrintLittle
	;---------------------------------------------
    ; wait for user input before exiting program
    ;
    call WaitMsg
	exit
main endp
end main