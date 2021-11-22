import rv32i_types::*;

module branch_predictor #(parameter size = 128)
(
	input 	logic 			clk,
	input 	logic 			rst,
	input 	pci_t 			pc_info, 	// comes from decoder
	input 	pci_t 			pc_info1,
	input 	logic 			br_result,	// comes from rob
	input 	logic 	[31:0] 	pc_result,	// comes from rob, pc of the jump instruction that is committed
	input	logic			pc_result_load, // comes from rob, goes high whenever a branch is resolved/committed
	output 	logic 			br_taken, 	// one bit, goes to PCMUX select bit (actually do we even need this)
	output 	logic 			br_taken1,
	output 	logic 	[31:0] 	br_addr, 	// next PC value (predicted) PCMUX input 1
	output 	logic 	[31:0] 	br_addr1
);

	logic 	[31:0]	fetch_rdata_i;
	logic 	[31:0]	fetch_pc_i;
	logic 			instr_b;
	logic 			predict_branch_taken_o;
	logic 	[31:0]	predict_branch_pc_o;

	always_comb begin 
		fetch_rdata_i		= '0;
		fetch_pc_i 			= '0;
		instr_b				= 0;

		br_taken			= 0;
		br_addr				= pc_info.pc + 4;
		br_taken1			= 0;
		br_addr1			= pc_info1.pc + 4;

		if (pc_info.is_br_instr) begin 
			fetch_rdata_i	= pc_info.instruction;
			fetch_pc_i		= pc_info.pc;
			instr_b			= pc_info.is_br_instr;
			br_taken		= predict_branch_taken_o;
			br_addr			= predict_branch_pc_o;
		end else if (pc_info1.is_br_instr) begin 
			fetch_rdata_i	= pc_info1.instruction;
			fetch_pc_i		= pc_info1.pc;
			instr_b			= pc_info1.is_br_instr;
			br_taken1		= predict_branch_taken_o;
			br_addr1		= predict_branch_pc_o;
		end
	end 

	bp_bimodal bp(
		.clk_i(clk),
		.rst_ni(~rst),
		.fetch_rdata_i(fetch_rdata_i),
		.fetch_pc_i(fetch_pc_i),
		.fetch_valid_i(1'b1),
		.ex_br_instr_addr_i(pc_result),
		.ex_br_taken_i(br_result),
		.ex_br_valid_i(pc_result_load),
		.instr_b(instr_b),
		.predict_branch_taken_o(predict_branch_taken_o),
		.predict_branch_pc_o(predict_branch_pc_o)
	);

endmodule : branch_predictor

module bp_bimodal #( 	parameter CTableSize = 512,
						parameter CounterLen = 2)
