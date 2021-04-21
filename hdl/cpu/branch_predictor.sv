import rv32i_types::*;

module branch_predictor(#parameter size = 8)
(
	input 	logic 			clk,
	input 	logic 			rst,
	input 	pci_t 			pc_info,
	input 	logic 			br_result,
	input 	logic 	[31:0] 	pc_result,
	output 	logic 			br_taken,
	output 	logic 	[31:0] 	addr
);
	/*********************************************************************************************/
	/*NOTE THERE IS A BUG WITH JALR WHERE WE NEED PC + 4 IN RD, CURRENTLY JUMP ADDRESS GOES TO RD*/
	/*********************************************************************************************/

	br_pred_t 	[size - 1:0] 	arr;



	always_ff @(posedge clk) begin 
		if(rst) begin 
			for(int i = 0; i < size; i++) begin 
				arr[i] 	<= '{pc_info: '{opcode: op_br, default: 0}, counter: br_w_taken};
			end 
		end

		else begin  

		end 
	end 

endmodule : branch_predictor