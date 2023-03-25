.text
	# main -----------------------------------------------------------------------

	lwc1	$f30, zero				# set FPU 0-reserved register 
	lwc1	$f28, one				# set FPU 1-reserved register 
	lwc1	$f26, three				# set FPU 3-reserved register 
	lwc1	$f24, four				# set FPU 4-reserved register 
	
	addi 	$v0, $zero, 6				# get x from user as float
	syscall
	
	add.s	$f2, $f30, $f0				# store x in $f2
	
	jal	f					# call f
	 
	add	$a0, $zero, $v0				# store result in $a0
	addi	$v0, $zero, 1				# set syscall code to print int
	syscall
	
	addi	$v0, $zero, 10				# system exit
	syscall
	
	# subroutines ----------------------------------------------------------------
	
	# f
	# calculate f
	# $f2: x, arg
	# $f0: return value
	f:
	
	c.le.s	$f2, $f28				# check if x <= 1
	bc1f	boundryConditionNotSatisfied		# branch if not satisfied
	
	addi	$v0, $zero, 1				# set return value to 1 if satisfied
	jr	$ra					# return to $ra
	
	boundryConditionNotSatisfied:
	
	addi	$sp, $sp, -24				# store registers in stack
	sw	$ra, 0($sp)
	s.s	$f2, 4($sp)
	s.s	$f4, 8($sp)
	s.s	$f6, 12($sp)
	sw	$t0, 16($sp)
	sw	$t1, 20($sp)
	
	add.s	$f2, $f2, $f28				# x += 1
	
	div.s	$f4, $f2, $f24				# $f4 = x + 1 / 4
	div.s	$f6, $f2, $f26				# $f6 = x + 1 / 3
	
	add.s	$f2, $f30, $f4				# set arg to x + 1 / 4
	jal	f					# recursion
	add	$t0, $zero, $v0				# store result in $t0
	
	add.s	$f2, $f30, $f6				# set arg to x + 1 / 3
	jal	f					# recursion
	add	$t1, $zero, $v0				# store result in $t1
	
	add	$v0, $t0, $t1				# calculate f(x) from recursion
	
	lw	$ra, 0($sp)				# restore registers from stack
	l.s	$f2, 4($sp)
	l.s	$f4, 8($sp)
	l.s	$f6, 12($sp)
	lw	$t0, 16($sp)
	lw	$t1, 20($sp)
	addi	$sp, $sp, 24
	
	jr	$ra					# return to $ra
	
.data
	zero:		.float 0.0
	one:		.float 1.0
	three:		.float 3.0
	four:		.float 4.0