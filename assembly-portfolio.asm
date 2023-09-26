TITLE Project 6   (Proj6_estrasab.asm)

; Author: Sabrina Estrada
; Last Modified: 03/07/2023
; OSU email address: estrasab@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 6                Due Date: 03/19/2023
; Description: User will input a number small enough to fit in a 32 bit register. After 10 valid inputs, the program will
; display the list of integers their sum, and their average value. This program uses macros and string primitives to convert
; user input string to a decimal and then back to a string without the use of ReadInt/ReadDec/WriteInt/WriteDec. Extra credit
; has been implemented to display the running subtotal of the user's inputs and number the amount of valid entries.

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------
; Name: mGetString
; 
; Display a prompt (input parameter, by reference), then gets 
; the user’s keyboard input into a memory location (output parameter, by reference). 
; It also gets the user inputs length (max bytes to read), and gets the bytes read.
; 
; Receives:
; num_prompt	= prompt address
; input_buffer	= user_input address
; buffer_length	= user_input_length value (max bytes to read)
; bytes_read	= user_input_bytes address (bytes read)
;
; returns: Writes num_prompt to console. The bytes read from input_buffer to bytes_read. 
; The input buffer stores the generated string characters of user's input
; ---------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------

mGetString MACRO num_prompt, input_buffer, buffer_length, bytes_read

	PUSH	EDX		
	PUSH	ECX
	PUSH	EBX
	PUSH	EAX

	MOV		EDX, num_prompt
	CALL	WriteString

	MOV		EDX, input_buffer
	MOV		ECX, buffer_length
	CALL	ReadString
	
	MOV		EBX, bytes_read
	MOV		[EBX], EAX

	POP		EAX
	POP		EBX
	POP		ECX
	POP		EDX

ENDM

; -----------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------
; Name: mDisplayString  
; 
; Prints the string which is stored in a specified memory location (input parameter, by reference).
;
; Receives: 
; input_string = address of global string
; 
; returns: writes input_string to console
; -----------------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------------

mDisplayString MACRO input_string 
	
	PUSH	EDX
	
	MOV		EDX, input_string
	CALL	WriteString

	POP		EDX

ENDM

SUMMATIONSIZE = 1001
AVERAGESIZE = 1001
ARRAYSIZE = 10
MAX_CHAR = 50

.data

program_title			BYTE	"PROGRAMMING ASSIGNMENT: Designing low-level I/O procedures", 13, 10, 0
programmer_name			BYTE	"Written by: Sabrina Estrada", 13, 10, 0
program_extracredit		BYTE	"**Number each line of user input and display a running subtotal of the user's valid numbers.", 0
program_description		BYTE	"Please provide 10 signed decimal integers.", 13, 10
						BYTE	"The size of every number should not exceed the capacity of a 32-bit register.", 13, 10
						BYTE	"After you have finished inputting 10 valid integers I will display a list of the numbers, the sum, and the average value.", 13, 10, 0
prompt_user				BYTE	"Please enter an signed number: ", 0

invalid_message			BYTE	"ERROR: You did not enter an signed number or your number was too big.", 0
try_again_message		BYTE	"Please try again: ", 0
user_input				BYTE	MAX_CHAR DUP (?)
user_input_length		DWORD	SIZEOF user_input
user_input_bytes		DWORD	?
num_digits_list			DWORD	ARRAYSIZE DUP(?)
sign_in_front			DWORD	0
valid_num				SDWORD	0
valid_num_list			SDWORD	ARRAYSIZE DUP(?)


write_val_string		BYTE	MAX_CHAR DUP (0)
display_ten_nums		BYTE	"You entered the following numbers:", 0
comma_string			BYTE	",", 0
spacer_string			BYTE	" ", 0

sum_message				BYTE	"The sum of these numbers is: ", 0
summation_nums_length	DWORD	LENGTHOF summation_string
summation_string		DWORD	SUMMATIONSIZE DUP(?)
summation_nums			SDWORD	?

truncated_average		BYTE	"The truncated average is: ", 0
average_string			DWORD	AVERAGESIZE DUP(?)
valid_nums_avg			SDWORD	?

period_string			BYTE	". ", 0
subtotal_string			BYTE	"Subtotal of valid numbers entered: ", 0
extra_credit_counter	DWORD	0
extra_credit_string		DWORD	SUMMATIONSIZE DUP(?)
extra_credit_sum		SDWORD	0

