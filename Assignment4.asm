TITLE Assignment4    (Assignment04.asm)

; Author: Benjamin Fridkis
; Course / Project ID Assignment #4        Date: 10/27/2017
; Description: Program to calculate and display composite numbers (up to 46 terms). 
;			   The user is prompted to enter the number of composites to display
;			   in the range of 1 to 400. Composites are then displayed to the user
;			   (with 10 numbers per output line).
;
; Implementation Note: This program is implemented using procedures that utilize
;					   both external and local parameters.

INCLUDE Irvine32.inc

UPPER_LIMIT			EQU <400>

.data
introduction1		BYTE "Composite Numbers    ", 0
introduction2		BYTE "Programmed by Benjamin Fridkis", 0
ecMessage1			BYTE "**EC1: Prints output aligned in vertical columns (left-justified).", 0
ecMessage2			BYTE "**EC3: Checks only agains prime divisors, storing each identified prime.", 0

inputInstructions1	BYTE "Enter the number of composite numbers you would like to see.", 0
inputInstructions2	BYTE "I'll accept orders for up to ", 0
inputInstructions3	BYTE " composites.", 0
inputUserPrompt1	BYTE "Enter the number of composite numbers to display [1 ..  ", 0
inputUserPrompt2	BYTE "]: ", 0
outOfRangeMessage	BYTE "Out of range. Try again.", 0
printPrompt			BYTE "Press enter to print results. NOTE: This will clear the screen.", 0
farewellMessage		BYTE "Results certified by Benjamin Fridkis. Goodbye.", 0
ALIGN 4

highEndOfRange		DWORD ?
currentValueToCheck DWORD 1
ALIGN 2
columnSpacingOffset	BYTE 0
outputRowNumber		BYTE 0
sequenceUpCounter	WORD 0				;Used for printing new line after every 5th term printed

.code
main PROC

call Clrscr
call Crlf

; Introduces the program
	push	OFFSET introduction1
	push	OFFSET introduction2
	push	OFFSET ecMessage1
	push	OFFSET ecMessage2
	push	OFFSET inputInstructions1
	push	OFFSET inputInstructions2
	push	OFFSET inputInstructions3
	call 	intro

; Gets the number of terms to print after validating user input
; is within the acceptable range (1 - <UPPER_LIMIT>).
; Returns user entered number of terms in EAX.
	push	OFFSET inputUserPrompt1
	push	OFFSET inputUserPrompt2
	push	OFFSET outOfRangeMessage
	call 	getUserData
	mov		highEndOfRange, eax							;Stores return value in memory

; Prints all composites with the user-defined range.
	push 	highEndOfRange								;Argument for showComposites
	call	showComposites
	
; Farewell Message
	push	OFFSET farewellMessage
	call	farewell
	
	exit	; exit to operating system
main ENDP


; ----------------------------------------------------------------------------
; 									intro
; Summary: Introduces program and author. States range of acceptable input.
; Uses: EDX
; Input Parameters: OFFSETs of intro strings (introduction1 & introduction2) 
;					OFFSETS of extra credit headers (ecMessage1 & ecMessage2)
;					OFFSETs of input instructions (inputInstructions[1-3])
; Local Parameters: none
; Outputs: Intro message
; Returns: none
;-----------------------------------------------------------------------------
intro PROC
	push	ebp
	mov		ebp, esp
	push 	edx
	
	mov		edx, [ebp + 32]
	call	WriteString									;"Composite Numbers    "
	mov		edx, [ebp + 28]
	call	WriteString									;"Programmed by Benjamin Fridkis"
	call	Crlf
	call	Crlf
	mov		edx, [ebp + 24]								;**EC1: Prints output aligned in vertical columns (left-justified)."
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 20]								;"**EC3: Checks only agains prime divisors, storing each identified prime."
	call	WriteString
	call	Crlf
	call	Crlf
	mov		edx, [ebp + 16]
	call	WriteString									;"Enter the number of composite numbers you would like to see."
	call	Crlf
	mov		edx, [ebp + 12]
	call	WriteString									;"I'll accept orders for up to "								
	mov		eax, UPPER_LIMIT
	call	WriteDec									;<UPPER_LIMIT>
	mov		edx, [ebp + 8]
	call	WriteString									;" composites."
	call	Crlf
	call	Crlf
	
	pop		edx
	pop		ebp
	
	ret 	24