(
	input 	logic 			clk_i,  				// 				Clock signal.
	input 	logic 			rst_ni,  				// 				Reset signal.

	input 	logic [31:0] 	fetch_rdata_i,  		// instruction: Current fetched instruction.
	input 	logic [31:0] 	fetch_pc_i,  			// PC 		  :	Current instruction address (current PC).
	input 	logic 			fetch_valid_i,  		// instr valid: Current instruction is valid.

	input 	logic [31:0] 	ex_br_instr_addr_i,  	// PC br_res  : Instruction address of outcome branch.
	input 	logic 			ex_br_taken_i,  		// br result  : Branch outcome is taken.
	input 	logic 			ex_br_valid_i,  		// br res val : Branch outcome is valid.

	input 	logic 			instr_b,

	output 	logic 			predict_branch_taken_o, // pred 	  : Prediction (1 for taken).
	output 	logic [31:0] 	predict_branch_pc_o  	// pred pc 	  : Predicted target address (next PC).
);

	typedef enum logic[1:0] {
		SST = 'b01,
		SWT = 'b00,
		WNT = 'b11,
		SNT = 'b10
	} br_counter_2_e;

	typedef enum logic[3:0] {
		ST3 = 'b0111, 
		ST2 = 'b0110, 
		ST1 = 'b0101, 
		ST0 = 'b0100, 
		WT3 = 'b0011, 
		WT2 = 'b0010, 
		WT1 = 'b0001, 
		WT0 = 'b0000,

		SN3 = 'b1111, 
		SN2 = 'b1110, 
		SN1 = 'b1101, 
		SN0 = 'b1100, 
		WN3 = 'b1011, 
		WN2 = 'b1010, 
		WN1 = 'b1001, 
		WN0 = 'b1000
	
	} br_counter_4_e;

	logic signed [CounterLen-1:0] ctable [CTableSize-1:0];

	logic [$clog2(CTableSize) - 1:0] fetch_pc_idx;
	logic [$clog2(CTableSize) - 1:0] outcome_pc_idx;
	logic [31:0] imm_j_type;
	logic [31:0] imm_b_type;
	logic [31:0] instr;
	logic instr_j;
	// logic instr_b;
	logic [3:0] st_taken, st_not_taken, init_val;


	assign fetch_pc_idx 			= fetch_pc_i[2+: $clog2(CTableSize)];
	assign outcome_pc_idx 			= ex_br_instr_addr_i[2+: $clog2(CTableSize)];

	assign instr 					= fetch_rdata_i;
	assign imm_j_type 				= { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
	assign imm_b_type 				= { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
	// assign instr_b 					= opcode_e'(instr[6:0]) == OPCODE_BRANCH;
	assign instr_j 					= 0;//opcode_e'(instr[6:0]) == OPCODE_JAL;

	assign predict_branch_taken_o 	= fetch_valid_i & (instr_j | (instr_b & ctable[fetch_pc_idx] >= 0));
	assign predict_branch_pc_o 		= fetch_valid_i & instr_j ? fetch_pc_i + imm_j_type : 
									  fetch_valid_i & instr_b & predict_branch_taken_o ? fetch_pc_i + imm_b_type : fetch_pc_i + 4;

	assign st_taken 				= CounterLen == 2 ? SST : ST3;
	assign st_not_taken 			= CounterLen == 2 ? SNT : WN0;
	assign init_val 				= CounterLen == 2 ? SWT : WT0;

	always_ff @(posedge clk_i) begin
		if(~rst_ni) begin
			for(int i = 0; i < CTableSize; i++) begin 
				ctable[i] 					<= 0;
			end 

		end else begin
			if(ex_br_valid_i) begin 
				if(ex_br_taken_i)
					ctable[outcome_pc_idx] 	<= ctable[outcome_pc_idx] == st_taken[CounterLen-1:0] ? st_taken[CounterLen-1:0] : ctable[outcome_pc_idx] + 1;
				else
					ctable[outcome_pc_idx] 	<= ctable[outcome_pc_idx] == st_not_taken[CounterLen-1:0] ? st_not_taken[CounterLen-1:0] : ctable[outcome_pc_idx] - 1;
			end 
		end
	end

	// generate
	// 	genvar idx;
	// 	for(idx = 0; idx < CTableSize; idx = idx+1) begin
	// 		wire [CounterLen-1:0] tmp;
	// 		assign tmp = ctable[idx];
	// 	end
	// endgenerate

endmodule : bp_bimodal

module bp_gshare #( 	parameter CTableSize 	= 1024,
						parameter CounterLen 	= 2,
						parameter GHRLen 		= 10)
(
	input 	logic 			clk_i,  				// 				Clock signal.
	input 	logic 			rst_ni,  				// 				Reset signal.

	input 	logic [31:0] 	fetch_rdata_i,  		// instruction: Current fetched instruction.
	input 	logic [31:0] 	fetch_pc_i,  			// PC 		  :	Current instruction address (current PC).
	input 	logic 			fetch_valid_i,  		// instr valid: Current instruction is valid.

	input 	logic [31:0] 	ex_br_instr_addr_i,  	// PC br_res  : Instruction address of outcome branch.
	input 	logic 			ex_br_taken_i,  		// br result  : Branch outcome is taken.
	input 	logic 			ex_br_valid_i,  		// br res val : Branch outcome is valid.

	input 	logic 			instr_b,

	output 	logic 			predict_branch_taken_o, // pred 	  : Prediction (1 for taken).
	output 	logic [31:0] 	predict_branch_pc_o  	// pred pc 	  : Predicted target address (next PC).
);

	logic signed 	[CounterLen-1:0] 	ctable [CTableSize-1:0];
	logic 			[GHRLen-1:0]		GHR;

	typedef enum logic[1:0] {
		SST = 'b01,
		SWT = 'b00,
		WNT = 'b11,
		SNT = 'b10
	} br_counter_2_e;

	logic [GHRLen - 1:0] fetch_table_idx;
	logic [GHRLen - 1:0] outcome_table_idx;
	logic [31:0] imm_j_type;
	logic [31:0] imm_b_type;
	logic [31:0] branch_imm;
	logic [31:0] instr;
	logic instr_j;
	// logic instr_b;


	assign fetch_table_idx 			= GHR ^ fetch_pc_i[2+: GHRLen];
	assign outcome_table_idx 		= GHR ^ ex_br_instr_addr_i[2+: GHRLen];

	assign instr 					= fetch_rdata_i;
	assign imm_j_type 				= { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
	assign imm_b_type 				= { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
	// assign instr_b 					= opcode_e'(instr[6:0]) == OPCODE_BRANCH;
	assign instr_j 					= 0; //opcode_e'(instr[6:0]) == OPCODE_JAL;

	assign predict_branch_taken_o 	= fetch_valid_i & (instr_j | (instr_b & ctable[fetch_table_idx] >= 0));
	assign predict_branch_pc_o 		= fetch_valid_i & instr_j ? fetch_pc_i + imm_j_type : 
									  fetch_valid_i & instr_b & predict_branch_taken_o ? fetch_pc_i + imm_b_type : fetch_pc_i + 4;

	always_ff @(posedge clk_i) begin
		if(~rst_ni) begin
			GHR <= 0;
			for(int i = 0; i < CTableSize; i++) begin 
				ctable[i] 						<= 0;
			end 

		end else begin
			if(ex_br_valid_i) begin 
				GHR <= {GHR[GHRLen-2:0], ex_br_taken_i};

				if(ex_br_taken_i)
					ctable[outcome_table_idx] 	<= ctable[outcome_table_idx] == SST ? SST : br_counter_2_e'(ctable[outcome_table_idx] + 1);
				else
					ctable[outcome_table_idx] 	<= ctable[outcome_table_idx] == SNT ? SNT : br_counter_2_e'(ctable[outcome_table_idx] - 1);
			end 
		end
	end

	// generate
	// 	genvar idx;
	// 	for(idx = 0; idx < CTableSize; idx = idx+1) begin
	// 		wire [CounterLen-1:0] tmp;
	// 		assign tmp = ctable[idx];
	// 	end
	// endgenerate

endmodule : bp_gshare

module bp_perceptron #( parameter PTableSize 	= 1024,
						parameter PWeightLen 	= 9,
						parameter GHRLen 		= 12)
(
	input 	logic 			clk_i,  				// 				Clock signal.
	input 	logic 			rst_ni,  				// 				Reset signal.

	input 	logic [31:0] 	fetch_rdata_i,  		// instruction: Current fetched instruction.
	input 	logic [31:0] 	fetch_pc_i,  			// PC 		  :	Current instruction address (current PC).
	input 	logic 			fetch_valid_i,  		// instr valid: Current instruction is valid.

	input 	logic [31:0] 	ex_br_instr_addr_i,  	// PC br_res  : Instruction address of outcome branch.
	input 	logic 			ex_br_taken_i,  		// br result  : Branch outcome is taken.
	input 	logic 			ex_br_valid_i,  		// br res val : Branch outcome is valid.

	input 	logic 			instr_b,

	output 	logic 			predict_branch_taken_o, // pred 	  : Prediction (1 for taken).
	output 	logic [31:0] 	predict_branch_pc_o  	// pred pc 	  : Predicted target address (next PC).
);

	localparam theta = GHRLen == 12 ? 38 : 30;

	logic signed	[PWeightLen-1:0] 	POS_MAX;
	logic signed	[PWeightLen-1:0] 	NEG_MIN;

	logic signed 	[PWeightLen-1:0] 	ptable_w [PTableSize-1:0] [GHRLen-1:0]; // for each address, theres 12 weights, each 9 bits long
	logic signed 	[PWeightLen-1:0] 	ptable_b [PTableSize-1:0];				// bias for w0
	logic 			[GHRLen-1:0]		GHR;

	logic [31:0] 						imm_j_type;
	logic [31:0] 						imm_b_type;
	logic [31:0] 						branch_imm;
	logic [31:0] 						instr;
	logic 								instr_j;
	// logic 								instr_b;

	logic [$clog2(PTableSize) - 1:0] 	fetch_pc_idx;
	logic [$clog2(PTableSize) - 1:0] 	outcome_pc_idx;
	logic signed [PWeightLen-1:0] 		fetch_w0;
	logic signed [PWeightLen-1:0] 		outcome_w0;
	logic signed [PWeightLen-1:0] 		fetch_w_n 	[GHRLen-1:0];
	logic signed [PWeightLen-1:0] 		outcome_w_n [GHRLen-1:0];
	logic signed [15:0]					fetch_y;
	logic signed [15:0] 				outcome_y;

	logic signed [15:0] 				fetch_sum, outcome_sum;

	assign NEG_MIN 						= 1 << (PWeightLen - 1);
	assign POS_MAX 						= ~NEG_MIN;

	assign instr 						= fetch_rdata_i;
	assign imm_j_type 					= { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
	assign imm_b_type 					= { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
	// assign instr_b 						= opcode_e'(instr[6:0]) == op_br;
	assign instr_j 						= 0;

	assign fetch_pc_idx 				= fetch_pc_i[2+: $clog2(PTableSize)];
	assign outcome_pc_idx 				= ex_br_instr_addr_i[2+: $clog2(PTableSize)];
	assign fetch_w0 					= ptable_b[fetch_pc_idx];
	assign outcome_w0 					= ptable_b[outcome_pc_idx];
	assign fetch_w_n 					= ptable_w[fetch_pc_idx];
	assign outcome_w_n					= ptable_w[outcome_pc_idx];

	assign predict_branch_taken_o 		= fetch_valid_i & (instr_j | (instr_b & ~fetch_y[15]));
	assign predict_branch_pc_o 			= fetch_valid_i & instr_j ? fetch_pc_i + imm_j_type : 
									  		fetch_valid_i & instr_b & predict_branch_taken_o ? fetch_pc_i + imm_b_type : fetch_pc_i + 4;

	function logic signed [PWeightLen-1:0] ceil_inc(logic signed [PWeightLen-1:0] num);
		if(num != POS_MAX)
			return num + 1;
		return POS_MAX;
		// return num + logic'(num != POS_MAX);
	endfunction : ceil_inc

	function logic signed [PWeightLen-1:0] floor_dec(logic signed [PWeightLen-1:0] num);
		if(num != NEG_MIN)
			return num - 1;
		return NEG_MIN;
		// return num - logic'(num != NEG_MIN);
	endfunction : floor_dec

	function logic signed [15:0] calc_fetch_y(logic signed [PWeightLen-1:0] w0, logic signed [PWeightLen-1:0] w_n [GHRLen-1:0]);
		fetch_sum = 0;
		fetch_sum = w0;
		for (int i = 0; i < GHRLen; i++) begin 
			fetch_sum = GHR[i] ? fetch_sum + $signed(w_n[i]) : fetch_sum - $signed(w_n[i]) ; 
		end 
		return fetch_sum;
	endfunction

	function logic signed [15:0] calc_outcome_y(logic signed [PWeightLen-1:0] w0, logic signed [PWeightLen-1:0] w_n [GHRLen-1:0]);
		outcome_sum = 0;
		outcome_sum = w0;
		for (int i = 0; i < GHRLen; i++) begin 
			outcome_sum = GHR[i] ? outcome_sum + $signed(w_n[i]) : outcome_sum - $signed(w_n[i]) ; 
		end 
		return outcome_sum;
	endfunction

	assign fetch_y 									= calc_fetch_y(fetch_w0, fetch_w_n);
	assign outcome_y 								= calc_outcome_y(outcome_w0, outcome_w_n);

	always_ff @(posedge clk_i) begin
		if(~rst_ni) begin
			GHR 									<= '0;
			for(int i = 0; i < PTableSize; i++) begin 
				for(int j = 0; j < GHRLen; j++)
					ptable_w[i][j] 					<= '0;
				ptable_b[i] 						<= '0;
			end 

		end else begin
			if(ex_br_valid_i) begin 
				GHR 								<= {GHR[GHRLen-2:0], ex_br_taken_i};
				if((~outcome_y[15] != ex_br_taken_i) || ($signed(outcome_y) >= 0 && $signed(outcome_y) <= theta) || ($signed(outcome_y) < 0 && $signed(-outcome_y) <= theta)) begin 
					ptable_b[outcome_pc_idx] 		<= ex_br_taken_i ? 
														ceil_inc(outcome_w0) : floor_dec(outcome_w0);
					
					for(int i = 0; i < GHRLen; i++) begin 
						ptable_w[outcome_pc_idx][i] <= ex_br_taken_i == GHR[i] ? 
														ceil_inc(outcome_w_n[i]) : floor_dec(outcome_w_n[i]);
					end
				end

			end 
		end
	end

endmodule : bp_perceptron