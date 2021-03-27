/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER. */

module shadow_memory(cache_monitor_itf.cache_monitor cache_itf);

logic [255:0] _mem [logic [31:5]];

function void _new(string filepath);
    $readmemh(filepath, _mem);
endfunction

function automatic logic [31:0] read(logic [31:0] addr);
    logic [255:0] line;
    logic [31:0] rv;
    line = _mem[addr[31:5]];
    rv = line[8*{addr[4:2], 2'b00} +: 32];
    return rv;
endfunction

function automatic void write(logic [31:0] addr, logic [31:0] wdata,
                              logic [3:0] mem_byte_enable);
    logic [255:0] line;
    line = _mem[addr[31:5]];
    foreach (mem_byte_enable[i]) begin
        if (mem_byte_enable[i])
            line[8*({addr[4:2], 2'b00} + i) +: 8] = wdata[8*i +: 8];
    end
    _mem[addr[31:5]] = line;
endfunction


int errcount = 0;
initial begin
    logic [31:0] rdata;
    logic _read;
    _new("memory.lst");
    forever begin
        @(cache_itf.cmcb iff cache_itf.cmcb.read || cache_itf.cmcb.write)
        if (cache_itf.cmcb.read) begin
            rdata = read(cache_itf.cmcb.addr);
            _read = 1'b1;
        end
        else begin
            write(cache_itf.cmcb.addr, cache_itf.cmcb.wdata,
                     cache_itf.cmcb.mbe);
            _read = 1'b0;
        end
        @(cache_itf.cmcb iff cache_itf.cmcb.resp)
        if (_read) begin
            if (rdata != cache_itf.cmcb.rdata) begin
                $display("%0t: ShadowCache Error: Mismatch rdata:", $time,
                    " Expected %8h, Detected: %8h", rdata,
                    cache_itf.cmcb.rdata);
                errcount++;
            end
        end

    end
end


endmodule
