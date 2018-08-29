TITLE Assignment5    (Assignment05.asm)

; Author: Benjamin Fridkis
; Course / Project ID Assignment #5        Date: 11/16/2017
; Description: Program to display an array of sorted random integers in descending
;			   order. User is prompted to enter the number of random integers to
;			   be displayed in the range of 10 - 200. Random integers are in the 
;			   range of 100 to 999.
;
; Implementation Note: This program is implemented using procedures that utilize
;					   both external and local parameters.

INCLUDE Irvine32.inc

MIN			EQU<10>
MAX			EQU<200>
LO			EQU<100>
HI			EQU<999>
RANGE		EQU HI-LO + 1

.data
introduction1			BYTE "Sorting Random Integers		", 0
introduction2			BYTE "Programmed by Benjamin Fridkis", 0
introduction3			BYTE "This program generates random numbers in the range [100 .. 999],", 0
introduction4			BYTE "displays the original list, sorts the list, and calculates the"  , 0
introduction5			BYTE "median value. Finally, it displays the list sorted in descending order.", 0
ecMessage1				BYTE "**EC1: Displays the numbers ordered by column instead of by row.", 0
ecMessage2				BYTE "**EC2: Uses a recursive sorting algorithm (Heap Sort).", 0
inputUserPrompt1		BYTE "How many numbers should be generated [", 0
inputUserPrompt2		BYTE " .. ", 0
inputUserPrompt3		BYTE "]: ", 0
invalidInputMessage		BYTE "Invalid input.", 0
printPrompt				BYTE "Press enter to print random integers. NOTE: This will clear the screen.", 0
unsortedArrayTitle		BYTE "The unsorted random numbers:", 0
medianMessage			BYTE "The median is ", 0
sortedArrayTitle		BYTE "The sorted list:", 0
farewellMessage			BYTE "Results certified by Benjamin Fridkis. Goodbye.", 0
ALIGN 4

request					DWORD ?
startingRow				BYTE 1
ALIGN 4
unsortedArray			WORD 200 DUP(0)
sortedArray				WORD 200 DUP(?)

.code
main PROC

call Clrscr
call Crlf
call Randomize											;Seeds psuedo-random number generator

; Introduces the program
	push	OFFSET introduction1
	push	OFFSET introduction2
	push	OFFSET introduction3
	push	OFFSET introduction4
	push	OFFSET introduction5
	push	OFFSET ecMessage1
	push	OFFSET ecMessage2
	call 	intro

; Gets the number of random integers to display after validating
; the value is within the acceptable range (LO - HI).
; Value is stored in request variable.
	push	OFFSET inputUserPrompt1
	push	OFFSET inputUserPrompt2
	push	OFFSET inputUserPrompt3
	push	OFFSET invalidInputMessage
	push	OFFSET request
	call 	getData

; Fills both the unsorted and sorted arrays with random integers
; in the range of LO to HI.
	push	request
	push	OFFSET unsortedArray
	push	OFFSET sortedArray
	call	fillArray
	
; Displays the list of random integers in the unsorted array.
; Displays in sequential order by column, 10 elements per row.
; Prompts user to press enter and then clears the screen prior
; to printing
	mov		edx, OFFSET printPrompt						
	call	WriteString									;"Press enter to print random integers. NOTE: This will clear the screen."
	call	ReadDec
	call	clrscr
	
	push	OFFSET startingRow
	push	request
	push	OFFSET unsortedArrayTitle
	push	OFFSET unsortedArray
	call	displayList

; Sorts array titled 'sortedArray'
	push	request
	push	OFFSET sortedArray
	call	heapSort

; Displays median of sorted list
	push	request
	push	OFFSET sortedArray
	push	OFFSET medianMessage
	call	displayMedian

; Displays the list of random integers in the sorted array.
; Displays in sequential order by column, 10 elements per row.
	push	OFFSET startingRow
	push	request
	push	OFFSET sortedArrayTitle
	push	OFFSET sortedArray
	call	displayList

	exit	; exit to operating system
main ENDP


