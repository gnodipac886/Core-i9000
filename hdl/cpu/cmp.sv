module cmp #(parameter size=8)
(
	input rs_t data[size],
    input logic[size-1:0] ready,

    output sal_t out[size]
);


always_comb
begin
    for (int idx = 0; idx < size; idx++)
    begin
        if (ready[idx])
        begin
            case (data[idx].operation)
				beq: out[idx].data = data[idx].r1 == data[idx].r2 ? '1 : '0;
				bne: out[idx].data = data[idx].r1 != data[idx].r2 ? '1 : '0;
				blt: out[idx].data = $signed(data[idx].r1) < $signed(data[idx].r2) ? '1 : '0;
				bge: out[idx].data = ($signed(data[idx].r1) > $signed(data[idx].r2) || $signed(data[idx].r1) == $signed(data[idx].r2))? '1 : '0;
				bltu: out[idx].data = data[idx].r1 < data[idx].r2 ? '1 : '0;
				bgeu: out[idx].data = (data[idx].r1 > data[idx].r2 || data[idx].r1 ==data[idx].r2) ? '1 : '0;
				default:;
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

endmodule : cmp