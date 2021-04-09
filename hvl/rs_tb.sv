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

	// assign data		= dut.data;
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
	
	alu rs_alu(
		.out(broadcast_bus),
		.*
	);

	task reset();
		##1;
		rst <= 1'b1;
		##1;
		rst <= 1'b0;
		pci <= {opcode: op_imm, default: 0};
		tag <= 4'b0;
		broadcast_bus = {default: 0};
		rob_broadcast_bus = {default: 0};
	endtask : reset


	task test_rs_load_new(logic busy1, logic busy2, int data1, int data2);
	// get rs from regfile , see if it can load into rs
		##4;
		input_r <= {cmp_ops:cmp_beq, alu_ops:alu_add, busy_r1: busy1, busy_r2: busy2, r1: data1, r2: data2, default:0};
		load <= 1'b1;
		##1;
		load <= 1'b0;
	endtask

	task print_rs();
		$display("=============%0t==========", $time);
		for (int idx = 0; idx < 8; idx++) begin
			$display("rs %0d, r1 %0d, r1_b %0d, r2 %0d, r2_b %0d", idx, data[idx].r1, data[idx].busy_r1, data[idx].r2, data[idx].busy_r2);
		end
		$display("==========================");
	endtask
		
	initial begin : TEST_VECTORS
		reset();
		
		// // fill it up with constants
		// for (int i = 0; i < 10; i++) begin
		// 	test_rs_load_new(1'b0, 1'b0, i, i);
		// end
		// ##5;


		// // test if update from alu clears the rs
		// broadcast_bus[0].rdy = 1;
		// ##1;
		// $display("time 1 %0t", $time);
		// assert(num_available == 1);
		// // test if update from 2 alu clears the rs
		// broadcast_bus[1].rdy = 1;
		// broadcast_bus[2].rdy = 1;
		// ##1;
		// $display("time 2 %0t", $time);
		// assert(num_available == 3);
		// // test if a lot of alu finishing at the same time works
		// broadcast_bus[3].rdy = 1;
		// broadcast_bus[4].rdy = 1;
		// broadcast_bus[5].rdy = 1;
		// broadcast_bus[6].rdy = 1;
		// broadcast_bus[7].rdy = 1;
		// ##1;
		// $display("time 3 %0t", $time);
		// assert(num_available == 8);
		// ##5;
		// reset();
		// // fill it up with random tags
		// for (int i = 0; i < 10; i++) begin
		// 	test_rs_load_new(1'b1, 1'b1, i, (i+5)%8);
		// end

		// print_rs();
		// // use rob to update some tags
		// rob_broadcast_bus[0].tag = 2;
		// rob_broadcast_bus[0].data = 12;
		// rob_broadcast_bus[0].rdy = 1;

		// ##1;
		// print_rs();
		// rob_broadcast_bus[1].tag = 1;
		// rob_broadcast_bus[1].data = 32;
		// rob_broadcast_bus[1].rdy = 1;

		// rob_broadcast_bus[2].tag = 4;
		// rob_broadcast_bus[2].data = 9;
		// rob_broadcast_bus[2].rdy = 1;
		// ##1;
		// print_rs();
		
		test_rs_load_new(1'b0, 1'b0, 5, 3);

		##5;
		pci <= {opcode: op_imm, funct3: 3'b011, default: 0};
		test_rs_load_new(1'b0, 1'b0, 5, 3);

		##5;
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
