# Title - Maman 11(Question 4)
# Author - Ori Nave
# Date - 15/08/24

########################################
# Algorithm Description:
# 1) The program recieve from the user a string at the maximum length of 36 characters.
#    The characters are hexadecimal pairs seperated by '$' and the string ends with '$'.
#    The string saved in an array called stringhex
# 2) The program checks if the string is valid according to the rules in the previous section.
#    If the input is invalid -> The user will be asked to enter a new string.
# 3) The program will convert each pair to act as one element and store it in an array called NUM
# 4) The program will sort NUM elements from big to small using a similar algorithm to Selection Sort(holding maximum instead of minimum),
#    The sort will be according to unsign method and the elements will store in an array called unsign. 
# 5) The program will sort NUM elements from big to small using a similar algorithm to Selection Sort(holding maximum instead of minimum),
#    The sort will be according to sign method(Two's complement method) and the elements will store in an array called sign.
# 6) The program will print all the elements of unsign in their decimal form.
# 7) The program will print all the elements of sign in their decimal form.
# In conclusion:
# Input - String in length of 36 characters that composed of hexadecimal pairs seperated by '$', also last character must be '$'
# Output - Sorted form of the pairs in unsign method and Sorted form of the pairs in sign method(Two's complement method) - both after conversion to decimal presentation

########################################
# Registers Document:
# $v0 - Used for syscalls
# $a0 - The address of stringhex(used also for syscalls).
# $a1 - The amount of hexadecimal pairs in a valid stringex input(used also for syscalls).
# $a2 - The address of NUM.
# $a3 - The address of unsign, later on the address of sign and
# $t0-$t9 - Temporaries registers that used along the code.
# $s0 - Address of the maximum element in the current loop of sortunsign and sortsign procedures.
# $s1 - Maximum element in current loop of sortunsign and sortsign procedures.
# $s2 - A value to stop the outer loop of sortunsign and sortsign procedures.
# $sp - Stack pointer register used in order to store effectively the elements of unsign and sign in printunsign and printsign procedures.
# $ra - Return address register which used for 'jal' and 'jr' instructions to effectively nagivate between the program's procedures.

############################## Data Segment ##############################
.data
	stringhex: .space 37
	input_message: .asciiz "Please enter a hexadecimal string \n"
	wrong_input_message: .asciiz "wrong input \n"
	NUM: .space 12
	unsign: .space 12
	unsign_message: .asciiz "printunsign elements in decimal presentation: \n"
	new_line: .asciiz "\n"
	sign: .space 12
	sign_message: .asciiz "printsign elements in decimal presentation: \n"
	
############################## Code Segment ##############################	
.text
main:
	li $v0, 4 # $v0 = 4(Syscall to print a string)
	la $a0, input_message # $a0 = input_message address
	syscall
	
	li $v0, 8 # $v0 = 8(Syscall to print a string)
	la $a0, stringhex # $a0 = stringhex address
	li $a1, 37 # $a1 = amount of bytes we want to read = 37
	syscall
	
	#Check if the input is valid
	li $a1, 0
	jal is_valid
	
	move $a1, $v0 # $a1 = The number of hexadecimal paris that was found
	beqz $a1, handle_wrong_input
	
	#Convert each pair to act as one element and store it in NUM	
	la $a2, NUM # $a2 = The address of NUM
	jal convert
	
	#Sort the elements in the unsign method and store in in unsign
	la $a3 unsign # $a3 = The address of unsign
	jal sortunsign
	
	#Sort the elements in the sign method(Two's complement method) and store in in sign
	la $a3 sign # $a3 = The address of sign
	jal sortsign
	
	#Print the pairs of unsign in their decimal form
	la $a3, unsign # $a3 = The address of unsign
	jal printunsign
	
	#Print new line to make the code more readable
	li $v0, 4
	la $a0, new_line
	syscall
	
	#Print the pairs of sign in their decimal form
	la $a3, sign # $a3 = The address of sign
	jal printsign
	
	#END
	j end_program
	
	#If the input was invalid -> Ask the user to enter a new string
	handle_wrong_input:
		li $v0, 4
		la $a0, wrong_input_message
		syscall
		j main

