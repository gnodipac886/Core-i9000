import rv32i_types::*;

module cpu #(	
	parameter width 		= 32,
	parameter rob_size 		= 8,
	parameter br_rs_size 	= 3,
	parameter acu_rs_size 	= 8,
	parameter lsq_size 		= 8
)
(
	input 	logic 					clk,
	input 	logic 					rst,

	input 	logic 					i_mem_resp,
	input 	logic [width-1:0] 		i_mem_rdata,
	output 	logic 					i_mem_read,
	output 	logic 					i_mem_write,
	output 	logic [(width/8)-1:0] 	i_mem_byte_enable,
	output 	logic [width-1:0] 		i_mem_address,
	output 	logic [width-1:0] 		i_mem_wdata,
	output 	logic 					iq_empty,

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
	logic	[width-1:0]	fetch_out;
	/*instruction queue logic*/
	logic 				iq_enq, iq_deq, iq_full, iq_ready;
	pci_t				iq_in, iq_out;

	/*pc_reg logic*/
	logic 				pc_load;
	logic 	[width-1:0] pc_in, pc_out;

	/* reorder buffer */
	logic 		stall_br, stall_acu, stall_lsq;
	sal_t 		br_rs_o [br_rs_size];
	sal_t 		acu_rs_o [acu_rs_size];
	sal_t 		lsq_o;
	logic 		load_br_rs, load_acu_rs, load_lsq;
	sal_t 		rob_broadcast_bus [rob_size];
	sal_t 		rdest;
	logic [3:0] rd_tag;
	
	/* regfile logic */
	logic 		reg_ld_instr;
	rs_t 		rs_out;
	
	/*rs and alu logic*/

	logic flush;

 	rs_t input_r; //regfile

	sal_t acu_broadcast_bus[acu_rs_size]; // after computation is done, coming back from alu
	// sal_t rob_broadcast_bus[rob_size]; // after other rs is done, send data from ROB to rs

	rs_t data[acu_rs_size]; // all the reservation stations, to the alu
	logic [acu_rs_size-1:0] ready; // if both values are not tags, flip this ready bit to 1
	logic[3:0] num_available; // do something if the number of available reservation stations are 0
	logic acu_operation[acu_rs_size];

	// assigns
	assign 	pc_load = iq_enq & ~iq_full;

	// assign rob
	assign 	stall_acu = num_available == 4'd0;

	pc_register pc_reg(
		.load(pc_load),
		.in(pc_out + 4),
		.out(pc_out),
		.*
	);
	
	fetcher fetcher(
		.deq(~iq_full),
		.pc_addr(pc_out),
		.rdy(iq_enq),
		.out(fetch_out),
		.*
	);

	decoder decoder(
		.instruction(fetch_out),
		.pc(pc_out),
		.decoder_out(iq_in)
	);

	circular_q iq(
		.enq(iq_enq),
		.deq(iq_deq),
		.in(iq_in),
		.empty(iq_empty),
		.full(iq_full),
		.ready(iq_ready),
		.out(pci),
		.*
	);

	// reorder_buffer
	reorder_buffer rob(
		.instr_q_empty(iq_empty),
		.instr_q_dequeue(iq_deq),
		.instr_mem_resp(iq_enq),
		.acu_rs_o(acu_broadcast_bus),
		.*
	);

	regfile registers(
		.rdest(rdest),
		.rs1(pci.rs1),
		.rs2(pci.rs2),
		.rd(pci.rd),
		.rs_out(rs_out),
		.*
	);

	reservation_station acu_rs(
		.load(load_acu_rs),
		.input_r(rs_out),
		.tag(rd_tag),
		.broadcast_bus(acu_broadcast_bus),
		.*
	);
	
	acu acu_module(
		.data(data),
		.ready(ready),
		.acu_operation(acu_operation),
		.out(acu_broadcast_bus)
	);
	
	load_store_q lsq(
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
		.*
	);

	// reservation_station cmp_rs(
	// );

	// cmp cmp_module(
	// );

endmodule : cpu
