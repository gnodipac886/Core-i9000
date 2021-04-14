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
		logic 				i_mem_resp;
		rv32i_word 			i_mem_rdata;
		logic 				i_mem_read;
		logic 				i_mem_write;
		logic 		[3:0] 	i_mem_byte_enable;
		rv32i_word 			i_mem_address;
		rv32i_word 			i_mem_wdata;
		logic 				iq_empty;

		logic 				lsq_mem_resp;
		rv32i_word 			lsq_mem_rdata;
		logic 				lsq_mem_read;
		logic 				lsq_mem_write;
		logic 		[3:0] 	lsq_mem_byte_enable;
		rv32i_word 			lsq_mem_address;
		rv32i_word 			lsq_mem_wdata;
	/*****************************************************************************/

	/**************************** Cache <-> Arbiter ******************************/
		logic 				i_pmem_read_cla;
		logic 				i_pmem_write_cla;
		logic 				i_pmem_resp_cla;
		logic 		[31:0]	i_pmem_address_cla;
		logic 		[255:0]	i_pmem_rdata_256_cla;
		logic 		[255:0]	i_pmem_wdata_256_cla;

		logic 				lsq_pmem_read_cla;
		logic 				lsq_pmem_write_cla;
		logic 				lsq_pmem_resp_cla;
		logic 		[31:0]	lsq_pmem_address_cla;
		logic 		[255:0]	lsq_pmem_rdata_256_cla;
		logic 		[255:0]	lsq_pmem_wdata_256_cla;
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
	cache i_cache(
		.mem_address(i_mem_address),
		.mem_read(i_mem_read),
		.mem_write(i_mem_write),
		.mem_wdata_cpu(i_mem_wdata),
		.mem_byte_enable_cpu(i_mem_byte_enable),
		.mem_rdata_cpu(i_mem_rdata),
		.mem_resp(i_mem_resp),

		.pmem_rdata(i_pmem_rdata_256_cla),
		.pmem_resp(i_pmem_resp_cla),
		.pmem_wdata(i_pmem_wdata_256_cla),
		.pmem_address(i_pmem_address_cla),
		.pmem_read(i_pmem_read_cla),
		.pmem_write(i_pmem_write_cla),
		.*
	);

	cache lsq_cache(
		.mem_address(lsq_mem_address),
		.mem_read(lsq_mem_read),
		.mem_write(lsq_mem_write),
		.mem_wdata_cpu(lsq_mem_wdata),
		.mem_byte_enable_cpu(lsq_mem_byte_enable),
		.mem_rdata_cpu(lsq_mem_rdata),
		.mem_resp(lsq_mem_resp),

		.pmem_rdata(lsq_pmem_rdata_256_cla),
		.pmem_resp(lsq_pmem_resp_cla),
		.pmem_wdata(lsq_pmem_wdata_256_cla),
		.pmem_address(lsq_pmem_address_cla),
		.pmem_read(lsq_pmem_read_cla),
		.pmem_write(lsq_pmem_write_cla),
		.*
	);

	arbiter arbiter(.*);

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
