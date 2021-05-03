module l2_cache_datapath #(parameter NUM_WAYS = 8,
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
  input logic [1:0] writing,
  
  input logic lru_load[NUM_WAYS],
  input logic [WAYS_LOG_2 - 1:0] lru_in [NUM_WAYS],
  output logic [WAYS_LOG_2 - 1:0] lru_out[NUM_WAYS],
  output logic [WAYS_LOG_2 - 1:0] _idx,
  output logic valid_out[NUM_WAYS]
);

logic _tag_load[NUM_WAYS];
logic _valid_load[NUM_WAYS];
logic _dirty_load[NUM_WAYS];
// logic _dirty_in[NUM_WAYS];
logic _dirty_out[NUM_WAYS];
logic _hit[NUM_WAYS];

logic [255:0] line_in, line_out[NUM_WAYS];
logic [23:0] address_tag, tag_out[NUM_WAYS];
logic [2:0]  set_index;
logic [31:0] mask[NUM_WAYS];

function void set_defaults();
  address_tag = mem_address[31:8];
  set_index = mem_address[7:5];
  _idx = 0;
  for (int i = 0; i < NUM_WAYS; i++) begin
    _tag_load[i] = 1'b0;
    _valid_load[i] = 1'b0;
    _dirty_load[i] = 1'b0;
    // _dirty_in[i] = 1'b0;
    mask[i] = 32'b0;
  end
endfunction

function logic [WAYS_LOG_2 - 1 : 0] find_idx();
  // Find idx if it is a hit
  for (logic [WAYS_LOG_2 : 0] i = 0; i < NUM_WAYS; i++) begin
    if (valid_out[i] && (tag_out[i] == address_tag)) begin
      return i;
    end
  end
  // Find first invalid idx
  for (logic [WAYS_LOG_2 : 0] i = 0; i < NUM_WAYS; i++) begin
    if (~valid_out[i]) begin
      return i;
    end
  end

  // Find LRU
  for (logic [WAYS_LOG_2 : 0] i = 0; i < NUM_WAYS; i++) begin
    if (lru_out[i] == (NUM_WAYS - 1)) begin
      return i;
    end
  end
  return 0;
endfunction

always_comb begin
  set_defaults();

  _idx = find_idx();
  _tag_load[_idx] = tag_load; 
  _valid_load[_idx] = valid_load; 
  _dirty_load[_idx] = dirty_load; 
  // _dirty_in[_idx] = dirty_in; 
  dirty_out = _dirty_out[_idx];
  
  hit = valid_out[_idx] && (tag_out[_idx] == address_tag);
  pmem_address = (_dirty_out[_idx]) ? {tag_out[_idx], mem_address[7:0]} : mem_address;
  mem_rdata = line_out[_idx];
  pmem_wdata = line_out[_idx];

  case(writing)
    2'b00: begin // load from memory
      mask[_idx] = 32'hFFFFFFFF;
      line_in = pmem_rdata;
    end
    2'b01: begin // write from cpu
      mask[_idx] = mem_byte_enable;
      line_in = mem_wdata;
    end
    default: begin // don't change data
      mask[_idx] = 32'b0;
      line_in = mem_wdata;
    end
	endcase
end

genvar i;
generate
  for (i = 0; i < NUM_WAYS; i++) begin : multiple_way_arrays
    data_array DM_cache (clk, mask[i], set_index, set_index, line_in, line_out[i]);
    array #(24, 0, 0) tag (clk, _tag_load[i], set_index, set_index, address_tag, tag_out[i]);
    array #(1, 0, 0) valid (clk, _valid_load[i], set_index, set_index, 1'b1, valid_out[i]);
    array #(1, 0, 0) dirty (clk, _dirty_load[i], set_index, set_index, dirty_in, _dirty_out[i]);
    array #(WAYS_LOG_2, NUM_WAYS-1, 1) lru (clk, lru_load[i], set_index, set_index, lru_in[i], lru_out[i]);
  end
endgenerate

/*
            control
               
              /
        0 1 2 3 4 5 6 7
valid:  1 1 0 0 0 0 0 0
lru:    1 0 0 0 0 0 0 0

for (int i = 0; i < 8; i++) begin
  array #(3) lru[i] (clk, lru_load[i], set_index, set_index, lru_in[i], lru_out[i]);
end

read/write:
if _idx is a hit:
  for (int j = 0; j < 8; j++) begin
    if (valid[j] && (lru_out[j] < lru_out[_idx])) begin
      lru_load[j] = 1'b1;
      lru_in[j] = lru_out[j] + 1;
    end
  begin
  lru_Load[_idx] = 1'b1;
  lru_in[_idx] = 3'b0;

miss:
  if (all_valid) begin
    for (int j = 0; j < NUM_WAYS; j++) begin
      lru_load[j] = 1'b1;
      lru_in[j] = lru_out[j] + 1;
    begin
  end else
    // go through valid arrays, find first idx that is invalid (idx)
    // idx = 0;
    // for (int i = 0; i < NUM_WAYS; i++) begin
    //   if (valid[i]) begin
    //     idx++;
    //   end
    // end
    for (int i = 0; i < _idx && i < NUM_WAYS; i++) begin
      lru_load[i] = 1'b1;
      lru_in[i] = lru_out[i] + 1;
    end
    lru_load[_idx] = 1'b1
    lru_in[_idx] = 3'b0;
  end
*/
endmodule : l2_cache_datapath

// module cache_datapath (
//   input clk,

//   /* CPU memory data signals */
//   input logic  [31:0]  mem_byte_enable,
//   input logic  [31:0]  mem_address,
//   input logic  [255:0] mem_wdata,
//   output logic [255:0] mem_rdata,

//   /* Physical memory data signals */
//   input  logic [255:0] pmem_rdata,
//   output logic [255:0] pmem_wdata,
//   output logic [31:0]  pmem_address,

//   /* Control signals */
//   input logic tag_load,
//   input logic valid_load,
//   input logic dirty_load,
//   input logic dirty_in,
//   output logic dirty_out,

//   output logic hit,
//   input logic [1:0] writing
// );

// logic [255:0] line_in, line_out;
// logic [23:0] address_tag, tag_out;
// logic [2:0]  set_index;
// logic [31:0] mask;
// logic valid_out;

// always_comb begin
//   address_tag = mem_address[31:8];
//   set_index = mem_address[7:5];
//   hit = valid_out && (tag_out == address_tag);
//   pmem_address = (dirty_out) ? {tag_out, mem_address[7:0]} : mem_address;
//   mem_rdata = line_out;
//   pmem_wdata = line_out;

//   case(writing)
//     2'b00: begin // load from memory
//       mask = 32'hFFFFFFFF;
//       line_in = pmem_rdata;
//     end
//     2'b01: begin // write from cpu
//       mask = mem_byte_enable;
//       line_in = mem_wdata;
//     end
//     default: begin // don't change data
//       mask = 32'b0;
//       line_in = mem_wdata;
//     end
// 	endcase
// end

// data_array DM_cache (clk, mask, set_index, set_index, line_in, line_out);
// array #(24) tag (clk, tag_load, set_index, set_index, address_tag, tag_out);
// array #(1) valid (clk, valid_load, set_index, set_index, 1'b1, valid_out);
// array #(1) dirty (clk, dirty_load, set_index, set_index, dirty_in, dirty_out);

// endmodule : cache_datapath
