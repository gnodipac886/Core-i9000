module multiplier_tb();

	// timeunit 1ns;
	// timeprecision 1ns;
	logic clk;
	always #5 clk = clk === 1'b0;
	default clocking tb_clk @(posedge clk); endclocking

	localparam width = 32;

	logic 					rst;
	logic 	[width - 1:0] 	a;
	logic 	[width - 1:0] 	b;
	logic 					valid;
	logic 	[(width << 1) - 1:0] 	ans;
	logic 					rdy;
	logic 	[(width << 1) - 1:0] 	neg_ans;

	logic 	[width - 1:0] 			div_a;
	logic 	[width - 1:0] 			div_b;
	logic 							div_valid;
	logic 	[width - 1:0] 			div_quo;
	logic 	[width - 1:0] 			div_rem;
	logic 							div_rdy;

	assign neg_ans = (~ans) + 1;

	multiplier #(width) mul_i(.*);
	divider div_i(
		.start(div_valid),
		.numerator(div_a),
		.denominator(div_b),
		.quotient(div_quo),
		.remainder(div_rem),
		.done(div_rdy),
		.*
	);

	task reset();
		##1;
		rst 		<= 1'b1;
		valid 		<= 1'b0;
		div_valid 	<= 1'b0;
		##1;
		rst 		<= 1'b0;
		##1;
	endtask : reset

	task test_multiply(logic 	[width - 1:0] 	op_a, logic 	[width - 1:0] 	op_b);
		valid 	<= 1'b1;
		a 		<= op_a;
		b 		<= op_b;
		##1;
		valid 	<= 1'b0;
		a 		<= 100;
		b 		<= 100;
		@(clk iff rdy)
		bad_product : assert(op_a * op_b == ans[width - 1:0])
		else begin
			$error ("%0d: %0t: BAD_PRODUCT error detected, %0d, %0d, %0d", `__LINE__, $time, op_a, op_b, ans);
		end
		$display("mul product: regularhi: %h, regularlo: %h, flippedhi: %h, flippedlo: %h,", ans[(width<<1) - 1:width], ans[width - 1:0], neg_ans[(width<<1) - 1:width], neg_ans[width - 1:0]);
		// $display("Signed product: high: %h, low: %h, ", ans[(width << 1) - 1: width], ans[width - 1:0]);
		##1;
		// reset();
	endtask

	task test_divide(logic 	[width - 1:0] 	op_a, logic 	[width - 1:0] 	op_b);
		div_valid 	<= 1'b1;
		div_a 		<= op_a;
		div_b 		<= op_b;
		##1;
		// div_valid 	<= 1'b0;
		// div_a 		<= 100;
		// div_b 		<= 100;
		@(clk iff div_rdy)
		bad_quo : assert(op_a / op_b == div_quo)
		else begin
			$error ("%0d: %0t: BAD_QUOTIENT error detected, %0d, %0d, %0d", `__LINE__, $time, op_a, op_b, div_quo);
		end

		bad_rem : assert(op_a % op_b == div_rem)
		else begin
			$error ("%0d: %0t: BAD_REMAINDER error detected, %0d, %0d, %0d", `__LINE__, $time, op_a, op_b, div_rem);
		end
		##1;
		// reset();
	endtask
	
	initial begin : TEST_VECTORS
		reset();
		for(int i = 1; i < 100; i++) begin 
			test_divide(i + 1, 12);
		end 
		// test_multiply(-1, -1);	// unsigned
		// test_multiply(1, 1);	// signed
		// test_multiply(1, -1);	// signed unsigned
		// for (int i = 0; i < 32; i++) begin 
		// 	for (int j = 0; j < 32; j++) begin 
		// 		test_multiply(1, 1 << j);
		// 		test_multiply(-1 * (1 << i), -1 * (1 << j));
		// 	end 
		// end 
		$finish;
	end

endmodule 