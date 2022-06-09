TITLE Integer ASCII Validation     (Proj6_tolsone.asm)

; Author: Eric Tolson
; Description: This program takes user 10 inputs that are validated as
; numbers that fit into 32 bit register. This program converts the user input
; into integers using math and ASCII references. This Program then converts the
; integers back to strings and displays them to the user. This program calculates
; the sum and truncated avg of the integers and displays those to the user. This 
; program uses two macros to get and display strings. It uses two procedures, one
; to validate input and convert it to integers, the other to convert the integers to
; strings and dsiplay them. 

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString 
; 
; Gets string from user that represents a number.
; 
; Preconditions: prompts exist for input, empty data exists for string output
; 
; Receives: 
; prompt = offset for string
; stringOut = empty string for output
;
; returns: stringOut with user input, stringCount with lenght of input
; --------------------------------------------------------------------------------- 
mGetString	MACRO	 prompt, stringOut, stringCount
	PUSH	EDX							;Save EDX, ECX, EAX registers
	PUSH	ECX
	PUSH	EAX

	MOV		EDX, prompt					;Display prompt
	CALL	WriteString

	MOV		EDX, stringOut				;Get input, save string and character count for output.
	MOV		ECX, 1000
	call	ReadString
	MOV		stringCount, EAX

	POP		EAX							;Restore ECX, EDX, EAX
	POP		ECX
	POP		EDX
ENDM


; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
; Displays string
; 
; Preconditions: string reference exist

; Receives: 
; stringDisplay = offset for string
; 
; returns: none
; --------------------------------------------------------------------------------- 
mDisplayString	MACRO	stringDisplay
	PUSH	EDX							;Save EDX register
	MOV		EDX, stringDisplay
	CALL	WriteString
	POP		EDX							;Restore EDX
ENDM


ARRAYSIZE	=	10						;Size for integer array looping
MAXLENGTH	=	100						;Max size for initial user input validation, accommodate for sign


.data
;data for mDisplayString macro
intro			BYTE "Integer ASCII Validation by Eric Tolson",13,10
				BYTE 13,10,"You will enter 10 signed decimal intergers. Each integer must fit in 32 bit register. "
				BYTE 13,10,"The list of integers, their sum, and their avg will be displayed.",13,10,0 
outro			BYTE 13,10,13,10,"Thank you and goodbye!",13,10,0

;data for mGetString macro
prompt			BYTE 13,10,"Please enter a signed decimal integer: ",0
userString		BYTE MAXLENGTH DUP (?)
stringLength	DWORD ?

;data for ReadlVal
error			BYTE 13,10,"Your number is too big or not a valid number!",0
userInt			DWORD ?

;data for WriteVal
outPutString	BYTE MAXLENGTH DUP (?)
reverseString	BYTE MAXLENGTH DUP (?)

;data for input loop
intArray		DWORD ARRAYSIZE DUP (?)
lengthArray		DWORD ARRAYSIZE DUP (?)

;data for output loop
listDisplay		BYTE 13, 10,"You entered these numbers:",13,10,0
space			BYTE " ",0
comma			BYTE ",",0

;data for sum and average display
avgDisplay		BYTE 13,10,13,10,"The truncated average of your numbers is: ",13,10,0
sumDisplay		BYTE 13,10,13,10,"The sum of your numbers is: ",13,10,0

userAvg			DWORD ?
userSum			DWORD ?
sumLength		DWORD ?
avgLength		DWORD ?

.code
main PROC
	mDisplayString	OFFSET intro					;display intro and instructions

; -------------------------- 
; Loops through ReadVal procedure 10 times
; Validates user input
; Saves user inputs as integers in array of size 10
; Saves lengths of user inpust as integer in array of size 10
 
; -------------------------- 

	MOV				ECX, ARRAYSIZE					;save ECX for user inputer loop of size 10
	MOV				EDI, OFFSET intArray			;save EDI for int values storage from ReadVal, stored in intArray
	MOV				ESI, OFFSET lengthArray			;save ESI for string length storage from ReadVal, stored in lengthArray
_inputLoop:
	PUSH			ECX
	PUSH			EDI
	PUSH			ESI

	PUSH			OFFSET userInt					;push necessary offsets for ReadVal
	PUSH			OFFSET stringLength			
	PUSH			OFFSET error				
	PUSH			OFFSET prompt				
	PUSH			OFFSET userString
	CALL			ReadVal
	MOV				userInt, EAX					;mov register values from ReadVal to data
	MOV				stringLength, EBX

	POP				ESI
	POP				EDI								;add return values from ReadVal to EDI and ESI for array storage and use in WriteVal
	
	MOV				[EDI], EAX
	MOV				[ESI], EBX
	ADD				EDI, 4
	ADD				ESI, 4
	POP				ECX
	LOOP			_inputLoop
; ... 


