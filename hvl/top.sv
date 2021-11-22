/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

`define SRC 1
`define RAND 0
`define TESTBENCH `SRC

module mp4_tb;

localparam size = 63;

timeunit 1ns;
timeprecision 1ns;

/****************************** Generate Clock *******************************/
bit clk;
always #5 clk = clk === 1'b0;


/*********************** Variable/Interface Declarations *********************/
logic commit;
assign commit = dut.cpu.pc_load;
tb_itf itf(clk);
logic [63:0] order;
initial order = 0;
always @(posedge itf.clk iff commit) order <= order + 1;
int timeout = 100000000;   // Feel Free to adjust the timeout value
// assign itf.registers = dut.cpu.datapath.regfile.data;
assign itf.halt = dut.cpu.rob.halt;
/*****************************************************************************/
int num_inst, num_rob_full;

/************************** Testbench Instantiation **************************/
// source_tb --- drives the dut by executing a RISC-V binary
cache_monitor_itf cache_itf(clk);
assign cache_itf.addr = dut.cpu.i_mem_address;
assign cache_itf.rdata = dut.cpu.i_mem_rdata;
assign cache_itf.wdata = dut.cpu.i_mem_wdata;
assign cache_itf.read = dut.cpu.i_mem_read;
assign cache_itf.write = dut.cpu.i_mem_write;
assign cache_itf.mbe = dut.cpu.i_mem_byte_enable;
assign cache_itf.resp = dut.cpu.i_mem_resp;
source_tb tb(.itf(itf), .mem_itf(itf), .cache_itf(cache_itf));
// For random_tb, recommend using mp1

// Initial Reset
initial begin
	$display("Compilation Successful");
	itf.path_mb.put("memory.lst");
	itf.rst = 1'b1;
	repeat (5) @(posedge clk);
	itf.rst = 1'b0;
	num_inst	 = 0;
	num_rob_full = 0;
end
/*****************************************************************************/


/************************* Error Halting Conditions **************************/
// Stop simulation on error detection
always @(itf.errcode iff (itf.errcode != 0)) begin
	repeat (30) @(posedge itf.clk);
	$display("TOP: Errcode: %0d", itf.errcode);
	$finish;
end

// Stop simulation on timeout (stall detection), halt
always @(posedge itf.clk) begin
	if (itf.halt) begin 
		$finish;
	end 
	if (timeout == 0) begin
		$display("TOP: Timed out");
		$finish;
	end
	timeout <= timeout - 1;
	if(dut.cpu.rob.deq)
		num_inst <= num_inst + dut.cpu.rob.num_deq;
	if(dut.cpu.rob.full) begin 
		num_rob_full <= num_rob_full + 1;
		// $display("%b", dut.cpu.rob.arr[dut.cpu.rob.front].pc_info.funct3);
	end
end

/*****************************************************************************/

mp4 #(
	.size(size)
) dut(
	.clk		  (itf.clk),
	.rst		  (itf.rst),
	.pmem_resp  (itf.mem_resp),
	.pmem_rdata   (itf.mem_rdata),
	.pmem_read  (itf.mem_read),
	.pmem_write   (itf.mem_write),
	.pmem_address (itf.mem_address),
	.pmem_wdata   (itf.mem_wdata)
);

software_model #(
	.size(size)
) sm(
	.clk	(itf.clk),
	.rst    (itf.rst),
	.commit (dut.cpu.rob.deq),
	.rdest  (dut.cpu.rob.rdest),
	.rd_bus (dut.cpu.rob.rd_bus),
	.cpu_registers(dut.cpu.registers.data),
	// .cpu_branch_prediction(dut.cpu.branch_prediction.data),
	.pc(dut.cpu.pc_out),
	.flush(dut.cpu.rob.flush),
	.halt(itf.halt),
	.pc_load(dut.cpu.pc_load),
	.pc_mux_out(dut.cpu.pc_mux_out),
	.num_deq(dut.cpu.rob.num_deq)
);

endmodule : mp4_tb

/*

comp1: 433,225
comp2: 223,635
comp3: 419,305
*/