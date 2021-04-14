module fetcher #(parameter width = 32)
(
	input  logic 				deq,
	input  logic 				i_mem_resp,
	input  logic 	[width-1:0] pc_addr,
	input  logic 	[width-1:0] i_mem_rdata,

	output logic 				i_mem_read,
	output logic 				rdy,
	output logic 	[width-1:0] out,
	output logic 	[width-1:0] i_mem_address
);

	assign i_mem_address 	= pc_addr;
	assign i_mem_read 		= deq;
	assign rdy 				= i_mem_resp;
	assign out  			= i_mem_rdata;

endmodule : fetcher
