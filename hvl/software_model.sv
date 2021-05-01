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
	input logic clk,
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
// timeunit 1ns;
// timeprecision 1ns;
// logic clk;
// always #5 clk = clk === 1'b0;
// default clocking clk @(posedge clk); endclocking

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
pci_t pci, cpu_pci;
logic [31:0] take_pc;
logic [31:0] sm_pc;
logic [31:0] sm_inst;
logic [31:0] pc_hist[NUM_PC];
int num_err, num_commit;

/*
decoder sm_decoder(
	.instruction({ sm_mem[sm_pc + 3], sm_mem[sm_pc + 2], sm_mem[sm_pc + 1], sm_mem[sm_pc] }),
	.pc(sm_pc),
	.br_taken(1'b0),
	.decoder_out(pci)
);
*/

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
	cpu_pci = '{ opcode: op_imm, default: 0 };
	r1_data = '0;
	r2_data = '0;
	sm_pc = 32'h60;
	sm_inst = { sm_mem[sm_pc + 3], sm_mem[sm_pc + 2], sm_mem[sm_pc + 1], sm_mem[sm_pc] };
	pci = decode_inst(sm_inst, sm_pc);
	take_pc = '0;
	num_err = 0;
	for (int i = 0; i < 32; i++) begin
		data[i] <= '{default: 0 };
	end
endtask

