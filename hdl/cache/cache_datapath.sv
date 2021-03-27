/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */
`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import data_write_en_mux::*;
import data_out_mux::*;
import data_datain_mux::*;

module cache_datapath #(
	parameter s_offset = 5, 						// for which byte
	parameter s_index  = 3, 						// index to which of the 8 sets
	parameter s_tag    = 32 - s_offset - s_index,	// 24
	parameter s_mask   = 2**s_offset,				// 32
	parameter s_line   = 8*s_mask,					// 256
	parameter num_sets = 2**s_index					// 8
)
(
	clk,
	rst,
	cpu_address_i,
	cpu_read_i,
	cpu_write_i,
	cpu_wdata256_i,
	cpu_byte_enable256_i,
	cpu_rdata256_o,
	mem_line_i,
	mem_line_o,
	mem_address_o,
	tag0_load,
	tag1_load,
	lru_load,
	lru_datain,
	dirty0_load,
	dirty0_datain,
	dirty1_load,
	dirty1_datain,
	valid0_load,
	valid0_datain,
	valid1_load,
	valid1_datain,
	arr_read,
	data0_write_en_mux_sel,
	data1_write_en_mux_sel,
	data_out_mux_sel,
	data0_datain_mux_sel,
	data1_datain_mux_sel,
	mem_addr_mux_sel,
	_hit,
	tag0_comp,
	tag1_comp,
	lru_dataout,
	dirty0_dataout, 
	dirty1_dataout,
	valid0_dataout,
	valid1_dataout
);
	input 	logic 						clk;
	input 	logic 						rst;
	// from/to BUS adaptor and CPU
	input 	logic 	[s_mask - 1:0] 		cpu_address_i;
	input 	logic 						cpu_read_i;
	input 	logic 						cpu_write_i;
	input 	logic 	[s_line - 1:0]		cpu_wdata256_i;
	input 	logic 	[s_mask - 1:0]		cpu_byte_enable256_i;

	output 	logic 	[s_line - 1:0] 		cpu_rdata256_o;
	// output 	logic 						cpu_resp_o;

	// from/to cacheline adaptor and memory
	input 	logic 	[s_line - 1:0]		mem_line_i;
	// input 	logic 						mem_resp_i;

	output 	logic 	[s_line - 1:0]		mem_line_o;
	output 	logic 	[s_mask - 1:0] 		mem_address_o;
	// output 	logic 						mem_read_o;
	// output 	logic 						mem_write_o;

	// from/to control
	input 	logic 						tag0_load;
	input 	logic 						tag1_load;
	input 	logic  						lru_load;
	input 	logic  						lru_datain;
	input 	logic 						dirty0_load;
	input 	logic  						dirty0_datain;
	input 	logic 						dirty1_load;
	input 	logic  						dirty1_datain;
	input 	logic 						valid0_load;
	input 	logic  						valid0_datain;
	input 	logic 						valid1_load;
	input 	logic  						valid1_datain;
	input 	logic 						arr_read;
	input 	logic  	[1:0] 				data0_write_en_mux_sel;
	input 	logic  	[1:0] 				data1_write_en_mux_sel;
	input 	logic  	[1:0] 				data_out_mux_sel;
	input 	logic  	[1:0] 				data0_datain_mux_sel;
	input 	logic  	[1:0] 				data1_datain_mux_sel;
	input 	logic 	[1:0] 				mem_addr_mux_sel;

	output 	logic						_hit;
	output 	logic 						tag0_comp;
	output 	logic 						tag1_comp;
	output 	logic 						lru_dataout; 		// lru = 1: data0; lru = 0: data1
	output 	logic						dirty0_dataout; 
	output 	logic						dirty1_dataout;
	output 	logic						valid0_dataout; 
	output 	logic						valid1_dataout;


	// data array logic
	logic 	[s_mask - 1:0] 		data0_write_en_mux_out, data1_write_en_mux_out; 	
	logic 	[s_line - 1:0] 		data0_dataout, data1_dataout;

	// tag array logic
	logic 	[s_tag - 1:0] 		tag0_dataout, tag1_dataout;
	logic 	[s_line - 1:0] 		mem_line_o_mod;

	// muxes
	logic 	[s_line - 1:0]		data_out_mux_out; // to physical write and cpu read
	logic 	[s_line - 1:0] 		data0_datain_mux_out, data1_datain_mux_out; 
	logic 	[s_mask - 1:0] 		mem_addr_mux_out;


	// internal logic
	logic 	[2:0] 				index;
	logic 	[23:0] 				tag;
	logic 	[4:0] 				offset;

	assign 	index 	= 	cpu_address_i[7:5];
	assign 	tag 	=	cpu_address_i[31:8];
	assign 	offset 	= 	cpu_address_i[4:0];

	//module declaration
	data_array data0_array(
		.read 		(arr_read),
		.write_en 	(data0_write_en_mux_out),
		.rindex  	(cpu_address_i[7:5]),
		.windex  	(cpu_address_i[7:5]),
		.datain  	(data0_datain_mux_out),
		.dataout 	(data0_dataout),
		.*
	);

	data_array data1_array(
		.read 		(arr_read),
		.write_en 	(data1_write_en_mux_out),
		.rindex  	(cpu_address_i[7:5]),
		.windex  	(cpu_address_i[7:5]),
		.datain  	(data1_datain_mux_out),
		.dataout 	(data1_dataout),
		.*
	);

	array #(s_index, s_tag) tag0_array(
		.read 		(arr_read),
		.load 		(tag0_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(cpu_address_i[31:8]),
		.dataout 	(tag0_dataout),
		.*
	);

	array #(s_index, s_tag) tag1_array(
		.read 		(arr_read),
		.load 		(tag1_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(cpu_address_i[31:8]),
		.dataout 	(tag1_dataout),
		.*
	);

	array lru_array(
		.read 		(arr_read),
		.load 		(lru_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(lru_datain),
		.dataout 	(lru_dataout),
		.*
	);

	array dirty0_array(
		.read 		(arr_read),
		.load 		(dirty0_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(dirty0_datain),
		.dataout 	(dirty0_dataout),
		.*
	);

	array dirty1_array(
		.read 		(arr_read),
		.load 		(dirty1_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(dirty1_datain),
		.dataout 	(dirty1_dataout),
		.*
	);

	array valid0_array(
		.read 		(arr_read),
		.load 		(valid0_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(valid0_datain),
		.dataout 	(valid0_dataout),
		.*
	);

	array valid1_array(
		.read 		(arr_read),
		.load 		(valid1_load),
		.rindex 	(cpu_address_i[7:5]),
		.windex 	(cpu_address_i[7:5]),
		.datain 	(valid1_datain),
		.dataout 	(valid1_dataout),
		.*
	);


	// combinational logic
	always_comb begin 
		mem_address_o 	= mem_addr_mux_out; 	// need to worry about tag address when evicting
		cpu_rdata256_o 	= data_out_mux_out;
		mem_line_o 		= data_out_mux_out;
		tag0_comp 		= tag0_dataout == cpu_address_i[31:8];
		tag1_comp 		= tag1_dataout == cpu_address_i[31:8];
		_hit 			= (tag0_comp && valid0_dataout) || (tag1_comp && valid1_dataout);

		for(int i = 0; i < s_mask; i++) begin
			mem_line_o_mod[8 * i +: 8]	= cpu_byte_enable256_i[i] ? cpu_wdata256_i[8 * i +: 8]: mem_line_i[8 * i +: 8];
		end 

	end 

	always_comb begin
		data0_write_en_mux_out	= 0;
		data1_write_en_mux_out	= 0;
		data_out_mux_out		= 0;
		data0_datain_mux_out	= 0;
		data1_datain_mux_out	= 0;

		unique case(data0_write_en_mux_sel)
			data_write_en_mux::zero 			: data0_write_en_mux_out 	= 32'd0;
			data_write_en_mux::all_ones 		: data0_write_en_mux_out 	= 32'hFFFFFFFF;
			data_write_en_mux::byte_enable 		: data0_write_en_mux_out 	= cpu_byte_enable256_i;
			// default 							: `BAD_MUX_SEL;
			default 							: ;//$fatal("%0t %s %0d, mux_sel:%0d: Illegal mux select", $time, `__FILE__, `__LINE__, data0_write_en_mux_sel);
		endcase

		unique case(data1_write_en_mux_sel)
			data_write_en_mux::zero 			: data1_write_en_mux_out 	= 32'd0;
			data_write_en_mux::all_ones 		: data1_write_en_mux_out 	= 32'hFFFFFFFF;
			data_write_en_mux::byte_enable 		: data1_write_en_mux_out 	= cpu_byte_enable256_i;
			default 							: ;//`BAD_MUX_SEL;
		endcase

		unique case(data_out_mux_sel)
			data_out_mux::data0_hit 			: data_out_mux_out 			= data0_dataout;
			data_out_mux::data1_hit 			: data_out_mux_out 			= data1_dataout;
			data_out_mux::no_hit 				: data_out_mux_out 			= 0;
			default 							: ;//`BAD_MUX_SEL;
		endcase 

		unique case(data0_datain_mux_sel)
			data_datain_mux::r_data_mod 		: data0_datain_mux_out 		= mem_line_o_mod;
			data_datain_mux::w_data 			: data0_datain_mux_out 		= cpu_wdata256_i;
			data_datain_mux::r_data 			: data0_datain_mux_out 		= mem_line_i;
			default 							: ;//`BAD_MUX_SEL;
		endcase 

		unique case(data1_datain_mux_sel)
			data_datain_mux::r_data_mod 		: data1_datain_mux_out 		= mem_line_o_mod;
			data_datain_mux::w_data 			: data1_datain_mux_out 		= cpu_wdata256_i;
			data_datain_mux::r_data 			: data1_datain_mux_out 		= mem_line_i;
			default 							: ;//`BAD_MUX_SEL;
		endcase 

		unique case(mem_addr_mux_sel)
			mem_addr_mux::cpu_addr 				: mem_addr_mux_out 			= {cpu_address_i[31:5], 5'd0};
			mem_addr_mux::tag0_addr 			: mem_addr_mux_out 			= {tag0_dataout, index, 5'd0};
			mem_addr_mux::tag1_addr 			: mem_addr_mux_out 			= {tag1_dataout, index, 5'd0};
		endcase
	end 

endmodule:cache_datapath
