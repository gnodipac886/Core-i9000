module fetcher #(parameter width = 32)
(
	input  logic 				deq,
	input  logic 				mem_resp,
	input  logic 	[width-1:0] pc_addr,
	input  logic 	[width-1:0] mem_rdata,

	output logic 				mem_read,
	output logic 				rdy,
	output logic 	[width-1:0] out,
	output logic 	[width-1:0] mem_address
);

	assign mem_address 	= pc_addr;
	assign mem_read 	= deq;
	assign rdy 			= mem_resp;
	assign out  		= mem_rdata;

endmodule : fetcher
