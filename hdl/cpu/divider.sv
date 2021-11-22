module divider #(width = 32)
(
	input logic clk,
	input logic rst,
	// signals are self-explainatory
	input logic start,
	input logic [31:0] numerator,
	input logic [31:0] denominator,
	output logic [31:0] quotient,
	output logic [31:0] remainder,
	output logic done
);

	enum int unsigned {
		// list of states
		idle			= 0,
		shift_sub		 = 1,
		d				 = 2
	} state, next_state;

	logic [31:0] counter, next_counter;
	logic [31:0] local_numerator, local_denominator;
	logic [31:0] Q;
	logic [31:0] R;

	logic 		 special_case;
	logic 		 delayed_done;
	logic [31:0] special_quo, special_rem;
	assign 		 special_case = start & check_special_case(numerator, denominator);

	function logic check_special_case(logic [31:0] a, logic [31:0] b);
	 	if (a == 0)
	 		return 1;
	 	if (a == 1 || b == 1)
	 		return 1;
	 	if (is_power_2(b))
	 		return 1;
	 	if (a == b)
	 		return 1;
	 	if (b > a)
	 		return 1;
	 	return 0;
	endfunction

	function logic is_power_2(logic [width - 1:0] num);
		return num != 0 && ((num - 1) == (~num));
	endfunction

	always_comb begin 
		special_quo = '0;
		special_rem = '0;
		if (start) begin 
			if (numerator == 0) begin 
				special_quo = '0;
				special_rem = '0;
			end 
			if (numerator == 1) begin 

				special_quo = denominator == 1 ? 1 : 0;
				special_rem = denominator == 1 ? 0 : 1;
			end 
			if (denominator== 1) begin 

				special_quo = numerator;
				special_rem = 0;
			end 
			if (is_power_2(denominator)) begin 

				special_quo = numerator >> $clog2(denominator);
				special_rem = numerator & (denominator- 1);
			end 
			if (numerator == denominator) begin 

				special_quo = 1;
				special_rem = 0;
			end 
			if (denominator > numerator) begin 

				special_quo = 0;
				special_rem = numerator;
			end 
		end 
	end 

	// next state condition
	always_ff @(posedge clk) begin
		if(rst) begin
				state <= idle;
				quotient <= 0;
				remainder <= 0;
				local_denominator <= '0;
				local_numerator <= '0;
		end
		else begin 
			if (start && state == idle) begin
				local_denominator <= denominator;
				local_numerator <= numerator;
				state <= next_state;
				counter <= next_counter;
				if (special_case) begin 
					quotient <= special_quo;
					remainder <= special_rem;
					delayed_done <= 1;
				end else begin 
					quotient <= Q;
					remainder <= R;
					delayed_done <= 0;
				end 
			end else if (~start) begin 
				state <= idle;
				quotient <= 0;
				remainder <= 0;
				local_denominator <= '0;
				local_numerator <= '0;
				delayed_done <= 0;
			end else begin 
				state <= next_state;
				counter <= next_counter;
				quotient <= Q;
				remainder <= R;
				delayed_done <= 0;
			end 
		end 
	end

	// next state logic
	always_comb begin
		unique case (state)
				idle: begin
					if(start && ~special_case) next_state <= shift_sub;
					else next_state <= idle;
				end

				shift_sub: begin
					if(counter == -32'd1) next_state <= d;
					else next_state <= shift_sub;
				end

				d : begin
					next_state <= idle;
				end

		endcase
	end

	// state output logic
	always_comb begin
		unique case (state)
				idle: begin
					Q <= 32'b0;
					R <= 32'b0;
					next_counter <= 32'd31;
					done <= delayed_done;
				end

				shift_sub: begin
					if (local_denominator <= remainder) begin
							Q[31:0] = {quotient[30:0], 1'b1};
							if (counter < 32'd32)
								R[31:0] = {remainder - local_denominator, local_numerator[counter]};
							else
								R[31:0] = remainder - local_denominator;
					end else begin
							Q = {quotient[30:0], 1'b0};
							if (counter < 32'd32)
								R[31:0] = {remainder[30:0], local_numerator[counter]};
							else
								R[31:0] = remainder[31:0];
					end

					next_counter <= counter - 32'd1;
					done <= 1'b0;
				end

				d: begin
					done <= 1'b1;
					Q <= 32'b0;
					R <= 32'b0;
					next_counter <= 32'd31;
				end
		endcase
	end

endmodule