farewell_string			BYTE	"Thanks for using my program, goodbye!", 0

.code
main PROC
	
	PUSH	OFFSET program_extracredit
	PUSH	OFFSET program_title
	PUSH	OFFSET programmer_name
	PUSH	OFFSET program_description
	CALL	introduction

	
	MOV		ESI, OFFSET valid_num_list
	MOV		ECX, ARRAYSIZE							; set the counter to 10
	MOV		EDI, OFFSET extra_credit_counter		; variable to store the counter integer

; Get 10 valid inputs from the user

_Valid_num_loop:
	MOV		EDI, OFFSET extra_credit_counter
	MOV		EBX, [EDI]
	INC		EBX
	MOV		[EDI], EBX
	
	PUSH	OFFSET extra_credit_string				
	PUSH	EBX
	CALL	WriteVal								; write the count (extra credit) to the console

	mDisplayString	OFFSET period_string			; writes the period to the console

	PUSH	ESI
	PUSH	OFFSET sign_in_front
	PUSH	OFFSET try_again_message
	PUSH	OFFSET valid_num
	PUSH	OFFSET invalid_message
	PUSH	OFFSET user_input_bytes
	PUSH	OFFSET user_input_length
	PUSH	OFFSET user_input
	PUSH	OFFSET prompt_user
	CALL	ReadVal

; Calculate the subtotal of the valid inputs

	mDisplayString	OFFSET subtotal_string			; writes subtotal string to console

	MOV		EBX, [ESI]								; gets the user input
	MOV		EDI, OFFSET extra_credit_sum			; variable that holds the subtotal
	MOV		EAX, [EDI]								
	ADD		EAX, EBX								; add the stored subtotal to the user's recent input
	MOV		[EDI], EAX								; store that value into the extra_credit_sum variable

	PUSH	OFFSET extra_credit_string
	PUSH	EAX
	CALL	WriteVal								; writes the subtotal value to the console

; Done with subtotal calculation, increment to get next valid number

	ADD		ESI, 4									; inc to store the next valid_num_list index
	CALL	CrLf
	LOOP	_Valid_num_loop

	CALL	CrLf

	mDisplayString	OFFSET display_ten_nums
	
	CALL	CrLf

	MOV		ECX, ARRAYSIZE							; set the counter to display the valid nums
	MOV		ESI, OFFSET valid_num_list

; Display the 10 user input valid numbers

_Display_valid_nums_loop:
	PUSH	OFFSET write_val_string
	MOV		EAX, [ESI]
	PUSH	EAX
	CALL	WriteVal								; writes the valid number to console
	
	ADD		ESI, 4

	CMP		ECX, 1
	JE		_Find_sum								; stop display loop after last value is written to console

	mDisplayString OFFSET comma_string
	mDisplayString OFFSET spacer_string

	LOOP	_Display_valid_nums_loop	

; Calculate the sum of all the valid number inputs

_Find_sum:
	CALL	CrLf
	CALL	CrLf

	mDisplayString OFFSET sum_message
	
	PUSH	OFFSET summation_nums
	PUSH	OFFSET valid_num_list
	CALL	CalculateSum

	MOV		ESI, OFFSET summation_nums

; Display the sum value to console

	PUSH	OFFSET summation_string
	MOV		EAX, [ESI]
	PUSH	EAX										; push the value of the sum 
	CALL	WriteVal

	CALL	CrLf
	CALL	CrLf

	mDisplayString OFFSET truncated_average

; Calculate the average value of the valid input numbers

	PUSH	OFFSET summation_nums					; summation_nums address that stores the sum 
	PUSH	OFFSET valid_nums_avg	
	CALL	CalculateAvg

	MOV		ESI, OFFSET valid_nums_avg

; Display the calculated average

	PUSH	OFFSET average_string	
	MOV		EAX, [ESI]
	PUSH	EAX
	CALL	WriteVal								; display the calculated average

	CALL	CrLf
	CALL	CrLf

; Display the farewell message 

	PUSH	OFFSET farewell_string	
	CALL	farewell

	INVOKE  ExitProcess, 0

main ENDP

