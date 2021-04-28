/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

`define SRC 1
`define RAND 0
`define TESTBENCH `SRC

module mp4_tb;

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
assign itf.halt = 0;//dut.cpu.pc_load & (dut.cpu.pc_mux_out == dut.cpu.pc_out);
/*****************************************************************************/

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
end

/*****************************************************************************/

mp4 dut(
	.clk		  (itf.clk),
	.rst		  (itf.rst),
	.pmem_resp  (itf.mem_resp),
	.pmem_rdata   (itf.mem_rdata),
	.pmem_read  (itf.mem_read),
	.pmem_write   (itf.mem_write),
	.pmem_address (itf.mem_address),
	.pmem_wdata   (itf.mem_wdata)
);

// riscv_formal_monitor_rv32i monitor(
//   .clock(itf.clk),
//   .reset(itf.rst),
//   .rvfi_valid(commit),
//   .rvfi_order(order),
//   .rvfi_insn(dut.cpu.datapath.IR.data),
//   .rvfi_trap(dut.cpu.control.trap),
//   .rvfi_halt(itf.halt),
//   .rvfi_intr(1'b0),
//   .rvfi_mode(2'b00),
//   .rvfi_rs1_addr(dut.cpu.control.rs1_addr),
//   .rvfi_rs2_addr(dut.cpu.control.rs2_addr),
//   .rvfi_rs1_rdata(monitor.rvfi_rs1_addr ? dut.cpu.datapath.rs1_out : 0),
//   .rvfi_rs2_rdata(monitor.rvfi_rs2_addr ? dut.cpu.datapath.rs2_out : 0),
//   .rvfi_rd_addr(dut.cpu.load_regfile ? dut.cpu.datapath.rd : 5'h0),
//   .rvfi_rd_wdata(monitor.rvfi_rd_addr ? dut.cpu.datapath.regfilemux_out : 0),
//   .rvfi_pc_rdata(dut.cpu.datapath.pc_out),
//   .rvfi_pc_wdata(dut.cpu.datapath.pcmux_out),
//   // NOTE: dut.cpu.datapath.mem_addr should be byte or 4-byte aligned
//   //	  memory address for all loads and stores (including fetches)
//   .rvfi_mem_addr({dut.cpu.datapath.mem_addr[31:2], 2'b0}),
//   .rvfi_mem_rmask(dut.cpu.control.rmask),
//   .rvfi_mem_wmask(dut.cpu.control.wmask),
//   .rvfi_mem_rdata(dut.cpu.datapath.mdrreg_out),
//   .rvfi_mem_wdata(dut.cpu.datapath.mem_wdata),
//   .rvfi_mem_extamo(1'b0),
//   .errcode(itf.errcode)
// );

software_model sm(
	// .clk	(itf.clk),
	.rst    (itf.rst),
	.commit (dut.cpu.rob.rdest[0].rdy || dut.cpu.rob.rdest[1].rdy || dut.cpu.rob.rdest[2].rdy || dut.cpu.rob.rdest[3].rdy || dut.cpu.rob.rdest[4].rdy 
		|| dut.cpu.rob.rdest[5].rdy || dut.cpu.rob.rdest[6].rdy || dut.cpu.rob.rdest[7].rdy),
	.rdest  (dut.cpu.rob.rdest),
	.rd_bus (dut.cpu.rob.rd_bus),
	.cpu_registers(dut.cpu.registers.data),
	.pc(dut.cpu.pc_out),
	.flush(dut.cpu.rob.flush),
	.halt(itf.halt)
);

endmodule : mp4_tb
