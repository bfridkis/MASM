TITLE Assignment2    (Assignment02.asm)

; Author: Benjamin Fridkis
; Course / Project ID Assignment #2        Date: 10/5/2017
; Description: Program to calculate Fibonacci numbers (up to 46 terms). The user is
;			   prompted to enter his or her name, and then  the number of terms to 
;			   be calcualed (max 46). Terms are then displayed to the user.

INCLUDE Irvine32.inc

UPPER_LIMIT			EQU <46>

.data
introduction1		BYTE "Fibonacci Numbers", 0
introduction2		BYTE "Programmed by Benjamin Fridkis", 0
ecMessage1			BYTE "**EC1: Prints output aligned in vertical columns (left-justified).", 0
ecMessage2			BYTE "**EC2: Prints a second time in reverse order.", 0
userNamePrompt		BYTE "What's your name? ", 0
helloMessage		BYTE "Hello, ", 0
userName			BYTE 21 DUP(0)		;Maximum of 20 characters for the name input
inputInstructions1	BYTE "Enter the number of Fibonacci terms to be displayed.", 0
inputInstructions2	BYTE "Give the number as an integer in the range of [1 .. ", 0
inputInstructions3	BYTE "].", 0
inputUserPrompt		BYTE "How many Fibonacci terms do you want? ", 0
outOfRangeMessage1	BYTE "Out of range. Enter a number in [1 .. ", 0
outOfRangeMessage2	BYTE "].", 0
printPrompt			BYTE "Press enter to print results. NOTE: This will clear the screen.", 0
somethingIncredible BYTE "Now I will show you something incredible.", 0
reversePrintMessage BYTE "Printed in reverse!", 0
certMessage			BYTE "Results certified by Benjamin Fridkis.", 0
farewellMessage		BYTE "Goodbye, ", 0
ALIGN 4

numberOfTerms		BYTE ?
columnSpacingOffset	BYTE 14
outputRowNumber		BYTE 0
ALIGN 1
sequenceUpCounter	WORD 1				;Used for printing new line after every 5th term printed
ALIGN 2
numberInSeries		DWORD 1
nextNumberInSeries	DWORD 1

.code
main PROC

call Clrscr
call CrLf

; Introduces the program
	mov		edx, OFFSET introduction1
	call	WriteString									;"Fibonacci Numbers"
	call	CrLf
	mov		edx, OFFSET introduction2
	call	WriteString									;"Programmed by Benjamin Fridkis"
	call	CrLf
	call	CrLf
	mov		edx, OFFSET ecMessage1						;**EC1: Prints output aligned in vertical columns (left-justified)."
	call	WriteString
	call	CrLf
	mov		edx, OFFSET ecMessage2						;**EC2: Prints a second time in reverse order."
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET userNamePrompt
	call	WriteString									;"What's your name? "
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	call	ReadString
	call	CrLf
	mov		edx, OFFSET helloMessage
	call	WriteString									;"Hello, "
	mov		edx, OFFSET userName
	call	WriteString									;userName
	call	CrLf
	call	CrLf

;Prompts user for number of Fibonacci Numbers to display and calculate.
	mov		edx, OFFSET inputInstructions1
	call	WriteString									;"Enter the number of Fibonacci terms to be displayed."
	call	CrLf
	mov		edx, OFFSET inputInstructions2	
	call	WriteString									;"Give the number as an integer in the range of [1 .. "
	mov		eax, UPPER_LIMIT
	call	WriteDec									;<UPPER_LIMIT>
	mov		edx, OFFSET inputInstructions3
	call	WriteString									;".]"
	call	CrLf
	call	CrLf

;Gets user data
InputPrompt:
	mov		edx, OFFSET inputUserPrompt	
	call	WriteString									;"How many Fibonacci terms do you want? "
	call	ReadDec
	mov		numberOfTerms, al
	cmp		eax, UPPER_LIMIT
	ja		InputOutOfBounds							;Short-circuit evaluation if input is > 46
	cmp		eax, 1
	jae		ContinuePrompt								;Jumps over out-of-bounds error message if input in range
InputOutOfBounds:
	call	CrLf
	mov		edx, OFFSET outOfRangeMessage1
	call	WriteString									;"Out of range. Enter a number in [1 .. "
	mov		eax, UPPER_LIMIT
	call	WriteDec									;"<UPPER_LIMIT>"
	mov		edx, OFFSET outOfRangeMessage2
	call	WriteString									;"]."
	call	CrLf
	call	CrLf
	jmp		InputPrompt									;Re-prompts user after displaying error message
ContinuePrompt:
	call	CrLf
	mov		edx, OFFSET printPrompt
	call	WriteString									;"Press enter to print results. NOTE: This will clear the screen."
	call	ReadDec

; Calculates and displays the fibonacci sequence.
; Each term is seperated by at least 5 spaces and left-justified in columns.
Calculations:	
	mov		al, numberOfTerms							
	sub		al, 1										
	movzx	ecx, al										;Sets loop counter to user input number of terms - 1 (first term is printed outside the loop)
	call	clrscr
	mov		eax, numberInSeries
	call	WriteDec									;Prints first term of sequence...

	cmp		numberOfTerms, 1
	je		FinishL1									;If only 1 term is requested, jump over calculations
	
