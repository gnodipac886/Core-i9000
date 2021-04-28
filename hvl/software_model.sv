import rv32i_types::*;

module software_model #(
	parameter width 		= 32,
	parameter size 			= 8,
	parameter br_rs_size 	= 8,
	parameter acu_rs_size 	= 8,
	parameter lsq_size 		= 8
)
(
	// input logic clk,
	input logic rst,
	
	input logic commit, // whenever any of the rdest.rdy bits are 1 (link them up in a big OR?)
	input sal2_t rdest[size], // from rob
	input logic [4:0] rd_bus[size], // probably not needed

	input reg_entry_t cpu_registers[32], // the whole regfile
	input logic halt,
	input logic [31:0] pc,
	input flush_t flush 
);
timeunit 1ns;
timeprecision 1ns;
logic clk;
always #5 clk = clk === 1'b0;
default clocking tb_clk @(posedge clk); endclocking

reg_entry_t data[32];
logic [31:0] r1_data;
logic [31:0] r2_data;
pci_t pci;
logic [31:0] take_pc;
logic [31:0] pc_out;
int num_err;
task reset();
	pci = '{ opcode: op_imm, default: 0 };
	r1_data = '0;
	r2_data = '0;
	pc_out = 32'h60;
	take_pc = '0;
	num_err = 0;
	for (int i = 0; i < 32; i++) begin
		data[i] <= '{default: 0 };
	end
endtask

task ingest_rd(int index);
// get the pci from each entry, and then do a big case statement of opcodes
	pci = rdest[index].pc_info;

	case (pci.opcode)
		op_imm:
		begin
			r1_data = data[pci.rs1].data;
			r2_data = pci.i_imm;
			case (pci.funct3)
				3'b000: //addi 
				begin
					data[pci.rd].data = r1_data + r2_data;
				end
				3'b001: //slli
				begin
					data[pci.rd].data = r1_data << r2_data[4:0];
				end
				3'b010: //slti (need to do something special?)
				begin
					data[pci.rd].data = $signed(r1_data) < $signed(r2_data) ? 1'b1 : 1'b0;
				end
				3'b011: //sltiu
				begin
					data[pci.rd].data = r1_data < r2_data ? 1'b1 : 1'b0;
				end
				3'b100: //xori
				begin
					data[pci.rd].data = r1_data ^ r2_data;
				end
				3'b101: //srli OR srai
				begin
					if (~pci.funct7[5]) //srli
						data[pci.rd].data = r1_data >> r2_data[4:0];
					else
						data[pci.rd].data = $signed(r1_data) >>> r2_data[4:0];
				end
				3'b110: //ori
				begin
					data[pci.rd].data = r1_data | r2_data;
				end
				3'b111: //andi
				begin
					data[pci.rd].data = r1_data & r2_data;
				end
				default: ;
			endcase // pci.funct3
		end
		op_reg:	
		begin
			r1_data = data[pci.rs1].data;
			r2_data = data[pci.rs2].data;
			case (pci.funct3)
				3'b000: //add or sub
				begin
					if (~pci.funct7[5])
						data[pci.rd].data = r1_data + r2_data;
					else
						data[pci.rd].data = r1_data - r2_data;
				end
				3'b001: //sll
				begin
					data[pci.rd].data = r1_data << r2_data[4:0];
				end
				3'b010: //slt 
				begin
					data[pci.rd].data = $signed(r1_data) >>> r2_data[4:0];
				end
				3'b011: //sltu
				begin
					data[pci.rd].data = r1_data - r2_data;
				end
				3'b100: //xor
				begin
					data[pci.rd].data = r1_data ^ r2_data;
				end
				3'b101: //srl OR sra
				begin
					if (~pci.funct7[5]) //srli
						data[pci.rd].data = r1_data >> r2_data[4:0];
					else
						data[pci.rd].data = $signed(r1_data) >>> r2_data[4:0];
				end
				3'b110: //or
				begin
					data[pci.rd].data = r1_data | r2_data;
				end
				3'b111: //and
				begin
					data[pci.rd].data = r1_data & r2_data;
				end
				default: ;
			endcase // pci.funct3
		end
		op_br:
		begin
			r1_data = data[pci.rs1].data;
			r2_data = data[pci.rs2].data;
			take_pc = pci.branch_pc;
			case (pci.funct3)
			3'b000: //beq
			begin
				if (r1_data == r2_data ? '1 : '0)
				begin
					pc_out = take_pc;
				end
			end
			3'b001: //bne
			begin
				if (r1_data != r2_data ? '1 : '0)
				begin
					pc_out = take_pc;
				end
			end
			3'b100: //blt
			begin
				if ($signed(r1_data) < $signed(r2_data) ? '1 : '0)
				begin
					pc_out = take_pc;
				end
			end
			3'b101: //bge
			begin
				if (($signed(r1_data) > $signed(r2_data) || $signed(r1_data) == $signed(r2_data))? '1 : '0)
				begin
					pc_out = take_pc;
				end
			end
			3'b110: //bltu
			begin
				if (r1_data < r2_data ? '1 : '0)
				begin
					pc_out = take_pc;
				end
			end
			3'b111: //bgeu
			begin
				if ((r1_data > r2_data || r1_data ==r2_data) ? '1 : '0)
				begin
					pc_out = take_pc;
				end
			end
			default:;
			endcase
		end
		op_lui:
		begin
			data[pci.rd].data = pci.u_imm;
		end
		op_auipc:
		begin
			//	pc_out = pci.pc + pci.u_imm;
			data[pci.rd].data = pci.pc + pci.u_imm;
		end
		op_jal:
		begin
			pc_out = pci.pc + pci.j_imm;
			data[pci.rd].data = pci.pc + 4;
		end
		op_jalr:
		begin
			r1_data = data[pci.rs1].data;
			pc_out = r1_data + pci.i_imm;
			data[pci.rd].data = pci.pc + 4;
		end
		op_load: // TODO: MAKE A MEANINGFUL LOAD CASE
		begin
			//currently looks in the rdest data, copies that to the software model
			data[pci.rd].data = rdest[index].data;
		end
		op_store:;
		default:;
	endcase // pci.opcode

	if (pci.opcode != op_br && pci.opcode != op_jal && pci.opcode != op_jalr)
		pc_out = pc_out + 4;
	data[0].data = 32'b0;
endtask
logic flag = 1'b0;
task compare_registers();
	// $display("comparing registers at %0t", $time);
	flag = 1'b0;
	for (int i = 0; i < 32; i++) begin
		assert (cpu_registers[i].data == data[i].data) //$display("%0t: register %0d matches", $time, i);
		else begin 
			$error("%0t: register %0d should be %0x, but it is %0x", $time, i, data[i].data, cpu_registers[i].data);
			flag = 1'b1;
		end
	end
	// assert(pc == pc_out)
	// else begin
	// 	$error("%0t: pc should be %0x, but it is %0x", $time, pc_out, pc);
	// 	flag = 1'b1;
	// end
	if (flag) num_err++;
	if (~flag) $display("all good at commit %4t, num_err:%4t", $time, num_err);
	
endtask

initial begin : TEST_VECTORS
	reset();


end

always @(posedge tb_clk iff commit) begin
		for (int i = 0; i < size; i++) begin
			if (~rdest[(i + flush.front_tag) % size].rdy) begin
				continue;
			end else begin
				ingest_rd((i + flush.front_tag) % size);
			end
		end
end

always @(negedge commit) begin
	// we want to compare the registers after the rdest has propogated (next cycle)	
	compare_registers();
end




endmodule : software_model
