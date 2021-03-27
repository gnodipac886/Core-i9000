/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

`ifndef TB_ITF_SV
`define TB_ITF_SV
interface tb_itf
#(
    parameter int BURST_LEN = 64
)
(
    input bit clk
);
    logic [15:0] errcode;
    logic halt;
    logic [31:0] registers [32];
    logic sm_error = 1'b0;
    logic pm_error = 1'b0;

    logic rst=0, mem_resp=0, mem_read, mem_write;
    logic [BURST_LEN-1:0] mem_rdata, mem_wdata;
    logic [31:0] mem_address;
    mailbox #(string) path_mb;
    initial path_mb = new();

    // For Memory
    clocking mcb @(posedge clk);
        input read = mem_read, write = mem_write, addr = mem_address,
              wdata = mem_wdata, rst = rst;
        output resp = mem_resp, rdata = mem_rdata, error = pm_error;
    endclocking

    clocking tbcb @(posedge clk);
    //    output read = mem_read, write = mem_write, addr = mem_address,
    //          wdata = mem_wdata, rst = rst;
        input resp = mem_resp, rdata = mem_rdata, error = pm_error;
    endclocking

    // For Shadow Memory
    clocking smcb @(posedge clk);
        input read = mem_read, write = mem_write, addr = mem_address,
              wdata = mem_wdata, rst = rst, resp = mem_resp, rdata = mem_rdata;
        output error = sm_error;
    endclocking

    modport mem(clocking mcb, ref path_mb);
    modport tb(clocking tbcb, ref path_mb);
    modport sm(clocking tbcb, ref path_mb);
    modport dut(
        input clk, rst, mem_resp, mem_rdata,
        output mem_read, mem_write, mem_address, mem_wdata
    );

endinterface
`endif
