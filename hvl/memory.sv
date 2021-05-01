`include "tb_itf.sv"
module memory #(
    parameter DELAY_CYCLE=25,
    parameter MEMFILE="memory.lst"
)
(
    tb_itf.mem itf
);

    logic [7:0] mem [logic [31:0]];
    logic [31:0] read_buffer;
    logic [31:0] _addr;
    logic [31:0] faddr;
    logic [31:0] write_buffer;

    /* Initialize memory contents from memory.lst file */
    initial
    begin
        $readmemh(MEMFILE, mem);
        itf.mcb.error <= 1'b0;
        itf.mcb.resp <= 0;
    end

    logic _read, _write;
    always @(itf.mcb) begin
        _read <= itf.mcb.read;
        _write <= itf.mcb.write;
    end

    always_ff @(itf.mcb iff itf.mcb.write && !_write) begin

    end

    initial begin
        forever begin
            fork : k1
                begin
                    @(itf.mcb iff itf.mcb.write && !_write)
                        write();
                    disable k1;
                end
                begin
                    @(itf.mcb iff itf.mcb.read && !_read)
                        read();
                    disable k1;
                end
            join
        end
    end

    /* Write Operation */
    task write;
        faddr =  itf.mcb.addr;
        _addr = itf.mcb.addr; //address must be 4-byte aligned
        write_buffer = itf.mcb.wdata;
        fork : g
            begin
                // Do Write
                repeat (DELAY_CYCLE) @(itf.mcb);
                for (int i = 0; i < 4; ++i) begin
                    if (itf.mcb.byte_enable[i])
                        mem[_addr+i] = write_buffer[8*i +: 8];
                end
                itf.mcb.resp <= 1'b1;
                disable g;
            end
            begin
                // Ensure address does not change
                @(itf.mcb iff itf.mcb.addr != faddr) begin
                    itf.report_error("Memory Error: write address changed");
                    itf.mcb.error <= 1'b1;
                    disable g;
                end
            end
            begin
                // Ensure wdata does not change
                @(itf.mcb iff itf.mcb.wdata != write_buffer) begin
                    itf.report_error("Memory Error: write data changed");
                    itf.mcb.error <= 1'b1;
                    disable g;
                end
            end
            begin
                // Ensure mcb.write is asserted
                @(itf.mcb iff itf.mcb.write == 1'b0) begin
                    itf.report_error("Memory Error: write terminated prematurely");
                    itf.mcb.error <= 1'b1;
                    disable g;
                end
            end
            begin
                // Ensure mcb.read is not asserted
                @(itf.mcb iff itf.mcb.read) begin
                    itf.report_error("Memory Error: read asserted during write");
                    itf.mcb.error <= 1'b1;
                    disable g;
                end
            end
        join
        // Let write finish
        @(itf.mcb) itf.mcb.resp <= 1'b0;
    endtask

    /* Read Operation */
    task read;
        faddr = itf.mcb.addr;
        _addr = itf.mcb.addr; //address must be 4-byte aligned
        read_buffer = {mem[_addr+3], mem[_addr+2], mem[_addr+1], mem[_addr]};
        fork : f
            begin
                // Do Read
                repeat (DELAY_CYCLE) @(itf.mcb);
                itf.mcb.rdata <= read_buffer;
                itf.mcb.resp <= 1'b1;
                disable f;
            end
            begin
                // Ensure mcb.read is asserted
                @(itf.mcb iff itf.mcb.read == 1'b0) begin
                    itf.report_error("Memory Error: read terminated prematurely");
                    itf.mcb.error <= 1'b1;
                    disable f;
                end
            end
            begin
                // Ensure mcb.write is not asserted
                @(itf.mcb iff itf.mcb.write) begin
                    itf.report_error("Memory Error: write asserted during read");
                    itf.mcb.error <= 1'b1;
                    disable f;
                end
            end
            begin
                // Ensure address does not change
                @(itf.mcb iff itf.mcb.addr != faddr) begin
                    itf.report_error("Memory Error: read address changed");
                    itf.mcb.error <= 1'b1;
                    disable f;
                end
            end
        join
        // Let read finish
        @(itf.mcb) itf.mcb.resp <= 1'b0;
    endtask

endmodule : memory