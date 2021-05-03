
module array #(parameter width = 1,
                parameter default_val = 0,
                parameter is_lru = 0)
(
  input clk,
  input logic load,
  input logic [2:0] rindex,
  input logic [2:0] windex,
  input logic [width-1:0] datain,
  output logic [width-1:0] dataout
);

//logic [width-1:0] data [2:0] = '{default: '0};
logic [width-1:0] data [8];
initial begin
  data[0] = default_val;
  data[1] = default_val;
  data[2] = default_val;
  data[3] = default_val;
  data[4] = default_val;
  data[5] = default_val;
  data[6] = default_val;
  data[7] = default_val;
end

always_comb begin
  dataout = (load & ~is_lru & (rindex == windex)) ? datain : data[rindex];
end

always_ff @(posedge clk)
begin
    if(load)
        data[windex] <= datain;
end

endmodule : array
