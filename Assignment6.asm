TITLE Assignment6    (Assignment06.asm)

; Author: Benjamin Fridkis
; Course / Project ID Assignment #6        Date: 11/20/2017
; Description: Program prompts user for 10 unsigned integers, converting each string input into
;			   an integer and storing in an array. The values are then each in turn converted back
;			   to a string and then displayed to the user. A sum and an average of the values is
;			   also displayed to the user.
;
; Implementation Note: This program is implemented using procedures that utilize
;					   both external and local parameters.

INCLUDE Irvine32.inc

getString MACRO offsetOfInputInstruction, offsetOfInputDestination	;Macro to display a prompt to user...
	push 	ecx														;...and save a user-entered string to memory
	push	edx
	mov		edx, offsetOfInputInstruction
	call	WriteString
	mov		edx, offsetOfInputDestination
	mov		ecx, 12
	call	ReadString
	pop		edx
	pop		ecx
ENDM

mReprompt MACRO offsetOfInputDestination
	push	edx
	push	ecx
	mov		edx, offsetOfInputDestination
	mov		ecx, 12
	call	ReadString
	pop		ecx
	pop		edx
ENDM

displayString MACRO offsetOfStringToDisplay
	push	edx
	mov		edx, offsetOfStringToDisplay
	call	WriteString
	pop		edx
ENDM
	
.data
introduction1			BYTE "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
introduction2			BYTE "Written by: Benjamin Fridkis", 0
introduction3			BYTE "Please provide 10 unsigned decimal integers.", 0
introduction4			BYTE "Each number needs to be small enough to fit inside a 32 bit register.", 0
introduction5			BYTE "After you have finished inputting the raw numbers I will display a list.", 0
introduction6			BYTE "of the integers, their sum, and their average value.", 0
inputInstruction		BYTE "Please enter an unsigned number: ", 0
invalidEntryMessage1	BYTE "ERROR: You did not enter an unsigned number or your number was too big.", 0
invalidEntryMessage2	BYTE "Please try again: ", 0
numberPrintBackMessage	BYTE "You entered the following numbers: ", 0
sumMessage				BYTE "The sum of these numbers is: ", 0
averageMessage			BYTE "The (truncated) average is: ", 0
farewellMessage			BYTE "Thanks for playing!", 0
userStringEntry			BYTE 12 DUP(?)			;Max unsigned 32 bit number is 4294967295... 
												;...so 10 characters needed at most (plus 1 for 0 terminator)...
												;...There is one additional character to detect if more than...
												;...10 digits total are entered via the Irvine ReadString procedure
numericOutputString		BYTE 11 DUP(0)
userNumericEntries		DWORD 10 DUP(?)

.code
main PROC

call Clrscr
call Crlf

; Introduces the program
	push	OFFSET introduction1
	push	OFFSET introduction2
	push	OFFSET introduction3
	push	OFFSET introduction4
	push	OFFSET introduction5
	push	OFFSET introduction6
	call 	intro
	
; Calls readVal to prompt user for 10 unsigned numeric entries...
; ...and stores each in an array of DWORDS (userNumericEntries)
	push	OFFSET userNumericEntries
	push	OFFSET inputInstruction
	push	OFFSET userStringEntry
	push	OFFSET invalidEntryMessage1
	push	OFFSET invalidEntryMessage2
	call	readVal
	
; Converts each numeric entry in userNumericEntries to a string and...
; ...prints.
	push	OFFSET numericOutputString
	push	OFFSET userNumericEntries
	push	OFFSET numberPrintBackMessage
	call	printValues

; Calculates and displays the sum and average of the user entries
	push	OFFSET sumMessage
	push	OFFSET averageMessage
	push	OFFSET userNumericEntries
	push	OFFSET numericOutputString
	call	calculateAndDisplaySumAndAverage

; Display farwell message
	call	Crlf
	call	Crlf
	mov		edx, OFFSET farewellMessage
	call	WriteString
	call	Crlf
	call	Crlf
	
	exit	; exit to operating system
main ENDP
	
