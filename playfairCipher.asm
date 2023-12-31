# Anastasia Davis, Srivalli Kakumani, Jerold Manansala, and Jessica Pinto
# CS 2640.01
# December 5, 2023

# Sets of macros used in this program.
.include "basicMacros.asm"
.include "playfairMacros.asm"

.data
# Prompts and Messages
menuPrompt: .asciiz "\n\nThis is a program that contains the Playfair cipher!\nPlease enter 'E' for encode or 'D' for decode: "
phrasePrompt: .asciiz "\n\nEnter your string now: "
editedMessage: .asciiz "\nYour edited phrase is: "
encodeMessage: .asciiz "\nYour encoded phrase is: "
decodeMessage: .asciiz "\nYour decoded phrase is: "
noXMessage: .asciiz "\n\nWould you like to see the decoded phrase with the letter 'X' removed?\nPlease enter 'Y' for yes or 'N' for no: "
repeatMessage: .asciiz "\n\nWould you like to encode/decode another phrase?\nPlease enter 'Y' for yes or 'N' for no: "
errorMessage: .asciiz "\n\nSorry! That wasn't one of our options. Please try again!"
exitMessage: .asciiz "\n\nThe program will now exit."

# Cipher Table
row1: .byte 'P', 'L', 'A', 'Y', 'F'
row2: .byte 'I', 'R', 'E', 'X', 'M'
row3: .byte 'B', 'C', 'D', 'G', 'H'
row4: .byte 'K', 'N', 'O', 'Q', 'S'
row5: .byte 'T', 'U', 'V', 'W', 'Z'
table: .word row1, row2, row3, row4, row5

# Phrases throughout encryption.
phrase: .space 500
editedPhrase: .space 500
encryptedPhrase: .space 500

.text
# User interaction code (menus, prompts, etc.), as well as jumps to logic code.
main:
	# Print the menu prompt.
	printString(menuPrompt)
	# Read the user's response.
	readChar
	# Move the user's response to $t0.
	move $t0, $v0
	# If the user's input is 'E' or 'e', jump to encodeLogic.
	beq $t0, 69, encode
	beq $t0, 101, encode
	# If the user's input is 'D' or 'd', jump to decodeLogic.
	beq $t0, 68, decode
	beq $t0, 100, decode
	# Else the user's input is indecipherable, jump to error.
	jal error
	j main
encode:
	# Use $t5 to store 0 for encoding, 1 for decoding.
	move $t5, $zero
	# Format the string
	jal formatString
	# Insert logic here.
	# Print the edited string.
	printString(editedMessage)
	jal printEdited
	# Find the rows and columns of each bigram and encode them.
	# Warning! Will loop automatically!
	jal beforeFind	# This jump loops through and encodes the entire phrase!
	# Print the encoded string.
	printString(encodeMessage)
	printString(encryptedPhrase)
	# Jump to repeat, ending encode.
	j repeat
decode:
	# Use $t5 to store 0 for encoding, 1 for decoding.
	li $t5, 1
	# Format the string
	jal formatString
	# Insert logic here.
	# Print the edited string.
	printString(editedMessage)
	jal printEdited
	# Find the rows and columns of each bigram and encode them.
	# Warning! Will loop automatically!
	jal beforeFind	# This jump loops through and encodes the entire phrase!
	# Print the decoded string.
	printString(decodeMessage)
	printString(encryptedPhrase)
decodeNoX:
	# Print the No 'X' prompt.
	printString(noXMessage)
	# Read the user's response.
	readChar
	# Move the user's response to $t0.
	move $t0, $v0
	# If the user's input is 'Y' or 'y', jump to printNoX.
	beq $t0, 89, printNoX
	beq $t0, 121, printNoX
	# If the user's input is 'N' or 'n', jump to repeat.
	beq $t0, 78, repeat
	beq $t0, 110, repeat
	# Else the user's input is indecipherable, jump to error.
	jal error
	j decodeNoX
repeat:
	# Print the repeat prompt.
	printString(repeatMessage)
	# Read the user's response.
	readChar
	# Move the user's response to $t0.
	move $t0, $v0
	# If the user's input is 'Y' or 'y', jump to main.
	beq $t0, 89, main
	beq $t0, 121, main
	# If the user's input is 'N' or 'n', jump to exit.
	beq $t0, 78, exit
	beq $t0, 110, exit
	# Else the user's input is indecipherable, jump to error.
	jal error
	j repeat
error:
	# Print the error message.
	printString(errorMessage)
	# Jump back to the main menu.
	jr $ra
exit:
	# Print the exit message.
	printString(exitMessage)
	# Exit the program
	li $v0, 10
	syscall
	
	