task ingest_rd(int index);
// get the pci from each entry, and then do a big case statement of opcodes
	cpu_pci = rdest[index].pc_info;
	if(num_deq > 1) 
		$display("time: %d, num_deq flag, %d, pc: %x", $time, index, pci.pc);
	if(cpu_pci.pc != sm_pc) begin 
		$error("%0t: PC mismatch at pc: %0x, sm_pc: %0x", $time, pci.pc, sm_pc);
		$finish;
	end 

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
			case (arith_funct3_t'(pci.funct3))
				add: //add or sub
				begin
					if (~pci.funct7[5])
						data[pci.rd].data = r1_data + r2_data;
					else
						data[pci.rd].data = r1_data - r2_data;
				end
				sll: //sll
				begin
					data[pci.rd].data = r1_data << r2_data[4:0];
				end
				slt: //slt 
				begin
					// data[pci.rd].data = $signed(r1_data) <<< r2_data[4:0];
					data[pci.rd].data = $signed(r1_data) < $signed(r2_data) ? 1'b1 : 1'b0;
				end
				sltu: //sltu
				begin
					// data[pci.rd].data = r1_data - r2_data;
					data[pci.rd].data = r1_data < r2_data ? 1'b1 : 1'b0;
				end
				axor: //xor
				begin
					data[pci.rd].data = r1_data ^ r2_data;
				end
				sr: //srl OR sra
				begin
					if (~pci.funct7[5]) //srli
						data[pci.rd].data = r1_data >> r2_data[4:0];
					else
						data[pci.rd].data = $signed(r1_data) >>> r2_data[4:0];
				end
				aor: //or
				begin
					data[pci.rd].data = r1_data | r2_data;
				end
				aand: //and
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
						sm_pc =  (r1_data == r2_data) ? take_pc : sm_pc + 4;
				3'b001: //bne
						sm_pc =  (r1_data != r2_data) ? take_pc : sm_pc + 4;
				3'b100: //blt
						sm_pc =  ($signed(r1_data) < $signed(r2_data)) ? take_pc : sm_pc + 4;
				3'b101: //bge
						sm_pc =  (($signed(r1_data) > $signed(r2_data) || $signed(r1_data) == $signed(r2_data))) ? take_pc : sm_pc + 4;
				3'b110: //bltu
						sm_pc =  (r1_data < r2_data) ? take_pc : sm_pc + 4;
				3'b111: //bgeu
						sm_pc =  ((r1_data > r2_data || r1_data == r2_data)) ? take_pc : sm_pc + 4;
				default:;
			endcase
		end
		op_lui:
		begin
			data[pci.rd].data = pci.u_imm;
		end
		op_auipc:
		begin
			//	sm_pc = pci.pc + pci.u_imm;
			data[pci.rd].data = pci.pc + pci.u_imm;
		end
		op_jal:
		begin
			sm_pc = pci.pc + pci.j_imm;
			data[pci.rd].data = pci.pc + 4;
		end
		op_jalr:
		begin
			r1_data = data[pci.rs1].data;
			sm_pc = r1_data + pci.i_imm;
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
			//$display("Load (%0t PC: %x) Address: %x, Data %x", $time, pci.pc, data[pci.rs1].data + pci.i_imm, data[pci.rd].data);
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
			//$display("Store (%0t PC: %x) Address: %x, Data %x", $time, pci.pc, data[pci.rs1].data + pci.s_imm, data[pci.rs2].data);
		end
		default:;
	endcase // pci.opcode

	if (pci.opcode != op_br && pci.opcode != op_jal && pci.opcode != op_jalr)
		sm_pc = sm_pc + 4;
	sm_inst = { sm_mem[sm_pc + 3], sm_mem[sm_pc + 2], sm_mem[sm_pc + 1], sm_mem[sm_pc] };
	pci = decode_inst(sm_inst, sm_pc);
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
	// assert(pc == sm_pc)
	// else begin
	// 	$error("%0t: pc should be %0x, but it is %0x", $time, sm_pc, pc);
	// 	flag = 1'b1;
	// end
	if (flag) num_err++;
	// if (~flag) $display("all good at commit %4t, num_err:%4t", $time, num_err);
	
endtask

// task compare_pc();
// 	if(sm_pc == pc) 
// 		return;
// 	if(~pc_load && sm_pc == pc_mux_out)
// 		return;
// 	for(int i = 0; i < NUM_PC; i++) begin 
// 		if(sm_pc == pc_hist[i]) begin 
// 			return;
// 		end 
// 	end 
//	$error("%0t: PC mismatch", $time);
// endtask

initial begin : TEST_VECTORS
	reset();
end

// always_comb begin
// 	num_commit = 0;
// 	for(int i = 0; i < 8; i++) begin 
// 		if(rdest[i].rdy)
// 			num_commit++;
// 	end 
// end

// always_ff @(posedge clk iff pc_load) begin
// 	pc_hist[0] <= pc;
// 	for(int i = 0; i < NUM_PC - 1; i++) begin 
// 		pc_hist[i + 1] <= pc_hist[i];
// 	end  
// end

always @(posedge clk iff commit) begin
	for (int i = 0; i < num_deq && i < size; i++) begin
		ingest_rd((i + flush.front_tag) % size);
	end
	// compare_registers();
	//compare_pc();
end

// always_comb begin
// 	if(commit) begin 
// 		for (int i = 0; i < num_deq && i < size; i++) begin
// 			ingest_rd((i + flush.front_tag) % size);
// 		end
// 		compare_registers();
// 	end 
// end

always @(negedge clk iff commit) begin
	// we want to compare the registers after the rdest has propogated (next cycle)	
	compare_registers();
	//compare_pc();
end

endmodule : software_model


function pci_t decode_inst(logic [31:0] data, logic [31:0] pc);
	return '{
		pc				: pc,
		instruction		: data,
		funct3			: data[14:12],
		funct7			: data[31:25],
		opcode			: rv32i_opcode'(data[6:0]),
		i_imm			: {{21{data[31]}}, data[30:20]},
		s_imm			: {{21{data[31]}}, data[30:25], data[11:7]},
		b_imm			: {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0},
		u_imm			: {data[31:12], 12'h000},
		j_imm			: {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0},
		rs1				: data[19:15],
		rs2				: data[24:20],
		rd				: data[11:7],
		is_br_instr		: rv32i_opcode'(data[6:0]) == op_br,
		br_pred			: 1'b0,
		branch_pc		: pc + {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0},
		jal_pc			: {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0}
	};
endfunction
