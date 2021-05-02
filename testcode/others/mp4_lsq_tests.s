mp4_lsq_tests.s:
.align 4
.section .text
.globl _start
	# Refer to the RISC-V ISA Spec for the functionality of
	# the instructions in this test program.
_start:
    addi x1,    x1,     1
    la  x2,     bad
    sb  x1,     1(x2)
	lw 	x1, 	(x2)
	lw	x2,		nice
	# lw 	x2, 	threshold
	# lw 	x3, 	result
	# lw 	x4, 	good 
	# lw 	x5, 	nice


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
