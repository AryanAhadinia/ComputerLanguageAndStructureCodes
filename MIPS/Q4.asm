.text
	# main -------------------------------------------------------------------------------------------
	
	addi $v0, $zero, 5			# get a from user
	syscall
	add $a0, $zero, $v0			# save m in $a0
	
	addi $v0, $zero, 5			# get b from user
	syscall
	add $a1, $zero, $v0			# save m in $a1
	
	jal isPythagorean			# call isPythagorean subroutine
	
	beq $v0, $zero, notPythagorean		# check if pythagorean
	
	# pythagorean				# run this block if pythagorean
	add $a0, $zero, $v1			# set $a0 = (a^2 + b^2) ^ 0.5
	
	addi $v0, $zero, 1			# print $a0
	syscall
	
	j conditionEnd				# jump to condition end to avoid else block
	
	notPythagorean:
	
	la $a0, notPythagoreanMessage		# set $a0 = address (notPythagoreanMessage)
	
	addi $v0, $zero, 4			# print $a0
	syscall
	
	conditionEnd:
	
	addi $v0, $zero, 10			# exit
	syscall
	
	# sunroutines ------------------------------------------------------------------------------------
	
	# isPythagorean
	# $a0: 'a'
	# $a1: 'b'
	# $v0: boolean: 0 if notPythagorean else 1
	# $v1: value of c = (a^2 + b^2) ^ 0.5 if pythagorean
	isPythagorean:
	mul $t0, $a0, $a0			# $t0 = a ^ 2
	mul $t1, $a1, $a1			# $t1 = b ^ 2
	add $t0, $t0, $t1			# $t0 = $t0 + $t1 = a ^ 2 + b ^ 2
	
	addi $v1, $zero, 0			# set $v1 = 0
	loop:					# while $t1 ^ 2 <= $t0: $v1++
	mul $t1, $v1, $v1
	bgt $t1, $t0, loopEnd
	
	bne $t1, $t0, conditionFail		# if $t2 == $t0
	
	addi $v0, $zero, 1			# set $v0 = 1
	
	jr $ra					# return to $ra
	
	conditionFail:
	
	addi $v1, $v1, 1			# $v0++
	
	j loop					# back to loop
	
	loopEnd:				# loop will finish if not pythagorean
	
	addi $v0, $zero, 0			# set $v0 = 0
	
	jr $ra					# return to $ra
	
.data
	notPythagoreanMessage: .asciiz "not pythagorean"
