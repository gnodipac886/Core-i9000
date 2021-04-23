mp4_simple_tests.s:
.align 4
.section .text
.globl _start
	# Refer to the RISC-V ISA Spec for the functionality of
	# the instructions in this test program.
_start:
	jal 	branch_pred_tests 	
	addi    x0,     x0,     0
	addi    x2,     x0,     2
	beq 	x2, 	x0, 	halt
	addi    x4,     x0,     4
	addi    x6,     x0,     6
	addi    x8,     x0,     8

alu:
	addi	x3,		x0,		-1		# x3 <= -1
	slt		x1,		x0,		x2		# x1 <= 0 < 2 -> 1
	sltu	x3,		x3,		x0		# x3 <= 0 < unsigned(-1) -> 1
	sltiu	x5,		x0,		-1		# x5 <= 0 < unsigned(-1) -> 1
	slti	x7,		x0,		-1		# x7 <= 0 < -1 -> 0
	slt		x9,		x0,		x0		# x9 <= 0 < 0 -> 0
	sltu	x11,	x0,		x0		# x11 <= 0 < 0 -> 0
    lw      x2,     result
    add     x4,     x2,     x8      # dependency on previous instruction
	add 	x8, 	x4, 	x4
	add 	x9, 	x8, 	x8
	add 	x10, 	x9, 	x9 
	add 	x11, 	x10, 	x10
    la      x5,     result          # x5 <= result
    sw      x4,     0(x5)           # dependency on add and lw
    beq 	x0, 	x0, 	halt
	add     x4,     x2,     x8      # dependency on previous instruction
	add 	x8, 	x4, 	x4
	add 	x9, 	x8, 	x8
	add 	x10, 	x9, 	x9 
	add 	x11, 	x10, 	x10
	
branch_pred_tests:
	and 	x1, x1, x0
	addi 	x2, x2, 10
loop:
	add 	x1, x1, 1
	bne 	x1, x2, loop
	

# lsq:
# 	lw 	x1, 	bad
# 	lw 	x2, 	threshold
# 	lw 	x3, 	result
# 	lw 	x4, 	good 
# 	lw 	x5, 	nice


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
result:	 	.word 0x00000002
good:	   	.word 0x600d600d
nice: 		.word 0xb00000b5