intro ENDP

;--------------------------------------------------------------------------------
; 								getUserData
; Summary: Prompts user for input (number of composites to display).
;		   Passes input to validate sub-procedure to check for acceptable
;		   entry (value between 1 and 400).
; Uses: EAX, EDX
; Input Parameters: OFFSETs of user prompts (inputUserPrompt1 & inputUserPrompt2)
; Local Parameters: none 
; Outputs: Prompt message with possible error message.
; Returns: Returns user input in EAX.
;---------------------------------------------------------------------------------
getUserData PROC
	push	ebp
	mov		ebp, esp
	push 	edx

InputPrompt:	
	mov		edx, [ebp + 16]
	call	WriteString									;"Enter the number of composite numbers to display [1 ..  "
	mov		eax, UPPER_LIMIT
	call	WriteDec
	mov		edx, [ebp + 12]
	call	WriteString									;"]: "
	call	ReadDec
	
	push	eax											;Argument for call validate
	call	validate									;validate returns a 1 if user input is within range...
	cmp		ebx, 1										;...or a 0 if out of range in EBX.
	je		ValidInput									;If entry valid, jump over error block
	
	mov		edx, [ebp + 8]								;If entry invalid, output error message...
	call	WriteString									;...and reprompt user for entry.
	call	Crlf
	jmp		InputPrompt

ValidInput:
	pop		edx
	pop		ebp
	call	Crlf

	ret 	12
getUserData ENDP

;-----------------------------------------------------------------------------
; 								validate
; Summary: Sub-procedure of getUserData that checks input parameter for 
;		   validity based on an input range between 1 and <UPPER_LIMIT>.
; Uses: EAX, EBX
; Input Parameters: User input (highEndOfRange)
; Local Parameters: none
; Outputs: none
; Returns: Returns 1 if entry is valid or 0 if entry is invalid in EBX.
;-----------------------------------------------------------------------------
validate PROC
	push	ebp
	mov		ebp, esp
	
	cmp		DWORD PTR [ebp + 8], UPPER_LIMIT
	ja		Invalid
	cmp		DWORD PTR [ebp + 8], 1
	jb		Invalid
	jmp		Valid
	
Invalid:
	mov		ebx, 0
	jmp		Return
Valid:
	mov		ebx, 1
	
Return:
	pop		ebp

	ret 	4
validate ENDP

;-----------------------------------------------------------------------------
; 								showComposites
; Summary: Prints all composite numbers in the range given by 1 - userInput
;		   to the console output.
; Uses: EAX, EBX, EDX
; Input Parameters: User input (highEndOfRange)
; Local Parameters: Array of 160 DWORDs (to hold primes for divisibility 
;					check). 
;					DWORD to hold the current size of the local array.
; Outputs: Composite numbers in user-defined range, printed 10 numbers per
;		   per row, left-justified with at least 3 spaces between each 
;		   number.
; Returns: none
;-----------------------------------------------------------------------------
showComposites PROC
	push	ebp
	mov		ebp, esp
	push 	eax
	push	ebx
	push	edx
	sub		esp, 160									;Allocates the equivalent of a 80-WORD array...
	lea		esi, [ebp - 16]								;...and loads the starting address into esi...
														;...This array can store the maximum number of...
														;...primes between 1 and 400. Primes will be stored...
														;... as they are discovered and then used to determine 
														;...if subsequent numbers are prime, as any number that...
														;...is not divisible by a prime is itself a prime.
											
	sub		esp, 4										;Reserves space for DWORD to hold size of array.
	mov		DWORD PTR [ebp - 176], 0					;Sets the initial size of the array of primes to 0.

	mov		ecx, [ebp + 8]
	
	mov		edx, OFFSET printPrompt						
	call	WriteString									;"Press enter to print results. NOTE: This will clear the screen."
	call	ReadDec
	call	clrscr
L1:
	push	DWORD PTR [ebp - 176]						;Passes size of array
	lea		eax, [ebp - 18]								;Passes starting address of the second element...
	push	eax											;...of the primes array via EAX, since divisible by 1 check is unnecessary.
	push	currentValueToCheck							;Passes currentValueToCheck
	call	isComposite									;Returns 0 if not prime, or currentValueToCheck if...
														;...prime.
	cmp		ax, 0
	je		PrintComposite								;Jumps over block to add prime to primes array if not prime.
	mov		WORD PTR [esi], ax							;Adds value to primes array if prime.
	sub		esi, 2					
	add		DWORD PTR [ebp - 176], 1					;Increments size of array if prime is added.
	jmp		FinishL1

