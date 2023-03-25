.text
	addi	$a0, $zero, 1024		# set buffer size
	addi	$v0, $zero, 9			# set syscall code to allocate buffer
	syscall
	
	add	$s0, $zero, $v0			# save buffer address in $s0

	la	$a0, encoded     		# set encoded file path
	addi	$a1, $zero, 0        		# set mode : read
	
	addi	$v0, $zero, 13       		# set syscall code to open file
	syscall

	add	$s1, $zero, $v0			# save file descriptor in $s1
	
	la	$a0, decoded     		# set decoded file path
	addi	$a1, $zero, 1        		# set mode : write
	addi	$v0, $zero, 13       		# set syscall code to open file
	syscall

	add	$s2, $zero, $v0			# save file descriptor in $s2
	
	add	$a0, $zero, $s1			# read first four characters from encoded
	add	$a1, $zero, $s0			# set buffer
	addi	$a2, $zero, 4			# set buffer size
	addi	$v0, $zero, 14			# set syscall code to read file
	syscall
	
	add	$s4, $zero, $v0			# save return value of read
	
	addi	$t0, $zero, 1			# save f(n-2)
	addi	$t1, $zero, 2			# save f(n-1)
	addi	$t2, $zero, 3			# save f(n)
	
	loop1:
	beq	$s4, 0, loop1End		# while !eof (end of file)
	
	add	$t3, $zero, $t1			# set number of chars to read
	loop2:
	ble	$t3, 1024, loop2End		# read and write until minimize to buffer size	
	
	add	$a0, $zero, $s1			# read next 1024 characters from encoded
	add	$a1, $zero, $s0			# set buffer
	addi	$a2, $zero, 1024		# set buffer size
	addi	$v0, $zero, 14			# set syscall code to read file
	syscall
	
	add	$s4, $zero, $v0			# save read chars count
	
	add	$a0, $zero, $s2			# write read characters to decoded
	add	$a1, $zero, $s0			# set buffer
	add	$a2, $zero, $v0			# set buffer size
	addi	$v0, $zero, 15			# set syscall code to write file
	syscall
	
	addi	$t3, $t3, -1024			# pendingChars -= 1024
	j	loop2				# jump over loop condition
	loop2End:
	
	add	$a0, $zero, $s1			# read next 1024 characters from encoded
	add	$a1, $zero, $s0			# set buffer
	add	$a2, $zero, $t3			# set buffer size
	addi	$v0, $zero, 14			# set syscall code to read file
	syscall
	
	add	$s4, $zero, $v0			# save read chars count
	
	blt	$v0, $t3, condFail		# check if last char is fibbo-indexed or not
	addi	$v0, $v0, -1			# if yes, set buffer size one less to don't write it
	condFail:
	
	add	$a0, $zero, $s2			# write read characters to decoded
	add	$a1, $zero, $s0			# set buffer
	add	$a2, $zero, $v0			# set buffer size
	addi	$v0, $zero, 15			# set syscall code to write file
	syscall
	
	add	$t0, $zero, $t1			# calculate next fibbos, shift
	add	$t1, $zero, $t2			# shift fibbo
	add	$t2, $t1, $t0			# f(n) = f(n-1) + f(n-2)
	j	loop1				# jump over loop condition
	loop1End:
	
	add	$a0, $zero, $s1			# close encoded file
	addi	$v0, $zero, 16			# set syscall code to close file
	syscall
	
	add	$a0, $zero, $s1			# close decoded file
	addi	$v0, $zero, 16			# set syscall code to close file
	syscall
	
	addi	$v0, $zero, 10			# system exit
	syscall

.data
	encoded:	.asciiz "D:/hw.txt"	# encoded file path
	decoded:	.asciiz "D:/hw2.txt"	# decoded file path