; ----------------------------------------------------------------------------
; 									intro
; Summary: Introduces program and author.
; Uses: EDX
; Input Parameters: OFFSETs of intro strings (introduction1, introduction2,
;											  introduction3, introduction4,
;											  introduction5, and introduction6.) 
; Local Parameters: none
; Outputs: Intro message
; Returns: none
;-----------------------------------------------------------------------------
intro PROC
	push	ebp
	mov		ebp, esp
	push 	edx
	
	mov		edx, [ebp + 28]
	call	WriteString									;"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures"
	call	Crlf
	mov		edx, [ebp + 24]
	call	WriteString									;"Written by: Benjamin Fridkis"
	call	Crlf
	call	Crlf
	mov		edx, [ebp + 20]								;"Please provide 10 unsigned decimal integers."
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 16]								;"Each number needs to be small enough to fit inside a 32 bit register."
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 12]								;"After you have finished inputting the raw numbers I will display a list."
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 8]								;"of the integers, their sum, and their average value."
	call	WriteString
	call	Crlf
	call	Crlf
	
	pop		edx
	pop		ebp
	
	ret 	24
intro ENDP

;--------------------------------------------------------------------------------
; 								readVal
; Summary: Prompts user 10 times to enter unsigned numbers < 4294967296
;		   (so as to fit in a 32-bit register). Converts string entry to numberic
;		   value. Checks entry for validity, reprompts user if entry contains
;		   alpha characters or is too large to fit in a 32-bit register.
; Uses: EDX, EBX, ECX, EDI
; Input Parameters: OFFSET of userNumericEntries
;					OFFSET of inputInstruction
;					OFFSET of userStringEntry
;					OFFSET of invalidEntryMessage1
;					OFFSET of invalidEntryMessage2
; Local Parameters: DWORD to hold converted value. The OFFSET of this local variable 
;						is passed to the stringToNumeric procedure.
; Outputs: Prompt message with possible error message. Stores user's input in
;		   request variable.
; Returns: none
;---------------------------------------------------------------------------------
readVal PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edi
	sub		esp, 8							;[ebp - 16] = DWORD to store number after string-to-number...
											;...conversion. Will hold -1 if string entry was invalid.
											;[ebp - 20] = DWORD flag to indicate an invalid entry (1 = valid, 0 = invalid)
	
	mov		ecx, 10
	mov		edi, 0							;Start index offset at 0 (to be incremented by TYPE DWORD after each entry).
	getString		[ebp + 20], [ebp + 16]
GetUserInputs:											
	cmp		eax, 10
	ja		InvalidEntry					;After the macro is called, eax contains the...
											;...number of characters entered by the user. If...
											;...more than 10 characters are entered this indicates...
											;...a number too large for a 32-bit integer (or alpha-...
											;...characters and numbers in excess of 10).
	cmp		eax, 0							;No value entered
	je		InvalidEntry
	
	lea		ebx, [ebp - 16]					;Lines 148-151 load the effective addresses of the local...
	mov		[ebp - 16], ebx					;...variables back into the variables memory location so...
	lea		ebx, [ebp - 20]					;...these can be passed to the stringToNumeric procedure which...
	mov		[ebp - 20], ebx					;...will update the values stored at these memory locations.
	
	push	[ebp - 16]
	push	[ebp - 20]
	push	[ebp + 16]
	call	stringToNumeric

	mov		eax, [ebp - 20]					;If status flag is 0, jump to InvalidEntry and print error message.
	cmp		eax, 0
	je		InvalidEntry
	mov		eax, [ebp - 16]					;If entry is valid, move value into the appropriate array index location									
	mov		ebx, [ebp + 24]
	mov		[ebx + edi], eax
	add		edi, 4							;Increment the index counter by TYPE DWORD
	cmp		ecx, 1
	je		FinishLoop						;Doesn't prompt again after last prompt
	getString		[ebp + 20], [ebp + 16]
	jmp		FinishLoop
