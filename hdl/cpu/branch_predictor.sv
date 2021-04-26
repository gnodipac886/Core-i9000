import rv32i_types::*;

module branch_predictor #(parameter size = 64)
(
	input 	logic 			clk,
	input 	logic 			rst,
	input 	pci_t 			pc_info, 	// comes from decoder
	input 	logic 			br_result,	// comes from rob
	input 	logic 	[31:0] 	pc_result,	// comes from rob, pc of the jump instruction that is committed
	input	logic			pc_result_load, // comes from rob, goes high whenever a branch is resolved/committed
	output 	logic 			br_taken, 	// one bit, goes to PCMUX select bit (actually do we even need this)
	output 	logic 	[31:0] 	br_addr 	// next PC value (predicted) PCMUX input 1
);
	/*********************************************************************************************/
	/*NOTE THERE IS A BUG WITH JALR WHERE WE NEED PC + 4 IN RD, CURRENTLY JUMP ADDRESS GOES TO RD*/
	/*********************************************************************************************/

	br_pred_t 							arr[size - 1:0];
	logic 		[$clog2(size) - 1:0] 	arr_idx;
	logic 		[$clog2(size) - 1:0] 	result_idx;
	logic 		[size - 1:0] 			lru;
	logic 								hit;
	int									hit_idx, next_avail_idx; // resume from here, write next_avail logic

	assign arr_idx = pc_info.pc[7:2];
	assign result_idx = pc_result[7:2];


// 76543210
// 11111100 => 31 take counter => 11
// 01111100 => 31 take mispredict => 10 
// 11111100 => 31 take counter => 11

// TODO:
// DONE need to change pcmux to handle in two inputs (cpu.sv, line 144)
// DONE need to add outputs to ROB, simple assign statements to the head of the queue
// NEED TO DISCUSS actually, if we do multiple ROB commits, we cant just look at top of queue, branch will always be at the end of a chunk
// NEED TO DISCUSS removing br_taken from output signal
// NEED TO DISCUSS overflow underflow counter
// NEED TO DISCUSS if you really want to do pseudolru, hardcode the 8 indexes
// add a for loop in this module, to loop through rob broadcast bus input
// flushing
	always_comb begin
		br_taken = 1'b0;
		br_addr = pc_info.pc + 4;
		if (pc_info.is_br_instr) begin
			br_taken = arr[arr_idx].counter[1];
			unique case(br_taken)
				1'b0: br_addr = pc_info.pc + 4;
				1'b1: br_addr = pc_info.branch_pc;
			endcase
		end
	end

	always_ff @(posedge clk) begin 
		if(rst) begin // set defaults
			for(int i = 0; i < size; i++) begin 
				arr[i] 	<= '{counter: 2'b10, valid: 1'b1};
			end 
		end else if (pc_result_load) begin // when a result comes in from the ROB, update index accordingly
			if (br_result == 1'b0 && arr[result_idx].counter != 2'b00) begin
				arr[result_idx].counter <= arr[result_idx].counter - 2'b01; 
			end else if (br_result == 1'b1 && arr[result_idx].counter != 2'b11) begin
				arr[result_idx].counter <= arr[result_idx].counter + 2'b01; 
			end
		end 
	end 

endmodule : branch_predictor

// module branch_predictor(#parameter size = 8)
// (
// 	input 	logic 			clk,
// 	input 	logic 			rst,
// 	input 	pci_t 			pc_info,
// 	input 	logic 			br_result,
// 	input 	logic 	[31:0] 	pc_result,
// 	output 	logic 			br_taken,
// 	output 	logic 	[31:0] 	br_addr
// );
// 	/*********************************************************************************************/
// 	/*NOTE THERE IS A BUG WITH JALR WHERE WE NEED PC + 4 IN RD, CURRENTLY JUMP ADDRESS GOES TO RD*/
// 	/*********************************************************************************************/

// 	br_pred_t 					arr[size - 1:0];
// 	logic 		[size - 1:0] 	lru;
// 	logic 						hit;
// 	int							hit_idx, next_avail_idx; // resume from here, write next_avail logic

// 	task update_lru();
		
// 	endtask
	

// 	always_comb begin
// 		hit = 1'b0;
// 		br_taken = 1'b0;
// 		hit_idx = -1;
// 		if (pc_info.is_br_instr) begin
// 			br_taken = 1'b1;
// 			for (int i = 0; i < size && ~hit; i++) begin	// Find hit
// 				if (arr[i].valid && (arr[i].pc_info.pc == pc_info.pc)) begin
// 					hit_idx = i;
// 					hit = 1'b1;
// 					br_taken = arr[i].counter[1];
// 					unique case(br_taken)
// 						1'b0: br_addr = arr[i].pc_info.pc + 4;
// 						1'b1: br_addr = arr[i].pc_info.branch_pc;
// 					endcase
// 				end
				
// 			end
// 			if (~hit) begin	// Miss
// 				br_addr = pc_info.branch_pc;
// 			end
// 		end
// 	end

// idx:	0 1 2 3
// lru:	2 4 0 1
// valid:	1 1 1 1

// 	always_ff @(posedge clk) begin 
// 		if(rst) begin 
// 			for(int i = 0; i < size; i++) begin 
// 				arr[i] 	<= '{pc_info: '{opcode: op_br, default: 0}, counter: br_w_taken};
// 			end 
// 		end else if (pc_info.is_br_instr) begin  
// 			if(hit) begin 
// 				update_lru(hit_idx);
// 			end else begin
// 				if (next_avail_idx == -1)	// Figure out how to get next available spot
// 			end
// 		end 
// 	end 

// endmodule : branch_predictor