; ----------------------------------------------------------------------------
; 									intro
; Summary: Introduces program and author. States range of acceptable input.
; Uses: EDX
; Input Parameters: OFFSETs of intro strings (introduction1, introduction2,
;											  introduction3, introduction4,
;											  & introduction5.) 
;					OFFSETS of extra credit headers (ecMessage1 & ecMessage2)
; Local Parameters: none
; Outputs: Intro message
; Returns: none
;-----------------------------------------------------------------------------
intro PROC
	push	ebp
	mov		ebp, esp
	push 	edx
	
	mov		edx, [ebp + 32]
	call	WriteString									;"Sorting Random Integers    "
	mov		edx, [ebp + 28]
	call	WriteString									;"Programmed by Benjamin Fridkis"
	call	Crlf
	call	Crlf
	mov		edx, [ebp + 24]								;"This program generates random numbers in the range [100 .. 999],
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 20]								;"displays the original list, sorts the list, and calculates the"
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 16]								;"median value. Finally, it displays the list sorted in descending order."
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 12]								;"**EC1: Displays the numbers ordered by column instead of by row."
	call	WriteString
	call	Crlf
	mov		edx, [ebp + 8]								;**EC2: Uses a recursive sorting algorithm (Heap Sort)."
	call	WriteString
	call	Crlf
	call	Crlf
	
	pop		edx
	pop		ebp
	
	ret 	28
intro ENDP

;--------------------------------------------------------------------------------
; 								getData
; Summary: Prompts user for input (number of random integers to display).
;		   Passes input to validate sub-procedure to check for acceptable
;		   entry (value between MIN [10] and MAX [200]). Re-prompts user if
;		   entry is outside valid range.
; Uses: EDX, EAX
; Input Parameters: OFFSETs of user prompts (inputUserPrompt1, inputUserPrompt2,
;											 & inputUserPrompt3)
;					OFFSET in invalidInputMessage
;					OFFSET of request
; Local Parameters: none 
; Outputs: Prompt message with possible error message. Stores user's input in
;		   request variable.
; Returns: none
;---------------------------------------------------------------------------------
getData PROC
	push	ebp
	mov		ebp, esp
	push 	edx
	push	eax

InputPrompt:	
	mov		edx, [ebp + 24]
	call	WriteString									;"How many numbers should be generated ["
	mov		eax, MIN
	call	WriteDec									;MIN (10)
	mov		edx, [ebp + 20]
	call	WriteString									;" .. "
	mov		eax, MAX
	call	WriteDec									;MAX (200)
	mov		edx, [ebp + 16]
	call	WriteString									;"]: "
	call	ReadDec
	
	mov		edx, [ebp + 8]
	mov		[edx], eax
	push	[edx]										;Argument for validate procedure - OFFSET of request
	call	validate									;validate returns a 1 if user input is within range...
	cmp		ebx, 1										;...or a 0 if out of range in EBX.
	je		ValidInput									;If entry valid, jump over error block
	
	mov		edx, [ebp + 12]								;If entry invalid, output error message...
	call	WriteString									;...and reprompt user for entry.
	call	Crlf
	jmp		InputPrompt

ValidInput:
	pop		eax
	pop		edx
	pop		ebp
	call	Crlf

	ret 	20
getData ENDP

;-----------------------------------------------------------------------------
; 								validate
; Summary: Sub-procedure of getUserData that checks input parameter for 
;		   validity based on an input range between MIN and MAX.
; Uses: EAX, EBX
; Input Parameters: OFFSET of request
; Local Parameters: none
; Outputs: none
; Returns: Returns 1 if entry is valid or 0 if entry is invalid in EBX.
;-----------------------------------------------------------------------------
validate PROC
	push	ebp
	mov		ebp, esp
	
	cmp		DWORD PTR[ebp + 8], MAX
	ja		Invalid
	cmp		DWORD PTR[ebp + 8], MIN
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
; 								fillArray
; Summary: Fills both the unsorted and sorted arrays with random numbers
;		   according to the request variable established by the user
;		   (in the getData procedure).
; Uses: EAX, ECX, EDI, ESI
; Input Parameters: request
;					OFFSET of unsortedArray
;					OFFSET of sortedArray
; Local Parameters: none
; Outputs: Fills sortedArray and unsortedArray as described in summary.
; Returns: none
;-----------------------------------------------------------------------------
fillArray PROC
	push 	ebp
	mov		ebp, esp
	push 	eax
	push	ecx
	push	edi
	push	esi
	
	mov		edi, 0								;Initializes destination index register to 0
	mov		ecx, 0								;Clear upper 3 BYTES of ECX
	mov		esi, 0								;This is used as an array index counter
	mov		ecx, [ebp + 16]						;Moves request (number of random integers to store/display)...
												;...into loop counter (ECX)
