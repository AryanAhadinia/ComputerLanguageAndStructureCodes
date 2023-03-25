.text
	addi $v0, $zero, 5		# get first number from user
	syscall
	add $s0, $zero, $v0		# save first number in $s0
	
	addi $v0, $zero, 5		# get second number from user
	syscall
	add $s1, $zero, $v0 		# save second number in $s0
	
	srl $t0, $s0, 24		# getting first part of $s0 in $ t0
	
	sll $t1, $s1, 24 		# getting fourth part of $s1 in $t1
	srl $t1, $t1, 24
	
	mul $s2, $t0, $t1		# multplying $t0 and $t1

	sll $s2, $s2, 8			# shift thw answer to 2nd and 3rd part of s2	

	addi $v0, $zero, 1		# print the result
	add $a0, $zero, $s2
	syscall
	
	addi $v0, $zero, 10		# exit
	syscall