############################################################																										
# The procedures:
																										
	##### is_valid #####				
	is_valid:
		move $t0, $a0 # $t0 = stringhex address
		move $t1, $a1 # #t1 = pairs counter
		li $t2, 0 # $t2 = flag.   states: 0 - expect hexadecimal letter, 1 - expect second hexadecimal letter, 2 - expect dollar
	
	is_valid_loop:
		lb $t3, 0($t0)
		beq $t3, '\n', end_is_valid
		
		beq $t3, '$', handle_dollar # If character = '$'
		blt $t3, '0', invalid_input # If character < '0'
		bgt $t3, 'F', invalid_input # If character > 'F'
		ble $t3, '9', valid_digit # If character <= '9'
		bge $t3, 'A', valid_digit # If character >= 'A'
		
	handle_dollar:
		beq $t2, 0, invalid_input
		beq $t2, 1, invalid_input
		beq $t2, 2, next_character_after_dollar
	
	valid_digit:
		beq $t2, 0, next_character_after_first_character
		beq $t2, 1, next_character_after_second_character
		beq $t2, 2, invalid_input #The character was supposed to be '$'
		
	next_character_after_first_character:
		addi $t2, $t2, 1 #Change the flag state to expect another hexadecimal character
		addi $t0, $t0, 1 #Increment $t0 for the next iteration
		j is_valid_loop
		
	next_character_after_second_character:
		addi $t2, $t2, 1 #Change the flag state to expect another hexadecimal character
		addi $t1, $t1, 1 #Count the pair
		addi $t0, $t0, 1 #Increment t0 for the next iteration
		j is_valid_loop
		
	next_character_after_dollar:
		li $t2, 0 #Resets the flag
		addi $t0, $t0, 1 #Increment $t0 for the next iteration
		j is_valid_loop
		
	invalid_input:
		li $v0, 0
		jr $ra	
	
	end_is_valid:
		lb $t3, -1($t0) #Load the last byte of stringhex
		bne $t3, '$', invalid_input #Check if the last character is not '$', if not - it's invalid
		move $v0, $t1
		jr $ra
	
	
	
	##### convert #####
	convert:
		move $t0, $a0 # $t0 = stringhex address
		move $t1, $a1 # $t1 = The amount of hexadecimal pairs we found in stringhex
		move $t2, $a2 # $t2 = NUM address
		li $t3, 0 # $t3 = The amount of the converted pairs
		
	convert_loop:
		beq $t3, $t1, end_convert #If we converted all the pairs - we finished the convert processs
		lb $t4, 0($t0) # $t4 = The first character of the current pair
		lb $t5, 1($t0) # $t5 = The second character of the current pair
		bgt $t4, '9', first_character_is_A_F #If the character value is bigger than '9', then it's between 'A' to 'F'
		sub $t4, $t4, '0' #Convert the first character into integer
		j convert_second_character
	
	first_character_is_A_F:
		sub $t4, $t4, 'A'
		addi $t4, $t4, 10 #After this two lines we converted the first character into integer
	
	convert_second_character:
		bgt $t5, '9', second_character_is_A_F #If the character value is bigger than '9', then it's between 'A' to 'F'
		sub $t5, $t5, '0' #Convert the second character into integer
		j combine_values
	
	second_character_is_A_F:
		sub $t5, $t5, 'A'
		addi $t5, $t5, 10 #After this two lines we converted the second character into integer		
	
	combine_values:
		sll $t6, $t4, 4 # $t6 = The first value with Shift Left Logical of 4 bytes
		or $t7, $t6, $t5 # $t7 = the combined value	
		sb $t7, 0($t2)
		
		addi $t0, $t0, 3 #Go to the next pair
		addi $t2, $t2, 1 #Go to the next byte of NUM
		addi $t3, $t3, 1 #Count the pair
		j convert_loop	
				
	end_convert:
		jr $ra
	
	
	
	##### sortunsign #####
	sortunsign:
		move $t0, $a3 #The address of unsign
		move $t1, $a2 #The address of NUM
		move $t2, $a1 #The number of hexadecimal pairs that was found

		li $t3, 0
		
	copy_loop:
		beq $t3, $t2 start_unsign_sort
		lbu $t4, 0($t1) #We use lbu instead lb to avoid from negative value
		sb $t4, 0($t0)
		addi $t0, $t0, 1 #Go to the next byte of unsign
		addi $t1, $t1, 1 #Go to the next byte of NUM
		addi $t3, $t3, 1 #Increment $t3 for the next iteration
		j copy_loop
	
	#Similar to Selection Sort
	start_unsign_sort:
		li $t3, 0 # $t3 = Outer loop iterator
		subi $s2, $t2, 1 # $s2 =  A value to stop the outer loop
	
	outer_loop:
		li $s1, 0 # Reset maximum element
		beq $t3, $s2, end_sort # Passed on all the hexadecimal pairs
		add $t4, $t3, $a3
		lbu $t5, 0($t4) # $t5 = Current max
		addi $t6, $t3, 1
	
	inner_loop:
		beq $t6, $t2 check_swap # Reached the last element
		add $t7, $t6, $a3
		lbu $t8, 0($t7) # $t8 = Current element
		
		blt $t5, $t8 check_max
		addi $t6, $t6, 1
		j inner_loop
		
	check_max:
		blt $s1, $t8, update_max
		addi $t6, $t6, 1
		j inner_loop
		
	update_max:
		move $s0, $t7 # $s0 = Address of the maximum element in the current loop
		move $s1, $t8 # $s1 = Maximum element in current loop
		addi $t6, $t6, 1
		j inner_loop
	
	check_swap:
		blt $t5, $s1, swap
		addi $t3, $t3, 1
		j outer_loop
	
	swap:
		move $t1, $t5 # $t1 = smaller element
		sb $s1, 0($t4)
		sb $t1, 0($s0)
		addi $t3, $t3, 1
		j outer_loop

	end_sort:
		jr $ra
	
	
	
	##### sortsign #####
	sortsign:
		move $t0, $a3 #The address of sign
		move $t1, $a2 #The address of NUM
		move $t2, $a1 #The number of hexadecimal pairs that was found

		li $t3, 0
		
	copy_loop_sign:
		beq $t3, $t2 start_sign_sort
		lb $t4, 0($t1)
		sb $t4, 0($t0)
		addi $t0, $t0, 1 #Go to the next byte of unsign
		addi $t1, $t1, 1 #Go to the next byte of NUM
		addi $t3, $t3, 1 #Increment $t3 for the next iteration
		j copy_loop_sign
	
	#Similar to Selection Sort
	start_sign_sort:
		li $t3, 0 # $t3 = Outer loop iterator
		subi $s2, $t2, 1 # $s2 =  A value to stop the outer loop
	
	outer_loop_sign:
		li $s1, -128 # Reset maximum element to smallest possible number in Two's complement method
		beq $t3, $s2, end_sort_sign # Passed on all the hexadecimal pairs
		add $t4, $t3, $a3
		lb $t5, 0($t4) # $t5 = Current max
		addi $t6, $t3, 1
	
	inner_loop_sign:
		beq $t6, $t2 check_swap_sign # Reached the last element
		add $t7, $t6, $a3
		lb $t8, 0($t7) # $t8 = Current element
		
		blt $t5, $t8 check_max_sign
		addi $t6, $t6, 1
		j inner_loop_sign
		
	check_max_sign:
		blt $s1, $t8, update_max_sign
		addi $t6, $t6, 1
		j inner_loop_sign
		
	update_max_sign:
		move $s0, $t7 # $s0 = Address of the maximum element in the current loop
		move $s1, $t8 # $s1 = Maximum element in current loop
		addi $t6, $t6, 1
		j inner_loop_sign
	
	check_swap_sign:
		blt $t5, $s1, swap_sign
		addi $t3, $t3, 1
		j outer_loop_sign
	
	swap_sign:
		move $t1, $t5 # $t1 = smaller element
		sb $s1, 0($t4)
		sb $t1, 0($s0)
		addi $t3, $t3, 1
		j outer_loop_sign

	end_sort_sign:
		jr $ra
	


	##### printunsign #####
	printunsign:
		move $t0, $a3 # $t0 = Address of unsign
		move $t1, $a1 # $t1 = Number of hexadecimal pairs that found
		
		li $v0, 4
		la $a0, unsign_message
		syscall
		
		li $t2, 0 # $t2 = Iterator
		li $t3, 0 # $t3 = Digits counter
		subi $t7, $t1, 1 # $t7 = last Iteration(we defined it in order to not add two spaces after the last number)
		
	printunsign_outer_loop:
		beq $t2, $t1 end_printunsign
		lbu $t4, 0($t0)

	convert_to_decimal_loop:
		divu $t4, $t4, 10 # $t4 = $t4/10
		mfhi $t5 # $t5 = Remainder of $t4/10
		subi $sp, $sp, 4
		sb $t5, 0($sp)
		addi $t3, $t3, 1
		bnez $t4, convert_to_decimal_loop
	
	check_digits_counter:
		bnez $t3, printunsign_inner_loop
		j add_spaces_unsign
		
	printunsign_inner_loop:
		lbu $t6, 0($sp)
		addi $t6, $t6, '0' #Makes $t6 a real digit
		li $v0, 11
		move $a0, $t6
		syscall
		sb $zero, 0($sp) #Reset the address's value after we finished printing what we needed
		addi $sp, $sp, 4 #Go to the next digit
		subi $t3, $t3, 1 #Done with the current digit
		j check_digits_counter
	
	add_spaces_unsign:
		beq $t2, $t7, printunsign_increment #Checks if we reached the last number, In that case avoid add two spaces after it
		li $v0, 11
		li $a0, ' '
		syscall
		li $v0, 11
		li $a0, ' '
		syscall
	
	printunsign_increment:
		addi $t0, $t0, 1 #Go to the next byte
		addi $t2, $t2, 1 #Go the the next number
		j printunsign_outer_loop
		
	end_printunsign:
		jr $ra
		
		
		
	##### printsign #####
	printsign:
		move $t0, $a3 # $t0 = Address of sign
		move $t1, $a1 # $t1 = Number of hexadecimal pairs that found
		
		li $v0, 4
		la $a0, sign_message
		syscall
		
		li $t2, 0 # $t2 = Iterator
		li $t3, 0 # $t3 = Digits counter
		subi $t7, $t1, 1 # $t7 = last Iteration(we defined it in order to not add two spaces after the last number)
		
	printsign_outer_loop:
		beq $t2, $t1 end_printsign
		lb $t4, 0($t0) 
		bgez $t4, convert_to_decimal_loop_sign 
		
	negative_number:
		li $v0, 11
		li $a0, '-' # Adds the minus sign before the number
		syscall
		negu $t4, $t4
	
	convert_to_decimal_loop_sign:
		div $t4, $t4, 10 # $t4 = $t4/10
		mfhi $t5 # $t5 = Remainder of $t4/10
		subi $sp, $sp, 4
		sb $t5, 0($sp)
		addi $t3, $t3, 1
		bnez $t4, convert_to_decimal_loop_sign
	
	check_digits_counter_sign:
		bnez $t3, printsign_inner_loop
		j add_spaces_sign
		
	printsign_inner_loop:
		lb $t6, 0($sp)
		addi $t6, $t6, '0' #Makes $t6 a real digit
		li $v0, 11
		move $a0, $t6
		syscall
		sb $zero, 0($sp) #Reset the address's value after we finished printing what we needed
		addi $sp, $sp, 4 #Go to the next digit
		subi $t3, $t3, 1 #Done with the current digit
		j check_digits_counter_sign
	
	add_spaces_sign:
		beq $t2, $t7, printsign_increment #Checks if we reached the last number, In that case avoid add two spaces after it
		li $v0, 11
		li $a0, ' '
		syscall
		li $v0, 11
		li $a0, ' '
		syscall
	
	printsign_increment:
		addi $t0, $t0, 1 #Go to the next byte
		addi $t2, $t2, 1 #Go the the next number
		j printsign_outer_loop
		
	end_printsign:
		jr $ra
		
	
############################################################																										
# THE END:	
	end_program:
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