L1:
	mov		eax, RANGE							;Moves RANGE into eax as parameter for RandomRange
	call	RandomRange
	add		eax, LO								;Adds low to random integer returned in eax by RandomRange...
												;...so random integer is in range of LO to HI.
				
	mov		edi, [ebp + 12]
	add		edi, esi
	mov		[edi], ax							;Moves random integer into unsortedArray
	mov		edi, [ebp + 8]
	add		edi, esi
	mov		[edi], ax							;Moves random integer into sortedArray (to be sorted later).						
	add		esi, TYPE WORD						;Increments array index counter by 2
	loop	L1

	pop		esi
	pop		edi
	pop		ecx
	pop		eax
	pop		ebp
	
	ret		12
fillArray	ENDP
	
;-----------------------------------------------------------------------------
; 								displayList
; Summary: Displays the contents of an array, printed in sequential order by
;		   column, 10 elements per column.
; Uses: EAX, EBX, EDX, ECX, ESI, EDI
; Input Parameters: OFFSET startingRow
;					request
;					OFFSET of unsortedArrayTitle or sortedArrayTitle
;					OFFSET of unsortedArray or sortedArray
; Local Parameters: BYTE to store number of rows needed to display all numbers
;					BYTE to store the column spacing offset
;					BYTE to store the output row number
;					BYTE to store an up counter to track number of elements printed
;					BYTE to store number of elements on the last row
; Outputs: Prints title message and array contents as described in summary.
;		   Updates startingRow variable with value for next call to displayList.
; Returns: none
;-----------------------------------------------------------------------------
displayList PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	sub		esp, 5										;[epb - 24] = number of complete rows - BYTE
														;[ebp - 25] = column spacing offset - BYTE                                       
														;[ebp - 26] = output row number - BYTE											
														;[ebp - 27] = sequence up counter - BYTE											
														;[ebp - 28] = number of elements on the last row - BYTE							
																									

	mov		eax, 0										;Lines 329-334: Divide the number of elements to print by 10...								
	mov		al, BYTE PTR[ebp + 16]						;...Because 10 items per row are displayed, the quotient of this div yields...
	mov		bl, 10										;...the number of complete rows needed. The remainder is stored as the
	div		bl											;...number of elements on the last row (if the last row is not a complete 10...
	mov		[ebp - 24], al								;...elements, as a 0 indicates all rows have a 'full' 10 elements).
	mov		[ebp - 28], ah								
		
	mov		BYTE PTR[ebp - 25], 0						;Moves 0 into the column spacing offset local variable
	mov		eax, [ebp + 20]								;Moves the value at startingRow into the local variable for output row number
	mov		eax, [eax]
	mov		BYTE PTR[ebp - 26], al						;Moves the value at startingRow into the output row number local variable
	mov		BYTE PTR[ebp - 27], 0						;Moves 0 into the sequence up counter
	mov		esi, 0										;Moves 0 into the source index register

	
	mov		edx, [ebp + 12]
	call	WriteString									;Prints array title message, based on input parameter #2
	call	Crlf
	
	mov		ecx, 0										;Clear upper 3 BYTES of ecx
	mov		ecx, [ebp + 16]								;Moves the request variable value into the loop counter (ECX)
	mov		eax, 0										;Clear upper word of EAX register
	mov		edi, 0										;Used as an array index counter
