module cache_datapath #(parameter NUM_WAYS = 2,
                        parameter WAYS_LOG_2 = $clog2(NUM_WAYS))
(
  input clk,

  /* CPU memory data signals */
  input logic  [31:0]  mem_byte_enable,
  input logic  [31:0]  mem_address,
  input logic  [255:0] mem_wdata,
  output logic [255:0] mem_rdata,

  /* Physical memory data signals */
  input  logic [255:0] pmem_rdata,
  output logic [255:0] pmem_wdata,
  output logic [31:0]  pmem_address,

  /* Control signals */
  input logic tag_load,
  input logic valid_load,
  input logic dirty_load,
  input logic dirty_in,
  output logic dirty_out,

  output logic hit,
  input logic [1:0] writing
);

logic [WAYS_LOG_2 - 1 : 0] _idx;
logic _tag_load[NUM_WAYS];
logic _valid_load[NUM_WAYS];
logic _dirty_load[NUM_WAYS];
logic _dirty_out[NUM_WAYS];
logic _hit[NUM_WAYS];

logic [255:0] line_in, line_out[NUM_WAYS];
logic [23:0] address_tag, tag_out[NUM_WAYS];
logic [2:0]  index;
logic [31:0] mask[NUM_WAYS];
logic valid_out[NUM_WAYS];

function void set_defaults();
  _idx = find_idx();
endfunction

function logic [WAYS_LOG_2 - 1 : 0] find_idx();
  // Find idx if it is a hit
  for (logic [WAYS_LOG_2 - 1 : 0] i = 0; i < NUM_WAYS; i++) begin
    if (valid_out[i] & (tag_out[i] == address_tag)) begin
      return i;
    end
  end
  // Find first invalid idx
  for (logic [WAYS_LOG_2 - 1 : 0] i = 0; i < NUM_WAYS; i++) begin
    if (~valid_out[i]) begin
      return i;
    end
  end

  // Find LRU
  for (logic [WAYS_LOG_2 - 1 : 0] i = 0; i < NUM_WAYS; i++) begin
    if (lru_out[i] == (NUM_WAYS - 1)) begin
      return i;
    end
  end
  return 0;
endfunction

always_comb begin
  set_defaults();

  address_tag = mem_address[31:8];
  index = mem_address[7:5];
  hit = valid_out[_idx] && (tag_out[_idx] == address_tag);
  pmem_address = (dirty_out[_idx]) ? {tag_out[_idx], mem_address[7:0]} : mem_address;
  mem_rdata = line_out[_idx];
  pmem_wdata = line_out[_idx];

  case(writing)
    2'b00: begin // load from memory
      mask[_idx] = 32'hFFFFFFFF;
      line_in[_idx] = pmem_rdata;
    end
    2'b01: begin // write from cpu
      mask[_idx] = mem_byte_enable;
      line_in[_idx] = mem_wdata;
    end
    default: begin // don't change data
      mask[_idx] = 32'b0;
      line_in[_idx] = mem_wdata;
    end
	endcase
end

generate : MULTIPLE_WAY_ARRAYS
  for (int i = 0; i < NUM_WAYS; i++) begin
    data_array DM_cache[i] (clk, mask[i], index, index, line_in, line_out[i]);
    array #(24) tag[i] (clk, tag_load[i], index, index, address_tag, tag_out[i]);
    array #(1) valid[i] (clk, valid_load[i], index, index, 1'b1, valid_out[i]);
    array #(1) dirty[i] (clk, dirty_load[i], index, index, dirty_in, dirty_out[i]);
    array #(3) lru[i] (clk, lru_load[i], index, index, lru_in[i], lru_out[i]);
  end
endgenerate

/*
            control
               
              /
        0 1 2 3 4 5 6 7
valid:  1 1 0 0 0 0 0 0
lru:    1 0 0 0 0 0 0 0

for (int i = 0; i < 8; i++) begin
  array #(3) lru[i] (clk, lru_load[i], index, index, lru_in[i], lru_out[i]);
end

read/write:
if i is a hit:
  for (int j = 0; j < 8; j++) begin
    if (lru_out[j] < lru_out[i]) begin
      lru_load[j] = 1'b1;
      lru_in[j] = lru_out[j] + 1;
    end
  begin
  lru_Load[i] = 1'b1;
  lru_in = 3'b0;

miss:
  if (all_valid) begin
    i = 7;
    for (int j = 0; j < 8; j++) begin
    if (lru_out[j] < lru_out[i]) begin
      lru_load[j] = 1'b1;
      lru_in[j] = lru_out[j] + 1;
    end
    begin
    lru_Load[i] <= 1'b1
    lru_in = 3'b0;
  end else
    // go through valid arrays, find first idx that is invalid (idx)
    // idx = 0;
    // for (int i = 0; i < 8; i++) begin
    //   if (valid[i]) begin
    //     idx++;
    //   end
    // end
    for (int i = 0; i < 8; i++) begin
      if (i >= idx)
        break;
      lru_load[i] = 1'b1;
      lru_in[i] = lru_out[i] + 1;
    end
    lru_load[idx] = 1'b1
    lru_in[idx] = 3'b0;
    valid_load[idx] = 1'b1;
  end
*/

endmodule : cache_datapath
