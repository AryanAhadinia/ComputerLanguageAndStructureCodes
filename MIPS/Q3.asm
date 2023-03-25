.text
	# main -------------------------------------------------------------------------------------------
	
	la $a0, array				# load pointer to array start
	
	la $a1, length				# load array length
	lw $a1, 0($a1)
	
	sll $a1, $a1, 2				# calculate pointer to array end
	add $a1, $a0, $a1
	
	jal sort				# call sort subroutine
						# params has already assigned to $a0 and $a1
					
	addi $v0, $zero, 10			# system exit
	syscall

	# subroutines ------------------------------------------------------------------------------------
	
	# rawSwap
	# $a0: i
	# $a1: j
	# don't have any return value
	rawSwap:	
	la $t0, array				# load address of array start
	
	sll $t1, $a0, 2				# $t1 = $a0 << 2 = $a0 * 4
	add $t1, $t0, $t1			# calculating address of a[i]
	lw $t3, 0($t1)				# load a[i] in t3
	
	sll $t2, $a1, 2				# $t2 = $a1 << 2 = $a1 * 4
	add $t2, $t0, $t2			# calculating address of a[j]
	lw $t4, 0($t2)				# load a[j] in t4
	
	sw $t3, 0($t2)				# store t3 in place of a[j]
	sw $t4, 0($t1)				# store t4 in place of a[i]
	
	jr $ra					# return to $ra
	
	# swap
	# $a0: pointer to a[i]
	# $a1: pointer to a[j]
	# don't have any return value
	swap:	
	lw $t0, 0($a0)				# load value of address $a0 in $t0
	lw $t1, 0($a1)				# load value of address $a1 in $t1
	
	sw $t0, 0($a1)				# store $t0 in where $a1 point to
	sw $t1, 0($a0)				# store $t1 in where $a0 point to
	
	jr $ra					# return to $ra
	
	# sort
	# use recursive bubble sort algo to sort an array
	# $a0: pointer to array start
	# $a1: pointer to array end
	sort:
	bne $a0, $a1, passBoundryCondition	# check boundry condition of bubble sort recursion
	
	jr $ra					# return to $ra if condition satisfy
	
	passBoundryCondition:			# continue if condition still not satisfied
	
	addi $sp, $sp, -32			# store registers
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp)
		
	add $s0, $zero, $a1			# save end pointer in $s0
	
	addi $s1, $a0, 0			# set $s1 = $a0 as iterator initialization
	addi $s2, $s0, -4			# set $s2 = $s0 - 4 as iterator bound, $s2 is address of last element in the array
	sortLoop:				# iterate over array to move biggest element to the end
	bge $s1, $s2, sortLoopEnd		# check iteration condition ($s1 != $s2)
	
	lw $s3, 0($s1)				# load value of address $s1 in $s3
	lw $s4, 4($s1)				# load value of address $s1 + 4 in $s4
	
	bge $s4, $s3, continue			# check if $s4 is less than $s3
	
	addi $a0, $s1, 0			# assign args and swap if $s4 is less than $s3
	addi $a1, $s1, 4
	jal swap
	
	continue:				# else continue
	
	addi, $s1, $s1, 4			# index++ ($s1 = $s1 + 4)
	j sortLoop				# back to loop condition check
	
	sortLoopEnd:				# loop end
	
	lw $a0, 4($sp)				# restore $a0 and $a1
	lw $a1, 8($sp)
	
	addi $a1, $a1, -4			# minify list (buuble sort logic)
	jal sort				# recursive call
	
	lw $ra, 0($sp)				# restore other registers (exclude a registers)
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $s4, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra					# return to $ra
	
.data
	array: .word 10, 7, 7, 13, 4, 6
	length: .word 6