# This code is for formatting the string so that it can be encrypted properly.
formatString:
	# Print the phrase prompt.
	printString(phrasePrompt)
	# Read the user's response.
	readString(phrase)
	# Load the base address of phrase into $s0.
	la $s0, phrase
	# Load the base address of editedPhrase into $s1.
	la $s1, editedPhrase
	# Initialize the counter for phrase.
	move $s2, $zero
	# Initialize the counter for editedPhrase.
	move $s3, $zero
	# Initialize the previous character for editedPhrase (starts with no character).
	move $t2, $zero
checkString:
	# Put the offset for phrase into $t0.
	add $t0, $s0, $s2
	# Load the appropriate character of phrase into $t1.
	lb $t1, ($t0)
	# Increment phrase counter.
	addi $s2, $s2, 1
	# Check for end of string.
	beq $t1, 0, checkNumChars
	# Check for non-letters below uppercase asciis (skip).
	blt $t1, 65, checkString
	# Check for lowercase character (make uppercase).
	bgt $t1, 90, makeUpperCase
	j jCheck
makeUpperCase:
	# Check for non-letters below/above lowercase asciis (skip).
	blt $t1, 97, checkString
	bgt $t1, 122, checkString
	# Make uppercase.
	subi, $t1, $t1, 32
jCheck:
	# Special case for 'J', convert to 'I'.
	bne $t1, 74, duplicateCheck
	li $t1, 73
duplicateCheck:
	# Check for non-duplicate letters.
	bne $t1, $t2, addChar
	# Check if editedPhrase counter is even (skip adding 'X') or odd (add 'X' to separate duplicates).
	# The result in $t3 will be 1 if odd and 0 if even.
	andi $t3, $s3, 1
	beq $t3, 0, addChar
	li $t3, 'X'
	addToString($t3)
addChar:
	addToString($t1)
	j checkString
checkNumChars:
	# Check if editedPhrase counter is even (skip adding 'X') or odd (add 'X' to make even bigrams).
	# The result in $t3 will be 1 if odd and 0 if even.
	andi $t3, $s3, 0x0001
	beq $t3, 0, afterCheckString
	li $t3, 'X'
	addToString($t3)
afterCheckString:
	# Add the null terminator.
	addToString($t1)
	# Return to encode/decode.
	jr $ra
	
	
# This code will print every character of the given phrase (either editedPhrase or encryptedPhrase) in pairs.
printEdited:
	la $s1, editedPhrase
	j print
printEncrypted:
	la $s1, encryptedPhrase
print:
	# Initialize the counter for phrase.
	move $s3, $zero
	# Syscall for printing a character.
	li $v0, 11
printLoop:
	# Put the offset for the phrase into $t0.
	add $t0, $s1, $s3
	# Load the appropriate character of the phrase into $t1.
	lb $t1, ($t0)
	# Increment phrase counter.
	addi $s3, $s3, 1
	# Check for end of string.
	beq $t1, 0, endPrint
	# Else print the character.
	la $a0, ($t1)
	syscall
	# Check if the phrase counter is odd (don't add ' ') or even (add ' ').
	# The result in $t3 will be 1 if odd and 0 if even.
	andi $t3, $s3, 0x0001
	beq $t3, 1, printLoop
	# Print space.
	li $a0, ' '
	syscall
	# Repeat
	j printLoop
endPrint:
	# Return to encode/decode.
	jr $ra
	
	
# This code will print every character of encryptedPhrase without 'X'.
printNoX:
	# Print the message for the decoded string.
	printString(decodeMessage)
	# Put the address of encryptedPhrase into $s1.
	la $s1, encryptedPhrase
	# Syscall for printing a character.
	li $v0, 11
printNoXLoop:
	# Load the appropriate character of editedPhrase into $t0.
	lb $t0, ($s1)
	# Increment to the next character of phrase.
	addi $s1, $s1, 1
	# Check for end of string. If yes, jump to repeat.
	beq $t0, 0, repeat
	# Check for the letter 'X'. If yes, skip the letter.
	beq $t0, 'X', printNoXLoop
	# Else print the character.
	la $a0, ($t0)
	syscall
	# Repeat
	j printNoXLoop
	
	
# This code finds the rows and columns for all of the bigrams in editedPhrase.
beforeFind:
	# Set $s0 to the base address for editedPhrase.
	la $s0, editedPhrase
	# $t2 will designate the first or second letter of the bigram.
	li $t2, 1
	# $t4 is the address of encryptedPhrase.
	la $t4, encryptedPhrase
findRowsAndColumns:	
	la $s1, table	# Put the address of the table into $s1.
	# $s3 is the counter for the row, $s4 is the counter for the column.
	move $s3, $zero
	move $s4, $zero
	# Put the letter of editedPhrase into $t0.
	lb $t0, ($s0)
	# Check for null terminator character.
	beq $t0, 0, afterFind
findRow:
	# Put the corresponding row into $s2.
	lw $s2, ($s1)
	# Move to the next row by incrementing row
	addi $s1, $s1, 4
	addi $s3, $s3, 1
	# Reset column counter.
	move $s4, $zero
