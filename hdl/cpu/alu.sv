import rv32i_types::*;

module alu #(parameter size=8)
    // this needs to be revised for ooo execution
    input rs_t data[size],
    input logic[size-1:0] ready,

    output logic sal_t out[size]
);

always_comb
begin
    for (int idx = 0; idx < size; idx++)
    begin
        if (ready[idx])
        begin
            unique case (data[idx].operation)
                alu_add:  out[idx].data = data[idx].r1 + data[idx].r2;
                alu_sll:  out[idx].data = data[idx].r1 << data[idx].r2[4:0];
                alu_sra:  out[idx].data = $signed(data[idx].r1) >>> data[idx].r2[4:0];
                alu_sub:  out[idx].data = data[idx].r1 - data[idx].r2;
                alu_xor:  out[idx].data = data[idx].r1 ^ data[idx].r2;
                alu_srl:  out[idx].data = data[idx].r1 >> data[idx].r2[4:0];
                alu_or:   out[idx].data = data[idx].r1 | data[idx].r2;
                alu_and:  out[idx].data = data[idx].r1 & data[idx].r2;
            endcase
            out[idx].rdy = 1'b1;
            out[idx].tag = data[idx].tag;
        end
        else 
        begin
            out[idx].rdy = 1'b0;
            out[idx].tag = 4'b0;
        end
    end
end

endmodule : alu