; ---------------------------------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------
; Name: introduction
; 
; Introduces the program title and promgrammer, displays
; the description of the program
; 
; Preconditions: global variable program_extracredit, program_title, programmer_name, 
; program_description passed on the stack as parameters to the correct address
; 
; Postconditions: prints program_extracredit, program_title, programmer_name, and program_description
; to the console using mDisplayString Macro.
; 
; Receives: 
;		[EBP+8]		= program_description
;		[EBP+12]	= programmer_name
;		[EBP+16]	= program_title
;		[EBP+20]	= program_extracredit
; 
; returns: writes variables program_extracredit, program_title, programmer_name, 
; program_description to the console
; ---------------------------------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------

introduction PROC

	PUSH    EBP
    MOV     EBP, ESP

	mDisplayString [EBP+16]
	CALL	CrLf

	mDisplayString [EBP+12]
	CALL	CrLf

	mDisplayString	[EBP+20]
	CALL	CrLf
	CALL	CrLf

	mDisplayString [EBP+8]
	CALL	CrLf

	POP		EBP
	RET		16

introduction ENDP

; -------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------
; Name: ReadVal 
; 
; Invoke the mGetString macro (see parameter requirements above) to get user input in the form of a 
; string of digits.Convert (using string primitives) the string of ascii digits to its numeric 
; value, validates the user’s input is a valid number. Stores the converted value into an array
;  
; Preconditions: global variables valid_num_list, sign_in_front, try_again_message, valid_num, invalid_message,
; user_input_bytes, user_input_length, user_input, prompt_user passed on the stack as parameters to the correct address.
; 
; Postconditions: changes registers AL, EAX, EBX, ECX, EDX, ESI, and EDI. prints prompt_user to the console using
; mDisplayString macro, and invalid_message and try_again_message (if invalid number entered)
; 
; Receives: 
;			[EBP+8]		= prompt_user address
;			[EBP+12]	= user_input address
;			[EBP+16]	= user_input_length address
;			[EBP+20]	= user_input_bytes address
;			[EBP+24]	= invalid_message address
;			[EBP+28]	= valid_num address
;			[EBP+32]	= try_again_message address
;			[EBP+36]	= sign_in_front address
;			[EBP+40]	= valid_num_list address
;
; returns: Writes prompt_user to the console. Writes invalid_message and try_again_message to the console if user enters
; invalid number. Converted user_input stored to valid_num_list
; -------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------

ReadVal PROC
	
	PUSH    EBP
    MOV     EBP, ESP

	PUSHAD

	MOV		EAX, [EBP+16]							; address to user_input_length
	MOV		EAX, [EAX]
	MOV		EDX, [EBP+8]							; address to prompt_user	

_Get_user_input:

	mGetString	EDX, [EBP+12], EAX, [EBP+20]

	MOV		ECX, [EBP+20]							; address to bytes read
	MOV		ECX, [ECX]								; get the bytes read (number of chars in the string array)
	MOV		EBX, [EBP+28]							; address to valid_num
	MOV		EBX, [EBX]								; value in valid_num (starting value to convert to string to value)

; check if there are is a plus or minus sign in front
	MOV		ESI, [EBP+12]							; address to user_input
	LODSB
	CMP		AL, '+'
	JE		_Positive_int
	CMP		AL, '-'
	JE		_Negative_int

; uses the algorithm from modules to convert characters to a integer
_Convert_char_to_number:	

; check if there are any invalid characters in the user's input
	CMP		AL, 48
	JL		_Invalid_num
	CMP		AL, 57
	JG		_Invalid_num

; subtract numChar by 48
	MOVZX   EDX, AL
	SUB		EDX, 48
	PUSH	EDX

; multiply valid_num by 10
	MOV		EAX, 10
	IMUL	EBX
	
; add the multiplication result to the subtraction result
	POP		EDX
	ADD		EAX, EDX
	MOV		EBX, EAX
	CMP		EBX, 2147483648								; check to make sure the user is small enough to fit in a 32 bit register
	JA		_Invalid_num
	
	LODSB
	LOOP	_Convert_char_to_number

; check if the number is had a negative sign in front
	MOV		EAX, [EBP+36]								; address to sign_in_front variable
	MOV		EAX, [EAX]
	CMP		EAX, 1										; if 1 = negative, 0 = positive value
	JE		_Convert_to_negative
	CMP		EBX, 2147483647								; check to make sure program rejects any value above 2147483647	
	JA		_Invalid_num

; after conversion, store number in valid_num_list
_After_conversion:										
	MOV		ESI, [EBP+40]
	MOV		[ESI], EBX									; store the user input number in valid_num_list

	MOV		EDI, [EBP+36]								
	MOV		EAX, 0		
	MOV		[EDI], EAX									; reset sign in front back to 0 

	POPAD

	POP		EBP
	RET		36

