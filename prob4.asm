;---------------------------;
; Assignment 3              ;
; Problem 4                 ;
; Author: Patrick Withams   ;
; Date: 9/6/2015            ;
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
    bigEndian       BYTE    12h, 34h, 56h, 78h
    littleEndian    DWORD   ?
    titleMsg        BYTE    "Welcome to Big Endian, Little Endian!", 0
    bigMsg          BYTE    "Big Endian Storage: ", 0
    littleMsg       BYTE    "Little Endian Storage: ", 0

.code
main proc
    ;------------------------
    ; print welcome message
    ;
    mov EDX, OFFSET titleMsg                                    ; move titleMsg address to EDX
    call WriteString                                            ; print "Welcome to..." message to screen
    call Crlf                                                   ; print new line
    ;------------------------
    ; print big endian message
    ;
    mov EDX, OFFSET bigMsg                                      ; move titleMsg address to EDX
    call WriteString                                            ; print "Welcome to..." message to screen
    call Crlf                                                   ; print new line to screen
    ;--------------------------
    ; print bigEndian array to
    ; screen, and move each
    ; value to corresponding
    ; littleEndian position
    ;
    mov ESI, OFFSET bigEndian                                   ; move bigEndian starting address into ESI
    mov EBX, OFFSET littleEndian                                ; move littleEndian "first" (technical last) byte into EBX
    mov ECX, LENGTHOF bigEndian                                 ; set ECX (loop counter) to length of bigEndian
    mov EAX, 0                                                  ; clear EAX by setting to 0
PrintBig:
    mov AL, [ESI]                                               ; each loop, move current bigEndian element into AL
    call WriteHex                                               ; print element to screen in hex format
    call Crlf                                                   ; print new line
    mov [EBX], AL                                               ; move first byte of bigEndian into last byte of littleEndian
    add ESI, TYPE bigEndian                                     ; increment ESI address
    add EBX, TYPE BYTE                                          ; increment EBX address by a byte to move backwards
    loop PrintBig                                               ; repeat loop for length of bigEndian (dec ECX, loop if != 0)

    ;------------------------
    ; print little endian message
    ;
    mov EDX, OFFSET littleMsg                                   ; move littleMsg address to EDX
    call WriteString                                            ; print message to screen
    call Crlf                                                   ; print new line to screen
    ;--------------------------
    ; print littleEndian array
    ;
    mov EAX, littleEndian                                       ; move littleEndian value to EAX
    call WriteHex                                               ; print EAX value to screen in hex format
    call Crlf                                                   ; print new line

    ;---------------------------------------------
    ; wait for user input before exiting program
    ;
    call WaitMsg                                                ; print wait message and wait for user input
    exit
main endp
end main
