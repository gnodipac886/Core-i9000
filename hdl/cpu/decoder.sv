import rv32i_types::*;

module decoder #(parameter width = 32)
(
	input 	logic 	[width-1:0] 	instruction,
	input 	logic 	[width-1:0] 	pc,
	output 	pci_t 					decoder_out
);

	logic [31:0] 	data;
	pci_t 			pci;

	assign data 			= instruction;
	assign decoder_out 		= pci;
	
	assign pci.pc 			= pc;
	assign pci.instruction 	= instruction;
	assign pci.funct3 		= data[14:12];
	assign pci.funct7 		= data[31:25];
	assign pci.opcode 		= rv32i_opcode'(data[6:0]);
	assign pci.i_imm 		= {{21{data[31]}}, data[30:20]};
	assign pci.s_imm 		= {{21{data[31]}}, data[30:25], data[11:7]};
	assign pci.b_imm 		= {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
	assign pci.u_imm 		= {data[31:12], 12'h000};
	assign pci.j_imm 		= {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};
	assign pci.rs1 			= data[19:15];
	assign pci.rs2 			= data[24:20];
	assign pci.rd 			= data[11:7];
	assign pci.is_br_instr 	= pci.opcode == op_br;
	assign pci.br_pred 		= 0;

endmodule : decoder
