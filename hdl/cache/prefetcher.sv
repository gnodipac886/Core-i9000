module prefetcher #(parameter limit = 8)
(
	input   logic 			clk,
	input   logic 			rst,
	input 	logic 			lsq_pmem_read_cla,
	input 	logic 			lsq_pmem_write_cla,
	input 	logic 			i_pmem_read_cla,
 	input 	logic 			i_pmem_write_cla,
	input 	logic 			pref_pmem_resp_cla,
	input   logic   [31:0]  lsq_pmem_address_cla,
	input 	logic 	[255:0]	pref_pmem_rdata_256_cla,
	input   logic 			arbiter_idle,
	output 	logic 			pref_pmem_read_cla,
	output 	logic 			pref_pmem_write_cla,
	output 	logic 	[31:0]	pref_pmem_address_cla,
	output 	logic 	[255:0]	pref_pmem_wdata_256_cla
);

/*
	limits: 8, 16, 32 cache size
	2: 644,235
	5: 630,025
	8: 629,905
	15:632,475
*/

	logic	[31:0]	pref_addr_in;
	logic			pref_addr_load;
	int  			counter;

	register pref_addr(
		.load(pref_addr_load),
		.in(pref_addr_in),
		.out(pref_pmem_address_cla),
		.*
	);

	logic		   	valid;

	enum logic [1:0] {
		idle,
		prefetch,
		inc_addr
	} state, next_state;
	
	always_comb begin : next_state_logic
		next_state = state;
		case (state) 
			idle	 : begin 
				if(~valid) 
					next_state = idle;
				else if(arbiter_idle && (~lsq_pmem_read_cla & ~lsq_pmem_write_cla) && (~i_pmem_read_cla & ~i_pmem_write_cla) && counter < limit)
					next_state = prefetch;
			end 

			prefetch : begin 
				if(pref_pmem_resp_cla)
					next_state = inc_addr;
				else
					next_state = prefetch; 
			end 
			
			inc_addr: begin 
				next_state = idle;
			end 
		endcase 
	end
	
	function void set_defaults();
		pref_pmem_read_cla		= 1'b0;
		pref_pmem_write_cla		= 1'b0;
		pref_pmem_wdata_256_cla	= 256'b0;
		pref_addr_load			= 1'b0;
		pref_addr_in			= 32'b0;
	endfunction

	always_comb begin : state_actions
		set_defaults();
		case (state) 
			idle: begin
				if (lsq_pmem_read_cla | lsq_pmem_write_cla) begin
					pref_addr_load	= 1'b1;
					pref_addr_in	= lsq_pmem_address_cla + 32'h20;
				end
			end

			prefetch: begin
				pref_pmem_read_cla	= 1'b1;
			end

			inc_addr: begin
				pref_addr_in	= pref_pmem_address_cla + 32'h20;
				pref_addr_load	= 1'b1;
			end
			
		endcase 
	end

	always_ff @(posedge clk) begin
		if (rst) begin
			valid	  	<= 1'b0;
			state 		<= idle;
			counter 	<= 0;
		end else begin
			if (lsq_pmem_read_cla | lsq_pmem_write_cla) begin
				valid	<= 1'b1;
			end
			state		<= next_state;
		end
		if(state == idle && (lsq_pmem_read_cla | lsq_pmem_write_cla))
			counter  	<= 0;
		if(state == inc_addr)
			counter 	<= counter + 1;
	end
endmodule : prefetcher