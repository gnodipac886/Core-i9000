import rv32i_types::*;

module decoder #(parameter width = 32)
(
	input 	logic 	[width-1:0] 	instruction,
	input 	logic 	[width-1:0] 	pc,
	output 	logic 	[2:0]			funct3,
	output 	logic 	[6:0]			funct7,
	output 	logic 	[4:0]			rs1, 
	output 	logic 	[4:0] 			rs2,
	output 	logic 	[4:0]			rd,
	output 	pci_t 					pci
);


endmodule : decoder
