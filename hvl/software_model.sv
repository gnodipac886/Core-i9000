import rv32i_types::*;

module software_model #(
	parameter width 		= 32,
	parameter size 			= 8,
	parameter br_rs_size 	= 8,
	parameter acu_rs_size 	= 8,
	parameter lsq_size 		= 8,
	parameter NUM_PC 		= 16
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
	input flush_t flush,
	input logic pc_load,
	input logic [31:0] pc_mux_out, 
	input int num_deq 
);
timeunit 1ns;
timeprecision 1ns;
logic clk;
always #5 clk = clk === 1'b0;
default clocking tb_clk @(posedge clk); endclocking

/* Software Model Memory */
/*
	Method 1:
	tb_itf.mem sm_mem_itf(clk);
	memory #(1) sm_mem(.itf(sm_mem_itf));
*/
/*
Method 2: 
*/
logic [7:0] sm_mem [logic [31:0]];

reg_entry_t data[32];
logic [31:0] r1_data;
logic [31:0] r2_data;
pci_t pci;
logic [31:0] take_pc;
logic [31:0] pc_out;
logic [31:0] pc_hist[NUM_PC];
int num_err, num_commit;

task reset();
	/*
		Method 2:
	*/
	sm_mem.delete();
	$readmemh("memory32.lst", sm_mem);
	$display("Reset Software Model Memory");
	$display("Addr: %x, data: %x", 32'h0, sm_mem[32'h0]);
	$display("Addr: %x, data: %x", 32'h90, sm_mem[32'h90]);
	$display("Addr: %x, data: %x", 32'h91, sm_mem[32'h91]);
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
	if(pci.pc != pc_out)
		$error("%0t: PC mismatch at pc: %0x, pc_out: %0x", $time, pci.pc, pc_out);

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
						pc_out =  (r1_data == r2_data) ? take_pc : pc_out + 4;
				3'b001: //bne
						pc_out =  (r1_data != r2_data) ? take_pc : pc_out + 4;
				3'b100: //blt
						pc_out =  ($signed(r1_data) < $signed(r2_data)) ? take_pc : pc_out + 4;
				3'b101: //bge
						pc_out =  (($signed(r1_data) > $signed(r2_data) || $signed(r1_data) == $signed(r2_data))) ? take_pc : pc_out + 4;
				3'b110: //bltu
						pc_out =  (r1_data < r2_data) ? take_pc : pc_out + 4;
				3'b111: //bgeu
						pc_out =  ((r1_data > r2_data || r1_data == r2_data)) ? take_pc : pc_out + 4;
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
			// BEFORE
			//data[pci.rd].data = rdest[index].data;
			// AFTER
			/*
			for (int i = 0; i < 4; i++) begin
				data[pci.rd].data[(8 * i) +: 8] = sm_mem[data[pci.rs1].data + pci.i_imm + i];
			end
			*/
			unique case (load_funct3_t'(pci.funct3))
				lb	: data[pci.rd].data = { {24{sm_mem[data[pci.rs1].data + pci.i_imm + 0][7]}},
											sm_mem[data[pci.rs1].data + pci.i_imm + 0] }; 
				lh	: data[pci.rd].data = { {16{sm_mem[data[pci.rs1].data + pci.i_imm + 1][7]}},
											sm_mem[data[pci.rs1].data + pci.i_imm + 1],  
											sm_mem[data[pci.rs1].data + pci.i_imm + 0] }; 
				lw	: data[pci.rd].data = { sm_mem[data[pci.rs1].data + pci.i_imm + 3], 
											sm_mem[data[pci.rs1].data + pci.i_imm + 2],  
											sm_mem[data[pci.rs1].data + pci.i_imm + 1],  
											sm_mem[data[pci.rs1].data + pci.i_imm + 0] }; 
				lbu	: data[pci.rd].data = { 24'd0,
											sm_mem[data[pci.rs1].data + pci.i_imm + 0] }; 
				lhu	: data[pci.rd].data = { 16'd0, 
											sm_mem[data[pci.rs1].data + pci.i_imm + 1],  
											sm_mem[data[pci.rs1].data + pci.i_imm + 0] }; 
				default: ;
			endcase
		end
		op_store:
		begin
			unique case(store_funct3_t'(pci.funct3))
				sb	: begin 
						sm_mem[data[pci.rs1].data + pci.s_imm + 0] = data[pci.rs2].data[7:0];
					end
				sh	: begin 
						sm_mem[data[pci.rs1].data + pci.s_imm + 0] = data[pci.rs2].data[7:0];
						sm_mem[data[pci.rs1].data + pci.s_imm + 1] = data[pci.rs2].data[15:8];
					end
				sw	: begin 
						sm_mem[data[pci.rs1].data + pci.s_imm + 0] = data[pci.rs2].data[7:0];
						sm_mem[data[pci.rs1].data + pci.s_imm + 1] = data[pci.rs2].data[15:8];
						sm_mem[data[pci.rs1].data + pci.s_imm + 2] = data[pci.rs2].data[23:16];
						sm_mem[data[pci.rs1].data + pci.s_imm + 3] = data[pci.rs2].data[31:24];
					end
			endcase
		end
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
	// if (~flag) $display("all good at commit %4t, num_err:%4t", $time, num_err);
	
endtask

task compare_pc();
	if(pc_out == pc) 
		return;
	if(~pc_load && pc_out == pc_mux_out)
		return;
	for(int i = 0; i < NUM_PC; i++) begin 
		if(pc_out == pc_hist[i]) begin 
			return;
		end 
	end 
	// $error("%0t: PC mismatch", $time);
endtask

initial begin : TEST_VECTORS
	reset();
end

always_comb begin
	num_commit = 0;
	for(int i = 0; i < 8; i++) begin 
		if(rdest[i].rdy)
			num_commit++;
	end 
end

always_ff @(posedge tb_clk iff pc_load) begin
	pc_hist[0] <= pc;
	for(int i = 0; i < NUM_PC - 1; i++) begin 
		pc_hist[i + 1] <= pc_hist[i];
	end  
end

always @(posedge tb_clk iff commit) begin
	for (int i = 0; i < num_deq && i < size; i++) begin
		ingest_rd((i + flush.front_tag) % size);
	end
end

always @(negedge commit) begin
	// we want to compare the registers after the rdest has propogated (next cycle)	
	compare_registers();
	compare_pc();
end




endmodule : software_model
