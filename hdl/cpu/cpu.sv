import rv32i_types::*;

module cpu #(	
	parameter width 		= 32,
	parameter size 			= 32,
	parameter rob_size 		= size,
	parameter br_rs_size 	= size,
	parameter acu_rs_size 	= size,
	parameter lsq_size 		= size
)
(
	input 	logic 					clk,
	input 	logic 					rst,

	input 	logic 					i_mem_resp,
	input 	logic [width * 2-1:0] 	i_mem_rdata,
	output 	logic 					i_mem_read,
	output 	logic 					i_mem_write,
	output 	logic [(width/8)-1:0] 	i_mem_byte_enable,
	output 	logic [width-1:0] 		i_mem_address,
	output 	logic [width-1:0] 		i_mem_wdata,
	output 	logic 					iq_empty,
	output	logic					num_fetch,

	input 	logic 					lsq_mem_resp,
	input 	logic [width-1:0] 		lsq_mem_rdata,
	output 	logic 					lsq_mem_read,
	output 	logic 					lsq_mem_write,
	output 	logic [(width/8)-1:0] 	lsq_mem_byte_enable,
	output 	logic [width-1:0] 		lsq_mem_address,
	output 	logic [width-1:0] 		lsq_mem_wdata
);

	/******************* Signals Needed for RVFI Monitor *************************/
	logic load_pc;
	logic load_regfile;
	/*****************************************************************************/

	/**************************** Control Signals ********************************/
	pcmux::pcmux_sel_t pcmux_sel;
	alumux::alumux1_sel_t alumux1_sel;
	alumux::alumux2_sel_t alumux2_sel;
	regfilemux::regfilemux_sel_t regfilemux_sel;
	marmux::marmux_sel_t marmux_sel;
	cmpmux::cmpmux_sel_t cmpmux_sel;

	rv32i_opcode 		opcode;
	alu_ops 			aluop;
	branch_funct3_t 	cmpop;
	logic 		[2:0]	funct3;
	logic 		[6:0]	funct7;
	logic		[31:0]	i_imm, s_imm, b_imm, u_imm, j_imm;
	logic 				br_en, load_ir, load_mar, load_mdr, load_data_out;
	logic 		[4:0] 	rs1, rs2, rd;
	logic 		[31:0] 	mem_address_raw;
	pci_t				pci;
	/*****************************************************************************/

	/*fetcher logic*/
	logic	[63:0]		fetch_out;
	/*instruction queue logic*/
	logic 				iq_enq, iq_deq, iq_deq1, iq_full, iq_ready;
	pci_t				iq_in, iq_in1, iq_out;
	logic				num_enq;

	/*pc_reg logic*/
	logic 				pc_load;
	logic 	[width-1:0] pc_in, pc_out;
	logic 	[width-1:0] fake_pc, comp1_pc, comp3_pc;

	/* reorder buffer */
	logic 				stall_br, stall_acu, stall_lsq;
	sal_t 				br_rs_o [br_rs_size];
	sal_t 				acu_rs_o [acu_rs_size];
	sal_t 				lsq_o;
	logic 				load_br_rs, load_acu_rs, load_lsq;
	sal_t 				rob_broadcast_bus [rob_size];
	sal2_t 				rdest[rob_size];
	logic [4:0] 		rd_bus[rob_size];
	logic [$clog2(size):0] 		rd_tag;
	logic 				br_result;
	logic [width-1:0] 	pc_result;
	logic 				pc_result_load;
	logic [width-1:0]	flush_pc;
	flush_t				flush;
	pci_t 				pci1;
	logic 				load_br_rs1;
	logic 				load_lsq1;
	logic 				load_acu_rs1;
	logic [$clog2(size):0] 		rd_tag1;
	logic 				reg_ld_instr1;
	int 				iq_num_items;
	logic [$clog2(size):0] 		rob_num_available;
	
	/* regfile logic */
	logic 		reg_ld_instr;
	rs_t 		rs_out, rs_out1;
	
	/*rs and alu logic*/
 	rs_t input_r; //regfile

	rs_t 					data[acu_rs_size]; // all the reservation stations, to the alu
	rs_t 					br_data[acu_rs_size]; // all the reservation stations, to the alu
	logic [acu_rs_size-1:0] ready; // if both values are not tags, flip this ready bit to 1
	logic [acu_rs_size-1:0] br_ready; // if both values are not tags, flip this ready bit to 1
	logic	[$clog2(size):0]			lsq_num_available;
	logic	[$clog2(size):0] 			num_available; // do something if the number of available reservation stations are 0
	logic	[$clog2(size):0] 			br_num_available; // do something if the number of available reservation stations are 0
	logic 					acu_operation[acu_rs_size];
	logic 					br_acu_operation[br_rs_size];

	/*branch prediction logic*/
	logic				br_taken, br_taken1;
	logic	[width-1:0] br_addr, br_addr1;
	logic				br_miss_pc_load;
	logic	[width-1:0] br_miss_pc_save;

	// CHECKPOINT 2 LAZY BRANCH METHOD VARSs	
	logic 	[1:0]	pc_mux_sel;
	logic 	[31:0] 	pc_mux_out, br_next_pc;
	rob_t 			rob_front;

	assign fake_pc = pc_out + 8'ha0;
	assign comp1_pc = pc_out - 4'hc;
	assign comp3_pc = pc_out + 8'h20;

	assign 			iq_br 		= iq_in.is_br_instr || iq_in.opcode == op_jal || iq_in.opcode == op_jalr;
	// assigns
	assign 			pc_load 	= iq_enq & ~iq_full;

	// assign rob
	assign 			stall_acu 	= num_available == 4'd0; // stall if acu_rs is full
	assign 			stall_br  	= br_num_available == 4'd0; // stall if br_rs is full

	always_comb begin
		br_next_pc 	= 0;
		pc_mux_sel 	= 2'b00;
		num_enq 	= num_fetch;
		
		if(br_miss_pc_load) begin
			pc_mux_sel			= 2'b11;
		end
		else if(flush.valid) begin 
			pc_mux_sel 			= 2'b10;
		end 
		else begin 
			unique case(iq_in.opcode)
				op_jal	: begin 
					br_next_pc  = iq_in.jal_pc;
					pc_mux_sel 	= 2'b01;
					num_enq 	= 1'b0;
				end 

				// op_jalr	: begin 								// NEEEDDDD TO DO THIS!!!!!!!!!!!!!!!!!!!!!!!!!!! NEED TO STALL???
				// 	br_next_pc 	= rob_front.data;
				// 	pc_mux_sel 	= 2'b00;
				// end 

				op_br	: begin 
					br_next_pc 	= br_addr;
					pc_mux_sel 	= 2'b01;
					num_enq 	= 1'b0;
				end 
				
				default	: begin 
					unique case(iq_in1.opcode)
						op_jal	: begin 
							br_next_pc  = iq_in1.jal_pc;
							pc_mux_sel 	= 2'b01;
						end 

						// op_jalr	: begin 								// NEEEDDDD TO DO THIS!!!!!!!!!!!!!!!!!!!!!!!!!!! NEED TO STALL???
						// 	br_next_pc 	= rob_front.data;
						// 	pc_mux_sel 	= 2'b00;
						// end 

						op_br	: begin 
							br_next_pc 	= br_addr1;
							pc_mux_sel 	= 2'b01;
						end 
						
						default	: begin 
							br_next_pc = 0;
							pc_mux_sel = 2'b00;
						end
					endcase 
				end
			endcase 
		end

		unique case(pc_mux_sel)
			2'b00: pc_mux_out = pc_out + 4 + (4 * num_enq);
			2'b01: pc_mux_out = br_next_pc;
			2'b10: pc_mux_out = flush_pc;
			2'b11: pc_mux_out = br_miss_pc_save;
			default: ;
		endcase

	end

	always_ff @(posedge clk) begin
		if(rst) begin 
			br_miss_pc_load <= 1'b0;
			br_miss_pc_save <= 32'b0;
		end 
		else if(flush.valid & ~pc_load) begin 
			br_miss_pc_load <= 1'b1;
		end else if(br_miss_pc_load & pc_load) begin 
			br_miss_pc_load <= 1'b0;
		end

		if (flush.valid) begin
			br_miss_pc_save <= flush_pc;
		end 
	end

	pc_register pc_reg(
		.load(pc_load),	// lazy br here CHECKPOINT 2
		.in(pc_mux_out),
		.out(pc_out),
		.*
	);

	fetcher #(64) fetcher(
		.deq(~iq_full), 				// lazy br here CHECKPOINT 2
		.pc_addr(pc_out),
		.rdy(iq_enq),
		.out(fetch_out),
		.*
	);

	decoder decoder(
		.instruction(fetch_out[31:0]),
		.pc(pc_out),
		.br_taken(br_taken),
		.decoder_out(iq_in)
	);

	decoder decoder1(
		.instruction(fetch_out[63:32]),
		.pc(pc_out + 4),
		.br_taken(br_taken1),
		.decoder_out(iq_in1)
	);

	circular_q iq(
		.enq(iq_enq & ~br_miss_pc_load),
		.deq(iq_deq),
		.deq1(iq_deq1),
		.in(iq_in),
		.in1(iq_in1),
		.empty(iq_empty),
		.full(iq_full),
		.ready(iq_ready),
		.out(pci),
		.out1(pci1),
		.num_items(iq_num_items),
		.*
	);

	// reorder_buffer
	reorder_buffer #(
		.width(width),
		.size(size),
		.br_rs_size(size),
		.acu_rs_size(size),
		.lsq_size(size)
	) rob(
		.instr_q_empty(iq_empty),
		.instr_q_dequeue(iq_deq),
		.instr_q_dequeue1(iq_deq1),
		.instr_mem_resp(iq_enq),
		.lsq_num_available(lsq_num_available),
		.acu_num_available(num_available),
		.br_num_available(br_num_available),
		.iq_num_available(iq_num_items[$clog2(size):0]),
		.*
	);

	regfile #(
		.width(width),
		.size(size)
	) registers(
		.rdest(rdest),
		.rs1(pci.rs1),
		.rs2(pci.rs2),
		.rd(pci.rd),
		.rs11(pci1.rs1),
		.rs21(pci1.rs2),
		.rd1(pci1.rd),
		.rs_out(rs_out),
		.*
	);

	reservation_station #(size, size) acu_rs(
		.load(load_acu_rs),
		.load1(load_acu_rs1),
		.input_r(rs_out),
		.input_r1(rs_out1),
		.tag(rd_tag),
		.tag1(rd_tag1),
		.broadcast_bus(acu_rs_o),
		.*
	);
	
	acu #(size) acu_module(
		.data(data),
		.ready(ready),
		.acu_operation(acu_operation),
		.out(acu_rs_o),
		.*
	);
	
	load_store_q #(
		.width(width),
		.lsq_size(size),
		.size(size)
	) lsq(
		.rob_bus(rob_broadcast_bus),
		.reg_entry(rs_out),
		.instruction(pci),
		.rob_tag(rd_tag),
		.lsq_stall(stall_lsq),
		.lsq_out(lsq_o),
		.mem_resp(lsq_mem_resp),
		.mem_rdata(lsq_mem_rdata),
		.mem_read(lsq_mem_read),
		.mem_write(lsq_mem_write),
		.mem_byte_enable(lsq_mem_byte_enable),
		.mem_address(lsq_mem_address),
		.mem_wdata(lsq_mem_wdata),
		.num_available(lsq_num_available),
		.*
	);

	reservation_station #(size, size) br_rs(
		.load(load_br_rs),
		.load1(load_br_rs1),
		.input_r(rs_out),
		.input_r1(rs_out1),
		.tag(rd_tag),
		.tag1(rd_tag1),
		.broadcast_bus(br_rs_o),
		.acu_operation(br_acu_operation),
		.data(br_data),
		.ready(br_ready),
		.num_available(br_num_available),
		.*
	);

	acu #(size) acu_br(
		.data(br_data),
		.ready(br_ready),
		.acu_operation(br_acu_operation),
		.out(br_rs_o),
		.*
	);

	branch_predictor br_pred(
		.pc_info(iq_in),
		.pc_info1(iq_in1),
		.br_result(br_result),
		.pc_result(pc_result),
		.pc_result_load(pc_result_load),
		.br_taken(br_taken),
		.br_taken1(br_taken1),
		.br_addr(br_addr),
		.br_addr1(br_addr1),
		.*
	);

endmodule : cpu

/*
rob entries
0 	1
1	2
2	3
3	br
4	1
5	2
6	3
7	4

regfile
0	
1	4
2	5
3	6
4	7
5
6
7

*/
