TITLE Assignment3    (Assignment03.asm)

; Author: Benjamin Fridkis
; Course / Project ID Assignment #3        Date: 10/22/2017
; Description: Program to accumulate user inputs in the range of -100 to -1
;			   until a non-negative value is entered. Program will then print
;			   the number of, sum, and average of the user inputs. If no 
;			   negative numbers are input, a special message is printed. A greeting
;			   and introduction message is provided at the beginning of the program,
;			   and a farewell message is provided at the end. 

INCLUDE Irvine32.inc

LOWER_LIMIT			EQU <-100>

.data
introduction1		BYTE "Welcome to the Integer Accumulator by Benjamin Fridkis", 0
introduction2		BYTE "What is your name? ", 0
ecMessage1			BYTE "**EC1: Lines numbered during user input.", 0
ecMessage2			BYTE "**EC2: Calculates and displays the average as a floating-point number,", 0
ecMessage3		    BYTE "       rounded to the nearest .001", 0
helloMessage		BYTE "Hello, ", 0
userName			BYTE 21 DUP(0)		;Maximum of 20 characters for the name input
inputInstructions1	BYTE "Please enter numbers in [", 0
inputInstructions2	BYTE ", -1].", 0
inputInstructions3	BYTE "Enter a non-negative number when you are finished to see results.", 0
lineNumberString	BYTE ".  ", 0
inputUserPrompt		BYTE "Enter number: ", 0
outOfRangeMessage1	BYTE "Out of range. Enter a number in [", 0
outOfRangeMessage2	BYTE ", -1] ", 0
outOfRangeMessage3	BYTE "or a non-negative number to see results.", 0
noNegativesMessage	BYTE "You entered no negative numbers in valid range of [-100, -1]", 0
countMessage1		BYTE "You entered ", 0
countMessage2		BYTE " valid numbers.", 0
sumMessage			BYTE "The sum of your valid numbers is ", 0
intRoundedAverage	BYTE "The rounded average is ", 0
ec2Header			BYTE "EC2: ", 0
floatRoundedAverage BYTE "The floating-point rounded average is ", 0
farewellMessage1	BYTE "Thank you for playing Integer Accumulator! ", 0
farewellMessage2	BYTE "It's been a pleasure to meet you, ", 0
farewellMessage3	BYTE ".", 0
ALIGN 4

userInput			SDWORD ?
numberOfInputs		DWORD 0
sumAccumulator		SDWORD 0
lineAccumulator		DWORD 1
intergerAverage		SDWORD 0
floatAverage		REAL8 0.0

thousand			WORD 1000				; Needed for EC2. See RoundedFloatingPointAverage: below.

.code
main PROC

	call Clrscr
	call Crlf

; Introduces the program
	mov		edx, OFFSET introduction1
	call	WriteString									;"Welcome to the Integer Accumulator by Benjamin Fridkis"
	call	Crlf
	call	Crlf
	mov		edx, OFFSET ecMessage1						;"**EC1: Lines numbered during user input."
	call	WriteString
	call	Crlf
	mov		edx, OFFSET ecMessage2						;"**EC2: Calculates and displays the average as a floating-point number,"
	call	WriteString
	call	Crlf
	mov		edx, OFFSET ecMessage3						;"        rounded to the nearest .001"
	call	WriteString
	call	Crlf
	call	Crlf
	mov		edx, OFFSET introduction2
	call	WriteString									;"What is your name? "
	mov		edx, OFFSET userName
	mov		ecx, SIZEOF userName
	call	ReadString
	call	Crlf
	mov		edx, OFFSET helloMessage
	call	WriteString									;"Hello, "
	mov		edx, OFFSET userName
	call	WriteString									;userName
	call	Crlf
	call	Crlf

;Prompts user to input numbers in range of [-100, -1] or non-negative to print results.
;If no non-negative numbers are entered, jumps to end of program and prints special messaage.
	mov		edx, OFFSET inputInstructions1
	call	WriteString									;"Please enter numbers in ["
	mov		eax, LOWER_LIMIT	
	call	WriteInt									;<LOWER_LIMIT>
	mov		edx, OFFSET inputInstructions2
	call	WriteString									;", -1]."
	call 	Crlf
	mov		edx, OFFSET inputInstructions3
	call	WriteString									;"Enter a non-negative number when you are finished to see results."
	call	Crlf
	call	Crlf

