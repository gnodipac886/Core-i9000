module arbiter #(parameter width = 32)
(
	// from instruction cache
	input 	logic 				iq_empty,
	input 	logic 				i_pmem_read_cla,
	input 	logic 				i_pmem_write_cla,
	input 	logic 		[31:0]	i_pmem_address_cla,
	input 	logic 		[255:0]	i_pmem_wdata_256_cla,
	output 	logic 				i_pmem_resp_cla,
	output 	logic 		[255:0]	i_pmem_rdata_256_cla,

	// from lsq cache
	input 	logic 				lsq_pmem_read_cla,
	input 	logic 				lsq_pmem_write_cla,
	input 	logic 		[31:0]	lsq_pmem_address_cla,
	input 	logic 		[255:0]	lsq_pmem_wdata_256_cla,
	output 	logic 				lsq_pmem_resp_cla,
	output 	logic 		[255:0]	lsq_pmem_rdata_256_cla,

	// to cacheline adaptor
	input 	logic 				pmem_resp_cla,
	input 	logic 		[255:0]	pmem_rdata_256_cla,
	output 	logic 				pmem_read_cla,
	output 	logic 				pmem_write_cla,
	output 	logic 		[31:0]	pmem_address_cla,
	output 	logic 		[255:0]	pmem_wdata_256_cla
);

	logic 		i_connected, lsq_connected;
	logic [1:0]	ar_mux_sel;

	assign ar_mux_sel = '{i_connected, lsq_connected};

	// lsq takes priority unless instruction queue is empty
	always_comb begin 
		i_connected = 0;
		lsq_connected = 0;
		if(iq_empty) 
			i_connected = 1;

		else begin
			if(lsq_pmem_read_cla || lsq_pmem_write_cla)
				lsq_connected = 1;

			else if(i_pmem_read_cla || i_pmem_write_cla)
				i_connected = 1;

			else begin 
				i_connected = 0;
				lsq_connected = 0;
			end
		end 

		unique case(ar_mux_sel)
			2'b01: begin 
				i_pmem_resp_cla			= 0;
				i_pmem_rdata_256_cla	= 0;
				lsq_pmem_resp_cla		= pmem_resp_cla;
				lsq_pmem_rdata_256_cla	= pmem_rdata_256_cla;
				pmem_read_cla 			= lsq_pmem_read_cla;
				pmem_write_cla			= lsq_pmem_write_cla;
				pmem_address_cla		= lsq_pmem_address_cla;
				pmem_wdata_256_cla		= lsq_pmem_wdata_256_cla;
			end 	

			2'b10: begin 
				i_pmem_resp_cla			= pmem_resp_cla;
				i_pmem_rdata_256_cla	= pmem_rdata_256_cla;
				lsq_pmem_resp_cla		= 0;
				lsq_pmem_rdata_256_cla	= 0;
				pmem_read_cla 			= i_pmem_read_cla;
				pmem_write_cla			= i_pmem_write_cla;
				pmem_address_cla		= i_pmem_address_cla;
				pmem_wdata_256_cla		= i_pmem_wdata_256_cla;
			end 

			default: begin 
				i_pmem_resp_cla			= 0;
				i_pmem_rdata_256_cla	= 0;
				lsq_pmem_resp_cla		= 0;
				lsq_pmem_rdata_256_cla	= 0;
				pmem_read_cla 			= 0;
				pmem_write_cla			= 0;
				pmem_address_cla		= 0;
				pmem_wdata_256_cla		= 0;
			end 
		endcase
	end 

endmodule : arbiter