PrintComposite:
	mov		eax, currentValueToCheck
	call	printComposites

FinishL1:
	inc		currentValueToCheck
	mov		ebx, highEndOfRange
	cmp		currentValueToCheck, ebx
	ja		Finish										;Jumps to return once user-input high-end-of-range is reached
	loop	L1
Finish:	
	add		esp, 164									;Clean up local array and array size variable
	pop		edx											;Restore registers
	pop		ebx
	pop		eax
	pop		ebp

	ret 	4
showComposites ENDP

;-----------------------------------------------------------------------------
; 								isComposite
; Summary: Checks if an argument is a prime number by referencing an array of
;		   previously determined prime numbers. A value is divided by each of
;		   the previously determined prime numbers, and if none of the primes
;		   are a factor of the value, the value is deemed prime.
; Uses: EAX, EDX, ESI
; Input Parameters: Integer value to check for primeness.
;					Array of prime numbers already identified, excluding 1.
;					Size of array of prime numbers already identified.
; Local Parameters: none
; Outputs: none
; Returns: Input parameter unmodified if not prime, 0 if prime in EAX.
;-----------------------------------------------------------------------------
isComposite PROC
	push	ebp
	mov		ebp, esp
	push	esi
	push	edx
	
	mov		esi, [ebp + 12]								;Loads address of second element of primes array into esi
	mov		ecx, DWORD PTR [ebp + 16]					;Sets loop counter to size of primes array
	sub		ecx, 1										;(Subtracts 1 because divisible by 1 is not needed as a check.)
	cmp		DWORD PTR [ebp + 16], 1						;If the number to be checked is 1 or 2 (i.e. size of primes array is 2 or less)...
	jbe		ReturnValue									;...jumps over prime check and returns these values.
										
L1:
	mov		ax, [ebp + 8]								;Puts current value to check into ax
	cwd
	div		WORD PTR [esi]
	cmp		dx, 0
	je		Return0
	sub		esi, 2										;Iterate to next element of primes array
	loop	L1
	jmp		ReturnValue
Return0:
	mov		ax, 0
	jmp		Return
ReturnValue:
	mov		ax, [ebp + 8]
Return:
	pop		edx
	pop		esi
	pop		ebp
	
	ret		12
isComposite ENDP

; ----------------------------------------------------------------------------
; 								printComposites
; Summary: Prints composite numbers in user-defined range.
; Uses: EAX
; Input Parameters: none 
; Local Parameters: none
; Outputs: Composite numbers, 10 per line left-justified with at least 3
;		   spaces between each.
; Returns: none
;-----------------------------------------------------------------------------
printComposites PROC
	inc		sequenceUpCounter
	
	mov		dh, outputRowNumber							
	mov		dl, columnSpacingOffset
	call	Gotoxy										;Establishes column spacing for output
	call	WriteDec									;Prints Composite
	
	add		dl, 6										;Increments column spacing for next term
	mov		columnSpacingOffset, dl
	
	mov		ax, sequenceUpCounter						;Lines 337-343 are used to print a new line only after every...
	mov		bl, 10										;...10th term has printed (except in the case of the last term)...
	div		bl											;...and to reset the column offset variable after every tenth...
	cmp		ah, 0										;...term
	jne		Return
	mov		columnSpacingOffset, 0
	inc		outputRowNumber				
	cmp		ecx, 1										;Won't print newline or increment values if on last term of sequence
	je		Return							
	call	Crlf
Return:
	ret
printComposites ENDP
; ----------------------------------------------------------------------------
; 									farewell
; Summary: Prints farewell message.
; Uses: EDX
; Input Parameters: OFFSETs of farewell message (farewellMessage) 
; Local Parameters: none
; Outputs: farewell message
; Returns: none
;-----------------------------------------------------------------------------
farewell PROC
	push	ebp
	mov		ebp, esp
	push 	edx
	
	call	Crlf
	call	Crlf

	mov		edx, [ebp + 8]
	call	WriteString									;"Results certified by Benjamin Fridkis. Goodbye.", 0

	call	Crlf
	call	Crlf
	
	pop 	edx
	pop		ebp
	
	ret		4
farewell ENDP

END main