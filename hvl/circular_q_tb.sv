module circular_q_tb();

	// timeunit 1ns;
	// timeprecision 1ns;
	logic clk;
	always #5 clk = clk === 1'b0;
	default clocking tb_clk @(posedge clk); endclocking
	

	logic 				rst;
	logic 				enq;
	logic 				deq;
	logic 	[31:0] 		in;
	logic 				empty;
	logic 				full;
	logic 				ready;
	logic 	[31:0] 		out;

	circular_q dut(.*);

	task reset();
		##1;
		rst <= 1'b1;
		enq <= 0;
		deq <= 0;
		in 	<= 32'hDEAD;
		##1;
		rst <= 1'b0;
		in 	<= 32'd0;
		##1;
	endtask : reset

	task test_enqueue(int num);
		##1;
		enq <= 1;
		for(int i = 0; i < num; i++) begin 
			in 	<= i + 1;
			@(tb_clk);
		end 
		enq <= 0;
		##2;
	endtask

	task test_dequeue(int num);
		##1;
		deq <= 1;
		for(int i = 0; i < num; i++) begin
			@(tb_clk);
		end 
		deq <= 0;
		##2;
	endtask

	task test_endequeue(int num);
		test_enqueue(5);
		enq <= 1;
		deq <= 1;
		for(int i = 0; i < num; i++) begin 
			in 	<= i + 1;
			@(tb_clk);
		end 
		enq <= 0;
		deq <= 0;
		##2;
	endtask
		
	initial begin : TEST_VECTORS
		reset();

		test_enqueue(8);
		test_dequeue(5);
		test_enqueue(5);
		test_dequeue(3);
		test_enqueue(7);
		test_dequeue(10);

		test_endequeue(10);

		$finish;
	end
 
endmodule 