InvalidEntry:
	mov		edx, [ebp + 12]
	call	WriteString						;"ERROR: You did not enter an unsigned number or your number was too big."
	call	Crlf
	mov		edx, [ebp + 8]
	call	WriteString						;"Please try again: "
	mReprompt		[ebp + 16]
	inc		ecx								;Increment loop counter because another entry is needed as the current...
FinishLoop:									;...is invalid.
	dec		ecx
	cmp		ecx, 0
	ja		GetUserInputs									
	
	add		esp, 8
	pop		edi
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	
	ret		20
readVal ENDP

;--------------------------------------------------------------------------------
; 								writeVal
; Summary: Converts a numeric value to a string and displays on console.
;		   (Uses sub-procedure numericToString for the conversion.)
; Uses: None
; Input Parameters: DWORD value to convert
;					OFFSET of string to hold converted number
; Local Parameters: None
; Outputs: Prompt message with possible error message. Stores user's input in
;		   request variable.
; Returns: none
;---------------------------------------------------------------------------------
WriteVal PROC
	push	ebp
	mov		ebp, esp

	push	[ebp + 8]
	push	[ebp + 12]
	call	numericToString

	displayString		[ebp + 8]				;Macro to print the string

	pop		ebp
	
	ret		8
writeVal ENDP

;--------------------------------------------------------------------------------------
; 								stringToNumeric
; Summary: Converts the string in userStringEntry to a numeric value and stores
;		   the value in the input parameter memory location. Returns a 0
;		   or a 1 in the second input parameter memory location.
; Uses: EAX, EBX, ECX, EDX, ESI
; Input Parameters: EFFECTIVE ADDRESS of DWORD to hold converted string value
;					EFFECTIVE ADDRESS of DWORD for input status flag 
;						-(Returns 1 if valid, 0 if invalid)
;					DWORD for OFFSET of userStringEntry
; Local Parameters: DWORD to hold the number of characters entered by the user.
;					DWORD to hold accumulator value
;					DWORD to hold the multiplier
; Outputs: Updates the input parameter memory locations with the converted value
;		   and flag status value (1 = valid, 0 = invalid). (Note that input parameter 1
;		   does not contain a valid converted value if parameter 2 is updated with a 0!)
; Returns: none
;---------------------------------------------------------------------------------------
stringToNumeric PROC											
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	sub		esp, 12						;[ebp - 20] = DWORD to hold the number of characters
										;			  entered by the user
										;[ebp - 24] = DWORD to hold accumulator value
										;[ebp - 28] = DWORD to hold multiplier
	
	mov		esi, [ebp + 8]				;Moves the OFFSET of userStringEntry into source index register
	mov		[ebp - 20], eax				;AL will contain the number of characters entered...
										;...by the user at the time this procedure is called...
										;...This value is moved into a local variable for later...
										;...use.

	mov		DWORD PTR[ebp - 24], 0		;Zero local variable (accumulator) DWORD								

										;Lines 181-189 setup a multiplier for each character entered...
	mov		ecx, eax					;...by the user. After line 190 the value in EDX will contain...
	mov		DWORD PTR[ebp - 28], 1		;...the multiplier for the first digit of the number (reading from
	cmp		ecx, 1						;...left to right, or the first character entered). (It will be...
	je		ConvertToNumeric			;...divided by 10 before being applied to the converted value for each... 
	jb		InvalidEntry				;...successive digit of the string entry. See lines 244-247.) Local storage...
	mov		eax, 1						;...for the multiplier is set to 1 in case only 1 character (digit)... 
										;...is entered by the user.

	dec		ecx							;Multiplier starts at 2nd digit (from right to left), so this loop needs...
L1:										;...to run number of characters (digits) input - 1 times.
	mov		ebx, 10
	mul		ebx							
	loop	L1
	mov		[ebp - 28], eax				;Multiplier stored in local variable
	
	mov		ecx, [ebp - 20]				;Move number of characters in user entered string into loop counter

