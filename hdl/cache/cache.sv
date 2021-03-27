/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(	
	clk,
	rst,
	mem_address,
	mem_read,
	mem_write,
	mem_wdata,
	mem_byte_enable,
	mem_rdata,
	mem_resp,

	pmem_rdata,
	pmem_resp,
	pmem_wdata,
	pmem_address,
	pmem_read,
	pmem_write
);
	input 						clk;
	input 						rst;
	// from/to CPU
	input 	[s_mask - 1:0] 		mem_address;
	input 						mem_read;
	input 						mem_write;
	input 	[s_mask - 1:0] 		mem_wdata;
	input 	[s_index:0] 		mem_byte_enable;

	output 	[s_mask - 1:0] 		mem_rdata;
	output 						mem_resp;

	// from/to cacheline adaptor and memory
	input 	[s_line - 1:0]		pmem_rdata;
	input 						pmem_resp;

	output 	[s_line - 1:0]		pmem_wdata;
	output 	[s_mask - 1:0] 		pmem_address;
	output 						pmem_read;
	output 						pmem_write;

	// local logic
	logic						_hit;
	logic 						tag0_comp;
	logic 						tag1_comp;
	logic 						lru_dataout; 		// lru = 1: data0, lru = 0: data1
	logic						dirty0_dataout; 
	logic						dirty1_dataout;
	logic						valid0_dataout; 
	logic						valid1_dataout;
	logic 						tag0_load;
	logic 						tag1_load;
	logic 						lru_load;
	logic 						lru_datain;
	logic						dirty0_load;
	logic 						dirty0_datain;
	logic						dirty1_load;
	logic 						dirty1_datain;
	logic						valid0_load;
	logic 						valid0_datain;
	logic						valid1_load;
	logic 						valid1_datain;
	logic 						arr_read;
	logic 	[1:0] 				data0_write_en_mux_sel;
	logic 	[1:0] 				data1_write_en_mux_sel;
	logic 	[1:0] 				data_out_mux_sel;
	logic 	[1:0] 				data0_datain_mux_sel;
	logic 	[1:0] 				data1_datain_mux_sel;
	logic 	[1:0] 				mem_addr_mux_sel;
	logic 	[s_line - 1:0]		cpu_wdata256_i;
	logic 	[s_mask - 1:0]		cpu_byte_enable256_i;
	logic 	[s_line - 1:0] 		cpu_rdata256_o;

	// from/to cacheline adaptor and memory
	logic 	[s_line - 1:0]		mem_line_i;
	logic 						mem_resp_i;

	logic 	[s_line - 1:0]		mem_line_o;
	logic 	[s_mask - 1:0] 		mem_address_o;
	logic 						mem_read_o;
	logic 						mem_write_o;

	logic 	[s_mask - 1:0] 		cpu_address_i;
	logic 						cpu_read_i;
	logic 						cpu_write_i;
	logic 						cpu_resp_o;

	assign 	mem_line_i 		= 	pmem_rdata;
	assign 	mem_resp_i 		= 	pmem_resp;
		
	assign 	pmem_wdata 		= 	mem_line_o;
	assign 	pmem_address 	= 	mem_address_o;
	assign 	pmem_read 		= 	mem_read_o;
	assign 	pmem_write 		= 	mem_write_o;

	assign 	cpu_address_i 	= 	mem_address;
	assign 	cpu_read_i 		= 	mem_read;
	assign 	cpu_write_i 	= 	mem_write;
	assign 	mem_resp 		= 	cpu_resp_o;

	cache_control control(.*);

	cache_datapath datapath(.*);

	bus_adapter bus_adapter(
		.mem_wdata256(cpu_wdata256_i),
		.mem_rdata256(cpu_rdata256_o),
		.mem_byte_enable256(cpu_byte_enable256_i),
		.address(cpu_address_i),
		.*
	);

endmodule : cache

/*# ** Error: packet: '
{evict:dirty_evict, rdata:3495673662, mem_addr:32896, 
mem_wdata:34501582747384933281130038896647312066726045446038337200936680773626371024993}^M

2021-03-16T21:50:58.056559797Z #    Time: 11050 ns  Scope: mp3_tb File: /job/student/hvl/top.sv Line: 105^M
2021-03-16T21:50:58.056689273Z # ** Error: ms: '
{mem_addr:2156429448, mem_rdata:3495673662, mem_wdata:0, mem_read:1, mem_write:0, mem_byte_enable:0, 
pmem_raddr:2156429448, pmem_rdata:87667841509031064702175510252504898230045271770296783919734637147482142104351, 
pmem_waddr:32904, pmem_wdata:34501582747384933281130038896647312066726045446038337200936680773626371024993, pmem_read:1, 
pmem_write:1, clock_cycles:32}

-- single write back

2021-03-19T10:43:52.160232760Z # ** Error: packet: '{evict:dirty_evict, rdata:3495673662, 
mem_addr:32896, mem_wdata:34501582747384933281130038896647312066726045446038337200936680773626371024993}
2021-03-19T10:43:52.160359696Z #    Time: 11050 ns  Scope: mp3_tb File: /job/student/hvl/top.sv Line: 105
2021-03-19T10:43:52.160497466Z # ** Error: ms: '{mem_addr:2156429448, mem_rdata:3495673662, 
mem_wdata:0, mem_read:1, mem_write:0, mem_byte_enable:0, pmem_raddr:2156429448, 
pmem_rdata:87667841509031064702175510252504898230045271770296783919734637147482142104351, 
pmem_waddr:32904, pmem_wdata:34501582747384933281130038896647312066726045446038337200936680773626371024993, 
pmem_read:1, pmem_write:1, clock_cycles:32}
2021-03-19T10:43:52.160656133Z #    Time: 11050 ns  Scope: mp3_tb File: /job/student/hvl/top.sv Line: 105

*/