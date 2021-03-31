module regfile #(paramter width = 32)
(
	input clk,
	input rst,
	input load,
	input sal_t rdest,
	input [4:0] rs1, rs2,
	output rs_t rs1_out, rs2_out,
);
