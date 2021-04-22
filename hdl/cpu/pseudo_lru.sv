module pseudo_lru #(parameter size = 8)
(
	input logic clk,
	input logic rst,
	input logic load,
	input logic [size - 1:0] set_p_lru,
	input logic [$clog2(size) - 1:0] mru_idx,
	output logic [$clog2(size) - 1:0] lru_idx
);
	logic	[size - 1:0]	p_lru;
	int						p_idx;

	always_comb begin
		lru_idx = 0;
		p_idx = 0;
		for (int i = $clog2(size) - 1; i >= 0; i--) begin
			lru_idx += (~p_lru[p_idx]) * 2**i;
			p_idx = 2 * p_idx + 1 + (~p_lru[p_idx]);
		end
	end

	always_ff @(posedge clk) begin
		if (rst) begin
			p_lru <= '1;
		end else if (load) begin
			p_lru <= set_p_lru;
		end
	end

endmodule : pseudo_lru