_Positive_int:
	DEC		ECX											; decrease the counter to skip/drop the + conversion
	MOV		EDX, [EBP+20]								; address to user_input_bytes
	MOV		[EDX], ECX									; update the value of user_input_bytes
	LODSB
	JMP		_Convert_char_to_number

_Negative_int:
	DEC		ECX
	MOV		EAX, 1										; address to sign_in_front variable
	MOV		EDI, [EBP+36]
	MOV		[EDI], EAX									; store sign_in_front as 1 make sure the conversion turns it into a negative integer
	LODSB	
	CMP		AL, 0										; edge case for when the user enters -0
	JE		_Is_positive
	JMP		_Convert_char_to_number						; else go back to the loop to convert to number

_Is_positive:											; handles edge case for when user enters -0
	MOV		EDX, [EBP+20]								; address to bytes to read
	MOV		[EDX], ECX	
	MOV		EAX, 1
	MOV		EDI, [EBP+36]								; address to sign_in_front
	MOV		[EDI], EAX									; make sure it reads -0 as a positive number
	LODSB	
	JMP		_Convert_char_to_number

_Convert_to_negative:
	CMP		EBX, 2147483648								; if its a negative number below the limit of a 32 bit register, its invalid
	JA 		_Invalid_num
	NEG		EBX											; convert it to the signed int using neg
	JMP		_After_conversion						

_Invalid_num:
	mDisplayString	[EBP+24]							; address to error message, display error message
	CALL	CrLf
	MOV		EDX, [EBP+32]								; address to please try again message
	
	MOV		EBX, [EBP+28]								; address to valid_num
	XOR		EBX, EBX									; clear it for the next user input

	MOV		EBX, 0

	MOV		EAX, [EBP+36]								; address to sign_in_front, resets it to 0
	MOV		[EAX], EBX		

	MOV		EAX, [EBP+16]								; address to user_input_length
	MOV		EAX, [EAX]									
	
	JMP		_Get_user_input								; if invalid reprompt the user to get a valid number

ReadVal ENDP

; ---------------------------------------------------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------
; Name: WriteVal 
; 
; Converts a numeric SDWORD value (input parameter, by value) to a string of ASCII digits. Invokes mDisplayString 
; to print the ASCII representation to the console.
; 
; Preconditions: variables of the input parameter (by value) and string to store the converted characters are
; passed on the stack as parameters to the correct address.
; 
; Postconditions: changes registers AL, DL, EAX, EBX, ECX, EDX, ESI, and EDI. changes the input string array to store
; the characters of the converted value.
; 
; Receives: 
;			[EBP+8]		= value of integer to be converted
;			[EBP+12]	= string array address
; 
; returns: invokes mDisplayString and writes the value to the console after converting to string.
; ---------------------------------------------------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------

WriteVal PROC

	PUSH    EBP
    MOV     EBP, ESP

	PUSHAD

	MOV		EDI, [EBP+12]								; address to string array to store characters of converted value
	
	MOV		ESI, [EBP+8]								; address to value that will be converted
	MOV		EAX, ESI									
	MOV		EBX, EAX									; store the value in EBX
	MOV		ECX, 0										; counter to count how many characters there are
	CMP		EBX, 0										; check if we need to add a negative sign in front
	JL		_Negative_num

; converts value to characters using the algorithm from modules but in reverse

_Convert_to_char_loop:
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX
	PUSH	EAX
	ADD		EDX, 48
	MOV		AL, DL
	STOSB												; store character into the string array
	
	INC		ECX

	POP		EAX
	
	CMP		EAX, 0
	JNE		_Convert_to_char_loop

	MOV		EBX, 0										; pointer to the first index of the left side of the string array (EBX will be used as left index pointer)

	MOV		EDI, [EBP+12]								; point to the beginning of the string array to reverse
	MOV		AL, [EDI]
	CMP		AL, "-"
	JE		_Sign_in_front
	
	DEC		ECX											; decrement to move the right index (ECX will be used as a right index pointer)
	JMP		_Reverse_string