ConvertToNumeric:	
	mov		eax, 0
	cld									;Clear the direction flag
	lodsb
	cmp		al, 48
	jb		InvalidEntry
	cmp		al, 57
	ja		InvalidEntry
	sub		al, 48						;Converts the ascii representation of digits 0-9 into numeric values
	mov		ebx, eax					;Moves digit into ebx register
	mov		eax, [ebp - 28]				;Moves multiplier into eax
	mul		ebx							;Multiplies digit by multiplier
	clc
	add		[ebp - 24], eax				;Adds value to accumulator
	jc		InvalidEntry				;If carry flag is set, value is too large. Jumps to InvalidEntry.
	mov		ebx, 10
	mov		eax, [ebp - 28]				;Moves multiplier back into eax.
										
	div		ebx							;Reduces multiplier by power of 10
	mov		[ebp - 28], eax				;Stores new multiplier in local storage
	loop	ConvertToNumeric
	mov		eax, [ebp + 12]
	mov		ebx, 1
	mov		[eax], ebx					;Set status flag valid if loop finishes
	mov		eax, [ebp + 16]
	mov		ebx, [ebp - 24]				;Move accumulated value into ebx
	mov		[eax], ebx					;Move accumulated value via ebx into the local variable (accumulator)...
										;...for the converted value
	jmp		Finish
	
InvalidEntry:
	mov		eax, [ebp + 12]
	mov		ebx, 0
	mov		[eax], ebx					;Set status flag invalid if jumped to InvalidEntry
	
Finish:
	add		esp, 12
	pop		esi
	pop		edx										
	pop		ecx										
	pop		ebx
	pop		eax									
	pop		ebp

	ret		12
stringToNumeric ENDP

;----------------------------------------------------------------------------------------
; 								numericToString
; Summary: Converts an integer value to a string and stores at the address passed as 
;		   parameter 1.
; Uses: EAX, EBX, ECX, EDX, EDI
; Input Parameters: ADDRESS of string (numericOutputString) to hold converted value
;					DWORD value to convert 
; Local Parameters: WORD to hold the number of digits in number to be converted
;				    DWORD to hold the next dividend value for the conversion calculation
; Outputs: Updates the string stored at the address passed as parameter 1 with the 
;		   a string representation of the numeric value at whichever array element
;		   esi references at the time the procedure is called.
; Returns: none
;-----------------------------------------------------------------------------------------
numericToString PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	sub		esp, 6						;[ebp - 20] = WORD to hold the number of digits
										;            in the number that is to be converted
										;[ebp - 24] = DWORD to hold the next dividend value
										;			 for the conversion calculation
	
	std									;Set the direction flag

	
	mov		WORD PTR[ebp - 20], 0		;Initializes local variable for number of digits to 0

	mov		eax, [ebp + 8]				;Move value to convert into eax
										
	mov		ebx, 10
	mov		edx, 0
DigitCounter:							;Lines 363-368 determine and store the number of digits...
	mov		edx, 0
	div		ebx							;...in the number to be converted.
	inc		WORD PTR[ebp - 20]
	cmp		eax, 0						;If quotient is 0, no more digits.
	je		StoreDigitsInString
	jmp		DigitCounter

