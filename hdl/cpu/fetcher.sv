module fetcher #(parameter width = 32)
(
	input  logic 				deq,
	input  logic 				i_mem_resp,
	input  logic 	[31:0] 		pc_addr,
	input  logic 	[width-1:0] i_mem_rdata,

	output logic 				i_mem_read,
	output logic 				rdy,
	output logic 	[width-1:0] out,
	output logic 	[31:0]		i_mem_address,
	output logic				num_fetch
);

	assign i_mem_address 	= pc_addr;
	assign i_mem_read 		= deq;
	assign rdy 				= i_mem_resp;
	assign out  			= i_mem_rdata;

	always_comb begin
		num_fetch = 1'b1;
		if (i_mem_address[4:0] == 5'b11100) begin
			num_fetch = 1'b0;
		end
	end

endmodule : fetcher