; -------------------------- 
; Displays user input as list with message
; Loops through WriteVal 10 times
; Passes values from integer and length arrays into WriteVal
; 
; -------------------------- 
	mDisplayString	OFFSET listDisplay

	MOV				ECX, ARRAYSIZE					;save ECX for user inputer loop of size 10
	MOV				EDI, OFFSET intArray			;save EDI for int values display in WriteVal
	MOV				ESI, OFFSET lengthArray			;save ESI for string length used in WriteVal
	MOV				EDX, OFFSET outPutString
_listLoop:
	PUSH			ECX
	PUSH			EDI
	PUSH			ESI
	PUSH			EDX

	PUSH			[ESI]							;push necessary offsets and values to WriteVal
	PUSH			OFFSET outPutString			
	PUSH			[EDI]
	CALL			WriteVal

	POP				EDX
	POP				ESI
	POP				EDI								;add return values from ReadVal to EDI and ESI for array storage and use in WriteVal
	ADD				EDI, 4
	ADD				ESI, 4
	POP				ECX

	CMP				ECX, 1							;make list pretty
	JLE				_skip
	mDisplayString	OFFSET comma					
	mDisplayString	OFFSET space					

	
_skip:
	
	LOOP			_listLoop
	
; ... 


; -------------------------- 
; Determines sum of user values.
; Uses values stored in intArray for arithmetic
; Calculate length of value
; Pass sum and length to WriteVal for display
;
; -------------------------- 
	 mDisplayString	OFFSET sumDisplay

	 MOV		EDI, OFFSET intArray				;setup integer loop
	 MOV		ECX, ARRAYSIZE
	 MOV		userSum, 0

_sumLoop:
	MOV			EAX, [EDI]
	ADD			userSum, EAX						;sum integers, store in sum
	ADD			EDI, 4
	LOOP		_sumLoop
					
	MOV			sumLength, 0						;determine length of sum for WriteVal procedure
	MOV			EAX, userSum
	CMP			userSum, 0
	JL			_negative

_length:
	CMP			EAX, 10								;algorithm for determing number length
	JL			_endLength
	MOV			EBX, 10
	CDQ
	IDIV		EBX
	INC			sumLength
	JMP			_length

_negative:
	NEG			userSum								;if negative, inc length for sign, negate value for length algorithm
	MOV			EAX, userSum

_length2:
	CMP			EAX, 10								;algorithm for determing number length for negative number
	JL			_endNegative
	MOV			EBX, 10
	CDQ
	IDIV		EBX
	INC			sumLength
	JMP			_length2

_endNegative:										;turn back to negative, inc length for sign
	NEG			userSum
	INC			sumLength

_endLength:
	INC			sumLength

	PUSH		sumLength							;user WriteVal to display sum with sum and length of sum
	PUSH		OFFSET outPutString
	PUSH		userSum
	CALL		WriteVal
; ... 


; -------------------------- 
; Determines sum of user values.
; Uses values stored in intArray for arithmetic
; Calculate length of value
; Pass sum and length to WriteVal for display
;
; -------------------------- 
	mDisplayString	OFFSET avgDisplay

	MOV			EAX, userSum						;calculate and store userAvg
	MOV			EBX, ARRAYSIZE
	CDQ
	IDIV		EBX
	MOV			userAvg, EAX

	MOV			avgLength, 0						;determine length of sum for WriteVal procedure
	MOV			EAX, userAvg
	CMP			userAvg, 0
	JL			_avgNegative

_avgLength:
	CMP			EAX, 10								;algorithm for determing number length
	JL			_endLengthAvg
	MOV			EBX, 10
	CDQ
	IDIV		EBX
	INC			avgLength
	JMP			_avgLength

_avgNegative:
	NEG			userAvg								;if negative, inc length for sign, negate value for length algorithm
	MOV			EAX, userAvg

_avgLength2:
	CMP			EAX, 10								;algorithm for determing number length for negative number
	JL			_endNegativeAvg
	MOV			EBX, 10
	CDQ
	IDIV		EBX
	INC			avgLength
	JMP			_avgLength2

_endNegativeAvg:										;turn back to negative, inc length for sign
	NEG			userAvg
	INC			avgLength

_endLengthAvg:
	INC			avgLength

	PUSH		avgLength							;user WriteVal to display avg with avg and length of avg
	PUSH		OFFSET outPutString
	PUSH		userAvg
	CALL		WriteVal
; ... 



	mDisplayString	OFFSET outro					;say bye bye

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --------------------------------------------------------------------------------- 
; Name: ReadVal
; Calls mGetString macro to get user string. 
; Loops string and confirms it is a number
; Loops string and converts to integer
; Confirms that integer is within 32 bit register range and saves integer for output
;
; Preconditions: mGetString returns user input and length of input
; 
; Postconditions: ECX, ESI, EDI, EAX, ECX, EDX chanaged
; 
; Receives:  
;	[EBP+8]		=	userString offset for macro
;	[EBP+12]	=	prompt offset for macro
;	[EBP+16]	=	error offset for validation
;	[EBP+20]	=	stringLength offset for macro
;	[EBP+24]	=	userInt offset for integer storage 
;
; returns: userInt with valid user integer from string input
; --------------------------------------------------------------------------------- 
ReadVal PROC
	PUSH		EBP
	MOV			EBP, ESP

