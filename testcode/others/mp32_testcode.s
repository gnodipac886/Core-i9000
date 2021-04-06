cp2_tests.s:
.align 4
.section .text
.globl _start
	# Refer to the RISC-V ISA Spec for the functionality of
	# the instructions in this test program.
_start:
	ori 	x1, 	x1, 	0x01
	la 		x2, 	threshold
	sw 		x1, 	(x2)			# 1

	addi 	x1, 	x1, 	0x01
	la 		x3, 	result
	sw 		x1, 	(x3)			# 2

	addi 	x1, 	x1, 	0x01
	sw 		x1, 	(x2)			# 3
	addi 	x1, 	x1, 	0x01
	sw 		x1, 	(x3)			# 4

	addi 	x1, 	x1, 	0x01
	la 		x4, 	good
	sw 		x1, 	(x4)
	addi 	x1, 	x1, 	0x01
	la 		x5, 	nice
	sw 		x1, 	(x5)
	addi 	x1, 	x1, 	0x01
	la 		x6, 	n_1
	sw 		x1, 	(x6)
	addi 	x1, 	x1, 	0x01
	la 		x7, 	n_2
	sw 		x1, 	(x7)
	addi 	x1, 	x1, 	0x01
	la 		x8, 	n_3
	sw 		x1, 	(x8)
	addi 	x1, 	x1, 	0x01
	la 		x9, 	n_4
	sw 		x1, 	(x9)
	addi 	x1, 	x1, 	0x01
	la 		x10, 	n_5
	sw 		x1, 	(x10)
	addi 	x1, 	x1, 	0x01
	la 		x11, 	n_6
	sw 		x1, 	(x11)
	addi 	x1, 	x1, 	0x01
	la 		x12, 	n_7
	sw 		x1, 	(x12)
	addi 	x1, 	x1, 	0x01
	la 		x13, 	n_8
	sw 		x1, 	(x13)
	addi 	x1, 	x1, 	0x01
	la 		x14, 	n_9
	sw 		x1, 	(x14)
	addi 	x1, 	x1, 	0x01
	la 		x15, 	n_10
	sw 		x1, 	(x15)
	addi 	x1, 	x1, 	0x01
	la 		x16, 	n_11
	sw 		x1, 	(x16)
	addi 	x1, 	x1, 	0x01
	la 		x17, 	n_12
	sw 		x1, 	(x17)
	addi 	x1, 	x1, 	0x01
	la 		x18, 	n_13
	sw 		x1, 	(x18)
	addi 	x1, 	x1, 	0x01
	la 		x19, 	n_14
	sw 		x1, 	(x19)
	addi 	x1, 	x1, 	0x01
	la 		x20, 	n_15
	sw 		x1, 	(x20)
	addi 	x1, 	x1, 	0x01
	la 		x21, 	n_16
	sw 		x1, 	(x21)
	addi 	x1, 	x1, 	0x01
	la 		x22, 	n_17
	sw 		x1, 	(x22)
	addi 	x1, 	x1, 	0x01
	la 		x23, 	n_18
	sw 		x1, 	(x23)
	addi 	x1, 	x1, 	0x01
	la 		x24, 	n_19
	sw 		x1, 	(x24)
	addi 	x1, 	x1, 	0x01
	la 		x25, 	n_20
	sw 		x1, 	(x25)
	addi 	x1, 	x1, 	0x01
	la 		x26, 	n_21
	sw 		x1, 	(x26)
	addi 	x1, 	x1, 	0x01
	la 		x27, 	n_22
	sw 		x1, 	(x27)
	addi 	x1, 	x1, 	0x01
	la 		x28, 	n_23
	sw 		x1, 	(x28)
	addi 	x1, 	x1, 	0x01


	# lw  	x1, 	bad
	# lw 		x2, 	threshold
	# lw 		x3, 	result
	# lw 		x4, 	good
	# lw 		x5, 	nice
	# lw 		x6, 	n_1
	# lw 		x7, 	n_2
	# lw 		x8, 	n_3
	# lw 		x9, 	n_4
	# lw 		x10, 	n_5
	# lw 		x11, 	n_6
	# lw 		x12, 	n_7
	# lw 		x13, 	n_8
	# lw 		x14, 	n_9
	# lw 		x15, 	n_10
	# lw 		x16, 	n_11
	# lw 		x17, 	n_12
	# lw 		x18, 	n_13
	# lw 		x19, 	n_14
	# lw 		x20, 	n_15
	# lw 		x21, 	n_16
	# lw 		x22, 	n_17
	# lw 		x23, 	n_18
	# lw 		x24, 	n_19
	# lw 		x25, 	n_20
	# lw 		x26, 	n_21
	# lw 		x27, 	n_22
	# lw 		x28, 	n_23
	# addi 	x29, 	x29, 	0x00000040
	# bne		x29, 	x2, 	deadend

halt:			 # Infinite loop to keep the processor
	beq x0, x0, halt  # from trying to execute the data below.
					  # Your own programs should also make use
					  # of an infinite loop at the end.

deadend:
	lw x8, bad   # X8 <= 0xdeadbeef
deadloop:
	beq x8, x8, deadloop

.section .rodata

.align 8
bad:		.word 0xdeadbeef
.align 8
threshold:  .word 0x00000040
.align 8
result:	 	.word 0x00000000
.align 8
good:	   	.word 0x600d600d
.align 8
nice: 		.word 0xb00000b5
.align 8
n_1: 		.word 0x00000001
.align 8
n_2: 		.word 0x00000002
.align 8
n_3: 		.word 0x00000003
.align 8
n_4: 		.word 0x00000004
.align 8
n_5: 		.word 0x00000005
.align 8
n_6: 		.word 0x00000006
.align 8
n_7: 		.word 0x00000007
.align 8
n_8: 		.word 0x00000008
.align 8
n_9: 		.word 0x00000009
.align 8
n_10: 		.word 0x0000000A
.align 8
n_11: 		.word 0x0000000B
.align 8
n_12: 		.word 0x0000000C
.align 8
n_13: 		.word 0x0000000D
.align 8
n_14: 		.word 0x0000000E
.align 8
n_15: 		.word 0x0000000F
.align 8
n_16: 		.word 0x00000010
.align 8
n_17: 		.word 0x00000011
.align 8
n_18: 		.word 0x00000012
.align 8
n_19: 		.word 0x00000013
.align 8
n_20: 		.word 0x00000014
.align 8
n_21: 		.word 0x00000015
.align 8
n_22: 		.word 0x00000016
.align 8
n_23: 		.word 0x00000017
.align 8
