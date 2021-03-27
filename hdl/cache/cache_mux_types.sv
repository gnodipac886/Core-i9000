// mux types for cache

package data_write_en_mux;
	typedef enum bit [1:0] {
		zero  		= 2'b00,
		all_ones  	= 2'b01,
		byte_enable = 2'b10
	} data_write_en_mux_t;
endpackage

package data_out_mux;
	typedef enum bit [1:0] {
		data0_hit	= 2'b00,
		data1_hit 	= 2'b01,
		no_hit 		= 2'b11
	} data_out_mux_t;
endpackage

package data_datain_mux;
	typedef enum bit [1:0] {
		r_data_mod	= 2'b00,
		w_data 		= 2'b01,
		r_data 		= 2'b11
	} data_datain_mux_t;
endpackage

package mem_addr_mux;
	typedef enum bit [1:0]{
		cpu_addr 	= 2'b00,
		tag0_addr 	= 2'b01,
		tag1_addr 	= 2'b10
	} mem_addr_mux_t;
endpackage