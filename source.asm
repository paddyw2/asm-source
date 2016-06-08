; Program template
; Author:
; Date:
; Program Description: 

include Irvine32.inc

.data
	; string variables used for constants
	msgTitle		BYTE "Assembly program to check Alphabet is Vowel or Constant", 0
	prompt			BYTE "Enter a letter: ", 0
	msgVowel		BYTE "Letter is Vowel", 0
	msgConstant		BYTE "Letter is Constant", 0
	msgIsDigit		BYTE "You entered a digit, please enter a letter", 0

.code
main proc
	mov EDX, OFFSET msgTitle	; moves the msgTitle variable to EDX using the memory address of the first character, ending with the null termination
	call WriteString			; this prints the message
	call Crlf					; write an end of line sequence to the console window		

		; display message on console for input
	MainFunction:
		mov EDX, OFFSET prompt		; moves prompt message to EDX using first characters memory address
		call WriteString			; writes to console window

		call ReadChar				; wait for single letter to be typed
		call WriteChar				; writes to screen
		call Crlf					; new line

		call IsDigit				; sets the zero flag if the AL register contains a digit value (ASCII value based)
		jz Digit					; jump if zero flat is set
	
		cmp AL, 'a'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'A'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'e'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'E'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'i'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'I'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'o'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'O'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'u'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		cmp AL, 'U'					; compare value of AL to a
		je Vowel					; if equal, go to Vowel

		mov EDX, OFFSET msgConstant	; if none of the above have been satisfied, it is a constant
		call WriteString			; write message to screen
		call Crlf					; write new line
		jmp Finish					; jump to finish program to skip other functions


	Vowel:
		mov EDX, OFFSET msgVowel	; move message to register
		call WriteString			; write to screen
		call Crlf
		jmp Finish					; jump to finish function


	Digit:
		mov EDX, OFFSET msgIsDigit	; display error message
		call WriteString			; write to screen
		call Crlf
		jmp MainFunction			; jump to finish

	Finish:
		call WaitMsg				; displays message and wait until user presses a key
		exit						; exits
		main endp					; ends main process

end main
