import rv32i_types::*;

module cmp #(parameter size=8)
(
	input rs_t data[size],
	input logic[size-1:0] ready,

	output sal_t out[size]
);


always_comb begin
	for (int idx = 0; idx < size; idx++) begin
		out[idx].data = 0;
		if (ready[idx]) begin
			case (data[idx].cmp_opcode)
				cmp_beq: out[idx].data = data[idx].r1 == data[idx].r2 ? 32'd1 : 32'd0;
				cmp_bne: out[idx].data = data[idx].r1 != data[idx].r2 ? 32'd1 : 32'd0;
				cmp_blt: out[idx].data = $signed(data[idx].r1) < $signed(data[idx].r2) ? 32'd1 : 32'd0;
				cmp_bge: out[idx].data = ($signed(data[idx].r1) > $signed(data[idx].r2) || $signed(data[idx].r1) == $signed(data[idx].r2))? 32'd1 : 32'd0;
				cmp_bltu: out[idx].data = data[idx].r1 < data[idx].r2 ? 32'd1 : 32'd0;
				cmp_bgeu: out[idx].data = (data[idx].r1 > data[idx].r2 || data[idx].r1 ==data[idx].r2) ? 32'd1 : 32'd0;
				default:;
			endcase
			out[idx].rdy = 1'b1;
			out[idx].tag = data[idx].tag;
		end
		else begin
			out[idx].rdy = 1'b0;
			out[idx].tag = 4'b0;
		end
	end
end

endmodule : cmp