; loop to reverse the contents of the string array
_Reverse_string:
	CMP     EBX, ECX
    JGE     _Done_reversing

    MOV     AL, [EDI+EBX]
    MOV     DL, [EDI+ECX]
    MOV     [EDI+EBX], DL
    MOV     [EDI+ECX], AL

    INC     EBX
    DEC     ECX
    JMP     _Reverse_string

_Done_reversing:
	MOV		EDI, [EBP+12]								; address to string array

	mDisplayString	EDI									; display the value from the characters after conversion and reversing

	MOV		ECX, 0										; clear the string to have it be ready for next value 

_Clear_string:
	MOV		BYTE PTR [EDI+ECX], 0
	INC		ECX
	CMP		ECX, 11
	JNE		_Clear_string

	POPAD

	POP		EBP
	RET		8

_Sign_in_front:
	INC		EBX											; if there is a negative sign in front, move the left starting index up to ignore when reversing string
	JMP		_Reverse_string

_Negative_num:
	MOV		AL, "-"										; negative number will append a - character in beginnging of the string array
	STOSB
	NEG		EBX											; revert the number back to its postive value
	MOV		EAX, EBX
	JMP		_Convert_to_char_loop

WriteVal ENDP

; ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------
; Name: CalculateSum
; 
; Calculates the sum from the valid_num list
; 
; Preconditions: the global variables summation_nums and valid_num_list are passed on the stack 
; as parameters to the correct address.
; 
; Postconditions: changes registers EAX, EBX, ECX, ESI, and EDI. changes the contents of summation_nums
; 
; Receives: 
;			[EBP+8]		= valid_num_list array address
;			[EBP+12]	= summation_nums address
; 
; returns: sum of the valid_num_list stored in summation_nums
; ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------

CalculateSum PROC
	PUSH    EBP
    MOV     EBP, ESP

	PUSHAD

	MOV		ECX, ARRAYSIZE

	MOV		EDI, [EBP+12]								; address to summation_nums

	MOV		ESI, [EBP+8]								; address to valid_num_list array

	MOV		EAX, [EDI]									; move the value of summation_nums to EAX 
		
; add up values stored in valud_num_list array
_Calculate_valid_nums:
	MOV		EBX, [ESI]
	ADD		EAX, EBX
	ADD		ESI, 4
	DEC		ECX
	CMP		ECX, 0
	JNE		_Calculate_valid_nums
	
	MOV		[EDI], EAX									; store the sum in summation_nums
	
	POPAD
	
	POP		EBP
	RET		8

CalculateSum ENDP

; ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------
; Name: CalculateAvg
; 
; Calculates the truncated average of the user input values
; 
; Preconditions: global variables summation_nums and valid_nums_avg are passed on the stack as parameters 
; to the correct address.
; 
; Postconditions: changes registers EAX, EBX, ESI, and EDI. changes contents of valid_nums_avg
; 
; Receives: 
;			[EBP+8]		= summation_nums address
;			[EBP+12]	= valid_nums_avg
;			ARRAYSIZE is a constant
; 
; returns: calculated truncated average is stored in the valid_nums_avg variable
; ----------------------------------------------------------------------------------------------------------
; ----------------------------------------------------------------------------------------------------------

CalculateAvg PROC
	PUSH    EBP
    MOV     EBP, ESP

	PUSHAD

	MOV		ESI, [EBP+12]								; address to summation_nums
	MOV		EDI, [EBP+8]								; address to valid_nums_avg

	MOV		EAX, [ESI]									; value of summation_nums
	MOV		EBX, ARRAYSIZE

	CDQ 
	IDIV	EBX
	MOV		[EDI], EAX									; stores the truncated average to valid_nums_avg variable

	POPAD

	POP		EBP
	RET		8

CalculateAvg ENDP

; --------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------
; Name: farewell 
; 
; Displays the farewell message
; 
; Preconditions: the global variable farewell_string are passed on the stack as parameters 
; to the correct address.
; 
; Postconditions: changes register ESI, prints farewell_string to console using mDisplayString
; Macro 
;
; Receives: 
;			[EBP+8]		= address to farewell_string
; 
; returns: writes farewell_string to console by invoking mDisplayString
; --------------------------------------------------------------------------------------------
; --------------------------------------------------------------------------------------------

farewell PROC
	PUSH    EBP
    MOV     EBP, ESP

	PUSHAD

	MOV		ESI, [EBP+8]		; address to farewell_string
	mDisplayString	ESI
	CALL	CrLf

	POPAD

	POP		EBP
	RET		4

farewell ENDP

END main
