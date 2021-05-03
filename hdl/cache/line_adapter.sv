module line_adapter #(parameter bus_size = 1)
(
  output logic [255:0] mem_wdata_line,
  input logic [255:0] mem_rdata_line,
  input logic [31:0] mem_wdata,
  output logic [32 * bus_size - 1:0] mem_rdata,
  input logic [3:0] mem_byte_enable,
  output logic [31:0] mem_byte_enable_line,
  input logic [31:0] address,
  input logic num_fetch
);

assign mem_wdata_line = {8{mem_wdata}};
assign mem_byte_enable_line = {28'h0, mem_byte_enable} << (address[4:2]*4);

always_comb begin
  if (~num_fetch) begin
    mem_rdata = { 32'h13, mem_rdata_line[(32*address[4:2]) +: 32] };  
  end 
  else begin 
    mem_rdata = mem_rdata_line[(32*address[4:2]) +: 64];
  end 
end

endmodule : line_adapter
