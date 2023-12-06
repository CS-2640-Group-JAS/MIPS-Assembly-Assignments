# Anastasia Davis, Srivalli Kakumani, Jerold Manansala, and Jessica Pinto
# CS 2640.01
# December 5, 2023
# A collection of macros that are good for general use.

.macro readChar
	li $v0, 12
	syscall
.end_macro
.macro printString(%string)
	li $v0, 4
	la $a0, %string
	syscall
.end_macro
.macro readString(%phrase)
	li $v0, 8
	la $a0, %phrase
	li $a1, 499
	syscall
.end_macro
