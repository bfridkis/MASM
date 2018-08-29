TITLE Assignment1    (Assignment01.asm)

; Author: Benjamin Fridkis
; Course / Project ID Assignment #1        Date: 9/22/2017
; Description: Program to prompt user for two numbers, then return the sum,
;			   difference, product, and quotient/remainder of the two numbers.
;			   Program loops until the user indicates to quit (extra credit)
;			   and re-prompts the user for inputs if input 2 is not less than
;			   input 1 (extra credit). The quotient is also provided as a
;			   floating point number rounded to the nearest .001 (extra credit).
;			   The following resource aided in achieving the result of 
;			   rounding the floating point to the nearest .001:
;			   https://stackoverflow.com/questions/23358537/assembly-round-floating-point-number-to-001-precision-toward-%E2%88%9E

INCLUDE Irvine32.inc

.data
introduction		BYTE "Assignment1 by Benjamin Fridkis", 0
ecMessage1			BYTE "**EC1: Program loops until user quits.", 0
ecMessage2			BYTE "       (User quits by pressing enter with no input.)", 0
ecMessage3			BYTE "**EC2: Program verifies second number less than first.", 0
ecMessage4			BYTE "**EC3: Program displays quotient result as a floating point number,", 0
ecMessage5			BYTE "       rounded to the nearest .001.", 0
userInstructions1a	BYTE "Enter 2 numbers, and I'll show you the sum, difference, ", 0
userInstructions1b	BYTE "product, quotient, remainder, and floating-point quotient.", 0
quitInstructions	BYTE "Press enter with no input to quit.", 0
userInstructions2	BYTE "(An entry greater than 2^32 - 1 will also cause the program to quit.)", 0
userInput1			DWORD ?
userInput2			DWORD ?
overflowMessage		BYTE "Input values too large; result overflow.", 0
divby0ErrorMessage	BYTE "Cannot divide by 0.", 0
input2TooBig		BYTE "Input 2 must be smaller than input 1. Please try again.", 0

sum					DWORD ?
difference			DWORD ?
product				DWORD ?
quotient			DWORD ?
remainder			DWORD ?

thousand			WORD 1000				; Needed for EC3. See FloatingPointCalculation below.

firstNumberHeader	BYTE "First Number: ", 0
secondNumberHeader	BYTE "Second Number: ", 0
remainderHeader		BYTE " remainder ", 0
floatingPointHeader BYTE "Floating Point Quotient (Extra Credit): ", 0

sumSymbol			BYTE " + ", 0
differenceSymbol	BYTE " - ", 0
productSymbol		BYTE " * ", 0
quotientSymbol		BYTE " / ", 0
equalsSymbol		BYTE " = ", 0

goodbyeMessage		BYTE "Goodbye!", 0

.code
main PROC

call Clrscr
call CrLf

; Clear general purpose registers used for calculations.
	mov		eax, 0
	mov		ebx, 0

; Introduces the programs authors and states extra credit options pursued.
	mov		edx, OFFSET introduction		;Setup for call to WriteString
	call	WriteString						;"Assignment1 by Benjamin Fridkis"
	call	CrLf
	mov		edx, OFFSET ecMessage1			
	call	WriteString						;"**EC1: Program loops until user quits."
	call	CrLf
	mov		edx, OFFSET ecMessage2
	call	WriteString						;"		 (User quits by pressing enter with no input.)"
	call	CrLf
	mov		edx, OFFSET ecMessage3			
	call	WriteString						;"**EC2: Program verifies second number less than first."
	call	CrLf
	mov		edx, OFFSET ecMessage4			
	call	WriteString						;"**EC3: Program displays quotient result as a floating point number,"
	call	CrLf
	mov		edx, OFFSET ecMessage5			
	call	WriteString						;"       rounded to the nearest .001."
	call	CrLf
	call	CrLf

; Prompts user for input, then stores input. If entry is non-numeric, program quits (extra credit).
; If entry 2 is not less than entry 1, reprompts user for entries (extra credit).
InputPrompt:
	mov		edx, OFFSET userInstructions1a
	call	WriteString						;"Enter 2 numbers, and I'll show you the sum, difference, "
	call	CrLf
	mov		edx, OFFSET userInstructions1b
	call	WriteString						;"product, quotient, remainder, and floating-point quotient."
	call	CrLf
	call	CrLf
	mov		edx, OFFSET quitInstructions
	call	WriteString						;"Press enter with no input to quit."
	call	CrLf
	mov		edx, OFFSET userInstructions2
	call	WriteString						;"(An entry greater than 2^32 - 1 will also cause the program to quit.)"
	call	CrLf
	call	CrLf
	mov		edx, OFFSET firstNumberHeader
	call	WriteString						;"First Number: "
	call	ReadDec							;Read entry 1
	jc		Quit							;Quits if entry is NULL (ReadDec sets carry flag if entry is NULL)
	mov		userInput1, eax
	mov		edx, OFFSET secondNumberHeader
	call	WriteString						;"Second Number: "
	call	ReadDec							;Read entry 2
	jc		Quit							;Quits if entry is NULL (ReadDec sets carry flag if entry is NULL)
	mov		userInput2, eax
	cmp		eax, userInput1
	jnb		Input2NotBelow					;If entry 2 is not below entry 1, jumps to error message block
	call	CrLf
	jmp		Calculations
