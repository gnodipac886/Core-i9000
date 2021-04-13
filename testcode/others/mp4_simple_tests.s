mp4_simple_tests.s:
.align 4
.section .text
.globl _start
	# Refer to the RISC-V ISA Spec for the functionality of
	# the instructions in this test program.
_start:
	addi    x0,     x0,     0
	addi    x2,     x0,     2
	addi    x4,     x0,     4
	addi    x6,     x0,     6
	addi    x8,     x0,     8

alu:
    add     x4,     x2,     x0      # x4 <= 2 + 0 = 2
    add     x6,     x8,     x6      # x6 <= 8 + 6 = 14
    sub     x8,     x2,     x0      # x8 <= 2 - 0 = 2
    lw      x2,     bad
    add     x4,     x2,     x8      # dependency on previous instruction
    la      x5,     result          # x5 <= result
    sw      x4,     0(x5)           # dependency on add and lw
    


lsq:
	lw 	x1, 	bad
	lw 	x2, 	threshold
	lw 	x3, 	result
	lw 	x4, 	good 
	lw 	x5, 	nice


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
