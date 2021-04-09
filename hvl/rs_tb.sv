import rv32i_types::*;

`define width 		32
`define size 		8
`define br_rs_size 	3
`define alu_rs_size 8
`define lsq_size 	5

module rs_tb();

	// timeunit 1ns;
	// timeprecision 1ns;
	logic clk;
	always #5 clk = clk === 1'b0;
	default clocking tb_clk @(posedge clk); endclocking

	class RandomInst;
		rv32i_reg reg_range[$];
		arith_funct3_t arith3_range[$];

		/** Constructor **/
		function new();
			arith_funct3_t af3;
			af3 = af3.first;

			for (int i = 0; i < 32; ++i)
				reg_range.push_back(i);
			do begin
				arith3_range.push_back(af3);
				af3 = af3.next;
			end while (af3 != af3.last);

		endfunction

		function rv32i_word immediate(
			const ref rv32i_reg rd_range[$] = reg_range,
			const ref arith_funct3_t funct3_range[$] = arith3_range,
			const ref rv32i_reg rs1_range[$] = reg_range
			// const ref rv32i_reg rs2_range[$] = reg_range
		);
			union {
				rv32i_word rvword;
				struct packed {
					logic [31:20] i_imm;
					rv32i_reg rs1;
					// rv32i_reg rs2;
					logic [2:0] funct3;
					logic [4:0] rd;
					rv32i_opcode opcode;
				} i_word;
			} word;

			word.rvword = '0;
			word.i_word.opcode = op_imm;

			// Set rd register
			do begin
				word.i_word.rd = $urandom();
			end while (!(word.i_word.rd inside {rd_range}));

			// set funct3
			do begin
				word.i_word.funct3 = $urandom();
			end while (!(word.i_word.funct3 inside {funct3_range}));

			// set rs1
			do begin
				word.i_word.rs1 = $urandom();
			end while (!(word.i_word.rs1 inside {rs1_range}));

			// set rs2
			// do begin
			// 	word.i_word.rs2 = $urandom();
			// end while (!(word.i_word.rs2 inside {rs2_range}));

			// set immediate value
			word.i_word.i_imm = $urandom();

			return word.rvword;
		endfunction

	endclass
	// inputs
	// logic 			rst;
	// logic			instr_q_empty;
	// pci_t			pci;
	// logic			stall_br;
	// logic			stall_alu;
	// logic			stall_lsq;
	// sal_t			br_rs_o [`br_rs_size];
	// sal_t			alu_rs_o [`alu_rs_size];
	// sal_t			lsq_o;
	
	// // outputs
	// logic 			instr_q_dequeue;
	// logic 			load_br_rs;
	// logic 			load_alu_rs;
	// logic 			load_lsq;
	// sal_t 			rob_broadcast_bus [`size];
	// sal_t 			rdest;
	// logic	[3:0] 	rd_tag;
	// logic 			reg_ld_instr;	

	// rob_t 	arr0, arr1, arr2, arr3, arr4, arr5, arr6, arr7;
	// sal_t rob_broadcast_bus0, rob_broadcast_bus1, rob_broadcast_bus2, 
	// 		rob_broadcast_bus3, rob_broadcast_bus4, rob_broadcast_bus5, 
	// 		rob_broadcast_bus6, rob_broadcast_bus7;
	// sal_t broadcast_bus0, broadcast_bus1, broadcast_bus2, 
	// 		broadcast_bus3, broadcast_bus4, broadcast_bus5, 
	// 		broadcast_bus6, broadcast_bus7;
	// int 	front, rear;
	// logic 	enq, deq;
	// logic	full, empty;
	// rob_t	temp_in;


	// inputs
	logic rst;
	logic flush;

	logic load;
 	rs_t input_r; //regfile
	logic[3:0] tag; // from ROB
	pci_t pci; // from ROB

	sal_t broadcast_bus[`size]; // after computation is done, coming back from alu
	sal_t rob_broadcast_bus[`size]; // after other rs is done, send data from ROB to rs

	rs_t data[`size]; // all the reservation stations, to the alu
	logic[`size-1:0] ready; // if both values are not tags, flip this ready bit to 1
	logic[3:0] num_available; // do something if the number of available reservation stations are 0

	// assign data0 	= dut.data[0];
	// assign data1 	= dut.data[1];
	// assign data2 	= dut.data[2];
	// assign data3 	= dut.data[3];
	// assign data4 	= dut.data[4];
	// assign data5 	= dut.data[5];
	// assign data6 	= dut.data[6];
	// assign data7 	= dut.data[7];
	// assign result_rs= dut.result_rs;

	// assign rob_broadcast_bus0 = rob_broadcast_bus[0];
	// assign rob_broadcast_bus1 = rob_broadcast_bus[1];
	// assign rob_broadcast_bus2 = rob_broadcast_bus[2];
	// assign rob_broadcast_bus3 = rob_broadcast_bus[3];
	// assign rob_broadcast_bus4 = rob_broadcast_bus[4];
	// assign rob_broadcast_bus5 = rob_broadcast_bus[5];
	// assign rob_broadcast_bus6 = rob_broadcast_bus[6];
	// assign rob_broadcast_bus7 = rob_broadcast_bus[7];
	
	// assign rob_broadcast_bus = {rob_broadcast_bus0, rob_broadcast_bus1, rob_broadcast_bus2,rob_broadcast_bus3,rob_broadcast_bus4,rob_broadcast_bus5,rob_broadcast_bus6,rob_broadcast_bus7};
	
	// assign broadcast_bus0 = broadcast_bus[0];
	// assign broadcast_bus1 = broadcast_bus[1];
	// assign broadcast_bus2 = broadcast_bus[2];
	// assign broadcast_bus3 = broadcast_bus[3];
	// assign broadcast_bus4 = broadcast_bus[4];
	// assign broadcast_bus5 = broadcast_bus[5];
	// assign broadcast_bus6 = broadcast_bus[6];
	// assign broadcast_bus7 = broadcast_bus[7];
	
	// assign broadcast_bus = {broadcast_bus0,broadcast_bus1,broadcast_bus2,broadcast_bus3,broadcast_bus4,broadcast_bus5,broadcast_bus6,broadcast_bus7};
	
	// assign front    = dut.front;
	// assign rear 	= dut.rear;
	// assign enq 		= dut.enq;
	// assign deq 		= dut.deq;
	// assign full		= dut.full;
	// assign empty	= dut.empty;
	// assign temp_in	= dut.temp_in;


	// RandomInst generator = new();
	// logic	[`width-1:0]	generate_instr;
	// logic	[`width-1:0]	generate_pc;

	// decoder decoder(
	// 	.instruction(generate_instr),
	// 	.pc(generate_pc),
	// 	.pci(pci)
	// );

	// reorder_buffer rob(
	// 	.*
	// );

	// regfile rf(
	// 	.*
	// );

	reservation_station dut(
		.clk(clk),
		.rst(rst),
		.flush(flush),

		.load(load),

		.input_r(input_r),
		.tag(tag),
		.pci(pci),

		.broadcast_bus(broadcast_bus),
		.rob_broadcast_bus(rob_broadcast_bus),

		.data(data),
		.ready(ready),
		.num_available(num_available)
	);

	task reset();
		##1;
		rst <= 1'b1;
		##1;
		rst <= 1'b0;

		// instr_q_empty 	<= 1'b1;
		// stall_br 		<= 1'b0;
		// stall_alu 		<= 1'b0;
		// stall_lsq 		<= 1'b0;
		// for (int i = 0; i < `br_rs_size; i = i + 1) begin
		// 	br_rs_o[i] 	= '{ default: 0 };
		// end
		// for (int i = 0; i < `alu_rs_size; i = i + 1) begin
		// 	alu_rs_o[i] = '{ default: 0 };
		// end
		// lsq_o			= '{ default: 0 };
		// ##1;
	endtask : reset

	// task test_rob_enqueue_alu();
	// 	##1;
	// 	generate_instr 	<= generator.immediate();
	// 	generate_pc 	<= 32'h60;
	// 	instr_q_empty 	<= 1'b0;
	// 	##1;
	// 	instr_q_empty	<= 1'b1;
	// endtask
	
	// task test_rob_broadcast_alu(int num_broadcast);
	// 	##1;
	// 	for (int j = 0; j < num_broadcast; j++) begin
	// 		alu_rs_o[j] <= '{ tag: front + j, rdy: 1'b1, data: (j + 1) };
	// 	end
	// 	##1;
	// 	for (int j = 0; j < num_broadcast; j++) begin
	// 		alu_rs_o[j] <= '{ default: 0 };
	// 	end
	// 	##1;
	// endtask

	// task test_rob_endequeue(int num_broadcast);
	// 	##1;
	// 	// broadcast -> dequeue
	// 	for (int j = 0; j < num_broadcast; j++) begin
	// 		alu_rs_o[j] <= '{ tag: front + j, rdy: 1'b1, data: (j + 1) };
	// 	end
	// 	##1;
	// 	// enqueue part
	// 	generate_instr 	<= generator.immediate();
	// 	generate_pc 	<= 32'h60;
	// 	instr_q_empty 	<= 1'b0;
	// 	for (int j = 0; j < num_broadcast; j++) begin
	// 		alu_rs_o[j] <= '{ default: 0 };
	// 	end
	// 	// turn things off
	// 	##1;
	// 	generate_instr 	<= generator.immediate();
	// 	generate_pc 	<= 32'h64;
	// 	##1;
	// 	generate_instr 	<= generator.immediate();
	// 	generate_pc 	<= 32'h68;
	// 	##1;
	// 	instr_q_empty	<= 1'b1;
	// endtask

	task test_rs_load_new();
	// get rs from regfile , see if it can load into rs
	
	endtask

	task test_rs_from_alu();
	// test update from alu output, update the rs tags and values
	
	endtask

	task test_rs_from_rob();
	// test update from rob output, update the rs tags and values
		
	endtask
		
	initial begin : TEST_VECTORS
		reset();
		// for(int i = 0; i < 8; i++) begin 
		// 	test_rob_enqueue_alu();
		// end

		// test_rob_broadcast_alu(2);

		// for(int i = 0; i < 2; i++) begin 
		// 	test_rob_enqueue_alu();
		// end

		// // for(int i = 0; i < 3; i++) begin 
		// test_rob_endequeue(3);
		// // end 
		// ##5;
		$finish;
	end
 
endmodule 

module decoder #(parameter width = 32)
(
	input 	logic 	[width-1:0] 	instruction,
	input 	logic 	[width-1:0] 	pc,
	output 	pci_t 					pci
);

	logic [31:0] data;

	assign data 			= instruction;

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
