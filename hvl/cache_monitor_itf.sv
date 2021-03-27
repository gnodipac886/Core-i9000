/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

interface cache_monitor_itf(input clk);
    logic [31:0] addr, rdata, wdata;
    logic read, write;
    logic [3:0] mbe;
    logic resp;

    modport tb(
        output addr, rdata, wdata, read, write, mbe, resp
    );

    clocking cmcb @(posedge clk);
        input  addr, rdata, wdata, read, write, mbe, resp;
    endclocking
    modport cache_monitor(clocking cmcb);

endinterface