L1:
	inc		BYTE PTR[ebp - 27]							;Increments the sequence up counter local variable
			
	mov		dh, BYTE PTR[ebp - 26]						
	mov		dl, BYTE PTR[ebp - 25]
	call	Gotoxy										;Aligns cursor in proper position for next element
		
	mov		esi, [ebp + 8]
	add		esi, edi
	mov		eax, 0
	mov		ax, WORD PTR[esi]
	call	WriteDec									;Prints the random integer from the array

	mov		eax, 0
	mov		al, BYTE PTR[ebp - 27]						;Moves sequence up counter local variable into al
	mov		bl, 10										;Lines 367-355 test if the sequence up counter divided by the...
	div		bl											;...number of rows yields a remainder of 0 (i.e. element is the... 
	cmp		ah, 0										;...10th and therefore last of the given row)... 
	je		IncrementRowNumber							;...If so, column spacing is incremented by 4 and the... 
	jmp		IncrementESI								;...execution jumps to IncrementRowNumber.
IncrementRowNumber:
	inc		BYTE PTR[ebp - 26]							;Increments output row number
	mov		BYTE PTR[ebp - 25], 0						;Resets column alignment variable
	mov		al, BYTE PTR[ebp - 26]						;Lines 376-384 sets the index offset register (edi) to the...						
	cbw													;...new row number - starting row number then multiplied by 2...
	mov		di, ax										;...This is because when printing in sequential order vertically...
	mov		eax, [ebp + 20]								;Moves the value at startingRow into the local variable for output row number
	mov		eax, [eax]
	sub		edi, eax									;...(by column), the first element offset to print for each row is...
	mov		eax, edi									;... given by said formula ((row number - starting row number) * 2)
	mov		ebx, 2
	mul		ebx
	mov		edi, eax
	jmp		FinishL1
IncrementESI:
	add		BYTE PTR[ebp - 25], 4						;Lines 387 - 407 set the appropriate index offset (edi)...
	mov		ebx, 0										;...spacing in the following fashion: if the term number per row...
	mov		bl, [ebp - 28]								;...(e.g. first term of row, second term of row, etc.) is greater...
	cmp		ebx, 0										;...than the number of terms in the last row, elements are skipped...
	je		IncrementByCompleteRowNumber				;...when printing across the row according to the number of complete...
	cmp		ah, [ebp - 28]								;...rows. If the term number per row is less than or equal to the...
	ja		IncrementByCompleteRowNumber				;...number of terms in the last row, the spacing to the next term...
IncrementByCompleteRowNumberPlus1:						;...is the number of complete rows plus one (or the number of rows
	mov		eax, 0										;...total). If the last row is complete (i.e. number of terms is
	mov		al, [ebp - 24]								;...divisible by 10 and therefore the last row contains 10 terms),...
	add		al, 1										;...all elements are spaced apart according to the number of rows.
	mov		ebx, 2										;Ex: If there are 2 rows total, and 5 elements in the last row...
	mul		ebx											;...the first row prints from left to right as follows:...
	add		edi, eax									;...array[0], array[2], array[4], array[6], array[8]...
	jmp		FinishL1									;...array[10], array[11], array[12], array[13], array[14]
IncrementByCompleteRowNumber:
	mov		eax, 0
	mov		al, [ebp - 24]
	mov		ebx, 2
	mul		ebx
	add		edi, eax

FinishL1:
	sub		ecx, 1
	cmp		ecx, 0
	jne		L1
	
	call	Crlf
	call	Crlf
	
	mov		al, [ebp - 26]								;Lines 418-425 set up the starting row variable... 
	cmp		BYTE PTR[ebp - 28], 0						;...for the next call to displayList
	jne		AddRowOffsetForNextCall						
	sub		al, 1										;Subtract one if last row is complete since row number is incremented...
AddRowOffsetForNextCall:								;...one row past the last row if so.
	add		al, 5
	mov		ebx, [ebp + 20]
	mov		[ebx], al
	
	add		esp, 5
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp

	ret		16
displayList   ENDP

