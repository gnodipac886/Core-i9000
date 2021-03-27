/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

import data_write_en_mux::*;
import data_out_mux::*;
import data_datain_mux::*;

module cache_control (
	input 	logic 				clk, 
	input 	logic 				rst, 

	// from BUS and CPU
	input 	logic				cpu_read_i,
	input 	logic				cpu_write_i,

	output 	logic				cpu_resp_o,	

	// from cacheline adaptor and memory
	input 	logic				mem_resp_i,

	output 	logic				mem_read_o,	
	output 	logic				mem_write_o,


	// from/to datapath
	input 	logic				_hit,
	input 	logic 				tag0_comp,
	input  	logic 				tag1_comp,
	input 	logic 				lru_dataout, 		// lru = 1: data0, lru = 0: data1
	input 	logic				dirty0_dataout, 
	input 	logic				dirty1_dataout,
	input 	logic				valid0_dataout, 
	input 	logic				valid1_dataout,

	output 	logic 				tag0_load,
	output 	logic 				tag1_load,
	output 	logic 				lru_load,
	output 	logic 				lru_datain,
	output 	logic				dirty0_load,
	output 	logic 				dirty0_datain,
	output 	logic				dirty1_load,
	output 	logic 				dirty1_datain,
	output 	logic				valid0_load,
	output 	logic 				valid0_datain,
	output 	logic				valid1_load,
	output 	logic 				valid1_datain,
	output 	logic 				arr_read,
	output 	logic 	[1:0] 		data0_write_en_mux_sel,
	output 	logic 	[1:0] 		data1_write_en_mux_sel,
	output 	logic 	[1:0] 		data_out_mux_sel,
	output 	logic 	[1:0] 		data0_datain_mux_sel,
	output 	logic 	[1:0] 		data1_datain_mux_sel,
	output 	logic 	[1:0] 		mem_addr_mux_sel
);
	logic 	evict_read;

	enum int unsigned{
		/* list of states*/
		start,
		read,
		write, 
		load_mem,
		evict
	} state, next_state;

	function void cache_set_defaults();
		evict_read 				= 0;
		tag0_load 				= 0;
		tag1_load 				= 0;
		lru_load				= 0;
		lru_datain				= 0;
		dirty0_load				= 0;
		dirty0_datain			= 0;
		dirty1_load				= 0;
		dirty1_datain			= 0;
		valid0_load				= 0;
		valid0_datain			= 0;
		valid1_load				= 0;
		valid1_datain			= 0;
		cpu_resp_o				= 0;
		mem_read_o				= 0;
		mem_write_o				= 0;
		arr_read 				= 1;

		data0_write_en_mux_sel 	= data_write_en_mux::zero;
		data1_write_en_mux_sel 	= data_write_en_mux::zero;
		data0_datain_mux_sel 	= data_datain_mux::w_data;
		data1_datain_mux_sel 	= data_datain_mux::w_data;
		data_out_mux_sel 		= data_out_mux::no_hit;
		mem_addr_mux_sel 		= mem_addr_mux::cpu_addr;
	endfunction

	always_ff @(posedge clk) begin : next_state_assignment
		if(rst) begin
			state <= start;
		end 
		else begin
			state <= next_state;
		end 
	end 

	always_comb begin : next_state_logic
		next_state = state;
		unique case (state)
			start		: begin 
				if(~cpu_read_i && ~cpu_write_i)
					next_state = start;
				else // ?
					next_state = cpu_read_i && ~cpu_write_i ? read : write;
			end 

			read		: begin 
				if(_hit&& state != start)
					next_state = start;
				else if(valid0_dataout || valid1_dataout) begin 
					if((dirty0_dataout && lru_dataout) || (dirty1_dataout && ~lru_dataout)) begin 
						next_state = evict;
					end 
					else begin 
						next_state = load_mem;
					end 
				end
				else
					next_state = load_mem;
			end 

			write		: begin 
				if(_hit&& state != start)
					next_state = start;
				else if(valid0_dataout || valid1_dataout) begin 
					if((dirty0_dataout && lru_dataout) || (dirty1_dataout && ~lru_dataout)) begin 
						next_state = evict;
					end 
					else begin 
						next_state = load_mem;
					end 
				end
				else
					next_state = load_mem;
			end 

			load_mem	: begin 
				if(~mem_resp_i)
					next_state = load_mem;

				else if(mem_resp_i && cpu_write_i)
					next_state = write;

				else if(mem_resp_i && cpu_read_i)
					next_state = read;
			end 

			evict		: begin 
				if(~mem_resp_i)
					next_state = evict;
				
				else
					next_state = load_mem;
			end 

		endcase 
	end 

	always_comb begin : state_actions
		//data_out_mux_sel 	= _hit ? 2'b{0, tag1_comp} : data_out_mux::no_hit; 	// NEEDS TO BE IN CONTROL INSTEAD
		cache_set_defaults();
		unique case (state)
			start	 	: ;

			read	 	: begin // data must be in cache already
				// READ FROM DATA ARRAY = 1
				if(_hit && state != start) begin 
					lru_load 				= 	1;
					lru_datain 				=	tag1_comp;
					data_out_mux_sel		= 	tag0_comp && valid0_dataout ? data_out_mux::data0_hit : data_out_mux::data1_hit;
					cpu_resp_o 				=	1;
				end 
			end 

			write	 	: begin 
				if(_hit && state != start) begin 
					data0_write_en_mux_sel 	= 	tag0_comp && valid0_dataout ? data_write_en_mux::byte_enable : data_write_en_mux::zero;
					data1_write_en_mux_sel 	= 	tag1_comp && valid1_dataout ? data_write_en_mux::byte_enable : data_write_en_mux::zero;
					data0_datain_mux_sel 	=	data_datain_mux::w_data;
					data1_datain_mux_sel 	=	data_datain_mux::w_data;

					lru_load 				= 	1;
					lru_datain 				=	tag1_comp && valid1_dataout;

					dirty0_load 			= 	tag0_comp && valid0_dataout;
					dirty1_load 			= 	tag1_comp && valid1_dataout;
					dirty0_datain 			= 	1'b1;
					dirty1_datain 			= 	1'b1;
					cpu_resp_o 				= 	1;
				end 
			end 

			load_mem	: begin 
				// READ FROM DATA ARRAY = 0
				mem_read_o 					= 	~mem_resp_i;

				if(mem_resp_i) begin
					data0_write_en_mux_sel 	= 	lru_dataout ? data_write_en_mux::all_ones : data_write_en_mux::zero;
					data1_write_en_mux_sel 	= 	~lru_dataout ? data_write_en_mux::all_ones : data_write_en_mux::zero;
					
					tag0_load 				= 	lru_dataout;
					tag1_load 				= 	~lru_dataout;

					valid0_datain 			= 	1'b1;
					valid1_datain 			= 	1'b1;
					valid0_load 			= 	lru_dataout;
					valid1_load 			= 	~lru_dataout;

					// dirty0_datain 			= 	1'b0;
					// dirty1_datain 			= 	1'b0;
					dirty0_load 			= 	lru_dataout;
					dirty1_load 			= 	~lru_dataout;

					unique case(cpu_write_i)
						1'b1: begin 
							data0_datain_mux_sel	= 	data_datain_mux::r_data;
							data1_datain_mux_sel	= 	data_datain_mux::r_data;
							// cpu_resp_o 				=	1;
						end 

						1'b0: begin 
							data0_datain_mux_sel	= 	data_datain_mux::r_data;
							data1_datain_mux_sel	= 	data_datain_mux::r_data;
						end 
					endcase 
				end 
			end 

			evict	 	: begin 
				// READ FROM DATA ARRAY = 1
				mem_write_o 				= 	1;
				data_out_mux_sel 			=	lru_dataout ? data_out_mux::data0_hit : data_out_mux::data1_hit;
				mem_addr_mux_sel 			= 	lru_dataout ? mem_addr_mux::tag0_addr : mem_addr_mux::tag1_addr;
				
				// dirty0_datain 				= 	1'b0;
				// dirty1_datain 				= 	1'b0;
	
				dirty0_load 				= 	lru_dataout;
				dirty1_load 				= 	~lru_dataout;
			end 

		endcase
	end 

endmodule : cache_control

// pmem_write_addr mismatch