findColumn:
	# Put the letter from the table into $t1.
	lb $t1, ($s2)
	# Check if they are equal
	beq $t0, $t1, store
	# If they are not equal increment column and repeat.
	addi $s4, $s4, 1
	addi $s2, $s2, 1
	# Check if we have reached the end of the column
	beq $s4, 5, findRow
	j findColumn
store:
	# Subtract 1 from row number to keep it consistent with column number.
	subi $s3, $s3, 1
	# Increment to the next letter of edited phrase.
	addi $s0, $s0, 1
	# Jump to cases once the second letter of the bigram has been found.
	beq $t2, 2, cases
	# Store the row and column where the letter was found.
	move $s5, $s3
	move $s6, $s4
	# Switch to the second letter of the bigram.
	li $t2, 2
	j findRowsAndColumns
afterFind:
	# Store the null terminator character in encryptedPhrase.
	sb $t0, ($t4)
	# Return to encode.
	jr $ra


# This code contains the cases used to encode bigrams.
# 1. (Jerold) If the letters are on the same row, replace each with the letter immediately to the right (wraparound).
# 2. (Srivalli) If the letters are in the same column, replace each with the letter immediately below (wraparound).
# 3. (Ana & Jess) Else, replace with the letter in the same column as one letter and same row as the other.
#	(Make a box out of the two letters, the missing corners are your new letters)
#	Replace each letter with the corner letter in the **same row** as it.
# $s5 and $s6 are the first letter's row and column, respectively.
# $s3 and $s4 are the second letter's row and column, respectively.
cases:
	# Go to encodeCases if 0 or decodeCases if 1.
	beq $t5, 1, decodeCases
encodeCases:
	# If the rows are equal, encode using first rule, if columns are equal, encode using second rule.
	beq $s3, $s5, encodeCase1
	beq $s4, $s6, encodeCase2
	# Else, encode using third rule.
	j case3
encodeCase1:
    # Since rows are equal, each character of bigram becomes the character in the next column or wraps around.
    addi $s4, $s4, 1
    addi $s6, $s6, 1 
    beq $s4, 5, wrapColumn1
    beq $s6, 5, wrapColumn2 
    # Jump to end of cases. 
    j afterCase     
# If first character's column is greater than 4, wrap around. 
wrapColumn1: 
    li $s4, 0
    beq $s6, 5, wrapColumn2 
    j afterCase 
# If second character's column is greater than 4, wrap around. 
wrapColumn2: 
    li $s6, 0 
    j afterCase
encodeCase2:
    # Since columns are equal, each character of bigrams becomes the character in the next row or wraps around. 
    addi $s3, $s3, 1
    addi $s5, $s5, 1 
    # If either character is in the last row, wrap it around to the top row. 
    beq $s3, 5, wrapRow1
    beq $s5, 5, wrapRow2 
    # Jump to end of cases. 
    j afterCase     
# If first character's row is greater than 4, wrap around. 
wrapRow1: 
    li $s3, 0   # Set row of the first letter to 0 (wrap around)
    beq $s5, 5 wrapRow2  # Jump to wrapRow2 for the second letter
    j afterCase
# If second character's row is greater than 4, wrap around. 
wrapRow2: 
    li $s5, 0 
    j afterCase
decodeCases:
	# If the rows are equal, decode using first rule, if columns are equal, decode using second rule.
	beq $s3, $s5, decodeCase1
	beq $s4, $s6, decodeCase2
	# Else, decode using third rule.
	j case3
decodeCase1:
	# Subtract 1 from the column to get the letter to the left.
	subi $s4, $s4, 1
	# Check for a negative value.
	bge $s4, 0, decodeCase1Part2
	# Wrap around.
	li $s4, 4
decodeCase1Part2:
	# Subtract 1 from the column to get the letter to the left.
	subi $s6, $s6, 1
	# Check for a negative value.
	bge $s6, 0, afterCase
	# Wrap around.
	li $s6, 4
	j afterCase
decodeCase2:
	# Subtract 1 from the row to get the letter above.
	subi $s3, $s3, 1
	# Check for a negative value.
	bge $s3, 0, decodeCase2Part2
	# Wrap around.
	li $s3, 4
decodeCase2Part2:
	# Subtract 1 from the row to get the letter above.
	subi $s5, $s5, 1
	# Check for a negative value.
	bge $s5, 0, afterCase
	# Wrap around.
	li $s5, 4
	j afterCase
case3:
	# Swap the columns to get the column values for the new letters.
	move $s7, $s6
	move $s6, $s4
	move $s4, $s7
	j afterCase
afterCase:
	# Add the two letters to encryptedPhrase
	addBigram
	# Reset to first letter of bigram and repeat.
	li $t2, 1
	j findRowsAndColumns
