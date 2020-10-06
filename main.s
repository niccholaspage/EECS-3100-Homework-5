;*******************************************************************
; main.s
; Author: Nicholas Nassar
; Date Created: 10/04/2020
; Last Modified: 10/06/2020
; Section Number: Lecture 001, Lab 002
; Instructor: Devinder Kaur
; Homework Number: 5
;   Includes 5 functions that implement
;	the functionality required from
;	homework 5.
;*******************************************************************

	AREA	DATA, READONLY
; Defines an array named MEAN_ARRAY with 10 elements in the DATA section
MEAN_ARRAY	DCD 1,2,3,4,5,6,7,8,9,10
	AREA    |.text|, CODE, READONLY, ALIGN=2
	THUMB
	EXPORT  Start

Start
	; Question 1 Testing
	MOV R0, #0x89AB
	MOVT R0, #0xCDEF
	; This converts R0 to 0xAB89 EFCD, converting endian
	BL ConvertEndian
	; Question 2 Testing
	; This calculates the mean of the ten
	; integers in the array and returns the
	; mean.
	BL CalculateMeanOfTenIntegers
	; Question 3 Testing
	; This returns -1 if x is negative,
	; 0 if x == 0,
	; and +1 if x is positive.
	MOV R0, #-10
	BL CalculateFunction
	; Question 4 Testing
	MOV R0, #0x7
	MOV R1, #0x5
	MOV R2, #0x6
	; This returns the minimum value
	; between all parameters.
	BL FindMinimalValue
	; Question 5 Testing
	MOV R0, #5 ; x = 5
	MOV R1, #10 ; y = 10
	; The result of this subroutine should
	; be 5^10 or 9,765,625.
	BL Power

; Endless loop, since we are an
; embedded program.
loop   B    loop

; Converts between 32-bit little
; endian and big endian numbers.
; Parameters:
; R0 - Number to convert
; Return value:
; Number converted (R0)
ConvertEndian
	LSR R1, R0, #24 ; Shift R0 to the right by 3 bytes, to isolate the last byte into R1
	LSL R2, R0, #24 ; Shift R0 to the left by 3 bytes, to isolate the first byte into R2
	ORR R3, R1, R2 ; Logical OR R1 & R2 into a temporary R3
	LSR R1, R0, #8 ; Shift R0 one byte to the right, to prepare the third byte, storing into R1
	BIC R1, R1, #0xFF00FF ; Clear all bytes in R1 except for the third one
	ORR R3, R3, R1 ; Logical OR R3 & R1 into R3
	LSL R2, R0, #8 ; Shift R0 to the left a byte and store the result into R2 to prepare the second byte
	MOV R1, #0xFF00FFFF ; Move our mask into R1 for bit clear
	BIC R2, R2, R1 ; Perform bit clear on R2 with a mask of R1
	ORR R0, R3, R2 ; Logical OR R3 and R2, giving us our final reversed result into R0.
	BX LR ; Go back to the caller.

; Calculates the mean of the
; ten integers stored in the
; MEAN_ARRAY array.
; Return value:
; Mean (R0)
CalculateMeanOfTenIntegers
	LDR R0, =MEAN_ARRAY ; Load the address of the first element in the array into R0
	MOV R2, #0 ; Our offset - we start at 0
	MOV R3, #0 ; Our total, adding all the elements
MeanLoop
	LDR R1, [R0, R2] ; R1 = MEAN_ARRAY[i]
	ADD R3, R3, R1 ; Add our element R1 to our total
	ADDS R2, #4 ; offset += 4
	CMP R2, #40 ; We have ten elements in the array, 10 * 4 bytes - 40
	BLO MeanLoop ; Go back to the loop if we haven't hit 9 yet
	MOV R2, #10 ; We are gonna divide by 10
	UDIV R0, R3, R2 ; Divide our total by 10, and store the value in R0, and we are done!
	BX LR ; Go back to the caller.

; Calculate the function as specified
; in question 3.
; Parameters:
; R0 - x
; Return value:
; -1, 0, or 1 (R0)
CalculateFunction
	CMP R0, #0 ; Check if R0 == 0
	BEQ ReturnZero ; If it is zero, we branch to return 0.
	BLT ReturnNegativeOne ; If it is less than 0, return negative 1.
	MOV R0, #1 ; We want to return 1 because x > 0
	BX LR ; Go back!
ReturnNegativeOne
	MOV R0, #-1 ; Return -1, since x < 0
ReturnZero
	; Since R0 is already 0, we don't have to set R0 so we are good.
	BX LR

; Finds the minimal value of three signed integers
; a, b, and c.
; Parameters:
; R0 - a (first int)
; R1 - b (second int)
; R2 - c (third int)
; Return value:
; Minimal value (R0)
FindMinimalValue
	CMP R0, R1 ; Compare a and b
	BLT Continue ; If A < B, go to continue
	MOV R0, R1 ; Set A to B since we just care about B and C at this point
Continue
	CMP R0, R2 ; Compare A/B to C
	BLT ReturnR0 ; A/B < C, so return A/B
	MOV R0, R2 ; C < A/B, so return C
ReturnR0
	BX LR

; Calculates the result of x
; raised to the power of y.
; x, y, and the result are
; signed integers.
; Parameters:
; R0 - x (the number we will raise)
; R1 - y (the exponent, which cannot be negative!)
Power
	CMP R0, #1 ; See if x == 1, since 1 ^ anything == 1
	BEQ ResultIsOne
	CMP R1, #0 ; See if y == 0, since anything raised to 0 == 1
	BEQ ExponentIsZero ; If it is, just go to the exponent is zero branch
	CMP R1, #1 ; If y == 1, then we just return x, since anything raised to 1 == x
	BEQ ExponentIsOne ; Go to ExponentisOne
	; At this point, we have to actually raise x by the exponent y
	MOV R2, #1 ; Setup a result register, initialized to 1
	; To do so, we will multiply x * x until y == 1
MultiplyXByItself
	MUL R2, R2, R0 ; Multiply R2 (our result) by x
	SUBS R1, R1, #1 ; Subtract 1 from R1, set condition flags
	BNE MultiplyXByItself ; We multiply x by itself again since if y != 1
	MOV R0, R2 ; Finally, put the result into R0
	BX LR ; Return back!
ResultIsOne
	MOV R0, #1 ; Our result is one, so just set R0
	BX LR ; and go back!
ExponentIsZero
	MOV R0, #1 ; Return 1 as our result
	BX LR ; Go back!
ExponentIsOne
	; R0 is already x so we are good!
	BX LR ; Go back

       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file
       