;Gets user data
InputPrompt:
	mov		eax, lineAccumulator
	call	WriteDec
	mov		edx, OFFSET lineNumberString
	call	WriteString									;Lines 95-98 write line number for user input (EC1).
	mov		edx, OFFSET inputUserPrompt	
	call	WriteString									;"Enter number: "
	call	ReadInt
	cmp		eax, LOWER_LIMIT
	jl		InputOutOfBounds							;Jumps to error message if input less than LOWER_LIMIT.
	cmp		eax, -1
	jg		Calculations								;Jumps to Finish if non-negative number is entered.
	add		sumAccumulator, eax							;If valid, adds user input to sumAccumulator
	inc		numberOfInputs								;If valid input received, increments numberOfInputs
	inc		lineAccumulator								;If valid input received, increments lineAccumulator
	jmp		InputPrompt
InputOutOfBounds:
	call	Crlf
	call	Crlf
	mov		edx, OFFSET outOfRangeMessage1
	call	WriteString									;"Out of range. Enter a number in [,"
	mov		eax, LOWER_LIMIT
	call	WriteInt									;"<LOWER_LIMIT>"
	mov		edx, OFFSET outOfRangeMessage2
	call	WriteString									;", -1],"
	call	Crlf
	mov		edx, OFFSET outOfRangeMessage3		
	call	WriteString									;" or a non-negative number to see results."
	call	Crlf
	call	Crlf
	jmp		InputPrompt									;Re-prompts user after displaying error message

;Calculations for rounded interger average and rounded floating-point average.
Calculations:
	cmp		numberOfInputs, 0
	je		NoValidNegativeInputs						;Jumps over calculations if no valid negative inputs	
	mov		eax, sumAccumulator
	cdq
	idiv	numberOfInputs
	mov		intergerAverage, eax
	imul	edx, 10										;Lines 142-148 handle rounding the integer average...
	mov		eax, edx									;...The remainder multiplied by 10 and then divided...
	cdq
	idiv	numberOfInputs								;...by the original divisor (integerAverage) yields the first decimal place...
	cmp		eax, -5										;...(as a negative integer). If this value is less (as in more negative) than -5,...
	jge		RoundedFloatingPointAverage					;...the integerAverage is rounded down (i.e. made more negative, as the result...
	add		intergerAverage, -1							;...is always negative) to the nearest integer. Otherwise, it is rounded up (truncated).
RoundedFloatingPointAverage:
	finit												; Initializes the FPU.
	fild	sumAccumulator
	fidiv	numberOfInputs
	fimul	thousand									; Multiplies by 1000.
	frndint												; Rounds to nearest integer value.
	fidiv	thousand									; Divides by 1000, effectively rounding to nearest .001.
	fst		floatAverage
	
;Prints results
PrintResults:
	call	Crlf
	mov		edx, OFFSET countMessage1		
	call	WriteString									;"You entered "
	mov		eax, numberOfInputs
	call	WriteDec									;<numberOfInputs>
	mov		edx, OFFSET countMessage2
	call	WriteString									;" valid numbers."
	call	Crlf
	mov		edx, OFFSET sumMessage
	call	WriteString									;"The sum of your valid numbers is "
	mov		eax, sumAccumulator
	call	WriteInt									;<sumAccumulator>
	call	Crlf
	mov		edx, OFFSET intRoundedAverage
	call	WriteString									;"The rounded average is "
	mov		eax, intergerAverage			
	call	WriteInt									;<integerAverage>
	call	Crlf
	call	Crlf
	mov		edx, OFFSET ec2Header
	call	WriteString									;"EC2: "
	mov		edx, OFFSET floatRoundedAverage
	call	WriteString									;"The floating-point rounded average is "
	fld		floatAverage
	call	writefloat									;ST(0) is written to output
	jmp		Farewell
NoValidNegativeInputs:
	mov		edx, OFFSET noNegativesMessage
	call	WriteString

;Prints farewell message
Farewell:
	call 	Crlf
	call 	Crlf
	mov 	edx, OFFSET farewellMessage1
	call	WriteString									;"Thank you for playing Integer Accumulator! "
	call	Crlf
	mov		edx, OFFSET farewellMessage2
	call	WriteString									;"It's been a pleasure to meet you, "
	mov		edx, OFFSET userName
	call	WriteString									;<userName>
	mov		edx, OFFSET farewellMessage3
	call	WriteString									;"."
	call	Crlf
	call	Crlf
	
	exit												; exit to operating system
main ENDP

END main