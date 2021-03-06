module arbiter #(parameter width = 32)
(
	input 	logic					clk,
	input 	logic					rst,
	
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

	// from prefetcher
	input 	logic 				pref_pmem_read_cla,
	input 	logic 				pref_pmem_write_cla,
	input 	logic 		[31:0]	pref_pmem_address_cla,
	input 	logic 		[255:0]	pref_pmem_wdata_256_cla,
	output 	logic 				pref_pmem_resp_cla,
	output 	logic 		[255:0]	pref_pmem_rdata_256_cla,
	output 	logic 				arbiter_idle,

	// to cacheline adaptor // now goes to l2
	input 	logic 				pmem_resp_cla,
	input 	logic 		[255:0]	pmem_rdata_256_cla,
	output 	logic 				pmem_read_cla,
	output 	logic 				pmem_write_cla,
	output 	logic 		[31:0]	pmem_address_cla,
	output 	logic 		[255:0]	pmem_wdata_256_cla
);

	enum logic [1:0]{
		serve_pref,
		serve_instr,
		serve_lsq,
		idle
	} state, next_state;

	function void connect_lsq();
		i_pmem_resp_cla			= 0;
		i_pmem_rdata_256_cla	= 0;
		pref_pmem_resp_cla		= 0;
		pref_pmem_rdata_256_cla	= 0;
		lsq_pmem_resp_cla		= pmem_resp_cla;
		lsq_pmem_rdata_256_cla	= pmem_rdata_256_cla;
		pmem_read_cla 			= lsq_pmem_read_cla;
		pmem_write_cla			= lsq_pmem_write_cla;
		pmem_address_cla		= lsq_pmem_address_cla;
		pmem_wdata_256_cla		= lsq_pmem_wdata_256_cla;
	endfunction: connect_lsq

	function void connect_instr();
		i_pmem_resp_cla			= pmem_resp_cla;
		i_pmem_rdata_256_cla	= pmem_rdata_256_cla;
		pref_pmem_resp_cla		= 0;
		pref_pmem_rdata_256_cla	= 0;
		lsq_pmem_resp_cla		= 0;
		lsq_pmem_rdata_256_cla	= 0;
		pmem_read_cla 			= i_pmem_read_cla;
		pmem_write_cla			= i_pmem_write_cla;
		pmem_address_cla		= i_pmem_address_cla;
		pmem_wdata_256_cla		= i_pmem_wdata_256_cla;
	endfunction: connect_instr

	function void connect_pref();
		i_pmem_resp_cla			= 0;
		i_pmem_rdata_256_cla	= 0;
		lsq_pmem_resp_cla		= 0;
		lsq_pmem_rdata_256_cla	= 0;
		pref_pmem_resp_cla		= pmem_resp_cla;
		pref_pmem_rdata_256_cla	= pmem_rdata_256_cla;
		pmem_read_cla 			= pref_pmem_read_cla;
		pmem_write_cla			= pref_pmem_write_cla;
		pmem_address_cla		= pref_pmem_address_cla;
		pmem_wdata_256_cla		= pref_pmem_wdata_256_cla;
	endfunction: connect_pref

	function void set_defaults();
		i_pmem_resp_cla			= 0;
		i_pmem_rdata_256_cla	= 0;
		lsq_pmem_resp_cla		= 0;
		lsq_pmem_rdata_256_cla	= 0;
		pref_pmem_resp_cla		= 0;
		pref_pmem_rdata_256_cla	= 0;
		pmem_read_cla 			= 0;
		pmem_write_cla			= 0;
		pmem_address_cla		= 0;
		pmem_wdata_256_cla		= 0;
	endfunction : set_defaults

	always_comb begin

		unique case(state)
			idle		: begin
				set_defaults();
				arbiter_idle = 1'b1;
			end 

			serve_instr : begin
				connect_instr();
				arbiter_idle = 1'b0;
			end 

			serve_lsq 	: begin 
				connect_lsq();
				arbiter_idle = 1'b0;
			end 

			serve_pref 	: begin 
				connect_pref();
				arbiter_idle = 1'b0;
			end 

			default		: begin
				set_defaults();
				arbiter_idle = 1'b0;
			end 

		endcase 
	end

	always_comb begin
		next_state = state;
		unique case(state)
			idle: begin 
				if (i_pmem_read_cla || i_pmem_write_cla)
					next_state = serve_instr;
				else if (lsq_pmem_read_cla || lsq_pmem_write_cla)
					next_state = serve_lsq;
				else if (pref_pmem_read_cla)
					next_state = serve_pref;
				else
					next_state = idle;
			end 

			serve_instr: begin
				if ((lsq_pmem_read_cla || lsq_pmem_write_cla) && pmem_resp_cla)
					next_state = serve_lsq;
				else if (pmem_resp_cla)
					next_state = idle;
				else
					next_state = serve_instr;
			end 

			serve_lsq: begin
				if ((i_pmem_read_cla || i_pmem_write_cla) && pmem_resp_cla)
					next_state = serve_instr;
				else if (pmem_resp_cla)
					next_state = idle;
				else 
					next_state = serve_lsq;
			end

			serve_pref: 
				if ((i_pmem_read_cla || i_pmem_write_cla) && pmem_resp_cla)
					next_state = serve_instr;
				else if ((lsq_pmem_read_cla || lsq_pmem_write_cla) && pmem_resp_cla)
					next_state = serve_lsq;
				else if (pmem_resp_cla)
					next_state = idle;
				else 
					next_state = serve_pref;
				

			default: ;
		endcase 
	end

	always_ff @(posedge clk) begin
		if(rst) begin 
			state 	<= idle;
		end 
		else begin 
			state 	<= next_state;
		end
	end

endmodule : arbiter
