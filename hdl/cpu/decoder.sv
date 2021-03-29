import rv32i_types::*;

module decoder #(parameter width = 32)
(
	input 	logic 	[width-1:0] 	instruction,
	input 	logic 	[width-1:0] 	pc,
	output	logic 	[2:0] 			funct3,
	output	logic 	[6:0] 			funct7,
	output	rv32i_opcode 			opcode,
	output	logic 	[31:0] 			i_imm,
	output	logic 	[31:0] 			s_imm,
	output	logic 	[31:0] 			b_imm,
	output	logic 	[31:0] 			u_imm,
	output	logic 	[31:0] 			j_imm,
	output	logic 	[4:0] 			rs1,
	output	logic 	[4:0] 			rs2,
	output	logic 	[4:0] 			rd,
	output 	pci_t 					pci
);

	logic [31:0] data;

	assign data 			= instruction;
	assign funct3 			= data[14:12];
	assign funct7 			= data[31:25];
	assign opcode 			= rv32i_opcode'(data[6:0]);
	assign i_imm 			= {{21{data[31]}}, data[30:20]};
	assign s_imm 			= {{21{data[31]}}, data[30:25], data[11:7]};
	assign b_imm 			= {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
	assign u_imm 			= {data[31:12], 12'h000};
	assign j_imm 			= {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};
	assign rs1 				= data[19:15];
	assign rs2 				= data[24:20];
	assign rd 				= data[11:7];

	assign pci.pc 			= pc;
	assign pci.instruction 	= instruction;
	assign pci.is_br_instr 	= opcode == op_br;
	assign pci.br_pred 		= 0;

endmodule : decoder
