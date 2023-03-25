.text
	# main -----------------------------------------------------------------------
	
	la $a0, m				# print "m"
	addi $v0, $zero, 4
	syscall
	
	la $a0, colon				# print ":"
	addi $v0, $zero, 4
	syscall
	
	addi $v0, $zero, 5			# get m from user
	syscall
	add $s0, $zero, $v0			# save m in $s0
	
	la $a0, n				# print "n"
	addi $v0, $zero, 4
	syscall
	
	la $a0, colon				# print ":"
	addi $v0, $zero, 4
	syscall
	
	addi $v0, $zero, 5			# get n from user
	syscall
	add $s1, $zero, $v0			# save n in $s1
	
	la $a0, p				# print "p"
	addi $v0, $zero, 4
	syscall
	
	la $a0, colon				# print ":"
	addi $v0, $zero, 4
	syscall
	
	addi $v0, $zero, 5			# get p from user
	syscall
	add $s2, $zero, $v0			# save p in $s2
	
	add $a0, $zero, $s0			# pass m in $a0
	add $a1, $zero, $s1			# pass n in $a1
	jal getMatrix				# call getMatrix subroutine
	add $s3, $zero, $v0			# save pointer to A in $s3
	
	add $a0, $zero, $s1			# pass n in $a0
	add $a1, $zero, $s2			# pass p in $a1
	jal getMatrix				# call getMatrix subroutine
	add $s4, $zero, $v0			# save pointer to B in $s3
	
	add $a0, $zero, $s3			# pass A as arg
	add $a1, $zero, $s4			# pass B as arg
	jal multiplyMatrices			# call subtoutine to calculate A * B
	add $s5, $zero, $v0			# store C in $s5
	
	add $a0, $zero, $s5			# pass C as arg
	add $a1, $zero, $s0			# pass length as arg
	add $a2, $zero, $s2			# pass width as arg
	jal printMatrix				# call subroutine to print C

	addi $v0, $zero, 10			# exit
	syscall
	
	# subroutines ----------------------------------------------------------------
	
	# getMatrix
	# get an m * n matrix from user input
	# $a0: m
	# $a1: n
	# $v0: pointer to m * n matrix
	getMatrix:
	add $t0, $zero, $a0			# store $a0 and $a1
	add $t1, $zero, $a1
	
	mul $a0, $t0, $t1			# calculate required size of memory to save matrix
	sll $a0, $a0, 2
	
	addi $v0, $zero, 9			# allocate memory in heap
	syscall
	
	add $t2, $zero, $v0			# save address of allocated memory in $t2
						
	add $t5, $zero, $t2			# initial $t5 = $t2 for iteration
						
	addi $t3, $zero, 0			# initial iterator $t3 = 0
	getRowsLoop:				# iterate over rows
	bge $t3, $t0, getRowsLoopEnd		# check iteration condition : iterator < m
	
	addi $t4, $zero, 0			# initial iterator $t4 = 0
	getCellsLoop:				# iterate over cells in a row
	bge $t4, $t1, getCellsLoopEnd		# check iteration condition : iterator < n
	
	add $a0, $zero, $t3			# print row index
	addi $v0, $zero, 1
	syscall
	
	la $a0, dash				# ptint "-"
	addi $v0, $zero, 4
	syscall
	
	add $a0, $zero, $t4			# print column index
	addi $v0, $zero, 1
	syscall
	
	la $a0, colon				# print ":"
	addi $v0, $zero, 4
	syscall
	
	addi $v0, $zero, 5			# get user input
	syscall
	
	sw $v0, 0($t5)				# store user input in memory
	
	addi $t5, $t5, 4			# move to next word in memory
	addi $t4, $t4, 1			# go to next cell
	j getCellsLoop				# back to cells loop condition check
	
	getCellsLoopEnd:
	
	addi $t3, $t3, 1			# go to next row
	j getRowsLoop				# back to rows loop condition check
	
	getRowsLoopEnd:
	
	add $a0, $zero, $t0			# restore $a0 and $a1
	add $a1, $zero, $t1
	
	add $v0, $zero, $t2			# set return argument
	
	jr $ra					# return to $ra
	
	# multiplyMatrices
	# multiply two m * n and n * p matrices
	# $s0: m (const)
	# $s1: n (const)
	# $s2: p (const)
	# $a0: pointer to first matrix
	# $a1: pointer to second matrix
	multiplyMatrices:
	add $t0, $zero, $a0			# temporary store $a0 in $t0 
	
	mul $a0, $s0, $s2			# calculate m * p * 4, required memory size for result
	sll $a0, $a0, 2
	
	addi $v0, $zero, 9			# allocate memory for result matrix
	syscall
	
	add $a0, $zero, $t0			# restore $a0
	
	add $t8, $zero, $v0			# store pointer to result matrix in $t8 for iteration
	
	sll $t9, $s2, 2				# calculate each step in vertical vector iteration
	
	addi $t0, $zero, 0			# initial iterator $t0 = 0
	rowsIterationLoop:			# iterate over rows in result matrix
	bge $t0, $s0, rowsIterationLoopEnd	# check iteration condition : iterator < m
	
	addi $t2, $zero, 0			# initial iterator $t2 = 0
	cellsIterationLoop:			# iterate over cells in a row in result matrix
	bge $t2, $s2, cellsIterationLoopEnd	# check iteration condition : iterator < p
	
	addi $t3, $zero, 0			# initial $t3 = 0 to calculate sum			
	
	mul $t4, $t0, $s1			# calculate address of A[i][0], = (i * n + 0) * 4 + A
	add $t4, $t4, $zero			# redundant, just for mainatainablity
	sll $t4, $t4, 2				# $t4 *= 4 
	add $t4, $t4, $a0			# $t4 += A
	
	mul $t5, $zero, $s2			# calculate address of B[0][0], = (j * p + k) * 4 + B, redundant
	add $t5, $t5, $t2			# $t5 += k
	sll $t5, $t5, 2				# $t5 *= 4
	add $t5, $t5, $a1			# $t5 += B
	
	addi $t1, $zero, 0			# initial iterator $t1 = 0
	vectorIterationLoop:			# iterate over vectors to calculate inner product
	bge $t1, $s1, vectorIterationLoopEnd	# check iteration condition : iterator < n
	
	lw $t6, 0($t4)				# load cell from A in address $t4
	lw $t7, 0($t5)				# load cell from B in address $t5
	
	mul $t7, $t6, $t7			# $t7 = A[i][j] * B[j][k]
	add $t3, $t3, $t7			# $t3 += $t7
	
	addi $t4, $t4, 4			# next horizontal cell in A
	add $t5, $t5, $t9			# next vertical cell in B
	addi $t1, $t1, 1			# go to next element in vector
	j vectorIterationLoop			# back to vector loop condition check
	
	vectorIterationLoopEnd:
	
	sw $t3, 0($t8)				# store result in cell
	
	addi $t8, $t8, 4			# go to next word in memory
	addi $t2, $t2, 1			# go to next cell
	j cellsIterationLoop			# back to cells loop condition check
	
	cellsIterationLoopEnd:
	
	addi $t0, $t0, 1			# go to next row
	j rowsIterationLoop			# back to rows loop condition check
	
	rowsIterationLoopEnd:
	
	jr $ra					# return to $ra
	
	# printMatrix
	# print an m * n matrix
	# $a0: pointer to matrix start
	# $a1: m
	# $a2: n
	printMatrix:
	add $t0, $zero, $a0			# save pointer in $t0 for iteration
	
	addi $t1, $zero, 0			# initial iterator $t1 = 0
	rowsPrintLoop:				# iterate over rows
	bge $t1, $a1, rowsPrintLoopEnd		# check iteration condition : iterator < m
	
	addi $t2, $zero, 0			# initial iterator $t2 = 0
	cellsPrintLoop:				# iterate over cells in a row
	bge $t2, $a2, cellsPrintLoopEnd		# check iteration condition : iterator < n
	
	lw $a0, 0($t0)				# load value from memory
	addi $v0, $zero, 1			# print loaded value
	syscall
	
	la $a0, tab				# print "\t" to separeate cells
	addi $v0, $zero, 4
	syscall
	
	addi $t0, $t0, 4			# move to next word in memory
	addi $t2, $t2, 1			# go to next cell
	j cellsPrintLoop			# back to cells loop condition check
	
	cellsPrintLoopEnd:
	
	la $a0, endl				# print "\n" to separeate rows
	addi $v0, $zero, 4
	syscall
	
	addi $t1, $t1, 1			# go to next row
	j rowsPrintLoop				# back to rows loop condition check
	
	rowsPrintLoopEnd:
	
	jr $ra					# return to $ra
	
.data
	m:	.asciiz "m"
	n:	.asciiz "n"
	p:	.asciiz "p"
	dash:	.asciiz "-"
	colon:	.asciiz ":"
	tab:	.asciiz "\t"
	endl:	.asciiz "\n"