StoreDigitsInString:	
	mov		ecx, 0
	mov		cx, WORD PTR[ebp - 20]		;Set loop counter register to number of digits

	mov		edi, [ebp + 12]				;Store address of string variable to hold...
										;...converted value
	add		di, WORD PTR[ebp - 20]		;Add the number of digits and subtract 1 to the address to get...
	dec		di							;...the address for the last digit (1 is subtracted because the...
										;...first digit is placed at the address itself (i.e. with no offset...
										;...from the beginning of the address.)
	inc		di							;Add one more to get address for null terminator
										
										;(Note that the previous 2 instructions cancel out and so strictly...
										;...speaking are not necessary. They are included with comments however...
										;...to demonstrate the logic behind establishing the proper indexing into...
										;...the string variable that is to hold the converted number.
	mov		al, 0
	stosb								;Store 0 in address for null terminator
	mov		eax, [ebp + 8]				;Move value of number to convert into local storage for initial...
	mov		[ebp - 24] , eax				;...dividend value
	
L1:	
	mov		eax, [ebp - 24]				;Move next dividend value into eax
	mov		edx, 0
	div		ebx							;Divide by 10
	mov		[ebp - 24], eax				;Store quotient in local variable to hold next dividend value
	mov		al, dl						;Remainder yields next digit (from right to left) as...
	add		al, 48						;...each loop iteration executes. Move remainder into al...
	stosb								;...and add 48 to yield ascii value for the digit. Store...
										;...this value pointed to by the address stored in edi.
										;...(Note that because the direction flag is set, the string...
										;...is being updated from right-to-left. That is, it is...
										;...being updated from least significant digit to most...
										;...significant digit.)
	loop	L1
	
	add		esp, 6
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp

	ret		8
numericToString ENDP
	
;--------------------------------------------------------------------------------------
; 								printValues
; Summary: Converts each numeric value stored in userNumericEntries to a string and 
;		   prints.
; Uses: EDX, EAX
; Input Parameters: OFFSET of numericStringOutput
;					OFFSET of userNumericEntries
;					OFFSET numberPrintBackMessage
; Local Parameters: DWORD to hold the value of the array element to print
;						-Argument for sub-procedure writeVal
; Outputs: Prints numeric entries as strings.
; Returns: none
;---------------------------------------------------------------------------------------
printValues PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push 	edx
	push	esi
	sub		esp, 4						;[ebp - 20] = DWORD as OFFSET of array element to print
	
	call	Crlf
	mov		edx, [ebp + 8]
	call	WriteString					;"You entered the following numbers: "
	call	Crlf
	mov		ebx, [ebp + 12]
	mov		esi, 0
	mov		ecx, 10
printNumbersAsStrings:
	mov		eax, [ebx + esi]			;Loops through each array element, converts to a string...
	mov		[ebp - 20], eax				;...via WriteVal, and prints each string seperated by a...
	push	[ebp - 20]					;...space and comma characters.
	push	[ebp + 16]
	call	WriteVal
	cmp		ecx, 1
	je		EndLoop
	mov		eax, ','
	call	WriteChar
	mov		eax, ' '
	call	WriteChar
	add		esi, 4
	loop	printNumbersAsStrings

EndLoop:
	call	Crlf
	
	add		esp, 4
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	
	ret		12
printValues ENDP

;---------------------------------------------------------------------------------
; 							calculateAndDisplaySumAndAverage
; Summary: Calculates and displays the sum and average of the user's inputs
; Uses: EAX, EBX, ECX, EDX, ESI
; Input Parameters: OFFSET of sumMessage
;					OFFSET of averageMessage
;					OFFSET of userNumericEntries
;					OFFSET of numericOutputString
; Local Parameters: DWORD as sum accumulator
;					DWORD as average
; Outputs: Prints sum and average of user integer inputs with display messages for
;		   each.
; Returns: none
;---------------------------------------------------------------------------------
calculateAndDisplaySumAndAverage PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	sub		esp, 8						;[ebp - 20] = DWORD for sum/accumulator
										;[ebp - 24] = DWORD for average

	mov		DWORD PTR[ebp - 20], 0		;Initialize sum to 0
	mov		DWORD PTR[ebp - 24], 0		;Initialize average to 0

	mov		esi, [ebp + 12]				;Move offset of array into esi
	mov		ecx, 10						;Set loop counter to 10
L1:
	mov		eax, [esi]					;Loop to add each successive array element...
	add		DWORD PTR[ebp - 20], eax	;...to the accumulator value.
	add		esi, 4
	loop	L1

	call	Crlf
	mov		edx, [ebp + 20]
	call	WriteString					;"The sum of these numbers is: "
	push	[ebp - 20]
	push	[ebp + 8]
	call	writeVal

	call	Crlf
	mov		edx, [ebp + 16]
	call	WriteString					;"The average of these numbers is: "
	mov		eax, [ebp - 20]
	mov		edx, 0
	mov		ebx, 10
	div		ebx
	mov		[ebp - 24], eax
	push	[ebp - 24]
	push	[ebp + 8]
	call	writeVal

	add		esp, 8
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp

	ret		16
calculateAndDisplaySumAndAverage ENDP	
END main