;-----------------------------------------------------------------------------
; 								heapSort
; Summary: Restructures an array into a heap configuration and then uses
;		   heap sort to sort the array in descending order.
; Uses: EAX, EBX
; Input Parameters: request
;					OFFSET of sortedArray	
; Local Parameters: DWORD to hold various index values
; Outputs: Sorts the array pointed to by the array offset parameter.
; Returns: none
;-----------------------------------------------------------------------------
heapSort PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	sub		esp, 4									;[ebp - 8] - DWORD to hold various index values

	mov		eax, 0
	mov		eax, [ebp + 12]							;Lines 458-462 divide the number of elements by 2 and...
	mov		bl, 2									;...subtract one from the result. This provides the index...
	div		bl										;...number of the first element that is guaranteed to be a...
	sub		al, 1									;...non-leaf node. This value is stored in the local DWORD.
	mov		[ebp - 8], eax

BuildHeap:
	cmp		WORD PTR[ebp - 8], 65535				;While the value determined above (lines 458-462) is greater than...				
	je		FinishHeapBuild							;...or equal to zero, call adjustHeap repeatedly and then decrement...
	push	DWORD PTR[ebp + 8]						;...the local DWORD. adjustHeap is passed the OFFSET of sortedArray...
	push	DWORD PTR[ebp + 12]
	push	DWORD PTR[ebp - 8]						;...on every non-leaf node of the of the array, establishing the heap...
	call	adjustHeap								;...order property. The array index (stored and passed in local DWORD)...
	dec		DWORD PTR[ebp - 8]						;...is decremented after each call and the loop discontinues when this...
	jmp		BuildHeap								;...value reaches -1.

FinishHeapBuild:
	mov		eax, 0
	mov		eax, [ebp + 12]							;Moves size of array (request) minus 1 and stores in local DWORD
	sub		eax, 1
	mov		[ebp - 8], eax

