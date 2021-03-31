import rv32i_types::*;

module cpu #(parameter width = 32)
(
	input 	logic 					clk,
	input 	logic 					rst,

	input 	logic 					mem_resp,
	input 	logic [width-1:0] 		mem_rdata,
	output 	logic 					mem_read,
	output 	logic 					mem_write,
	output 	logic [(width/8)-1:0] 	mem_byte_enable,
	output 	logic [width-1:0] 		mem_address,
	output 	logic [width-1:0] 		mem_wdata
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
	logic 				br_en, load_ir, load_mar, load_mdr, load_data_out;
	logic 		[4:0] 	rs1, rs2;
	logic 		[31:0] 	mem_address_raw;
	/*****************************************************************************/

	/*instruction queue logic*/
	logic 				iq_enq, iq_deq, iq_empty, iq_full, iq_ready;
	logic 	[width-1:0] iq_in, iq_out;

	/*pc_reg logic*/
	logic 	[width-1:0] pc_in, pc_out, pc_load;

	assign 	pc_load = iq_enq & ~iq_full;
	assign 	iq_deq 	= 1'b1; 				// need to change
	
	fetcher fetcher(
		.deq(1'b1),
		.pc_addr(pc_out),
		.rdy(iq_enq),
		.out(iq_in),
		.*
	);

	circular_q iq(
		.enq(iq_enq),
		.deq(iq_deq),
		.in(iq_in),
		.empty(iq_empty),
		.full(iq_full),
		.ready(iq_ready),
		.out(iq_out),
		.*
	);

	pc_register pc_reg(
		.load(pc_load),
		.in(pc_out + 4),
		.out(pc_out),
		.*
	);

	decoder decoder(
		.instruction(iq_out),
		.pc(pc_out)
	);

endmodule : cpu
