.data
	input1:	
		.word	0	
	input2:	
		.word	0
	operater:	
		.word	0
	output:	
		.word	0

# TODO : change the file name/path to access the files
# NOTE : Before you submit the code, make sure these two fields are "input.txt" and "output.txt"
	file_in:
		.asciiz	"input.txt"
	file_out:
		.asciiz	"output.txt"
		
# the following data is only for sample demonstration
	output_ascii:	
		.byte	'X', 'X', 'X', 'X'

.text
	main:    #start of your program

#STEP1: open input file
# ($s0: fd_in)

	li	$v0, 13			# 13 = open file
	la	$a0, file_in	# $a2 <= filepath
	
	# NOTE: this syscall is system-dependent
	# 0x4000 is _O_TEXT in Windows, but it's invalid in Linux
	# (io.h) for Windows, (fcntl-linux.h) for Linux
	# For Linux, 0x0000 (O_RDONLY) should be used instead
	li	$a1, 0x0000		# $a1 <= flags = 0x4000 for Windows, 0x0000 for Linux
	li	$a2, 0			# $a2 <= mode = 0
	syscall				# $v0 <= $s0 = fd
	move	$s0, $v0	# store fd_in in $s0, fd_in is the file descriptor just returned by syscall

#STEP2: read inputs (chars) from file to registers
# ($s1: input1, $s2: input2, $s3: operator)

#   2 bytes for the first operand
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0	# $a0 <= fd_in
	la	$a1, input1		# $a1 <= input1
	li	$a2, 2			# read 2 bytes to the address given by input1
	syscall
	
#   1 byte for the operator
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0	# $a0 <= fd_in
	la	$a1, operater	# $a1 <= operater
	li	$a2, 1			# read 1 bytes to the address given by operater
	syscall
	
#   2 bytes for the second operand
	li	$v0, 14			# 14 = read from file
	move	$a0, $s0	# $a0 <= fd_in
	la	$a1, input2		# $a1 <= input2
	li	$a2, 2			# read 2 bytes to the address given by input2
	syscall

#STEP3: turn the chars into integers
	la	$a0, input1		
	bal	atoi			 
	move	$s1, $v0	# $s1 <= atoi(input1)

	la	$a0, input2		
	bal	atoi			 
	move	$s2, $v0	# $s2 <= atoi(input2)

	lw	$s3, operater	# $s3 <= operater

# Inputs are ($s1: input1, $s2: input2, $s3: operator's ASCII)
# Output is $s4 (in integer)


#STEP4 integer operations
	# TODO: operation selector
    # hint: you could write multiple "if (operator==??)then(...)" structures below
	li $t0,'+'
	beq $s3, $t0, addition

	li $t0,'-'
	beq $s3, $t0, substraction

	li $t0,'*'
	beq $s3, $t0, multiplication

	li $t0,'/'
	beq $s3, $t0, division

	j ret

addition:
	add	$s4, $s1, $s2	# $s4 <= $s1 + $s2
	j result

substraction:
	sub	$s4, $s1, $s2
	j result

multiplication:
	mult $s1, $s2
	mflo $s4
	j result

division:
	beq $s2, $zero, ret # If divide 0, go to ret
	div $s1, $s2
	mflo $s4
	j result

	
#STEP5: turn the integer into pritable char
    # transferred ASCII should be put into "output_ascii"(see definition in the beginning of the file)
result:
	sw	$s4, output	# output <= $s4	
	move	$a0, $s4
	bal	itoa		# itoa($s4)
	
	# TODO: store return array to output_ascii

	j	ret

itoa:
	# Input: ($a0 = input integer)
	# Output: ( output_ascii )
	# TODO: (you should turn an integer into a pritable char with the right ASCII code to output_ascii)
	
	la $s5, output_ascii
	addi $s5, $s5, 4
	sw $ra, 0($sp)
	
	addi $s6, $zero, 0
	jal loop
	
	lw $ra, 0($sp)

	jr	$ra		# return

loop:
	addi $t0, $zero, 10

	beq $s6, 4, finishloop
	div $a0, $t0
	mflo $t1
	mfhi $t2
	addi $a0, $t1, 0
	addi $t2, $t2, 48
	addi $s5, $s5, -1
	sb $t2, 0($s5)
	addi $s6, $s6, 1
	j loop
	
finishloop:
	jr	$ra		# return


ret:

#STEP6: write result (output_ascii) to file_out
# ($s4 = fd_out)
	
	li	$v0, 13			# 13 = open file
	la	$a0, file_out	# $a2 <= filepath
	li	$a1, 0x4301		# $a1 <= flags = 0x4301 for Windows, 0x41 for Linux
	li	$a2, 0x1a4		# $a2 <= mode = 0
	syscall				# $v0 <= $s0 = fd_out
	move	$s4, $v0	# store fd_out in $s4
	
	li	$v0, 15			# 15 = write file
	move	$a0, $s4	# $a0 <= $s4 = fd_out
	la	$a1, output_ascii
	li	$a2, 4		
	syscall				# $v0 <= $s0 = fd
	
#STEP7: this is for you to debug your calculation on console
	li	$v0, 1			# 1 = print int
	lw	$a0, output		# $a0 <= $s1
	syscall				# print output


#STEP8: close file_in and file_out

	li	$v0, 16			# 16 = close file
	move	$a0, $s0	# $a0 <= $s0 = fd_in
	syscall				# close file

	li	$v0, 16			# 16 = close file
	move	$a0, $s4	# $a0 <= $s4 = fd_out
	syscall				# close file


# exit

	li	$v0, 10
	syscall



#######################################################################################
#
#  int atoi ( const char *str );
#
#  Parse the cstring str into an integral value
#
#  Author: http://stackoverflow.com/questions/9649761/mips-store-integer-data-into-array-from-file
atoi:
    	or      $v0, $zero, $zero   	# num = 0
   		or      $t1, $zero, $zero   	# isNegative = false
    	lb      $t0, 0($a0)
    	bne     $t0, '+', .isp      	# consume a positive symbol
    	addi    $a0, $a0, 1
.isp:
    	lb      $t0, 0($a0)
    	bne     $t0, '-', .num
    	addi    $t1, $zero, 1       	# isNegative = true
    	addi    $a0, $a0, 1
.num:
    	lb      $t0, 0($a0)
    	slti    $t2, $t0, 58        	# *str <= '9'
    	slti    $t3, $t0, '0'       	# *str < '0'
    	beq     $t2, $zero, .done
    	bne     $t3, $zero, .done
    	sll     $t2, $v0, 1
    	sll     $v0, $v0, 3
    	add     $v0, $v0, $t2       	# num *= 10, using: num = (num << 3) + (num << 1)
    	addi    $t0, $t0, -48
    	add     $v0, $v0, $t0       	# num += (*str - '0')
    	addi    $a0, $a0, 1         	# ++num
    	j   .num
.done:
    	beq     $t1, $zero, .out    	# if (isNegative) num = -num
    	sub     $v0, $zero, $v0		
.out:
    	jr      $ra         			# return

