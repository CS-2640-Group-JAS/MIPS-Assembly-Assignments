# Anastasia Davis, Srivalli Kakumani, Jerold Manansala, and Jessica Pinto
# CS 2640.01
# December 5, 2023
# Macros specifically adapted for use in the playfairCipher.asm program.
.macro addToString(%char)
	# Put the offset for editedPhrase into $t0.
	add $t0, $s1, $s3
	sb %char, ($t0)
	# Increment editedPhrase counter.
	addi $s3, $s3, 1
	# Move char to previous character for editedPhrase.
	move $t2, %char
.end_macro
.macro addBigram
	# Put the address of the table into $s1.
	la $s1, table
	# Put the corresponding row into $s2.
	mul $s5, $s5, 4
	add $s1, $s1, $s5
	lw $s2, ($s1)
	# Put the letter into $t1, and then encrypted phrase.
	add $s2, $s2, $s6
	lb $t1, ($s2)
	sb $t1, ($t4)
	# Increment encryptedPhrase to next byte.
	addi $t4, $t4, 1
	# Put the address of the table into $s1.
	la $s1, table
	# Put the corresponding row into $s2.
	mul $s3, $s3, 4
	add $s1, $s1, $s3
	lw $s2, ($s1)
	# Put the letter into $t1, and then encrypted phrase.
	add $s2, $s2, $s4
	lb $t1, ($s2)
	sb $t1, ($t4)
	# Increment encryptedPhrase to next byte.
	addi $t4, $t4, 1
.end_macro