SortHeap:
	cmp		BYTE PTR[ebp - 8], 255					;Lines 481-497 swap the first element with the element given by the...
	je		FinishSortHeap							;...local DWORD (size [request] - 1)
													;adjustHeap then re-establishes the heap order property up to the position...
	push	[ebp + 8]								;...of the element just moved to the back. The local DWORD is then decremented with... 
	push	[ebp - 8]								;...each loop iteration. This has the effect of sorting the array in...
	mov		ebx, 0									;...descending order, since the heap property always maintains the smallest...
	push	ebx										;...element at the root of the heap (and since it is this element that is...
	call	swapArrayElements						;...continually moved to the back of the array up to the point of the previous...
													;...swap.
	push	[ebp + 8]
	push	[ebp - 8]
	mov		ebx, 0
	push	ebx
	call	adjustHeap
	
	dec		DWORD PTR[ebp - 8]
	jmp		SortHeap

FinishSortHeap:
	add		esp, 4
	pop		ebx
	pop		eax
	pop		ebp

	ret		8

heapSort ENDP
		
;-----------------------------------------------------------------------------
; 								swapArrayElements
; Summary: Swaps the input parameter elements 
; Uses: EAX, EBX, ECX, EDX, EDI, ESI
; Input Parameters: OFFSET of sortedArray
;					Array Element # Parameter 1
;					Array Element # Parameter 2	
; Local Parameters: none
; Outputs: Sorts the array pointed to by the array offset parameter.
; Returns: none
;-----------------------------------------------------------------------------
swapArrayElements PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi
	
	mov		ax, WORD PTR[ebp + 12]
	mov		bl, 2
	mul		bl
	mov		edi, 0
	mov		di, ax								;Store offset variable for array element #1 in edi

	mov		ax, WORD PTR[ebp + 8]
	mov		bl, 2
	mul		bl
	mov		esi, 0
	mov		si, ax								;Store offset variable for array element #2 in esi
		

	mov		eax, [ebp + 16]						;Calculate and store address of Array Element Parameter 1 in EAX
	add		eax, edi
	mov		cx, WORD PTR[eax]					;Store value at Array Element Parameter 1 in CX

	mov		ebx, [ebp + 16]						;Calculate and store address of Array Element Parameter 2 in EBX
	add		ebx, esi
	mov		dx, WORD PTR[ebx]					;Store value at Array Element Parameter 2 in DX

	mov		[eax], dx							;Move value of Array Element Parameter 2 into address of Parameter 1
	mov		[ebx], cx							;Move value of Array Element Parameter 1 into address of Parameter 2

	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp

	ret		12
swapArrayElements ENDP

;-----------------------------------------------------------------------------
; 								adjustHeap
; Summary: Recursive function to set heap ordering property for an array
;		   argument. The element at position index is percolated down the
;		   heap tree until it is no longer larger than its children nodes,
;		   down to (but not including) the position 'max'. 
; Uses: EAX, EBX, ECX, EDX, EDI, ESI
; Input Parameters: OFFSET of sortedArray
;					max position - adjusts 'down to' but not including this
;								   array element number
;					position index - the element number to adjust within
;									 the heap structure
; Local Parameters: BYTE - 'rightChildIdx'
;					BYTE - 'leftChildIdx'
;					WORD - smallestChildValue
; Outputs: Adjusts the element number 'position index' within the array 
;		   parameter.
; Returns: none
;-----------------------------------------------------------------------------
adjustHeap PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi
	sub		esp, 14							;[ebp - 24] = leftChildIdx - DWORD
											;[ebp - 28] = rightChildIdx - DWORD									   
											;[ebp - 32] = smallestChildValue - WORD								   
											;[ebp - 34] = leftChildValue - WORD									   
											;[ebp - 36] = rightChildValue - WORD								   
																				
	mov		eax, 0
	mov		al, BYTE PTR[ebp + 8]
	mov		bl, 2
	mul		bl
	add		ax, 1							;Multiply position index by 2 and add 1 to get left child index
	mov		[ebp - 24], eax					;Store in local variable

	add		ax, 1							;Add one more to result to get right child index
	mov		[ebp - 28], eax					;Store in local variable

	mov		eax, [ebp + 12]					;Move max parameter into eax and check if right child index is less...
	cmp		[ebp - 28], eax					;... than max (indicating two child nodes). If not, jmp to check for left child
	jl		TwoChildren
	cmp		[ebp - 24], eax					;If there aren't two children, check if leftIdx < max, and if so, there is one...
	jl		LeftChildSmallest				;...child (left). Jump accordingly.
	jmp		Finish							;If no children, jump to finish

TwoChildren:								;Determine smaller of two children nodes...
	mov		eax, [ebp - 24]					
	mul		bl								;Multiply left child index value by TYPE WORD to get array offset at left child index
	mov		edi, eax
	mov		edx, [ebp + 16]
	add		edx, edi						;EDX holds address of array at element of left child node
	mov		eax, [ebp - 28]					
	mul		bl								;Multiply right child index value by TYPE WORD to get array offset
	mov		esi, eax
	mov		ecx, [ebp + 16]
	add		ecx, esi						;ECX holds address of array at element of right child node

	mov		dx, WORD PTR[edx]				;Move value of left child into EDX
	mov		cx, WORD PTR[ecx]				;Move value of right child into ECX
	mov		[ebp - 34], dx					;Store value of left child in local WORD
	mov		[ebp - 36], cx					;Store value of right child in local WORD
	cmp		cx, dx							;Compare right child value to left child value
	jl		RightChildSmallest

LeftChildSmallest:	
	mov		eax, [ebp - 24]					
	mul		bl								;Multiply left child index value by TYPE WORD to get array offset at left child index
	mov		edi, eax
	mov		edx, [ebp + 16]
	add		edx, edi						;EDX holds address of array at element of left child node
	mov		dx, WORD PTR[edx]				;Move value of left child into EDX
	mov		[ebp - 32], dx					;Moves value of smallest child (left) into local variable
	mov		eax, [ebp + 8]					;Multiply position index by 2... 
	mul		bl								
	add		eax, [ebp + 16]					;...and add to array OFFSET to get address of array at index
	mov		ax, WORD PTR[eax]				;Move the value of index position into eax by dereferencing its address
	cmp		ax, WORD PTR[ebp - 32]			;Compare value at position index to value of smallest child
	jbe		Finish							;If parent is already smaller, jump to finish
	
	push	[ebp + 16]						;Push offset of array
	push	[ebp - 24]						;Push index of smallest (left) child array element			
	push	[ebp + 8]						;Push position index
	call	swapArrayElements

AdjustHeapFunctionCallParametersPush:
	push	[ebp + 16]						;Push offset of array
	push	[ebp + 12]						;Push index of max position
	mov		ax, [ebp - 34]					;Determine the smallest child value... 
	cmp		ax, [ebp - 36]					;...and then push the smallest child index based thereon
	jbe		PushLeftChildIndex
	jmp		PushRightChildIndex
PushLeftChildIndex:					
	push	[ebp - 24]						;Push index of left child
	jmp		AdjustHeapFunctionCall
PushRightChildIndex:
	push	[ebp - 28]		
AdjustHeapFunctionCall:	
	call	adjustHeap						;Recursive call to adjustHeap
	
	jmp		Finish	

RightChildSmallest:
	mov		[ebp - 32], cx					;Moves value of smallest child into local variable
	mov		eax, [ebp + 8]					;Multiply position index by 2... 
	mul		bl								
	add		eax, [ebp + 16]					;...and add to array OFFSET to get address of array at index
	mov		ax, WORD PTR[eax]				;Move the value of index position into eax by dereferencing its address
	cmp		ax, WORD PTR[ebp - 32]			;Compare value at position index to value of smallest child
	jbe		Finish							;If parent is already smaller or equal, jump to finish

	push	[ebp + 16]						;Push offset of array
	push	[ebp - 28]						;Push index of smallest (right) child array element			
	push	[ebp + 8]						;Push position index
	call	swapArrayElements
	jmp		AdjustHeapFunctionCallParametersPush

Finish:
	add		esp, 14
	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp

	ret		12

adjustHeap ENDP

;-----------------------------------------------------------------------------
; 								displayMedian
; Summary: Displays the median value of the sorted array. If there are an 
;		   even number of terms and hence two medians, provides the average
;		   of the two rounded to the nearest integer.
; Uses: EAX, EBX
; Input Parameters: request
;					OFFSET of sortedArray
;					OFFSET of medianMessage	
; Local Parameters: DWORD to hold various index values
; Outputs: Sorts the array pointed to by the array offset parameter.
; Returns: none
;-----------------------------------------------------------------------------
displayMedian PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx

	mov		edx, [ebp + 8]
	call	WriteString						;"The median is "
	mov		edx, 0

	mov		eax, [ebp + 16]					;Divide number of terms by 2...
	mov		bx, 2							;...A remainder of zero indicates...
	div		bl								;...an even number of terms. A non-zero...
	cmp		ah, 0							;...remainder indicates an odd number of...
	je		EvenNumberOfTerms				;...terms.
OddNumberOfTerms:
	mov		edx, [ebp + 12]					;If there are an odd number of terms, the...
	mul		bl								;...quotient value from the above division is...
	add		dl, al							;...the array element number of the median (assuming...
	mov		cx, [edx]						;...a starting index of 0). Print this number.
	jmp		Finish
EvenNumberOfTerms:
	mov		edx, [ebp + 12]					;If there are an even number of terms, divide the sum of...
	mul		bl								;...the two middle terms by 2 to yield the median (the average...
	add		dl, al							;...of the two). This value is rounded to the nearest integer...
	mov		eax, [edx]						;...by multiplying the remainder of the average-yielding division...
	sub		edx, 2							;...operation by 10, then dividing this value by 2 once more. If...
	mov		edx, [edx]						;...the quotient of the resulting operation is equal to or...
	add		eax, edx						;...greater than 5, add one to the original average value to...
	cwd										;...to effectively round up.
	div		bx								
	mov		cx, ax
	mov		ax, dx
	mov		bx, 10
	mul		bx
	mov		bx, 2
	div		bx
	cmp		ax, 5
	jl		Finish
	add		cx, 1
Finish:	
	mov		eax, 0
	mov		ax, cx							;Print the rounded average.
	call	WriteDec
	mov		eax, '.'
	call	WriteChar
	call	Crlf
	call	Crlf

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp

	ret		12
displayMedian ENDP
END main