_getInput:							
	mGetString	[EBP+12], [EBP+8], [EBP+20]			;call get string macro with arguments from stack

	MOV			ECX, [EBP+20]						;move length of user input in ECX for iteration
	MOV			ESI, [EBP+8]						;validate user input, first check if first character is sign or '+' or '-'
	LODSB
	CMP			AL, 43
	JE			_nextIndex
	CMP			AL, 45
	JE			_nextIndex
	JMP			_isNum

_nextIndex:											;make sure each character in the string is valid number
	LODSB
	DEC			ECX

_isNum:
	CMP			AL, 48								;iterate string and compare index values to ascii values for 0-9
	JL			_error
	CMP			AL, 57
	JG			_error
	LODSB
	LOOP		_isNUm
	JMP			_convert

_error:
	MOV			EDX, [EBP+16]
	CALL		WriteString
	JMP			_getInput

_convert:
	MOV			EDI, 0								;set EDI as accumulator for integer conversion		
	MOV			ECX, [EBP+20]						;move length of user input in ECX for iteration
	MOV			ESI, [EBP+8]
	LODSB											
	CMP			AL, 45								;if negative, jump to use subtraction algorithm
	JE			_negativeSign
	
	CMP			AL, 43								;check if + sign, jump to skip if so
	JE			_plusSign

_positive:
													;implement addition algorithm to create positive integer
	MOV		EDX, 0
	MOV		DL, AL
	SUB		DL, 48
	IMUL	EDI, 10
	ADD		EDI, EDX
	
	MOV		EAX, 0									;see if sign flips from overflow
	CMP		EDI, EAX
	JL		_error

	LODSB
	LOOP		_positive							
	JMP			_endReadVal

_plusSign:											;skip first character is + sign and go to adding algorithm
	DEC			ECX
	LODSB
	JMP			_positive

_negativeSign:
	DEC			ECX
	LODSB
	
_negative:											;same as positive algorithm but with subtraction
	MOV		EDX, 0
	MOV		DL, AL
	SUB		DL, 48
	IMUL	EDI, 10
	SUB		EDI, EDX

	MOV		EAX, 0									;see if sign flips from overflow
	CMP		EDI, EAX
	JG		_error

	LODSB
	LOOP	_negative


_endReadVal:
	MOV			[EBP+24], EDI						

	MOV			EAX, [EBP+24]						;save integer to output parameter in EAX
	MOV			EBX, [EBP+20]						;save length of input to EBX
	
	POP			EBP
	RET			20
ReadVal ENDP


; --------------------------------------------------------------------------------- 
; Name: WriteVal
; Converts SDOWRD number to a string of ASCII digits.
; Uses mDisplayString to display SDWORD value to output
; 
; Preconditions: mDisplayString macro works and integer values are set for input and length of input
; 
; Postconditions: outPutString holds string, all registers changed
; 
; Receives:  
;	[EBP+8]		=	user input as integer 
;	[EBP+12]	=	OFFSET outPutString, for string output.
;	[EBP+16]	=	input string length
; returns: none
; --------------------------------------------------------------------------------- 
WriteVal PROC
	PUSH		EBP
	MOV			EBP, ESP
	MOV			EDI, [EBP+12]						;mov output string offset to edi, increment EDI by length and change direction flag to accommodate algorithm that makes it backwards
	
	ADD			EDI, [EBP+16]
	DEC			EDI
	STD

	MOV			EAX, [EBP+8]
	CMP			EAX, 0								;determine in integer is positive or negative, jump to negate in order to convert to string
	PUSH		EAX
	JL			_negate									

_toString:	
	MOV			EBX, 10	
	CDQ												;divide by 10, convert/add remainder to string, divide dividend by 10 until dividend is less than 10
	IDIV		EBX				
	ADD			EDX, 48		
	MOV			ESI, EAX
	MOV			AL, DL
	STOSB
	CMP			ESI, 10
	JL			_lastDigit
	MOV			EAX, ESI
	JMP			_toString


_lastDigit:
	MOV			EDX, ESI							;Add last digit to EDI string
	ADD			EDX, 48	
	MOV			AL, DL
	STOSB
	POP			EAX
	CMP			EAX, 0
	JL			_addSign
	JMP			_endWriteVal						

_negate:											;Negate input integer for conversion
	NEG			EAX
	CMP			EAX, 10
	JL			_smallNegative
	JMP			_toString
	
_smallNegative:										;Fix for negative numbers greater than -10
	MOV			ESI, EAX
	JMP			_lastDigit

_addSign:
	MOV			ESI, EAX							;Add negative sign for negative value
	MOV			Al, 45								
	STOSB

_endWriteVal:
	CLD

	mDisplayString [EBP+12]							;use macro to display string

	MOV			EDI, [EBP+12]
	MOV			ECX, [EBP+16]
	
_clear:												;clear string input for re use
	MOV			AL, 0
	STOSB
	LOOP		_clear

	POP			EBP
	RET			12
WriteVal ENDP


END main
