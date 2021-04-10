cp2_tests.s:
.align 4
.section .text
.globl _start
	# Refer to the RISC-V ISA Spec for the functionality of
	# the instructions in this test program.
_start:
	lw  	x0, 	bad
	lb  	x1, 	bad
	lh 		x1, 	bad
	la 		x3, 	bad
	lh 		x1, 	2(x3)
	lb 		x1, 	1(x3)
	lb 		x1, 	2(x3)
	lb 		x1, 	3(x3)
	lw 		x1, 	bad
	lw  	x1, 	good
	la  	x2, 	result
	sb  	x1, 	0(x2)
	sh  	x1, 	0(x2)
	sw  	x1, 	0(x2)
	lw		x2, 	result
	bne		x1, 	x2, 	deadend

logic_ops:
	andi	x1, 	x1, 	0 	# x1 = 0
	addi 	x2, 	x1, 	-1	# x2 = -1
	ori 	x1, 	x2, 	0	# x1 = (x2 | 0) = -1
	xori 	x3, 	x1, 	0	# x3 = (x1 ^ 0) = -1
	bne 	x1, 	x2, 	deadend
	bne 	x1, 	x3, 	deadend

logic_reg_reg:
	lw 		x1, 	one 		# x1 = 1
	add 	x2, 	x1, 	x1	# x2 = 2
	xor  	x3, 	x1, 	x2	# x3 = 3
	and 	x4, 	x3, 	x1 	# x4 = 1
	or 		x5, 	x4, 	x2 	# x5 = 3
	bne 	x4, 	x1, 	deadend
	bne 	x5,  	x3, 	deadend
	sll 	x4, 	x4, 	x4
	bne 	x4, 	x2, 	deadend

jal_ops:
	jal 	x0, 	jal_dest 	# pc = pc + 16
	addi 	x0, 	x0, 	0	# no_ops
	addi 	x0, 	x0, 	0	# no_ops
	addi 	x0, 	x0, 	0	# no_ops

jal_dest:
	add 	x1, 	x1, 	x1
	bne 	x1, 	x2, 	deadend

jalr_ops:
	la 		x3, 	jalr_dest
	jalr 	x1, 	x3, 	0
	addi 	x0, 	x0, 	0	# no_ops
	addi 	x0, 	x0, 	0	# no_ops
	addi 	x0, 	x0, 	0	# no_ops

jalr_dest:
	bne 	x1, 	x1, 	deadend

start_fact:
	addi 	a0, 	x0, 	6

factorial:
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
	addi 	t3, 	x0, 	720
	beq 	a0, 	t3, 	halt

# ret:
# 		jr ra # Register ra holds the return address

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



halt:			 # Infinite loop to keep the processor
	beq x0, x0, halt  # from trying to execute the data below.
					  # Your own programs should also make use
					  # of an infinite loop at the end.

deadend:
	lw x8, bad   # X8 <= 0xdeadbeef
deadloop:
	beq x8, x8, deadloop

.section .rodata

bad:		.word 0xdeadbeef
threshold:  .word 0x00000040
result:	 	.word 0x00000000
good:	   	.word 0x600d600d
nice: 		.word 0xb00000b5
one: 		.word 0x00000001
