TITLE Project #6A     (Behrman_Project6A.asm)

; Author:	Alexandra Behrman
; Course / Project ID	CS271_400                 Date: 3/19/17
; Description:	Write a small test program that:
;	1. gets 10 valid integers from the user and stores the numeric values in an array.
;	2. The program then displays the integers, their sum, and their average.
;	3. Requirements:
;		a. Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
;		b. Implement macros getString and displayString. 
;			-The macros may use Irvine’s ReadString to get input from the user, and WriteString to display output.
;		c. getString should display a prompt, then get the user’s keyboard input into a memory location
;		d. displayString should the string stored in a specified memory location.
;		e. readVal should invoke the getString macro to get the user’s string of digits. 
;			-It should then convert the digit string to numeric, while validating the user’s input.
;		f. writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to produce the output.

INCLUDE Irvine32.inc

.data

myName			BYTE	"Name: Alexandra Behrman", 0
myProgram		BYTE	"Title: Programming Assignment #6A", 0
goodbye			BYTE	"Thanks for playing! Goodbye.", 0
intro1			BYTE	"Please provide 10 unsigned decimal integers, each small enough to fit in a 32-bit register.", 0
intro2			BYTE	"When you are done, I will display a list of the integers, their sum, and their average value.", 0
prompt			BYTE	"Please enter an unsigned integer: ", 0
err				BYTE	"ERROR: You did not enter an unsigned number or your number was too big. Try again.", 0
averageIs		BYTE	"The average of the 10 numbers is: ", 0
sumIs			BYTE	"The total sum of the 10 numbers is: ", 0
numsEntered		BYTE	"You entered the following numbers:", 0
space			BYTE	"   ", 0

userString		DWORD	10 DUP(?)	;user input
userStringSize	DWORD	?
numArray		DWORD	10 DUP(?)	;user input converted to integers
tempString		BYTE	10 DUP(0)	;user input converted back to string

EC_intro1		BYTE	"**EC #1: Numbering the lines of user input.", 0
EC_intro2		BYTE	"**EC #2: Displaying running subtotal of user input.", 0
ec_count		DWORD	1 ;for numbering user input lines
ec_period		BYTE	". ", 0
ec_currentSum	BYTE	"The current sum is: ", 0
ec_sum			DWORD	0 ;for displaying running subtotal


;---------------------------------------------------------------------------------
;mGetString MACRO
;Description:			Gets user's keyboard input into memory location
;Receives:				varName
;Registers Changed:		ecx, edx
;---------------------------------------------------------------------------------
mGetString MACRO userString, userStringSize					;code taken from from Lecture 26 slides
	push	ecx
	push	edx
	push	eax

	mov		edx, OFFSET userString
	mov		ecx, SIZEOF userString
	call	ReadString
	mov		userStringSize, 0
	mov		userStringSize, eax

	pop		eax
	pop		edx
	pop		ecx
ENDM


;---------------------------------------------------------------------------------
;mDisplayString MACRO
;Description:			Displays string stored in specified memory location
;Receives:				buffer
;Registers Changed:		edx
;---------------------------------------------------------------------------------
mDisplayString MACRO buffer					;code taken from Lecture 26 slides
	push	edx
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx
ENDM


.code
main PROC

;------------- introduction procedure --------------
	push	OFFSET EC_intro1
	push	OFFSET EC_intro2
	push	OFFSET myName
	push	OFFSET myProgram
	push	OFFSET intro1
	push	OFFSET intro2
	call	introduction

;--------------- readVal procedure -----------------
	push	OFFSET ec_currentSum
	push	ec_sum
	push	ec_count
	push	OFFSET ec_period
	push	OFFSET numArray
	push	OFFSET userString
	push	OFFSET userStringSize
	push	OFFSET prompt
	push	OFFSET err
	call	readVal

;--------------- writeVal procedure ----------------
	push	OFFSET space
	push	OFFSET numArray
	push	OFFSET numsEntered
	call	writeVal

;------------ SumAndAverage procedure -------------
	push	OFFSET sumIs
	push	OFFSET averageIs
	push	OFFSET numArray
	call	sumAndAverage

;------------- farewell procedure -----------------
	push	OFFSET goodbye
	call	farewell

	exit	; exit to operating system
main ENDP

;---------------------------------------------------------------------------------
;Introduction PROCEDURE
;Description:			Introduces the program and programmer
;Receives:				EC_intro1, EC_intro2, myName, myProgram, intro1, intro2
;Returns:				N/A
;Preconditions:			N/A
;Registers Changed:		edx
;---------------------------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+20]			;edx = myName
	call	WriteString
	call	CrLf
	mov		edx, [ebp+16]			;edx = myProgram
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp+12]			;edx = intro1
	call	WriteString
	call	CrLf
	mov		edx, [ebp+8]			;edx = intro2
	call	WriteString
	call	Crlf
	call	CrLf
	mov		edx, [ebp+28]			;edx = EC_intro1
	call	WriteString
	call	CrLf
	mov		edx, [ebp+24]			;edx = EC_intro2
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		24
introduction ENDP


