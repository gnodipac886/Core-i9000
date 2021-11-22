module multiplier #(
	parameter width = 32,
	parameter width_div3 = 11,
	parameter width_near3 = 33
) (
	input 	logic 							clk,
	input 	logic 							rst,
	input 	logic 	[width - 1:0] 			a,
	input 	logic 	[width - 1:0] 			b,
	input 	logic 							valid,
	
	output 	logic 	[(width << 1) - 1:0] 	ans,
	output 	logic 							rdy
);

	enum logic [1:0] {s_idle, s_expand, s_add} state, next_state;

	logic 	[width - 1:0] 			saved_a;
	logic 	[width - 1:0] 			saved_b;
	logic 	[width - 1:0]			add_counter;
	logic 	[width_near3 - 1:0] 	check_zeros;
	logic 	[$clog2(width) - 1:0]	ind_3s[0:width_div3 - 1];
	logic 	[$clog2(width) - 1:0]	ind_set_0s[0:7];
	logic 	[(width << 1) - 1:0]	mul_slots[0:width_near3 - 1];
	logic 							special_case;
	logic 	[(width << 1) - 1:0]	nani_ans;
	// logic 	[10:0]	mul_slots[0:width_near3 - 1];

	assign 							ind_3s 		= '{0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30};
	assign 							ind_set_0s 	= '{22, 16, 12, 8, 6, 4, 3, 2};
	assign 							special_case= (((saved_a & 3) == saved_a && saved_a != 3) || ((saved_b & 3) == saved_b && saved_b != 3) || is_power_2(saved_a) || is_power_2(saved_b)) && (state == s_add);
	assign 							nani_ans 	= mul_slots[0] + mul_slots[1];
	// assign 							ans 		= get_answer();
	assign 							rdy 		= special_case | check_done() | add_counter == 32'h9;

	task reset();
		state 				<= s_idle;
		add_counter 		<= 0;
		saved_a				<= '0;
		saved_b				<= '0;
		for (int i = 0; i < width_near3; i++) begin 
			mul_slots[i] 	<= '0;
		end 
	endtask

	function logic is_power_2(logic [width - 1:0] num);
		return num != 0 && ((num - 1) == (~num));
	endfunction

	function logic check_done();
		check_zeros[0] = 0;
		check_zeros[1] = 0;
		for (int i = 2; i < width_near3; i++) begin 
			check_zeros[i] = |mul_slots[i];
		end 
		return ~(|check_zeros) & (|add_counter);
	endfunction

	task bitwise_expand();
		for (int i = 0; i < width_near3; i++) begin 
			unique case (b[i])
				1'b1: mul_slots[i] <= (a << i);

				1'b0: ;
				default:;
			endcase
		end 
	endtask

	task wallace_add();
		add_counter 	<= add_counter + 1;
		for (int i = 0; i < width_div3; i++) begin 
			mul_slots[ind_3s[i] + 0 - i]	<= mul_slots[ind_3s[i] + 0] ^ mul_slots[ind_3s[i] + 1] ^ mul_slots[ind_3s[i] + 2];
			mul_slots[ind_3s[i] + 1 - i]	<= ((mul_slots[ind_3s[i] + 0] & mul_slots[ind_3s[i] + 1]) | 
												(mul_slots[ind_3s[i] + 1] & mul_slots[ind_3s[i] + 2]) | 
												(mul_slots[ind_3s[i] + 0] & mul_slots[ind_3s[i] + 2])) << 1;
		end 
		for (int i = 0; i < width_near3 - ind_set_0s[add_counter]; i++) begin 
			mul_slots[ind_set_0s[add_counter] + i] <= '0;
		end
	endtask

	always_comb begin 
		next_state = state;
		unique case (state)
			s_idle 	: next_state = valid == 1'b1 ? s_add : s_idle;

			s_expand: next_state = s_add;

			s_add 	: next_state = rdy ? s_idle : s_add;

			default :;
		endcase
	end 

	always_comb begin
		ans = nani_ans;
		if (saved_a == 0 || saved_b == 0)
			ans =  '0;
		if (saved_a == 1 || saved_a == 2)
			ans =  saved_b << (saved_a - 1);
		if (saved_b == 1 || saved_b == 2)
			ans =  saved_a << (saved_b - 1);
		if (is_power_2(saved_a))
			ans = saved_b << $clog2(saved_a);
		if (is_power_2(saved_b))
			ans = saved_a << $clog2(saved_b);
	end

	always_ff @(posedge clk) begin
		if(rst) begin
			reset();
		end else begin
			state <= next_state;

			unique case (state)
				s_idle 		: begin 
					if (valid) begin
						bitwise_expand();
						saved_a <= a;
						saved_b <= b;
					end 
				end 
				s_expand 	: begin 
					if (rdy)
						reset();
					else
						bitwise_expand();
				end 

				s_add 		: begin 
					if (rdy)
						reset();
					else
						wallace_add();
				end 
				default 	:;
			endcase
		end
	end

endmodule