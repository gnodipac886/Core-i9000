import rv32i_types::*;

module mp4 #(parameter width = 32)
(
	input 	logic			clk,
	input 	logic			rst,
	input 	logic			pmem_resp,
	input 	logic [63:0]	pmem_rdata,
	output 	logic			pmem_read,
	output 	logic			pmem_write,
	output 	rv32i_word 		pmem_address,
	output 	logic [63:0]	pmem_wdata
);
	/**************************** Signals CPU <-> Cache **************************/
		logic 				mem_resp;
		rv32i_word 			mem_rdata;
		logic 				mem_read;
		logic 				mem_write;
		logic 		[3:0] 	mem_byte_enable;
		rv32i_word 			mem_address;
		rv32i_word 			mem_wdata;
	/*****************************************************************************/

	/**************************** Signals Cache <-> Adaptor **********************/
		logic 				pmem_read_cla;
		logic 				pmem_write_cla;
		logic 				pmem_resp_cla;
		logic 		[31:0]	pmem_address_cla;
		logic 		[255:0]	pmem_rdata_256_cla;
		logic 		[255:0]	pmem_wdata_256_cla;
	/*****************************************************************************/

	cpu cpu(.*);

	// Keep cache named `cache` for RVFI Monitor
	cache instr_cache(
		.mem_address(mem_address),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.mem_wdata_cpu(mem_wdata),
		.mem_byte_enable_cpu(mem_byte_enable),
		.mem_rdata_cpu(mem_rdata),
		.mem_resp(mem_resp),

		.pmem_rdata(pmem_rdata_256_cla),
		.pmem_resp(pmem_resp_cla),
		.pmem_wdata(pmem_wdata_256_cla),
		.pmem_address(pmem_address_cla),
		.pmem_read(pmem_read_cla),
		.pmem_write(pmem_write_cla),
		.*
	);

	// From MP1
	cacheline_adaptor cacheline_adaptor(
			.clk(clk),
			.reset_n(~rst),

			.line_i(pmem_wdata_256_cla),
			.line_o(pmem_rdata_256_cla),
			.address_i(pmem_address_cla),
			.read_i(pmem_read_cla),
			.write_i(pmem_write_cla),
			.resp_o(pmem_resp_cla),

			.burst_i(pmem_rdata),
			.burst_o(pmem_wdata),
			.address_o(pmem_address),
			.read_o(pmem_read),
			.write_o(pmem_write),
			.resp_i(pmem_resp)
	);
	
endmodule : mp4
