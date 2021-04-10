import rv32i_types::*;

module acu #(parameter size = 8)
(
	input rs_t data[size],
	input logic[size-1:0] ready,
	output sal_t out[size]
);

sal_t out_alu[size];
sal_t out_cmp[size];

alu alu(data, ready, out_alu);
cmp cmp(data, ready, out_cmp);

always_comb begin
	for (int i = 0; i < size; i++) begin
		if (~acu_operation[next_rs]) begin
			out = out_alu;
		end else
			out = out_cmp;
		end
	end
end