L1:
	inc		sequenceUpCounter
	
	mov		dh, outputRowNumber							
	mov		dl, columnSpacingOffset
	call	Gotoxy										;Establishes column spacing for output

	mov		eax, nextNumberInSeries						;Prints next term			
	call	WriteDec
	
	add		dl, 14										;Increments column spacing for next term
	mov		columnSpacingOffset, dl
	
	mov		ax, sequenceUpCounter						;Lines 126-135 are used to print a new line only after every...
	mov		bl, 5										;...5th term has printed (except in the case of the last term)...
	div		bl											;...and to reset the column offset variable after every fifth...
	cmp		ah, 0										;...term
	jne		IncrementSeries
	mov		columnSpacingOffset, 0
	inc		outputRowNumber				
	cmp		ecx, 1										;Won't print newline or increment values if on last term of sequence
	je		FinishL1							
	call	CrLf
IncrementSeries:
	cmp		ecx, 1										;Won't increment values if on last term of sequence
	je		FinishL1
	mov		eax, numberInSeries							;Lines 143-147 are responsible for generating the next item in...
	add		eax, nextNumberInSeries						;...in sequence and shifting the values upward in the data members.
	mov		ebx, nextNumberInSeries						
	mov		numberInSeries, ebx							;numberInSeries becomes nextNumberInSeries
	mov		nextNumberInSeries, eax						;nextNumberInSeries becomes the result of numberInSeries minus nextNumberInSeries.
	Loop	L1
FinishL1:
	call	CrLf
	call	CrLf
	mov		edx, OFFSET somethingIncredible
	call	WriteString									;Now I will show you something incredible.
	call	CrLf
	call	CrLf
	mov		edx, OFFSET printPrompt
	call	WriteString									;"Press enter to print results. NOTE: This will clear the screen."
	call	ReadDec
	call	clrscr
	mov		edx, OFFSET reversePrintMessage
	call	WriteString									;"Printed in reverse!"
	call	CrLf
	call	CrLf

; Calculates and displays the fibonacci sequence in reverse.
; Each term is seperated by at least 5 spaces and left-justified in columns.
	mov		eax, nextNumberInSeries						;These next 4 instructions swap the final results...
	mov		ebx, numberInSeries
	mov		numberInSeries, eax							;... of the forward-printing sequence...
	mov		nextNumberInSeries, ebx						;...so the reverse loop can begin at the final term.

	mov		eax, numberInSeries
	call	WriteDec									;Prints first term of sequence...

	cmp		numberOfTerms, 1
	je		FinishL2									;If only 1 term is requested, jump over calculations
	
	mov		outputRowNumber, 2							;Reset the x-coordinant spacing variable
	mov		columnSpacingOffset, 14						;Reset the y-coordinant spacing variable
	mov		sequenceUpCounter, 1						;Reset the sequence term counter

	mov		al, numberOfTerms							
	sub		al, 1										
	movzx	ecx, al										;Sets loop counter to user input number of terms - 1 (first term is printed outside the loop)
	
L2:
	inc		sequenceUpCounter
	
	mov		dh, outputRowNumber							
	mov		dl, columnSpacingOffset
	call	Gotoxy										;Establishes column spacing for output

	mov		eax, nextNumberInSeries						;Prints next term			
	call	WriteDec
	
	add		dl, 14										;Increments column spacing for next term
	mov		columnSpacingOffset, dl
	
	mov		ax, sequenceUpCounter						;Lines 189-198 are used to print a new line only after every...
	mov		bl, 5										;...5th term has printed (except in the case of the last term)...
	div		bl											;...and to reset the column offset variable after every fifth...
	cmp		ah, 0										;...term
	jne		DecrementReverseSeries
	mov		columnSpacingOffset, 0
	inc		outputRowNumber				
	cmp		ecx, 1										;Won't print newline or decrement values if on last term of sequence
	je		FinishL2							
	call	CrLf
DecrementReverseSeries:
	cmp		ecx, 1										;Won't decrement values if on last term of sequence
	je		FinishL2
	mov		eax, numberInSeries							;Lines 206-210 are responsible for generating the next item...						
	sub		eax, nextNumberInSeries						;...in sequence and shifting the values downward in the data members.
	mov		ebx, nextNumberInSeries						
	mov		numberInSeries, ebx							;numberInSeries becomes nextNumberInSeries
	mov		nextNumberInSeries, eax						;nextNumberInSeries becomes the result of numberInSeries minus nextNumberInSeries.
	Loop	L2	
FinishL2:
	
;Display farewell message
Farewell:
	call	CrLf
	call	CrLf
	mov		edx, OFFSET certMessage
	call	WriteString									;"Results certified by Benjamin Fridkis."
	call	CrLf					
	mov		edx, OFFSET farewellMessage
	call	WriteString									;"Goodbye, "
	mov		edx, OFFSET userName
	call	WriteString									;"<userName>"
	call	CrLf
	call	CrLf
	
	exit	; exit to operating system
main ENDP

END main