Input2NotBelow:
	call	CrLf
	mov		edx, OFFSET input2TooBig		
	call	WriteString						;"Input 2 must be smaller than input 1. Please try again."
	call	CrLf
	call	CrLf
	jmp		InputPrompt						;Repromts user for new entrys

Calculations:
; Calculates and displays sum of integers.
	mov		ebx, userInput1
	mov		sum, ebx
	add		sum, eax
	mov		eax, userInput1
	call	WriteDec						;userInput1
	mov		edx, OFFSET sumSymbol		
	call	WriteString						;" + "
	mov		eax, userInput2
	call	WriteDec						;userInput2
	mov		edx, OFFSET equalsSymbol
	call	WriteString						;" = "
	mov		eax, sum	
	call	WriteDec						;sum
	call	CrLf

; Calculates and displays difference of integers (Input 1 - Input 2).
	mov		difference, ebx
	mov		eax, userInput2
	sub		difference, eax
	mov		eax, userInput1
	call	WriteDec						;userInput1
	mov		edx, OFFSET differenceSymbol		
	call	WriteString						;" - "
	mov		eax, userInput2
	call	WriteDec						;userInput2
	mov		edx, OFFSET equalsSymbol
	call	WriteString						;" = "
	mov		eax, difference	
	call	WriteDec						;difference
	call	CrLf

; Calculates and displays product of integers.
	mov		eax, userInput2
	mul		userInput1
	mov		product, eax
	jc		Overflow						; Jumps to overflow block and prints overflow message if necessary
	mov		eax, userInput1
	call	WriteDec						;userInput1
	mov		edx, OFFSET productSymbol		
	call	WriteString						;" * "
	mov		eax, userInput2
	call	WriteDec						;userInput2
	mov		edx, OFFSET equalsSymbol
	call	WriteString						;" = "
	mov		eax, product	
	call	WriteDec						;product
	call	CrLf
	jmp		Division
;Conditional block in to inform user of a product overflow
	Overflow:				
	mov		edx, OFFSET overflowMessage
	call	WriteString						;"Input values too large; result overflow."
	call	CrLf

; Calculates and displays quotient and remainder of integers (Input 1 / Input 2).
Division:
	cdq
	mov		eax, userInput1
	mov		ebx, userInput2
	cmp		ebx, 0					
	je		DivBy0Error						;Jumps to divide by 0 error message block if necessary
	div		ebx
	mov		quotient, eax
	mov		remainder, edx
	mov		eax, userInput1
	call	WriteDec						;userInput1
	mov		edx, OFFSET quotientSymbol		
	call	WriteString						;" / "
	mov		eax, userInput2
	call	WriteDec						;userInput2
	mov		edx, OFFSET equalsSymbol
	call	WriteString						;" = "
	mov		eax, quotient	
	call	WriteDec						;quotient
	mov		edx, OFFSET remainderHeader	
	call	WriteString						;" remainder "
	mov		eax, remainder
	call	WriteDec						;remainder
	call	CrLf
	call	CrLf
	jmp		FloatingPointCalculation
DivBy0Error:
	mov		edx, OFFSET divBy0ErrorMessage
	call	WriteString						;"Cannot divide by 0."
	call	CrLf
	call	CrLf

; Calculates and displays quotient and remainder of integers (Input 1 / Input 2)
; in floading point format (extra credit).
FloatingPointCalculation:
	finit									; Initializes the FPU.
	fild	userInput1
	fidiv	userInput2
	fimul	thousand						; Multiplies by 1000.
	frndint									; Rounds to nearest integer value.
	fidiv	thousand						; Divides by 1000, effectively rounding to nearest .001.
	mov		edx, OFFSET floatingPointHeader
	call	WriteString						;"Floating Point Quotient (Extra Credit): "			
	call	writefloat						;ST(0) is written to output
	call	CrLf
	call	CrLf
	jmp		InputPrompt

Quit:
	exit									; exit to operating system
main ENDP

END main
