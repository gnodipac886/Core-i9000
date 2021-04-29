`define size		8

module pseudo_lru_tb();

	// timeunit 1ns;
	// timeprecision 1ns;
	logic clk;
	always #5 clk = clk === 1'b0;
	default clocking tb_clk @(posedge clk); endclocking

	// INPUTS
	logic rst;
	logic load;
	logic [`size - 1:0] set_p_lru;
	logic [$clog2(`size) - 1:0] mru_idx;

	// OUTPUTS
	logic [$clog2(`size) - 1:0] lru_idx;

	pseudo_lru #(8) dut(
		.*
	);

	task reset();
		rst			<= 1'b1;
		##1;
		rst			<= 1'b0;
		load		<= 1'b0;
		set_p_lru	<= '0;	
		mru_idx		<= '0;
	endtask : reset

	task test_arr(logic [`size - 1:0] in_arr);
		load		<= 1'b1;
		set_p_lru	<= in_arr;
		##1;
		load		<= 1'b0;
		##1;
	endtask : test_arr

	initial begin: TEST_VECTORS
		reset();
		##1;
		for (int i = 0; i < 2**`size; i++) begin
			test_arr(i);
		end
		$finish;
	end
endmodule
