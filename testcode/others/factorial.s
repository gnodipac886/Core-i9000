factorial.s:
 .align 4
 .section .text
 .globl factorial


 # Register a0 holds the input value
 # Register t0-t6 are caller-save, so you may use them without saving
 # Return value need to be put in register a0
 # Your code starts here

 # t2 - next value to multiply with
factorial:
	addi 	a0, 	x0, 	5
	beq 	a0, 	x0, 	case_0	# base cases
	addi 	t2, 	x0, 	1
	beq 	a0, 	t2, 	ret

	addi 	t2, 	a0, 	-1	# set t2 to input - 1

fact_loop:
	addi 	a1, 	t2, 	0 	# set a1 to the next value to mult with
	addi 	t2, 	t2, 	-1 	# t2--
	jal 	t0, 	mult 		# call multiplication function
	bne 	t2, 	x0, 	fact_loop
	jal 	x0, 	ret

case_0:
	addi 	a0, 	x0, 	1

ret:
		jr ra # Register ra holds the return address

# a0, a1 holds the input values
# a0 holds the output
# t0 return address
# t1 counter
# t5 original a0 value
mult:
	addi 	t1, 	x0, 	1	# set t1 to 1
	addi 	t5, 	a0, 	0 	# set t5 to original a0 value
	beq 	t1, 	a1, 	mult_return

	beq 	a0, 	x0, 	mult_return	# see if a0 is 0
	bne 	a1, 	x0, 	mult_loop	# see if a1 is not -
	addi 	a0, 	x0, 	0			# set a0 to 0
	jal 	x0, 	mult_return 		# return

mult_loop:
	add 	a0, 	a0, 	t5 	# add once
	addi 	t1, 	t1, 	1 	# t0++
	blt 	t1, 	a1, 	mult_loop 

mult_return:
	jalr 	x0, 	t0, 	0

 .section .rodata
 # if you need any constants
 some_label:	.word 0x6