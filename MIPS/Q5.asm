.text
	# main -----------------------------------------------------------------------
	
	addi	$v0, $zero, 5					# get n from user
	syscall

	add	$a0, $zero, $v0					# store n in $a0
	jal	f_64						# call f or 
	
	add	$t1, $zero, $v1					# store result msb in $t1, required only when using f_64
	add	$t0, $zero, $v0					# store result lsb in $t0
	
	add	$a0, $zero, $t1					# print first 32 bits, required only when using f_64
	addi	$v0, $zero, 36					# set syscall code to print unsigned int
	syscall
	
	la	$a0, endl					# print "\n"
	addi	$v0, $zero, 4					# set syscall code to pring string
	syscall
	
	add	$a0, $zero, $t0					# print second 32 bits, required only when using f_64
	addi	$v0, $zero, 36					# set syscall code to print unsigned int
	syscall
	
	addi	$v0, $zero, 10					# system exit
	syscall
	
	# subroutines ----------------------------------------------------------------
	
	# f
	# calculate f(n) = n * f(n - 1) + 1 recursivly
	# $a0: n
	# $v0: f(n) lsb
	# $v1: f(n) msb
	# max n allowed: 12
	f:
	bgt	$a0, 1, fBoundryConditionNotSatisfied		# check boundry condition, ? n <= 1
	
	addi	$v0, $zero, 2					# if boundry condition satisfied, set return value to 2
	jr	$ra						# return to $ra
	
	fBoundryConditionNotSatisfied:				# continue if not satisfied
	
	addi	$sp, $sp, -8					# extend stack to store registers
	sw	$ra, 0($sp)					# store $ra in stack
	sw	$a0, 4($sp)					# store $a0 in stack
	
	addi	$a0, $a0, -1					# set arg for recursion
	jal	f						# call f recursivly
	
	lw	$ra, 0($sp)					# restore $ra from stack
	lw	$a0, 4($sp)					# restore $a0 from stack
	addi	$sp, $sp, 8					# freeup space in stack
	
	mulu	$v0, $v0, $a0					# $v0 *= $a0 (n * f(n-1))
	addiu	$v0, $v0, 1					# $v0 += 1 (n * f(n-1))
	
	jr	$ra						# return to $ra
	
	# f_64
	# calculate f(n) = n * f(n - 1) + 1 recursivly with 64-bit words
	# $a0: n
	# $v0: f(n)
	# max n allowed: 20
	f_64:
	bgt	$a0, 1, f64BoundryConditionNotSatisfied		# check boundry condition, ? n <= 1
	
	addi	$v0, $zero, 2					# if boundry condition satisfied, set return value to 2
	addi	$v1, $zero, 0
	jr	$ra						# return to $ra
	
	f64BoundryConditionNotSatisfied:			# continue if not satisfied
	
	addi	$sp, $sp, -8					# extend stack to store registers
	sw	$ra, 0($sp)					# store $ra in stack
	sw	$a0, 4($sp)					# store $a0 in stack
	
	addi	$a0, $a0, -1					# set arg for recursion
	jal	f_64						# call f recursivly
	
	lw	$ra, 0($sp)					# restore $ra from stack
	lw	$a0, 4($sp)					# restore $a0 from stack
	addi	$sp, $sp, 8					# freeup space in stack
	
	mulu	$v1, $v1, $a0					# msb *= n
	
	multu	$v0, $a0					# lsb *= n, use multu to handle overflow
	mfhi	$t1						# store hi in $t1
	mflo	$t0						# store lo in $t0
	
	add	$v1, $v1, $t1					# add mult-hi to f(n-1) msb
	addi	$v0, $t0, 1					# n * f(n - 1) += 1
	
	bne	$v0, 0, overflowFailed				# check if overflow occurs in $v0
	
	addi	$v1, $v1, 1					# add 1 to msb if overflow occured
	
	overflowFailed:
	
	jr	$ra						# return to $ra
	
.data
	endl:	.asciiz	"\n"