;---------------------------------------------------------------------------------
;readVal PROCEDURE
;Description:			Validates and converts string to numeric
;Receives:				ec_currentSum, ec_sum, ec_count, ec_period, numArray, 
;						userString, userStringSize, prompt, err
;Returns:				numArray filled with integers
;Preconditions:			N/A
;Registers Changed:		eax, ebx, ecx, edx, edi, esi
;---------------------------------------------------------------------------------
readVal PROC

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+24]								;edi = numArray
	mov		ecx, 10

	fillArray:

		mov		eax, [ebp+32]							;eax = ec_count
		call	writedec
		inc		eax
		mov		[ebp+32], eax
		mov		edx, [ebp+28]							;edx = ec_period
		call	writestring
		mov		edx, [ebp+12]							;edx = prompt
		call	WriteString

		mGetString		userString, userStringSize

		push	ecx
		mov		esi, [ebp+20]							;esi = userString
		mov		ecx, [ebp+16]							;ecx = userStringSize
		mov		ecx, [ecx]								;set counter
		mov		eax, 0
		mov		ebx, 0
		mov		edx, 0
		cld												;moving forward through string

		LoadString:
			lodsb										;move first byte into eax
			cmp		eax, 48
			jb		BadInput							;if lower than first ascii digit
			cmp		eax, 57
			ja		BadInput							;if higher than last ascii digit

			sub		eax, 48								;conversion to integer
			push	eax
			mov		eax, ebx
			mov		ebx, 10
			mul		ebx
			cmp		edx, 0								;if number too large for 32-bit register (edx:eax)
			jne		TooLarge							
			mov		ebx, eax
			pop		eax
			add		ebx, eax
			mov		eax, 0								;reset eax for next byte
			loop	LoadString

		mov		eax, ebx
		stosd											;move integer to correct numArray location

		mov		edx, [ebp+40]							;edx = ec_currentSum
		call	WriteString
		mov		ebx, [ebp+36]							;ebx = ec_sum
		add		eax, ebx								;eax = new sum
		call	WriteDec
		mov		[ebp+36], eax
		call	CrLf
		call	CrLf

		add		esi, 4									;move esi to next location
		pop		ecx										;reset counter
		dec		ecx
		cmp		ecx, 0
		jne		fillArray
		jmp		ProcEnd

	BadInput:											;input contains non-decimal values
		pop		ecx
		call	CrLf
		mov		edx, [ebp+8]							;edx = err
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		FillArray

	TooLarge:											;input is too large for 32-bit register
		pop		eax
		pop		ecx
		mov		edx, [ebp+8]							;edx = err
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		FillArray

	ProcEnd:
		pop		ebp
		ret		36

readVal ENDP


;---------------------------------------------------------------------------------
;WriteVal PROCEDURE
;Description:		Convert numeric to string and display	
;Receives:			space, numArray, numsEntered	
;Returns:			N/A	
;Preconditions:		numArray contains integers
;Registers Changed:	eax, ebx, ecx, edx, edi, esi	
;---------------------------------------------------------------------------------
writeVal PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]								;edi = numArray				
	mov		ecx, 10
	mov		eax, 0

	call	CrLf
	mov		edx, [ebp+8]								;edx = numsEntered
	call	WriteString
	call	CrLf

	L1:	
		push	ecx
		mov		ecx, 10 
		mov		eax, [edi]								;eax = first value in numArray
		mov		ebx, 0

		L2:
			mov		edx, 0								
			div		ecx									
			push	edx									;push remainder
			inc		ebx									;increment number of digits
			cmp		eax, 0								;compare quotient to 0
			jne		L2								
			mov		ecx, ebx							;new loop counter
			lea		esi, tempString						;esi = address of tempString

		Next:
			pop		eax
			add		eax, '0'							;convert each number to ASCII
			mov		[esi], eax							;move string to esi (tempString)
				
			mDisplayString OFFSET tempString

			loop	Next
			
		pop		ecx 
		mov		edx, OFFSET space
		call	WriteString
		mov		edx, 0
		mov		ebx, 0
		add		edi, 4
		loop L1
	
	pop		ebp			
	ret		12											
writeVal ENDP

;---------------------------------------------------------------------------------
;SumAndAverage PROCEDURE
;Description:		Calculates and displays average and sum of user numbers		
;Receives:			sumIs, averageIs, numArray				
;Returns:			N/A		
;Preconditions:		numArray contains integers, not strings		
;Registers Changed:	eax, ebx, ecx, edx, esi		
;---------------------------------------------------------------------------------
SumAndAverage PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+8]								;esi = numArray
	mov		ebx, 0										;ebx = sum										
	mov		edx, 0
	mov		ecx, 10

	;calculate and write sum
	Sum:
		mov		eax, [esi]								;move first integer into eax
		add		ebx, eax
		add		esi, 4									;move to next location in numArray
		loop	Sum
	
		mov		edx, 0
		mov		eax, ebx								;eax = total sum
		mov		edx, [ebp+16]							;edx = sumIs
		call	CrLf
		call	CrLf
		call	WriteString
		call	WriteDec
		call	CrLf

	;calculate and write average
		mov		edx, 0
		mov		ebx, 10
		div		ebx										;eax = average
		mov		edx, [ebp+12]							;edx = averageIs
		call	WriteString
		call	WriteDec
		call	CrLf

	pop		ebp
	ret		12
SumAndAverage ENDP


;---------------------------------------------------------------------------------
;Farewell PROCEDURE
;Description:			Says goodbye
;Receives:				goodbye
;Returns:				N/A
;Preconditions:			N/A
;Registers Changed:		edx
;---------------------------------------------------------------------------------
farewell PROC
	push	ebp
	mov		ebp, esp

	call	CrLf
	mov		edx, [ebp+8]		;edx = goodbye
	call	WriteString
	call	CrLf
	call	CrLf
	
	pop		ebp
	ret		4
farewell ENDP

END main