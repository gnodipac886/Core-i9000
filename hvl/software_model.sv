import rv32i_types::*;

module software_model #(
	parameter width 		= 32,
	parameter size 			= 8,
	parameter br_rs_size 	= 8,
	parameter acu_rs_size 	= 8,
	parameter lsq_size 		= 8
)
(
	input logic clk,
	input logic rst,
	
	input logic commit, // whenever any of the rdest.rdy bits are 1 (link them up in a big OR?)
	input sal_t rdest[size], // from rob
	input logic [4:0] rd_bus[size], // probably not needed

	input reg_entry_t cpu_registers[32], // the whole regfile
)

reg_entry_t data[32];
logic [31:0] r1_data;
logic [31:0] r2_data;
pci_t pci;
task reset();
	pci = '{ opcode: op_imm, default: 0 };
	r1_data = '0;
	r2_data = '0;
	for (int i = 0; i < 32; i++) begin
		data[i] <= '{default: 0 };
	end
endtask

task ingest_rd(int index);
// get the pci from each entry, and then do a big case statement of opcodes
	pci = rdest[i].pci;

	case (pci.opcode)
		op_imm:
		begin
			r1_data = data[pci.rs1];
			r2_data = pci.i_imm;
			case (pci.funct3)
				3'b000: //addi
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				3'b001: //slli
				begin
					data[pci.rd] = r1_data << r2_data[4:0];
				end
				3'b010: //slti
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				3'b011: //sltiu
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				3'b100: //xori
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				3'b101: //srli OR srai
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				3'b110: //ori
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				3'b111: //andi
				begin
					data[pci.rd] = r1_data + r2_data;
				end
				default: ;
			endcase // pci.funct3
		end
		default:;
	endcase // pci.opcode
endtask

task compare_registers();
	for (int i = 0; i < 32, i++) begin
		assert (cpu_registers[i].data == data[i].data); $info("%0t: register %0d matches", $time, i);
		else $error("%0t: register %0d should be %0d, but it is %0d", $time, i, data[i].data, cpu_registers[i].data);
	end
endtask

initial begin : TEST_VECTORS
	reset();
	@(commit);
	for (int i = 0; i < size; i++) begin
		if (~rdest[i].rdy) begin
			continue;
		end else begin
			ingest_rd(i);
		end
	end
	compare_registers();



end

import rv32i_types::*;

// module decoder #(parameter width = 32)
// (
// 	input 	logic 	[width-1:0] 	instruction,
// 	input 	logic 	[width-1:0] 	pc,
// 	input	logic					br_taken,
// 	output 	pci_t 					decoder_out
// );

// 	logic [31:0] 	data;
// 	pci_t 			pci;

// 	assign data 			= instruction;
// 	assign decoder_out 		= pci;
	
// 	assign pci.pc 			= pc;
// 	assign pci.instruction 	= data;
// 	assign pci.funct3 		= data[14:12];
// 	assign pci.funct7 		= data[31:25];
// 	assign pci.opcode 		= rv32i_opcode'(data[6:0]);
// 	assign pci.i_imm 		= {{21{data[31]}}, data[30:20]};
// 	assign pci.s_imm 		= {{21{data[31]}}, data[30:25], data[11:7]};
// 	assign pci.b_imm 		= {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
// 	assign pci.u_imm 		= {data[31:12], 12'h000};
// 	assign pci.j_imm 		= {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};
// 	assign pci.rs1 			= data[19:15];
// 	assign pci.rs2 			= data[24:20];
// 	assign pci.rd 			= data[11:7];
// 	assign pci.is_br_instr 	= pci.opcode == op_br;
// 	assign pci.br_pred 		= br_taken;
// 	assign pci.branch_pc	= pc + pci.b_imm;
// 	assign pci.jal_pc 		= pc + pci.j_imm;

// endmodule : decoder



