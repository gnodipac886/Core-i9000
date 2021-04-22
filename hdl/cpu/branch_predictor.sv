import rv32i_types::*;

module branch_predictor(#parameter size = 8)
(
	input 	logic 			clk,
	input 	logic 			rst,
	input 	pci_t 			pc_info,
	input 	logic 			br_result,
	input 	logic 	[31:0] 	pc_result,
	output 	logic 			br_taken,
	output 	logic 	[31:0] 	br_addr
);
	/*********************************************************************************************/
	/*NOTE THERE IS A BUG WITH JALR WHERE WE NEED PC + 4 IN RD, CURRENTLY JUMP ADDRESS GOES TO RD*/
	/*********************************************************************************************/

	br_pred_t 					arr[size - 1:0];
	logic 		[size - 1:0] 	lru;
	logic 						hit;
	int							hit_idx, next_avail_idx; // resume from here, write next_avail logic

	task update_lru();
		
	endtask
	

	always_comb begin
		hit = 1'b0;
		br_taken = 1'b0;
		hit_idx = -1;
		if (pc_info.is_br_instr) begin
			br_taken = 1'b1;
			for (int i = 0; i < size && ~hit; i++) begin	// Find hit
				if (arr[i].valid && (arr[i].pc_info.pc == pc_info.pc)) begin
					hit_idx = i;
					hit = 1'b1;
					br_taken = arr[i].counter[1];
					unique case(br_taken)
						1'b0: br_addr = arr[i].pc_info.pc + 4;
						1'b1: br_addr = arr[i].pc_info.branch_pc;
					endcase
				end
				
			end
			if (~hit) begin	// Miss
				br_addr = pc_info.branch_pc;
			end
		end
	end

idx:	0 1 2 3
lru:	2 4 0 1
valid:	1 1 1 1

	always_ff @(posedge clk) begin 
		if(rst) begin 
			for(int i = 0; i < size; i++) begin 
				arr[i] 	<= '{pc_info: '{opcode: op_br, default: 0}, counter: br_w_taken};
			end 
		end else if (pc_info.is_br_instr) begin  
			if(hit) begin 
				update_lru(hit_idx);
			end else begin
				if (next_avail_idx == -1)	// Figure out how to get next available spot
			end
		end 
	end 

endmodule : branch_predictor