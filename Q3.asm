# Title - Maman 11(Question 3)
# Author - Ori Nave
# Date - 15/08/24

####################
# Description:
# The program will check whether a given string is a palindrome or not a palindrome.
# If the string is a palindrome then a message that it's a palindrome will be displayed.
# If the string is not a palindrome then a message that it's not a palindrome will be displayed with the number of unidentical spots.
# In conclusion:
# Input - String that it's maximum length is 31 characters.
# Output:
#	If the string is palindrome - "The string is a palindrome"
#	If the string isn't a palindrome - "The string is not a palindrome" + the amount of unidentical spots
      
########## Data Segment ##########
.data
	String: .space 31
	newLine: .asciiz "\n"
	enterStringMessage: .asciiz "Please enter a string \n"
	palindromeAnnoucement: .asciiz "The string is a palindrome"
	notPalindromeAnnoucement: .asciiz "The string is not a palindrome"
	
########## Code Segment ##########
.text
	li $v0, 4 # $v0 = 8(Syscall to print a string)
	la $a0, enterStringMessage
	syscall

	li $v0, 8 # $v0 = 8(Syscall to read a string)
	la $a0, String # $a0 = String address
	li $a1, 31 # $a1 = amount of bytes we want to read = 31
	syscall
	
	li $t0, 0 # $t0 = iterator
	
	#Check if the character '\n' exists in String and replaces it with the null terminator('\0')
	ADD_NULL_TERMINATOR:
		lb $t1, String($t0)
		beq $t1, '\n', REPLACE
		beq $t1, '\0', END_LOOP
		addi $t0, $t0, 1
		j ADD_NULL_TERMINATOR
		
	REPLACE:
		sb $zero, String($t0) #Replace '\n' with '\0'
	
	END_LOOP:
	
	li $t0, 0 # $t0 = iterator
	
	#Calculates string length
	CALCULATE_STRING_LENGTH:
		lb $t1, String($t0)
		beq $t1, $zero, END_CALCULATION
		addi $t0, $t0, 1
		j CALCULATE_STRING_LENGTH
	
	END_CALCULATION:
		move $t2, $t0 #The register t2 will hold String's length
	
	li $t3, 0 # $t0 = counter of inequalites
	li $t4, 0 # $t4 = first index of String
	subi $t5, $t2, 1 # $t5 = last index of String
	
	
	PALINDROME_TEST:
		bge $t4, $t5, PALINDROME_DONE #If the registers equal or crossed each other the we finished the calculation
		
		lb $t6, String($t4)
		lb $t7, String($t5)
		bne $t6, $t7 NOT_IDENTICAL
		addi $t4, $t4, 1
		subi $t5, $t5, 1
		j PALINDROME_TEST
		
	NOT_IDENTICAL:
		addi $t3, $t3, 1
		addi $t4, $t4, 1
		subi $t5, $t5, 1
		j PALINDROME_TEST
	
	PALINDROME_DONE:
	
	li $v0, 1 #Syscall code for print an integer
	move $a0, $t3 # $a0 = The amount of "not identical" characters.
	syscall
	
	li $v0, 4 #Syscall code for printing a string
	la $a0, newLine #Print a new line to make the code more readable
	syscall
	
	bne $t3, $zero, NOT_A_PALINDROME
	
	li $v0, 4 #Syscall code for print a string
	la $a0, palindromeAnnoucement
	syscall
	j END_Q3
	
	NOT_A_PALINDROME:
		li $v0, 4
		la $a0, notPalindromeAnnoucement
		syscall
	
	END_Q3:
