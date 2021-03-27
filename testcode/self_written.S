riscv_mp2test.s:
.align 4
.section .text
.globl _start
	# Refer to the RISC-V ISA Spec for the functionality of
	# the instructions in this test program.
_start:
	lw  	x0, 	bad
	lw  	x1, 	bad
	# lw  	x1, 	x0
	lw  	x1, 	good
	la  	x2, 	result
	# sw  	x1, 	0(x0)
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
	# reg reg?

shift_ops:
	lw 		x1, 	bad
	lw 		x2,	 	bad
	slli 	x1, 	x1, 	1
	srai 	x1, 	x1, 	1
	srli 	x1, 	x1, 	1
	beq 	x1, 	x2, 	deadend
	slli 	x1,	 	x1,	 	31
	slli 	x1, 	x1, 	1
	bne 	x1, 	x0, 	deadend

arith_ops:
	andi 	x1, 	x1, 	0
	addi 	x1, 	x1, 	-1
	addi 	x1, 	x1,	 	1
	bne 	x1, 	x0, 	deadend

	andi 	x2,	 	x2, 	0
	addi 	x2, 	x2, 	-1		# x2 = -1, x1 = 0

	slti 	x3, 	x1, 	-1 		# 0 < -1 ?
	bne 	x3, 	x0, 	deadend
	andi 	x3, 	x3, 	0

	slti 	x3, 	x2, 	0 		# -1 < 0 ?
	beq 	x3, 	x0, 	deadend
	andi 	x3, 	x3, 	0

	sltiu 	x3, 	x1, 	-1 		# 0 < FFFF ?
	beq 	x3, 	x0, 	deadend
	andi 	x3, 	x3, 	0

	sltiu 	x3, 	x2, 	0 		# FFFF < 0 ?
	bne 	x3, 	x0, 	deadend
	andi 	x3, 	x3, 	0

branch_ops:
	bge 	x1, 	x2, 	br_one
	beq 	x1, 	x1, 	deadend

br_one:
	blt	 	x2, 	x1, 	br_two
	beq 	x1, 	x1, 	deadend

br_two:
	bne 	x2, 	x1, 	br_three
	beq 	x1, 	x1, 	deadend

br_three:	
	bltu 	x1,		x2, 	br_four
	beq 	x1, 	x1, 	deadend

br_four:
	bgeu 	x2, 	x1, 	halt
	beq 	x1, 	x1, 	deadend



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
