module l2_cache #(parameter NUM_WAYS = 8,
              parameter WAYS_LOG_2 = $clog2(NUM_WAYS)) 
(
  input clk,

  /* Physical memory signals */
  input logic pmem_resp,
  input logic [255:0] pmem_rdata,
  output logic [31:0] pmem_address,
  output logic [255:0] pmem_wdata,
  output logic pmem_read,
  output logic pmem_write,

  /* L1 memory signals */
  input logic mem_read,
  input logic mem_write,
  // input logic [3:0] mem_byte_enable_cpu,
  input logic [31:0] mem_address,
  input logic [255:0] mem_wdata_l1,
  output logic mem_resp,
  output logic [255:0] mem_rdata_l1
);

logic tag_load;
logic valid_load;
logic dirty_load;
logic dirty_in;
logic dirty_out;

logic lru_load[NUM_WAYS];
logic [WAYS_LOG_2 - 1:0] lru_in [NUM_WAYS];
logic [WAYS_LOG_2 - 1:0] lru_out[NUM_WAYS];
logic [WAYS_LOG_2 - 1:0] _idx;
logic valid_out[NUM_WAYS];

logic hit;
logic [1:0] writing;

logic [255:0] mem_wdata;
logic [255:0] mem_rdata;
logic [31:0] mem_byte_enable;

assign mem_byte_enable = '1;

l2_cache_control #(NUM_WAYS, WAYS_LOG_2) control(.*);
l2_cache_datapath #(NUM_WAYS, WAYS_LOG_2) datapath(
    .mem_wdata(mem_wdata_l1),
  .mem_rdata(mem_rdata_l1),
  .*
);

// line_adapter bus (
//     .mem_wdata_line(mem_wdata),
//     .mem_rdata_line(mem_rdata),
//     .mem_wdata(mem_wdata_cpu),
//     .mem_rdata(mem_rdata_cpu),
//     .mem_byte_enable(mem_byte_enable_cpu),
//     .mem_byte_enable_line(mem_byte_enable),
//     .address(mem_address)
// );

endmodule : l2_cache
